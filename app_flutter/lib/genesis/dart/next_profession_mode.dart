// ⚛️ אטום-Dart (דרגת-חוזה) · nextProfessionMode
// מוצא: buildsmart/app_flutter/lib/state/profession_mode.dart:24 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): ProfessionMode.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__catalog_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · בעץ · גרסאות · מים · חמים · בלבד · מתכת · ליפסקי · ברקן · משפחות · וריאנטים · שונה

/// Who's using the card — affects which detail level is the *sensible default*
/// and (in the future) which sections show by default. Orthogonal to
/// `cardDetailModeProvider`: profession picks the default mode; the user can
/// still toggle mode within that. Roadmap step 57 (state layer; UI affordance TBD).
enum ProfessionMode { diy, contractor, pro }

/// Cycle order for the UI chip: diy → contractor → pro → diy …
/// Pure (no provider read); the UI calls this on tap.
ProfessionMode nextProfessionMode(ProfessionMode current) {
  switch (current) {
    case ProfessionMode.diy:
      return ProfessionMode.contractor;
    case ProfessionMode.contractor:
      return ProfessionMode.pro;
    case ProfessionMode.pro:
      return ProfessionMode.diy;
  }
}
