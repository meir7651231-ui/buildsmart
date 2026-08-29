/// אטום-קבוע · enroll-new-family — ערך-מערכת קבוע. חוזה: enroll-new-family.contract.md
/// חולץ מ-maor/src/components/courses/lib.ts:523-530 · TS→JS→Dart. טהור — אפס import
/// (dart-core בלבד). התנהגות זהה-לחלוטין למקור-ה-JS.
///
/// ההתחייבות הבודקת (רתמת-הזהב) היא הערך הקבוע ENROLL_NEW_FAMILY.
/// שני השכנים המוטמעים (normSearch/normNameLocal) פורטו verbatim מהמקור לשימור-פאריטי.

// ignore: constant_identifier_names
const String ENROLL_NEW_FAMILY = '__new';

/// truthiness של JS: `t || ''` — null/undefined/''/false/0/NaN ⇒ ''.
String _jsStr(dynamic t) {
  if (t == null || t == false || t == '' || t == 0) return '';
  if (t is num && t.isNaN) return '';
  return t.toString();
}

/// נרמול-חיפוש מוטמע (מקור: maor/src/lib/validate.ts:51-59) — regex/string, אפס-IO.
/// זהה-למקור: lower → הסרת-ניקוד → סופיות→רגילות → הסרת-פיסוק → trim.
String normSearch(dynamic t) {
  const Map<String, String> finals = {
    'ך': 'כ',
    'ם': 'מ',
    'ן': 'נ',
    'ף': 'פ',
    'ץ': 'צ',
  };
  return _jsStr(t)
      .toLowerCase()
      // /[֑-ׇ]/ — ניקוד/טעמים U+0591..U+05C7
      .replaceAll(RegExp('[֑-ׇ]'), '')
      // /[ךםןףץ]/ — אותיות-סופיות ⇒ רגילות
      .replaceAllMapped(RegExp('[ךםןףץ]'), (m) => finals[m[0]]!)
      // /['"׳״\-–._]/ — גרש/גרשיים/מקף/מקף-ארוך/נקודה/קו-תחתון
      .replaceAll(RegExp("['\"׳״\\-–._]"), '')
      .trim();
}

/// נרמול שם להשוואה — כמו normName במקור (normSearch + הסרת רווחים).
String normNameLocal(dynamic s) {
  return normSearch(s).replaceAll(RegExp(r'\s'), '');
}
