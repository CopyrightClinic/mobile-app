import 'package:json_annotation/json_annotation.dart';

part 'payment_request_model.g.dart';

@JsonSerializable()
class CreatePaymentMethodRequestModel {
  final String stripePaymentMethodId;
  final bool isDefault;

  const CreatePaymentMethodRequestModel({required this.stripePaymentMethodId, required this.isDefault});

  factory CreatePaymentMethodRequestModel.fromJson(Map<String, dynamic> json) => _$CreatePaymentMethodRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentMethodRequestModelToJson(this);
}
