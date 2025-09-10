import 'package:equatable/equatable.dart';
import '../../domain/entities/session_entity.dart';

enum SessionsTab { upcoming, completed }

abstract class SessionsState extends Equatable {
  const SessionsState();

  @override
  List<Object?> get props => [];
}

class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

class SessionsLoaded extends SessionsState {
  final List<SessionEntity> upcomingSessions;
  final List<SessionEntity> completedSessions;
  final SessionsTab currentTab;

  const SessionsLoaded({required this.upcomingSessions, required this.completedSessions, required this.currentTab});

  @override
  List<Object> get props => [upcomingSessions, completedSessions, currentTab];

  List<SessionEntity> get currentSessions {
    return currentTab == SessionsTab.upcoming ? upcomingSessions : completedSessions;
  }

  SessionsLoaded copyWith({List<SessionEntity>? upcomingSessions, List<SessionEntity>? completedSessions, SessionsTab? currentTab}) {
    return SessionsLoaded(
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      currentTab: currentTab ?? this.currentTab,
    );
  }
}

class SessionsError extends SessionsState {
  final String message;

  const SessionsError({required this.message});

  @override
  List<Object> get props => [message];
}

class SessionCancelLoading extends SessionsState {
  final String sessionId;

  const SessionCancelLoading({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class SessionCancelled extends SessionsState {
  final String message;

  const SessionCancelled({required this.message});

  @override
  List<Object> get props => [message];
}

class SessionJoinLoading extends SessionsState {
  final String sessionId;

  const SessionJoinLoading({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class SessionJoined extends SessionsState {
  final SessionEntity session;

  const SessionJoined({required this.session});

  @override
  List<Object> get props => [session];
}

class SessionScheduleLoading extends SessionsState {
  const SessionScheduleLoading();
}

class SessionScheduled extends SessionsState {
  final SessionEntity session;

  const SessionScheduled({required this.session});

  @override
  List<Object> get props => [session];
}

class SessionScheduleError extends SessionsState {
  final String message;

  const SessionScheduleError({required this.message});

  @override
  List<Object> get props => [message];
}
