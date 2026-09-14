import 'package:cyclea/domain/dates.dart';

class PeriodSpan {
  const PeriodSpan({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  int get lengthDays => daysBetween(start, end) + 1;

  bool contains(DateTime date) {
    final d = dateOnly(date);
    return !d.isBefore(start) && !d.isAfter(end);
  }
}
