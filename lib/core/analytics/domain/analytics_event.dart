import 'analytics_event_type.dart';
import 'payloads/commerce_payload.dart';
import 'payloads/registration_payload.dart';
import 'payloads/search_payload.dart';
import 'payloads/view_content_payload.dart';

sealed class AnalyticsEvent {
  const AnalyticsEvent();

  AnalyticsEventType get type;
}

final class AppInstallAnalyticsEvent extends AnalyticsEvent {
  const AppInstallAnalyticsEvent();

  @override
  AnalyticsEventType get type => AnalyticsEventType.appInstall;
}

final class AppOpenAnalyticsEvent extends AnalyticsEvent {
  final bool fromBackground;

  const AppOpenAnalyticsEvent({this.fromBackground = false});

  @override
  AnalyticsEventType get type => AnalyticsEventType.appOpen;
}

final class CompleteRegistrationAnalyticsEvent extends AnalyticsEvent {
  final CompleteRegistrationPayload payload;

  const CompleteRegistrationAnalyticsEvent(this.payload);

  @override
  AnalyticsEventType get type => AnalyticsEventType.completeRegistration;
}

final class ViewContentAnalyticsEvent extends AnalyticsEvent {
  final ViewContentPayload payload;

  const ViewContentAnalyticsEvent(this.payload);

  @override
  AnalyticsEventType get type => AnalyticsEventType.viewContent;
}

final class SearchAnalyticsEvent extends AnalyticsEvent {
  final SearchPayload payload;

  const SearchAnalyticsEvent(this.payload);

  @override
  AnalyticsEventType get type => AnalyticsEventType.search;
}

final class InitiateCheckoutAnalyticsEvent extends AnalyticsEvent {
  final InitiateCheckoutPayload payload;

  const InitiateCheckoutAnalyticsEvent(this.payload);

  @override
  AnalyticsEventType get type => AnalyticsEventType.initiateCheckout;
}

final class PurchaseAnalyticsEvent extends AnalyticsEvent {
  final PurchasePayload payload;

  const PurchaseAnalyticsEvent(this.payload);

  @override
  AnalyticsEventType get type => AnalyticsEventType.purchase;
}
