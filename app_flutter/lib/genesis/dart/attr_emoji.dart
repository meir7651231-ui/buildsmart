// ⚛️ אטום-Dart (דרגת-חוזה) · attrEmoji
// מוצא: buildsmart/app_flutter/lib/screens/lipskey_products_screen.dart:1711 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): AttrKind.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__lipskey_products_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): יוסר · מהסל · מוצרים · ׳״ · קוטר · חיצוני · נומינלי · או · אורך · אין · להצגה · אישור

/// Kinds of attributes that are cyclable variants on a product card.
/// [colorMod] is the finish/modifier word of a compound colour (e.g. "מוברש"
/// from "ניקל מוברש") — shown as a separate chip from the base colour.
enum AttrKind { size, color, colorMod, model, subtype, type, material, pressure, sdr, maker }

/// Emoji marker per attribute kind (shown on the chip).
String attrEmoji(AttrKind k) => switch (k) {
      AttrKind.size => '📐',
      AttrKind.color => '🎨',
      AttrKind.colorMod => '✨',
      AttrKind.model => '🏷',
      AttrKind.subtype => '📋',
      AttrKind.type => '🔧',
      AttrKind.material => '🧪',
      AttrKind.pressure => '🔵',
      AttrKind.sdr => '📊',
      AttrKind.maker => '🏭',
    };
