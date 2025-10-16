import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/unlock_summary_response_entity.dart';
import '../repositories/sessions_repository.dart';

class UnlockSessionSummaryUseCase implements UseCase<UnlockSummaryResponseEntity, UnlockSessionSummaryParams> {
  final SessionsRepository repository;

  UnlockSessionSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, UnlockSummaryResponseEntity>> call(UnlockSessionSummaryParams params) async {
    return await repository.unlockSessionSummary(sessionId: params.sessionId, paymentMethodId: params.paymentMethodId, summaryFee: params.summaryFee);
  }
}

class UnlockSessionSummaryParams {
  final String sessionId;
  final String paymentMethodId;
  final double summaryFee;

  const UnlockSessionSummaryParams({required this.sessionId, required this.paymentMethodId, required this.summaryFee});
}
