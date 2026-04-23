import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/harold_eligibility_result.dart';
import '../entities/harold_evaluation_result.dart';

abstract class HaroldRepository {
  Future<Either<Failure, HaroldEvaluationResult>> evaluateQuery(String query);
  Future<Either<Failure, HaroldEligibilityResult>> checkEligibility({
    required String evaluationId,
    required Map<String, dynamic> answersPayload,
  });
}
