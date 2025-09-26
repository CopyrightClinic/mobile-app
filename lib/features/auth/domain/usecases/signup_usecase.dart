import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase extends UseCase<AuthResult, SignupParams> {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(SignupParams params) async {
    return await repository.signup(params.email, params.password, params.confirmPassword);
  }
}

class SignupParams {
  final String email;
  final String password;
  final String confirmPassword;

  SignupParams({required this.email, required this.password, required this.confirmPassword});
}
