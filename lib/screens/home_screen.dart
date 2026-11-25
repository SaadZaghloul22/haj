import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/guide.dart';
import '../state/hajj_state.dart';
import 'counter_screen.dart';
import 'guide_screen.dart';
import 'reference_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<HajjController>();
    void open(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    final tiles = <_Tile>[
      _Tile('العمرة خطوة بخطوة', Icons.mosque_outlined, '${s.doneIn(umrah.steps.map((e) => e.id))}/${umrah.steps.length} خطوات',
          () => open(const GuideScreen(umrah))),
      _Tile('الحج يوماً بيوم', Icons.terrain_outlined, '${s.doneIn(hajj.steps.map((e) => e.id))}/${hajj.steps.length} مراحل',
          () => open(const GuideScreen(hajj))),
      _Tile('عداد الطواف والسعي', Icons.timelapse, 'لا تنسَ عدد الأشواط', () => open(const CounterScreen())),
      _Tile('الأدعية والأذكار', Icons.auto_awesome_outlined, '${allDuas.length} ذكراً بمصادرها', () => open(const DuasScreen())),
      _Tile('المواقيت', Icons.place_outlined, '5 مواقيت', () => open(const MawaqitScreen())),
      _Tile('محظورات الإحرام', Icons.block, '${restrictions.length} محظورات', () => open(const RestrictionsScreen())),
      _Tile('الأركان والواجبات', Icons.rule, 'للحج والعمرة', () => open(const PillarsScreen())),
      _Tile('قائمة التجهيز', Icons.luggage_outlined, '${s.checkedCount}/${checklist.length}', () => open(const ChecklistScreen())),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل الحج والعمرة'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => v == 'about' ? open(const AboutScreen()) : s.setThemeMode(int.parse(v)),
            itemBuilder: (_) => [
              CheckedPopupMenuItem(value: '0', checked: s.themeMode == 0, child: const Text('مظهر النظام')),
              CheckedPopupMenuItem(value: '1', checked: s.themeMode == 1, child: const Text('فاتح')),
              CheckedPopupMenuItem(value: '2', checked: s.themeMode == 2, child: const Text('داكن')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'about', child: Text('عن التطبيق والمصادر')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _SeasonCard(season: s.season()),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [for (final t in tiles) _TileCard(t)],
          ),
        ],
      ),
    );
  }
}

class _Tile {
  const _Tile(this.title, this.icon, this.sub, this.onTap);
  final String title;
  final IconData icon;
  final String sub;
  final VoidCallback onTap;
}

class _TileCard extends StatelessWidget {
  const _TileCard(this.t);
  final _Tile t;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: t.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: scheme.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
              child: Icon(t.icon, color: scheme.primary),
            ),
            const Spacer(),
            Text(t.title, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.3)),
            Text(t.sub, style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: .6))),
          ]),
        ),
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.season});
  final HajjSeason season;

  static const _dayNames = ['يوم التروية', 'يوم عرفة', 'يوم النحر (العيد)', 'أول أيام التشريق', 'ثاني أيام التشريق', 'ثالث أيام التشريق'];
  static const _stepIds = ['h8', 'h9', 'h10', 'h11', 'h11', 'h11'];

  @override
  Widget build(BuildContext context) {
    final idx = season.hajjDayIndex;
    final d = season.daysToArafah;
    final fmt = DateFormat('EEEE d MMMM yyyy', 'ar');
    const white = Colors.white;
    final muted = Colors.white.withValues(alpha: .8);
    return Container(
      key: const Key('season'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [HajjColors.tealMid, HajjColors.teal],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('موسم حج ${season.hYear}هـ', style: TextStyle(color: muted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        if (idx != null) ...[
          Text('اليوم: ${_dayNames[idx]}', style: const TextStyle(color: white, fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: () {
              final i = hajj.steps.indexWhere((e) => e.id == _stepIds[idx]);
              Navigator.push(context, MaterialPageRoute(builder: (_) => StepScreen(guide: hajj, index: i)));
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('أعمال اليوم'),
          ),
        ] else ...[
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$d', style: const TextStyle(color: white, fontSize: 44, fontWeight: FontWeight.w800, height: 1)),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(d == 1 ? 'يوم على يوم عرفة' : (d <= 10 ? 'أيام على يوم عرفة' : 'يوماً على يوم عرفة'),
                  style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 8),
          Text('يوم عرفة: ${fmt.format(season.arafah)}', style: TextStyle(color: muted)),
          Text('عيد الأضحى: ${fmt.format(season.eid)}', style: TextStyle(color: muted)),
        ],
        const SizedBox(height: 6),
        Text('حسب تقويم أم القرى، وقد يختلف يوماً حسب الرؤية.', style: TextStyle(color: muted, fontSize: 11)),
      ]),
    );
  }
}
