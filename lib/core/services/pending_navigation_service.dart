import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/logger/logger.dart';

class PendingNavigationService {
  static final PendingNavigationService _instance = PendingNavigationService._internal();
  factory PendingNavigationService() => _instance;
  PendingNavigationService._internal();

  RemoteMessage? _pendingMessage;
  bool _hasBeenHandled = false;

  void setPendingNotification(RemoteMessage message) {
    Log.i(runtimeType, '📌 ========================================');
    Log.i(runtimeType, '📌 STORING PENDING NOTIFICATION');
    Log.i(runtimeType, '📌 ========================================');
    Log.i(runtimeType, '📌 Message ID: ${message.messageId}');
    Log.i(runtimeType, '📌 Type: ${message.data['type']}');
    Log.i(runtimeType, '📌 Will be handled after splash completes');
    Log.i(runtimeType, '📌 ========================================');

    _pendingMessage = message;
    _hasBeenHandled = false;
  }

  RemoteMessage? getPendingNotification() {
    if (_hasBeenHandled) {
      Log.i(runtimeType, '✅ Pending notification already handled, returning null');
      return null;
    }

    if (_pendingMessage != null) {
      Log.i(runtimeType, '📌 ========================================');
      Log.i(runtimeType, '📌 RETRIEVING PENDING NOTIFICATION');
      Log.i(runtimeType, '📌 ========================================');
      Log.i(runtimeType, '📌 Message ID: ${_pendingMessage!.messageId}');
      Log.i(runtimeType, '📌 Type: ${_pendingMessage!.data['type']}');
      Log.i(runtimeType, '📌 Ready to be handled now');
      Log.i(runtimeType, '📌 ========================================');
    } else {
      Log.i(runtimeType, '📌 No pending notification found');
    }

    return _pendingMessage;
  }

  bool hasPendingNotification() {
    return _pendingMessage != null && !_hasBeenHandled;
  }

  void markAsHandled() {
    Log.i(runtimeType, '✅ Marking pending notification as handled');
    _hasBeenHandled = true;
  }

  void clear() {
    Log.i(runtimeType, '🗑️ Clearing pending notification');
    _pendingMessage = null;
    _hasBeenHandled = false;
  }

  bool shouldSkipDefaultNavigation() {
    final shouldSkip = _pendingMessage != null;
    if (shouldSkip) {
      Log.i(runtimeType, '🚫 Splash should SKIP default navigation (notification will handle it)');
    }
    return shouldSkip;
  }
}
