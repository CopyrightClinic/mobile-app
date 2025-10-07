import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../constants/app_strings.dart';

enum ZoomMeetingStatus {
  idle,
  connecting,
  waitingForHost,
  inWaitingRoom,
  inMeeting,
  disconnecting,
  reconnecting,
  failed,
  ended,
  locked,
  unlocked,
  authExpired,
  unknown;

  static ZoomMeetingStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'IDLE':
        return ZoomMeetingStatus.idle;
      case 'CONNECTING':
        return ZoomMeetingStatus.connecting;
      case 'WAITING_FOR_HOST':
        return ZoomMeetingStatus.waitingForHost;
      case 'IN_WAITING_ROOM':
        return ZoomMeetingStatus.inWaitingRoom;
      case 'IN_MEETING':
        return ZoomMeetingStatus.inMeeting;
      case 'DISCONNECTING':
        return ZoomMeetingStatus.disconnecting;
      case 'RECONNECTING':
        return ZoomMeetingStatus.reconnecting;
      case 'FAILED':
        return ZoomMeetingStatus.failed;
      case 'ENDED':
        return ZoomMeetingStatus.ended;
      case 'LOCKED':
        return ZoomMeetingStatus.locked;
      case 'UNLOCKED':
        return ZoomMeetingStatus.unlocked;
      case 'AUTH_EXPIRED':
        return ZoomMeetingStatus.authExpired;
      default:
        return ZoomMeetingStatus.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case ZoomMeetingStatus.idle:
        return AppStrings.zoomStatusIdle;
      case ZoomMeetingStatus.connecting:
        return AppStrings.zoomStatusConnecting;
      case ZoomMeetingStatus.waitingForHost:
        return AppStrings.zoomStatusWaitingForHost;
      case ZoomMeetingStatus.inWaitingRoom:
        return AppStrings.zoomStatusInWaitingRoom;
      case ZoomMeetingStatus.inMeeting:
        return AppStrings.zoomStatusInMeeting;
      case ZoomMeetingStatus.disconnecting:
        return AppStrings.zoomStatusDisconnecting;
      case ZoomMeetingStatus.reconnecting:
        return AppStrings.zoomStatusReconnecting;
      case ZoomMeetingStatus.failed:
        return AppStrings.zoomStatusFailed;
      case ZoomMeetingStatus.ended:
        return AppStrings.zoomStatusEnded;
      case ZoomMeetingStatus.locked:
        return AppStrings.zoomStatusLocked;
      case ZoomMeetingStatus.unlocked:
        return AppStrings.zoomStatusUnlocked;
      case ZoomMeetingStatus.authExpired:
        return AppStrings.zoomStatusAuthExpired;
      case ZoomMeetingStatus.unknown:
        return AppStrings.zoomStatusUnknown;
    }
  }

  Color get statusColor {
    switch (this) {
      case ZoomMeetingStatus.idle:
        return AppTheme.textBodyLight;
      case ZoomMeetingStatus.connecting:
      case ZoomMeetingStatus.reconnecting:
        return AppTheme.orange;
      case ZoomMeetingStatus.waitingForHost:
      case ZoomMeetingStatus.inWaitingRoom:
        return AppTheme.orange;
      case ZoomMeetingStatus.inMeeting:
        return AppTheme.green;
      case ZoomMeetingStatus.disconnecting:
        return AppTheme.textBodyLight;
      case ZoomMeetingStatus.failed:
      case ZoomMeetingStatus.locked:
      case ZoomMeetingStatus.authExpired:
        return AppTheme.red;
      case ZoomMeetingStatus.ended:
        return AppTheme.textBody;
      case ZoomMeetingStatus.unlocked:
        return AppTheme.green;
      case ZoomMeetingStatus.unknown:
        return AppTheme.textBodyLight;
    }
  }

  bool get isConnecting => this == ZoomMeetingStatus.connecting || this == ZoomMeetingStatus.reconnecting;

  bool get isWaiting => this == ZoomMeetingStatus.waitingForHost || this == ZoomMeetingStatus.inWaitingRoom;

  bool get isActive => this == ZoomMeetingStatus.inMeeting;

  bool get isError => this == ZoomMeetingStatus.failed || this == ZoomMeetingStatus.locked || this == ZoomMeetingStatus.authExpired;

  bool get isFinished => this == ZoomMeetingStatus.ended || this == ZoomMeetingStatus.idle;
}
