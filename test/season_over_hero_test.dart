import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/home/season_over_hero.dart';
import 'package:kopa/cubits/home_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/state/match_programme_refresh_notifier.dart';
import 'package:kopa/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  final ready = DbuSeasonOutlook(
    status: DbuSeasonOutlookStatus.ready,
    checkedAt: DateTime(2026, 11, 11, 8, 14),
    candidates: [
      DbuNextSeasonCandidate(
        dbuTeamId: 10,
        dbuPoolId: 200,
        teamName: 'Kopa IF',
        seriesName: 'Serie 4, pulje 12',
        poolLabel: '',
        seasonLabel: 'Forår 2027',
        upcomingMatchCount: 9,
        firstUpcomingMatchOn: DateTime(2027, 3, 28),
      ),
    ],
  );
  final waiting = DbuSeasonOutlook(
    status: DbuSeasonOutlookStatus.waiting,
    checkedAt: DateTime(2026, 11, 11, 8, 14),
  );

  testWidgets('recaps the played season from the team perspective',
      (tester) async {
    await _pump(tester, outlook: waiting, matches: _season());

    expect(find.text('Sæsonen er slut'), findsOneWidget);
    expect(find.text('Sæsonen i tal'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
    // Home 2-1 win, 1-1 draw, away 3-0 loss.
    expect(find.text('1-1-1'), findsOneWidget);
  });

  testWidgets('shows a checking state until the outlook arrives',
      (tester) async {
    await _pump(tester, outlook: null, matches: _season());

    expect(find.text('Kigger efter næste sæson på DBU…'), findsOneWidget);
  });

  testWidgets('waiting lets team leaders re-check or override', (tester) async {
    await _pump(tester, outlook: waiting, matches: _season());

    expect(find.text('Venter på næste sæson'), findsOneWidget);
    expect(find.text('Tjek igen'), findsOneWidget);
    expect(
        find.text('Jeg ved, den er der – importér alligevel'), findsOneWidget);
  });

  testWidgets('players can check, import and start the season too',
      (tester) async {
    await _pump(
      tester,
      outlook: waiting,
      matches: _season(),
      canManage: false,
    );

    expect(find.text('Tjek igen'), findsOneWidget);
    expect(
        find.text('Jeg ved, den er der – importér alligevel'), findsOneWidget);

    await _pump(
      tester,
      outlook: const DbuSeasonOutlook(
        status: DbuSeasonOutlookStatus.unavailable,
      ),
      matches: const [],
      canManage: false,
    );
    expect(find.text('Start ny sæson'), findsOneWidget);
  });

  testWidgets('ready shows the found season and a start action',
      (tester) async {
    await _pump(tester, outlook: ready, matches: _season());

    expect(find.text('Ny sæson klar'), findsOneWidget);
    expect(find.text('Serie 4, pulje 12'), findsOneWidget);
    expect(find.text('Forår 2027'), findsOneWidget);
    expect(find.textContaining('9 kampe'), findsOneWidget);
    expect(find.text('Start ny sæson'), findsOneWidget);
    expect(find.text('Ikke den rigtige? Find den på DBU'), findsOneWidget);
  });

  testWidgets('a team without history is ready for kick-off', (tester) async {
    await _pump(
      tester,
      outlook: const DbuSeasonOutlook(
        status: DbuSeasonOutlookStatus.unavailable,
      ),
      matches: const [],
    );

    expect(find.text('Klar til kickoff'), findsOneWidget);
    expect(find.text('Sæsonen i tal'), findsNothing);
    expect(find.text('Start ny sæson'), findsOneWidget);
  });

  testWidgets('fits a narrow phone at large text sizes', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final outlook in [null, waiting, ready]) {
      await _pump(
        tester,
        outlook: outlook,
        matches: _season(),
        textScale: 1.6,
      );
      expect(tester.takeException(), isNull);
    }
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required DbuSeasonOutlook? outlook,
  required List<MatchDetails> matches,
  bool canManage = true,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => MatchProgrammeRefreshNotifier(),
      child: BlocProvider(
        create: (_) => HomeCubit(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('da'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: SeasonOverHero(
                  matches: matches,
                  currentUser: _user(canManage),
                  outlook: outlook,
                  isChecking: outlook == null,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

List<MatchDetails> _season() {
  MatchDetails match(int id, int home, int away, bool isHome) {
    final date = DateTime(2026, 9, id);
    return MatchDetails(
      id: id,
      homeTeam: isHome ? 'Kopa IF' : 'Fremad',
      awayTeam: isHome ? 'Fremad' : 'Kopa IF',
      date: date,
      location: 'Kopa Stadion',
      createdAt: date,
      updatedAt: date,
      homeTeamScore: home,
      awayTeamScore: away,
      isHomeTeam: isHome,
    );
  }

  return [match(1, 2, 1, true), match(2, 1, 1, true), match(3, 3, 0, false)];
}

UserDetails _user(bool canManage) {
  final now = DateTime(2026, 1, 1);
  return UserDetails(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    isTeamOwner: canManage,
    roleId: 1,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}
