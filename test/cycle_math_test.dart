import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/flow_level.dart';
import 'package:cyclea/services/cycle_math.dart';
import 'package:flutter_test/flutter_test.dart';

DailyLog _period(String key, {FlowLevel flow = FlowLevel.medium}) {
  return DailyLog(
    date: parseDateKey(key),
    isPeriod: true,
    flow: flow,
    updatedAt: DateTime.utc(2024),
  );
}

DailyLog _symptoms(String key, Set<String> ids) {
  return DailyLog(
    date: parseDateKey(key),
    symptomIds: ids,
    updatedAt: DateTime.utc(2024),
  );
}

void main() {
  group('periodSpans', () {
    test('groups consecutive bleeding days and splits gaps', () {
      final spans = CycleMath.periodSpans([
        _period('2026-01-01'),
        _period('2026-01-02'),
        _period('2026-01-03'),
        _period('2026-01-28'),
        _period('2026-01-29'),
      ]);
      expect(spans, hasLength(2));
      expect(spans[0].start, parseDateKey('2026-01-01'));
      expect(spans[0].end, parseDateKey('2026-01-03'));
      expect(spans[0].lengthDays, 3);
      expect(spans[1].start, parseDateKey('2026-01-28'));
      expect(spans[1].lengthDays, 2);
    });

    test('treats flow-only days as period even if isPeriod is false', () {
      final spans = CycleMath.periodSpans([
        DailyLog(
          date: parseDateKey('2026-03-01'),
          flow: FlowLevel.spotting,
          updatedAt: DateTime.utc(2024),
        ),
      ]);
      expect(spans, hasLength(1));
      expect(spans.first.lengthDays, 1);
    });
  });

  group('cycle lengths', () {
    test('uses start-to-start differences and ignores implausible gaps', () {
      final spans = CycleMath.periodSpans([
        _period('2026-01-01'),
        _period('2026-01-29'),
        _period('2026-02-26'),
        _period('2026-06-01'),
      ]);
      final lengths = CycleMath.cycleLengthsFromSpans(spans);
      expect(lengths, [28, 28]);
    });
  });

  group('timing classification', () {
    test('counts early, on-time, and late versus personal average ±2 days', () {
      const lengths = [24, 28, 28, 29, 33];
      final avg = CycleMath.mean(lengths)!;
      expect(avg, 28.4);
      final timing = CycleMath.classifyTiming(lengths, average: avg);
      expect(timing.early, 1);
      expect(timing.onTime, 3);
      expect(timing.late, 1);
    });

    test('on-time window is inclusive of ±2 days', () {
      final timing = CycleMath.classifyTiming(const [26, 28, 30], average: 28);
      expect(timing.early, 0);
      expect(timing.onTime, 3);
      expect(timing.late, 0);
    });
  });

  group('variability and irregular flag', () {
    test('sample standard deviation is defined for 2+ cycles', () {
      final sd = CycleMath.sampleStdDev(const [26, 28, 30]);
      expect(sd, closeTo(2.0, 0.001));
    });

    test('flags irregular when stddev or range is wide', () {
      expect(CycleMath.isIrregular(const [28, 29, 27]), isFalse);
      expect(CycleMath.isIrregular(const [21, 35, 40, 22]), isTrue);
    });
  });

  group('statsFor', () {
    test('computes average cycle, period length, and last start', () {
      final logs = [
        ...['2026-01-01', '2026-01-02', '2026-01-03', '2026-01-04', '2026-01-05'].map(_period),
        ...['2026-01-29', '2026-01-30', '2026-01-31', '2026-02-01'].map(_period),
        ...['2026-02-26', '2026-02-27', '2026-02-28', '2026-03-01', '2026-03-02'].map(_period),
      ];
      final stats = CycleMath.statsFor(logs, now: parseDateKey('2026-03-10'));
      expect(stats.completeCycleCount, 2);
      expect(stats.averageCycleLength, 28);
      expect(stats.averagePeriodLength, closeTo(4.67, 0.05));
      expect(stats.lastPeriodStart, parseDateKey('2026-02-26'));
      expect(stats.irregular, isFalse);
    });

    test('groups symptoms by estimated phase', () {
      final logs = [
        _period('2026-01-01'),
        _period('2026-01-29'),
        _symptoms('2026-01-02', {'cramps'}),
        _symptoms('2026-01-10', {'high_energy'}),
        _symptoms('2026-01-14', {'calm'}),
        _symptoms('2026-01-22', {'bloating'}),
        _period('2026-01-03'),
      ];
      final stats = CycleMath.statsFor(logs);
      expect(stats.symptomsByPhase[stats.symptomsByPhase.keys.first], isNotNull);
      expect(
        stats.symptomsByPhase.values.any((bucket) => bucket.containsKey('cramps')),
        isTrue,
      );
      expect(
        stats.symptomsByPhase.values.any((bucket) => bucket.containsKey('bloating')),
        isTrue,
      );
    });
  });
}
