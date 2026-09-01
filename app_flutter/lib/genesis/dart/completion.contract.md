# חוזה · `completion` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/connection_resolver.dart:320-386` (מתודת `completion`).

## תפקיד
בודק "שלמות-קו" מול חוקי-השלמה ומחזיר רשימת-issues: (1) צורת-חומר — ≥2 קבוצות-חומר בלתי-תואמות נוכחות בקו; (2) צורת-טיפוס — קיים type-מפעיל אך חסר ה-type-הנדרש.

## חתימה
```dart
List<CompletionIssue> completion(List<ProductConnectorSpec> line, {required List<CompletionRule> rules})
// ProductConnectorSpec{productSku, materialGroupId?, ends:[ConnectorEnd{connectorTypeId}]}
// CompletionRule{whyHe, severity, whenInLineHasTypeId, requireTypeId, incompatibleMaterialGroups?, requiredInterposerWhyHe?}
// CompletionIssue{rule, whyHe, severity, offendingSkus} — כולם מוטבעים (severity=String)
```

## התנהגות (עוגן connection_resolver.dart:320-386)
`presentGroups` = כל ה-materialGroupId הלא-null בקו. לכל rule:
- **(1) MATERIAL** — אם `incompatibleMaterialGroups` לא-ריק: `hit` = החיתוך עם presentGroups; `hit.length>=2` ⇒ issue עם `whyHe = requiredInterposerWhyHe ?? whyHe`, `severity`, ו-`offendingSkus` = ה-sku של כל spec ש-materialGroupId שלו ב-hit (בסדר-הקו).
- **(2) TYPE** — אם `whenInLineHasTypeId` לא-ריק: `triggerSkus` = sku של כל spec עם end ש-connectorTypeId==whenInLineHasTypeId; אם לא-ריק ו-אין spec עם end ש-connectorTypeId==requireTypeId ⇒ issue עם `whyHe`, `severity`, `offendingSkus = triggerSkus`.

## שקעים
- `rules` — במקור שדה-מופע `completionRules` ⇒ שקע.
- severity — מאוחסן בלבד (לא-מסועף באטום) ⇒ String.

## דוגמאות-מחייבות (matRule: groups=[copper,pex], severity=error; typeRule: when=hot, require=mixer, severity=warn)
| # | line | rules | ⇒ |
|---|------|-------|---|
| 1 | P1(copper,hot), P2(pex) | [matRule interposer='נדרש מתאם'] | 1 issue · whyHe='נדרש מתאם' · error · skus=[P1,P2] |
| 2 | P1(copper,hot) | [matRule] | [] (‏hit<2) |
| 3 | P1,P2 | [matRule interposer=null] | whyHe='חומרים לא-תואמים' (fallback) |
| 4 | P1(hot) | [typeRule] | 1 issue · whyHe='חסר מערבל' · warn · skus=[P1] |
| 5 | P1(hot), P4(mixer) | [typeRule] | [] (הנדרש נוכח) |
| 6 | P1,P2 | [matRule, typeRule] | 2 issues |
| 7 | P1,P2 | [rule groups=[]] | [] (‏isNotEmpty=false) |
| 8 | [] | [matRule, typeRule] | [] |

## DoD
```
dart run --enable-asserts new/dart/completion_test.dart  ⇒ exit 0 + "OK completion: 8 asserts passed"
```
