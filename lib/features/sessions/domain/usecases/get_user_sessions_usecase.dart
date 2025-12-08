import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_sessions_entity.dart';
import '../repositories/sessions_repository.dart';

class GetUserSessionsParams extends Equatable {
  final String? status;
  final String? timezone;
  final int? page;
  final int? limit;

  const GetUserSessionsParams({this.status, this.timezone, this.page, this.limit});

  @override
  List<Object?> get props => [status, timezone, page, limit];
}

class GetUserSessionsUseCase implements UseCase<PaginatedSessionsEntity, GetUserSessionsParams> {
  final SessionsRepository repository;

  GetUserSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedSessionsEntity>> call(GetUserSessionsParams params) async {
    return await repository.getUserSessions(status: params.status, timezone: params.timezone, page: params.page, limit: params.limit);
  }
}
