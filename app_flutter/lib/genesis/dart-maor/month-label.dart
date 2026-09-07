// חוט · month-label — תווית חודש/שנה ממפתח "YYYY-MM...". חוזה: month-label.contract.md
// המרה מ-JS (new/atoms/month-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). מוצא: maor/src/components/reports/lib.ts:64-69.
//
// סמנטיקת-JS משומרת:
//   const [y, m] = key.split('-')  ⇒ איבר-חסר = undefined (לא זריקה);
//   `${undefined}` ⇒ המחרוזת "undefined" (Dart היה מדפיס "null" ⇒ עוזר _jsStr).


/// ‏truthiness של JS (חוק 7): '' / 0 / -0 / NaN / null / false כוזבים. (הוזרק ע"י מתקן-ההסגר)
bool _rqTruthy(dynamic v) =>
    !(v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN)));

dynamic monthLabel(dynamic key) {
  final parts = key.split('-');
  final dynamic y = _rqTruthy(parts.isNotEmpty) ? parts[0] : null; // JS split תמיד ≥1 איבר; שימור-פירוק ליתר-ביטחון
  final dynamic m = _rqTruthy(parts.length > 1) ? parts[1] : null; // אין '-' ⇒ undefined בפירוק-JS
  return '${_jsStr(m)}/${_jsStr(y)}';
}

/// עוזר מקומי: אינטרפולציית-תבנית של JS — undefined ⇒ "undefined".
String _jsStr(dynamic v) => v == null ? 'undefined' : '$v';
