import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/services/secure_storage_service.dart';
import 'package:kopa/utils/analytics_events.dart';
import 'package:kopa/utils/crash_reporting.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Product analytics, backed by PostHog (EU cloud).
///
/// * Users are identified by their numeric Kopa id only; no name or email is
///   sent.
/// * Every user is attached to a `team` group, so funnels and retention can be
///   analysed per team as well as per person.
/// * Collection is on by default; users can opt out from profile settings
///   ([setEnabled]). The choice is stored on the device.
/// * Disabled in debug builds unless `POSTHOG_DEBUG_CAPTURE=true` is set in the
///   env file, so development never pollutes production data.
///
/// Configuration (`.env.*`):
/// * `POSTHOG_PROJECT_TOKEN` - required; analytics is off without it.
/// * `POSTHOG_HOST` - defaults to `https://eu.i.posthog.com`.
/// * `POSTHOG_SESSION_REPLAY` - `true` to record sessions (text and images are
///   masked).
abstract final class AppAnalytics {
  static const _defaultHost = 'https://eu.i.posthog.com';
  static const teamGroupType = 'team';

  static bool _initialized = false;
  static final _posthog = Posthog();

  /// Whether the SDK is set up. Capture calls are no-ops otherwise.
  static bool get isSupported => _initialized;

  static bool get _isPlatformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Route observers for the root navigator. Records screen views (named after
  /// the go_router path pattern, e.g. `/match/:id`) and lets surveys show.
  static List<NavigatorObserver> get routeObservers {
    if (!isSupported) {
      return const [];
    }
    return [PosthogObserver()];
  }

  /// Wraps the app so session replay can capture it (when enabled).
  static Widget wrapApp(Widget app) {
    if (!isSupported) {
      return app;
    }
    return PostHogWidget(child: app);
  }

  static Future<void> initialize() async {
    if (!_isPlatformSupported) {
      return;
    }

    final token = dotenv.maybeGet('POSTHOG_PROJECT_TOKEN')?.trim() ?? '';
    if (token.isEmpty) {
      debugPrint('Analytics disabled: POSTHOG_PROJECT_TOKEN is not set.');
      return;
    }
    if (kDebugMode && !_envFlag('POSTHOG_DEBUG_CAPTURE')) {
      return;
    }

    final enabled = await isEnabled();
    final config = PostHogConfig(token)
      ..host = dotenv.maybeGet('POSTHOG_HOST')?.trim() ?? _defaultHost
      ..debug = kDebugMode
      ..optOut = !enabled
      ..personProfiles = PostHogPersonProfiles.identifiedOnly
      ..captureApplicationLifecycleEvents = true
      // Push is delivered by our own backend through FCM; don't register
      // device tokens with PostHog.
      ..capturePushNotificationSubscriptions = false
      ..capturePushNotificationOpened = false
      ..sessionReplay = _envFlag('POSTHOG_SESSION_REPLAY');
    config.sessionReplayConfig
      ..maskAllTexts = true
      ..maskAllImages = true;

    await _posthog.setup(config);
    _initialized = true;
  }

  /// Whether the user allows analytics on this device. Defaults to `true`.
  static Future<bool> isEnabled() async {
    try {
      return await SecureStorageService.isAnalyticsEnabled();
    } catch (_) {
      return true;
    }
  }

  /// Stores the user's analytics choice and applies it immediately.
  static Future<void> setEnabled(bool enabled) async {
    await SecureStorageService.setAnalyticsEnabled(enabled);
    await _guard(() => enabled ? _posthog.optIn() : _posthog.optOut());
  }

  /// Identifies the signed-in user and their team, or resets on sign-out.
  static Future<void> setCurrentUser(UserDetails? user) async {
    await CrashReporting.setUserIdentifier(user?.id);

    if (!isSupported) {
      return;
    }

    if (user == null) {
      // Only forget an identified user (logout or expired session). Resetting
      // an anonymous device would mint a new anonymous id on every logged-out
      // cold start and split install/open events from the rest of the visit.
      await _guard(() async {
        if (_isIdentifiedDistinctId(await _posthog.getDistinctId())) {
          await _posthog.reset();
        }
      });
      return;
    }

    final team = user.teamDetails;
    await _guard(() async {
      await _posthog.identify(
        userId: user.id.toString(),
        userProperties: {
          'role_id': user.roleId,
          'is_team_owner': user.isTeamOwner,
          'is_fine_admin': user.isFineAdmin,
          'has_team': team != null,
        },
        userPropertiesSetOnce: {
          'signed_up_at': user.createdAt.toUtc().toIso8601String(),
        },
      );

      if (team != null) {
        await _posthog.group(
          groupType: teamGroupType,
          groupKey: team.id.toString(),
          groupProperties: {
            'name': team.title,
            'rsvp_selection_mode': team.rsvpSelectionMode,
            'player_count': team.playerCount,
            'created_at': team.createdAt.toUtc().toIso8601String(),
          },
        );
      }
    });
  }

  static Future<void> logScreenView(String screenName) {
    return _guard(() => _posthog.screen(screenName: screenName));
  }

  /// Captures [name], which must be listed in [AnalyticsEvents].
  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) {
    assert(
      AnalyticsEvents.all.contains(name),
      'Unknown analytics event "$name". Add it to AnalyticsEvents first.',
    );
    return _guard(() {
      return _posthog.capture(eventName: name, properties: parameters);
    });
  }

  /// Properties identifying the team an event concerns, for events that
  /// happen before the user's own team group is set (onboarding).
  static Map<String, Object> teamContextParameters({int? teamId}) {
    return {
      if (teamId != null) 'team_id': teamId.toString(),
    };
  }

  static Future<void> logLogin({required bool success}) {
    return logEvent(success ? 'login_success' : 'login_failure');
  }

  static Future<void> logRegister({required bool success}) {
    return logEvent(success ? 'register_success' : 'register_failure');
  }

  /// Identified users use their numeric Kopa id as distinct id; anonymous
  /// devices use a PostHog-generated UUID.
  static bool _isIdentifiedDistinctId(String distinctId) {
    return int.tryParse(distinctId) != null;
  }

  static bool _envFlag(String key) {
    return dotenv.maybeGet(key)?.trim().toLowerCase() == 'true';
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
