import 'package:equatable/equatable.dart';

abstract class SessionDetailsEvent extends Equatable {
  const SessionDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadSessionDetails extends SessionDetailsEvent {
  final String sessionId;

  const LoadSessionDetails({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class CancelSessionFromDetails extends SessionDetailsEvent {
  final String sessionId;
  final String reason;

  const CancelSessionFromDetails({required this.sessionId, required this.reason});

  @override
  List<Object> get props => [sessionId, reason];
}
