// ⚛️ אטום-Dart (דרגת-חוזה) · removeMember — הסרת עובד/ת מארגון (members + memberConfigs), טהור.
// מוצא: maor/src/components/platform/lib.ts:266-276 · המקור: new/atoms/remove-member.mjs
// חוזה: new/atoms/remove-member.contract.md · חולץ כלשונו; השכן normEmail הוזרק כשקע (חוק-1).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקע (חוק-1): normEmail(email) — מנרמל-מייל (במקור: trim().toLowerCase()).
// קלט: org ({members?: List<String>, memberConfigs?: Map}) · email · שקע-normEmail.
// פלט: {members: List<String>, memberConfigs: Map} — אובייקט-עדכון בלבד; org הנכנס לא משוכתב.
//
// הערות-המרה (מקור→Dart), מול DART-PORTING-RULES:
//  • `org.members ?? []`  ⇒  `(org['members'] as List?) ?? const []`  — ה-`??` של JS תופס
//    null/undefined; ב-Dart מפתח-חסר מחזיר null, ולכן `??` מתנהג זהה (אין הבחנה נדרשת כאן).
//  • `{ ...org.memberConfigs }` (עותק-רדוד; spread של undefined ⇒ {}) ⇒ `Map.from(... ?? const {})`.
//  • `delete memberConfigs[e]` ⇒ `memberConfigs.remove(e)` — על העותק בלבד (מוטביליות נשמרת:
//    members דרך `.toList()` חדש, memberConfigs דרך `Map.from` — org המקורי אינו נוגע).
//  • אין locale/פורמט/getMonth/substring/מודולו/truthiness במקור — אין שקע להזרקה.

/// Removes a member (email) from an org's `members` list (normalizing the whole
/// list to trim+lowercase in passing) and from `memberConfigs`. Returns an update
/// object `{members, memberConfigs}` only; the incoming `org` is never mutated.
/// Verbatim behaviour of the JS source `removeMember`.
Map<String, dynamic> removeMember(
  Map<String, dynamic> org,
  String email,
  String Function(String) normEmail,
) {
  final e = normEmail(email);
  final rawMembers = (org['members'] as List?) ?? const [];
  final members = rawMembers
      .map((m) => (m as String).trim().toLowerCase())
      .where((m) => m != e)
      .toList();
  final memberConfigs =
      Map<String, dynamic>.from((org['memberConfigs'] as Map?) ?? const {});
  memberConfigs.remove(e);
  return {'members': members, 'memberConfigs': memberConfigs};
}
