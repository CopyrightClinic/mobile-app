// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendEmailVerificationResponseModel _$SendEmailVerificationResponseModelFromJson(
  Map<String, dynamic> json,
) => SendEmailVerificationResponseModel(message: json['message'] as String);

Map<String, dynamic> _$SendEmailVerificationResponseModelToJson(
  SendEmailVerificationResponseModel instance,
) => <String, dynamic>{'message': instance.message};

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      message: json['message'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
      'accessToken': instance.accessToken,
    };

SignupResponseModel _$SignupResponseModelFromJson(Map<String, dynamic> json) =>
    SignupResponseModel(
      message: json['message'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      verificationEmailSent: json['verificationEmailSent'] as bool?,
    );

Map<String, dynamic> _$SignupResponseModelToJson(
  SignupResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'user': instance.user,
  'accessToken': instance.accessToken,
  'verificationEmailSent': instance.verificationEmailSent,
};

VerifyOtpResponseModel _$VerifyOtpResponseModelFromJson(
  Map<String, dynamic> json,
) => VerifyOtpResponseModel(
  message: json['message'] as String,
  isVerified: json['isVerified'] as bool,
);

Map<String, dynamic> _$VerifyOtpResponseModelToJson(
  VerifyOtpResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'isVerified': instance.isVerified,
};
