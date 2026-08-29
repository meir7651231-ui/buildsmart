// ⚛️ אטום-Dart (דרגת-חוזה) · nonEmptyString
// מוצא: buildsmart/app_flutter/lib/data/bs_user.dart:217-226 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
// פרטי-במקור: `_nonEmptyString` — הוצא לחוזה כ-top-level ציבורי.
//
// קלט:  value — ערך מפוענח כלשהו.
// פלט:  מחרוזת מקוצצת לא-ריקה, או null (שדה-ריק ⇒ null, שומר חוזה-אופציונלי).

/// מחרוזת מקוצצת לא-ריקה מ-[value], או null (כל שאינו String / ריק ⇒ null). טהור.
String? nonEmptyString(Object? value) {
  if (value is! String) return null;
  final t = value.trim();
  return t.isEmpty ? null : t;
}
