import 'package:cyclea/app.dart';
import 'package:cyclea/data/auth_service.dart';
import 'package:cyclea/data/stores.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/widgets/auth_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('welcome shows guest and google options then home in guest mode', (tester) async {
    final controller = CycleController(
      localLogs: MemoryLogStore(),
      settings: MemorySettingsStore(),
      auth: AuthService.disabled(),
      now: () => DateTime(2026, 9, 14),
    );
    await controller.bootstrap();
    await tester.pumpWidget(CycleaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Cyclea'), findsWidgets);
    expect(find.textContaining('not a contraceptive'), findsWidgets);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text(AuthCopy.firebaseNeededTitle), findsOneWidget);
    await tester.tap(find.text('Keep using guest'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    expect(find.text('Cyclea'), findsWidgets);
    expect(find.textContaining('not medical advice'), findsWidgets);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('settings keeps google as an optional path beside guest', (tester) async {
    final controller = CycleController(
      localLogs: MemoryLogStore(),
      settings: MemorySettingsStore(disclaimerAccepted: true),
      auth: AuthService.disabled(),
      now: () => DateTime(2026, 9, 14),
    );
    await controller.bootstrap();
    await tester.pumpWidget(CycleaApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.textContaining('Guest mode remains fully usable'), findsOneWidget);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text(AuthCopy.firebaseNeededTitle), findsOneWidget);
    expect(find.textContaining('Guest mode stays fully usable'), findsOneWidget);
  });

  testWidgets('seeded demo data shows insights averages', (tester) async {
    final controller = CycleController(
      localLogs: MemoryLogStore(),
      settings: MemorySettingsStore(disclaimerAccepted: true),
      auth: AuthService.disabled(),
      now: () => DateTime(2026, 9, 14),
    );
    await controller.bootstrap();
    await controller.seedDemoData();
    await tester.pumpWidget(CycleaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Insights'), findsOneWidget);
    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    expect(find.text('Average cycle'), findsOneWidget);
    expect(find.textContaining('Not a diagnosis'), findsWidgets);
    expect(find.text('Early · on-time · late'), findsOneWidget);
  });

  testWidgets('botanical glyphs paint without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              CycleaIcon(CycleaGlyph.blossom, filled: true),
              CycleaIcon(CycleaGlyph.calendarBloom),
              CycleaIcon(CycleaGlyph.sprout, filled: true),
              CycleaIcon(CycleaGlyph.moon),
              CycleaIcon(CycleaGlyph.heartLeaf, filled: true),
              GoogleGMark(),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(CycleaIcon), findsNWidgets(5));
    expect(find.byType(GoogleGMark), findsOneWidget);
  });
}
