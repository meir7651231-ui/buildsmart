// חוט · is-super-admin — האם מייל-על (trim+lowercase מול רשימה מוזרקת). חוזה: is-super-admin.contract.md
// המרה מ-JS (new/atoms/is-super-admin.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכן SUPER_ADMIN_EMAILS מוזרק כשקע (חוק-1) — זהות/מיילים = חיווט-הצבה, לא אטום (חוק-6).
// אפס-import (dart-core בלבד).
//
// שקילות-JS:
//   `email || ''` — null/undefined/'' כולם falsy ⇒ '' ⇒ ב-Dart `email ?? ''` (null→'', ''נשאר'').
//   `!!e` — מחרוזת לא-ריקה truthy ⇒ `e.isNotEmpty` (כלל-7: truthiness מפורש).
//   `.includes` ⇒ `.contains`.
bool isSuperAdmin(String? email, List<String> superAdminEmails) {
  final e = (email ?? '').trim().toLowerCase();
  return e.isNotEmpty && superAdminEmails.contains(e);
}
