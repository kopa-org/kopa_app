import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/navigation/router_refresh_notifier.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/repository/feature_flags_repository.dart';
import 'package:kopa/utils/crash_reporting.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kopa/repository/onboarding_repository.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_theme.dart';
import 'package:kopa/services/push_notifications_service.dart';
import 'package:kopa/state/match_programme_refresh_notifier.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

const _envFileFromDefine = String.fromEnvironment('ENV_FILE');
const _minimumSplashDuration = Duration(seconds: 2);
const _splashBackgroundColor = Color(0xFFE8F2ED);
const _splashAnimationCacheWidth = 690;
const _splashAnimationCacheHeight = 428;

void main() async {
  await CrashReporting.runAppGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final initialLocation = AppRouter.initialLocationFromPlatformRoute(
      WidgetsBinding.instance.platformDispatcher.defaultRouteName,
    );
    runApp(KopaBootstrapApp(initialLocation: initialLocation));
  });
}

class KopaBootstrapApp extends StatefulWidget {
  const KopaBootstrapApp({super.key, this.initialLocation});

  final String? initialLocation;

  @override
  State<KopaBootstrapApp> createState() => _KopaBootstrapAppState();
}

class _KopaBootstrapAppState extends State<KopaBootstrapApp> {
  late final Future<_BootstrapResult> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrapWithMinimumSplash();
  }

  Future<_BootstrapResult> _bootstrapWithMinimumSplash() async {
    final minimumSplash = Future<void>.delayed(_minimumSplashDuration);

    try {
      final result = await _bootstrap();
      await minimumSplash;
      return result;
    } catch (_) {
      await minimumSplash;
      rethrow;
    }
  }

  Future<_BootstrapResult> _bootstrap() async {
    final envFile = _envFileFromDefine.isNotEmpty
        ? _envFileFromDefine
        : (kReleaseMode ? '.env.deploy' : '.env.local');
    await dotenv.load(fileName: envFile);
    await CrashReporting.initialize();
    await AppAnalytics.initialize();
    await PushNotificationsService.instance.initialize();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await LiquidGlassWidgets.initialize();
    }

    final authRepository = ApiAuthRepository();
    final featureFlagsRepository = FeatureFlagsRepository();
    final onboardingRepository = OnboardingRepository();

    final featureFlags = await featureFlagsRepository.getFeatureFlags();
    final authCubit = AuthCubit(authRepository: authRepository);
    final onboardingCubit = OnboardingCubit(onboardingRepository);

    // Initialize auth state
    await authCubit.init();
    final user = authCubit.state.user;
    if (user != null && user.teamDetails == null) {
      await onboardingCubit.restorePendingJoinRequest();
    }

    return _BootstrapResult(
      authRepository: authRepository,
      onboardingRepository: onboardingRepository,
      featureFlags: featureFlags,
      authCubit: authCubit,
      onboardingCubit: onboardingCubit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapResult>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final result = snapshot.requireData;
          final app = KopaApp(
            authRepository: result.authRepository,
            onboardingRepository: result.onboardingRepository,
            featureFlags: result.featureFlags,
            authCubit: result.authCubit,
            onboardingCubit: result.onboardingCubit,
            initialLocation: widget.initialLocation,
          );

          return defaultTargetPlatform == TargetPlatform.iOS
              ? LiquidGlassWidgets.wrap(child: app)
              : app;
        }

        if (snapshot.hasError) {
          return _SplashErrorApp(error: snapshot.error);
        }

        return const _AnimatedSplashApp();
      },
    );
  }
}

class _BootstrapResult {
  const _BootstrapResult({
    required this.authRepository,
    required this.onboardingRepository,
    required this.featureFlags,
    required this.authCubit,
    required this.onboardingCubit,
  });

  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final AppFeatureFlags featureFlags;
  final AuthCubit authCubit;
  final OnboardingCubit onboardingCubit;
}

class KopaApp extends StatefulWidget {
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final AppFeatureFlags featureFlags;
  final AuthCubit authCubit;
  final OnboardingCubit onboardingCubit;
  final String? initialLocation;

  const KopaApp({
    super.key,
    required this.authRepository,
    required this.onboardingRepository,
    required this.featureFlags,
    required this.authCubit,
    required this.onboardingCubit,
    this.initialLocation,
  });

  @override
  State<KopaApp> createState() => _KopaAppState();
}

class _KopaAppState extends State<KopaApp> {
  late final RouterRefreshNotifier _refreshNotifier;
  late final MatchProgrammeRefreshNotifier _matchProgrammeRefreshNotifier;
  late final GoRouter _router;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _refreshNotifier = RouterRefreshNotifier(widget.authCubit.stream);
    _matchProgrammeRefreshNotifier = MatchProgrammeRefreshNotifier();
    _router = AppRouter.create(
      authCubit: widget.authCubit,
      onboardingCubit: widget.onboardingCubit,
      featureFlags: widget.featureFlags,
      refreshListenable: _refreshNotifier,
      initialLocation: widget.initialLocation,
    );
    _authSubscription = widget.authCubit.stream.listen(_handleAuthStateChanged);
    _handleAuthStateChanged(widget.authCubit.state);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _refreshNotifier.dispose();
    _matchProgrammeRefreshNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleAuthStateChanged(AuthState state) async {
    if (!state.isAuthenticated) {
      return;
    }

    await PushNotificationsService.instance.syncForUser(state.user);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.onboardingRepository),
        Provider.value(value: widget.featureFlags),
        ChangeNotifierProvider.value(value: _matchProgrammeRefreshNotifier),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: widget.authCubit),
          BlocProvider.value(value: widget.onboardingCubit),
        ],
        child: MaterialApp.router(
          title: 'Kopa',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('da'),
            Locale('en'),
          ],
          routerConfig: _router,
        ),
      ),
    );
  }
}

class _AnimatedSplashApp extends StatelessWidget {
  const _AnimatedSplashApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _AnimatedSplashScreen(),
    );
  }
}

class _AnimatedSplashScreen extends StatelessWidget {
  const _AnimatedSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBackgroundColor,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shortestSide = constraints.biggest.shortestSide;
            final width = shortestSide < 360 ? shortestSide * 0.62 : 230.0;

            return Image.asset(
              'assets/Walk_Kick_Animation_green.gif',
              width: width,
              fit: BoxFit.contain,
              cacheWidth: _splashAnimationCacheWidth,
              cacheHeight: _splashAnimationCacheHeight,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
            );
          },
        ),
      ),
    );
  }
}

class _SplashErrorApp extends StatelessWidget {
  const _SplashErrorApp({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: _splashBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              kReleaseMode
                  ? 'Kopa kunne ikke starte.'
                  : 'Kopa kunne ikke starte.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF00943C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
