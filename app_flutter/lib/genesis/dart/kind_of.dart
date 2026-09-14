// ⚛️ אטום-Dart (דרגת-חוזה) · kindOf
// מוצא: buildsmart/app_flutter/lib/data/variant_families.dart:33 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, ייבוא-מדף בלבד (אומת ע"י פותר-המזהים).
// ייבוא-מדף (G69/G70 — אטום משותף מיובא, לא עותק מוטבע ולא שקע): kLipskeyColors · kLipskeyModels · kLipskeySubtypes ← ../dart-data/k_lipskey_catalog-table.dart.
// שקעים (חוק-3 — הוזרקו אוטומטית מקריאות-שכן במקור): isSizeToken.
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): AttrKind.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__lipskey_product_sheet — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): ליחידה · מוצרים · וריאנטים · דרישות · שלבים · חלקים · צדדים · מה · מתחבר · לכל · מידה · חובה

import '../dart-data/k_lipskey_catalog-table.dart';

enum AttrKind { size, color, model, subtype }

AttrKind? kindOf(String w, {required bool Function(String) isSizeToken}) {
  if (isSizeToken(w)) return AttrKind.size;
  if (kLipskeyColors.contains(w)) return AttrKind.color;
  if (kLipskeyModels.contains(w)) return AttrKind.model;
  if (kLipskeySubtypes.contains(w)) return AttrKind.subtype;
  return null;
}
