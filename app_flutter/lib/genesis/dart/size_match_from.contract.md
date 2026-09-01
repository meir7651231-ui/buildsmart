# חוזה · sizeMatchFrom

מפענח-סובלני: ממפה ערך-גולמי (בד"כ מ-JSON) ל-enum `SizeMatch`.

- **מוצא (עוגני-שורה):** `buildsmart/app_flutter/lib/domain/connection_schema.dart`
  - `46-47` — גוף הפונקציה `_sizeMatchFrom`.
  - `23` — הגדרת `enum SizeMatch { exactSame, anyToAny, tableLookup }`.
  - `259` — שימוש חי: `sizeMatch: _sizeMatchFrom(j['sizeMatch'])` (הקלט = ערך-JSON גולמי).

## קלט
| שם | טיפוס | הערה |
|----|-------|------|
| `v` | `Object?` | ערך גולמי, ‏nullable. בד"כ String מ-JSON, אך כל טיפוס מותר. |

## פלט
`SizeMatch` — הערך ש-`e.name == v` בדיוק. אם אף שם לא תואם (כולל `null`, טיפוס-לא-String, או String-לא-מוכר) ⇒ ברירת-המחדל `SizeMatch.exactSame`.

## התנהגות
1. סורק את `SizeMatch.values` לפי סדר-ההכרזה: `exactSame`, `anyToAny`, `tableLookup`.
2. מחזיר את הראשון ש-`e.name == v`.
3. אין התאמה ⇒ `orElse` ⇒ `exactSame`. לעולם לא זורק.
4. ההשוואה היא `String(e.name) == v` — רגיש-רישיות, ללא-trim; רווח-נוסף ⇒ ברירת-מחדל.

## דוגמאות מספריות (מקריאת-הקוד)
| `v` | פלט | סיבה |
|-----|-----|------|
| `'exactSame'` | `SizeMatch.exactSame` | name תואם |
| `'anyToAny'` | `SizeMatch.anyToAny` | name תואם |
| `'tableLookup'` | `SizeMatch.tableLookup` | name תואם |
| `null` | `SizeMatch.exactSame` | אין name==null ⇒ default |
| `''` | `SizeMatch.exactSame` | מחרוזת-ריקה לא-מוכרת ⇒ default |
| `'ExactSame'` | `SizeMatch.exactSame` | רישיות שגויה (E) ⇒ default (במקרה זה גם ברירת-המחדל) |
| `'anytoany'` | `SizeMatch.exactSame` | רישיות שגויה ⇒ default |
| `'tableLookup '` | `SizeMatch.exactSame` | רווח-נוסף ⇒ default |
| `'foo'` | `SizeMatch.exactSame` | לא-מוכר ⇒ default |
| `5` | `SizeMatch.exactSame` | לא-String ⇒ אף name לא שווה ל-int ⇒ default |
| `true` | `SizeMatch.exactSame` | לא-String ⇒ default |

## DoD
```
dart run --enable-asserts new/dart/size_match_from_test.dart  ⇒ exit 0 + "OK sizeMatchFrom: N asserts passed"
```
