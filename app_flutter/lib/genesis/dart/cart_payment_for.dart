// ⚛️ אטום-Dart (דרגת-חוזה) · cartPaymentFor
// מוצא: buildsmart/app_flutter/lib/screens/store_screen.dart:167 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): StorePayment, CartPaymentMethod.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__store_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): פריטים · ממתינים · לסיכום · בבנייה · להמשיך · הוסף · כלים · מושכרים · עד · פעילים · הצעות · חדשות

enum StorePayment { card, bit, applePay, supplierCredit }

enum CartPaymentMethod { card, bit, supplierCredit }

CartPaymentMethod cartPaymentFor(StorePayment p) => switch (p) {
  StorePayment.bit => CartPaymentMethod.bit,
  StorePayment.supplierCredit => CartPaymentMethod.supplierCredit,
  StorePayment.card || StorePayment.applePay => CartPaymentMethod.card,
};
