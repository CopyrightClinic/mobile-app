import 'package:equatable/equatable.dart';

abstract class SessionDetailsEvent extends Equatable {
  const SessionDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadSessionDetails extends SessionDetailsEvent {
  final String sessionId;

  const LoadSessionDetails({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class SubmitSessionFeedback extends SessionDetailsEvent {
  final String sessionId;
  final double rating;
  final String? review;

  const SubmitSessionFeedback({required this.sessionId, required this.rating, this.review});

  @override
  List<Object> get props => [sessionId, rating, review ?? ''];
}

class UnlockSessionSummary extends SessionDetailsEvent {
  final String sessionId;
  final String paymentMethodId;
  final double summaryFee;

  const UnlockSessionSummary({required this.sessionId, required this.paymentMethodId, required this.summaryFee});

  @override
  List<Object> get props => [sessionId, paymentMethodId, summaryFee];
}
