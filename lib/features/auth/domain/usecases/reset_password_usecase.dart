import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase implements UseCase<String, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(params.email, params.otp, params.newPassword, params.confirmPassword);
  }
}

class ResetPasswordParams {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordParams({required this.email, required this.otp, required this.newPassword, required this.confirmPassword});
}
