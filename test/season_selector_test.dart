import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kopa/component/card/all_games_card.dart';
import 'package:kopa/component/chip/match_result_badge.dart';
import 'package:kopa/cubits/match_programme_state.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/season_details.dart';
import 'package:kopa/component/season/season_selector.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('da_DK');
  });

  final active = _season(id: 3, name: 'Efterår 2026', start: DateTime(2026, 8));
  final previous = _season(
    id: 2,
    name: 'Forår 2026',
    start: DateTime(2026, 3),
    end: DateTime(2026, 7, 31),
  );
  final oldest = _season(
    id: 1,
    name: 'Efterår 2025',
    start: DateTime(2025, 8),
    end: DateTime(2026, 2, 28),
  );

  group('MatchProgrammeState', () {
    test('shows the active season until another one is picked', () {
      final state = MatchProgrammeState(seasons: [active, previous]);

      expect(state.selectedSeason, active);
      expect(state.isViewingPastSeason, isFalse);
    });

    test('flags a picked finished season as past', () {
      final state = MatchProgrammeState(
        seasons: [active, previous],
        selectedSeasonId: previous.id,
      );

      expect(state.selectedSeason, previous);
      expect(state.isViewingPastSeason, isTrue);
      expect(
        state.copyWith(selectedSeasonId: () => null).isViewingPastSeason,
        isFalse,
      );
    });
  });

  test('ownTeamResults counts results from the own team side', () {
    final results = ownTeamResults([
      _match(1, 'Kopa IF', 'Fremad', 3, 1),
      _match(2, 'Østerbro', 'Kopa IF', 2, 0, isHomeTeam: false),
      _match(3, 'Kopa IF', 'B.93', 1, 1),
      _match(4, 'Kopa IF', 'Valby', null, null),
    ], 'Kopa IF');

    expect(results, [
      MatchResultStatus.win,
      MatchResultStatus.loss,
      MatchResultStatus.draw,
    ]);
  });

  testWidgets('picker lists the active season first and returns the choice',
      (tester) async {
    SeasonDetails? picked;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          picked = await showSeasonPicker(
            context,
            seasons: [oldest, active, previous],
            selected: active,
          );
        },
        child: const Text('open'),
      ),
    )));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Vælg sæson'), findsOneWidget);
    expect(find.text('TIDLIGERE SÆSONER'), findsOneWidget);
    expect(find.text('Aktiv'), findsOneWidget);
    final names = ['Efterår 2026', 'Forår 2026', 'Efterår 2025'];
    final tops = [
      for (final name in names) tester.getTopLeft(find.text(name)).dy
    ];
    expect(tops, orderedEquals([...tops]..sort()));

    await tester.tap(find.text('Forår 2026'));
    await tester.pumpAndSettle();

    expect(picked, previous);
    expect(find.text('Vælg sæson'), findsNothing);
  });

  testWidgets('past season banner leads back to the current season',
      (tester) async {
    var backTapped = false;
    await tester.pumpWidget(_app(Column(
      children: [
        PastSeasonBanner(
          season: previous,
          onBackToCurrent: () => backTapped = true,
        ),
        SeasonResultSummary(
          matches: [
            _match(1, 'Kopa IF', 'Fremad', 3, 1),
            _match(2, 'Kopa IF', 'B.93', 0, 2),
          ],
          ownTeamName: 'Kopa IF',
        ),
      ],
    )));

    expect(find.text('Afsluttet sæson'), findsOneWidget);
    expect(find.text('Du ser kampe fra Mar 2026 – Jul 2026'), findsOneWidget);
    expect(find.text('Kampe'), findsOneWidget);

    await tester.tap(find.text('Til nuværende'));
    expect(backTapped, isTrue);
  });

  testWidgets('selector hides the chevron when there is nothing to switch to',
      (tester) async {
    await tester.pumpWidget(_app(
      SeasonSelectorButton(season: active, onTap: null),
    ));

    expect(find.text('Efterår 2026'), findsOneWidget);
    expect(find.text('· Aktiv'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.chevron_down), findsNothing);
  });
}

Widget _app(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[
        AppColors.light,
        AppTextStyles.light,
      ],
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

SeasonDetails _season({
  required int id,
  required String name,
  required DateTime start,
  DateTime? end,
}) {
  return SeasonDetails(
    id: id,
    teamId: 1,
    name: name,
    startsOn: start,
    endsOn: end,
    isActive: end == null,
  );
}

MatchDetails _match(
  int id,
  String homeTeam,
  String awayTeam,
  int? homeScore,
  int? awayScore, {
  bool isHomeTeam = true,
}) {
  final date = DateTime(2026, 4, id);
  return MatchDetails(
    id: id,
    homeTeam: homeTeam,
    awayTeam: awayTeam,
    date: date,
    location: 'Kopa Stadion',
    createdAt: date,
    updatedAt: date,
    homeTeamScore: homeScore,
    awayTeamScore: awayScore,
    isHomeTeam: isHomeTeam,
  );
}
