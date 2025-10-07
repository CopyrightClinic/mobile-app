// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttorneyModel _$AttorneyModelFromJson(Map<String, dynamic> json) =>
    AttorneyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$AttorneyModelToJson(AttorneyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  id: json['id'] as String,
  scheduledDate: json['scheduledDate'] as String,
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  status: json['status'] as String,
  summary: json['summary'] as String?,
  rating: _ratingFromJson(json['rating']),
  review: json['review'] as String?,
  cancelTime: json['cancelTime'] as String?,
  cancelTimeExpired: json['cancelTimeExpired'] as bool?,
  attorney: AttorneyModel.fromJson(json['attorney'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  cancelledAt:
      json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
  cancellationReason: json['cancellation_reason'] as String?,
  zoomMeetingNumber: json['zoom_meeting_number'] as String?,
  zoomPasscode: json['zoom_passcode'] as String?,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scheduledDate': instance.scheduledDate,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'durationMinutes': instance.durationMinutes,
      'status': instance.status,
      'summary': instance.summary,
      'rating': _ratingToJson(instance.rating),
      'review': instance.review,
      'cancelTime': instance.cancelTime,
      'cancelTimeExpired': instance.cancelTimeExpired,
      'attorney': instance.attorney,
      'createdAt': instance.createdAt.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'cancellation_reason': instance.cancellationReason,
      'zoom_meeting_number': instance.zoomMeetingNumber,
      'zoom_passcode': instance.zoomPasscode,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
