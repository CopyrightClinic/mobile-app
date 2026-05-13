import 'package:flutter/foundation.dart';

import '../domain/analytics_event.dart';
import '../infrastructure/mapping/analytics_dispatch_mapper.dart';
import '../infrastructure/providers/analytics_provider.dart';
import 'analytics_debug_sink.dart';
import 'analytics_install_gate.dart';

final class AnalyticsManager {
  AnalyticsManager({
    required List<AnalyticsProvider> providers,
    required AnalyticsDebugSink debugSink,
    required AnalyticsInstallGate installGate,
  }) : _providers = List<AnalyticsProvider>.unmodifiable(providers),
       _debugSink = debugSink,
       _installGate = installGate;

  final List<AnalyticsProvider> _providers;
  final AnalyticsDebugSink _debugSink;
  final AnalyticsInstallGate _installGate;
  bool _installBootstrapScheduled = false;

  Future<void> bootstrapLifecycleSignals() async {
    if (_installBootstrapScheduled) {
      if (!kReleaseMode) {
        debugPrint(
          '[analytics] bootstrap_lifecycle skipped (already_scheduled)',
        );
      }
      return;
    }
    _installBootstrapScheduled = true;
    final shouldEmitInstall = await _installGate.consumeFirstInstallSlot();
    if (!kReleaseMode) {
      debugPrint(
        '[analytics] bootstrap_lifecycle first_install_event=$shouldEmitInstall',
      );
    }
    if (shouldEmitInstall) {
      await track(const AppInstallAnalyticsEvent());
    }
    await track(const AppOpenAnalyticsEvent(fromBackground: false));
  }

  Future<void> track(AnalyticsEvent event) async {
    if (!kReleaseMode) {
      debugPrint('[analytics] track_begin type=${event.type.name}');
    }
    final mapped = AnalyticsDispatchMapper.map(event);
    Object? firstError;
    StackTrace? firstStack;
    var providerDispatchOkCount = 0;
    for (final provider in _providers) {
      if (!provider.isEnabled) {
        if (!kReleaseMode) {
          debugPrint(
            '[analytics] track_skip type=${event.type.name} provider=${provider.id} reason=disabled',
          );
        }
        continue;
      }
      if (!provider.hasMappedWork(mapped)) {
        if (!kReleaseMode) {
          debugPrint(
            '[analytics] track_skip type=${event.type.name} provider=${provider.id} reason=no_mapping',
          );
        }
        continue;
      }
      try {
        await provider.dispatch(mapped);
        providerDispatchOkCount++;
        if (!kReleaseMode) {
          debugPrint(
            '[analytics] track_ok type=${event.type.name} provider=${provider.id}',
          );
        }
      } catch (error, stack) {
        firstError ??= error;
        firstStack ??= stack;
        if (!kReleaseMode) {
          debugPrint(
            '[analytics] track_error type=${event.type.name} provider=${provider.id} error=$error',
          );
          debugPrintStack(
            stackTrace: stack,
            label: '[analytics] track_error stack',
          );
        }
      }
    }
    if (!kReleaseMode) {
      if (firstError == null) {
        debugPrint('[analytics] track_complete type=${event.type.name} ok');
      } else {
        debugPrint(
          '[analytics] track_complete type=${event.type.name} had_provider_errors',
        );
      }
      if (providerDispatchOkCount == 0) {
        debugPrint(
          '[analytics] track_note type=${event.type.name} no_provider_invoked (all disabled or no_mapping for this event)',
        );
      }
    }
    _debugSink.onDispatch(event, firstError, firstStack);
  }
}
