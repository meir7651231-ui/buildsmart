// 🏫 SchoolOS — בנייה מאפס לפי THE-WAY הנכון (פעולה-ראשונה · הרכבה-תמיד).
// כל מסך: מטרה → פעולות-יסוד הכי-מתאימות → הרכבה (תמיד כמה) → חיווט → אימות-מול-המטרה.
// בוחרים פעולת-יסוד, לא "אטום"; האטום רק מגלם. לעולם אין אטום-אחד שמשרת מטרה מקסימלית.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/ds/ds_seam.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/premium/lists/stat_row.dart';

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

  // המקסימום = ההחלטה השלמה (3 נגזרות-אמת, אפס-זיוף):
  //  · ימים-עד-ריקון  → StatRow (בר-דחיפות: קצר=דחוף) + ערך
  //  · כמות-להזמנה    → יעד − נוכחי
  //  · מועד-אחרון     → ריקון − זמן-אספקה (הזמן עד אז או תאזל בזמן-האספקה)
  Widget _row(String name, int cur, int target, double daysLeft, int lead) {
    final d = daysLeft.round();
    final urgent = daysLeft < lead;
    final qty = (target - cur).clamp(0, target);
    final within = (daysLeft - lead).round();
    final frac = (daysLeft / (lead * 2)).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StatRow(label: urgent ? '$name · 🔴' : name, value: '$d ימים לריקון', fraction: frac),
        if (urgent)
          Padding(
            padding: const EdgeInsets.only(top: 3, right: 4),
            child: Text('🛒 הזמן $qty יח׳ · ${within <= 0 ? 'הזמן היום' : 'תוך $within ימים'}',
                style: const TextStyle(color: _acc, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
      ]),
    );
  }
}
