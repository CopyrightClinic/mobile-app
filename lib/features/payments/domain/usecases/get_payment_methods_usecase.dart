import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger/logger.dart';
import '../entities/payment_method_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentMethodsUseCase implements UseCase<List<PaymentMethodEntity>, NoParams> {
  final PaymentRepository repository;

  GetPaymentMethodsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> call(NoParams params) async {
    Log.d('GetPaymentMethodsUseCase', 'Executing get payment methods use case');
    final result = await repository.getPaymentMethods();

    result.fold(
      (failure) => Log.e('GetPaymentMethodsUseCase', 'Use case failed: ${failure.message}'),
      (paymentMethods) => Log.d('GetPaymentMethodsUseCase', 'Use case completed successfully: ${paymentMethods.length} methods retrieved'),
    );

    return result;
  }
}
