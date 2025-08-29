import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

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
