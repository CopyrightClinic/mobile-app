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
  rating: (json['rating'] as num?)?.toDouble(),
  review: json['review'] as String?,
  attorney: AttorneyModel.fromJson(json['attorney'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
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
      'rating': instance.rating,
      'review': instance.review,
      'attorney': instance.attorney,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
