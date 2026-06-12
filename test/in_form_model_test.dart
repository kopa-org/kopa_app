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

  test('serializes canonical performance fields', () {
    const performance = InFormPerformance(
      userId: 4,
      position: 'goalkeeper',
      played: true,
      penaltiesSaved: 1,
      motmVotes: 2,
    );

    final json = performance.toJson();
    expect(json['user_id'], 4);
    expect(json['played'], isTrue);
    expect(json['penalties_saved'], 1);
    expect(json['motm_votes'], 2);
    expect(json.containsKey('position'), isFalse);
  });
}
