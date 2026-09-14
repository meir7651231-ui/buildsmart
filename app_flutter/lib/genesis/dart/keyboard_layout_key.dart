// ⚛️ אטום-Dart (דרגת-חוזה) · keyboardLayoutKey
// מוצא: buildsmart/app_flutter/lib/config/screen_registry.dart:42 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__floating_card_keyboard — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): אינסטלציה · ברזים · וסניטריים · ההזמנות · שלי · החלקים · לעבודה · הסל · התראות · חיפוש · כלי · עבודה

/// The [screenSectionsProvider] key for a screen's KEYBOARD-tool layout (order /
/// hide of the per-screen keyboard tiles), distinct from the section layout.
String keyboardLayoutKey(String screenId) => 'kbd:$screenId';
