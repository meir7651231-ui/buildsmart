// ⚛️ אטום-Dart (דרגת-חוזה) · parseSupporterGrid — פענוח רשת-תאים (CSV/xlsx) לשורות-ייבוא.
// מוצא: maor/src/components/supporters/lib.ts:416-505 · המקור: new/atoms/parse-supporter-grid.mjs.
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). שלושת השכנים = שקעי-פרמטר (חוק-1/חוק-3):
//        supNameKeys · parseAnyDate · excelSerialToIso.
//
// הערות-המרה (מקור→Dart, לפי machtzev/emit/DART-PORTING-RULES.md):
//  • Number(str) של JS ≠ num.tryParse: JS Number('')===0, Number('אבג-נקי')===0, קלט-רע===NaN.
//    ⇒ שקע _jsNumber שמחקה: ריק⇒0.0, tryParse-נכשל⇒NaN. (כלל 10)
//  • Math.round על NaN: JS מחזיר NaN; Dart .round() על NaN זורק. ⇒ שומר-isFinite לפני round.
//  • גישה-מחוץ-לטווח: JS r[i]===undefined⇒''; Dart List[i] זורק. ⇒ שומר i<r.length ב-g.
//  • ?? '' של JS תופס null+undefined; המרנו ל-_s (null⇒''), ואת .includes ל-.contains.
//  • מפתחות-מטא אופציונליים (spread מותנה): מוסיפים את המפתח ל-Map רק אם התנאי אמת —
//    כך `'brand' in hist[0] === false` נשמר (מפתח נעדר, לא null). (כלל 2 — null≠undefined)
//  • isFinite = גלובל-שפה (num.isFinite), אינו שקע.

/// Verbatim port of new/atoms/parse-supporter-grid.mjs (`parseSupporterGrid`).
/// [rows] — grid of cells (rows of cells; cells are strings or null).
/// Shims (wired to real atoms in the box): [supNameKeys], [parseAnyDate], [excelSerialToIso].
List<Map<String, dynamic>> parseSupporterGrid(List<List<Object?>> rows,
  List<String> supNameKeys,
  String Function(String) parseAnyDate,
  String Function(num) excelSerialToIso, Map<String, dynamic> T) {
  if (rows.isEmpty) return [];

  String s(Object? v) => v == null ? '' : v.toString();

  // שורת-הכותרות = הראשונה (מבין 15 העליונות) שיש בה עמודת-שם ("שם"/"תורם").
  int hdrIdx = -1;
  final lim = rows.length < 15 ? rows.length : 15;
  for (int i = 0; i < lim; i++) {
    final r = rows[i];
    if (r.any((h) => supNameKeys.any((k) => s(h).contains(k)))) {
      hdrIdx = i;
      break;
    }
  }

  final header =
      (hdrIdx >= 0 ? rows[hdrIdx] : rows[0]).map((h) => s(h).trim()).toList();
  int find(List<String> keys) =>
      header.indexWhere((h) => keys.any((k) => h.contains(k)));

  int iName = find(supNameKeys);
  int iPhone = find([(T['k1'] as String), (T['k2'] as String)]);
  int iEmail = find([(T['k3'] as String), (T['k4'] as String), 'email']);
  int iId = find([(T['k6'] as String), (T['k7'] as String), (T['k8'] as String)]);
  int iAddr = find([(T['k9'] as String)]);
  int iCat = find([(T['k10'] as String)]);
  int iFor = find([(T['k11'] as String), (T['k12'] as String)]);
  // קובץ מסוף-הסליקה (ExportHistory): עמודות סכום/תאריך-עסקה/מטבע ⇒ היסטוריה-ללא-קבלה.
  final iAmount = find([(T['k13'] as String)]);
  final iTxDate = find([(T['k14'] as String)]);
  final iCur = find([(T['k15'] as String)]);
  // כל שאר עמודות-הסליקה נקלטות למטא-דאטה של רשומת-ההיסטוריה.
  final iRef = find([(T['k16'] as String)]);
  final iTxn = find([(T['k17'] as String)]);
  final iReceipt = find([(T['k18'] as String)]);
  final iBrand = find([(T['k19'] as String)]);
  final iLast4 = find([(T['k20'] as String), (T['k21'] as String)]);
  final iClearer = find([(T['k22'] as String), (T['k23'] as String)]);
  final iPays = find([(T['k24'] as String)]);
  final iStatus = find([(T['k25'] as String)]);

  int start = hdrIdx >= 0 ? hdrIdx + 1 : 1;
  if (iName < 0) {
    // אין שורת כותרות מזוהה — סדר עמודות קבוע.
    iName = 0;
    iPhone = 1;
    iEmail = 2;
    iId = 3;
    iAddr = 4;
    iCat = 5;
    iFor = 6;
    start = 0;
  }

  String g(List<Object?> r, int i) =>
      (i >= 0 && i < r.length) ? s(r[i]).trim() : '';

  final out = <Map<String, dynamic>>[];
  final tail = start >= rows.length ? const <List<Object?>>[] : rows.sublist(start);
  final curRe = RegExp(r'דולר|\$|usd', caseSensitive: false);
  final nedRe = RegExp(r'נדרים|nedarim', caseSensitive: false);
  final serialRe = RegExp(r'^\d+(\.\d+)?$');

  for (final r in tail) {
    final name = g(r, iName);
    if (name.isEmpty) continue;
    final row = <String, dynamic>{
      'name': name,
      'phone': g(r, iPhone),
      'email': g(r, iEmail),
      'idNum': g(r, iId),
      'address': g(r, iAddr),
      'cat': g(r, iCat),
      'forWho': g(r, iFor),
    };
    if (iAmount >= 0 && iTxDate >= 0) {
      final cleaned = g(r, iAmount).replaceAll(RegExp(r'[^\d.-]'), '');
      final prod = _jsNumber(cleaned) * 100;
      final double amount = prod.isFinite ? prod.round() / 100 : double.nan;
      // 'תאריך עסקה' מגיע עם שעה ("09/08/26 00:36") — התאריך בלבד. תא מספר-סריאל
      // של Excel ⇒ parseAnyDate נכשל ⇒ המרה מסריאל.
      final rawDate = g(r, iTxDate).split(' ')[0];
      final pd = parseAnyDate(rawDate);
      final String d = pd.isNotEmpty
          ? pd
          : (serialRe.hasMatch(rawDate)
              ? excelSerialToIso(num.tryParse(rawDate) ?? double.nan)
              : '');
      if (amount.isFinite && amount > 0 && d.isNotEmpty) {
        // מטא-דאטה: רק שדות שקיימים בפועל (המפתח נעדר אחרת).
        final pays = _jsNumber(g(r, iPays));
        final hist = <String, dynamic>{'d': d, 'a': amount};
        if (curRe.hasMatch(g(r, iCur))) hist['c'] = '\$';
        if (g(r, iRef).isNotEmpty) hist['ref'] = g(r, iRef);
        if (g(r, iTxn).isNotEmpty) hist['txn'] = g(r, iTxn);
        if (g(r, iReceipt).isNotEmpty) hist['receipt'] = g(r, iReceipt);
        if (g(r, iBrand).isNotEmpty) hist['brand'] = g(r, iBrand);
        if (g(r, iLast4).isNotEmpty) hist['last4'] = g(r, iLast4);
        if (g(r, iClearer).isNotEmpty) {
          hist['clearer'] =
              nedRe.hasMatch(g(r, iClearer)) ? (T['k26'] as String) : g(r, iClearer);
        }
        if (iPays >= 0 && pays.isFinite && pays > 0) hist['pays'] = pays;
        if (g(r, iStatus).isNotEmpty) hist['status'] = g(r, iStatus);
        row['hist'] = [hist];
      }
    }
    // הוסר אוטומט-העי"ן: קטגוריה "הסרת עין הרע" היא ייעוד-תרומה, לא הוראה לפתוח תיק.
    out.add(row);
  }
  return out;
}

/// מחקה את Number(str) של JS: מחרוזת-ריקה⇒0.0, כשל-פרסור⇒NaN. (DART-PORTING-RULES כלל 10)
double _jsNumber(String v) {
  final t = v.trim();
  if (t.isEmpty) return 0.0;
  final n = num.tryParse(t);
  return n == null ? double.nan : n.toDouble();
}
