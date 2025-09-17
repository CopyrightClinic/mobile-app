import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/harold_evaluation_result.dart';
import '../repositories/harold_repository.dart';

class EvaluateQueryUseCase implements UseCase<HaroldEvaluationResult, EvaluateQueryParams> {
  final HaroldRepository repository;

  EvaluateQueryUseCase({required this.repository});

  @override
  Future<Either<Failure, HaroldEvaluationResult>> call(EvaluateQueryParams params) async {
    return await repository.evaluateQuery(params.query);
  }
}

class EvaluateQueryParams extends Equatable {
  final String query;

  const EvaluateQueryParams({required this.query});

  @override
  List<Object?> get props => [query];

  @override
  String toString() => 'EvaluateQueryParams(query: $query)';
}
