import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/avatar/team_avatar.dart';
import 'package:kopa/component/avatar/team_badge_label.dart';

void main() {
  test('uses the team number instead of brackets', () {
    expect(teamInitials('Skjold (7)'), 'S7');
    expect(teamInitials('Skjold 7'), 'S7');
  });

  test('falls back to the first letters of the first two words', () {
    expect(teamInitials('FC Ryparken'), 'FR');
    expect(teamInitials('Copenfalster FF'), 'CF');
    expect(teamInitials('Lersøparken'), 'L');
    expect(teamInitials('  '), '');
  });

  test('matches team names that differ only in brackets, case and spacing',
      () {
    expect(teamNamesMatch('Skjold (7)', 'Skjold 7'), isTrue);
    expect(teamNamesMatch('  skjold   7 ', 'SKJOLD (7)'), isTrue);
    expect(teamNamesMatch('Skjold 7', 'Skjold 8'), isFalse);
    expect(teamNamesMatch('Skjold', 'Skjold 7'), isFalse);
  });
}
