import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/guide.dart';
import '../state/hajj_state.dart';
import '../widgets/common.dart';
import 'counter_screen.dart';

/// Timeline of a guide (Umrah or Hajj) with per-step progress.
class GuideScreen extends StatelessWidget {
  const GuideScreen(this.guide, {super.key});
  final Guide guide;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<HajjController>();
    final ids = guide.steps.map((e) => e.id);
    final done = s.doneIn(ids);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(guide.title),
        actions: [
          if (done > 0)
            IconButton(
              tooltip: 'بدء من جديد',
              icon: const Icon(Icons.restart_alt),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('بدء من جديد؟'),
                    content: const Text('سيتم مسح علامات الإنجاز في هذا الدليل.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
                      FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('مسح')),
                    ],
                  ),
                );
                if (ok == true) await s.resetDone(ids);
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(guide.subtitle, style: TextStyle(color: scheme.onSurface.withValues(alpha: .65))),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: guide.steps.isEmpty ? 0 : done / guide.steps.length,
              minHeight: 8,
              backgroundColor: scheme.outlineVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text('أنجزت $done من ${guide.steps.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (var i = 0; i < guide.steps.length; i++)
            _StepTile(
              guide: guide,
              index: i,
              last: i == guide.steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.guide, required this.index, required this.last});
  final Guide guide;
  final int index;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final step = guide.steps[index];
    final s = context.watch<HajjController>();
    final done = s.isDone(step.id);
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 40,
          child: Column(children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? HajjColors.sunnah : scheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: done ? HajjColors.sunnah : scheme.primary, width: 2),
              ),
              child: done
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.primary)),
            ),
            if (!last) Expanded(child: Container(width: 2, color: scheme.outlineVariant)),
          ]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StepScreen(guide: guide, index: index)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Flexible(
                            child: Text(step.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          ),
                          const SizedBox(width: 6),
                          GradeChip(step.grade),
                        ]),
                        Text(step.when, style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: .6))),
                      ]),
                    ),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class StepScreen extends StatefulWidget {
  const StepScreen({super.key, required this.guide, required this.index});
  final Guide guide;
  final int index;
  @override
  State<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends State<StepScreen> {
  late final PageController _pc = PageController(initialPage: widget.index);
  late int _i = widget.index;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.guide.steps;
    final step = steps[_i];
    final s = context.watch<HajjController>();
    final done = s.isDone(step.id);
    return Scaffold(
      appBar: AppBar(title: Text('${_i + 1} / ${steps.length} — ${widget.guide.title}')),
      body: PageView.builder(
        controller: _pc,
        itemCount: steps.length,
        onPageChanged: (i) => setState(() => _i = i),
        itemBuilder: (_, i) => _StepBody(steps[i]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Row(children: [
            IconButton.outlined(
              tooltip: 'السابق',
              onPressed: _i == 0 ? null : () => _pc.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                key: const Key('step-done'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: done ? HajjColors.sunnah : null,
                ),
                onPressed: () async {
                  await s.setDone(step.id, !done);
                  if (!done && _i < steps.length - 1) {
                    await _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  }
                },
                icon: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked),
                label: Text(done ? 'تم بحمد الله' : 'أنجزت هذه الخطوة',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.outlined(
              tooltip: 'التالي',
              onPressed: _i == steps.length - 1 ? null : () => _pc.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
              icon: const Icon(Icons.arrow_forward),
            ),
          ]),
        ),
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody(this.step);
  final GuideStep step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Row(children: [
          Expanded(child: Text(step.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
          GradeChip(step.grade),
        ]),
        Text(step.when, style: TextStyle(color: scheme.onSurface.withValues(alpha: .65))),
        const SizedBox(height: 14),
        for (final p in step.points) Bullet(p, color: gradeColor(step.grade)),
        if (step.counter != null) ...[
          const SizedBox(height: 4),
          OutlinedButton.icon(
            key: Key('open-counter-${step.counter}'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CounterScreen(initial: step.counter!)),
            ),
            icon: const Icon(Icons.timelapse),
            label: Text(step.counter == 'sai' ? 'افتح عداد السعي' : 'افتح عداد الطواف',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
        if (step.tip != null) ...[
          const SizedBox(height: 12),
          InfoCard(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lightbulb_outline, size: 20, color: HajjColors.goldDeep),
              const SizedBox(width: 8),
              Expanded(child: Text(step.tip!, style: const TextStyle(height: 1.6))),
            ]),
          ),
        ],
        if (step.duas.isNotEmpty) ...[
          const SectionTitle('الأذكار والأدعية'),
          for (final d in step.duas) Padding(padding: const EdgeInsets.only(bottom: 10), child: DuaCard(d)),
        ],
      ],
    );
  }
}
