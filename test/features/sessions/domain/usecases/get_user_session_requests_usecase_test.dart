import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:copyright_clinic_flutter/core/error/failures.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/ui/session_request_status.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/entities/user_session_request_entity.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/usecases/get_user_session_requests_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late GetUserSessionRequestsUseCase useCase;
  late MockSessionsRepository repository;

  setUp(() {
    repository = MockSessionsRepository();
    useCase = GetUserSessionRequestsUseCase(repository);
  });

  final requestEntity = UserSessionRequestEntity(
    id: 'req-1',
    requestedDate: '2026-07-10',
    startTime: '10:00',
    endTime: '10:30',
    status: SessionRequestStatus.pending,
    isFreeSession: false,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  );

  test('forwards timezone and status to the repository', () async {
    when(
      () => repository.getUserSessionRequests(timezone: any(named: 'timezone'), status: any(named: 'status')),
    ).thenAnswer((_) async => Right([requestEntity]));

    final result = await useCase(const GetUserSessionRequestsParams(timezone: 'Asia/Karachi', status: 'pending'));

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected Right'), (entities) => expect(entities, [requestEntity]));
    verify(() => repository.getUserSessionRequests(timezone: 'Asia/Karachi', status: 'pending')).called(1);
  });

  test('forwards a null status when none is provided', () async {
    when(
      () => repository.getUserSessionRequests(timezone: any(named: 'timezone'), status: any(named: 'status')),
    ).thenAnswer((_) async => const Right([]));

    await useCase(const GetUserSessionRequestsParams(timezone: 'Asia/Karachi'));

    verify(() => repository.getUserSessionRequests(timezone: 'Asia/Karachi', status: null)).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(
      () => repository.getUserSessionRequests(timezone: any(named: 'timezone'), status: any(named: 'status')),
    ).thenAnswer((_) async => const Left(ServerFailure('failed to fetch requests')));

    final result = await useCase(const GetUserSessionRequestsParams(timezone: 'Asia/Karachi', status: 'canceled'));

    expect(result, const Left(ServerFailure('failed to fetch requests')));
  });
}
