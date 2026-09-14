import 'dart:math';

import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/domain/cycle_stats.dart';
import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/period_span.dart';

class CycleMath {
  static const int defaultCycleLength = 28;
  static const int typicalLutealDays = 14;
  static const int fertileBeforeOvulation = 5;
  static const int fertileAfterOvulation = 1;
  static const int onTimeWindowDays = 2;
  static const int minPlausibleCycle = 10;
  static const int maxPlausibleCycle = 90;
  static const int defaultPeriodLength = 5;
  static const double irregularStdDevThreshold = 8;
  static const int irregularRangeThreshold = 10;

  static List<PeriodSpan> periodSpans(Iterable<DailyLog> logs) {
    final days = logs
        .where((log) => log.isPeriod || log.flow.isBleeding)
        .map((log) => dateOnly(log.date))
        .toSet()
        .toList()
      ..sort();
    if (days.isEmpty) return const [];

    final spans = <PeriodSpan>[];
    var runStart = days.first;
    var runEnd = days.first;
    for (var i = 1; i < days.length; i++) {
      if (daysBetween(runEnd, days[i]) == 1) {
        runEnd = days[i];
      } else {
        spans.add(PeriodSpan(start: runStart, end: runEnd));
        runStart = days[i];
        runEnd = days[i];
      }
    }
    spans.add(PeriodSpan(start: runStart, end: runEnd));
    return spans;
  }

  static List<int> cycleLengthsFromSpans(List<PeriodSpan> spans) {
    if (spans.length < 2) return const [];
    final starts = spans.map((span) => span.start).toList()..sort();
    final lengths = <int>[];
    for (var i = 1; i < starts.length; i++) {
      final length = daysBetween(starts[i - 1], starts[i]);
      if (length >= minPlausibleCycle && length <= maxPlausibleCycle) {
        lengths.add(length);
      }
    }
    return lengths;
  }

  static double? mean(List<num> values) {
    if (values.isEmpty) return null;
    final total = values.fold<double>(0, (sum, item) => sum + item.toDouble());
    return total / values.length;
  }

  static double? sampleStdDev(List<num> values) {
    if (values.length < 2) return null;
    final avg = mean(values)!;
    final squared = values.fold<double>(
      0,
      (sum, item) => sum + pow(item.toDouble() - avg, 2),
    );
    return sqrt(squared / (values.length - 1));
  }

  static TimingCounts classifyTiming(
    List<int> cycleLengths, {
    double? average,
    int window = onTimeWindowDays,
  }) {
    if (cycleLengths.isEmpty) {
      return const TimingCounts(early: 0, onTime: 0, late: 0);
    }
    final avg = average ?? mean(cycleLengths)!;
    var early = 0;
    var onTime = 0;
    var late = 0;
    for (final length in cycleLengths) {
      if (length < avg - window) {
        early += 1;
      } else if (length > avg + window) {
        late += 1;
      } else {
        onTime += 1;
      }
    }
    return TimingCounts(early: early, onTime: onTime, late: late);
  }

  static bool isIrregular(List<int> cycleLengths, {double? stdDev}) {
    if (cycleLengths.length < 2) return false;
    final sd = stdDev ?? sampleStdDev(cycleLengths) ?? 0;
    final minLen = cycleLengths.reduce(min);
    final maxLen = cycleLengths.reduce(max);
    return sd >= irregularStdDevThreshold ||
        (maxLen - minLen) >= irregularRangeThreshold;
  }

  static CyclePhase phaseFor({
    required DateTime date,
    required List<PeriodSpan> spans,
    required int cycleLength,
    DateTime? lastPeriodStart,
  }) {
    final d = dateOnly(date);
    for (final span in spans) {
      if (span.contains(d)) return CyclePhase.menstrual;
    }

    final start = _cycleStartOnOrBefore(d, spans) ?? lastPeriodStart;
    if (start == null) return CyclePhase.unknown;

    final ovulationOffset = max(cycleLength - typicalLutealDays, 8);
    final ovulation = start.add(Duration(days: ovulationOffset));
    final fertileStart = ovulation.subtract(
      const Duration(days: fertileBeforeOvulation),
    );
    final fertileEnd = ovulation.add(const Duration(days: fertileAfterOvulation));
    if (!d.isBefore(fertileStart) && !d.isAfter(fertileEnd)) {
      return CyclePhase.ovulatory;
    }
    if (d.isBefore(fertileStart)) return CyclePhase.follicular;
    return CyclePhase.luteal;
  }

  static DateTime? _cycleStartOnOrBefore(DateTime date, List<PeriodSpan> spans) {
    DateTime? best;
    for (final span in spans) {
      if (!span.start.isAfter(date)) {
        if (best == null || span.start.isAfter(best)) {
          best = span.start;
        }
      }
    }
    return best;
  }

  static Map<CyclePhase, Map<String, int>> symptomsByPhase({
    required Iterable<DailyLog> logs,
    required List<PeriodSpan> spans,
    required int cycleLength,
  }) {
    final counts = <CyclePhase, Map<String, int>>{
      for (final phase in CyclePhase.values)
        if (phase != CyclePhase.unknown) phase: <String, int>{},
    };
    final lastStart = spans.isEmpty ? null : spans.last.start;
    for (final log in logs) {
      if (log.symptomIds.isEmpty) continue;
      final phase = phaseFor(
        date: log.date,
        spans: spans,
        cycleLength: cycleLength,
        lastPeriodStart: lastStart,
      );
      if (phase == CyclePhase.unknown) continue;
      final bucket = counts[phase]!;
      for (final id in log.symptomIds) {
        bucket[id] = (bucket[id] ?? 0) + 1;
      }
    }
    return counts;
  }

  static CycleStats statsFor(
    Iterable<DailyLog> logs, {
    DateTime? now,
  }) {
    now ?? DateTime.now();
    final spans = periodSpans(logs);
    final lengths = cycleLengthsFromSpans(spans);
    final avg = mean(lengths);
    final sd = sampleStdDev(lengths);
    final timing = classifyTiming(lengths, average: avg);
    final periodLengths = spans.map((span) => span.lengthDays).toList();
    final avgPeriod = mean(periodLengths);
    final cycleLength = avg?.round() ?? defaultCycleLength;
    final lastSpan = spans.isEmpty ? null : spans.last;

    return CycleStats(
      periodSpans: spans,
      cycleLengths: lengths,
      averageCycleLength: avg,
      cycleStdDev: sd,
      minCycle: lengths.isEmpty ? null : lengths.reduce(min),
      maxCycle: lengths.isEmpty ? null : lengths.reduce(max),
      averagePeriodLength: avgPeriod,
      earlyCount: timing.early,
      onTimeCount: timing.onTime,
      lateCount: timing.late,
      irregular: isIrregular(lengths, stdDev: sd),
      lastPeriodStart: lastSpan?.start,
      lastPeriodLength: lastSpan?.lengthDays,
      symptomsByPhase: symptomsByPhase(
        logs: logs,
        spans: spans,
        cycleLength: cycleLength,
      ),
      onTimeWindowDays: onTimeWindowDays,
    );
  }
}

class TimingCounts {
  const TimingCounts({
    required this.early,
    required this.onTime,
    required this.late,
  });

  final int early;
  final int onTime;
  final int late;
}
