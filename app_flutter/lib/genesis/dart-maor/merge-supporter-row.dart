// ⚛️ אטום-Dart (דרגת-חוזה) · mergeSupporterRow — החלת שורת-ייבוא על תומכת קיימת.
// מוצא: maor/src/components/supporters/lib.ts:637-651 · המקור: new/atoms/merge-supporter-row.mjs.
//        חוזה: new/atoms/merge-supporter-row.contract.md. חוק-4 — התנהגות זהה-ביט
//        למקור-ה-JS (המקור קדוש). המנוע-האוטומטי החזיר טיוטה-ריקה ⇒ הפורט כולו ידני.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core).
//
// תפקיד: לא-ריק (אחרי trim) דורס, ריק ⇒ הקיים נשמר; הטלפון עובר עיצוב דרך השקע
//        fixPhone; היסטוריה (אם יש בשורה) ממוזגת אידמפוטנטית דרך השקע mergeHist.
//        כל שאר שדות-הכרטיס (donations/count/ils/…) עוברים כמו-שהם דרך ‎...sp‎.
// קלט:  sp  — כרטיס-תומכת קיים (Map<String,Object?>).
//        row — שורת-ייבוא (name/phone/email/idNum/address/cat/forWho מחרוזות חובה;
//              hist? אופציונלי — List או חסר).
//        mergeHist(existing, incoming) — שקע מיזוג-היסטוריה (האטום merge-hist).
//        fixPhone(p) — שקע עיצוב-טלפון-ישראלי (String; האטום fix-phone).
// פלט:  כרטיס מעודכן חדש (Map<String,Object?> טרי).
//
// הערות-המרה (מקור→Dart — נקודות שחייבות דיוק-JS, אחרת סטייה; DART-PORTING-RULES):
//  • כלל-7 truthiness: `row.hist?.length` — ב-JS: hist חסר/null ⇒ undefined ⇒ falsy;
//    מערך-ריק ⇒ 0 ⇒ falsy; מערך-מלא ⇒ truthy. אין ל-Map/מספר תכונת-length ⇒ falsy.
//    ⇒ `_truthyLen` (List/String לא-ריקים בלבד). `row.name.trim() || sp.name` ו-
//    `row.phone ? … : sp.phone` = מחרוזת-ריקה בלבד falsy ⇒ בדיקת isEmpty מפורשת.
//  • כלל-2 null≠undefined: מפתח-חסר ב-Map של Dart מחזיר null — שקול ל-`?.`/`??` של JS
//    כאן (‏`sp.hist ?? []` ⇒ `sp['hist'] ?? const []`; ‏row בלי hist ⇒ null ⇒ falsy).
//  • מוטביליות: הפלט מפה טרייה (`{...sp}` ⇒ עותק) שנדרסת דרך `[]=`, כמו ספרד-JS.
//    שדות-הדריסה מגיעים אחרי `...sp` ⇒ גוברים על ערכי-sp (כולל hist בענף-התנאי).
//  • אין locale/פורמט/getMonth/תאריך מעורבים — כל העיצוב מואצל לשקע fixPhone.

/// `row.name.trim() || sp.name` של JS: מחרוזת-גזומה לא-ריקה גוברת, ריקה ⇒ [fallback].
Object? _orStr(String trimmed, Object? fallback) =>
    trimmed.isEmpty ? fallback : trimmed;

/// `v?.length` truthy של JS: רק List/String לא-ריקים אמת; כל השאר (null/Map/מספר) שקר.
bool _truthyLen(Object? v) {
  if (v is List) return v.isNotEmpty;
  if (v is String) return v.isNotEmpty;
  return false;
}

/// החלת שורת-ייבוא [row] על כרטיס-תומכת [sp]. התנהגות זהה-ביט למקור-ה-JS
/// new/atoms/merge-supporter-row.mjs. השכנים מוזרקים כשקעים (חוק-1):
/// [mergeHist] — מיזוג-היסטוריה אידמפוטנטי · [fixPhone] — עיצוב-טלפון.
Map<String, Object?> mergeSupporterRow(
  Map<String, Object?> sp,
  Map<String, Object?> row,
  Object? Function(Object? existing, Object? incoming) mergeHist,
  String Function(String p) fixPhone,
) {
  final out = <String, Object?>{...sp};

  // ...(row.hist?.length ? { hist: mergeHist(sp.hist ?? [], row.hist) } : {})
  if (_truthyLen(row['hist'])) {
    out['hist'] = mergeHist(sp['hist'] ?? const <Object?>[], row['hist']);
  }

  final rowPhone = row['phone'] as String;
  out['name'] = _orStr((row['name'] as String).trim(), sp['name']);
  out['phone'] =
      rowPhone.isNotEmpty ? fixPhone(rowPhone.trim()) : sp['phone'];
  out['email'] = _orStr((row['email'] as String).trim(), sp['email']);
  out['idNum'] = _orStr((row['idNum'] as String).trim(), sp['idNum']);
  out['address'] = _orStr((row['address'] as String).trim(), sp['address']);
  out['cat'] = _orStr((row['cat'] as String).trim(), sp['cat']);
  out['forWho'] = _orStr((row['forWho'] as String).trim(), sp['forWho']);

  return out;
}
