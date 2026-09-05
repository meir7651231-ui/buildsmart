// ⚛️ אטום-Dart (דרגת-חוזה) · expandScope
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:425-455 (‏expandScope; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import. הקלט `RegistryView registry` פורק
//        לשקעי-ריאדר (חוק-3/6): `elementIds()` ו-`actionIdsFor(id)`. שתי קריאות-שכן
//        (‏`matchElementId(registry, raw)` · `scopeElementIds(token, registry)`) הפכו
//        לשקעי-פונקציה — ה-registry נלכד ע"י הקורא בקופסה (חוק-1: חוט לא מייבא חוט).
//        חמשת קבועי-הטוקן (`kScopeActionable`/`kScopeEveryPrefix`/`kScopeSinglePrefix`/
//        `kScopeAll`/`kScopeScreenPrefix`) הופכו לשקעי-מחרוזת — ערכיהם אינם נגישים
//        במקור-הנוכחי (studio/ חסר) ⇒ שקע, לא ניחוש (חוק-9).
//
// קלט:  token          — טוקן-הטווח.
//       elementIds     — שקע: () ⇒ כל מזהי-האלמנט (במקור registry.elementIds).
//       actionIdsFor   — שקע: id ⇒ מזהי-פעולה (במקור registry.actionIdsFor).
//       matchElementId — שקע: raw ⇒ id-אמיתי או null (במקור matchElementId).
//       scopeElementIds— שקע: token ⇒ אוסף-מזהים (במקור scopeElementIds).
//       scope*         — 5 שקעי-טוקן (במקור const-ים).
// פלט:  List<String> — מזהים אמיתיים, deduped וממויין; טוקן לא-מוכר ⇒ ריק (fail-closed).

/// Expand a scope token to its REAL, deduped, sorted element ids.
/// Verbatim behaviour of edit_intent.dart:425-455 with the registry reads and
/// scope-token consts injected.
List<String> expandScope(
  String token, {
  required Iterable<String> Function() elementIds,
  required Iterable<String> Function(String id) actionIdsFor,
  required String? Function(String raw) matchElementId,
  required Iterable<String> Function(String token) scopeElementIds,
  required String scopeActionable,
  required String scopeEveryPrefix,
  required String scopeSinglePrefix,
  required String scopeAll,
  required String scopeScreenPrefix,
}) {
  final ids = elementIds();
  final Iterable<String> matched;
  if (token == scopeActionable) {
    // "all buttons" proxy — an element CARRYING actions is the button-like one.
    matched = ids.where((id) => actionIdsFor(id).isNotEmpty);
  } else if (token.startsWith(scopeEveryPrefix)) {
    // `every:<ns>` — the id-namespace subtree IS the area grouping.
    final ns = token.substring(scopeEveryPrefix.length).trim();
    matched = ns.isEmpty
        ? const <String>[]
        : ids.where((id) => id == ns || id.startsWith('$ns.'));
  } else if (token.startsWith(scopeSinglePrefix)) {
    // Re-ground the single id through the frozen matcher — drop to empty if missing.
    final one = matchElementId(token.substring(scopeSinglePrefix.length));
    matched = one == null ? const <String>[] : <String>[one];
  } else if (token == scopeAll || token.startsWith(scopeScreenPrefix)) {
    // The model-emittable tokens — reuse the proven `scopeElementIds`.
    matched = scopeElementIds(token);
  } else {
    return const <String>[]; // unknown token → fail-closed (empty).
  }
  // deduped, SORTED, and — via the `ids.contains` filter — every id is REAL.
  final out = matched.where(ids.contains).toSet().toList()..sort();
  return out;
}
