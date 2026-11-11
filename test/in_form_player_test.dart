import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/in_form_player_cubit.dart';
import 'package:kopa/model/in_form.dart';

void main() {
  test('parses per-match breakdown, summary and edit permissions', () {
    final breakdown = InFormPlayerBreakdown.fromJson(_breakdownJson());

    expect(breakdown.canEditPosition, isTrue);
    expect(breakdown.canEditMatchData, isFalse);
    expect(breakdown.summary.goals, 1);
    expect(breakdown.summary.average, 16.5);

    final match = breakdown.matches.single;
    expect(match.opponent, 'Away FC');
    expect(match.result, InFormMatchResult.win);
    expect(match.position, 'goalkeeper');
    expect(match.override.position, 'goalkeeper');
    expect(match.stats.goals, 1);
    expect(match.entries.first.category, 'offensive');
    expect(breakdown.bonuses.single.rule, 'monthly_votes');
  });

  test('older payloads without matches still parse', () {
    final breakdown = InFormPlayerBreakdown.fromJson({'total': 3});
    expect(breakdown.matches, isEmpty);
    expect(breakdown.canEditPosition, isFalse);
  });

  test('parses the points system per position', () {
    final system = InFormPointsSystem.fromJson({
      'positions': [
        {
          'position': 'striker',
          'rules': [
            {
              'rule': 'goal',
              'label': 'Scoring',
              'value': 3,
              'category': 'offensive',
            },
          ],
        },
      ],
    });
    expect(system.rulesByPosition['striker']!.single.value, 3);
  });

  group('InFormPlayerCubit', () {
    test('expands the latest match and reloads after an update', () async {
      var loads = 0;
      Map<String, Object?>? sent;
      final cubit = InFormPlayerCubit(
        teamId: 1,
        playerId: 2,
        period: InFormPeriod.allTime,
        loader: ({
          required int teamId,
          required int playerId,
          required InFormPeriod period,
          int? seasonId,
        }) async {
          loads++;
          return InFormPlayerBreakdown.fromJson(_breakdownJson());
        },
        updater: ({
          required int eventId,
          required int playerId,
          required Map<String, Object?> changes,
        }) async {
          sent = changes;
        },
      );

      await cubit.load();
      expect(cubit.state.status, InFormPlayerStatus.loaded);
      expect(cubit.state.expandedEventIds, {7});

      cubit.toggleMatch(7);
      expect(cubit.state.expandedEventIds, isEmpty);

      final saved = await cubit.updateMatch(7, {'position': null});
      expect(saved, isTrue);
      expect(sent, {'position': null});
      expect(loads, 2);
      // Reloading keeps the user's expansion choice.
      expect(cubit.state.expandedEventIds, isEmpty);
    });

    test('reports a failed update without reloading', () async {
      var loads = 0;
      final cubit = InFormPlayerCubit(
        teamId: 1,
        playerId: 2,
        period: InFormPeriod.allTime,
        loader: ({
          required int teamId,
          required int playerId,
          required InFormPeriod period,
          int? seasonId,
        }) async {
          loads++;
          return InFormPlayerBreakdown.fromJson(_breakdownJson());
        },
        updater: ({
          required int eventId,
          required int playerId,
          required Map<String, Object?> changes,
        }) async =>
            throw Exception('nope'),
      );

      await cubit.load();
      expect(await cubit.updateMatch(7, {'own_goals': 1}), isFalse);
      expect(loads, 1);
    });
  });
}

Map<String, dynamic> _breakdownJson() => {
      'user_id': 2,
      'period': 'all_time',
      'total': 26.5,
      'can_edit_position': true,
      'can_edit_match_data': false,
      'summary': {
        'matches': 1,
        'goals': 1,
        'assists': 0,
        'yellow_cards': 0,
        'red_cards': 0,
        'motm': 0,
        'average': 16.5,
      },
      'matches': [
        {
          'event_id': 7,
          'date': '2026-05-01T12:00:00Z',
          'opponent': 'Away FC',
          'is_home_team': true,
          'team_goals': 2,
          'opponent_goals': 0,
          'result': 'win',
          'position': 'goalkeeper',
          'stats': {'position': 'goalkeeper', 'goals': 1, 'motm': false},
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
          ],
        },
      ],
      'bonuses': [
        {
          'id': 3,
          'event_id': null,
          'rule': 'monthly_votes',
          'category': 'bonus',
          'description': 'Flest MOTM-stemmer i måneden',
          'value': 10,
          'awarded_on': '2026-05-31',
        },
      ],
      'entries': [],
    };
