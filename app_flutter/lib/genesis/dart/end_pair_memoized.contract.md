# חוזה · `endPairMemoized` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/connection_resolver.dart:223-227`
(‏`ConnectionResolver._endPairMemoized`; תיעוד-המֶמו: ‏:178-183). ⚠️ הקובץ אינו בעץ-העבודה
של buildsmart (אין `lib/domain/` בענף הנוכחי) — חולץ verbatim מ-git, ענף `claude/align-main`
(וזהה בעשרות ענפי-origin).

הכרעת-הקידום (טיוטה-"קשה", מסלול 1 — 🔌 שכן/סטייט ⇒ שקע):
- הקריאה-לשכן `_endPair(endA, endB)` (‏:226) ⇒ שקע `endPair` (חוק-1/3, דיבר-3).
- סטייט-המחלקה `_memo` (‏:183 — `Map<String, ConnectResult>`) ⇒ שקע `memo` מוזרק;
  הסטייט חי אצל הקופסה, לא באטום (חוק-5 — אפס ידע-הקשר).
- שדות `ProductEnd.connectorTypeId` / `.sizeValue` ⇒ שקעי-ריאדר גנריים
  (התקדים: `estimate_price.dart` · `categoryHe`) — אפס הטבעת-טיפוס, `E`/`R` גנריים.

## חתימה
```dart
R endPairMemoized<E, R>(E endA, E endB, {
  required String Function(E) connectorTypeId,   // שקע-ריאדר: end.connectorTypeId
  required String Function(E) sizeValue,          // שקע-ריאדר: end.sizeValue (RAW!)
  required Map<String, R> memo,                   // שקע-סטייט: _memo של הקופסה
  required R Function(E endA, E endB) endPair,    // שקע-שכן: ConnectionResolver._endPair
})
```

## התנהגות (עוגני-שורה)
- `connection_resolver.dart:224-225` — המפתח:
  `'${endA.connectorTypeId}|${endA.sizeValue}|${endB.connectorTypeId}|${endB.sizeValue}'`
  — צירוף-מחרוזות נאיבי ב-`|`, **ערכי-גודל RAW לא-מנורמלים** (‏:179-181: הנרמול קורה
  בתוך ההערכה, לא במפתח — `'1/2'` ו-`'1/2"'` הם **מפתחות שונים**).
- `connection_resolver.dart:226` — `memo.putIfAbsent(key, () => endPair(endA, endB))`:
  מפתח חסר ⇒ מחשבים פעם-אחת ושומרים; מפתח קיים ⇒ **endPair לא נקרא**, מוחזר הערך השמור.
- כיווניות נשמרת במפתח: ‏(A,B) ו-(B,A) — מפתחות שונים, שני חישובים.
- דטרמיניזם (‏:16, :181-183): ההערכה טהורה ⇒ ערך-מהמטמון בלתי-ניתן-להבחנה מחישוב-טרי;
  האטום עצמו לא מניח זאת — הוא רק מיישם putIfAbsent verbatim.

## דוגמאות מספריות
| # | קריאה | memo לפני | endPair נקרא? | מפתח |
|---|-------|-----------|---------------|------|
| 1 | (t1·'1/2', t2·'3/4') | ריק | כן (פעם-1) | `t1\|1/2\|t2\|3/4` |
| 2 | אותו זוג שוב | יש מפתח | **לא** | אותו מפתח, ערך שמור |
| 3 | (t1·'1/2"', t2·'3/4') | יש `t1\|1/2\|…` | כן | `t1\|1/2"\|t2\|3/4` — RAW, מפתח חדש |
| 4 | (t2·'3/4', t1·'1/2') | יש forward | כן | `t2\|3/4\|t1\|1/2` — כיוון הפוך = מפתח אחר |
| 5 | end-אחר עם אותם 4 שדות | יש מפתח | **לא** | המפתח מזהה את הזוג, לא את האובייקט |

## DoD (פקודה+פלט-צפוי — דיבר 12; נרשם לפני הקוד)
```
dart run --enable-asserts new/dart/end_pair_memoized_test.dart  ⇒ exit 0 + "OK endPairMemoized: N asserts passed"
```
