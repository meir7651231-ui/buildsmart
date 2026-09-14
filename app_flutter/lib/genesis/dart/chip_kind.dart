// ⚛️ אטום-Dart (דרגת-חוזה) · chipKind
// מוצא: buildsmart/app_flutter/lib/features/catalog_config/product_chips.dart:118 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): AttributeKind.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור features__catalog_config__product_chips — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): טמפ · אורך · זווית · חומר · יעד · מותג · מין · חיבור · מעבר · סוג · צבע · קוטר

enum AttributeKind { dimension, choice, material, color, freeText, number }

AttributeKind chipKind(String id) => switch (id) {
      'diameter' || 'diameter-small' => AttributeKind.dimension,
      'color' => AttributeKind.color,
      _ => AttributeKind.choice,
    };
