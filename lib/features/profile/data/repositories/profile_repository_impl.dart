import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/utils/storage/user_storage.dart';
import '../../../auth/domain/entities/user_entity.dart';
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
      final profileEntity = profileModel.toEntity();

      // Update local user storage with the new profile data
      await _updateUserStorage(profileEntity);

      return Right(profileEntity);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(AppStrings.failedToUpdateProfileGeneric));
    }
  }

  Future<void> _updateUserStorage(ProfileEntity profile) async {
    try {
      final currentUser = await UserStorage.getUser();
      if (currentUser != null) {
        final updatedUser = UserEntity(
          id: currentUser.id,
          name: profile.name,
          email: currentUser.email,
          phoneNumber: profile.phoneNumber,
          address: profile.address,
          role: currentUser.role,
          status: currentUser.status,
          totalSessions: currentUser.totalSessions,
          stripeCustomerId: currentUser.stripeCustomerId,
          createdAt: currentUser.createdAt,
          updatedAt: profile.updatedAt,
        );
        await UserStorage.saveUser(updatedUser);
      }
    } catch (e) {
      Log.e('ProfileRepositoryImpl', e.toString());
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
