// ⚛️ אטום-Dart (דרגת-חוזה) · currencySymbol
// מוצא: buildsmart/app_flutter/lib/state/catalog_settings.dart:469 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): CatalogCurrency.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__lipskey_product_sheet — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): ליחידה · מוצרים · וריאנטים · דרישות · שלבים · חלקים · צדדים · מה · מתחבר · לכל · מידה · חובה

enum CatalogCurrency { ils, usd, eur }

/// Display symbol for the chosen catalog currency. This is the *local display*
/// symbol only — NO FX conversion is applied to the amount (live rates need an
/// external service; faking a conversion would mislead). The selection is
/// persisted and the symbol is shown next to the (unconverted) amount.
String currencySymbol(CatalogCurrency c) => switch (c) {
      CatalogCurrency.ils => '₪',
      CatalogCurrency.usd => r'$',
      CatalogCurrency.eur => '€',
    };
