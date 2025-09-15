import 'package:equatable/equatable.dart';

abstract class SessionsEvent extends Equatable {
  const SessionsEvent();

  @override
  List<Object> get props => [];
}

class LoadUserSessions extends SessionsEvent {
  const LoadUserSessions();
}

class RefreshSessions extends SessionsEvent {
  const RefreshSessions();
}

class SwitchToUpcoming extends SessionsEvent {
  const SwitchToUpcoming();
}

class SwitchToCompleted extends SessionsEvent {
  const SwitchToCompleted();
}

class CancelSessionRequested extends SessionsEvent {
  final String sessionId;
  final String reason;

  const CancelSessionRequested({required this.sessionId, required this.reason});

  @override
  List<Object> get props => [sessionId, reason];
}

class JoinSessionRequested extends SessionsEvent {
  final String sessionId;

  const JoinSessionRequested({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class ScheduleSessionRequested extends SessionsEvent {
  final DateTime selectedDate;
  final String selectedTimeSlot;

  const ScheduleSessionRequested({required this.selectedDate, required this.selectedTimeSlot});

  @override
  List<Object> get props => [selectedDate, selectedTimeSlot];
}

class DateSelected extends SessionsEvent {
  final DateTime selectedDate;

  const DateSelected({required this.selectedDate});

  @override
  List<Object> get props => [selectedDate];
}

class TimeSlotSelected extends SessionsEvent {
  final String selectedTimeSlot;

  const TimeSlotSelected({required this.selectedTimeSlot});

  @override
  List<Object> get props => [selectedTimeSlot];
}

class InitializeScheduleSession extends SessionsEvent {
  const InitializeScheduleSession();
}

class LoadSessionAvailability extends SessionsEvent {
  final String timezone;

  const LoadSessionAvailability({required this.timezone});

  @override
  List<Object> get props => [timezone];
}
