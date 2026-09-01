// ⚛️ אטום-Dart (דרגת-חוזה) · token
// מוצא: buildsmart/app_flutter/lib/features/catalog_config/config_card.dart:200-206
//        (הפונקציה הפרטית `_token` — חוק-4, התנהגות זהה).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//
// אח שהוטבע (טיפוס-שכן קטן, כלל-1): `AttributeValue` — טיפוס-הקלט. הוטבע
//        verbatim מ-lib/domain/trade_schema.dart:168 עם רק שני השדות שהפונקציה
//        קוראת (canonical · labelHe); שאר השדות/factory הושמטו (כלל-1).
// פרטי-במקור: `_token` היה פרטי — הוצא לחוזה כ-top-level ציבורי `token`.
//
// קלט:  v — ערך-תכונה (variant value).
// פלט:  ה-canonical (הטוקן המכונתי) אם קיים, אחרת ה-labelHe (התווית האנושית).

/// טיפוס-שכן מוטבע (trade_schema.dart:168) — רק השדות שהפונקציה קוראת.
class AttributeValue {
  const AttributeValue({required this.labelHe, this.canonical});
  final String labelHe;
  final String? canonical;
}

/// הטוקן של [v] — צורתו הקנונית אם קיימת, אחרת התווית העברית.
String token(AttributeValue v) => v.canonical ?? v.labelHe;
