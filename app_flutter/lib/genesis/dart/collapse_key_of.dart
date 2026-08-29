// ⚛️ אטום-Dart (דרגת-חוזה) · collapseKeyOf
// מוצא: buildsmart/app_flutter/lib/features/word_finder/word_finder_engine.dart:239-247 (חצב-בינה · חוק-3/4).
// שקע: collapseKey ← השכן `_collapseKey(p)` — מפתח-קיפול-וריאנטים של מוצר (String).
// מעביר-דרך טהור: הגוף אינו נוגע בשדות המוצר ⇒ טיפוס-המוצר (LipskeyCatalogProduct,
//        מחלקה כבדה עם תלויות) נשאר פרמטר-טיפוס גנרי T (כלל-1 — אפס-import).

String collapseKeyOf<T>(T p, {required String Function(T) collapseKey}) =>
    collapseKey(p);
