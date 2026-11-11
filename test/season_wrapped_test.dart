import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/home/missing_result_hero.dart';
import 'package:kopa/component/home/season_wrapped_teaser.dart';
import 'package:kopa/cubits/home_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/season_wrapped.dart';
import 'package:kopa/page/wrapped/season_wrapped_page.dart';
import 'package:kopa/page/wrapped/wrapped_settings_sheet.dart';
import 'package:kopa/page/wrapped/wrapped_slides.dart';
import 'package:kopa/tab/home_tab.dart';
import 'package:kopa/theme/app_theme.dart';

Map<String, dynamic> _json({List<String>? slides}) => {
      'available': true,
      'season': {'id': 7, 'name': 'Efterår 2026'},
      'team': {
        'title': 'Kopa IF',
        'played': 12,
        'wins': 7,
        'draws': 2,
        'losses': 3,
        'goals_for': 20,
        'goals_against': 14,
        'form': ['W', 'W', 'D', 'L', 'W'],
        'best_win_streak': 4,
        'match_ids': List.generate(12, (i) => i + 1),
      },
      'me': {
        'name': 'Jonas Petersen',
        'matches_played': 10,
        'goals': 5,
        'assists': 3,
        'training_percentage': 86.0,
        'players_with_more_matches': 2,
        'form_rank': 3,
        'form_players': 18,
      },
      'awards': {
        'goals': {
          'podium': [
            {'user_id': 2, 'user_name': 'Mads Kristensen', 'value': 7},
            {'user_id': 1, 'user_name': 'Jonas Petersen', 'value': 5},
            {'user_id': 3, 'user_name': 'Emil Rasmussen', 'value': 3},
          ],
          'team_goals': 20,
        },
        'assists': {
          'podium': [
            {'user_id': 3, 'user_name': 'Emil Rasmussen', 'value': 6},
            {'user_id': 2, 'user_name': 'Mads Kristensen', 'value': 4},
            {'user_id': 1, 'user_name': 'Jonas Petersen', 'value': 3},
          ],
          'duo': {
            'from_name': 'Emil Rasmussen',
            'to_name': 'Mads Kristensen',
            'goals': 4,
          },
        },
        'motm': {
          'podium': [
            {
              'user_id': 3,
              'user_name': 'Emil Rasmussen',
              'value': 4,
              'event_ids': [2, 5, 8, 11],
            },
          ],
          'voted_matches': 9,
        },
        'iron': {
          'podium': [
            {'user_id': 4, 'user_name': 'Frederik Lund', 'value': 12},
          ],
          'team_matches': 12,
        },
        'form': {
          'rows': [
            {
              'rank': 1,
              'user_id': 2,
              'user_name': 'Mads Kristensen',
              'total': 142
            },
            {
              'rank': 2,
              'user_id': 3,
              'user_name': 'Emil Rasmussen',
              'total': 131
            },
            {
              'rank': 3,
              'user_id': 1,
              'user_name': 'Jonas Petersen',
              'total': 128
            },
          ],
          'me': {
            'rank': 3,
            'user_id': 1,
            'user_name': 'Jonas Petersen',
            'total': 128
          },
        },
        'fines': {
          'podium': [
            {'user_id': 5, 'user_name': 'Kasper Holm', 'value': 425.0},
          ],
          'total': 2150.0,
        },
        'cards': {
          'podium': [
            {
              'user_id': 6,
              'user_name': 'Nikolaj Berg',
              'value': 5,
              'yellow': 4,
              'red': 1,
            },
          ],
        },
        'lantern': {
          'last': {
            'rank': 18,
            'user_id': 9,
            'user_name': 'Oliver Sand',
            'total': 12
          },
          'players': 18,
        },
      },
      'categories': [
        for (final key in SeasonWrapped.optionalCategories)
          {
            'key': key,
            'available': key != 'fines',
            'enabled': key != 'lantern',
            'count': 3,
          },
      ],
      'slides': slides ??
          [
            'intro',
            'team',
            'you',
            'form',
            'goals',
            'assists',
            'motm',
            'iron',
            'cards',
            'lantern',
            'outro',
          ],
    };

Widget _app(Widget child) => BlocProvider(
      create: (_) => HomeCubit(),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('da'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );

MatchDetails _match(int id, DateTime date, {int? home, int? away}) =>
    MatchDetails(
      id: id,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: date,
      location: 'Kopa Stadion',
      createdAt: date,
      updatedAt: date,
      homeTeamScore: home,
      awayTeamScore: away,
      isHomeTeam: true,
    );

void main() {
  test('parses the wrapped and shortens names', () {
    final wrapped = SeasonWrapped.fromJson(_json());

    expect(wrapped.seasonId, 7);
    expect(wrapped.team.form, ['W', 'W', 'D', 'L', 'W']);
    expect(wrapped.me.firstName, 'Jonas');
    expect(wrapped.awards.goals.first.shortName, 'Mads K.');
    expect(wrapped.awards.motm.first.eventIds, [2, 5, 8, 11]);
    expect(wrapped.awards.duo?.goals, 4);
    expect(wrapped.awards.cards.first.red, 1);
    expect(wrapped.disabledCategories, ['lantern']);
  });

  test('only played matches without a score block the Wrapped', () {
    final now = DateTime(2026, 11, 11, 12);
    final matches = [
      _match(1, now.subtract(const Duration(days: 9)), home: 2, away: 1),
      _match(2, now.subtract(const Duration(days: 2))),
      _match(3, now.subtract(const Duration(days: 5))),
      // Kicked off an hour ago: still being played.
      _match(4, now.subtract(const Duration(hours: 1))),
    ];

    expect(matchesMissingResult(matches, now).map((m) => m.id), [2, 3]);
  });

  testWidgets('missing result asks leaders to enter it and players to wait',
      (tester) async {
    var tapped = false;
    final match = _match(2, DateTime(2026, 11, 2, 14));

    await tester.pumpWidget(_app(Scaffold(
      body: MissingResultHero(
        match: match,
        otherMissing: 1,
        canEnterResult: true,
        onEnterResult: () => tapped = true,
      ),
    )));

    expect(find.text('Der mangler et resultat'), findsOneWidget);
    expect(find.text('1 kamp mere mangler resultat'), findsOneWidget);
    await tester.tap(find.text('Indtast resultat'));
    expect(tapped, isTrue);

    await tester.pumpWidget(_app(Scaffold(
      body: MissingResultHero(
        match: match,
        otherMissing: 0,
        canEnterResult: false,
        onEnterResult: () {},
      ),
    )));
    expect(find.text('Indtast resultat'), findsNothing);
    expect(
      find.text(
          'Holdlederen indtaster resultatet, så er jeres Season Wrapped klar.'),
      findsOneWidget,
    );
  });

  testWidgets('teaser opens the Wrapped or skips it', (tester) async {
    var opened = false;
    var skipped = false;
    await tester.pumpWidget(_app(Scaffold(
      body: SeasonWrappedTeaser(
        onOpen: () => opened = true,
        onSkip: () => skipped = true,
      ),
    )));

    expect(find.text('Jeres sæson er pakket ind'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('season_wrapped_teaser')));
    await tester.tap(find.text('Spring over – gå til næste sæson'));
    expect(opened, isTrue);
    expect(skipped, isTrue);
  });

  testWidgets('the story taps through every slide without overflowing',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final wrapped = SeasonWrapped.fromJson(_json());

    await tester.pumpWidget(_app(SeasonWrappedPage(
      wrapped: wrapped,
      teamId: 1,
      currentUserId: 1,
      canCustomize: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Season Wrapped · 1/11'), findsOneWidget);
    expect(find.byKey(const ValueKey('wrapped_customize')), findsOneWidget);

    final expectations = <String>[
      'HOLDET I TAL',
      'DIN SÆSON, JONAS',
      'KOPA-FORM',
      'MÅLKONGEN',
      'ASSISTKONGEN',
      'KAMPENS SPILLER',
      'JERNMANDEN',
      'KORTKONGEN',
      'DEN RØDE LANTERNE',
      'Sæsonens priser',
    ];
    for (final text in expectations) {
      await tester.tap(find.byKey(const ValueKey('wrapped_next')));
      await tester.pumpAndSettle();
      expect(find.text(text), findsWidgets, reason: text);
      expect(tester.takeException(), isNull, reason: text);
    }

    expect(find.byKey(const ValueKey('wrapped_next')), findsNothing);
    expect(find.text('Videre til næste sæson'), findsOneWidget);
    // The fine king is not on the shareable card unless its slide is shown.
    expect(find.text('Bødekongen'), findsNothing);
  });

  testWidgets('assists slide shows the top three with or without a duo',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final withDuo in [true, false]) {
      // Round-trip through JSON so the maps are as loose as server data.
      final json = jsonDecode(jsonEncode(_json())) as Map<String, dynamic>;
      if (!withDuo) json['awards']['assists']['duo'] = null;
      await tester.pumpWidget(_app(Scaffold(
        body: WrappedSlide(
          slide: 'assists',
          wrapped: SeasonWrapped.fromJson(json),
          currentUserId: 1,
        ),
      )));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('FLEST OPLÆG'), findsOneWidget);
      expect(find.text('Emil R.'), findsWidgets);
      expect(find.text('Jonas P.'), findsOneWidget);
      expect(find.text('SÆSONENS MAKKERPAR'),
          withDuo ? findsOneWidget : findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('settings lock categories without data and save the rest',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final wrapped = SeasonWrapped.fromJson(_json());
    List<String>? saved;
    late bool result;

    await tester.pumpWidget(_app(Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            result = await showWrappedSettingsSheet(
              context,
              teamId: 1,
              wrapped: wrapped,
              save: (_, disabled) async => saved = disabled,
            );
          },
          child: const Text('open'),
        ),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Ikke nok data i denne sæson'), findsOneWidget);
    final fines = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('wrapped_category_fines')),
    );
    expect(fines.onChanged, isNull);

    await tester.tap(find.byKey(const ValueKey('wrapped_category_cards')));
    await tester.tap(find.byKey(const ValueKey('wrapped_category_lantern')));
    await tester.pump();
    await tester.tap(find.text('Gem'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(saved, ['cards']);
  });
}
