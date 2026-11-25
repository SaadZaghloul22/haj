import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hajj_guide/data/guide.dart';
import 'package:hajj_guide/main.dart';
import 'package:hajj_guide/screens/counter_screen.dart';
import 'package:hajj_guide/screens/guide_screen.dart';
import 'package:hajj_guide/screens/reference_screens.dart';
import 'package:hajj_guide/state/hajj_state.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders every screen at phone size with the real fonts and writes PNGs to screenshots/.
Future<void> loadFonts() async {
  Future<void> family(String name, List<String> assets) async {
    final l = FontLoader(name);
    for (final a in assets) {
      l.addFont(rootBundle.load(a));
    }
    await l.load();
  }

  await family('Cairo', [
    'assets/fonts/Cairo_400Regular.ttf',
    'assets/fonts/Cairo_600SemiBold.ttf',
    'assets/fonts/Cairo_700Bold.ttf',
    'assets/fonts/Cairo_800ExtraBold.ttf',
  ]);
  await family('Amiri', ['assets/fonts/Amiri_400Regular.ttf', 'assets/fonts/Amiri_700Bold.ttf']);
  await family('MaterialIcons', ['fonts/MaterialIcons-Regular.otf']);
}

void main() {
  const size = Size(412, 915);
  const ratio = 2.625;
  final shotKey = GlobalKey();

  Future<void> settle(WidgetTester t, [int ms = 800]) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> shot(WidgetTester t, String name) async {
    await settle(t, 500);
    await t.runAsync(() async {
      final ro = shotKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await ro.toImage(pixelRatio: ratio);
      final png = await img.toByteData(format: ui.ImageByteFormat.png);
      File('screenshots/$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  testWidgets('store and review screenshots', (tester) async {
    await initializeDateFormatting('ar');
    await loadFonts();
    tester.view.physicalSize = size * ratio;
    tester.view.devicePixelRatio = ratio;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'theme': 1});
    final prefs = await SharedPreferences.getInstance();
    final s = HajjController(prefs);
    await s.setDone('u1', true);
    await s.setDone('u2', true);
    await s.setDone('u3', true);

    await tester.pumpWidget(RepaintBoundary(
      key: shotKey,
      child: ChangeNotifierProvider.value(value: s, child: const HajjApp()),
    ));
    await settle(tester, 1000);
    await shot(tester, '01_home');

    final nav = navigatorKey.currentState!;
    Future<void> open(Widget w, String name, {Future<void> Function()? then}) async {
      nav.push(MaterialPageRoute(builder: (_) => w));
      await settle(tester, 900);
      await shot(tester, name);
      if (then != null) await then();
      nav.pop();
      await settle(tester, 600);
    }

    await open(const GuideScreen(umrah), '02_umrah_steps');
    await open(StepScreen(guide: umrah, index: 3), '03_step_tawaf', then: () async {
      await tester.drag(find.byType(ListView).last, const Offset(0, -1200));
      await settle(tester);
      await shot(tester, '04_tawaf_duas');
    });
    await open(StepScreen(guide: umrah, index: 6), '05_step_sai');
    await open(const GuideScreen(hajj), '06_hajj_days');
    await open(StepScreen(guide: hajj, index: 2), '07_step_arafah');
    await open(StepScreen(guide: hajj, index: 4), '08_step_eid');
    await s.setCount('tawaf', 3);
    await open(const CounterScreen(), '09_counter_tawaf');
    await s.setCount('sai', 4);
    await open(const CounterScreen(initial: 'sai'), '10_counter_sai');
    await open(const DuasScreen(), '11_duas');
    await open(const MawaqitScreen(), '12_mawaqit');
    await open(const RestrictionsScreen(), '13_restrictions');
    await open(const PillarsScreen(), '14_pillars');
    await s.setChecked('doc1', true);
    await s.setChecked('ihr1', true);
    await open(const ChecklistScreen(), '15_checklist');
    await s.setThemeMode(2);
    await settle(tester);
    await shot(tester, '16_home_dark');
    await open(StepScreen(guide: umrah, index: 6), '17_step_sai_dark');
  });
}
