// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  id: json['id'] as String,
  title: json['title'] as String,
  scheduledDate: DateTime.parse(json['scheduled_date'] as String),
  durationMinutes: (json['duration_minutes'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  status: json['status'] as String,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  cancelledAt:
      json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
  cancellationReason: json['cancellation_reason'] as String?,
  zoomMeetingNumber: json['zoom_meeting_number'] as String?,
  zoomPasscode: json['zoom_passcode'] as String?,
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'scheduled_date': instance.scheduledDate.toIso8601String(),
      'duration_minutes': instance.durationMinutes,
      'price': instance.price,
      'status': instance.status,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'cancellation_reason': instance.cancellationReason,
      'zoom_meeting_number': instance.zoomMeetingNumber,
      'zoom_passcode': instance.zoomPasscode,
    };
