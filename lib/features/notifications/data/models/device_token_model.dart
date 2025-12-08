import 'package:json_annotation/json_annotation.dart';

part 'device_token_model.g.dart';

@JsonSerializable()
class RegisterDeviceTokenRequestModel {
  final String token;

  const RegisterDeviceTokenRequestModel({required this.token});

  factory RegisterDeviceTokenRequestModel.fromJson(Map<String, dynamic> json) => _$RegisterDeviceTokenRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDeviceTokenRequestModelToJson(this);
}

@JsonSerializable()
class DeviceTokenModel {
  final String id;
  final String userId;
  final String lastActiveAt;

  const DeviceTokenModel({required this.id, required this.userId, required this.lastActiveAt});

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) => _$DeviceTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceTokenModelToJson(this);
}

@JsonSerializable()
class RegisterDeviceTokenResponseModel {
  final String message;
  final DeviceTokenModel deviceToken;

  const RegisterDeviceTokenResponseModel({required this.message, required this.deviceToken});

  factory RegisterDeviceTokenResponseModel.fromJson(Map<String, dynamic> json) => _$RegisterDeviceTokenResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDeviceTokenResponseModelToJson(this);
}
