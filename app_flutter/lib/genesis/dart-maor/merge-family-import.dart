// ⚛️ אטום-Dart (דרגת-חוזה) · mergeFamilyImport — מיזוג-שדות מיובאים למשפחה
// מוצא: new/atoms/merge-family-import.mjs (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת):
//   export function mergeFamilyImport(f, obj) {
//     const out = { ...f };
//     for (const k of Object.keys(obj)) { const v = obj[k]; if (v) out[k] = v; }
//     return out;
//   }
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core).
//
// תפקיד: פורש את `f` (spread) לאובייקט-פלט, ואז דורס/מוסיף כל שדה של `obj` שערכו
//        truthy (falsy — null/false/0/''/NaN — נדלג עליו, כך `f` נשמר לאותו מפתח).
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//  • truthiness (כלל-7): `if (v)` של JS ≠ Dart. מומש שקע `_truthy` מפורש
//    (null/false/0/NaN/'' ⇒ false; שאר ⇒ true).
//  • `{ ...f }` ו-`Object.keys(obj)` ב-JS פועלים על **כל** ערך: מחרוזת נפרשת
//    לזוגות אינדקס→תו ("abc" ⇒ {"0":"a",...}); אובייקט/מפה ⇒ מפתחותיו; מספר/בוליאני/
//    null ⇒ אפס-מפתחות (spread על null אינו זורק). שוחזר ב-`_ownEntries`.
//  • סדר-מפתחות: JS מונה מפתחות דמויי-מספר בסדר-עולה; כאן ההוספה עולה ממילא,
//    ו-Dart LinkedHashMap שומר סדר-הוספה ⇒ זהה.

/// Verbatim behaviour of the JS source new/atoms/merge-family-import.mjs.
/// Spreads [f] into a fresh map, then overlays every truthy own-field of [obj].
Map<String, dynamic> mergeFamilyImport(dynamic f, dynamic obj) {
  final out = <String, dynamic>{};
  // out = { ...f }  — spread copies every own field, no truthiness filter.
  for (final e in _ownEntries(f)) {
    out[e.key] = e.value;
  }
  // for (k of Object.keys(obj)) { const v = obj[k]; if (v) out[k] = v; }
  for (final e in _ownEntries(obj)) {
    if (_truthy(e.value)) {
      out[e.key] = e.value;
    }
  }
  return out;
}

// JS own-enumerable entries of an arbitrary value, in enumeration order.
// String/List ⇒ index→element; Map ⇒ its (stringified) keys; anything else ⇒ none.
List<MapEntry<String, dynamic>> _ownEntries(dynamic v) {
  if (v is String) {
    final r = <MapEntry<String, dynamic>>[];
    for (var i = 0; i < v.length; i++) {
      r.add(MapEntry(i.toString(), v[i]));
    }
    return r;
  }
  if (v is Map) {
    return v.entries
        .map((e) => MapEntry(e.key.toString(), e.value as dynamic))
        .toList();
  }
  if (v is List) {
    final r = <MapEntry<String, dynamic>>[];
    for (var i = 0; i < v.length; i++) {
      r.add(MapEntry(i.toString(), v[i]));
    }
    return r;
  }
  // null/undefined/num/bool: no own enumerable keys.
  return const [];
}

// JS truthiness: falsy = null/undefined, false, 0, NaN, ''.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}
