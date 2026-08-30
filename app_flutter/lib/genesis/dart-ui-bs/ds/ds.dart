// ✨ מערכת-העיצוב של המחולל (Design System · חוט-טהור) — טוקנים + פרימיטיבים
// מעוצבים ברמת-מוצר: מרווחים, טיפוגרפיה, צל רך, פינות, ערכת-צבע מרוסנת. אפס-דאטה
// (כל טקסט מוזרק בחיווט); material בלבד; פוקוס/מצב פנימיים. חוק-1/חוק-5.
import 'package:flutter/material.dart';

class DsTokens {
  static const bg = Color(0xFFF4F6FA);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const faint = Color(0xFF94A3B8);
  static const line = Color(0xFFE6E9F0);
  static const accent = Color(0xFFF97316);
  static const accentDark = Color(0xFFEA580C);
  static const accentSoft = Color(0xFFFFF1E7);
  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFE9F7EF);
  static const r = 16.0;
  static const rSm = 11.0;
  static const pad = 20.0;
  static const gap = 16.0;
  static const List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x14101828), blurRadius: 4, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0A101828), blurRadius: 2, offset: Offset(0, 1)),
  ];
}

// ── שלד-מסך: רקע רך + כותרת נקייה + גוף גלילה מרווח ──
class DsScaffold extends StatelessWidget {
  const DsScaffold({required this.title, required this.subtitle, required this.icon, required this.children, this.bottomBar, super.key});
  final String title, subtitle, icon;
  final List<Widget> children;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DsTokens.bg,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: const BoxDecoration(
                  color: DsTokens.card,
                  border: Border(bottom: BorderSide(color: DsTokens.line)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: DsTokens.accentSoft, borderRadius: BorderRadius.circular(12)),
                      child: Text(icon, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.ink, fontSize: 19, fontWeight: FontWeight.w800, height: 1.1)),
                          if (subtitle.isNotEmpty) Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.muted, fontSize: 12.5, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                    if (canPop)
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_forward, color: DsTokens.muted, size: 22),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: children,
                ),
              ),
              if (bottomBar != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: DsTokens.card,
                    border: Border(top: BorderSide(color: DsTokens.line)),
                  ),
                  child: SafeArea(top: false, child: bottomBar!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── כרטיס-סקשן: כותרת + ילדים במרווח אחיד ──
class DsSection extends StatelessWidget {
  const DsSection({required this.title, required this.children, this.trailing, super.key});
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: DsTokens.gap),
        decoration: BoxDecoration(color: DsTokens.card, borderRadius: BorderRadius.circular(DsTokens.r), boxShadow: DsTokens.shadow),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(DsTokens.pad, 16, DsTokens.pad, 12),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: const TextStyle(color: DsTokens.ink, fontSize: 15.5, fontWeight: FontWeight.w800))),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: DsTokens.line),
            Padding(
              padding: const EdgeInsets.fromLTRB(DsTokens.pad, 6, DsTokens.pad, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
          ],
        ),
      );
}

// (שדות-הקלט DsField · DsNumberField · DsDateField · DsToggleTile חיים בקבצים
//  נפרדים תחת ds/ — כל אחד עם תיאור-עצמי (he) של סוג-הנתון שהוא מחזיק, כדי שהמנוע
//  יאחזר אותם לפי-משמעות. הידע חי על האטום, לא במנוע — טהור, עובר מבחן-קונכייה.)

// ── פס-מסע (workflow): עיגולים ממוספרים + מחברים, שלב-נוכחי מודגש ──
class DsWorkflow extends StatelessWidget {
  const DsWorkflow({required this.steps, required this.current, super.key});
  final List<String> steps;
  final int current;
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final done = i <= current;
      if (i > 0) {
        items.add(Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 20), color: i <= current ? DsTokens.accent : DsTokens.line)));
      }
      items.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30, height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? DsTokens.accent : DsTokens.card,
              shape: BoxShape.circle,
              border: Border.all(color: done ? DsTokens.accent : DsTokens.line, width: 2),
            ),
            child: Text('${i + 1}', style: TextStyle(color: done ? Colors.white : DsTokens.faint, fontSize: 13, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 54,
            child: Text(steps[i], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: i == current ? DsTokens.ink : DsTokens.faint, fontSize: 10.5, fontWeight: i == current ? FontWeight.w700 : FontWeight.w500)),
          ),
        ],
      ));
    }
    return Container(
      margin: const EdgeInsets.only(bottom: DsTokens.gap),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(color: DsTokens.card, borderRadius: BorderRadius.circular(DsTokens.r), boxShadow: DsTokens.shadow),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }
}

// ── כפתור-ראשי (gradient) ──
class DsPrimaryButton extends StatelessWidget {
  const DsPrimaryButton({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(colors: [DsTokens.accent, DsTokens.accentDark]),
          boxShadow: const [BoxShadow(color: Color(0x33F97316), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
}

// ── שבב-סטטוס ──
class DsChip extends StatelessWidget {
  const DsChip({required this.label, this.tone = 0, super.key});
  final String label;
  final int tone; // 0 accent · 1 success · 2 muted
  @override
  Widget build(BuildContext context) {
    final bg = tone == 1 ? DsTokens.successSoft : tone == 2 ? const Color(0xFFF1F5F9) : DsTokens.accentSoft;
    final fg = tone == 1 ? DsTokens.success : tone == 2 ? DsTokens.muted : DsTokens.accentDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ── אריח-KPI (דשבורד) ──
class DsStat extends StatelessWidget {
  const DsStat({required this.label, required this.value, required this.sub, required this.glyph, super.key});
  final String label, value, sub, glyph;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: DsTokens.card, borderRadius: BorderRadius.circular(DsTokens.r), boxShadow: DsTokens.shadow),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34, height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: DsTokens.accentSoft, borderRadius: BorderRadius.circular(9)),
                  child: Text(glyph, style: const TextStyle(fontSize: 17)),
                ),
                const Spacer(),
                Text(value, style: const TextStyle(color: DsTokens.ink, fontSize: 24, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 10),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.ink, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.muted, fontSize: 11.5, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

// ── שורת-ניווט (לוח) ──
class DsNavTile extends StatelessWidget {
  const DsNavTile({required this.glyph, required this.title, required this.sub, required this.onTap, super.key});
  final String glyph, title, sub;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: DsTokens.card,
          borderRadius: BorderRadius.circular(DsTokens.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(DsTokens.r),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(DsTokens.r), border: Border.all(color: DsTokens.line)),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: DsTokens.accentSoft, borderRadius: BorderRadius.circular(12)),
                    child: Text(glyph, style: const TextStyle(fontSize: 21)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: DsTokens.ink, fontSize: 15.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.muted, fontSize: 12.5, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_left, color: DsTokens.faint, size: 22),
                ],
              ),
            ),
          ),
        ),
      );
}

// ── מצב-ריק (טבלת-רשומות ריקה) ──
class DsEmpty extends StatelessWidget {
  const DsEmpty({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            Container(
              width: 46, height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.inbox_outlined, color: DsTokens.faint, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: DsTokens.muted, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
