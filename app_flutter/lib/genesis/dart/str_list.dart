// ⚛️ אטום-Dart (דרגת-חוזה) · strList
// מוצא: buildsmart/app_flutter/lib/domain/trade_schema.dart:36-37 (`_strList`; פרטי-במקור;
//        חוק-4 — התנהגות זהה, לא-משופרת). מקדם `_strList` ⇒ `strList` (דגם `_name⇒name`).
// טוהר: פונקציית top-level עצמאית, dart:core בלבד — אפס import, אפס שקע, אפס שכן.
//
// תפקיד: מפענח-סובלני — מחזיר את איברי-המחרוזת של רשימה כלשהי (שאר-הטיפוסים נשמטים),
//        או רשימה-ריקה כשהקלט אינו רשימה (null/מספר/מפה/…). לעולם לא זורק.
//
// קלט:  v — Object? כלשהו (מ-JSON-סובלני: null / List / כל-טיפוס-אחר).
// פלט:  List<String> — איברי-המחרוזת בלבד, בסדר-המקור. אינו-רשימה ⇒ const [].
List<String> strList(Object? v) =>
    v is List ? v.whereType<String>().toList() : const [];
