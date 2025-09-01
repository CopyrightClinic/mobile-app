// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendEmailVerificationRequestModel _$SendEmailVerificationRequestModelFromJson(
  Map<String, dynamic> json,
) => SendEmailVerificationRequestModel(email: json['email'] as String);

Map<String, dynamic> _$SendEmailVerificationRequestModelToJson(
  SendEmailVerificationRequestModel instance,
) => <String, dynamic>{'email': instance.email};

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) =>
    LoginRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestModelToJson(LoginRequestModel instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

SignupRequestModel _$SignupRequestModelFromJson(Map<String, dynamic> json) =>
    SignupRequestModel(
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );

Map<String, dynamic> _$SignupRequestModelToJson(SignupRequestModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
    };

VerifyOtpRequestModel _$VerifyOtpRequestModelFromJson(
  Map<String, dynamic> json,
) => VerifyOtpRequestModel(
  email: json['email'] as String,
  otp: json['otp'] as String,
);

Map<String, dynamic> _$VerifyOtpRequestModelToJson(
  VerifyOtpRequestModel instance,
) => <String, dynamic>{'email': instance.email, 'otp': instance.otp};

ForgotPasswordRequestModel _$ForgotPasswordRequestModelFromJson(
  Map<String, dynamic> json,
) => ForgotPasswordRequestModel(email: json['email'] as String);

Map<String, dynamic> _$ForgotPasswordRequestModelToJson(
  ForgotPasswordRequestModel instance,
) => <String, dynamic>{'email': instance.email};

ResetPasswordRequestModel _$ResetPasswordRequestModelFromJson(
  Map<String, dynamic> json,
) => ResetPasswordRequestModel(
  email: json['email'] as String,
  otp: json['otp'] as String,
  newPassword: json['newPassword'] as String,
  confirmPassword: json['confirmPassword'] as String,
);

Map<String, dynamic> _$ResetPasswordRequestModelToJson(
  ResetPasswordRequestModel instance,
) => <String, dynamic>{
  'email': instance.email,
  'otp': instance.otp,
  'newPassword': instance.newPassword,
  'confirmPassword': instance.confirmPassword,
};
