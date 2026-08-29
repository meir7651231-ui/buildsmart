// ⚛️ אטום-Dart (דרגת-חוזה) · receiptLines — שורות-הקבלה (§46 / רגילה / אישור-חנות S-).
// מוצא: maor/src/lib/receipt.ts:86-149 · המקור: new/atoms/receipt-lines.mjs (קריאות-השכן שוקעו).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). ארבעת השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        hebDateFull(iso) · amountInWords(amount, sym) · receiptVerifyCode(rid, amount, cur, date) ·
//        hebrewLocaleDate(iso).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נטה לפספס · לפי DART-PORTING-RULES):
//  • truthiness של JS: `o.copy ? …`, `o.method ? …`, `o.summary ? …`, `o.verify ? …`,
//    `o.orgTaxId ? …` — שדות-מחרוזת/undefined ⇒ שוקעו ל-`_truthy` (null/''/false/0 = כבוי).
//  • `o.currency || '₪'` / `o.orgName || 'מאור החסד'` ⇒ `_or` (מחזיר fallback על falsy).
//  • `o.mark === false` — השוואת-זהות ל-false: `o['mark'] == false` (null==false⇒false ⇒ נכלל,
//    כמו undefined!==false ב-JS). כלל-2: null≠undefined אך כאן ההשוואה ל-false זהה.
//  • `d.toLocaleDateString('he-IL')` (כלל-6 locale) ⇒ שקע `_gregorian`: d.m.yyyy ספרות-מערב.
//    כלל-4 (תאריך-מגלגל): regex `^\d{4}-\d{2}-\d{2}` + טווח-חודש 1..12 ויום 1..31 (JS פוסל
//    חודש-00/13 ויום-00, אך **מגלגל** יום-גולש 2026-02-30⇒מרץ) — DateTime מגלגל כמו V8.
//  • `o.amount.toLocaleString('he-IL')` (§46) ⇒ `_heGroup` (פסיק-אלפים, ספרות-מערב, בלי RTL).
//  • `cur + o.amount` (רגילה) / `'₪' + summary.totalDue` ⇒ צירוף-מספר גולמי `_jsNum`
//    (Number.toString — בלי קיבוץ; שלם⇒בלי נקודה עשרונית, כמו JS).
//  • הספרד `...(cond ? [x] : [])` → collection-if בתוך ה-List-literal.
//  • `o.summary?.nextDate` → גישה בטוחה: summary קיים truthy וגם nextDate truthy.
//  • הגישה לשדות = Map (`o['x']`) — הנתונים הם Map, לא record.

bool _truthy(dynamic v) => v != null && v != false && v != '' && v != 0;

/// מקביל ל-`a || b` של JS: מחזיר a כשהוא truthy, אחרת b.
dynamic _or(dynamic a, dynamic b) => _truthy(a) ? a : b;

/// Number.toString של JS: שלם ⇒ בלי נקודה עשרונית; אחרת ייצוג רגיל.
String _jsNum(dynamic n) {
  if (n is int) return n.toString();
  if (n is num) {
    if (n.isFinite && n == n.truncateToDouble()) return n.truncate().toString();
    return n.toString();
  }
  return n.toString();
}

/// he-IL grouping (thousands separator = comma), מקביל ל-Number.toLocaleString('he-IL'):
/// ספרות-מערב, פסיק כל שלוש ספרות שלמות, בלי סימן-RTL.
String _heGroup(num n) {
  final neg = n < 0;
  final abs = neg ? -n : n;
  final whole = abs.truncate();
  if (abs != whole) {
    final r = (abs * 1000).round() / 1000;
    final parts = r.toString().split('.');
    final frac = parts.length > 1 ? '.' + parts[1] : '';
    return (neg ? '-' : '') + _group3(r.truncate().toString()) + frac;
  }
  return (neg ? '-' : '') + _group3(whole.toString());
}

String _group3(String digits) {
  final buf = StringBuffer();
  final len = digits.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return buf.toString();
}

/// מקביל ל-`new Date(o.date.slice(0,10)+'T12:00:00')` ואז `isNaN?raw:toLocaleDateString('he-IL')`.
/// תאריך תקין ⇒ d.m.yyyy (ספרות-מערב); תאריך שבור ⇒ המחרוזת הגולמית כמות-שהיא.
String _gregorian(String raw) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
  if (m == null) return raw;
  final y = int.parse(m.group(1)!);
  final mo = int.parse(m.group(2)!);
  final d = int.parse(m.group(3)!);
  // JS פוסל חודש 00/13+ ויום 00; יום 1..31 מתקבל ומתגלגל (2026-02-30 ⇒ מרץ).
  if (mo < 1 || mo > 12 || d < 1 || d > 31) return raw;
  final dt = DateTime(y, mo, d, 12);
  return '${dt.day}.${dt.month}.${dt.year}';
}

/// Verbatim port of new/atoms/receipt-lines.mjs (`receiptLines`); ארבעת השכנים כשקעים.
List<String> receiptLines(
  Map<String, dynamic> o,
  String Function(dynamic iso) hebDateFull,
  String Function(dynamic amount, dynamic sym) amountInWords,
  String Function(dynamic rid, dynamic amount, dynamic cur, dynamic date) receiptVerifyCode,
  String Function(dynamic iso) hebrewLocaleDate,
) {
  final cur = _or(o['currency'], '₪');
  final gregorian = _gregorian(o['date'].toString());
  final heb = hebDateFull(o['date']);

  // קבלת סעיף 46 פורמלית — פריסה רשמית עם סכום-במילים, ת"ז ונוסח §46.
  if (_truthy(o['taxReceipt'])) {
    final curSym = cur == '\$' ? '\$' : '₪';
    final words = amountInWords(o['amount'], cur == '\$' ? '\$' : '₪');
    return <String>[
      if (o['mark'] != false) (_truthy(o['copy']) ? 'העתק נאמן למקור' : 'מקור'),
      _or(o['orgName'], 'מאור החסד').toString(),
      _truthy(o['orgTaxId']) ? 'מס׳ עמותה/מלכ"ר: ' + o['orgTaxId'].toString() : '',
      '',
      'קבלה על תרומה — לפי סעיף 46 לפקודת מס הכנסה',
      'קבלה מס׳: ' + o['rid'].toString(),
      if (_truthy(o['verify']))
        'קוד-אימות: ' + receiptVerifyCode(o['rid'], o['amount'], cur, o['date']),
      'תאריך: ' + (_truthy(heb) ? heb + ' · ' : '') + gregorian,
      '',
      'התקבל בתודה מאת: ' + o['payer'].toString(),
      _truthy(o['payerId']) ? 'ת"ז / ח"פ: ' + o['payerId'].toString() : '',
      'סכום: ' + curSym + _heGroup(o['amount'] as num),
      'במילים: ' + words,
      _truthy(o['method']) ? 'אמצעי תשלום: ' + o['method'].toString() : '',
      'עבור: ' + o['forWhat'].toString(),
      '',
      'תרומה זו מוכרת לצורכי מס לפי סעיף 46 לפקודת מס הכנסה.',
      'קבלה זו מהווה אסמכתא לתרומה שהתקבלה.',
      '',
      'בכבוד רב,',
      (_truthy(o['signatory']) ? o['signatory'].toString() : '') + '  ______________________',
      'חתימה וחותמת',
      _truthy(o['site']) ? 'אתר: ' + o['site'].toString() : '',
    ];
  }

  // תיקון (swarm-audit): סדרת S- (אישורי-תשלום של החנות — לא קבלת מס) מקבלת "אישור תשלום";
  // כל rid אחר (כולל R-/D- מסחריים בלי §46) נשאר ביט-זהה.
  final isShopConfirmation = o['rid'].toString().startsWith('S-');
  final summary = o['summary'];
  final hasSummary = _truthy(summary);
  final summaryMap = hasSummary ? (summary as Map) : null;
  final hasNext = hasSummary && _truthy(summaryMap!['nextDate']);
  return <String>[
    if (o['mark'] != false) (_truthy(o['copy']) ? 'העתק נאמן למקור' : 'מקור'),
    (isShopConfirmation ? 'אישור תשלום — ' : 'קבלה — ') + _or(o['orgName'], 'מאור החסד').toString(),
    (isShopConfirmation ? 'אישור מס׳: ' : 'קבלה מס׳: ') + o['rid'].toString(),
    if (_truthy(o['verify']))
      'קוד-אימות: ' + receiptVerifyCode(o['rid'], o['amount'], cur, o['date']),
    // תאריך עברי + לועזי, כמו באב-טיפוס
    'תאריך: ' + (_truthy(heb) ? heb + ' · ' : '') + gregorian,
    'התקבל מאת: ' + o['payer'].toString(),
    'סכום: ' + cur.toString() + _jsNum(o['amount']),
    _truthy(o['method']) ? 'אמצעי תשלום: ' + o['method'].toString() : '',
    'עבור: ' + o['forWhat'].toString(),
    // סיכום העסקה — verbatim מלגאסי receipt() (legacy:1264-1265)
    hasSummary
        ? 'סה"כ עסקה: ₪' +
            _jsNum(summaryMap!['totalDue']) +
            ' · שולם עד כה: ₪' +
            _jsNum(summaryMap['paidSoFar']) +
            ' · יתרה: ₪' +
            _jsNum(summaryMap['balance'])
        : '',
    hasNext
        ? 'תשלום הבא: ' +
            hebDateFull(summaryMap!['nextDate']) +
            ' · ' +
            hebrewLocaleDate(summaryMap['nextDate'])
        : '',
    _truthy(o['site']) ? 'אתר: ' + o['site'].toString() : '',
    'תודה על תמיכתכם',
  ];
}
