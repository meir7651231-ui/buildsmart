// ⚛️ אטום-Dart (דרגת-חוזה) · passesImportance
// מוצא: buildsmart/app_flutter/lib/screens/notifications_screen.dart:331 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): NotifImportance.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__notifications_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): חדשות · נקודות · נוספו · למועדון · אושרה · ונמצאת · בהכנה · אין · התראות · אשר · איסוף · תדריך

enum NotifImportance { all, important, critical }

/// Importance filter: "all" keeps everything; otherwise only high-priority rows.
bool passesImportance(NotifImportance filter, bool highPriority) =>
    filter == NotifImportance.all || highPriority;
