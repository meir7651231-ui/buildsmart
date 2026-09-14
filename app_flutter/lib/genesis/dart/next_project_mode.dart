// ⚛️ אטום-Dart (דרגת-חוזה) · nextProjectMode
// מוצא: buildsmart/app_flutter/lib/state/project_mode.dart:33 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): ProjectMode.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__catalog_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · בעץ · גרסאות · מים · חמים · בלבד · מתכת · ליפסקי · ברקן · משפחות · וריאנטים · שונה

/// Active project type — which "world" the user is shopping for. Persisted
/// so the card can later hide irrelevant content (e.g. hide hot-water-only
/// items when the project is `cold`, or show only commercial-grade items in
/// `commercial`). Roadmap step 52 (state layer; UI filter wiring TBD).
enum ProjectMode { any, cold, hot, commercial }

/// Cycle order for the UI chip: any → cold → hot → commercial → any.
/// Pure — caller passes the current; UI taps to advance.
ProjectMode nextProjectMode(ProjectMode current) {
  switch (current) {
    case ProjectMode.any:
      return ProjectMode.cold;
    case ProjectMode.cold:
      return ProjectMode.hot;
    case ProjectMode.hot:
      return ProjectMode.commercial;
    case ProjectMode.commercial:
      return ProjectMode.any;
  }
}
