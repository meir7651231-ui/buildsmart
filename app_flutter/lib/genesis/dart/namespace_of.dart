// ⚛️ אטום-Dart (דרגת-חוזה) · namespaceOf
// תפקיד: מיצוי מרחב-השם ממזהה — הקטע שלפני הנקודה הראשונה (או המזהה כולו).
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:119-124
//        (‏_namespaceOf, פרטי-במקור). מקודם ל-public (כלל-הגלגול). חוק-4.
// אחים-שסוקטו/הוטבעו: אין. האטום קורא רק String (trim/indexOf/substring).
//        (האח בטיוטה — קבוצת-סקופ Stage-A מעל elementIds — שכן, לא האטום.)
// טוהר: אפס import (dart:core בלבד).
//
// קלט:  id — מזהה-אלמנט (String; במקור מ-elementIds()). נחתך (trim) תחילה.
// פלט:  String — הקטע שלפני '.' הראשונה; אם אין '.' ⇒ המזהה-החתוך כולו.

/// Namespace of an element [id]: the text before the first `.`, or the whole
/// (trimmed) id when there is none. Verbatim behaviour of edit_prompt.dart:119-124.
String namespaceOf(String id) {
  final s = id.trim();
  final dot = s.indexOf('.');
  return dot < 0 ? s : s.substring(0, dot);
}
