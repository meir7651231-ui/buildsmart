# אטום · `triggerMatches`

מוצא: `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:385-400`

## חתימה
```dart
bool triggerMatches(String trigger, Order order)
```

## חוזה
פרדיקט-הבסיס של כלל-סטודיו: האם `order` תואם את `trigger`. READ-ONLY, fail-closed.

| trigger | תנאי |
|---|---|
| `order.new` | `stage == 'new'` |
| `order.stuck` | `isOpen` (לא-נמסר) |
| `order.open` | `isOpen` (לא-נמסר) |
| `order.delivered` | `stage == 'delivered'` |
| לא-מוכר | `false` |

## מוטבע verbatim
- 4 consts `kTriggerOrder*`.
- `Order` מוטבע-מינימום: שדה `stage` + getter `isOpen => stage != 'delivered'` (טהור).

## טוהר
דטרמיניסטי, בלי state/IO/setter.
