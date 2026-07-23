import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:copyright_clinic_flutter/core/error/failures.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/ui/session_request_status.dart';
import 'package:copyright_clinic_flutter/core/utils/enumns/ui/sessions_tab.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/entities/book_session_response_entity.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/entities/cancel_session_request_response_entity.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/entities/user_session_request_entity.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/usecases/book_session_usecase.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/usecases/cancel_session_request_usecase.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/usecases/cancel_session_usecase.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/usecases/extend_session_usecase.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/usecases/get_session_availability_usecase.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/usecases/get_user_session_requests_usecase.dart';
import 'package:copyright_clinic_flutter/features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'package:copyright_clinic_flutter/features/sessions/presentation/bloc/sessions_bloc.dart';
import 'package:copyright_clinic_flutter/features/sessions/presentation/bloc/sessions_event.dart';
import 'package:copyright_clinic_flutter/features/sessions/presentation/bloc/sessions_state.dart';

class MockGetUserSessionsUseCase extends Mock implements GetUserSessionsUseCase {}

class MockGetUserSessionRequestsUseCase extends Mock implements GetUserSessionRequestsUseCase {}

class MockCancelSessionUseCase extends Mock implements CancelSessionUseCase {}

class MockCancelSessionRequestUseCase extends Mock implements CancelSessionRequestUseCase {}

class MockGetSessionAvailabilityUseCase extends Mock implements GetSessionAvailabilityUseCase {}

class MockBookSessionUseCase extends Mock implements BookSessionUseCase {}

class MockExtendSessionUseCase extends Mock implements ExtendSessionUseCase {}

UserSessionRequestEntity _buildRequest(String id, {SessionRequestStatus status = SessionRequestStatus.pending}) {
  return UserSessionRequestEntity(
    id: id,
    requestedDate: '2026-07-10',
    startTime: '10:00',
    endTime: '10:30',
    status: status,
    isFreeSession: false,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  );
}

void main() {
  late MockGetUserSessionsUseCase getUserSessionsUseCase;
  late MockGetUserSessionRequestsUseCase getUserSessionRequestsUseCase;
  late MockCancelSessionUseCase cancelSessionUseCase;
  late MockCancelSessionRequestUseCase cancelSessionRequestUseCase;
  late MockGetSessionAvailabilityUseCase getSessionAvailabilityUseCase;
  late MockBookSessionUseCase bookSessionUseCase;
  late MockExtendSessionUseCase extendSessionUseCase;

  setUpAll(() {
    registerFallbackValue(const GetUserSessionRequestsParams(timezone: 'UTC'));
    registerFallbackValue(const CancelSessionRequestParams(requestId: '', reason: ''));
    registerFallbackValue(
      const BookSessionParams(stripePaymentMethodId: '', date: '', startTime: '', endTime: '', summary: '', query: '', timezone: ''),
    );
  });

  setUp(() {
    getUserSessionsUseCase = MockGetUserSessionsUseCase();
    getUserSessionRequestsUseCase = MockGetUserSessionRequestsUseCase();
    cancelSessionUseCase = MockCancelSessionUseCase();
    cancelSessionRequestUseCase = MockCancelSessionRequestUseCase();
    getSessionAvailabilityUseCase = MockGetSessionAvailabilityUseCase();
    bookSessionUseCase = MockBookSessionUseCase();
    extendSessionUseCase = MockExtendSessionUseCase();
  });

  SessionsBloc buildBloc() {
    return SessionsBloc(
      getUserSessionsUseCase: getUserSessionsUseCase,
      getUserSessionRequestsUseCase: getUserSessionRequestsUseCase,
      cancelSessionUseCase: cancelSessionUseCase,
      cancelSessionRequestUseCase: cancelSessionRequestUseCase,
      getSessionAvailabilityUseCase: getSessionAvailabilityUseCase,
      bookSessionUseCase: bookSessionUseCase,
      extendSessionUseCase: extendSessionUseCase,
    );
  }

  group('SwitchToPending', () {
    blocTest<SessionsBloc, SessionsState>(
      'loads pending requests via the pending status filter when none are cached yet',
      build: () {
        when(() => getUserSessionRequestsUseCase.call(any())).thenAnswer((_) async => Right([_buildRequest('req-1')]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SwitchToPending()),
      expect: () => [
        predicate<SessionsState>((s) => s.currentTab == SessionsTab.pending && !s.hasError && !s.hasSuccess),
        predicate<SessionsState>((s) => s.isLoadingSessions == true),
        predicate<SessionsState>((s) => s.isLoadingSessions == false && s.pendingRequests?.length == 1),
      ],
      verify: (_) {
        verify(() => getUserSessionRequestsUseCase.call(const GetUserSessionRequestsParams(timezone: 'UTC', status: 'pending'))).called(1);
      },
    );

    blocTest<SessionsBloc, SessionsState>(
      'does not refetch when pending requests are already cached',
      build: buildBloc,
      seed: () => SessionsState(pendingRequests: [_buildRequest('req-1')], currentTab: SessionsTab.upcoming),
      act: (bloc) => bloc.add(const SwitchToPending()),
      expect: () => [predicate<SessionsState>((s) => s.currentTab == SessionsTab.pending)],
      verify: (_) {
        verifyNever(() => getUserSessionRequestsUseCase.call(any()));
      },
    );

    blocTest<SessionsBloc, SessionsState>(
      'clears a prior success/error message when switching tabs',
      build: buildBloc,
      seed: () => SessionsState(pendingRequests: const [], errorMessage: 'previous error', successMessage: 'previous success'),
      act: (bloc) => bloc.add(const SwitchToPending()),
      expect: () => [predicate<SessionsState>((s) => s.errorMessage == null && s.successMessage == null)],
    );
  });

  group('SwitchToCancelled', () {
    blocTest<SessionsBloc, SessionsState>(
      'loads cancelled requests using the "canceled" status filter',
      build: () {
        when(
          () => getUserSessionRequestsUseCase.call(any()),
        ).thenAnswer((_) async => Right([_buildRequest('req-2', status: SessionRequestStatus.canceled)]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SwitchToCancelled()),
      expect: () => [
        predicate<SessionsState>((s) => s.currentTab == SessionsTab.cancelled),
        predicate<SessionsState>((s) => s.isLoadingSessions == true),
        predicate<SessionsState>((s) => s.isLoadingSessions == false && s.cancelledRequests?.length == 1),
      ],
      verify: (_) {
        verify(() => getUserSessionRequestsUseCase.call(const GetUserSessionRequestsParams(timezone: 'UTC', status: 'canceled'))).called(1);
      },
    );

    blocTest<SessionsBloc, SessionsState>(
      'does not refetch when cancelled requests are already cached',
      build: buildBloc,
      seed: () => SessionsState(cancelledRequests: [_buildRequest('req-2', status: SessionRequestStatus.canceled)]),
      act: (bloc) => bloc.add(const SwitchToCancelled()),
      verify: (_) {
        verifyNever(() => getUserSessionRequestsUseCase.call(any()));
      },
    );
  });

  group('CancelSessionRequestSubmitted', () {
    blocTest<SessionsBloc, SessionsState>(
      'on success, refreshes pending requests but leaves the cancelled tab untouched if it was never loaded',
      build: () {
        when(
          () => cancelSessionRequestUseCase.call(any()),
        ).thenAnswer((_) async => const Right(CancelSessionRequestResponseEntity(message: 'Cancelled')));
        when(() => getUserSessionRequestsUseCase.call(any())).thenAnswer((_) async => Right([_buildRequest('req-1')]));
        return buildBloc();
      },
      seed: () => SessionsState(pendingRequests: const []),
      act: (bloc) => bloc.add(const CancelSessionRequestSubmitted(requestId: 'req-1', reason: 'changed my mind')),
      expect: () => [
        predicate<SessionsState>((s) => s.isProcessingCancel == true && s.cancellingSessionId == 'req-1'),
        predicate<SessionsState>((s) => s.isProcessingCancel == false && s.successMessage == 'Cancelled' && s.cancellingSessionId == null),
        predicate<SessionsState>((s) => s.pendingRequests?.length == 1),
      ],
      verify: (_) {
        verify(
          () => cancelSessionRequestUseCase.call(const CancelSessionRequestParams(requestId: 'req-1', reason: 'changed my mind')),
        ).called(1);
        verify(() => getUserSessionRequestsUseCase.call(const GetUserSessionRequestsParams(timezone: 'UTC', status: 'pending'))).called(1);
        verifyNever(() => getUserSessionRequestsUseCase.call(const GetUserSessionRequestsParams(timezone: 'UTC', status: 'canceled')));
      },
    );

    blocTest<SessionsBloc, SessionsState>(
      'on success, also refreshes cancelled requests when that tab has already been loaded',
      build: () {
        when(
          () => cancelSessionRequestUseCase.call(any()),
        ).thenAnswer((_) async => const Right(CancelSessionRequestResponseEntity(message: 'Cancelled')));
        when(
          () => getUserSessionRequestsUseCase.call(const GetUserSessionRequestsParams(timezone: 'UTC', status: 'pending')),
        ).thenAnswer((_) async => Right([_buildRequest('req-1')]));
        when(
          () => getUserSessionRequestsUseCase.call(const GetUserSessionRequestsParams(timezone: 'UTC', status: 'canceled')),
        ).thenAnswer((_) async => Right([_buildRequest('req-2', status: SessionRequestStatus.canceled)]));
        return buildBloc();
      },
      seed: () => SessionsState(
        pendingRequests: const [],
        cancelledRequests: [_buildRequest('req-old', status: SessionRequestStatus.canceled)],
      ),
      act: (bloc) => bloc.add(const CancelSessionRequestSubmitted(requestId: 'req-1', reason: 'changed my mind')),
      verify: (_) {
        verify(() => getUserSessionRequestsUseCase.call(const GetUserSessionRequestsParams(timezone: 'UTC', status: 'pending'))).called(1);
        verify(() => getUserSessionRequestsUseCase.call(const GetUserSessionRequestsParams(timezone: 'UTC', status: 'canceled'))).called(1);
      },
    );

    blocTest<SessionsBloc, SessionsState>(
      'on failure, surfaces the error and does not refresh any lists',
      build: () {
        when(() => cancelSessionRequestUseCase.call(any())).thenAnswer((_) async => const Left(ServerFailure('cannot cancel')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CancelSessionRequestSubmitted(requestId: 'req-1', reason: 'changed my mind')),
      expect: () => [
        predicate<SessionsState>((s) => s.isProcessingCancel == true),
        predicate<SessionsState>((s) => s.isProcessingCancel == false && s.errorMessage == 'cannot cancel' && s.cancellingSessionId == null),
      ],
      verify: (_) {
        verifyNever(() => getUserSessionRequestsUseCase.call(any()));
      },
    );
  });

  group('BookSessionRequested', () {
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

    blocTest<SessionsBloc, SessionsState>(
      'forwards the new query field from the event through to the use case',
      build: () {
        when(() => bookSessionUseCase.call(any())).thenAnswer((_) async => Right(responseEntity));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const BookSessionRequested(
          stripePaymentMethodId: 'pm_123',
          date: '2026-07-10',
          startTime: '10:00',
          endTime: '10:30',
          summary: 'summary',
          query: 'Can I use this logo?',
          timezone: 'Asia/Karachi',
        ),
      ),
      expect: () => [
        predicate<SessionsState>((s) => s.isProcessingBook == true),
        predicate<SessionsState>((s) => s.isProcessingBook == false && s.bookSessionResponse == responseEntity && s.successMessage == 'Booked'),
      ],
      verify: (_) {
        verify(
          () => bookSessionUseCase.call(
            const BookSessionParams(
              stripePaymentMethodId: 'pm_123',
              date: '2026-07-10',
              startTime: '10:00',
              endTime: '10:30',
              summary: 'summary',
              query: 'Can I use this logo?',
              timezone: 'Asia/Karachi',
            ),
          ),
        ).called(1);
      },
    );
  });
}
