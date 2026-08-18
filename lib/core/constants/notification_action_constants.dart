/// Identifiers shared between the notification that is built and the handlers
/// that react to it.
class NotificationActionConstants {
  const NotificationActionConstants._();

  /// Fixed id so a newer extension prompt replaces the previous one instead of
  /// stacking.
  static const int sessionExtensionNotificationId = 91001;
}
