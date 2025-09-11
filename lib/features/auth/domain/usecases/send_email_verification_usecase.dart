import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendEmailVerificationUseCase implements UseCase<String, SendEmailVerificationParams> {
  final AuthRepository repository;

  SendEmailVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SendEmailVerificationParams params) async {
    return await repository.sendEmailVerification(params.email);
  }
}

class SendEmailVerificationParams {
  final String email;

  SendEmailVerificationParams({required this.email});
}
