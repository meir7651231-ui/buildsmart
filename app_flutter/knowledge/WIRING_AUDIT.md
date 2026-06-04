# Wiring Audit — v6.13 (2026-06-04)

Post-cutover audit of the unified app (v6.12) by 5 parallel review agents, then
fixed in v6.13. Scope: every interactive control across all surfaces (contractor
app, store, courier, worker, manager, settings, menu/search dials, onboarding).

## Verdict
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
