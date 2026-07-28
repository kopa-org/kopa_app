import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/match_details.dart';

void main() {
  test('post-match details start one hour after kampstart', () {
    final kickoff = DateTime(2026, 7, 28, 19);
    final match = MatchDetails(
      id: 1,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: kickoff,
      location: 'Kopa Stadion',
      createdAt: kickoff,
      updatedAt: kickoff,
    );

    expect(
        match.isPostMatchAt(kickoff.add(const Duration(minutes: 59))), isFalse);
    expect(match.isPostMatchAt(kickoff.add(const Duration(hours: 1))), isTrue);
  });

  test('final score is independent from post-match timing', () {
    final kickoff = DateTime(2026, 7, 28, 19);
    final match = MatchDetails(
      id: 1,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: kickoff,
      location: 'Kopa Stadion',
      createdAt: kickoff,
      updatedAt: kickoff,
    );

    expect(match.isPostMatchAt(kickoff.add(const Duration(hours: 2))), isTrue);
    expect(match.hasFinalScore, isFalse);
  });
}
