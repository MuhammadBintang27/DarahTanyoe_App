import 'package:intl/intl.dart';

String formatDateTime(String rawDate) {
  DateTime dateTime = DateTime.parse(rawDate);
  return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
}
