import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cancel_session_request_response_entity.dart';

part 'cancel_session_request_response_model.g.dart';

@JsonSerializable()
class CancelSessionRequestResponseModel {
  final String? message;

  const CancelSessionRequestResponseModel({this.message});

  factory CancelSessionRequestResponseModel.fromJson(Map<String, dynamic> json) => _$CancelSessionRequestResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CancelSessionRequestResponseModelToJson(this);

  CancelSessionRequestResponseEntity toEntity() {
    return CancelSessionRequestResponseEntity(message: message);
  }
}
