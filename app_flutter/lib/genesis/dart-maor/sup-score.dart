// ⚛️ אטום-Dart (דרגת-חוזה) · supScore — ציון-תורם RFM ‏0–1000 (טריות+תדירות+סכום).
// מוצא: maor/src/components/supporters/lib.ts:151-171 · המקור: new/atoms/sup-score.mjs ·
// חוזה: sup-score.contract.md. טוהר: פונקציית top-level עצמאית, אפס import
// (dart:core בלבד). חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
// השכנים supTotalIls/supLast/supCount הוזרקו כשקעים ו-Date.now ⇒ הזרקת-nowMs (חוק-1).
//
// המקור (verbatim):
//   export function supScore(sp, rate = 3.7, nowMs, supTotalIls, supLast, supCount) {
//     const now = nowMs ?? Date.now();
//     const tot = supTotalIls(sp, rate);
//     const last = supLast(sp);
//     const cnt = supCount(sp);
//     const days = last
//       ? Math.floor((now - new Date(last + 'T12:00:00').getTime()) / 86400000)
//       : 9999;
//     const R = days <= 30 ? 350 : days <= 90 ? 280 : days <= 180 ? 200 : days <= 365 ? 120 : 40;
//     const F = cnt >= 10 ? 300 : cnt >= 5 ? 230 : cnt >= 3 ? 160 : cnt >= 2 ? 100 : 50;
//     const M = tot >= 5000 ? 350 : tot >= 2000 ? 280 : tot >= 1000 ? 210 : tot >= 500 ? 140 : tot >= 100 ? 80 : 40;
//     return R + F + M;
//   }
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES — הנקודות שהמנוע נוטה לפספס):
//  • הערת-חתימה: ב-JS ‏rate=3.7 פרמטר-אמצעי עם ברירת-מחדל והשקעים אחריו נדרשים;
//    ‏Dart אוסר optional-positional לפני required ⇒ ‏rate/nowMs והשקעים הפכו named
//    (תקדים sup-score-bins/find-supporter-dup-groups). הסמנטיקה נשמרת: השמטה
//    (=undefined של JS) ⇒ 3.7; ‏rate:null מפורש ⇒ null זורם לשקע כמו ב-JS — כלל-2 מכובד.
//  • ‏`nowMs ?? Date.now()` — nullish של JS תופס undefined+null ⇒ ‏`??` של Dart על
//    null (השמטה או null-מפורש) = מיפוי נאמן; ‏DateTime.now().millisecondsSinceEpoch
//    ≡ ‏Date.now() (אפוק-UTC במילישניות).
//  • תאריך (כללים 3/4 — סמנטיקת-Date של JS, לא משמר-טווח; אומת מול V8):
//    ‏new Date('yyyy-mm-ddT12:00:00') = פרסר-ISO קשיח: חודש 01–12 ודבל-ספרה בלבד,
//    יום 01–31 (יום 00/32+/חד-ספרה ⇒ Invalid; חודש 00/13 ⇒ Invalid), אבל
//    **יום-גולש בתוך 01–31 מתגלגל לחודש-הבא** (2026-02-30 ⇒ 2 במרץ — אומת ב-V8) —
//    בדיוק התנהגות בנאי-DateTime של Dart. בלי אזור-זמן ⇒ זמן-מקומי בשתי השפות
//    (‏DateTime.parse בלי Z = מקומי). מחרוזת לא-תואמת ⇒ NaN ⇒ ‏days=NaN ⇒ כל
//    ההשוואות false ⇒ ‏R=40 — כמו ב-JS. (מחוץ לתחום-החוזה: שנים-מורחבות ‎+010000‎
//    וטריקי-הפרסר-הלגאסי של V8 אינם משוקפים — החוזה מחייב ISO ‏yyyy-mm-dd או ''.)
//  • ‏Math.floor ⇒ ‏_jsMathFloor (לא ‏.floor()! — floor של Dart זורק על NaN/±Inf;
//    ב-JS ‏floor(NaN)=NaN ⇒ נשמר, וכך ‏days=NaN מפיל ל-R=40). שלילי: ‏floor(-0.5)=-1
//    בשתי השפות (תאריך-עתידי ⇒ days שלילי ⇒ ‏≤30 ⇒ 350 — זהה).
//  • truthiness (כלל-7): ‏`last ? … : 9999` ⇒ ‏_truthy מפורש (null/''/0/false/NaN ⇒ 9999).
//  • השוואות-הספים (כלל-15 — קוארציה): ‏cnt>=10 / tot>=5000 עם אופרנד-ימני מספרי ⇒
//    ‏ToNumber על ערך-השקע ⇒ ‏_jsGe (מחרוזת ⇒ ‏ToNumber עם ‏_jsTrim לפי כלל-16,
//    ''⇒0, כשל-פרסור ⇒ NaN ⇒ false — כלל-10: tryParse, לא parse-זורק).
//  • שרשור ‏`last + 'T12:00:00'` — בתחום-החוזה last מחרוזת; לא-מחרוזת (מספר/bool)
//    ⇒ ‏ToString לעולם אינו תבנית-תאריך תקפה ⇒ NaN בשתי השפות (שקילות-פלט; ‏_jsStr
//    המלא של כלל-12 מיותר כאן — אין נתיב שבו פריסת-המספר משנה את התוצאה).
//  • החשבון ב-num/double (מספרי-JS הם double); ‏R+F+M שלמים ⇒ int, כמו number שלם ב-JS.
//  • אין locale/מיון/מודולו/toLowerCase/מוטציה — כללים 1/6/9/13/14 לא חלים.

/// RFM donor score 0–1000: R recency (days since last donation, from local
/// noon; no donation ⇒ 9999 days) + F frequency (donation count) + M monetary
/// (total ILS). Thresholds verbatim from the JS source `supScore`; the
/// neighbours `supTotalIls(sp, rate)`, `supLast(sp)`, `supCount(sp)` are
/// injected sockets (Law 1) and `nowMs` injects "now" (omitted ⇒ Date.now()).
int supScore(
  dynamic sp, {
  dynamic rate = 3.7,
  dynamic nowMs,
  required dynamic Function(dynamic sp, dynamic rate) supTotalIls,
  required dynamic Function(dynamic sp) supLast,
  required dynamic Function(dynamic sp) supCount,
}) {
  final num now = _jsToNum(nowMs ?? DateTime.now().millisecondsSinceEpoch);
  final dynamic tot = supTotalIls(sp, rate);
  final dynamic last = supLast(sp);
  final dynamic cnt = supCount(sp);
  final num days = _truthy(last)
      ? _jsMathFloor((now - _jsDateNoonMs(last)) / 86400000)
      : 9999;
  // NaN בכל השוואה ⇒ false (זהה ל-JS) ⇒ נופל לענף-האחרית.
  final int R = days <= 30
      ? 350
      : days <= 90
          ? 280
          : days <= 180
              ? 200
              : days <= 365
                  ? 120
                  : 40;
  final int F = _jsGe(cnt, 10)
      ? 300
      : _jsGe(cnt, 5)
          ? 230
          : _jsGe(cnt, 3)
              ? 160
              : _jsGe(cnt, 2)
                  ? 100
                  : 50;
  final int M = _jsGe(tot, 5000)
      ? 350
      : _jsGe(tot, 2000)
          ? 280
          : _jsGe(tot, 1000)
              ? 210
              : _jsGe(tot, 500)
                  ? 140
                  : _jsGe(tot, 100)
                      ? 80
                      : 40;
  return R + F + M;
}

/// JS `new Date(last + 'T12:00:00').getTime()` — אפוק-מילישניות של חצות-יום
/// מקומי; מחרוזת שאינה ISO ‏yyyy-mm-dd קשיח (או ערך לא-מחרוזת) ⇒ NaN, כמו
/// Invalid Date ב-JS. יום-גולש 01–31 מתגלגל לחודש-הבא (V8 ≡ בנאי-DateTime).
double _jsDateNoonMs(dynamic last) {
  if (last is! String) return double.nan; // ToString של לא-מחרוזת ⇒ לא-תבנית ⇒ Invalid
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(last);
  if (m == null) return double.nan;
  final y = int.parse(m.group(1)!);
  final mo = int.parse(m.group(2)!);
  final d = int.parse(m.group(3)!);
  if (mo < 1 || mo > 12 || d < 1 || d > 31) return double.nan; // כמו פרסר-ה-ISO של V8
  // זמן-מקומי (אין Z) בשתי השפות; יום-גולש מתגלגל בשתיהן.
  return DateTime(y, mo, d, 12).millisecondsSinceEpoch.toDouble();
}

/// JS-faithful Math.floor: NaN/±Infinity עוברים כמו-שהם (Dart .floor() זורק).
double _jsMathFloor(num x) {
  final v = x.toDouble();
  if (v.isNaN || v.isInfinite) return v;
  return v.floorToDouble();
}

/// JS `a >= n` כשהאופרנד-הימני מספרי ⇒ ToNumber(a) >= n; ‏NaN ⇒ false.
bool _jsGe(dynamic a, num n) => _jsToNum(a) >= n;

/// ES ToNumber מגודר-תחום (החוזה מחייב number מהשקעים): num כמו-שהוא ·
/// null ⇒ 0 · bool ⇒ 1/0 · מחרוזת ⇒ ‏_jsTrim (כלל-16) ואז פרסור (''⇒0,
/// ‏Infinity, כשל ⇒ NaN — כלל-10) · אחר ⇒ NaN.
num _jsToNum(dynamic v) {
  if (v is num) return v;
  if (v == null) return 0;
  if (v is bool) return v ? 1 : 0;
  if (v is String) {
    final s = _jsTrim(v);
    if (s.isEmpty) return 0;
    if (s == 'Infinity' || s == '+Infinity') return double.infinity;
    if (s == '-Infinity') return double.negativeInfinity;
    return num.tryParse(s) ?? double.nan;
  }
  return double.nan;
}

// קבוצת-הרווחים של ECMAScript (כלל-16): TAB/LF/VT/FF/CR/SP/NBSP/BOM/Zs/LS/PS —
// בלי U+0085 (NEL) ו-U+180E (ש-String.trim של Dart גוזם ו-JS לא).
const String _esWs = '\t\n\u000B\f\r \u00A0\uFEFF'
    '\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007'
    '\u2008\u2009\u200A\u202F\u205F\u3000\u2028\u2029';

/// trim בקבוצת-ES המדויקת — לא String.trim של Dart.
String _jsTrim(String s) {
  var a = 0, b = s.length;
  while (a < b && _esWs.contains(s[a])) a++;
  while (b > a && _esWs.contains(s[b - 1])) b--;
  return s.substring(a, b);
}

/// JS truthiness (כלל-7): undefined/null (⇒ null ב-Dart) · '' · 0/-0 · false ·
/// NaN — falsy; כל השאר (כולל אובייקטים/מערכים) — truthy.
bool _truthy(dynamic v) => !(v == null ||
    v == '' ||
    v == 0 ||
    v == false ||
    (v is double && v.isNaN));
