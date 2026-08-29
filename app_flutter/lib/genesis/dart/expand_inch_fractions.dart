// ⚛️ אטום-Dart (דרגת-חוזה) · expandInchFractions
// מוצא: buildsmart/app_flutter/lib/data/lipskey_catalog.dart:265-275 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// Normalise unicode inch fractions so the size engine recognises them
/// (צעד 22): 1¼ → 1.25 · 1½ → 1.5 · 2½ → 2.5 · ¾ → 0.75 ...
String expandInchFractions(String w) => w
    .replaceAll('¼', '.25')
    .replaceAll('½', '.5')
    .replaceAll('¾', '.75')
    .replaceAll('⅛', '.125')
    .replaceAll('⅜', '.375')
    .replaceAll('⅝', '.625')
    .replaceAll('⅞', '.875');
