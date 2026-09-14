// ⚛️ אטום-Dart (דרגת-חוזה) · registrationValid
// מוצא: buildsmart/app_flutter/lib/state/user_profile.dart:84 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__welcome_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): ואת · של · כולל · אימות · דו · שלבי · אם · מוגדר · לא · נשמרת · סיסמה · במכשיר

/// Registration is valid when both name and contact are non-empty — mirrors the
/// prototype's `checkRegistration` (the ✓ appears once the fields are filled).
/// Pure → unit-testable.
bool registrationValid(String name, String contact) =>
    name.trim().isNotEmpty && contact.trim().isNotEmpty;
