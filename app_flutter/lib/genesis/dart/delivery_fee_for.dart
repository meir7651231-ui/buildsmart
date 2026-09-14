// ⚛️ אטום-Dart (דרגת-חוזה) · deliveryFeeFor
// מוצא: buildsmart/app_flutter/lib/screens/store_screen.dart:451 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): CartDelivery.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__store_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): פריטים · ממתינים · לסיכום · בבנייה · להמשיך · הוסף · כלים · מושכרים · עד · פעילים · הצעות · חדשות

enum CartDelivery { express, standard, pickup }

int deliveryFeeFor(CartDelivery d) => switch (d) {
  CartDelivery.express => 120,
  CartDelivery.standard => 45,
  CartDelivery.pickup => 0,
};
