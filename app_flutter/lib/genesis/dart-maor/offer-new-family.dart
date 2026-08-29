/// חוט · offer-new-family — האם להציע "＋ משפחה חדשה" לשאילתת-שיבוץ.
/// חוזה: offer-new-family.contract.md · שקע: normName
/// חולץ מ-maor/src/components/courses/lib.ts:531-534 · TS→JS→Dart. טהור — אפס
/// import (dart-core בלבד). התנהגות זהה-לחלוטין למקור-ה-JS (חוק-4).
///
/// השכן normNameLocal הוזרק כשקע normName (חוק-1 — אפס import פנימי).
/// המקור:
///   const t = q.trim();
///   return t.length >= 2 && !families.some((f) => normName(f.name) === normName(t));
///
/// הערות-פאריטי:
///  • `q.trim()` — Dart trim() מסיר רווחים כמו JS trim() (תווי-הרווח הרלוונטיים חופפים).
///  • `t.length` — אורך code-units (UTF-16), זהה ל-JS; אותיות עבריות = יחידה אחת.
///  • `families.some` ⇒ `families.any`; רשימה-ריקה ⇒ false, זהה ל-JS.
bool offerNewFamily(
  List<Map<String, dynamic>> families,
  String q,
  String Function(dynamic) normName,
) {
  final t = q.trim();
  return t.length >= 2 &&
      !families.any((f) => normName(f['name']) == normName(t));
}
