import 'package:json_annotation/json_annotation.dart';

part 'extend_session_request_model.g.dart';

@JsonSerializable()
class ExtendSessionRequestModel {
  final String paymentMethodId;

  const ExtendSessionRequestModel({required this.paymentMethodId});

  factory ExtendSessionRequestModel.fromJson(Map<String, dynamic> json) => _$ExtendSessionRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExtendSessionRequestModelToJson(this);
}
