# חוזה · `actionIdsFor` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/registry_view.dart:198-201` (מתודת `actionIdsFor`).

## תפקיד
מחזיר עותק חדש של קבוצת-הפעולות-המותרות לרכיב לפי id; אם אין descriptor (null) ⇒ קבוצה-ריקה.

## חתימה
```dart
Set<String> actionIdsFor(String id, {required Iterable<String>? Function(String id) allowedActionsOf})
```

## התנהגות (עוגן registry_view.dart:198-201)
`acts = allowedActionsOf(id)` ; `acts == null ? {} : Set<String>.of(acts)` — עותק חדש (מנתק מהמקור), מנטרל כפילויות.

## שקעים
- `allowedActionsOf` — **שקע** (חוק-3): במקור `findDescriptor(_descriptors, id)?.allowedActions` (חיפוש descriptor על state-מופע + השדה allowedActions). קופל לשקע יחיד המחזיר את הפעולות-המותרות או null.
- `_empty` (קבוצה-ריקה קבועה) הוטבע inline כ-`<String>{}`.

## דוגמאות-מחייבות
| # | allowedActionsOf(id) | ⇒ |
|---|----------------------|---|
| 1 | ['tap','longPress'] | {tap, longPress} |
| 2 | null | {} (ריק) |
| 3 | [] | {} (ריק, לא null) |
| 4 | ['a'] ואז שינוי-המקור | {a} — עותק מנותק |
| 5 | ['a','a','b'] | {a,b} — מנטרל כפילות |

## DoD
```
dart run --enable-asserts new/dart/action_ids_for_test.dart  ⇒ exit 0 + "OK actionIdsFor: 5 asserts passed"
```
