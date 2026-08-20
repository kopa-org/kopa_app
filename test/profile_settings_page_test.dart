import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/model/user_details.dart';
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
      _testApp(
        authCubit: authCubit,
        onboardingCubit: onboardingCubit,
      ),
    );

    expect(find.text('Ændre hold logo'), findsOneWidget);

    await tester.tap(find.text('Ændre hold logo'));
    await tester.pumpAndSettle();

    expect(find.byType(TeamLogoDesignPage), findsOneWidget);
    expect(find.text('Gem logo'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('team-logo-shape-shield')),
      findsOneWidget,
    );
  });

  testWidgets('players do not see the team logo editor action', (tester) async {
    final authCubit = AuthCubit(
      authRepository: _FakeAuthRepository(_user(isTeamOwner: false)),
    )..updateUser(_user(isTeamOwner: false));
    final onboardingCubit = OnboardingCubit(OnboardingRepository());
    addTearDown(authCubit.close);
    addTearDown(onboardingCubit.close);

    await tester.pumpWidget(
      _testApp(
        authCubit: authCubit,
        onboardingCubit: onboardingCubit,
      ),
    );

    expect(find.text('Ændre hold logo'), findsNothing);
  });
}

Widget _testApp({
  required AuthCubit authCubit,
  required OnboardingCubit onboardingCubit,
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
      home: const ProfileSettingsPage(),
    ),
  );
}

UserDetails _user({
  required bool isTeamOwner,
  TeamLogoDesign logoDesign = TeamLogoDesign.defaultDesign,
}) {
  final now = DateTime(2026, 8, 20);
  return UserDetails(
    id: 1,
    name: 'Owner',
    email: 'owner@example.com',
    isTeamOwner: isTeamOwner,
    roleId: isTeamOwner ? 1 : 2,
    createdAt: now,
    updatedAt: now,
    teamDetails: TeamDetails(
      id: 7,
      title: 'Kopa FC',
      logoDesign: logoDesign,
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
