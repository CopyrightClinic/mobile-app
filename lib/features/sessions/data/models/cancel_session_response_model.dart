import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cancel_session_response_entity.dart';

part 'cancel_session_response_model.g.dart';

@JsonSerializable()
class CancelSessionSessionModel {
  final String id;
  final String status;
  final String cancelledBy;
  final String cancellationReason;

  const CancelSessionSessionModel({required this.id, required this.status, required this.cancelledBy, required this.cancellationReason});

  factory CancelSessionSessionModel.fromJson(Map<String, dynamic> json) => _$CancelSessionSessionModelFromJson(json);
  Map<String, dynamic> toJson() => _$CancelSessionSessionModelToJson(this);

  CancelSessionSessionEntity toEntity() {
    return CancelSessionSessionEntity(id: id, status: status, cancelledBy: cancelledBy, cancellationReason: cancellationReason);
  }
}

@JsonSerializable()
class CancelSessionResponseModel {
  final String message;
  final int status;
  final CancelSessionSessionModel session;

  const CancelSessionResponseModel({required this.message, required this.status, required this.session});

  factory CancelSessionResponseModel.fromJson(Map<String, dynamic> json) => _$CancelSessionResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$CancelSessionResponseModelToJson(this);

  CancelSessionResponseEntity toEntity() {
    return CancelSessionResponseEntity(message: message, status: status, session: session.toEntity());
  }
}
