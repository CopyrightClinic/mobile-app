import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

class DeletePaymentMethodUseCase implements UseCase<String, DeletePaymentMethodParams> {
  final PaymentRepository repository;

  DeletePaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(DeletePaymentMethodParams params) async {
    return await repository.deletePaymentMethod(params.stripePaymentMethodId);
  }
}

class DeletePaymentMethodParams extends Equatable {
  final String stripePaymentMethodId;

  const DeletePaymentMethodParams({required this.stripePaymentMethodId});

  @override
  List<Object> get props => [stripePaymentMethodId];
}
