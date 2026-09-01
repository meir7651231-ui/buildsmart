# חוזה · isPipe

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:624-632` (verbatim, חוק-4).
עוגן: `:628` `_isPipe` + `:632` `isPipe` (עוטף). האטום מאחד לפונקציה-אחת (זהה-התנהגות).

## חתימה
```dart
bool isPipe(String categoryHe);
```

## קלט
- `categoryHe` — קטגוריית-המוצר בעברית (במקור `p.categoryHe`).

## פלט
`bool` — `_pipeCats.contains(categoryHe)` (6 קטגוריות-צינור, מקור:624-627).

## התנהגות
`true` כשהמוצר נמכר לפי-אורך (צינור) ⇒ ה-BOM נושא מטרים במקום יחידות.

## דוגמאות (עוגן install_engine.dart:624-632)
| # | categoryHe | פלט |
|---|------------|-----|
| 1 | צינורות    | true |
| 2 | צינורות רב שכבתי | true |
| 3 | צינורות מקלחת | true |
| 4 | אביזרי נחושת | false |
| 5 | ברכיים     | false |
| 6 | '' (ריק)   | false |
