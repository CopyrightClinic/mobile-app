import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/decline_extension_response_entity.dart';

part 'decline_extension_response_model.g.dart';

@JsonSerializable()
class DeclineExtensionResponseModel {
  final bool? success;
  final String? message;

  const DeclineExtensionResponseModel({this.success, this.message});

  factory DeclineExtensionResponseModel.fromJson(Map<String, dynamic> json) => _$DeclineExtensionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeclineExtensionResponseModelToJson(this);

  DeclineExtensionResponseEntity toEntity() {
    return DeclineExtensionResponseEntity(success: success ?? true, message: message);
  }
}
