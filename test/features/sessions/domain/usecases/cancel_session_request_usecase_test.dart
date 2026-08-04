import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:copyright_clinic_flutter/core/error/failures.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/entities/cancel_session_request_response_entity.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/usecases/cancel_session_request_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late CancelSessionRequestUseCase useCase;
  late MockSessionsRepository repository;

  setUp(() {
    repository = MockSessionsRepository();
    useCase = CancelSessionRequestUseCase(repository);
  });

  test('forwards requestId and reason as positional args to the repository', () async {
    when(
      () => repository.cancelSessionRequest(any(), any()),
    ).thenAnswer((_) async => const Right(CancelSessionRequestResponseEntity(message: 'Cancelled')));

    final result = await useCase(const CancelSessionRequestParams(requestId: 'req-1', reason: 'Change of plans'));

    expect(result, const Right(CancelSessionRequestResponseEntity(message: 'Cancelled')));
    verify(() => repository.cancelSessionRequest('req-1', 'Change of plans')).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(
      () => repository.cancelSessionRequest(any(), any()),
    ).thenAnswer((_) async => const Left(ServerFailure('failed to cancel')));

    final result = await useCase(const CancelSessionRequestParams(requestId: 'req-1', reason: 'Change of plans'));

    expect(result, const Left(ServerFailure('failed to cancel')));
  });
}
