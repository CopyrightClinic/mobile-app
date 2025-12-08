import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class ChangePasswordUseCase implements UseCase<String, ChangePasswordParams> {
  final ProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ChangePasswordParams params) async {
    return await repository.changePassword(currentPassword: params.currentPassword, newPassword: params.newPassword);
  }
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  ChangePasswordParams({required this.currentPassword, required this.newPassword});
}
