# 04 — Contractor: Home · Projects/Sites · Budget/Finance · Tasks/Site-Management · Scan · Stock

Exhaustive port reference for the **contractor (קבלן) persona** of the BuildSmart prototype.
Source of truth: `/home/user/buildsmart/index.html` (single-file prototype, Hebrew RTL, ~22,416 lines).
All `[L#]` line references are to that file. Every Hebrew string below is **verbatim** — copy it character-for-character into the Flutter port.

This document is self-contained: data structures, render functions, behaviors, overlays, the task status machine, the dual manager/worker roles, the two ten-feature hubs (Finance + Site), the plan-scan engine, and the stock screen. It ends with a **→ Flutter port notes** section (none of this is wired in Flutter yet — toast stubs only).

> The contractor is the **default/primary persona**. `view-home` is `active` on load `[L4416]`. `loginExisting()` defaults `userProfession='קבלן'` and sets the greeting `👷 שלום, קבלן` `[L11823-11830]`.

---

## 0. Global state (contractor scope)

| Variable | Init value | `[L#]` | Notes |
|---|---|---|---|
| `PROJECTS` | 3 seeded sites (see §2) | `[L6447]` | `let` — mutable; the contractor's construction sites. |
| `activeProjectId` | `'PRJ-1'` | `[L6452]` | Which site is "active now". |
| `projSeq` | `4` | `[L6453]` | Next id suffix → `PRJ-4`, `PRJ-5`… |
| `activeProject()` | fn | `[L6455]` | `PROJECTS.filter(p=>p.id===activeProjectId)[0] \|\| PROJECTS[0]`. |
| `cart` | `[]` | — | Per-project; saved/loaded on `switchProject`. |
| `smartDayDone` | `{}` | `[L7146]` | Key `"taskId-dayN"` → `true` when that work-day is done. |
| `smartStepDone` | `{}` | `[L7147]` | Key `"taskId-stepN"` → `true` when an execution step is done. |
| `projectBudget` | `{total:15000,spent:9840}` | `[L7150]` | Editable. |
| `budgetCategories` | 4 categories (see §3) | `[L7152]` | Editable. |
| `expandedStage` | `null` | `[L7330]` | Which smart-project stage card is open. |
| `daySelStage` | `{}` (per-card stage selection) | — | Used by `dayDiagramHTML`. |
| `expandedProduct` | `null` | `[L10615]` | Which home product card is expanded. |
| `HOME_PRODUCTS` | `['faucet','toilet','shower']` | `[L10614]` | Tree keys shown on home. |
| `TASKS` | 5 tasks (see §6) | `[L8023]` | `let` — mutable; status mutates in place. |
| `WORKERS` | `['רן (עובד)','עומר (עובד)']` | `[L8021]` | |
| `taskRole` | `'manager'` | `[L8022]` | `'manager'` or `'worker'`. |
| `activeWorker` | `0` | `[L8022]` | Index into `WORKERS`. |
| `currentTask` | `null` | `[L8022]` | Task open in the detail sheet. |
| `WORK_LOG` | 2 historical days | `[L8156]` | Read-only demo. |
| `stockTab` | `'warehouse'` | `[L8194]` | `'warehouse'` or `'site'`. |
| `STOCK_DEMO` | 11 named items (see §8) | `[L6202]` | Each value `'warehouse'` or `'site'`. |
| `selectedPlan` | `'plumbing'` | `[L9732]` | Active scan plan type. |
| `userLocation` | `''` → `'site'` | `[L11657]` | Set on entry; tasks-screen location dropdown. |
| `editingSiteId` | `null` | `[L7556]` | Site being edited. |
| `statusSiteId` | `null` | `[L7553]` | Site whose status sheet is open. |
| `editingCatIdx` | `null` | `[L7242]` | Budget category being edited. |

**Money formatter** `fMoney(n)` `[L20753]`: `'₪'+Math.round(n||0).toLocaleString()`. Aliases: `finMoney` `[L19484]`, `caMoney` `[L18442]` all delegate to `fMoney`. `caToday()` `[L18443]`: `new Date().toLocaleDateString('he-IL')`.

**Router `go(v)`** `[L6407]` — relevant tail `[L6429-6437]`:
```
if(v==='home') renderHomeProducts();
if(v==='project') renderSmartProject();
if(v==='sites') renderProjects();
// scan / stock / tasks are "coming soon" — static placeholders, no render
```
Note: `view-scan`, `view-stock`, `view-tasks` do **not** auto-render on navigation; they render on first interaction or were rendered at app init. `renderHomeProducts()` is also called once at boot `[L18381]`.

---

## 1. HOME — `view-home` `[L4416]`, `renderHomeProducts` `[L10633]`

### 1a. Static home layout `[L4416-4516]` (verbatim strings)
- **Search box** placeholder: `חפש כלי עבודה, חומר בניין, אביזר...` `[L4420]`.
- **Hero** `[L4427-4431]`: tag `id="homeGreet"` default text `⚡ אקספרס לאתר`; `<h2>הזמן עכשיו —<br>קבל לאתר עד שעתיים</h2>`; `<p>בלי לעצור את העבודה ובלי נסיעה לחנות. הכל מגיע אליך.</p>`.
  - Greeting is overwritten on login: `pickProfession` → `icon+' שלום, '+name` `[L11647]`; `loginExisting` → `👷 שלום, קבלן` `[L11827]`.
- **AI hub button** `[L4433-4440]`: `🤖` / `בינה מלאכותית ואוטומציה` / `חיזוי מלאי, סורק ברקוד, חלופות זולות ותובנות` → `openAIHub()` (out of scope — see AI hub doc).
- **Categories grid** `[L4443-4453]` — 8 tiles, all → `go('catalog')`: `🔧 כלי עבודה`, `🚿 אינסטלציה`, `⚡ חשמל`, `🧱 בנייה`, `🎨 גמר וצבע`, `🔩 חיבורים`, `🦺 בטיחות`, `➕ הכל`. Section title `קטגוריות`.
- **Smart install tree** section `[L4456-4462]`: title `עץ התקנה חכם — אינסטלציה` + `הצג הכל` (→ `openSmartCatalog()`); hint: `💡 נסה את זה: בחר ברז או כלי סניטרי. עץ ההתקנה יקפיץ אוטומטית את כל האביזרים שצריך להרכבה — צינורות, אטמים, סיליקון — שהצוות תמיד שוכח.`; then `<div class="prow" id="homeProductRow">` (filled by `renderHomeProducts`).
- **Smart-work-route hero** `[L4465-4476]`: section `מסלול עבודה חכם`; card → `go('project')`: tag `🛁 חדש — מאפס עד גמר`; `<h2>גמר אמבטיה — מלווה אותך שלב-שלב</h2>`; `<p>4 שלבים בסדר הנכון. כל שלב: עץ מוצרים + חלון "סדר הרכבה" שמראה מה לפני מה.</p>`; progress bar `width:38%` static; `פתח מסלול ›`.
- **Three "promise" cards** `[L4478-4509]`:
  - → `go('scan')`: `📐 סרוק תוכנית עבודה` / `צלם שרטוט אינסטלציה — נזהה מה צריך להזמין`.
  - → `go('stock')`: `📦 המלאי שלי` / `מה כבר יש לך — במחסן ובאתר`.
  - → `go('tasks')`: `📋 משימות העבודה` / `חלק משימות לעובדים ועקוב אחרי הביצוע`.
- **Reorder block** `[L4511-4514]`: section `הזמנה חוזרת לאתר זה` + `היסטוריה` (→ `go('orders')`); `<div id="reorderHistory">` filled by `renderReorderHistory()` `[L7017]`.

`renderReorderHistory()` `[L7017-7038]`: shows `DEMO_HISTORY` `[L7013]` only when `entryMode==='demo'`; else empty state text `עדיין אין הזמנות קודמות — לאחר ההזמנה הראשונה היא תופיע כאן.`. `DEMO_HISTORY` = 2 items: `{name:'מקדחה רוטטת בוש GBH',price:640,icon:'🔩',cat:'כלי עבודה',ago:'הוזמן לפני 9 ימים'}`, `{name:'שק מלט אפור 25 ק"ג',price:31,icon:'🪨',cat:'בנייה',ago:'הוזמן לפני 6 ימים'}`. Tapping a row calls `addSingle(name,price,icon)` `[L10605]`.

> **Note:** `SAFETY_TIPS` is **NOT** used on home. It lives at `[L19833]` and is consumed only by `siteSafety()` (§7.6). Documented in §7.6.

### 1b. `renderHomeProducts()` `[L10633-10684]`
Renders one `.pcard` per key in `HOME_PRODUCTS` (`faucet`, `toilet`, `shower`) by reading `TREES[key]` `[L5525/5567/5596]`. For each card:
- Category button (top): `🔧 אינסטלציה` → `openSmartCatalog()`.
- Thumb: `t.img` (faucet `🚰`, toilet `🚽`, shower `🚿`).
- Name line: `t.name` (`ברז לכיור`, `אסלה תלויה`, `סוללת מקלחת`) + a check button `.prod-check` (filled `on` if `productInCart(key)` `[L10544]`) → `toggleProductInCart(key, catQty(key))` `[L10540ish]`; title `הוסף לסל`.
- Price line: `₪{price} <small>/ יח'</small>` where `price=productPrice(key)` (default brand prices: faucet 189, toilet 740, shower 520 — the `rec:true` brand `[L5527/5569/5598]`).
- Quantity wheel `.qty-wheel`: `−` (`stepCatQty(key,-1)`), value `catQty(key)` (`openCatQtyInput(key)`), `+` (`stepCatQty(key,1)`).
- If `isRich(key)` `[L6388]` (has `brands` or `catalogProduct` — all three are rich): a tree button `🌳 עץ מוצרים · {accN} אביזרים` → `openTree(key)`. accN = `t.acc.length` → faucet **7**, toilet **6**, shower **6**.

`toggleProductDetail(key)` `[L10629]` toggles `expandedProduct` then re-renders. When expanded, a `.pcard-detail` panel is built **inside the map** (note: in current markup the detail is computed but the returned card template does not splice `detail` in — the rich panel text is: `למוצר הזה יש עץ מוצרים חכם` + `כל {accN} האביזרים שצריך להרכבה במקום אחד — כדי שלא תשכח כלום.` + button `🌳 פתח את העץ החכם`; non-rich fallback: `פרטי המוצר` + `{name} · ₪{price}`). For the port, treat the expand panel as optional/cosmetic.

`renderHomeProducts` is re-invoked from many cart mutations to keep the check state fresh: `toggleProductInCart` `[L10570/10587]`, `refreshProductCartItem` `[L10602]`, `pickBrand` `[L10720]`.

**HOME_PRODUCTS source trees (full data for the 3 cards):**

| key | name | img | cat | brands (brand/price/tag/rec) | acc count | accessories (name·img·price·why·must) |
|---|---|---|---|---|---|---|
| `faucet` `[L5525]` | ברז לכיור | 🚰 | ברזים וכיורים | מותג סטנדרט/189/הבחירה שלנו/rec; מותג כלכלי/139/הכי משתלם; מותג פרימיום/329/איכות גבוהה | 7 | צינורות חיבור גמישים·🌀·28·"מחבר את הברז למים"·must; ברזי ניל זוויתיים·🔧·22·"לסגור מים בעת תיקון"·must; סרט טפלון·🎗️·4·"אוטם את ההברגה"·must; אטם גומי לברז·⚫·3·"מונע נזילה בחיבור"·must; סיליקון סניטרי·🧴·21·"אם הברז יושב על המשטח"; מפתח צינורות·🔩·39·"רק אם אין לך בערכה"; פקק ניקוז עם שרשרת·⚪·18·"אם הכיור בלי פקק מובנה" |
| `toilet` `[L5567]` | אסלה תלויה | 🚽 | אסלות | מותג סטנדרט/740/הבחירה שלנו/rec; מותג כלכלי/560/הכי משתלם; מותג פרימיום — Soft Close/1240/איכות גבוהה | 6 | מיכל הדחה סמוי·⬜·430·"הבסיס למערכת — חובה"·must; אטם לאסלה·⚫·18·"מונע ריחות ונזילות"·must; ברגי קיבוע·🔩·9·"מחזיק את האסלה"·must; לחצן הדחה·⏹️·65·"הכפתור של ההדחה"·must; מושב אסלה·⭕·89·"אם לא מגיע עם האסלה"; סיליקון סניטרי·🧴·21·"איטום בסיס האסלה לרצפה" |
| `shower` `[L5596]` | סוללת מקלחת | 🚿 | מקלחות ואמבטיות | מותג סטנדרט/520/הבחירה שלנו/rec; מותג כלכלי/380/הכי משתלם; מותג פרימיום — תרמוסטטי/890/איכות גבוהה | 6 | גוף סמוי לסוללה·⬛·240·"נכנס לקיר — חובה"·must; ראש מקלחת + זרוע·🌧️·155·"החלק שרואים"·must; סרט טפלון·🎗️·4·"אוטם את ההברגות"·must; צינור גמיש + מתקן·🌀·32·"אם רוצים גם ראש נייד"; מדף פינתי למקלחת·📐·48·"נחמד אבל לא חובה"; סיליקון סניטרי·🧴·21·"איטום מול הקרמיקה" |

(The full TREES + variants + brand/variant pickers are documented in the catalog port doc; here we capture only what the 3 home cards need.)

---

## 2. PROJECTS / SITES

### 2a. Data — `PROJECTS` `[L6447-6451]`
```
{id:'PRJ-1',name:'מגדל הרצליה — קומה 4', addr:"רח' הנדיב 12, הרצליה",  manager:'יוסי כהן',  cart:[],treeProgress:{}}
{id:'PRJ-2',name:'וילה כפר שמריהו',      addr:"רח' האלון 4, כפר שמריהו",manager:'אבי מזרחי', cart:[],treeProgress:{}}
{id:'PRJ-3',name:'שיפוץ משרדים — רעננה',  addr:'אחוזה 88, רעננה',        manager:'דנה לוי',   cart:[],treeProgress:{}}
```
`applyEntryMode('new')` `[L6998]` replaces this with a single empty site `{id:'PRJ-1',name:'',addr:'',manager:'',cart:[],treeProgress:{}}`. `'demo'`/`'existing'` keep the seed.

### 2b. `SIM_SITES` `[L17160]` (supplier-side simulation only)
`['מגדל יוקרה — רמת גן','וילה פרטית — כפר שמריהו','בניין מגורים — פתח תקווה','שיפוץ דירה — תל אביב','פרויקט מסחרי — ראשל״צ']`. Used by `simulateIncomingOrder()` `[L17161]` to stamp a random `site` on a simulated supplier order — **not** part of the contractor's own sites. Companion `SIM_CUSTOMERS` `[L17159]`: `['אלי בניין בע״מ','קבלן דוד שמש','י. לוי שיפוצים','מ.כ. הנדסה','אחים ברק בנייה']`.

### 2c. `ARCHIVED_PROJECTS` `[L19849-19853]` (used by Site Hub §7.10)
```
{name:'מגדל הרצליה — שלב א׳',year:'2024',units:24,status:'הושלם'}
{name:'בית פרטי רעננה',     year:'2023',units:1, status:'הושלם'}
{name:'שיפוץ משרדים תל-אביב',year:'2023',units:6, status:'הושלם'}
```

### 2d. `SITE_TREE` `[L19841-19848]` (floor→apartment→room, used by Site Hub §7.3)
```
{floor:'קומה 1',apts:[{n:'דירה 1',rooms:['סלון','מטבח','חדר רחצה']},
                      {n:'דירה 2',rooms:['סלון','חדר שינה','שירותים']}]}
{floor:'קומה 2',apts:[{n:'דירה 3',rooms:['סלון','מטבח','חדר רחצה','מרפסת']},
                      {n:'דירה 4',rooms:['סלון','חדר שינה','חדר ילדים']}]}
{floor:'קומה 3',apts:[{n:'דירה 5',rooms:['סלון','מטבח','חדר רחצה']},
                      {n:'דירה 6',rooms:['סלון','חדר שינה','שירותים','מרפסת']}]}
```

### 2e. `view-sites` `[L5126-5164]` (verbatim)
- View-switch tabs: `🌳 הפרויקט שלי` (→ `go('project')`) | `🏗️ האתרים שלי` (on, → `go('sites')`).
- Section `סקירת תקציב`, then a synced **budget box** `id="sitesBudgetBox"` (the `sb*` ids — see §3) → `openBudgetDetail()`; foot hint `הקש לפרטים וניתוח · מסונכרן עם הפרויקט ›`; edit button `✏️ עריכה` (`event.stopPropagation();openBudgetEditor()`).
- Section `האתרים שלי`; add button `＋ הוסף פרויקט / אתר חדש` → `openProjectModal()`; `<div id="projectList">`.

### 2f. `renderProjects()` `[L7455-7480]`
For each `p` in `PROJECTS`, a `.site-card` (class `current` if `p.id===activeProjectId`):
- `.sc-top` → `openSiteStatus(p.id)`: `p.name`, `p.addr`, and a badge button: if active `פעיל עכשיו` (class `live`) else `החלף ›` (class `soon`) → `event.stopPropagation();switchProject(p.id)`.
- `.sc-pm` → `openSiteStatus(p.id)`: `👷 מנהל עבודה: {p.manager||'—'}`.
- `.sc-links`: `🛒 {cartCount} פריטים בעגלה ›` → `openSiteCart(p.id)`; `🌳 {treeCount} עצי מוצרים ›` → `openSiteProject(p.id)`. (`cartCount=p.cart.length`, `treeCount=Object.keys(p.treeProgress).length`.)
- `.sc-edit-hint` → `openSiteStatus(p.id)`: `📊 הקש לסטטוס האתר המלא`.
- Then `renderBudget()` (keeps the sites-screen budget box in sync).

### 2g. Navigation helpers
- `openSiteCart(id)` `[L7482]`: if not active, `switchProjectSilent(id)`, then `go('cart')`.
- `openSiteProject(id)` `[L7486]`: if not active, `switchProjectSilent(id)`, then `go('project')`.
- `switchProjectSilent(id)` `[L7491]`: saves outgoing cart, sets `activeProjectId`, loads incoming cart, `updateCartCount()`, `refreshSiteLabel()` — **without** navigating.
- `switchProject(id)` `[L7584]`: if id is already active → `go('home')` and return; else save outgoing cart, switch, load incoming cart, set app-bar site label to `incoming.name+' ›'`, `renderProjects()`, toast `עברת לפרויקט: {incoming.name}`, `go('home')`.

### 2h. `openSiteStatus(id)` `[L7502-7549]` — full status sheet (overlay `siteStatusOverlay`)
Computes: `isActive`, `cartCount`, `treeCount`, total work-days across `TASKS` (`totalDays=Σ max(1,t.days)`), `doneDays=count(smartDayDone truthy keys)`, `projPct=round(doneDays/totalDays*100)`, budget `bTotal/bSpent/bPct`. Title `ssTitle`=`p.name`. HTML blocks:
- **State** `.ss-state` → `closeSiteStatus();switchProject(id)`: active → `🟢 אתר פעיל עכשיו` (class `on`); inactive → `⚪ לא פעיל — הקש כדי להפעיל` (class `off`).
- **Details card** `.ss-card` → `closeSiteStatus();openSiteEditor(id)`: rows `📍 כתובת` / `p.addr||'—'`; `👷 מנהל עבודה` / `p.manager||'—'`; edit hint `✏️ הקש לעריכת הפרטים`.
- **Progress tile** `.ss-tile` → `openSiteProject(id)`: top `🌳 התקדמות הפרויקט` + `{projPct}%`; bar width=`projPct%`; sub `{doneDays} מתוך {totalDays} ימי עבודה בוצעו · הקש לפרויקט ›`.
- **Budget tile** `.ss-tile` → `openBudgetDetail()`: top `💰 תקציב` + `{bPct}%`; bar width=`min(100,bPct)%`; sub `{fmt(bSpent)} מתוך {fmt(bTotal)} · הקש לפרטים ›`.
- **Quick links** `.ss-links`: `🛒 {cartCount} פריטים בעגלה ›` → `openSiteCart(id)`; `🌳 {treeCount} עצי מוצרים בעבודה ›` → `openSiteProject(id)`.
- Footer button `✏️ עריכת פרטי האתר` → `closeSiteStatus();openSiteEditor(id)`.
- `closeSiteStatus()` `[L7550]`.
- `fmt(n)` here = `'₪'+Math.round(n).toLocaleString()`.

### 2i. `openSiteEditor(id)` `[L7557]` / `saveSiteEdit()` `[L7569]` — overlay `siteEditOverlay` `[L4707]`
Sheet head: `<h3>עריכת פרטי האתר</h3>` / `<p>עדכן את שם האתר, הכתובת ומנהל העבודה.</p>`. Inputs prefilled from `p`: `seNameInput`, `seAddrInput`, `seManagerInput`. `saveSiteEdit`: trims name → if empty toast `יש להזין שם אתר`; sets `p.name/addr/manager`; `closeSiteEditor()`; `renderProjects()`; `refreshSiteLabel()`; `renderSmartProject()` (project title follows); toast `פרטי האתר עודכנו`.

### 2j. `openProjectModal()` `[L7603]` / `saveProject()` `[L7612]` — overlay `projectModal`
Inputs cleared: `pmProjName`, `pmProjAddr`, `pmProjMgr`. `saveProject`: trim name → empty toast `יש להזין שם פרויקט`; push `{id:'PRJ-'+(projSeq++),name,addr:addr||'—',manager:mgr||'—',cart:[],treeProgress:{}}`; `closeProjectModal()`; `renderProjects()`; toast `הפרויקט "{name}" נוסף`. Backdrop click closes `[L7623]`.

### 2k. Site picker (delivery destination) — `openSitePicker()` `[L7041]` / `saveSiteName()` `[L7083]` — overlay `sitePickerOverlay`
Depends on `entryMode`:
- `existing`: title `האתרים שלך`, sub `בחר לאן לשלוח, או הוסף אתר חדש`; lists each project as `.site-opt` (`on` if active) → `chooseSite(p.id)`; label `🏗️ {p.name||'אתר ללא שם'}`, tick `✓` if active.
- else (new/demo): title `שם אתר המשלוח`, sub `לאן לשלוח את החומרים?`.
- Both modes append an add/rename row: input placeholder `שם האתר (לדוגמה: מגדל ויטה — תל אביב)` + button `שמור אתר` → `saveSiteName()`. Input prefilled with current site name.
- `chooseSite(id)` `[L7074]`: `switchProject(id)` if different, else set `activeProjectId`; `refreshSiteLabel()`; close.
- `saveSiteName()`: trim → empty toast `יש להזין שם אתר`; if `existing` and current already named differently → push NEW project `{id:'PRJ-'+(projSeq++),...}` and activate it; else rename current `p.name=name`; if `entryMode==='new'` flip to `'existing'`; `refreshSiteLabel()`; close; toast `אתר המשלוח עודכן: {name}`.

---

## 3. BUDGET / FINANCE (basic budget)

### 3a. Data
- `projectBudget` `[L7150]`: `{total:15000, spent:9840}` → left=5160, pct=`round(9840/15000*100)`=**66%**.
- `budgetCategories` `[L7152]`:
  | name | ic | amount |
  |---|---|---|
  | אינסטלציה | 🔧 | 3740 |
  | חשמל | ⚡ | 2660 |
  | גמר | 🎨 | 2070 |
  | אחר | 📦 | 1370 |
  (sum = 9840 = `spent`.)

### 3b. Budget box markup (two synced instances)
Project screen ids (`bg*`) `[L4580-4604]`; sites screen ids (`sb*`) `[L5133-5157]`. Each box: title `💰 תקציב הפרויקט`, pct, bar, three columns — `הוצאת עד כה` / `נשאר בתקציב` / `תקציב כולל` — foot hint + `✏️ עריכה` button. Tapping the box → `openBudgetDetail()`; edit button → `openBudgetEditor()` (with `event.stopPropagation()`).

### 3c. `renderBudget()` `[L7159-7178]`
Computes `left=total-spent`, `pct=round(spent/total*100)`. Writes to **both** id sets: `bgTotal/sbTotal`, `bgSpent/sbSpent`, `bgLeft/sbLeft` (all as `'₪'+x.toLocaleString()`), `bgPct/sbPct` (`pct%`). Bars `bgBar/sbBar` width = `min(100,pct)%`. `bgLeft/sbLeft` color: `var(--danger)` if `left<0` else `var(--ok)`.

### 3d. `openBudgetDetail()` `[L7190-7236]` — overlay `budgetDetailOverlay` (everything tappable)
Sheet head `[L4673-4682]`: `<h3>תקציב הפרויקט — פרטים וניתוח</h3>` / `<p>תמונת מצב מלאה. להזין נתונים אמיתיים — הקש "עריכה".</p>`. Body built into `budgetDetailBody`:
- `over = left<0`; `fmt(n)='₪'+Math.round(n).toLocaleString()`; `catTotal=Σ category.amount || 1`.
- **Headline** `.bd-headline` (class `over` if over) → `closeBudgetDetail();openBudgetEditor()`: big `{pct}%`; sub `{over?'חריגה מהתקציב':'מהתקציב נוצל'} · הקש לעריכה`.
- **Three numbers** `.bd-nums` (each → editor): `{fmt(total)}` / `תקציב כולל`; `{fmt(spent)}` / `הוצא`; `{fmt(left)}` (color danger/ok) / `נשאר`.
- If over: alert `⚠️ ההוצאות חרגו מהתקציב ב-{fmt(-left)}. כדאי לעדכן את התקציב או לבדוק הוצאות.`.
- **By category** header `פירוט הוצאות לפי קטגוריה` + add `＋ הוסף` → `addBudgetCategory()`. Each `.bd-cat` → `openCategoryEditor(i)`: `{c.ic} {c.name}`, a proportional bar (`width=round(amount/catTotal*100)%`), `{fmt(amount)} ›`.
- **By site** header `הוצאות לפי אתר`. Weighted distribution: with `n=PROJECTS.length`, site i weight `w=(n-i)/((n*(n+1))/2)` (decreasing triangular weights). Each `.bd-site` → `closeBudgetDetail();openSiteProject(p.id)`: `🏗️ {p.name}` and `{fmt(spent*w)} ›`.
- Demo note: `* הנתונים להמחשה — בגרסה המלאה יתבססו על ההזמנות וההוצאות בפועל של הלקוח.`.
- Footer button `✏️ עריכת התקציב` → `closeBudgetDetail();openBudgetEditor()`.
- `closeBudgetDetail()` `[L7237]`.

### 3e. `openBudgetEditor()` `[L7179]` / `saveBudget()` `[L7278]` / `adjustBudget(dir)` `[L7289]` — overlay `budgetEditOverlay` `[L4642]`
Head: `<h3>עריכת תקציב הפרויקט</h3>` / `<p>עדכן את התקציב הכולל, או הוסף / הורד עלות.</p>`. Fields: `תקציב כולל (₪)` (`beTotalInput`), `סך ההוצאות עד כה (₪)` (`beSpentInput`), button `שמור תקציב` → `saveBudget`. Divider `— או הוסף / הורד עלות —`. Cost field `סכום העלות (₪)` (`beCostInput`, placeholder `לדוגמה: 500`), two buttons: `➕ הוסף הוצאה` → `adjustBudget(1)`; `➖ הורד הוצאה` → `adjustBudget(-1)`.
- `saveBudget`: parse total/spent ints; invalid/negative → toast `יש להזין מספרים תקינים`; else set, `renderBudget()`, `closeBudgetEditor()`, toast `התקציב עודכן`.
- `adjustBudget(dir)`: parse amt; invalid/≤0 → toast `יש להזין סכום`; else `spent=max(0,spent+dir*amt)`, `renderBudget()`, close, toast `נוספה הוצאה: ₪{amt}` (dir>0) or `הוסרה הוצאה: ₪{amt}`.

### 3f. Category editor — `openCategoryEditor(i)` `[L7243]`, `addBudgetCategory()` `[L7253]`, `saveCategoryEdit()` `[L7260]`, `deleteCategory()` `[L7271]` — overlay `catEditOverlay` `[L4685]`
- Head title id `ceTitle`: `עריכת קטגוריה` (existing) or `קטגוריה חדשה` (new). Sub `עדכן את שם הקטגוריה והסכום שהוצא בה.`. Fields: `שם הקטגוריה` (`ceNameInput`), `סכום שהוצא (₪)` (`ceAmountInput`); button `שמור קטגוריה` → `saveCategoryEdit`; delete button `🗑️ מחק קטגוריה` (`ceDelete`, shown only if existing AND `length>1`) → `deleteCategory`.
- `addBudgetCategory`: pushes `{name:'',ic:'📦',amount:0}` then opens editor on it.
- `saveCategoryEdit`: trim name → empty toast `יש להזין שם קטגוריה`; amt NaN/<0 → toast `יש להזין סכום תקין`; set, close, `openBudgetDetail()`, toast `הקטגוריה נשמרה`.
- `deleteCategory`: if `length<=1` toast `חייבת להישאר קטגוריה אחת`; else splice, close, `openBudgetDetail()`, toast `הקטגוריה נמחקה`.

---

## 4. FINANCE HUB — `openFinanceHub()` `[L19487]` (10 features)

Entered from the project screen via `.fin-hub-btn` `[L4606-4613]`: `📊` / `מרכז פיננסים` / `מדד, תנאי תשלום, ROI, דוחות וקבלני משנה`. Overlay `financeHubOverlay`, body `financeHubBody`. Hub header: `📊` / `מרכז פיננסים` / `ניהול פיננסי מלא של הפרויקט — תקציב, תשלומים, אישורים ודוחות.`. Grid `.fin-grid` of 10 `.fin-tile` buttons (`{ic}`/`{t}`/`{s}` → `{fn}()`):

| # | fn | ic | t (title) | s (sub) | `[L#]` |
|---|---|---|---|---|---|
| 11 | `finIndex` | 📈 | הצמדה למדד | מדד תשומות הבנייה | `[L19520]` |
| 12 | `finPayTerms` | 🗓️ | תנאי תשלום | שוטף+30/60, אבני דרך | `[L19545]` |
| 13 | `finSubs` | 👷 | קבלני משנה | תקציב וחלוקה | `[L19569]` |
| 14 | `finApprovals` | ✅ | אישורי רכש | Approval workflow | `[L19594]` |
| 15 | `finThresholds` | 🔔 | התראות חריגה | 80% / 90% מהתקציב | `[L19633]` |
| 16 | `finROI` | 📊 | ניתוח ROI | תשואה על ההשקעה | `[L19657]` |
| 17 | `finInvoiceSplit` | 🧾 | פיצול חשבוניות | לפי סעיפי תקציב | `[L19678]` |
| 18 | `finPenalties` | ⏰ | פיצויים וקנסות | איחורים באספקה | `[L19698]` |
| 19 | `finReports` | 📄 | דוחות PDF | דוח רשמי להורדה | `[L19729]` |
| 20 | `finFX` | 💱 | רכש במט״ח | שערים בזמן אמת | `[L19773]` |

Each feature renders into `finFeatureBody` via `finFeature(html)` `[L19514]` (overlay `finFeatureOverlay`). Each starts with a `.md-head` (`{ic}`/title/sub).

**Supporting data:**
- `BUILD_INDEX` `[L19459]`: `{base:121.3, current:128.7, label:'מדד תשומות הבנייה'}`.
- `PAYMENT_TERMS` `[L19461]`: `[{id:'now',name:'מזומן / מיידי',days:0},{id:'net30',name:'שוטף + 30',days:30},{id:'net60',name:'שוטף + 60',days:60},{id:'milestone',name:'לפי אבני דרך',days:null}]`. `activePaymentTerm='net30'` `[L19467]`.
- `subcontractors` `[L19469]`: `[{id:'sub1',name:'אינסטלציה — דוד לוי',ic:'🔧',allocated:18000,spent:11200},{id:'sub2',name:'חשמל — מ. כהן בע״מ',ic:'⚡',allocated:14000,spent:9600},{id:'sub3',name:'גמר וצבע — שיא הצבע',ic:'🎨',allocated:9000,spent:3100}]`.
- `approvalQueue` `[L19475]`: `[{id:'AP-201',what:'הזמנת ברזל זיון',amount:8400,by:'מנהל עבודה',status:'ממתין'},{id:'AP-202',what:'40 שק דבק אריחים',amount:2600,by:'רכש',status:'ממתין'}]`.
- `penaltyLedger=[]` `[L19480]`.
- `FX_RATES` `[L19482]`: `{USD:3.72, EUR:4.05, GBP:4.71}`.

**11 · finIndex** `[L19520]`: head sub `{BUILD_INDEX.label} — עדכון אוטומטי של ערכי החוזה.`. delta=current−base=7.4; pct=`delta/base*100`≈6.10%; `linked=round(budget*(1+pct/100))`. Rows: `מדד בסיס (חתימת חוזה)`/121.3; `מדד נוכחי`/128.7; `שינוי`/`+{pct}%` (class `fin-up` if ≥0 else `fin-dn`). Callout: `תקציב מקורי`/`{finMoney(budget)}`; `תקציב צמוד-מדד`/`{finMoney(linked)}` (big); note `תוספת הצמדה: {finMoney(linked-budget)}`.

**12 · finPayTerms** `[L19545]`: head sub `בחר את תנאי התשלום של הפרויקט — משפיע על מועדי החיוב.`. For each term, `.fin-opt` (`on` if active) → `setPaymentTerm(id)`; title `{name}{ ✓ if active}`; sub due-text: `days===null`→`משולם בכל אבן דרך`; `days===0`→`תשלום מיידי`; else `התשלום מתבצע {days} יום מקבלת החשבונית`. `setPaymentTerm(id)` `[L19561]`: set, toast `תנאי התשלום עודכנו: {name}`, re-render.

**13 · finSubs** `[L19569]`: head sub `חלוקת תקציב הפרויקט בין קבלני המשנה ומעקב ניצול.`. Totals `totAlloc`/`totSpent`. Callout `סך הוקצה לקבלני משנה`/`{finMoney(totAlloc)}`; note `נוצל: {finMoney(totSpent)} ({round(totSpent/totAlloc*100)}%)`. Per sub `.fin-sub`: top `{ic} {name}` + `{pct}%` (`fin-dn` if over 100); bar width=`min(100,pct)%` (red if over); nums `נוצל {finMoney(spent)} מתוך {finMoney(allocated)}`.

**14 · finApprovals** `[L19594]`: head sub `בקשות רכש הממתינות לאישור מנהל לפני ביצוע ההזמנה.`. Empty (no items) → `אין בקשות לאישור`. Per item `.fin-appr`: `{id}` + status pill (`אושר` plain / `נדחה` danger / `ממתין`); `{what}`; `{finMoney(amount)} · מבקש: {by}`; if `ממתין` two buttons `אשר` → `decideApproval(id,1)`, `דחה` → `decideApproval(id,0)`. `decideApproval(id,ok)` `[L19617]`: RBAC gate `requirePerm('order.approve','אישור בקשת רכש')`; set status `אושר`/`נדחה`; `auditLog('החלטת רכש', id+': '+...)`; `pushNotification('בקשת רכש {id} אושרה/נדחתה', icon ✅/⛔, detail title `אישור רכש`, lines `[what, finMoney(amount), 'סטטוס: '+status]`); toast `בקשה {id} אושרה ✓` / `נדחתה`; re-render.

**15 · finThresholds** `[L19633]`: pct=`round(spent/total*100)`. Level: ≥90 `חריגה קריטית` (cls `x`); ≥80 `התראת חריגה` (cls `h`); else `תקין` (cls `ok`). Head sub `ניטור דינמי — התראה אוטומטית בהגעה ל-80% ול-90% מהתקציב.`. Gauge `.fin-gauge-{cls}`: `{pct}%` + level. Threshold list (each hit if pct≥threshold, mark `⚠️` else `○`): `80% — התראת חריגה ראשונית`; `90% — חריגה קריטית — נדרש אישור`; `100% — חריגה מלאה מהתקציב`.

**16 · finROI** `[L19657]`: `invested=spent`; `projectValue=round(total*1.42)`; `profit=projectValue-total`; `roi=profit/total*100`. Head sub `תשואה צפויה על ההשקעה בפרויקט.`. Rows: `תקציב הפרויקט`/`{finMoney(total)}`; `הושקע עד כה`/`{finMoney(invested)}`; `שווי חוזה צפוי`/`{finMoney(projectValue)}`; `רווח גולמי צפוי`/`{finMoney(profit)}` (fin-up). Callout `ROI צפוי`/`{roi}%` (big fin-up); note `תשואה על כל שקל שהושקע בפרויקט`.

**17 · finInvoiceSplit** `[L19678]`: `totalInv=12800`; `catTotal=Σ amount`. Head sub `פיצול חשבונית בסך {finMoney(12800)} לסעיפי התקציב.`. Per category a row `{ic} {name}` / `{finMoney(round(totalInv*amount/catTotal))}`. Callout `סך החשבונית`/`{finMoney(12800)}`; note `פוצלה ל-{count} סעיפי תקציב לפי משקל`.

**18 · finPenalties** `[L19698]`: head sub `ניהול קנסות על איחור באספקה — פיצוי מוסכם לפי יום.`. Button `+ רישום קנס איחור` → `addPenalty()`. Empty → `לא נרשמו קנסות`. With items: callout `סך קנסות שנצברו`/`{finMoney(tot)}` (fin-dn). Per `.ca-card`: `{p.id}` + pill `{finMoney(amount)}` (danger); sub `{days} ימי איחור · {finMoney(perDay)} ליום · 📅 {createdAt}`. `addPenalty()` `[L19717]`: `prompt('כמה ימי איחור?','2')`; `perDay=500`; unshift `{id:'PEN-'+(300+len+1),days,perDay,amount:days*perDay,createdAt:caToday()}`; toast `קנס איחור נרשם: {finMoney(days*500)}`.

**19 · finReports** `[L19729]`: head sub `הפקת דוח פיננסי רשמי של הפרויקט להורדה והדפסה.`. Rows: `תקציב הפרויקט`/total; `הוצאות בפועל`/spent; `יתרה`/(total−spent). Button `⬇️ הפק והורד דוח PDF` → `downloadFinReport()` `[L19741]` (opens a print window with an RTL HTML report titled `דוח פיננסי — BuildSmart`, headings `BuildSmart — דוח פיננסי לפרויקט`, `תאריך הפקה: {caToday()}`, sections `תמצית תקציב` (`תקציב כולל`/`הוצאות בפועל`/`יתרה`) and `פירוט לפי סעיפים`, footer `הופק על ידי מערכת BuildSmart · {caToday()}`; auto-print after 350 ms; toast `הדוח הופק — בחר "שמור כ-PDF" בחלון ההדפסה`; popup-blocked toast `יש לאפשר חלונות קופצים להפקת הדוח`).

**20 · finFX** `[L19773]`: head sub `שערי חליפין לרכש מספקים בחו״ל.`. Server note `⚙️ שערי המט״ח מתעדכנים מהשרת — כאן מוצגים שערי דמו`. Rows per currency `1 {cur}` / `₪{rate.toFixed(2)}`. Calculator: label `המרת סכום`; number input `fxAmount` placeholder `סכום` value `1000` (`oninput=updateFXCalc()`); select `fxCur` (`onchange=updateFXCalc()`): `דולר אמריקאי (USD)` / `אירו (EUR)` / `לירה שטרלינג (GBP)`; result `fxResult`. `updateFXCalc()` `[L19797]`: `{amt} {cur} = ₪{round(amt*rate)}`.

---

## 5. SITE HUB — `openSiteHub()` `[L19856]` (10 features)

Entered from the Tasks screen via `.fin-hub-btn` `[L5213-5221]`: `🏗️` / `ניהול אתר הבנייה` / `גאנט, ליקויים, נוכחות, יומן עבודה ובטיחות`. Overlay `siteHubOverlay`, body `siteHubBody`. Hub header: `🏗️` / `ניהול אתר הבנייה` / `כל כלי הניהול של אתר הבנייה במקום אחד.`. Grid of 10 `.fin-tile`:

| # | fn | ic | t | s | `[L#]` |
|---|---|---|---|---|---|
| 21 | `siteGantt` | 📅 | תרשים גאנט | לוח זמנים אינטראקטיבי | `[L19889]` |
| 22 | `siteSnagging` | 🔧 | רשימת ליקויים | Snagging list | `[L19913]` |
| 23 | `siteLocations` | 🏢 | קומה · דירה · חדר | שיוך משימות למיקום | `[L19952]` |
| 24 | `siteAttendance` | 📍 | נוכחות GPS | שעון נוכחות | `[L19972]` |
| 25 | `siteDiary` | 📓 | יומן עבודה | יומן יומי דיגיטלי | `[L20012]` |
| 26 | `siteSafety` | 🦺 | התראות בטיחות | תדריך בטיחות יומי | `[L20041]` |
| 27 | `siteDeps` | 🔗 | תלויות חומרים | בין משימות | `[L20066]` |
| 28 | `sitePhotos` | 📸 | צילום לפני/אחרי | תיעוד התקדמות | `[L20087]` |
| 29 | `siteInspect` | 🔍 | ביקורות מפקח | תזכורות ביקורת | `[L20111]` |
| 30 | `siteArchive` | 🗄️ | ארכיון פרויקטים | פרויקטים שהושלמו | `[L20143]` |

Each renders into `siteFeatureBody` via `siteFeature(html)` `[L19883]` (overlay `siteFeatureOverlay`).

**Supporting data:**
- `GANTT_TASKS` `[L19815]`: `{name:'יסודות וחפירה',start:0,len:5,done:100}; {name:'שלד וקירות',start:4,len:8,done:100}; {name:'אינסטלציה גסה',start:10,len:6,done:70}; {name:'חשמל גס',start:11,len:5,done:55}; {name:'טיח וריצוף',start:15,len:7,done:20}; {name:'גמר וצבע',start:21,len:6,done:0}`.
- `snagList` `[L19823]` (mutable): `{id:'SNG-01',what:'סדק בקיר חדר שינה',loc:'קומה 3 · דירה 7',severity:'בינוני',status:'פתוח'}; {id:'SNG-02',what:'נזילה מתחת לכיור',loc:'קומה 2 · דירה 4',severity:'חמור',status:'פתוח'}`.
- `attendanceLog=[]` `[L19827]`; `workDiary=[]` `[L19828]`.
- `inspections` `[L19829]`: `{id:'INS-1',what:'ביקורת מהנדס — שלד',due:'בעוד 3 ימים',status:'מתוכננת'}; {id:'INS-2',what:'ביקורת כיבוי אש',due:'בעוד 8 ימים',status:'מתוכננת'}`.
- `SAFETY_TIPS` `[L19833]`: `['🦺 לוודא קסדות ואפודים זוהרים לכל הנוכחים באתר.','⚡ לנתק מתח לפני עבודה על מערכות חשמל.','🪜 לבדוק יציבות פיגומים וסולמות לפני טיפוס.','🧯 לוודא שעמדות כיבוי אש פנויות וזמינות.','🕳️ לסמן ולגדר פתחים ובורות פתוחים.']`.
- `SITE_TREE` `[L19841]` (see §2d); `ARCHIVED_PROJECTS` `[L19849]` (see §2c).

**21 · siteGantt** `[L19889]`: `span=max(start+len)`=27. Head sub `לוח הזמנים של הפרויקט — {span} שבועות.`. Per task a `.sc-gantt-row`: name; track with a bar positioned `right:{start/span*100}%; width:{len/span*100}%`, inner fill width=`done%`, label `{done}%`. (RTL: bar uses `right`, fill uses left-anchored width.)

**22 · siteSnagging** `[L19913]`: head sub `תיעוד ומעקב אחר ליקויים ותקלות באתר.`. Button `+ דווח ליקוי חדש` → `addSnag()`. Empty → `אין ליקויים פתוחים ✓`. Per snag `.ca-card` (class `overdue` unless `status==='טופל'`): `{id}` + severity pill (risk cls: חמור→`x`, בינוני→`h`, else `m`); `{what}`; `📍 {loc} · {status}`; if fixed `✓ הליקוי טופל`, else button `סמן כטופל` → `fixSnag(id)`. `addSnag()` `[L19937]`: `prompt('תאר את הליקוי:','סדק בקיר')`; unshift `{id:'SNG-'+String(len+1).padStart(2,'0'),what:what||'ליקוי',loc:'האתר הנוכחי',severity:'בינוני',status:'פתוח'}`; toast `ליקוי דווח ✓`. `fixSnag(id)` `[L19945]`: set `status='טופל'`; toast `הליקוי {id} סומן כטופל ✓`.

**23 · siteLocations** `[L19952]`: head sub `מבנה האתר ההיררכי — לשיוך משימות למיקום מדויק.`. Per floor `.sc-floor`: `🏢 {floor}`; per apt `.sc-apt`: `🚪 {n}`; per room a `.sc-room` chip `{r}`.

**24 · siteAttendance** `[L19972]`: head sub `החתמת כניסה ויציאה עם אימות מיקום באתר.`. `open=attendanceLog.find(!out)`. If open: status `🟢 נוכח באתר מ-{open.in}` + button `החתם יציאה` → `clockAttendance(0)`; else status `⚪ לא מחותם כרגע` + button `החתם כניסה 📍` → `clockAttendance(1)`. If history exists: sub-title `היסטוריית נוכחות`; per `.ca-card`: `📅 {date}` + pill (`הושלם`/`פתוח`); sub `כניסה {in}{ · יציאה {out}} · 📍 {geo}`. `clockAttendance(isIn)` `[L19998]`: `now` via `toLocaleTimeString('he-IL',{hour:'2-digit',minute:'2-digit'})`; in → unshift `{date:caToday(),in:now,out:null,geo:'32.07°N, 34.79°E (±12מ׳)'}`, toast `כניסה נרשמה ב-{now} 📍`; out → set `open.out=now`, toast `יציאה נרשמה ב-{now}`.

**25 · siteDiary** `[L20012]`: head sub `תיעוד יומי של ההתקדמות, כוח האדם והאירועים באתר.`. Button `+ רישום יומן להיום` → `addDiaryEntry()`. Empty → `אין רישומים ביומן`. Per `.ca-card`: `📅 {date}` + pill `{workers} עובדים`; `{text}`; `מזג אוויר: {weather}`. `addDiaryEntry()` `[L20029]`: `prompt('מה בוצע היום באתר?','יציקת רצפת קומה 3')`; weather random from `['בהיר ☀️','מעונן ⛅','גשום 🌧️']`; unshift `{date:caToday(),text:text||'עבודה באתר',workers:3+rand(0..5),weather}`; toast `רישום נוסף ליומן ✓`.

**26 · siteSafety** `[L20041]`: `tip=SAFETY_TIPS[new Date().getDate()%5]` (rotates daily). Head sub `תדריך בטיחות יומי — חובה לפני תחילת העבודה.`. Today box: label `תדריך היום` + `{tip}`. Sub-title `כללי בטיחות כלליים`; then all 5 `SAFETY_TIPS` as `.sc-safety-row`. Button `✓ קראתי ואישרתי את התדריך` → `ackSafety()` `[L20056]`: `pushNotification('תדריך הבטיחות אושר', icon 🦺, detail title `תדריך בטיחות`, lines `['התדריך היומי אושר.','תאריך: '+caToday()]`); toast `תדריך הבטיחות אושר ✓`; closes `siteFeatureOverlay`.

**27 · siteDeps** `[L20066]`: head sub `משימה לא יכולה להתחיל לפני שהמשימות התלויות הושלמו.`. Inline `deps` array `[L20067]`: `{task:'טיח וריצוף',needs:'אינסטלציה גסה + חשמל גס',ready:true}; {task:'גמר וצבע',needs:'טיח וריצוף הושלם',ready:false}; {task:'התקנת כלים סניטריים',needs:'ריצוף + חיבורי מים',ready:false}; {task:'הרכבת מטבח',needs:'נקודות מים וחשמל מוכנות',ready:true}`. Per `.sc-dep` (class `ready` if ready): task `{ready?'🟢 ':'🔒 '}{task}`; `דורש: {needs}`; status `{ready?'מוכן להתחלה':'ממתין לתלויות'}`.

**28 · sitePhotos** `[L20087]`: head sub `תיעוד ויזואלי של ההתקדמות — השוואת מצב לפני ואחרי.`. Inline `pairs` `[L20091]`: `{area:'חדר רחצה — קומה 2',before:'🛠️',after:'✨'}; {area:'מטבח — דירה 4',before:'🧱',after:'🍳'}; {area:'סלון — קומה 3',before:'🪵',after:'🛋️'}`. Per pair `.sc-photo-pair`: area; row with `{before}`+label `לפני`, arrow `←`, `{after}`+label `אחרי`. Button `📷 הוסף צילום חדש` → inline toast `מצלמה — דורשת הרשאת מצלמה במכשיר`.

**29 · siteInspect** `[L20111]`: head sub `תזכורות לביקורות מפקח ורשויות.`. Button `+ תזמן ביקורת` → `addInspection()`. Per inspection `.ca-card`: `{id}` + pill `{status}` (class `done` if `בוצעה`); `{what}`; `🗓️ {due}`; if done `✓ הביקורת בוצעה`, else button `סמן כבוצעה` → `completeInspection(id)`. `addInspection()` `[L20128]`: `prompt('סוג הביקורת:','ביקורת מהנדס')`; unshift `{id:'INS-'+(len+1),what:what||'ביקורת',due:'בעוד שבוע',status:'מתוכננת'}`; toast `ביקורת תוזמנה ✓`. `completeInspection(id)` `[L20136]`: set `status='בוצעה'`; toast `הביקורת {id} סומנה כבוצעה ✓`.

**30 · siteArchive** `[L20143]`: head sub `פרויקטים שהושלמו — לעיון והפקת לקחים.`. Per archived `.ca-card`: `{name}` + pill `{status}` (done); `📅 {year} · {units} יח״ד`.

---

## 6. TASKS — `view-tasks` `[L5193]`, `renderTasks` `[L8075]`, status machine, dual roles

### 6a. `TASKS` `[L8023-8034]` — full structure
Fields: `id` (1–5), `name`, `detail`, `worker` (index into WORKERS), `status`, `photo` (`null`|`'demo'`), `note`, `days`, `steps` (string[]).

| id | name | worker | status | photo | note | days | steps |
|---|---|---|---|---|---|---|---|
| 1 | התקנת קו מים חם — חדר רחצה | 0 | active | null | '' | 2 | סימון מסלול הצנרת על הקיר · השחלת צינור PEX מהדוד · חיבור לנקודות הקצה · בדיקת אטימה בלחץ מים |
| 2 | הרכבת מיכל הדחה סמוי | 0 | pending | null | '' | 1 | סימון גובה המיכל · קיבוע המסגרת לקיר · חיבור לקו המים · בדיקת מפלס ויישור |
| 3 | איטום רצפת מקלחת | 1 | review | demo | בוצע — שכבה שנייה תתייבש מחר | 3 | ניקוי והכנת הרצפה · מריחת פריימר · חיזוק פינות בסרט איטום · מריחת שכבת איטום ראשונה · מריחת שכבה שנייה · בדיקת הצפה |
| 4 | התקנת נקזון רצפה | 1 | done | demo | הושלם ונבדק | 1 | סימון מיקום הנקז לפי השיפוע · חיבור לקו ניקוז 50 מ"מ · קיבוע ואיטום הנקז |
| 5 | חיבור ברז כיור + ברזי ניל | 0 | pending | null | '' | 2 | התקנת ברזי ניל זוויתיים · הרכבת הברז על הכיור · חיבור צינורות גמישים · בדיקת זרימה ואטימה |

Full details (verbatim): id1 detail `חיבור צנרת PEX מהדוד לנקודות. לוודא אטימה בכל חיבור.`; id2 `התקנת המיכל בקיר לפי הסימון. בדיקת מפלס.`; id3 `מריחת 2 שכבות איטום + חיזוק פינות.`; id4 `מיקום הנקז לפי השיפוע. חיבור לקו ניקוז 50 מ"מ.`; id5 `התקנת הברז וחיבור צינורות גמישים דרך ברזי ניל.`.

### 6b. Status machine — `taskStatusInfo(s)` `[L8048]`
| status | label | cls | ic |
|---|---|---|---|
| pending | ממתינה | pend | ⏳ |
| active | בביצוע | act | 🔨 |
| review | ממתין לאישור | rev | 📸 |
| done | אושר ✓ | done | ✅ |
| rejected | נדחה — לתקן | rej | ↩️ |

**Transitions:**
- Worker submits (`taskActionClick` `[L8138]`): from `active`/`rejected` → set `note` from textarea, `photo='demo'` if none, `status='review'`; **auto-advance** the worker's next `pending` task to `active`; toast `נשלח לאישור המנהל ✓`.
- Manager approve (`taskApprove` `[L8152]`): `status='done'`; toast `המשימה אושרה ✓`.
- Manager reject (`taskReject` `[L8153]`): `status='rejected'`, `photo=null`; toast `המשימה הוחזרה לעובד לתיקון`.
- Upload photo (`taskUpload` `[L8151]`): `photo='demo'`, re-open sheet; toast `תמונה צורפה (הדגמה)`.

### 6c. `view-tasks` static layout `[L5193-5225]`
- Back-head → `go('home')`, title `משימות העבודה`.
- Section `📋 משימות העבודה`.
- **Location dropdown** `.task-loc`: label `📍 מיקום נוכחי`; select `taskLocation` (`onchange=setTaskLocation(this.value)`): options `🏗️ באתר` (value `site`) / `🏬 במחסן` (value `warehouse`).
- **Role switch** `.role-switch`: `👔 מנהל` (on, `data-role=manager`, `pickRole('manager')`) / `👷 עובד` (`data-role=worker`, `pickRole('worker')`).
- Site-hub button (see §5).
- `<div id="tasksBody">` (filled by `renderTasks`).

`setTaskLocation(loc)` `[L8042]`: set `userLocation`; label `במחסן 🏬` (warehouse) / `באתר 🏗️`; toast `המיקום עודכן: {label}`. `pickRole(role)` `[L8035]`: set `taskRole`, toggle `.role-btn.on`, `renderTasks()`. `pickWorker(i)` `[L8047]`: set `activeWorker`, `renderTasks()`.

### 6d. `renderTasks()` `[L8075-8105]` — two role views
`taskCard(t)` `[L8057]`: `.task-card` → `openTask(t.id)`; icon `.tc-ic {cls}` `{ic}`; name `{t.name}`; optional detail; meta `👷 {WORKERS[worker]}` + (if steps) `· 📋 {n} שלבים` + (if days) `· ⏱️ {days} ימים`; pill `.task-pill {cls}` `{label}`.

**Manager view** (`taskRole==='manager'`):
- Intro: `אתה רואה את כל משימות הצוות. אשר עבודות שהוגשו ועקוב אחרי ההתקדמות.`.
- Button `📅 יומן עבודה — מה בוצע בכל יום` → `openTaskLog()`.
- Groups (only if non-empty), each a header then cards:
  - review → `📸 ממתין לאישור שלך ({n})`.
  - active+rejected → `🔨 בביצוע עכשיו ({n})`.
  - pending → `⏳ ממתינות בתור ({n})`.
  - done → `✅ הושלמו ואושרו ({n})`.

**Worker view** (else):
- Intro: `בחר עובד כדי לראות את המשימות שלו (בהדגמה — באפליקציה אמיתית כל עובד מחובר לחשבון שלו).`.
- Worker picker `.worker-pick`: a `.wp-btn` per worker (`on` if `activeWorker`), `pickWorker(i)`.
- `mine=TASKS.filter(worker===activeWorker)`; `current=first active/rejected`; `queue=pending`; `submitted=review/done`.
- If current: `🔨 המשימה הנוכחית שלך` + card; else `🎉 אין משימה פעילה כרגע`.
- If queue: `⏳ הבאות בתור ({n})` + cards.
- If submitted: `📋 שהגשת ({n})` + cards.

### 6e. `openTask(id)` `[L8106-8133]` — overlay `taskSheet` `[L5230]`
Sheet head ids: `taskName` (=t.name), `taskFor` (=`👷 {WORKERS[worker]}`). Body:
- Status chip `.td-status {cls}`: `{ic} {label}`.
- Section `תיאור המשימה` / `{detail}`.
- If photo: section `תמונת ביצוע` / `📷 תמונה מהשטח — {WORKERS[worker]}`.
- If note: section `הערת העובד` / `"{note}"`.
- **Worker, status active/rejected**: section `דווח על הביצוע`; upload button `📷 {photo?'החלף תמונה':'העלה תמונת ביצוע'}` → `taskUpload()`; textarea `taskNoteInput` placeholder `הערה — מה בוצע, ומה נשאר (אופציונלי)` prefilled with note. Action button (`taskAction`) text `שלח לאישור המנהל`, visible.
- **Manager, status review**: note `העובד הגיש את המשימה. אשר אם בוצעה כראוי, או החזר לתיקון.`; buttons `↩️ החזר לתיקון` → `taskReject()`, `✅ אשר` → `taskApprove()`. Action button hidden.
- Else: action button text `סגור`, visible.
- Backdrop click closes `[L8135]`. `closeTask()` `[L8134]`. Action click → `taskActionClick()` `[L8138]`.

### 6f. Work log — `WORK_LOG` `[L8156]` + `openTaskLog()` `[L8167]`
`WORK_LOG` (read-only):
```
{date:'אתמול', items:[
  {worker:'רן',  task:'בניית מחיצת גבס — חדר רחצה', status:'done'},
  {worker:'רן',  task:'העברת קו ביוב ראשי',         status:'done'},
  {worker:'עומר',task:'יציקת מדה ושיפועים',         status:'done'}]}
{date:'שלשום', items:[
  {worker:'רן',  task:'סימון נקודות מים וחשמל',     status:'done'},
  {worker:'עומר',task:'פירוק אינסטלציה ישנה',       status:'done'}]}
```
`openTaskLog()`: builds `todayDone` from `TASKS` with `status==='done'` (worker name stripped of `' (עובד)'`); prepends a `היום` day (or empty row `אין עדיין משימות שאושרו היום` with worker `—` if none) to `WORK_LOG`. Per day `.log-day`: `📅 {date}` + count `{n} משימות הושלמו`. Per item `.log-row` (`empty` if status `none`): dot `✅`/`·`; task; if worker≠`—` then `👷 {worker}`. Reuses the task sheet: `taskName='יומן עבודה'`, `taskFor='סיכום יומי — מה בוצע בפרויקט'`; action `סגור`; `currentTask=null`.

---

## 7. SMART PROJECT (the "מאפס עד מסירה" day-by-day flow)

### 7a. `view-project` `[L4563-4627]` (verbatim)
- View-switch: `🌳 הפרויקט שלי` (on) / `🏗️ האתרים שלי` (→ `go('sites')`).
- Project hero: tag-button `🚽 פרויקט מלא · בחר יום ›` → `openDayPicker()`; `<h2 id="smartProjTitle">מאפס עד מסירה</h2>`; `<p>BuildSmart מפרק את המשימות לימי עבודה לפי הסדר הנכון בשטח.</p>`; progress bar `smartHeroBar` (0%) + text `smartHeroTxt` `טוען…`.
- Budget box (`bg*`) → `openBudgetDetail()` (see §3b).
- Finance hub button (see §4).
- Hint: `💡 הפרויקט החכם מפרק כל משימה לימי עבודה. אפשר לבצע ימים בכל סדר — ההתקדמות נספרת לפי מה שסומן כבוצע.`.
- `<div id="smartStages">` (filled by `renderSmartProject`).
- `proj-done` (`smartProjDone`, hidden until all done): `🎯 בסיום כל ימי העבודה — הפרויקט מוכן למסירה.`.

### 7b. `renderSmartProject()` `[L7348-7444]`
Builds a **flat list of day-stages** from every task: for each task, `days=max(1,t.days)` stages with `key=t.id+'-'+d`. Total stages = 2+1+3+1+2 = **9**. Progress = count of `smartDayDone[key]` truthy; `pct=round(done/total*100)`.

Per stage card `.stage-card` (class `done` or `open-day`; `open` if expanded):
- Head → `toggleStageCard(key)`: number `✓` if done else sequential index+1; name `{task.name}`; meta `{dayTag} · {task.detail}` where `dayTag={totalDays>1 ? 'יום {day} מתוך {totalDays}' : 'יום עבודה'}`; state pill `בוצע` (cls `s-done`) / `לא בוצע` (cls `s-now`); arrow `▾`.
- When expanded (`expandedStage===key`): `.stage-detail` with rows `פירוט`/`{detail||'—'}`, `עובד אחראי`/`{WORKERS[worker]||'לא שובץ'}`, `היקף`/`{totalDays} ימי עבודה`, optional `הערה`/`{note}`; then `dayDiagramHTML(taskTreeKey(task), key)` (a tree-flow widget, §7e); then steps: header `שלבי ביצוע`, each `.sd-step` (`done` class) → `toggleSmartStep(stepKey)` with check, `{stepName}`, state `בוצע`/`לא בוצע` (`stepKey=t.id+'-step'+si`).
- Foot: a tree button `עץ מוצרים` → `openTree(tk)` (where `tk=taskTreeKey(task)`); and the toggle: if done `↩ בטל סימון` → `toggleSmartDay(key)`, else `✓ סמן יום כבוצע` → `toggleSmartDay(key)`.

After the cards: set `smartHeroBar` width=`pct%`; `smartHeroTxt`=`{done} מתוך {total} ימים בוצעו · {pct}%`; show `smartProjDone` only when `done===total && total>0`; set `smartProjTitle`=`{activeProject().name||'הפרויקט שלי'} — מאפס עד מסירה`; finally `renderBudget()`.

### 7c. Day/stage toggles
- `toggleSmartDay(key)` `[L7445]`: flip `smartDayDone[key]`, re-render, toast `יום עבודה סומן כבוצע` / `הסימון בוטל`.
- `toggleSmartStep(key)` `[L7450]`: flip `smartStepDone[key]`, re-render (no toast).
- `toggleStageCard(key)` `[L7331]`: flip `expandedStage`, re-render.

### 7d. Day picker — `openDayPicker()` `[L7299]` / `jumpToDay(i)` `[L7317]` — overlay `dayPickerOverlay` `[L4630]`
Head: `<h3>קפיצה ליום בפרויקט</h3>` / `<p>בחר יום להצגה — ההתקדמות נשארת לפי מה שבוצע בפועל.</p>`. Builds the same flat stage list; per stage a `.site-opt` → `jumpToDay(i)`: `יום {i+1} · {task.name}` + (if done) tick `✓ הושלם`. `jumpToDay(i)` `[L7317]`: close picker; scroll the i-th `#smartStages .stage-card` into view, add/remove `day-flash` class (1600 ms); toast `עברת ליום {i+1}`. `closeDayPicker()` `[L7314]`.

### 7e. `taskTreeKey(t)` `[L7337]` (keyword → tree key) and `dayDiagramHTML` `[L9458]`
`taskTreeKey` maps a task name to a product-tree via regex, most-specific first: `איטום`→`sealing`; `אסלה|הדחה|מיכל`→`toilet`; `ניקוז|נקז`→`infra`; `מקלח|סוללה`→`shower`; `ברז|כיור|ניל|קו מים|צנרת|אינסטל`→`faucet`; fallback `faucet`. `dayDiagramHTML(treeKey,cardKey)` `[L9458]` renders an interactive `DIAGRAMS[treeKey]` flow (stages → tap a stage to "explode" the components from `TREES[treeKey].acc` whose name matches the stage's `match` keywords). Strings inside: title from `DIAGRAMS[treeKey].title`; burst header `🧩 רכיבים לשלב "{stageLabel}"`; empty `אין רכיבים ייעודיים לשלב זה`; hints `⤵ הרכיבים לשלב הנבחר מוצגים למטה` / `💡 הקש על שלב כדי לראות אילו רכיבים צריך`. (`DIAGRAMS`/`ICN`/`pickDayStage` are part of the catalog/tree subsystem — documented there; the smart-project just embeds them per expanded stage.)

---

## 8. STOCK — `view-stock` `[L5173]`, `renderStock` `[L8209]`, `STOCK_DEMO` `[L6202]`, `moveStock` `[L8237]`

### 8a. `STOCK_DEMO` `[L6202-6214]` — name → location (`'warehouse'`|`'site'`)
```
'סרט טפלון'              : 'warehouse'
'סרט טפלון (גליל)'        : 'warehouse'
'סרט טפלון לאיטום'        : 'warehouse'
'ברזי ניל זוויתיים'       : 'site'
'ברז ניל זוויתי 1/2"'     : 'site'
'ברז זוויתי לכיור 1/2"'   : 'site'
'סיליקון סניטרי'          : 'warehouse'
'סיליקון סניטרי שקוף'      : 'warehouse'
'ברגי קיבוע'             : 'warehouse'
'אטם גומי לברז'          : 'site'
'מחברים וזוויות'          : 'warehouse'
```
(7 warehouse, 4 site.) `STOCK_DEMO` is also mutated from the product-tree "where is it?" control via `[L10231-10232]` (`'order'` deletes the key) and read across the cart/prep flows `[L9542, L11671-11747]`.

### 8b. `view-stock` static `[L5173-5190]` (verbatim)
- Back-head → `go('home')`, title `המלאי שלי`.
- Section `📦 המלאי שלי`.
- Tabs `.stock-tabs`: `🏬 המחסן` (on, `data-st=warehouse`, `pickStockTab('warehouse')`) / `🏗️ האתר` (`data-st=site`, `pickStockTab('site')`).
- `<div id="stockList">`.
- Hint: `💡 כשתסמן פריט כ"במחסן" או "באתר" בעץ המוצרים — הוא יופיע כאן.`.

### 8c. `renderStock()` `[L8209-8236]`
`accLookup()` `[L8195]` builds `{name:{img,why}}` from all `TREES[*].acc`. `items` = keys of `STOCK_DEMO` whose value === `stockTab`. Empty state `.stock-empty`: icon `🏬`/`🏗️`; title `המחסן ריק`/`אין פריטים באתר`; sub `סמן פריטים כ"במחסן"/"באתר" בעץ המוצרים והם יופיעו כאן`. Else per item `.stock-row`: thumb `{info.img||'📦'}`; name `{nm}`; why `{info.why}`; move button `↦ לאתר` (warehouse tab) / `↤ למחסן` (site tab) → `moveStock(nm)`.
`pickStockTab(tab)` `[L8202]`: set tab, toggle `.stock-tab.on`, `renderStock()`. `moveStock(nm)` `[L8237]`: flip `STOCK_DEMO[nm]` between `'site'`/`'warehouse'`, `renderStock()`, toast `הפריט הועבר`.

---

## 9. PLAN SCAN — `view-scan` `[L4984]`, `PLAN_TYPES` `[L9658]`, `renderScanResults` `[L9821]`; doc OCR `openDocScan`/`runDocOCR`

### 9a. `view-scan` static `[L4984-5054]` (verbatim)
- Back-head → `go('home')`, title `סריקת תוכנית`.
- Hero: tag `📐 סריקה חכמה`; `<h2>צלם תוכנית — קבל רשימת חומרים</h2>`; `<p>BuildSmart קורא כל סוג שרטוט, מזהה את הנקודות, ומשווה מחירים בין חנויות שותפות.</p>`.
- **Step A** (`scanStepUpload`): section `בחר סוג תוכנית`; `<div id="planTypePicker">` (filled by `renderPlanPicker`); two upload buttons (both → `startScan()`): `צלם תוכנית`/`פתח מצלמה` and `העלה קובץ`/`PDF / תמונה`; hint `💡 נסה את זה: בחר סוג תוכנית ולחץ "צלם" — נשתמש בשרטוט לדוגמה כדי להדגים את הסריקה והשוואת המחירים.`.
- **Step B** (`scanStepCanvas`, hidden): `.scan-canvas` with `blueprintHolder`, tint, laser, status `scanStatus` (initial spinner + `סורק את התוכנית...`).
- **Step C** (`scanStepResults`, hidden): summary `.detect-summary` with `✓`, title `scanSummaryT` (default `זוהו 4 נקודות`), sub `scanSummaryS` (default `— פריטים נדרשים`); price note `💰 המחירים נמשכים מ-3 חנויות שותפות. BuildSmart בוחר אוטומטית את ההצעה המשתלמת ביותר לכל פריט.`; `<div id="scanZones">`; add button `scanAddBtn` label `scanAddLabel` (default `אשר הכל — הוסף לסל`) → `addScanToCart()`; reset button `סרוק תוכנית אחרת` → `resetScan()`.

### 9b. `PLAN_TYPES` `[L9658-9730]` — four plan types
Each: `label`, `icon`, `sub`, `steps[4]`, `summaryUnit`, `blueprint` (inline SVG), `dots[]` (`{e,r,t}` emoji + right%/top%), `zones[]`. Zones contain `{zi (emoji), zn (zone name), conf (%), items[]}`; items `{n (name), m (meta), img, tree? (tree key), stores: [[storeName,price],...] }`.

| key | label | icon | sub | summaryUnit | dots (e) | zones (count) |
|---|---|---|---|---|---|---|
| `plumbing` | אינסטלציה | 🚿 | מים, ביוב, ניקוז | נקודות אינסטלציה | 🚽 🚰 🚿 🧺 | 4 |
| `electrical` | חשמל | ⚡ | נקודות, שקעים, לוח | נקודות חשמל | 🔲 💡 🔌 🔌 | 3 |
| `architectural` | אדריכלות | 🏛️ | קירות, גבס, פתחים | אלמנטי בנייה | 🧱 🧱 🚪 | 3 |
| `finishing` | גמר | 🎨 | ריצוף, חיפוי, צבע | אזורי גמר | 🟫 🪨 🎨 | 3 |

**steps** (verbatim): plumbing `['סורק את התוכנית...','מזהה סמלים סניטריים...','מאתר נקודות מים וניקוז...','משווה מחירים בחנויות...']`; electrical `[...,'מזהה סמלי חשמל...','מאתר נקודות ומעגלים...',...]`; architectural `[...,'מזהה קירות ומחיצות...','מחשב שטחים ואורכים...',...]`; finishing `[...,'מזהה אזורי ריצוף וחיפוי...','מחשב שטחים נדרשים...',...]`. (First and last steps shared: `סורק את התוכנית...` / `משווה מחירים בחנויות...`.)

**plumbing zones** `[L9665-9676]`:
- 🚽 `נקודת אסלה — קיר צפוני` conf 98 — `אסלה תלויה — סט מושלם` / `כולל מיכל סמוי · 6 אביזרים` / 🚽 / tree `toilet` / stores `[['בנייני העיר',789],['אבן קיסר',740],['טמבור הום',765]]`.
- 🚰 `נקודת כיור — קיר מערבי` conf 95 — `ברז אמבטיה לכיור` / `ברז סוללה · 6 אביזרים` / 🚰 / tree `faucet` / `[['בנייני העיר',205],['אבן קיסר',189],['טמבור הום',198]]`; `סיפון לכיור 1.1/4"` / `ניקוז הכיור` / 🌀 / `[['בנייני העיר',52],['אבן קיסר',46],['טמבור הום',49]]`.
- 🚿 `מקלחת — פינה דרום-מזרחית` conf 92 — `סוללת מקלחת תרמוסטטית` / `עם גוף סמוי · 5 אביזרים` / 🚿 / tree `shower` / `[['בנייני העיר',560],['אבן קיסר',538],['טמבור הום',520]]`.
- 🧺 `נקודת מים — מכונת כביסה` conf 81 — `ברז מכונת כביסה 3/4"` / `כולל אל-חזור` / 🚰 / `[['בנייני העיר',41],['אבן קיסר',38],['טמבור הום',44]]`; `צינור ניקוז למכונה` / `מומלץ — נשכח לעיתים` / 🌀 / `[['בנייני העיר',26],['אבן קיסר',24],['טמבור הום',25]]`.

**electrical zones** `[L9684-9694]`: 🔲 `לוח חשמל — כניסה` conf 97 (`לוח חשמל 24 מודולים`/`כולל פסי צבירה`/🔲/`[['חשמל ישיר',420],['אבן קיסר',389],['טמבור הום',405]]`; `מאמ"תים + ממסר פחת`/`הגנת המעגלים`/⚙️/`[['חשמל ישיר',295],['אבן קיסר',268],['טמבור הום',280]]`); 💡 `נקודת מאור — מרכז התקרה` conf 94 (`כבל חשמל 3×1.5`/`גליל 100 מ' · מעגל תאורה`/🟧/tree `cable`/`[['חשמל ישיר',310],['אבן קיסר',289],['טמבור הום',299]]`; `בית מנורה + מתג`/`נקודת ההדלקה`/💡/`[['חשמל ישיר',54],['אבן קיסר',48],['טמבור הום',51]]`); 🔌 `2× נקודות שקע — קירות` conf 88 (`שקע כפול מוגן`/`×2 — לפי התוכנית`/🔌/`[['חשמל ישיר',38],['אבן קיסר',33],['טמבור הום',36]]`; `קופסאות התקנה + שרוול`/`הכנת הנקודות בקיר`/⬛/`[['חשמל ישיר',62],['אבן קיסר',57],['טמבור הום',60]]`).

**architectural zones** `[L9702-9711]`: 🧱 `מחיצת גבס — אורך 3.40 מ'` conf 96 (`פרופיל גבס 70 מ"מ`/`שלד המחיצה · 5 אביזרים`/⬜/tree `profile`/`[['בנייני העיר',26],['אבן קיסר',24],['גבס מרכז',25]]`; `לוח גבס ירוק 12.5 מ"מ`/`עמיד לחות — חדר רטוב`/🟩/`[['בנייני העיר',58],['אבן קיסר',52],['גבס מרכז',55]]`); 🧱 `מחיצת גבס — אורך 2.10 מ'` conf 91 (`פרופיל גבס 70 מ"מ`/`שלד המחיצה`/⬜/tree `profile`/`[...,24,...]`; `צמר סלעים לבידוד`/`בידוד אקוסטי`/🧵/`[['בנייני העיר',44],['אבן קיסר',39],['גבס מרכז',42]]`); 🚪 `פתח דלת — קיר צפוני` conf 84 (`משקוף + כנף דלת`/`פתח סטנדרטי 80 ס"מ`/🚪/`[['בנייני העיר',520],['אבן קיסר',485],['גבס מרכז',499]]`).

**finishing zones** `[L9719-9728]`: 🟫 `ריצוף רצפה — 8.5 מ"ר` conf 95 (`אריחי גרניט פורצלן 60×60`/`14 מ"ר כולל פחת`/⬜/`[['בנייני העיר',95],['אבן קיסר',89],['קרמיקה פלוס',92]]`; `דבק אריחים גמיש`/`8 שקים · התקנת רצפה`/🪣/`[['בנייני העיר',56],['אבן קיסר',52],['קרמיקה פלוס',54]]`); 🪨 `חיפוי קיר — 6.2 מ"ר` conf 90 (`קרמיקת חיפוי 25×40`/`8 מ"ר כולל פחת`/🟧/`[['בנייני העיר',72],['אבן קיסר',66],['קרמיקה פלוס',69]]`; `רובה אפוקסי`/`מילוי מישקים עמיד מים`/🎨/`[['בנייני העיר',82],['אבן קיסר',78],['קרמיקה פלוס',80]]`); 🎨 `צביעת תקרה ושטחים יבשים` conf 83 (`צבע אקרילי לבן`/`2 דליים · 2 שכבות`/🪣/`[['בנייני העיר',168],['אבן קיסר',149],['קרמיקה פלוס',158]]`).

### 9c. Scan flow functions
- `renderPlanPicker()` `[L9734]`: `.ptype-grid` of one `.ptype` per key (`on` if selected) → `pickPlan(k)`: icon `{p.icon}`, title `{p.label}`, sub `{p.sub}`. `pickPlan(k)` `[L9745]`: set `selectedPlan`, re-render.
- `bestStore(stores)` `[L9747]`: index of the lowest price.
- `startScan()` `[L9752]`: hide upload, show canvas; inject `plan.blueprint`; place `.detect-dot` per `plan.dots` (`right:{r}%; top:{t}%`, text emoji); animated loading with rotating `loadSteps` `[L9780]` (`['מאתר קווי מתאר וקירות…','מזהה נקודות אינסטלציה וחשמל…','מחלץ כמויות חומרים…','משווה מחירים בין חנויות שותפות…']`), headline `מנתח את תצורת הבנייה ומחלץ כמויות חומרים…`; reveals dots staggered; after 3400 ms: `✓ הסריקה הושלמה — {dots.length} אזורים זוהו`, then 700 ms later show results + `renderScanResults()`.
- `renderScanResults()` `[L9821]`: per zone `.zone-card` head `{zi} {zn}` + `ודאות {conf}%` (class `mid` if conf<88). Per item `.zone-item`: thumb `{img}`, info `{n}`/`{m}`; then either a tree button `עץ מוצרים` → `openTree(it.tree)` (if `it.tree`), or a price block `.zi-price` `₪{best}` (+ struck `₪{highest}` if higher exists). Below each item a `.stores` row of `.store-chip` (best one tagged `הזול`): `{store}` `₪{price}`. Footers set: `scanSummaryT`=`זוהו {zones.length} {summaryUnit}`; `scanSummaryS`=`{itemCount} פריטים · ההצעה הזולה ₪{total}`; `scanAddLabel`=`אשר הכל — הוסף {itemCount} פריטים לסל`.
- `resetScan()` `[L9867]`: back to step A, `renderPlanPicker()`, scroll top.
- `addScanToCart()` `[L9881]`: for each zone item push `{name:n,img,price:bestPrice,qty:1,auto:true}`; `updateCartCount()`; toast `{n} פריטים מהתוכנית נוספו לסל`; `go('cart')`.

### 9d. Delivery-note OCR — `openDocScan(orderId)` `[L19249]` / `runDocOCR(orderId)` `[L19260]`
Reached from an order card button `📷 צילום תעודה` `[L7926]`. Overlay `docScanOverlay`, body `docScanBody`.
- `openDocScan`: head `📷` / `צילום תעודת משלוח` / `צלם את תעודת המשלוח הפיזית — המערכת תקלוט את הפרטים אוטומטית.`; server note `⚙️ קליטת הטקסט (OCR) מתבצעת בשרת — כאן מוצגת הדגמה`; scan frame `📄` + `מסגרת הצילום`; button `📷 צלם וקלוט תעודה` → `runDocOCR(orderId)`.
- `runDocOCR`: looks up the order in `SYS_ORDERS`; builds `extracted={docNo:o?.id || 'BS-'+(1000+rand900), date:caToday(), supplier:o?.suppliers[0].store || 'ספק לדוגמה', items:o?.items || 3}`; if order found, sets `o.docScanned=true`, `o.docScanData=extracted`, `saveSysOrders()`. Renders result: head `✓` / `התעודה נקלטה` / `הפרטים זוהו אוטומטית מהצילום:`; rows `מספר תעודה`/docNo, `תאריך`/date, `ספק`/supplier, `פריטים`/items; button `שמור וסגור` → `closeOverlayById('docScanOverlay')`; toast `תעודת המשלוח נקלטה ✓`.

---

## 10. CSS class inventory (port styling map — key classes)

`.pcard`/`.pthumb`/`.pname`/`.prod-check`/`.pprice`/`.qty-wheel`/`.qw-btn`/`.qw-val`/`.pcard-tree`/`.pcard-cat` (home cards); `.site-card`/`.sc-top`/`.sc-name`/`.sc-addr`/`.sc-pm`/`.sc-links`/`.sc-link`/`.sc-edit-hint`/`.badge.live`/`.badge.soon` (sites); `.ss-state`/`.ss-card`/`.ss-row`/`.ss-tile`/`.ss-bar`/`.ss-links`/`.ss-link` (site status); `.budget-box`/`.bg-head`/`.bg-bar`/`.bg-nums`/`.bg-col`/`.bg-foot`/`.bg-edit-btn` (budget box); `.bd-headline`/`.bd-nums`/`.bd-n`/`.bd-alert`/`.bd-sec-h`/`.bd-cat`/`.bd-site`/`.bd-demo-note` (budget detail); `.fin-grid`/`.fin-tile`/`.fin-rows`/`.fin-row`/`.fin-callout`/`.fin-opt`/`.fin-sub`/`.fin-appr`/`.fin-gauge`/`.fin-thr`/`.fin-fx-calc`/`.fin-fx-result`/`.md-head`/`.md-ic`/`.md-title`/`.md-sub` (finance + hub headers); `.sc-gantt`/`.sc-gantt-row`/`.sc-gantt-bar`/`.sc-floor`/`.sc-apt`/`.sc-room`/`.sc-attend-box`/`.sc-safety-today`/`.sc-dep`/`.sc-photo-pair` (site hub); `.ca-card`/`.ca-primary`/`.ca-pill`/`.ca-empty`/`.ca-card-btn`/`.ca-card-done`/`.ca-sub-title`/`.ca-server-note`/`.ca-ocr-result`/`.ca-scan-frame` (shared cards/overlays); `.task-card`/`.tc-ic`/`.task-pill`/`.task-group`/`.task-intro`/`.task-cal-btn`/`.worker-pick`/`.wp-btn`/`.role-switch`/`.role-btn`/`.task-loc`/`.td-status`/`.td-sec`/`.td-upload`/`.td-note`/`.td-mgr-btns`/`.td-approve`/`.td-reject`/`.log-day`/`.log-row` (tasks); `.stage-card`/`.stage-head`/`.stage-num`/`.stage-state`/`.stage-arrow`/`.stage-foot`/`.sf-tree`/`.sf-done`/`.sf-undo`/`.stage-detail`/`.sd-step`/`.sd-row` (smart project); `.stock-tabs`/`.stock-tab`/`.stock-row`/`.sr-thumb`/`.sr-move`/`.stock-empty` (stock); `.ptype`/`.ptype-grid`/`.scan-canvas`/`.detect-dot`/`.scan-status`/`.scan-load`/`.zone-card`/`.zone-head`/`.zone-item`/`.zi-tree-btn`/`.store-chip` (scan). Status pill color classes (tasks): `pend/act/rev/done/rej`. Order status (`ORDER_STATUS` `[L7632]`): `st-pending/processing/shipped/delivered`.

---

## → Flutter port notes

**Current Flutter state: NONE of this domain is implemented.** The contractor's Home/Projects/Budget/Finance/Tasks/Site-Hub/Scan/Stock features are entirely absent from `app_flutter/`. Per R2 ("אין חלון, נקודה") every feature here that opens a full screen/sheet in the prototype must be re-expressed as a **dial leaf** in Flutter, and the prototype's actual screens (`view-project`, `view-sites`, `view-tasks`, `view-scan`, `view-stock`) must remain **placeholder/toast stubs** — do not port them as full-screen views. Concretely:

1. **Data models** — port all the data verbatim into Dart immutable seeds: `PROJECTS` (3), `ARCHIVED_PROJECTS` (3), `SIM_SITES`/`SIM_CUSTOMERS` (supplier-sim only), `SITE_TREE` (3 floors), `STOCK_DEMO` (11 items), `TASKS` (5, with full `steps`), `WORK_LOG` (2 days), `GANTT_TASKS` (6), `snagList`/`inspections` (initial 2 each), `SAFETY_TIPS` (5), `PLAN_TYPES` (4 with all zones/stores), `budgetCategories` (4), `projectBudget`, `PAYMENT_TERMS` (4), `subcontractors` (3), `approvalQueue` (2), `FX_RATES`/`BUILD_INDEX`, `DEMO_HISTORY` (2), `HOME_PRODUCTS` keys + their 3 source TREES. Use Riverpod `StateNotifier`s for the mutable ones (`PROJECTS`, `TASKS`, `projectBudget`, `budgetCategories`, `STOCK_DEMO`, `smartDayDone`, `smartStepDone`, `snagList`, `inspections`, `attendanceLog`, `workDiary`, `penaltyLedger`, `subcontractors`, `approvalQueue`, `activePaymentTerm`).

2. **All Hebrew strings are verbatim and load-bearing (R6/R8)** — copy them exactly, including punctuation, the `₪` prefix, `מ"מ`/`מ"ר`/`ס"מ` quoting, `יח״ד`/`ראשל״צ`/`בע״מ` gershayim, the inch marks (`1/2"`, `3/4"`, `1.1/4"`), and emoji. Do not paraphrase, translate, or "fix" spacing.

3. **Two ten-feature hubs → two dial sub-trees.** `openFinanceHub` (features 11–20) and `openSiteHub` (features 21–30) are already represented as hub leaves in the existing Menu/BS dials per the project status; this doc gives the **full inner behavior** of every feature so each can become its own leaf. Replace `prompt()` calls (addPenalty/addSnag/addDiaryEntry/addInspection/editProductMaterial) with R9 inline text inputs, not dialogs. Replace `window.open`/print (finReports) and the FX/OCR "server" notes with toast stubs.

4. **Task status machine + dual roles** — port `taskStatusInfo` (5 states), the worker→review auto-advance, manager approve/reject, and the manager/worker view split (`renderTasks`). Keep the `WORKERS` array and the `' (עובד)'` strip in the work-log. Photo is a demo string (`'demo'`) — stub the camera with a toast.

5. **Smart project** — the flat day-stage expansion (`task.days` → N stages, key `id-d`), independent (un-ordered) done-marking, `smartStepDone` per step, and the `dayDiagramHTML` tree-flow embed all depend on the catalog/`DIAGRAMS` subsystem; gate the diagram behind that doc's port. Progress = done/total over **9** stages by default.

6. **Money/format helpers** — implement `fMoney(n) = '₪' + round(n).toString()` with thousands separators matching `toLocaleString()` (Hebrew locale groups by comma). `caToday()` = localized date (`he-IL`). Beware: budget/finance math (pct, ROI×1.42, index×(1+pct/100), invoice split by weight, triangular site weights `(n-i)/((n(n+1))/2)`) must match exactly to reproduce the demo numbers (pct=66%, etc.).

7. **Sync coupling** — the budget box exists twice (`bg*` on project, `sb*` on sites) and `renderBudget` writes both; in Flutter a single shared provider feeding two widgets covers this. `switchProject`/`switchProjectSilent` save/restore per-project carts and update the app-bar site label — preserve that ownership model.

8. **RTL specifics** — Gantt bars are positioned with `right:%` (RTL); arrows are `‹`/`←`/`›` pointing RTL; ensure `Directionality.rtl`. Confidence chip `mid` styling triggers when `conf < 88`.

9. **Toast-stub everything not yet built** — until the real flows land, any leaf for these features should `toast('בקרוב')`-style stub or render the static informational content; do NOT build new full-screen views (R2).
