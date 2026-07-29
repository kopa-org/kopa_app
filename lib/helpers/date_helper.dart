import 'package:intl/intl.dart';

class DateHelper {
  static String getFormattedDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String getFormattedMatchDate(DateTime date) {
    final weekday = DateFormat('EEEE', 'da_DK').format(date);
    final capitalizedWeekday =
        '${weekday.substring(0, 1).toUpperCase()}${weekday.substring(1)}';
    return '$capitalizedWeekday ${DateFormat('d. MMMM', 'da_DK').format(date)}';
  }

  static String getFormattedShortWeekdayDate(DateTime date) {
    return DateFormat('EEE d. MMM', 'da_DK').format(date);
  }

  static String getFormattedShortDate(DateTime date) {
    return DateFormat('dd-MM').format(date);
  }

  static String getFormattedTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('HH:mm').format(date);
  }
}
