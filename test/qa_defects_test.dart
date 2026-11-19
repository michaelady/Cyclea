import 'dart:math' as math;

import 'package:cyclea/app.dart';
import 'package:cyclea/data/auth_service.dart';
import 'package:cyclea/data/stores.dart';
import 'package:cyclea/domain/cycle_phase.dart';
import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/flow_level.dart';
import 'package:cyclea/screens/settings_screen.dart';
import 'package:cyclea/services/advice_engine.dart';
import 'package:cyclea/services/cycle_math.dart';
import 'package:cyclea/services/demo_data.dart';
import 'package:cyclea/services/prediction_service.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

DailyLog period(String key) => DailyLog(
  date: parseDateKey(key),
  isPeriod: true,
  flow: FlowLevel.medium,
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  final today = parseDateKey('2026-11-19');

  group('future period starts', () {
    test('a future range does not become the current cycle', () {
      final logs = [
        period('2026-11-03'),
        period('2026-11-04'),
        period('2026-11-05'),
        period('2026-12-01'),
        period('2026-12-02'),
        period('2026-12-03'),
      ];
      final stats = CycleMath.statsFor(logs, now: today);
      final prediction = PredictionService.predict(stats, now: today);

      expect(stats.lastPeriodStart, parseDateKey('2026-11-03'));
      expect(prediction.cycleDay, 17);
      expect(prediction.phaseToday, isNot(CyclePhase.unknown));
      expect(prediction.nextPeriodStart, isNot(parseDateKey('2026-12-25')));
      expect(
        prediction.phaseToday == CyclePhase.ovulatory,
        prediction.isFertile(today),
      );
      expect(
        prediction.cycleDay == null,
        prediction.phaseToday == CyclePhase.unknown,
      );
    });

    test('a one-day period months ahead does not set phase or dates', () {
      final stats = CycleMath.statsFor([period('2027-02-19')], now: today);
      final prediction = PredictionService.predict(stats, now: today);

      expect(stats.lastPeriodStart, isNull);
      expect(prediction.cycleDay, isNull);
      expect(prediction.phaseToday, CyclePhase.unknown);
      expect(prediction.nextPeriodStart, isNull);
      expect(prediction.fertileStart, isNull);
      expect(
        prediction.phaseToday == CyclePhase.ovulatory,
        prediction.isFertile(today),
      );
    });
  });

  group('middle-day delete', () {
    test('removing a day inside a period does not start a new cycle', () {
      final full = [
        for (final day in [
          '2026-11-03',
          '2026-11-04',
          '2026-11-05',
          '2026-11-06',
          '2026-11-07',
        ])
          period(day),
      ];
      final gapped = [
        period('2026-11-03'),
        period('2026-11-04'),
        period('2026-11-05'),
        period('2026-11-07'),
      ];
      final before = PredictionService.predict(
        CycleMath.statsFor(full, now: today),
        now: today,
      );
      final afterStats = CycleMath.statsFor(gapped, now: today);
      final after = PredictionService.predict(afterStats, now: today);

      expect(afterStats.lastPeriodStart, parseDateKey('2026-11-03'));
      expect(afterStats.completeCycleCount, 0);
      expect(after.nextPeriodStart, before.nextPeriodStart);
      expect(after.fertileStart, before.fertileStart);
      expect(after.fertileEnd, before.fertileEnd);
    });
  });

  group('calendar and home agreement', () {
    test('one past period exposes the same estimate both surfaces read', () {
      final stats = CycleMath.statsFor([
        period('2026-11-03'),
        period('2026-11-04'),
        period('2026-11-05'),
        period('2026-11-06'),
        period('2026-11-07'),
      ], now: today);
      final prediction = PredictionService.predict(stats, now: today);

      expect(prediction.nextPeriodStart, isNotNull);
      expect(prediction.fertileStart, isNotNull);
      expect(prediction.fertileEnd, isNotNull);
      expect(prediction.isFertile(prediction.fertileStart!), isTrue);
      expect(prediction.isPredictedPeriod(prediction.nextPeriodStart!), isTrue);
      expect(prediction.cycleDay, isNotNull);
      expect(prediction.phaseToday, isNot(CyclePhase.unknown));
      expect(
        prediction.phaseToday == CyclePhase.ovulatory,
        prediction.isFertile(today),
      );
    });
  });

  group('fertile-window advice', () {
    test(
      'the inside-window card is shown only when today is in that window',
      () {
        // Several real cycles keep the average near 28 days, so 19 Nov still
        // falls in the fertile window of the 6 Nov start. A stored 20 Dec start
        // must not move the published window off today while the card stays.
        const starts = [
          '2026-02-27',
          '2026-03-27',
          '2026-04-24',
          '2026-05-22',
          '2026-06-19',
          '2026-07-17',
          '2026-08-14',
          '2026-09-11',
          '2026-10-09',
          '2026-11-06',
          '2026-12-20',
        ];
        final logs = [
          for (final start in starts) ...[
            period(start),
            period(dateKey(parseDateKey(start).add(const Duration(days: 1)))),
            period(dateKey(parseDateKey(start).add(const Duration(days: 2)))),
          ],
        ];
        final stats = CycleMath.statsFor(logs, now: today);
        final prediction = PredictionService.predict(stats, now: today);
        final cards = AdviceEngine.cardsFor(
          stats: stats,
          prediction: prediction,
        );
        final showsInside = cards.any(
          (card) => card.title == 'Inside the estimated fertile window',
        );

        expect(showsInside, prediction.isFertile(today));
        expect(
          prediction.phaseToday == CyclePhase.ovulatory,
          prediction.isFertile(today),
        );
      },
    );

    test('a day outside the window does not get the inside-window card', () {
      final logs = [
        period('2026-10-01'),
        period('2026-10-02'),
        period('2026-10-03'),
      ];
      final stats = CycleMath.statsFor(logs, now: today);
      final prediction = PredictionService.predict(stats, now: today);
      final cards = AdviceEngine.cardsFor(stats: stats, prediction: prediction);

      expect(prediction.isFertile(today), isFalse);
      expect(
        cards.any(
          (card) => card.title == 'Inside the estimated fertile window',
        ),
        isFalse,
      );
    });
  });

  test('empty-state phase label is not Unspecified', () {
    expect(CyclePhase.unknown.label, isNot('Unspecified'));
    expect(CyclePhase.unknown.label, 'No cycle yet');
  });

  test('demo periods have no interior gaps and no future days', () {
    final logs = DemoData.generate(now: today);
    expect(logs.every((log) => !dateOnly(log.date).isAfter(today)), isTrue);
    final spans = CycleMath.periodSpans(logs);
    expect(spans, isNotEmpty);
    for (final span in spans) {
      final logged = logs.where((log) {
        if (!log.isPeriod && !log.flow.isBleeding) return false;
        final day = dateOnly(log.date);
        return !day.isBefore(span.start) && !day.isAfter(span.end);
      }).length;
      expect(logged, span.lengthDays, reason: 'hole inside $span');
    }
    expect(spans.last.start.isAfter(today), isFalse);
  });

  test('seed replaces stored logs so future leftovers do not remain', () async {
    final settings = MemorySettingsStore(disclaimerAccepted: true);
    final logs = MemoryLogStore({
      for (final key in ['2026-12-01', '2026-12-02', '2026-12-03'])
        key: period(key),
    });
    final controller = CycleController(
      localLogs: logs,
      settings: settings,
      auth: AuthService.disabled(),
      now: () => today,
    );
    await controller.bootstrap();
    expect(controller.logOn(parseDateKey('2026-12-01')), isNotNull);

    await controller.seedDemoData();

    expect(controller.logOn(parseDateKey('2026-12-01')), isNull);
    expect(
      controller.logs.every((log) => !dateOnly(log.date).isAfter(today)),
      isTrue,
    );
    final spans = controller.stats.periodSpans;
    for (final span in spans) {
      var cursor = span.start;
      while (!cursor.isAfter(span.end)) {
        final log = controller.logOn(cursor);
        expect(
          log?.isPeriod == true || log?.flow.isBleeding == true,
          isTrue,
          reason: '$cursor',
        );
        cursor = cursor.add(const Duration(days: 1));
      }
    }
  });

  test('saving a future day is rejected', () async {
    final controller = CycleController(
      localLogs: MemoryLogStore(),
      settings: MemorySettingsStore(disclaimerAccepted: true),
      auth: AuthService.disabled(),
      now: () => today,
    );
    await controller.bootstrap();
    await controller.saveLog(period('2027-02-19'));
    await controller.markPeriodRange(
      parseDateKey('2026-12-01'),
      parseDateKey('2026-12-03'),
    );

    expect(controller.logOn(parseDateKey('2027-02-19')), isNull);
    expect(controller.logOn(parseDateKey('2026-12-01')), isNull);
    expect(controller.logs, isEmpty);
  });

  testWidgets('home ignores a stored future period and keeps the past cycle', (
    tester,
  ) async {
    final realToday = dateOnly(DateTime.now());
    final past = realToday.subtract(const Duration(days: 16));
    final future = realToday.add(const Duration(days: 14));
    final store = MemoryLogStore();
    for (var i = 0; i < 3; i++) {
      await store.upsert(
        DailyLog(
          date: future.add(Duration(days: i)),
          isPeriod: true,
          flow: FlowLevel.medium,
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );
    }
    final controller = CycleController(
      localLogs: store,
      settings: MemorySettingsStore(disclaimerAccepted: true),
      auth: AuthService.disabled(),
    );
    await controller.bootstrap();
    await controller.markPeriodRange(past, past.add(const Duration(days: 3)));

    await tester.pumpWidget(CycleaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.textContaining('awaiting'), findsNothing);
    expect(find.textContaining('day of'), findsOneWidget);
    expect(find.text('Unspecified'), findsNothing);
    expect(find.text('Needs more logs'), findsNothing);
  });

  testWidgets('settings hides continue-as-guest and tester tools for a guest', (
    tester,
  ) async {
    final controller = CycleController(
      localLogs: MemoryLogStore(),
      settings: MemorySettingsStore(disclaimerAccepted: true),
      auth: AuthService.disabled(),
    );
    await controller.bootstrap();
    await tester.pumpWidget(CycleaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue as guest'), findsNothing);
    expect(find.text('Tester tools'), findsNothing);
    expect(find.text('Seed demo data'), findsNothing);

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Seeded demo data'), findsNothing);
  });

  testWidgets('delete day asks before removing the log', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    final todayDate = dateOnly(DateTime.now());
    final controller = CycleController(
      localLogs: MemoryLogStore(),
      settings: MemorySettingsStore(disclaimerAccepted: true),
      auth: AuthService.disabled(),
    );
    await controller.bootstrap();
    await controller.saveLog(
      DailyLog(
        date: todayDate,
        isPeriod: true,
        flow: FlowLevel.medium,
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    await tester.pumpWidget(CycleaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('Logged period · Medium flow'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this day?'), findsOneWidget);
    expect(controller.logOn(todayDate), isNotNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.logOn(todayDate), isNotNull);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(controller.logOn(todayDate), isNull);
    expect(
      find.text('No log yet. Tap Add log to edit this day.'),
      findsOneWidget,
    );
  });

  testWidgets('named controls are at least 44 px tall', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final controller = CycleController(
      localLogs: MemoryLogStore(),
      settings: MemorySettingsStore(disclaimerAccepted: true),
      auth: AuthService.disabled(),
    );
    await controller.bootstrap();
    await tester.pumpWidget(CycleaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.widgetWithText(Chip, 'Guest')).height,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(
      tester
          .getSize(find.widgetWithText(FilledButton, 'Log period range'))
          .height,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(SegmentedButton<ThemeMode>)).height,
      greaterThanOrEqualTo(44),
    );
    final deleteAll = find.widgetWithText(TextButton, 'Delete all Cyclea data');
    await tester.ensureVisible(deleteAll);
    await tester.pumpAndSettle();
    expect(tester.getSize(deleteAll).height, greaterThanOrEqualTo(44));
  });

  test('selected tab is restored after reload', () async {
    final settings = MemorySettingsStore(disclaimerAccepted: true);
    final first = CycleController(
      localLogs: MemoryLogStore(),
      settings: settings,
      auth: AuthService.disabled(),
      now: () => today,
    );
    await first.bootstrap();
    await first.setTabIndex(2);
    final second = CycleController(
      localLogs: MemoryLogStore(),
      settings: settings,
      auth: AuthService.disabled(),
      now: () => today,
    );
    await second.bootstrap();
    expect(second.tabIndex, 2);
  });

  test('privacy link drops an empty query and fragment', () {
    final uri = privacyPageUriFrom(
      Uri.parse('https://michaelady.github.io/Cyclea/?source=app#top'),
      onWeb: true,
    );
    expect(uri.toString(), 'https://michaelady.github.io/Cyclea/privacy.html');
    expect(uri.toString().contains('?'), isFalse);
    expect(uri.toString().contains('#'), isFalse);
  });

  test('dark home ring card text clears a 4.5 contrast ratio', () {
    final ratio = _contrast(
      CycleaColors.darkHeroText,
      CycleaColors.darkHeroEnd,
    );
    expect(ratio, greaterThanOrEqualTo(4.5));
    expect(
      _contrast(CycleaColors.darkHeroMuted, CycleaColors.darkHeroEnd),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('range picker keeps two quick taps and ignores a future day', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final realToday = dateOnly(DateTime.now());
    late DateTime start;
    late DateTime end;
    var changeMonth = false;
    if (realToday.day >= 8) {
      start = DateTime(realToday.year, realToday.month, realToday.day - 6);
      end = DateTime(realToday.year, realToday.month, realToday.day - 2);
    } else {
      final previous = DateTime(
        realToday.year,
        realToday.month,
        1,
      ).subtract(const Duration(days: 1));
      start = DateTime(previous.year, previous.month, 8);
      end = DateTime(previous.year, previous.month, 12);
      changeMonth = true;
    }

    final controller = CycleController(
      localLogs: MemoryLogStore(),
      settings: MemorySettingsStore(disclaimerAccepted: true),
      auth: AuthService.disabled(),
    );
    await controller.bootstrap();
    await tester.pumpWidget(CycleaApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log period range'));
    await tester.pumpAndSettle();

    if (realToday.day <
        DateUtils.getDaysInMonth(realToday.year, realToday.month)) {
      final future = DateTime(
        realToday.year,
        realToday.month,
        realToday.day + 1,
      );
      await tester.tap(find.byKey(Key('period-range-day-${dateKey(future)}')));
      await tester.pump();
      expect(find.text('Choose a start date'), findsOneWidget);
    }

    if (changeMonth) {
      await tester.tap(find.byKey(const Key('period-range-prev')));
      await tester.pump();
    }

    await tester.tap(find.byKey(Key('period-range-day-${dateKey(start)}')));
    await tester.tap(find.byKey(Key('period-range-day-${dateKey(end)}')));
    await tester.pump();

    expect(find.textContaining('End date'), findsNothing);
    final label =
        '${DateFormat.MMMd().format(start)} – ${DateFormat.MMMd().format(end)}';
    expect(find.text(label), findsOneWidget);

    await tester.tap(find.byKey(const Key('period-range-save')));
    await tester.pumpAndSettle();
    expect(controller.logOn(start)?.isPeriod, isTrue);
    expect(controller.logOn(end)?.isPeriod, isTrue);
    var cursor = start;
    while (!cursor.isAfter(end)) {
      expect(controller.logOn(cursor)?.isPeriod, isTrue, reason: '$cursor');
      cursor = cursor.add(const Duration(days: 1));
    }
  });
}

double _contrast(Color foreground, Color background) {
  final lighter = math.max(
    foreground.computeLuminance(),
    background.computeLuminance(),
  );
  final darker = math.min(
    foreground.computeLuminance(),
    background.computeLuminance(),
  );
  return (lighter + 0.05) / (darker + 0.05);
}
