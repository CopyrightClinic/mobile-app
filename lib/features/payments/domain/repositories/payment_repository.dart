import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_method_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentMethodEntity>> attachPaymentMethod(String paymentMethodId);
}
