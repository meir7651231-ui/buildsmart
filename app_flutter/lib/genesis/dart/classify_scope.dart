// ⚛️ אטום-Dart (דרגת-חוזה) · classifyScope
// תפקיד: מסווג reply של מודל ל-scope-סטודיו: token-רחב/מרחבי מוקדם, אחרת scope:single:<id>
//        על id-אמת, אחרת null (fail-closed → הבהרה). לעולם לא scope-מנוחש.
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_prompt.dart:147-167 (חוק-4).
// אחים שהוטבעו/סוקטו (חוק-3):
//   • studioScopeTokens(registry) ⇒ שקע `scopeTokens` (List<String>).
//   • matchElementId(view, reply) (exact→הכי-ארוך-מוכל→null) ⇒ שקע-פונקציה `matchId(ids, reply)`;
//     קריאה-1 מול scopeTokens, קריאה-2 מול registry.elementIds() ⇒ שקע `registryIds`.
//   • kScopeSinglePrefix (const-מודול) ⇒ שקע `scopeSinglePrefix`.
//   • RegistryView/FakeRegistryView נמחקו — נבלעו לתוך scopeTokens/registryIds/matchId.
// טוהר: dart:core בלבד.

/// verbatim edit_prompt.dart:147-167 (registry ⇒ scopeTokens/registryIds; matchElementId ⇒ matchId).
String? classifyScope(
  String reply, {
  required List<String> scopeTokens,
  required List<String> registryIds,
  required String scopeSinglePrefix,
  required String? Function(Iterable<String> ids, String reply) matchId,
}) {
  final r = reply.trim();
  if (r.isEmpty) return null; // fail-closed → clarify

  final t = matchId(scopeTokens, r);
  if (t != null) return t;

  if (r.contains(scopeSinglePrefix)) {
    final id = matchId(registryIds, r);
    if (id != null) return '$scopeSinglePrefix$id';
  }
  return null;
}
