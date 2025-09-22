import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/constants/app_strings.dart';
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
      final request = CreatePaymentMethodRequestModel(stripePaymentMethodId: paymentMethodId, isDefault: false);
      final result = await remoteDataSource.createPaymentMethod(request);
      return Right(result.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(AppStrings.failedToCreatePaymentMethodGeneric));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
    try {
      final result = await remoteDataSource.getPaymentMethods();
      return Right(result.toEntities());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToLoadPaymentMethodsGeneric}: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> deletePaymentMethod(String paymentMethodId) async {
    try {
      // TODO: Implement delete payment method API call
      // For now, return a mock success response
      await Future.delayed(const Duration(seconds: 1));
      return const Right(AppStrings.paymentMethodDeletedSuccessfully);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToDeletePaymentMethodGeneric}: $e'));
    }
  }
}
