import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyclea/data/stores.dart';
import 'package:cyclea/domain/daily_log.dart';
import 'package:cyclea/domain/dates.dart';
import 'package:flutter/foundation.dart';

class FirestoreLogStore implements LogStore {
  FirestoreLogStore(this.uid, {FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _logs =>
      _db.collection('users').doc(uid).collection('logs');

  @override
  Future<Map<String, DailyLog>> loadAll() async {
    final snapshot = await _logs.get();
    final result = <String, DailyLog>{};
    for (final doc in snapshot.docs) {
      try {
        final log = DailyLog.fromJson(doc.data());
        result[dateKey(log.date)] = log;
      } catch (error) {
        debugPrint('Skipped remote log ${doc.id}: $error');
      }
    }
    return result;
  }

  @override
  Future<void> upsert(DailyLog log) async {
    await _logs.doc(dateKey(log.date)).set(log.toJson());
  }

  @override
  Future<void> upsertAll(Iterable<DailyLog> logs) async {
    var batch = _db.batch();
    var count = 0;
    for (final log in logs) {
      batch.set(_logs.doc(dateKey(log.date)), log.toJson());
      count += 1;
      if (count >= 400) {
        await batch.commit();
        batch = _db.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
  }

  @override
  Future<void> delete(DateTime date) async {
    await _logs.doc(dateKey(date)).delete();
  }

  @override
  Future<void> clear() async {
    final snapshot = await _logs.get();
    var batch = _db.batch();
    var count = 0;
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
      count += 1;
      if (count >= 400) {
        await batch.commit();
        batch = _db.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
  }
}
