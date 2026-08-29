// ⚛️ אטום-Dart (דרגת-חוזה) · studioScopeTokens
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:131-146 (חוק-4 — לוגיקה verbatim).
// אחים-שהוזרקו (חוק-3): `registry.elementIds()` ⇒ שקע `elementIds`; הפונקציה-השכנה
//        `_namespaceOf(id)` ⇒ שקע `namespaceOf`. הקבועים `kScopeAll`/`kScopeScreenPrefix`
//        (ערכיהם נעדרים מהטיוטה — מקור נעדר) ⇒ שקעים `scopeAll`/`screenPrefix` (חוק-8: אין המצאת-ערך).
//
// קלט:  elementIds  — שקע: מזהי-האלמנטים החיים (Iterable<String>).
//       namespaceOf — שקע: חילוץ מרחב-שם ממזהה (id ⇒ ns; '' = אין).
//       scopeAll    — שקע: טוקן-"הכול" (kScopeAll).
//       screenPrefix— שקע: תחילית-טוקן-מסך (kScopeScreenPrefix).
// פלט:  קבוצה: {scopeAll} + '<screenPrefix><ns>' לכל id בעל ns לא-ריק (Set ⇒ ייחוד-אוטומטי).

/// The closed set of editable scope tokens: `{scopeAll}` plus one
/// `<screenPrefix><namespace>` per element whose namespace is non-empty.
/// Verbatim behaviour of edit_prompt.dart:131-146 with the registry read, the
/// namespace helper, and the two scope consts injected as slots.
Set<String> studioScopeTokens({
  required Iterable<String> Function() elementIds,
  required String Function(String) namespaceOf,
  required String scopeAll,
  required String screenPrefix,
}) {
  final tokens = <String>{scopeAll};
  for (final id in elementIds()) {
    final ns = namespaceOf(id);
    if (ns.isNotEmpty) tokens.add('$screenPrefix$ns');
  }
  return tokens;
}
