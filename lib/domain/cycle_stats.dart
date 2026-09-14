import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/domain/period_span.dart';

class CycleStats {
  const CycleStats({
    required this.periodSpans,
    required this.cycleLengths,
    required this.averageCycleLength,
    required this.cycleStdDev,
    required this.minCycle,
    required this.maxCycle,
    required this.averagePeriodLength,
    required this.earlyCount,
    required this.onTimeCount,
    required this.lateCount,
    required this.irregular,
    required this.lastPeriodStart,
    required this.lastPeriodLength,
    required this.symptomsByPhase,
    required this.onTimeWindowDays,
  });

  final List<PeriodSpan> periodSpans;
  final List<int> cycleLengths;
  final double? averageCycleLength;
  final double? cycleStdDev;
  final int? minCycle;
  final int? maxCycle;
  final double? averagePeriodLength;
  final int earlyCount;
  final int onTimeCount;
  final int lateCount;
  final bool irregular;
  final DateTime? lastPeriodStart;
  final int? lastPeriodLength;
  final Map<CyclePhase, Map<String, int>> symptomsByPhase;
  final int onTimeWindowDays;

  int get completeCycleCount => cycleLengths.length;

  int get classifiedCount => earlyCount + onTimeCount + lateCount;

  double get earlyRate => classifiedCount == 0 ? 0 : earlyCount / classifiedCount;

  double get onTimeRate => classifiedCount == 0 ? 0 : onTimeCount / classifiedCount;

  double get lateRate => classifiedCount == 0 ? 0 : lateCount / classifiedCount;

  int get roundedAverageCycle => averageCycleLength?.round() ?? 28;

  bool get hasPredictionBasis => completeCycleCount >= 1;
}
