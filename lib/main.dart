import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/navigation/router_refresh_notifier.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/utils/crash_reporting.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kopa/repository/onboarding_repository.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_theme.dart';

void main() async {
  await CrashReporting.runAppGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
    await CrashReporting.initialize();

    final authRepository = ApiAuthRepository();
    final onboardingRepository = OnboardingRepository();

    final authCubit = AuthCubit(authRepository: authRepository);
    final onboardingCubit = OnboardingCubit(onboardingRepository);

    // Initialize auth state
    await authCubit.init();

    runApp(
      KopaApp(
        authRepository: authRepository,
        onboardingRepository: onboardingRepository,
        authCubit: authCubit,
        onboardingCubit: onboardingCubit,
      ),
    );
  });
}

class KopaApp extends StatefulWidget {
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final AuthCubit authCubit;
  final OnboardingCubit onboardingCubit;

  const KopaApp({
    super.key,
    required this.authRepository,
    required this.onboardingRepository,
    required this.authCubit,
    required this.onboardingCubit,
  });

  @override
  State<KopaApp> createState() => _KopaAppState();
}

class _KopaAppState extends State<KopaApp> {
  late final RouterRefreshNotifier _refreshNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _refreshNotifier = RouterRefreshNotifier(widget.authCubit.stream);
    _router = AppRouter.create(
      authCubit: widget.authCubit,
      onboardingCubit: widget.onboardingCubit,
      refreshListenable: _refreshNotifier,
    );
  }

  @override
  void dispose() {
    _refreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.onboardingRepository),
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
