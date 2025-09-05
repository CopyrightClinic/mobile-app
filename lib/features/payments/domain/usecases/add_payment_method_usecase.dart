import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger/logger.dart';
import '../entities/payment_method_entity.dart';
import '../repositories/payment_repository.dart';

class AddPaymentMethodUseCase implements UseCase<PaymentMethodEntity, AddPaymentMethodParams> {
  final PaymentRepository repository;

  AddPaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentMethodEntity>> call(AddPaymentMethodParams params) async {
    Log.d('AddPaymentMethodUseCase', 'Executing with payment method ID: ${params.paymentMethodId}');
    final result = await repository.attachPaymentMethod(params.paymentMethodId);

    result.fold(
      (failure) => Log.e('AddPaymentMethodUseCase', 'Use case failed: ${failure.message}'),
      (paymentMethod) => Log.d('AddPaymentMethodUseCase', 'Use case completed successfully: ${paymentMethod.id}'),
    );

    return result;
  }
}

class AddPaymentMethodParams extends Equatable {
  final String paymentMethodId;

  const AddPaymentMethodParams({required this.paymentMethodId});

  @override
  List<Object> get props => [paymentMethodId];
}
