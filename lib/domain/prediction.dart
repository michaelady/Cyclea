import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/domain/dates.dart';

/// One projected cycle: a future period plus the fertile window that leads into it.
class ForecastCycle {
  const ForecastCycle({
    required this.periodStart,
    required this.periodEnd,
    required this.ovulation,
    required this.fertileStart,
    required this.fertileEnd,
  });

  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime ovulation;
  final DateTime fertileStart;
  final DateTime fertileEnd;

  bool containsPeriod(DateTime date) {
    final day = dateOnly(date);
    return !day.isBefore(periodStart) && !day.isAfter(periodEnd);
  }

  bool containsFertile(DateTime date) {
    final day = dateOnly(date);
    return !day.isBefore(fertileStart) && !day.isAfter(fertileEnd);
  }

  bool isOvulationDay(DateTime date) => dateOnly(date) == dateOnly(ovulation);
}

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
    required this.asOf,
    required this.upcoming,
    this.activeOvulation,
    this.activeFertileStart,
    this.activeFertileEnd,
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

  /// Day the forecast was built for. Predicted markers never paint before this.
  final DateTime asOf;

  /// The next several cycles, beginning with the next period on or after [asOf].
  final List<ForecastCycle> upcoming;

  /// Ovulation and fertile window of the cycle that contains [asOf].
  final DateTime? activeOvulation;
  final DateTime? activeFertileStart;
  final DateTime? activeFertileEnd;

  bool get showsEstimate =>
      nextPeriodStart != null && fertileStart != null && fertileEnd != null;

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

  bool _onOrAfterAsOf(DateTime date) => !dateOnly(date).isBefore(asOf);

  bool isPredictedPeriod(DateTime date) {
    if (!_onOrAfterAsOf(date)) return false;
    return upcoming.any((cycle) => cycle.containsPeriod(date));
  }

  bool isPredictedPeriodBand(DateTime date) {
    if (!_onOrAfterAsOf(date)) return false;
    final day = dateOnly(date);
    for (final cycle in upcoming) {
      final early = cycle.periodStart.subtract(Duration(days: uncertaintyDays));
      final late = cycle.periodStart.add(Duration(days: uncertaintyDays));
      if (!day.isBefore(early) && !day.isAfter(late)) return true;
    }
    return false;
  }

  bool isFertile(DateTime date) {
    if (!_onOrAfterAsOf(date)) return false;
    final activeStart = activeFertileStart;
    final activeEnd = activeFertileEnd;
    if (activeStart != null &&
        activeEnd != null &&
        !dateOnly(date).isBefore(activeStart) &&
        !dateOnly(date).isAfter(activeEnd)) {
      return true;
    }
    return upcoming.any((cycle) => cycle.containsFertile(date));
  }

  bool isOvulation(DateTime date) {
    if (!_onOrAfterAsOf(date)) return false;
    final active = activeOvulation;
    if (active != null && dateOnly(date) == dateOnly(active)) return true;
    return upcoming.any((cycle) => cycle.isOvulationDay(date));
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
