# lib/features/ — Isolation Pattern (Rule 2)

> **Rule 2 (NEW):** New features are NEVER built on top of existing code.
> They are built in isolation here, verified 100% independently, then connected.

---

## Directory convention

```
lib/features/[feature_name]/
    model.dart     — pure data types / enums (no Flutter, no Riverpod)
    helper.dart    — pure logic functions (no BuildContext, no ref, no side-effects)
    widget.dart    — dial widget (DialRow / DialColumn only — R2 enforced)

test/features/[feature_name]_test.dart  — unit + widget tests, 100% pass before connect
```

---

## Allowed imports inside lib/features/

| Allowed | Forbidden |
|---|---|
| `lib/data/` | `lib/screens/` |
| `lib/state/` | any new `Scaffold` / `showDialog` / `Navigator.push` |
| `lib/theme/` | |
| `lib/widgets/` | |
| `package:flutter/material.dart` | |
| `package:flutter_riverpod/flutter_riverpod.dart` | |

**If your feature file contains `import.*screens/` → CI fails.**

---

## Build order (always this order, never reversed)

```
1. model.dart         — define enums + data classes
2. helper.dart        — pure logic
3. test (unit)        — flutter test test/features/[name]_test.dart
4. widget.dart        — dial widget only
5. test (widget)      — pumpDial + expectDialLeaf
6. connect            — wire into home_shell / FAB trigger
7. WIRING.md update
```

---

## Integration checklist (before connecting to shell)

- [ ] `flutter analyze` — 0 issues in `lib/features/[name]/`
- [ ] `flutter test test/features/[name]_test.dart` — 0 failures
- [ ] No `import.*screens/` in any file under `lib/features/[name]/`
- [ ] No `showDialog` / `showModalBottomSheet` / `Navigator.push` / new `Scaffold`
- [ ] All Hebrew strings have `// [L####]` verbatim source comment
- [ ] `WIRING.md` row added with status `🚧`
- [ ] After connection: `flutter test` — full suite 0 failures
- [ ] After connection: update WIRING.md row to `✅` or `⛔`

---

## Example

```
lib/features/order_track/
    model.dart    — OrderStage enum, OrderAction enum
    helper.dart   — transition(order, action, role) → OrderTransitionResult
    widget.dart   — OrderTrackDial (DialColumn with DialRow leaves)

test/features/order_track_test.dart
    — group('helper') → all 30 state×role transitions
    — group('widget') → pumpDial, expectDialLeaf('הזמנות פתוחות') [L11970]
```

---

> Every violation of this pattern is tracked in PROTOCOL.md §15.
> Do not skip isolation. Do not import from `lib/screens/`.
