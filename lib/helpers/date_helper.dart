import 'package:intl/intl.dart';
import 'package:kopa/l10n/current_l10n.dart';

class DateHelper {
  static String get _locale => currentL10n.localeName;

  static String _capitalized(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

  static String getFormattedDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String getFormattedMatchDate(DateTime date) {
    final weekday = _capitalized(DateFormat('EEEE', _locale).format(date));
    final dayPattern = _locale == 'da' ? 'd. MMMM' : 'd MMMM';
    return '$weekday ${DateFormat(dayPattern, _locale).format(date)}';
  }

  static String getFormattedShortWeekdayDate(DateTime date) {
    final pattern = _locale == 'da' ? 'EEE d. MMM' : 'EEE d MMM';
    return DateFormat(pattern, _locale).format(date);
  }

  /// Month name with the first letter capitalized, such as "Marts".
  static String getMonthName(DateTime date) {
    return _capitalized(DateFormat('MMMM', _locale).format(date));
  }

  /// Short month name with the first letter capitalized, such as "Okt".
  static String getShortMonthName(DateTime date) {
    final month = DateFormat('MMM', _locale).format(date).replaceAll('.', '');
    return _capitalized(month);
  }

  /// Full date such as "1. marts 2026" or "1 March 2026".
  static String getFormattedLongDate(DateTime date) {
    final pattern = _locale == 'da' ? 'd. MMMM y' : 'd MMMM y';
    return DateFormat(pattern, _locale).format(date);
  }

  static String getFormattedShortDate(DateTime date) {
    return DateFormat('dd-MM').format(date);
  }

  static String getFormattedTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('HH:mm').format(date);
  }
}
