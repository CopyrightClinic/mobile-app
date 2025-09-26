import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyPasswordResetOtpUseCase implements UseCase<String, VerifyPasswordResetOtpParams> {
  final AuthRepository repository;

  VerifyPasswordResetOtpUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(VerifyPasswordResetOtpParams params) async {
    return await repository.verifyPasswordResetOtp(params.email, params.otp);
  }
}

class VerifyPasswordResetOtpParams {
  final String email;
  final String otp;

  VerifyPasswordResetOtpParams({required this.email, required this.otp});
}
