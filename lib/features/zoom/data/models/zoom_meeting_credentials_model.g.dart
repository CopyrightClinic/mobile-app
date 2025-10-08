// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zoom_meeting_credentials_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoomMeetingCredentialsModel _$ZoomMeetingCredentialsModelFromJson(
  Map<String, dynamic> json,
) => ZoomMeetingCredentialsModel(
  sdkKey: json['sdkKey'] as String?,
  signature: json['signature'] as String,
  meetingNumber: json['meetingNumber'] as String,
  password: json['password'] as String,
  role: (json['role'] as num?)?.toInt(),
  userName: json['userName'] as String,
  userEmail: json['userEmail'] as String?,
);

Map<String, dynamic> _$ZoomMeetingCredentialsModelToJson(
  ZoomMeetingCredentialsModel instance,
) => <String, dynamic>{
  'sdkKey': instance.sdkKey,
  'signature': instance.signature,
  'meetingNumber': instance.meetingNumber,
  'password': instance.password,
  'role': instance.role,
  'userName': instance.userName,
  'userEmail': instance.userEmail,
};
