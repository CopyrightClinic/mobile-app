import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/extend_session_response_entity.dart';
import '../repositories/sessions_repository.dart';

class ExtendSessionUseCase implements UseCase<ExtendSessionResponseEntity, ExtendSessionParams> {
  final SessionsRepository repository;

  ExtendSessionUseCase(this.repository);

  @override
  Future<Either<Failure, ExtendSessionResponseEntity>> call(ExtendSessionParams params) async {
    return await repository.extendSession(sessionId: params.sessionId, paymentMethodId: params.paymentMethodId);
  }
}

class ExtendSessionParams extends Equatable {
  final String sessionId;
  final String paymentMethodId;

  const ExtendSessionParams({required this.sessionId, required this.paymentMethodId});

  @override
  List<Object> get props => [sessionId, paymentMethodId];
}
