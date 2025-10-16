// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionDetailsAttorneyModel _$SessionDetailsAttorneyModelFromJson(
  Map<String, dynamic> json,
) => SessionDetailsAttorneyModel(
  id: json['id'] as String,
  name: json['name'] as String?,
  email: json['email'] as String,
  profileUrl: json['profileUrl'] as String?,
);

Map<String, dynamic> _$SessionDetailsAttorneyModelToJson(
  SessionDetailsAttorneyModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'profileUrl': instance.profileUrl,
};

SessionDetailsUserModel _$SessionDetailsUserModelFromJson(
  Map<String, dynamic> json,
) => SessionDetailsUserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$SessionDetailsUserModelToJson(
  SessionDetailsUserModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
};

SessionRequestModel _$SessionRequestModelFromJson(Map<String, dynamic> json) =>
    SessionRequestModel(
      id: json['id'] as String,
      summary: json['summary'] as String,
    );

Map<String, dynamic> _$SessionRequestModelToJson(
  SessionRequestModel instance,
) => <String, dynamic>{'id': instance.id, 'summary': instance.summary};

SessionDetailsModel _$SessionDetailsModelFromJson(Map<String, dynamic> json) =>
    SessionDetailsModel(
      id: json['id'] as String,
      scheduledDate: json['scheduledDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      status: json['status'] as String,
      summary: json['summary'] as String?,
      summaryLocked: json['summaryLocked'] as bool,
      summaryApprovalStatus: json['summaryApprovalStatus'] as String?,
      rating: _ratingFromJson(json['rating']),
      review: json['review'] as String?,
      cancelTime: json['cancelTime'] as String?,
      cancelTimeExpired: json['cancelTimeExpired'] as bool?,
      attorney: SessionDetailsAttorneyModel.fromJson(
        json['attorney'] as Map<String, dynamic>,
      ),
      user: SessionDetailsUserModel.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
      sessionRequest: SessionRequestModel.fromJson(
        json['sessionRequest'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SessionDetailsModelToJson(
  SessionDetailsModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'scheduledDate': instance.scheduledDate,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'durationMinutes': instance.durationMinutes,
  'status': instance.status,
  'summary': instance.summary,
  'summaryLocked': instance.summaryLocked,
  'summaryApprovalStatus': instance.summaryApprovalStatus,
  'rating': _ratingToJson(instance.rating),
  'review': instance.review,
  'cancelTime': instance.cancelTime,
  'cancelTimeExpired': instance.cancelTimeExpired,
  'attorney': instance.attorney,
  'user': instance.user,
  'sessionRequest': instance.sessionRequest,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
