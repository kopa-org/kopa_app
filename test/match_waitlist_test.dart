import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/match_details.dart';

void main() {
  Map<String, dynamic> attendance(
    int id,
    int userId, {
    required bool attending,
    bool? selected,
    required String updatedAt,
  }) =>
      {
        'id': id,
        'user_details': {
          'id': userId,
          'name': 'Player $userId',
          'email': 'p$userId@example.com',
          'is_team_owner': false,
          'role_id': 2,
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-01T00:00:00Z',
        },
        'is_attending': attending,
        'is_selected': selected,
        'created_at': updatedAt,
        'updated_at': updatedAt,
      };

  MatchDetails match(
      {int? maxSignups, String mode = 'first_come_first_served'}) {
    return MatchDetails.fromJson({
      'id': 1,
      'type': 'MATCH',
      'team_id': 1,
      'date': '2026-12-01T12:00:00Z',
      'meeting_time': null,
      'location': 'Stadium',
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
      'rsvp_selection_mode': mode,
      'max_signups': maxSignups,
      'attendance_details_list': [
        attendance(1, 10,
            attending: true, selected: true, updatedAt: '2026-11-01T10:00:00Z'),
        attendance(2, 11, attending: true, updatedAt: '2026-11-01T12:00:00Z'),
        attendance(3, 12, attending: true, updatedAt: '2026-11-01T11:00:00Z'),
        attendance(4, 13, attending: false, updatedAt: '2026-11-01T09:00:00Z'),
      ],
    });
  }

  test('waitlist is ordered by signup time when a limit is set', () {
    final details = match(maxSignups: 1);

    expect(details.usesWaitlist, isTrue);
    expect(details.waitlist.map((a) => a.userDetails.id), [12, 11]);
    expect(details.waitlistPosition(12), 1);
    expect(details.waitlistPosition(11), 2);
    expect(details.waitlistPosition(10), isNull);
    expect(details.waitlistPosition(13), isNull);
  });

  test('no waitlist without a limit or in leader selection mode', () {
    expect(match().waitlist, isEmpty);
    expect(
      match(maxSignups: 1, mode: 'team_leader_selection').waitlist,
      isEmpty,
    );
  });
}
