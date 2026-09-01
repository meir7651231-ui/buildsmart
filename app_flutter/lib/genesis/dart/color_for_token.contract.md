# חוזה · `colorForToken` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:254-273`
(‏`_colorForToken`, commit `d3c57704` — הקובץ אינו בעץ-העבודה הנוכחי של buildsmart;
חולץ מההיסטוריה. פרטי-במקור ⇒ public).

**שקעים (חוק-3 + חוק-5):** במקור כל case מחזיר שדה-שכן `BsTokens.*`
(‏`app_flutter/lib/theme/tokens.dart`, commit d3c57704:56-77 — ה-SSOT של הפיגמנטים).
הפיגמנטים = דאטה-הצבה ⇒ 7 פרמטרים-נקובים מוזרקים; האטום גנרי על `T` (אפס dart:ui).
**הידע שבאטום:** אוצר-7-ה-tokens + בחירת-השדה — `'warn'⇒warnText` (לא warnBright),
`'ink'⇒inkLight`, `'muted'⇒mutedLight`, והשאר בשם-זהה; כל-השאר ⇒ `null`.

## חתימה
```dart
T? colorForToken<T>(String? token, {
  required T brand, required T brandDark, required T success, required T danger,
  required T warnText, required T inkLight, required T mutedLight})
```

## קלט
- `token` — שם-ה-token (nullable).
- 7 שקעי-פיגמנט — במקור: `BsTokens.brand` וכו'.

## פלט / התנהגות (עוגני-שורה, edit_safety.dart@d3c57704)
- `:256-257` — `'brand'` ⇒ שקע `brand` (במקור `0xFFFF7A18`).
- `:258-259` — `'brandDark'` ⇒ `brandDark` (‏`0xFFE85F00`).
- `:260-261` — `'success'` ⇒ `success` (‏`0xFF22C55E`).
- `:262-263` — `'danger'` ⇒ `danger` (‏`0xFFEF4444`).
- `:264-265` — `'warn'` ⇒ **`warnText`** (‏`0xFFB45309`; לא warnBright — בחירת-המקור).
- `:266-267` — `'ink'` ⇒ **`inkLight`** (‏`0xFF1A1A1A`).
- `:268-269` — `'muted'` ⇒ **`mutedLight`** (‏`0xFF666666`).
- `:270-271` — default ⇒ `null` — כולל `null`, `''`, hex-גולמי (`'#FF7A18'`),
  רגישות-רישיות (`'Brand'`), ו-token-שכן שאינו-באוצר (`'warnText'`).

## דוגמאות (שקעים = ערכי-ה-SSOT כ-int)
| # | token | ⇒ |
|---|-------|---|
| 1 | `'brand'` | `0xFFFF7A18` |
| 2 | `'warn'` | `0xFFB45309` (warnText) |
| 3 | `'ink'` | `0xFF1A1A1A` (inkLight) |
| 4 | `'muted'` | `0xFF666666` (mutedLight) |
| 5 | `null` | `null` |
| 6 | `'#FF7A18'` | `null` (hex-גולמי לעולם לא נפתר) |
| 7 | `'Brand'` | `null` (רגיש-רישיות) |

## DoD
```
dart run --enable-asserts new/dart/color_for_token_test.dart  ⇒ exit 0 + "OK colorForToken: N asserts passed"
```
