import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../core/theme.dart';
import '../data/guide.dart';

Color gradeColor(Grade g) => switch (g) {
      Grade.rukn => HajjColors.rukn,
      Grade.wajib => HajjColors.wajib,
      Grade.sunnah => HajjColors.sunnah,
      Grade.info => HajjColors.goldDeep,
    };

class GradeChip extends StatelessWidget {
  const GradeChip(this.grade, {super.key});
  final Grade grade;
  @override
  Widget build(BuildContext context) {
    final c = gradeColor(grade);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(color: c.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
      child: Text(grade.label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

/// Supplication card: Amiri text, repeat count, source, note, copy and share.
class DuaCard extends StatelessWidget {
  const DuaCard(this.dua, {super.key});
  final Dua dua;

  String get _plain => '${dua.quran ? '﴿${dua.text}﴾' : dua.text}\n\n${dua.source}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: .62);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.auto_awesome, size: 16, color: HajjColors.gold),
            const SizedBox(width: 6),
            Expanded(child: Text(dua.title, style: const TextStyle(fontWeight: FontWeight.w800))),
            if (dua.repeat > 1)
              Container(
                margin: const EdgeInsetsDirectional.only(end: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                decoration: BoxDecoration(color: scheme.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
                child: Text('${dua.repeat} مرات', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: scheme.primary)),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 6),
            child: Text(
              dua.quran ? '﴿${dua.text}﴾' : dua.text,
              style: const TextStyle(fontFamily: 'Amiri', fontSize: 21, height: 1.9, fontWeight: FontWeight.w700),
            ),
          ),
          if (dua.note != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 8),
              child: Text(dua.note!, style: TextStyle(fontSize: 13, height: 1.6, color: muted)),
            ),
          Row(children: [
            Icon(Icons.menu_book_outlined, size: 14, color: muted),
            const SizedBox(width: 4),
            Expanded(child: Text(dua.source, style: TextStyle(fontSize: 12, color: muted))),
            IconButton(
              tooltip: 'نسخ',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_rounded, size: 19),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _plain));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('تم النسخ'), duration: Duration(seconds: 1)));
              },
            ),
            IconButton(
              tooltip: 'مشاركة',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.share_outlined, size: 19),
              onPressed: () => SharePlus.instance.share(ShareParams(text: '${dua.title}\n\n$_plain\n\nمن تطبيق «دليل الحج والعمرة»')),
            ),
          ]),
        ]),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );
}

class Bullet extends StatelessWidget {
  const Bullet(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Container(width: 6, height: 6, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.75))),
      ]),
    );
  }
}

/// Simple text page used by the reference sections.
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.child, this.color});
  final Widget child;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (color ?? HajjColors.gold).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );
}
