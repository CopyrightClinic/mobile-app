// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_feedback_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitFeedbackRequestModel _$SubmitFeedbackRequestModelFromJson(
  Map<String, dynamic> json,
) => SubmitFeedbackRequestModel(
  rating: (json['rating'] as num).toDouble(),
  review: json['review'] as String?,
);

Map<String, dynamic> _$SubmitFeedbackRequestModelToJson(
  SubmitFeedbackRequestModel instance,
) => <String, dynamic>{'rating': instance.rating, 'review': instance.review};
