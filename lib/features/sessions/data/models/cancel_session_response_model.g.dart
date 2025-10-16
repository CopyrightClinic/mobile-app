// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_session_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelSessionSessionModel _$CancelSessionSessionModelFromJson(
  Map<String, dynamic> json,
) => CancelSessionSessionModel(
  id: json['id'] as String,
  status: json['status'] as String,
  cancelledBy: json['cancelledBy'] as String,
  cancellationReason: json['cancellationReason'] as String,
);

Map<String, dynamic> _$CancelSessionSessionModelToJson(
  CancelSessionSessionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'cancelledBy': instance.cancelledBy,
  'cancellationReason': instance.cancellationReason,
};

CancelSessionResponseModel _$CancelSessionResponseModelFromJson(
  Map<String, dynamic> json,
) => CancelSessionResponseModel(
  message: json['message'] as String,
  status: (json['status'] as num).toInt(),
  session: CancelSessionSessionModel.fromJson(
    json['session'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$CancelSessionResponseModelToJson(
  CancelSessionResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'status': instance.status,
  'session': instance.session,
};
