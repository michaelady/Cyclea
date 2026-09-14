import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/flow_level.dart';
import 'package:cyclea/services/advice_engine.dart';
import 'package:cyclea/services/cycle_math.dart';
import 'package:cyclea/services/demo_data.dart';
import 'package:cyclea/services/prediction_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('demo data produces multiple complete cycles and period days', () {
    final logs = DemoData.generate(now: parseDateKey('2026-09-14'));
    final stats = CycleMath.statsFor(logs, now: parseDateKey('2026-09-14'));
    expect(logs.length, greaterThan(40));
    expect(stats.completeCycleCount, greaterThanOrEqualTo(5));
    expect(stats.averageCycleLength, isNotNull);
    expect(stats.lastPeriodStart, isNotNull);
    expect(stats.periodSpans.every((span) => span.lengthDays >= 3), isTrue);
  });

  test('demo data is deterministic for a given seed and now', () {
    final a = DemoData.generate(now: parseDateKey('2026-09-14'), seed: 42);
    final b = DemoData.generate(now: parseDateKey('2026-09-14'), seed: 42);
    expect(a.map((log) => log.toJson()), b.map((log) => log.toJson()));
  });

  test('advice always includes the contraception disclaimer card', () {
    final cards = AdviceEngine.cardsFor(
      stats: CycleMath.statsFor(const []),
      prediction: PredictionService.predict(CycleMath.statsFor(const [])),
    );
    expect(cards.any((card) => card.id == 'not-contraception'), isTrue);
    expect(cards.any((card) => card.body.toLowerCase().contains('not a method')), isTrue);
  });

  test('advice mentions personal average once enough cycles exist', () {
    final logs = <DailyLog>[
      for (final start in ['2026-01-01', '2026-01-29', '2026-02-26', '2026-03-26'])
        DailyLog(
          date: parseDateKey(start),
          isPeriod: true,
          flow: FlowLevel.medium,
          updatedAt: DateTime.utc(2024),
        ),
    ];
    final stats = CycleMath.statsFor(logs);
    final cards = AdviceEngine.cardsFor(
      stats: stats,
      prediction: PredictionService.predict(stats, now: parseDateKey('2026-04-01')),
    );
    expect(cards.any((card) => card.id == 'your-length'), isTrue);
    expect(cards.any((card) => card.id == 'timing'), isTrue);
  });
}
