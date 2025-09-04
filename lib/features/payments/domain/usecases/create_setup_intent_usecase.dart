import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/setup_intent_entity.dart';
import '../repositories/payment_repository.dart';

class CreateSetupIntentUseCase implements UseCase<SetupIntentEntity, NoParams> {
  final PaymentRepository repository;

  CreateSetupIntentUseCase(this.repository);

  @override
  Future<Either<Failure, SetupIntentEntity>> call(NoParams params) async {
    return await repository.createSetupIntent();
  }
}
