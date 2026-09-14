// ⚛️ אטום-Dart (דרגת-חוזה) · normalizeDocName
// מוצא: buildsmart/app_flutter/lib/state/required_docs_policy.dart:38 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// Normalize a document/cert name for MATCHING (the gate compares a required
/// name against a present cert's name through this): trim, collapse internal
/// runs of whitespace to a single space, and lower-case. This is the E2 lesson
/// — match by NORMALIZED-EXACT equality, NEVER substring/contains — so e.g.
/// 'בטיחות' and 'בטיחות בגובה' stay DISTINCT (one is not "contained" in the
/// other). The stored policy value keeps the contractor's display form; only
/// the comparison runs through here.
String normalizeDocName(String s) =>
    s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
