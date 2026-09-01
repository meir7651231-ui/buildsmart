# חוזה · `connection_schema_to_json` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/connection_schema.dart`
(‏`ProductEnd.toJson` ‏:157-158 · `ProductConnectorSpec.toJson` ‏:206-214 ·
`CompatibilityRule.toJson` ‏:279-291 · `CompletionRule.toJson` ‏:356-367).
⚠️ **עוגן-ענף:** הקובץ **אינו קיים על main** של buildsmart — חולץ מ-
`origin/claude/align-main` ≡ `origin/claude/whats-happening-LyY9G` (md5 זהה
`8e0a2620a74c57fe8ec5cdd8af764f2f` — ענף-העבודה החי של app_flutter).

הכרעת-הקידום-הקשה: **הכרעה 2 (⚛️ הטבעת-טיפוס) + הכרעה 4 (🏷️ שם-מובחן)** —
- ⚛️ 4 מחלקות-הסכמה + 2 enums הוטבעו מינימלית-verbatim בקובץ-האטום:
  `SizeMatch` (‏:23) · `RuleSeverity` (‏:27) · `ProductEnd` (‏:146-158) ·
  `ProductConnectorSpec` (‏:170-214) · `CompatibilityRule` (‏:240-291) ·
  `CompletionRule` (‏:322-367) — שדות + בנאי + `toJson` בלבד. ‏`fromJson`
  (עוזריו כבר אטומים: `size_match_from`/`size_table`/`num_map`/`str_list_or_null`)
  ו-`==`/`hashCode` (תלויי `listEquals`/`mapEquals` של flutter) **אינם** חלק
  מהאטום-הזה — קידוד-לאחור ושוויון חיים באטומים/קופסה אחרים. ‏`@immutable`
  הושמט — אפס-import באטום (תקדים `end_pair`).
- 🏷️ שם-הטיוטה `to_json` גנרי ומתנגש-מושגית (טיוטת `to_json@…studio_rules_model`
  קודמה כ-`config_ops_to_json`) ⇒ שם-מובחן-דומיין: `connection_schema_to_json`.

## חתימה
```dart
// ‏toJson מתודות-מופע verbatim על המחלקות המוטבעות:
Map<String, dynamic> ProductEnd.toJson()
Map<String, dynamic> ProductConnectorSpec.toJson()
Map<String, dynamic> CompatibilityRule.toJson()
Map<String, dynamic> CompletionRule.toJson()
```

## קלט
מופע בנוי של אחת מ-4 מחלקות-הסכמה (כל השדות כמו במקור; ברירות-מחדל verbatim:
‏`ends=[]` · `envelope={}` · `onMismatch=RuleSeverity.warning` ·
`severity=RuleSeverity.warning`).

## פלט / התנהגות (עוגני-שורה)
- ‏`:157-158` — `ProductEnd`: תמיד בדיוק 2 מפתחות, בסדר
  `connectorTypeId, sizeValue`.
- ‏`:206-214` — `ProductConnectorSpec`: מפתחות-חובה תמיד-נוכחים
  `productSku, tradeId, ends, envelope` (‏`ends`/`envelope` נוכחים **גם כשריקים**);
  ‏`ends` = רשימת `ProductEnd.toJson()` מקוננת (‏:209, סדר-נשמר);
  מפתח-אופציונלי נכתב **רק כשאינו null** (‏collection-if): `materialId` (:210) ·
  `ratingHe` (:211) · `materialGroupId` (:213). סדר-המפתחות = סדר-המקור.
- ‏`:279-291` — `CompatibilityRule`: תמיד-נוכחים
  `id, tradeId, aTypeId, bTypeId, sizeMatch, methodLabelHe, onMismatch`;
  ‏enum ⇒ **`.name`** (מחרוזת: `'exactSame'|'anyToAny'|'tableLookup'` ·
  `'info'|'warning'|'critical'`; ‏:284, :287); `sizeTable` רק כש-לא-null (‏:286 —
  הרשימה-המקוננת עוברת כמות-שהיא); `materialGroup` (:288) ·
  `incompatibleMaterialGroups` (:289-290) רק כש-לא-null.
- ‏`:356-367` — `CompletionRule`: תמיד-נוכחים
  `id, tradeId, whenInLineHasTypeId, requireTypeId, whyHe, severity`
  (‏`severity` ⇒ `.name`; ‏:362); `incompatibleMaterialGroups` (:363-364) ·
  `requiredInterposerWhyHe` (:365-366) רק כש-לא-null.
- TOTAL — אף מתודה אינה זורקת; אין mutation של המופע.

## דוגמאות מספריות
| # | מופע | פלט |
|---|------|------|
| 1 | `ProductEnd(connectorTypeId:'pex', sizeValue:'1/2')` | `{connectorTypeId:'pex', sizeValue:'1/2'}` |
| 2 | `ProductConnectorSpec(productSku:'P-1', tradeId:'plumbing')` (הכול-ברירת-מחדל) | `{productSku:'P-1', tradeId:'plumbing', ends:[], envelope:{}}` — **בדיוק 4 מפתחות**, אפס-null |
| 3 | ספק מלא: 2 ends (pex 1/2 · cu 3/4), materialId:'pex', ratingHe:'PN10', envelope:{maxTempC:40}, materialGroupId:'plastic' | 7 מפתחות בסדר-המקור; `ends:[{connectorTypeId:'pex',sizeValue:'1/2'},{connectorTypeId:'cu',sizeValue:'3/4'}]` |
| 4 | `CompatibilityRule(id:'R1', tradeId:'plumbing', aTypeId:'pex', bTypeId:'pex', sizeMatch:exactSame, methodLabelHe:'הברגה')` | `{id:'R1', tradeId:'plumbing', aTypeId:'pex', bTypeId:'pex', sizeMatch:'exactSame', methodLabelHe:'הברגה', onMismatch:'warning'}` — בדיוק 7 |
| 5 | חוקה מלאה: tableLookup, sizeTable:[['1/2','3/4']], onMismatch:critical, materialGroup:'metal', incompatibleMaterialGroups:['plastic'] | ‏+3 מפתחות: `sizeMatch:'tableLookup'` · `sizeTable:[['1/2','3/4']]` · `onMismatch:'critical'` |
| 6 | `CompletionRule(id:'C1', tradeId:'plumbing', whenInLineHasTypeId:'boiler', requireTypeId:'safety-valve', whyHe:'חובה')` | `{id:'C1', tradeId:'plumbing', whenInLineHasTypeId:'boiler', requireTypeId:'safety-valve', whyHe:'חובה', severity:'warning'}` — בדיוק 6 |
| 7 | השלמה מלאה: severity:info, incompatibleMaterialGroups:['iron'], requiredInterposerWhyHe:'נתק דיאלקטרי' | ‏+2 מפתחות, `severity:'info'` |

## שקעים
אין קריאות-חוץ: `Object.hash`/`hashAll` שסומנו-במחצבה שייכים ל-`==`/`hashCode`
שהושארו-בחוץ; `toJson` המקונן (‏:209) הוא בתוך-האטום (ProductEnd המוטבע).
הדאטה (חוקות/ספקים) מוזרקת כמופעים — לעולם לא צרובה באטום.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/connection_schema_to_json_test.dart  ⇒ exit 0 + "OK connectionSchemaToJson: N asserts passed"
```
