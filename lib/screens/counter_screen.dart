import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/hajj_state.dart';

/// Round counter for Tawaf and Sa'i (seven rounds each), kept across restarts.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key, this.initial = 'tawaf'});
  final String initial;
  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  late String kind = widget.initial;

  String _hint(int n, bool man) {
    if (kind == 'tawaf') {
      if (n >= 7) return 'تمّ الطواف — توجّه لصلاة ركعتين خلف المقام إن تيسّر.';
      final next = n + 1;
      final ramal = man && next <= 3 ? ' — يُسنّ الرَّمَل (الإسراع بخطى متقاربة).' : '';
      return 'الشوط $next: ابدأ من محاذاة الحجر الأسود وكبّر$ramal';
    }
    if (n >= 7) return 'تمّ السعي عند المروة — بقي الحلق أو التقصير.';
    final next = n + 1;
    final from = next.isOdd ? 'من الصفا إلى المروة' : 'من المروة إلى الصفا';
    final jog = man ? ' — أسرِع بين العلمين الأخضرين.' : '';
    return 'الشوط $next: $from$jog';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<HajjController>();
    final n = s.count(kind);
    final complete = n >= 7;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('عداد الأشواط'),
        actions: [
          IconButton(
            tooltip: 'تصفير',
            icon: const Icon(Icons.restart_alt),
            onPressed: n == 0 ? null : () => s.setCount(kind, 0),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'tawaf', label: Text('الطواف'), icon: Icon(Icons.autorenew)),
                ButtonSegment(value: 'sai', label: Text('السعي'), icon: Icon(Icons.swap_horiz)),
              ],
              selected: {kind},
              onSelectionChanged: (v) => setState(() => kind = v.first),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('إظهار سنن الرجال', style: TextStyle(fontSize: 13)),
              Switch(value: s.isMan, onChanged: s.setMan),
            ]),
            Expanded(
              child: Center(
                child: GestureDetector(
                  key: const Key('counter-tap'),
                  onTap: complete
                      ? null
                      : () {
                          final v = n + 1;
                          v == 7 ? HapticFeedback.heavyImpact() : HapticFeedback.mediumImpact();
                          s.setCount(kind, v);
                        },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: _Ring(n, track: scheme.outlineVariant, done: complete),
                      child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            complete ? '✓' : '$n',
                            style: TextStyle(
                              fontSize: 84,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: complete ? HajjColors.sunnah : scheme.onSurface,
                            ),
                          ),
                          Text(complete ? 'اكتملت السبعة' : 'من 7 أشواط',
                              style: TextStyle(fontSize: 16, color: scheme.onSurface.withValues(alpha: .65))),
                          if (!complete)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('اضغط عند إتمام كل شوط',
                                  style: TextStyle(fontSize: 12, color: scheme.primary, fontWeight: FontWeight.w700)),
                            ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (complete ? HajjColors.sunnah : HajjColors.gold).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(_hint(n, s.isMan), key: const Key('counter-hint'), style: const TextStyle(fontWeight: FontWeight.w700, height: 1.6)),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: n == 0 ? null : () => s.setCount(kind, n - 1),
                  icon: const Icon(Icons.undo),
                  label: const Text('تراجع عن شوط'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: complete ? () => s.setCount(kind, 0) : () => s.setCount(kind, n + 1),
                  icon: Icon(complete ? Icons.restart_alt : Icons.add),
                  label: Text(complete ? 'عدّ من جديد' : 'شوط جديد'),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Text('عند الشك في العدد ابنِ على الأقل.',
                style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: .6))),
          ]),
        ),
      ),
    );
  }
}

class _Ring extends CustomPainter {
  _Ring(this.n, {required this.track, required this.done});
  final int n;
  final Color track;
  final bool done;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2 - 14;
    const gap = 0.07;
    const seg = 2 * math.pi / 7;
    for (var i = 0; i < 7; i++) {
      // segments fill counter-clockwise from the top, the direction of Tawaf seen from above
      final start = -math.pi / 2 - i * seg - gap / 2;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..color = i < n ? (done ? HajjColors.sunnah : HajjColors.gold) : track;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, -(seg - gap), false, p);
    }
  }

  @override
  bool shouldRepaint(_Ring old) => old.n != n || old.track != track || old.done != done;
}
