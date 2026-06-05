# Wiring Audit — v6.13 + v6.14 + v6.15 (2026-06-04)

Post-cutover audit of the unified app (v6.12) by parallel review agents, fixed across three
passes. Scope: every interactive control across all surfaces (contractor app, store,
courier, worker, manager, settings, menu/search dials, onboarding).

## v6.15 — third pass + store-orders refactor

5 agents (onboarding/auth · money-path · full settings screens · hubs/tools internals ·
form-input persistence) on v6.14. ~15 deduped findings; the actionable set fixed:

- **Store-orders unified on the engine (headline refactor):** the contractor's "הזמנות שלי" read a
  RAM-only `storeOrdersProvider` (static seed, isolated from `ordersEngineProvider`) — placed orders
  vanished on restart, checkout minted two divergent records (different id + stage), detail came from
  a static 5-id map, address/notes were dropped. Now `storeOrdersProvider` is a `Provider` DERIVED
  from the engine: one id, live stage (follows manager/courier advances), real line items (new
  `OrderLineItem` on `Order`), persisted address+notes, and the timeline regained its `new`+`pickup`
  stages. Demo seed retained for the empty-state.
- **Persistence:** supplier out-of-stock toggles (`storeOosProvider`) + user-added project names
  (`storeProjectsProvider` → StateNotifier) now survive navigation + restart.
- **Quiet hours:** new `NotifSettings.isInQuietHours` getter + a list-suppression gate (mirrors the
  v6.14 snooze gate) — quiet hours finally mute notifications.
- **Onboarding:** the chosen profession now seeds `professionModeProvider` / catalog detail-mode
  (`defaultDetailFor`), respecting an explicit manual choice.
- **Settings applied:** store `sortDefault` + `displayMode` now actually sort / switch grid-list.
- **Honesty:** the 6 supply-chain service-sheet rows show a 🚧 badge (were rich-looking but dead);
  the SLA tile subtitle 'ספירה לאחור' → 'זמני אספקה' (no live timer exists).
- **Account dial:** name/phone/profession leaves are now editable (dialogs via existing
  `register`/`setProfession`); 'שם הקבלן' value is shown.

Left by design: ~60 forward-compat settings fields that persist but have no consumer yet — honest
scaffolding, not bugs (per product decision). Regression: all v6.13+v6.14 fixes intact.
analyze 0 · 1536 tests green · build OK.

---

## v6.14 — second pass (deeper sweep)

4 agents (systematic stub-hunt · dead/mismatched provider hunt · hubs & deep flows · full
dial-leaf sweep + regression) on the fixed v6.13. ~18 new findings, all fixed:

- **Real functional:** chat custom greeting now honored (was hard-coded); notification snooze
  now actually suppresses the list; notification 'אשר איסוף' → store-orders tab ('עקוב' → honest
  🚧, no shipments screen); install-studio cart lines carry the real price (was ₪0); store
  favorites tap navigates to the service; store 'מחיקת חיפושים' actually clears the query.
- **BS-dial (reachable via home_shell):** manager **metric** tiles (the sibling missed in v6.13)
  + store/courier portal leaves + worker task-status leaves now read live providers
  (`managerAnalyticsProvider` / `showPortalSheet` / `workerTasksProvider`); courier vehicle leaves
  → honest placeholder (no shared provider).
- **Honest placeholders:** false-confirm buttons (chat storage/export/backup/delete-history,
  camera non-barcode capture) no longer fake success; dead region (currency/units/haul) + security
  (2FA/biometric/location/session) dial leaves marked 🚧; 14 orphaned `AppSettings` fields tagged
  `// DEAD — not consumed (v6.14)` (kept for the test harness; persistence intact).
- **Polish:** search-dial filter is a real toggle + sort/filter show active highlight.

Regression: all v6.13 fixes re-verified intact. analyze 0 · 1536 tests green · build OK.

---

## Verdict (v6.13 — first pass)
Core wiring is sound: the unified `ordersEngineProvider` is the single source for
all four roles; role routing, checkout, onboarding, the full settings screens, the
full manager dashboard, and worker approvals are all correctly wired. Findings
concentrated in the **FAB/dial shortcut layer** (menu + search dials) plus a few
cross-role/display details — a parallel UI surface that duplicated, and in places
stubbed, behavior that already worked on the full screens.

~19 findings · all functional ones fixed in v6.13 · verified: `analyze` 0 errors,
1536/1536 tests green, `flutter build web` OK.

## Fixed (v6.13)

### A. Controls that looked active but did nothing
| Sev | Where | Was | Now |
|-----|-------|-----|-----|
| HIGH | `search_dial_widget.dart` ↕️ מיון | 5 options toasted "בבנייה" | set `catalogProductSortProvider` (4 `ProductSort` values) |
| HIGH | `search_dial_widget.dart` ⚙️ פילטרים | "עם תמונה" toasted | sets `searchImageOnlyProvider` ("עם מחיר" left placeholder — no backing provider exists) |
| HIGH | `menu_dial_widget.dart` text-size / contrast / reduce-motion | wrote `appSettings.*` (never read) | read/write `catalogSettingsProvider` (the consumed one) |
| MED | `menu_dial_widget.dart` notification toggles | wrote `appSettings.notif*` (never read) | `notifSettingsProvider.type*` |
| MED | `menu_dial_widget.dart` 🛒 הסל שלי | toasted "בבנייה" | opens the store cart (`storeSectionProvider=cart`, tab 3) |
| HIGH | `store_dashboard_screen.dart` stock toggle | toast falsely claimed "הוסתר מקטלוג הקבלן" | honest local copy ("סומן כאזל במלאי"); subtitle "❌ אזל מהמלאי" |

### B. Manager dial panels read static data (leftover of the pre-v6.12 split)
| Sev | Where | Was | Now |
|-----|-------|-----|-----|
| HIGH | `bs_dial_widget.dart` `_ManagerOrderPanel` | read `kManagerOrderSeed` (frozen) | `ref.watch(ordersEngineProvider)` (live) |
| MED | `bs_dial_widget.dart` `_ManagerCustomerPanel` | read static seed | `ordersEngineProvider` + `managerCustomersProvider` (mirrors the full screen) |

### C. Display / liveness
| Sev | Where | Fix |
|-----|-------|-----|
| MED | `courier_dashboard_screen.dart` "בדרך 🚚" stat | now counts `pickup`+`transit` (was `transit` only) |
| MED | `manager_dashboard_screen.dart` customer sheet | `ConsumerWidget` + `ref.watch` (was `ref.read` snapshot, stale while open) |
| MED | `search_dial_widget.dart` `_ToolsRoot` | added missing 5th tool ▦ קטלוג (sets `catalogSectionProvider`) |
| MED | `store_dashboard_screen.dart` `_stockNames` | `ref.watch` (was `ref.read` in a getter) |

### D. Honesty — settings shown active but ⛔ no-engine → marked placeholders
`catalog_settings_screen.dart` §7 "ספקים מועדפים" (3) + §8 "AI והמלצות" (4) converted
to `_PlaceholderRow`. The ✅ consumed fields (history / grid / view / image / compact /
textSize / contrast / reducedMotion) kept live. (§3–6 prices/favorites/notifications/
units were already placeholders.)

### E. Edge / docs
- `manager_dashboard_screen.dart` `_advance`: added `if (cur < 0) return;` guard against an unknown stage.
- Stale doc comments updated (`manager_dashboard_screen.dart`, `manager_dashboard_state.dart`).

## Documented (not code bugs)
- `persona_portal.dart`: 5 store/courier portal tiles are honest "יחובר בהמשך הפיתוח" stubs (POD, barcode, auto-stock, chat, navigation).
- `sys_orders.dart` store/courier stage guards use canonical stage strings (functionally correct; type-safety nicety only).

## Verified clean (no change needed)
Role-picker routing (all 5 roles), onboarding / welcome / profession, checkout →
`ordersEngineProvider.placeOrder`, shared-engine propagation (contractor / store /
courier / worker → manager), worker submit / approve / reject, the full settings
screens' ✅ fields, and the full manager dashboard (advance / approvals / analytics /
customers — all live).

## Follow-up (optional)
No regression tests were added for the newly-wired dial behaviors; a future pass
could add `dial`-level widget tests so these can't silently regress again.
