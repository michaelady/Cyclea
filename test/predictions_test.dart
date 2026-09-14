import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/flow_level.dart';
import 'package:cyclea/domain/prediction.dart';
import 'package:cyclea/services/cycle_math.dart';
import 'package:cyclea/services/prediction_service.dart';
import 'package:flutter_test/flutter_test.dart';

DailyLog period(String key) => DailyLog(
  date: parseDateKey(key),
  isPeriod: true,
  flow: FlowLevel.medium,
  updatedAt: DateTime.utc(2024),
);

void main() {
  test('no period start yields no dates and none confidence', () {
    final prediction = PredictionService.predict(
      CycleMath.statsFor(const []),
      now: parseDateKey('2026-03-01'),
    );
    expect(prediction.nextPeriodStart, isNull);
    expect(prediction.fertileStart, isNull);
    expect(prediction.confidence, PredictionConfidence.none);
    expect(prediction.usedDefaultCycle, isTrue);
    expect(prediction.cycleDay, isNull);
  });

  test('one logged period uses default 28-day cycle with wide uncertainty', () {
    final stats = CycleMath.statsFor([
      period('2026-03-01'),
      period('2026-03-02'),
      period('2026-03-03'),
      period('2026-03-04'),
      period('2026-03-05'),
    ], now: parseDateKey('2026-03-10'));
    final prediction = PredictionService.predict(stats, now: parseDateKey('2026-03-10'));
    expect(prediction.nextPeriodStart, parseDateKey('2026-03-29'));
    expect(prediction.uncertaintyDays, 5);
    expect(prediction.usedDefaultCycle, isTrue);
    expect(prediction.cycleDay, 10);
    expect(prediction.fertileStart, isNotNull);
    expect(prediction.fertileEnd!.isAfter(prediction.fertileStart!), isTrue);
  });

  test('two complete cycles predict from the personal average', () {
    final logs = [
      period('2026-01-01'),
      period('2026-01-30'), // 29-day cycle
      period('2026-02-27'), // 28-day cycle
    ];
    final stats = CycleMath.statsFor(logs, now: parseDateKey('2026-03-05'));
    expect(stats.averageCycleLength, 28.5);
    final prediction = PredictionService.predict(stats, now: parseDateKey('2026-03-05'));
    expect(prediction.nextPeriodStart, parseDateKey('2026-02-27').add(const Duration(days: 29)));
    expect(prediction.usedDefaultCycle, isFalse);
    expect(prediction.confidence, isNot(PredictionConfidence.none));
    expect(prediction.isPredictedPeriodBand(prediction.nextPeriodStart!), isTrue);
  });

  test('irregular history widens the uncertainty band', () {
    final logs = [
      period('2026-01-01'),
      period('2026-01-22'),
      period('2026-03-03'),
      period('2026-03-24'),
    ];
    final stats = CycleMath.statsFor(logs, now: parseDateKey('2026-03-30'));
    expect(stats.irregular, isTrue);
    final prediction = PredictionService.predict(stats, now: parseDateKey('2026-03-30'));
    expect(prediction.irregular, isTrue);
    expect(prediction.uncertaintyDays, greaterThanOrEqualTo(5));
    expect(prediction.confidence, PredictionConfidence.low);
  });

  test('fertile window sits about 14 days before the next period estimate', () {
    final logs = [
      period('2026-01-01'),
      period('2026-01-29'),
      period('2026-02-26'),
    ];
    final stats = CycleMath.statsFor(logs, now: parseDateKey('2026-03-01'));
    final prediction = PredictionService.predict(stats, now: parseDateKey('2026-03-01'));
    final ovulation = parseDateKey('2026-02-26').add(const Duration(days: 14));
    expect(prediction.fertileEnd, ovulation.add(const Duration(days: 1)));
    expect(
      prediction.fertileStart,
      ovulation.subtract(const Duration(days: 5)),
    );
  });
}
