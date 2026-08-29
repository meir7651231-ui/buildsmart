/// אטום-קבוע · module-labels — צילום-ערך: תוויות 9 המודולים. חוזה: module-labels.contract.md
/// חולץ מ-new/atoms/module-labels.mjs (TS→JS→Dart). טהור — אפס import (dart-core בלבד).
/// התנהגות זהה-לחלוטין למקור-ה-JS (חוק-4 — המקור קדוש).
///
/// תיקון-המרה (המנוע פספס): המנוע פלט `var MODULE_LABELS` (משתנה-מוטבילי);
/// המקור הוא `export const` — ערך-קבוע. ⇒ `const Map<String, String>` (אי-שינוי,
/// זהה-לסמנטיקת-const של המקור). ההתחייבות הבודקת (רתמת-הזהב) היא הצילום עצמו.

// ignore: constant_identifier_names
const Map<String, String> MODULE_LABELS = {
  'families': 'משפחות',
  'courses': 'חוגים',
  'calendar': 'לוח שנה',
  'diary': 'יומן חדרים',
  'supporters': 'תורמים',
  'reports': 'דוחות',
  'tzedaka': 'קופות צדקה',
  'shop': 'חנות',
  'shop7': 'חלוקה',
};
