import 'package:json_annotation/json_annotation.dart';

part 'submit_feedback_request_model.g.dart';

@JsonSerializable()
class SubmitFeedbackRequestModel {
  final double rating;
  final String? review;

  const SubmitFeedbackRequestModel({required this.rating, this.review});

  factory SubmitFeedbackRequestModel.fromJson(Map<String, dynamic> json) => _$SubmitFeedbackRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$SubmitFeedbackRequestModelToJson(this);
}
