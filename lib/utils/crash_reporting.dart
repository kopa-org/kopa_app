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
      // Still set up error handlers on web, just without Crashlytics
      FlutterError.onError = (details) {
        logWebError(details.exception, details.stack);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        logWebError(error, stack);
        return true;
      };
      return;
    }

    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kIsWeb) {
        logWebError(error, stack);
      }
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<void> runAppGuarded(Future<void> Function() body) {
    if (kIsWeb) {
      return runZonedGuarded<Future<void>>(body, (error, stack) {
        logWebError(error, stack);
      }) ??
          Future<void>.value();
    }

    if (!isCrashlyticsSupported) {
      return body();
    }

    return runZonedGuarded<Future<void>>(body, (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }) ??
        Future<void>.value();
  }

  static void logWebError(Object error, StackTrace? stack) {
    // Use print directly for release mode visibility in browser console
    // ignore: avoid_print
    print('*** KOPA WEB ERROR ***');
    // ignore: avoid_print
    print('Error: $error');
    if (stack != null) {
      // ignore: avoid_print
      print('Stack Trace:\n$stack');
    }
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
