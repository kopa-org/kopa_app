import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/navigation/router_refresh_notifier.dart';
import 'package:kopa/pages/onboarding_page.dart';
import 'package:kopa/pages/register_page.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/repository/onboarding_repository.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets('invite context skips role question and starts position step',
      (tester) async {
    final onboardingCubit = _TestOnboardingCubit()
      ..setInviteContext(
        email: 'player@example.com',
        name: 'Player One',
        teamId: 1,
        teamTitle: 'Kopa FC',
      );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository: _FakeAuthRepository()),
          ),
          BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('da'),
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
          home: const OnboardingPage(),
        ),
      ),
    );

    expect(find.text('Vælg din position'), findsOneWidget);
    expect(find.text('Er du holdleder?'), findsNothing);
    expect(find.text('7-mand'), findsNothing);
    expect(find.text('11-mand'), findsNothing);
  });

  testWidgets('creates the team and link before showing the final step',
      (tester) async {
    final onboardingCubit = _CreateTestOnboardingCubit();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository: _FakeAuthRepository()),
          ),
          BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('da'),
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
          home: OnboardingPage(
            updatePosition: (_) async => _user(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ja, jeg er holdleder'));
    await tester.pump();

    final backRect = tester.getRect(
      find.byKey(const ValueKey('onboarding-back-button')),
    );
    final logoRect = tester.getRect(
      find.byKey(const ValueKey('onboarding-header-logo')),
    );
    expect(backRect.center.dx, lessThan(logoRect.center.dx));

    await tester.enterText(find.byType(TextField), 'Kopa FC');
    await tester.pump();
    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();

    expect(find.text('Design dit holdlogo'), findsOneWidget);
    expect(find.text('Klar til oprettelse'), findsNothing);
    expect(find.text('Invitationslinket kunne ikke hentes.'), findsNothing);

    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();

    expect(onboardingCubit.createTeamCallCount, 1);
    expect(onboardingCubit.fetchTeamJoinTokenCallCount, 1);
    expect(find.text('Inviter dit hold'), findsOneWidget);
    expect(find.text('Fortsæt til Kopa'), findsOneWidget);
    expect(find.textContaining('kopa.dk/join'), findsOneWidget);
    expect(find.text('Invitationslinket kunne ikke hentes.'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('onboarding-back-button')));
    await tester.pump();

    expect(find.text('Design dit holdlogo'), findsOneWidget);
    expect(find.text('Inviter dit hold'), findsNothing);

    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();

    expect(onboardingCubit.fetchTeamJoinTokenCallCount, 2);
    expect(find.text('Inviter dit hold'), findsOneWidget);
    expect(find.text('Fortsæt til Kopa'), findsOneWidget);
    expect(find.textContaining('kopa.dk/join'), findsOneWidget);
  });

  testWidgets('first onboarding back returns to the signup route',
      (tester) async {
    final authCubit = AuthCubit(authRepository: _FakeAuthRepository());
    final onboardingCubit = _TestOnboardingCubit();
    final refreshNotifier = RouterRefreshNotifier(authCubit.stream);
    addTearDown(refreshNotifier.dispose);

    final router = GoRouter(
      initialLocation: AppRouter.register,
      refreshListenable: refreshNotifier,
      redirect: (context, state) => AppRouter.redirectPathFor(
        path: state.uri.path,
        authState: authCubit.state,
        onboardingState: onboardingCubit.state,
      ),
      routes: [
        GoRoute(
          path: AppRouter.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRouter.onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
        ],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          locale: const Locale('da'),
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
          routerConfig: router,
        ),
      ),
    );

    expect(find.byType(RegisterPage), findsOneWidget);

    authCubit.updateUser(_user());
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingPage), findsOneWidget);
    await tester.tap(find.text('Ja, jeg er holdleder'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('onboarding-back-button')));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPage), findsOneWidget);
    expect(find.byType(OnboardingPage), findsNothing);
  });

  testWidgets('invite context uses leader-selected 7-player format',
      (tester) async {
    final onboardingCubit = _TestOnboardingCubit()
      ..setInviteContext(
        email: 'player@example.com',
        name: 'Player One',
        teamId: 1,
        teamTitle: 'Kopa FC',
        teamPlayerCount: 7,
      );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository: _FakeAuthRepository()),
          ),
          BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
        ],
        child: MaterialApp(
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
          home: const OnboardingPage(),
        ),
      ),
    );

    expect(find.text('Vælg din position'), findsOneWidget);
    expect(find.text('7-mand'), findsNothing);
    expect(find.text('11-mand'), findsNothing);
    expect(find.text('Du valgte: Central midtbane (CM)'), findsOneWidget);
    expect(find.text('Højre midtbane (HM)'), findsNothing);
  });

  testWidgets('restored pending join request shows waiting screen',
      (tester) async {
    final onboardingCubit = _TestOnboardingCubit()
      ..setPendingJoinRequest(
        requestId: 12,
        teamId: 1,
        teamTitle: 'Kopa FC',
        teamLeaderName: 'Owner',
      );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository: _FakeAuthRepository()),
          ),
          BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
        ],
        child: MaterialApp(
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
          home: const OnboardingPage(),
        ),
      ),
    );

    expect(find.text('Venter på accept'), findsOneWidget);
    expect(find.textContaining('Kopa FC'), findsWidgets);
    expect(find.text('Holdleder: Owner'), findsOneWidget);
    expect(find.text('Afventer'), findsOneWidget);
    expect(find.text('Holdleder: Afventer'), findsNothing);
    expect(find.text('Er du holdleder?'), findsNothing);
  });

  testWidgets('async invite validation switches from role question to position',
      (tester) async {
    final onboardingCubit = _TestOnboardingCubit();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository: _FakeAuthRepository()),
          ),
          BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
        ],
        child: MaterialApp(
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
          home: const OnboardingPage(),
        ),
      ),
    );

    expect(find.text('Er du holdleder?'), findsOneWidget);

    onboardingCubit.setInviteContext(
      email: 'player@example.com',
      name: 'Player One',
      teamId: 1,
      teamTitle: 'Kopa FC',
    );
    await tester.pump();

    expect(find.text('Vælg din position'), findsOneWidget);
    expect(find.text('Er du holdleder?'), findsNothing);
  });

  testWidgets('backend waiting approval state restores waiting screen',
      (tester) async {
    final onboardingCubit = _TestOnboardingCubit(
      restoredPendingRequest: OnboardingState(
        status: OnboardingStatus.waitingApproval,
        pendingJoinRequestId: 12,
        teamId: 1,
        teamTitle: 'Kopa FC',
        teamLeaderName: 'Owner',
      ),
    );
    final authCubit = AuthCubit(authRepository: _FakeAuthRepository())
      ..updateUser(_user(
        onboardingState: const UserOnboardingState(
          status: 'waiting_approval',
          joinRequest: UserPendingJoinRequest(
            id: 12,
            status: 'pending',
            teamId: 1,
            teamTitle: 'Kopa FC',
            leaderName: 'Owner',
          ),
        ),
      ));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
        ],
        child: MaterialApp(
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
          home: const OnboardingPage(),
        ),
      ),
    );

    await tester.pump();

    expect(onboardingCubit.restoreCallCount, 1);
    expect(find.text('Venter på accept'), findsOneWidget);
    expect(find.text('Holdleder: Owner'), findsOneWidget);
  });
}

class _TestOnboardingCubit extends OnboardingCubit {
  final OnboardingState? restoredPendingRequest;
  int restoreCallCount = 0;

  _TestOnboardingCubit({this.restoredPendingRequest})
      : super(OnboardingRepository());

  void setInviteContext({
    required String email,
    required String name,
    required int teamId,
    required String teamTitle,
    int? teamPlayerCount,
  }) {
    emit(OnboardingState(
      status: OnboardingStatus.validated,
      inviteToken: 'invite-token',
      email: email,
      name: name,
      teamId: teamId,
      teamTitle: teamTitle,
      teamPlayerCount: teamPlayerCount,
    ));
  }

  void setPendingJoinRequest({
    required int requestId,
    required int teamId,
    required String teamTitle,
    String? teamLeaderName,
  }) {
    emit(OnboardingState(
      status: OnboardingStatus.waitingApproval,
      pendingJoinRequestId: requestId,
      teamId: teamId,
      teamTitle: teamTitle,
      teamLeaderName: teamLeaderName,
    ));
  }

  @override
  Future<bool> restorePendingJoinRequest() async {
    restoreCallCount++;
    final restored = restoredPendingRequest;
    if (restored == null) return false;
    emit(restored);
    return true;
  }
}

class _CreateTestOnboardingCubit extends OnboardingCubit {
  int createTeamCallCount = 0;
  int fetchTeamJoinTokenCallCount = 0;

  _CreateTestOnboardingCubit() : super(OnboardingRepository());

  @override
  Future<bool> createTeam({
    required String title,
    required int playerCount,
    Map<String, dynamic>? dbuContext,
    List<Map<String, dynamic>> standings = const [],
  }) async {
    createTeamCallCount++;
    emit(state.copyWith(
      status: OnboardingStatus.success,
      teamId: 42,
      teamTitle: title,
    ));
    return true;
  }

  @override
  Future<String?> fetchTeamJoinToken(int teamId) async {
    fetchTeamJoinTokenCallCount++;
    emit(state.copyWith(joinToken: 'join-token', errorMessage: null));
    return 'join-token';
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserDetails?> getCurrentUser() async => null;

  @override
  Future<bool> login(String email, String password) async => false;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async =>
      false;
}

UserDetails _user({UserOnboardingState? onboardingState}) {
  final now = DateTime(2026, 7, 28);
  return UserDetails(
    id: 1,
    name: 'Player',
    email: 'player@example.com',
    isTeamOwner: false,
    roleId: 2,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
    onboardingState: onboardingState,
  );
}
