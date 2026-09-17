import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/team_details.dart';

void main() {
  test('team and match models default to first come, first served', () {
    final now = DateTime(2026, 9, 17);
    final team = TeamDetails(
      id: 1,
      title: 'Kopa FC',
      createdAt: now,
      updatedAt: now,
    );
    final match = MatchDetails(
      id: 1,
      date: now,
      location: 'Stadium',
      createdAt: now,
      updatedAt: now,
    );

    expect(team.rsvpSelectionMode, TeamDetails.firstComeFirstServed);
    expect(match.rsvpSelectionMode, MatchDetails.firstComeFirstServed);
    expect(match.usesTeamLeaderSelection, isFalse);
  });

  test('leader selection mode is represented by the match model', () {
    final now = DateTime(2026, 9, 17);
    final match = MatchDetails(
      id: 1,
      date: now,
      location: 'Stadium',
      createdAt: now,
      updatedAt: now,
      rsvpSelectionMode: MatchDetails.teamLeaderSelection,
    );

    expect(match.usesTeamLeaderSelection, isTrue);
  });
}
