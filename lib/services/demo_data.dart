import 'dart:math';

import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/flow_level.dart';

class DemoData {
  static List<DailyLog> generate({DateTime? now, int seed = 42}) {
    final today = dateOnly(now ?? DateTime.now());
    final random = Random(seed);
    final currentDayInCycle = 12;
    var cursor = today.subtract(Duration(days: currentDayInCycle - 1));
    final periodStarts = <DateTime>[cursor];
    const priorLengths = [30, 26, 29, 27, 31, 28, 25];
    for (final length in priorLengths) {
      cursor = cursor.subtract(Duration(days: length));
      periodStarts.add(cursor);
    }
    periodStarts.sort();

    final logs = <String, DailyLog>{};
    final stamp = DateTime.utc(2020, 1, 1);

    for (var i = 0; i < periodStarts.length; i++) {
      final start = periodStarts[i];
      final periodLength = 4 + random.nextInt(3);
      final nextStart = i + 1 < periodStarts.length
          ? periodStarts[i + 1]
          : start.add(const Duration(days: 28));
      final cycleLen = daysBetween(start, nextStart);

      for (var p = 0; p < periodLength; p++) {
        final day = start.add(Duration(days: p));
        if (day.isAfter(today)) continue;
        final flow = switch (p) {
          0 => FlowLevel.heavy,
          1 => FlowLevel.medium,
          _ when p == periodLength - 1 => FlowLevel.light,
          _ => random.nextBool() ? FlowLevel.medium : FlowLevel.light,
        };
        _merge(
          logs,
          DailyLog(
            date: day,
            isPeriod: true,
            flow: flow,
            symptomIds: {
              'cramps',
              if (p < 2) 'fatigue',
              if (p == 0) 'back_pain',
              if (random.nextInt(3) == 0) 'low_mood',
            },
            notes: p == 0 ? 'Period started' : '',
            updatedAt: stamp,
          ),
        );
      }

      for (var d = 0; d < cycleLen; d++) {
        final day = start.add(Duration(days: d));
        if (day.isAfter(today) || d < periodLength) continue;
        final ovulation = cycleLen - 14;
        final ids = <String>{};
        String notes = '';
        if (d >= ovulation - 5 && d <= ovulation + 1) {
          if (random.nextInt(3) == 0) ids.add('high_energy');
          if (random.nextInt(4) == 0) ids.add('calm');
        } else if (d > ovulation + 1) {
          if (random.nextInt(2) == 0) ids.add('bloating');
          if (random.nextInt(3) == 0) ids.add('irritability');
          if (random.nextInt(3) == 0) ids.add('cravings');
          if (random.nextInt(4) == 0) ids.add('breast_tenderness');
          if (random.nextInt(5) == 0) ids.add('acne');
          if (random.nextInt(4) == 0) ids.add('sleep_issues');
          if (d == cycleLen - 2) notes = 'Feeling pre-period-ish';
        } else {
          if (random.nextInt(4) == 0) ids.add('high_energy');
          if (random.nextInt(5) == 0) ids.add('headache');
        }
        if (ids.isEmpty && notes.isEmpty) continue;
        _merge(
          logs,
          DailyLog(
            date: day,
            symptomIds: ids,
            notes: notes,
            updatedAt: stamp,
          ),
        );
      }
    }

    return logs.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  static void _merge(Map<String, DailyLog> logs, DailyLog incoming) {
    final key = dateKey(incoming.date);
    final existing = logs[key];
    if (existing == null) {
      logs[key] = incoming;
      return;
    }
    logs[key] = existing.copyWith(
      isPeriod: existing.isPeriod || incoming.isPeriod,
      flow: incoming.flow != FlowLevel.none ? incoming.flow : existing.flow,
      symptomIds: {...existing.symptomIds, ...incoming.symptomIds},
      notes: incoming.notes.isNotEmpty ? incoming.notes : existing.notes,
    );
  }
}
