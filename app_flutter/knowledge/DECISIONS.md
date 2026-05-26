# Decisions (ADR log) — app_flutter

Short records of notable choices. Newest first.

## D-013 · Progressive dock UX (3-state)
**Problem:** The dock at the bottom of Install Studio showed a flat "הוסף / השלם" row
at all times, regardless of whether the chain was empty.  
**Process:** Identified 3 distinct user states and designed a separate layout for each:
- **State A (empty):** full-width primary CTA "➕ הוסף מוצר ראשון" + 3 hint chips (הזנה / ברז / ניקוז)
- **State B (1 item):** full-width glow "➕ הוסף עוד מוצר" + muted hint "נדרש לפחות מוצר נוסף"
- **State C (2+ items):** ghost "הוסף" (flex 1) + glow "⚡ השלם התקנה" (flex 2)
**Rule:** Loop toggle ("מחזור מים חמים") only shown when `tempC > 20` — irrelevant on cold lines.

## D-012 · BOM quality upgrade (v3.75→v3.79) — zero new SKUs
**Trigger:** External critique rated the BOM output 6.8/10: "36 items trivial, no zone
breakdown, missing safety items, no severity."  
**Constraint:** No new catalog products — upgrade engine + UI only.  
**Process (ordered):**
1. **ג · TMTV auto-per-branch** — `buildTreeInstallation` adds `HW-TMTV-15` once per
   branch when `tempC ≥ 60` and a manifold is in trunk. Qty = branch count.
2. **ב · Zone tagging** — `InstallationPlan` gains `zones: Map<String, List<String>>`.
   `buildTreeInstallation` populates "גזע" + "ענף א/ב/ג…" zones. BomSheet renders
   sectioned headers with item count chips.
3. **Severity on LineCheck** — `CheckSeverity {critical, warning, info}` enum; every
   `LineCheck` carries a severity. BomSheet renders colored icons (🔴/🟡/🔵) and a
   "N קריטי פתוח" badge.
4. **New compliance checks** — Legionella bypass (`critical`) when commercial pump + hot;
   sampling port (`warning`) when recirc; balancing valve (`warning`) when pump + manifold.
5. **Auto-compliance** — `_autoAddCompliance(items, qty, tempC)` auto-inserts PRV,
   BladderTank, isolation ball valve, dielectric when missing. Both build functions
   accept `autoCompliance: bool = false`; UI passes `true`.
6. **Gap hints** — `_gapHint(InstallationGap)` suggests what adapter to search.
7. **Temperature pill** — Human labels + color: "קר 20°C" blue / "חם 60°C" orange / "חם מאוד 80°C" red.
**Tests added:** `zone_tmtv_test.dart` (10) + `auto_compliance_test.dart` (10). Total: 50 domain tests.

## D-011 · Balance valve auto-add per branch with pump
When `HW-PUMP-40` detected in trunk of a tree install, `buildTreeInstallation`
auto-adds `HW-BALANCE-20` per branch — required to balance a pumped manifold system.

## D-010 · BOM zone headers in UI
`_zoneHeader(label, {count})` renders a cyan bar + Hebrew zone name + "N פריטים" chip +
divider line. Linear installs (zones empty) fall back to flat "קו ראשי" list.

## D-009 · _NodeRow colored dot
Added an 8 px colored dot (system color) before the numbered circle in `_NodeRow`.
Color mirrors the product's `systemType` for instant visual grouping.

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
