import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/guide.dart';
import '../state/hajj_state.dart';
import '../widgets/common.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الأدعية والأذكار')),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: allDuas.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => i == 0
              ? const InfoCard(
                  child: Text(
                    'لا يوجد دعاء مخصوص لكل شوط من أشواط الطواف أو السعي؛ ادعُ بما شئت من خيري الدنيا والآخرة. '
                    'هذه الأذكار ثابتة بأسانيدها.',
                    style: TextStyle(height: 1.6),
                  ),
                )
              : DuaCard(allDuas[i - 1]),
        ),
      );
}

class MawaqitScreen extends StatelessWidget {
  const MawaqitScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .65);
    return Scaffold(
      appBar: AppBar(title: const Text('المواقيت')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          for (final m in mawaqit)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: HajjColors.teal.withValues(alpha: .12), shape: BoxShape.circle),
                      child: const Icon(Icons.place_outlined, color: HajjColors.tealMid),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(m.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                        Text('تُعرف اليوم: ${m.today}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(m.forWho, style: TextStyle(fontSize: 13, color: muted)),
                      ]),
                    ),
                    Text(m.distance, style: TextStyle(fontSize: 12, color: muted)),
                  ]),
                ),
              ),
            ),
          const SizedBox(height: 4),
          for (final n in mawaqitNotes) Bullet(n),
          Text('المسافات تقريبية.', style: TextStyle(fontSize: 12, color: muted)),
        ],
      ),
    );
  }
}

class RestrictionsScreen extends StatelessWidget {
  const RestrictionsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('محظورات الإحرام')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            for (var i = 0; i < restrictions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: HajjColors.rukn.withValues(alpha: .12),
                      foregroundColor: HajjColors.rukn,
                      child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    title: Text(restrictions[i].$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(restrictions[i].$2, style: const TextStyle(height: 1.5)),
                  ),
                ),
              ),
            const SectionTitle('من وقع في محظور'),
            for (final n in restrictionNotes) Bullet(n, color: HajjColors.rukn),
          ],
        ),
      );
}

class PillarsScreen extends StatelessWidget {
  const PillarsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الأركان والواجبات')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            for (final (title, items) in pillars) ...[
              SectionTitle(title),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 2),
                  child: Column(children: [
                    for (final t in items) Bullet(t, color: title.startsWith('أركان') ? HajjColors.rukn : HajjColors.wajib),
                  ]),
                ),
              ),
            ],
            const SectionTitle('الفرق بينها'),
            for (final n in pillarNotes) Bullet(n),
          ],
        ),
      );
}

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<HajjController>();
    final groups = <String, List<(String, String, String)>>{};
    for (final c in checklist) {
      groups.putIfAbsent(c.$3, () => []).add(c);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('قائمة التجهيز (${s.checkedCount}/${checklist.length})'),
        actions: [
          IconButton(tooltip: 'مسح العلامات', icon: const Icon(Icons.restart_alt), onPressed: s.checkedCount == 0 ? null : s.clearChecklist),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          for (final g in groups.entries) ...[
            SectionTitle(g.key),
            Card(
              child: Column(children: [
                for (final c in g.value)
                  CheckboxListTile(
                    value: s.isChecked(c.$1),
                    onChanged: (v) => s.setChecked(c.$1, v ?? false),
                    title: Text(
                      c.$2,
                      style: TextStyle(
                        decoration: s.isChecked(c.$1) ? TextDecoration.lineThrough : null,
                        color: s.isChecked(c.$1) ? Theme.of(context).colorScheme.onSurface.withValues(alpha: .5) : null,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<HajjController>();
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: .7);
    return Scaffold(
      appBar: AppBar(title: const Text('عن التطبيق')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text('دليل الحج والعمرة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text('الإصدار 1.0.0 — يعمل بدون إنترنت، بلا إعلانات، ولا يجمع أي بيانات.', style: TextStyle(color: muted, height: 1.6)),
          const SectionTitle('المصادر'),
          Text(sourcesNote, style: TextStyle(color: muted, height: 1.7)),
          const SectionTitle('تصحيح التاريخ الهجري'),
          Text('إذا اختلف بدء ذي الحجة في بلدك عن تقويم أم القرى، عدّل يوماً للأمام أو للخلف:',
              style: TextStyle(color: muted, height: 1.6)),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: -1, label: Text('−1 يوم')),
              ButtonSegment(value: 0, label: Text('بدون')),
              ButtonSegment(value: 1, label: Text('+1 يوم')),
            ],
            selected: {s.hijriOffset.clamp(-1, 1)},
            onSelectionChanged: (v) => s.setHijriOffset(v.first),
          ),
        ],
      ),
    );
  }
}
