import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/submit_feedback_response_entity.dart';

part 'submit_feedback_response_model.g.dart';

@JsonSerializable()
class SubmitFeedbackSessionModel {
  final String id;
  final double rating;
  final String review;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  const SubmitFeedbackSessionModel({required this.id, required this.rating, required this.review, required this.updatedAt});

  factory SubmitFeedbackSessionModel.fromJson(Map<String, dynamic> json) => _$SubmitFeedbackSessionModelFromJson(json);
  Map<String, dynamic> toJson() => _$SubmitFeedbackSessionModelToJson(this);

  SubmitFeedbackSessionEntity toEntity() {
    return SubmitFeedbackSessionEntity(id: id, rating: rating, review: review, updatedAt: updatedAt);
  }
}

@JsonSerializable()
class SubmitFeedbackResponseModel {
  final String message;
  final SubmitFeedbackSessionModel session;

  const SubmitFeedbackResponseModel({required this.message, required this.session});

  factory SubmitFeedbackResponseModel.fromJson(Map<String, dynamic> json) => _$SubmitFeedbackResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$SubmitFeedbackResponseModelToJson(this);

  SubmitFeedbackResponseEntity toEntity() {
    return SubmitFeedbackResponseEntity(message: message, session: session.toEntity());
  }
}
