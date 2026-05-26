# Decisions (ADR log) — app_flutter

Short records of notable choices. Newest first.

## D-008 · Knowledge protocol for Flutter
Built `app_flutter/knowledge/` (this folder) because the legacy `app/knowledge/`
Inspector protocol is Preact-only and frozen at INSP-0044. Flutter uses a
code-first discipline: `WIRING.md` contract + `flutter test` + mutation testing.

## D-007 · 100% mutation coverage of domain logic
Goal: every domain-logic mutation is caught. Achieved 50/50 by extracting
embedded logic to pure helpers and pinning one equivalent mutant with an
adversarial input. UI-only effects are tested via providers/helpers, not pixels.

## D-006 · Extract widget logic into pure helpers
VAT/checkout math, the notification filter/grouping, payment/delivery mapping,
date-group detection, and the index tokenizer were lifted out of widgets into
top-level pure functions so they're unit-testable. This closed 27 mutation gaps.

## D-005 · Wiring contract enforced by tests
`WIRING.md` lists every button/setting → behavior → status; wired rows have a
matching check in `gaps_test.dart`/`wiring_test.dart`. Contract and tests evolve
together.

## D-004 · Wire only what has data; mark the rest honestly
Settings are wired to real effects only when the data/behavior exists locally.
Everything needing prices, ratings, geo, a notification engine, media, telephony,
or a server is marked ⛔ blocked rather than faked.

## D-003 · Full light-mode migration
Converted every screen from the original dark theme to light (scaffold
`0xFFF5F6FA`, dark ink). Recurring bug class: white text on white surfaces —
fixed across chats, all settings screens, store, notifications, product/brand
screens. White text kept only on colored buttons/badges.

## D-002 · Real product grid + cart stepper
`viewMode`/`gridColumns` render a real grid card (legacy Preact `.product`
style: image, name, "מחיר לפי ספק", `+ לעגלה` / `− qty +`). Cart gained
`qtyForKey`/`setQtyForKey`. Default view = list (grid opt-in).

## D-001 · Light-themed settings with count badges
The four settings screens share a `_SectionTile` whose ExpansionTile shows an
orange active-count badge instead of the expand chevron (chevron kept when the
section has 0 functional rows).
