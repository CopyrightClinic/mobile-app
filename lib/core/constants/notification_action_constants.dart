/// Identifiers shared between the notification that is built and the handlers
/// that react to its action buttons. iOS additionally needs the category id to
/// be registered up-front (see [LocalNotificationService.initialize]).
class NotificationActionConstants {
  const NotificationActionConstants._();

  static const String sessionExtensionCategoryId = 'SESSION_EXTENSION_PROMPT';
  static const String acceptExtensionActionId = 'ACCEPT_EXTENSION';
  static const String declineExtensionActionId = 'DECLINE_EXTENSION';

  /// Fixed id so a newer extension prompt replaces the previous one instead of
  /// stacking, and so the decline handler can always dismiss it.
  static const int sessionExtensionNotificationId = 91001;
}
