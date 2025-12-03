// lib/utils/date_extensions.dart
import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String toShortDateString() {
    return DateFormat('MMM dd, yyyy').format(this);
  }
}