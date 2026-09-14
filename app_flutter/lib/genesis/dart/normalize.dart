// ⚛️ אטום-Dart (דרגת-חוזה) · normalize
// מוצא: buildsmart/app_flutter/lib/logic/equipment_stock_join.dart:35 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// Normalize one side of the join: trim, lower-case, and collapse every run of
/// whitespace AND punctuation (anything that is not a letter/digit, across
/// scripts incl. Hebrew via Unicode-aware classes) into a single space, then
/// trim again. So 'סרט טפלון (PTFE)' and '  סרט   טפלון – ptfe ' both reduce to
/// a clean space-separated core, and 'Wrench, 1/2"' → 'wrench 1 2'. Punctuation
/// becomes a separator (not a deletion) so adjacent words never fuse.
String normalize(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();
