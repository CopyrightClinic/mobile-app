import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

import '../../domain/analytics_events.dart';
import '../mapping/analytics_currency_codec.dart';
import '../sanitization/analytics_parameter_sanitizer.dart';
import 'analytics_platform_service.dart';

final class MetaAnalyticsService implements AnalyticsPlatformService {
  MetaAnalyticsService({
    required FacebookAppEvents appEvents,
    required bool enabled,
  }) : _appEvents = appEvents,
       _enabled = enabled;

  final FacebookAppEvents _appEvents;
  final bool _enabled;

  @override
  bool get isEnabled => _enabled;

  @override
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_enabled) return;
    final normalized = AnalyticsParameterSanitizer.normalizeEventName(eventName);
    try {
      switch (normalized) {
        case AnalyticsEvents.appInstall:
          await _appEvents.logEvent(
            name: 'app_install',
            parameters: AnalyticsParameterSanitizer.forMeta(parameters),
          );
        case AnalyticsEvents.appOpen:
          await _appEvents.activateApp();
        case AnalyticsEvents.completeRegistration:
          await _appEvents.logCompletedRegistration(
            registrationMethod:
                AnalyticsParameterSanitizer.stringValue(parameters, 'method') ??
                'unknown',
          );
        case AnalyticsEvents.login:
          await _appEvents.logEvent(
            name: 'login',
            parameters: AnalyticsParameterSanitizer.forMeta(parameters),
          );
        case AnalyticsEvents.viewContent:
          await _appEvents.logViewContent(
            id:
                AnalyticsParameterSanitizer.stringValue(
                  parameters,
                  'content_id',
                ) ??
                'unknown',
            type:
                AnalyticsParameterSanitizer.stringValue(
                  parameters,
                  'content_type',
                ) ??
                'content',
            currency: _currency(parameters),
            price: AnalyticsParameterSanitizer.doubleValue(parameters, 'value'),
            content: AnalyticsParameterSanitizer.forMeta(parameters),
          );
        case AnalyticsEvents.search:
          await _appEvents.logEvent(
            name: 'fb_mobile_search',
            parameters: <String, dynamic>{
              'fb_search_string':
                  AnalyticsParameterSanitizer.stringValue(
                    parameters,
                    'search_term',
                  ) ??
                  'unknown',
              ...AnalyticsParameterSanitizer.forMeta(parameters),
            },
          );
        case AnalyticsEvents.addToCart:
          await _appEvents.logAddToCart(
            id:
                AnalyticsParameterSanitizer.stringValue(parameters, 'item_id') ??
                AnalyticsParameterSanitizer.stringValue(
                  parameters,
                  'content_id',
                ) ??
                'unknown',
            type:
                AnalyticsParameterSanitizer.stringValue(
                  parameters,
                  'content_type',
                ) ??
                'consultation',
            currency: _currency(parameters),
            price:
                AnalyticsParameterSanitizer.doubleValue(parameters, 'value') ??
                0,
          );
        case AnalyticsEvents.initiateCheckout:
          await _appEvents.logInitiatedCheckout(
            totalPrice:
                AnalyticsParameterSanitizer.doubleValue(parameters, 'value') ??
                0,
            currency: _currency(parameters),
            contentType:
                AnalyticsParameterSanitizer.stringValue(
                  parameters,
                  'content_type',
                ) ??
                'consultation',
            contentId: AnalyticsParameterSanitizer.stringValue(
              parameters,
              'checkout_id',
            ),
            numItems:
                AnalyticsParameterSanitizer.intValue(parameters, 'quantity') ??
                AnalyticsParameterSanitizer.intValue(parameters, 'item_count'),
            paymentInfoAvailable:
                AnalyticsParameterSanitizer.boolValue(
                  parameters,
                  'payment_info_available',
                ) ??
                true,
          );
        case AnalyticsEvents.addPaymentInfo:
          await _appEvents.logEvent(
            name: 'fb_mobile_add_payment_info',
            parameters: AnalyticsParameterSanitizer.forMeta(parameters),
          );
        case AnalyticsEvents.purchase:
          await _appEvents.logPurchase(
            amount:
                AnalyticsParameterSanitizer.doubleValue(parameters, 'value') ??
                0,
            currency: _currency(parameters),
            parameters: <String, dynamic>{
              FacebookAppEvents.paramNameOrderId:
                  AnalyticsParameterSanitizer.stringValue(
                    parameters,
                    'transaction_id',
                  ) ??
                  AnalyticsParameterSanitizer.stringValue(
                    parameters,
                    'order_id',
                  ),
              if (AnalyticsParameterSanitizer.stringValue(
                    parameters,
                    'item_id',
                  ) !=
                  null)
                FacebookAppEvents.paramNameContentId:
                    AnalyticsParameterSanitizer.stringValue(
                      parameters,
                      'item_id',
                    ),
              ...AnalyticsParameterSanitizer.forMeta(parameters),
            },
          );
        default:
          await _appEvents.logEvent(
            name: normalized,
            parameters: AnalyticsParameterSanitizer.forMeta(parameters),
          );
      }
    } catch (error, stack) {
      _logDebugError(normalized, error, stack);
    }
  }

  String _currency(Map<String, dynamic>? parameters) {
    return AnalyticsCurrencyCodec.normalizeIso4217(
      AnalyticsParameterSanitizer.stringValue(parameters, 'currency') ?? 'USD',
    );
  }

  void _logDebugError(String eventName, Object error, StackTrace stack) {
    if (kReleaseMode) return;
    debugPrint('[analytics][meta] event=$eventName error=$error');
    debugPrintStack(stackTrace: stack, label: '[analytics][meta]');
  }
}
