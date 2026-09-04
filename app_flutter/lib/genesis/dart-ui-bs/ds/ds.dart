// ✨ מערכת-העיצוב של המחולל (Design System · חוט-טהור) — טוקנים + פרימיטיבים
// זהות "מקסימום": כהה-עמוק · ניאון סגול/מגנטה/ציאן · זוהר · זכוכית · גרדיאנט-טקסט.
// אפס-דאטה (כל טקסט מוזרק בחיווט); material בלבד; פוקוס/מצב פנימיים. חוק-1/חוק-5.
// ⚠️ חתימות-הבנאי קפואות (תפר atom-census) — כאן משתנה רק המראה (build/צבעים/צללים).
import 'package:flutter/material.dart';
import 'ds_pure.dart'; // 🎨 עיצוב-Pure (הכרעת-בעלים 1.9) — הפלטה מופנית ל-DsPure. הפיך: שחזור-קובץ ⇒ הישן.

class DsTokens {
  // ── זהות · בהירות-הערכה (טוקן=דאטה · המנוע קורא-עיוור, לא מכריע) ──
  // חילוף כהה↔בהיר = שינוי הטוקן הזה בלבד. הכרעה 19.
  static const brightness = Brightness.dark;
  // ── פלטה · Pure (מופנית ל-DsPure · חוק-7 הפיך) ──
  static const bg = DsPure.canvas;
  static const bg2 = DsPure.sunken;
  static const card = DsPure.surface;
  static const cardAlt = DsPure.raised;        // משטח-משנה (כרטיס-רשומה מקונן)
  static const ink = DsPure.ink;
  static const muted = DsPure.mut;
  static const faint = DsPure.faint;
  static const line = DsPure.hair;             // מסגרת-זכוכית דקה
  static const track = DsPure.raised2;         // רקע-מסילה (פסים · התקדמות · שבב-נייטרל)
  static const accent = DsPure.accent;         // אינדיגו-Pure (מבטא ראשי)
  static const accentDark = DsPure.accentHi;
  static const accentSoft = Color(0x1F7A6BF0); // אינדיגו-שקוף (רקע-שבב)
  static const magenta = Color(0xFFB57BE6);
  static const cyan = Color(0xFF4CC6E6);
  static const success = Color(0xFF43D08C);
  static const successSoft = Color(0x1F43D08C);
  // ── טיפוגרפיה · Pure (הכרעת-בעלים 1.9): כותרות = Frank Ruhl Libre · גוף = Heebo (theme) ──
  static const fontHead = 'FrankRuhlLibre';
  static const fontBody = 'Heebo';             // גופן-גוף עברי מצורף (pubspec של בנייה-חכמה: Heebo) — טקסט-ברירת-מחדל בלי CDN (L69: Roboto-מ-gstatic לא נטען באתר-מנותק ⇒ טקסט נעלם)
  // ── רדיוסים · דרגות ──
  static const r = 16.0;
  static const rSm = 11.0;
  static const rLg = 20.0;
  static const pad = 20.0;
  static const gap = 16.0;
  // ── גרדיאנטים · ספרייה נקובה ──
  static const accentGrad = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [accent, magenta],
  );
  static const neonGrad = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [cyan, accent, magenta],
  );
  static const inkGrad = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFF9BF0FF)],
  );
  // ── ראמפת-צל · כפולת-שכבה (מגע קרוב + עומק רחוק) ──
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x59000000), blurRadius: 18, offset: Offset(0, 9)),
    BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 20)),
    BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 3)),
  ];
  // ── זוהר-ניאון (מבטא) — לכפתורים/הדגשות ──
  static const List<BoxShadow> glow = [
    BoxShadow(color: Color(0x807C3AED), blurRadius: 26, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x40EC4899), blurRadius: 12, offset: Offset(0, 2)),
  ];
}

// ── שלד-מסך: רקע כהה + כותרת-זכוכית + גוף גלילה מרווח ──
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
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.7, -1.1), radius: 1.5,
              colors: [Color(0x267C3AED), Color(0x0007070D)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: const BoxDecoration(
                    color: DsTokens.card,
                    border: Border(bottom: BorderSide(color: DsTokens.line)),
                    boxShadow: DsTokens.shadowSm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(gradient: DsTokens.accentGrad, borderRadius: BorderRadius.circular(12), boxShadow: DsTokens.glow),
                        child: Text(icon, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.ink, fontSize: 19, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.3, fontFamily: DsTokens.fontHead)),
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
      ),
    );
  }
}

// ── כרטיס-סקשן: כותרת + ילדים במרווח אחיד (זכוכית-כהה) ──
class DsSection extends StatelessWidget {
  const DsSection({required this.title, required this.children, this.trailing, this.tone = 0, super.key});
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final int tone; // פס-האקסנט: 0=accent(ברירת-מחדל, ביט-זהה) · 1=success · 2=danger · 3=warning
  static const List<Color> _toneC = [Color(0xFF7C3AED), Color(0xFF34D399), Color(0xFFF43F5E), Color(0xFFF59E0B)];

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: DsTokens.gap),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF141534), Color(0xFF101127)]),
          borderRadius: BorderRadius.circular(DsTokens.r),
          border: Border.all(color: DsTokens.line),
          boxShadow: DsTokens.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(DsTokens.pad, 16, DsTokens.pad, 12),
              child: Row(
                children: [
                  Container(width: 3, height: 16, margin: const EdgeInsets.only(left: 9), decoration: BoxDecoration(gradient: tone == 0 ? DsTokens.accentGrad : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_toneC[tone % 4], _toneC[tone % 4].withValues(alpha: 0.55)]), borderRadius: BorderRadius.circular(2))),
                  Expanded(child: Text(title, style: const TextStyle(color: DsTokens.ink, fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: -0.2, fontFamily: DsTokens.fontHead))),
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
        items.add(Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(gradient: i <= current ? DsTokens.accentGrad : null, color: i <= current ? null : DsTokens.line))));
      }
      items.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30, height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: done ? DsTokens.accentGrad : null,
              color: done ? null : DsTokens.card,
              shape: BoxShape.circle,
              border: Border.all(color: done ? Colors.transparent : DsTokens.line, width: 2),
              boxShadow: i == current ? DsTokens.glow : null,
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
      decoration: BoxDecoration(color: DsTokens.card, borderRadius: BorderRadius.circular(DsTokens.r), border: Border.all(color: DsTokens.line), boxShadow: DsTokens.shadow),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }
}

// ── כפתור-ראשי (gradient-ניאון + זוהר) ──
class DsPrimaryButton extends StatelessWidget {
  const DsPrimaryButton({required this.label, this.onTap, super.key});
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: DsTokens.accentGrad,
          boxShadow: DsTokens.glow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: onTap ?? () {},
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0x24FFFFFF)),
              ),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
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
    final bg = tone == 1 ? DsTokens.successSoft : tone == 2 ? DsTokens.track : DsTokens.accentSoft;
    final fg = tone == 1 ? DsTokens.success : tone == 2 ? DsTokens.muted : DsTokens.accentDark;
    final bd = tone == 1 ? const Color(0x3334D399) : tone == 2 ? DsTokens.line : const Color(0x407C3AED);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: bd)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ── אריח-KPI (דשבורד) — ערך בגרדיאנט-טקסט ──
class DsStat extends StatelessWidget {
  const DsStat({required this.label, required this.value, required this.sub, required this.glyph, this.onTap, super.key});
  final String label, value, sub, glyph;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final card = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF16173A), Color(0xFF101127)]),
          borderRadius: BorderRadius.circular(DsTokens.r),
          border: Border.all(color: DsTokens.line),
          boxShadow: DsTokens.shadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34, height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: DsTokens.accentSoft, borderRadius: BorderRadius.circular(9), border: Border.all(color: const Color(0x337C3AED))),
                  child: Text(glyph, style: const TextStyle(fontSize: 17)),
                ),
                const Spacer(),
                ShaderMask(
                  shaderCallback: (r) => DsTokens.inkGrad.createShader(r),
                  child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -0.6, fontFamily: DsTokens.fontHead)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.ink, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DsTokens.muted, fontSize: 11.5, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(DsTokens.r),
      child: InkWell(borderRadius: BorderRadius.circular(DsTokens.r), onTap: onTap, child: card),
    );
  }
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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(DsTokens.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(DsTokens.r),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: DsTokens.card, borderRadius: BorderRadius.circular(DsTokens.r), border: Border.all(color: DsTokens.line), boxShadow: DsTokens.shadowSm),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(gradient: DsTokens.accentGrad, borderRadius: BorderRadius.circular(12), boxShadow: DsTokens.glow),
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
                  const Icon(Icons.chevron_left, color: DsTokens.accentDark, size: 22),
                ],
              ),
            ),
          ),
        ),
      );
}

// ── כרטיס-רשומה: תווית:ערך לכל שדה + שבב-שלב חי + קידום + עריכה (הקשה) + מחיקה ──
class DsRecordCard extends StatelessWidget {
  const DsRecordCard({required this.labels, required this.values, this.stage = '', this.stageDone = false, this.stages = const [], this.stageIndex = 0, this.onStage, this.onAdvance, this.onEdit, this.onDelete, this.footer, this.blockedReason, this.confirmMessage, this.hidden = const {}, super.key});
  final List<String> labels, values;
  final Set<int> hidden;   // RLS · אינדקסי-עמודה מוסתרים לתפקיד-הנוכחי (סינון-תצוגה)
  final Widget? footer;   // תוכן-תחתית (למשל שבבי קשר-הפוך)
  final String? blockedReason;   // שלמות-קשר · חסימה: מחיקה חסומה + סיבה (טוסט)
  final String? confirmMessage;  // שלמות-קשר · מפל: אישור לפני מחיקת-שרשרת
  final String stage;         // שם השלב-הנוכחי (ריק = לישות אין מסע)
  final bool stageDone;       // האם הגיע לשלב-האחרון
  final List<String> stages;  // כל השלבים (למסע לא-ליניארי — קפיצה לכל שלב)
  final int stageIndex;       // אינדקס השלב-הנוכחי
  final ValueChanged<int>? onStage;   // קפיצה לשלב שנבחר
  final VoidCallback? onAdvance, onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < labels.length && i < values.length; i++) {
      if (hidden.contains(i)) continue;   // RLS · עמודה מוסתרת לתפקיד
      if (values[i].trim().isEmpty) continue;
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(labels[i], style: const TextStyle(color: DsTokens.faint, fontSize: 12.5, fontWeight: FontWeight.w600))),
            const SizedBox(width: 8),
            Expanded(child: Text(values[i], style: const TextStyle(color: DsTokens.ink, fontSize: 13.5, fontWeight: FontWeight.w600))),
          ],
        ),
      ));
    }
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stage.isNotEmpty || onDelete != null) Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              if (stage.isNotEmpty && (stages.isEmpty || onStage == null))
                DsChip(label: stage, tone: stageDone ? 1 : 0),
              if (stage.isNotEmpty && stages.isNotEmpty && onStage != null)
                PopupMenuButton<int>(
                  onSelected: onStage,
                  tooltip: 'קפוץ לשלב',
                  itemBuilder: (_) => [
                    for (var i = 0; i < stages.length; i++)
                      PopupMenuItem<int>(
                        value: i,
                        child: Row(children: [
                          Icon(i == stageIndex ? Icons.radio_button_checked : Icons.radio_button_off, size: 16, color: i == stageIndex ? DsTokens.accent : DsTokens.faint),
                          const SizedBox(width: 8),
                          Text(stages[i], style: const TextStyle(fontSize: 13.5)),
                        ]),
                      ),
                  ],
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    DsChip(label: stage, tone: stageDone ? 1 : 0),
                    const SizedBox(width: 2),
                    const Icon(Icons.expand_more, size: 15, color: DsTokens.faint),
                  ]),
                ),
              const Spacer(),
              if (stage.isNotEmpty && !stageDone && onAdvance != null)
                Material(
                  color: DsTokens.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onAdvance,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('קדם שלב', style: TextStyle(color: DsTokens.accentDark, fontSize: 12, fontWeight: FontWeight.w700)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_back, size: 14, color: DsTokens.accentDark),
                      ]),
                    ),
                  ),
                ),
              if (onDelete != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    onPressed: blockedReason != null
                        ? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(blockedReason!)))
                        : confirmMessage != null
                            ? () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    content: Text(confirmMessage!),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('ביטול')),
                                      TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('מחק')),
                                    ],
                                  ),
                                );
                                if (ok == true) onDelete?.call();
                              }
                            : onDelete,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    icon: Icon(Icons.delete_outline, size: 18, color: blockedReason != null ? DsTokens.faint : DsTokens.muted),
                    tooltip: blockedReason != null ? 'מחיקה חסומה' : 'מחק',
                  ),
                ),
            ],
          ),
        ),
        ...rows.isEmpty ? [const Text('—', style: TextStyle(color: DsTokens.faint))] : rows,
        if (footer != null) Padding(padding: const EdgeInsets.only(top: 10), child: footer),
      ],
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: DsTokens.cardAlt,
        borderRadius: BorderRadius.circular(DsTokens.rSm),
        border: Border.all(color: DsTokens.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: onEdit == null
          ? Padding(padding: const EdgeInsets.all(14), child: body)
          : InkWell(onTap: onEdit, child: Padding(padding: const EdgeInsets.all(14), child: body)),
    );
  }
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
              decoration: BoxDecoration(color: DsTokens.track, borderRadius: BorderRadius.circular(13), border: Border.all(color: DsTokens.line)),
              child: const Icon(Icons.inbox_outlined, color: DsTokens.faint, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: DsTokens.muted, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
