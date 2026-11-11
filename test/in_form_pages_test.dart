import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/page/in_form/in_form_page.dart';
import 'package:kopa/page/in_form/in_form_player_page.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('da_DK');
  });

  testWidgets('league table fits a narrow phone with large numbers',
      (tester) async {
    _phone(tester);
    InFormLeaderboardRow? tapped;
    await tester.pumpWidget(_app(SingleChildScrollView(
      child: InFormLeagueTable(
        currentUserId: 2,
        onPlayerTap: (row) => tapped = row,
        rows: const [
          InFormLeaderboardRow(
            rank: 1,
            userId: 1,
            userName: 'Christopher Alexander Vestergaard',
            position: 'defensive_midfield',
            rankChange: 2,
            latestRound: 22.5,
            pointsToFirst: 0,
            total: 1234.5,
          ),
          InFormLeaderboardRow(
            rank: 2,
            userId: 2,
            userName: 'Tobias',
            position: 'striker',
            rankChange: -4,
            latestRound: -3.5,
            pointsToFirst: 1100.5,
            total: 134,
          ),
          InFormLeaderboardRow(
            rank: 3,
            userId: 3,
            userName: 'Peter',
            position: null,
            rankChange: 0,
            latestRound: 0,
            pointsToFirst: 1200,
            total: 34.5,
          ),
        ],
      ),
    )));

    expect(find.text('Til nr. 1'), findsOneWidget);
    expect(find.text('-1100.5'), findsOneWidget);
    expect(find.text('+22.5'), findsOneWidget);
    expect(find.text('4'), findsOneWidget); // ▼4
    await tester.tap(find.text('Tobias'));
    expect(tapped?.userId, 2);
  });

  testWidgets('player page shows matches, details by category and editing',
      (tester) async {
    _phone(tester, height: 1800);
    await tester.pumpWidget(_app(InFormPlayerPage(
      teamId: 1,
      period: InFormPeriod.rollingThreeMonths,
      row: const InFormLeaderboardRow(
        rank: 2,
        userId: 2,
        userName: 'Tobias',
        position: 'striker',
        rankChange: 1,
        latestRound: 16.5,
        pointsToFirst: 8,
        total: 26.5,
      ),
      loader: ({
        required int teamId,
        required int playerId,
        required InFormPeriod period,
        int? seasonId,
      }) async =>
          // Round-trip so nested maps have the same types as API responses.
          InFormPlayerBreakdown.fromJson(
              jsonDecode(jsonEncode(_breakdownJson)) as Map<String, dynamic>),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Boldklubben Meget Lange Holdnavn IF'), findsOneWidget);
    expect(find.text('2–1'), findsOneWidget);
    expect(
      find.text('Spillede som Målmand (ændret for denne kamp)'),
      findsOneWidget,
    );
    // The latest match is expanded and grouped by category.
    expect(find.text('OFFENSIV'), findsOneWidget);
    expect(find.text('DEFENSIV'), findsOneWidget);
    expect(find.text('Modstander scorede x1'), findsOneWidget);

    await tester.ensureVisible(find.text('Skift position'));
    await tester.tap(find.text('Skift position'));
    await tester.pumpAndSettle();
    expect(find.text('Position i kampen'), findsOneWidget);
    // Players without the owner role only see the position picker.
    expect(find.text('Selvmål'), findsNothing);
  });
}

void _phone(WidgetTester tester, {double height = 740}) {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('da'),
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

const _breakdownJson = <String, dynamic>{
  'user_id': 2,
  'period': 'rolling_3_months',
  'total': 26.5,
  'can_edit_position': true,
  'can_edit_match_data': false,
  'summary': {
    'matches': 12,
    'goals': 14,
    'assists': 10,
    'yellow_cards': 3,
    'red_cards': 1,
    'motm': 4,
    'average': 12.4,
  },
  'matches': [
    {
      'event_id': 7,
      'date': '2026-05-01T12:00:00Z',
      'opponent': 'Boldklubben Meget Lange Holdnavn IF',
      'is_home_team': false,
      'team_goals': 2,
      'opponent_goals': 1,
      'result': 'win',
      'position': 'goalkeeper',
      'stats': {'position': 'goalkeeper', 'goals': 1},
      'override': {'position': 'goalkeeper'},
      'total': 16.5,
      'entries': [
        {
          'id': 1,
          'event_id': 7,
          'rule': 'goal',
          'category': 'offensive',
          'description': 'Mål x1',
          'value': 10,
          'awarded_on': '2026-05-01',
        },
        {
          'id': 2,
          'event_id': 7,
          'rule': 'opponent_scored',
          'category': 'defensive',
          'description': 'Modstander scorede x1',
          'value': -2,
          'awarded_on': '2026-05-01',
        },
      ],
    },
    {
      'event_id': 6,
      'date': '2026-04-20T12:00:00Z',
      'opponent': 'Tyrkiet',
      'is_home_team': true,
      'team_goals': 0,
      'opponent_goals': 1,
      'result': 'loss',
      'position': 'striker',
      'stats': {'position': 'striker'},
      'override': {},
      'total': -4,
      'entries': [],
    },
  ],
  'bonuses': [],
  'entries': [],
};
