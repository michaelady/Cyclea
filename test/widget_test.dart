import 'package:cyclea/app.dart';
import 'package:cyclea/data/auth_service.dart';
import 'package:cyclea/data/stores.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('disclaimer gate then home in guest mode', (tester) async {
    final controller = CycleController(
      localLogs: MemoryLogStore(),
      settings: MemorySettingsStore(),
      auth: AuthService.disabled(),
      now: () => DateTime(2026, 9, 14),
    );
    await controller.bootstrap();
    await tester.pumpWidget(CycleaApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Cyclea'), findsOneWidget);
    expect(find.textContaining('not a contraceptive'), findsWidgets);

    await tester.tap(find.text('I understand — continue'));
    await tester.pumpAndSettle();

    expect(find.text('Cyclea'), findsWidgets);
    expect(find.textContaining('not medical advice'), findsWidgets);
    expect(find.text('Guest'), findsOneWidget);
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
}
