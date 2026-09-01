# חוזה · `canConnectResolver` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/connection_resolver.dart:211-222`
(‏`ConnectionResolver.canConnect`; תיעוד-ההתנהגות: ‏:200-210; ‏`_noRule`: ‏:197-198).
⚠️ הקובץ אינו בעץ-העבודה של buildsmart (אין `lib/domain/` בענף הנוכחי) — חולץ verbatim
מ-git (‏commit ‏b4cdcefd ≡ ‏origin/claude/align-main, ‏md5 ‏0b34f3fa… — זהה לעוגן של
האטומים-האחים `end_pair` / `end_pair_memoized`).

הכרעת-הקידום (טיוטה-"קשה", **מסלול 4 + מסלול 1**):
- **מסלול 4 — התנגשות-שם:** ‏`can_connect.dart` כבר קיים ב-new/dart אך גופו שונה-מהותית —
  זהו `install_engine.dart:498-521` (‏bool, ‏name-inference: גדלים/מגדר/שיטה). הטיוטה כאן
  היא ה-`canConnect` של **ה-resolver מונחה-החוקות** (‏ConnectResult, איטרציית-ends) —
  התנהגות אחרת ⇒ שם-מובחן-לפי-דומיין: **`can_connect_resolver`**. לא-כפול, לא-דריסה.
- **מסלול 1 — שכנים ⇒ שקעים** (חוק-1/3, דיבר-3):
  - `_endPairMemoized(endA, endB)` (‏:215) ⇒ שקע `endPairMemoized` — מעריך-הזוג-הממוטמן
    של הקופסה (האטום-האח `end_pair_memoized.dart` העוטף את `end_pair.dart`).
  - `_noRule` (‏:197-198, ‏const ‏`ConnectResult(mates:false, methodLabelHe:'')`) ⇒ שקע
    `noRule` — הערך מוזרק (גנרי `R` אינו יכול לשאת const-ברירת-מחדל; הקופסה מזריקה).
  - `a.ends` / `b.ends` (‏ProductConnectorSpec) ⇒ שקע-ריאדר גנרי `ends`
    (התקדים: `end_pair_memoized.dart` · ריאדרים גנריים, אפס הטבעת-טיפוס).
  - `r.mates` / `r.severity != null` (‏:216-217) ⇒ שקעי-ריאדר `mates` / `hasMissSeverity`
    — ‏`R` נשאר גנרי; בקופסה ‏R=ConnectResult ‏(mates ⇒ ‏r.mates, ‏hasMissSeverity ⇒
    ‏r.severity != null).

## חתימה
```dart
R canConnectResolver<S, E, R>(S a, S b, {
  required List<E> Function(S) ends,               // שקע-ריאדר: spec.ends
  required R Function(E endA, E endB) endPairMemoized, // שקע-שכן: _endPairMemoized
  required bool Function(R) mates,                 // שקע-ריאדר: r.mates
  required bool Function(R) hasMissSeverity,       // שקע-ריאדר: r.severity != null
  required R noRule,                               // שקע-ערך: _noRule (:197-198)
})
```

## התנהגות (עוגני-שורה — verbatim ‏:212-221)
- `connection_resolver.dart:213-214` — סדר-האיטרציה הוא החוזה: ‏`a.ends` חיצוני (בסדר),
  ‏`b.ends` פנימי (בסדר) — הכללה מדויקת של ה-legacy ‏`connectionMethodLabel`
  (‏install_engine.dart:90-109; תיעוד ‏:202-205).
- `connection_resolver.dart:215-216` — כל זוג מוערך דרך `_endPairMemoized`; התוצאה
  ה**ראשונה** עם ‏`mates == true` מנצחת ומוחזרת **מיד** (זוגות שאחריה לא מוערכים כלל).
- `connection_resolver.dart:217` — ‏size-miss ראשון (‏`severity != null`) נלכד ל-`firstMiss`
  פעם-אחת בלבד (‏`firstMiss == null &&`); ‏miss-ים מאוחרים אינם דורסים אותו.
- `connection_resolver.dart:220` — אף זוג לא חיבר ⇒ מוחזר `firstMiss ?? noRule` —
  ה-miss-הראשון אם היה, אחרת ‏`noRule` ("לא מתחבר" מתועד, לעולם-לא-חריגה; ‏:207-209).
- ‏ends ריק בכל צד ⇒ אפס איטרציות ⇒ ‏`noRule`, ‏`endPairMemoized` לא נקרא כלל
  ("Products with no ends therefore simply don't connect" — ‏:209-210).
- דטרמיניזם (‏:12-17): אפס אקראיות/‏DateTime/‏I/O — אותו קלט ⇒ אותו פלט.

## דוגמאות מספריות (a.ends=[a1,a2] · b.ends=[b1,b2] ⇒ סדר-זוגות: a1b1,a1b2,a2b1,a2b2)
| # | תוצאות-הזוגות (לפי הסדר) | פלט | קריאות-endPairMemoized |
|---|--------------------------|------|------------------------|
| 1 | a1b1=noMatch · a1b2=**mate** | תוצאת-a1b2 (זהות-אובייקט) | 2 בלבד — a2b1/a2b2 לא הוערכו |
| 2 | a1b1=miss(sev) · a1b2=**mate** | ה-mate — ‏miss קודם אינו חוסם | 2 |
| 3 | a1b1=noMatch · a1b2=miss₁ · a2b1=miss₂ · a2b2=noMatch | **miss₁** (הראשון-עם-severity, זהות-אובייקט) | 4 — סריקה מלאה |
| 4 | כל-הזוגות noMatch (‏severity=null) | ‏`noRule` המוזרק (זהות-אובייקט) | 4 |
| 5 | ‏a.ends=[] (או b.ends=[]) | ‏`noRule` | **0** |

## DoD (פקודה+פלט-צפוי — דיבר 12; נרשם לפני הקוד)
```
dart run --enable-asserts new/dart/can_connect_resolver_test.dart  ⇒ exit 0 + "OK canConnectResolver: N asserts passed"
```
