import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_session_request_entity.dart';
import '../repositories/sessions_repository.dart';

class GetUserSessionRequestsParams extends Equatable {
  final String timezone;
  final String? status;

  const GetUserSessionRequestsParams({required this.timezone, this.status});

  @override
  List<Object?> get props => [timezone, status];
}

class GetUserSessionRequestsUseCase implements UseCase<List<UserSessionRequestEntity>, GetUserSessionRequestsParams> {
  final SessionsRepository repository;

  GetUserSessionRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserSessionRequestEntity>>> call(GetUserSessionRequestsParams params) async {
    return await repository.getUserSessionRequests(timezone: params.timezone, status: params.status);
  }
}
