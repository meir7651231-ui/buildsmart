# 04 — UI Architecture (whole-app) + Role-Drawer / Multi-Persona System + Legacy Map

> **Scope.** Faithful capture of the previous project's three architecture knowledge docs into the
> Flutter-port knowledge base. Sources (all read-only, none edited):
> - `app/knowledge/UI_ARCHITECTURE.md` (1560 lines — the master UI map across all 6 dashboards)
> - `app/knowledge/ROLE_DRAWER_SYSTEM.md` (844 lines — the multi-persona / role-drawer system)
> - `app/knowledge/legacy-map.md` (79 lines — the `index.html` → Preact `app/` porting index)
>
> Those docs were written against the **legacy prototype `/index.html`** (the spec, R6) and the Preact
> realization. They describe a *full-window dashboard* world. **This is exactly the world R2 forbids us
> from reproducing:** in our Flutter port every one of these screens collapses into a **dial** (R1–R9).
> So read this doc as "what the source intends to express," then jump to **§D — Flutter port notes** for
> how the Flutter shell diverges, what to mirror, and how this feeds `PARITY.md` domains **A** (navigation),
> **G** (personas), **F** (onboarding/RBAC). Companion docs: `01-shell-dials-components-trees.md` (the dial
> mechanics as already realized in Preact) and `02-data-stores-history.md` (data + stores + R1–R9).

---

# PART A — Overall UI Architecture (`UI_ARCHITECTURE.md`)

The master doc is a 6-part series. Part 1 (the contractor's 5-tab dashboard) lives inline in
`UI_ARCHITECTURE.md`; Parts 2–6 are pointers to sibling docs:

| Part | File | Subject |
|---|---|---|
| 1 — Contractor Dashboard | `UI_ARCHITECTURE.md` (inline) | the contractor 5-tab interface |
| 2 — Role Drawer & Multi-Persona | `ROLE_DRAWER_SYSTEM.md` | entry point + 5 role systems (Part B below) |
| 3 — System Manager Dashboard | `SYSTEM_MANAGER_DASHBOARD.md` | 4-tab manager interface |
| 4 — Supplier Store Dashboard | `STORE_DASHBOARD.md` | store login + 4-tab store interface |
| 5 — Courier Dashboard | `COURIER_DASHBOARD.md` | single-pane delivery hub |
| 6 — Field Worker Dashboard | `WORKER_DASHBOARD.md` | worker picker + task management |

## A.1 — App-wide navigation chrome (legacy/prototype shape)

> ⚠️ This describes the **legacy window model**, NOT what we build. Captured for fidelity. R2 turns all of
> this into dials.

### Bottom navigation bar — the original "5 FABs"
Fixed at bottom of every view; all 5 always visible. This is the legacy seed of R1's "5 FABs exactly":

| Tab | Icon | Label | ID | Handler |
|---|---|---|---|---|
| Home | BS | בית | `tabHome` | `go('home')` |
| Search | 🔍 | חיפוש | `tabSearch` | opens search overlay |
| BS Mode | ⚙️ | BS-mode | `tabMode` | toggles BS-mode (demo setting) |
| Menu | ☰ | תפריט | `tabMenu` | opens settings menu |
| Profile | 👤 | חשבון | `tabProfile` | `go('profile')` |

### App bar header
- **Left:** site/project name badge with pin icon — clickable → `openCartSitePicker()` (change destination site).
- **Center:** dynamic page title (per current view).
- **Right:** notification bell 🔔 with unread-count badge; cart count badge 🛒 with item count.

### The contractor 5-tab dashboard (legacy Part 1)
Five tabs, each a full-window view. **In our world each becomes a dial spine — see `01-*.md`.**

1. 🏠 **בית (Home)** — discovery, search, quick products. 8 vertical sections:
   global search bar (placeholder `חפש כלי עבודה, חומר בנייה, אביזר...`) · hero banner
   (`⚡ אקספרס לאתר` / `הזמן עכשיו — קבל לאתר עד שעתיים`) · AI hub button (🤖 `בינה מלאכותית ואוטומציה`
   → `openAIHub()`) · 8-card category grid (`go('catalog')`) · smart product picker
   (`עץ התקנה חכם — אינסטלציה`, `renderHomeProducts()` over `HOME_PRODUCTS[]`) · smart workflow
   (`.project-hero` → `go('project')`) · 3 quick-action cards (📐 `סרוק תוכנית עבודה`→`go('scan')`,
   📦 `המלאי שלי`→`go('stock')`, 📋 `משימות העבודה`→`go('tasks')`) · reorder history
   (`renderReorderHistory()` over `DEMO_HISTORY[]`, empty `עדיין אין הזמנות קודמות...`).
2. 📋 **קטלוג (Catalog)** — two views: flat catalog (`view-catalog`, `renderCatalog()`, category chips
   from `CATALOG`, sort menu `catMainSort`, info hint `💡 קטלוג אינסטלציה מלא — לחץ על מוצר לפתיחת עץ המוצרים.`)
   and drill-down (`view-catnav`). **Auto-drill reduction:** for each `ATTR_SCHEMA` attribute, count distinct
   values in the category — 0–1 values → auto-skip, >1 → show as a drill step. The 5 standard attributes:
   `productType` (סוג מוצר 📦) · `secondary` (מאפיין 🔧) · `diameter` (קוטר / מידה 📏) ·
   `variantOpt` (דגם 🔩) · `brandName` (מותג 🏷️). Drill state object `catNav { cat, type, secondary,
   diameter, prod, accMode, picks{} }`.
3. 🏗️ **הפרויקטים (Projects)** — two sub-tabs: `🌳 הפרויקט שלי` (smart project, day-by-day stage cards,
   `openDayPicker()`, progress bar, budget box → `openBudgetDetail()`, finance hub → `openFinanceHub()`,
   completion banner `🎯 בסיום כל ימי העבודה — הפרויקט מוכן למסירה.`) and `🏗️ האתרים שלי` (sites list from
   `PROJECTS`, add via `openProjectModal()`, per-site status `openSiteStatus(id)`, editor `openSiteEditor(id)`,
   switch `switchProject(id)`). Site modals: `siteStatusOverlay`, `siteEditOverlay`, `projectModal` (new
   project gets id `PRJ-[sequence]`, empty `cart:[]`, empty `treeProgress:{}`).
4. 🛒 **רכש (Cart)** — two sub-tabs `🛒 הסל שלי` / `📦 ההזמנות שלי`. Site-assignment strip
   (`ההזמנה תשויך ותישלח לאתר` + `החלף ›`→`openCartSitePicker()`), shipment-planning strip
   (single: `🚚 אספקה אחת · …` + `חלק לגלים ›`→`openCartShipPlanner()`; multi-wave:
   `ההזמנה תגיע ב-[N] גלים`), cart items grouped by supplier store, haul-type selector
   (`🚗 קטן`/`🚐 וואן`/`🚛 משאית`, `pickHaul(storeId,haulId)`), empty state (`הסל ריק` /
   `עבור לקטלוג ובחר מוצר אב...`), checkout summary (delivery-slot picker `pickSlot(index)`, payment box
   `💳 פירוט תשלום`→`openPaymentDetail()`, VAT `מע"מ (17%)`, credit box `מסגרת אשראי — קבלן` /
   `שוטף +60`→`openCreditDetail()`, confirm `✓ אשר הזמנה · משלוח ל[project name]`→`checkout()`).
5. 👤 **חשבון (Profile/Identity)** — gamification: hero card (name/role/stars/site), stats
   (`📊 הנתונים שלך` — `הוצאה עד כה`/`הזמנות`/`אתרים`/`דירוג`), spending (`💰 הוצאה על אתר זה`), perk
   (`🎁 היתרון שלך`), achievements (`🏆 התוצאות שלך`, 8 badges 🔨/🚿/💪/🌟/📚/🎯/⚡/🏅), ranks ladder
   (`🪜 סולם הדרגות`), gamification hub (`openGamificationHub()`), settings links (`⚙️ הגדרות`).

## A.2 — Key overlays/modals & cross-cutting patterns

- **Settings menu (dial-based).** The doc already calls this out as the seed of R3/R4: a hierarchical tree
  of dials + toggles. Top-level sections (legacy list): תצוגה · התראות · נגישות · אזור ושפה · משלוח · מידע ·
  איפוס · אבטחה (23 items) · שירות ותמיכה (15 items). **"Dials: each setting option = circle + label (R4
  compliance)."** This is the bridge from legacy → our dial doctrine. (Compare the realized 10-group settings
  tree in `01-*.md §5`.)
- **Notification bell** — list with unread count; item → detail sheet; breadcrumb `title › detail lines › action`.
- **Search overlays** — `catSearchSuggest` / `homeSearchSuggest` / `catNavSuggest`, all same pattern:
  real-time results, breadcrumb paths, kind labels (product/accessory/category/screen), fuzzy fallback for typos.
- **Product tree overlay** — hero (`rootImg`/`treeTitle`/`rootName`/`rootMeta`/`rootPrice`), installation
  diagram (SVG, 8 types: faucet/toilet/shower/infra/sealing/tiling/cable/profile; stage click highlights
  accessories: `⤵ הודגשו האביזרים לשלב...`, idle hint `💡 הקש על שלב...`), accessories section
  (`רכיבים ואביזרים`), tool bag, add-to-cart (`הוסף לסל`, toast `[product-name] × [qty] נוסף לסל`), brand/variant
  pickers (`brandOverlay`/`variantOverlay`/`accDetailOverlay`).
- **Plan scanner** — plan types אינסטלציה/חשמל/אדריכלות; flow `סורק...`→`מזהה סמלים...`→`מאתר נקודות...`,
  detection confidence 84%–98%, per-item 3-store price comparison.

### Data structures (verbatim shapes from the doc)
`TREES[key]` = `{ name, img, image?, category, subcat, brands[{brand,price,rec,tag}], acc[{name,img,price,stock}],
catalogProduct, productType, secondary, diameter, … }`.
`VARIANTS[key]` = `{ label, opts[{name,diameter,delta,…}] }`.
`CATALOG` = `[{cat,icon,items[]}]`.
`DIAGRAMS[treeKey]` = `{ title, stages[{ic,l,s,match[]}] }`.
`PROJECTS` = `[{id,name,addr,manager,cart[],treeProgress{}}]`.
Cart item = `{name,img,price,qty,auto,store}`.
Order = `{id,createdAt,status,project{site,stage},delivery{day,window},items[],suppliers[],totals{itemsSubtotal,
shippingTotal,vatRate,vat,grandTotal},shipments?[]}`.

### Cross-cutting UX patterns (named in the doc)
Search (input→suggestions→breadcrumb→navigate) · Drill-down (categories→auto-skipped attribute steps→
products→tree) · Product tree (card→overlay→hero+diagram+accessories→add) · Cart flow (add→qty→haul/slot→
summary→confirm→orders) · Site management (view sites→select active→edit→switch→cart follows) · Smart project
(day breakdown→mark complete→track→stage-tied accessories) · Mobile gestures (tap/swipe/long-press/pull-to-refresh).

---

# PART B — Role-Drawer / Multi-Persona System (`ROLE_DRAWER_SYSTEM.md`)

## B.1 — Overview (the persona doctrine)

BuildSmart supports **5 distinct roles**, each with a unique login/onboarding flow, role-specific dashboard,
custom tab navigation, domain features, and access level. **Crucially the shared-architecture invariant:**

- All roles share the **same underlying data model** (`PROJECTS`, `TASKS`, `ORDERS`, `WORKERS`, `SYS_ORDERS`).
- **Single database / state tree.** One source of truth viewed through different lenses.
- **RBAC layer controls visibility** (filtered/restricted per role).
- **Demo mode allows seamless switching** between roles — same data, different view.

> This is the single most important architectural fact for the port: personas are **lenses over one model**,
> not separate apps. The drawer footer states it verbatim: `הדגמה — כל התצוגות חולקות מאגר נתונים אחד`.

## B.2 — The Role Drawer UI

**Component:** `.role-drawer` + `.role-drawer-scrim`. **Trigger:** `.welcome-hamburger` on the welcome screen,
`onclick="toggleRoleDrawer()"` (toggles `.show` on drawer + scrim). Header `rd-head`: title `מי אתה?`,
subtitle `בחר תפקיד כדי להיכנס`. Footer `rd-foot`: `הדגמה — כל התצוגות חולקות מאגר נתונים אחד`.

### The 5 role-pick buttons (`role-pick-btn`) — VERBATIM, in order

Each button = left emoji (`rpb-ic`) + center title+subtitle (`rpb-txt`) + right arrow `‹` (`rpb-arrow`),
`onclick="enterRole('[role]')"`:

| # | Emoji | Title (verbatim) | Subtitle (verbatim) | Action |
|---|---|---|---|---|
| 1 | 👷 | קבלן | הזמנת חומרים, מלאי, משימות | `enterRole('contractor')` |
| 2 | 👔 | מנהל המערכת | ניהול מוצרים, חנויות, לקוחות | `enterRole('manager')` |
| 3 | 🏪 | חנות ספק | הזמנות נכנסות, מלאי החנות | `enterRole('store')` |
| 4 | 🛵 | שליח | משלוחים ועדכוני סטטוס | `enterRole('courier')` |
| 5 | 🦺 | עובד | המשימות שהוקצו לי בשטח | `enterRole('worker')` |

> These five are **identical** to the Preact BS-dial `TILES` and the Flutter `kPersonas` (see `01-*.md §3.2`).
> The drawer *is* the legacy ancestor of our BS dial.

## B.3 — The 5 role systems (entry flow + dashboard shape)

### Role 1 — 👷 קבלן (Contractor)
**Flow:** `enterRole('contractor')` → `showScreen('screen-login')` → *(opt)* `screen-profession` →
*(opt)* `screen-prep` → `enterApp()` → the **5-tab dashboard** (Part A.1).
**`screen-login`:** logo + brand, tagline `מהשרטוט עד האתר — בלי לשכוח כלום`, header `ברוך הבא 👋` /
`התחבר כדי להתחיל לעבוד`, phone input (label `מספר טלפון`, placeholder `050-0000000`, type `tel`), continue
`המשך`→`loginExisting()`, alt `כניסה עם פרטי אחרים`. Back → `showScreen('screen-welcome')`.

### Role 2 — 👔 מנהל המערכת (System Manager)
**Flow:** `enterRole('manager')` → `showScreen('screen-manager')` → `admTab('m-products')` (default tab).
Header `adm-top`: back `‹ יציאה`→`showScreen('screen-welcome')`, title `👔 מנהל המערכת`.
**4 tabs (`adm-tabs`):**

| Icon | Label | Handler | Pane id | Container |
|---|---|---|---|---|
| 📊 | לוח בקרה | `admTab('m-products')` | `m-products` (default `.on`) | `mgrDashboard` |
| 🚚 | הזמנות | `admTab('m-orders')` | `m-orders` | `mgrOrderList` |
| 👥 | לקוחות | `admTab('m-customers')` | `m-customers` | `mgrCustomers` |
| 🛠️ | ניהול | `admTab('m-manage')` | `m-manage` | `mgrManage` |

Pane architecture: `.adm-pane` each; `admTab()` removes all `.on`, adds to selected. Detail overlay
`mgrStoreDetailOverlay`.

### Role 3 — 🏪 חנות ספק (Supplier Store)
**Flow:** `enterRole('store')` → `showScreen('screen-store-login')` → `renderStoreLogin()` (choose store) →
`storePortal()` → `showScreen('screen-store')`.
**`screen-store-login`:** logo 🏪, title `כניסת ספקים`, subtitle `בחר את החנות שלך כדי להיכנס לפורטל הניהול`,
store list `storeLoginList` (`renderStoreLogin()`), security note
`🔒 באפליקציה האמיתית כל ספק מתחבר עם קוד גישה אישי. זוהי כניסת הדגמה.`. Back → welcome.
**`screen-store`:** back `‹ יציאה`→`storeLogout()`, title `🏪 חנות ספק` (+ store name via `storeTitle`).
**4 tabs:**

| Icon | Label | Handler | Pane id | Container | Pane note (verbatim) |
|---|---|---|---|---|---|
| 🏠 | בית | `admTab('s-home')` | `s-home` | `storeHome` | — |
| 📥 | הזמנות | `admTab('s-orders')` | `s-orders` | `storeOrderList` | `אשר הזמנות והכן אותן — הסטטוס יעבור לשליח ולמנהל.` |
| 📦 | מלאי | `admTab('s-stock')` | `s-stock` | `storeStockList` | `מוצר שאזל לא יוצג לקבלנים בקטלוג.` |
| 🧰 | פורטל | `admTab('s-portal')` | `s-portal` | `storePortal` | `כלי הספק — דירוג, SLA, אזורי הפצה, הנחות כמות וברקודים.` |

Detail overlay `storePickOverlay`.

### Role 4 — 🛵 שליח (Courier)
**Flow:** `enterRole('courier')` → `showScreen('screen-courier')` → `renderCourier()`.
**Single pane — NO tabs.** Header: back `‹ יציאה`→welcome, title `🛵 שליח · משאית [vehicle ID]`
(e.g. `🛵 שליח · משאית 14`). Content: courier home (`courierHome`, `renderCourierHome()`) + delivery list
(`courierList`, `renderCourierList()`). Detail overlay `courierDetailOverlay`.

### Role 5 — 🦺 עובד (Field Worker)
**Flow:** `enterRole('worker')` → `showScreen('screen-worker')` → `renderWorker()` →
`pickWorkerScreen([index])`.
**Single pane — NO tabs.** Header: back `‹ יציאה`→welcome, title `🦺 עובד`. Instruction (`adm-note`):
`בחר את שמך, בצע את המשימה, צרף תמונה ושלח לאישור המנהל.`. Worker picker (`workerPick`) = name buttons
(e.g. דוד כהן / אברהם שחף / עלי כהן), `onclick="pickWorkerScreen([index])"`, default `activeWorker`.
Tasks body (`workerTasksBody`, `renderWorker()`) in 3 sections — **task-filtering logic (verbatim):**

| Section | Predicate |
|---|---|
| Current Task | `status === 'active'` OR `status === 'rejected'` |
| Queue | `status === 'pending'` |
| Submitted | `status === 'review'` OR `status === 'done'` |

Progress metric: `doneCount = (status==='done')`, `total = all assigned`, `% = Math.round(doneCount/total*100)`.

## B.4 — Role selection flow & backend actions

**Welcome screen (`screen-welcome`):** green button `כניסה ללקוח קיים`, registration (name+contact), demo
`המשך ללא רישום`, hamburger `מי אתה?` (role drawer).

**`enterRole(role)` does 5 things (verbatim from doc):**
1. **Close drawer** — remove `.show` from drawer + scrim.
2. **RBAC sync** — `appStore.set({role: role})` (updates permissions layer).
3. **Audit log** — `auditLog('מעבר תפקיד', role)`.
4. **Navigate** — route to role-specific screen.
5. **Render** — populate content.

## B.5 — Data & state management (RBAC linkage)

**Global state variables (verbatim):**
```js
let entryMode = 'demo'|'new'|'existing'    // user entry state
let userName = ''                          // registered/existing customers
let userProfession = 'קבלן'|'חשמלאי'|'קבלן שיפוצים'  // contractor specialty
let activeWorker = 0                        // index into WORKERS[]
let taskRole = 'worker'                     // task-operation context
```

**RBAC:** implemented via `appStore` + a `role` property; conditional rendering keyed on `role`. Role values:
`'contractor'|'manager'|'store'|'courier'|'worker'`. **Shared data model** (`PROJECTS`/`TASKS`/`ORDERS`/
`WORKERS`/`SYS_ORDERS`) filtered per role: contractors see only their projects/orders; managers see all;
store sees only their orders; courier sees only assigned deliveries; worker sees only assigned tasks.
**Demo note:** one DB for all roles — changes in one role surface in the others.

---

# PART C — Legacy → Preact Mapping (`legacy-map.md`)

> The legacy file `/index.html` is **the spec** (R6); `legacy-map.md` is the index of what was ported into
> Preact `app/` and what wasn't. **For the Flutter port this is doubly indirect: legacy → Preact → Flutter.**
> Cited `index.html` line ranges are the original anchors.

## C.1 — Data structures

| Area | Legacy | Preact | Notes |
|---|---|---|---|
| TREES catalog | `index.html:5441-6044` | `src/data/catalog.ts` | 202 products + accessories |
| VARIANTS | `index.html:6060-6182` | `src/data/variants.ts` | 44 size/SKU pickers |
| STORE_PRICING | `index.html:11908-11941` | `src/data/suppliers.ts` | 696 SKU prices × 3 stores |
| SUPPLIER_STORES | `index.html:11942-11946` | `src/data/suppliers.ts` | 3 suppliers (s1/s2/s3) |
| TOOLS | `index.html:6216-6320` | `src/data/tools.ts` | 21 job-type tool bundles |

## C.2 — State & navigation (THE persona/dial bridge)

| Area | Legacy | Preact | Notes |
|---|---|---|---|
| `appStore` (role/screen) | `index.html:20280` | `src/store/bs-store.ts` | **replaced by `activePersona` signal** |
| `toggleRoleDrawer()` | `index.html:18364-18370` | `bs-store.ts` `toggleBs()` | **dial pattern instead of drawer** |
| `enterRole(role)` | `index.html:11806-11820` | `bs-store.ts` `setPersona()` | **identical role list** |
| `showScreen(id)` | `index.html:11635-11640` | `app.tsx` ActiveView switch | routed via persona |
| `loginExisting()` | `index.html:11823-11829` | (not yet ported) | onboarding TBD |

> This is the crux: the legacy **role-drawer → Preact BS-dial**, legacy **`showScreen` window-routing → Preact
> persona-driven `ActiveView`**. The whole window→dial transform R2 demands is recorded right here.

## C.3 — Catalog / Search / Regression (abbreviated)

- **Catalog:** `renderCatalog()` `9310-9346`→`product-grid.tsx`; category drill `8901-8974`→`category-circles.tsx`;
  `productPrice(key)` `6397-6408`→(TBD); `openTree(key)` `9546-9605`→`product-sheet.tsx` (light port).
- **Search:** `buildSearchIndex()` `8591-8621`→`data/search-index.ts`; `searchSuggestions(q)` `8629-8651`→
  `lib/search.ts searchExact()` (prefix-first); `fuzzySearchSuggest(q)` `21095-21114`→`searchFuzzy()`
  (Levenshtein, tol `≤ floor(len/3)+1`); voice/barcode demo modals `21181-21229`→`lib/voice.ts`,`lib/barcode.ts`
  (real Web Speech + BarcodeDetector).
- **Regression:** `runRegressionTests` `15253-15329`→`test/runner.ts`; `buildRegressionReport` `15829-16112`→
  `runner.ts`+`tests/*`; `regCheckProduct` `12320-12508`→`tests/products.ts`; `BUTTON_REGISTRY` `12517-12942`→
  `test/registry.ts` (21 vs 176 entries); `findDuplicates` `12984-13061`→`tests/dupes.ts`; display-sync probes
  `14759-14901`→`tests/dsync.ts`.

## C.4 — Personas status (Preact, per legacy-map)

| Persona | Legacy screen | Preact view | Status |
|---|---|---|---|
| contractor | `screen-login` + `view-catalog` | `views/home.tsx` | implemented (catalog + sheet) |
| manager | `screen-manager` `4207-4238` | `views/manager.tsx` | partial (regression panel only) |
| store | `screen-store-login` + `screen-store` | `views/store.tsx` | stub |
| courier | `screen-courier` `4291-4308` | `views/courier.tsx` | stub |
| worker | `screen-worker` `4321-4330` | `views/worker.tsx` | stub |

## C.5 — Not yet ported (Preact, per legacy-map)

| Area | Legacy | Why later |
|---|---|---|
| Onboarding (login/registration) | `4042-4145` | after personas are real |
| Smart product tree | `9546-9605, 10251-10310` | large feature; needs accessories UI |
| Cart line items | `7700-8100` | cart icon exists; cart page missing |
| Courier delivery flow | `17963-18150` | stub view only |
| Worker task picker | `11832-11881` | stub view only |
| Manager dashboards (orders/customers/manage) | `4212-4231` | only regression tab built |
| Store dashboard | `4254-4288` | stub view only |

---

# PART D — → Flutter port notes

> How the Flutter shell (`app_flutter/lib/`) diverges from everything above, what to mirror, and how this
> informs `PARITY.md` domains **A** (navigation), **G** (personas), **F** (onboarding/RBAC). Flutter status
> markers below follow PARITY's legend: ✅ works · 🟡 partial/façade · 🔌 built-but-disconnected · ❌ absent ·
> ⛔ blocked (no data/server/device). Cross-check `01-*.md §10` (the per-area scoreboard) for file:line detail.

## D.1 — The shell divergence (this is the whole story)

| Layer | Legacy/prototype | Preact (live) | Flutter port |
|---|---|---|---|
| Navigation spine | bottom **5-tab** window-router (`showScreen`) | **persona-driven** single `<main>` + dial overlays (R2) | **4-tab bottom IndexedStack** (`home_shell.dart`) — קטלוג · שיחות · התראות · חנות + cart FAB |
| Persona switch | role-drawer → full dashboard screens | BS dial → `ActiveView` switch | BS dial → drill only; **no persona-driven `ActiveView`** |
| "5 FABs" (R1) | the legacy bottom tabbar (5) | toggleBs/toggleMenu/toggleSearch + CSS row | single `OpenDial { none, bs, search, bsMode, menu }` enum + full-screen scrim |

**Three shells, three philosophies.** Legacy = full-window dashboards per role. Preact = R2 dials over one
persona-selected `<main>`. **Flutter = a WhatsApp-style 4-tab chrome with a cart FAB, where only the BS dial is
wired to real content.** The persona dashboards documented in Parts A/B (manager 4-tab, store 4-tab, courier
single-pane, worker single-pane) **must NOT be reproduced as Flutter screens** — R2, and the project's history
of 3 reverts, forbids it. Their *functionality* lands as BS-dial drill levels + a shared order engine.

## D.2 — What to MIRROR (faithful, low-risk)

- **The 5 personas verbatim** (B.2). Already mirrored: `kPersonas` (`data/personas.dart`) == legacy
  role-drawer `TILES`. Keep emoji + Hebrew exact (👷 קבלן / 👔 מנהל המערכת / 🏪 חנות ספק / 🛵 שליח / 🦺 עובד).
- **The persona section trees** (the dial translation of each dashboard's tabs/panes). Already a verbatim
  mirror in `data/sections.dart` (`kStoreSections`/`kCourierSections`/`kWorkerSections`/`kManagerSections`).
  The legacy manager 4 tabs (לוח בקרה/הזמנות/לקוחות/ניהול), store 4 tabs (בית/הזמנות/מלאי/פורטל), courier
  single-pane, worker 3-section task list (B.3) are exactly what those trees encode.
- **The shared-data-model invariant** (B.1/B.5). This is the architectural north star for domain G: one model,
  five lenses, RBAC filter. The Flutter port has **no shared order engine yet** (`SYS_ORDERS` → ❌, PARITY G) —
  mirror this concept before fleshing any persona, or each persona will reinvent state.
- **The worker task-status state machine** (B.3): `pending`/`active`/`review`/`done`/`rejected` and the 3-section
  filtering. Port it as the contract behind the worker dial-drill (PARITY G: "לולאת-אישור עובד→מנהל").
- **Verbatim Hebrew pane notes** (B.3 store table): `אשר הזמנות והכן אותן — הסטטוס יעבור לשליח ולמנהל.` /
  `מוצר שאזל לא יוצג לקבלנים בקטלוג.` / `כלי הספק — דירוג, SLA, אזורי הפצה, הנחות כמות וברקודים.` — these are
  R6/R8 strings; reuse them as dial labels/toasts, never invent.

## D.3 — Where Flutter DIVERGES (and the open decisions)

- **Identity vs browse conflation (domain G core issue).** Legacy/Preact keep *being* a persona
  (`appStore.role` / `activePersona`, drives the screen) separate from *browsing* its sub-tree
  (`bsDrillPersona`). Flutter's `activePersonaProvider` only plays the **browse** role — there is no
  current-identity concept and no persona-driven `ActiveView` (because the shell is bottom-nav). Consequence:
  the legacy `enterRole()` 5-step contract (close-drawer → **RBAC sync** → **audit log** → navigate → render)
  has **no Flutter equivalent**. PARITY F lists this exactly: role-drawer is 🟡 ("BS dial הוא זה — להשלים
  מעבר-תפקיד"); the RBAC sync + `auditLog('מעבר תפקיד', role)` are unported.
- **The R1 "5 FABs" decision is still open.** PARITY A states it as a live decision:
  *"לממש 5-FAB או להשאיר 4-טאב ולחבר menu/search אחרת"*. Legacy had a literal 5-tab bottom bar; Flutter chose
  4 tabs + cart FAB. This doc confirms the legacy lineage (A.1) but does not resolve the decision — it must be
  made explicitly (currently 🟡).
- **Onboarding is absent (domain F).** Legacy flow `splash→welcome→login→profession→prep→enterApp` (B.3
  contractor flow; legacy-map C.5 marks login/registration `4042-4145` not-yet-ported). Flutter enters
  straight to the catalog tab (PARITY F: ❌ "נכנס ישר"). The decision *"זרימת-כניסה או דילוג"* is open.
  `loginExisting()`/`pickProfession()`/`enterAsExisting()`/`enterAsDemo()` and the `entryMode`/`userName`/
  `userProfession` state (B.5) have no Flutter mirror.
- **Manager = regression only.** Legacy manager has 4 real tabs (B.3); Flutter has just the regression panel,
  reached via the BS dial's extra `🔬 בדיקות רגרסיה` leaf (a Flutter-only addition — see `01-*.md §3`).
  PARITY G marks manager 🟡 ("רגרסיה בלבד"; needs KPI/orders/customers/CRUD).
- **Store/courier/worker are name-stubs.** Legacy gives them full dashboards (B.3); Flutter currently
  surfaces only names → toast (PARITY G: 🔌). The store *view* `store_screen.dart` exists as a WhatsApp-style
  surface (mirrors Preact's `StoreView`) but is not wired to the shared engine.

## D.4 — How this informs PARITY domains A / G / F

**Domain A — מעטפת וניווט.** This doc supplies the legacy provenance of the "5 FABs" (A.1 bottom tabbar) and
the window→dial transform (C.2). It confirms: contractor persona = the main app (the 5-tab dashboard, Part A.1)
→ in Flutter it must become a dial that routes to the contractor's menu/search dials, **not** a full screen.
Action items it reinforces: (1) wire the built-but-disconnected menu dial (`menu-speed-dial.tsx` equivalent) +
search dial to a FAB; (2) resolve the 5-FAB-vs-4-tab decision; (3) fill the קבלן persona tile so "everything
that exists becomes reachable."

**Domain G — 4 אפליקציות-התפקיד (כ-dial).** This is the doc's richest contribution. Parts A/B give the exact
tab/pane structure of each legacy dashboard (manager 4 / store 4 / courier 1 / worker 3-section) that PARITY G
says to re-express as dial-drill. It also supplies the worker state machine (B.3) and — critically — the
**shared-data-model + per-role-filter invariant** (B.1/B.5) that justifies PARITY G's "מנוע-הזמנות משותף
(`SYS_ORDERS`)" line. **Guard rail:** Parts A/B describe *windows*; G demands *dials*. Do not let the dashboard
descriptions tempt a screen build (R2; 3 prior reverts).

**Domain F — Onboarding / זהות / RBAC.** Part B is essentially the F spec from the Preact side: the role-drawer
UI + the 5-step `enterRole()` (RBAC sync + audit log) + `entryMode`/`userName`/`userProfession`/`activeWorker`
state + the per-role data-access filter. PARITY F's rows map 1:1: `splash→welcome→login→מקצוע→app` (B.3),
`pickProfession` specialties (`קבלן`/`חשמלאי`/`קבלן שיפוצים`, B.5), `role-drawer` (B.2), RBAC matrix +
`can`/`requirePerm` (the `appStore.role` conditional-render layer, B.5), security center (the legacy "אבטחה"
23-item settings section, A.2 — already partially in Flutter settings). The verbatim role subtitles (B.2) and
the demo-mode note (`הדגמה — כל התצוגות חולקות מאגר נתונים אחד`) are the R6 strings to reuse.

## D.5 — Highest-leverage gaps surfaced by this capture

1. **No persona identity / RBAC layer in Flutter** — `enterRole()`'s RBAC-sync + audit-log have no mirror;
   browse ≠ identity is conflated (domain F/G blocker).
2. **No shared order engine (`SYS_ORDERS`)** — the "one model, five lenses" invariant (B.1) is unimplemented;
   every persona dial will need it (domain G).
3. **No onboarding flow** — splash/welcome/login/profession all absent (domain F); decision pending.
4. **Persona dashboards are stubs** — manager (regression-only), store (façade view), courier/worker
   (name→toast); their dashboard *content* (A/B) must be re-expressed as dial-drill, never as windows (domain G).
5. **5-FAB vs 4-tab shell decision unresolved** — legacy lineage documented (A.1) but not chosen (domain A).
