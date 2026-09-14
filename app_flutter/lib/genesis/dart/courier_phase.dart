// ⚛️ אטום-Dart (דרגת-חוזה) · courierPhase
// מוצא: buildsmart/app_flutter/lib/screens/courier_dashboard_screen.dart:941 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): OrderStage.

enum OrderStage { newOrder, preparing, ready, pickup, transit, delivered }

/// Which of the 3 tracker steps (איסוף / בדרך / נמסר) is current.
int courierPhase(OrderStage s) => switch (s) {
  OrderStage.ready => 0,
  OrderStage.pickup => 1,
  OrderStage.transit => 1,
  OrderStage.delivered => 2,
  _ => 0,
};
