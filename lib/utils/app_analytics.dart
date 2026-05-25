import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/utils/crash_reporting.dart';

abstract final class AppAnalytics {
  static bool _initialized = false;

  static FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  static List<NavigatorObserver> get routeObservers {
    if (!isSupported) {
      return const [];
    }

    return [FirebaseAnalyticsObserver(analytics: _analytics)];
  }

  static bool get isSupported =>
      _initialized && CrashReporting.isFirebaseSupported;

  static Future<void> initialize() async {
    if (!CrashReporting.isFirebaseSupported) {
      return;
    }

    await _analytics.setAnalyticsCollectionEnabled(true);
    _initialized = true;
  }

  static Future<void> setCurrentUser(UserDetails? user) async {
    if (!isSupported) {
      return;
    }

    if (user == null) {
      await _guard(() async {
        await _analytics.setUserId(id: null);
        await _analytics.setUserProperty(name: 'team_id', value: null);
        await _analytics.setUserProperty(name: 'role_id', value: null);
        await _analytics.setUserProperty(name: 'is_team_owner', value: null);
        await _analytics.setUserProperty(name: 'has_team', value: null);
      });
      return;
    }

    await _guard(() async {
      await _analytics.setUserId(id: user.id.toString());
      await _analytics.setUserProperty(
        name: 'team_id',
        value: user.teamDetails?.id.toString(),
      );
      await _analytics.setUserProperty(
        name: 'role_id',
        value: user.roleId.toString(),
      );
      await _analytics.setUserProperty(
        name: 'is_team_owner',
        value: user.isTeamOwner.toString(),
      );
      await _analytics.setUserProperty(
        name: 'has_team',
        value: (user.teamDetails != null).toString(),
      );
    });
  }

  static Future<void> logScreenView(String screenName) {
    return _guard(() {
      return _analytics.logScreenView(screenName: screenName);
    });
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) {
    return _guard(() {
      return _analytics.logEvent(name: name, parameters: parameters);
    });
  }

  static Future<void> logLogin({required bool success}) {
    return logEvent(success ? 'login_success' : 'login_failure');
  }

  static Future<void> logRegister({required bool success}) {
    return logEvent(success ? 'register_success' : 'register_failure');
  }

  static Future<void> _guard(Future<void> Function() action) async {
    if (!isSupported) {
      return;
    }

    try {
      await action();
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('Analytics error: $error');
        debugPrintStack(stackTrace: stack);
      }
    }
  }
}
