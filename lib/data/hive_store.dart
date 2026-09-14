import 'dart:convert';

import 'package:cyclea/data/stores.dart';
import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveLogStore implements LogStore {
  HiveLogStore(this._box);

  final Box<String> _box;

  static const boxName = 'cyclea_daily_logs';

  @override
  Future<Map<String, DailyLog>> loadAll() async {
    final result = <String, DailyLog>{};
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final log = DailyLog.fromJson(decoded);
          result[dateKey(log.date)] = log;
        } else if (decoded is Map) {
          final log = DailyLog.fromJson(Map<String, dynamic>.from(decoded));
          result[dateKey(log.date)] = log;
        }
      } catch (error) {
        debugPrint('Skipped corrupt log $key: $error');
      }
    }
    return result;
  }

  @override
  Future<void> upsert(DailyLog log) async {
    await _box.put(dateKey(log.date), jsonEncode(log.toJson()));
  }

  @override
  Future<void> upsertAll(Iterable<DailyLog> logs) async {
    final entries = <String, String>{
      for (final log in logs) dateKey(log.date): jsonEncode(log.toJson()),
    };
    await _box.putAll(entries);
  }

  @override
  Future<void> delete(DateTime date) async {
    await _box.delete(dateKey(date));
  }

  @override
  Future<void> clear() async => _box.clear();
}

class HiveSettingsStore implements SettingsStore {
  HiveSettingsStore(this._box);

  final Box<dynamic> _box;

  static const boxName = 'cyclea_settings';
  static const _disclaimerKey = 'disclaimerAccepted';
  static const _themeKey = 'themeMode';

  @override
  Future<bool> disclaimerAccepted() async =>
      _box.get(_disclaimerKey, defaultValue: false) == true;

  @override
  Future<void> setDisclaimerAccepted(bool value) async {
    await _box.put(_disclaimerKey, value);
  }

  @override
  Future<ThemeMode> themeMode() async {
    final raw = _box.get(_themeKey, defaultValue: 'system') as String;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(_themeKey, mode.name);
  }
}
