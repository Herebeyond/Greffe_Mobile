import 'package:intl/intl.dart';

class AppDateFormatter {
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
  static final RegExp _timezoneSuffix = RegExp(r'[+-]\d{2}:\d{2}$');

  static String formatDateTime(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) return '';

    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) return rawValue;

    final hasTimeOrTimezone =
        rawValue.contains('T') || rawValue.endsWith('Z') || _timezoneSuffix.hasMatch(rawValue);
    final dateToFormat = hasTimeOrTimezone ? parsed.toLocal() : parsed;
    return _dateTimeFormat.format(dateToFormat);
  }
}