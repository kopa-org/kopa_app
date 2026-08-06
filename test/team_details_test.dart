import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/team_details.dart';

void main() {
  test('parses default meeting offset from team details', () {
    final team = TeamDetails.fromJson({
      'id': 1,
      'title': 'Kopa FC',
      'player_count': 11,
      'default_meeting_offset_minutes': 30,
      'created_at': '2026-08-06T12:00:00Z',
      'updated_at': '2026-08-06T12:00:00Z',
    });

    expect(team.defaultMeetingOffsetMinutes, 30);
  });
}
