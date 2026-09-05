// 🔌 חוט-Dart (דרגת-חוזה) · orgSlugFromUrl — ‏slug מ-‎?org=<slug>‎
// מוצא: maor/src/lib/config.ts:812-819 → new/atoms/org-slug-from-url.mjs (מקור-האמת; חוק-4).
//        המקור: `const slug = new URLSearchParams(search).get('org');
//                 return slug && /^[a-z0-9-]{2,40}$/.test(slug) ? slug : null;`
// טוהר: פונקציית top-level עצמאית, אפס import של אטום אחר (רק dart:convert הסטנדרטי).
//
// תפקיד: חילוץ-slug בטוח ממחרוזת-החיפוש — רק ‏^[a-z0-9-]{2,40}$; כל השאר ⇒ null.
//        גבול-הדפדפן (window.location.search) נשאר בקופסה — החוט מקבל את המחרוזת כקלט.
// קלט:  search — מחרוזת-חיפוש (למשל '?org=demo'); dynamic — ‏null/זבל ⇒ null, אפס-זריקות.
// פלט:  ה-slug (String) או null.
//
// הערות-המרה (מקור→Dart):
// • ל-Dart אין URLSearchParams; ‏Uri.splitQueryString סוטה פעמיים מ-WHATWG —
//   זורק על percent-escape שבור (JS משאיר-כמות-שהוא: '?x=%zz&org=demo' ⇒ 'demo')
//   ומחזיר Map שבו האחרון-מנצח (‏URLSearchParams.get ⇒ הראשון: '?org=demo&org=xx' ⇒ 'demo').
//   ⇒ מימוש-מקומי _firstQueryParam נאמן-ספק: '?' בודד נחתך, פיצול '&' (רצועות-ריקות
//   מדולגות), '=' ראשון מפריד, מפתח-וערך עוברים form-decode סלחני, ההתאמה הראשונה מנצחת.
// • ‏form-decode כמו-JS: הקלט מקודד UTF-8 לבייטים; '+'⇒רווח; ‏%XX חוקי ⇒ בייט, ‏% שבור
//   נשאר-מילולית; פענוח UTF-8 עם U+FFFD (allowMalformed) — כמו WHATWG. תו-החלפה לעולם
//   לא עובר את הרג'קס, כך שהתוצאה הנצפית זהה-ביט.
// • חוק-7 (truthiness): ‏`slug && re.test(slug)` — ‏null או '' ⇒ falsy ⇒ null; מפורש כאן.
// • הרג'קס verbatim (ערבות-3 בחוזה); סמנטיקת ^/$ של RegExp ב-Dart היא ECMAScript — זהה
//   ('?org=demo\n' ⇒ null בשניהם).
// • ‏try/catch נשמר כמו-במקור (אפס-זריקות על קלט-זבל, ערבות-2); קלט לא-מחרוזתי ⇒ toString
//   (‏JS ‏URLSearchParams(123) ⇒ '123' ⇒ אין org ⇒ null — זהה).

import 'dart:convert' show utf8;

bool _isHex(int b) =>
    (b >= 0x30 && b <= 0x39) || // 0-9
    (b >= 0x41 && b <= 0x46) || // A-F
    (b >= 0x61 && b <= 0x66);   // a-f

int _hexVal(int b) => b <= 0x39 ? b - 0x30 : (b & 0x20 != 0 ? b - 0x57 : b - 0x37);

/// ‏application/x-www-form-urlencoded decode סלחני כמו-JS: ‏'+'⇒רווח, ‏%XX חוקי ⇒ בייט,
/// ‏% שבור נשאר מילולית, פענוח UTF-8 עם תווי-החלפה (לא זורק).
String _formDecode(String s) {
  final input = utf8.encode(s);
  final out = <int>[];
  for (var i = 0; i < input.length; i++) {
    final b = input[i];
    if (b == 0x2B) {
      out.add(0x20); // '+' => space
    } else if (b == 0x25 &&
        i + 2 < input.length &&
        _isHex(input[i + 1]) &&
        _isHex(input[i + 2])) {
      out.add(_hexVal(input[i + 1]) * 16 + _hexVal(input[i + 2]));
      i += 2;
    } else {
      out.add(b);
    }
  }
  return utf8.decode(out, allowMalformed: true);
}

/// שווה-ערך ל-`new URLSearchParams(search).get(key)` של WHATWG:
/// '?' מוביל בודד נחתך; פיצול '&' (ריקים מדולגים); '=' ראשון מפריד; מפתח/ערך
/// עוברים _formDecode; מוחזר ערך ההתאמה **הראשונה**, או null באין-התאמה.
String? _firstQueryParam(String search, String key) {
  var s = search;
  if (s.startsWith('?')) s = s.substring(1);
  for (final piece in s.split('&')) {
    if (piece.isEmpty) continue;
    final eq = piece.indexOf('=');
    final rawKey = eq < 0 ? piece : piece.substring(0, eq);
    final rawVal = eq < 0 ? '' : piece.substring(eq + 1);
    if (_formDecode(rawKey) == key) return _formDecode(rawVal);
  }
  return null;
}

/// ‏slug מ-‎?org=<slug>‎ — פריסה אחת משרתת אינסוף לקוחות. התנהגות verbatim של
/// new/atoms/org-slug-from-url.mjs: רק ‏^[a-z0-9-]{2,40}$ מוחזר; כל השאר ⇒ null.
dynamic orgSlugFromUrl(dynamic search) {
  try {
    final slug = _firstQueryParam(search == null ? '' : search.toString(), 'org');
    if (slug == null || slug.isEmpty) return null; // truthiness של JS (חוק-7)
    return RegExp(r'^[a-z0-9-]{2,40}$').hasMatch(slug) ? slug : null;
  } catch (_) {
    return null;
  }
}
