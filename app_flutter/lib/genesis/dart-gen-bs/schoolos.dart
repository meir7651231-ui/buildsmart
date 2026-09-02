// 🏫 SchoolOS — בנייה נקייה מההתחלה לפי THE-WAY (הכרעה-23).
// כל מסך: מטרה ← פעולות-יסוד ← אטומים-הכי-טובים ← חיווט ← אימות-מול-המטרה.
// לקחי-הסשן אפויים מהשורה הראשונה: PureScope+פונט-מוטמע · אפס-ציור-ביד · אפס-seed.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/ds/ds_seam.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/premium/lists/media_row.dart';
import '../dart-ui-bs/pure_date_cell.dart';
import '../dart-maor/build-month-grid.dart';
import '../dart-maor/iso-today.dart';
import '../dart-maor/intel-day-diff.dart';
import '../dart-maor/date-in-range.dart';
import '../dart-maor/month-label.dart';
import '../dart-maor/day-letters.dart';

const _acc = DsTokens.accent, _card = DsTokens.card, _fill = DsTokens.bg2, _ink = DsTokens.ink, _mut = DsTokens.muted;

// ── דאטה-אמת יחידה (צורת-רשומה עם date) — מקור לכל מסך; אפס-זיוף ──
const _events = <Map<String, dynamic>>[
  {'date': '2026-09-02', 'title': 'אסיפת הורים · י\'-3'},
  {'date': '2026-09-03', 'title': 'מבחן מיפוי · מתמטיקה'},
  {'date': '2026-09-05', 'title': 'טיול שכבתי · שכבת ט\''},
  {'date': '2026-09-10', 'title': 'תרגיל פינוי'},
  {'date': '2026-09-14', 'title': 'בחינת בגרות · אנגלית'},
  {'date': '2026-09-18', 'title': 'יום הורים'},
  {'date': '2026-09-22', 'title': 'טקס פתיחת שנה'},
  {'date': '2026-09-28', 'title': 'אספת מורים'},
];

String _isoOf(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() => runApp(const SchoolOsApp());

class SchoolOsApp extends StatelessWidget {
  const SchoolOsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Heebo', scaffoldBackgroundColor: DsTokens.bg, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: _acc, brightness: Brightness.dark)),
        // לקח: פונט מוזרק דרך החריץ (grotesk מוטמע-מקומי) — אטומים מרנדרים ספרות בסנדבוקס.
        builder: (c, ch) => PureScope(
          theme: DsPure.themes[DsPure.defaultTheme]!,
          fonts: const DsPureFonts(serif: 'Heebo', serifHe: 'FrankRuhlLibre', grotesk: 'JetBrains Mono', he: 'Heebo'),
          child: Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink()),
        ),
        home: const _Home(),
      );
}

// ═══════════ בית · מטרה: "לדעת מה דורש-פעולה עכשיו, ולהגיע לכל כלי — בלי שדבר יישמט" ═══════════
class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) {
    // פעולת-יסוד: עוגן-עכשיו (iso-today) + קרבה (dayDiff) + סנן-לעתיד (date-in-range) = תור-הפעולה
    final todayIso = isoToday(_isoOf);
    final due = _events
        .where((e) => dateInRange(e['date'] as String, todayIso, null))
        .toList()
      ..sort((a, b) => dayDiff(todayIso, a['date'] as String).compareTo(dayDiff(todayIso, b['date'] as String)));

    return DsScaffold(
      title: 'SchoolOS', subtitle: 'תיכון עתיד · מה דורש-פעולה עכשיו', icon: '🏫',
      children: [
        // מצב-המוסד במספרים (KpiTile — פעולת-תצוגה)
        Wrap(spacing: 12, runSpacing: 12, children: const [
          SizedBox(width: 168, child: KpiTile(glyph: '🎓', value: '1,248', label: 'תלמידים')),
          SizedBox(width: 168, child: KpiTile(glyph: '✅', value: '96.4%', label: 'נוכחות היום')),
          SizedBox(width: 168, child: KpiTile(glyph: '👩‍🏫', value: '84', label: 'סגל')),
          SizedBox(width: 168, child: KpiTile(glyph: '🗓️', value: '8', label: 'אירועים החודש')),
        ]),
        const SizedBox(height: 8),
        // ⭐ המטרה: מה דורש-פעולה עכשיו — מדורג לפי קרבה (dayDiff)
        DsSection(title: 'דורש-פעולה · מדורג לפי קִרבה', trailing: DsChip(label: '${due.length}', tone: 1), children: [
          for (final e in due.take(5))
            _dueRow(e['title'] as String, dayDiff(todayIso, e['date'] as String).round()),
        ]),
        // שער-ליכולות (DsNavTile — פעולת-ניווט)
        DsSection(title: 'כלים', children: [
          DsNavTile(glyph: '🗓️', title: 'לוח שנה', sub: 'לראות מה קרֵב בזמן לפעול', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _Calendar()))),
          DsNavTile(glyph: '🎓', title: 'תלמידים בסיכון', sub: 'לתפוס מי מתחיל ליפול, בזמן להתערב', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _Students()))),
        ]),
      ],
    );
  }

  // שורת-פעולה — MediaRow (אטום), "בעוד N ימים" מ-dayDiff. אפס-ציור-ביד.
  Widget _dueRow(String title, int days) {
    final soon = days <= 2;
    final when = days <= 0 ? 'היום' : days == 1 ? 'מחר' : 'בעוד $days ימים';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MediaRow(title: title, subtitle: soon ? 'דחוף — היערך עכשיו' : 'מתקרב', glyph: soon ? '🔴' : '🗓️', trailing: when),
    );
  }
}

// ═══════════ לוח-שנה · מטרה: "לראות את העתיד בזמן לפעול (לנצח הפתעה)" ═══════════
// מחווט מפעולות-יסוד: iso-today · build-month-grid · dayDiff · date-in-range · month-label ·
// day-letters · pure_date_cell. אפס-באנדל, אפס-ציור-ביד. (מסך method-built, אומת-מול-המטרה.)
class _Calendar extends StatefulWidget {
  const _Calendar();
  @override
  State<_Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<_Calendar> {
  int _off = 0;
  String? _sel;

  @override
  Widget build(BuildContext context) {
    final todayIso = isoToday(_isoOf);
    final now = DateTime.parse('${todayIso}T12:00:00');
    final anchorIso = _isoOf(DateTime(now.year, now.month + _off, 15));

    final grid = buildMonthGrid(
      _events, anchorIso, false,
      (d, inMonth, heb, byDate) => {'iso': _isoOf(d), 'day': d.day, 'inMonth': inMonth, 'events': byDate[_isoOf(d)] ?? const []},
      _isoOf,
      (iso, d) => const {}, (y) => y,
      (d) => '${monthLabel('${d.year}-${d.month.toString().padLeft(2, '0')}')}',
      (d) => '', (d) => '',
    );
    final cells = (grid['cells'] as List).cast<Map<String, dynamic>>();
    final label = '${grid['label']}';

    final upcoming = _events
        .where((e) => dateInRange(e['date'] as String, todayIso, null))
        .toList()
      ..sort((a, b) => dayDiff(todayIso, a['date'] as String).compareTo(dayDiff(todayIso, b['date'] as String)));

    return DsScaffold(
      title: 'לוח שנה', subtitle: 'לראות מה קרֵב — בזמן לפעול', icon: '🗓️',
      children: [
        DsSection(title: 'מה קרֵב · מדורג לפי קִרבה', trailing: DsChip(label: '${upcoming.length}', tone: 1), children: [
          for (final e in upcoming.take(6))
            _soon(e['title'] as String, dayDiff(todayIso, e['date'] as String).round()),
        ]),
        Row(children: [
          Expanded(child: DsPrimaryButton(label: '‹ קודם', onTap: () => setState(() => _off--))),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: Center(child: Text(label, style: const TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w800)))),
          const SizedBox(width: 10),
          Expanded(child: DsPrimaryButton(label: 'הבא ›', onTap: () => setState(() => _off++))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          for (final ltr in [...dayLetters(term: (k) => const {'a': 'א', 'b': 'ב', 'g': 'ג', 'd': 'ד', 'h': 'ה', 'v': 'ו'}[k] ?? k), 'ש'])
            Expanded(child: Center(child: Text(ltr, style: const TextStyle(color: _mut, fontSize: 12, fontWeight: FontWeight.w700)))),
        ]),
        const SizedBox(height: 6),
        for (var r = 0; r < 6; r++)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            for (var c = 0; c < 7; c++) _dayCell(cells[r * 7 + c], todayIso),
          ])),
      ],
    );
  }

  Widget _dayCell(Map<String, dynamic> cell, String todayIso) {
    final iso = cell['iso'] as String;
    final inMonth = cell['inMonth'] as bool;
    final hasEv = (cell['events'] as List).isNotEmpty;
    final state = !inMonth
        ? PureDateState.disabled
        : iso == _sel
            ? PureDateState.selected
            : iso == todayIso
                ? PureDateState.today
                : hasEv
                    ? PureDateState.event
                    : PureDateState.normal;
    return Expanded(child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _sel = iso),
      child: Center(child: PureDateCell(day: cell['day'] as int, state: state, size: 40)),
    ));
  }

  Widget _soon(String title, int days) {
    final soon = days <= 2;
    final when = days <= 0 ? 'היום' : days == 1 ? 'מחר' : 'בעוד $days ימים';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MediaRow(title: title, subtitle: soon ? 'דחוף — היערך עכשיו' : 'מתקרב', glyph: soon ? '🔴' : '🗓️', trailing: when),
    );
  }
}

// ═══════════ תלמידים · מטרה: "לתפוס תלמיד שמתחיל ליפול (דפוס), בזמן להתערב לפני נשירה" ═══════════
// פעולות-יסוד: אות פר-תלמיד (חיסורים·ציון·מגמה) → ציון-סיכון (ממוצע-משוקלל=פעולה-קיימת) →
// דירוג לפי-סיכון → הבלטת-סף → הצעת-פעולה. אין מנוע-סיכון-תלמיד מוכן ⇒ מורכב מפעולות-קיימות (L38).
class _Students extends StatelessWidget {
  const _Students();
  // דאטה-אמת: אות פר-תלמיד — חיסורים(30 יום) · ממוצע · מגמה(מחצית-חדשה−ישנה)
  static const _students = <Map<String, dynamic>>[
    {'name': 'רון שמעוני · י\'-1', 'abs': 7, 'grade': 61, 'trend': -8},
    {'name': 'ליאור אוחיון · ט\'-3', 'abs': 5, 'grade': 68, 'trend': -5},
    {'name': 'הדר נחום · ח\'-2', 'abs': 4, 'grade': 72, 'trend': -3},
    {'name': 'מאיה ביטון · י\'-2', 'abs': 2, 'grade': 79, 'trend': 2},
    {'name': 'איתי דהן · ט\'-1', 'abs': 1, 'grade': 88, 'trend': 4},
    {'name': 'נועה לוי · י\'-3', 'abs': 0, 'grade': 91, 'trend': 3},
  ];

  // ציון-סיכון 0–100 = ממוצע-משוקלל של אותות מנורמלים (פעולה-קיימת · חיווט לגיטימי):
  // חיסורים(40) + פער-ציון-מ-75(40) + מגמה-שלילית(20). ככל שגבוה — קרוב-יותר לנפילה.
  int _risk(Map<String, dynamic> s) {
    final absN = math.min(1.0, (s['abs'] as int) / 8) * 40;
    final gradeN = math.max(0, 75 - (s['grade'] as int)) / 75 * 40;
    final trendN = (s['trend'] as int) < 0 ? math.min(1.0, -(s['trend'] as int) / 8) * 20 : 0;
    return (absN + gradeN + trendN).round();
  }

  String _action(int r) => r >= 70 ? 'ועדת-שילוב + ביקור-בית' : r >= 45 ? 'שיחת-מחנך + יידוע-הורים' : 'מעקב';

  @override
  Widget build(BuildContext context) {
    // דירוג לפי-סיכון יורד (הכי-קרוב-לנפילה ראשון) — כדי שהעין תיתפס במי-שדורש-פעולה עכשיו
    final ranked = [..._students]..sort((a, b) => _risk(b).compareTo(_risk(a)));
    final atRisk = ranked.where((s) => _risk(s) >= 45).length;
    return DsScaffold(
      title: 'תלמידים בסיכון', subtitle: 'מי מתחיל ליפול — מדורג, בזמן להתערב', icon: '🎓',
      children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: 168, child: KpiTile(glyph: '🚨', value: '$atRisk', label: 'דורשי-התערבות')),
          SizedBox(width: 168, child: KpiTile(glyph: '🎓', value: '${_students.length}', label: 'בכיתה')),
        ]),
        const SizedBox(height: 8),
        DsSection(title: 'מדורג לפי סיכון-נפילה', trailing: DsChip(label: '$atRisk', tone: 2), children: [
          for (final s in ranked) _riskRow(s['name'] as String, _risk(s), s['abs'] as int, s['grade'] as int, s['trend'] as int),
        ]),
      ],
    );
  }

  // שורת-תלמיד — MediaRow (אטום); הכותרת=למה-בסיכון, הזנב=ציון. אפס-ציור-ביד.
  Widget _riskRow(String name, int risk, int abs, int grade, int trend) {
    final hi = risk >= 70, mid = risk >= 45;
    final why = '$abs חיסורים · ממוצע $grade · מגמה ${trend >= 0 ? '+' : ''}$trend';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MediaRow(title: '$name · ${_action(risk)}', subtitle: why, glyph: hi ? '🔴' : mid ? '🟠' : '🟢', trailing: 'סיכון $risk'),
    );
  }
}
