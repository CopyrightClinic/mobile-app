import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class SendEmailVerificationResponseModel {
  final String message;

  const SendEmailVerificationResponseModel({required this.message});

  factory SendEmailVerificationResponseModel.fromJson(Map<String, dynamic> json) => _$SendEmailVerificationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SendEmailVerificationResponseModelToJson(this);
}

@JsonSerializable()
class AuthResponseModel {
  final String message;
  final UserModel user;
  final String accessToken;

  const AuthResponseModel({required this.message, required this.user, required this.accessToken});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  UserEntity toEntity() => user.toEntity();
}

@JsonSerializable()
class SignupResponseModel {
  final String message;
  final UserModel user;
  final String accessToken;
  final bool? verificationEmailSent;

  const SignupResponseModel({required this.message, required this.user, required this.accessToken, this.verificationEmailSent});

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) => _$SignupResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupResponseModelToJson(this);

  UserEntity toEntity() => user.toEntity();
}

@JsonSerializable()
class VerifyOtpResponseModel {
  final String message;
  final bool isVerified;

  const VerifyOtpResponseModel({required this.message, required this.isVerified});

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) => _$VerifyOtpResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpResponseModelToJson(this);
}

@JsonSerializable()
class ForgotPasswordResponseModel {
  final String message;

  const ForgotPasswordResponseModel({required this.message});

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) => _$ForgotPasswordResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResponseModelToJson(this);
}

@JsonSerializable()
class VerifyPasswordResetOtpResponseModel {
  final String message;

  const VerifyPasswordResetOtpResponseModel({required this.message});

  factory VerifyPasswordResetOtpResponseModel.fromJson(Map<String, dynamic> json) => _$VerifyPasswordResetOtpResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyPasswordResetOtpResponseModelToJson(this);
}

@JsonSerializable()
class ResetPasswordResponseModel {
  final String message;

  const ResetPasswordResponseModel({required this.message});

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) => _$ResetPasswordResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordResponseModelToJson(this);
}
