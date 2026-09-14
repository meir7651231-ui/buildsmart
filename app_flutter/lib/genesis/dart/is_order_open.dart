// ⚛️ אטום-Dart (דרגת-חוזה) · isOrderOpen
// מוצא: buildsmart/app_flutter/lib/screens/store_screen.dart:481 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// שקעים (חוק-3 — הוזרקו אוטומטית מקריאות-שכן במקור): kDeliveredStage.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__store_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): פריטים · ממתינים · לסיכום · בבנייה · להמשיך · הוסף · כלים · מושכרים · עד · פעילים · הצעות · חדשות

/// An order is "open" until it has been delivered.
bool isOrderOpen(String stage, {required String kDeliveredStage}) => stage != kDeliveredStage;
