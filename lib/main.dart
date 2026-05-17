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
import 'package:kopa/theme/app_theme.dart';

void main() async {
  await CrashReporting.runAppGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
    await CrashReporting.initialize();
    
    final authRepository = ApiAuthRepository();
    final authCubit = AuthCubit(authRepository: authRepository);
    // Initialize auth state
    await authCubit.init();

    runApp(
      KopaApp(
        authRepository: authRepository,
        authCubit: authCubit,
      ),
    );
  });
}

class KopaApp extends StatefulWidget {
  final AuthRepository authRepository;
  final AuthCubit authCubit;

  const KopaApp({
    super.key,
    required this.authRepository,
    required this.authCubit,
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: widget.authCubit),
        ],
        child: MaterialApp.router(
          title: 'Kopa',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
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
