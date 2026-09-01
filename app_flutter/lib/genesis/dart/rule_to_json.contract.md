# חוזה · `rule_to_json` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/rules_model.dart`
(‏`RuleCondition` ‏:214-249 · `Rule` ‏:254-295).
⚠️ **עוגן-ענף:** הקובץ **אינו קיים על ה-checkout המקומי** של buildsmart — חולץ מ-
`claude/align-main` ≡ `origin/claude/whats-happening-LyY9G` (הקומיט המקורי
`6e23aa4c` — "Pillar-4 step 84"; md5 ‏`a174aec58f6915096b2c880900849a4d`).

הכרעת-הקידום-הקשה: **הכרעה 2 (⚛️ הטבעת-טיפוס) + הכרעה 4 (🏷️ שם-מובחן)** —
- ⚛️ 2 מחלקות-המודל הוטבעו מינימלית-verbatim בקובץ-האטום: `RuleCondition`
  (‏:214-249) · `Rule` (‏:254-295) — שדות + בנאי + `toJson` + `fromJson` +
  `==`/`hashCode`. ‏`identical`/`Object.hash` = ‏dart:core (מותר, חוק-1);
  ‏`@immutable` הושמט — אפס-import (תקדים `end_pair`/`connection_schema_to_json`).
- ⚡ הגטר `Rule.isMutating` (‏:270) הוא קריאה-לשכן `ruleActionIsMutating`
  (‏:167-172) ⇒ **הוצא מהאטום** (חוק-3: חוט לא מייבא חוט); הוא כבר קיים כאטום
  `rule_action_is_mutating`, והחיבור `rule.action ⇒ mutating?` = חיווט-קופסה.
- 🏷️ שם-הטיוטה `to_json` גנרי ⇒ `rule_to_json`. **לא skip-dup:** הטענה בחוזה-האח
  `connection_schema_to_json` ("הטיוטה קודמה כ-config_ops_to_json") נבדקה מול
  ביטים ונמצאה שגויה — `config_ops_to_json` מקורו ב-`config_op.dart:109-111`,
  ואף אטום ב-new/dart אינו נושא את קודק ה-`Rule`/`RuleCondition`.

## חתימה
```dart
// מתודות-מופע verbatim על המחלקות המוטבעות:
Map<String, dynamic> RuleCondition.toJson()
factory RuleCondition.fromJson(Map<String, dynamic> j)
Map<String, dynamic> Rule.toJson()
factory Rule.fromJson(Map<String, dynamic> j)
// + שוויון-ערכי ו-hashCode על שתיהן.
```

## קלט
- `toJson` — מופע בנוי (`RuleCondition(field, op, value)` · `Rule(trigger,
  condition, action)`); `value` הוא `num` (int או double).
- `fromJson` — `Map<String, dynamic>` **אמין** (persistence/round-trip §10).
  קלט-מודל לא-אמין עובר דרך האטום `parse_rule` — לא דרך כאן.

## פלט / התנהגות (עוגני-שורה)
- ‏`:230-231` — `RuleCondition.toJson`: תמיד **בדיוק 3 מפתחות**, בסדר
  `field, op, value`; ‏`value` עובר כ-num כמות-שהוא (int נשאר int, double נשאר double).
- ‏`:272-276` — `Rule.toJson`: תמיד **בדיוק 3 מפתחות**, בסדר
  `trigger, condition, action`; ‏`condition` = המפה המקוננת של
  `condition.toJson()` (‏:274 — קינון בתוך-האטום, כמו ProductEnd בתקדים).
- ‏`:233-237` — `RuleCondition.fromJson`: casts קשיחים verbatim
  (`as String`/`as num`): מפתח-חסר או טיפוס-שגוי ⇒ **זורק TypeError** — במכוון
  (המקור לא מגן; הפרסר-הטוטאלי הוא `parseRule` ‏:308).
- ‏`:278-283` — `Rule.fromJson`: ‏`(j['condition'] as Map).cast<String, dynamic>()`
  — מקבל גם `Map<dynamic, dynamic>` (פלט-`jsonDecode` טיפוסי) ומקסט; ‏condition
  לא-Map ⇒ זורק.
- ‏`:239-248, :285-294` — שוויון-ערכי: `identical` קיצור-דרך; אחרת השוואת כל
  השדות (ב-`Rule` — `condition` בשוויון-הערכי של `RuleCondition`);
  ‏`hashCode = Object.hash(<השדות>)` ⇒ שווים ⇒ hash שווה.
- **Round-trip:** ‏`fromJson(toJson(x)) == x` לשתי המחלקות.
- TOTAL בכיוון-הסריאליזציה — `toJson` לעולם לא זורק, אפס-mutation.

## דוגמאות מספריות
| # | פעולה | פלט |
|---|------|------|
| 1 | `RuleCondition(field:'ageDays', op:'>', value:2).toJson()` | `{field:'ageDays', op:'>', value:2}` — בדיוק 3, בסדר-המקור |
| 2 | `RuleCondition(field:'sum', op:'>=', value:1000.5).toJson()` | `{field:'sum', op:'>=', value:1000.5}` — double נשמר |
| 3 | `Rule(trigger:'order.stuck', condition:#1, action:'notify.manager').toJson()` | `{trigger:'order.stuck', condition:{field:'ageDays', op:'>', value:2}, action:'notify.manager'}` — קינון |
| 4 | `RuleCondition.fromJson(#1-map)` | ‏`== RuleCondition('ageDays','>',2)` (round-trip) |
| 5 | `Rule.fromJson(#3-map)` — גם כש-condition הוא `Map<dynamic,dynamic>` | ‏`== ` המקור (round-trip + cast) |
| 6 | `RuleCondition.fromJson({field:'sum', op:'<'})` (value חסר) | **זורק** TypeError (cast verbatim) |
| 7 | `Rule.fromJson({trigger:'t', condition:'לא-מפה', action:'a'})` | **זורק** (‏as Map) |
| 8 | שוויון: שני מופעים שווי-שדות | `==` אמת · `hashCode` שווה; שינוי שדה-אחד ⇒ `!=` |

## שקעים
אין קריאות-חוץ באטום: `identical`/`Object.hash` = dart:core. השכן היחיד של
המקור — `ruleActionIsMutating` (הגטר `isMutating` ‏:270) — הוצא ומחווט בקופסה
מהאטום `rule_action_is_mutating`. הדאטה (כללים) מוזרקת כמופעים — אפס-צריבה.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/rule_to_json_test.dart  ⇒ exit 0 + "OK ruleToJson: N asserts passed"
```
