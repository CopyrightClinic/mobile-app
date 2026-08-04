import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:copyright_clinic_flutter/core/services/zoom_service.dart';
import 'package:copyright_clinic_flutter/features/zoom/domain/entities/zoom_meeting_credentials_entity.dart';
import 'package:copyright_clinic_flutter/features/zoom/domain/usecases/get_meeting_credentials_usecase.dart';
import 'package:copyright_clinic_flutter/features/zoom/presentation/bloc/zoom_bloc.dart';
import 'package:copyright_clinic_flutter/features/zoom/presentation/bloc/zoom_event.dart';
import 'package:copyright_clinic_flutter/features/zoom/presentation/bloc/zoom_state.dart';

class MockZoomService extends Mock implements ZoomService {}

class MockGetMeetingCredentialsUseCase extends Mock implements GetMeetingCredentialsUseCase {}

void main() {
  late MockZoomService zoomService;
  late MockGetMeetingCredentialsUseCase getMeetingCredentialsUseCase;

  setUp(() {
    zoomService = MockZoomService();
    getMeetingCredentialsUseCase = MockGetMeetingCredentialsUseCase();
    when(() => zoomService.listenToMeetingEvents(onStatusChanged: any(named: 'onStatusChanged'))).thenReturn(null);
    when(() => zoomService.dispose()).thenReturn(null);
  });

  ZoomBloc buildBloc() => ZoomBloc(zoomService: zoomService, getMeetingCredentialsUseCase: getMeetingCredentialsUseCase);

  group('JoinMeetingWithId - meeting-not-joining fix', () {
    blocTest<ZoomBloc, ZoomState>(
      'falls back to an empty display name instead of crashing when userName is null',
      build: () {
        when(() => getMeetingCredentialsUseCase.call(any())).thenAnswer(
          (_) async => const Right(
            ZoomMeetingCredentialsEntity(signature: 'sig', meetingNumber: '123456789', password: 'pass', userName: null),
          ),
        );
        when(() => zoomService.initZoomWithJwt(any())).thenAnswer((_) async => {'success': true});
        when(
          () => zoomService.joinMeeting(
            meetingNumber: any(named: 'meetingNumber'),
            passcode: any(named: 'passcode'),
            displayName: any(named: 'displayName'),
          ),
        ).thenAnswer((_) async => {'success': true});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const JoinMeetingWithId(meetingId: 'meeting-1')),
      expect: () => [isA<ZoomFetchingCredentials>(), isA<ZoomJoining>()],
      verify: (_) {
        verify(
          () => zoomService.joinMeeting(meetingNumber: '123456789', passcode: 'pass', displayName: ''),
        ).called(1);
      },
    );

    blocTest<ZoomBloc, ZoomState>(
      'passes the real display name through unchanged when userName is present',
      build: () {
        when(() => getMeetingCredentialsUseCase.call(any())).thenAnswer(
          (_) async => const Right(
            ZoomMeetingCredentialsEntity(signature: 'sig', meetingNumber: '123456789', password: 'pass', userName: 'Jane Doe'),
          ),
        );
        when(() => zoomService.initZoomWithJwt(any())).thenAnswer((_) async => {'success': true});
        when(
          () => zoomService.joinMeeting(
            meetingNumber: any(named: 'meetingNumber'),
            passcode: any(named: 'passcode'),
            displayName: any(named: 'displayName'),
          ),
        ).thenAnswer((_) async => {'success': true});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const JoinMeetingWithId(meetingId: 'meeting-1')),
      expect: () => [isA<ZoomFetchingCredentials>(), isA<ZoomJoining>()],
      verify: (_) {
        verify(
          () => zoomService.joinMeeting(meetingNumber: '123456789', passcode: 'pass', displayName: 'Jane Doe'),
        ).called(1);
      },
    );

    test('the NOT_INITIALIZED retry also falls back to an empty display name, not a null crash', () async {
      when(() => getMeetingCredentialsUseCase.call(any())).thenAnswer(
        (_) async => const Right(
          ZoomMeetingCredentialsEntity(signature: 'sig', meetingNumber: '123456789', password: 'pass', userName: null),
        ),
      );
      when(() => zoomService.initZoomWithJwt(any())).thenAnswer((_) async => {'success': true});

      var joinAttempts = 0;
      when(
        () => zoomService.joinMeeting(
          meetingNumber: any(named: 'meetingNumber'),
          passcode: any(named: 'passcode'),
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async {
        joinAttempts++;
        if (joinAttempts == 1) {
          throw PlatformException(code: 'NOT_INITIALIZED');
        }
        return {'success': true};
      });

      final bloc = buildBloc();
      addTearDown(bloc.close);

      bloc.add(const JoinMeetingWithId(meetingId: 'meeting-1'));

      // Bloc coalesces the two ZoomJoining(meetingNumber: ...) emissions since they're
      // equal, so the retry can't be observed on the state stream - poll the mock
      // invocation count instead, pumping the event loop between checks.
      for (var i = 0; i < 100 && joinAttempts < 2; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(joinAttempts, 2);
      verify(() => zoomService.initZoomWithJwt('sig')).called(2);

      final capturedDisplayNames = verify(
        () => zoomService.joinMeeting(
          meetingNumber: any(named: 'meetingNumber'),
          passcode: any(named: 'passcode'),
          displayName: captureAny(named: 'displayName'),
        ),
      ).captured;
      expect(capturedDisplayNames, ['', '']);
    });
  });
}
