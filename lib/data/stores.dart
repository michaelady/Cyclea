import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:flutter/material.dart';

abstract class LogStore {
  Future<Map<String, DailyLog>> loadAll();
  Future<void> upsert(DailyLog log);
  Future<void> upsertAll(Iterable<DailyLog> logs);
  Future<void> delete(DateTime date);
  Future<void> clear();
}

abstract class SettingsStore {
  Future<bool> disclaimerAccepted();
  Future<void> setDisclaimerAccepted(bool value);
  Future<ThemeMode> themeMode();
  Future<void> setThemeMode(ThemeMode mode);
}

class MemoryLogStore implements LogStore {
  MemoryLogStore([Map<String, DailyLog>? seed]) : _logs = {...?seed};

  final Map<String, DailyLog> _logs;

  @override
  Future<Map<String, DailyLog>> loadAll() async => Map.of(_logs);

  @override
  Future<void> upsert(DailyLog log) async {
    _logs[dateKey(log.date)] = log;
  }

  @override
  Future<void> upsertAll(Iterable<DailyLog> logs) async {
    for (final log in logs) {
      _logs[dateKey(log.date)] = log;
    }
  }

  @override
  Future<void> delete(DateTime date) async {
    _logs.remove(dateKey(date));
  }

  @override
  Future<void> clear() async => _logs.clear();
}

class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore({
    bool disclaimerAccepted = false,
    ThemeMode themeMode = ThemeMode.system,
  }) : _disclaimer = disclaimerAccepted,
       _theme = themeMode;

  bool _disclaimer;
  ThemeMode _theme;

  @override
  Future<bool> disclaimerAccepted() async => _disclaimer;

  @override
  Future<void> setDisclaimerAccepted(bool value) async => _disclaimer = value;

  @override
  Future<ThemeMode> themeMode() async => _theme;

  @override
  Future<void> setThemeMode(ThemeMode mode) async => _theme = mode;
}
