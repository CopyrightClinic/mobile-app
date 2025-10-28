import 'package:equatable/equatable.dart';
import '../../../../core/utils/enumns/ui/zoom_meeting_status.dart';

abstract class ZoomState extends Equatable {
  const ZoomState();

  @override
  List<Object?> get props => [];
}

class ZoomInitial extends ZoomState {
  const ZoomInitial();
}

class ZoomInitializing extends ZoomState {
  const ZoomInitializing();
}

class ZoomInitialized extends ZoomState {
  const ZoomInitialized();
}

class ZoomInitializationFailed extends ZoomState {
  final String message;

  const ZoomInitializationFailed({required this.message});

  @override
  List<Object> get props => [message];
}

class ZoomFetchingCredentials extends ZoomState {
  final String meetingId;

  const ZoomFetchingCredentials({required this.meetingId});

  @override
  List<Object> get props => [meetingId];
}

class ZoomJoining extends ZoomState {
  final String meetingNumber;

  const ZoomJoining({required this.meetingNumber});

  @override
  List<Object> get props => [meetingNumber];
}

class ZoomMeetingActive extends ZoomState {
  final ZoomMeetingStatus status;
  final String? message;
  final String? sessionId;

  const ZoomMeetingActive({required this.status, this.message, this.sessionId});

  @override
  List<Object?> get props => [status, message, sessionId];

  bool get isWaiting => status.isWaiting;
  bool get isConnecting => status.isConnecting;
  bool get isInMeeting => status.isActive;
}

class ZoomMeetingEnded extends ZoomState {
  final String? message;

  const ZoomMeetingEnded({this.message});

  @override
  List<Object?> get props => [message];
}

class ZoomMeetingFailed extends ZoomState {
  final String message;

  const ZoomMeetingFailed({required this.message});

  @override
  List<Object> get props => [message];
}
