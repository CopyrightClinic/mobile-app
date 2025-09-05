import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';
import '../models/payment_request_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaymentMethodEntity>> attachPaymentMethod(String paymentMethodId) async {
    try {
      Log.d('PaymentRepositoryImpl', 'Creating payment method: $paymentMethodId');
      final request = CreatePaymentMethodRequestModel(stripePaymentMethodId: paymentMethodId, isDefault: false);
      final result = await remoteDataSource.createPaymentMethod(request);
      Log.d('PaymentRepositoryImpl', 'Payment method created successfully');
      return Right(result.toEntity());
    } on CustomException catch (e) {
      Log.e('PaymentRepositoryImpl', 'CustomException during createPaymentMethod: ${e.message}', StackTrace.current);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Log.e('PaymentRepositoryImpl', 'Unexpected error during createPaymentMethod: $e', stackTrace);
      return Left(ServerFailure('Failed to create payment method: $e'));
    }
  }
}
