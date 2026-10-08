import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/team_members_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/tab/profile_tab.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets(
      'leader assigns another leader then switches themselves to player',
      (tester) async {
    final users = [_user(1, true), _user(2, false)];
    final auth = AuthCubit(authRepository: _Auth())..updateUser(users.first);
    final cubit = TeamMembersCubit(
        loadMembers: () async => users,
        updateRole: (
            {required teamId, required userId, required isTeamLeader}) async {
          expect(teamId, 10);
          return _user(userId, isTeamLeader);
        });
    addTearDown(auth.close);
    await cubit.load();
    await _pump(tester, auth, cubit);
    expect(find.byTooltip('Skift rolle på holdet'), findsNWidgets(2));
    await tester.tap(find.descendant(
        of: find.byKey(const ValueKey('team-member-2')),
        matching: find.byType(IconButton)));
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
    await tester
        .tap(find.widgetWithText(CupertinoActionSheetAction, 'Holdleder'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
    expect(cubit.state.members.last.isTeamOwner, isTrue);
    await tester.tap(find.descendant(
        of: find.byKey(const ValueKey('team-member-1')),
        matching: find.byType(IconButton)));
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
    await tester
        .tap(find.widgetWithText(CupertinoActionSheetAction, 'Spiller'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
    expect(auth.state.user!.isTeamOwner, isFalse);
    expect(find.byTooltip('Skift rolle på holdet'), findsNothing);
    expect(find.text('Holdleder'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('roster refresh applies a role assigned by another leader',
      (tester) async {
    final current = _user(1, false);
    final auth = AuthCubit(authRepository: _Auth())..updateUser(current);
    var leader = false;
    final cubit = TeamMembersCubit(loadMembers: () async => [_user(1, leader)]);
    addTearDown(auth.close);
    await _pump(tester, auth, cubit);
    expect(find.byTooltip('Skift rolle på holdet'), findsNothing);
    leader = true;
    await cubit.load();
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
    expect(auth.state.user!.isTeamOwner, isTrue);
    expect(
        identical(auth.state.user!.teamDetails, current.teamDetails), isTrue);
    expect(find.byTooltip('Skift rolle på holdet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('last leader error retains role and explains how to proceed',
      (tester) async {
    final auth = AuthCubit(authRepository: _Auth())..updateUser(_user(1, true));
    final cubit = TeamMembersCubit(
        loadMembers: () async => [_user(1, true)],
        updateRole: (
            {required teamId, required userId, required isTeamLeader}) async {
          throw const LastTeamLeaderException();
        });
    addTearDown(auth.close);
    await cubit.load();
    await _pump(tester, auth, cubit);
    await tester.tap(find.byTooltip('Skift rolle på holdet'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
    await tester
        .tap(find.widgetWithText(CupertinoActionSheetAction, 'Spiller'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
    expect(find.text('Udpeg en anden holdleder, før du skifter til spiller.'),
        findsOneWidget);
    expect(auth.state.user!.isTeamOwner, isTrue);
    expect(cubit.state.members.single.isTeamOwner, isTrue);
    expect(cubit.state.savingUserId, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _pump(
    WidgetTester tester, AuthCubit auth, TeamMembersCubit cubit) async {
  await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: auth),
      ],
      child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('da'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileTab(createMembersCubit: () => cubit))));
  await tester.pumpAndSettle(const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
}

UserDetails _user(int id, bool leader) => UserDetails(
    id: id,
    name: 'Member $id',
    email: 'member$id@example.com',
    isTeamOwner: leader,
    roleId: 2,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    teamDetails: TeamDetails(
        id: 10,
        title: 'Kopa FC',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026)));

class _Auth implements AuthRepository {
  @override
  Future<UserDetails?> getCurrentUser() async => null;
  @override
  Future<bool> login(String email, String password) async => false;
  @override
  Future<void> logout() async {}
  @override
  Future<bool> register(
          {required String name,
          required String email,
          required String password,
          required int roleId}) async =>
      false;
}
