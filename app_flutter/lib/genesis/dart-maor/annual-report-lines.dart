// ⚛️ אטום-Dart (דרגת-חוזה) · annualReportLines — שורות דוח-שנתי לתורם/ת יחיד/ה.
// מוצא: maor/src/lib/annualReport.ts · המקור: new/atoms/annual-report-lines.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). שני השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        donationsOfYear(donations, year) · money(amount, [cur]).
//
// תפקיד: מקטע-שורות לתורם/ת — כותרת, פרטי-ארגון/תורם, טבלת-תרומות-השנה, סיכומים,
//        פסקת-§46 (רק כשיש orgTaxId) ושורת-אתר (רק כשיש site).
// קלט:  inp={orgName, orgTaxId?, supporterName, payerId?, year, donations, site?} +
//        donationsOfYear(donations, year)⇒תרומות-השנה · money(amount, [cur])⇒מחרוזת-כסף.
//        פלט: List<String>.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נטה לפספס):
//  • truthiness של JS: `inp.orgTaxId ? ... : []`, `d.rid ? ...`, `if (inp.site)` — כולם
//    שדות-מחרוזת/undefined. שוקעו ל-`_truthy` (null/''/false/0 = כבוי) — זהה לחוקי-JS.
//  • הספרד `...(cond ? [x] : [])` → collection-if בתוך ה-List-literal.
//  • `'='.repeat(46)` → `'=' * 46` · `.padStart(12)` → `.padLeft(12)`.
//  • `Number.isFinite(d.amount)` → `_isFinite` (num && isFinite; לא-מספר ⇒ false, כמו JS).
//  • `rows.length` בתוך שרשור-מחרוזת → `.length.toString()` (Dart אינו מצרף-אוטומטית).
//  • `d.cur !== '$'` על שורה בלי cur: undefined!=='$' ⇒ true (נכלל בשקלים); ב-Dart null!='$'
//    ⇒ true — סמנטיקה זהה.
//  • הגישה לשדות = Map (`inp['x']`/`d['x']`) — הנתונים הם Map, לא record.
//  • מוטביליות: `out` final (מוטבל דרך add) · `ils`/`usd` final; הפורמט/locale חי בשקע money.

bool _truthy(dynamic v) => v != null && v != false && v != '' && v != 0;

bool _isFinite(dynamic x) => x is num && x.isFinite;

/// A single supporter's yearly donation report. Verbatim port of
/// new/atoms/annual-report-lines.mjs (`annualReportLines`); the neighbours
/// donationsOfYear and money are injected as sockets (Law 1/3).
List<String> annualReportLines(Map<String, dynamic> inp,
  List<dynamic> Function(dynamic donations, dynamic year) donationsOfYear,
  String Function(dynamic amount, [dynamic cur]) money, Map<String, dynamic> T) {
  final rows = donationsOfYear(inp['donations'], inp['year']);
  final ils = rows
      .where((d) => (d as Map)['cur'] != '\$')
      .fold<num>(0, (a, d) => a + (_isFinite((d as Map)['amount']) ? d['amount'] as num : 0));
  final usd = rows
      .where((d) => (d as Map)['cur'] == '\$')
      .fold<num>(0, (a, d) => a + (_isFinite((d as Map)['amount']) ? d['amount'] as num : 0));
  final out = <String>[
    '=' * 46,
    T['k1']! + inp['year'].toString(),
    '=' * 46,
    '',
    T['k2']! + inp['orgName'].toString(),
    if (_truthy(inp['orgTaxId'])) T['k3']! + inp['orgTaxId'].toString(),
    T['k4']! +
        inp['supporterName'].toString() +
        (_truthy(inp['payerId']) ? T['k5']! + inp['payerId'].toString() : ''),
    '',
    '-' * 46,
  ];
  if (rows.length == 0) {
    out.add(T['k6']! + inp['year'].toString() + '.');
  } else {
    for (final d in rows) {
      final m = d as Map;
      out.add(
        m['date'].toString() +
            '  ' +
            money(m['amount'], m['cur']).padLeft(12) +
            (_truthy(m['rid']) ? T['k7']! + m['rid'].toString() : '') +
            (_truthy(m['designation']) ? '  · ' + m['designation'].toString() : ''),
      );
    }
  }
  out.add('-' * 46);
  out.add(T['k8']! + rows.length.toString() + T['k9']! + inp['year'].toString());
  if (ils > 0) out.add(T['k10']! + money(ils));
  if (usd > 0) out.add(T['k11']! + money(usd, '\$'));
  if (_truthy(inp['orgTaxId'])) {
    out.add('');
    out.add(T['k12']!);
    out.add(T['k13']!);
  }
  if (_truthy(inp['site'])) {
    out.add('');
    out.add(inp['site'].toString());
  }
  return out;
}
