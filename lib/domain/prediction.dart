import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/domain/dates.dart';

class CyclePrediction {
  const CyclePrediction({
    required this.nextPeriodStart,
    required this.nextPeriodEnd,
    required this.uncertaintyDays,
    required this.fertileStart,
    required this.fertileEnd,
    required this.confidence,
    required this.usedDefaultCycle,
    required this.irregular,
    required this.cycleDay,
    required this.expectedCycleLength,
    required this.phaseToday,
  });

  final DateTime? nextPeriodStart;
  final DateTime? nextPeriodEnd;
  final int uncertaintyDays;
  final DateTime? fertileStart;
  final DateTime? fertileEnd;
  final PredictionConfidence confidence;
  final bool usedDefaultCycle;
  final bool irregular;
  final int? cycleDay;
  final int expectedCycleLength;
  final CyclePhase phaseToday;

  DateTime? get earliestNextPeriod {
    final start = nextPeriodStart;
    if (start == null) return null;
    return start.subtract(Duration(days: uncertaintyDays));
  }

  DateTime? get latestNextPeriod {
    final start = nextPeriodStart;
    if (start == null) return null;
    return start.add(Duration(days: uncertaintyDays));
  }

  bool isPredictedPeriod(DateTime date) {
    final start = nextPeriodStart;
    final end = nextPeriodEnd;
    if (start == null || end == null) return false;
    final d = dateOnly(date);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  bool isPredictedPeriodBand(DateTime date) {
    final early = earliestNextPeriod;
    final late = latestNextPeriod;
    if (early == null || late == null) return false;
    final d = dateOnly(date);
    return !d.isBefore(early) && !d.isAfter(late);
  }

  bool isFertile(DateTime date) {
    final start = fertileStart;
    final end = fertileEnd;
    if (start == null || end == null) return false;
    final d = dateOnly(date);
    return !d.isBefore(start) && !d.isAfter(end);
  }
}

enum PredictionConfidence {
  none,
  low,
  medium,
  high;

  String get label => switch (this) {
    PredictionConfidence.none => 'Not enough data',
    PredictionConfidence.low => 'Low confidence',
    PredictionConfidence.medium => 'Moderate confidence',
    PredictionConfidence.high => 'Higher confidence',
  };
}
