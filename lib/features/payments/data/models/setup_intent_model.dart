import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/setup_intent_entity.dart';

part 'setup_intent_model.g.dart';

@JsonSerializable()
class SetupIntentModel {
  final String id;
  @JsonKey(name: 'client_secret')
  final String clientSecret;
  final String status;
  @JsonKey(name: 'customer_id')
  final String? customerId;

  const SetupIntentModel({required this.id, required this.clientSecret, required this.status, this.customerId});

  factory SetupIntentModel.fromJson(Map<String, dynamic> json) => _$SetupIntentModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetupIntentModelToJson(this);

  SetupIntentEntity toEntity() => SetupIntentEntity(id: id, clientSecret: clientSecret, status: status, customerId: customerId);
}
