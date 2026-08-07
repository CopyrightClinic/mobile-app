import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/decline_extension_response_entity.dart';
import '../repositories/sessions_repository.dart';

class DeclineSessionExtensionUseCase implements UseCase<DeclineExtensionResponseEntity, DeclineSessionExtensionParams> {
  final SessionsRepository repository;

  DeclineSessionExtensionUseCase(this.repository);

  @override
  Future<Either<Failure, DeclineExtensionResponseEntity>> call(DeclineSessionExtensionParams params) async {
    return await repository.declineSessionExtension(sessionId: params.sessionId);
  }
}

class DeclineSessionExtensionParams extends Equatable {
  final String sessionId;

  const DeclineSessionExtensionParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
