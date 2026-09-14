DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

String dateKey(DateTime value) {
  final d = dateOnly(value);
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) {
    throw FormatException('Invalid date key: $key');
  }
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

int daysBetween(DateTime start, DateTime end) =>
    dateOnly(end).difference(dateOnly(start)).inDays;

Iterable<DateTime> daysInRange(DateTime start, DateTime endInclusive) sync* {
  var cursor = dateOnly(start);
  final last = dateOnly(endInclusive);
  while (!cursor.isAfter(last)) {
    yield cursor;
    cursor = cursor.add(const Duration(days: 1));
  }
}
