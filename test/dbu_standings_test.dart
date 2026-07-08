import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/dbu_standings.dart';

void main() {
  test('parses synchronized DBU standings for the placement card', () {
    final standings = DbuStandings.fromJson({
      'poolId': 489363,
      'currentTeamId': 449594,
      'poolTeams': [
        {
          'dbu_team_id': 449594,
          'name': 'Skjold 6',
          'logo_url': 'https://file.dbu.dk/images/club/1581/skjold.png',
        },
      ],
      'rows': [
        {
          'position': 6,
          'dbuTeamId': 449594,
          'teamName': 'Skjold 6',
          'matchesPlayed': 8,
          'wins': 3,
          'draws': 0,
          'losses': 5,
          'goalsFor': 22,
          'goalsAgainst': 25,
          'points': 9,
          'boundaryAfter': 'solid',
        },
      ],
    });

    expect(standings.poolId, 489363);
    expect(standings.currentTeamId, 449594);
    expect(standings.rows.single.teamName, 'Skjold 6');
    expect(standings.rows.single.points, 9);
    expect(standings.rows.single.boundaryAfter, 'solid');
    expect(
      standings.rows.single.logoUrl,
      'https://file.dbu.dk/images/club/1581/skjold.png',
    );
  });
}
