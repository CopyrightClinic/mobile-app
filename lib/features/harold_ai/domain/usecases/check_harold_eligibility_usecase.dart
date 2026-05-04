import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/harold_eligibility_result.dart';
import '../repositories/harold_repository.dart';

class CheckHaroldEligibilityUseCase implements UseCase<HaroldEligibilityResult, CheckHaroldEligibilityParams> {
  final HaroldRepository repository;

  CheckHaroldEligibilityUseCase({required this.repository});

  @override
  Future<Either<Failure, HaroldEligibilityResult>> call(CheckHaroldEligibilityParams params) async {
    return repository.checkEligibility(evaluationId: params.evaluationId, answersPayload: params.answersPayload);
  }
}

class CheckHaroldEligibilityParams extends Equatable {
  final String evaluationId;
  final Map<String, dynamic> answersPayload;

  const CheckHaroldEligibilityParams({required this.evaluationId, required this.answersPayload});

  @override
  List<Object?> get props => [evaluationId, answersPayload];
}
