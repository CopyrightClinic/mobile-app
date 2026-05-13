import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tiktok_events_sdk/tiktok_events_sdk.dart';

import '../../domain/analytics_event.dart';
import '../../domain/analytics_event_type.dart';
import '../../domain/view_content_subject.dart';
import 'analytics_currency_codec.dart';
import 'tiktok_dispatch_payload.dart';

typedef MetaEmitter = FacebookAppEvents;

final class MappedAnalyticsWork {
  final Future<void> Function(FirebaseAnalytics firebase)? firebase;
  final Future<void> Function(MetaEmitter meta)? meta;
  final Future<void> Function()? tiktok;

  const MappedAnalyticsWork({this.firebase, this.meta, this.tiktok});
}

final class AnalyticsDispatchMapper {
  const AnalyticsDispatchMapper._();

  static String _contentTypeForSubject(ViewContentSubject subject) {
    return switch (subject) {
      ViewContentSubject.attorneyProfile => 'attorney_profile',
      ViewContentSubject.sessionDetails => 'session_details',
      ViewContentSubject.haroldLegalQuery => 'harold_legal_query',
      ViewContentSubject.userAccountProfile => 'user_account_profile',
    };
  }

  static MappedAnalyticsWork map(AnalyticsEvent event) {
    return switch (event) {
      AppInstallAnalyticsEvent _ => MappedAnalyticsWork(
        firebase: (fa) async {
          await fa.logEvent(
            name: 'app_install',
            parameters: <String, Object>{'channel': 'first_party'},
          );
        },
        meta: (meta) async {
          await meta.logEvent(
            name: 'app_install',
            parameters: <String, dynamic>{},
          );
        },
        tiktok: () async {
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(
              eventName: BaseEventName.installApp.value,
              eventType: TTEventType.none,
            ),
          );
        },
      ),
      AppOpenAnalyticsEvent _ => MappedAnalyticsWork(
        firebase: (fa) async {
          await fa.logAppOpen();
        },
        meta: (meta) async {
          await meta.activateApp();
        },
        tiktok: () async {
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(
              eventName: BaseEventName.launchApp.value,
              eventType: TTEventType.none,
            ),
          );
        },
      ),
      CompleteRegistrationAnalyticsEvent e => MappedAnalyticsWork(
        firebase: (fa) async {
          await fa.logSignUp(signUpMethod: e.payload.method.name);
        },
        meta: (meta) async {
          await meta.logEvent(
            name: FacebookAppEvents.eventNameCompletedRegistration,
            parameters: <String, dynamic>{
              FacebookAppEvents.paramNameRegistrationMethod:
                  e.payload.method.name,
              if (e.payload.userId != null) 'user_id': e.payload.userId,
            },
          );
        },
        tiktok: () async {
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(
              eventName: BaseEventName.registration.value,
              eventType: TTEventType.none,
              properties: EventProperties(
                customProperties: <String, dynamic>{
                  'method': e.payload.method.name,
                  if (e.payload.userId != null)
                    'external_id': TikTokDispatchPayload.clip(e.payload.userId!),
                },
              ),
            ),
          );
        },
      ),
      ViewContentAnalyticsEvent e => MappedAnalyticsWork(
        firebase: (fa) async {
          final ct = _contentTypeForSubject(e.payload.subject);
          await fa.logViewItem(
            items: <AnalyticsEventItem>[
              AnalyticsEventItem(
                itemId: e.payload.contentId,
                itemName: e.payload.contentName,
                itemCategory: e.payload.contentCategory ?? ct,
              ),
            ],
            parameters: <String, Object>{
              for (final MapEntry(:key, :value) in e.payload.attributes.entries)
                key: value,
            },
          );
        },
        meta: (meta) async {
          final ct = _contentTypeForSubject(e.payload.subject);
          await meta.logEvent(
            name: FacebookAppEvents.eventNameViewedContent,
            parameters: <String, dynamic>{
              FacebookAppEvents.paramNameContentType: ct,
              FacebookAppEvents.paramNameContentId: e.payload.contentId,
              if (e.payload.contentName != null)
                'content_name': e.payload.contentName,
              for (final MapEntry(:key, :value) in e.payload.attributes.entries)
                key: value,
            },
          );
        },
        tiktok: () async {
          final ct = _contentTypeForSubject(e.payload.subject);
          final currency = AnalyticsCurrencyCodec.toTikTokCurrency('USD');
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(
              eventName: 'ViewContent',
              eventType: TTEventType.viewContent,
              properties: EventProperties(
                contentType: ct,
                contentId: TikTokDispatchPayload.clip(e.payload.contentId),
                contentName: TikTokDispatchPayload.clipNullable(
                  e.payload.contentName,
                ),
                currency: currency,
                customProperties: TikTokDispatchPayload.stringAttributes(
                  e.payload.attributes,
                ),
              ),
            ),
          );
        },
      ),
      SearchAnalyticsEvent e => MappedAnalyticsWork(
        firebase: (fa) async {
          await fa.logSearch(
            searchTerm: e.payload.searchTerm,
            parameters: <String, Object>{
              'search_context': e.payload.context.name,
              if (e.payload.resultCount != null)
                'result_count': e.payload.resultCount!,
            },
          );
        },
        meta: (meta) async {
          await meta.logEvent(
            name: 'fb_mobile_search',
            parameters: <String, dynamic>{
              'fb_search_string': e.payload.searchTerm,
              'search_context': e.payload.context.name,
              if (e.payload.resultCount != null)
                'result_count': e.payload.resultCount,
            },
          );
        },
        tiktok: () async {
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(
              eventName: BaseEventName.search.value,
              eventType: TTEventType.none,
              properties: EventProperties(
                description: TikTokDispatchPayload.clip(e.payload.searchTerm),
                customProperties: <String, dynamic>{
                  'search_context': e.payload.context.name,
                  if (e.payload.resultCount != null)
                    'result_count': e.payload.resultCount!,
                },
              ),
            ),
          );
        },
      ),
      InitiateCheckoutAnalyticsEvent e => MappedAnalyticsWork(
        firebase: (fa) async {
          await fa.logBeginCheckout(
            value: e.payload.value,
            currency: AnalyticsCurrencyCodec.normalizeIso4217(
              e.payload.currencyCode,
            ),
            items: <AnalyticsEventItem>[
              AnalyticsEventItem(
                itemId: e.payload.primaryItemId ?? e.payload.checkoutId,
                itemName: e.payload.primaryItemName ?? 'consultation_checkout',
                quantity: e.payload.itemCount,
                price: e.payload.value,
              ),
            ],
          );
        },
        meta: (meta) async {
          await meta.logInitiatedCheckout(
            totalPrice: e.payload.value,
            currency: AnalyticsCurrencyCodec.normalizeIso4217(
              e.payload.currencyCode,
            ),
            contentType: 'consultation',
            contentId: e.payload.checkoutId,
            numItems: e.payload.itemCount,
            paymentInfoAvailable: true,
          );
        },
        tiktok: () async {
          final currency = AnalyticsCurrencyCodec.toTikTokCurrency(
            e.payload.currencyCode,
          );
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(
              eventName: 'Checkout',
              eventType: TTEventType.checkout,
              properties: EventProperties(
                value: TikTokDispatchPayload.finiteValue(e.payload.value),
                currency: currency,
                quantity: e.payload.itemCount,
                contentId: TikTokDispatchPayload.clip(e.payload.checkoutId),
                contentType: 'consultation',
                contentName: TikTokDispatchPayload.clipNullable(
                  e.payload.primaryItemName,
                ),
              ),
            ),
          );
        },
      ),
      PurchaseAnalyticsEvent e => MappedAnalyticsWork(
        firebase: (fa) async {
          await fa.logPurchase(
            currency: AnalyticsCurrencyCodec.normalizeIso4217(
              e.payload.currencyCode,
            ),
            value: e.payload.value,
            transactionId: e.payload.transactionId,
            affiliation: e.payload.affiliation,
            items: <AnalyticsEventItem>[
              AnalyticsEventItem(
                itemId: e.payload.itemId ?? e.payload.transactionId,
                itemName: e.payload.itemName ?? 'paid_consultation',
                quantity: e.payload.quantity,
                price: e.payload.value,
              ),
            ],
          );
        },
        meta: (meta) async {
          await meta.logPurchase(
            amount: e.payload.value,
            currency: AnalyticsCurrencyCodec.normalizeIso4217(
              e.payload.currencyCode,
            ),
            parameters: <String, dynamic>{
              FacebookAppEvents.paramNameOrderId: e.payload.transactionId,
              if (e.payload.itemId != null)
                FacebookAppEvents.paramNameContentId: e.payload.itemId,
              if (e.payload.itemName != null)
                'content_name': e.payload.itemName,
            },
          );
        },
        tiktok: () async {
          final currency = AnalyticsCurrencyCodec.toTikTokCurrency(
            e.payload.currencyCode,
          );
          final tid = TikTokDispatchPayload.clip(e.payload.transactionId);
          await TikTokEventsSdk.logEvent(
            event: TikTokEvent(
              eventName: 'Purchase',
              eventType: TTEventType.purchase,
              eventId: tid,
              properties: EventProperties(
                value: TikTokDispatchPayload.finiteValue(e.payload.value),
                currency: currency,
                quantity: e.payload.quantity,
                contentId: TikTokDispatchPayload.clip(
                  e.payload.itemId ?? e.payload.transactionId,
                ),
                contentType: 'consultation',
                contentName: TikTokDispatchPayload.clipNullable(
                  e.payload.itemName,
                ),
              ),
            ),
          );
        },
      ),
    };
  }

  static AnalyticsEventType typeOf(AnalyticsEvent event) => event.type;
}
