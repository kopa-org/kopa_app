import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kopa/component/chip/match_result_badge.dart';
import 'package:kopa/cubits/statistics_cubit.dart';
import 'package:kopa/cubits/statistics_state.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/page/statistics/team_stats_card.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('da_DK');
  });

  testWidgets('team card shows form newest on the right and the totals',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(SingleChildScrollView(
      child: TeamStatsCard(
        stats: StatisticsResponse.fromJson(_statsJson(
          // The API lists the newest match first.
          form: [1, 0, -1],
          wins: 8,
          draws: 3,
          losses: 3,
          goalsFor: 24,
          goalsAgainst: 15,
          average: 1.94,
        )),
      ),
    )));

    final letters = ['T', 'U', 'V'];
    final lefts = [
      for (final letter in letters) tester.getTopLeft(find.text(letter)).dx,
    ];
    expect(lefts, orderedEquals([...lefts]..sort()));
    expect(find.bySemanticsLabel('Sejr'), findsOneWidget);
    expect(find.text('Seneste 3 · nyeste til højre'), findsOneWidget);

    expect(find.text('14'), findsOneWidget);
    expect(find.text('Vundet'), findsOneWidget);
    expect(find.text('+9'), findsOneWidget);
    expect(find.text('1,9'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('team card explains an empty form', (tester) async {
    await tester.pumpWidget(_app(TeamStatsCard(
      stats: StatisticsResponse.fromJson(_statsJson(form: [])),
    )));

    expect(find.text('Ingen spillede kampe endnu.'), findsOneWidget);
    expect(find.byType(ResultLetterBadge), findsNothing);
  });

  test('result letters follow the language', () {
    expect(MatchResultStatus.fromForm(1).letter, 'V');
    expect(MatchResultStatus.fromForm(0).letter, 'U');
    expect(MatchResultStatus.fromForm(-1).letter, 'T');
  });

  test('cubit loads the active season, then a picked past season', () async {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example.test/api');
    FlutterSecureStorage.setMockInitialValues({'token': 'test-session'});
    final requested = <Uri>[];
    final client = MockClient((request) async {
      requested.add(request.url);
      if (request.url.path.endsWith('/seasons')) {
        return http.Response(
          jsonEncode({
            'seasons': [
              _seasonJson(id: 2, name: 'Efterår 2026', active: true),
              _seasonJson(id: 1, name: 'Forår 2026', active: false),
            ],
          }),
          200,
        );
      }
      final isPast = request.url.queryParameters['season_id'] == '1';
      return http.Response(
        jsonEncode({'statistics': _statsJson(wins: isPast ? 12 : 8)}),
        200,
      );
    });

    await http.runWithClient(() async {
      final cubit = StatisticsCubit(teamId: 7);
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state.status, StatisticsStatus.loaded);
      expect(cubit.state.stats!.club.wins, 8);
      expect(cubit.state.selectedSeason!.name, 'Efterår 2026');
      expect(cubit.state.isViewingPastSeason, isFalse);

      await cubit.selectSeason(cubit.state.seasons.last);
      expect(cubit.state.isViewingPastSeason, isTrue);
      expect(cubit.state.stats!.club.wins, 12);
      expect(
        requested.where((url) => url.path.endsWith('/statistics/7')).last,
        isA<Uri>().having(
          (url) => url.queryParameters['season_id'],
          'season_id',
          '1',
        ),
      );

      await cubit.showActiveSeason();
      expect(cubit.state.isViewingPastSeason, isFalse);
      expect(cubit.state.stats!.club.wins, 8);
    }, () => client);
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
    home: Scaffold(body: child),
  );
}

Map<String, dynamic> _seasonJson({
  required int id,
  required String name,
  required bool active,
}) {
  return {
    'id': id,
    'team_id': 7,
    'name': name,
    'starts_on': active ? '2026-08-01' : '2026-03-01',
    'ends_on': active ? null : '2026-07-31',
    'is_active': active,
  };
}

Map<String, dynamic> _statsJson({
  List<int> form = const [1, 1, 0],
  int wins = 0,
  int draws = 0,
  int losses = 0,
  int goalsFor = 0,
  int goalsAgainst = 0,
  double? average,
}) {
  return {
    'player': {'name': 'Test Spiller'},
    'club': {
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'goals_for': goalsFor,
      'goals_against': goalsAgainst,
      'last_five_matches_form': form,
    },
    'in_form_rows': <dynamic>[],
    'leaderboards': <String, dynamic>{},
    'team_metrics': {
      'team_average_points': average,
      'team_form': form,
      'goals_scored': goalsFor,
      'goals_conceded': goalsAgainst,
    },
  };
}
