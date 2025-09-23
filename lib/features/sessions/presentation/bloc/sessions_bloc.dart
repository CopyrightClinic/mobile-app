import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/timezone_helper.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/enumns/ui/session_status.dart';
import '../../../../core/utils/enumns/ui/sessions_tab.dart';
import '../../domain/usecases/cancel_session_usecase.dart';
import '../../domain/usecases/get_user_sessions_usecase.dart';
import '../../domain/usecases/get_session_availability_usecase.dart';
import '../../domain/usecases/book_session_usecase.dart';
import '../../domain/entities/session_entity.dart';
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
  }) : super(const SessionsInitial()) {
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
    emit(const SessionsLoading());

    final result = await getUserSessionsUseCase(NoParams());

    result.fold((failure) => emit(SessionsError(message: failure.message ?? AppStrings.failedToLoadSessions)), (sessions) {
      final upcomingSessions = sessions.where((session) => session.isUpcoming).toList();
      final completedSessions = sessions.where((session) => session.isCompleted).toList();

      emit(SessionsLoaded(upcomingSessions: upcomingSessions, completedSessions: completedSessions, currentTab: SessionsTab.upcoming));
    });
  }

  Future<void> _onRefreshSessions(RefreshSessions event, Emitter<SessionsState> emit) async {
    if (state is SessionsLoaded) {
      final currentState = state as SessionsLoaded;

      final result = await getUserSessionsUseCase(NoParams());

      result.fold((failure) => emit(SessionsError(message: failure.message ?? AppStrings.failedToRefreshSessions)), (sessions) {
        final upcomingSessions = sessions.where((session) => session.isUpcoming).toList();
        final completedSessions = sessions.where((session) => session.isCompleted).toList();

        emit(currentState.copyWith(upcomingSessions: upcomingSessions, completedSessions: completedSessions));
      });
    } else {
      await _onLoadUserSessions(const LoadUserSessions(), emit);
    }
  }

  void _onSwitchToUpcoming(SwitchToUpcoming event, Emitter<SessionsState> emit) {
    if (state is SessionsLoaded) {
      final currentState = state as SessionsLoaded;
      emit(currentState.copyWith(currentTab: SessionsTab.upcoming));
    }
  }

  void _onSwitchToCompleted(SwitchToCompleted event, Emitter<SessionsState> emit) {
    if (state is SessionsLoaded) {
      final currentState = state as SessionsLoaded;
      emit(currentState.copyWith(currentTab: SessionsTab.completed));
    }
  }

  Future<void> _onCancelSessionRequested(CancelSessionRequested event, Emitter<SessionsState> emit) async {
    emit(SessionCancelLoading(sessionId: event.sessionId));

    final result = await cancelSessionUseCase(CancelSessionParams(sessionId: event.sessionId, reason: event.reason));

    await result.fold((failure) async => emit(SessionsError(message: failure.message ?? AppStrings.failedToCancelSession)), (message) async {
      emit(SessionCancelled(message: message));
      await _onRefreshSessions(const RefreshSessions(), emit);
    });
  }

  Future<void> _onScheduleSessionRequested(ScheduleSessionRequested event, Emitter<SessionsState> emit) async {
    emit(const SessionScheduleLoading());

    try {
      await Future.delayed(const Duration(seconds: 1));

      final newSession = SessionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: AppStrings.copyrightConsultation,
        scheduledDate: event.selectedDate,
        duration: const Duration(minutes: 30),
        price: 50.0,
        status: SessionStatus.upcoming,
        description: AppStrings.copyrightConsultationSession,
        createdAt: DateTime.now(),
      );

      emit(SessionScheduled(session: newSession));
    } catch (e) {
      emit(SessionScheduleError(message: '${AppStrings.failedToScheduleSessionGeneric}: ${e.toString()}'));
    }
  }

  Future<void> _onInitializeScheduleSession(InitializeScheduleSession event, Emitter<SessionsState> emit) async {
    final now = DateTime.now();
    emit(ScheduleSessionState(selectedDate: now, isLoadingAvailability: true));

    final String currentTimeZone = await TimezoneHelper.getUserTimezone();
    await _onLoadSessionAvailability(LoadSessionAvailability(timezone: currentTimeZone), emit);
  }

  void _onDateSelected(DateSelected event, Emitter<SessionsState> emit) {
    if (state is ScheduleSessionState) {
      final currentState = state as ScheduleSessionState;
      emit(currentState.copyWith(selectedDate: event.selectedDate, clearTimeSlot: true));
    }
  }

  void _onTimeSlotSelected(TimeSlotSelected event, Emitter<SessionsState> emit) {
    if (state is ScheduleSessionState) {
      final currentState = state as ScheduleSessionState;
      emit(currentState.copyWith(selectedTimeSlot: event.selectedTimeSlot));
    }
  }

  Future<void> _onLoadSessionAvailability(LoadSessionAvailability event, Emitter<SessionsState> emit) async {
    if (state is ScheduleSessionState) {
      final currentState = state as ScheduleSessionState;
      emit(currentState.copyWith(isLoadingAvailability: true));

      final result = await getSessionAvailabilityUseCase(event.timezone);

      result.fold(
        (failure) {
          emit(currentState.copyWith(isLoadingAvailability: false, errorMessage: failure.message ?? AppStrings.failedToLoadSessionAvailability));
        },
        (availability) {
          DateTime selectedDate = currentState.selectedDate;
          if (availability.days.isNotEmpty) {
            final availableDate = availability.days.firstWhere((day) => day.slots.isNotEmpty, orElse: () => availability.days.first);
            selectedDate = availableDate.date;
          }

          emit(
            currentState.copyWith(
              availability: availability,
              selectedDate: selectedDate,
              isLoadingAvailability: false,
              clearTimeSlot: true,
              clearError: true,
            ),
          );
        },
      );
    }
  }

  Future<void> _onBookSessionRequested(BookSessionRequested event, Emitter<SessionsState> emit) async {
    emit(const SessionBookLoading());

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
        emit(SessionBookError(message: failure.message ?? AppStrings.failedToBookSession));
      },
      (response) {
        emit(SessionBooked(response: response));
      },
    );
  }
}
