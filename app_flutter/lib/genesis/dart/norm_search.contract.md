# חוזה · `normSearch` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/text_normalize.dart:24-33`
(‏`normSearch`). נירמול-מפתח לחיפוש/dedup עברי.

## הטבעה (חוק const-אח · חוק-8 · דיבר 11)
- `kHebrewFinalFold` — מפת קיפול-אותיות-סופיות. **ערכיה אינם בגוף-הטיוטה**
  והמקור `text_normalize.dart` אינו בריפו (grep ⇒ ריק). הוסקו משם-הקבוע
  ("final-fold") ומהתקן-העברי — 5 המיפויים היחידים האפשריים: `ך→כ · ם→מ · ן→נ ·
  ף→פ · ץ→צ`. הוטבעו inline כ-`_kHebrewFinalFold`. **דגל-סיכון:** אם המקור-החי
  כולל מיפוי נוסף/שונה — יש לעדכן; הגולדן מאפיין את ההטבעה הזו.

## חתימה
```dart
String normSearch(String t)
```

## התנהגות (עוגני-שורה)
- `text_normalize.dart:25` — `toLowerCase()`.
- `:26` — הסרת-ניקוד `RegExp('[֑-ׇ]')` (U+0591..U+05C7).
- `:27-30` — קיפול תו-תו דרך `kHebrewFinalFold[ch] ?? ch`.
- `:31` — הסרת-מפרידים `RegExp('[\'"׳״\\-–._]')` (גרש/מרכאות/מקף/en-dash/נקודה/קו-תחתי).
  **רווח אינו מפריד** — נשמר.
- `:32` — `trim`.

## דוגמאות מספריות
| # | t | ⇒ | מנגנון |
|---|---|---|--------|
| 1 | `'שלום'` | `'שלומ'` | ם→מ |
| 2 | `'מלך'` | `'מלכ'` | ך→כ |
| 3 | `'בן דוד'` | `'בנ דוד'` | ן→נ · רווח נשמר |
| 4 | `'a-b.c_d'` | `'abcd'` | מפרידים מוסרים |
| 5 | `'Cohen'` | `'cohen'` | lower-case |
| 6 | `'ד״ר'` | `'דר'` | גרשיים מוסר |
| 7 | `"  צ'ק  "` | `'צק'` | גרש מוסר + trim |

## שקעים
אין (הקבוע הוטבע). `toLowerCase`/`replaceAll`/`RegExp`/`split`/`StringBuffer`/`trim` — שפה בלבד.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/norm_search_test.dart  ⇒ exit 0 + "OK normSearch: N asserts passed"
```
