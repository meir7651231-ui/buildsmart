# חוזה · `dryCountScope` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:484-495`
(‏`dryCountScope`).

**שקעים:** `expandScope(token, registry)`⇒`expandScope` (ה-registry נצרך רק שם ⇒ נבלע
בשקע) · `_batchRejectHe(n)`⇒`batchRejectHe` (גופו **לא הופיע בטיוטה** ⇒ שקע, חוק-3).
**הוטבע:** טיפוס-התוצאה `ScopeCount` (ctor פרטי `._`) ⇒ record inline.
**הוסק:** `kStudioMaxBatch` — ערכו לא בטיוטה זו; הוסק **25** מהערת-אח (‏edit_safety draft:
"the committed kStudioMaxBatch=25"), הוטבע const inline. אם התקרה האמיתית שונה — יש לעדכן const יחיד.

## חתימה
```dart
({List<String> ids, int total, String? rejectedReasonHe}) dryCountScope(
  String token, {
  required List<String> Function(String token) expandScope,
  required String Function(int n) batchRejectHe,
})
```

## קלט
- `token` — טוקן-ההיקף.
- `expandScope` — **שקע**: הרחבת-token לרשימת-מזהים.
- `batchRejectHe` — **שקע**: בניית סיבת-דחייה עברית מגודל-ההרחבה.

## פלט / התנהגות (עוגני-שורה)
- `:485` — `expanded = expandScope(token, registry)`.
- `:486-491` — `expanded.length > 25` ⇒ החזרת `(ids: [], total: length, rejectedReasonHe: batchRejectHe(length))`
  (סירוב-מוקדם, fail-closed, ids ריק).
- `:493` — אחרת ⇒ `(ids: expanded, total: length, rejectedReasonHe: null)`.
- **גבול**: `length == 25` ⇒ בסדר (‏25>25 שקר); `length == 26` ⇒ נדחה.

## דוגמאות (‏batchRejectHe(n) = `'REJECT:$n'`)
| # | expandScope⇒ | total | ids | rejectedReasonHe |
|---|--------------|-------|-----|------------------|
| 1 | 3 מזהים | 3 | ‏3 המזהים | `null` |
| 2 | 0 מזהים | 0 | `[]` | `null` |
| 3 | בדיוק 25 | 25 | ‏25 המזהים | `null` (גבול-פנימי) |
| 4 | 26 | 26 | `[]` | `'REJECT:26'` (גבול-דחייה) |
| 5 | 100 | 100 | `[]` | `'REJECT:100'` |

## שקעים
- `expandScope`, `batchRejectHe` — מוזרקים. הבדיקה מזריקה מחוללי-רשימה + בונה-סיבה קבועים.

## DoD
```
dart run --enable-asserts new/dart/dry_count_scope_test.dart  ⇒ exit 0 + "OK dryCountScope: N asserts passed"
```
