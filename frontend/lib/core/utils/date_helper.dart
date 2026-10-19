import 'package:intl/intl.dart';

class DateHelper {
  static String time(DateTime d) => DateFormat('HH.mm').format(d);
  static String date(DateTime d) => DateFormat('d MMM yyyy').format(d);
}
