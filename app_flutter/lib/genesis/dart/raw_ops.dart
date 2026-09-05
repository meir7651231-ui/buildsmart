// ⚛️ אטום-Dart (דרגת-חוזה) · rawOps
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:303-313 (‏_rawOps; חוק-4 — התנהגות זהה, לא-משופרת).
// תפקיד: נירמול תוצאת-JSON-מפוענחת לרשימת-פעולות אחידה: או רשימה-ישירה, או
//        מפה עם מפתח `ops`, או אובייקט-פעולה-בודד (מפתח `op`) — אחרת רשימה-ריקה.
// טוהר: פונקציית top-level עצמאית, אפס שקע, אפס import (dart:core בלבד — List/Map).
//        במקור פרטית (`_rawOps`) ⇒ פורסמה (כלל-הגלגול).
//
// קלט:  decoded — Object? (בד"כ פלט של jsonDecode: List / Map / null / פרימיטיב).
// פלט:  List<Object?> — הפעולות שחולצו; `const <Object?>[]` כשאין (edit_intent.dart:312).

/// Normalise a decoded-JSON value to a flat ops list. Verbatim behaviour of
/// edit_intent.dart:303-313 (`_rawOps`): a List passes through; a Map yields its
/// `ops` list, or `[map]` when it is itself a lone `op` object; else `const []`.
List<Object?> rawOps(Object? decoded) {
  if (decoded is List) return decoded;
  if (decoded is Map) {
    final ops = decoded['ops'];
    if (ops is List) return ops;
    if (decoded['op'] != null) return <Object?>[decoded]; // a lone op object.
  }
  return const <Object?>[];
}
