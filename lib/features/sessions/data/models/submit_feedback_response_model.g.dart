// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_feedback_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitFeedbackSessionModel _$SubmitFeedbackSessionModelFromJson(
  Map<String, dynamic> json,
) => SubmitFeedbackSessionModel(
  id: json['id'] as String,
  rating: (json['rating'] as num).toDouble(),
  review: json['review'] as String?,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SubmitFeedbackSessionModelToJson(
  SubmitFeedbackSessionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'review': instance.review,
  'updatedAt': instance.updatedAt.toIso8601String(),
};

SubmitFeedbackResponseModel _$SubmitFeedbackResponseModelFromJson(
  Map<String, dynamic> json,
) => SubmitFeedbackResponseModel(
  message: json['message'] as String,
  session: SubmitFeedbackSessionModel.fromJson(
    json['session'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SubmitFeedbackResponseModelToJson(
  SubmitFeedbackResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'session': instance.session,
};
