import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<ProfileEntity, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(name: params.name, phoneNumber: params.phoneNumber, address: params.address);
  }
}

class UpdateProfileParams {
  final String name;
  final String phoneNumber;
  final String address;

  UpdateProfileParams({required this.name, required this.phoneNumber, required this.address});
}
