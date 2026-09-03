// 🏫 SchoolOS — בנייה מאפס לפי THE-WAY הנכון (פעולה-ראשונה · הרכבה-תמיד).
// כל מסך: מטרה → פעולות-יסוד הכי-מתאימות → הרכבה (תמיד כמה) → חיווט → אימות-מול-המטרה.
// בוחרים פעולת-יסוד, לא "אטום"; האטום רק מגלם. לעולם אין אטום-אחד שמשרת מטרה מקסימלית.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/ds/ds_seam.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/premium/dataviz/neon_bars.dart';
import '../dart-ui-bs/bare_stat.dart';
import '../dart-ui-bs/premium/surfaces/gradient_card.dart';
import '../dart-ui-bs/premium/lists/media_row.dart';
import '../dart-ui-bs/premium/lists/stat_row.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';

const _acc = DsTokens.accent;
// פיגמנטים מוזרקים לאטומי-מדף טהורים (BareStat דורש הזרקת-צבע — חוק-6: צבע=הצבה, לא ציור)
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);

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
            SizedBox(width: 168, child: KpiTile(glyph: '📦', value: '${_InvData.urgent}', label: 'מלאי לא-יספיק')),
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
// דאטה+מנוע טהור (אפס-DOM): חוזה-הפריט + הפסים. חוזה: knowledge/INVENTORY-DATA-CONTRACT-2026-09-02.md
//   שדות-חובה: name·cur·target·rate·lead · שדות-אופציה: supplier?·price? (מוצגים רק כשקיימים).
class _InvData {
  static const int horizon = 4; // חלון-תכנון: כמה ימים מראש מזהירים לפני שחייבים להזמין
  static const items = <Map<String, dynamic>>[
    {'name': 'טונר מדפסת', 'cur': 3, 'target': 20, 'rate': 1.0, 'lead': 4, 'supplier': 'אופיס-דיפו', 'price': 89},
    {'name': 'נייר A4 (חבילות)', 'cur': 8, 'target': 30, 'rate': 2.0, 'lead': 5},
    {'name': 'חומרי ניקוי', 'cur': 40, 'target': 80, 'rate': 3.0, 'lead': 7},
    {'name': 'ערכות מעבדה', 'cur': 6, 'target': 40, 'rate': 0.5, 'lead': 10, 'supplier': 'סיינס-לאב', 'price': 240},
    {'name': 'מקרנים (חלופיים)', 'cur': 22, 'target': 30, 'rate': 0.2, 'lead': 14},
  ];
  // חוזה-תצוגה של שדות-מטא = דאטה (לא קוד-פר-שדה). המקום-השמור: הרינדור לולאה גנרית מעל זה.
  // הוספת שורה כאן ⇒ השדה מופיע לכל רשומה שנושאת אותו, אפס-שינוי-קוד (מבחן-הקונכייה, חוק-7).
  // (מלאי 'cur' שודרג מ-chip ל-StatRow נוגזרת נוכחי/יעד — לכן יצא מכאן; אלה נשארים facts אטומיים)
  static const metaFields = <Map<String, String>>[
    {'key': 'rate', 'prefix': '', 'suffix': '/יום'},
    {'key': 'supplier', 'prefix': '🏭 ', 'suffix': ''},
    {'key': 'price', 'prefix': '₪ ', 'suffix': ' ליח׳'},
  ];

  static double daysLeft(Map<String, dynamic> s) => (s['cur'] as int) / (s['rate'] as double);
  // כמה ימים עד שחייבים להזמין = ימים-עד-ריקון − זמן-אספקה (שלילי ⇒ כבר עברת)
  static double mustOrderIn(Map<String, dynamic> s) => daysLeft(s) - (s['lead'] as int);
  // שלושת-הפסים (הגוי-האמת של "בזמן להזמין"): 2=הזמן-היום · 1=הזמן-בקרוב · 0=בטוח
  static int band(Map<String, dynamic> s) {
    final m = mustOrderIn(s);
    if (m <= 0) return 2;
    if (m <= horizon) return 1;
    return 0;
  }

  static int get urgent => items.where((s) => band(s) == 2).length; // לא-יספיק (ל-_Home)
}

class _Inventory extends StatefulWidget {
  const _Inventory();
  @override
  State<_Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<_Inventory> {
  final Set<String> _ordered = {}; // זיכרון d2: פריטים שסומנו "הוזמן" (מצב=חיווט לגיטימי)

  @override
  Widget build(BuildContext context) {
    // דירוג לפי ימים-עד-ריקון עולה — הכי-קרוב-להיגמר ראשון
    final ranked = [..._InvData.items]..sort((a, b) => _InvData.daysLeft(a).compareTo(_InvData.daysLeft(b)));
    // Dp3+Dp8+Dp11: קיבוץ-לפי-מצב ⇒ הדחוף בראש כקבוצה, המצב דומיננטי-במבט, היררכיה.
    //   דלי לפי מצב (הוזמן=−1) — שומר על סדר-הדירוג בתוך כל דלי.
    final buckets = <int, List<Map<String, dynamic>>>{2: [], 1: [], 0: [], -1: []};
    for (final s in ranked) {
      buckets[_ordered.contains(s['name']) ? -1 : _InvData.band(s)]!.add(s);
    }
    // ה-KPI המצבי = הרכבת 3 פעולות-יסוד (לא מספר-אחד): ספירת-היום · ספירת-בקרוב · סכום-יחידות-בסיכון.
    int qtyOf(Map<String, dynamic> s) => ((s['target'] as int) - (s['cur'] as int)).clamp(0, s['target'] as int);
    final today = buckets[2]!.length;
    final soon = buckets[1]!.length;
    final unitsAtRisk = [...buckets[2]!, ...buckets[1]!].fold<int>(0, (a, s) => a + qtyOf(s));
    // כותרות-הסקשן = מצב + מונה (glyph-מצב נושא את הדומיננטיות)
    const secTitle = {2: '🔴 הזמן היום', 1: '🟠 הזמן בקרוב', 0: '🟢 מרווח בטוח', -1: '✅ הוזמן'};
    const secTone = {2: 2, 1: 3, 0: 1, -1: 1}; // אקסנט-הסקשן צבוע לפי-מצב (שקע tone החדש ב-DsSection)
    return DsScaffold(
      title: 'מלאי', subtitle: 'ימים-עד-ריקון מול זמן-אספקה — שלא ייגמר', icon: '📦',
      children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: 168, child: KpiTile(glyph: '🔴', value: '$today', label: 'הזמן היום')),
          SizedBox(width: 168, child: KpiTile(glyph: '🟠', value: '$soon', label: 'הזמן בקרוב')),
          SizedBox(width: 168, child: KpiTile(glyph: '🛒', value: '$unitsAtRisk', label: 'יח׳ להזמנה')),
        ]),
        const SizedBox(height: 8),
        for (final st in const [2, 1, 0, -1])
          if (buckets[st]!.isNotEmpty)
            DsSection(title: '${secTitle[st]} · ${buckets[st]!.length}', tone: secTone[st]!, children: [
              for (final s in buckets[st]!) _row(s),
            ]),
      ],
    );
  }

  // המקום-השמור (חוק-7): לולאה גנרית מעל חוזה-התצוגה (_InvData.metaFields) — לא קוד-פר-שדה.
  // כל שדה-מטא שהרשומה נושאת ⇒ שבב; חסר ⇒ שקט. שדה חדש בחוזה מופיע כאן לבד (אפס-רישום-ביד).
  List<Widget> _facts(Map<String, dynamic> s) => [
        for (final f in _InvData.metaFields)
          if (s[f['key']] != null) StatusChip(label: '${f['prefix']}${s[f['key']]}${f['suffix']}', tone: 0),
      ];

  Widget _wrap(List<Widget> kids, {double top = 6}) => Padding(
        padding: EdgeInsets.only(top: top, right: 4),
        child: Wrap(spacing: 8, runSpacing: 6, children: kids),
      );

  Widget _card(Widget inner) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GradientCard(child: inner),
      );

  // הצגה מקסימלית = הרכבת אטומי-הצגה, כל חלקיק מפורק לפעולות-היסוד שלו (לא אטום-אחד עצל):
  //  · זהות+מצב  → MediaRow (glyph · שם · תמצית-ריצה)
  //  · ההשוואה   → NeonBars (גדלֵי ריצה/אספקה; הפער נראה-בעין + נאמר במועד — לא צריך אטום-מרווח נפרד)
  //  · מלאי      → StatRow (נוכחי מתוך יעד + בר-מילוי — פעולות נוכחי·יעד·יחס, לא "N ביד" יחיד)
  //  · facts     → קצב/ספק/מחיר (chip אטומי לגיטימי, לולאה גנרית על metaFields)
  //  · ההחלטה    → StatusChip×2 (כמות/מועד) · הפעולה → SoftButton (זיכרון d2)
  Widget _row(Map<String, dynamic> s) {
    final name = s['name'] as String;
    final left = _InvData.daysLeft(s);
    final lead = s['lead'] as int;
    final cur = s['cur'] as int;
    final target = s['target'] as int;
    final ordered = _ordered.contains(name);
    final band = _InvData.band(s);
    final kids = <Widget>[
      MediaRow(glyph: '📦', title: name, subtitle: '${left.round()} ימים ריצה · אספקה $lead י׳'),
    ];
    if (ordered) {
      kids.add(_wrap([SoftButton(label: 'בטל', tone: 0, onTap: () => setState(() => _ordered.remove(name)))], top: 8));
      return _card(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: kids));
    }
    if (band >= 1) {
      // ההשוואה = חלקיק מרובה-אטומים: NeonBars (גדלים) + BareStat×2 (הפרש-בימים · יחס-כיסוי%) —
      //   שלוש פעולות-יסוד של שלושה אטומים לחלקיק-אחד (הכרעה 23-ב, בתצוגה).
      final margin = _InvData.mustOrderIn(s); // ריצה − אספקה
      final coverage = (left / lead * 100).round(); // כמה מזמן-האספקה הריצה מכסה; <100=לא-יספיק
      kids.add(Padding(padding: const EdgeInsets.only(top: 8), child: NeonBars(labels: const ['ימים-עד-ריקון', 'זמן-אספקה'], values: [left, lead.toDouble()])));
      kids.add(Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(children: [
          BareStat(value: '${margin.round()} י׳', label: 'מרווח מול הקו', inkColor: margin < 0 ? _danger : _ok, mutedColor: _muted),
          BareStat(value: '$coverage%', label: 'כיסוי-אספקה', inkColor: coverage < 100 ? _danger : _ok, mutedColor: _muted),
        ]),
      ));
    }
    // מלאי מול יעד: פעולת נוכחי·יעד·יחס (בר-מילוי), לא "N ביד" יחיד. ניסוח RTL-בטוח ("מתוך").
    kids.add(Padding(padding: const EdgeInsets.only(top: 8), child: StatRow(label: 'מלאי מול יעד', value: '$cur מתוך $target', fraction: target == 0 ? 0 : cur / target)));
    kids.add(_wrap(_facts(s)));
    if (band >= 1) {
      final qty = ((s['target'] as int) - (s['cur'] as int)).clamp(0, s['target'] as int);
      final mustIn = _InvData.mustOrderIn(s).ceil();
      final tone = band == 2 ? 2 : 3;
      kids.add(_wrap([
        StatusChip(label: '🛒 $qty יח׳ להזמנה', tone: tone),
        StatusChip(label: band == 2 ? 'הזמן היום' : 'הזמן תוך $mustIn ימים', tone: tone),
      ]));
      kids.add(_wrap([SoftButton(label: 'סמן: הוזמן', tone: 1, onTap: () => setState(() => _ordered.add(name)))], top: 8));
    }
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: kids));
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
