import 'package:equatable/equatable.dart';

class SubmitFeedbackSessionEntity extends Equatable {
  final String id;
  final double rating;
  final String review;
  final DateTime updatedAt;

  const SubmitFeedbackSessionEntity({required this.id, required this.rating, required this.review, required this.updatedAt});

  @override
  List<Object> get props => [id, rating, review, updatedAt];
}

class SubmitFeedbackResponseEntity extends Equatable {
  final String message;
  final SubmitFeedbackSessionEntity session;

  const SubmitFeedbackResponseEntity({required this.message, required this.session});

  @override
  List<Object> get props => [message, session];
}
