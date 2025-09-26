import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/harold_evaluation_result.dart';

abstract class HaroldRepository {
  Future<Either<Failure, HaroldEvaluationResult>> evaluateQuery(String query);
}
