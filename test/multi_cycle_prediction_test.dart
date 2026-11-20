import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/flow_level.dart';
import 'package:cyclea/services/cycle_math.dart';
import 'package:cyclea/services/prediction_service.dart';
import 'package:flutter_test/flutter_test.dart';

DailyLog period(String key) => DailyLog(
  date: parseDateKey(key),
  isPeriod: true,
  flow: FlowLevel.medium,
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  test('no data produces an empty horizon', () {
    final today = parseDateKey('2026-11-20');
    final prediction = PredictionService.predict(
      CycleMath.statsFor(const [], now: today),
      now: today,
    );
    expect(prediction.upcoming, isEmpty);
    expect(prediction.nextPeriodStart, isNull);
    expect(prediction.fertileStart, isNull);
    expect(prediction.isPredictedPeriod(today), isFalse);
    expect(prediction.isFertile(today.add(const Duration(days: 40))), isFalse);
    expect(
      prediction.isOvulation(today.add(const Duration(days: 14))),
      isFalse,
    );
  });

  test('a single cycle projects six default-length cycles', () {
    final today = parseDateKey('2026-03-10');
    final stats = CycleMath.statsFor([
      period('2026-03-01'),
      period('2026-03-02'),
      period('2026-03-03'),
      period('2026-03-04'),
      period('2026-03-05'),
    ], now: today);
    final prediction = PredictionService.predict(stats, now: today);

    expect(prediction.upcoming, hasLength(PredictionService.horizonCycles));
    expect(prediction.usedDefaultCycle, isTrue);
    expect(prediction.nextPeriodStart, parseDateKey('2026-03-29'));
    expect(prediction.upcoming.map((cycle) => cycle.periodStart).toList(), [
      for (var index = 0; index < 6; index++)
        parseDateKey('2026-03-29').add(Duration(days: 28 * index)),
    ]);
    final first = prediction.upcoming.first;
    expect(
      first.ovulation,
      parseDateKey('2026-03-29').add(const Duration(days: 14)),
    );
    expect(prediction.isPredictedPeriod(first.periodStart), isTrue);
    expect(prediction.isFertile(first.fertileStart), isTrue);
    expect(prediction.isOvulation(first.ovulation), isTrue);
    expect(
      prediction.isPredictedPeriod(today.subtract(const Duration(days: 1))),
      isFalse,
    );
  });

  test('irregular history still spaces six cycles and keeps a wide band', () {
    final today = parseDateKey('2026-03-30');
    final stats = CycleMath.statsFor([
      period('2026-01-01'),
      period('2026-01-22'),
      period('2026-03-03'),
      period('2026-03-24'),
    ], now: today);
    expect(stats.irregular, isTrue);
    final prediction = PredictionService.predict(stats, now: today);
    final length = prediction.expectedCycleLength;

    expect(prediction.upcoming, hasLength(6));
    expect(prediction.uncertaintyDays, greaterThanOrEqualTo(5));
    expect(prediction.irregular, isTrue);
    for (var index = 1; index < prediction.upcoming.length; index++) {
      expect(
        daysBetween(
          prediction.upcoming[index - 1].periodStart,
          prediction.upcoming[index].periodStart,
        ),
        length,
      );
    }
    expect(
      prediction.upcoming.every((cycle) => !cycle.periodStart.isBefore(today)),
      isTrue,
    );
    final past = today.subtract(const Duration(days: 3));
    expect(prediction.isPredictedPeriod(past), isFalse);
    expect(prediction.isFertile(past), isFalse);
    expect(prediction.isOvulation(past), isFalse);
  });

  test('home fertile dates are a window the calendar will also mark', () {
    final today = parseDateKey('2026-11-20');
    final stats = CycleMath.statsFor([
      period('2026-11-02'),
      period('2026-11-03'),
      period('2026-11-04'),
    ], now: today);
    final prediction = PredictionService.predict(stats, now: today);
    expect(prediction.fertileStart, isNotNull);
    expect(prediction.isFertile(prediction.fertileStart!), isTrue);
    expect(prediction.isPredictedPeriod(prediction.nextPeriodStart!), isTrue);
    expect(prediction.upcoming.length, greaterThanOrEqualTo(6));
    final far = prediction.upcoming[4];
    expect(prediction.isPredictedPeriod(far.periodStart), isTrue);
    expect(prediction.isFertile(far.ovulation), isTrue);
  });
}
