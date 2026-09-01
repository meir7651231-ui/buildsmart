# חוזה · `endPair` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/connection_resolver.dart:239-302`
(‏`ConnectionResolver._endPair` ‏:239-266 + עוזרו `_sizeOk` ‏:277-302).
⚠️ **עוגן-ענף:** הקובץ **אינו קיים על main** של buildsmart — חולץ מ-
`origin/claude/align-main` ≡ `origin/claude/whats-happening-LyY9G` (md5 זהה
`0b34f3fae4a39f20804d4fd0790ed9b3` — ענף-העבודה החי של app_flutter).

הכרעת-הקידום-הקשה: **שילוב 1+2** —
- ⚛️ 4 טיפוסי-סכמה הוטבעו מינימלית-verbatim מ-`connection_schema.dart` (אותו ענף):
  `SizeMatch` (‏:23) · `RuleSeverity` (‏:27) · `ProductEnd` (‏:146-168, שני שדות-הקריאה) ·
  `CompatibilityRule` (‏:240-277, רק 7 שדות-הקריאה). ‏`ConnectResult` הוטבע verbatim
  מ-`connection_resolver.dart:49-83` (‏@immutable הושמט — אפס-import באטום).
- 🔌 שני שקעים: `rules` (שדה-המופע `ConnectionResolver.rules` ‏:170 ⇒ פרמטר) ·
  `normalizeSize` (שכן top-level ‏:31 ⇒ שקע-פונקציה; במקור: הסרת כל `"` + trim).

## חתימה
```dart
ConnectResult endPair(ProductEnd endA, ProductEnd endB, {
  required List<CompatibilityRule> rules,
  required String Function(String) normalizeSize,
})
// ConnectResult { bool mates; String methodLabelHe; RuleSeverity? severity; CompatibilityRule? rule; }
```

## קלט
- `endA`, `endB` — קצוות-מוצר: `connectorTypeId` + `sizeValue`.
- `rules` — **שקע**: חוקות-ההתאמה; נסרקות בסדר-הרשימה (authored order = שובר-שוויון דטרמיניסטי).
- `normalizeSize` — **שקע**: נירמול-גודל; **כל** ההשוואות עוברות דרכו (exactSame וגם תאי-הטבלה).

## פלט / התנהגות (עוגני-שורה — טבלת-ההכרעה `connection_resolver.dart:36-42`)
- ‏`:242-246` — התאמת-זוג: FORWARD = ‏`aTypeId==endA.type && bTypeId==endB.type`;
  ‏REVERSE = ה-ids בהיפוך (רק אם לא-forward — חוקת-same-type נתפסת forward).
- ‏`:247` — לא-forward ולא-reverse ⇒ ממשיכים לחוקה הבאה.
- ‏`:248-254` — החוקה הראשונה שמתאימה-לזוג **וגם** עוברת-גודל ⇒
  `ConnectResult(mates:true, methodLabelHe:rule.methodLabelHe, rule:rule, severity:null)`.
- ‏`:255` — התאמת-זוג שנכשלה-בגודל **אינה עוצרת** את הסריקה; ה-miss ה-**ראשון** נשמר (`??=`).
- ‏`:257-264` — אף חוקה לא חיברה אך היה miss ⇒
  `(mates:false, methodLabelHe:'', severity:firstMiss.onMismatch, rule:firstMiss)`.
- ‏`:265` — אף חוקה לא כיסתה את זוג-הטיפוסים ⇒ `_noRule` =
  `(mates:false, methodLabelHe:'', severity:null, rule:null)` — "לא מתחבר" מתועד, לא-חריגה.
- ‏`_sizeOk` ‏`:283-301`: ‏exactSame ⇒ `normalizeSize(a)==normalizeSize(b)` ·
  ‏anyToAny ⇒ `true` תמיד · tableLookup ⇒ שורות `[aSize,bSize]` באוריינטציית
  ‏`(aTypeId,bTypeId)` **המוצהרת** של החוקה (‏:270-276): הצד שמגלם `aTypeId` מספק
  עמודה 0 — ‏forward ⇒ `[endA,endB]`, ‏reverse ⇒ `[endB,endA]`; שורה קצרה מ-2
  מדולגת (‏:294); טבלה-`null` תחת tableLookup ⇒ לעולם לא מתאימה (‏:290).

## דוגמאות מספריות (‏normalizeSize מוזרק = המקור: `s.replaceAll('"','').trim()`)
| # | rules | endA | endB | mates | label | severity | rule |
|---|-------|------|------|-------|-------|----------|------|
| 1 | pex×pex exactSame 'הברגה' | pex `'1/2'` | pex `'1/2"'` | true | `'הברגה'` | null | R1 |
| 2 | pex×cu exactSame 'לחיצה' | cu `'3/4'` | pex `'3/4'` | true (reverse) | `'לחיצה'` | null | R1 |
| 3 | pex×cu … | pvc `'1/2'` | pex `'1/2'` | false | `''` | **null** | **null** (no-rule) |
| 4 | pex×pex exactSame (critical) | pex `'1/2'` | pex `'3/4'` | false | `''` | critical | R1 (size-miss) |
| 5 | R1 miss ‎+‎ R2 pex×pex anyToAny 'מצמד' | pex `'1/2'` | pex `'3/4'` | true | `'מצמד'` | null | **R2** (הסריקה ממשיכה) |
| 6 | R1 miss(warning) + R2 miss(info) | pex `'1/2'` | pex `'3/4'` | false | `''` | **warning** | **R1** (ה-miss הראשון) |
| 7 | dn×od tableLookup ‎[['1/2','3/4']]‎ | dn `'1/2'` | od `'3/4"'` | true | — | null | R1 (forward, נירמול-תא) |
| 8 | אותה חוקה | od `'3/4'` | dn `'1/2'` | true | — | null | R1 (reverse ⇒ ‎[endB,endA]‎) |
| 9 | אותה חוקה | dn `'3/4'` | od `'1/2'` | false | `''` | warning | R1 (אוריינטציה לא-סימטרית) |
| 10 | tableLookup sizeTable:null | dn `'1/2'` | od `'1/2'` | false | `''` | warning | R1 (טבלה-null) |
| 11 | tableLookup ‎[['1/2'],['1/2','1/2']]‎ | dn `'1/2'` | od `'1/2'` | true | — | null | R1 (שורה-קצרה מדולגת) |
| 12 | `rules: []` | כלשהו | כלשהו | false | `''` | null | null (_noRule) |
| 13 | R1+R2 שתיהן מחברות | — | — | true | של-**R1** | null | R1 (סדר-הרשימה מכריע) |

## שקעים
- `rules` — הזרקת-דאטה (חוק-1): החוקות המחוברות חיות בקופסה/דאטה, לא באטום.
- `normalizeSize` — הזרקת-שכן (חוק-3): הגולדן מזריק את מימוש-המקור ומאמת גם
  נירמול-`"` בקצוות **וגם** בתאי-הטבלה.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/end_pair_test.dart  ⇒ exit 0 + "OK endPair: N asserts passed"
```
