import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/cancel_session_usecase.dart';
import '../../domain/usecases/get_user_sessions_usecase.dart';
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
}
