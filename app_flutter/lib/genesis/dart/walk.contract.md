# חוזה · `walk` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/category_division.dart:86-95` (ה-closure `walk` בתוך `resolveCatTitle`; חולץ מ-commit `54d5e20e` — הקובץ אינו בעץ-העבודה הנוכחי).

## תפקיד
חיפוש-עומק רקורסיבי (DFS קדם-סדר) של הצומת **הראשון** בעץ CatalogNode שמקיים
`n.title == title || n.lipskeyCategory == title`, עם עצירה-מוקדמת כשכבר נמצא
(מאפשר לולאת-יער: `for (t in trees) walk(t, title, hit)` — המציאה הראשונה נועלת).

## חתימה
```dart
void walk(CatalogNode n, String title, CatalogHit hit)
// CatalogHit{ CatalogNode? node }                                  — מוטבע (מחזיק-מוטבל)
// CatalogNode{ String title; String? lipskeyCategory; List<CatalogNode> children } — מוטבע
```

## התנהגות (עוגן category_division.dart:86-95)
- `hit.node != null` ⇒ יציאה מיידית, `hit` לא נגוע (שורה 87: `if (hit != null) return;`).
- `n.title == title || n.lipskeyCategory == title` ⇒ `hit.node = n` ועצירה (שורות 88-91) —
  **קדם-סדר**: הצומת נבדק לפני ילדיו; אב-מתאים גובר על ילד-מתאים.
- אחרת ⇒ רקורסיה על `n.children` בסדרם (שורות 92-94) — אח-שמאלי גובר על אח-ימני.
- אין התאמה בכל תת-העץ ⇒ `hit.node` נשאר null.

## שקעים
- `title` — במקור closed-over מפרמטר resolveCatTitle ⇒ פרמטר (חוק-3).
- `hit` — במקור המקומי המוטבל `CatalogNode? hit` (שורה 85) שה-closure כותב אליו ⇒
  מחזיק `CatalogHit` מוזרק (Dart לא מעביר by-ref; חוק-3: הסגירה החיצונית ⇒ שקע).
- הזנב בטיוטה (לולאת `kCatalogTree` + עלה-סינתטי `catalogRepo()`) שייך לעוטפת
  `resolveCatTitle` — אינו חלק מהאטום (תקדים: collect / cat_node_product_count).

## דוגמאות-מחייבות
| # | עץ · title | hit-לפני | ⇒ hit.node-אחרי |
|---|------------|----------|------------------|
| 1 | שורש'צנרת' · 'צנרת' | null | השורש (התאמת-title) |
| 2 | שורש'א'[עלה'ב'(lip:'ברזי כיור')] · 'ברזי כיור' | null | העלה (התאמת-lipskeyCategory) |
| 3 | עץ-עם-התאמה · 'צנרת' | כבר-מלא בצומת-זר | הצומת-הזר, ללא-שינוי (עצירה-מוקדמת) |
| 4 | שורש'א'[עלה'ב'] · 'ג' | null | null (אין התאמה) |
| 5 | שורש'x'[עלה'x'] · 'x' | null | השורש (קדם-סדר: אב לפני ילד) |
| 6 | שורש'א'[עלה'x', עלה'x'₂] · 'x' | null | העלה הראשון (סדר-אחים) |
| 7 | יער [עץ1-מתאים, עץ2-מתאים], hit משותף | null | ההתאמה מעץ-1 (נעילת-יער) |

## DoD
```
dart run --enable-asserts new/dart/walk_test.dart  ⇒ exit 0 + "OK walk: 7 asserts passed"
```
