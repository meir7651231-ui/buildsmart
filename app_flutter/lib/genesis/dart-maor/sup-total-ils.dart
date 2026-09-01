/// חוט · sup-total-ils (Dart) — שווי-תורם כולל בש"ח: ₪ + $×שער (ברירת-מחדל 3.7).
/// מקור-האמת: new/atoms/sup-total-ils.mjs · חוזה: sup-total-ils.contract.md ·
/// מוצא: maor/src/components/supporters/lib.ts:143-150. השכנים supIls/supUsd
/// הוזרקו כשקעים (חוק-1 — אפס import של אטום אחר).
///
/// המקור (verbatim):
///   export function supTotalIls(sp, rate = 3.7, supIls, supUsd) {
///     return supIls(sp) + supUsd(sp) * rate;
///   }
///
/// הערות-המרה (DART-PORTING-RULES):
///  • חתימה: ב-JS ‏rate=3.7 פרמטר-אמצעי עם ברירת-מחדל והשקעים אחריו נדרשים;
///    ‏Dart אוסר optional-positional לפני required ⇒ ‏rate והשקעים הפכו named
///    (תקדים sup-score — ששם השקע `supTotalIls(sp, rate)` הוא בדיוק האטום הזה).
///    הסמנטיקה נשמרת: השמטה (=undefined של JS) ⇒ 3.7; ‏rate:null מפורש ⇒ null
///    (חוק-2: null ≠ "לא-הועבר") ⇒ ‏ToNumber(null)=0 ⇒ ענף-הדולר מתאפס — כמו ב-JS.
///  • חוק-17: ה-`+`/`*` של JS חיים במרחב-float64 ⇒ ‏_jsAdd/_jsMul כופים toDouble.
///  • חוק-15: ‏`supUsd(sp) * rate` = ‏ToNumber על שני האופרנדים ⇒ ‏_jsToNum
///    (null⇒0 · bool⇒1/0 · מחרוזת⇒פרסור-ES · אחר⇒NaN); כך גם תוצאות-השקעים
///    (החוזה מחייב number מהשקעים — ‏_jsToNum מרחיב בנאמנות במקום cast זורק).
///  • חוק-16: מחרוזת-rate נגזמת ב-‏_jsTrim בקבוצת-ES המדויקת (בלי U+0085/U+180E).
///  • חוק-18: ‏tryParse של Dart גוזם-רווחים-בעצמו ⇒ מאמתים דקדוק-מספר-ES קפדני
///    (עשרוני/hex/oct/bin/Infinity) לפני הפרסור; כשל ⇒ NaN (חוק-10 — בלי parse זורק).
///  • חוק-12 (_jsStr) אינו חל: אין באטום שום המרת-מספר-למחרוזת — ה-`+` מפעיל
///    שרשור רק כשאופרנד הוא מחרוזת, וזה מחוץ לתחום-החוזה (השקעים ⇒ number);
///    בתחום-החוזה שני האופרנדים מספריים ⇒ חיבור-double בלבד (כתקדים sup-score).
///  • אין מיון/תאריך/לוח/locale/מודולו/toLowerCase/מוטציה — חוקים 1/3/4/6/9/11/13/14 לא חלים.

/// שווי-תורם כולל בש"ח (double, מרחב-JS): supIls(sp) + supUsd(sp) × rate.
dynamic supTotalIls(
  dynamic sp, {
  dynamic rate = 3.7,
  required dynamic Function(dynamic sp) supIls,
  required dynamic Function(dynamic sp) supUsd,
}) {
  // return supIls(sp) + supUsd(sp) * rate;
  return _jsAdd(supIls(sp), _jsMul(supUsd(sp), rate));
}

/// חוק-17: `a + b` של JS על מספרים = חיבור-float64.
double _jsAdd(dynamic a, dynamic b) => _jsToNum(a).toDouble() + _jsToNum(b).toDouble();

/// חוק-17: `a * b` של JS = ‏ToNumber על שניהם + כפל-float64.
double _jsMul(dynamic a, dynamic b) => _jsToNum(a).toDouble() * _jsToNum(b).toDouble();

/// ES ToNumber נאמן (חוקים 10/15/16/18): num כמו-שהוא · null ⇒ 0 · bool ⇒ 1/0 ·
/// מחרוזת ⇒ ‏_jsTrim ואז דקדוק-ES קפדני לפני פרסור (''⇒0 · ‏±Infinity ·
/// עשרוני עם נקודה/מעריך · ‏0x/0o/0b ללא-סימן · אחרת NaN) · אחר ⇒ NaN.
num _jsToNum(dynamic v) {
  if (v is num) return v;
  if (v == null) return 0;
  if (v is bool) return v ? 1 : 0;
  if (v is String) {
    final s = _jsTrim(v);
    if (s.isEmpty) return 0;
    if (s == 'Infinity' || s == '+Infinity') return double.infinity;
    if (s == '-Infinity') return double.negativeInfinity;
    // דקדוק עשרוני של ES: sign? (digits [. digits?] | . digits) exponent?
    final dec = RegExp(r'^([+-]?)(\d+(?:\.(\d*))?|\.(\d+))([eE][+-]?\d+)?$')
        .firstMatch(s);
    if (dec != null) {
      // קנוניזציה לפני double.parse — Dart דוחה '12.' / '.5' / '12.e3' ש-JS מקבל.
      final sign = dec.group(1)!;
      final body = dec.group(2)!;
      final exp = dec.group(5) ?? '';
      final dot = body.indexOf('.');
      final ip = dot < 0 ? body : body.substring(0, dot);
      final fp = dot < 0 ? '' : body.substring(dot + 1);
      return double.parse(
          '$sign${ip.isEmpty ? '0' : ip}.${fp.isEmpty ? '0' : fp}$exp');
    }
    // ‏0x/0o/0b — ללא-סימן בלבד (Number('-0x10') של JS ⇒ NaN).
    final radix = RegExp(r'^0([xX]([0-9a-fA-F]+)|[oO]([0-7]+)|[bB]([01]+))$')
        .firstMatch(s);
    if (radix != null) {
      final hex = radix.group(2), oct = radix.group(3), bin = radix.group(4);
      final int? n = hex != null
          ? int.tryParse(hex, radix: 16)
          : oct != null
              ? int.tryParse(oct, radix: 8)
              : int.tryParse(bin!, radix: 2);
      return n?.toDouble() ?? double.nan; // מעבר-int64 מחוץ לתחום-החוזה
    }
    return double.nan;
  }
  return double.nan;
}

// קבוצת-הרווחים של ECMAScript (חוק-16): TAB/LF/VT/FF/CR/SP/NBSP/BOM/Zs/LS/PS —
// בלי U+0085 (NEL) ו-U+180E, ש-String.trim של Dart גוזם ו-JS לא.
const String _esWs = '\t\n\u000B\f\r \u00A0\uFEFF'
    '\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007'
    '\u2008\u2009\u200A\u202F\u205F\u3000\u2028\u2029';

/// trim בקבוצת-ES המדויקת — לא String.trim של Dart (חוק-16).
String _jsTrim(String s) {
  var a = 0, b = s.length;
  while (a < b && _esWs.contains(s[a])) a++;
  while (b > a && _esWs.contains(s[b - 1])) b--;
  return s.substring(a, b);
}
