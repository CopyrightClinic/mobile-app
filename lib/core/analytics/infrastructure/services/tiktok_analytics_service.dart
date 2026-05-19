import 'package:flutter/foundation.dart';
import 'package:tiktok_events_sdk/tiktok_events_sdk.dart';

import '../../domain/analytics_events.dart';
import '../mapping/analytics_currency_codec.dart';
import '../mapping/tiktok_dispatch_payload.dart';
import '../sanitization/analytics_parameter_sanitizer.dart';
import 'analytics_platform_service.dart';

final class TikTokAnalyticsService implements AnalyticsPlatformService {
  TikTokAnalyticsService({required bool enabled}) : _enabled = enabled;

  final bool _enabled;

  @override
  bool get isEnabled => _enabled;

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (!_enabled) return;
    final normalized = AnalyticsParameterSanitizer.normalizeEventName(eventName);
    try {
      switch (normalized) {
        case AnalyticsEvents.appInstall:
          await _logBase(BaseEventName.installApp);
        case AnalyticsEvents.appOpen:
          await _logBase(BaseEventName.launchApp);
        case AnalyticsEvents.completeRegistration:
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(
              eventName: BaseEventName.registration.value,
              eventType: TTEventType.none,
              properties: EventProperties(customProperties: AnalyticsParameterSanitizer.forTikTokCustom(parameters)),
            ),
          );
        case AnalyticsEvents.login:
          await _logCustom('Login', AnalyticsParameterSanitizer.forTikTokCustom(parameters));
        case AnalyticsEvents.viewContent:
          await _logViewContent(parameters);
        case AnalyticsEvents.search:
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(
              eventName: BaseEventName.search.value,
              eventType: TTEventType.none,
              properties: EventProperties(
                description: AnalyticsParameterSanitizer.clipForTikTok(
                  AnalyticsParameterSanitizer.stringValue(parameters, 'search_term') ?? 'unknown',
                ),
                customProperties: AnalyticsParameterSanitizer.forTikTokCustom(parameters),
              ),
            ),
          );
        case AnalyticsEvents.selectSessionSlot:
          await _logCustom('SelectSessionSlot', AnalyticsParameterSanitizer.forTikTokCustom(parameters));
        case AnalyticsEvents.addToCart:
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(eventName: 'AddToCart', eventType: TTEventType.addToCart, properties: _commerceProperties(parameters)),
          );
        case AnalyticsEvents.initiateCheckout:
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(eventName: 'Checkout', eventType: TTEventType.checkout, properties: _commerceProperties(parameters)),
          );
        case AnalyticsEvents.addPaymentInfo:
          await _logCustom('AddPaymentInfo', AnalyticsParameterSanitizer.forTikTokCustom(parameters));
        case AnalyticsEvents.purchase:
          await _logPurchase(parameters);
        default:
          await _logCustom(normalized, AnalyticsParameterSanitizer.forTikTokCustom(parameters));
      }
    } catch (error, stack) {
      print('tiktok error: $error');
      _logDebugError(normalized, error, stack);
    }
  }

  Future<void> _logBase(BaseEventName eventName) async {
    await TikTokEventsSdk.logEvent(event: TikTokEvent(eventName: eventName.value, eventType: TTEventType.none));
  }

  Future<void> _logCustom(String eventName, Map<String, dynamic> customProperties) async {
    await TikTokEventsSdk.logEvent(
      event: TikTokEvent(
        eventName: AnalyticsParameterSanitizer.clipForTikTok(eventName),
        eventType: TTEventType.none,
        properties: EventProperties(customProperties: customProperties),
      ),
    );
  }

  Future<void> _logViewContent(Map<String, dynamic>? parameters) async {
    print('tiktok _logViewContent: $parameters');
    await TikTokEventsSdk.logEvent(
          event: TikTokEvent(
            eventName: 'ViewContent',
            eventType: TTEventType.viewContent,
            properties: EventProperties(
              contentType: TikTokDispatchPayload.clipNullable(AnalyticsParameterSanitizer.stringValue(parameters, 'content_type')),
              contentId: TikTokDispatchPayload.clip(AnalyticsParameterSanitizer.stringValue(parameters, 'content_id') ?? 'unknown'),
              contentName: TikTokDispatchPayload.clipNullable(AnalyticsParameterSanitizer.stringValue(parameters, 'content_name')),
              currency: AnalyticsCurrencyCodec.toTikTokCurrency(AnalyticsParameterSanitizer.stringValue(parameters, 'currency') ?? 'USD'),
              value: AnalyticsParameterSanitizer.doubleValue(parameters, 'value'),
              customProperties: AnalyticsParameterSanitizer.forTikTokCustom(parameters),
            ),
          ),
        )
        .then((value) {
          print('tiktok _logViewContent success: ');
        })
        .catchError((error) {
          print('tiktok _logViewContent error: $error');
        });
  }

  Future<void> _logPurchase(Map<String, dynamic>? parameters) async {
    final transactionId =
        AnalyticsParameterSanitizer.stringValue(parameters, 'transaction_id') ??
        AnalyticsParameterSanitizer.stringValue(parameters, 'order_id') ??
        'unknown';
    await TikTokEventsSdk.logEvent(
      event: TikTokEvent(
        eventName: 'Purchase',
        eventType: TTEventType.purchase,
        eventId: TikTokDispatchPayload.clip(transactionId),
        properties: _commerceProperties(parameters),
      ),
    );
  }

  EventProperties _commerceProperties(Map<String, dynamic>? parameters) {
    return EventProperties(
      value: TikTokDispatchPayload.finiteValue(AnalyticsParameterSanitizer.doubleValue(parameters, 'value') ?? 0),
      currency: AnalyticsCurrencyCodec.toTikTokCurrency(AnalyticsParameterSanitizer.stringValue(parameters, 'currency') ?? 'USD'),
      quantity: AnalyticsParameterSanitizer.intValue(parameters, 'quantity') ?? AnalyticsParameterSanitizer.intValue(parameters, 'item_count'),
      contentId: TikTokDispatchPayload.clip(
        AnalyticsParameterSanitizer.stringValue(parameters, 'item_id') ??
            AnalyticsParameterSanitizer.stringValue(parameters, 'content_id') ??
            AnalyticsParameterSanitizer.stringValue(parameters, 'checkout_id') ??
            'unknown',
      ),
      contentType: TikTokDispatchPayload.clipNullable(AnalyticsParameterSanitizer.stringValue(parameters, 'content_type') ?? 'consultation'),
      contentName: TikTokDispatchPayload.clipNullable(
        AnalyticsParameterSanitizer.stringValue(parameters, 'item_name') ?? AnalyticsParameterSanitizer.stringValue(parameters, 'content_name'),
      ),
      customProperties: AnalyticsParameterSanitizer.forTikTokCustom(parameters),
    );
  }

  void _logDebugError(String eventName, Object error, StackTrace stack) {
    if (kReleaseMode) return;
    debugPrint('[analytics][tiktok] event=$eventName error=$error');
    debugPrintStack(stackTrace: stack, label: '[analytics][tiktok]');
  }
}
