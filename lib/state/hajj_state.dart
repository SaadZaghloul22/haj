import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dates of the coming (or current) Hajj season, from the Umm al-Qura calendar.
class HajjSeason {
  const HajjSeason({required this.hYear, required this.tarwiyah, required this.now});

  final int hYear;

  /// 8 Dhul-Hijjah.
  final DateTime tarwiyah;
  final DateTime now;

  DateTime get arafah => tarwiyah.add(const Duration(days: 1));
  DateTime get eid => tarwiyah.add(const Duration(days: 2));
  DateTime get lastTashreeq => tarwiyah.add(const Duration(days: 5));

  DateTime get _today => DateTime(now.year, now.month, now.day);

  /// Days left until Arafah (0 on the day).
  int get daysToArafah => arafah.difference(_today).inDays;

  /// 8..13 Dhul-Hijjah: index of today's guide step, else null.
  int? get hajjDayIndex {
    final d = _today.difference(tarwiyah).inDays;
    return d >= 0 && d <= 5 ? d : null;
  }

  static DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime tarwiyahOf(int hYear, int offset) =>
      _date(HijriCalendar().hijriToGregorian(hYear, 12, 8)).add(Duration(days: offset));

  /// This year's season until its last day of Tashreeq, then next year's.
  static HajjSeason of(DateTime now, {int offset = 0}) {
    final today = _date(now);
    var y = HijriCalendar.fromDate(today.subtract(Duration(days: offset))).hYear;
    var t = tarwiyahOf(y, offset);
    if (today.isAfter(t.add(const Duration(days: 5)))) {
      y++;
      t = tarwiyahOf(y, offset);
    }
    return HajjSeason(hYear: y, tarwiyah: t, now: now);
  }
}

/// Progress, checklist, counters and settings — all kept on the device.
class HajjController extends ChangeNotifier {
  HajjController(this._prefs) {
    _done = (_prefs.getStringList(_doneKey) ?? const []).toSet();
    _checked = (_prefs.getStringList(_checkKey) ?? const []).toSet();
    try {
      final raw = _prefs.getString(_countKey);
      if (raw != null) {
        (jsonDecode(raw) as Map).forEach((k, v) {
          if (v is int) _counts['$k'] = v;
        });
      }
    } catch (_) {}
  }

  final SharedPreferences _prefs;
  static const _doneKey = 'done_steps';
  static const _checkKey = 'checklist';
  static const _countKey = 'counters';
  static const _themeKey = 'theme';
  static const _offsetKey = 'hijri_offset';
  static const _menKey = 'is_man';

  late Set<String> _done;
  late Set<String> _checked;
  final Map<String, int> _counts = {};

  bool isDone(String id) => _done.contains(id);
  int doneIn(Iterable<String> ids) => ids.where(_done.contains).length;

  Future<void> setDone(String id, bool v) async {
    v ? _done.add(id) : _done.remove(id);
    await _prefs.setStringList(_doneKey, _done.toList());
    notifyListeners();
  }

  Future<void> resetDone(Iterable<String> ids) async {
    _done.removeAll(ids);
    await _prefs.setStringList(_doneKey, _done.toList());
    notifyListeners();
  }

  bool isChecked(String id) => _checked.contains(id);
  int get checkedCount => _checked.length;

  Future<void> setChecked(String id, bool v) async {
    v ? _checked.add(id) : _checked.remove(id);
    await _prefs.setStringList(_checkKey, _checked.toList());
    notifyListeners();
  }

  Future<void> clearChecklist() async {
    _checked.clear();
    await _prefs.setStringList(_checkKey, const []);
    notifyListeners();
  }

  /// Round counters ('tawaf' / 'sai'), kept across restarts so a closed app loses nothing.
  int count(String kind) => _counts[kind] ?? 0;

  Future<void> setCount(String kind, int v) async {
    _counts[kind] = v.clamp(0, 7);
    await _prefs.setString(_countKey, jsonEncode(_counts));
    notifyListeners();
  }

  /// Shows the men-only sunan (ramal, idtiba', jogging between the green lights).
  bool get isMan => _prefs.getBool(_menKey) ?? true;
  Future<void> setMan(bool v) async {
    await _prefs.setBool(_menKey, v);
    notifyListeners();
  }

  /// 0 = system, 1 = light, 2 = dark.
  int get themeMode => _prefs.getInt(_themeKey) ?? 0;
  Future<void> setThemeMode(int m) async {
    await _prefs.setInt(_themeKey, m);
    notifyListeners();
  }

  /// Day correction for the Hijri date (-1, 0, +1) to match the local announcement.
  int get hijriOffset => _prefs.getInt(_offsetKey) ?? 0;
  Future<void> setHijriOffset(int v) async {
    await _prefs.setInt(_offsetKey, v.clamp(-2, 2));
    notifyListeners();
  }

  HajjSeason season([DateTime? now]) => HajjSeason.of(now ?? DateTime.now(), offset: hijriOffset);
}
