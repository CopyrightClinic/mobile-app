import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/session_availability_entity.dart';
import '../repositories/sessions_repository.dart';

class GetSessionAvailabilityUseCase implements UseCase<SessionAvailabilityEntity, String> {
  final SessionsRepository repository;

  GetSessionAvailabilityUseCase(this.repository);

  @override
  Future<Either<Failure, SessionAvailabilityEntity>> call(String timezone) async {
    return await repository.getSessionAvailability(timezone);
  }
}
