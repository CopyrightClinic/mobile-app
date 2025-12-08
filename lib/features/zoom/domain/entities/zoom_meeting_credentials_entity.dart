import 'package:equatable/equatable.dart';

class ZoomMeetingCredentialsEntity extends Equatable {
  final String signature;
  final String meetingNumber;
  final String password;
  final String userName;

  const ZoomMeetingCredentialsEntity({required this.signature, required this.meetingNumber, required this.password, required this.userName});

  @override
  List<Object?> get props => [signature, meetingNumber, password, userName];
}
