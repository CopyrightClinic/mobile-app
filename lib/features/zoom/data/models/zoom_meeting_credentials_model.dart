import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/zoom_meeting_credentials_entity.dart';

part 'zoom_meeting_credentials_model.g.dart';

@JsonSerializable()
class ZoomMeetingCredentialsModel {
  @JsonKey(name: 'sdkKey')
  final String? sdkKey;

  @JsonKey(name: 'signature')
  final String signature;

  @JsonKey(name: 'meetingNumber')
  final String meetingNumber;

  @JsonKey(name: 'password')
  final String password;

  @JsonKey(name: 'role')
  final int? role;

  @JsonKey(name: 'userName')
  final String userName;

  @JsonKey(name: 'userEmail')
  final String? userEmail;

  const ZoomMeetingCredentialsModel({
    this.sdkKey,
    required this.signature,
    required this.meetingNumber,
    required this.password,
    this.role,
    required this.userName,
    this.userEmail,
  });

  factory ZoomMeetingCredentialsModel.fromJson(Map<String, dynamic> json) => _$ZoomMeetingCredentialsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoomMeetingCredentialsModelToJson(this);

  ZoomMeetingCredentialsEntity toEntity() {
    return ZoomMeetingCredentialsEntity(signature: signature, meetingNumber: meetingNumber, password: password, userName: userName);
  }
}
