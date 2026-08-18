import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:copyright_clinic_flutter/core/error/failures.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/entities/book_session_response_entity.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/usecases/book_session_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late BookSessionUseCase useCase;
  late MockSessionsRepository repository;

  setUp(() {
    repository = MockSessionsRepository();
    useCase = BookSessionUseCase(repository);
  });

  final responseEntity = BookSessionResponseEntity(
    message: 'Booked',
    data: BookSessionDataEntity(
      sessionRequest: BookSessionRequestEntity(
        id: 'req-1',
        userId: 'user-1',
        requestedDate: '2026-07-10',
        startTime: '10:00',
        endTime: '10:30',
        status: 'pending',
        expiresAt: DateTime(2026, 7, 11),
        createdAt: DateTime(2026, 7, 10),
        updatedAt: DateTime(2026, 7, 10),
      ),
      availableAttorneys: const [],
    ),
  );

  test('forwards the query field to the repository alongside the other booking params', () async {
    when(
      () => repository.bookSession(
        stripePaymentMethodId: any(named: 'stripePaymentMethodId'),
        couponCode: any(named: 'couponCode'),
        date: any(named: 'date'),
        startTime: any(named: 'startTime'),
        endTime: any(named: 'endTime'),
        summary: any(named: 'summary'),
        query: any(named: 'query'),
        timezone: any(named: 'timezone'),
      ),
    ).thenAnswer((_) async => Right(responseEntity));

    final result = await useCase(
      const BookSessionParams(
        stripePaymentMethodId: 'pm_123',
        couponCode: 'SAVE10',
        date: '2026-07-10',
        startTime: '10:00',
        endTime: '10:30',
        summary: 'Copyright question about a logo',
        query: 'Can I use this logo commercially?',
        timezone: 'Asia/Karachi',
      ),
    );

    expect(result, Right(responseEntity));
    verify(
      () => repository.bookSession(
        stripePaymentMethodId: 'pm_123',
        couponCode: 'SAVE10',
        date: '2026-07-10',
        startTime: '10:00',
        endTime: '10:30',
        summary: 'Copyright question about a logo',
        query: 'Can I use this logo commercially?',
        timezone: 'Asia/Karachi',
      ),
    ).called(1);
  });

  test('propagates a failure from the repository', () async {
    when(
      () => repository.bookSession(
        stripePaymentMethodId: any(named: 'stripePaymentMethodId'),
        couponCode: any(named: 'couponCode'),
        date: any(named: 'date'),
        startTime: any(named: 'startTime'),
        endTime: any(named: 'endTime'),
        summary: any(named: 'summary'),
        query: any(named: 'query'),
        timezone: any(named: 'timezone'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('failed to book')));

    final result = await useCase(
      const BookSessionParams(
        stripePaymentMethodId: 'pm_123',
        date: '2026-07-10',
        startTime: '10:00',
        endTime: '10:30',
        summary: 'summary',
        query: 'query',
        timezone: 'Asia/Karachi',
      ),
    );

    expect(result, const Left(ServerFailure('failed to book')));
  });
}
