import 'package:json_annotation/json_annotation.dart';

part 'auth_request_model.g.dart';

@JsonSerializable()
class SendEmailVerificationRequestModel {
  final String email;

  const SendEmailVerificationRequestModel({required this.email});

  factory SendEmailVerificationRequestModel.fromJson(Map<String, dynamic> json) => _$SendEmailVerificationRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SendEmailVerificationRequestModelToJson(this);
}

@JsonSerializable()
class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({required this.email, required this.password});

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) => _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}

@JsonSerializable()
class SignupRequestModel {
  final String email;
  final String password;
  @JsonKey(name: 'confirmPassword')
  final String confirmPassword;

  const SignupRequestModel({required this.email, required this.password, required this.confirmPassword});

  factory SignupRequestModel.fromJson(Map<String, dynamic> json) => _$SignupRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestModelToJson(this);
}

@JsonSerializable()
class VerifyOtpRequestModel {
  final String email;
  final String otp;

  const VerifyOtpRequestModel({required this.email, required this.otp});

  factory VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) => _$VerifyOtpRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpRequestModelToJson(this);
}
