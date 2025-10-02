import 'package:equatable/equatable.dart';
import '../../domain/entities/session_details_entity.dart';

abstract class SessionDetailsState extends Equatable {
  const SessionDetailsState();

  @override
  List<Object?> get props => [];
}

class SessionDetailsInitial extends SessionDetailsState {
  const SessionDetailsInitial();
}

class SessionDetailsLoading extends SessionDetailsState {
  const SessionDetailsLoading();
}

class SessionDetailsLoaded extends SessionDetailsState {
  final SessionDetailsEntity sessionDetails;

  const SessionDetailsLoaded({required this.sessionDetails});

  @override
  List<Object> get props => [sessionDetails];
}

class SessionDetailsError extends SessionDetailsState {
  final String message;

  const SessionDetailsError({required this.message});

  @override
  List<Object> get props => [message];
}

class SessionDetailsCancelLoading extends SessionDetailsState {
  final SessionDetailsEntity sessionDetails;

  const SessionDetailsCancelLoading({required this.sessionDetails});

  @override
  List<Object> get props => [sessionDetails];
}

class SessionDetailsCancelled extends SessionDetailsState {
  final String message;

  const SessionDetailsCancelled({required this.message});

  @override
  List<Object> get props => [message];
}
