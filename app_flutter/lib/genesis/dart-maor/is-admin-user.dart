// חוט · is-admin-user — האם המשתמש מנהל-על (רשימה ריקה/חסרה=כולם). חוזה: is-admin-user.contract.md
// המרה מ-JS (new/atoms/is-admin-user.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// חוק-6: המיילים הם קונפיגורציית-הצבה, מוזרקים דרך config; החוט לא נושא זהות. אפס-import (dart-core בלבד).
bool isAdminUser(Map<String, dynamic> config, String? email) {
  final admins = config['adminEmails'] as List?;
  // JS: !admins || admins.length===0 — רשימה חסרה/ריקה = אין הגבלה.
  if (admins == null || admins.isEmpty) return true;
  // JS: if (!email) — null/undefined/'' כולם falsy ⇒ לא-אדמין.
  if (email == null || email.isEmpty) return false;
  final e = email.trim().toLowerCase();
  return admins.any((a) => (a as String).trim().toLowerCase() == e);
}
