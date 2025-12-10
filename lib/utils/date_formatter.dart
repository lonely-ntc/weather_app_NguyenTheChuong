import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateFormatter {
  static String formatFullDate(DateTime date, String langCode) {
    initializeDateFormatting(langCode);
    return DateFormat.yMMMMEEEEd(langCode).format(date);
  }

  static String formatDayName(DateTime date, String langCode) {
    initializeDateFormatting(langCode);
    return DateFormat('EEEE', langCode).format(date);
  }
}