import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cancel_session_request_response_entity.dart';
import '../repositories/sessions_repository.dart';

class CancelSessionRequestUseCase implements UseCase<CancelSessionRequestResponseEntity, CancelSessionRequestParams> {
  final SessionsRepository repository;

  CancelSessionRequestUseCase(this.repository);

  @override
  Future<Either<Failure, CancelSessionRequestResponseEntity>> call(CancelSessionRequestParams params) async {
    return await repository.cancelSessionRequest(params.requestId, params.reason);
  }
}

class CancelSessionRequestParams extends Equatable {
  final String requestId;
  final String reason;

  const CancelSessionRequestParams({required this.requestId, required this.reason});

  @override
  List<Object> get props => [requestId, reason];
}
