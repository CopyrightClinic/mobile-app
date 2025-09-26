import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/session_entity.dart';
import '../repositories/sessions_repository.dart';

class GetUserSessionsUseCase implements UseCase<List<SessionEntity>, NoParams> {
  final SessionsRepository repository;

  GetUserSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SessionEntity>>> call(NoParams params) async {
    return await repository.getUserSessions();
  }
}
