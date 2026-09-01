# חוזה · `productDivisionSystems` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/system_division.dart:22-27`.

## שקעים והטבעות (חוק-3 / חוק-5)
- `kVerifiedSpecs[p.sku]?.endSystems` (system_division.dart:23, טבלת-const חיצונית) הורם
  לשקע-ערך `verifiedEndSystems` (`Set<WaterSystem>?`). כך נשמט טיפוס-השכן
  `LipskeyCatalogProduct` (‏`p` שימש אך-ורק ל-`.sku` ⇒ לשקע, ול-`.brand` ⇒ לפרמטר `brand`).
- `WaterSystem` — enum-שכן-קטן, **הוטבע inline**. ערכיו אינם בטיוטה; הוסקו
  `{ supply, drainage }` מ-ראיית-אחות מפורשת: הטיוטה `plumbing_systems` בונה בדיוק
  2 מערכות ("אספקה"/"ניקוז") עם ההערה "These mirror [WaterSystem]", וטיוטה זו נוגעת
  רק ב-supply/drainage. (חוק: ערך-enum חסר ⇒ הסק מגוף+אחיות ותעד.)

## חתימה
```dart
enum WaterSystem { supply, drainage }
Set<WaterSystem> productDivisionSystems(String brand, {required Set<WaterSystem>? verifiedEndSystems})
```

## קלט
- `brand` — `String`, מותג-המוצר. במקור `p.brand` (system_division.dart:25).
- `verifiedEndSystems` — **שקע**: `Set<WaterSystem>?`, מערכות-הקצה מה-VerifiedSpec של המק"ט
  (‏`kVerifiedSpecs[p.sku]?.endSystems`, system_division.dart:23). `null` = אין spec.

## פלט / התנהגות (עוגני-שורה)
- `system_division.dart:24` — `if (ends != null && ends.isNotEmpty) return ends;`
  — spec מוגדר ולא-ריק גובר על הכול.
- `system_division.dart:25` — `if (p.brand == 'פולירול') return const {WaterSystem.supply};`
- `system_division.dart:26` — `return const {WaterSystem.drainage};` — ברירת-מחדל.
- **סדר-הכרעה:** spec-לא-ריק › מותג-פולירול › ניקוז.

## דוגמאות מספריות
| # | brand | verifiedEndSystems | ⇒ |
|---|-------|--------------------|---|
| 1 | `'פולירול'` | `null` | `{supply}` (מותג) |
| 2 | `'חוליות'` | `null` | `{drainage}` (ברירת-מחדל) |
| 3 | `'כלשהו'` | `{supply, drainage}` | `{supply, drainage}` (spec גובר) |
| 4 | `'פולירול'` | `{drainage}` | `{drainage}` (spec גובר על המותג) |
| 5 | `'כלשהו'` | `{}` (ריק) | `{drainage}` (spec ריק ⇒ נופל לברירת-מחדל) |
| 6 | `'פולירול'` | `{}` (ריק) | `{supply}` (spec ריק ⇒ מותג) |

## עדשה-עוינת
| # | brand | verifiedEndSystems | ⇒ |
|---|-------|--------------------|---|
| 7 | `''` (ריק) | `null` | `{drainage}` (אינו פולירול) |
| 8 | `'פולירול '` (רווח-נלווה) | `null` | `{drainage}` (השוואה מדויקת, אינו שווה) |
| 9 | `'x'` | `{supply}` | `{supply}` (spec יחיד) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/product_division_systems.dart                    ⇒ "No issues found!"
dart run --enable-asserts new/dart/product_division_systems_test.dart  ⇒ exit 0 + "OK productDivisionSystems: N asserts passed"
```
