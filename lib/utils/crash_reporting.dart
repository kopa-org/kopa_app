import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

abstract final class CrashReporting {
  static bool get isFirebaseSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isCrashlyticsSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

  static Future<void> initialize() async {
    if (!isFirebaseSupported) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!isCrashlyticsSupported) {
      return;
    }

    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kIsWeb) {
        // Log to console on web since Crashlytics is not supported
        debugPrint('Kopa Error: $error');
        debugPrint('Stack trace: $stack');
      }
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<void> runAppGuarded(Future<void> Function() body) {
    if (!isCrashlyticsSupported) {
      return body();
    }

    return runZonedGuarded<Future<void>>(body, (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }) ?? Future<void>.value();
  }

  static Future<void> recordTestException() async {
    if (!isCrashlyticsSupported) {
      return;
    }

    await FirebaseCrashlytics.instance.recordError(
      StateError('Manual Crashlytics smoke test'),
      StackTrace.current,
      reason: 'Triggered from the dashboard test panel.',
    );
  }

  static void triggerTestCrash() {
    if (!isCrashlyticsSupported) {
      return;
    }

    FirebaseCrashlytics.instance.crash();
  }
}