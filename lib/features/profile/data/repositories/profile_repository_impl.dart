import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({required String name, required String phoneNumber, required String address}) async {
    try {
      final profileModel = await remoteDataSource.updateProfile(name: name, phoneNumber: phoneNumber, address: address);
      return Right(profileModel.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(AppStrings.failedToUpdateProfileGeneric));
    }
  }

  @override
  Future<Either<Failure, String>> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      final message = await remoteDataSource.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      return Right(message);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(AppStrings.failedToChangePasswordGeneric));
    }
  }

  @override
  Future<Either<Failure, String>> deleteAccount() async {
    try {
      final message = await remoteDataSource.deleteAccount();
      return Right(message);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(AppStrings.failedToDeleteAccountGeneric));
    }
  }
}
