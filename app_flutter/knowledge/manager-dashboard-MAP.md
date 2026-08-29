# Manager Dashboard (מסך הניהול · מרכז השליטה) — knowledge MAP

> **Purpose:** distilled, durable reference for any future work on the manager screen.
> **Provenance:** synthesized 2026-06-23 from (a) `MANAGER-SCREEN-COMPLETE.md` (branch
> `claude/nice-volta-BSbVm`, owner's 3-researcher master doc) + (b) a live-code 3-agent
> audit on this branch. Both AGREE. Where they differ, the live-code finding wins and is
> flagged ⚠️. **NOT a build order — reference only.**

---

## 0. One-line truth
The manager screen is **already built** as a full 4-tab board (`manager_dashboard_screen.dart`, ~3,409 lines), **mostly live intra-app**, but the **shipped build runs on LOCAL in-memory demo seeds** (backend flags OFF). "Building" = filling the **edit-gaps** (3 sections are display-only) + new features. The old manager **dial is deprecated → full-screen board is the architecture (no R2 violation).**

---

## 0.5 ⚖️ OWNERSHIP / GOVERNANCE DECISION (owner ruling 2026-06-14 · lesson #84)
> **BINDING principle** — the current code **CONTRADICTS it** (⚠️ confirmed by the 23/6 live audit). Ruling is 9 days old; its code-quotes were **re-verified against current code on 23/6 ✓** (§0/§0.5 HR on manager = still true).

**Who the manager is:** the **platform-owner / the user himself**. Needs full **No-Code** control of the whole APP from his screen (no code, no tech knowledge): catalog · prices · categories · brands · product-tree · global settings · **what each persona sees** (contractor/worker/courier/supplier) · users + roles.

**CORE RULE — capability-ownership follows the BUSINESS context, NOT the manager:**
| topic | employer/owner | belongs to |
|---|---|---|
| workers (tasks + vacations) | the **CONTRACTOR** | **contractor board** |
| couriers (vacations + mgmt) | the **STORE/supplier** | **store board** |
| contractor credit limit | the **STORE** (it grants it) | **store board** — manager sees oversight/analytics **ONLY** |

**Emergency override (manager = super-admin, FAULTS ONLY):** daily ownership is the business's; the manager keeps an override **for faults only**, limited to exactly two ops:
- **order advance** ("קדם שלב", fault-mode) — primary: store+courier · override: manager
- **price edit** — primary: store · override: manager
- Both must be **marked in the manager UI as a fault/override action**. **NO override on credit** (store-exclusive) or **HR** (employer-exclusive) → manager is **read-only (oversight)** there.

**Other rulings:** express-delivery fee → **manager** (platform, global) · VAT → **manager** (legal) · manager chat → **support/system channel ONLY** (manager does NOT join the business chat contractor↔store↔courier) · 🐛 **BUG:** the manager-board settings button currently opens the shared **contractor** settings = misplacement → fix.

**Why (owner's reasoning):** corrected twice — *"they're not my workers"*, *"it's their employer's concern"*. The manager operates the **PLATFORM**, not the contractor's/store's workforce.

**Implementation target (#84) — current code CONTRADICTS this (⚠️ 23/6 audit confirms):**
- `manager_dashboard_screen.dart` HAS §0 👷 worker-approvals (`_ApprovalsBody:2621`) + §0.5 🏖️ vacations (`_VacationsBody:2834`); request flow = worker/courier → **manager**. ← WRONG per this ruling.
- **Redesign:** (1) simplify manager board to **pure platform-admin** (remove HR); (2) worker approvals + worker vacations → **CONTRACTOR board**; (3) courier vacations + courier mgmt → **STORE board**; (4) re-route flow: worker→contractor · courier→store.
> ⚠️ **Therefore the §4 rows "✅ LIVE 👷 אישורי-עובדים + 🏖️ חופשות on manager" are a DESIGN-BUG to RELOCATE, not features to keep.** Re-read the §8 roadmap through this lens: manager = platform-admin; HR → owning business board; credit-limit edit → STORE board (not manager); manager keeps only the two fault-overrides (advance, price) + global (express/VAT) + catalog/users/visibility.

---

## 1. Entry / identity / access
| What | File | Note |
|---|---|---|
| persona picker | `role_picker_sheet.dart` | 👔 מנהל → subtitle "ניהול מוצרים, חנויות, לקוחות" |
| **owner Google gate** | `welcome_screen.dart:283-395` | `_managerGoogleLogin` → `isOwnerEmail()`; rejects non-owner ("רק חשבון הבעלים…") |
| owner allowlist | `board_accounts_local.dart:98` | `kOwnerEmails = {'meir7651231@gmail.com'}` (single email) |
| seed login | `board_auth.dart:243-266` | `admin` / `5555` (display "מנהל המערכת") |
| owner session | `board_auth.dart:286-303` | `loginManagerViaGoogle{uid,displayName}` — **NO DEMO · NO LOGOUT** |
| screen gate | `manager_dashboard_screen.dart:71-73` | not manager → renders `WelcomeScreen(manager)` ("מבחוץ לא רואים כלום") |
| "‹ יציאה" | `:190-199` | **navigation-only** `Navigator.maybePop()` — does NOT clear session (by product rule) |
| AppBar title | `:111` | "מרכז השליטה" + green **"חי"** pill |
| tab state | `manager_dashboard_state.dart:9` | `managerTabProvider` = `StateProvider<int>` (0-3), `IndexedStack` `:206-220` |

---

## 2. ⭐ LIVE vs DEMO seam — the headline (3 compile-time flags, all default OFF)
`lib/data/repositories/backend.dart`:
| flag | define | default | OFF effect |
|---|---|---|---|
| `useFirebaseBackend` | `USE_FIREBASE_BACKEND` | **OFF** (`:12-17`, also needs `Firebase.apps.isNotEmpty`) | all repos `_local` (demo seeds) |
| `kServerCallables` | `SERVER_CALLABLES` | **OFF** (`:66`) | advance = local write · credit = `contractorCredit()` hash |
| `kClaudeAi` | `CLAUDE_AI` | **OFF** (`:138`) | AI buttons (credit-explain/reject-reason) absent |

- Default/test build (Firebase never init in tests) → **DEMO/seed, in-memory, persisted to SharedPreferences** (`bs.orders.v1`). ⚠️ The green **"חי" pill is aspirational** on the shipped demo build.
- Connected build = `--dart-define=USE_FIREBASE_BACKEND=true SERVER_CALLABLES=true CLAUDE_AI=true` (STATUS.md:310). No build config sets these by default (grep: none).
- **Backend IS deployed + verified** (STATUS v6.71, `buildsmart-b0b78/me-west1`): `computeCredit`, `advanceOrderStage`, `reviewRoleRequest`, `firestore.rules` — all `Deploy complete!`. Just flag-gated off client-side.
- **drop-in pattern:** all manager writes go through the SHARED provider → editing features built now work in-app immediately and auto-sync to the server when the flag flips. **No need to flip backend first to build edit-features.**

---

## 3. The 4 tabs (status · live/demo · actions · file:line)
| tab | file:line | status | key data | actions |
|---|---|---|---|---|
| 📊 לוח בקרה | `:371-663` | ✅ built, **read-only** | `managerAnalyticsProvider` + `ordersEngineProvider` | **none** |
| 🚚 הזמנות | `:665-1401` | ✅ live (intra-app) | `ordersEngineProvider` | **god-advance "קדם שלב ›"** + filter + contact + detail-sheet |
| 👥 לקוחות | `:1404-2145` | ✅ live-derived, **read-only** | `managerCustomersProvider` (group-by-buyer) | filter + detail sheet + 💳 AI-credit (gated) |
| 🛠️ ניהול | `:2147-3409` | mixed (accordion) | per-section | 3 live writers + 4 display-only (§5) |

### 📊 לוח בקרה — 5 KPI + pipeline
- `_MetricGrid` `:419-466`. ⚠️ **only 🚚 openOrders is dynamic.** Other 4 are **hardcoded const maps** (never move): 📦 catalog=54 · 🧰 accessories=148 · ✅ available=202 (**fake-by-construction** — stock seeded all-true, `manager_dashboard.dart:212-215`) · 🏪 stores=3/3 (`kManagerStores` all on).
- `_OrderPipeline` `:533-599` — 6 stages, live counts + bars. Labels: new=התקבלה preparing=בהכנה ready=מוכן pickup=נאסף transit=בדרך delivered=נמסר.
- **Prototype-only (not ported = gap):** revenue total · category mix · store leaderboard 🥇🥈🥉 · product-management w/ availability toggle · ＋מוצר/＋חנות.

### 🚚 הזמנות — the action tab
- `_OrderSummary` `:848` (orders/open/revenue ₪5,490 seed) · `_OrderStageChips` `:905` (**view-only filter**) · `_OrderRow` `:973` · `_OrderDetailSheet` `:1187` (watches engine live).
- **THE write:** `_advance(o)` `:797-814` → `ordersEngineProvider.notifier.advance(o.id)`. Routing (`orders_engine.dart:482-509`): default=local setStage+persist · Firebase+callables-ON → **`advanceOrderStage` callable** (`functions/src/orders.ts:50`, role-checked + audit + **`revertIllegalOrderStageWrite` reverts non-single-forward writes**). **Forward-single-step only.**
- `ContactActions(order.customerPhone)` 📞/💬 — **inert on seeds** (no phone). `_MiniTracker` 6-seg.
- **Missing:** no create/edit/cancel/reassign order · no search (omitted).

### 👥 לקוחות
- `managerCustomersProvider` (orders_engine.dart:693) → `mgrCustomerList` (manager_dashboard.dart:272) — group-by-buyer fold over orders (rooted in 4 demo seeds: יוסי כהן/אבי מזרחי/משה אברהם/דוד לוי).
- ⚠️ **credit limit = `contractorCredit(name)` HASH** (manager_dashboard.dart:256-264) of name.hashCode → ₪30k-120k band. **Not a real policy; a manager CANNOT edit it.** Real `used` (Σ sum) only server-side via `computeCredit` when `SERVER_CALLABLES`=ON (`customerCreditProvider` `:1502`, `customers_local.dart:95`).
- `_CustomerDetailSheet` `:1924` read-only + `💳 הסבר אשראי` `:2079` (gated on `claudeGatewayProvider`).
- **Repo is READ-ONLY** (`customers_repository.dart:27-49`): `all/byName/creditLimit/computeCredit` — **no add/update/delete/setCreditLimit**.

---

## 4. 🛠️ ניהול — 8 accordion sections
| section | file:line | status |
|---|---|---|
| 👷 אישורי עובדים | `:2279-2311` / `_ApprovalsBody :2621` | ✅ **LIVE write** — `tasksProvider.approve/reject` → coins+🔔+chat; shows proof photo (`taskPhotoWidget`) |
| 🏖️ בקשות חופשה | `:2314-2331` / `_VacationsBody :2834` | ✅ **LIVE write** — `vacationRequestsProvider` approve/reject → 🔔 + (worker only) chat thread |
| 🔑 שיוך תפקידים | `:2407-2422` / sheet | ✅ **LIVE** — `setRole` callable; disabled+banner w/o backend |
| 🗂️ קטגוריות | `_CategoriesBody :3077` | ⚠️ display-only (static count; hint claims rename but none) |
| ⚙️ הגדרות אפליקציה | `_AppSettingsBody :3108` | ⚠️ **hardcoded const** express ₪120 · credit ₪50,000 · VAT 18% — no edit |
| 🌳 עץ המוצרים | `_ProductTreeBody :3145` | ⚠️ **stub** (summary only; "NO invented edit") |
| 🏷️ מותגים ומחירים | `_BrandsBody :3182` | ⚠️ display-only (`kBrands`); no price/brand edit |
| 🔬 בדיקות רגרסיה | `:2390-2405` | dev-only (`kDebugMode`, tree-shaken in release) → `RegressionPanelScreen` |

⚠️ The ⚙️ ₪50,000 setting **contradicts** the 👥 hash-band (₪30k-120k) — two unrelated credit numbers.
⚠️ **GOVERNANCE (§0.5):** the 👷 אישורי-עובדים + 🏖️ חופשות rows are **HR** — per the 2026-06-14 owner ruling HR is NOT the manager's job; they belong on the **contractor/store** boards. They are LIVE = currently-built, but **slated to RELOCATE** (manager = platform-admin only).

---

## 5. Manager-exclusive systems
- **🖥️ impersonation** `manager_screens_sheet.dart` — view as worker/courier/store/contractor; `boardAuthProvider.impersonate(role)` (`board_auth.dart:305-344`), banner "👔 צופה כ… · מצב מנהל" + "חזרה לניהול" (`returnFromImpersonation` on pop). Views the seed account per role; one-deep, not persisted.
- **🔑 role-assign** `manager_role_assign_sheet.dart` — phone→uid (`UsersLookup.uidByPhone`) → role chip (🏪/🛵/🦺/👔, **never contractor**, `kAssignableRoles:63`) → `assignRole()` → **`setRole`** callable (`auth_state.dart:387`, server checks admin-claim). No-backend → disabled + amber banner. **No faked success** (HARD RULE).
- **💳 AI** `credit_explain_screen.dart` (Claude phrases REAL credit numbers, gated `claudeGatewayProvider`) + reject-reason "✨ נסח סיבת דחייה".
- **🔬 self-test** `test_harness/runner.dart` — 11 packages, 1,539+ tests, CI-enforced.
- **profile** `manager_profile_screen.dart` — live session + live order stats (`sysOrdersProvider`); **no profile editing**; no logout (by design).

---

## 6. Data providers (canonical)
| data | provider | live? |
|---|---|---|
| orders (list/pipeline/metrics) | `ordersEngineProvider` (orders_engine.dart:628) | ✅ shared engine |
| customers | `managerCustomersProvider` (:693) | ✅ derived |
| analytics/categories | `managerAnalyticsProvider` (:678) | ✅ (but 4/5 KPIs static maps) |
| credit | `customerCreditProvider` (:1502) → `contractorCredit` local / `computeCredit` server | local OFF · server ON |
| approvals | `pendingApprovalTasksProvider` / `tasksProvider` | ✅ |
| vacations | `vacationRequestsProvider` | ✅ |
| brands/settings/tree | `kBrands` / consts / counts | ⚠️ seed display |
> seeds (`kManagerOrderSeed`/`kManagerStores`/`kManagerCatalogCategories` in `logic/manager_dashboard.dart`) run only when no live data; P2 = gate fake seed to 0 when flag ON.

---

## 7. ⚠️ Critical gaps (live-code findings)
1. **Everything flag-gated to LOCAL/demo** in the shipped build (the #1 thing).
2. **Customers: no CRUD; credit = uneditable hash.**
3. **4/5 dashboard KPIs are static constants** (catalog/accessories/available/stores).
4. **4/8 manage sections display-only** (categories/settings/tree/brands — legacy edits removed).
5. **`reviewRoleRequest` (role-approval inbox) NOT wired to the manager dashboard** — its only UI is `RoleRequestsInboxScreen`, mounted from the **contractor** `profile_screen.dart:315`. Manager-tier approvals (store/contractor requests) have **no manager entry point**. The manager's role tool is the *different* `setRole` push.
6. **Finance NOT wired** — `firestore.rules` reserve `finance*` for the manager + `finance_hub_sheets.dart`/`budget_screen.dart` exist, but **no finance UI in the manager dashboard**.
7. **No manager notifications** (`push.ts` exists, no manager-facing surface).
8. No order create/edit/cancel/reassign; no order search.

---

## 8. Canonical build roadmap (G1-G9) — REFERENCE (not building now)
Principle **R9: every edit = inline input** (not modal/prompt). All G* write the shared provider → drop-in server-ready.
| # | gap | prototype fn | effort |
|---|---|---|---|
| G1 | edit ⚙️ settings (express fee + credit default; VAT fixed) | `mgrEditExpress`/`mgrEditCredit` | S |
| G4 | 🗂️ rename category (propagates to products) | `mgrRenameCat` | S |
| G2 | edit 🏷️ brands+prices (add/edit/remove) | `mgrAddBrand`/`mgrEditBrand`/`mgrDelBrand` | M |
| G3 | edit 🌳 product tree (accessory add/edit/remove, req/opt + price) | `mgrAddAcc`/`mgrEditAcc`/`mgrDelAcc` | M |
| G6 | store CRUD (add/toggle/remove) | `openMgrStore`/`toggleMgrStore` | M |
| G7 | audit log (server-persisted who-did-what) | `auditLog` | M |
| G5 | product management (search + availability toggle + CRUD) | `mgrToggleAvail`/`openMgrProduct` | L |
| G8 | server RBAC enforcement (rules check manager-claim on sensitive ops) | RBAC_MATRIX | L |
| G9 | (v2) 2FA · session lock · advanced reports | — | L |

Canonical Preact source: `bs-dial.tsx:177-235` ↔ `index.html:4213-4216`; **`SYSTEM_MANAGER_DASHBOARD.md` (863 lines)** = ambitious full spec (orders table · customers table · 7 manage sections: system-settings · warehouses/suppliers · stores · reports/analytics · RBAC · audit-log · tools). RBAC verbatim: "מנהל מערכת: ניהול מלא — הזמנות · קטלוג · משתמשים · דוחות".

---

## 8.5 ⭐ EXPANDED VISION — `MANAGER-MASTER-PLAN.md` (branch nice-volta, 2026-06-23)
> The owner's grand "mission-control" vision that SUPERSEDES the §8 G-list (G1-G9 = a subset of module M3). Per-module flags `kMgr*` (default OFF) · R9 inline · zero-regression · **does NOT block launch.** Full 105-step detail in that doc.

**10 modules:**
| M | module | rides on (exists) |
|---|---|---|
| M1 | 🫀 Live Cockpit (real-time pulse, sparklines, red-alerts) | ordersEngine + managerAnalytics |
| **M2** | 🤖 **AI Co-Pilot ("ask your business")** — Claude over the data + graphs + proactive alerts + morning-brief + agentic | `functions/claude.ts` (built) |
| M3 | 🎛️ God-Mode CRUD (catalog/brands/trees/categories/stores/fleet/settings — incl. the §8 G1-G6) | manager screen + catalog |
| M4 | 💰 Money center (revenue/profit/credit-exposure/cashflow/VAT + AI forecast + PDF/Excel export) | orders+credit |
| M5 | 👤 Customer-360 (per-contractor history + churn-risk-AI + LTV) | managerCustomers + chat |
| M6 | 📦 Inventory/supplier intel (stock + shortage-forecast-AI + supplier-rank + reorder) | stock/store + catalog |
| M7 | 👷 People & permissions (role-assign · presence · impersonation · approvals · audit-log) | role_assign + impersonate (built) |
| M8 | 🗺️ Live ops map (couriers/deliveries/sites real-time) | GPS native |
| M9 | 📣 Marketing engine (banners/promos/coupons → segmented push) | push |
| M10 | 🩺 System health (1,539 tests · Crashlytics · connection/build status) | test_harness |

**Already live (base poured):** M1/M7 partial · M2 infra · M3 partial (the 4 tabs + impersonation + role-assign + AI-credit).
**Phasing:** P1 = cockpit(M1) + CRUD-edits(M3 G1-G6) + audit/RBAC(M7). P2 = Co-Pilot(M2) + money(M4) + 360(M5) + stock(M6) + mktg(M9). P3 = live-map(M8) + AI-forecasts + full-agentic.
**❤️ heart-path (if one):** **M2 — the AI Co-Pilot** (the "wow"; Claude infra already built).
**Build-plan steps 1-105** grouped A-L; step 8/18/34/50/… are zero-regression tests; steps 102-105 = analyze/CI/staged-rollout/docs. **DoD = 105 ✅, each module OFF=zero-regression, owner GA per module.**

> ⚠️⚠️ **GOVERNANCE CONFLICT to reconcile (§0.5 ruling 2026-06-14 vs this plan 2026-06-23):**
> The master-plan's **M7 step 82 "unified approval queue (workers + vacations + role-requests)"** and **M3 "employees" CRUD** put **HR on the manager** — which the **2026-06-14 ruling forbids** (workers→contractor, couriers→store; manager = oversight-only on HR/credit).
> **Reconciliation (proposed, needs owner confirm):** keep on the manager only PLATFORM-admin CRUD — **stores/fleet-as-entities, catalog, users+roles, visibility, global settings** (these align with both docs). **RELOCATE** worker-task-approvals + worker/courier-vacation-approvals to the **contractor/store boards**; the manager's M7 shows **oversight/audit only** + the **two fault-overrides** (order-advance, price-edit). Credit-limit EDIT → STORE board (manager sees analytics). **Which doc wins on HR is an OPEN owner decision** — flagged, not assumed.

---

## 9. File index (Flutter source of truth)
`screens/manager_dashboard_screen.dart` (4 tabs) · `screens/manager_profile_screen.dart` · `screens/manager_role_assign_sheet.dart` · `screens/manager_screens_sheet.dart` · `screens/credit_explain_screen.dart` · `screens/role_requests_inbox_screen.dart` (reviewRoleRequest UI — NOT on manager) · `logic/manager_dashboard.dart` (analytics+seeds) · `state/manager_dashboard_state.dart` · `state/board_auth.dart` (owner/impersonate) · `state/orders_engine.dart:482-693` (advance routing + providers) · `data/repositories/backend.dart` (flags) · `data/repositories/customers_repository.dart` (read-only contract) · `data/board_accounts_local.dart:98` (owner allowlist) · `functions/src/{credit,orders,reviewRoleRequest}.ts` · `firestore.rules` (manager RBAC) · `test_harness/`.

## ⚠️ R2 note
R2 ("no window/dialog") is a **Preact-dial** rule. In Flutter the manager is **already a full-screen board** (dial deprecated, `data/sections.dart:152-199`) — building here does NOT violate R2. ✅
