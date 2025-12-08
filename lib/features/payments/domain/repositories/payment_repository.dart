import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_method_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentMethodEntity>> attachPaymentMethod(String paymentMethodId);
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();
  Future<Either<Failure, String>> deletePaymentMethod(String stripePaymentMethodId);
}
