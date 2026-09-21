import 'dart:async';

import 'package:cyclea/data/auth_service.dart';
import 'package:cyclea/data/firestore_store.dart';
import 'package:cyclea/data/stores.dart';
import 'package:cyclea/domain/advice.dart';
import 'package:cyclea/domain/cycle_stats.dart';
import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:cyclea/domain/flow_level.dart';
import 'package:cyclea/domain/prediction.dart';
import 'package:cyclea/services/advice_engine.dart';
import 'package:cyclea/services/cycle_math.dart';
import 'package:cyclea/services/demo_data.dart';
import 'package:cyclea/services/prediction_service.dart';
import 'package:flutter/material.dart';

class CycleController extends ChangeNotifier {
  CycleController({
    required this.localLogs,
    required this.settings,
    required this.auth,
    this.now,
  });

  final LogStore localLogs;
  final SettingsStore settings;
  final AuthService auth;
  final DateTime Function()? now;

  final Map<String, DailyLog> _logs = {};
  AuthUser? _user;
  ThemeMode _themeMode = ThemeMode.system;
  bool _disclaimerAccepted = false;
  bool _loading = true;
  String? _error;
  String _syncLabel = 'Local only';
  LogStore? _remote;

  DateTime get _today => dateOnly(now?.call() ?? DateTime.now());

  bool get loading => _loading;
  String? get error => _error;
  AuthUser? get user => _user;
  ThemeMode get themeMode => _themeMode;
  bool get disclaimerAccepted => _disclaimerAccepted;
  bool get firebaseReady => auth.firebaseReady;
  bool get isGuest => _user == null;
  String get syncLabel => _syncLabel;
  List<DailyLog> get logs => _logs.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  DailyLog? logOn(DateTime date) => _logs[dateKey(date)];

  CycleStats get stats => CycleMath.statsFor(_logs.values, now: _today);

  CyclePrediction get prediction => PredictionService.predict(stats, now: _today);

  List<AdviceCard> get adviceCards =>
      AdviceEngine.cardsFor(stats: stats, prediction: prediction);

  Future<void> bootstrap() async {
    _loading = true;
    notifyListeners();
    try {
      _disclaimerAccepted = await settings.disclaimerAccepted();
      _themeMode = await settings.themeMode();
      _logs
        ..clear()
        ..addAll(await localLogs.loadAll());
      final firstAuth = Completer<void>();
      auth.authStateChanges().listen((user) async {
        await _onAuth(user);
        if (!firstAuth.isCompleted) firstAuth.complete();
      });
      await firstAuth.future.timeout(const Duration(seconds: 5));
      _error = null;
    } catch (error, stack) {
      _error = error.toString();
      debugPrint('Bootstrap failed: $error\n$stack');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _onAuth(AuthUser? user) async {
    _user = user;
    if (user == null) {
      _remote = null;
      _syncLabel = firebaseReady
          ? 'Guest — stored on this device'
          : 'Guest — Firebase not configured';
      notifyListeners();
      return;
    }
    _syncLabel = 'Syncing with Google account…';
    notifyListeners();
    try {
      _remote = FirestoreLogStore(user.uid);
      await _mergeRemote();
      _syncLabel = 'Synced to ${user.email ?? 'your Google account'}';
      _error = null;
    } catch (error, stack) {
      _syncLabel = 'Signed in, but cloud sync failed';
      _error = 'Sync error: $error';
      debugPrint('Sync failed: $error\n$stack');
    }
    notifyListeners();
  }

  Future<void> _mergeRemote() async {
    final remote = _remote;
    if (remote == null) return;
    final remoteLogs = await remote.loadAll();
    final merged = <String, DailyLog>{..._logs};
    for (final entry in remoteLogs.entries) {
      final local = merged[entry.key];
      if (local == null || !local.updatedAt.isAfter(entry.value.updatedAt)) {
        merged[entry.key] = entry.value;
      }
    }
    _logs
      ..clear()
      ..addAll(merged);
    await localLogs.upsertAll(merged.values);
    await remote.upsertAll(merged.values);
  }

  Future<void> acceptDisclaimer() async {
    _disclaimerAccepted = true;
    await settings.setDisclaimerAccepted(true);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await settings.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> saveLog(DailyLog log) async {
    final cleaned = log.copyWith(
      date: dateOnly(log.date),
      isPeriod: log.isPeriod || log.flow.isBleeding,
      flow: log.isPeriod || log.flow.isBleeding ? log.flow : FlowLevel.none,
      updatedAt: DateTime.now().toUtc(),
    );
    if (cleaned.isEmpty) {
      await deleteLog(cleaned.date);
      return;
    }
    _logs[dateKey(cleaned.date)] = cleaned;
    await localLogs.upsert(cleaned);
    await _remote?.upsert(cleaned);
    notifyListeners();
  }

  Future<void> deleteLog(DateTime date) async {
    _logs.remove(dateKey(date));
    await localLogs.delete(date);
    await _remote?.delete(date);
    notifyListeners();
  }

  Future<void> markPeriodRange(DateTime start, DateTime end, {FlowLevel? flow}) async {
    final first = dateOnly(start);
    final last = dateOnly(end);
    final from = first.isBefore(last) ? first : last;
    final to = first.isBefore(last) ? last : first;
    final days = daysInRange(from, to).toList();
    for (var i = 0; i < days.length; i++) {
      final existing = logOn(days[i]);
      final autoFlow = flow ??
          (i == 0
              ? FlowLevel.heavy
              : i == days.length - 1
              ? FlowLevel.light
              : FlowLevel.medium);
      await saveLog(
        DailyLog(
          date: days[i],
          isPeriod: true,
          flow: autoFlow,
          symptomIds: existing?.symptomIds ?? {},
          notes: existing?.notes ?? '',
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }

  Future<void> seedDemoData() async {
    final demo = DemoData.generate(now: _today);
    for (final log in demo) {
      _logs[dateKey(log.date)] = log;
    }
    await localLogs.upsertAll(demo);
    await _remote?.upsertAll(demo);
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    _logs.clear();
    await localLogs.clear();
    await _remote?.clear();
    notifyListeners();
  }

  Future<AuthUser?> signIn() async {
    if (!firebaseReady) {
      throw const FirebaseNotConfiguredException();
    }
    try {
      final user = await auth.signInWithGoogle();
      _error = null;
      return user;
    } catch (error) {
      _error = 'Google sign-in failed: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}

class AppScope extends InheritedNotifier<CycleController> {
  const AppScope({
    super.key,
    required CycleController controller,
    required super.child,
  }) : super(notifier: controller);

  static CycleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}
