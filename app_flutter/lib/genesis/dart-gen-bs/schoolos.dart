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
  // דאטה-אמת: מלאי · קצב-צריכה-יומי · זמן-אספקה (ימים)
  static const _items = <Map<String, dynamic>>[
    {'name': 'טונר מדפסת', 'cur': 3, 'rate': 1.0, 'lead': 4},
    {'name': 'נייר A4 (חבילות)', 'cur': 8, 'rate': 2.0, 'lead': 5},
    {'name': 'חומרי ניקוי', 'cur': 40, 'rate': 3.0, 'lead': 7},
    {'name': 'ערכות מעבדה', 'cur': 6, 'rate': 0.5, 'lead': 10},
    {'name': 'מקרנים (חלופיים)', 'cur': 22, 'rate': 0.2, 'lead': 14},
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
        DsSection(title: 'ימים-עד-ריקון · הכי-דחוף ראשון', children: [
          for (final s in ranked) _row(s['name'] as String, _daysLeft(s), s['lead'] as int),
        ]),
      ],
    );
  }

  Widget _row(String name, double daysLeft, int lead) {
    final urgent = daysLeft < lead;
    final d = daysLeft.round();
    // runway מול-אספקה: בקו-האספקה הבר=0.5; מתחת=לא-יספיק (בר קצר, נראה בעין)
    final frac = (daysLeft / (lead * 2)).clamp(0.0, 1.0);
    final label = urgent ? '$name · 🛒 הזמן עכשיו · אספקה ${lead}י' : '$name · אספקה ${lead}י';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: StatRow(label: label, value: '$d ימים', fraction: frac),
    );
  }
}
