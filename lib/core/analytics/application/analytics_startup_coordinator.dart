import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../../di.dart';
import 'analytics_initializer.dart';

final class AnalyticsStartupCoordinator with WidgetsBindingObserver {
  AnalyticsStartupCoordinator();

  static const _fallbackDelay = Duration(seconds: 5);
  static const _minElapsedBeforeAtt = Duration(milliseconds: 600);

  var _started = false;
  var _completed = false;
  var _inProgress = false;
  var _sawInactiveForSystemDialog = false;
  Timer? _fallbackTimer;
  final DateTime _appStartTime = DateTime.now();

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    if (!Platform.isIOS) {
      unawaited(_runInitialize());
      return;
    }
    _fallbackTimer = Timer(_fallbackDelay, () {
      unawaited(_runInitialize());
    });
  }

  void stop() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Platform.isIOS || _completed || _inProgress) {
      return;
    }
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _sawInactiveForSystemDialog = true;
      case AppLifecycleState.resumed:
        if (_sawInactiveForSystemDialog && DateTime.now().difference(_appStartTime) >= _minElapsedBeforeAtt) {
          unawaited(_runInitialize());
        }
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _runInitialize() async {
    if (_completed || _inProgress) {
      return;
    }
    _inProgress = true;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    try {
      if (Platform.isIOS) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      await sl<AnalyticsInitializer>().initialize();
      _completed = true;
    } finally {
      _inProgress = false;
    }
  }
}
