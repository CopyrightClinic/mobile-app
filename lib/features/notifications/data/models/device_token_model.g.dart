// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterDeviceTokenRequestModel _$RegisterDeviceTokenRequestModelFromJson(
  Map<String, dynamic> json,
) => RegisterDeviceTokenRequestModel(token: json['token'] as String);

Map<String, dynamic> _$RegisterDeviceTokenRequestModelToJson(
  RegisterDeviceTokenRequestModel instance,
) => <String, dynamic>{'token': instance.token};

DeviceTokenModel _$DeviceTokenModelFromJson(Map<String, dynamic> json) =>
    DeviceTokenModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      lastActiveAt: json['lastActiveAt'] as String,
    );

Map<String, dynamic> _$DeviceTokenModelToJson(DeviceTokenModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'lastActiveAt': instance.lastActiveAt,
    };

RegisterDeviceTokenResponseModel _$RegisterDeviceTokenResponseModelFromJson(
  Map<String, dynamic> json,
) => RegisterDeviceTokenResponseModel(
  message: json['message'] as String,
  deviceToken: DeviceTokenModel.fromJson(
    json['deviceToken'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$RegisterDeviceTokenResponseModelToJson(
  RegisterDeviceTokenResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'deviceToken': instance.deviceToken,
};
