import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/cubits/team_settings_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/profile/match_settings_page.dart';
import 'package:kopa/page/profile/profile_settings_page.dart';
import 'package:kopa/page/profile/team_logo_design_page.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/repository/onboarding_repository.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets('team owner can open the team logo editor', (tester) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(_user(isTeamOwner: true)),
    )..updateUser(_user(
        isTeamOwner: true,
        logoDesign: const TeamLogoDesign(shape: TeamLogoShape.shield),
      ));
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);

    await tester.pumpWidget(
      _testApp(authCubit: authCubit, onboardingCubit: onboardingCubit),
    );
    await tester.pump();

    final logoRow = find.byKey(const ValueKey('profile-settings-team-logo'));
    await tester.scrollUntilVisible(logoRow, 200);
    await tester.tap(logoRow);
    await tester.pumpAndSettle();

    expect(find.byType(TeamLogoDesignPage), findsOneWidget);
    expect(find.text('Gem logo'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('team-logo-shape-shield')),
      findsOneWidget,
    );
  });

  testWidgets('owner sees grouped admin sections and pending requests',
      (tester) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(_user(isTeamOwner: true)),
    )..updateUser(_user(isTeamOwner: true));
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);

    await tester.pumpWidget(
      _testApp(
        authCubit: authCubit,
        onboardingCubit: onboardingCubit,
        pendingJoinRequests: 3,
      ),
    );
    await tester.pump();

    expect(find.text('3 spillere venter'), findsOneWidget);
    expect(find.text('KAMPE'), findsOneWidget);
    expect(find.text('Tilmelding & kampdag'), findsOneWidget);
    expect(
      find.text('Først til mølle · Mødetid 45 min før'),
      findsOneWidget,
    );
    expect(find.text('SÆSON & DBU'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('HOLD'), 200);
    expect(find.text('HOLD'), findsOneWidget);
    expect(find.text('3 venter på godkendelse'), findsOneWidget);
  });

  testWidgets('players only see personal actions', (tester) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(_user(isTeamOwner: false)),
    )..updateUser(_user(isTeamOwner: false));
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);

    await tester.pumpWidget(
      _testApp(authCubit: authCubit, onboardingCubit: onboardingCubit),
    );
    await tester.pump();

    expect(find.text('Inviter spillere'), findsOneWidget);
    expect(find.text('Log ud'), findsOneWidget);
    expect(find.text('Holdlogo'), findsNothing);
    expect(find.text('Tilmelding & kampdag'), findsNothing);
    expect(find.text('SÆSON & DBU'), findsNothing);
  });

  testWidgets('team admins change the signup method without a save button',
      (tester) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(
        _user(isTeamOwner: false, isAdmin: true),
      ),
    )..updateUser(_user(isTeamOwner: false, isAdmin: true));
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);
    final saves = <String?>[];

    await tester.pumpWidget(
      _testApp(
        authCubit: authCubit,
        onboardingCubit: onboardingCubit,
        onSave: (mode, _) => saves.add(mode),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tilmelding & kampdag'));
    await tester.pumpAndSettle();

    expect(find.text('Gem tilmeldingsmetode'), findsNothing);
    // Meeting time stays owner-only, as before.
    expect(find.text('Mødetid'.toUpperCase()), findsNothing);

    await tester.tap(find.byKey(const ValueKey('match-settings-rsvp-leader')));
    await tester.pumpAndSettle();

    expect(saves, [TeamDetails.teamLeaderSelection]);
    expect(find.text('Gemt'), findsOneWidget);
  });

  testWidgets('owner picks a meeting time and sees the preview',
      (tester) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(_user(isTeamOwner: true)),
    )..updateUser(_user(isTeamOwner: true));
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);
    final offsets = <int?>[];

    await tester.pumpWidget(
      _testApp(
        authCubit: authCubit,
        onboardingCubit: onboardingCubit,
        onSave: (_, offset) => offsets.add(offset),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tilmelding & kampdag'));
    await tester.pumpAndSettle();

    expect(
      find.text('Kampstart kl. 14:00 → mødetid kl. 13:15'),
      findsOneWidget,
    );

    final chip = find.byKey(const ValueKey('match-settings-offset-90'));
    await tester.scrollUntilVisible(chip, 100);
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(offsets, [90]);
    expect(
      find.text('Kampstart kl. 14:00 → mødetid kl. 12:30'),
      findsOneWidget,
    );
  });

  testWidgets('a failed save rolls the signup method back', (tester) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(_user(isTeamOwner: true)),
    )..updateUser(_user(isTeamOwner: true));
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);

    await tester.pumpWidget(
      _testApp(
        authCubit: authCubit,
        onboardingCubit: onboardingCubit,
        onSave: (_, __) => throw Exception('offline'),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tilmelding & kampdag'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('match-settings-rsvp-leader')));
    await tester.pumpAndSettle();

    final cubit = tester
        .element(find.byType(MatchSettingsPage))
        .read<TeamSettingsCubit>();
    expect(cubit.state.rsvpSelectionMode, TeamDetails.firstComeFirstServed);
    expect(cubit.state.saveStatus, TeamSettingsSaveStatus.failed);
  });

  testWidgets('players edit their position from the profile card',
      (tester) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(_user(isTeamOwner: false)),
    )..updateUser(_user(isTeamOwner: false));
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);
    final saved = <String>[];

    await tester.pumpWidget(
      _testApp(
        authCubit: authCubit,
        onboardingCubit: onboardingCubit,
        updatePosition: (position) async {
          saved.add(position);
          return _user(isTeamOwner: false, position: position);
        },
      ),
    );
    await tester.pump();

    expect(find.text('Vælg position'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('profile-settings-edit-profile')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-position-striker')));
    await tester.pumpAndSettle();

    expect(saved, ['striker']);
    expect(authCubit.state.user?.position, 'striker');
    expect(find.text('Angriber'), findsOneWidget);
  });

  testWidgets('hub summary includes the signup limit', (tester) async {
    final user = _user(isTeamOwner: true, maxSignups: 14);
    final authCubit = AuthCubit(authRepository: _FakeAuthRepository(user))
      ..updateUser(user);
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);

    await tester.pumpWidget(
      _testApp(authCubit: authCubit, onboardingCubit: onboardingCubit),
    );
    await tester.pump();

    expect(
      find.text('Først til mølle · maks 14 · Mødetid 45 min før'),
      findsOneWidget,
    );
  });

  testWidgets('admins set a signup limit with one debounced save',
      (tester) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(_user(isTeamOwner: true)),
    )..updateUser(_user(isTeamOwner: true));
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);
    final limits = <int?>[];

    await tester.pumpWidget(
      _testApp(
        authCubit: authCubit,
        onboardingCubit: onboardingCubit,
        onSaveLimit: limits.add,
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Tilmelding & kampdag'));
    await tester.pumpAndSettle();

    expect(find.text('Alle der melder sig til, kommer med.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('match-settings-limit-toggle')));
    await tester.pump();
    final increase =
        find.byKey(const ValueKey('match-settings-limit-increase'));
    await tester.ensureVisible(increase);
    await tester.tap(increase);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(increase);
    await tester.pump(const Duration(milliseconds: 100));

    expect(limits, isEmpty);
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('match-settings-limit-value')),
          )
          .data,
      '16',
    );

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(limits, [16]);
    expect(find.textContaining('Når 16 har meldt sig til'), findsOneWidget);
  });

  testWidgets('the signup limit is hidden when the leader picks the squad',
      (tester) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(_user(isTeamOwner: true)),
    )..updateUser(_user(isTeamOwner: true));
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);

    await tester.pumpWidget(
      _testApp(authCubit: authCubit, onboardingCubit: onboardingCubit),
    );
    await tester.pump();
    await tester.tap(find.text('Tilmelding & kampdag'));
    await tester.pumpAndSettle();

    expect(find.text('Begræns antal tilmeldte'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('match-settings-rsvp-leader')));
    await tester.pumpAndSettle();

    expect(find.text('Begræns antal tilmeldte'), findsNothing);
  });
}

Widget _testApp({
  required AuthCubit authCubit,
  required OnboardingCubit onboardingCubit,
  int pendingJoinRequests = 0,
  void Function(String? mode, int? offset)? onSave,
  Future<UserDetails> Function(String position)? updatePosition,
  void Function(int? maxSignups)? onSaveLimit,
}) {
  return MultiBlocProvider(
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
      home: ProfileSettingsPage(
        updatePosition: updatePosition,
        createSettingsCubit: (context) {
          final user = authCubit.state.user;
          return TeamSettingsCubit(
            teamId: user?.teamDetails?.id,
            team: user?.teamDetails,
            countJoinRequests: (_) async => pendingJoinRequests,
            saveDebounce: const Duration(milliseconds: 300),
            saveSettings: ({
              required int teamId,
              required int? defaultMeetingOffsetMinutes,
              required int? maxSignups,
              String? rsvpSelectionMode,
            }) async {
              onSave?.call(rsvpSelectionMode, defaultMeetingOffsetMinutes);
              onSaveLimit?.call(maxSignups);
              return user!.teamDetails!;
            },
          );
        },
      ),
    ),
  );
}

UserDetails _user({
  required bool isTeamOwner,
  bool isAdmin = false,
  TeamLogoDesign logoDesign = TeamLogoDesign.defaultDesign,
  String? position,
  int? maxSignups,
}) {
  final now = DateTime(2026, 8, 20);
  return UserDetails(
    id: 1,
    name: 'Owner',
    email: 'owner@example.com',
    isTeamOwner: isTeamOwner,
    isAdmin: isAdmin,
    roleId: isTeamOwner ? 1 : 2,
    position: position,
    createdAt: now,
    updatedAt: now,
    teamDetails: TeamDetails(
      id: 7,
      title: 'Kopa FC',
      logoDesign: logoDesign,
      defaultMeetingOffsetMinutes: 45,
      maxSignups: maxSignups,
      createdAt: now,
      updatedAt: now,
    ),
  );
}

class _FakeAuthRepository implements AuthRepository {
  final UserDetails user;

  _FakeAuthRepository(this.user);

  @override
  Future<UserDetails?> getCurrentUser() async => user;

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async =>
      true;
}
