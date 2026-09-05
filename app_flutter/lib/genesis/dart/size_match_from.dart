// ⚛️ אטום-Dart (דרגת-חוזה) · sizeMatchFrom
// מוצא: buildsmart/app_flutter/lib/domain/connection_schema.dart:46-47 (חוק-4 — התנהגות זהה, לא-משופרת).
//        ה-enum SizeMatch (שם:23) נכלל כאן כטיפוס-הפלט של האטום — לא import-אטום, אלא הטיפוס
//        שהאטום מייצר (שמות-הערכים הם ה-lookup עצמו: e.name == v).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). firstWhere = סטנדרט-Dart
//        (לא שקע-הזרקה). השם הפרטי במקור (_sizeMatchFrom) הוסר; זהו מפענח-סובלני טהור
//        (מיפוי-ערך, לא עוזר-גלגול) — יחידה קטנה עם קלט/פלט מוגדרים (תיקון-בעלים לחוק-5).
//
// קלט:  v — הערך הגולמי (Object?, ‏nullable) — בד"כ מ-JSON (connection_schema.dart:259).
// פלט:  ה-SizeMatch ש-e.name שווה בדיוק ל-v; לא-מוכר / null / לא-String ⇒ ברירת-מחדל exactSame.

/// How a rule matches connector sizes when it fires.
enum SizeMatch { exactSame, anyToAny, tableLookup }

/// Tolerant decoder: the SizeMatch whose `.name` equals [v] exactly.
/// Unknown / null / non-String → SizeMatch.exactSame (no throw).
SizeMatch sizeMatchFrom(Object? v) => SizeMatch.values
    .firstWhere((e) => e.name == v, orElse: () => SizeMatch.exactSame);
