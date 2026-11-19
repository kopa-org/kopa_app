import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_rsvp_card.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/auth_state.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/match_details_page.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  test('squad selection has no waitlist, even with a signup limit', () {
    final match = _match(maxSignups: 5);
    expect(match.usesSquadSelection, isTrue);
    expect(match.usesTeamLeaderSelection, isFalse);
    expect(match.usesWaitlist, isFalse);
  });

  testWidgets('an available player can only withdraw', (tester) async {
    var withdrawn = 0;
    await tester.pumpWidget(_wrap(Scaffold(
      body: MatchRsvpCard(
        status: MatchRsvpStatus.available,
        squadSelection: true,
        isSaving: false,
        onAccept: () {},
        onDecline: () => withdrawn++,
      ),
    )));

    expect(find.text('Du er til rådighed'), findsOneWidget);
    expect(find.byKey(const ValueKey('match-rsvp-accept')), findsNothing);
    await tester.tap(find.text('Meld afbud'));
    expect(withdrawn, 1);
  });

  testWidgets('saving disables withdrawing', (tester) async {
    var withdrawn = 0;
    await tester.pumpWidget(_wrap(Scaffold(
      body: MatchRsvpCard(
        status: MatchRsvpStatus.available,
        squadSelection: true,
        isSaving: true,
        onAccept: () {},
        onDecline: () => withdrawn++,
      ),
    )));
    await tester.tap(find.byKey(const ValueKey('match-rsvp-decline')));
    expect(withdrawn, 0);
  });

  testWidgets('a picked player is shown as selected', (tester) async {
    await tester.pumpWidget(_wrap(Scaffold(
      body: MatchRsvpCard(
        status: MatchRsvpStatus.attending,
        squadSelection: true,
        isSaving: false,
        onAccept: () {},
        onDecline: () {},
      ),
    )));
    expect(find.text('Udtaget'), findsOneWidget);
  });

  for (final leader in [true, false]) {
    testWidgets(
        '${leader ? 'leader picks from' : 'player sees'} the whole squad',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 1400);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final user = _user(1, 'Leader', owner: leader);
      final auth = _Auth(user);
      addTearDown(auth.close);

      await tester.pumpWidget(_wrap(
        auth: auth,
        MatchDetailsPage(
          matchId: 42,
          showBottomNavigationBar: false,
          loadMatch: (_) async => _match(),
          loadSquad: () async => [
            user,
            _user(2, 'Picked'),
            _user(3, 'Withdrawn'),
            _user(4, 'Free'),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const ValueKey('match-details-segment-attendance')));
      await tester.pumpAndSettle();

      if (leader) {
        // Picked, available (never signed up) and withdrawn players.
        expect(find.text('Udtaget (1)'), findsOneWidget);
        expect(find.text('Til rådighed (2)'), findsOneWidget);
        expect(find.text('Frameldt (1)'), findsOneWidget);
        expect(find.byKey(const ValueKey('squad-unpick-2')), findsOneWidget);

        await tester.tap(find.text('Til rådighed (2)'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('squad-pick-4')), findsOneWidget);
        expect(find.byKey(const ValueKey('squad-pick-1')), findsOneWidget);
        // Withdrawn players cannot be picked.
        expect(find.byKey(const ValueKey('squad-pick-3')), findsNothing);
      } else {
        // Picks stay hidden until the lineup is shown, and only leaders pick.
        expect(find.textContaining('Udtaget ('), findsNothing);
        expect(find.text('Til rådighed (3)'), findsOneWidget);
        expect(find.byKey(const ValueKey('squad-pick-4')), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _wrap(Widget home, {AuthCubit? auth}) {
  final app = MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('da'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
  return auth == null
      ? app
      : BlocProvider<AuthCubit>.value(value: auth, child: app);
}

Map<String, dynamic> _attendance(int userId, String name,
        {required bool attending, bool? selected}) =>
    {
      'id': userId,
      'user_details': {
        'id': userId,
        'name': name,
        'email': '$name@example.com',
        'is_team_owner': false,
        'role_id': 2,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      },
      'is_attending': attending,
      'is_selected': selected,
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
    };

MatchDetails _match({int? maxSignups}) {
  final date = DateTime.now().add(const Duration(days: 3)).toUtc();
  return MatchDetails.fromJson({
    'id': 42,
    'type': 'MATCH',
    'team_id': 1,
    'home_team': 'Kopa IF',
    'away_team': 'Fremad',
    'date': date.toIso8601String(),
    'location': 'Stadium',
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
    'rsvp_selection_mode': 'squad_selection',
    'max_signups': maxSignups,
    'attendance_details_list': [
      _attendance(2, 'Picked', attending: true, selected: true),
      _attendance(3, 'Withdrawn', attending: false),
    ],
  });
}

UserDetails _user(int id, String name, {bool owner = false}) => UserDetails(
      id: id,
      name: name,
      email: '$name@example.com',
      isTeamOwner: owner,
      roleId: 2,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      teamDetails: null,
    );

class _Auth extends AuthCubit {
  _Auth(UserDetails user) : super(authRepository: _NoAuth()) {
    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }
}

class _NoAuth implements AuthRepository {
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
