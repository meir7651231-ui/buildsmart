# 08 — Remaining Prototype Symbols (the last ~14% → 100% coverage)

This file captures **every prototype function/data-symbol not already named** in
`proto/01`–`proto/07`. With it, prototype function-name coverage reaches **100%**
(`COVERAGE.md` previously logged 620/720 = 86%).

Source: `/home/user/buildsmart/index.html` (single-file vanilla-JS prototype, Hebrew
RTL). Every line ref `[L#]` was grepped against source. These are the **secondary
helpers, pickers, device/PWA glue, and per-button self-tests** — each belongs to a
domain already documented in `proto/01`–`07`; this file is the leaf-level index so no
symbol is unaccounted for. One line each: **what it does + `[L#]`**.

> **Scope note.** Nothing new architecturally — these are the helpers *inside* the
> documented domains. The deep "what + how-to-port" prose for each domain stays in its
> numbered file; this is the completeness ledger that maps the remaining names there.

---

## 1. Catalog-drill helpers → domain `proto/02` (catalog · CatNav engine)

The attribute-driven category-navigation engine (`catNav` state object → search / sort /
stage). All of these mutate or render the `catNav` drill.

- `clearCatDrill()` `[L8330]` — resets the whole `catNav` drill object (`cat/type/secondary/diameter/prod/accMode/picks`) then `syncCatDrill()`.
- `catNavIsPlasson()` `[L8411]` — true if any TREE under the current category carries `productType` (i.e. a Plasson catalog category vs. a smart-tree breed).
- `catNavResetSearch()` `[L8949]` — clears the CatNav search box, hides suggestions, and resets sort to `'default'`.
- `catNavFilterRows(rows)` `[L8901]` — filters row descriptors by the live CatNav query string (`title.indexOf(q)`).
- `catNavSortRows(rows)` `[L8907]` — sorts row descriptors by the active mode: `name` / `name_desc` (Hebrew `localeCompare`) / `count` / `price_asc` / `price_desc`.
- `toggleCatNavSort()` `[L8916]` — opens/closes the sort dropdown (`#catNavSortMenu`), toggles the `.on` class on the sort button.
- `catNavSetSort(mode)` `[L8923]` — sets `catNavSort=mode`, closes the menu, re-renders CatNav.
- `renderCatNavSortMenu(stage)` `[L8933]` — builds the sort-option buttons; options depend on stage (adds `count` for group stages; adds `price_asc/desc` for pick/product/variant/brand stages). Hebrew labels verbatim: `ברירת מחדל`, `שם א׳-ת׳`, `שם ת׳-א׳`, `כמות פריטים`, `מחיר — מהזול`, `מחיר — מהיקר`.
- `renderCatNavAccList()` `[L9029]` — renders the "accessories for category" list (`accessoriesForCategory`), applying the same query filter + sort; header `אביזרים נלווים · N`.
- `checkProductStandard()` `[L13076]` — data-integrity audit: scans TREES, returns `{total, families[], issues[]}` reporting products missing standard fields (a catalog QA pass).
- `openBrandsFor(...)` `[L10701]` — opens the brand chooser for a catalog product (brand → price drill step).
- `addCatalogProduct(key)` `[L9348]` — pushes a CatNav/catalog product into `cart` (name+brand suffix, price via `productPrice`, qty via `catQty(key)`), then `updateCartCount()`.

---

## 2. Quantity / size / store pickers → domain `proto/02`,`03`

- `openQtyInput(i)` `[L10422]` — `prompt()` for an exact accessory quantity (tree row `i`); validates ≥1 then `setQty`. (R9 note: Flutter port must replace `prompt` with inline input.)
- `setCatQty(key,val)` `[L10434]` — sets catalog product qty (`catalogQty[key]`), updating **every** on-screen qty display node (a product can render on catalog + CatNav simultaneously).
- `pickAccSize(si)` `[L10771]` — selects accessory size index `si`, recomputes price (`basePrice + sizes[si].delta`), re-renders accessories; toast `נבחרה מידה: …`.
- `pickCatalogStore(storeKey,productKey)` `[L10383]` — sets the active supplier store whose prices the catalog shows, re-renders accessories + `#rootPrice` + catalog.
- `closeCategoryEditor()` `[L7257]` — hides the category-editor overlay (`#catEditOverlay`).

---

## 3. Smart-tree helpers → domain `proto/02` (smart tree · accessories · tools)

- `saveTreeProgress()` `[L7132]` — deep-copies `treeState` into `activeProject().treeProgress[currentTree]` (JSON round-trip snapshot so later edits don't mutate the save).
- `toggleTreeTool(i)` `[L10461]` — flips `treeToolState[i].picked`, re-renders accessories.
- `toggleToolbag()` `[L10462]` — flips `toolsExpanded` (expand/collapse the tools section).
- `updateTreeTotal()` `[L10464]` — recomputes tree total `₪` + `pickCount` = picked accessories + picked tools + main product (only when its ✓ is on); writes `#treeTotal`/`#pickCount`.
- `refreshRootCheck()` `[L10486]` — syncs the main-product ✓ inside the tree (`#rootCheck`): shows only for rich/`catalogProduct` items, toggles `.on` by `productInCart`, updates the hint text (`✓ המוצר ייכלל בסל` / `סמן ✓ …`).
- `toggleRootInTree()` `[L10504]` — toggles the root product in/out of cart (shared with catalog/home checkbox), then `refreshRootCheck()` + `updateTreeTotal()`.
- `toolBox(...)` `[L10237]` — renders a tool card/box for the tools strip in the tree.
- `addMainProduct(key)` `[L10618]` — pushes the root/main product to `cart` with `productKey`, brand suffix, price, qty 1, and `store: storeForProduct(key)`.

---

## 4. Manager UI helpers → domain `proto/06` (manager persona)

- `mgrAnimateCounters()` `[L16374]` — animates every `[data-count]` element from 0 → target over 22 steps (dashboard metric count-up, with `data-prefix`).
- `mgrScrollStores()` `[L16397]` — smooth-scrolls to the stores anchor (`#mgrStoresAnchor`).
- `mgrShowUnavailable()` `[L16400]` — clears the category filter + search and re-renders the manager dashboard; toast `מציג את כל המוצרים — הלא-זמינים מסומנים`.
- `mgrToggleSection(key)` `[L16764]` — accordion toggle for a manage-section (`mgrManageOpen`), re-renders `renderMgrManage`.
- `mmSettingRow(label,val,fn)` `[L16758]` — renders one manager-settings row (`.mm-set`, optional `onclick`, ` ›` affordance) — manager-side settings list builder.
- `createStore(initial)` `[L20267]` — generic **reactive store factory** (`get`/`set`/subscribe with shallow-diff change detection); the R107 architecture-layer state primitive (used by `BSStore` etc.). Misc/infra, lives in the personas/engine layer.
- `portalFeature(html)` `[L20754]` — injects HTML into the supplier-portal feature overlay body (`#portalFeatureBody`) and shows `#portalFeatureOverlay`.
- `runAutoStock()` `[L20945]` — supplier portal "auto stock sync" stub: toast `המלאי סונכרן — 53 יחידות עודכנו ✓`, closes the portal overlay.
- `getAllOrders(cb)` `[L7739]` — async order fetch: uses `apiService.getOrders()` if present, else falls back to local `SYS_ORDERS`; callback-style.
- `stockInfo(s)` `[L10155]` — maps a stock state to `{icon,label,cls}`: `warehouse→🏬 במחסן/wh`, `site→🏗️ באתר/site`, else `🛒 צריך להזמין/order`.

---

## 5. Store-replacement (held-for-missing) → domain `proto/06` (`heldForMissing` flow)

When a contractor picks a product *while* replacing a missing line in a held order, this
3-way flow decides where the product goes.

- `openReplacementChoice(key,qty)` `[L17738]` — opens the decision overlay (`#missingDecisionOverlay`) with two buttons: "מוצר חילופי — עדכן בהזמנה N" (`confirmReplacement`) vs "הזמנה חדשה — המשך לרכש רגיל" (`replacementAsNewOrder`); stores `replacementPick`.
- `confirmReplacement()` `[L17759]` — applies the pick as a **substitute line** in the held order (updates the missing line in `SYS_ORDERS`), then closes the decision overlay.
- `replacementAsNewOrder()` `[L17785]` — keeps the held order's missing line cancelled and routes the picked product into the **normal purchase** path instead.

---

## 6. Undo / skeleton / page-FX → domain (cross-cutting UX, R107 layer; touched in `proto/05`/`06`)

- `offerUndo(message,revertFn)` `[L20576]` — shows the snackbar undo bar (`#bsUndoBar`, "בטל"), stores `revertFn`, ARIA-announces, auto-hides after 5 s.
- `hideUndo()` `[L20601]` — hides the undo bar, clears the stored revert fn + timer.
- `showSkeleton(containerId,rows)` `[L20500]` — fills a container with N skeleton placeholder rows (`.ux-skel`) during loading.
- `mockSaved(o)` `[L7998]` — test/demo bridge: pushes a mock order into `SYS_ORDERS` so supplier/courier/manager all see it (mimics a real checkout).
- `sanitizeText(s)` `[L20182]` — strips `<` / `>` from a string (lightweight XSS guard); trivial.
- `tpl(str,data)` `[L20326]` — micro template engine: `{{{raw}}}` (unescaped) + `{{escaped}}` (via `escapeHTML`) substitution; trivial helper.

---

## 7. PWA / device-status / router / init → domain `proto/01` (shell · bootstrap, R107 layer)

- `registerPWA()` `[L20360]` — registers `service-worker.js` if `navigator.serviceWorker` exists (guarded, logs via `bsLog`).
- `wireRouter()` `[L20392]` — IIFE that wraps `showScreen`/`go` so both write the URL hash (`SCREEN_TO_HASH`), enabling browser back/forward + deep-linking; guarded against `hashchange→go→setHash` loops via `BSRouter.isHandling()`.
- `initDeviceStatus()` `[L20630]` — wires the status-bar widget (`#bsDeviceStatus`): connectivity + battery; binds `online`/`offline` + battery events.
- `paintConn()` `[L20633]` — paints the connectivity glyph (`#bsConn`): `📶 מחובר לרשת` / `⚠️ אין חיבור — מצב לא מקוון`. (Defined nested inside `initDeviceStatus`.)
- `paintBattery(bat)` `[L20646]` — paints battery glyph + % (`#bsBattery`): `⚡` charging / `🪫` ≤20% / `🔋`; hides if Battery API absent.
- `paintLoading(pct,subText)` `[L9786]` — renders the scan-loading progress UI (`.scan-load`, percentage + sub-text) during barcode/AI scanning.
- `initPullToRefresh()` `[L20527]` — binds a real touch pull-to-refresh gesture on `.body`; releasing past threshold re-renders the current screen.
- `initSwipeToClose()` `[L20671]` — binds downward-swipe-to-dismiss on `.overlay .sheet` grips (in addition to backdrop tap).
- `makeBarcodeSVG(code)` `[L21051]` — generates a deterministic barcode-style SVG (`<rect>` bars whose widths/gaps derive from `charCodeAt`).
- `aiPlanResult()` `[L21283]` — renders the AI-planner result sheet: a fixed materials BOM (`אריחי קרמיקה 60×60` / `דבק אריחים` / `רובה למישקים` / `פרופיל פינה`) with quantities. (AI hub, `proto/05`.)

---

## 8. Picker-overlay close helpers (trivial — `classList.remove('show')`) → domains `proto/01`,`03`,`04`

Each hides one overlay; documented together as they share one body.

- `closeSitePicker()` `[L7071]` — `#sitePickerOverlay` (project/site switcher). `proto/04`.
- `closeDeliveryPicker()` `[L7114]` — `#deliveryPickerOverlay` (delivery-window picker). `proto/03`.
- `closeCartSitePicker()` `[L10965]` — `#cartSitePickerOverlay` (cart→site picker). `proto/03`.
- `closePaymentDetail()` `[L11000]` — `#paymentDetailOverlay` (payment-method detail). `proto/05`.
- `closeCreditDetail()` `[L11032]` — `#creditDetailOverlay` (editable credit-ceiling sheet). `proto/03` (credit).

---

## 9. Search-FAB action shims → domain `proto/07`,`03`

- `searchReorder()` `[L8476]` — search-result action: `go('cart')` then opens the cart-site picker (re-order shortcut).
- `searchOpenNotifications()` `[L8481]` — search-result action: `go('home')` then opens notifications.
- `dynamicContentEntries()` `[L8552]` — builds the dynamic search/index corpus (projects, sites, …) so the search FAB can match live app content. (`proto/07` search.)

---

## 10. Smart-tree / task / context shims → domains `proto/04`,`06`

- `refreshTasks()` `[L11885]` — re-renders the worker screen (`renderWorker`) if it's visible (task list refresh). `proto/06`.
- `prepRow(a,kind)` `[L11720]` — renders one prep/load row with a tag (`להעמסה`/`להזמנה`/`באתר`/`במחסן`) — courier/worker prep list. `proto/06`.
- `regCheckRow(name,pass,detail)` `[L15650]` — self-test report row renderer; guarantees every failed check shows a reason (fallback Hebrew explanation). `proto/06` self-test.
- `regIsContextError(msg)` `[L13931]` — classifies a thrown error as a missing-app-state context error (`/undefined|null|not a function/i`) vs a real bug. `proto/06` self-test.

---

## 11. Service-tools (calc) + shake-report → domain `proto/05` (service hub)

- `setUnitConv(k)` `[L22272]` — sets the active unit-converter unit (`activeUnitConv`) and reruns `runUnitConv()`.
- `setQtyMode(m)` `[L22301]` — sets the quantity-calculator mode (`qtyCalcMode`) and reruns `svcQtyCalc()`.
- `toggleShakeReport()` `[L22214]` — toggles shake-to-report (`shakeReport.enabled`); on enable binds `devicemotion→onDeviceShake`; toast `דיווח בניעור הופעל/כובה`.

---

## 12. Self-test harness — per-button test functions → domain `proto/06` (BUTTON_REGISTRY)

**Pattern.** The self-test system (documented in `proto/06` via `BUTTON_REGISTRY` and the
`buildRegressionReport` engine) is driven by many small **per-button test functions**. Each
returns a `{button, label, checks:[{name,pass,expected,got}]}` descriptor; the suite
runners aggregate them into the regression report. They wrap the call in `try/catch` and
use `regIsContextError` to distinguish a missing-state crash from a real failure. Naming
prefixes encode tier: `testButton_*` (button-contract), `testContract_*` (UI contract),
`testCrit_*` (critical-path), `testImp_*` (important-path), plus `testTen_*` and
`testFamily_*` families. Counts: **3** `testButton_`, **4** `testContract_`, **10**
`testCrit_`, **9** `testImp_`.

Suite runners / core entry points:
- `runRegressionTestsCore(panel)` `[L15641]` — compat shim: writes `buildRegressionReport()` into a panel.
- `runDisplaySyncTestCore(probeIds)` `[L14869]` — runs display-sync probes (press a button that changes a number, compare data value vs. on-screen value); optional id subset.
- `runTenButtonSuite()` `[L13780]` — runs the 10 `testTen_*` smoke tests, map → result descriptors.
- `showCustomResultsCore(ids,compareMode)` `[L15482]` — runs a user-selected subset of tests (splits `dsync:`-prefixed probe ids from button-contract ids).
- `onRunClick()` `[L12278]` — (nested) the self-test panel "run" button handler; guards that `runRegressionTests` is loaded before invoking.

Per-button test functions (all in the L13183–14676 self-test block):

| prefix | functions `[L#]` |
|---|---|
| `testButton_` | `testButton_courierAdvance` `[L13183]` · `testButton_checkout` `[L13247]` · `testButton_addTreeToCart` `[L13380]` |
| `testContract_` | `testContract_closeTree` `[L13796]` · `testContract_mgrOrderDetail` `[L13834]` · `testContract_mgrDoSearch` `[L13878]` · `testContract_storeOrderSetFilter` `[L13901]` |
| `testCrit_` | `testCrit_addSingle` `[L14203]` · `testCrit_addScanToCart` `[L14222]` · `testCrit_chooseCartSite` `[L14247]` · `testCrit_storeLogin` `[L14276]` · `testCrit_storePickLine` `[L14299]` · `testCrit_storeMissLine` `[L14337]` · `testCrit_taskActionClick` `[L14374]` · `testCrit_taskReject` `[L14392]` · `testCrit_switchProject` `[L14420]` · `testCrit_showDeliveryNote` `[L14450]` |
| `testImp_` | `testImp_setCatalogCategory` `[L14476]` · `testImp_openTree` `[L14503]` · `testImp_chooseSite` `[L14526]` · `testImp_cycleAccStock` `[L14554]` · `testImp_moveStock` `[L14588]` · `testImp_setTaskLocation` `[L14616]` · `testImp_clearNotifications` `[L14634]` · `testImp_adjustBudget` `[L14652]` · `testImp_navSafe(fn,arg,label)` `[L14676]` (shared safe-invoke helper for the `testImp_` family) |

> **Port note.** These are test fixtures for the *prototype's* in-app self-test screen, not
> product features. The Flutter port reproduces the *audited behaviours*, not the harness;
> the harness itself is documented for completeness only. The system-level design is in
> `proto/06`.

---

## 13. Uncovered data symbols `BSL` / `BS_DEBUG` (the 2 in COVERAGE.md)

These were the only two unnamed "data tables" in `COVERAGE.md`. On inspection both are
**R107 architecture-layer infrastructure**, not product-content tables — which is why
content coverage was already 100%.

- **`BS_DEBUG`** `[L20189]` — `var BS_DEBUG=true;` — global **debug flag** for the console-hygiene layer; gates the `bsLog` wrapper (`bsLog` guards each `console.*` call so logging can never throw). Production would flip it off. Not product data.
- **`BSL`** → resolves to **`BSLiveSync`** `[L20339]` (the `BSL…` token COVERAGE.md flagged) — `var BSLiveSync=(function(){…})` — the **cross-tab live-sync bridge**: wraps `BroadcastChannel('buildsmart-sync')` in a publish/subscribe shape matching a real socket, so call-sites don't change when a server is added. Companion to `BSStore` `[L20233]` (the localStorage/memory persistence layer). Pure infra; carries no product content. (No standalone identifier literally named `BSL` exists in source — confirmed by `grep -c '\bBSL\b' = 0`.)

---

## Coverage closure

With this file, every prototype symbol is now named in the knowledge base:

- **Functions:** the ~100 previously-unnamed helpers/pickers/device-glue/self-tests above
  are now each logged with `[L#]` and mapped to their documented domain → prototype
  function coverage = **100%** (was 620/720 = 86% in `COVERAGE.md`).
- **Data tables:** `BSL` (=`BSLiveSync`) and `BS_DEBUG` are identified as R107 infra (not
  content) → table coverage = **84/84 = 100%** (content was already 100%).

**This file completes `COVERAGE.md`.** No prototype function, helper, picker, device hook,
self-test fixture, or data symbol remains unaccounted for. The remaining known semantic gap
is non-source (the 3 un-extracted PDFs, mainly AQUATEC) — captured by reference, not
reproducible from `/index.html`.
