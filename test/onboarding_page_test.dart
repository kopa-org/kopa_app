import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/pages/onboarding_page.dart';
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
  });

  testWidgets('restored pending join request shows waiting screen',
      (tester) async {
    final onboardingCubit = _TestOnboardingCubit()
      ..setPendingJoinRequest(
        requestId: 12,
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
}

class _TestOnboardingCubit extends OnboardingCubit {
  _TestOnboardingCubit() : super(OnboardingRepository());

  void setInviteContext({
    required String email,
    required String name,
    required int teamId,
    required String teamTitle,
  }) {
    emit(OnboardingState(
      status: OnboardingStatus.validated,
      inviteToken: 'invite-token',
      email: email,
      name: name,
      teamId: teamId,
      teamTitle: teamTitle,
    ));
  }

  void setPendingJoinRequest({
    required int requestId,
    required int teamId,
    required String teamTitle,
  }) {
    emit(OnboardingState(
      status: OnboardingStatus.waitingApproval,
      pendingJoinRequestId: requestId,
      teamId: teamId,
      teamTitle: teamTitle,
    ));
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
