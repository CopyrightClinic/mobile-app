import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../../domain/analytics_events.dart';
import '../mapping/analytics_currency_codec.dart';
import '../sanitization/analytics_parameter_sanitizer.dart';
import 'analytics_platform_service.dart';

final class FirebaseAnalyticsService implements AnalyticsPlatformService {
  FirebaseAnalyticsService({
    required FirebaseAnalytics analytics,
    required bool enabled,
  }) : _analytics = analytics,
       _enabled = enabled;

  final FirebaseAnalytics _analytics;
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
          await _analytics.logEvent(
            name: 'app_install',
            parameters: <String, Object>{
              'channel': 'first_party',
              ...AnalyticsParameterSanitizer.forFirebase(parameters),
            },
          );
        case AnalyticsEvents.appOpen:
          await _analytics.logAppOpen(
            parameters: AnalyticsParameterSanitizer.forFirebase(parameters),
          );
        case AnalyticsEvents.completeRegistration:
          await _analytics.logSignUp(
            signUpMethod:
                AnalyticsParameterSanitizer.stringValue(parameters, 'method') ??
                'unknown',
          );
        case AnalyticsEvents.login:
          await _analytics.logLogin(
            loginMethod:
                AnalyticsParameterSanitizer.stringValue(parameters, 'method') ??
                'unknown',
          );
        case AnalyticsEvents.viewContent:
          await _logViewContent(parameters);
        case AnalyticsEvents.search:
          await _analytics.logSearch(
            searchTerm:
                AnalyticsParameterSanitizer.stringValue(
                  parameters,
                  'search_term',
                ) ??
                'unknown',
            parameters: AnalyticsParameterSanitizer.forFirebase(parameters),
          );
        case AnalyticsEvents.selectSessionSlot:
          await _analytics.logEvent(
            name: 'select_item',
            parameters: <String, Object>{
              'item_list_name': 'session_slots',
              ...AnalyticsParameterSanitizer.forFirebase(parameters),
            },
          );
        case AnalyticsEvents.addToCart:
          await _logAddToCart(parameters);
        case AnalyticsEvents.initiateCheckout:
          await _logBeginCheckout(parameters);
        case AnalyticsEvents.addPaymentInfo:
          await _analytics.logAddPaymentInfo(
            paymentType:
                AnalyticsParameterSanitizer.stringValue(
                  parameters,
                  'payment_type',
                ) ??
                'unknown',
            parameters: AnalyticsParameterSanitizer.forFirebase(parameters),
          );
        case AnalyticsEvents.purchase:
          await _logPurchase(parameters);
        default:
          await _analytics.logEvent(
            name: normalized,
            parameters: AnalyticsParameterSanitizer.forFirebase(parameters),
          );
      }
    } catch (error, stack) {
      _logDebugError(normalized, error, stack);
    }
  }

  Future<void> _logViewContent(Map<String, dynamic>? parameters) async {
    final contentId =
        AnalyticsParameterSanitizer.stringValue(parameters, 'content_id') ??
        'unknown';
    final contentType =
        AnalyticsParameterSanitizer.stringValue(parameters, 'content_type') ??
        'content';
    final item = AnalyticsEventItem(
      itemId: contentId,
      itemName: AnalyticsParameterSanitizer.stringValue(
        parameters,
        'content_name',
      ),
      itemCategory:
          AnalyticsParameterSanitizer.stringValue(
            parameters,
            'content_category',
          ) ??
          contentType,
    );
    await _analytics.logViewItem(
      currency:
          AnalyticsParameterSanitizer.stringValue(parameters, 'currency') ??
          'USD',
      value: AnalyticsParameterSanitizer.doubleValue(parameters, 'value') ?? 0,
      items: [item],
      parameters: AnalyticsParameterSanitizer.forFirebase(parameters),
    );
  }

  Future<void> _logAddToCart(Map<String, dynamic>? parameters) async {
    final item = _commerceItem(parameters);
    await _analytics.logAddToCart(
      currency: _currency(parameters),
      value: AnalyticsParameterSanitizer.doubleValue(parameters, 'value') ?? 0,
      items: [item],
      parameters: AnalyticsParameterSanitizer.forFirebase(parameters),
    );
  }

  Future<void> _logBeginCheckout(Map<String, dynamic>? parameters) async {
    final item = _commerceItem(parameters);
    await _analytics.logBeginCheckout(
      currency: _currency(parameters),
      value: AnalyticsParameterSanitizer.doubleValue(parameters, 'value') ?? 0,
      items: [item],
      parameters: AnalyticsParameterSanitizer.forFirebase(parameters),
    );
  }

  Future<void> _logPurchase(Map<String, dynamic>? parameters) async {
    final transactionId =
        AnalyticsParameterSanitizer.stringValue(parameters, 'transaction_id') ??
        AnalyticsParameterSanitizer.stringValue(parameters, 'order_id') ??
        'unknown';
    final value = AnalyticsParameterSanitizer.doubleValue(parameters, 'value');
    final item = _commerceItem(parameters);
    await _analytics.logPurchase(
      currency: _currency(parameters),
      value: value,
      transactionId: transactionId,
      affiliation: AnalyticsParameterSanitizer.stringValue(
        parameters,
        'affiliation',
      ),
      items: [item],
      parameters: AnalyticsParameterSanitizer.forFirebase(parameters),
    );
  }

  AnalyticsEventItem _commerceItem(Map<String, dynamic>? parameters) {
    return AnalyticsEventItem(
      itemId:
          AnalyticsParameterSanitizer.stringValue(parameters, 'item_id') ??
          AnalyticsParameterSanitizer.stringValue(parameters, 'content_id') ??
          'unknown',
      itemName:
          AnalyticsParameterSanitizer.stringValue(parameters, 'item_name') ??
          AnalyticsParameterSanitizer.stringValue(parameters, 'content_name') ??
          'consultation',
      quantity: AnalyticsParameterSanitizer.intValue(parameters, 'quantity'),
      price: AnalyticsParameterSanitizer.doubleValue(parameters, 'value'),
    );
  }

  String _currency(Map<String, dynamic>? parameters) {
    return AnalyticsCurrencyCodec.normalizeIso4217(
      AnalyticsParameterSanitizer.stringValue(parameters, 'currency') ?? 'USD',
    );
  }

  void _logDebugError(String eventName, Object error, StackTrace stack) {
    if (kReleaseMode) return;
    debugPrint('[analytics][firebase] event=$eventName error=$error');
    debugPrintStack(stackTrace: stack, label: '[analytics][firebase]');
  }
}
