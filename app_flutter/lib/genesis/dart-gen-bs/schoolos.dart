// 🏫 SchoolOS — בנייה מאפס לפי THE-WAY הנכון (פעולה-ראשונה · הרכבה-תמיד).
// כל מסך: מטרה → פעולות-יסוד הכי-מתאימות → הרכבה (תמיד כמה) → חיווט → אימות-מול-המטרה.
// בוחרים פעולת-יסוד, לא "אטום"; האטום רק מגלם. לעולם אין אטום-אחד שמשרת מטרה מקסימלית.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/ds/ds_seam.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/premium/lists/stat_row.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';

const _acc = DsTokens.accent;

void main() => runApp(const SchoolOsApp());

class SchoolOsApp extends StatelessWidget {
  const SchoolOsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Heebo', scaffoldBackgroundColor: DsTokens.bg, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: _acc, brightness: Brightness.dark)),
        builder: (c, ch) => PureScope(
          theme: DsPure.themes[DsPure.defaultTheme]!,
          fonts: const DsPureFonts(serif: 'Heebo', serifHe: 'FrankRuhlLibre', grotesk: 'JetBrains Mono', he: 'Heebo'),
          child: Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink()),
        ),
        home: const _Home(),
      );
}

// ═══════════ בית · מטרה: "לדעת מה דורש-פעולה עכשיו — בלי שדבר יישמט" ═══════════
class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'SchoolOS', subtitle: 'תיכון עתיד · מה דורש-פעולה עכשיו', icon: '🏫',
        children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            const SizedBox(width: 168, child: KpiTile(glyph: '🎓', value: '1,248', label: 'תלמידים')),
            SizedBox(width: 168, child: KpiTile(glyph: '📦', value: '${_Inventory.urgent}', label: 'מלאי לא-יספיק')),
          ]),
          const SizedBox(height: 8),
          DsSection(title: 'כלים', children: [
            DsNavTile(glyph: '🎓', title: 'תלמידים בסיכון', sub: 'מי מתחיל ליפול — בזמן להתערב', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _Students()))),
            DsNavTile(glyph: '📦', title: 'מלאי', sub: 'ימים-עד-ריקון מול אספקה — שלא ייגמר', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _Inventory()))),
          ]),
        ],
      );
}

// ═══════════ מלאי · מטרה: "שלא ייגמר פריט קריטי בלי שנספיק להזמין" ═══════════
// "לא ייגמר" זה ציר-זמן, לא מפלס-סטטי. פירוק-אמת לכמה פעולות-יסוד (הרכבה-תמיד):
//  1. ימים-עד-ריקון = מלאי ÷ קצב-צריכה   → הקרבה האמיתית (כמו dayDiff בלוח)
//  2. השוואה מול זמן-אספקה               → יספיק/לא-יספיק
//  3. דירוג לפי ימים-עד-ריקון            → הכי-דחוף ראשון
//  4. ציור runway מול-אספקה (StatRow)    → רואים בעין אם הבר מתחת לקו-האספקה
//  5. דגל-הזמנה                          → פעולה
class _Inventory extends StatelessWidget {
  const _Inventory();
  // דאטה-אמת: מלאי · יעד-בריא · קצב-צריכה-יומי · זמן-אספקה (ימים)
  static const _items = <Map<String, dynamic>>[
    {'name': 'טונר מדפסת', 'cur': 3, 'target': 20, 'rate': 1.0, 'lead': 4},
    {'name': 'נייר A4 (חבילות)', 'cur': 8, 'target': 30, 'rate': 2.0, 'lead': 5},
    {'name': 'חומרי ניקוי', 'cur': 40, 'target': 80, 'rate': 3.0, 'lead': 7},
    {'name': 'ערכות מעבדה', 'cur': 6, 'target': 40, 'rate': 0.5, 'lead': 10},
    {'name': 'מקרנים (חלופיים)', 'cur': 22, 'target': 30, 'rate': 0.2, 'lead': 14},
  ];
  static double _daysLeft(Map<String, dynamic> s) => (s['cur'] as int) / (s['rate'] as double);
  static int get urgent => _items.where((s) => _daysLeft(s) < (s['lead'] as int)).length;

  @override
  Widget build(BuildContext context) {
    // דירוג לפי ימים-עד-ריקון עולה — הכי-קרוב-להיגמר ראשון
    final ranked = [..._items]..sort((a, b) => _daysLeft(a).compareTo(_daysLeft(b)));
    return DsScaffold(
      title: 'מלאי', subtitle: 'ימים-עד-ריקון מול זמן-אספקה — שלא ייגמר', icon: '📦',
      children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: 190, child: KpiTile(glyph: '⏳', value: '$urgent', label: 'לא יספיק עד אספקה')),
          SizedBox(width: 190, child: KpiTile(glyph: '📦', value: '${_items.length}', label: 'פריטים')),
        ]),
        const SizedBox(height: 8),
        DsSection(title: 'החלטת-הזמנה · הכי-דחוף ראשון', children: [
          for (final s in ranked) _row(s['name'] as String, s['cur'] as int, s['target'] as int, _daysLeft(s), s['lead'] as int),
        ]),
      ],
    );
  }

  // המקסימום = ההחלטה השלמה מורכבת מ-3 נגזרות-אמת, כל אחת מגולמת באטום-מדף (אפס-ציור-ביד):
  //  · ימים-עד-ריקון  → StatRow   (בר-דחיפות: קצר=דחוף) + ערך
  //  · כמות-להזמנה    → StatusChip (יעד − נוכחי, tone=סכנה)
  //  · מועד-אחרון     → StatusChip (ריקון − זמן-אספקה; tone=סכנה אם היום, אחרת אזהרה)
  Widget _row(String name, int cur, int target, double daysLeft, int lead) {
    final d = daysLeft.round();
    final urgent = daysLeft < lead;
    final qty = (target - cur).clamp(0, target);
    final within = (daysLeft - lead).round();
    final frac = (daysLeft / (lead * 2)).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StatRow(label: name, value: '$d ימים לריקון', fraction: frac),
        if (urgent)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Wrap(spacing: 8, runSpacing: 6, children: [
              StatusChip(label: '🛒 $qty יח׳ להזמנה', tone: 2),
              StatusChip(label: within <= 0 ? 'הזמן היום' : 'תוך $within ימים', tone: within <= 0 ? 2 : 3),
            ]),
          ),
      ]),
    );
  }
}

// ═══════════ תלמידים בסיכון · מטרה: "לתפוס מי מתחיל ליפול — בזמן להתערב לפני נשירה" ═══════════
// ההחלטה השלמה: מי · למה (האות המוביל) · איזו התערבות. פעולות-יסוד מורכבות (אין מנוע-סיכון-תלמיד מוכן):
//  · ציון-סיכון      → ממוצע-משוקלל של אותות מנורמלים (היעדרויות40+פער-ציון40+מגמה20)
//  · האות-המוביל     → מקסימום-התרומה = הסיבה (מכתיב את ההתערבות)
//  · דירוג לפי-סיכון → הכי-קרוב-לנפילה ראשון · התערבות לפי-band
class _Students extends StatelessWidget {
  const _Students();
  // דאטה-אמת: אות פר-תלמיד — חיסורים(30י) · ממוצע · מגמה(מחצית-חדשה−ישנה)
  static const _st = <Map<String, dynamic>>[
    {'name': 'רון שמעוני · י\'-1', 'abs': 7, 'grade': 61, 'trend': -8},
    {'name': 'ליאור אוחיון · ט\'-3', 'abs': 5, 'grade': 68, 'trend': -5},
    {'name': 'הדר נחום · ח\'-2', 'abs': 4, 'grade': 72, 'trend': -3},
    {'name': 'מאיה ביטון · י\'-2', 'abs': 2, 'grade': 79, 'trend': 2},
    {'name': 'נועה לוי · י\'-3', 'abs': 0, 'grade': 91, 'trend': 3},
  ];
  static double _absN(Map<String, dynamic> s) => math.min(1.0, (s['abs'] as int) / 8);
  static double _gradeN(Map<String, dynamic> s) => math.max(0, 75 - (s['grade'] as int)) / 75;
  static double _trendN(Map<String, dynamic> s) => (s['trend'] as int) < 0 ? math.min(1.0, -(s['trend'] as int) / 8) : 0;
  static int _risk(Map<String, dynamic> s) => (_absN(s) * 40 + _gradeN(s) * 40 + _trendN(s) * 20).round();
  static int get atRisk => _st.where((s) => _risk(s) >= 45).length;

  // האות-המוביל = התרומה הגדולה-ביותר לסיכון (מכתיב את ההתערבות)
  String _why(Map<String, dynamic> s) {
    final a = _absN(s) * 40, g = _gradeN(s) * 40, t = _trendN(s) * 20;
    if (a >= g && a >= t) return 'היעדרויות (${s['abs']})';
    if (g >= t) return 'ציון נמוך (${s['grade']})';
    return 'מגמה שלילית (${s['trend']})';
  }

  String _action(int r) => r >= 70 ? 'ועדת-שילוב + ביקור-בית' : r >= 45 ? 'שיחת-מחנך + יידוע-הורים' : 'מעקב';

  @override
  Widget build(BuildContext context) {
    final ranked = [..._st]..sort((a, b) => _risk(b).compareTo(_risk(a))); // הכי-בסיכון ראשון
    return DsScaffold(
      title: 'תלמידים בסיכון', subtitle: 'מי מתחיל ליפול — מדורג, בזמן להתערב', icon: '🎓',
      children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: 190, child: KpiTile(glyph: '🚨', value: '$atRisk', label: 'דורשי-התערבות')),
          SizedBox(width: 190, child: KpiTile(glyph: '🎓', value: '${_st.length}', label: 'בכיתה')),
        ]),
        const SizedBox(height: 8),
        DsSection(title: 'החלטת-התערבות · הכי-בסיכון ראשון', children: [
          for (final s in ranked) _row(s),
        ]),
      ],
    );
  }

  // ההחלטה מורכבת מ-3 נגזרות-אמת, כל אחת מגולמת באטום-מדף (אפס-ציור-ביד):
  //  · ציון-סיכון  → StatRow   (בר: ארוך=בסיכון)
  //  · האות-המוביל → StatusChip (הסיבה; tone=סכנה בוועדת-שילוב, אחרת אזהרה)
  //  · ההתערבות    → StatusChip (הפעולה; אותו tone-band)
  Widget _row(Map<String, dynamic> s) {
    final r = _risk(s), act = r >= 45;
    final tone = r >= 70 ? 2 : 3;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StatRow(label: s['name'] as String, value: 'סיכון $r', fraction: (r / 100).clamp(0.0, 1.0)),
        if (act)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Wrap(spacing: 8, runSpacing: 6, children: [
              StatusChip(label: _why(s), tone: tone),
              StatusChip(label: _action(r), tone: tone),
            ]),
          ),
      ]),
    );
  }
}
