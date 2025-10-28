import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/zoom_service.dart';
import '../../../../core/utils/enumns/ui/zoom_meeting_status.dart';
import '../../domain/usecases/get_meeting_credentials_usecase.dart';
import 'zoom_event.dart';
import 'zoom_state.dart';

class ZoomBloc extends Bloc<ZoomEvent, ZoomState> {
  final ZoomService zoomService;
  final GetMeetingCredentialsUseCase getMeetingCredentialsUseCase;
  String? _currentSessionId;

  ZoomBloc({required this.zoomService, required this.getMeetingCredentialsUseCase}) : super(const ZoomInitial()) {
    on<InitializeZoom>(_onInitializeZoom);
    on<JoinMeetingRequested>(_onJoinMeetingRequested);
    on<JoinMeetingWithId>(_onJoinMeetingWithId);
    on<LeaveMeetingRequested>(_onLeaveMeetingRequested);
    on<MeetingStatusUpdated>(_onMeetingStatusUpdated);
    on<ResetZoomState>(_onResetZoomState);

    _listenToMeetingEvents();
  }

  String? get currentSessionId => _currentSessionId;

  void _listenToMeetingEvents() {
    zoomService.listenToMeetingEvents(
      onStatusChanged: (status, message) {
        add(MeetingStatusUpdated(status: status.name, message: message));
      },
    );
  }

  Future<void> _onInitializeZoom(InitializeZoom event, Emitter<ZoomState> emit) async {
    if (zoomService.isInitialized) {
      emit(const ZoomInitialized());
      return;
    }

    emit(const ZoomInitializing());

    try {
      await zoomService.initZoom();
      emit(const ZoomInitialized());
    } on PlatformException catch (e) {
      String errorMessage = AppStrings.zoomErrorInitFailed;

      switch (e.code) {
        case 'JWT_INVALID':
          errorMessage = AppStrings.zoomErrorJwtInvalid;
          break;
        case 'NETWORK_UNAVAILABLE':
          errorMessage = AppStrings.zoomErrorNetworkUnavailable;
          break;
        default:
          if (e.message != null) {
            errorMessage = e.message!;
          }
      }

      emit(ZoomInitializationFailed(message: errorMessage));
    } catch (e) {
      emit(ZoomInitializationFailed(message: '${AppStrings.zoomErrorInitFailed}: $e'));
    }
  }

  Future<void> _onJoinMeetingRequested(JoinMeetingRequested event, Emitter<ZoomState> emit) async {
    emit(ZoomJoining(meetingNumber: event.meetingNumber));

    try {
      await zoomService.joinMeeting(meetingNumber: event.meetingNumber, passcode: event.passcode, displayName: event.displayName);
    } on PlatformException catch (e) {
      String errorMessage = AppStrings.zoomErrorJoinFailed;

      switch (e.code) {
        case 'NETWORK_UNAVAILABLE':
          errorMessage = AppStrings.zoomErrorNetworkUnavailable;
          break;
        case 'INVALID_ARGUMENTS':
          errorMessage = AppStrings.zoomErrorInvalidMeetingNumber;
          break;
        case 'JWT_INVALID':
          errorMessage = AppStrings.zoomErrorJwtInvalid;
          break;
        case 'NOT_INITIALIZED':
          emit(const ZoomInitializing());
          await zoomService.initZoom();
          add(JoinMeetingRequested(meetingNumber: event.meetingNumber, passcode: event.passcode, displayName: event.displayName));
          return;
        default:
          if (e.message != null) {
            errorMessage = e.message!;
          }
      }

      emit(ZoomMeetingFailed(message: errorMessage));
    } catch (e) {
      emit(ZoomMeetingFailed(message: '${AppStrings.zoomErrorJoinFailed}: $e'));
    }
  }

  Future<void> _onJoinMeetingWithId(JoinMeetingWithId event, Emitter<ZoomState> emit) async {
    emit(ZoomFetchingCredentials(meetingId: event.meetingId));
    _currentSessionId = event.meetingId;

    final result = await getMeetingCredentialsUseCase(event.meetingId);

    await result.fold(
      (failure) async {
        _currentSessionId = null;
        emit(ZoomMeetingFailed(message: failure.message ?? AppStrings.zoomErrorFetchCredentials));
      },
      (credentials) async {
        emit(ZoomJoining(meetingNumber: credentials.meetingNumber));

        try {
          await zoomService.initZoomWithJwt(credentials.signature);

          await zoomService.joinMeeting(meetingNumber: credentials.meetingNumber, passcode: credentials.password, displayName: credentials.userName);
        } on PlatformException catch (e) {
          String errorMessage = AppStrings.zoomErrorJoinFailed;

          switch (e.code) {
            case 'NETWORK_UNAVAILABLE':
              errorMessage = AppStrings.zoomErrorNetworkUnavailable;
              break;
            case 'INVALID_ARGUMENTS':
              errorMessage = AppStrings.zoomErrorInvalidMeetingNumber;
              break;
            case 'JWT_INVALID':
              errorMessage = AppStrings.zoomErrorJwtInvalid;
              break;
            case 'NOT_INITIALIZED':
              await zoomService.initZoomWithJwt(credentials.signature);
              add(JoinMeetingRequested(meetingNumber: credentials.meetingNumber, passcode: credentials.password, displayName: credentials.userName));
              return;
            default:
              if (e.message != null) {
                errorMessage = e.message!;
              }
          }

          _currentSessionId = null;
          emit(ZoomMeetingFailed(message: errorMessage));
        } catch (e) {
          _currentSessionId = null;
          emit(ZoomMeetingFailed(message: '${AppStrings.zoomErrorJoinFailed}: $e'));
        }
      },
    );
  }

  Future<void> _onLeaveMeetingRequested(LeaveMeetingRequested event, Emitter<ZoomState> emit) async {
    try {
      await zoomService.leaveMeeting();
      _currentSessionId = null;
      emit(const ZoomMeetingEnded(message: null));
    } catch (e) {
      _currentSessionId = null;
    }
  }

  void _onMeetingStatusUpdated(MeetingStatusUpdated event, Emitter<ZoomState> emit) {
    final status = ZoomMeetingStatus.fromString(event.status);

    if (status.isActive || status.isWaiting || status.isConnecting) {
      emit(ZoomMeetingActive(status: status, message: event.message, sessionId: _currentSessionId));
    } else if (status == ZoomMeetingStatus.disconnecting) {
      // Do nothing, wait for end state
    } else if (status.isError) {
      _currentSessionId = null;
      emit(ZoomMeetingFailed(message: event.message ?? AppStrings.zoomStatusFailed));
    } else if (status.isFinished) {
      _currentSessionId = null;
      emit(ZoomMeetingEnded(message: event.message));
    }
  }

  void _onResetZoomState(ResetZoomState event, Emitter<ZoomState> emit) {
    _currentSessionId = null;
    emit(const ZoomInitial());
  }

  @override
  Future<void> close() {
    zoomService.dispose();
    return super.close();
  }
}
