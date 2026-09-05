// חוט · importable-contacts (Dart) — אנשי-הקשר הראויים-לייבוא מטקסט-VCF (בניכוי זבל).
// חוזה: importable-contacts.contract.md · מקור: new/atoms/importable-contacts.mjs (מ-maor vcardImport.ts:236-254).
// השכנים parseVcards (פרסור-VCF) ו-isJunkContact (זיהוי כרטיס-זבל) מוזרקים כשקעים (חוק-1 — אפס import פנימי).
// אפס import (dart-core בלבד).

// JS-truthiness (כלל-המרה 7): `!isJunkContact(c)` של JS ≠ `!` של Dart.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// שקילה מלאה ל-JS: `parseVcards(text).filter((c) => !isJunkContact(c))`.
/// מחזיר List (כמו מערך JS מ-`.filter`), שומר-סדר ושומר-רפרנסים.
List<dynamic> importableContacts(
  dynamic text,
  dynamic Function(dynamic) parseVcards,
  dynamic Function(dynamic) isJunkContact,
) {
  final parsed = parseVcards(text) as List;
  return parsed.where((c) => !_truthy(isJunkContact(c))).toList();
}
