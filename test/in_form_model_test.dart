import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/in_form.dart';

void main() {
  test('parses leaderboard decimals and rank movement', () {
    final leaderboard = InFormLeaderboard.fromJson({
      'period': 'rolling_3_months',
      'position': null,
      'rows': [
        {
          'rank': 1,
          'user_id': 9,
          'user_name': 'Mads',
          'position': 'midfield',
          'rank_change': 2,
          'latest_round': 7.5,
          'points_to_first': 0,
          'total': 51.5,
        }
      ],
    });

    expect(leaderboard.rows.single.latestRound, 7.5);
    expect(leaderboard.rows.single.total, 51.5);
    expect(leaderboard.rows.single.rankChange, 2);
  });

  test('parses player breakdown entries', () {
    final breakdown = InFormPlayerBreakdown.fromJson({
      'user_id': 4,
      'period': 'all_time',
      'total': 12.5,
      'entries': [
        {
          'id': 1,
          'event_id': 7,
          'rule': 'goal',
          'description': 'Mål',
          'value': 5,
          'awarded_on': '2026-05-01',
        },
        {
          'id': 2,
          'event_id': null,
          'rule': 'goal_streak_2',
          'description': 'Målstreak x2',
          'value': 2.5,
          'awarded_on': '2026-05-01',
        },
      ],
    });

    expect(breakdown.total, 12.5);
    expect(breakdown.entries.length, 2);
    expect(breakdown.entries.first.rule, 'goal');
    expect(breakdown.entries.first.value, 5);
    expect(breakdown.entries.last.eventId, isNull);
    expect(breakdown.entries.last.value, 2.5);
  });
}
