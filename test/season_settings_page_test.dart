import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/season_overview_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/season_details.dart';
import 'package:kopa/model/team_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/profile/season_settings_page.dart';
import 'package:kopa/repositories/auth_repository.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets('shows the current season, sync dates and next season',
      (tester) async {
    final user = _owner();
    final authCubit = AuthCubit(authRepository: _FakeAuthRepository(user))
      ..updateUser(user);
    addTearDown(authCubit.close);

    await tester.pumpWidget(
      _app(
        authCubit,
        (teamId) => SeasonOverviewCubit(
          teamId: teamId,
          loadSeasons: (_) async => [
            SeasonDetails(
              id: 2,
              teamId: 7,
              name: 'Efterår 2026',
              startsOn: DateTime(2026, 8, 1),
              endsOn: null,
              isActive: true,
            ),
          ],
          loadStandings: (_) async => DbuStandings(
            currentTeamId: 100,
            seriesName: 'Serie 3, pulje 2',
            syncedAt: DateTime(2026, 11, 10, 12),
            rows: [
              _row(1, 101),
              _row(2, 102),
              _row(3, 100),
            ],
          ),
          loadMatches: () async => [
            _match(1, scored: true),
            _match(2, scored: true),
            _match(3, scored: false),
          ],
          loadOutlook: (_) async => const DbuSeasonOutlook(
            status: DbuSeasonOutlookStatus.ready,
            candidates: [
              DbuNextSeasonCandidate(
                dbuTeamId: 100,
                dbuPoolId: 9,
                teamName: 'Kopa FC',
                seriesName: 'Serie 3',
                poolLabel: 'Pulje 1',
                seasonLabel: 'Forår 2027',
                upcomingMatchCount: 9,
                firstUpcomingMatchOn: null,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AKTUEL SÆSON'), findsOneWidget);
    expect(find.text('Efterår 2026'), findsOneWidget);
    expect(find.text('Serie 3, pulje 2 · 3 hold'), findsOneWidget);
    expect(find.text('3.'), findsOneWidget);
    expect(find.text('spillet'), findsOneWidget);
    expect(find.text('3 kampe i sæsonen'), findsOneWidget);
    expect(find.text('Opdateret 10. nov.'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Start Forår 2027'), 200);
    expect(
      find.text('Forår 2027 er klar på DBU med 9 kampe.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Opret kamp manuelt'), 200);
    expect(find.text('Opret kamp manuelt'), findsOneWidget);
  });

  testWidgets('hides facts that failed to load', (tester) async {
    final user = _owner();
    final authCubit = AuthCubit(authRepository: _FakeAuthRepository(user))
      ..updateUser(user);
    addTearDown(authCubit.close);

    await tester.pumpWidget(
      _app(
        authCubit,
        (teamId) => SeasonOverviewCubit(
          teamId: teamId,
          loadSeasons: (_) async => throw Exception('offline'),
          loadStandings: (_) async => null,
          loadMatches: () async => throw Exception('offline'),
          loadOutlook: (_) async => throw Exception('offline'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ingen aktiv sæson'), findsOneWidget);
    expect(find.byKey(const ValueKey('season-stat-matches')), findsNothing);
    expect(find.text('Ikke hentet endnu'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Start ny sæson'), 200);
    expect(
      find.text(
        'Importér den nye sæsons kampprogram, når DBU har offentliggjort det.',
      ),
      findsOneWidget,
    );
  });
}

Widget _app(
  AuthCubit authCubit,
  SeasonOverviewCubit Function(int? teamId) createCubit,
) {
  return BlocProvider<AuthCubit>.value(
    value: authCubit,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('da'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('da'), Locale('en')],
      home: SeasonSettingsPage(createOverviewCubit: createCubit),
    ),
  );
}

DbuStandingRow _row(int position, int teamId) => DbuStandingRow(
      position: position,
      dbuTeamId: teamId,
      teamName: 'Team $teamId',
      matchesPlayed: 2,
      wins: 1,
      draws: 0,
      losses: 1,
      goalsFor: 3,
      goalsAgainst: 3,
      points: 3,
    );

MatchDetails _match(int id, {required bool scored}) => MatchDetails.fromJson({
      'id': id,
      'type': 'MATCH',
      'team_id': 7,
      'date': '2026-10-0${id}T12:00:00Z',
      'meeting_time': null,
      'location': 'Stadium',
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
      'home_team_score': scored ? 2 : null,
      'away_team_score': scored ? 1 : null,
    });

UserDetails _owner() {
  final now = DateTime(2026, 8, 20);
  return UserDetails(
    id: 1,
    name: 'Owner',
    email: 'owner@example.com',
    isTeamOwner: true,
    roleId: 1,
    createdAt: now,
    updatedAt: now,
    teamDetails: TeamDetails(
      id: 7,
      title: 'Kopa FC',
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
