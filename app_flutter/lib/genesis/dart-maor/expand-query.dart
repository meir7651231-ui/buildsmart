// ⚛️ אטום-Dart (דרגת-חוזה) · expandQuery — הרחבת-שאילתה דרך מילון-התעתיקים.
// מוצא: maor/src/lib/search.ts:129-138 כלשונו; המקור: new/atoms/expand-query.mjs —
//   const nq = normSearch(q); const out = [q]; if (!nq) return out;
//   for (const [heb, aliases] of Object.entries(XLAT)) {
//     if (normSearch(heb) === nq) out.push(...aliases);
//     else if (aliases.some((a) => normSearch(a) === nq)) out.push(heb);
//   }
//   return [...new Set(out)];
// חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). normSearch ו-XLAT שקעים.
//
// תפקיד: מפתח-עברי ⇒ +כינויים; כינוי ⇒ +המפתח-העברי; תמיד כולל את השאילתה עצמה, בלי כפולים.
// קלט:  q — השאילתה (String) · normSearch — שקע (String)=>String · XLAT — Map<String,List<String>>.
// פלט:  List<String> — q ראשונה, ואז ההרחבות, מדודפת בסדר-הכנסה.
//
// הערות-המרה (DART-PORTING-RULES):
//  · truthiness (כלל 7): JS `!nq` על מחרוזת = ריק; ב-Dart `nq.isEmpty` מפורש — normSearch
//    מחזיר תמיד String (השקע `String(s||'')`), אז אין null.
//  · Object.entries שומר סדר-הכנסה; `Map.entries` של Dart על Map-literal (LinkedHashMap) זהה.
//  · new Set(out) של JS שומר סדר-הכנסה; `LinkedHashSet` (ברירת-מחדל של `{...}` ב-Dart) זהה —
//    לכן `out.toSet().toList()` שומר את הסדר ומדדף כמו המקור.
//  · spread `out.push(...aliases)` ⇒ `out.addAll(aliases)`; מוטביליות: `out` מקומי בלבד.

/// Expands a search query through the transliteration dictionary. Verbatim behaviour
/// of the JS source new/atoms/expand-query.mjs.
List<String> expandQuery(
  String q,
  String Function(String) normSearch,
  Map<String, List<String>> XLAT,
) {
  final nq = normSearch(q);
  final out = <String>[q];
  if (nq.isEmpty) return out;
  for (final entry in XLAT.entries) {
    final heb = entry.key;
    final aliases = entry.value;
    if (normSearch(heb) == nq) {
      out.addAll(aliases);
    } else if (aliases.any((a) => normSearch(a) == nq)) {
      out.add(heb);
    }
  }
  return out.toSet().toList();
}
