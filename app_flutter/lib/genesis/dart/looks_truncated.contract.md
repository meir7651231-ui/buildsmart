# חוזה · `looksTruncated` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:334-357`
(‏`_looksTruncated`, private-במקור). קודם לפונקציה top-level ציבורית `looksTruncated`.

## חתימה
```dart
bool looksTruncated(String candidate)
```

## קלט
- `candidate` — טקסט JSON-י מועמד (למשל תשובת-מודל שעלולה להיחתך באמצע-סטרימינג).

## פלט / התנהגות (עוגני-שורה)
- `:335-337` — מונים `depth=0`, דגלים `inString=false`, `escaped=false`.
- `:338-357` — סריקת `candidate.runes`:
  - בתוך-מחרוזת (‏`inString`): `escaped` ⇒ מאפס-escaping; `\` (0x5C) ⇒ מדליק escaping;
    `"` (0x22) ⇒ סוגר-מחרוזת. שאר-התווים (כולל `{`/`[`) — מדולגים (‏`continue`), אינם משנים עומק.
  - מחוץ-למחרוזת: `"` ⇒ פותח-מחרוזת; `{`(0x7B)/`[`(0x5B) ⇒ `depth++`; `}`(0x7D)/`]`(0x5D) ⇒ `depth--`.
- `:356` — מחזיר `inString || depth > 0` (נותרנו-בתוך-מחרוזת או עומק-חיובי).
- ⚠️ נאמנות-מקור: אין בדיקת-איזון-סוגים (‏`{` שנסגר ב-`]` עדיין מאפס עומק); `depth` שלילי (עודף-סוגר)
  ⇒ `depth > 0` שקר ⇒ מוחזר `false`.

## דוגמאות מספריות
| # | candidate | ⇒ | סיבה |
|---|-----------|---|------|
| 1 | `'{"a":1}'` | `false` | מאוזן, לא-בתוך-מחרוזת |
| 2 | `'{"a":1'` | `true` | ‏depth=1>0 בסוף |
| 3 | `'{"a":"unterminated'` | `true` | ‏inString בסוף |
| 4 | `'[]'` | `false` | מאוזן |
| 5 | `'[{'` | `true` | ‏depth=2 |
| 6 | `r'{"p":"a\"b"}'` | `false` | המרכאות המוברחות אינן סוגרות מחרוזת |
| 7 | `'{"k":"[{"}'` | `false` | ‏`[`/`{` בתוך-מחרוזת אינם מגדילים עומק |
| 8 | `''` | `false` | ריק |
| 9 | `'}'` | `false` | ‏depth=-1, אך `>0` שקר (נאמנות-מקור) |

## שקעים
- אין. `candidate` = פרמטר-נתון; `String.runes` — שפה/סטנדרט.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/looks_truncated_test.dart  ⇒ exit 0 + "OK looksTruncated: N asserts passed"
```
