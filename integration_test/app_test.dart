import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajj_guide/main.dart' as app;
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Walks through every screen on the emulator and captures screenshots.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester t, [int ms = 1200]) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> tapText(WidgetTester t, String text) async {
    final f = find.text(text).hitTestable().evaluate().isNotEmpty ? find.text(text).hitTestable().first : find.text(text).first;
    await t.ensureVisible(f);
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(f, warnIfMissed: false);
  }

  Future<void> back(WidgetTester t) async {
    app.navigatorKey.currentState!.pop();
    await settle(t);
  }

  testWidgets('screens render', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setInt('theme', 1);
    app.main();
    await settle(tester, 2500);
    await binding.convertFlutterSurfaceToImage();
    await settle(tester, 300);
    expect(find.textContaining('موسم حج'), findsOneWidget);
    await binding.takeScreenshot('01_home');

    await tapText(tester, 'العمرة خطوة بخطوة');
    await settle(tester);
    await binding.takeScreenshot('02_umrah_steps');
    await tapText(tester, 'الطواف — سبعة أشواط');
    await settle(tester);
    expect(find.textContaining('يضطبع الرجل'), findsOneWidget);
    await binding.takeScreenshot('03_step_tawaf');
    await tester.tap(find.byKey(const Key('step-done')));
    await settle(tester, 1500);
    await binding.takeScreenshot('04_step_rak3atain');
    await back(tester);
    await binding.takeScreenshot('05_umrah_progress');
    await back(tester);

    await tapText(tester, 'الحج يوماً بيوم');
    await settle(tester);
    await binding.takeScreenshot('06_hajj_days');
    await tapText(tester, 'يوم عرفة — 9 ذي الحجة');
    await settle(tester);
    await binding.takeScreenshot('07_step_arafah');
    await tester.drag(find.byType(ListView).last, const Offset(0, -900));
    await settle(tester);
    await binding.takeScreenshot('08_arafah_dua');
    await back(tester);
    await back(tester);

    await tapText(tester, 'عداد الطواف والسعي');
    await settle(tester);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('counter-tap')));
      await settle(tester, 300);
    }
    expect(find.text('3'), findsOneWidget);
    await binding.takeScreenshot('09_counter_tawaf');
    await tapText(tester, 'السعي');
    await settle(tester);
    await tester.tap(find.byKey(const Key('counter-tap')));
    await settle(tester, 300);
    expect(find.textContaining('من المروة إلى الصفا'), findsOneWidget);
    await binding.takeScreenshot('10_counter_sai');
    await back(tester);

    await tapText(tester, 'الأدعية والأذكار');
    await settle(tester);
    await binding.takeScreenshot('11_duas');
    await back(tester);
    await tapText(tester, 'المواقيت');
    await settle(tester);
    await binding.takeScreenshot('12_mawaqit');
    await back(tester);
    await tapText(tester, 'محظورات الإحرام');
    await settle(tester);
    await binding.takeScreenshot('13_restrictions');
    await back(tester);
    await tapText(tester, 'الأركان والواجبات');
    await settle(tester);
    await binding.takeScreenshot('14_pillars');
    await back(tester);
    await tapText(tester, 'قائمة التجهيز');
    await settle(tester);
    await tapText(tester, 'جواز السفر والهوية');
    await settle(tester, 600);
    await binding.takeScreenshot('15_checklist');
    await back(tester);

    // Dark theme
    await prefs.setInt('theme', 2);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await settle(tester);
    await tapText(tester, 'داكن');
    await settle(tester, 1500);
    await binding.takeScreenshot('16_home_dark');
  });
}
