import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger/logger.dart';
import '../entities/setup_intent_entity.dart';
import '../repositories/payment_repository.dart';

class CreateSetupIntentUseCase implements UseCase<SetupIntentEntity, NoParams> {
  final PaymentRepository repository;

  CreateSetupIntentUseCase(this.repository);

  @override
  Future<Either<Failure, SetupIntentEntity>> call(NoParams params) async {
    Log.d('CreateSetupIntentUseCase', 'Executing create setup intent use case');
    final result = await repository.createSetupIntent();

    result.fold(
      (failure) => Log.e('CreateSetupIntentUseCase', 'Use case failed: ${failure.message}'),
      (setupIntent) => Log.d('CreateSetupIntentUseCase', 'Use case completed successfully: ${setupIntent.id}'),
    );

    return result;
  }
}
