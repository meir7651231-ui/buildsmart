// ⚛️ אטום-Dart (דרגת-חוזה) · approveMember — אישור בקשת-הצטרפות (רשימת-חברים מנורמלת, בלי כפילויות).
// מוצא: maor/src/components/platform/lib.ts:249-253 · המקור: new/atoms/approve-member.mjs —
//   export function approveMember(org, email, normEmail) {
//     const e = normEmail(email);
//     const members = [...new Set([...(org.members ?? []).map((m)=>m.trim().toLowerCase()), e])];
//     return { members };
//   }
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקע (חוק-1): normEmail — נירמול-מייל של השכן, מוזרק כפרמטר (במקור import פנימי).
// קלט: org (מפה עם members?) · email · normEmail. פלט: מפה {'members': [...]} מנורמלת+מדודפת.
//
// הערות-המרה (מקור→Dart):
//   • org.members ?? []  ⇒  (org['members'] as List?) ?? const []  (nullish-coalescing → ?? ; חסר/null בלבד).
//   • new Set(...)        ⇒  <String>{...}  — Set של Dart (LinkedHashSet) שומר סדר-הכנסה ומדדפ על-הראשון,
//     זהה בדיוק ל-Set של JS: הקיימים-המנורמלים תחילה, ואז e; כפילות משאירה את המופע הראשון.
//   • אין locale/פורמט/getMonth/truthiness. מוטביליות: final בלבד (אין השמה-חוזרת).
//   • אי-מוטציה: org אינו משוכתב (map יוצר איטרטור חדש) — דוגמת-חוזה 5.

/// Approves a join request: returns a normalized, de-duplicated member list.
/// Verbatim behaviour of the JS source `approveMember`.
Map<String, List<String>> approveMember(
  Map org,
  String email,
  String Function(String) normEmail,
) {
  final e = normEmail(email);
  final existing = (org['members'] as List?) ?? const [];
  final normalized = existing.map((m) => (m as String).trim().toLowerCase());
  final members = <String>{...normalized, e}.toList();
  return {'members': members};
}
