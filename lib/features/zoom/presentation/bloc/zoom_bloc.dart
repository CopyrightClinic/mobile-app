import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/zoom_service.dart';
import '../../../../core/utils/enumns/ui/zoom_meeting_status.dart';
import '../../../../core/utils/logger/logger.dart';
import 'zoom_event.dart';
import 'zoom_state.dart';

class ZoomBloc extends Bloc<ZoomEvent, ZoomState> {
  final ZoomService zoomService;
  StreamSubscription? _meetingStatusSubscription;

  ZoomBloc({required this.zoomService}) : super(const ZoomInitial()) {
    on<InitializeZoom>(_onInitializeZoom);
    on<JoinMeetingRequested>(_onJoinMeetingRequested);
    on<LeaveMeetingRequested>(_onLeaveMeetingRequested);
    on<MeetingStatusUpdated>(_onMeetingStatusUpdated);
    on<ResetZoomState>(_onResetZoomState);

    _listenToMeetingEvents();
  }

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
      Log.e('ZoomBloc', 'Platform exception during initialization: ${e.code} - ${e.message}');

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
      Log.e('ZoomBloc', 'Error during initialization: $e');
      emit(ZoomInitializationFailed(message: '${AppStrings.zoomErrorInitFailed}: $e'));
    }
  }

  Future<void> _onJoinMeetingRequested(JoinMeetingRequested event, Emitter<ZoomState> emit) async {
    emit(ZoomJoining(meetingNumber: event.meetingNumber));

    try {
      await zoomService.joinMeeting(meetingNumber: event.meetingNumber, passcode: event.passcode, displayName: event.displayName);
    } on PlatformException catch (e) {
      Log.e('ZoomBloc', 'Platform exception during join: ${e.code} - ${e.message}');

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
      Log.e('ZoomBloc', 'Error during join: $e');
      emit(ZoomMeetingFailed(message: '${AppStrings.zoomErrorJoinFailed}: $e'));
    }
  }

  Future<void> _onLeaveMeetingRequested(LeaveMeetingRequested event, Emitter<ZoomState> emit) async {
    try {
      await zoomService.leaveMeeting();
      emit(const ZoomMeetingEnded(message: null));
    } catch (e) {
      Log.e('ZoomBloc', 'Error leaving meeting: $e');
    }
  }

  void _onMeetingStatusUpdated(MeetingStatusUpdated event, Emitter<ZoomState> emit) {
    final status = ZoomMeetingStatus.fromString(event.status);

    if (status.isActive || status.isWaiting || status.isConnecting) {
      emit(ZoomMeetingActive(status: status, message: event.message));
    } else if (status.isError) {
      emit(ZoomMeetingFailed(message: event.message ?? AppStrings.zoomStatusFailed));
    } else if (status.isFinished) {
      emit(ZoomMeetingEnded(message: event.message));
    }
  }

  void _onResetZoomState(ResetZoomState event, Emitter<ZoomState> emit) {
    emit(const ZoomInitial());
  }

  @override
  Future<void> close() {
    _meetingStatusSubscription?.cancel();
    zoomService.dispose();
    return super.close();
  }
}
