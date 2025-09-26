// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_intent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetupIntentModel _$SetupIntentModelFromJson(Map<String, dynamic> json) =>
    SetupIntentModel(
      id: json['id'] as String,
      clientSecret: json['client_secret'] as String,
      status: json['status'] as String,
      customerId: json['customer_id'] as String?,
    );

Map<String, dynamic> _$SetupIntentModelToJson(SetupIntentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_secret': instance.clientSecret,
      'status': instance.status,
      'customer_id': instance.customerId,
    };
