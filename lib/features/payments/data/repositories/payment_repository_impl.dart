import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/setup_intent_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SetupIntentEntity>> createSetupIntent() async {
    try {
      Log.d('PaymentRepositoryImpl', 'Creating setup intent');
      final result = await remoteDataSource.createSetupIntent();
      Log.d('PaymentRepositoryImpl', 'Setup intent created successfully');
      return Right(result.toEntity());
    } on CustomException catch (e) {
      Log.e('PaymentRepositoryImpl', 'CustomException during createSetupIntent: ${e.message}', StackTrace.current);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Log.e('PaymentRepositoryImpl', 'Unexpected error during createSetupIntent: $e', stackTrace);
      return Left(ServerFailure('Failed to create setup intent: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentMethodEntity>> attachPaymentMethod(String paymentMethodId) async {
    try {
      Log.d('PaymentRepositoryImpl', 'Attaching payment method: $paymentMethodId');
      final result = await remoteDataSource.attachPaymentMethod(paymentMethodId);
      Log.d('PaymentRepositoryImpl', 'Payment method attached successfully');
      return Right(result.toEntity());
    } on CustomException catch (e) {
      Log.e('PaymentRepositoryImpl', 'CustomException during attachPaymentMethod: ${e.message}', StackTrace.current);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Log.e('PaymentRepositoryImpl', 'Unexpected error during attachPaymentMethod: $e', stackTrace);
      return Left(ServerFailure('Failed to attach payment method: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
    try {
      Log.d('PaymentRepositoryImpl', 'Fetching payment methods');
      final result = await remoteDataSource.getPaymentMethods();
      Log.d('PaymentRepositoryImpl', 'Payment methods fetched successfully: ${result.length} methods');
      return Right(result.map((model) => model.toEntity()).toList());
    } on CustomException catch (e) {
      Log.e('PaymentRepositoryImpl', 'CustomException during getPaymentMethods: ${e.message}', StackTrace.current);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Log.e('PaymentRepositoryImpl', 'Unexpected error during getPaymentMethods: $e', stackTrace);
      return Left(ServerFailure('Failed to fetch payment methods: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePaymentMethod(String paymentMethodId) async {
    try {
      Log.d('PaymentRepositoryImpl', 'Deleting payment method: $paymentMethodId');
      final result = await remoteDataSource.deletePaymentMethod(paymentMethodId);
      Log.d('PaymentRepositoryImpl', 'Payment method deleted successfully');
      return Right(result);
    } on CustomException catch (e) {
      Log.e('PaymentRepositoryImpl', 'CustomException during deletePaymentMethod: ${e.message}', StackTrace.current);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Log.e('PaymentRepositoryImpl', 'Unexpected error during deletePaymentMethod: $e', stackTrace);
      return Left(ServerFailure('Failed to delete payment method: $e'));
    }
  }
}
