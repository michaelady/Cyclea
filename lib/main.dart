import 'package:cyclea/app.dart';
import 'package:cyclea/data/auth_service.dart';
import 'package:cyclea/data/firebase_gate.dart';
import 'package:cyclea/data/hive_store.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebase = await FirebaseGate.tryInit();
  await Hive.initFlutter();
  final logsBox = await Hive.openBox<String>(HiveLogStore.boxName);
  final settingsBox = await Hive.openBox<dynamic>(HiveSettingsStore.boxName);
  final controller = CycleController(
    localLogs: HiveLogStore(logsBox),
    settings: HiveSettingsStore(settingsBox),
    auth: AuthService(firebase),
  );
  await controller.bootstrap();
  runApp(CycleaApp(controller: controller));
}
