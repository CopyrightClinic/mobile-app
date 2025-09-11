// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: json['name'] as String?,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  address: json['address'] as String?,
  role: json['role'] as String,
  status: json['status'] as String,
  totalSessions: (json['totalSessions'] as num?)?.toInt(),
  stripeCustomerId: json['stripeCustomerId'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'role': instance.role,
  'status': instance.status,
  'totalSessions': instance.totalSessions,
  'stripeCustomerId': instance.stripeCustomerId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
