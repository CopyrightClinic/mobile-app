import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:copyright_clinic_flutter/core/error/failures.dart';
import 'package:copyright_clinic_flutter/core/network/exception/custom_exception.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/datasources/sessions_remote_data_source.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/models/book_session_response_model.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/models/cancel_session_request_response_model.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/models/user_session_request_model.dart';
import 'package:copyright_clinic_flutter/features/sessions/data/repositories/sessions_repository_impl.dart';

class MockSessionsRemoteDataSource extends Mock implements SessionsRemoteDataSource {}

void main() {
  late SessionsRepositoryImpl repository;
  late MockSessionsRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = MockSessionsRemoteDataSource();
    repository = SessionsRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('getUserSessionRequests', () {
    final requestModel = UserSessionRequestModel(
      id: 'req-1',
      requestedDate: '2026-07-10',
      startTime: '10:00',
      endTime: '10:30',
      status: 'pending',
      isFreeSession: false,
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    );

    test('maps successful data source responses to entities', () async {
      when(
        () => remoteDataSource.getUserSessionRequests(timezone: any(named: 'timezone'), status: any(named: 'status')),
      ).thenAnswer((_) async => [requestModel]);

      final result = await repository.getUserSessionRequests(timezone: 'Asia/Karachi', status: 'pending');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (entities) {
        expect(entities, hasLength(1));
        expect(entities.first.id, 'req-1');
      });
    });

    test('maps a CustomException to a ServerFailure carrying its message', () async {
      when(
        () => remoteDataSource.getUserSessionRequests(timezone: any(named: 'timezone'), status: any(named: 'status')),
      ).thenThrow(CustomException(message: 'boom'));

      final result = await repository.getUserSessionRequests(timezone: 'Asia/Karachi', status: 'pending');

      expect(result, const Left(ServerFailure('boom')));
    });
  });

  group('cancelSessionRequest', () {
    test('maps a successful cancellation to an entity', () async {
      when(
        () => remoteDataSource.cancelSessionRequest(any(), any()),
      ).thenAnswer((_) async => const CancelSessionRequestResponseModel(message: 'Cancelled'));

      final result = await repository.cancelSessionRequest('req-1', 'change of plans');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (entity) => expect(entity.message, 'Cancelled'));
      verify(() => remoteDataSource.cancelSessionRequest('req-1', 'change of plans')).called(1);
    });

    test('maps a CustomException to a ServerFailure', () async {
      when(() => remoteDataSource.cancelSessionRequest(any(), any())).thenThrow(CustomException(message: 'cannot cancel'));

      final result = await repository.cancelSessionRequest('req-1', 'change of plans');

      expect(result, const Left(ServerFailure('cannot cancel')));
    });
  });

  group('bookSession', () {
    final responseModel = BookSessionResponseModel(
      message: 'Booked',
      data: BookSessionDataModel(
        sessionRequest: BookSessionRequestEntityModel(
          id: 'req-1',
          userId: 'user-1',
          requestedDate: '2026-07-10',
          startTime: '10:00',
          endTime: '10:30',
          status: 'pending',
          expiresAt: '2026-07-11T00:00:00.000Z',
          createdAt: '2026-07-10T00:00:00.000Z',
          updatedAt: '2026-07-10T00:00:00.000Z',
        ),
        availableAttorneys: const [],
      ),
    );

    void stubBookSession(Future<BookSessionResponseModel> Function(Invocation) answer) {
      when(
        () => remoteDataSource.bookSession(
          stripePaymentMethodId: any(named: 'stripePaymentMethodId'),
          couponCode: any(named: 'couponCode'),
          date: any(named: 'date'),
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          summary: any(named: 'summary'),
          query: any(named: 'query'),
          timezone: any(named: 'timezone'),
        ),
      ).thenAnswer(answer);
    }

    test('forwards the query field and maps a successful response to an entity', () async {
      stubBookSession((_) async => responseModel);

      final result = await repository.bookSession(
        stripePaymentMethodId: 'pm_123',
        date: '2026-07-10',
        startTime: '10:00',
        endTime: '10:30',
        summary: 'summary',
        query: 'Can I use this logo?',
        timezone: 'Asia/Karachi',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => remoteDataSource.bookSession(
          stripePaymentMethodId: 'pm_123',
          couponCode: null,
          date: '2026-07-10',
          startTime: '10:00',
          endTime: '10:30',
          summary: 'summary',
          query: 'Can I use this logo?',
          timezone: 'Asia/Karachi',
        ),
      ).called(1);
    });

    test('maps a DioException response body message to a ServerFailure', () async {
      when(
        () => remoteDataSource.bookSession(
          stripePaymentMethodId: any(named: 'stripePaymentMethodId'),
          couponCode: any(named: 'couponCode'),
          date: any(named: 'date'),
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          summary: any(named: 'summary'),
          query: any(named: 'query'),
          timezone: any(named: 'timezone'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/session-requests/book-session'),
          response: Response(
            requestOptions: RequestOptions(path: '/session-requests/book-session'),
            data: {'message': 'Slot no longer available'},
          ),
        ),
      );

      final result = await repository.bookSession(
        stripePaymentMethodId: 'pm_123',
        date: '2026-07-10',
        startTime: '10:00',
        endTime: '10:30',
        summary: 'summary',
        query: 'query',
        timezone: 'Asia/Karachi',
      );

      expect(result, const Left(ServerFailure('Slot no longer available')));
    });

    test('falls back to a generic message when the DioException has no response body', () async {
      when(
        () => remoteDataSource.bookSession(
          stripePaymentMethodId: any(named: 'stripePaymentMethodId'),
          couponCode: any(named: 'couponCode'),
          date: any(named: 'date'),
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
          summary: any(named: 'summary'),
          query: any(named: 'query'),
          timezone: any(named: 'timezone'),
        ),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '/session-requests/book-session')));

      final result = await repository.bookSession(
        stripePaymentMethodId: 'pm_123',
        date: '2026-07-10',
        startTime: '10:00',
        endTime: '10:30',
        summary: 'summary',
        query: 'query',
        timezone: 'Asia/Karachi',
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure.message, isNotEmpty), (_) => fail('expected Left'));
    });
  });
}
