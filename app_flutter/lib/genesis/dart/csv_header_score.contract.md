# חוזה · `csvHeaderScore`

מוצא: `buildsmart/app_flutter/lib/data/csv_kernel.dart:54-68`.

## חתימה
```dart
int csvHeaderScore(List<CsvRecord> records, Set<String> knownHeaders)
```

## התנהגות
ציון-זיהוי-מפריד: כמה מתאי רשומת-הכותרת תואמים שם ב-[knownHeaders] תחת
הנרמול הזה. מאתר את רשומת-הכותרת (`csvHeaderIndex` = הראשונה שאינה ריקה ואינה
'#'-הערה), ולכל תא בה סופר אם `normHeader(cell)` (‏BOM החוצה · trim · lowercase)
נמצא ב-[knownHeaders]. אין רשומת-כותרת ⇒ 0.

## מפל-מינימום
- `CsvRecord` (line+cells) + `kCsvBom` + `normHeader`/`csvIsBlank`/`csvIsComment`/
  `csvHeaderIndex` הוטבעו verbatim ⇒ האטום עומד בפני-עצמו.

## שוליים
- רשומות ריקות/הערה בראש ⇒ מדולגות; הכותרת נלקחת מהרשומה הממשית הראשונה.
- אין רשומה-ממשית (הכל ריק/הערה) ⇒ 0.
- כותרת עם BOM/רישיות שונה ⇒ עדיין תואמת אחרי הנרמול.
