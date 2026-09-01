# חוזה · `matchAssistantRecipeKey` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/assistant_intent.dart:82-98`
(‏`matchAssistantRecipeKey`).

## הכרעת-שקע (שקיפות)
המקור סורק `for (final p in kSmartProducts)` וקורא אך-ורק את `p.key`. לכן טיפוס-המוצר
המלא מיותר: הקבוע `kSmartProducts` קופל לשקע-רשימת-מפתחות
`productKeys` = `kSmartProducts.map((p) => p.key)` verbatim (חוק-3). סדר-הרשימה נשמר —
קריטי ל-tie של אורך-שווה (‏`>` חמור ⇒ הראשון-שנסרק זוכה).

## חתימה
```dart
String? matchAssistantRecipeKey(String reply, {required List<String> productKeys})
```

## קלט
- `reply` — תשובת-המודל הגולמית.
- `productKeys` — **שקע**: `kSmartProducts.map((p) => p.key)` verbatim (בסדר המקורי).

## פלט / התנהגות (עוגני-שורה)
- `:83` — `r = reply.trim()`; `:84` — `r.isEmpty ⇒ null`.
- `:85-87` — **מעבר-מדויק ראשון**: `r == p.key` ⇒ מחזיר את המפתח.
- `:90-96` — **fallback המוכל-הארוך-ביותר**: `r.contains(key) && (best==null || key.length > best.length)`.
- ⚠️ נאמנות-מקור: אין מגן `key.isNotEmpty` בלולאת-המוכל (מפתחות-מוצר אמיתיים אינם ריקים).

## דוגמאות מספריות (‏productKeys: `['faucet','kitchenFaucet','basinTrap']`)
| # | reply | ⇒ |
|---|-------|---|
| 1 | `'faucet'` | `'faucet'` (מדויק — גובר לפני שהתת-מחרוזת ב-kitchenFaucet נשקלת) |
| 2 | `'kitchenFaucet'` | `'kitchenFaucet'` (מדויק) |
| 3 | `'הרכב לי kitchenFaucet'` | `'kitchenFaucet'` (מוכל-ארוך; 13>6) |
| 4 | `'zzz'` | `null` |
| 5 | `'   '` | `null` (ריק) |
| 6 | (productKeys ריק) `'faucet'` | `null` |

## שקעים
- `productKeys` — הזרקת-רשימת-מפתחות (חוק-3).

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_assistant_recipe_key_test.dart  ⇒ exit 0 + "OK matchAssistantRecipeKey: N asserts passed"
```
