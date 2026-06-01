import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService with ChangeNotifier {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Centralized storage engine write pipeline
  Future<void> write(String key, dynamic value) async {
    final db = await _instance;
    final String stringPayload = value is String ? value : jsonEncode(value);
    await db.setString(key, stringPayload);
    // Alert downstream components using proxy pipelines that a state shift occurred
    notifyListeners();
  }

  /// Centralized storage engine read pipeline
  Future<dynamic> read(String key) async {
    final db = await _instance;
    final rawData = db.getString(key);
    if (rawData == null) return null;
    try {
      return jsonDecode(rawData);
    } catch (_) {
      return rawData;
    }
  }

  Future<void> delete(String key) async {
    final db = await _instance;
    await db.remove(key);
    notifyListeners();
  }

  /// Explicitly evict cache targets when critical dependencies change (like subjects)
  Future<void> clearTargetCaches(String uid) async {
    final db = await _instance;
    await db.remove('tasks_cache_$uid');
    await db.remove('semester_progress_cache_$uid');
    await db.remove('dashboard_cache_$uid');
    await db.remove('study_plan_tasks_$uid');
    await db.remove('study_plan_week_$uid');
    await db.remove('burnout_alert_cache_$uid');
    notifyListeners();
  }
}