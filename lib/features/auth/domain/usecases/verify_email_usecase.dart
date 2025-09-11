import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/otp_verification_result.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailUseCase extends UseCase<OtpVerificationResult, VerifyEmailParams> {
  final AuthRepository repository;

  VerifyEmailUseCase(this.repository);

  @override
  Future<Either<Failure, OtpVerificationResult>> call(VerifyEmailParams params) async {
    return await repository.verifyEmail(params.email, params.otp);
  }
}

class VerifyEmailParams {
  final String email;
  final String otp;

  VerifyEmailParams({required this.email, required this.otp});
}
