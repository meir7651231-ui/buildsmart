// ⚛️ אטום-Dart (דרגת-חוזה) · defaultValue
// מוצא: buildsmart/app_flutter/lib/features/catalog_config/config_card.dart:189-199 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית, אפס import (רק dart:core).
// פרטי-במקור: `_defaultValue` — הוצא לחוזה כ-top-level ציבורי.
//
// אחים שהוטבעו (טיפוסי-שכן, כלל-1):
//   • `AttributeValue` — מ-trade_schema.dart:168, רק `sortIndex` (הפונקציה קוראת
//        אותו) + `labelHe` (זהות-ערך לבדיקה). שאר השדות הושמטו.
//   • `AttributeDef` — מ-trade_schema.dart:208, רק `values`.
//
// קלט:  attr — הגדרת-תכונה (קורא מובטח — `values` לא-ריק).
// פלט:  הערך שסדר-המיון שלו 0, אחרת הראשון.

/// טיפוס-שכן מוטבע (trade_schema.dart:168) — רק `sortIndex` + `labelHe`.
class AttributeValue {
  const AttributeValue({required this.labelHe, required this.sortIndex});
  final String labelHe;
  final int sortIndex;
}

/// טיפוס-שכן מוטבע (trade_schema.dart:208) — רק `values`.
class AttributeDef {
  const AttributeDef({required this.values});
  final List<AttributeValue> values;
}

/// ערך-ברירת-המחדל של [attr] — `sortIndex == 0`, אחרת הראשון. טהור.
AttributeValue defaultValue(AttributeDef attr) {
  for (final v in attr.values) {
    if (v.sortIndex == 0) {
      return v;
    }
  }
  return attr.values.first;
}
