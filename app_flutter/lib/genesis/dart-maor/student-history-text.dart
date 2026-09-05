// ⚛️ אטום-Dart (דרגת-חוזה) · studentHistoryText — היסטוריית-תלמיד/ה כטקסט קריא (שורה להשתתפות).
// מוצא: maor/src/components/courses/reenroll-lib.ts:306-318 · המקור: new/atoms/student-history-text.mjs
// חוזה: new/atoms/student-history-text.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: שורה פר-רשומת-היסטוריה — `[<yearLabel>] <courseName> · <group> — נוכחות <presents>,
//        חיסורים <absences> · <statusLabel>`; yearLabel כוזב ⇒ בלי הסוגריים, group כוזב ⇒ בלי
//        ה-' · '. השורות מחוברות ב-'\n'; מערך ריק ⇒ מחרוזת ריקה.
// קלט: entries — List של רשומות {yearLabel, courseName, group, summary:{presents, absences, statusLabel}}.
// פלט: String רב-שורתית.
//
// הערות-המרה (מקור→Dart):
//  • `h.yearLabel ? … : …` / `h.group ? … : …` — truthiness של JS (חוק-7): '' / null / 0 / -0 /
//    NaN / false / מפתח-חסר = כוזב ⇒ `_jsTruthy`, לא בדיקת-null של Dart.
//  • גישת-שדה על אובייקט ⇒ גישת-Map; מפתח-חסר ב-JS = undefined ⇒ באינטרפולציה 'undefined',
//    null-מפורש ⇒ 'null' (חוק-2: containsKey מבחין, לא `== null`) ⇒ `_prop` + `_jsStr`.
//  • אינטרפולציית-מספר = String(num) של JS (חוק-12): int ⇒ עשרוני; double שלם <1e21 ⇒ עשרוני-מלא
//    בלי '.0' (פריסת-Dart היא כבר shortest-round-trip — רק גזירת הסיומת); ‏-0 ⇒ '0'; ‏≥1e21 ⇒
//    כתיב-מעריכי (toString של Dart זהה ל-JS: '1e+21'); NaN/Infinity כלשונם ⇒ `_jsNumStr`.
//  • `.map(...).join('\n')` ⇒ map-של-Iterable + join — סדר-הקלט נשמר, ריק ⇒ ''.
//  • אין locale / תאריכים / מיון / מודולו / trim — אין צורך בשקעים (חוק-11 לא חל).

/// היסטוריית-תלמיד/ה כטקסט קריא — שורה להשתתפות, לתדפיס/העתקה.
/// התנהגות זהה-ביט למקור-ה-JS `studentHistoryText`.
String studentHistoryText(List<dynamic> entries, {required String Function(String) term}) {
  return entries.map((hDyn) {
    final h = hDyn as Map;
    final yearLabel = _prop(h, 'yearLabel');
    final group = _prop(h, 'group');
    final yr = _jsTruthy(yearLabel) ? '[${_jsStr(yearLabel)}] ' : '';
    final grp = _jsTruthy(group) ? ' · ${_jsStr(group)}' : '';
    final summary = h['summary'] as Map;
    return '$yr${_jsStr(_prop(h, 'courseName'))}$grp'
        '${term('nvkchvt')}${_jsStr(_prop(summary, 'presents'))},'
        '${term('chysvrym')}${_jsStr(_prop(summary, 'absences'))}'
        ' · ${_jsStr(_prop(summary, 'statusLabel'))}';
  }).join('\n');
}

/// זקיף-undefined פנימי: מבחין מפתח-חסר (undefined של JS) מ-null מפורש (חוק-2).
const Object _undefined = #_undefined;

/// גישת-שדה נאמנת-JS: מפתח-חסר ⇒ זקיף-undefined, לא null (חוק-2: containsKey).
Object? _prop(Map h, String key) =>
    h.containsKey(key) ? h[key] : _undefined;

/// מקביל-ביט ל-truthiness של JS: undefined/null/''/0/-0/false/NaN = כוזב, השאר = אמת (חוק-7).
bool _jsTruthy(Object? v) {
  if (identical(v, _undefined) || v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

/// מקביל-ביט ל-String(v) של JS באינטרפולציה: undefined⇒'undefined' · null⇒'null' ·
/// מחרוזת⇒עצמה · מספר⇒`_jsNumStr` (חוק-12) · bool⇒'true'/'false' · אחר⇒toString.
String _jsStr(Object? v) {
  if (identical(v, _undefined)) return 'undefined';
  if (v == null) return 'null';
  if (v is String) return v;
  if (v is num) return _jsNumStr(v);
  return v.toString();
}

/// String(num) של JS (חוק-12): int ⇒ עשרוני · NaN/±Infinity כלשונם · -0⇒'0' ·
/// double שלם בטווח-הסופי <1e21 ⇒ הפריסה-העשרונית של Dart בלי הסיומת '.0'
/// (Dart מדפיס עשרוני-מלא shortest-round-trip עד 1e21, מעריכי '1e+21' מעליו — כמו JS) ·
/// שאר ה-double ⇒ toString (shortest-round-trip זהה).
String _jsNumStr(num v) {
  if (v is int) return v.toString();
  final d = v as double;
  if (d.isNaN) return 'NaN';
  if (d.isInfinite) return d > 0 ? 'Infinity' : '-Infinity';
  if (d == 0) return '0'; // גם -0.0 — JS: String(-0)==='0'
  final s = d.toString();
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}
