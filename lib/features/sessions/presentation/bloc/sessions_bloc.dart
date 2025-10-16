import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/timezone_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/enumns/ui/sessions_tab.dart';
import '../../domain/usecases/cancel_session_usecase.dart';
import '../../domain/usecases/get_user_sessions_usecase.dart';
import '../../domain/usecases/get_session_availability_usecase.dart';
import '../../domain/usecases/book_session_usecase.dart';
import 'sessions_event.dart';
import 'sessions_state.dart';

class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {
  final GetUserSessionsUseCase getUserSessionsUseCase;
  final CancelSessionUseCase cancelSessionUseCase;
  final GetSessionAvailabilityUseCase getSessionAvailabilityUseCase;
  final BookSessionUseCase bookSessionUseCase;

  SessionsBloc({
    required this.getUserSessionsUseCase,
    required this.cancelSessionUseCase,
    required this.getSessionAvailabilityUseCase,
    required this.bookSessionUseCase,
  }) : super(const SessionsState()) {
    on<LoadUserSessions>(_onLoadUserSessions);
    on<RefreshSessions>(_onRefreshSessions);
    on<SwitchToUpcoming>(_onSwitchToUpcoming);
    on<SwitchToCompleted>(_onSwitchToCompleted);
    on<CancelSessionRequested>(_onCancelSessionRequested);
    on<ScheduleSessionRequested>(_onScheduleSessionRequested);
    on<InitializeScheduleSession>(_onInitializeScheduleSession);
    on<DateSelected>(_onDateSelected);
    on<TimeSlotSelected>(_onTimeSlotSelected);
    on<LoadSessionAvailability>(_onLoadSessionAvailability);
    on<BookSessionRequested>(_onBookSessionRequested);
  }

  Future<void> _onLoadUserSessions(LoadUserSessions event, Emitter<SessionsState> emit) async {
    emit(state.copyWith(isLoadingSessions: true, clearError: true, clearSuccess: true));

    final String timezone = await TimezoneHelper.getUserTimezone();
    final result = await getUserSessionsUseCase(GetUserSessionsParams(timezone: timezone));

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingSessions: false,
          errorMessage: failure.message ?? AppStrings.failedToLoadSessions,
          lastOperation: SessionsOperation.loadSessions,
        ),
      ),
      (sessions) {
        final upcomingSessions = sessions.where((session) => session.isUpcoming).toList();
        final completedSessions = sessions.where((session) => session.isCompleted).toList();

        emit(
          state.copyWith(
            upcomingSessions: upcomingSessions,
            completedSessions: completedSessions,
            isLoadingSessions: false,
            currentTab: SessionsTab.upcoming,
            clearError: true,
            lastOperation: SessionsOperation.loadSessions,
          ),
        );
      },
    );
  }

  Future<void> _onRefreshSessions(RefreshSessions event, Emitter<SessionsState> emit) async {
    if (state.hasData) {
      final String timezone = await TimezoneHelper.getUserTimezone();
      final result = await getUserSessionsUseCase(GetUserSessionsParams(timezone: timezone));

      result.fold(
        (failure) =>
            emit(state.copyWith(errorMessage: failure.message ?? AppStrings.failedToRefreshSessions, lastOperation: SessionsOperation.loadSessions)),
        (sessions) {
          final upcomingSessions = sessions.where((session) => session.isUpcoming).toList();
          final completedSessions = sessions.where((session) => session.isCompleted).toList();

          emit(state.copyWith(upcomingSessions: upcomingSessions, completedSessions: completedSessions, clearError: true));
        },
      );
    } else {
      await _onLoadUserSessions(const LoadUserSessions(), emit);
    }
  }

  void _onSwitchToUpcoming(SwitchToUpcoming event, Emitter<SessionsState> emit) {
    if (state.hasData) {
      emit(state.copyWith(currentTab: SessionsTab.upcoming));
    }
  }

  void _onSwitchToCompleted(SwitchToCompleted event, Emitter<SessionsState> emit) {
    if (state.hasData) {
      emit(state.copyWith(currentTab: SessionsTab.completed));
    }
  }

  Future<void> _onCancelSessionRequested(CancelSessionRequested event, Emitter<SessionsState> emit) async {
    if (!state.hasData) return;

    emit(state.copyWith(isProcessingCancel: true, cancellingSessionId: event.sessionId, clearError: true, clearSuccess: true));

    final result = await cancelSessionUseCase(CancelSessionParams(sessionId: event.sessionId, reason: event.reason));

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          isProcessingCancel: false,
          errorMessage: failure.message ?? AppStrings.failedToCancelSession,
          lastOperation: SessionsOperation.cancelSession,
          clearCancellingSessionId: true,
        ),
      ),
      (response) async {
        emit(
          state.copyWith(
            isProcessingCancel: false,
            successMessage: response.message,
            lastOperation: SessionsOperation.cancelSession,
            clearCancellingSessionId: true,
          ),
        );
        await _onRefreshSessions(const RefreshSessions(), emit);
      },
    );
  }

  Future<void> _onScheduleSessionRequested(ScheduleSessionRequested event, Emitter<SessionsState> emit) async {
    emit(state.copyWith(isProcessingSchedule: true, clearError: true, clearSuccess: true));

    try {
      await Future.delayed(const Duration(seconds: 1));

      emit(
        state.copyWith(
          isProcessingSchedule: false,
          successMessage: AppStrings.sessionScheduledSuccessfully,
          lastOperation: SessionsOperation.scheduleSession,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isProcessingSchedule: false,
          errorMessage: '${AppStrings.failedToScheduleSessionGeneric}: ${e.toString()}',
          lastOperation: SessionsOperation.scheduleSession,
        ),
      );
    }
  }

  Future<void> _onInitializeScheduleSession(InitializeScheduleSession event, Emitter<SessionsState> emit) async {
    final now = DateTime.now();
    emit(state.copyWith(selectedDate: now, isLoadingAvailability: true, clearError: true, clearSuccess: true, clearTimeSlot: true));

    final String currentTimeZone = await TimezoneHelper.getUserTimezone();
    await _onLoadSessionAvailability(LoadSessionAvailability(timezone: currentTimeZone), emit);
  }

  void _onDateSelected(DateSelected event, Emitter<SessionsState> emit) {
    if (state.isScheduling) {
      emit(state.copyWith(selectedDate: event.selectedDate, clearTimeSlot: true));
    }
  }

  void _onTimeSlotSelected(TimeSlotSelected event, Emitter<SessionsState> emit) {
    if (state.isScheduling) {
      emit(state.copyWith(selectedTimeSlot: event.selectedTimeSlot));
    }
  }

  Future<void> _onLoadSessionAvailability(LoadSessionAvailability event, Emitter<SessionsState> emit) async {
    if (!state.isScheduling) return;

    emit(state.copyWith(isLoadingAvailability: true));

    final result = await getSessionAvailabilityUseCase(event.timezone);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoadingAvailability: false,
            errorMessage: failure.message ?? AppStrings.failedToLoadSessionAvailability,
            lastOperation: SessionsOperation.loadAvailability,
          ),
        );
      },
      (availability) {
        DateTime selectedDate = state.selectedDate!;
        if (availability.days.isNotEmpty) {
          final availableDate = availability.days.firstWhere((day) => day.slots.isNotEmpty, orElse: () => availability.days.first);
          selectedDate = availableDate.date;
        }

        emit(
          state.copyWith(
            availability: availability,
            selectedDate: selectedDate,
            isLoadingAvailability: false,
            clearTimeSlot: true,
            clearError: true,
            lastOperation: SessionsOperation.loadAvailability,
          ),
        );
      },
    );
  }

  Future<void> _onBookSessionRequested(BookSessionRequested event, Emitter<SessionsState> emit) async {
    emit(state.copyWith(isProcessingBook: true, clearError: true, clearSuccess: true));

    final result = await bookSessionUseCase(
      BookSessionParams(
        stripePaymentMethodId: event.stripePaymentMethodId,
        date: event.date,
        startTime: event.startTime,
        endTime: event.endTime,
        summary: event.summary,
        timezone: event.timezone,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isProcessingBook: false,
            errorMessage: failure.message ?? AppStrings.failedToBookSession,
            lastOperation: SessionsOperation.bookSession,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            isProcessingBook: false,
            bookSessionResponse: response,
            successMessage: response.message,
            lastOperation: SessionsOperation.bookSession,
          ),
        );
      },
    );
  }
}
