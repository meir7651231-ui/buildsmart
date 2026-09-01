# חוזה · edgeCost

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_engine.dart:683-729`
**אטום:** `new/dart/edge_cost.dart` — `int edgeCost(EdgeNode a, EdgeNode b, {verifiedSpec, minBoreMm, directMates, isFitting})`

## קלט
- `a`, `b` — `EdgeNode`: `sku` (String) · `categoryHe` (String).
- `verifiedSpec` — שקע `SpecView? Function(String sku)` — היה `kVerifiedSpecs[sku]` (:684-685). `SpecView`= `material` (String) + `ends` (List&lt;EndPart&gt;). ברירת-מחדל null.
- `minBoreMm` — שקע `double? Function(String sku)` — היה `_minBoreMmOf(b)` (:722; הגדרה :656-681). ברירת-מחדל null.
- `directMates` — שקע `bool Function(EndPart a, EndPart b)` — היה `eA.directMatesWith(eB)` (:707). ברירת-מחדל = verbatim הכלל מ-lipskey_verified_connections.dart:38-48.
- `isFitting` — שקע `bool Function(String categoryHe)` — היה `isFitting(b)` (:727; הגדרה :622). ברירת-מחדל = חברות ב-`_fittingCats` (:615-620).
- `EndPart` — `type` (שם-EndType כמחרוזת) · `size` (String).

## פלט
`int` = `10 + deviceFiller + transition + pipeBridge + boreCost` (:728).

## התנהגות (עוגני-שורה למקור)
1. **transition** (:689-696): `ma==null||mb==null||ma==mb` ⇒ 0; שניהם ב-`_drainageFamily`{PVC,PP,רב-שכבתי,ceramic} ⇒ 1 (:693); אחרת 4 (:695).
2. **pipeBridge** (:702-715): ברירת-מחדל 2; אם לשני-הצדדים spec ומצא קצה מתאים-ישירות ⇒ 0 (:707-710); אם לפחות-לאחד אין spec ⇒ 0 (:714).
3. **boreCost** (:722-725): `bore==null || bore>=15` ⇒ 0; אחרת `(15-bore).round().clamp(0,10)`.
4. **deviceFiller** (:727): `isFitting(b.categoryHe)` ⇒ 0, אחרת 50.

## דוגמאות מספריות (מוכחות ב-edge_cost_test.dart)
| # | a·b (material · ends · cat · bore) | 10 + dev + trans + bridge + bore | פלט | עוגן |
|---|---|---|---|---|
| 1 | פליז bspMale½ · פליז bspFemale½ · fitting · 15 | 10+0+0+0+0 | 10 | :707,722,727 |
| 2 | פליז bspMale½ · HDPE hdpe16 · ברזי-כיור · 10 | 10+50+4+2+5 | 71 | :695,702,725,727 |
| 3 | PP drain50 · PVC drain50 · fitting · null | 10+0+1+0+0 | 11 | :693,707 |
| 4 | אין-spec · אין-spec · אסלות(לא-fitting) · null | 10+50+0+0+0 | 60 | :714,727 |
| 5 | אין-spec · אין-spec · צינורות(fitting) · null | 10+0+0+0+0 | 10 | :727 |
| 6 | פליז(spec) · אין-spec · ברזי-כיור · null | 10+50+0+0+0 | 60 | :690,714 |

## עדשה-עוינת
- material-null (צד ללא-spec) ⇒ transition 0, **לא** 4 (#6 מול #2) — הזוג הלא-מאומת "חינם" במעבר.
- pipeBridge: `hdpeCompression↔hdpeCompression` **אינו** direct-mate (מטופל ב-pipeShared, לא ב-directMatesWith) ⇒ נשאר 2 (#2).
- boreCost נחתך ל-10 ולעולם ≥0; bore==null זהה ל-bore≥15 (0).
- deviceFiller בודק את **b** בלבד (יעד-הקשת), לא a (#4 מול #5).
