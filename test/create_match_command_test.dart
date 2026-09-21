import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/create_match_comand.dart';
import 'package:kopa/model/event_type.dart';

void main() {
  test('training creation sends only event fields', () {
    final date = DateTime(2026, 9, 21, 18, 30);
    final command = CreateMatchCommand(
      null,
      null,
      'Training Pitch',
      null,
      date,
      null,
      eventType: KopaEventType.training,
    );

    expect(command.toJson(), {
      'type': 'training',
      'location': 'Training Pitch',
      'date': date.toUtc().toIso8601String(),
    });
  });

  test('training creation includes a trimmed category when provided', () {
    final command = CreateMatchCommand(
      null,
      null,
      'Training Pitch',
      null,
      DateTime(2026, 9, 21, 18, 30),
      null,
      eventType: KopaEventType.training,
      category: '  Pasninger  ',
    );

    expect(command.toJson()['category'], 'Pasninger');
  });

  test('match creation remains the default payload', () {
    final command = CreateMatchCommand(
      'Kopa IF',
      'Fremad',
      'Kopa Stadion',
      null,
      DateTime(2026, 9, 21, 18),
      null,
    );

    expect(command.toJson()['type'], 'match');
    expect(command.toJson()['home_team'], 'Kopa IF');
    expect(command.toJson()['away_team'], 'Fremad');
  });
}
