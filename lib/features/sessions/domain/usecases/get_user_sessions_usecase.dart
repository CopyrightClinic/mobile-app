import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/session_entity.dart';
import '../repositories/sessions_repository.dart';

class GetUserSessionsParams extends Equatable {
  final String? status;
  final String? timezone;

  const GetUserSessionsParams({this.status, this.timezone});

  @override
  List<Object?> get props => [status, timezone];
}

class GetUserSessionsUseCase implements UseCase<List<SessionEntity>, GetUserSessionsParams> {
  final SessionsRepository repository;

  GetUserSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SessionEntity>>> call(GetUserSessionsParams params) async {
    return await repository.getUserSessions(status: params.status, timezone: params.timezone);
  }
}
