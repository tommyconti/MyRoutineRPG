import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/user_stats.dart';
import 'package:flutter/material.dart';

class StorageService {
  // Chiavi per SharedPreferences
  static const String _tasksKey = 'tasks';
  static const String _userStatsKey = 'user_stats';
  static const String _notificationTimesKey = 'notification_times';
  static const String _randomQuestCountKey = 'random_quest_count';
  static const String _randomQuestDateKey = 'random_quest_date';

  // Restituisce la lista delle quest salvate.
  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    if (tasksJson == null) return [];
    final List<dynamic> tasksList = json.decode(tasksJson);
    return tasksList.map((json) => Task.fromJson(json)).toList();
  }

  // Salva la lista delle quest.
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = json.encode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }

  // Restituisce le statistiche utente salvate.
  static Future<UserStats> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_userStatsKey);
    if (statsJson == null) return UserStats.initial;
    return UserStats.fromJson(json.decode(statsJson));
  }

  // Salva le statistiche utente.
  static Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = json.encode(stats.toJson());
    await prefs.setString(_userStatsKey, statsJson);
  }

  // Salva gli orari delle notifiche.
  static Future<void> saveNotificationTimes(List<TimeOfDay> times) async {
    final prefs = await SharedPreferences.getInstance();
    final timeStrings = times.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').toList();
    await prefs.setStringList(_notificationTimesKey, timeStrings);
  }

  // Restituisce gli orari delle notifiche salvati o i default.
  static Future<List<TimeOfDay>> getNotificationTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStrings = prefs.getStringList(_notificationTimesKey);
    if (timeStrings == null || timeStrings.length != 3) {
      return [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 15, minute: 0),
        const TimeOfDay(hour: 21, minute: 0),
      ];
    }
    return timeStrings.map((s) {
      final parts = s.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();
  }

  // Incrementa e restituisce il conteggio delle random quest di oggi.
  static Future<int> incrementRandomQuestCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastDate = prefs.getString(_randomQuestDateKey);
    int count = prefs.getInt(_randomQuestCountKey) ?? 0;
    if (lastDate != todayStr) {
      await prefs.setString(_randomQuestDateKey, todayStr);
      await prefs.setInt(_randomQuestCountKey, 1);
      return 1;
    } else {
      count++;
      await prefs.setInt(_randomQuestCountKey, count);
      return count;
    }
  }

  // Restituisce il conteggio delle random quest di oggi.
  static Future<int> getRandomQuestCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastDate = prefs.getString(_randomQuestDateKey);
    if (lastDate != todayStr) {
      return 0;
    }
    return prefs.getInt(_randomQuestCountKey) ?? 0;
  }
}