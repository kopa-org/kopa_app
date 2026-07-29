import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kopa/helpers/date_helper.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('da_DK');
  });

  test('formats imported DBU match timestamps without local offset conversion',
      () {
    expect(
      DateHelper.getFormattedTime(DateTime.utc(2026, 8, 17, 20)),
      '20:00',
    );
    expect(
      DateHelper.getFormattedShortWeekdayDate(
        DateTime.utc(2026, 8, 17, 20),
      ),
      'man. 17. aug.',
    );
  });
}
