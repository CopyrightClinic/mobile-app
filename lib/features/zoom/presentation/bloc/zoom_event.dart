import 'package:equatable/equatable.dart';

abstract class ZoomEvent extends Equatable {
  const ZoomEvent();

  @override
  List<Object?> get props => [];
}

class InitializeZoom extends ZoomEvent {
  const InitializeZoom();
}

class JoinMeetingRequested extends ZoomEvent {
  final String meetingNumber;
  final String passcode;
  final String displayName;

  const JoinMeetingRequested({required this.meetingNumber, required this.passcode, required this.displayName});

  @override
  List<Object> get props => [meetingNumber, passcode, displayName];
}

class JoinMeetingWithId extends ZoomEvent {
  final String meetingId;

  const JoinMeetingWithId({required this.meetingId});

  @override
  List<Object> get props => [meetingId];
}

class LeaveMeetingRequested extends ZoomEvent {
  const LeaveMeetingRequested();
}

class MeetingStatusUpdated extends ZoomEvent {
  final String status;
  final String? message;

  const MeetingStatusUpdated({required this.status, this.message});

  @override
  List<Object?> get props => [status, message];
}

class ResetZoomState extends ZoomEvent {
  const ResetZoomState();
}
