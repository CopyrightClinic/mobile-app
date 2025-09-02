import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CompleteProfileUseCase implements UseCase<String, CompleteProfileParams> {
  final AuthRepository repository;

  CompleteProfileUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CompleteProfileParams params) async {
    return await repository.completeProfile(params.name, params.phoneNumber, params.address);
  }
}

class CompleteProfileParams {
  final String name;
  final String phoneNumber;
  final String address;

  CompleteProfileParams({required this.name, required this.phoneNumber, required this.address});
}
