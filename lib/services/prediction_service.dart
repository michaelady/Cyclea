import 'dart:math';

import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/domain/cycle_stats.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/prediction.dart';
import 'package:cyclea/services/cycle_math.dart';

class PredictionService {
  static const int horizonCycles = 6;

  static CyclePrediction predict(CycleStats stats, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final cycleLength =
        stats.averageCycleLength?.round() ?? CycleMath.defaultCycleLength;
    final periodLength =
        stats.averagePeriodLength?.round() ?? CycleMath.defaultPeriodLength;
    final lastStart = stats.lastPeriodStart;

    if (lastStart == null || lastStart.isAfter(today)) {
      return CyclePrediction(
        nextPeriodStart: null,
        nextPeriodEnd: null,
        uncertaintyDays: 5,
        fertileStart: null,
        fertileEnd: null,
        confidence: PredictionConfidence.none,
        usedDefaultCycle: true,
        irregular: false,
        cycleDay: null,
        expectedCycleLength: cycleLength,
        phaseToday: CyclePhase.unknown,
        asOf: today,
        upcoming: const [],
      );
    }

    final anchor = _cycleStartOnOrBefore(lastStart, today, cycleLength);
    final usedDefault = !stats.hasPredictionBasis;
    final uncertainty = _uncertaintyDays(stats);
    final active = _project(
      periodStart: anchor,
      cycleLength: cycleLength,
      periodLength: periodLength,
    );
    final upcoming = [
      for (var index = 1; index <= horizonCycles; index++)
        _project(
          periodStart: anchor.add(Duration(days: cycleLength * index)),
          cycleLength: cycleLength,
          periodLength: periodLength,
        ),
    ];
    final next = upcoming.first;

    final displayFertileStart = !active.fertileEnd.isBefore(today)
        ? active.fertileStart
        : next.fertileStart;
    final displayFertileEnd = !active.fertileEnd.isBefore(today)
        ? active.fertileEnd
        : next.fertileEnd;

    final cycleDay = daysBetween(anchor, today) + 1;
    final onPeriod = stats.periodSpans.any((span) => span.contains(today));
    final inFertile =
        !today.isBefore(active.fertileStart) &&
        !today.isAfter(active.fertileEnd);
    final phase = onPeriod
        ? CyclePhase.menstrual
        : inFertile
        ? CyclePhase.ovulatory
        : today.isBefore(active.fertileStart)
        ? CyclePhase.follicular
        : CyclePhase.luteal;

    return CyclePrediction(
      nextPeriodStart: next.periodStart,
      nextPeriodEnd: next.periodEnd,
      uncertaintyDays: uncertainty,
      fertileStart: displayFertileStart,
      fertileEnd: displayFertileEnd,
      confidence: _confidence(stats, usedDefault: usedDefault),
      usedDefaultCycle: usedDefault,
      irregular: stats.irregular,
      cycleDay: cycleDay < 1 || cycleDay > 90 ? null : cycleDay,
      expectedCycleLength: cycleLength,
      phaseToday: phase,
      asOf: today,
      upcoming: upcoming,
      activeOvulation: active.ovulation,
      activeFertileStart: active.fertileStart,
      activeFertileEnd: active.fertileEnd,
    );
  }

  /// Walks forward from [lastStart] until the next period is today or later.
  static DateTime _cycleStartOnOrBefore(
    DateTime lastStart,
    DateTime today,
    int cycleLength,
  ) {
    var anchor = dateOnly(lastStart);
    var guard = 0;
    while (guard < 48) {
      final next = anchor.add(Duration(days: cycleLength));
      if (!next.isBefore(today)) return anchor;
      anchor = next;
      guard++;
    }
    return anchor;
  }

  static ForecastCycle _project({
    required DateTime periodStart,
    required int cycleLength,
    required int periodLength,
  }) {
    final ovulationOffset = max(cycleLength - CycleMath.typicalLutealDays, 8);
    final ovulation = periodStart.add(Duration(days: ovulationOffset));
    return ForecastCycle(
      periodStart: periodStart,
      periodEnd: periodStart.add(Duration(days: max(periodLength, 1) - 1)),
      ovulation: ovulation,
      fertileStart: ovulation.subtract(
        const Duration(days: CycleMath.fertileBeforeOvulation),
      ),
      fertileEnd: ovulation.add(
        const Duration(days: CycleMath.fertileAfterOvulation),
      ),
    );
  }

  static int _uncertaintyDays(CycleStats stats) {
    if (stats.completeCycleCount == 0) return 5;
    if (stats.completeCycleCount == 1) return 4;
    final sd = stats.cycleStdDev ?? 2;
    final fromSpread = (sd * 1.5).round();
    final bounded = max(2, min(10, fromSpread));
    if (stats.irregular) return max(bounded, 5);
    return bounded;
  }

  static PredictionConfidence _confidence(
    CycleStats stats, {
    required bool usedDefault,
  }) {
    if (usedDefault || stats.completeCycleCount == 0) {
      return PredictionConfidence.none;
    }
    if (stats.completeCycleCount == 1 || stats.irregular) {
      return PredictionConfidence.low;
    }
    if (stats.completeCycleCount < 4 || (stats.cycleStdDev ?? 0) >= 5) {
      return PredictionConfidence.medium;
    }
    return PredictionConfidence.high;
  }
}
