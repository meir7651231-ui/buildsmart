# אטום · `plainClassifications`

מוצא: `buildsmart/app_flutter/lib/features/ring_dive/plain_dive.dart:186-198`

## חתימה
```dart
List<String> plainClassifications(String superCat, {
  required List<PlainNode> Function() allNodes,
  required bool Function(PlainNode) reaches,
})
```

## חוזה
Ring 2 של הצלילה-הפשוטה: מחזיר את **הסיווגים הייחודיים** תחת `superCat` נתון,
בסדר-העץ, **רק אלה שמגיעים למוצר** (`reaches(n)==true`).

- מסנן לפי `n.superCat == superCat`.
- דדופ על `classification` (הופעה ראשונה שומרת סדר).
- צומת שאינו מגיע-למוצר (`reaches==false`) מדולג.

## שקעים (מוזרקים)
- `allNodes()` — כל שורות-המילון (`_allNodes` במקור).
- `reaches(n)` — האם הצומת מגיע למוצר-אמת (`_reaches` במקור).

## טוהר
דטרמיניסטי, בלי state/IO. `PlainNode` מוטבע-מינימום (רק `superCat`+`classification`).
