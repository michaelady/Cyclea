import 'dart:math';

import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/domain/cycle_stats.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/prediction.dart';
import 'package:cyclea/services/cycle_math.dart';

class PredictionService {
  static CyclePrediction predict(CycleStats stats, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final cycleLength = stats.averageCycleLength?.round() ?? CycleMath.defaultCycleLength;
    final periodLength =
        stats.averagePeriodLength?.round() ?? CycleMath.defaultPeriodLength;
    final lastStart = stats.lastPeriodStart;

    if (lastStart == null) {
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
      );
    }

    final usedDefault = !stats.hasPredictionBasis;
    final nextStart = lastStart.add(Duration(days: cycleLength));
    final nextEnd = nextStart.add(Duration(days: periodLength - 1));
    final uncertainty = _uncertaintyDays(stats);
    final ovulationOffset = max(cycleLength - CycleMath.typicalLutealDays, 8);
    final ovulation = lastStart.add(Duration(days: ovulationOffset));
    final fertileStart = ovulation.subtract(
      const Duration(days: CycleMath.fertileBeforeOvulation),
    );
    final fertileEnd = ovulation.add(
      const Duration(days: CycleMath.fertileAfterOvulation),
    );

    final cycleDay = daysBetween(lastStart, today) + 1;
    final phase = CycleMath.phaseFor(
      date: today,
      spans: stats.periodSpans,
      cycleLength: cycleLength,
      lastPeriodStart: lastStart,
    );

    return CyclePrediction(
      nextPeriodStart: nextStart,
      nextPeriodEnd: nextEnd,
      uncertaintyDays: uncertainty,
      fertileStart: fertileStart,
      fertileEnd: fertileEnd,
      confidence: _confidence(stats, usedDefault: usedDefault),
      usedDefaultCycle: usedDefault,
      irregular: stats.irregular,
      cycleDay: cycleDay < 1 || cycleDay > 90 ? null : cycleDay,
      expectedCycleLength: cycleLength,
      phaseToday: phase,
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
