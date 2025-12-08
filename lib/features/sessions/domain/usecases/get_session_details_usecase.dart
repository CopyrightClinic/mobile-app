import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/session_details_entity.dart';
import '../repositories/sessions_repository.dart';

class GetSessionDetailsParams extends Equatable {
  final String sessionId;
  final String? timezone;

  const GetSessionDetailsParams({required this.sessionId, this.timezone});

  @override
  List<Object?> get props => [sessionId, timezone];
}

class GetSessionDetailsUseCase implements UseCase<SessionDetailsEntity, GetSessionDetailsParams> {
  final SessionsRepository repository;

  GetSessionDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, SessionDetailsEntity>> call(GetSessionDetailsParams params) async {
    return await repository.getSessionDetails(sessionId: params.sessionId, timezone: params.timezone);
  }
}
