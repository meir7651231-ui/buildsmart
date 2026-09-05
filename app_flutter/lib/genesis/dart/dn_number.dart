// ⚛️ אטום-Dart · dnNumber
// מוצא: buildsmart/app_flutter/lib/features/catalog_config/dn_scale.dart:70-75 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: ה-RegExp `_kFirstNum` (:50) הוטבע verbatim.

/// המספר-הראשון בטקסט (שלם או עשרוני). ריגקס-מקור, לא-שונה.
final RegExp _kFirstNum = RegExp(r'(\d+(?:\.\d+)?)');

/// The integer of a `DN<n>` label, for ascending wheel sort (so DN15 precedes
/// DN110, not the lexical reverse). A non-DN label sorts last, deterministically.
int dnNumber(String label) {
  final m = _kFirstNum.firstMatch(label);
  if (m == null) return 1 << 30;
  return int.tryParse(m.group(1)!.split('.').first) ?? (1 << 30);
}
