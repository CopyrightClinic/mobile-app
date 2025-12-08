import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/submit_feedback_response_entity.dart';
import '../repositories/sessions_repository.dart';

class SubmitSessionFeedbackParams extends Equatable {
  final String sessionId;
  final double rating;
  final String? review;

  const SubmitSessionFeedbackParams({required this.sessionId, required this.rating, this.review});

  @override
  List<Object?> get props => [sessionId, rating, review];
}

class SubmitSessionFeedbackUseCase implements UseCase<SubmitFeedbackResponseEntity, SubmitSessionFeedbackParams> {
  final SessionsRepository repository;

  SubmitSessionFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, SubmitFeedbackResponseEntity>> call(SubmitSessionFeedbackParams params) async {
    return await repository.submitSessionFeedback(sessionId: params.sessionId, rating: params.rating, review: params.review);
  }
}
