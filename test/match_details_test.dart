import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/match_details.dart';

void main() {
  test('parses API event timestamps as local instants', () {
    final match = MatchDetails.fromJson({
      'id': 1,
      'type': 'MATCH',
      'home_team': 'Kopa IF',
      'away_team': 'Fremad',
      'date': '2026-08-17T20:00:00Z',
      'meeting_time': '18:30:00',
      'location': 'Kopa Stadion',
      'created_at': '2026-08-01T10:00:00Z',
      'updated_at': '2026-08-01T10:00:00Z',
    });

    expect(match.date, DateTime.parse('2026-08-17T20:00:00Z').toLocal());
    expect(match.date.isUtc, isFalse);
    expect(match.meetingTime, DateTime.utc(1970, 1, 1, 18, 30));
  });
}
