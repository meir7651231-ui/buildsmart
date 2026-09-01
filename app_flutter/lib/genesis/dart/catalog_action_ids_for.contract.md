# חוזה · catalogActionIdsFor

**מוצא (עוגן-שורה · דיבר-11):** `buildsmart/app_flutter/lib/logic/studio/action_catalog.dart:280-286`

חולץ verbatim (חוק-4). המקור:

```dart
Set<String> catalogActionIdsFor(String elementId, {required bool readOnly}) {
  if (elementId.trim().isEmpty) return const <String>{}; // fail-closed   // :281
  return {
    for (final a in kActionCatalog)                                        // :283
      if (!(readOnly && a.mutates)) a.id,                                  // :284
  };
}
```

## שקע שהוזרק (חוק-1/3 · דיבר-3)
- `kActionCatalog` (השכן הגלובלי, action_catalog.dart:283) — קורס ל-`catalog`,
  `Iterable<CatalogAction>`. המקור קורא מכל פריט שני שדות בלבד: `a.id` (`:284`)
  ו-`a.mutates` (`:284`). לכן `CatalogAction` = מחזיק-קלט טהור `{ id, mutates }` —
  אפס תלות ב-`ActionDescriptor`, ב-enum `ActionEffectKind`, או בשדות `he/kind/
  groundedIn/sheetId/confirmGated`.

## קלט
| שם | טיפוס | משמעות |
|----|-------|--------|
| `elementId` | `String` | מזהה-האלמנט. `trim().isEmpty` ⇒ fail-closed. |
| `readOnly` | `bool` (named, required) | הקשר-קריאה-בלבד ⇒ בלי מוטטורים. |
| `catalog` | `Iterable<CatalogAction>` (named, required) | הקטלוג-הסגור. |

## פלט
`Set<String>` — ה-id-ים החוקיים להקשר-העריכה. Set-literal של Dart שומר
סדר-הכנסה (LinkedHashSet) ומסיר כפילויות.

## התנהגות (verbatim)
1. `elementId.trim().isEmpty` (ריק **או** רווחים-בלבד) ⇒ `<String>{}` ריק (`:281`).
2. אחרת ⇒ אוסף כל `a.id` שעבורו `!(readOnly && a.mutates)` (`:284`):
   - `readOnly == false` ⇒ **כל** ה-id-ים (התנאי `readOnly && …` תמיד false).
   - `readOnly == true` ⇒ רק פריטים שאינם מוטטורים (מדלג על `mutates == true`).
3. `elementId` אינו משמש מעבר לבדיקת-הריקוּת — זהה למקור (לא "משפרים", חוק-4).

## דוגמאות מספריות (מקריאת-הקוד · kActionCatalog, action_catalog.dart:131-181)
הקטלוג-החי: 7 פעולות בסדר —
`nav.screen`, `sheet.scanPlan`, `sheet.cheaperAlt`, `sheet.priceCompare`,
`cart.add` (**mutates:true**, :163), `cart.open`, `share.text` — רק `cart.add` מוטטור.

| # | elementId | readOnly | catalog | פלט |
|---|-----------|----------|---------|-----|
| 1 | `'card1'` | `false` | 7 החי | כל 7 ה-id-ים (כולל `cart.add`) |
| 2 | `'card1'` | `true`  | 7 החי | 6 ה-id-ים **בלי** `cart.add` |
| 3 | `''`      | `false` | 7 החי | `{}` ריק (fail-closed) |
| 4 | `'   '`   | `true`  | 7 החי | `{}` ריק (trim ⇒ ריק) |
| 5 | `'x'`     | `true`  | ריק     | `{}` ריק (אין פריטים) |
| 6 | `'x'`     | `false` | ריק     | `{}` ריק (אין פריטים) |
| 7 | `'x'`     | `true`  | שני-מוטטורים | `{}` ריק (הכול סונן) |
| 8 | `'x'`     | `false` | id כפול `k` | `{k}` (Set מדדפ) |

## עדשה-עוינת (CURRICULUM #6)
- קלט-קצה `''` ו-`'   '` (רווחים) — שניהם עוברים `trim().isEmpty` ⇒ ריק, כמו המקור.
- `readOnly=true` על קטלוג שכולו מוטטורים ⇒ ריק (לא זריקה, לא מוטטור-שדלף).
- קטלוג ריק ⇒ ריק בשני מצבי-readOnly.
- id כפול בקטלוג ⇒ מופיע פעם-אחת (סמנטיקת-Set), כמו במקור.

## DoD (דיבר-12)
```
dart run --enable-asserts new/dart/catalog_action_ids_for_test.dart  ⇒ exit 0
פלט צפוי: "catalogActionIdsFor OK — 8/8 contract examples proven"
```
