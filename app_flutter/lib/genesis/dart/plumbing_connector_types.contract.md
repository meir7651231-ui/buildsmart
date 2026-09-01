# חוזה · `plumbingConnectorTypes` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/domain/seeds/plumbing_trade_seed.dart:271-299`
(ענף `claude/whats-happening-LyY9G`). ‏ConnectorType אחד פר-`EndType`, ממוין לפי id.

## חתימה
```dart
List<ConnectorType> plumbingConnectorTypes(Iterable<ConnectorEnd> verifiedEnds)
// ConnectorType { String id; String tradeId; String nameHe; List<String> sizeValues; String? systemId; }
```

## שקעים (קריאה-לשכן ⇒ פרמטר · חוק-1/3)
- `verifiedEnds` — במקור `kVerifiedSpecs.values` → `spec.ends` (‏:284-287). קורס
  לשקע-קצוות **שטוח**: האיסוף הוא צבירת-Set אדישה-לקיבוץ ⇒ פלט זהה-ביט.
  חיווט-הקופסה: `[for (final s in kVerifiedSpecs.values) ...s.ends]`.

## אחים שהוטבעו verbatim (עוגני-שורה)
- `kPlumbingTradeId='plumbing'` — plumbing_trade_seed.dart:30.
- `_connTypeId(e)` = `'plumbing.conn.${e.name}'` — ‏:40 · `_systemId(s)` = `'plumbing.sys.${s.name}'` — ‏:38.
- `_systemOfEndType` — ‏:57 = `ConnectorEnd(e,'').system`; ה-getter‏ system
  (lipskey_verified_connections.dart:70-77) קורא רק `type` ⇒ ה-switch הוטבע ישירות:
  hdpeCompression/drainOpening ⇒ drainage · bspMale/bspFemale/pexPress/copperPress ⇒ supply.
- טיפוסים: `EndType` (‏:24, סדר-הכרזה = סדר-בנייה טרם-מיון) · `WaterSystem` (‏:41) ·
  `ConnectorEnd` (‏:43, ‏type+size) · `ConnectorType` (connection_schema.dart:64-85, שדות בלבד).

## התנהגות (עוגני-שורה)
- ‏:272-279 — `nameHe` מפת-תוויות authored, verbatim (הפיזיקה לא קוראת אותה).
- ‏:281-283 — קבוצת-גדלים ריקה לכל `EndType.values` (גם כשאין קצוות ⇒ 6 רשומות תמיד).
- ‏:284-287 — כל קצה מוסיף `end.size` לקבוצת `end.type` (Set ⇒ נבדלות).
- ‏:289-297 — בנייה פר-EndType: ‏id=`_connTypeId` · tradeId=`kPlumbingTradeId` ·
  ‏nameHe מהמפה (`!`) · ‏sizeValues=`toList()..sort()` (**מיון-מחרוזות לקסיקוגרפי**) ·
  ‏systemId=`_systemId(_systemOfEndType(e))`.
- ‏:298 — מיון-סופי `a.id.compareTo(b.id)` ⇒ סדר: bspFemale · bspMale · copperPress ·
  drainOpening · hdpeCompression · pexPress.

## דוגמאות מספריות
| # | verifiedEnds | תוצאה |
|---|---|---|
| 1 | `[]` | 6 רשומות, כל sizeValues=`[]`; ids ממוינים כנ"ל |
| 2 | `[pexPress·'25', pexPress·'16', pexPress·'25', bspMale·'1/2']` | pexPress ⇒ `['16','25']` (נבדל+ממוין) · bspMale ⇒ `['1/2']` · השאר `[]` |
| 3 | `[hdpeCompression·'63', hdpeCompression·'110', hdpeCompression·'16']` | hdpeCompression ⇒ `['110','16','63']` (מיון-מחרוזות, לא מספרי!) |
| 4 | כל רשומה | tradeId=`'plumbing'`; hdpeCompression/drainOpening ⇒ systemId=`'plumbing.sys.drainage'`; ‏4 האחרים ⇒ `'plumbing.sys.supply'` |
| 5 | כל רשומה | nameHe: hdpeCompression=`'הידוק HDPE'` · pexPress=`'PEX פרס'` · copperPress=`'נחושת פרס'` · bspMale=`'תבריג זכר (BSP)'` · bspFemale=`'תבריג נקבה (BSP)'` · drainOpening=`'פתח ניקוז'` |

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/plumbing_connector_types_test.dart  ⇒ exit 0 + "OK plumbingConnectorTypes: N asserts passed"
```
