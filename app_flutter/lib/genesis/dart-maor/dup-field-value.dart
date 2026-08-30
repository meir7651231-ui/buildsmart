/// חוט · dup-field-value — ערך-שדה נבחר במיזוג-כפולים (edit ⇒ pick ⇒ ראשונה-עם-ערך).
/// המרה נאמנה מ-new/atoms/dup-field-value.mjs (חוק-4: המקור קדוש).
/// המנוע פספס: def הוא רשומה (key+get) ⇒ גישת-מפה לא property-access;
/// ו-findIndex של JS בודק truthiness של הערך ⇒ Dart indexWhere דורש bool (כלל-7).
dynamic dupFieldValue(List fams, Map def, Map pick, Map edit) {
  final key = def['key'];
  final get = def['get'] as dynamic Function(dynamic);
  final edited = edit[key];
  // JS: `edited != null` (רופף) תופס null+undefined; ב-Dart מפה-חסרה=null ⇒ זהה.
  if (edited != null) return edited;
  final picked = pick[key];
  // JS `??` נופל רק על null/undefined (0 עובר) ⇒ Dart `??` זהה.
  final int idx = ((picked ?? fams.indexWhere((f) => _truthy(get(f)))) as int);
  return get(fams[idx >= 0 ? idx : 0]);
}

/// שקע-truthiness שמחקה את JS: '' / 0 / null / false / NaN = falsy, השאר truthy.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}
