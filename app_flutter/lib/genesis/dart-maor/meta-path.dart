// חוט · meta-path — נתיב מסמך meta/envelope של הצפנת-הענן. חוזה: meta-path.contract.md
// המרה מ-JS (new/atoms/meta-path.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// מקור: cloudRoot ? 'meta/org' : 'orgs/' + slug + '/meta/org'
// כלל-המרה 7 (truthiness): המנוע פספס — הגולדן מזין מחרוזות ל-cloudRoot,
// ו-"" ב-JS הוא falsy. שקע-truthy מפורש מחקה את סמנטיקת-ה-JS. אפס-import (dart-core בלבד).
String metaPath(dynamic slug, dynamic cloudRoot) {
  return _truthy(cloudRoot) ? 'meta/org' : 'orgs/' + _jsStr(slug) + '/meta/org';
}

// truthiness של JS: false/0/NaN/""/null/undefined ⇒ falsy; כל השאר ⇒ truthy.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

// שרשור-מחרוזת בסגנון-JS: String() coercion (null⇒'null'; אחרת toString).
String _jsStr(dynamic v) {
  if (v == null) return 'null';
  if (v is String) return v;
  return v.toString();
}
