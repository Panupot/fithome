import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A completed workout session record.
class SessionRecord {
  final DateTime date;
  final String programName;
  final int minutes;
  final int exerciseCount;

  SessionRecord({
    required this.date,
    required this.programName,
    required this.minutes,
    required this.exerciseCount,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'programName': programName,
        'minutes': minutes,
        'exerciseCount': exerciseCount,
      };

  static SessionRecord fromJson(Map<String, dynamic> j) => SessionRecord(
        date: DateTime.parse(j['date'] as String),
        programName: (j['programName'] ?? '') as String,
        minutes: (j['minutes'] ?? 0) as int,
        exerciseCount: (j['exerciseCount'] ?? 0) as int,
      );
}

class Store {
  static SharedPreferences? _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  // ---------- language ----------
  static String get lang => _p?.getString('lang') ?? 'th';
  static Future<void> setLang(String v) async => _p?.setString('lang', v);

  // ---------- reminder ----------
  static bool get reminderOn => _p?.getBool('reminderOn') ?? false;
  static int get reminderHour => _p?.getInt('reminderHour') ?? 18;
  static int get reminderMinute => _p?.getInt('reminderMinute') ?? 0;

  static Future<void> setReminder(bool on, int hour, int minute) async {
    await _p?.setBool('reminderOn', on);
    await _p?.setInt('reminderHour', hour);
    await _p?.setInt('reminderMinute', minute);
  }

  // ---------- history ----------
  static List<SessionRecord> get history {
    final raw = _p?.getString('history');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SessionRecord.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }

  static Future<void> addSession(SessionRecord r) async {
    final list = history..insert(0, r);
    await _p?.setString(
        'history', jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearHistory() async => _p?.remove('history');

  // ---------- stats ----------
  static int get totalSessions => history.length;

  static int get sessionsThisWeek {
    final now = DateTime.now();
    final monday =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return history.where((r) => !r.date.isBefore(monday)).length;
  }

  static int get streakDays {
    final dates = history
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet();
    if (dates.isEmpty) return 0;
    var day = DateTime.now();
    var d = DateTime(day.year, day.month, day.day);
    // Streak may start today or yesterday.
    if (!dates.contains(d)) {
      d = d.subtract(const Duration(days: 1));
      if (!dates.contains(d)) return 0;
    }
    var streak = 0;
    while (dates.contains(d)) {
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
