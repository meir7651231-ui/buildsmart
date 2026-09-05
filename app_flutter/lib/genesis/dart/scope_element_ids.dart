// ⚛️ אטום-Dart (דרגת-חוזה) · scopeElementIds
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:168-188 (חוק-4).
//        קובץ-המקור אינו קיים עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: אטום-סינון טהור. שקעים (חוק-3):
//        · `registry.elementIds()` (מתודה על RegistryView-שכן) ⇒ הוזרק כ-`ids` (Set).
//        · `_namespaceOf(id)` (עוזר-שכן פרטי) ⇒ הוזרק כשקע-פונקציה `namespaceOf`.
//        · `kScopeAll/kScopeScreenPrefix/kScopeSinglePrefix` const-שכנים לא-ניתנים-לשחזור
//          ⇒ שקעים בשם, ברירות-מחדל מייצגות.
//
// קלט:  scope · ids · namespaceOf · (אוצר-הטווחים).
// פלט:  קבוצת-המזהים בטווח: הכל / לפי-מרחב / בודד-אם-קיים / ריק (fail-closed).

/// The element ids in [scope], filtered from [ids]. `all` → every id;
/// `screenPrefix<ns>` → ids whose [namespaceOf] equals `ns`; `singlePrefix<id>`
/// → `{id}` iff present, else empty; anything else → empty (FAIL-CLOSED).
/// Verbatim behaviour of edit_prompt.dart:168-188 with the registry lookup and
/// the namespace helper injected as sockets.
Set<String> scopeElementIds(
  String scope, {
  required Set<String> ids,
  required String Function(String id) namespaceOf,
  String all = 'all',
  String screenPrefix = 'screen:',
  String singlePrefix = 'element:',
}) {
  if (scope == all) return ids;
  if (scope.startsWith(screenPrefix)) {
    final ns = scope.substring(screenPrefix.length);
    return {
      for (final id in ids)
        if (namespaceOf(id) == ns) id,
    };
  }
  if (scope.startsWith(singlePrefix)) {
    final id = scope.substring(singlePrefix.length);
    return ids.contains(id) ? {id} : const <String>{};
  }
  return const <String>{}; // fail-closed
}
