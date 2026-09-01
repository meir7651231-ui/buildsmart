# חוזה · `roleFloorBlock` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:226-249`
(‏`_roleFloorBlock`, פרטי-במקור). הקובץ אינו קיים עוד ⇒ הטיוטה = מקור-האמת.

## חתימה
```dart
String? roleFloorBlock({
  required String labelHe, required String roleFloor,
  required bool isNavStructural, required String? persona,
  String contractorRole = 'contractor',
})
```

## שקעים (חוק-3)
- `labelHe` = `d.labelHe` · `roleFloor` = `d.kRoleFloor` (‏`ElementDescriptor`-שכן, פורק לשדות).
- `isNavStructural` = פלט העוזר `_isNavStructural(d)`.
- `contractorRole` = `_kRoleContractor` (const-שכן לא-ניתן-לשחזור). ברירת-המחדל `'contractor'`
  נסמכת על עדות-מחצב: `plumbing_trade_seed.dart` מציב `personaId: 'contractor'`.

## פלט / התנהגות (עוגני-שורה)
- `isGlobal = persona == null || persona.isEmpty` (‏:228, null/ריק = כל-הפרסונות).
- **מסלול-גלובלי** (`isGlobal`):
  - `:230-233` — `isNavStructural` ⇒ הודעת "רכיב ניווט חייב להישאר גלוי".
  - `:234-237` — אחרת `floor != contractorRole` ⇒ הודעת "חייב להישאר גלוי לתפקיד «$floor»".
  - `:238` — אחרת ⇒ `null` (רכיב יומיומי לא-מבני מותר להסתרה כלל-מערכתית).
- **מסלול-פרסונה-בודדת** (persona לא-ריק):
  - `:243-245` — `persona == floor && floor != contractorRole` ⇒ הודעת "קריטי לתפקיד זה".
  - `:247` — אחרת ⇒ `null`.
- `$floor` בהודעות = `roleFloor`.

## דוגמאות (contractorRole='contractor')
| # | labelHe | roleFloor | isNavStructural | persona | ⇒ |
|---|---------|-----------|-----------------|---------|---|
| 1 | 'תפריט' | 'manager' | true | `null` | הודעת-ניווט (גלובלי + מבני) |
| 2 | 'דוח' | 'manager' | false | `null` | הודעת-floor (גלובלי, floor≠קבלן) |
| 3 | 'באנר' | 'contractor' | false | `null` | `null` (גלובלי, floor=קבלן, לא-מבני) |
| 4 | 'דוח' | 'manager' | false | `'manager'` | הודעת-"קריטי" (מסתיר מהתפקיד עצמו) |
| 5 | 'דוח' | 'manager' | false | `'courier'` | `null` (פרסונה אחרת) |
| 6 | 'באנר' | 'contractor' | false | `'contractor'` | `null` (floor=קבלן ⇒ מותר) |
| 7 | 'דוח' | 'manager' | true | `'manager'` | הודעת-"קריטי" (isNavStructural לא-רלוונטי במסלול-בודד) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart analyze new/dart/role_floor_block.dart                    ⇒ No issues found!
dart run --enable-asserts new/dart/role_floor_block_test.dart  ⇒ exit 0 + "OK roleFloorBlock: N asserts passed"
```
