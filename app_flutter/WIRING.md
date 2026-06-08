# WIRING CONTRACT — app_flutter

What every interactive button / setting is expected to do, and its status.
**This contract is enforced by `test/wiring_test.dart`** (the wired-behavior rows
marked ✅ have an executable regression check). Keep this file and that test in
sync — if you change a behavior, update both.

Status legend: ✅ wired (real effect) · 🚧 בבנייה (placeholder toast) ·
⛔ blocked (needs price/rating/geo data, a server, or telephony that don't exist).

> **v6.13 → v6.16 wiring audits:** see `knowledge/WIRING_AUDIT.md` — six rounds (three fix passes + a deep
> correctness/perf/a11y pass with adversarial validation). v6.16 corrected the manager express-fee display,
> aligned contractor stage labels to the canonical map, made the manager customer/order detail sheets read
> live engine data, fixed load-clobber races + incomplete resets + double-checkout, moved hot catalog/manager
> paths to derived providers, and fixed targeted RTL/overflow/reducedMotion issues — deferring the app-wide
> Semantics + highContrast-token initiatives and keeping verbatim-legacy strings.
>
> **v6.13 + v6.14 + v6.15 wiring audits:** see `knowledge/WIRING_AUDIT.md` — three passes swept the
> FAB/dial shortcut layer, deeper flows, and the full screens for stubs / mis-wired toggles and fixed
> them. v6.15 unified the contractor's order history on `ordersEngineProvider` (one id, live stage,
> real items, persisted), made supplier out-of-stock + project names persist, gated notification
> quiet-hours, seeded profession→catalog-mode, applied store sort/display, and made the
> service-sheet rows + account-edit leaves honest/editable.

---

## Opening flow — first run (`onboarding_screen.dart` · `welcome_screen.dart` · `profession_screen.dart` · `role_picker_sheet.dart`)

`OnboardingGate` (gated by `welcomeSeenProvider`, seeded in `main()` from prefs):
a genuine first run walks Welcome → Profession → onboarding slides → home; afterwards
home directly. Guarded by `onboarding_test`.

| Button | Behavior | Status |
|---|---|---|
| WelcomeScreen · אישור והמשך (רישום) | `register(name, contact)` → `userProfileProvider` (persisted) → profession step | ✅ |
| WelcomeScreen · כניסה ללקוח קיים | enters straight to home (skips the trade step; no auth backend) | ✅ |
| WelcomeScreen · המשך ללא רישום (דוגמה) | `continueAsDemo` → profession step | ✅ |
| ProfessionScreen · בחירת מקצוע / חזור | `setProfession` → slides · back → welcome | ✅ |
| OnboardingScreen · דלג / הבא / בואו נתחיל | finishes (`welcomeSeenProvider=true`, persisted) → home | ✅ |

## Home app-bar (`home_shell.dart` · `_HomeAppBar`)

| Button | Behavior | Status |
|---|---|---|
| logo "BuildSmart" | opens the "מי אתה?" persona picker (`showRolePicker`); contractor stays in the main app; **עובד / מנהל / חנות / שליח each open their full role-app** (`WorkerAppScreen` / `ManagerDashboardScreen` / `StoreDashboardScreen` / `CourierDashboardScreen`) | ✅ |
| role-app **עובד** (`WorkerAppScreen`) — T9 | same shell as the main app (white AppBar `🦺 עובד · ‹ יציאה` + card list, `BsTokens`); only the content differs. Faithful port of `renderWorker()` (proto 06 §4.2): worker picker (`kWorkers`) · summary (`שלום {name} 👷` + `{done}/{total}` + progress + פעילה/בתור/הוגשו) · 3 buckets (🔨 המשימה הנוכחית שלך = active\|rejected · ⏳ הבאות בתור = pending · 📋 שהגשת = review\|done) as task cards. **W3 — now LIVE:** `ConsumerStatefulWidget` reading the shared `workerTasksProvider` (not the static const); a current-bucket card carries a keyed "📸 שלח לאישור" button → `submitForReview` (active\|rejected → `review`), surfacing the task in the manager's approvals view. Data: `persona_data.dart` (5 verbatim tasks, R8). | ✅ |
| role-app **מנהל המערכת** (`ManagerDashboardScreen`) — unify | full LIGHT role-app, 4-tab toggle (📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול) reading the shared `ordersEngineProvider` live data (`managerAnalyticsProvider` / `managerCustomersProvider`). Replaces the old dial-manager panel for the manager persona. | ✅ |
| role-app **🏪 חנות ספק** (`StoreDashboardScreen`) — T9 | full role-app, 4 segmented tabs (בית/הזמנות/מלאי/פורטל), same shell as the main app. Faithful port of `screen-store` (proto 06 §2): action-first home (`שלום 👋` · primary `הזמנות ממתינות לאישור` · stats בהכנה/מוכן לאיסוף/מחזור פעיל · stock alert · demo `סימולציית הזמנה נכנסת`) · orders queue with the real **`new→preparing→ready`** advance (`✓ אשר וקבל להכנה` / `📦 סמן כמוכן — העבר לשליח`) · stock availability toggles (`✅ זמין במלאי` / `❌ אזל`) · 8-tile supplier portal. Orders are the shared `sysOrdersProvider`. Data verbatim `supplier_data.dart` (R8). Guarded by `t9_supplier_personas_test`. | ✅ |
| role-app **🛵 שליח** (`CourierDashboardScreen`) — T9 | full role-app: vehicle picker (`vehicleCanCarry`, משלוח קטן/טנדר/משאית) + delivery home (stats לאיסוף/בדרך/נמסרו) + job list (3-step tracker איסוף/בדרך/נמסר) + 6-tile portal. Faithful port of `screen-courier` (proto 06 §3): the real **`ready→pickup→transit→delivered`** advance (`📦 אספתי מהחנות` / `🚚 יצאתי לדרך` / `✅ נמסר ללקוח`). Shares `sysOrdersProvider` with the store — an order the store marks "מוכן" appears here live. Data verbatim (R8). Guarded by `t9_supplier_personas_test`. | ✅ |

> **T9 deferred** (proto "adds beyond"/heavier infra): per-store login routing, the picking sheet + missing-item hold loop, split-shipment jobs, POD capture, the printed delivery note, and localStorage persistence. The store/courier full screens + the shared 6-stage advance engine are done.
>
> **✅ unified (v6.12):** `sysOrdersProvider` is now a live view of the single `ordersEngineProvider`, so store/courier advances reach the manager live — all four roles (contractor checkout · store · courier · worker approval) share one engine. **v6.13:** the BS-dial manager order/customer panels also read the live engine (were a static seed). See `knowledge/WIRING_AUDIT.md`.
| 💡 (קצה שמאלי) | replays the intro tour (`showIntroTour` → the onboarding slides) | ✅ |
| שם-משתמש (צ'יפ ליד הלוגו) | registered user's first name (`userProfileProvider`); absent for guest/demo. **Tappable → `ProfileScreen.route()`** (48dp target · `Semantics(button,'הפרופיל שלי')`+Tooltip) — native profile surface: name/contact/profession edit via `userProfileProvider.update`, + 🔄 החלפת תפקיד (`showRolePicker`) + 🎮 מועדון BuildSmart (`RewardsHubScreen`). | ✅ |

## Version chrome (`home_shell.dart` AppBar → `version.g.dart`)

| Element | Behavior | Status |
|---|---|---|
| תווית-גרסה | מציגה `kVersionLabel` בלבד (אפור-secondary, `Key('version_chrome')`), מ-`version.g.dart` הנוצר אוטומטית מ-git+STATUS. אין נקודה-ירוקה (שמורה ל-`_PulsingStatus`), אין changelog ב-UI. לא מרונדרת במצב "עץ חכם". | ✅ wired (לקח #72) |

## 🔗 Shared orders engine — DATA LAYER (`state/orders_engine.dart` · `logic/manager_dashboard.dart`)

The legacy `SYS_ORDERS` (the localStorage array every role read & wrote, @index.html:11965-12039,
:16939-17035) ported to a Riverpod state engine. **DATA LAYER ONLY — no UI reads it yet** (wiring
the 4-tab UI / the dial to the engine is a LATER wave). `ordersEngineProvider`
(`StateNotifier<List<Order>>`) is **SEEDED with the SAME four seed orders** (from `kManagerOrderSeed`,
the retained seed source) so every existing manager number is preserved. `Order` =
`id/who/site/items/sum/stage` (+ optional `createdAt`); `isOpen` = `stage!=='delivered'`. Persists
to `SharedPreferences` key `bs.orders.v1` (cart/profile pattern; corrupt → seed).

| API / provider | Behavior | Status |
|---|---|---|
| `placeOrder({who, site, items, sum, id?, createdAt?})` | contractor creates an order at stage `new`; auto-id `BS-####` above current max; prepended + timestamped; returns it | ✅ |
| `advance(orderId)` | next stage in `kManagerOrderFlow`; no-op once `delivered` (verbatim `mgrAdvanceOrder` @17022-17032); unknown id = no-op | ✅ |
| `setStage(orderId, stage)` | manager "god-step" to ANY flow stage; ignores unknown id/stage | ✅ |
| `resetToSeed()` | restore the four seed orders | ✅ |
| `managerAnalyticsProvider` | `ManagerAnalytics` over the engine's LIVE orders (same fold as the static `managerAnalytics`) | ✅ |
| `managerCustomersProvider` | `mgrCustomerList` over the engine's LIVE orders | ✅ |

Guard: `orders_engine_test` (21 — seed correctness vs `kManagerOrderSeed`/`managerAnalytics`,
place/advance/setStage behavior, persistence round-trip, flow ordering). The static
`managerAnalytics` / `mgrCustomerList()` (seed-bound) are UNCHANGED and still feed the dashboard
widget below — the engine just adds the live path for the upcoming UI wave.

## 🔗 Shared worker-tasks engine — W3 cross-persona (`state/worker_tasks_engine.dart` · `data/persona_data.dart`)

The 🦺 worker's tasks lifted from the STATIC `kPersonaTasks` into a live Riverpod engine both the
worker and the manager read & write — so "the manager manages everyone live" now covers the worker.
`workerTasksProvider` (`StateNotifier<List<PersonaTask>>`) is **SEEDED from `kPersonaTasks`** (every
verbatim string/number preserved). The approval bridge is the task status (proto 06 `taskStatusInfo`):
`active`/`rejected` →(worker)→ `review` (📸 ממתין לאישור) →(manager)→ `done` (✅ אושר) or `rejected`
(↩️ נדחה — back to the worker). `PersonaTask` gained `copyWith(status:)` + an optional `orderId`.

| API / provider | Behavior | Status |
|---|---|---|
| `submitForReview(id)` | WORKER "שלח לאישור": `active`/`rejected` → `review`; no-op from any other status | ✅ |
| `approve(id)` | MANAGER: `review` → `done`; if the task has an `orderId`, also `advance`s that order on the SHARED `ordersEngineProvider` (a completed install moves its order live) | ✅ |
| `reject(id)` | MANAGER: `review` → `rejected` (bounces it back to the worker's current bucket) | ✅ |
| `resetToSeed()` | restore the verbatim seed | ✅ |
| `pendingApprovalTasksProvider` | the LIVE `review` queue (id-sorted) the manager's אישורי עובדים view reads | ✅ |

Seed task 3 (איטום רצפת מקלחת, `review`) is bound to order **BS-1040** (stage `ready`) so approving it
advances ready → pickup — the cross-engine link. Guard: `worker_approval_engine_test` (5 — pure
submit→pending→approve→done in one container · reject bounce-back · order-linked approval advancing
BS-1040 with the manager open-orders 4→3 chain · the worker "📸 שלח לאישור" widget submit · the manager
👷 אישורי עובדים widget approve, reflecting live). `worker_app_test` updated to pump in a `ProviderScope`.

## 👔 Manager dashboard — M1 SHELL + M2 📊 לוח בקרה + M3 🚚 הזמנות + M4 👥 לקוחות + M5 🛠️ ניהול (COMPLETE) (`screens/manager_dashboard_screen.dart` · `state/manager_dashboard_state.dart` · `state/orders_engine.dart` · `screens/role_picker_sheet.dart`)

The 👔 "מנהל המערכת" persona was rebuilt from the BS-dial drill (below) into a **full
role-app screen** — the same LIGHT shell/style as the 🦺 worker app. **M1 = the SHELL; M2 fills the
📊 לוח בקרה tab with a LIVE cockpit; M3 fills the 🚚 הזמנות tab with the live order list + the
manager's god-mode stage-advance; M4 fills the 👥 לקוחות tab with the live customer list + credit;
M5 fills the 🛠️ ניהול tab with the 5 management tools** (all derived from the same shared orders
engine where live). **The screen is now COMPLETE — every tab is real, ZERO "בקרוב" placeholder remains.**

| Element | Behavior | Status |
|---|---|---|
| `ManagerDashboardScreen` | `ConsumerWidget`; LIGHT `Scaffold(bgLight)` + white AppBar (`cardLight`) — title "מרכז השליטה" (`inkLight`) + subtitle "מנהל המערכת" (`mutedLight`) + green "חי" pill + "‹ יציאה" | ✅ |
| 4-tab segmented toggle | pill style (selected = `brand` fill + white text; unselected = `cardLight` + `inkLight` text; pill radius) — 📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול; replicates `updates_screen`'s `seg()`; tap sets `managerTabProvider` | ✅ |
| `IndexedStack` body | index-0 = the 📊 `_DashboardTab` cockpit (M2); index-1 = the 🚚 `_OrdersTab` (M3); index-2 = the 👥 `_CustomersTab` (M4); index-3 = the 🛠️ `_ManageTab` (M5); all 4 kept mounted. **No placeholder remains — `_TabPlaceholder` was removed** | ✅ |
| 📊 `_DashboardTab` (M2) | `ConsumerWidget`; a LIGHT `ListView` (`bgLight`) over the LIVE engine — watches `managerAnalyticsProvider` + `ordersEngineProvider` (a trimmed port of `renderMgrDashboard` @index.html:12133) | ✅ |
| 5 metric tiles (`_MetricGrid`/`_MetricTile`) | WHITE `cardLight` cards (2-up `Wrap`) — emoji + big `brand` number + `mutedLight` verbatim label: 🚚 הזמנות פתוחות · 📦 מוצרים בקטלוג · 🧰 אביזרים נלווים · ✅ זמינים כעת · 🏪 חנויות פעילות. Numbers from `managerAnalyticsProvider` over the engine's LIVE orders (`mdMetric` @12160-12164). Seed: 4 / 54 / 148 / 202 / 3/3 — and 🚚 reflows when an order is placed/advanced/delivered | ✅ |
| Order pipeline (`_OrderPipeline`/`_PipelineRow`) | WHITE `cardLight` card "צינור ההזמנות" — per-stage count + proportional bar across the **6** `kManagerOrderFlow` stages (group-by-stage over `ordersEngineProvider`); labels verbatim from the legacy `md-pipe` array + נאסף for pickup: התקבלה · בהכנה · מוכן · נאסף · בדרך · נמסר; bar colours = legacy hex (`md-pipe` @12177-12198). Seed: 1/1/1/0/0/0 | ✅ |
| 🚚 `_OrdersTab` (M3) | `ConsumerStatefulWidget`; a LIGHT `ListView` (`bgLight`) over the LIVE engine — `ref.watch(ordersEngineProvider)`. A faithful port of the legacy `renderMgrOrders` (@index.html:16939-17075). Local `_filter` = `'all'` or one `kManagerOrderFlow` stage (the legacy `mgrOrderFilter`); the free-text search is out of scope this wave | ✅ |
| `_OrderSummary` (M3) | WHITE `cardLight` strip — 3 stats (הזמנות = total / פתוחות = open / מחזור = ₪Σsum, grouped). Legacy `mo-summary` @index.html:16953-16962 | ✅ |
| `_OrderStageChips` (M3) | `הכל (N)` + one chip per **populated** stage — VERBATIM `ORDER_STAGE` labels + counts (@index.html:12041-12048, `md-chips` @16967-16973). Active chip = `brand` fill; tap sets `_filter`. A stage that empties out falls back to `הכל` | ✅ |
| `_OrderRow` (M3) | WHITE `cardLight` card (legacy `mo-card` @16998-17017): `📦 id` + a `_StagePill` (tinted stage colour) on top · `who · site` · a 6-step `_MiniTracker` · footer `items פריטים · ₪sum` + the advance control. Tapping the card opens the detail sheet | ✅ |
| 🔑 `_AdvanceButton` "קדם שלב ›" (M3) | per **open** order → `ref.read(ordersEngineProvider.notifier).advance(o.id)` (the legacy `mgrAdvanceOrder` @17022) → toasts `הזמנה id → next-label` (or "ההזמנה כבר הושלמה"). A `delivered` order shows "✓ הושלם" instead. **The first manager WRITE to the engine** — the shared `ordersEngineProvider` means the 📊 dashboard's 🚚 tile + pipeline + counts reflow LIVE | ✅ |
| `_OrderDetailSheet` (M3, optional) | `showModalBottomSheet` on row tap (legacy `mgrOrderDetail` @17037-17075): `📦` + id + `status · who` tag · full 6-step `_MiniTracker` · items/sum/step grid · קבלן/אתר/סטטוס rows · `קדם ל"…"` action (routes through the same `advance`) or a "✓ ההזמנה הושלמה ונמסרה" note | ✅ |
| 👥 `_CustomersTab` (M4) | `ConsumerStatefulWidget`; a LIGHT `ListView` (`bgLight`) over the LIVE engine — `ref.watch(managerCustomersProvider)` (orders grouped by buyer `who`) + `ref.watch(ordersEngineProvider)` (for distinct sites + live reflow). A faithful port of the legacy `renderMgrCustomers` (@index.html:16566-16607). Local `_filter` = `'all'` / `live` / `low` (the status filter, swapping the legacy free-text search) | ✅ |
| `_CustomerSummary` (M4) | WHITE `cardLight` strip — 3 stats (קבלנים = count / סך רכש = ₪Σspend / ניצול אשראי = Σused÷Σlimit %). Legacy `mo-summary` @index.html:16574-16578 | ✅ |
| `_CustomerStatusChips` (M4) | `הכל (N)` + a פעיל / אשראי גבוה chip per **populated** status (counts). Active chip = `brand` fill; tap sets `_filter`. A status that empties out falls back to `הכל`. Labels verbatim from the legacy `mc-pill` (@index.html:16592) | ✅ |
| `_CustomerCard` (M4) | WHITE `cardLight` card (legacy `mc-card` @16593-16604): `👷 name` + `N הזמנות · M אתרים` (M = distinct build-sites per buyer off the live orders) + a status `_StagePill` on top; then a `_CreditBar` + the line `ניצול אשראי: ₪used / ₪limit (pct%)`. `pct = min(100, round(spend÷credit×100))`; ceiling = `contractorCredit` (the deterministic hash in the analytics layer). Status (@16562): **פעיל** 0<pct<90 (green) / **⚠️ אשראי גבוה** pct≥90 (amber) / לא פעיל pct=0 (grey). Tapping opens the detail sheet | ✅ |
| 🔑 LIVE customers | the list is `managerCustomersProvider` over the engine's orders, so a **new contractor order placed on the engine (by ANY role) adds/updates a customer card here LIVE** — proven in `manager_dashboard_screen_test` (place an order → a 5th customer card appears; push a buyer >90% → "⚠️ אשראי גבוה") | ✅ |
| `_CustomerDetailSheet` (M4, optional) | `showModalBottomSheet` on card tap (legacy `mgrCustomerDetail` @16609-16643): `👷` + name + a status tag · orders/spend/pct grid · credit rows (מסגרת אשראי / נוצל / יתרה זמינה / אתרי בנייה) · the contractor's own orders (📦 id · ₪sum · stage pill), all off the same live engine. Read-only | ✅ |
| 🛠️ `_ManageTab` (M5) | `ConsumerStatefulWidget`; a LIGHT `ListView` (`bgLight`) — the intro banner + the W3 👷 אישורי עובדים section + a 5-section accordion (only one open at a time, local `_open` key, the legacy `mgrManageOpen`). A faithful port of `renderMgrManage` (@index.html:16645-16890) | ✅ |
| `_ManageIntro` (M5) | a soft `brand`-tinted banner: "🛠️ שליטה מלאה על אפליקציית הקבלן — כל שינוי מתעדכן מיידית." (legacy `mm-intro` @16650) | ✅ |
| `_ManageSection` (M5) | a WHITE `cardLight` accordion card — tappable header (emoji + title + sub + optional count badge + ▾/‹ chevron) revealing its body when open (legacy `mmSection` @16855). 6 of them now (👷 אישורי עובדים first, then the 5 verbatim tools) | ✅ |
| 👷 אישורי עובדים body (`_ApprovalsBody`/`_ApprovalRow`, W3) | the manager's LIVE worker-approval queue (the W3 cross-persona affordance) — `ref.watch(pendingApprovalTasksProvider)` (`review` tasks off the shared `workerTasksProvider`), with a count `_CountBadge` in the header. Each row: task name · `🦺 worker · 🕒 days · steps` · note · keyed **✅ אשר** (`approve-<id>` → `approve`, review→done; advances a bound order) / **↩️ דחה** (`reject-<id>` → `reject`, review→rejected). Empty → "🎉 אין משימות הממתינות לאישור." A worker "📸 שלח לאישור" surfaces a row here with no refresh; the decision reflects live on the worker screen. LIGHT only | ✅ |
| 🗂️ קטגוריות body (`_CategoriesBody`, M5) | the **LIVE** catalog category list — `ref.watch(managerAnalyticsProvider).catalogCategories` (sorted by count desc): header `קטגוריות פעילות (N)` + a `<cat> · <count> מוצרים` row per category + the verbatim hint "שינוי שם קטגוריה מעדכן את כל המוצרים שבה." (legacy SECTION 3 @16715-16729) | ✅ |
| ⚙️ הגדרות אפליקציה body (`_AppSettingsBody`, M5) | the 3 contractor-app config rows VERBATIM: תוספת משלוח אקספרס=₪80 (`EXPRESS_FEE` @11961) · מסגרת אשראי לקבלן=₪50,000 (`creditLimit` @11963) · שיעור מע״מ=18% (`VAT_RATE` @11941) + the verbatim hint (legacy SECTION 4 @16733). Display-only | ✅ |
| 🌳 עץ המוצרים body (`_ProductTreeBody`, M5) | an inline summary of the catalog product-tree (the legacy SECTION 1 prompt-edit has no backend here): the verbatim purpose + the live tree size (מוצרים בעץ / קטגוריות, from the same analytics map) | ✅ |
| 🏷️ מותגים ומחירים body (`_BrandsBody`, M5) | the brands list from `lib/data/brands.dart` (`kBrands`): header `מותגים (N)` + each brand's `emoji name` + tagline + product count (legacy SECTION 2 @16687) | ✅ |
| 🔬 בדיקות רגרסיה body (`_RegressionBody`, M5) | a `brand` action button "🔬 פתח מרכז בדיקות רגרסיה" → `Navigator.push(RegressionPanelScreen.route())` (the same target the old manager dial used) | ✅ |
| `managerCustomersProvider` | `Provider<List<ManagerCustomer>>` — `mgrCustomerList` over the engine's LIVE orders (`state/orders_engine.dart`) | ✅ |
| `managerTabProvider` | `StateProvider<int>` (0..3) — the active tab the `IndexedStack` reads | ✅ |
| `ManagerDashboardScreen.route()` | `MaterialPageRoute<void>` (the app's screen pattern) | ✅ |
| role picker → manager | `role_picker_sheet.dart` `_RoleRow.onTap` for `manager` now `Navigator.push`es `ManagerDashboardScreen.route()` (mirrors worker→`WorkerAppScreen`) **instead of** `activePersonaProvider='manager'`/`OpenDial.bs` (the old drill). Other personas unchanged. | ✅ |

Scope (M5): ONLY the 🛠️ tab body + the route call to `RegressionPanelScreen` — the orders engine
internals, the logic layer (read, not changed), the other 3 tabs (M2 = 📊 · M3 = 🚚 · M4 = 👥, all
done), the role picker, and the buyer/checkout flow are untouched. **The manager screen is now COMPLETE
— `_TabPlaceholder` was removed; no "בקרוב" remains anywhere.** The old BS-dial manager drill code below
remains (now unreachable via the picker) pending a later cleanup. Guard: `manager_dashboard_screen_test`
(30 — M1's six + M2's four + M3's six + M4's six + M5's seven [intro + 5 tool headers · 🗂️ LIVE category
counts · ⚙️ verbatim config rows · 🌳 inline tree summary · 🏷️ kBrands list · 🔬 routes to
`RegressionPanelScreen` · manage tab LIGHT/no-dark] + the COMPLETE/no-"בקרוב" + role-picker tests).

## 👔 Manager BS-dial → 📊 dashboard (`bs_dial_widget.dart` · `state/dial_state.dart` · `logic/manager_dashboard.dart`) — LEGACY drill (unreachable via picker as of M1)

The 👔 "מנהל המערכת" persona → לוח בקרה (`kManagerSections` → section `m-products`) has 5
`md-*` leaves. Tapping a leaf opens an INLINE `_ManagerMetricPanel` above the dial (R2 —
dial-drill, NO navigation) showing the REAL number derived in `manager_dashboard.dart`
(`managerAnalytics`, a verbatim port of `mgrAnalytics()` @index.html:12081-12126). State:
`bsMetricLeafProvider` (which `md-*` panel is open; tap toggles; any other dial action
clears it). The other dial leaves (children / `mm-regression` / etc.) are unchanged.

| Leaf (id) | Shows | Source getter | Status |
|---|---|---|---|
| 🚚 הזמנות פתוחות (`md-open-orders`) | `openOrders` (=4; orders not delivered, @12096) | `ManagerAnalytics.openOrders` | ✅ |
| 📦 מוצרים בקטלוג (`md-catalog`) | `catalogCount` (=54; non-accessory, @12110) | `ManagerAnalytics.catalogCount` | ✅ |
| 🧰 אביזרים נלווים (`md-accessories`) | `accessoryCount` (=148; `accessoryProduct:true`, @12107) | `ManagerAnalytics.accessoryCount` | ✅ |
| ✅ זמינים כעת (`md-available`) | `availableCount` (=202; STORE_STOCK all-true, @12122) | `ManagerAnalytics.availableCount` | ✅ |
| 🏪 חנויות פעילות (`md-stores`) | `storesLabel` (="3/3"; active/total, @12125) | `ManagerAnalytics.storesLabel` | ✅ |

The leaf row whose panel is open is rendered `active` (highlighted), so the user sees which
metric the panel belongs to; popping the persona/anchor or drilling into a child clears
`bsMetricLeafProvider`. Verified active in v5.93 (M1 — the 5 leaves no longer toast "בבנייה").

Guard: `bs_dial_manager_test` (5 leaves present · tap→inline panel with the real number ·
NO "בבנייה" · toggle closes) + `manager_dashboard_test` (the derivations, vs index.html).

### 👔 Manager BS-dial → 📦 הזמנות (M2)

The 👔 persona → 🚚 הזמנות (`kManagerSections` → section `m-orders`) has 6 `mo-*` leaves —
ONE per order-flow stage (`kManagerOrderFlow` @index.html:16943). Tapping a leaf opens an
INLINE `_ManagerOrderPanel` above the dial (R2 — dial-drill, NO navigation) listing the REAL
orders in that stage from `kManagerOrderSeed` (@index.html SYS_ORDERS_SEED) — each row is
`📦 id` / `who · site` / `items פריטים · ₪sum` (mirrors the legacy `mo-card` @17001-17014),
plus the stage's order count in the header. State: `bsOrderLeafProvider` (which `mo-*` panel
is open; tap toggles; opening a metric panel or any pop/drill clears it — order & metric
panels are mutually exclusive). `kManagerOrderLeafStage` maps each leaf id → stage;
`_kOrderStageLabel` is the verbatim Hebrew stage name (`ORDER_STAGE[st].label` @12041-12048).

| Leaf (id) | Stage | Shows | Status |
|---|---|---|---|
| 📥 התקבלה (`mo-new`) | `new` | order BS-1042 (יוסי כהן · מגדל הרצליה · 7 פריטים · ₪1240) | ✅ |
| 🔧 בהכנה (`mo-preparing`) | `preparing` | order BS-1041 (אבי מזרחי · דירה — רמת גן · 3 · ₪680) | ✅ |
| 📦 מוכן לאיסוף (`mo-ready`) | `ready` | order BS-1040 (משה אברהם · וילה — סביון · 12 · ₪3150) | ✅ |
| 🚛 נאסף (`mo-pickup`) | `pickup` | **empty** → "לא נמצאו הזמנות תואמות." (0 in seed) | ✅ |
| 🚚 בדרך לאתר (`mo-transit`) | `transit` | order BS-1039 (דוד לוי · משרדים — תל אביב · 4 · ₪420) | ✅ |
| ✅ נמסר ✓ (`mo-delivered`) | `delivered` | **empty** → "לא נמצאו הזמנות תואמות." (0 in seed) | ✅ |

The empty text "לא נמצאו הזמנות תואמות." is the legacy `md-empty` line (@index.html:16986).
Guard: `bs_dial_manager_orders_test` (6 leaves present · each populated stage → its real order
row · the 2 empty stages → empty text · metric/order mutual-exclusion · NO "בבנייה").

### 👔 Manager BS-dial → 👥 לקוחות (M3)

The 👔 persona → 👥 לקוחות (`kManagerSections` → section `m-customers`) has 2 `mc-*` leaves —
ONE per customer status filter (the legacy `status` @index.html:16562). Tapping a leaf opens an
INLINE `_ManagerCustomerPanel` above the dial (R2 — dial-drill, NO navigation) listing the REAL
customers in that status from `mgrCustomerList` (manager_dashboard.dart, grouping index.html
SYS_ORDERS_SEED by buyer) — each row is `👷 name` / `orders הזמנות · sites אתרים` / status pill /
`ניצול אשראי: ₪spent / ₪credit (pct%)` (mirrors the legacy `mc-card` @16593-16604), plus the
status's customer count in the header. State: `bsCustomerLeafProvider` (which `mc-*` panel is
open; tap toggles; any other dial action / pop / drill clears it; metric/order/customer panels
are mutually exclusive). `kManagerCustomerLeafStatus` maps each leaf id → status; `pct`/`status`
+ the distinct-site count `sites` are derived exactly as the legacy `mgrCustomerList`
(@16554,16559-16562).

| Leaf (id) | Status | Customers (verbatim from `mgrCustomerList`) | Status |
|---|---|---|---|
| 🟢 פעיל (`mc-live`) | `live` (0<pct<90) | all 4 seed buyers — e.g. משה אברהם (1 הזמנות · 1 אתרים · ניצול אשראי: ₪3,150 / ₪71,100 (4%)), יוסי כהן · אבי מזרחי · דוד לוי | ✅ |
| ⚠️ אשראי גבוה (`mc-low`) | `low` (pct≥90) | **empty** → "לא נמצאו קבלנים תואמים." (no buyer ≥90% with the Dart credit ceilings) | ✅ |

The empty text "לא נמצאו קבלנים תואמים." is the legacy customer `md-empty` line
(@index.html:16586). Guard: `bs_dial_manager_customers_test` (2 leaves present · mc-live → its
real customer rows · mc-low empty → empty text · metric/order/customer mutual-exclusion ·
NO "בבנייה").

### 👔 Manager BS-dial → 🛠️ ניהול (M4 — final wave; manager persona COMPLETE)

The 👔 persona → 🛠️ ניהול (`kManagerSections` → section `m-manage`) has 5 `mm-*` leaves, ALL
wired to their REAL target — a faithful port of the legacy `renderMgrManage`
(@index.html:16645-16743). After M4 the manager persona has **ZERO reachable "בבנייה"** in any of
its four sections (md/mo/mc/mm). Two leaves are DATA views → an INLINE `_ManagerManagePanel` above
the dial (R2 — NO navigation), state `bsManageLeafProvider` (tap toggles; any other dial action /
pop / drill clears it; metric/order/customer/**manage** panels are mutually exclusive). Two leaves
are server actions → a labelled toast (the legacy `prompt()` editors have no backend here). One
leaf routes. The partition `kManagerManageDataLeafIds` ∪ `kManagerManageActionLeafIds` ∪
`{mm-regression}` covers every leaf with no overlap, so none can fall through to the stub.

| Leaf (id) | Kind | Real target (verbatim, NO "בבנייה") | Status |
|---|---|---|---|
| 🌳 עץ המוצרים (`mm-trees`) | server action | toast "🌳 עריכת האביזרים המשלימים של כל מוצר" (legacy `mmSection` sub-title @16653) | ✅ |
| 🏷️ מותגים ומחירים (`mm-brands`) | server action | toast "🏷️ עריכת המותגים והמחירים של כל מוצר" (legacy sub-title @16687) | ✅ |
| 🗂️ קטגוריות (`mm-cats`) | data view | inline panel: `קטגוריות פעילות (14)` + every category + `N מוצרים` from `kManagerCatalogCategories` (legacy SECTION 3 @16716) + hint "שינוי שם קטגוריה מעדכן את כל המוצרים שבה." | ✅ |
| ⚙️ הגדרות אפליקציה (`mm-settings`) | data view | inline panel: תוספת משלוח אקספרס=₪80 (`EXPRESS_FEE`@11961) · מסגרת אשראי לקבלן=₪50,000 (`creditLimit`@11963) · שיעור מע״מ=18% (`VAT_RATE`@11941) + the legacy hint | ✅ |
| 🔬 בדיקות רגרסיה (`mm-regression`) | route | `RegressionPanelScreen.route()` — **UNCHANGED** (closes the dial; no panel/toast) | ✅ |

The settings values are the legacy editable globals (read-only here — the `prompt()` editors are
server actions, R8: no invented mutation); the credit line uses comma grouping to mirror the legacy
`creditLimit.toLocaleString()` (@16736). Guard: `bs_dial_manager_manage_test` (12 — 5 leaves
present · mm-cats → its real categories+counts · mm-settings → its 3 real rows · mm-trees/mm-brands
→ the verbatim action toast (not "בבנייה") · mm-regression → still routes · metric/order/customer
mutual-exclusion both directions · the leaf-set partition).

## Catalog settings (`catalog_settings_screen.dart` → `catalog_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| שמור היסטוריית חיפוש | gates recording recent searches; recents persist across launches via `recentSearchesProvider` (`addRecentSearch`, key `bs.recent-searches.v1`) | ✅ |
| סרגל מיון מהיר במוצרים | shows/hides the "מיון לפי" control | ✅ |
| גודל תמונות | product image size (small/med/large) — list rows (image column w/h) **and** grid cards (`gridCardImageMetrics`: image padding + emoji) | ✅ |
| מצב קומפקטי | product row height/margins (list) **and** grid card name-box/paddings | ✅ |
| הנפשות מופחתות | disables explode/diagram/pulse animations (app-wide) | ✅ |
| ניגודיות גבוהה | high-contrast theme (app-wide) | ✅ |
| גודל טקסט | global text scale (app-wide) | ✅ |
| סוג תצוגה (רשת/רשימה) | product grid ↔ list | ✅ |
| עמודות בתצוגת רשת | grid column count | ✅ |
| ניקוי היסטוריה / איפוס | clears recents / restores defaults | ✅ |
| מחירים/מע"מ/מטבע/מחיר-יחידה/השוואה | — | ⛔ no price data |
| דירוג/מרחק/ספקים מקומיים · AI×4 · יחידות/עשרוני · מיון-ברירת-מחדל · רדיוס | — | ⛔ no data/engine |

## Bottom nav (Benzi #3) — `home_shell._BottomNav`

4 tabs: **🏠 בית** (0, `CatalogScreen` on the "הכל" window) · **▦ מחלקות** (1,
`DepartmentsScreen`) · **🔔 עדכונים** (2, `UpdatesScreen` = התראות + שיחות merged
under a toggle `updatesSubTabProvider`) · **🛒 חנות** (3, `StoreScreen`). Cart =
floating FAB (hidden on חנות). Tapping בית resets the catalog to 'הכל' unscoped;
tapping מחלקות returns to the grid.

## Departments home (`departments_screen.dart` — Benzi #2/#3)

The **מחלקות** tab (bottom-nav index 1): a 2-col grid of 9 departments
(verbatim names). The two plumbing departments open a **fixtures-vs-pipes**
layout (Benzi #1 reframed, v5.96 — `category_division.dart` / `_DeptCatGroups`):
**small headings, each followed by its category rows** (no super-category to
drill into); a row tap drills into that category via `catalogTreePathProvider`.
- **ברזים וסניטריים** → 🚽 כלים לבנים (אסלות) · 🛁 כלים גמר (faucets · showers ·
  accessories) — `isCatalogDept` true.
- **אינסטלציה** → 💧 צינורות מים (PPR · copper · garden · transit valves ·
  manifolds · multilayer) · 🟤 צינורות שפכים (drainage · SmartLock · toilet
  branches).
A genuinely-mixed top-node splits per leaf (ברז-כיור→גמר but ברז-מעבר→מים); pure
families (PPR/SmartLock/אסלות) collapse to one drill-in row. **Dual-system
fittings** (אטמים ופקקים · חבקי תליה/צינור · עוגנים ובנדים · סטי הידוק, v5.97)
appear under **both** מים and שפכים headings — they fit either pipe. Supersedes
the old department-level `WaterSystem` filter. Guarded by `category_division_test`.
**v5.97 (בנצי #2):** `_CatGroupRow` dropped its trailing `Icon(Icons.chevron_left)`;
the orange product-count badge is now the row's END element (where the chevron was).
Row stays tappable (`InkWell` → `catalogTreePathProvider = [node]`).

**Tool departments (v5.83 — gather every real tool category):** a full audit (all
99 leaf categories) confirmed the catalog is 100% plumbing, so the only genuine
tool data backs two live tiles via `toolCats` (leaf `categoryHe`) →
`_toolDeptPath` (synthetic drill node, no system scope): **כלי עבודה ידני** →
`כלי עבודה` (2 wrenches) + `חותך צינורות` (2 cutters) · **כלי עבודה חשמלי** →
`כלי ריתוך PPR` (35 welding machines/drivers). Fitting-like cats stayed out
(מכשירי לחץ/מנגנונים/סטי-הידוק). The remaining **5** trades (חשמל · חומרי בניין ·
צבע · גבס · אספקה טכנית) → "בקרוב" toast (R8: no data) — guarded by
`departments_test`.

A `_DeptScopeBar` over the catalog names the active scope + a "כל המחלקות" clear.
Re-tapping the מחלקות tab (or the bar's clear) resets all three providers → grid.

**Flat "all products" per branch (Benzi #5, v5.86):** the scope bar also carries a
**"כל המוצרים" ↔ "קטלוג"** toggle (`deptFlatProductsProvider`) — "כל המוצרים"
swaps the catalog for ONE flat `LipskeyProductsList` of the whole branch
("ברצף, ללא קשר לקטלוג"). Scope = `departmentProducts`: water dept = all its
in-system products (`filterBySystem`), tool dept = all its `toolCats` products.
Resets on department open + clear. Guarded by `departments_test`.

## Catalog search panel tools (`catalog_screen.dart` · `_SearchToolsRow`)

> **חלוקת מערכת (Benzi #1) — option 2, דרך ה-finder:** מחלקה חיה קובעת
> `catalogSystemFilterProvider` ופותחת את ה-finder (בית) מסונן. הלוגיקה ב-
> `logic/system_division.dart` (משותף ל-catalog+finder, ללא back-import):
> `productDivisionSystems` (`VerifiedSpec.endSystems` supply=נקיים/drainage=שפכים
> → PPR=נקיים → שאר=שפכים), `filterBySystem`, `nodeHasSystem` (מתקנים בשני
> הצדדים; שאר לפי דומיננטיות). **פאזה 1:** finder (groups ריקים מוסתרים) +
> tree-drill + search. **פאזה 2 (v5.70):** קטגוריות + הכל + מועדפים —
> `_catsForSystem` (קטגוריות לפי `nodeHasSystem` הדומיננטי) · `filterBySystem`
> (מוצרים). **שורות הקטגוריה חיות (v5.79):** `_categorySummary` נותן לכל שורה
> ספירת-מוצרים אמיתית פר-מערכת (badge) + תיאור מתת-הקטגוריות שבמערכת — במקום
> ה-`_kMeta` הסטטי שהיה זהה בכל המחלקות. **פאזה 2b (v5.71):** עץ חכם — `filterSmartBySystem`/`smartProductSystems`
> ממפים את ה-SKU של מותגי ה-SmartProduct חזרה לקטלוג (לא-פתיר → נשאר בשני
> הצדדים, R8). **פאזה 3 (v5.71):** בורר המערכת הכפול (`sysOpt`) הוסר מגיליון ⚙️
> פילטרים — המערכת מגיעה רק מהמחלקות (source-of-truth אחד). **כל סקשני ה-browse מסוננים.**

| Tool | Behavior | Status |
|---|---|---|
| 🎤 קולי | `VoiceService.listen` (browser speech) | ✅ |
| 📷 ברקוד | `openBarcodeScanner` (כפתור: "הפעל מצלמה" — verbatim ← Preact `submenu-barcode`) | ✅ |
| ⚙️ פילטרים | sheet → `searchImageOnlyProvider`; live results filtered by `filterByImage` (הכל / עם תמונה בלבד) | ✅ |
| ↕️ מיון | sheet → `catalogProductSortProvider` (`_sortProducts`): ברירת מחדל / שם א-ת / שם ת-א / מק"ט, applied to live results | ✅ |
| ▦ קטלוג | closes the panel + jumps to the קטגוריות section | ✅ |
| filter "עם מחיר" / price sort | — | ⛔ no price data |

## Catalog search — product matching (`catalog_screen.dart` · `catalogProductMatchesQuery`)

| Behavior | Detail | Status |
|---|---|---|
| forgiving product search | matches across name + category + colour word-by-word (order-independent); folds Hebrew gershayim/geresh (״ ׳ → " ') so a Hebrew-keyboard size query matches; expands everyday words via `kSearchSynonyms` (kept precise — e.g. שירותים → toilet fixtures only, not branch connectors); AND-match with a graceful any-word fallback (`requireAll:false`) so a reasonable query never dead-ends. **SKU (v5.89):** matched separately, only for queries ≥5 chars — a short numeric size query (`20`/`200`/`3000`) no longer substring-matches an unrelated SKU (`200` inside `120011`), which used to make 55% of `"20"` results SKU-coincidence noise. Guarded by `search_sku_pollution_test`. | ✅ |
| relevance ranking | default order sorts results by `searchRelevance` (name match > category-only > synonym/colour), so the product the user meant surfaces first; an explicit ↕️ sort overrides it | ✅ |
| word-completion (Benzi #6) | `searchSuggestions` → `_SearchSuggestions` chip row above the results: **completes the word being typed from catalog PRODUCT-name words** ("השלמת מילים לפי מוצרים") — last whitespace-token is the fragment, suggestions are distinct product words it prefixes, ranked frequency → א-ת, capped at 6, keeping the already-typed words (`מח` → מחסום·מחבר·מחזיק); respects `catalogSystemFilterProvider`; ≥2-char fragment in a product scope. Tapping fills `searchQueryProvider` → results re-run. Guarded by `search_suggestions_test` | ✅ |

## Catalog בית — finder home (`finder_screen.dart`)

| Behavior | Detail | Status |
|---|---|---|
| default landing | `catalogSectionProvider` defaults to `'בית'` — the app opens straight on the finder home (`active=='בית' ⇒ FinderScreen`), the least-technical path to a product | ✅ |
| type groups | `kFinderGroups` — 8 plain-language groups + אחר catch-all; groups are pairwise disjoint and every catalog product is reachable. Each row shows `desc` (plain-Hebrew description) + a product-count badge, same idiom as the קטלוג category rows | ✅ |
| group glyph | `finderGroupGlyph(label)`: each home group circle (+ breadcrumb) renders a designer 3D product icon — `kFinderGroupImage` (label → `assets/lipskey/categories/{faucets,toilets,shower_bath,drainage,pipes,garden,connectors,clamps,ppr,other}.png`), with an `errorBuilder` fallback to a Material icon `kFinderGroupIcons`/`finderGroupIcon`. Replaces the empty-box emoji canvaskit's font can't draw. Guarded by `finder_group_icons_test` (every group mapped, images+icons unique). | ✅ |
| sub-types | curated `kFinderSubs` (ברזים · ניקוז) cover every group category that has products, with unique labels and no 1-item junk chips; other groups auto-derive sub-types from `categoryHe`, merged by cleaned label | ✅ |
| narrow chips | `_narrowOptions`: curated facets (`kFinderFacets` — incl. floor-drain open/closed/shower words instead of opaque DN codes) → sizes (`_sizeRe`; confusing inch forms folded to clean fractions, e.g. 11/4"·1.25" → 1¼") → colours → distinguishing words | ✅ |
| results | render through the shared `LipskeyProductsList` (variant dedup + quantity wheel) | ✅ |
| chip-row scroll hint | `_ChipScroll` wraps every narrow chip row (סוג/גודל/זווית): when chips overflow, a soft edge-fade + ‹ chevron (`Key('chip-scroll-more')`) appears on the END edge (left in RTL) and hides once scrolled to the end / when nothing overflows — so clipped chips are discoverable | ✅ |
| letter-size axis | `_letterBar`/`_letterOptions` + `letterSizeTokens` (`_size_norm.dart`): a secondary `'מידה'` chip row (S/M/L…) appears when a pool has >1 letter sizes (e.g. clamp collars `אוגן כפול M`/`S`), co-filtering with גודל + זווית. Excludes the `L=` length prefix (gray pipe `L=50 ס"מ` is not a size). State `_letter`, reset on group/sub/back nav. | ✅ |
| wall-thickness axis | `_wallBar`/`_wallOptions` + `wallTokens` (`_size_norm.dart`): a secondary `'עובי'` chip row appears when a cross-dim pool has >1 distinct wall (`20×2.8` vs `40×5.5`). PPR/multilayer pipes ship the SAME OD at different walls (PN ratings — verified: 9/13 ODs have ≥2 walls), so wall narrows beyond the גודל (OD) axis. Co-filters with size/angle/letter. State `_wall`, reset on nav. | ✅ |
| chip display contract | one shared path keeps the filter chip and the product-card chip identical: `displaySizeLabel` (label text — P9/P12/P13) + `chipLabelDirection` (LTR for digit labels so `40×60` doesn't RTL-flip — P16). Drift is guarded by `finder_card_consistency_test` (finder chip set ⊆ card chip set over the whole catalog). | ✅ |
| secondary-axis orphan guard | `finder_card_consistency_test` extended: the three secondary axes (זווית/מידה/עובי) are derived only from the name, so every chip they surface must be literally visible on the card. Audit 2026-06-02: 0 violations; three guards lock it in. | ✅ |
| size-chip substring false-match (v5.86) | `_productHasChip` matches a chip by structural size/angle token, then falls back to `nameHe.contains(chipLabel)` for curated-facet PLAIN-WORD chips. That fallback is now gated to digit-free labels — it used to fire for digit chips too, so `5"` matched `1.25"`, `50 מ"מ` matched `250 מ"מ`, `2"` matched `1/2"` (a size filter surfacing larger sizes it isn't). Global false-positive upper bound 350→0. Guarded by `finder_filter_falsematch_test`. | ✅ |
| mm-token dedup reachability (v5.87) | `dedupLengthByMm` collapses equivalent LENGTH chips (cm≡meters, P11), but it also merged the `mm` family — which is usually a DIAMETER (`250 מ"מ` head) or cross-dim OD (`16×20`), not a length. `250 מ"מ` collapsed into `25 ס"מ` and `16×20` into `16×16`; since `_productHasChip` matches by exact label, every product carrying the collapsed-away label became unreachable by the surviving chip (328 catalog-wide). Fix: `mm` dropped from the length-dedup rank — mm tokens each stay their own chip. dedup-missed 328→0. Guarded by `finder_dedup_reachability_test`. | ✅ |
| tokenizer agreement — leading fraction (v5.88) | `isSizeToken` (card word-classifier) required a leading digit, rejecting a bare `½"` that `parseSizeTokens` (finder) accepts — so on the Lipskey `_NameWords` path `½"` would render as a plain link not a size chip, and `productListDedupeKey` wouldn't strip it. No product triggers it today (the lone `½"` is a חוליות hierarchy card), but the asymmetry was latent. Fix: `isSizeToken` accepts a leading fraction glyph; the two tokenizers now agree. Full suite 1061/1061. Guarded by `finder_tokenizer_agreement_test`. | ✅ |
| dims-DN chip on card (v5.84) | the finder surfaces a גודל chip from `tokensFromDims(dims)` (DN/length) even when the name has no size — but `_NameWords` (Lipskey card) previously showed only name words + length, so fittings (ברכיים/אטמים/מכסים) filtered by DN landed on a card with no visible size, and the collapsed DN variants (cycled via the "N/M" family badge) looked identical. Fix: `_NameWords` adds a gray informational DN chip from `tokensFromDims` for each `dnDiameter` whose label isn't already a name size-chip — mirrors the finder exactly (incl. showing BOTH `4"` from name AND `DN110` from dims). `_grayInfoChip` helper shared by the DN + length chips (adds `chipLabelDirection` LTR). | ✅ |
| dims-DN chip on hierarchy card (v5.85) | the חוליות/PPR card path (`_HierarchyChips`) shows a name-derived breadcrumb, so covers/risers/grates whose bore lives ONLY in dims (e.g. `הגבהה`/`מכסה`/`רשת` → DN98/DN104/DN111) had no visible size while the finder filtered them by DN. Fix: `_HierarchyChips` appends a gray stacked "מידה" DN pill from `tokensFromDims` **only when the breadcrumb carries no size of its own** — so a PPR valve (name states the OD, e.g. `20`) never gets a second, possibly-inconsistent dims-DN (PPR dims DN is unreliable: a `50` valve carries DN63). Cards with no visible size: 18→1. The lone remainder (`סט פקקים…½"`) is a `parseChips` gap — it doesn't surface a leading-fraction `½"` the way `parseSizeTokens` does (tokenizer asymmetry, 1 accessory). Guarded by `card_dims_dn_chip_test` (4: Lipskey DN · חוליות hierarchy DN · PPR no-dup · name-size no-dup). | ✅ |
| Lipski → `_HierarchyChips` (gate 117 follow-up, v6.09) | post PDF-data sync (9/9), Lipski cards route to the same hierarchy breadcrumb as Polyroll/חוליות (`lipskey_products_screen.dart:1176`). `parseChips` got compound-type lookahead (`מיכל הדחה` / `מושב אסלה`) + Lipski model vocab (ספיר/ברקת/טופז/יהלום/טיטאן/כנרת/חרמון/אדיר/תבור/כרמל/הגייני) + `87°` shape + `סגירה רכה` / `אנטי ונדליזם` / `ציר ניירוסטה` compound features + `(מס. 1)..(מס. 9)` kitchen-sink variants + `DN\d+` size prefix for pipes. AQUATEC stays on `_NameWords` (no structure). Guarded by `lipskey_hierarchy_parity_test` (18 SKUs · type+path) + `card_dims_dn_chip_test` (updated for v6.01 names). | ✅ |
| group-emoji glyph fallback | sites that showed a finder group emoji (🚰🚽🕳️ — empty box in canvaskit) now render an icon instead: product-sheet "נמצא ב" strip uses `Icons.travel_explore` (`_StripDef.icon`), and the catalog overview "מאתר" row drops the emoji (label only). Home circles already use `finderGroupGlyph` (I1). | ✅ |
| code hygiene (I10-partial) | `dart fix` sweep on `finder_screen.dart` + `_size_norm.dart` (44 mechanical fixes: trailing commas, redundant args, combinators ordering, unnecessary raw strings, omitted local types). Both files lint-clean. No user-visible behavior change. | ✅ |

## Chat settings (`chat_settings_screen.dart` → `chat_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| בוט (botEnabled) | enables the canned auto-reply | ✅ |
| חיווי הקלדה | shows "מקליד..." before a bot reply | ✅ |
| אישורי קריאה | sent ticks blue ✓✓ vs grey ✓ | ✅ |
| רטט (chatVibration) | haptic on send | ✅ |
| ברכת פתיחה | seeds a greeting in a fresh chat | ✅ |
| זמן מקוון אחרון (lastSeenPrivacy) | nobody → hides "פעיל כעת" + online dot (`showOnlinePresence`) | ✅ |
| מדיה/גיבוי/שפה/שעות-עסקיות/פרטיות/lock-preview/auto-archive/spam | — | ⛔ media/server |

## Chats screen (`chats_screen.dart`)

| Button | Behavior | Status |
|---|---|---|
| חיפוש / פילטר צ'יפים | filter thread list | ✅ |
| לחיצה על שיחה | opens conversation | ✅ |
| החלקה לארכוב + ביטול | archive/restore (persistent) | ✅ |
| תפריט ⋮ → שיחה חדשה | opens an empty conversation with the contact | ✅ |
| תפריט ⋮ → ארכיון שיחות | opens the archive screen (restore per row) | ✅ |
| תפריט ⋮ → השתק הכל / בטל | mutes/unmutes all threads (persistent, toggles label) | ✅ |
| תפריט ⋮ → הגדרות | opens ChatSettingsScreen | ✅ |
| שליחת הודעה | adds bubble (+ auto-reply if bot on) | ✅ |
| וידאו/שיחה/עוד · מצלמה/צירוף/אמוג'י/מיקרופון | — | 🚧 |

## Notifications (`notifications_screen.dart` → `notif_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| סוגי התראות: הזמנות/משלוחים/מבצעים/ירידות-מחיר | hide that category from the list (`notifMutedSections`) | ✅ |
| חשיבות (importanceFilter) | important/critical → only high-priority rows (`passesImportance`) | ✅ |
| snooze banner | mutes notifications temporarily | ✅ |
| push/email/sms/whatsapp · שעות-שקט · סיכומים · צליל/רטט · lock-screen · לפי-תפקיד | — | ⛔ no notif engine |
| 🦺/💰 פעולת-התראה (טפל כעת/פרטים) | **T6:** sheet inline (R9, `showNotifActionSheet`) — safety→`kSafetyTips`×5+אישור · budget→ספי 80/90/100% + סטטוס. מחליף toast 'בבנייה' | ✅ |

## Store (`store_screen.dart` → `store_settings.dart`)

| Setting / button | Behavior | Status |
|---|---|---|
| defaultPayment | seeds the cart payment method | ✅ |
| selfPickupDefault | seeds delivery = pickup | ✅ |
| vatInclusive | VAT shown embedded vs added; total adjusts | ✅ |
| minOrderAmount | blocks checkout below the minimum | ✅ |
| confirmLargeOrder + largeOrderThreshold | confirm dialog at checkout | ✅ |
| cart stepper (+ / − / לעגלה) | `qtyForKey` / `setQtyForKey` | ✅ |
| saveCartToProject | show/hide the cart project selector | ✅ |
| summary chips (פריטים בסל / הזמנות פתוחות / הצעות ספקים) | derived live: `cartItemCount` (cart+smart lines), `isOrderOpen` over `_kOrders`, offers single-sourced from the מכרז ספקים row badge | ✅ |
| לאן לשלוח (Benzi #4) | **one-time** non-binding popup `openShipToSheet` (TextField + דלג/שמירה), auto-opened by `home_shell`'s `smartCartProvider` listener on the **first product add** (cart 0→1) — NOT at checkout. Guard `shipToPromptedProvider` (default true for tests; seeded in `main()` via `loadShipToPrompted`, persisted via `saveShipToPrompted`). Address → `shipToProvider`. Guarded by `shipto_prompt_test` | ✅ |
| כתובות/חשבוניות/ספקים/השכרה/אחריות/ביומטרי/אשראי-יומי | — | ⛔ server/data |
| ההזמנות שלי → גיליון-הזמנה (T5) | מעקב-סטטוס חי (`_OrderTimeline` · 4 stages) + כפתור "📄 סרוק תעודת-משלוח" → toast (OCR=stub, §9d). Sheet `isScrollControlled` (QA — הכפתור היה חתוך) + תוכן ב-`SingleChildScrollView` (gate 32 — לא גולש במסכים נמוכים). | ✅ |

## Install Studio (`install_studio_screen.dart` → `logic/install_engine.dart`)

Entry: the catalog section chip **`'תכנון חיבור'`** (renamed from "תאימות" — a
self-explanatory name for non-technical users). Safety-checklist labels carry a
plain-Hebrew gloss with the technical term in parens (e.g. "ברז ערבוב נגד כוויה (TMTV)").

| Button | Behavior | Status |
|---|---|---|
| הוסף מוצר | append a chain anchor from the dark catalog picker | ✅ |
| **השלם התקנה** | linear `buildInstallation`, or `buildTreeInstallation` when a manifold is mid-chain (trunk → branches); dark BOM sheet with quantities, ⑂ branch count + outlet warning, gaps; "החל על הקו" applies it | ✅ |
| מטראז׳ צינור (− / +) | per-pipe length in metres; header totals "X מ׳ צנרת" | ✅ |
| טמפ׳ הקו | cycles 20/60/80°C (material suitability) | ✅ |

**Engine hardening (B1):** the bore engine (`_minBoreMmOf` · install_engine), the
pressure-drop estimator (`_boreMeters` · pressure_drop) and the spec sheet
(`engineeringSpecFor` · related_info) now share ONE BSP inch→mm const
`kBspInchToMm` (in `lipskey_verified_connections`) instead of three hand-copied
tables that could silently drift. `_autoAddCompliance.insertAt` guards
`items.length < 2`, so `buildInstallation([oneSupplyProduct], autoCompliance: true)`
no longer throws a `clamp(1, 0)` ArgumentError. Both locked by
`install_engine_hardening_test`.

**Engine safety (B2):** (P2.4) `_findBridge` (the name-inference fallback used
when the verified BFS finds no path) now refuses to bridge across plumbing
systems — `productSystems(from) ∩ productSystems(to)` must be non-empty, matching
the BFS's own isolation. A probe found 0/3600 reachable cross-system bridges
today, so this is defence-in-depth; `install_engine_safety_test` enforces the
invariant going forward. (P2.5) `manifoldOutlets` classifies a manifold by the
catalog taxonomy (`'מחלקים'` / `productType 'מחלק'`), not by raw end-count — a
tee/מסעף with 3 same-size ends (e.g. `116565`) is no longer mis-read as a
3-outlet manifold (now 0). Real manifolds keep their outlet counts (4/2/4).

**Drainage slope (P3.9):** the BOM sheet showed the supply-only "עלייה אנכית /
ירידת לחץ" block for EVERY line. Now it's gated on `lineIsSupply(plan.items)`:
a supply line keeps the pressure-drop check; a **drainage** line instead shows a
slope block — "אורך אופקי" + "מפל אנכי" sliders feeding the existing
`checkDrainageSlope` (pressure_drop) → "שיפוע ניקוז X%" with the ת"י-1205 verdict
(green ≥ 2%, amber below). No invented values — the function and the 2% standard
already existed (covered by `pressure_drop_advanced_test`); P3.9 only wires them
into the drainage UI.

**Connection validity — terminal devices (B4):** the engine validated geometry +
material + cross-system isolation, but treated almost every non-ceramic device as
a pass-through connector — so it accepted physically-invalid chains a plumber
rejects. Now TERMINAL devices are `FlowRole.fixture` (endpoint-only, never
auto-inserted): traps (`סיפונים`/`מחסומים גלויים`), floor/roof drains
(`מחסומי רצפה`/`מאספי רצפה`/`תעלות ניקוז`/`ניקוז גג`/`מאספים וקולטים`), and supply
draw-off taps (`ברזי מטבח`/`כיור`/`קיר`/`אמבטיה`/`גן`/`דלי`). A line carries at
most ONE terminal: two-on-one (double-trap, two taps in series, two floor drains)
is rejected in `findShortestPath`/`_findShortestPathExcluding`/`_findBridge`, and a
pair separated by connectors (`trap→pipe→trap`) is caught at the line level in
`buildInstallation` (records a gap → `isComplete=false`, so "התקנה שלמה" no longer
overclaims). In-line valves (`ברזי מעבר`) stay connectors; shower components
(`מערבל→זרוע→ראש`) are deliberately left for a later finer model; flow-direction
for check/backflow valves is the next step (B5). Locked by
`install_engine_safety_test`; `audit40` cases 3/15/23/35/39 — which had encoded the
two-terminal bug as *valid* — were flipped to expect no-path.

**Engine round-2 fixes (B5):** (E1) the galvanic dielectric requirement now fires
between dissimilar metal GROUPS — copper-group (נחושת/פליז) joined to iron-group
(פלדה/נירוסטה) — via `_galvanicallyDissimilar`, used by both `lineComplianceChecklist`
and `_autoAddCompliance`. The old predicate required copper specifically (missed
brass↔steel) and omitted stainless; benign copper↔brass is no longer over-flagged.
(E8) shower spray OUTLETS — `ראשי מקלחת` (heads) + `מזלפי יד` (hand-sprayers) — are
now `_terminalCats` (endpoint-only), while `זרועות דוש` (arms) + `ברזי מקלחת`
(mixers) stay connectors so the real mixer→arm→head chain still builds. Locked by
`install_engine_b5_test`.

**Spec-data fixes (B6):** (E6) `224156` (PP-MD-ML DN110 drainage pipe) maxTempC
80→70 to match its identical family (224345/224169/… all 70) — was an outlier that
made the engine accept it but reject its identical siblings on a ~71-80°C line.
(E3) reducing branch tees had their larger DN erased (ends flattened to all-DN50):
`116558` (מסעף 110/50) → [110,110,50], `217533` (75/50) → [75,50], `218564` (מסעף
כפול 110/50/50) → [110,50,50] — so the real DN110/DN75 joints connect and a DN50
pipe no longer mates a physically large socket. DNs taken from the product names.
Locked by `install_engine_b6_test`. (A broader flattened-DN sweep — מצרה 50/40,
40/32, 110/100, 50/32 — is tracked for B8.)

**Manifold over-capacity cap (B7/E5):** `buildTreeInstallation` used to route EVERY
branch target even past the manifold's physical outlet count — emitting phantom
branches (each with its own TMTV/balancing valve) off ports that don't exist, and
miscounting over-capacity from the raw target list. Now branches are CAPPED at
`manifoldOutlets`: the overflow targets become gaps (so `isComplete` is false) plus
an explicit over-capacity warning, and TMTV/balance are added only per actually-
routed branch. Within capacity, behaviour is unchanged. Locked by `manifold_test`
case 10 (now builds a 4-branch-on-2-outlet tree). The studio UI banner is fixed too
(B12, #5): `_assemble` counts only real branch targets (≠ the manifold), and the
over-capacity banner now reads "$branches ענפים על מחלק $outlets-יציאות — N לא חוברו
(חסר במחלק)" — the accurate requested / capacity / overflow. Verified live (build
web + browser: a 3-branch line on a 2-outlet manifold showed "1 לא חוברו"). visual_log.

**Flattened-DN data sweep (B8):** a class of reducers/couplers/caps had their
verified-spec ends lazily defaulted to a single DN (mostly [50,50]) regardless of
the product name, so the engine accepted wrong-size joints and rejected the real
ones. Restored from the names: reducers `218568`(50/40)/`220316`(40/32)/
`116680`(50/32), `194897`(110/100), coupler `218567`(160/160), and single-ended
caps `218569`(110)/`218460`(50)/`218560`(160)/`220315`(40). Full suite (1569) stayed
green — no test had encoded these wrong joints. Two ambiguous items (`116203`
"40/49", thread-side elbow `116207` "32/32") were left for human confirmation.
Locked by `install_engine_b8_test`.

**Backflow / vacuum-breaker (B10/E7):** a garden tap / hose outlet (`ברזי גן`) on a
supply line can back-siphon dirty water into the potable supply; code requires a
vacuum-breaker. `lineComplianceChecklist` now surfaces this as a WARNING-severity
check ("שובר-ואקום למניעת זרימה-חוזרת") instead of silently passing. It is
intentionally UNSATISFIABLE — no vacuum-breaker SKU exists in the catalog, so it
cannot be auto-inserted and stays a warning (no `criticalOpen` impact). Adding a
real VB product is flagged for the user. Locked by `install_engine_b10_test`.
(E4 note: the high-value auto-compliance fix — auto-adding the dielectric union for
the steel expansion tank — already shipped in B5; TMTV line-sizing was evaluated
and dropped as a practical no-op since every fixture line carries a ½″≈DN15 outlet,
and the PRV has no DN variants to size.)

**Directional-valve orientation warning (B11/D4):** check valves (אל-חזור/אלחוזר)
and sewage backflow preventers (category `אל חזור`) are one-way devices, but the
model stores their two ends identically — so the undirected engine cannot reject a
backwards mount (`deep_audit` even asserts path symmetry). The checklist now WARNS
("כיוון התקנה — שסתום חד-כיווני", warning severity) when a line contains such a
device, surfacing the orientation hazard for manual verification. This is the safe
increment; full orientation ENFORCEMENT (a per-end inlet/outlet `port` on
ConnectorEnd + a direction-aware search + relaxing the symmetry invariant) is a
larger architectural change deferred for design review. Locked by
`install_engine_b11_test`.

**Per-device directionality guidance (B13/#1):** the single generic warning is now
ONE check PER directional valve — `lineComplianceChecklist` emits
"כיוון התקנה: <valve name>" with `_directionalContext` stating where it sits
("בין <upstream> ל-<downstream>"), so the installer knows exactly which valve, and
between which two parts, to orient for flow. (True rejection of a backwards mount
remains impossible — a check valve's two ends are physically identical, so
orientation is an install choice the parts list can't encode; the engine pinpoints
and guides rather than enforces.) Locked by `install_engine_b13_test`.

---

## Verified by regression (`test/wiring_test.dart`)
- cart `qtyForKey` / `setQtyForKey` (sum, collapse, remove-at-0)
- store `cartPaymentProvider` / `cartDeliveryProvider` defaults from store settings
- `notifMutedSections` mapping (all-on → none; per-type off → matching section)
- chat mute notifier (`setAll`) and archive notifier (`archive`/`restore`)
- finder grouping: groups disjoint, אחר catch-all + no blank category, curated
  `kFinderSubs` cover every group category w/ products, unique labels, cats ⊆ group
- `catalogProductMatchesQuery`: category-word match, synonym expansion,
  `requireAll:false` graceful superset, colour searchable, שירותים precision
  (no connector match), `searchRelevance` ranks name-match above synonym-match

UI-only effects (theme/contrast/text-scale, grid layout, VAT display, image size)
are documented above but exercised through their underlying providers/helpers

---

## Dead code removed (step 9)

Symbols removed from `catalog_screen.dart` — never had callers, no visual impact:

| Symbol | Lines removed | Phase |
|--------|--------------|-------|
| `_MiniSearchPill` | ~22 | B ✅ |
| `_Chip` | ~37 | C ✅ |
| `_diameterSubGroups` + `_diameterCounts` + `_diameterBucket` + `scrollCtrl`/`subGroups` params + `_SectionBanner` | ~54 | D ✅ |
| `_CatalogDrillSection` cluster (P4+P5+P6+P7) | ~353 | E ✅ |

Total removed: ~466 lines. Kept: `catalogDrillCatProvider` (line 237) — used in smoke test `tabs.dart`.
rather than pixel rendering.

## Polyroll catalog spec routing (§22)
- `lib/data/polyroll_catalog.dart` `_pprSpecFor(categoryHe, nameHe, page)` returns
  the correct per-page or per-sub-type spec for each product. See
  `knowledge/CATALOG-CARD-PROTOCOL.md` §22.C/D/E/F for the full ruleset.
- p80 AQUATHERM AC blue pipes: kPprPipesAC → `spec_pprct_pipe.jpg` (was
  routing to `spec_faser_20.jpg` green by mistake; fixed in §22.F sweep).
- **§22.I — internal-card dims completeness:** `_acPipe` builder now injects
  `'מק"ט חוליות': sku` into its dims map (was missing for all 16 AC pipes,
  thinning the internal card vs. the catalog). Guard: spec_assets_test
  "§22.I every Polyroll product carries יצרן + at least one מק"ט" — sweeps
  the whole catalog, fails on any builder that skips the standard dim fields.
  mutation-verified by `scripts/mutation_verify.sh` (the protocolist's tool).
- §14 detection: `test/spec_assets_test.dart` enforces 36 routing rules
  including "every page lands on its own per-page crop or a legit shared one".
- All 74 catalog pages audited per §22.F mandatory audit checklist.

## External-card chip hierarchy (§21)
- `chip_hierarchy.dart` `parseChips(nameHe)` → breadcrumb [shape ‹ thread ‹ size];
  the title is the type noun. Angles (45°/90°) are shape, the diameter is the
  size — a digit-leading angle no longer steals the size slot.
- `lipskey_products_screen.dart` `_HierarchyChips`: display-only cleanup —
  `_chipDisplayLabel` strips wrapping parens, `_isNoiseChip` hides bare units
  (מ"מ). nameHe stays verbatim (R8); tap index maps back to the raw path level.
- §14: `spec_assets_test` · "§21 angle fittings keep the diameter as size".

## §21.A chip fixes (2026-06-01)
- Angle elbows keep diameter as size (sizeRe skips shape tokens); bare 45/90
  removed from shape set. Display: parens stripped, units (מ"מ) hidden.
- Multi-word phrase "למיקום נקודת מים" kept as one ordered chip (_l3Compounds).
- Guards: spec_assets_test "§21 angle fittings keep the diameter as size" +
  "§21 multi-word phrase stays one ordered chip".

## §21.B unit-fold — lossless recoverability (2026-06-01)
- `chip_hierarchy.dart` `_kChipUnits {מ"מ, mm}` + a parseChips branch fold the
  unit INTO the size chip (`l5 = '$l5 $t'`), so the size reads "20-63 מ"מ" and
  the full Polyroll name is recoverable from [type]+breadcrumb+material badge.
  'מ"מ' removed from kChipLevel3Feature (was being hidden as noise → dropped).
- Guard: spec_assets_test "§21.B every Polyroll name is fully recoverable from
  the chips" — behavioral, scoped to kPolyrollCatalog (no grep antipattern: מ"מ
  is a legit standalone token in lipskey_catalog, so a source grep can't tell
  the wrong placement from the right one). E2E result: 774/774 full recon.

## §21 chip picker (בורר) — works for Huliot (v5.95 — 2026-06-03)
- The faceted chip picker (tap a breadcrumb chip → swap that attribute for a
  sibling product) was dead for every Huliot product. Two bugs, lesson T4:
  - `lipskey_products_screen.dart` `_cycleHierarchy` drew siblings from
    `kPolyrollCatalog` → now `kCatalogProducts` (unified).
  - `chip_hierarchy.dart` `findHierarchySiblings` gated on a fixed
    `polyrollBrand` (returned `[]` for Huliot) → now gates on the product's
    **own** brand (same-brand siblings); the `polyrollBrand` param is removed.
- Behavior: tap a חוליות `ברך 45°` shape chip → picker offers `45°`+`90°`; size
  chip → `32/40/50/63`. Polyroll/PPR picker unaffected (same-brand still holds).
- Guard: `huliot_picker_test` (4) + mutation_verify on the brand gate.

## §21.C chip + picker level labels — primary/secondary/final clarity (2026-06-01)
- User: "אני נכנס לבורר בציפ אני לא יודע מה הוא בורר ראשי ומה משני ומה אחרון
  זה בבלגן." Chips were identical-looking pills, picker said "בחר ערך" generic.
- `chip_hierarchy.dart` `ChipPath.levelLabelOf(int) → String` maps a path index
  to one of {חיבור, צורה, תכונה, תבריג, מידה}. Two consumers:
  - `lipskey_products_screen.dart` `_HierarchyChips` — stacks each chip in a
    Column: 9pt grey level label on top + value pill below. RTL → "חיבור" reads
    first (primary), "מידה" last (final).
  - `lipskey_products_screen.dart` `_hierarchyPickerTitle` — picker header now
    reads "בחר חיבור:" / "בחר צורה:" / "בחר תכונה:" / "בחר תבריג:" / "בחר מידה:".
- Guard: spec_assets_test "§21.C every visible chip carries a semantic level
  label" — sweeps kPolyrollCatalog, asserts every non-noise chip gets one of
  the 5 allowed labels and the size chip always reads "מידה".
## Catalog lens selector (v5.44 — data layer)
- `lib/data/catalog_lens.dart` — `CatalogLens {category,variant,smartTree}`,
  `availableLensesForSet(products)` (which lenses are meaningful for a set;
  smart-tree hidden below 25% mapped — approach א), `groupByLens(products,lens)`
  (titled `LensGroup` buckets per axis), `setSupportsLens`.
- `lib/state/catalog_lens_state.dart` — `catalogLensProvider` (transient
  StateProvider, default category) + `resolveActiveLens(selected, available)`
  (falls back to first-available; never strands on an unavailable lens).
- Wiring status: data layer ONLY. The selector chips + list router (which read
  `catalogLensProvider` and render `groupByLens` output beside the existing
  grid/list + sort controls) are the NEXT step — not yet wired into
  `catalog_screen.dart`. Guard: `catalog_lens_test` (18 tests).

## Lens selector UI — step 3a (v5.46)
- `lib/screens/lens_selector_row.dart` — `LensSelectorRow(products:)` ConsumerWidget:
  a list-level chip row ("סדר לפי: 📂/🎚/🌳") that reads/writes `catalogLensProvider`
  and shows only the lenses `availableLensesForSet(products)` deems meaningful.
  Renders nothing when <2 lenses apply (category-only sets unchanged).
- Wiring status: widget BUILT + tested (`lens_selector_row_test`, 3 widget tests),
  NOT yet placed in a product-list screen. Placement into the product browse view
  (where `groupByLens` output renders) is step 3b.

## Lens selector — step 3b WIRED (v5.47)
- `LipskeyProductsList` (lib/screens/lipskey_products_screen.dart) now renders
  `LensSelectorRow` ABOVE the product list. Default lens = category → the
  original flat grid/list, unchanged. variant/smartTree → `_groupedList` renders
  `groupByLens` output: a `_LensGroupHeader` (title + count) per group, products
  as standard rows. The selector hides itself when <2 lenses apply.
- This is the user-visible activation of the lens feature (steps 1+2+3a).

## Lens selector — option א: smart-tree group = gateway (v5.48)
- Under the 🌳 smart-tree lens, each `_LensGroupHeader` in `lipskey_products_screen.dart`
  is now TAPPABLE → `openSmartProductSheet(context, smartProductForSku(first.sku))`,
  opening the rich SmartProduct card (install/compat/brands/BOM). Header shows a
  🌳 prefix + "פתח כרטיס ›" hint + Semantics(button). Category/variant headers
  stay non-tappable. Imports via `show` (openSmartProductSheet, smartProductForSku)
  to avoid circular-import symbol pollution.

## Lens selector — option א refined: per-row "כרטיס חכם" (v5.49)
- Under 🌳 smart-tree lens, each `_ProductRow` shows "כרטיס חכם" (was "פרטים")
  → `_openSheet` opens the rich SmartProduct card via openSmartProductSheet/
  smartProductForSku for THAT product's fixture (not a group-level gateway).
  Falls back to the standard Lipskey sheet when unmapped. `_LensGroupHeader`
  reverted to a plain label (🌳 prefix cue only, not tappable).

## cardReadinessScore — raised bar (v5.53)
- `related_info.dart::cardReadinessScore` expanded 5→9 dimensions so 100 reflects
  FULL smart-card readiness (spec+25 · connectivity+20 · ת"י+12 · install+13 ·
  acceptance+5 · compliance+5 · finder+5 · price+5 · variants+10). A spec'd
  connectable PPR fitting now reaches ~95 (was 90); fixture endpoints stay low.
  Guards: card_score_test (raised-bar group) + mutation_log.

## Score badge on internal card (v5.56)
- `lipskey_product_sheet.dart` header now renders the `cardReadinessScore` badge
  ("📊 ציון נתונים N · label", `scoreBandColors`) — same metric the smart card
  shows. Closes the gap: PPR/Lipskey products that open the INTERNAL card (not
  the smart card) now display their data-readiness score (PPR ~95).

## cardReadinessScore — quantity-aware (v5.57)
- `related_info.dart::cardReadinessScore` now grades by AMOUNT of knowledge, not
  binary presence (user: "לא תתסתכל על הכמות ידע שיש לו"). New/regraded terms:
  data-depth `p.dims.length` (≥8→15 · 4-7→10 · 1-3→5); connectivity (≥20→18 ·
  ≥5→12 · >0→6); install-tips / acceptance / compliance graded by item count;
  spec 25→20, finder 5→3, price 5→2. Effect: the PPR faser pipe (dims=11, richest
  but 0 mates) rises ~75→80 מצוין instead of being pinned by connectivity.
  Verified live-equivalent: PPR supply 98 · faser 80 · toilet seat 16 · trap 63.
  Guards: card_score_test (spec-weight 25→20) + mutation_log (dims `:0`→`:50`
  turns the seat "stays low" + "no single dim=100" guards red).

## cardReadinessScore — composite breadth+depth (v5.58)
- `related_info.dart::cardReadinessScore` now returns a COMPOSITE of two axes
  (user: "ציון משוכלל משני הצירים"), each ≤50, and exposes both sub-scores in
  the return record `({score, label, breadth, depth})`:
  • BREADTH — weighted presence of distinct knowledge KINDS (variety).
  • DEPTH — graded QUANTITY within the measurable kinds (dims/mates/tips/…).
  composite = breadth + depth (cap 100). Broad-but-shallow or deep-but-narrow
  products land mid-band; only broad AND deep reach מצוין. Callers
  (`lipskey_product_sheet.dart`, `catalog_screen.dart`) keep using `.score`/
  `.label` (named access — extra record fields are non-breaking).
  Verified: PPR supply 99 (b49/d50) · faser 75 (b41/d34) · seat 15 (b11/d4).
  Guards: card_score_test (spec→breadth≥10; composite==breadth+depth) +
  polyroll_score_test (pre-spec baseline ≤50) + mutation_log.

## Huliot SmartLock — P11 installKit parity (v5.83 — 2026-06-02)
- **`recommendedKitForProduct` קיבל ענף `if (p.brand == 'חוליות')`** ב-
  `lib/logic/install_kit.dart`: חותך-צינורות (רק ל-`kSmlPipes`) + מפתח-לאום
  SmartLock לפי DN bracket (≤40 → 61040360, >40 → 61060560). ענף תואם ב-
  `installKitFor` (`related_info.dart`) סופר tools.
- **תוצאה ב-UI:** product sheet של כל מוצר חוליות מציג עכשיו strip "ערכת
  התקנה" (📦) — צינור = tools≥2, fitting/nut = tools=1.
- 4 בדיקות P11 חדשות ב-`polyroll_e2e_test.dart` (קבוצה אחרי P6) +
  mutation_verify על ענף ה-Huliot. 1041 tests pass.

## Huliot SmartLock — hotfix R2-fallback (v5.80 — 2026-06-02)
- **באג שאובחן ע"י בנצי:** כרטיסי Huliot ב-web/release התרוקנו. שורש:
  89 photo crops + 83 spec crops לא הועלו ל-R2 bucket → CDN 404 →
  `CachedNetworkImage` זרק חריגה → build failed → כרטיס ריק.
- **תיקון זמני:** `_huliotImageFor` ו-`_huliotSpecFor` קיבלו flags
  `_routeCropDisabled` + `_specCropDisabled = true`. הכרטיס מציג עכשיו
  את עמוד-הקטלוג המלא (`page_NN.jpg` — כבר ב-R2) במקום crop. הרוטינג
  הקנוני נשמר ב-`_huliotImageForCrop` — flip של flag אחד מחזיר את
  ההתנהגות המקורית ברגע שה-crops יעלו.
- **§17.1 הוקל זמנית** ל"exists" בלבד (במקום "is a real crop"). **§17.1.b**
  עודכן לעבוד מול ה-routing table הקנוני, לא מול imageAsset הדינמי, כך
  שה-crops הקיימים על דיסק נחשבים legitimate (הם ה-deliverable ל-upload).
- **P10 בHULIOT_TODO** — הוראות upload + reversal steps.

## Huliot SmartLock — P3 spec crops פר-משפחה (v5.77 — 2026-06-02)
- `scripts/crop_huliot.py` הורחב: לכל band ש-`SPEC_PAGES` (31 עמודי-טבלה),
  מתחת לתצלום נחתכת **דיאגרמת חתך** (L/DN/W/t/H verbatim) → 83 קבצי
  `spec_sml_p{NN}_{tag}.jpg`. פטור: עמ' 24 (אביזרים), עמ' 27 (AQUA SLIM —
  hand-tuned).
- `_huliotSpecFor` עבר מ-`return null` ל-routing: מקבל את ה-tag
  מ-`_huliotImageFor` וממפה `spec_$img`. נופל ל-null עבור page-fallback +
  עמודי 24/27.
- **2 שערים חדשים/מורחבים:**
  - **§17.2-Huliot** (חדש) — every product with specImageFile → קובץ קיים פיזית.
  - **§17.1.b** הורחב לכלול גם `spec_sml_p*.jpg` ב-orphan scanning.
- 39 lint-infos `avoid_escaping_inner_quotes` נוקו ב-`dart fix --apply`
  (single→double quotes ל-strings עם `'` בתוכן).
- mutation_verify ✓ · 1031 tests · flutter analyze: 0 Huliot warnings.
- **HULIOT_TODO סגור 9/9 ✅ 100%** (P3 הומר מ-🔵 ל-✅).

## Huliot SmartLock — P8 לוגו brand ייעודי (v5.75 — 2026-06-02)
- `assets/lipskey/categories/smartlock.png` — היה עותק של `drainage.png`
  (placeholder). הוחלף ב-crop של ה-Y-tee האייקוני מעמ' 1 של הקטלוג
  (x=10-510, y=150-650), resize ל-512×512 RGBA. דומיננטי בצבע ה-Huliot הירוק
  הכהה, מציג את חתימת SmartLock visual signature (3 השקעים + הטבעות הירוקות).
- `finder_group_icons_test` "no two groups share the same product image"
  עובר (md5 שונה מ-drainage.png). 1015 tests pass.
- **HULIOT_TODO סגור 9/9** — כל הפריטים בוצעו או הוכרעו כ-cosmetic.

## Huliot SmartLock — P4 AQUA SLIM crops עמ' 27 (v5.74 — 2026-06-02)
- עמ' 27 = layout ייחודי (2 renders + strip schematic) שלא מתאים ל-band-loop
  הגנרי. `scripts/crop_huliot.py` הורחב ב-`CROPS_27` עם hand-tuned boxes:
  - `sml_p27_a.jpg` — Aqua Slim 330 render (470,195→825,315)
  - `sml_p27_b.jpg` — Aqua Slim 700 render (420,440→825,540)
  - `sml_p27_c.jpg` — פס ניקוז ללא סט (strip-only schematic, 150,870→670,920)
- `_huliotImageFor` case 27: `has('פס') → c` · `has('700') → b` · default 330(a).
- 10 מוצרי AQUA SLIM (סטים + פסים) יצאו מ-page-27 fallback ל-crops ייעודיים.
- mutation_verify על default routing (page_27 → red §17.1, restore → green).

## Huliot SmartLock — P5 orphan-crop cleanup + 2 routing fixes (v5.73 — 2026-06-02)
- **P5 בוצע:** נמחקו `sml_p24_b.jpg` + `sml_p25_b.jpg` (table-only rows שלא
  היו ב-routing). `scripts/crop_huliot.py` SECTIONS עודכן (24:`['a','c','d']`,
  25:`['a','c']`). 88→86 crops.
- **Guard חדש §17.1.b-Huliot:** "no orphan crops" — סורק
  `assets/huliot_smartlock/products/sml_p*.jpg`, וכל קובץ חייב להיות referenced
  ע"י לפחות מוצר Huliot אחד דרך `_huliotImageFor`. **גילה 2 בגי-routing נוספים:**
  - **עמ' 30:** "רשת מוגבהת עגולה בז'/אפור" נפלה ל-`_p(30,'c')` (עגולה) במקום
    `_p(30,'a')` (raised). תוקן: `מוגבהת` נבדק לפני `עגולה`.
  - **עמ' 40:** "מאריך למבוא זחיח" נפלה ל-`_p(40,'b')` (slip pipe) במקום
    `_p(40,'c')` (extension). תוקן: `מאריך` נבדק לפני `זחיח`.
- mutation_verify על תיקון עמ' 30 (red→green). 1015 tests pass.

## Huliot SmartLock — P9 תיעוד PARITY+COVERAGE (v5.72 — 2026-06-02)
- `knowledge/PARITY.md` סעיף H · קטלוג: השורה הישנה "קטלוג 935" → "קטלוג
  3-brand (1,879 מוצרים)"; נוסף sub-table "Brand catalogs" עם 3 השורות
  (ליפסקי 935·21 cats · פולירול 774·14 cats · חוליות 170·17 cats).
- `knowledge/port/COVERAGE.md` "תוצאות מדודות" — שורה חדשה:
  **קטלוגי-מותג ב-Flutter · 1,879/1,879 = 100%** (כולל הקרדיט ל-brand #3).
- אין שינוי קוד; תיעוד-בלבד (סוגר את החוזה הפורמלי של ה-brand).

## Huliot SmartLock — P7 full dims למוצר-ייחוס פר-משפחה (v5.71 — 2026-06-02)
- CATALOG §13 — מוצר-ייחוס פר-משפחה = שורת-טבלה מלאה verbatim. נוספו
  `יח׳/ארגז` (per-box) + `יח׳/משטח` (per-pallet) ל-13 מוצרי-ייחוס:
  pipes(40·L3000), cutters, joker, elbow oneside 15°/40, elbow 45°/32,
  elbow reducing 90°/32-40, telescopic 40, tee 45°/32, double coupling 32,
  reducer 32/40, gutter 70/40, drain 80/50 סגור, nut 32, raised cover 28, basin
  siphon 1¼". ערכים נשלפו ישירות מ-PDF (smartlock_raw.txt) לכל reference SKU.
- Guard: `§22.J-Huliot reference product per family carries יח׳/ארגז + יח׳/משטח`
  ב-`spec_assets_test.dart` — סורק את ה-product הראשון בכל categoryHe,
  פטור: kSmlAccessories (umbrella, varied) + kSmlAquaSlim (layout שונה).
- mutation_verify על §22.J (מחיקת זוג ערכים → red→green). 1014 tests pass.

## Huliot SmartLock — P6 חיווט מותג לפונקציות משותפות (v5.70 — 2026-06-02)
- CATALOG שלב ה' — Huliot נפל ל-default ב-4 פונקציות משותפות. נוסף ענף 'חוליות':
  - `related_info.dart::finderGroupFor` → (🟢, 'דלוחין SmartLock') — "נמצא ב" עכשיו מאוכלס.
  - `related_info.dart::engineeringSpecFor` → snapshot מ-עמ' 4/6: PP רב-שכבתי
    (PPMD) · ללא PN (כבידה) · 95°C · דלוחין · נעילת ראטצ'ט+TPE · bore=DN.
  - `related_info.dart::complianceTriggersFor` → 5 תקני Huliot verbatim
    (ת"י 958-1/71253-1+2/5694/14020 + EN-1451·DIN 8078), בלי לדלוף תקני PPR.
  - `related_info.dart::complianceWhyHe` → 5 הסברי-why ל-labels החדשים
    (smart_card_data_test דורש why לכל label, כי Huliot smart-wired ע"י בנצי).
- Guards: `test/polyroll_e2e_test.dart` group `P6 · Huliot brand-wiring` (4
  בדיקות: finderGroup=דלוחין · engineeringSpec PP/no-PN/95°C · 5 תקנים נוכחים
  + לא דולף 15874 · 0 orphans). mutation_verify על finderGroupFor (red→green).
- 1013 tests pass.

## Huliot SmartLock — P1+P2 תצלומי-מוצר נקיים (v5.69 — 2026-06-02)
- מענה לפידבק "חלק מה-crops כוללים דיאגרמת L/DN + שאריות-טבלה":
- `scripts/crop_huliot.py`: `TOP_FRAC` (חלק יחסי מהבנד) → `PHOTO_H=170` קבוע
  מראש-הבנד. התצלום בגובה ~קבוע בכל הבנדים (2/3/4 סקשנים) כי ה-render בגודל
  אחיד; דיאגרמת L/DN+הטבלה יושבות מתחת ונחתכות. `min(PHOTO_H, band*0.92)`
  שומר על בנדים קטנים בתוך-הבנד.
- P2: `X1` 250→238 — מסיר את פס אייקוני יח'/ארגז/משטח האפור מימין.
- 88/88 crops נחתכו מחדש; שמות-קבצים ו-`_huliotImageFor` routing **ללא שינוי**
  (אותו contract, רק תוכן-תמונה נקי יותר). אומת ויזואלית ב-contact-sheet.
- Guards ללא שינוי: §17.1-Huliot (קיום + לא page-fallback) עדיין ירוק.

## Huliot SmartLock — 88 תמונות מוצר חתוכות פר-משפחה (v5.63 — 2026-06-01)
- מענה לפידבק "איפה תמונות לפי פרוטוקול?": עמוד-מוקטן הוחלף ב-crops אמיתיים.
- `scripts/crop_huliot.py` (one-off): חותך את עמודת-התצלום השמאלית (x=12-250)
  של כל עמוד-מוצר ל-N בנדים (לפי מספר הסקשנים), `sml_p{NN}_{a|b|c|d}.jpg`.
  88 קבצים ב-`assets/huliot_smartlock/products/`.
- `lib/data/huliot_smartlock_catalog.dart::_huliotImageFor` — switch פר-עמוד
  (11-43) שמנתב כל מוצר ל-crop שלו לפי keyword ב-nameHe (זווית/מידה/קטגוריה),
  בדיוק כמו polyroll `_pprPagePhoto`. שורות table-only (אטם מעביר p24, מצרה
  p25) ממחזרות crop של אח או מצמד. עמ' 27 (AQUA SLIM, render-on-table) =
  page image לגיטימי.
- Guard: `§17.1-Huliot every product front image exists + is a real crop` —
  מאמת שכל imageAsset קיים על דיסק ו**אינו** page-fallback (פרט לעמ' 27).
  זו ההגנה שמוודאת שלא נחזור לעמוד-מוקטן.

## Huliot SmartLock — chips היררכיים + תמונות (v5.62 — 2026-06-01)
- `lib/screens/lipskey_products_screen.dart:1175` — Huliot מצטרף ל-Polyroll
  במסלול `_HierarchyChips` (היה `_NameWords` Lipskey-style). כל קלף Huliot
  עכשיו מציג pills עם labels (חיבור/צורה/תכונה/תבריג/מידה) ו-breadcrumb '‹'.
- `lib/data/chip_hierarchy.dart`:
  - `kChipTypes` += 23 Huliot types (סיפון, מחסום, מאסף, אום, אטם, ...).
  - `kChipLevel2Shape` += 15°/30°/87.5° + חלק/טלסקופית/כפול/נפילה/קומקום/...
  - `kChipLevel3Feature` += 60+ Huliot tokens (לג'וקר, מטבח, רחצה, אמריקאי, ...)
  - `_l3Compounds` += 40+ multi-word compounds (צד אחד חלק, AQUA SLIM, ...)
  - Parser: skip cosmetic separators ('-', '—', '/'); strip surrounding parens
    on token before vocab lookup; multi-numeric tokens fold INTO `level5`.
  - Existing `_l3Compounds` של Polyroll עודכנו (הסרת '-' פנימי) כדי לתאום
    ל-skip-dash בtokenizer החדש.
- `lib/data/lipskey_catalog.dart`: image-asset path resolver — שם קובץ
  שמתחיל ב-`page_` הולך ל-`pages/` (לא `products/`). מאפשר ל-Huliot להציג
  את עמוד הקטלוג כתמונת מוצר כברירת-מחדל עד שתחתכו crops פר-משפחה.
- `lib/data/huliot_smartlock_catalog.dart`: `_huliotImageFor(page, …)`
  מחזיר `'page_NN.jpg'` (היה null → emoji-fallback). 170/170 cards עם תמונה.
- Guards: `§21.B-Huliot` strong recoverability עבר (parseChips); `§21.C-Huliot`
  מאמת שכל chip נושא label סמנטי. שני tests של Polyroll עודכנו במקביל
  (skip '-/—//' מ-orig set כדי שלא יסומנו כ-lossy אחרי שהפרסר מדלג עליהם).

## Huliot SmartLock — קבוצת בית ייעודית (v5.61 — 2026-06-01)
- `lib/screens/finder_screen.dart`:
  - `kFinderGroups` += `FinderGroup('🟢', 'דלוחין SmartLock', {kSml* ×17})` —
    מוצב בין "צנרת PPR" (פולירול) ל-"אחר" (catch-all).
  - `kFinderGroupIcons` += `'דלוחין SmartLock': Icons.water_damage` (Material).
  - `kFinderGroupImage` += `'דלוחין SmartLock': 'smartlock'` — תמונה
    `assets/lipskey/categories/smartlock.png`.
- `lib/data/huliot_smartlock_catalog.dart`:
  - `kSmlSiphons = 'סיפונים SmartLock'` (היה 'סיפונים' — התנגש עם קבוצת
    'ניקוז' שכבר כוללת את 'סיפונים' של Lipskey/Aquatec). הקבוצות עכשיו
    pairwise-disjoint (wiring_test).
- `lib/data/catalog_tree.dart`: `sml.siphons.lipskeyCategory` עודכן בהתאם.
- אפקט: ניקוז יצא 168→150 (18 סיפוני Huliot עברו לקבוצה החדשה).

## Huliot SmartLock catalog ingestion (v5.59-60 — 2026-06-01)

### Catalog tree leaves (sml.*)
| Leaf id | Title | Category (kSml*) | Products | Pages |
|---|---|---|---|---|
| `sml.pipes` | צינור חלק | `kSmlPipes` | 7 | 11 |
| `sml.cutters` | חותך צינורות | `kSmlCutters` | 2 | 11 |
| `sml.joker` | מתאם זווית - ג'וקר | `kSmlJoker` | 3 | 11 |
| `sml.elbow_oneside` | ברכיים צד אחד חלק | `kSmlElbowOneSide` | 8 | 12 |
| `sml.elbow` | ברכיים | `kSmlElbow` | 7 | 13 |
| `sml.elbow_reducing` | ברך מצרה | `kSmlElbowReducing` | 5 | 13-14 |
| `sml.elbow_telescopic` | ברך טלסקופית | `kSmlElbowTelescopic` | 4 | 15 |
| `sml.tees` | מסעפים | `kSmlTee` | 11 | 16-17 |
| `sml.double_coupling` | מצמד כפול | `kSmlDoubleCoupling` | 4 | 18 |
| `sml.reducer` | מצרה | `kSmlReducer` | 5 | 18, 25 |
| `sml.gutters` | מאספים | `kSmlGutters` | 8 | 19-20 |
| `sml.drains` | מחסומים | `kSmlFloorDrains` | 7 | 21-23 |
| `sml.accessories` | אביזרים משלימים | `kSmlAccessories` | 46 | 24, 39-43 |
| `sml.nuts` | אום SmartLock | `kSmlNuts` | 5 | 25 |
| `sml.aquaslim` | מאסף קווי AQUA SLIM | `kSmlAquaSlim` | 10 | 27 |
| `sml.covers` | מכסים, הגבהות ורשתות | `kSmlCovers` | 20 | 28-30 |
| `sml.siphons` | סיפונים | `kSmlSiphons` | 18 | 31-38 |
| **TOTAL** | | | **170** | **11-43 (excl. 26)** |

### Guards
- `test/spec_assets_test.dart`:
  - `§22.I-Huliot every product carries יצרן + מק"ט` (170 SKUs)
  - `§22-Huliot every product asset resolves to assets/huliot_smartlock/`
  - `§22-Huliot every Huliot page asset exists on disk` (170 × N pages)
  - `§21.B-Huliot every product name renders verbatim (no empty words)`
  - `§22-Huliot every numeric token in name is grounded in dims`
  - `§22-Huliot paranoid 12-check audit — cross-product consistency`
- `test/ppr_infra_test.dart`: `kCatalogProducts.length == Lipskey + Polyroll + Huliot`
- `knowledge/mutation_log.md`: `_sl` (factory) + `_brandDir` (path mapping) verified.

### File map
- **Data:** `lib/data/huliot_smartlock_catalog.dart` (170 products, factory `_sl`).
- **Brand:** `lib/data/brands.dart` Brand(id='huliot', name='חוליות', emoji='🟢').
- **Tree:** `lib/data/catalog_tree.dart` root `sml` + 17 leaves.
- **Path mapping:** `lib/data/lipskey_catalog.dart` `_brandDir(brand)` static.
- **Unified registry:** `lib/data/polyroll_catalog.dart` `kCatalogProducts +=
  kHuliotCatalog`.
- **Sheet content:** `lib/screens/lipskey_product_sheet.dart` `_buildInfoHuliot()`
  — page 5-6 advantages + page 4 standards + page 8-9 install verbatim.
- **Brand emoji:** `lib/screens/lipskey_products_screen.dart:1187-1192` —
  '🟢 חוליות' (was '🏭 ${brand}' fallback).
- **Assets:** `assets/huliot_smartlock/pages/page_01-44.jpg` (3.5MB).

### Detail

- New file: `lib/data/huliot_smartlock_catalog.dart` — 170 products from the
  Huliot SmartLock™ HE catalog PDF (44 pages, REV 001 / 02.2026). PP drainage
  system, 32-63mm, ratchet-tooth locking, TPE elastomer pressure seal.
  Standards: ת"י 958-1, 71253-1, 71253-2, 5694, 14020.
- 17 verbatim TOC families: `kSmlPipes`/`kSmlCutters`/`kSmlJoker`/
  `kSmlElbowOneSide`/`kSmlElbow`/`kSmlElbowReducing`/`kSmlElbowTelescopic`/
  `kSmlTee`/`kSmlDoubleCoupling`/`kSmlReducer`/`kSmlGutters`/`kSmlFloorDrains`/
  `kSmlAccessories`/`kSmlNuts`/`kSmlAquaSlim`/`kSmlCovers`/`kSmlSiphons`.
- Factory `_sl` auto-injects `יצרן='חוליות'` + `מק"ט חוליות'=sku` into every
  product's dims — §22.I (internal card completeness) is satisfied by
  construction (guarded by a new spec_assets_test §22.I-Huliot test).
- Wired into `kCatalogProducts` (polyroll_catalog.dart) — now Lipskey 935 +
  Polyroll 774 + Huliot 170 = **1,879 products**.
- Brand `'חוליות'` added to `lib/data/brands.dart` (id `huliot`, green 🟢).
- Catalog tree: `lib/data/catalog_tree.dart` `'sml'` root + 17 leaf nodes
  (`sml.pipes` → `sml.siphons`), each `brandIds: ['huliot']` +
  `lipskeyCategory: <kSml*>`. Reachable from the catalog drill-down.
- `lib/data/lipskey_catalog.dart` `_brandDir(brand)` helper now resolves
  Huliot to `assets/huliot_smartlock/` (was hardcoded `polyroll|lipskey`).
- Image fallback: `_huliotImageFor` returns null → flip side lands on the
  full catalog page (`assets/huliot_smartlock/pages/page_NN.jpg`). Per-family
  crops will go here as they're cut from the PDF (protocol §17).
- 44 pages extracted via `pdftoppm` to `assets/huliot_smartlock/pages/` +
  `pubspec.yaml` asset entry added.

## cardReadinessScore — row-level chip in search results (v5.59)
- `catalog_screen.dart::_SearchResultsList` product `ListTile` now shows the
  composite `cardReadinessScore` as a band-coloured `📊 N` chip in `trailing`
  (above the "מוצר" tag), via `cardReadinessScore`/`scoreBandColors` (already
  imported). Makes the score visible at a glance in the catalog search list —
  no need to open the card overlay. Verified live: PPR אספקה → 📊 99 (🟢);
  מושב אסלה → 📊 15 (🔴). Pure display; the score engine (v5.58) is unchanged.

## Huliot SmartLock → smart-tree wiring, batch 1: drainage fixtures (v5.62)
- `smart_tree.dart`: added 17 Huliot SmartLock SKUs as `SmartBrand` options to 4
  existing drainage-fixture cards (so they become mapped via `smartProductForSku`
  and reachable under the 🌳 smart-tree lens / "כרטיס חכם" button):
  - `floorDrain` (מחסום רצפה) +7 — 70124599 · 70124590 · 70114500 · 70114590 ·
    70145960 · 70117500 · 70117560
  - `basinTrap` (סיפון לכיור רחצה) +3 — 61230060 · 63466055 · 61233360
  - `kitchenDrain` (סיפון לכיור מטבח) +4 — 61450060 · 61550060 · 61350060 · 61650060
  - `washingMachineDrain` (סיפון למכונת כביסה) +3 — 61480100 · 61230065 · 62850060
- Effect: smart-tree mapped coverage 293 → **310** SKUs. Huliot floor-drains &
  siphons now show a כרטיס-חכם instead of falling back to the plain sheet.
- Guards: `smartproduct_contract_test` — new "Huliot … wired into the smart-tree"
  test (4 cards carry a Huliot brand; spot-check sku→card; ≥17 mapped) + the
  existing "every SmartBrand.sku is a real catalog SKU" + bridge round-trip.
  Mutation-verified (a broken Huliot sku fails both). Pure data; no engine change.
- REMAINING (next batches): American-sink siphons (62230060/62450060/62550060/
  62650060/62750060 + 61233172/63350060/61100062) → visibleTrap/otherTraps;
  pipes/elbows/tees/couplings → pvcPipe/drainageElbow/drainageFittings;
  gutters/covers/aquaslim → floorCollector/drainageManifold/floorCover.

## Huliot SmartLock → smart-tree wiring, batch 2: PP piping + remaining siphons (v5.63)
- `smart_tree.dart`: +62 Huliot SmartLock SKUs as `SmartBrand` options on 4 more
  drainage cards:
  - `pvcPipe` (צינור ניקוז) +7 — צינור חלק 32/40/50/63 (3-4 מ')
  - `drainageElbow` (ברכיים) +27 — ג'וקר ×3 · צד-אחד ×8 · 45°/90° ×7 · מצרה ×5 · טלסקופית ×4
  - `drainageFittings` (מחברים/מצמדים) +20 — מסעפים ×11 · מצמד כפול ×4 · מצרה ×5
  - `visibleTrap` (מחסום גלוי) +8 — סיפוני כיור-אמריקאי ×5 · ללא-סיפון · הורקה · אמבט
- Effect: smart-tree mapped coverage 310 → **372** SKUs; Huliot **79/170** mapped.
  Together with batch 1, all of Huliot's drainage *fixtures* + *piping* now open a
  כרטיס-חכם as a brand option.
- Guards: `smartproduct_contract_test` Huliot test extended to all 8 cards + sku→card
  spot-checks + ≥79 mapped. Mutation-verified (broken sku fails it + the catalog-SKU
  contract). Pure data; no engine change.
- REMAINING (batch 3): מאספים/AQUA SLIM → floorCollector/drainageManifold; מכסים
  → floorCover; אום/חותך/אביזרים משלימים (mostly SmartAcc, not brands).

## Huliot SmartLock → smart-tree wiring, batch 3: collectors/channels/covers (v5.64)
- `smart_tree.dart`: +38 Huliot SKUs as `SmartBrand` options on 3 more cards:
  - `roofCollector` (מאספים וקולטי גג) +8 — מאסף 70/40·130·230 + מאסף נפילה 50/100/110
  - `drainChannel` (תעלת ניקוז) +10 — AQUA SLIM 330/700 נירוסטה (סטים + פסים)
  - `floorCover` (מכסים ורשתות) +20 — הגבהות + מכסים עגול/ריבועי + רשתות
- Effect: smart-tree mapped coverage 372 → **410** SKUs; Huliot **117/170** mapped.
  All of Huliot's installable units (fixtures · piping · collectors · channels ·
  covers) now open a כרטיס-חכם. The unmapped ~53 are nuts/cutters/complementary
  accessories — SmartAcc-style, not standalone brand cards.
- Guards: `smartproduct_contract_test` Huliot test now spans 11 cards + sku→card
  spot-checks + ≥117 mapped. Mutation-verified. Pure data; no engine change.

## CI Gate-5 false-positive fix — BsTokens.chatText token (v5.68)
- `lib/theme/tokens.dart`: הוספת `BsTokens.chatText = Color(0xFF111111)` +
  `BsTokens.chatTimestamp = Color(0xFF777777)` כטוקנים ייעודיים לצ'אט.
- `lib/screens/chats_screen.dart`: החלפת שני שימושים בצבע גולמי `0xFF111111`
  (צבע טקסט, לא משטח כהה) בטוקן `BsTokens.chatText`.
- Effect: Gate-5 ב-CI (`grep ... lib/screens/`) מחזיר 0 תוצאות — false-positive נפתר.
  הטוקן עצמו נמצא ב-`lib/theme/` שלא נסרק ע"י Gate-5.

## Product/page images → CDN + bounded on-device cache (#3 weight)
- `lib/data/product_images.dart`: `productImageUrl` (pure asset-path → CDN-URL map,
  strips `assets/`) + `resolveProductImage`/`productImage` (drop-in for `Image.asset`).
  Full-quality images load from Cloudflare R2; cached on-device in a hard-capped LRU
  (`productImageCache`, ≤700 objects) so the device never fills, even at 60k+ images.
- Call-sites migrated `Image.asset(` → `productImage(`: `catalog_screen.dart` (2),
  `lipskey_products_screen.dart` (5), `lipskey_product_sheet.dart` (7),
  `install_studio_screen.dart` (1). Category icons + fonts stay bundled.
- Effect: release AAB 141.6 MB → 68.2 MB (−52%), image quality unchanged. Product/page
  assets de-bundled from pubspec; `IMAGE_BASE_URL` empty → bundled-asset fallback.
- Guards: `product_images_test.dart` (URL mapping, mutation-verified: strip + base).

## Huliot SmartLock → smart-tree wiring, batch 4: tools + connection nuts (v5.72)
- `smart_tree.dart`: +9 Huliot SKUs as `SmartBrand` options on 2 existing cards:
  - `tools` (כלי עבודה) +4 — חותך צינורות 40/50 + מפתח לאום 32-40/50-69
  - `drainageFittings` (מחברים/מצמדים) +5 — אום SmartLock 32/40/50/63 + אום מעבר מברזל
- Effect: smart-tree mapped coverage → Huliot **126/170** mapped.
- The remaining ~44 Huliot SKUs are kSmlAccessories (אטמים/פקקים/משפכים/מבואים/
  רוזטות — siphon spare-parts/seals). These are accessory-tier (SmartAcc), not
  standalone brand-cards; left as plain catalog products by design (a 44-brand
  catch-all card would be a dumping ground, not a usable smart-card).
- Guards: `smartproduct_contract_test` Huliot test extended to 12 cards (+tools)
  + sku→card spot-checks + ≥126 mapped. Mutation-verified. Pure data.

## Huliot SmartLock → smart-tree wiring, batch 5: spare-parts card (v5.78) — COMPLETE 170/170
- `smart_tree.dart`: new SmartProduct `smlSpareParts` ("חלקי חילוף לסיפון/מחסום
  SmartLock") — a parts-picker card listing the 44 remaining kSmlAccessories as
  SmartBrand options: אטמים (6) · אומי-ג'וקר (3) · פקקים (9) · אגנית/רוזטות (4) ·
  מבואים (5) · מכלולים/זחיחים/מאריכים/מתאם (7) · סטי-חיבור (3) · משפכים (3) ·
  אביקים/ונטיל/מצחיה (4).
- Effect: **Huliot smart-tree coverage = 170/170 (100%)**. Every Huliot SmartLock
  product now opens a כרטיס-חכם.
- Guard: `smartproduct_contract_test` Huliot test → 13 cards (+smlSpareParts) +
  sku→card spot-check + ≥170 mapped. Mutation-verified. Pure data.

## Unified-catalog reads — Huliot/PPR card, search & favorites/cart (v5.90)
Consolidates three fixes onto origin (the v5.85–v5.87 work, re-applied after
origin advanced to v5.89):
- **Blank card:** the search-result onTap built the sheet's sibling list from
  kLipskeyCatalog (empty for Huliot/PPR) → the variant pager threw
  "Invalid argument(s): 0" → blank card. Fix: build from kCatalogProducts +
  guard `categoryProducts.isEmpty ? [product]` in showLipskeyProductSheet.
- **SKU search:** matchProducts (results) iterated kLipskeyCatalog → a Huliot
  SKU (64032300) returned nothing. Fix: matchProducts runs over kCatalogProducts
  (catalogProductMatchesQuery already matches sku for >=5-char queries).
- **Favorites & cart:** favorites (×2), openCartLineProductSheet + cartLineDisplay,
  and the favorites-tile sibling call-site → kCatalogProducts.
Intentionally Lipskey-scoped: searchSuggestions (autocomplete, pinned by
search_suggestions_test) + the connection-planner count (install_engine Lipskey).
Rule in CONVENTIONS.md. Guards: huliot_card_render_test (2) + huliot_search_test (2).

## Contractor seeds foundation — T0 partial (לוח-קבלן)
- New `lib/data/contractor_seeds.dart` — verbatim const seeds (proto/04, T0.1/T0.3):
  PLAN_TYPES (4 · 13 zones · 3-store offers) · SAFETY_TIPS×5 · budget thresholds +
  `budgetLevel` · budgetCategories(4)+projectBudget · DEPT tiles(8) · helpers
  `bestStore`/`fMoney`/`caToday`.
- Guard: `test/contractor_seeds_test` (8 tests; fMoney/bestStore mutation-verified).
- Deferred (per PLAN): T0.2 StateNotifiers (mute→T7 · orders→T5; favorites exists) +
  ORDER_STATUS/STORE-services seeds (proto/04 lacks the verbatim labels → T4/T5).
  No `kLipskeyCatalog` introduced (gate 114 clean).

## Contractor T1 — catalog ⋮ "חלופות זולות" → cheaper same-product alternatives
- `home_shell.dart`: catalog ⋮ `case 'alternatives'` → `showModalBottomSheet(_CheaperAlternativesSheet)`
  (replaced the "בבנייה" toast). New `CheaperAlt` model + `cheaperAlternativesAcrossCatalog()`
  scanning `kHomeProductBrands` (lib/data/contractor_seeds.dart — proto §1b HOME_PRODUCTS, verbatim).
- For each product returns the cheapest tier below its recommended brand, sorted by savings desc
  (אסלה ₪740→560 · מקלחת ₪520→380 · ברז ₪189→139). Footer notes live supplier pricing in prod.
- Guard: `test/cheaper_alternatives_test` (≥3 alts · each altPrice<recPrice · sorted; filter
  mutation-verified). No `kLipskeyCatalog` (gate 114 clean).

## Contractor T2 — catalog ⋮ "השוואת מחירים" → per-product store price comparison
- `home_shell.dart`: catalog ⋮ `case 'price_compare'` → `showModalBottomSheet(_StorePriceComparisonSheet)`
  (replaced the "בבנייה" toast). New `StoreCompareRow` model + `storePriceComparisonAcrossCatalog()`
  flattening `kPlanTypes` zone items (lib/data/contractor_seeds.dart — proto §9b store offers, verbatim).
- Each product shows its 3 partner-store prices (בנייני העיר/אבן קיסר/טמבור הום…) as `_StoreChip`s;
  the cheapest (`bestStore`) is brand-highlighted with ✓. Footer = proto §9b verbatim note.
- Guard: `test/store_price_comparison_test` (≥3 products · each ≥3 stores · best==cheapest · §9b verbatim).
  No `kLipskeyCatalog` (gate 114 clean).

## Contractor T3 — catalog ⋮ "סרוק תוכנית" → scan flow (picker → scan → results → cart)
- `home_shell.dart`: `_ScanPlanSheet` now a `ConsumerStatefulWidget` (was a `showToast('בבנייה')` stub).
  3 phases: **picker** (4 `kPlanTypes` — proto §9) → **scan** (per-type `steps`, Timer animation) →
  **results** (per zone: header + ודאות%, items with `_StoreChip` store comparison, cheapest tagged).
- "אשר הכל — הוסף N פריטים לסל" → `scanPlanCartLines(plan)` adds each zone item at its cheapest store
  (`bestStore`) as a `SmartCartLine` → `smartCartProvider`, switches to חנות/הסל tab, toasts. Modal `isScrollControlled`.
- All strings verbatim proto §9. Guard: `test/scan_plan_test` (4 types active · each line cheapest · qty 1).
  No `kLipskeyCatalog` (gate 114 clean).

## Polish — token-binding (ליטוש · אין שינוי-wiring)
- **P-1 wave-1** (`catalog/notif/chat/store_settings_screen`): 44× צבעי-טקסט קשיחים →
  `BsTokens.inkLight/mutedLight` (token-equal · אפס שינוי-render/wiring). ראה `POLISH_LOG.md` #7.
- **P-3** (`toast`/`chain_diagram`): font-literals → `BsTokens.fontXs/Sm/Md/Lg` (token-equal).
- **P-4**: הוסר `go_router` (dependency מת, 0 שימושים).

## Dedup consolidation — scan/alternatives unified to canonical R9 sheets
- **Why:** Phase-1 added duplicate full-screens (`ScanMenuScreen`, AI-hub `_Alternatives`/`_PlanScan`)
  for features already implemented as catalog ⋮ modal sheets (T2/T3 above). Audit flagged it; fixed by
  upgrading the EXISTING sheets and deleting the duplicates (R9 = modal sheet is canonical).
- **New shared file `contractor_tools_sheets.dart`** (moved verbatim from `home_shell.dart`, no string/number change):
  `CheaperAlt`/`cheaperAlternativesAcrossCatalog`/`_CheaperAlternativesSheet`,
  `StoreCompareRow`/`storePriceComparisonAcrossCatalog`/`_StorePriceComparisonSheet`/`_StoreChip`,
  `scanPlanCartLines`/`_ScanPlanSheet`. Public openers: `openScanPlanSheet(ctx,{planKey})` ·
  `openCheaperAlternativesSheet(ctx)` · `openPriceCompareSheet(ctx)` (avoids home_shell↔leaf import cycle).
- **`_ScanPlanSheet` upgraded** with `initialPlanKey` deep-link (auto-starts the matching `kPlanTypes` plan) —
  ports the only extra the deleted `ScanMenuScreen` had. Guard: `budget_stock_scan_test` widget test.
- **Rewiring:** `menu_dial_widget` plan-* → `openScanPlanSheet(planKey)`; `ai_hub_screen` alt/plan tiles →
  the canonical sheets; `home_shell` catalog ⋮ → openers; `ai_hub_logic` repointed to the new file.
- **Deleted:** `lib/screens/scan_menu_screen.dart`. Net −1,144/+57. Gate: analyze 0 · 1642 tests · build web ✓.
- **Open TODO:** `knowledge/TODO-dedup-gate.md` — protocol has NO anti-dup gate (structural overlaps רכש≈Store,
  הגדרות≈dedicated screens still pending decision).

## Dial-distribution Wave 2 — 9×9 fleet (audit→validate→fix→gate, per Law #0)
Distributes the menu-dial 🏠 home branch into the catalog ⋮ (the dial itself is removed in Wave 3).
The 3 tools below were already in the ⋮ `itemBuilder` but had **NO `_onSelected` case** = silent no-op;
caught by 2 independent audit lenses (navigation + edge-crash), byte-verified against the architect agent's
mis-narration (it claimed "wired"). Now actually wired:

| ⋮ item | Behavior | Status |
|---|---|---|
| 🤖 בינה מלאכותית ואוטומציה | `case 'ai_hub'` → `AIHubScreen.route()` (label also un-truncated for text-parity) | ✅ |
| 📦 המלאי שלי | `case 'stock'` → `StockScreen.route()` | ✅ |
| 📋 משימות העבודה | `case 'site_tasks'` → `openSiteHub()` (10-tool site-hub landing) | ✅ |

- **`profile_screen.dart`** — native profile surface (name/contact/profession edit via `userProfileProvider.update`)
  reached from the name-chip; a11y pass (accessibility-rtl lens): 48dp target, button Semantics, chevron contrast,
  ExcludeSemantics on emoji/avatar, RTL/LTR input direction, ChoiceChip checkmark.
- **Conformance:** verbatim rule `הסל שלי` re-pointed `menu_trees.dart` → `store_screen.dart` (cart moved to the
  Store in the dedup; string preserved ×3). Gate: central-verify green — analyze 0 · 1645 tests · build · conformance 7/7.
- **Wave 3 (pending product-owner decisions):** delete `menu_dial_widget.dart` + hamburger + dial state; build a
  unified `SettingsScreen`; reconcile the projects dataset. Escalations in `_findings.md`.

## Dial-distribution Wave 3a — native settings + per-persona access (9×9 fleet · product-owner decisions)
Per product-owner: settings = extend the EXISTING `CatalogSettingsScreen` (not a new screen); profile+settings
reachable from EACH persona dashboard (separately); guest reaches profile via an always-visible account row.

| Surface | Wiring | Status |
|---|---|---|
| CatalogSettingsScreen · 👤 הפרופיל שלי (top, always visible) | → `ProfileScreen.route()` — guest-visible (register path) | ✅ |
| CatalogSettingsScreen · ערכת נושא / התראות (×4) / שפה | ported from the dial; provider-split kept (theme·lang→`appSettings` · notif→`notifSettings` · text/motion/contrast→`catalogSettings`) — verbatim strings from `settings_tree.dart` | ✅ |
| מנהל / חנות / שליח / עובד dashboards · AppBar | 👤 פרופיל→`ProfileScreen.route()` · ⚙️ הגדרות→`CatalogSettingsScreen.route()` (each persona, separately) | ✅ |

- Gate: central-verify green — analyze 0 · 1645 tests · build · conformance 7/7 · required-tests present.
- **Known follow-up (Wave 3b):** `CatalogSettingsScreen._confirmReset` resets only `catalogSettings` — extend to also reset `appSettings`+`notifSettings` so the ported controls reset too.
- **Wave 3b (next, atomic):** delete `menu_dial_widget.dart` + the hamburger + dial state, now that the native surfaces are in place.

## Dial-distribution Wave 3b — menu-dial REMOVED (cutover · 9×9 fleet)
The menu-dial FAB is **gone** — all its content lives natively (catalog ⋮ · ProfileScreen via name-chip ·
extended CatalogSettingsScreen · store project-picker · per-persona dashboard access).
- **Deleted:** `lib/screens/menu_dial_widget.dart`, `lib/state/menu_state.dart` (drill providers).
- `home_shell.dart`: removed the hamburger leading button + the `OpenDial.menu` render block + the import.
- `dial_state.dart`: removed `OpenDial.menu`, `menuTabProvider`, `MenuTab`, and their `resetAllDials` lines (BS/search dials untouched).
- harness: removed `tabs:menu` + the `menuTabProvider`/`MenuTab` lines from `button:resetAllDials`.
- `CatalogSettingsScreen._confirmReset` now resets catalog+app+notif (covers the Wave-3a ported controls); copy → 'כל ההגדרות…'.
- **0 dangling code references** (byte-verified for all 8 dial symbols). Gate: central-verify green — analyze 0 · 1645 tests · build · conformance 7/7 · required-tests.
- Note: the search-dial (`OpenDial.search`) remains; the BS-dial was removed in Wave 4 (below).

## Dial-distribution Wave 4 — BS-dial REMOVED + cleanups (9×9 fleet)
The BS-dial (the old 5-persona radial FAB drill) is **gone**. A 4-persona parity audit (manager/store/courier/worker) confirmed every dial leaf is covered by the full dashboards — often as a SUPERSET (several dial leaves were placeholder 'בבנייה' toasts), all on the SAME engines.
- **Deleted:** `lib/screens/bs_dial_widget.dart` (~1670 lines) + 4 `test/bs_dial_manager_*` tests (their target was the deleted widget; manager logic/UI stays covered by `orders_engine_test` · `manager_dashboard_test` · `manager_dashboard_screen_test`).
- `dial_state.dart`: removed `OpenDial.bs` (+ dead `bsMode`), `bsDrillPathProvider`, the 7 `bs*LeafProvider`s + their `resetAllDials` lines (kept `activePersonaProvider`, `OpenDial.search`).
- `home_shell.dart`: removed the `OpenDial.bs` render block + the `bs_dial_widget` import. `role_picker_sheet.dart`: removed the dead `OpenDial.bs` fallback (kept terminal pop + `activePersonaProvider`).
- `store_/courier_stage_advance_engine_test.dart`: rewritten to drive the shared engine DIRECTLY (`storeAdvance`/`courierAdvance` → `ordersEngineProvider`) — order-flow coverage preserved without the widget. harness `buttons.dart`: dropped the BS test blocks.
- Cleanups: stale `menu_dial_widget` comments (site_hub/app_settings) reworded; `CatalogSettingsScreen` title `הגדרות קטלוג` → `הגדרות`.
- **0 BS-dial code references** remain (byte-verified). The legacy "👔 Manager BS-dial M1–M4" wiring docs below are now **historical** — the widget + its `bs_dial_manager_*` guards no longer exist.
- Gate: central-verify green — analyze 0 · tests green · build · conformance 7/7 · required-tests.

## Wave 5 — audit-driven dead-code + wiring (9×9 fleet)
Full-app completeness audit (6 area-auditors) → fix-fleet. The app proved largely well-wired; gaps were few.
- **Dead-code removed:** unused `_MiniPill` (notifications_screen + chats_screen); orphan seeds `kVoiceSamples` / `PlanItem`+`kPlanResult` from `ai_hub_logic.dart` (+ their assertions in `t3_ghi_rewards_ai_home_test`).
- **Wired:** Store **saved-cart-lists** — `cartListsProvider` was write-only; added a "רשימות" sheet (load a saved cart into the smart-cart + delete). Courier **split-shipment indicator** — `🚚×N` tag from `fulfillmentProvider.splitInto`, mirroring `_StoreOrderCard`.
- **Validation caught (kept honest):** `aiAlternatives()` is NOT dead (a live test exercises it) → KEPT. The store price-comparison row was ALREADY routed to `openPriceCompareSheet` (audit false-positive).
- **Deferred — need a refactor / new infra (R8: not forced, not invented):** autoStock portal tile → live OOS list (needs `storeOosProvider` moved to `lib/state/` to avoid a circular import); chat history-clear (needs a persisted `chatHistoryProvider` — history is local widget state today). See `_gaps.md`.
- Gate: central-verify green — analyze 0 · tests · build · conformance 7/7 · required-tests.

## Wave 6 — deferred items resolved + dead-data removed (9×9 fleet)
Closes the Wave-5 "deferred" list + D3.
- **autoStock → live OOS:** moved `storeOosProvider` (+ its notifier + key) to a shared `lib/state/store_stock.dart` (screens→state, no cycle); the `autoStock` portal tile now renders the live out-of-stock products from it (was the "יחובר בהמשך" stub).
- **chat history-clear:** added a persisted `chatHistoryClearedProvider` (mirrors the archive notifier); `_ChatPage` seeds empty once cleared; the 'מחיקת היסטוריה' row → confirm dialog → `clearAll()` (a light cleared-flag, NOT a full message store — R8).
- **D3:** deleted the dead `lib/data/settings_tree.dart` (~70-leaf `kSettingsGroups`/`walkSettings`, 0 consumers — superseded by the screen-based settings); detached its 2 harness sections in `test_harness/tests/settings.dart`. (Stale `knowledge/` doc refs → separate scrub.)
- Gate: central-verify green — analyze 0 · tests · build · conformance 7/7 · required-tests.

## Wave 7 — search-dial removed (the LAST FAB dial · 9×9 fleet)
The search-dial was the last FAB dial (menu + BS already gone). A reachability audit confirmed `OpenDial.search` was never set by any user action (no search FAB; only the dial's own close + the harness), and every tool it offered is live in the in-catalog `_SearchToolsRow` (better-wired). So the entire `OpenDial`/dial machinery is gone:
- **Deleted:** `lib/screens/search_dial_widget.dart`.
- `dial_state.dart`: removed `enum OpenDial`, `openDialProvider`, `enum SearchTool`, `searchToolProvider` + their `resetAllDials` lines (kept `activePersonaProvider`, `mainTabProvider`, `tabHeaderHiddenProvider`). **No FAB-dial state remains in the app.**
- `home_shell.dart`: removed the search-dial render + scrim + import; the cart FAB guard is now just `tabIndex != 3`. The real in-catalog search (`_SearchToolsRow`) + the `Icons.search` header button are untouched.
- harness `buttons.dart`: dropped the search-dial/OpenDial test blocks. `lib/widgets/dial.dart` kept (test-only, via `dial_test_helper`).
- **0 dial-symbol references remain** (byte-verified). Gate: central-verify green — analyze 0 · tests · build · conformance 7/7 · required-tests.

## Wave 8 — inert-switch honesty pass (D2 · 9×9 fleet)
A 3-auditor sweep (store/notif/chat settings) byte-verified (grep-proven) which persisted toggles have **no consumer** anywhere in `lib/` — written by the settings screen, read by nothing. 13 sections proved **fully inert** (every persisted field dead); they previously rendered as live switches with an active-count badge, misleading users.
- `_SectionTile` (in each of the 3 settings screens) gained an optional `underConstruction` flag → renders an honest ExpansionTile `subtitle:` **"בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות"** and **suppresses the count badge** (a dead section no longer claims N active settings). Additive only — `_activeCount`/`children` untouched.
- **Marked (13):** store — התראות חנות · ספקים מועדפים · שירות ולוגיסטיקה. notif — ערוצי קבלה · צליל ורטט · לפי תפקיד · סיכומים תקופתיים · פרטיות במסך נעול. chat — מדיה ושמע · גיבוי וייצוא · שפה ותרגום · שיחות עסקיות · ארכיון וניקיון.
- **NOT section-marked — MIXED/LIVE sections** (some toggles ARE genuinely wired; a section-level note would mislabel a working toggle): store תשלום/חשבוניות/סל/תצוגה/משלוחים/פרטיות; notif סוגי-התראות (4 live via `notifMutedSections`) + שעות-שקט (core quiet-hours IS consumed at `notifications_screen.dart`) + חשיבות; chat שיחות-וחיווי/התראות-שיחה/פרטיות(live delete)/בוט.
- **Full D2 pass (per-row honesty inside the MIXED sections):** a 3-auditor re-sweep re-proved the **29 dead toggles** inside them (store 17 · notif 8 · chat 4); each now carries an honest per-row marker **"בבנייה — עדיין לא משפיע"** (subtitle on `_SwitchRow`; a note under the label on `_RadioGroupRow`/`_InlineTextRow`/`_NumberRow`) and stays functional (still persists). A shared `_Inert` interface lets `_SectionTile._activeCount` exclude them, so each MIXED section's badge now shows only the **LIVE** count (e.g. סוגי-התראות 9→4). Live toggles untouched.
- Guard: `test/settings_honesty_test.dart` (6 tests) — asserts the section-level subtitle on all 3 screens, and expands a MIXED section per screen to assert the per-row marker renders.
- Gate: central-verify green — analyze 0 · tests · build · conformance · required-tests.

## Wave 9 — T7 cross-persona chat + server-ready (orders/customers) + P1 colors (9×9 fleet)
The three remaining tracks, built/wired in parallel (disjoint files), one verified gate.

### T7 — cross-persona chat (the one missing feature)
The chat is now a shared, persisted, cross-persona engine (was a contractor-only `const _kThreads` + bot). A store message is seen by the contractor and vice-versa; each persona sees ONLY its own threads.
- `state/sys_chat.dart` (NEW): `ChatEngineNotifier` over `ChatThread`/`ChatMessage`, persist `bs.sys-chat.v1` (worker_tasks H2 pattern: `_loaded`-guard + persist-flag). `send(threadId, fromRole, text)` (visible to both participants), `threadsFor(role)` (data isolation). `chatEngineProvider`.
- `data/chat_seeds.dart` (NEW): cross threads (contractor↔store/courier/manager · store↔courier) + a bot thread (auto-reply kept).
- `chats_screen.dart`: `ChatsScreen({persona = contractor})` — the thread list + `_ChatPage` read the engine via `threadsFor(persona)`; sending calls `send(.., persona, ..)`. UI reused verbatim (emoji/camera/archive/honest-stubs/bot). Backward-compatible: `const ChatsScreen()` still serves the contractor home-shell tab.
- 🔒 Isolation (SPEC §2.5): a non-contractor persona opens a STANDALONE Scaffold (own "שיחות" AppBar + back→pop) — no home_shell, no role_picker, no cross-board nav.
- Wiring (CH-4): store/courier → `persona_portal` (`_ChatEntryRow`); worker → `worker_app_screen`; manager → `manager_dashboard_screen` — each pushes `ChatsScreen(persona:)` standalone. Contractor via `updates_screen`.
- Guard: `test/sys_chat_test.dart` — cross-persona visibility · restart persistence · isolation.

### server-ready (Repository seam) — orders + customers wired (T6.2/T6.3)
- `data/repositories/orders_local.dart` + `customers_local.dart` (NEW): local impls of the existing interfaces, delegating to the live engine; `seed()` exposes the const genesis acyclically.
- `orders_engine.dart`: `ordersEngineProvider` sources its seed via `ordersRepositoryProvider.seed()`; `managerCustomersProvider` derives via `customersRepositoryProvider.aggregate(orders)` (still watches the engine). Behavior byte-identical.
- Guard: `test/repositories_test.dart`. The other 4 domains (finance/site/stock/catalog) read their seeds directly across many screens (no single owning provider) → T6.3 deferred (R8 — not forced); their T6.1 interfaces remain.

### P1 polish — colors → BsTokens
- 20 raw `Color(0x)` literals → `BsTokens` (19 in `widgets/chain_diagram.dart` + 1 in `theme/app_theme.dart`); 14 new exact-hex tokens in `theme/tokens.dart` (chain* palette + `bgLightAlt`). Screenshot-identical.

Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

## Wave 10 — server-ready extension: route catalog/site/stock through their repositories (T6.3 · 9×9 fleet)
Extends the server-ready seam to the cleanest of the remaining domains (Wave 9 did orders/customers), all behavior **byte-identical** (the verified 29/29 hubs read the same consts, now via the repos).
- **catalog** — `data/repositories/catalog_local.dart` (LocalCatalogRepository — returns `kCatalogProducts`/`kSmartProducts`/`kCatalogCats` verbatim). Routed **21 ref-scoped reads** via `catalogRepositoryProvider` in `catalog_screen.dart` (19) + `lipskey_products_screen.dart` (2).
- **site** — `site_local.dart` (LocalSiteRepository). Routed `kProjects` via `siteRepositoryProvider` in `budget_screen.dart` (site rows) + `projects_engine.dart` (seed — orders-idiom, acyclic).
- **stock** — `stock_local.dart` (LocalStockRepository). `stock_screen.dart` sources `kStockDemo` via `stockRepositoryProvider` (11 items unchanged).
- **Architectural ceiling (reported — R8, NOT forced):** the finance/site **hub screens** + the catalog **pure-logic** (`category_division`/`pressure_drop`/`system_division`) + `finder`/`departments` read their consts in non-Consumer contexts (StatelessWidget / top-level functions, no `ref`). Routing them would require converting the verified 10/10 hub screens to ConsumerWidgets (structural change → regression risk). Their T6.1 interfaces + T6.2 local impls stand; that provider-rewire needs a dedicated screen-restructure pass. (`finance_local` removed — it had no safe consumer.)
- **Net server-ready:** orders · customers · catalog · site · stock routed through repos; finance + the pure-logic catalog paths remain const-bound by architecture.
- Guard: mutation-verified; gate green.

Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

## Wave 11 — server-ready 6/6: close finance + catalog pure-logic via a global repo accessor (T6.3 · 9×9 fleet)
Closes the architectural ceiling Wave 10 flagged. The remaining const reads sat in non-Consumer contexts (top-level functions / StatelessWidgets, no `ref`), so a Ref-free **global repo accessor** routes them — no signature changes, no verified hub restructured.
- `finance_local.dart`: added a const `LocalFinanceRepository.constData()` + global `financeRepo()` (Ref-free) for the budget consts; `activeRevenue()` stays Ref-based via the provider. `finance_hub_sheets.dart`'s `_open*` functions + `_FinReportView` now read budget data via `financeRepo()` — the 10 verified finance values byte-identical (15000/9840/66 · ₪12,800 · ×1.42 · 80/90/100 · …).
- `catalog_local.dart`: const `_kCatalogRepo` + global `catalogRepo()`; the provider returns the same instance. The pure-logic readers — `category_division` · `system_division` · `pressure_drop` (colleague's file — only the catalog read touched, their flow logic intact) · `finder_screen` · `departments_screen` · `card_projects` — now read via `catalogRepo().allProducts()`/`allSmartProducts()` (byte-identical; dead `polyroll_catalog` imports dropped).
- **R8 exception (honest):** `pressure_drop.dart`'s `kLipskeyCatalog` read (a Lipskey-only const, not the unified catalog — no matching interface method) left as-is.
- **Net server-ready now 6/6:** orders · customers · catalog · site · stock · finance all route through their repositories. A backend swap is a drop-in repo replacement.
- Guard: mutation-verified; gate green.

Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

## W1 — ליטוש-באגים (workbook `POLISH.md` §5)
### #1 בועות-צ׳אט RTL — `chats_screen.dart` — 2026-06-08
- helper חדש `chatBubbleAlignment({required isMe})` (top-level) — מנתב צד-בועה: own→start (ימין ב-RTL), other→end. `_Bubble` (הודעה) + `_TypingBubble` (הקלדה=incoming) שניהם דרכו. רדיוסי-הזנב → `BorderRadiusDirectional` (start/end) כך שהזנב עוקב אחר הצד.
- מתקן היפוך מול spec `sys_chat.dart §1`. guard: `chat_bubble_side_test` (4) + mutation-verified. אין שינוי state/ניווט.
### teal→כתום (W0) — `site_hub_screen.dart` · `finance_hub_sheets.dart` — 2026-06-08
- 3 consts מקומיים שהחזיקו teal **בטעות** (`_kBrand`/`_kBrandDark` ב-site · `_kBrandTeal` ב-finance — ההערה ב-site אף אמרה "orange brand") → `BsTokens.brand`/`brandDark`. ~12 שימושים flipped לכתום. status-teals אחרים (manager 'new' · lipskey accents) מחוץ-לסקופ.
### microcopy (W0) — `search_index` · `notif_settings_screen` · `catalog_settings_screen` — 2026-06-08
- `מנהל מערכת`→`מנהל המערכת` (search_index ×2 · notif_settings — האחדה ל-canonical `personas.dart`) · `AI`→`בינה מלאכותית` (catalog_settings ×2). אפס שינוי-לוגיקה. tests של 'מנהל המערכת' (manager_dashboard/widget) כבר על ה-canonical — לא נשברו. `mm`→`מ"מ` נדחה לפס נפרד.
### #+-עגלה — `lipskey_products_screen` — 2026-06-08
- `_ProductRow._addToCart` השתמש ב-`.add()` (append) → על ListView-recycle (כש-`_open` טרי אך המוצר כבר בעגלה) tap על `+` יצר **שורה כפולה**. → `setQtyForKey` (אידמפוטנטי לפי productKey), כמו add-path של grid-card (507) ו-`_setQty`. guard: `lipskey_plus_no_dup_test` (2). אין שינוי-API.
### #perf — install_studio blueprint rebuild-per-frame — 2026-06-08
- `AnimatedBuilder` בנה את כל ה-Column (header/canvas/dock) **בתוך ה-builder** → כל הצומת נבנה-מחדש בכל tick (60fps). → התוכן ל-`AnimatedBuilder.child` (נבנה פעם-אחת) + `RepaintBoundary` סביב ה-CustomPaint. אותו עץ-ויזואלי, רק ה-painter מצוייר מחדש. אין שינוי state/לוגיקה.
### #weld-key — תזמון-ריתוך PPR נעלם — `lipskey_product_sheet` — 2026-06-08
- חיפוש תוכנית-הריתוך (`_kPprWeldPlan[dn]`) קרא רק `dims['dn נומינלי']`, אך רוב צינורות ה-PPR של פולירול (supply+faser) נושאים את הקוטר תחת `'קוטר חיצוני'` → null → התזמון נעלם. → helper `pprWeldDn` עם fallback ל-`'קוטר חיצוני'`. guard: `ppr_weld_dn_test` (4) + mutation-verified. אין שינוי API/state.

## Wave 12 — deep bug-hunt fixes + protocol hardening (9×9 fleet)
A deep audit (5 semantic/integration lenses — business-logic/RBAC · e2e-flow · edge-cases · dead-interactions/isolation · races) found bugs the surface/regression gates structurally couldn't (features never wired right · cross-feature seams · races). Fixed:
- **HIGH — cart-per-project (now works):** `projects_screen._switch` called `switchProject` without `outgoingCart` and discarded the returned snapshot → the cart never swapped (every project showed 0 items). Now passes `outgoingCart: ref.read(smartCartProvider)` + applies the snapshot via new `SmartCartNotifier.loadSnapshot`.
- **HIGH — §2.5 isolation hole:** the shared `ProfileScreen` exposed "🔄 החלפת תפקיד" → role-picker from inside every non-contractor persona. Gated the link on `activePersonaProvider == null` (contractor only).
- **MED — plumbing safety:** the vacuum-breaker/backflow check missed `'ציוד גן'` (garden hose-connectors — supply parts needing a hose-bibb vacuum-breaker). Widened the trigger to `'ברזי גן' || 'ציוד גן'` (`install_engine.dart`).
- **MED — data-loss:** `saved_projects._persist` had no try/catch (awaited from an `async void` rename) → silent loss; wrapped it.
- **MED — cross-engine load-clobber (WON'T-FIX, documented):** the theoretical "approve on seed before `_load` resolves → double-advance" is a sub-microtask, low-reachability window. An `if(!_loaded) return;` guard on `approve`/`advance` was TRIED but **reverted** — it no-ops a legitimate SYNCHRONOUS mutation (construct-then-act), which the persistence regression test correctly caught. The existing per-notifier `_loaded` guard (on `_load`/`set state`) + the persisted-status check (`status != 'review'`) already prevent the double-advance after a real restart. Cure was worse than the disease.
- **MED — load-clobber (4 notifiers):** `store_stock` · `smart_project_engine` · `saved_projects` · `card_projects` lacked the `_loaded` guard (WIRING earlier claimed the load-clobber race "fixed" — it wasn't, for these); added the guard mirroring `cart_lists_state`. Closes that spec-divergence.
- **Guards:** `test/deep_fix_regression_test.dart` (cart round-trip · 'ציוד גן' vacuum-breaker · profile isolation). **Protocol hardening:** `test/state_loaded_guard_test.dart` — a source-scan gate asserting every persisting notifier that overrides `set state` carries `bool _loaded` (12 guarded / 0 offenders) → a future un-guarded persisting notifier now fails `flutter test`. (The behavioral/invariant gate class the build was missing.)
- **HIGH — order-site decoupled (RESOLVED):** product decision = **the projects engine is canonical**. Checkout's `cartProjectProvider` now defaults from `activeProjectProvider` (watches it); the site-picker lists `projectsProvider` projects + `'ללא פרויקט'`; the "+ הוסף" add-flow routes to the engine's `addProject`; both post-order/clear resets follow the active project. `storeProjectsProvider` retired (vestigial — 0 live readers). An order's `site` now follows the active project. Guard: `test/order_site_canonical_test.dart` (5 cases); `contractor_checkout_engine_test` updated to the canonical site name.
Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

### #₪-truncation — `store_screen` saved-cart reload (W1) — 2026-06-08
- `_loadItem` שיחזר שורה-שמורה כ-`brandPrice: total ~/ qty` → איבד עד (qty-1) ₪ כשה-total לא מתחלק ב-qty (₪340@3→339). → helper top-level `savedLineReconstruct` ששומר total מדויק (מתחלק→per-unit; אחרת qty=1 ב-total מלא). guard: `saved_line_reconstruct_test` (4) + mutation-verified.
### #camera — מסך-שחור בהרשאה-נדחית (W1) — 2026-06-08
- 2 ה-MobileScanner (`camera_sheet` · `barcode_scanner`) היו בלי `errorBuilder` → מסך-שחור כשהמצלמה לא עולה (הרשאה נדחית/אין מצלמה). → `errorBuilder` → widget משותף `cameraPermissionErrorView` (`lib/widgets/`, מקור-אחד לקופי המאושר). guard: `camera_error_view_test`.

## Round 3 — deeper bug-hunt fixes (data integrity / RTL / UX · 9×9 fleet)
A 3rd, DEEPER audit (data-integrity · RTL/BiDi · error/empty-path lenses) caught bugs the prior rounds missed:
- **HIGH×2 — lipskey category-key mismatch (52 products):** `lipskey_smart_data.dart` taxonomy keys `'אטמים אומים ופקקים'` / `'מחסומים (סיפונים) גלויים'` didn't match the real products' `categoryHe` (`'אטמים ופקקים'` / `'מחסומים גלויים'`), so `lipskeyAccFor`/`lipskeyStagesFor` returned `[]` → 17+35 products silently lost their curated accessories + install-stages + showed dead tiles. Renamed all 3 occurrences each. Guard: `test/lipskey_category_keys_test.dart` (non-empty + negative-guard on the old keys; mutation-verified).
- **MED×2 — vanishing catalog leaves:** `catalog_tree.dart` leaves `קולטי גג` + `אביק לאמבט ואגנית` set a `lipskeyCategory` matching 0 products → "0 מוצרים" + the leaf vanished under a water-system filter. Dropped the bogus `lipskeyCategory` (each has a working `smartKey` that drives it).
- **MED — CDN image placeholder:** `product_images.dart` `productImage` now has a default `frameBuilder` (faint grey skeleton + fade-in) so slow CDN loads don't show blank boxes (one-point fix, covers all 15 call-sites).
- **Convergence (already fixed via rebase):** the FX-equation RTL reorder (`finance_hub_sheets`, wrapped LTR) + the wrong-direction `Icons.arrow_back` (→ `arrow_forward`, 11 sites) were independently fixed in the parallel agent's RTL-polish pass.
- **Deferred (low-value / not cleanly fixable):** lipskey spec-string Latin-reorder (a `_StripDef.value` data field rendered through a shared mixed-direction `Text` — per-value bidi-isolation needed; cosmetic); voice "listening" indicator (a real STT-feedback feature, not a one-liner); 7 LOWs (emoji/SKU order, `₪-` sign, breadcrumb arrow, badge side, zoom-error, partial-load notice).
Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

### #bind-color — W3 batch 1: inkLight ×150 — 2026-06-08
- `Color(0xFF1A1A1A)` → `BsTokens.inkLight` ב-17 קבצי-screens (token-equal · אפס שינוי-עין · imports נוספו). guard: `color_token_ratchet_test` (down-only). batch-1 של בינדינג-הצבע (#3); re-based על tip-הצי `d8b1089` אחרי collision.

### #a11y-contrast — "ניגודיות גבוהה" מכסה foregrounds-של-מותג — 2026-06-08
- ה-toggle `catalogSettings.highContrast` היה **חלקי**: `app_theme` נגע רק בטקסט-התמה (`ink`/bodyMedium), אך לא ב-literals ברמת-widget — FAB לבן-על-כתום (2.61:1), מחיר/online ירוק-על-לבן (2.28:1), ו-~40 chip/CTA/badge פעילים (לבן-על-כתום). נשארו לא-קריאים גם כש-HC דלוק.
- **היסוד:** `BsSemanticColors` ThemeExtension ב-`app_theme.dart` נושא 2 צבעים תלויי-HC, נקראים דרך top-level `bsOnAccent(context)` (foreground על מילוי-מבטא) ו-`bsSuccess(context)` (ירוק-טקסט על בהיר). רגיל → `white` / `#22C55E` ; HC → `BsTokens.inkLight` (6.7:1 על כתום) / `BsTokens.successDark`=`#15803D` (5.0:1 על לבן). + `floatingActionButtonTheme.foregroundColor` תלוי-HC. token חדש: `BsTokens.successDark`.
- **רולאאוט:** ~32 foregrounds ב-22 קבצים → helpers (FAB · lens-chip · מחיר · online-badge · dial · וכל ה-active pill/chip/CTA/badge ב-catalog/store/manager/store_dashboard/worker/tasks/chats/stock/projects/profile/rewards/departments/finance/persona/regression). **המצב הרגיל מוכח שלא משתנה** (helper מחזיר white/#22C55E כש-HC כבוי) → אפס סיכון לברירת-המחדל של הקולגה. ratchet-clean (משתמש ב-`inkLight`, לא raw literal).
- **נדחה לקומיט נפרד:** `_RunButton` (regression · dev) · `_ApprovalButton` textColor-param (manager_dashboard) · a11y לא-צבעוני (tooltips/semanticLabels/Dynamic-Type).
- guard: `test/a11y_contrast_theme_test.dart` (5 · normal=white/#22C55E · HC=inkLight/successDark · helpers resolve via Theme).
Gate: analyze 0 · a11y_contrast(5) + color_token_ratchet green · מוזג נקי (0 conflicts) על tip-הקולגה `5269b37`.

### #a11y-noncolor — Dynamic-Type + tooltips + image-semantics — 2026-06-08
- **Dynamic-Type:** `main.dart` קודם דרס את scaler-ה-OS (`TextScaler.linear(textScale)` קבוע · cap 1.15×) → התעלם לגמרי מהגדרת גודל-הטקסט של iOS/Android. עכשיו מקפל את ה-OS scaler עם העדפת-האפליקציה ו-clamp ל-`[0.85, 1.35]` (תקרת-בטיחות-layout, ניתנת להעלאה אחרי QA-ויזואלי). משתמשי low-vision מקבלים הגדלה אמיתית במקום ננעלים על 1.15.
- **Tooltips:** 13 `IconButton` icon-only קיבלו `tooltip:` עברי (גם = semantic label) — `camera_sheet` (סגור/פלאש ×3) + `chats_screen` (חזרה/אפשרויות/וידאו/שיחה/מצלמה/צירוף/אימוג׳י/נקה ×10).
- **Image semantics:** `product_images.productImage` → `excludeFromSemantics: semanticLabel == null` (תיקון נקודה-אחת, כל 15+ call-sites): תמונת-מוצר לא-מתויגת (שם-המוצר מוצג כטקסט לידה) הופכת דקורטיבית → screen-reader לא מקריא "תמונה" חסר-משמעות; caller שמעביר `semanticLabel` (hero) מקבל הקראה.
- **HC straggler:** `regression_panel._RunButton` (dev) → `bsOnAccent`.
- **לא שונה במכוון (false-positive):** `_ApprovalButton` "אשר" = לבן-על-ירוק-כהה `#1F8A4C` (כבר ~4.5:1) — bsOnAccent היה שובר אותו ב-HC (כהה-על-כהה).
Gate: analyze 0 · a11y_contrast(5) green · tooltips/semantics additive.
### #smart-home — מחיקת סקשן 'הכל' + מסך-בית חכם + מצב-היכרות — `catalog_screen`/`smart_home_screen`/`home_content_reorder`/`help_target` — 2026-06-09
- **מחיקת 'הכל' (per deletion protocol — MASTER_PROTOCOL חלק כ):** סקשן הקטלוג 'הכל' הוסר — הפיל-הקבוע, הניתוב, ברירת-המחדל, וה-classes היתומים `_AllOverview`/`_OverviewBlock`/`_OverviewRow`/`_OverviewEmpty`/`_openStudio` (256 שורות; grep אישר שאין callers אחרים). `catalogSectionProvider` ברירת-מחדל עכשיו `'בית'` (הפיל-הקבוע הראשון = הבית-החכם). ה-finder עבר ל-`'מאתר'` (`if(active=='מאתר') return FinderScreen()`). כל ה-fallbacks (`activate`/hide/delete) → 'בית'; home_shell טאב-בית → 'בית'. `_findCatalogTreeNodeByTitle`/`_CatalogRow` נשמרו (בשימוש).
- **`SmartHomeBody`** (smart_home_screen.dart) = נחיתת 'בית': מקטעים ניתנים-לסידור דרך `smartHomeSectionFor(HomeSection)` הקורא `homeContentOrderProvider` — מחלקות (`DepartmentsScreen.departments`, 2 שורות + "עוד") · 🌳 עץ-חכם (`kSmartProducts` + תמונות `productImage`) · מסלול-עבודה · כלים-מהירים (`openScanPlanSheet`/`StockScreen.route`/`openSiteHub`) · תכנון-חיבור (`InstallStudioScreen`) · מועדפים (`productFavoritesProvider`) · הזמנות-אחרונות (`sysOrdersProvider`). אין מחירים מומצאים (עץ-חכם → "מחיר לפי ספק").
- **`home_content_reorder`** ("סידור מסך הבית", נגיש מהגדרות→תצוגה דרך `HomeContentReorder.route()`) מציג עכשיו את אותם מקטעים דרך `smartHomeSectionFor`; ה-preview-widgets הישנים הוסרו (449 שורות) + imports יתומים. `kHomeSectionMeta` כותרות עודכנו (מחלקות/עץ-חכם/הזמנות-אחרונות).
- **מצב-היכרות (#30):** `helpModeProvider` (help_mode.dart) + `HelpTarget`/`HelpToggleButton`/`HelpModeBanner`/`HelpModeScaffold` (help_target.dart). 💡 ב-home app-bar = toggle; לחיצה-ארוכה = `showIntroTour`. במצב פעיל: `HelpModeScaffold` דוחף באנר מעל התוכן + `HelpTarget` עוטף אלמנט → לחיצה פותחת בועת-הסבר (Overlay, זנב מעל/מתחת אוטומטי). מחובר: בית (📷, סל-FAB), מסך-פתיחה (5 אלמנטים), מקצוע, שקופיות.

### #a11y-round3 — Semantics labels + round-3 deferred cosmetics — 2026-06-08
- **Semantics** (screen-reader) ל-7 אלמנטים אינטראקטיביים icon-only שלא הוקראו: catalog (נקה-סינון · בטל-breadcrumb · מידע-אביזר · `_MiniQtyBtn` הוסף/הפחת-כמות) · lipskey_product_sheet (סגור-תמונה-מלאה) · install_studio (`_stepBtn` הוסף/הפחת · הסר-מוצר). אדיטיבי (`Semantics(button,label)`), בלי שינוי-גודל (נמנע מסיכון-layout).
- **סימן ₪-** (budget `_fmt`): סכום שלילי הוצג `₪-3,150` → עכשיו `-₪3,150` (הסימן לפני הסמל).
- **חץ-breadcrumb** (finder): מפריד `›` (הצביע לכיוון הלא-נכון ב-RTL) → `‹`, תואם catalog/lipskey.
- **zoom errorBuilder** (lipskey_products `_openImage`): תמונת-zoom שנכשלת הציגה קופסת-שבר → `errorBuilder` עם emoji-fallback (×2).
- **התראת טעינה-חלקית** (catalog `_SearchResultsList`): כשתוצאות-החיפוש נחתכות ל-40 → footer "מציג 40 תוצאות ראשונות — צמצמו את החיפוש".
- **נדחה:** bidi-spec/brand (FSI מזהם מחרוזות + שובר `find.text` → צריך impl נקי דרך `textDirection`); ניגודיות-טקסט-משני (`888888`/`AAAAAA` ~120 אתרים — שינוי-עין בתחום-הצבע של הקולגה, דורש תיאום).
Gate: analyze 0 · full suite 1737/1737 green.
