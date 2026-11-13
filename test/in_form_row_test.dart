import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/statistics.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';

void main() {
  test('reads the exact In-form total, halves included', () {
    final row = InFormRow.fromJson(
      {'user_id': 7, 'user_name': 'Jonas', 'total': 12.5, 'points': 13},
    );

    expect(row.total, 12.5);
    // Same formatting as the Player+ In-form leaderboard.
    expect(inFormNumber(row.total), '12.5');
  });

  test('falls back to the rounded points from older backends', () {
    final row = InFormRow.fromJson(
      {'user_id': 7, 'user_name': 'Jonas', 'points': 14},
    );

    expect(row.total, 14);
    expect(inFormNumber(row.total), '14');
  });
}
