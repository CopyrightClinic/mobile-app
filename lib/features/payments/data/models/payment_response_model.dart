import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_method_entity.dart';
import 'payment_method_model.dart';

part 'payment_response_model.g.dart';

@JsonSerializable()
class CreatePaymentMethodResponseModel {
  final String message;
  final PaymentMethodModel paymentMethod;

  const CreatePaymentMethodResponseModel({required this.message, required this.paymentMethod});

  factory CreatePaymentMethodResponseModel.fromJson(Map<String, dynamic> json) => _$CreatePaymentMethodResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentMethodResponseModelToJson(this);

  PaymentMethodEntity toEntity() => paymentMethod.toEntity();
}
