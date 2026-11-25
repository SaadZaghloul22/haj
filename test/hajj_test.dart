import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajj_guide/data/guide.dart';
import 'package:hajj_guide/main.dart';
import 'package:hajj_guide/state/hajj_state.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('season', () {
    test('Hajj 1448: Arafah falls in May 2027 (Umm al-Qura)', () {
      final s = HajjSeason.of(DateTime(2026, 11, 25));
      expect(s.hYear, 1448);
      expect(s.arafah.year, 2027);
      expect(s.arafah.month, 5);
      expect(s.eid.difference(s.arafah).inDays, 1);
      expect(s.hajjDayIndex, isNull);
      expect(s.daysToArafah, greaterThan(150));
    });

    test('during Hajj days the step index follows the day', () {
      final base = HajjSeason.of(DateTime(2026, 11, 25));
      final arafah = HajjSeason.of(base.arafah.add(const Duration(hours: 10)));
      expect(arafah.hYear, 1448);
      expect(arafah.hajjDayIndex, 1);
      expect(arafah.daysToArafah, 0);
      final after = HajjSeason.of(base.lastTashreeq.add(const Duration(days: 1)));
      expect(after.hYear, 1449);
    });

    test('offset shifts the dates', () {
      final a = HajjSeason.of(DateTime(2026, 11, 25));
      final b = HajjSeason.of(DateTime(2026, 11, 25), offset: 1);
      expect(b.arafah.difference(a.arafah).inDays, 1);
    });
  });

  group('content', () {
    test('ids unique, every step has points, every dua has a source', () {
      final ids = [for (final g in guides) ...g.steps.map((s) => s.id)];
      expect(ids.toSet().length, ids.length);
      for (final g in guides) {
        for (final s in g.steps) {
          expect(s.points, isNotEmpty, reason: s.id);
        }
      }
      for (final d in allDuas) {
        expect(d.source.trim(), isNotEmpty, reason: d.title);
        expect(d.text.trim(), isNotEmpty, reason: d.title);
      }
      expect(umrah.steps.length, 8);
      expect(mawaqit.length, 5);
      expect(checklist.map((c) => c.$1).toSet().length, checklist.length);
    });

    test('Umrah order: ihram, tawaf, sai, shaving', () {
      final t = umrah.steps.map((s) => s.title).toList();
      int at(String w) => t.indexWhere((x) => x.contains(w));
      expect(at('الإحرام من الميقات') < at('الطواف'), isTrue);
      expect(at('الطواف') < at('السعي'), isTrue);
      expect(at('السعي') < at('الحلق'), isTrue);
    });
  });

  group('state', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('progress, checklist and counters persist', () async {
      final prefs = await SharedPreferences.getInstance();
      final c = HajjController(prefs);
      await c.setDone('u1', true);
      await c.setChecked('doc1', true);
      await c.setCount('tawaf', 9);
      final again = HajjController(prefs);
      expect(again.isDone('u1'), isTrue);
      expect(again.doneIn(['u1', 'u2']), 1);
      expect(again.isChecked('doc1'), isTrue);
      expect(again.count('tawaf'), 7);
      await again.resetDone(['u1']);
      expect(again.isDone('u1'), isFalse);
    });
  });

  testWidgets('home renders and opens the counter', (tester) async {
    await initializeDateFormatting('ar');
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ChangeNotifierProvider(create: (_) => HajjController(prefs), child: const HajjApp()));
    await tester.pumpAndSettle();
    expect(find.text('العمرة خطوة بخطوة'), findsOneWidget);
    await tester.ensureVisible(find.text('عداد الطواف والسعي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عداد الطواف والسعي'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('counter-tap')));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.textContaining('الشوط 2'), findsOneWidget);
  });
}
