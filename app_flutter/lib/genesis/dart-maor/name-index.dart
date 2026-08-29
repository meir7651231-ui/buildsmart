// ⚛️ אטום-Dart (דרגת-חוזה) · nameIndex — אינדקס בני-משפחה לפי מזהה (Map id⇒member) לדוחות.
// מוצא: maor/src/components/reports/lib.ts:70-75 · המקור: new/atoms/name-index.mjs —
//        `for (const m of allMembers(db)) map.set(m.id, m); return map;`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: בונה Map מ-id לרשומת-החבר לחיפוש O(1) בדוחות. מזהה כפול ⇒ האחרון-
//        ברשימה מנצח (סמנטיקת Map.set של JS ≡ הצבת-אינדקס ב-Dart).
// שקע (חוק-1): allMembers(db) ⇒ מערך כל בני-המשפחה (במקור השכן useApp.allMembers
//        הוזרק כפרמטר — אפס import פנימי).
// קלט: db · allMembers. פלט: Map<key, member>.
//
// 🩹 תיקון-הסגר (כלל-2 · null↔undefined במפתח-Map): במקור-ה-JS `m.id` הוא
// `undefined` כשהשדה חסר ו-`null` כשהוא מוצב-מפורש; ‏JS Map מבחין בין שני
// המפתחות ⇒ שתי רשומות. פורט-נאיבי עם `m['id']` ממפה את שניהם ל-null-של-Dart
// (מפתח-חסר ≡ ערך-null) ⇒ רשומה אחת אובדת מהאינדקס. התיקון: מפתח החבר נגזר
// דרך `_keyOf` — שדה-id חסר ⇒ sentinel `_undefined` (מובחן מ-null-מפורש),
// בדיוק כמו הבחנת undefined↔null של JS.

/// Sentinel המייצג את `undefined` של JS (שדה-id חסר), מובחן מ-null-מפורש —
/// מונע התמוטטות שני מפתחות-נבדלים למפתח-Dart אחד.
class _Undefined {
  const _Undefined();
  @override
  String toString() => 'undefined';
}

const _undefined = _Undefined();

/// גוזר את מפתח-האינדקס מרשומת-חבר בנאמנות ל-`m.id` של JS:
///  • Map בלי המפתח 'id'  ⇒ `_undefined` (undefined ב-JS).
///  • Map עם 'id':null    ⇒ null (null ב-JS).
///  • אחרת                ⇒ הערך עצמו.
/// אובייקט לא-Map: מוחזר `_undefined` רק אם אין דרך לקרוא 'id' (שמרנות).
dynamic _keyOf(dynamic m) {
  if (m is Map) {
    return m.containsKey('id') ? m['id'] : _undefined;
  }
  // רשומה שאינה Map — ניגשים לשדה כרגיל; חסר ⇒ null (אין containsKey).
  try {
    final dynamic id = (m as dynamic).id;
    return id;
  } catch (_) {
    return _undefined;
  }
}

/// Builds an id⇒member index over all family members, for O(1) lookup in
/// reports. Duplicate id: the last one in the list wins (JS Map.set semantics).
/// A member with an explicit `id:null` and a member missing `id` (undefined)
/// are kept as two distinct entries — faithful to JS Map null↔undefined keys.
/// The sink `allMembers` is called exactly once with the injected `db`.
/// Verbatim behaviour of the JS source `nameIndex`.
dynamic nameIndex(dynamic db, dynamic allMembers) {
  final map = <dynamic, dynamic>{};
  for (final m in allMembers(db)) {
    map[_keyOf(m)] = m;
  }
  return map;
}
