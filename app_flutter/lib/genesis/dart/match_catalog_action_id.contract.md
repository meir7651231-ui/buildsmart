# חוזה · `matchCatalogActionId` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/action_catalog.dart:266-267`
(‏`matchCatalogActionId`). האח private `_matchClosed` (‏`registry_view.dart:237-260`) הוטבע verbatim inline (חוק-1).

## הכרעת-שקע (שקיפות)
המקור: `matchCatalogActionId(reply) => matchElementId(_catalogActionView, reply)`.
לפי חוזה-`matchElementId`, זה שקול ל-`_matchClosed(_catalogActionView.elementIds(), reply)`.
‏`_catalogActionView` הוא מופע-RegistryView פרטי (היררכיה+state) שאין להטביע verbatim;
לכן `_catalogActionView.elementIds()` הופך לשקע-נתון `catalogActionIds` (חוק-3).
התנהגות-האטום זהה-ביט בהינתן הקבוצה.

## חתימה
```dart
String? matchCatalogActionId(String reply, {required Set<String> catalogActionIds})
```

## קלט
- `reply` — תשובת-המודל הגולמית.
- `catalogActionIds` — **שקע**: `_catalogActionView.elementIds()` verbatim (תת-קבוצת פעולות-הקטלוג החוקיות).

## פלט / התנהגות (עוגני-שורה)
- `:266-267` — `matchElementId(_catalogActionView, reply)` ⇒ `_matchClosed(catalogActionIds, reply)`.
- `_matchClosed`: מדויק גובר → מוכל-ארוך-ביותר → null; reply-ריק ⇒ null (fail-closed).

## דוגמאות מספריות (‏catalogActionIds: `{'nav.open','share','cart.add'}`)
| # | reply | ⇒ |
|---|-------|---|
| 1 | `'share'` | `'share'` (מדויק) |
| 2 | `'בצע cart.add כאן'` | `'cart.add'` (מוכל) |
| 3 | `'zzz'` | `null` |
| 4 | `'   '` | `null` (ריק, fail-closed) |
| 5 | (catalogActionIds ריק) `'share'` | `null` |

## שקעים
- `catalogActionIds` — הזרקת-קבוצה (חוק-3, בגלל מופע-View פרטי במקור).

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_catalog_action_id_test.dart  ⇒ exit 0 + "OK matchCatalogActionId: N asserts passed"
```
