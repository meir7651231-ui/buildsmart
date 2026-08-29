// חוט · is-member — האם המייל חבר בארגון (מנהל או ברשימת-members).
// המרה מ-JS (new/atoms/is-member.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכנים normEmail ו-isOrgManager מוזרקים כשקעים (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
bool isMember(
  String email,
  Map<String, dynamic> org,
  String Function(String) normEmail,
  bool Function(String, Map<String, dynamic>) isOrgManager,
) {
  final e = normEmail(email);
  if (isOrgManager(e, org)) return true;
  // org.members ?? [] — מפתח חסר/null ⇒ רשימה ריקה (JS nullish); כל חבר מנורמל trim+lower.
  final members = (org['members'] as List?) ?? const [];
  return members.map((m) => (m as String).trim().toLowerCase()).contains(e);
}
