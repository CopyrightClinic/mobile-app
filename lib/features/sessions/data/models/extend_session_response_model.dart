import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/extend_session_response_entity.dart';

part 'extend_session_response_model.g.dart';

@JsonSerializable()
class ExtendSessionResponseModel {
  final String? message;

  const ExtendSessionResponseModel({this.message});

  factory ExtendSessionResponseModel.fromJson(Map<String, dynamic> json) => _$ExtendSessionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExtendSessionResponseModelToJson(this);

  ExtendSessionResponseEntity toEntity() {
    return ExtendSessionResponseEntity(message: message);
  }
}
