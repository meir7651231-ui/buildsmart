// ✨ מערכת-העיצוב של המחולל (Design System · חוט-טהור) — טוקנים + פרימיטיבים
// זהות "מקסימום": כהה-עמוק · ניאון סגול/מגנטה/ציאן · זוהר · זכוכית · גרדיאנט-טקסט.
// אפס-דאטה (כל טקסט מוזרק בחיווט); material בלבד; פוקוס/מצב פנימיים. חוק-1/חוק-5.
// ⚠️ חתימות-הבנאי קפואות (תפר atom-census) — כאן משתנה רק המראה (build/צבעים/צללים).
import 'package:flutter/material.dart';
import 'ds_pure.dart'; // 🎨 עיצוב-Pure (הכרעת-בעלים 1.9) — הפלטה מופנית ל-DsPure. הפיך: שחזור-קובץ ⇒ הישן.
import 'ds_seam.dart'; // G28 · חריץ-העור: DsLook.of(context) — כרום-ה-DS לובש את העור המוזרק (paper) או נשאר ביט-זהה (כהה)

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

// ── G28 (הכרעה-28) · מראה-נפתר לכרום-ה-DS ──
// בלי PureScope, או עור-כהה ⇒ DsLook.dark = ערכי-DsTokens (ביט-זהה — חוק-7). עור-בהיר (skins.paper) ⇒ paper:
// לבן · דיו #37352F · קו 8% · אקצנט-יחיד · בלי גרדיאנט/זוהר/צל · שורה-לא-כרטיס · בלי אריח-אמוג׳י. הכרום קורא DsLook.of(context)
// בדיוק כמו שאטום-forge קורא DsSeam.skinOf — הזהות בחיווט (חוק-6), לא בקוד.
class DsLook {
  const DsLook({required this.paper, required this.bg, required this.card, required this.cardAlt, required this.ink, required this.muted, required this.faint, required this.line, required this.track, required this.accent, required this.accentDark, required this.accentSoft, required this.success, required this.successSoft, required this.warn, required this.danger, required this.dangerSoft, required this.dangerLine, required this.chipBg, required this.r, required this.rSm, required this.fontHead});
  final bool paper;
  final Color bg, card, cardAlt, ink, muted, faint, line, track, accent, accentDark, accentSoft, success, successSoft, warn, danger, dangerSoft, dangerLine, chipBg;
  final double r, rSm;
  final String fontHead;
  static const DsLook dark = DsLook(paper: false, bg: DsTokens.bg, card: DsTokens.card, cardAlt: DsTokens.cardAlt, ink: DsTokens.ink, muted: DsTokens.muted, faint: DsTokens.faint, line: DsTokens.line, track: DsTokens.track, accent: DsTokens.accent, accentDark: DsTokens.accentDark, accentSoft: DsTokens.accentSoft, success: DsTokens.success, successSoft: DsTokens.successSoft, warn: Color(0xFFF59E0B), danger: Color(0xFFDC2626), dangerSoft: Color(0x14DC2626), dangerLine: Color(0x40DC2626), chipBg: Color(0xFFF1F5F9), r: DsTokens.r, rSm: DsTokens.rSm, fontHead: DsTokens.fontHead);
  static DsLook of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PureScope>();
    if (scope == null || scope.skin.canvas.computeLuminance() < 0.5) return dark;
    final s = scope.skin, th = scope.theme;
    return DsLook(paper: true, bg: s.canvas, card: s.surface, cardAlt: s.raised, ink: s.ink, muted: s.mut, faint: s.faint, line: s.hair, track: s.raised2, accent: th.a, accentDark: th.a800, accentSoft: th.a.withValues(alpha: 0.10), success: s.ok, successSoft: s.ok.withValues(alpha: 0.12), warn: s.warn, danger: s.err, dangerSoft: s.err.withValues(alpha: 0.08), dangerLine: s.err.withValues(alpha: 0.25), chipBg: s.raised2, r: 12, rSm: 10, fontHead: scope.fonts.he);
  }
}

// ── שלד-מסך: רקע כהה + כותרת-זכוכית + גוף גלילה מרווח (paper: לבן · כותרת 22/600 · קו · בלי אריח) ──
class DsScaffold extends StatelessWidget {
  const DsScaffold({required this.title, required this.subtitle, required this.icon, required this.children, this.bottomBar, this.header = true, super.key});
  final String title, subtitle, icon;
  final List<Widget> children;
  final Widget? bottomBar;
  /// G13c · header=false ⇒ בלי כותרת-המסך של ה-DS (אטום-forge מצייר אותה בראש children); כפתור-חזרה נשמר. true ⇒ ביט-זהה.
  final bool header;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final lk = DsLook.of(context);
    final paper = lk.paper;
    final column = Column(
      children: [
        if (!header && canPop) Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: Icon(Icons.arrow_forward, color: lk.muted, size: 22))),
        if (header) Container(
          padding: paper ? const EdgeInsets.fromLTRB(16, 10, 16, 10) : const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: lk.card,
            border: Border(bottom: BorderSide(color: lk.line)),
            boxShadow: paper ? null : DsTokens.shadowSm,
          ),
          child: Row(
            children: [
              if (!paper) Container(
                width: 42, height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(gradient: DsTokens.accentGrad, borderRadius: BorderRadius.circular(12), boxShadow: DsTokens.glow),
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
              if (!paper) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: paper
                        ? TextStyle(color: lk.ink, fontSize: 22, fontWeight: FontWeight.w600, height: 1.3, fontFamily: lk.fontHead)
                        : const TextStyle(color: DsTokens.ink, fontSize: 19, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.3, fontFamily: DsTokens.fontHead)),
                    if (subtitle.isNotEmpty) Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: lk.muted, fontSize: paper ? 13 : 12.5, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              if (canPop)
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(Icons.arrow_forward, color: lk.muted, size: 22),
                ),
            ],
          ),
        ),
        Expanded(
          child: paper
              ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 28), children: children)))
              : ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 28), children: children),
        ),
        if (bottomBar != null)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: lk.card,
              border: Border(top: BorderSide(color: lk.line)),
            ),
            child: SafeArea(top: false, child: bottomBar!),
          ),
      ],
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: lk.bg,
        body: paper
            ? SafeArea(child: column)
            : DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.7, -1.1), radius: 1.5,
                    colors: [Color(0x267C3AED), Color(0x0007070D)],
                  ),
                ),
                child: SafeArea(child: column),
              ),
      ),
    );
  }
}

// ── כרטיס-סקשן: כותרת + ילדים במרווח אחיד (זכוכית-כהה · paper: כותרת-חלק 15/700 שטוחה, בלי כרטיס) ──
class DsSection extends StatelessWidget {
  const DsSection({required this.title, required this.children, this.trailing, this.tone = 0, super.key});
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final int tone; // פס-האקסנט: 0=accent(ברירת-מחדל, ביט-זהה) · 1=success · 2=danger · 3=warning
  static const List<Color> _toneC = [Color(0xFF7C3AED), Color(0xFF34D399), Color(0xFFF43F5E), Color(0xFFF59E0B)];

  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    if (lk.paper) {
      final toneC = tone == 0 ? lk.ink : tone == 1 ? lk.success : tone == 2 ? lk.danger : const Color(0xFFC98A00);
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Expanded(child: Text(title, style: TextStyle(color: toneC, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: lk.fontHead))),
                if (trailing != null) trailing!,
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ],
        ),
      );
    }
    return Container(
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
}

// ── G28 · חלק-מקופל: כותרת «▸ פרטים (n)» + ילדים, סגור כברירת-מחדל (3-למעלה, השאר מתחת — PLAN §3.2) ──
// סוקטים: title · details (List<Widget>) — נאסף לקטלוג ע"י המפקד כ-op expand. paper ובכהה כאחד (אין מצב-קודם ⇒ אין ביט-זהה לשבור).
class DsFold extends StatefulWidget {
  const DsFold({required this.title, required this.details, this.open = false, super.key});
  final String title;
  final List<Widget> details;
  final bool open;
  @override
  State<DsFold> createState() => _DsFoldState();
}

class _DsFoldState extends State<DsFold> {
  bool? _open;
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final open = _open ?? widget.open;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Icon(open ? Icons.expand_more : Icons.chevron_left, size: 18, color: lk.muted),
              const SizedBox(width: 4),
              Expanded(child: Text(widget.title, style: TextStyle(color: lk.muted, fontSize: 14, fontWeight: FontWeight.w600))),
            ]),
          ),
        ),
        if (open) Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.details),
      ],
    );
  }
}

// ── G28 · פסקת-תוכן: כותרת-חלק + טקסט (אטום-תוכן «תוכן X: …» של הפירוק) — סוקטים: message · label. Notion-שטוח: 16/1.5, בלי כרטיס ──
class DsNote extends StatelessWidget {
  const DsNote({required this.message, this.label = '', this.tone = 0, super.key});
  final String message, label;
  final int tone; // 0 רגיל · 1 ok · 2 danger · 3 warn — צבע-הכותרת בלבד
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final toneC = tone == 1 ? lk.success : tone == 2 ? lk.danger : tone == 3 ? const Color(0xFFC98A00) : lk.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 2), child: Text(label, style: TextStyle(color: toneC, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: lk.fontHead))),
          Text(message, style: TextStyle(color: lk.ink, fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }
}

// ── G29 · שורת-דיף: מה-השתנה בלבד — תווית · ישן→חדש (value) · Δ (delta) · משמעות-כסף (sub). Notion-שטוח, קו-תחתון, בלי כרטיס ──
class DsDiffRow extends StatelessWidget {
  const DsDiffRow({required this.label, required this.value, required this.delta, this.sub = '', this.tone = 0, super.key});
  final String label, value, delta, sub;
  final int tone; // 0 ניטרלי · 1 ok · 2 danger · 3 warn — צבע-ה-Δ
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final dC = tone == 1 ? lk.success : tone == 2 ? lk.danger : tone == 3 ? const Color(0xFFC98A00) : lk.ink;
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lk.line))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 84, child: Text(label, style: TextStyle(color: lk.muted, fontSize: 14))),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: lk.ink, fontSize: 15, fontFeatures: const [FontFeature.tabularFigures()])),
                if (sub.isNotEmpty) Text(sub, style: TextStyle(color: lk.muted, fontSize: 12.5)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(color: dC.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
            child: Text(delta, style: TextStyle(color: dC, fontSize: 12, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])),
          ),
        ],
      ),
    );
  }
}

// ── G30 · הוספה-מהירה (quick-add): one text box, Enter creates (Todoist rule; ≤3 keys) ──
class DsQuickAdd extends StatefulWidget {
  const DsQuickAdd({required this.hint, required this.onSubmit, this.autofocus = false, super.key});
  final bool autofocus;
  final String hint;
  final ValueChanged<String> onSubmit;
  @override
  State<DsQuickAdd> createState() => _DsQuickAddState();
}

class _DsQuickAddState extends State<DsQuickAdd> {
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lk.line))),
      child: Row(children: [
        Icon(Icons.add, size: 20, color: lk.muted),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _c,
            autofocus: widget.autofocus,
            style: TextStyle(color: lk.ink, fontSize: 16),
            decoration: InputDecoration(hintText: widget.hint, hintStyle: TextStyle(color: lk.faint, fontSize: 15), border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 12)),
            textInputAction: TextInputAction.done,
            onSubmitted: (v) { final s = v.trim(); if (s.isEmpty) return; widget.onSubmit(s); _c.clear(); },
          ),
        ),
      ]),
    );
  }
}

// ── G30 · פלטת-פקודות (Ctrl/Cmd+K): text search over records + actions; pick = one tap ──
class DsPaletteItem {
  const DsPaletteItem({required this.label, required this.sub, required this.onTap});
  final String label, sub;
  final VoidCallback onTap;
}

class DsPalette extends StatefulWidget {
  const DsPalette({required this.hint, required this.items, super.key});
  final String hint;
  final List<DsPaletteItem> items;
  static Future<void> show(BuildContext context, {required String hint, required List<DsPaletteItem> items}) =>
      showDialog<void>(context: context, builder: (_) => Dialog(insetPadding: const EdgeInsets.fromLTRB(16, 60, 16, 16), child: DsPalette(hint: hint, items: items)));
  @override
  State<DsPalette> createState() => _DsPaletteState();
}

class _DsPaletteState extends State<DsPalette> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final q = _q.trim().toLowerCase();
    final shown = widget.items.where((i) => q.isEmpty || i.label.toLowerCase().contains(q) || i.sub.toLowerCase().contains(q)).take(12).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 520),
        decoration: BoxDecoration(color: lk.bg, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              style: TextStyle(color: lk.ink, fontSize: 16),
              decoration: InputDecoration(hintText: widget.hint, hintStyle: TextStyle(color: lk.faint), border: InputBorder.none, prefixIcon: Icon(Icons.search, color: lk.muted)),
              onChanged: (v) => setState(() => _q = v),
              onSubmitted: (_) { if (shown.isNotEmpty) { Navigator.of(context).pop(); shown.first.onTap(); } },
            ),
            Divider(height: 1, color: lk.line),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [for (final i in shown) DsNavTile(glyph: '', title: i.label, sub: i.sub, onTap: () { Navigator.of(context).pop(); i.onTap(); })],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── G32 · DsLoadMeter (load meter: 5 bars, 3 states) ──
class DsLoadMeter extends StatelessWidget {
  const DsLoadMeter({required this.count, required this.label, required this.stateLabels, this.threshold = 5, super.key});
  final int count, threshold;
  final String label;
  final List<String> stateLabels; // 3 states
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final state = count <= (threshold * 0.6).floor() ? 0 : count <= threshold ? 1 : 2;
    final c = state == 0 ? lk.success : state == 1 ? lk.warn : lk.danger;
    final on = threshold == 0 ? 0 : ((count / threshold) * 5).clamp(0, 5).round();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lk.line))),
      child: Row(children: [
        Row(mainAxisSize: MainAxisSize.min, children: [for (var i = 0; i < 5; i++) Container(width: 12, height: 18, margin: const EdgeInsets.only(left: 3), decoration: BoxDecoration(color: i < on ? c : lk.line, borderRadius: BorderRadius.circular(2)))]),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(color: lk.ink, fontSize: 15))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(999)), child: Text(stateLabels[state.clamp(0, stateLabels.length - 1)], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

// ── G32 · DsActionRow (row + up to 5 one-tap actions) ──
class DsActionRow extends StatelessWidget {
  const DsActionRow({required this.title, this.sub = '', this.actions = const [], this.onAct, this.tone = 0, super.key});
  final String title, sub;
  final List<String> actions;
  final ValueChanged<int>? onAct;
  final int tone; // 0 normal · 2 overdue
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lk.line))),
      child: Row(children: [
        Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: tone == 2 ? lk.danger : lk.muted, width: 1.5))),
        const SizedBox(width: 12),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: lk.ink, fontSize: 16, height: 1.4)),
          if (sub.isNotEmpty) Text(sub, style: TextStyle(color: tone == 2 ? lk.danger : lk.muted, fontSize: 13)),
        ])),
        for (var i = 0; i < actions.length && i < 5; i++) GestureDetector(onTap: onAct == null ? null : () => onAct!(i), child: Padding(padding: const EdgeInsets.only(right: 6), child: DsChip(label: actions[i], tone: i == 0 ? 0 : 2))),
      ]),
    );
  }
}

// ── G32 · DsApproveCard (ask before acting: ok / no / always + source) ──
class DsApproveCard extends StatelessWidget {
  const DsApproveCard({required this.question, this.source = '', required this.okLabel, required this.noLabel, this.alwaysLabel = '', required this.onOk, required this.onNo, this.onAlways, super.key});
  final String question, source, okLabel, noLabel, alwaysLabel;
  final VoidCallback onOk, onNo;
  final VoidCallback? onAlways;
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: lk.cardAlt, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Text(question, style: TextStyle(color: lk.ink, fontSize: 16, height: 1.4)),
        if (source.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Text(source, style: TextStyle(color: lk.muted, fontSize: 13))),
        Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [
          GestureDetector(onTap: onOk, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: lk.accent, borderRadius: BorderRadius.circular(9)), child: Text(okLabel, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)))),
          const SizedBox(width: 8),
          GestureDetector(onTap: onNo, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(border: Border.all(color: lk.line), borderRadius: BorderRadius.circular(9)), child: Text(noLabel, style: TextStyle(color: lk.ink, fontSize: 14, fontWeight: FontWeight.w600)))),
          if (onAlways != null && alwaysLabel.isNotEmpty) ...[const SizedBox(width: 8), GestureDetector(onTap: onAlways, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(border: Border.all(color: lk.line), borderRadius: BorderRadius.circular(9)), child: Text(alwaysLabel, style: TextStyle(color: lk.ink, fontSize: 14, fontWeight: FontWeight.w600))))],
        ])),
      ]),
    );
  }
}

// ── G33 · DsChipButton (flat outline action) ──
class DsChipButton extends StatelessWidget {
  const DsChipButton({required this.label, this.onTap, super.key});
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(border: Border.all(color: lk.line), borderRadius: BorderRadius.circular(9)), child: Text(label, style: TextStyle(color: lk.ink, fontSize: 14, fontWeight: FontWeight.w600))));
  }
}

// ── G33 · DsTodayItem (one today-row shared by all modules; act = bound closure) ──
class DsTodayItem {
  const DsTodayItem({required this.title, required this.sub, required this.due, required this.hard, required this.overdue, required this.module, required this.actions, required this.act, this.rid = '', this.field = ''});
  final String title, sub, module, rid, field;
  final DateTime due;
  final bool hard, overdue;
  final List<String> actions;
  final void Function(int i) act;
}

// ── G32 · DsLogRow (log row + undo) ──
class DsLogRow extends StatelessWidget {
  const DsLogRow({required this.text, this.sub = '', this.undoLabel = '', this.onUndo, super.key});
  final String text, sub, undoLabel;
  final VoidCallback? onUndo;
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lk.line))),
      child: Row(children: [
        Container(width: 18, height: 18, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: lk.success.withValues(alpha: 0.12)), child: Icon(Icons.check, size: 12, color: lk.success)),
        const SizedBox(width: 12),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(text, style: TextStyle(color: lk.ink, fontSize: 15, height: 1.4)),
          if (sub.isNotEmpty) Text(sub, style: TextStyle(color: lk.muted, fontSize: 13)),
        ])),
        if (onUndo != null && undoLabel.isNotEmpty) GestureDetector(onTap: onUndo, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text(undoLabel, style: TextStyle(color: lk.muted, fontSize: 13)))),
      ]),
    );
  }
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
    final lk = DsLook.of(context);
    final paper = lk.paper;
    final items = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final done = i <= current;
      if (i > 0) {
        items.add(Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(gradient: paper ? null : (i <= current ? DsTokens.accentGrad : null), color: paper ? (i <= current ? lk.accent : lk.line) : (i <= current ? null : DsTokens.line)))));
      }
      items.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30, height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: paper ? null : (done ? DsTokens.accentGrad : null),
              color: paper ? (done ? lk.accent : lk.card) : (done ? null : DsTokens.card),
              shape: BoxShape.circle,
              border: Border.all(color: done ? Colors.transparent : lk.line, width: 2),
              boxShadow: paper ? null : (i == current ? DsTokens.glow : null),
            ),
            child: Text('${i + 1}', style: TextStyle(color: done ? Colors.white : lk.faint, fontSize: 13, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 54,
            child: Text(steps[i], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: i == current ? lk.ink : lk.faint, fontSize: 10.5, fontWeight: i == current ? FontWeight.w700 : FontWeight.w500)),
          ),
        ],
      ));
    }
    return Container(
      margin: const EdgeInsets.only(bottom: DsTokens.gap),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: paper
          ? BoxDecoration(border: Border(bottom: BorderSide(color: lk.line)))
          : BoxDecoration(color: DsTokens.card, borderRadius: BorderRadius.circular(DsTokens.r), border: Border.all(color: DsTokens.line), boxShadow: DsTokens.shadow),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }
}

// ── כפתור-ראשי (gradient-ניאון + זוהר · paper: אקצנט-מלא שטוח, רדיוס 12) ──
class DsPrimaryButton extends StatelessWidget {
  const DsPrimaryButton({required this.label, this.onTap, super.key});
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final paper = lk.paper;
    return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(paper ? 12 : 13),
          gradient: paper ? null : DsTokens.accentGrad,
          color: paper ? lk.accent : null,
          boxShadow: paper ? null : DsTokens.glow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(paper ? 12 : 13),
            onTap: onTap ?? () {},
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: paper ? null : BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0x24FFFFFF)),
              ),
              child: Text(label, style: TextStyle(color: Colors.white, fontSize: paper ? 16 : 15.5, fontWeight: paper ? FontWeight.w600 : FontWeight.w800, letterSpacing: paper ? 0 : 0.2)),
            ),
          ),
        ),
      );
  }
}

// ── שבב-סטטוס ──
class DsChip extends StatelessWidget {
  const DsChip({required this.label, this.tone = 0, super.key});
  final String label;
  final int tone; // 0 accent · 1 success · 2 muted
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final bg = tone == 1 ? lk.successSoft : tone == 2 ? lk.track : lk.accentSoft;
    final fg = tone == 1 ? lk.success : tone == 2 ? lk.muted : lk.accentDark;
    final bd = lk.paper ? Colors.transparent : (tone == 1 ? const Color(0x3334D399) : tone == 2 ? DsTokens.line : const Color(0x407C3AED));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: bd)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ── אריח-KPI (דשבורד) — ערך בגרדיאנט-טקסט (paper: מספר-גדול על לבן, קו) ──
class DsStat extends StatelessWidget {
  const DsStat({required this.label, required this.value, required this.sub, required this.glyph, this.onTap, super.key});
  final String label, value, sub, glyph;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final paper = lk.paper;
    final card = Container(
        padding: const EdgeInsets.all(16),
        decoration: paper
            ? BoxDecoration(color: lk.card, borderRadius: BorderRadius.circular(lk.r), border: Border.all(color: lk.line))
            : BoxDecoration(
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
                if (!paper) Container(
                  width: 34, height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: DsTokens.accentSoft, borderRadius: BorderRadius.circular(9), border: Border.all(color: const Color(0x337C3AED))),
                  child: Text(glyph, style: const TextStyle(fontSize: 17)),
                ),
                const Spacer(),
                if (paper)
                  Text(value, style: TextStyle(color: lk.ink, fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5, fontFamily: lk.fontHead, fontFeatures: const [FontFeature.tabularFigures()]))
                else
                  ShaderMask(
                    shaderCallback: (r) => DsTokens.inkGrad.createShader(r),
                    child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -0.6, fontFamily: DsTokens.fontHead)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: lk.ink, fontSize: 14, fontWeight: paper ? FontWeight.w600 : FontWeight.w700)),
            const SizedBox(height: 2),
            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: lk.muted, fontSize: paper ? 13 : 11.5, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(lk.r),
      child: InkWell(borderRadius: BorderRadius.circular(lk.r), onTap: onTap, child: card),
    );
  }
}

// ── שורת-ניווט (לוח) — paper: שורה 52px, כותרת+מטא, קו-מפריד, בלי כרטיס ובלי אריח-אמוג׳י ──
class DsNavTile extends StatelessWidget {
  const DsNavTile({required this.glyph, required this.title, required this.sub, required this.onTap, super.key});
  final String glyph, title, sub;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    if (lk.paper) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: lk.line))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: lk.ink, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5)),
                      if (sub.isNotEmpty) Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: lk.muted, fontSize: 13, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left, color: lk.muted, size: 20),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
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
    final lk = DsLook.of(context);
    final rows = <Widget>[];
    for (var i = 0; i < labels.length && i < values.length; i++) {
      if (hidden.contains(i)) continue;   // RLS · עמודה מוסתרת לתפקיד
      if (values[i].trim().isEmpty) continue;
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(labels[i], style: TextStyle(color: lk.faint, fontSize: 12.5, fontWeight: FontWeight.w600))),
            const SizedBox(width: 8),
            Expanded(child: Text(values[i], style: TextStyle(color: lk.ink, fontSize: 13.5, fontWeight: FontWeight.w600))),
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
                          Icon(i == stageIndex ? Icons.radio_button_checked : Icons.radio_button_off, size: 16, color: i == stageIndex ? lk.accent : lk.faint),
                          const SizedBox(width: 8),
                          Text(stages[i], style: const TextStyle(fontSize: 13.5)),
                        ]),
                      ),
                  ],
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    DsChip(label: stage, tone: stageDone ? 1 : 0),
                    const SizedBox(width: 2),
                    Icon(Icons.expand_more, size: 15, color: lk.faint),
                  ]),
                ),
              const Spacer(),
              if (stage.isNotEmpty && !stageDone && onAdvance != null)
                Material(
                  color: lk.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onAdvance,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('קדם שלב', style: TextStyle(color: lk.accentDark, fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_back, size: 14, color: lk.accentDark),
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
                    icon: Icon(Icons.delete_outline, size: 18, color: blockedReason != null ? lk.faint : lk.muted),
                    tooltip: blockedReason != null ? 'מחיקה חסומה' : 'מחק',
                  ),
                ),
            ],
          ),
        ),
        ...rows.isEmpty ? [Text('—', style: TextStyle(color: lk.faint))] : rows,
        if (footer != null) Padding(padding: const EdgeInsets.only(top: 10), child: footer),
      ],
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: lk.cardAlt,
        borderRadius: BorderRadius.circular(lk.rSm),
        border: Border.all(color: lk.line),
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
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            Container(
              width: 46, height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: lk.track, borderRadius: BorderRadius.circular(13), border: Border.all(color: lk.line)),
              child: Icon(Icons.inbox_outlined, color: lk.faint, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(color: lk.muted, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      );
  }
}
