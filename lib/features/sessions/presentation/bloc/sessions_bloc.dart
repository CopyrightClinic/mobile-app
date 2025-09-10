import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/cancel_session_usecase.dart';
import '../../domain/usecases/get_user_sessions_usecase.dart';
import '../../domain/entities/session_entity.dart';
import 'sessions_event.dart';
import 'sessions_state.dart';

class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {
  final GetUserSessionsUseCase getUserSessionsUseCase;
  final CancelSessionUseCase cancelSessionUseCase;

  SessionsBloc({required this.getUserSessionsUseCase, required this.cancelSessionUseCase}) : super(const SessionsInitial()) {
    on<LoadUserSessions>(_onLoadUserSessions);
    on<RefreshSessions>(_onRefreshSessions);
    on<SwitchToUpcoming>(_onSwitchToUpcoming);
    on<SwitchToCompleted>(_onSwitchToCompleted);
    on<CancelSessionRequested>(_onCancelSessionRequested);
    on<ScheduleSessionRequested>(_onScheduleSessionRequested);
    on<InitializeScheduleSession>(_onInitializeScheduleSession);
    on<DateSelected>(_onDateSelected);
    on<TimeSlotSelected>(_onTimeSlotSelected);
  }

  Future<void> _onLoadUserSessions(LoadUserSessions event, Emitter<SessionsState> emit) async {
    emit(const SessionsLoading());

    final result = await getUserSessionsUseCase(NoParams());

    result.fold((failure) => emit(SessionsError(message: failure.message ?? 'Failed to load sessions')), (sessions) {
      final upcomingSessions = sessions.where((session) => session.isUpcoming).toList();
      final completedSessions = sessions.where((session) => session.isCompleted).toList();

      emit(SessionsLoaded(upcomingSessions: upcomingSessions, completedSessions: completedSessions, currentTab: SessionsTab.upcoming));
    });
  }

  Future<void> _onRefreshSessions(RefreshSessions event, Emitter<SessionsState> emit) async {
    // Keep current state while refreshing
    if (state is SessionsLoaded) {
      final currentState = state as SessionsLoaded;

      final result = await getUserSessionsUseCase(NoParams());

      result.fold((failure) => emit(SessionsError(message: failure.message ?? 'Failed to refresh sessions')), (sessions) {
        final upcomingSessions = sessions.where((session) => session.isUpcoming).toList();
        final completedSessions = sessions.where((session) => session.isCompleted).toList();

        emit(currentState.copyWith(upcomingSessions: upcomingSessions, completedSessions: completedSessions));
      });
    } else {
      add(const LoadUserSessions());
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

    result.fold((failure) => emit(SessionsError(message: failure.message ?? 'Failed to cancel session')), (message) {
      emit(SessionCancelled(message: message));
      // Refresh sessions after cancellation
      add(const RefreshSessions());
    });
  }

  Future<void> _onScheduleSessionRequested(ScheduleSessionRequested event, Emitter<SessionsState> emit) async {
    emit(const SessionScheduleLoading());

    try {
      // Mock session creation - in real app this would call a use case
      await Future.delayed(const Duration(seconds: 1));

      final newSession = SessionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Copyright Consultation',
        scheduledDate: event.selectedDate,
        duration: const Duration(minutes: 30),
        price: 50.0,
        status: SessionStatus.upcoming,
        description: 'Copyright consultation session',
        createdAt: DateTime.now(),
      );

      emit(SessionScheduled(session: newSession));

      // Refresh sessions after scheduling
      add(const RefreshSessions());
    } catch (e) {
      emit(SessionScheduleError(message: 'Failed to schedule session: ${e.toString()}'));
    }
  }

  void _onInitializeScheduleSession(InitializeScheduleSession event, Emitter<SessionsState> emit) {
    final now = DateTime.now();
    final mondayOfWeek = now.add(Duration(days: (1 - now.weekday) % 7));

    final availableTimeSlots = [
      {'time': '9:00 AM – 9:30 AM', 'value': '09:00-09:30'},
      {'time': '10:30 AM – 11:00 AM', 'value': '10:30-11:00'},
      {'time': '2:00 PM – 2:30 PM', 'value': '14:00-14:30'},
      {'time': '3:00 PM – 3:30 PM', 'value': '15:00-15:30'},
    ];

    emit(ScheduleSessionState(selectedDate: mondayOfWeek, availableTimeSlots: availableTimeSlots));
  }

  void _onDateSelected(DateSelected event, Emitter<SessionsState> emit) {
    if (state is ScheduleSessionState) {
      final currentState = state as ScheduleSessionState;
      emit(
        currentState.copyWith(
          selectedDate: event.selectedDate,
          clearTimeSlot: true, // Reset time slot when date changes
        ),
      );
    }
  }

  void _onTimeSlotSelected(TimeSlotSelected event, Emitter<SessionsState> emit) {
    if (state is ScheduleSessionState) {
      final currentState = state as ScheduleSessionState;
      emit(currentState.copyWith(selectedTimeSlot: event.selectedTimeSlot));
    }
  }
}
