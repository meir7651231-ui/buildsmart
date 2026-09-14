// ⚛️ אטום-Dart (דרגת-חוזה) · slug
// מוצא: buildsmart/app_flutter/lib/screens/trade_builder/attribute_schema_editor.dart:50 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__trade_builder__attribute_schema_editor — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): אין · עדיין · מאפיינים · בדיקת · פירוק · שם · בחירה · הוסף · מאפיין · ערך · הסר · חומר

/// The s44 deterministic slug: trimmed, lowercased, whitespace runs → '-'.
/// NO DateTime/random — the same text always yields the same slug.
String slug(String text) =>
    text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
