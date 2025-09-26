import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/sessions_repository.dart';

class CancelSessionUseCase implements UseCase<String, CancelSessionParams> {
  final SessionsRepository repository;

  CancelSessionUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CancelSessionParams params) async {
    return await repository.cancelSession(params.sessionId, params.reason);
  }
}

class CancelSessionParams extends Equatable {
  final String sessionId;
  final String reason;

  const CancelSessionParams({required this.sessionId, required this.reason});

  @override
  List<Object> get props => [sessionId, reason];
}
