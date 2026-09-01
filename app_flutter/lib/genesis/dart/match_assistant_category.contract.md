# חוזה · `matchAssistantCategory` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/assistant_intent.dart:60-81`
(‏`matchAssistantCategory`).

## חתימה
```dart
String? matchAssistantCategory(String reply, {required List<String> categories})
```

## קלט
- `reply` — תשובת-המודל הגולמית.
- `categories` — **שקע** (חוק-3): `assistantCategories()` verbatim — רשימת שמות-הקטגוריה.

## פלט / התנהגות (עוגני-שורה)
- `:61` — `r = reply.trim()`; `:62` — `r.isEmpty ⇒ null`.
- `:64-66` — **מעבר-מדויק ראשון**: `r == c` ⇒ מחזיר `c`.
- `:70-76` — **fallback המוכל-הארוך-ביותר**: `r.contains(c) && (best==null || c.length > best.length)`.
- ⚠️ נאמנות-מקור: בלולאת-המוכל **אין** מגן `c.isNotEmpty` (שלא כמו `_matchClosed`); הקלט
  במקור הוא רשימת-קטגוריות-אמת שאינה מכילה מחרוזת-ריקה.

## דוגמאות מספריות (‏categories: `['plumbing','electric','plumbingPro']`)
| # | reply | ⇒ |
|---|-------|---|
| 1 | `'electric'` | `'electric'` (מדויק) |
| 2 | `'plumbingPro'` | `'plumbingPro'` (מדויק גובר על התת-מחרוזת plumbing) |
| 3 | `'רוצה plumbingPro בבקשה'` | `'plumbingPro'` (מוכל-ארוך; 11>8) |
| 4 | `'zzz'` | `null` |
| 5 | `'   '` | `null` (ריק) |
| 6 | (categories ריק) `'electric'` | `null` |

## שקעים
- `categories` — הזרקת-רשימה (חוק-3).

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/match_assistant_category_test.dart  ⇒ exit 0 + "OK matchAssistantCategory: N asserts passed"
```
