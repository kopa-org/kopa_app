import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/navigation/router_refresh_notifier.dart';
import 'package:kopa/pages/onboarding_page.dart';
import 'package:kopa/pages/register_page.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/repository/onboarding_repository.dart';
import 'package:kopa/theme/app_theme.dart';
import 'package:kopa/theme/app_colors.dart';

void main() {
  for (final language in ['da', 'en']) {
    testWidgets('both signup choice pairs are equal outlined pills: $language',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final onboardingCubit = _TestOnboardingCubit();
      addTearDown(onboardingCubit.close);
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository: _FakeAuthRepository()),
          ),
          BlocProvider<OnboardingCubit>.value(value: onboardingCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OnboardingPage(),
        ),
      ));
      await tester.pumpAndSettle();
      final createLabel = language == 'en' ? 'Create Team' : 'Opret hold';
      final joinLabel = language == 'en' ? 'Join team' : 'Tilmeld hold';
      final leaderLabel = language == 'en' ? 'Team leader' : 'Holdleder';
      final playerLabel = language == 'en' ? 'Player' : 'Spiller';

      void checkPair(String first, String second) {
        final buttons = find.byType(OutlinedButton);
        expect(buttons, findsNWidgets(2));
        expect(find.byType(FilledButton), findsNothing);
        final firstRect = tester.getRect(find.ancestor(
            of: find.text(first), matching: find.byType(OutlinedButton)));
        final secondRect = tester.getRect(find.ancestor(
            of: find.text(second), matching: find.byType(OutlinedButton)));
        expect(firstRect.top, secondRect.top);
        expect(firstRect.width, secondRect.width);
        expect(firstRect.height, secondRect.height);
        for (final button in tester.widgetList<OutlinedButton>(buttons)) {
          final style = button.style!;
          expect(style.backgroundColor!.resolve({}), AppColors.light.white);
          expect(style.foregroundColor!.resolve({}), AppColors.light.grass);
          expect(style.side!.resolve({})!.color, AppColors.light.grass);
          expect(style.shape!.resolve({}), isA<StadiumBorder>());
        }
        expect(tester.takeException(), isNull);
      }

      checkPair(createLabel, joinLabel);
      await tester.tap(find.text(createLabel));
      await tester.pumpAndSettle();
      checkPair(leaderLabel, playerLabel);
      await tester.tap(find.text(playerLabel));
      await tester.pumpAndSettle();
      expect(onboardingCubit.state.isTeamLeader, isFalse);
      expect(find.byType(TextField), findsWidgets);
      await tester.tap(find.byKey(const ValueKey('onboarding-back-button')));
      await tester.pumpAndSettle();
      checkPair(leaderLabel, playerLabel);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      checkPair(createLabel, joinLabel);
      await tester.tap(find.text(joinLabel));
      await tester.pumpAndSettle();
      checkPair(leaderLabel, playerLabel);
      await tester.tap(find.text(leaderLabel));
      await tester.pumpAndSettle();
      expect(onboardingCubit.state.isTeamLeader, isTrue);
      expect(find.text(language == 'en' ? 'Join team' : 'Tilmeld hold'),
          findsOneWidget);
    });
  }

  for (final count in [7, 11]) {
    testWidgets('search join inherits $count-player format before requesting',
        (tester) async {
      final onboarding = _TestOnboardingCubit();
      final auth = AuthCubit(authRepository: _FakeAuthRepository());
      addTearDown(onboarding.close);
      addTearDown(auth.close);
      await tester.pumpWidget(MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: auth),
            BlocProvider<OnboardingCubit>.value(value: onboarding),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: const Locale('da'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OnboardingPage(updatePosition: (_) async => _user()),
          )));
      await tester.tap(find.text('Tilmeld hold'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Holdleder'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('onboarding-formation-toggle')),
          findsNothing);
      expect(find.text('Vælg din position'), findsNothing);
      onboarding.setSearchResult(count);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vælg hold'));
      await tester.pumpAndSettle();
      expect(find.text('Vælg din position'), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding-formation-toggle')),
          findsNothing);
      expect(find.text('HM'), count == 11 ? findsOneWidget : findsNothing);
      expect(onboarding.requestedTeamId, isNull);
      await tester.tap(find.text('Fortsæt'));
      await tester.pumpAndSettle();
      expect(onboarding.requestedTeamId, 42);
      expect(onboarding.requestedAsLeader, isTrue);
    });
  }

  for (final stage in ['position', 'waiting', 'invite']) {
    testWidgets('can exit signup from $stage without completing it',
        (tester) async {
      final repository = _FakeAuthRepository();
      final auth = AuthCubit(
          authRepository: repository, unregisterPushToken: () async {})
        ..updateUser(_user());
      final onboarding = _TestOnboardingCubit();
      if (stage == 'waiting') {
        onboarding.setPendingJoinRequest(
            requestId: 12, teamId: 1, teamTitle: 'Kopa FC');
      } else if (stage == 'invite') {
        onboarding.setInviteContext(
            email: 'player@example.com',
            name: 'Player',
            teamId: 1,
            teamTitle: 'Kopa FC');
      }
      final refresh = RouterRefreshNotifier(auth.stream);
      final router = GoRouter(
          initialLocation: AppRouter.onboarding,
          refreshListenable: refresh,
          redirect: (_, state) => AppRouter.redirectPathFor(
              path: state.uri.path,
              authState: auth.state,
              onboardingState: onboarding.state),
          routes: [
            GoRoute(
                path: AppRouter.onboarding,
                builder: (_, __) => const OnboardingPage()),
            GoRoute(
                path: AppRouter.login,
                builder: (_, __) => const Scaffold(body: Text('Login'))),
          ]);
      addTearDown(router.dispose);
      addTearDown(refresh.dispose);
      addTearDown(auth.close);
      addTearDown(onboarding.close);
      await tester.pumpWidget(MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: auth),
            BlocProvider<OnboardingCubit>.value(value: onboarding),
          ],
          child: MaterialApp.router(
              routerConfig: router,
              theme: AppTheme.lightTheme,
              locale: const Locale('da'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales)));
      await tester.pumpAndSettle();
      if (stage == 'position') {
        await tester.tap(find.text('Tilmeld hold'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Spiller'));
        await tester.pumpAndSettle();
        onboarding.setSearchResult(7);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Vælg hold'));
        await tester.pumpAndSettle();
      }
      if (stage == 'waiting') {
        await tester.binding.handlePopRoute();
      } else {
        await tester.tap(find.byKey(const ValueKey('onboarding-exit-button')));
      }
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
      expect(repository.logoutCount, 1);
      expect(auth.state.user, isNull);
      expect(onboarding.state.pendingJoinRequestId, isNull);
      expect(onboarding.state.inviteToken, isNull);
    });
  }

  testWidgets('role question scrolls on a compact viewport', (tester) async {
    tester.view.physicalSize = const Size(360, 416);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Opret eller tilmeld dig et hold'), findsOneWidget);
    expect(find.text('Tilmeld hold'), findsOneWidget);
  });

  testWidgets('invite context asks for a role before the position step',
      (tester) async {
    final onboardingCubit = _TestOnboardingCubit()
      ..setInviteContext(
        email: 'player@example.com',
        name: 'Player One',
        teamId: 1,
        teamTitle: 'Kopa FC',
        isTeamLeader: null,
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

    expect(find.text('Hvad er din rolle?'), findsOneWidget);
    expect(find.text('Opret hold'), findsNothing);
    await tester.tap(find.text('Holdleder'));
    await tester.pumpAndSettle();
    expect(onboardingCubit.state.isTeamLeader, isTrue);
    expect(find.text('Vælg din position'), findsOneWidget);
    expect(find.text('Opret eller tilmeld dig et hold'), findsNothing);
    expect(find.text('7-mand'), findsNothing);
    expect(find.text('11-mand'), findsNothing);
  });

  testWidgets('formation segmented toggle matches the Figma states',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    await tester.tap(find.text('Opret hold'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Holdleder'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Kopa FC');
    await tester.pump();
    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();

    final toggleFinder =
        find.byKey(const ValueKey('onboarding-formation-toggle'));
    expect(toggleFinder, findsOneWidget);
    expect(tester.getSize(toggleFinder), const Size(342, 40));

    final selectedOptionFinder =
        find.byKey(const ValueKey('onboarding-formation-option-11-mand'));
    final inactiveOptionFinder =
        find.byKey(const ValueKey('onboarding-formation-option-7-mand'));
    final selectedDecoration = tester
        .widget<DecoratedBox>(selectedOptionFinder)
        .decoration as BoxDecoration;
    final inactiveDecoration = tester
        .widget<DecoratedBox>(inactiveOptionFinder)
        .decoration as BoxDecoration;

    expect(selectedDecoration.color, AppColors.light.white);
    expect(selectedDecoration.borderRadius, BorderRadius.circular(17));
    expect(selectedDecoration.boxShadow, hasLength(1));
    expect(selectedDecoration.boxShadow!.single.offset, const Offset(0, 2));
    expect(selectedDecoration.boxShadow!.single.blurRadius, 2);
    expect(inactiveDecoration.color, Colors.transparent);
    expect(
      tester.widget<Text>(find.text('11-mand')).style,
      isNotNull,
    );
    expect(
      tester.widget<Text>(find.text('11-mand')).style!.fontSize,
      13,
    );
    expect(
      tester.widget<Text>(find.text('11-mand')).style!.fontWeight,
      FontWeight.bold,
    );
    expect(
      tester.widget<Text>(find.text('7-mand')).style!.fontWeight,
      FontWeight.w600,
    );

    await tester.tap(inactiveOptionFinder);
    await tester.pump();

    final sevenMandDecoration = tester
        .widget<DecoratedBox>(inactiveOptionFinder)
        .decoration as BoxDecoration;
    final elevenMandDecoration = tester
        .widget<DecoratedBox>(selectedOptionFinder)
        .decoration as BoxDecoration;
    expect(sevenMandDecoration.color, AppColors.light.white);
    expect(sevenMandDecoration.boxShadow, hasLength(1));
    expect(elevenMandDecoration.color, Colors.transparent);
    expect(elevenMandDecoration.boxShadow, isNull);
  });

  testWidgets('recommends DBU once before advancing from manual team name',
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

    await tester.tap(find.text('Opret hold'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Holdleder'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Kopa FC');
    await tester.pump();

    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Det anbefles at synkronisere med DBU, for den bedste app oplevelse',
      ),
      findsOneWidget,
    );
    expect(find.text('Vælg din position'), findsNothing);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Det anbefles at synkronisere med DBU, for den bedste app oplevelse'),
        findsNothing);

    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();

    expect(find.text('Vælg din position'), findsOneWidget);
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

    await tester.tap(find.text('Opret hold'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Holdleder'));
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
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();

    expect(find.text('Design dit holdlogo'), findsOneWidget);
    expect(find.text('Klar til oprettelse'), findsNothing);
    expect(find.text('Invitationslinket kunne ikke hentes.'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('onboarding-logo-color-#D22B2B')),
    );
    final shapeFinder =
        find.byKey(const ValueKey('onboarding-logo-shape-shield'));
    await tester.ensureVisible(shapeFinder);
    await tester.tap(
      shapeFinder,
    );
    final patternFinder =
        find.byKey(const ValueKey('onboarding-logo-pattern-horizontalSplit'));
    await tester.ensureVisible(patternFinder);
    await tester.tap(
      patternFinder,
    );

    await tester.tap(find.text('Fortsæt'));
    await tester.pumpAndSettle();

    expect(onboardingCubit.createTeamCallCount, 1);
    expect(onboardingCubit.createdLogoDesign?.color, const Color(0xFFD22B2B));
    expect(onboardingCubit.createdLogoDesign?.shape, TeamLogoShape.shield);
    expect(
      onboardingCubit.createdLogoDesign?.pattern,
      TeamLogoPattern.horizontalSplit,
    );
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
    expect(onboardingCubit.updateTeamLogoCallCount, 1);
    expect(find.text('Inviter dit hold'), findsOneWidget);
    expect(find.text('Fortsæt til Kopa'), findsOneWidget);
    expect(find.textContaining('kopa.dk/join'), findsOneWidget);
  });

  testWidgets('onboarding back walks through choices and logs out to login',
      (tester) async {
    final authCubit = AuthCubit(
        authRepository: _FakeAuthRepository(),
        unregisterPushToken: () async {});
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
            path: AppRouter.welcome,
            builder: (_, __) => const Scaffold(body: Text('Welcome'))),
        GoRoute(
            path: AppRouter.login,
            builder: (_, __) => const Scaffold(body: Text('Login'))),
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
    await tester.tap(find.text('Opret hold'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Holdleder'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('onboarding-back-button')));
    await tester.pumpAndSettle();

    expect(find.text('Hvad er din rolle?'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Opret eller tilmeld dig et hold'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
    expect(authCubit.state.user, isNull);
    expect(onboardingCubit.state.isTeamLeader, isNull);
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
    expect(find.text('7-mand'), findsNothing);
    expect(find.text('11-mand'), findsNothing);
    expect(find.text('Du valgte: Central midtbane (CM)'), findsOneWidget);
    expect(find.text('HM'), findsNothing);
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

    expect(find.text('Venter på accept'), findsOneWidget);
    expect(find.textContaining('Kopa FC'), findsWidgets);
    expect(find.text('Holdleder: Owner'), findsOneWidget);
    expect(find.text('Afventer'), findsOneWidget);
    expect(find.text('Holdleder: Afventer'), findsNothing);
    expect(find.text('Opret eller tilmeld dig et hold'), findsNothing);
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

    expect(find.text('Opret eller tilmeld dig et hold'), findsOneWidget);

    onboardingCubit.setInviteContext(
      email: 'player@example.com',
      name: 'Player One',
      teamId: 1,
      teamTitle: 'Kopa FC',
    );
    await tester.pump();

    expect(find.text('Vælg din position'), findsOneWidget);
    expect(find.text('Opret eller tilmeld dig et hold'), findsNothing);
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

    await tester.pump();

    expect(onboardingCubit.restoreCallCount, 1);
    expect(find.text('Venter på accept'), findsOneWidget);
    expect(find.text('Holdleder: Owner'), findsOneWidget);
  });
}

class _TestOnboardingCubit extends OnboardingCubit {
  final OnboardingState? restoredPendingRequest;
  int restoreCallCount = 0;
  int? requestedTeamId;
  bool? requestedAsLeader;
  bool failNextRequest = false;

  void setSearchResult(int count) => emit(state.copyWith(searchResults: [
        {'id': 42, 'title': 'Kopa FC', 'player_count': count},
      ]));

  @override
  Future<bool> requestToJoinTeam(int teamId, {String? teamName}) async {
    requestedTeamId = teamId;
    requestedAsLeader = state.isTeamLeader;
    if (failNextRequest) {
      failNextRequest = false;
      emit(state.copyWith(
          status: OnboardingStatus.failure, errorMessage: 'Request failed'));
      return false;
    }
    emit(state.copyWith(
        status: OnboardingStatus.waitingApproval, pendingJoinRequestId: 12));
    return true;
  }

  _TestOnboardingCubit({this.restoredPendingRequest})
      : super(OnboardingRepository());

  void setInviteContext({
    required String email,
    required String name,
    required int teamId,
    required String teamTitle,
    int? teamPlayerCount,
    bool? isTeamLeader = false,
  }) {
    emit(OnboardingState(
      status: OnboardingStatus.validated,
      inviteToken: 'invite-token',
      email: email,
      name: name,
      teamId: teamId,
      teamTitle: teamTitle,
      teamPlayerCount: teamPlayerCount,
      isTeamLeader: isTeamLeader,
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
  int updateTeamLogoCallCount = 0;
  TeamLogoDesign? createdLogoDesign;

  _CreateTestOnboardingCubit() : super(OnboardingRepository());

  @override
  Future<bool> createTeam({
    required String title,
    required int playerCount,
    TeamLogoDesign? logoDesign,
    Map<String, dynamic>? dbuContext,
    List<Map<String, dynamic>> standings = const [],
  }) async {
    createTeamCallCount++;
    createdLogoDesign = logoDesign;
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

  @override
  Future<bool> updateTeamLogo({
    required int teamId,
    required TeamLogoDesign logoDesign,
  }) async {
    updateTeamLogoCallCount++;
    return true;
  }
}

class _FakeAuthRepository implements AuthRepository {
  int logoutCount = 0;
  @override
  Future<UserDetails?> getCurrentUser() async => null;

  @override
  Future<bool> login(String email, String password) async => false;

  @override
  Future<void> logout() async {
    logoutCount++;
  }

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
