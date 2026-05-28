# Prototype Port Spec — 01: Onboarding · Shell · Navigation/Routing · FAB/Dial

> Source of truth: `/home/user/buildsmart/index.html` (22,416-line vanilla-JS prototype, Hebrew RTL).
> All `[L#]` refs point into that file. Hebrew strings are reproduced **verbatim** (exact punctuation, emoji, niqqud-free as in source). This doc covers the **entry/onboarding flow, the app shell chrome, the hash router, and the tabbar** — and explains why the prototype has **no FAB/dial** (that is a Flutter/Preact-era reinvention, governed by R1/R2).

---

## 0. Big picture & boot order

The whole prototype lives inside one `.screen` container `[L4025]`. There are two layers:

1. **Onboarding overlay screens** — full-screen `.fullscreen` divs (`z-index:100` `[L2468-2471]`) that sit *on top of* the app. Toggled by `showScreen(id)`. All but `screen-splash` start `style="display:none"`.
2. **The contractor app** — `statusbar` + `appbar` + `body` (the `.view`s) + `tabbar`. Always present underneath; revealed when every overlay screen is hidden via `enterApp()`.

**Boot sequence:**
- Page loads → `screen-splash` is the only visible fullscreen (no `display:none` on it `[L4030]`).
- A 1600 ms `setTimeout` `[L18373-18378]` checks the splash is still visible and calls `showScreen('screen-welcome')`.
- `BSRouter.start()` `[L20371]` wires `hashchange`. On first load the hash is empty → router treats current route as `home` (default `current()` returns `'#home'` stripped `[L20296]`), but the visible overlay still wins visually until an `enterApp()` / `showScreen` runs.
- `tick()` + `setInterval(tick,30000)` `[L22413]` drives the status-bar clock.

`appStore.screen` `[L20280-20282]` defaults to `'home'` and is updated by the router on every `hashchange` `[L20305]` (used by RBAC/audit elsewhere).

---

## 1. Onboarding screens — verbatim markup

### 1.1 `screen-splash` `[L4030-4039]`
Full-screen, dark (`#screen-splash{background:var(--ink);…}` `[L2514]`), centered, `splashIn .6s` animation `[L2515-2516]`.

| Element | Content / verbatim string |
|---|---|
| `.login-bg` | decorative radial blob `[L4031]` |
| `.splash-logo` svg | house/roof glyph, teal `#1f6f6b` + amber `#f2a516` strokes `[L4034]` |
| `.splash-brand` | `Build` + `<span>Smart</span>` (span = amber) → renders **BuildSmart** `[L4036]` |
| `.splash-slogan` | **מהשרטוט עד האתר — בלי לשכוח כלום** `[L4037]` |

Auto-advances to welcome after 1.6 s (see boot).

### 1.2 `screen-welcome` ("connect / register") `[L4042-4079]`
The hub of entry. Has the hamburger that opens the role drawer.

| Element | Verbatim string / behavior |
|---|---|
| `.welcome-hamburger` (3 spans) | `onclick="toggleRoleDrawer()"` `title="מי אתה?"` `[L4044-4046]` |
| `.login-logo` + `.login-brand` | **BuildSmart** logo lockup `[L4048-4051]` |
| green button `.btn .btn-green` | **כניסה ללקוח קיים** → `onclick="enterAsExisting()"` `[L4054-4056]` |
| `.login-or` | **או הירשם** `[L4057]` |
| `.login-h` | **רישום ראשוני** `[L4058]` |
| `.login-sub` | **מלא את הפרטים — סימן ✓ יופיע כשהשדות תקינים** `[L4059]` |
| input `#regName` | placeholder **שם מלא**, `oninput="checkRegistration()"` `[L4061-4062]` |
| `#regNameCheck` | `✓` (hidden until valid) `[L4063]` |
| input `#regContact` | placeholder **טלפון או אימייל**, `oninput="checkRegistration()"` `[L4066-4067]` |
| `#regContactCheck` | `✓` `[L4068]` |
| `.reg-confirm #regConfirm` | checkmark svg + **אישור והמשך** → `onclick="finishRegistration()"` (hidden until both fields valid) `[L4070-4073]` |
| `.login-alt` button | **המשך ללא רישום (דוגמה)** → `onclick="enterAsDemo()"` `[L4074-4076]` |
| `.login-foot` | **בהרשמה אתה מאשר את תנאי השימוש של BuildSmart** `[L4078]` |

### 1.3 `role-drawer` ("מי אתה?") `[L4082-4114]`
A right-side slide-in drawer + scrim. Scrim `#roleDrawerScrim` `onclick="toggleRoleDrawer()"` `[L4082]`. Drawer slides from right (`transform:translateX(100%)`→`0`) `[L2566-2572]`, width 290 px / max 84% `[L2567]`.

Head `[L4084-4087]`:
- `.rd-title` — **מי אתה?**
- `.rd-sub` — **בחר תפקיד כדי להיכנס**

Five `.role-pick-btn` (icon · `<b>` title · `<small>` desc · `‹` arrow) `[L4088-4112]`:

| onclick | icon | `<b>` title | `<small>` description |
|---|---|---|---|
| `enterRole('contractor')` | 👷 | **קבלן** | **הזמנת חומרים, מלאי, משימות** |
| `enterRole('manager')` | 👔 | **מנהל המערכת** | **ניהול מוצרים, חנויות, לקוחות** |
| `enterRole('store')` | 🏪 | **חנות ספק** | **הזמנות נכנסות, מלאי החנות** |
| `enterRole('courier')` | 🛵 | **שליח** | **משלוחים ועדכוני סטטוס** |
| `enterRole('worker')` | 🦺 | **עובד** | **המשימות שהוקצו לי בשטח** |

Foot `.rd-foot` `[L4113]`: **הדגמה — כל התצוגות חולקות מאגר נתונים אחד**

### 1.4 `screen-login` `[L4116-4145]`
Dark background (`#screen-login{background:var(--ink)}` `[L2472]`). Reached for `contractor` role and from existing/demo entry.

| Element | Verbatim string / behavior |
|---|---|
| `.login-logo` + `.login-brand` | **BuildSmart** `[L4118-4123]` |
| `.login-slogan` | **מהשרטוט עד האתר — בלי לשכוח כלום** `[L4123]` |
| `.onb-back` | back chevron svg + **חזור** → `onclick="showScreen('screen-welcome')"` `[L4126-4129]` |
| `.login-h` | **ברוך הבא 👋** `[L4130]` |
| `.login-sub` | **התחבר כדי להתחיל לעבוד** `[L4131]` |
| `.login-field` label | **מספר טלפון** `[L4133]` |
| input `#loginPhone` | `type="tel"` placeholder **050-0000000** `[L4134]` |
| `.btn .btn-amber` | **המשך** → `onclick="loginExisting()"` `[L4136-4138]` |
| `.login-or` | **או** `[L4139]` |
| `.btn .login-alt` | **כניסה מהירה להדגמה** → `onclick="loginExisting()"` `[L4140-4142]` |
| `.login-foot` | **בכניסה אתה מאשר את תנאי השימוש של BuildSmart** `[L4144]` |

Note: both buttons call the same `loginExisting()` — phone input is decorative; no validation.

### 1.5 `screen-profession` ("מה התחום שלך?") `[L4148-4184]`
Reached only after **new** registration (`finishRegistration`). Layout `#screen-profession{padding:0 22px}` `[L2577]`.

| Element | Verbatim string / behavior |
|---|---|
| `.onb-back` | chevron + **חזור** → `showScreen('screen-welcome')` `[L4149-4152]` |
| `.prof-h` | **מה התחום שלך?** `[L4154]` |
| `.prof-sub` | **נתאים לך את האפליקציה — קטלוג, כלים והמלצות לפי המקצוע** `[L4155]` |
| `.prof-foot` | **תוכל לשנות את הבחירה בכל עת מההגדרות** `[L4183]` |

Three `.prof-card` (icon box · name · desc · `‹`) `[L4157-4182]`:

| onclick | icon | `.prof-name` | `.prof-desc` |
|---|---|---|---|
| `pickProfession('אינסטלטור','🔧')` | 🔧 | **אינסטלטור** | **ברזים, אסלות, צנרת, חימום מים** |
| `pickProfession('חשמלאי','⚡')` | ⚡ | **חשמלאי** | **נקודות, לוחות, כבלים, גופי תאורה** |
| `pickProfession('קבלן שיפוצים','🔨')` | 🔨 | **קבלן שיפוצים** | **פרויקט שלם — מבנייה ועד גמר** |

> The profession name passed to `pickProfession` (e.g. `'אינסטלטור'`) is **not** the same vocabulary as the role-drawer's `'קבלن'`; profession is a contractor sub-trade for catalog tailoring.

### 1.6 `screen-prep` (legacy "where are you?" / loading list) `[L4188-4203]`
**Vestigial / unreachable in the normal flow.** `pickProfession` comments note the prep/where screens were *moved into the Tasks view* and finishing the trade enters the app directly `[L11648-11651]`. It is **not** in `ONBOARD_SCREENS`, so `showScreen` never hides/shows it as a peer; it is registered in the hash map (`prep`→`screen-prep` `[L20385]`) but `buildPrep`/`prepProceed`/`prepChoice` are dead from onboarding. Still, capture its strings since a deep-link `#prep` would reveal it:

| Element | Verbatim |
|---|---|
| `.onb-back.onb-back-light` | chevron + **חזור** → `showScreen('screen-profession')` `[L4190-4193]` |
| `#prepStageTag` | **שלב נוכחי** (replaced at runtime by `'שלב נוכחי · '+stage.name`) `[L4194]`,`[L11665]` |
| `#prepH` | **רשימת העמסה** `[L4195]` |
| `#prepGo` | **המשך** → `prepProceed()` `[L4200]` |
| `.prep-skip` | **דלג — כניסה לאפליקציה** → `enterApp()` `[L4201]` |

`buildPrep(loc)` strings (warehouse vs site), kept for completeness `[L11661-11719]`:
- warehouse H: **רשימת העמסה מהמחסן 🏬**; sub `'לפי שלב "…" — אלה הפריטים שכדאי לקחת מהמחסן לאתר.'`
- site H: **מה חסר באתר 🏗️**; sub `'לפי שלב "…" — אלה הפריטים שעדיין לא נמצאים באתר.'`
- group labels: `✅ יש במחסן — קח איתך (n)`, `🛒 חסר — לא במחסן ולא באתר (n)`, `✅ הכל כבר באתר — אפשר לצאת לעבודה`, `✅ כבר באתר (n)`, `⚠️ לא באתר (n)`, `✅ כל הציוד לשלב הזה כבר באתר`
- prompt: **איך תרצה להשלים את החוסר?** / **…איך תרצה להשלים?** with options **🚚 משלוח ישר לאתר**, **🛍️ אאסוף בדרך**, **🏬 לקחת מהמחסן**, **🚚 משלוח מחנות** `[L11680-11711]`
- `#prepGo` is relabeled **המשך לאפליקציה** `[L11718]`
- `prepChoice` toasts `[L11738-11743]`: deliver=**נשלח לאתר — הפריטים יתווספו לעגלה**; pickup=**סומן לאיסוף עצמי בדרך**; fromwh=**סומן להעברה מהמחסן לאתר**; store=**משלוח מחנות — הפריטים יתווספו לעגלה**; default=**נשמר**. `currentStage()` is hardcoded `{name:'איטום והכנת רצפה',tree:'sealing'}` `[L11658-11660]`.

### 1.7 Role-dashboard screens (in `ONBOARD_SCREENS`, opened by `enterRole`)
These are *not* the contractor app — they're full-screen role views. Documented briefly here because `showScreen` switches among them; the full content is a separate domain.
- `screen-manager` `[L4207-4238]` — title **👔 מנהל המערכת**; back **‹ יציאה**→`screen-welcome`; tabs: **📊 לוח בקרה** (`m-products`) · **🚚 הזמנות** (`m-orders`) · **👥 לקוחות** (`m-customers`) · **🛠️ ניהול** (`m-manage`).
- `screen-store-login` `[L4241-4251]` — **כניסת ספקים** / **בחר את החנות שלך כדי להיכנס לפורטל הניהול**; list from `STORES`; note **🔒 באפליקציה האמיתית כל ספק מתחבר עם קוד גישה אישי. זוהי כניסת הדגמה.** Stores `[L11930-11934]`: `מחסני אינסטלציה תל-אביב`/גוש דן/עד שעתיים, `ספקי סניטריה השרון`/השרון/עד שעתיים, `חומרי בניין הרצליה`/הרצליה והסביבה/עד שעה.
- `screen-store` `[L4254-4288]` — title `#storeTitle` default **🏪 חנות ספק**; back **‹ יציאה**→`storeLogout()`; tabs **🏠 בית**(`s-home`)·**📥 הזמנות**(`s-orders`)·**📦 מלאי**(`s-stock`)·**🧰 פורטל**(`s-portal`).
- `screen-courier` `[L4291-4308]` — title **🛵 שליח · משאית 14**; back→`screen-welcome`.
- `screen-worker` `[L4321-4333]` — title **🦺 עובד**; back→`screen-welcome`; note **בחר את שמך, בצע את המשימה, צרף תמונה ושלח לאישור המנהל.**; workers `WORKERS=['רן (עובד)','עומר (עובד)']` `[L8021]`.
- `screen-delivery-note` `[L4311-4318]` — bar **‹ סגור** / **תעודת משלוח** / **🖨️ הדפסה** (`window.print()`).

---

## 2. Onboarding functions — behavior & side-effects

### `showScreen(id)` `[L11635-11640]`
Iterates `ONBOARD_SCREENS` `[L11634]` and sets each element's `display` to `'flex'` if it equals `id`, else `'none'`. Only screens **in that array** are toggled — `screen-prep` and the welcome/profession-only siblings outside the array are unaffected. **Wrapped by the router** `[L20396-20406]`: after the original runs, if not already handling a hashchange, it writes `location.hash = '#'+SCREEN_TO_HASH[id]`.

`ONBOARD_SCREENS` `[L11634]` =
```
['screen-splash','screen-welcome','screen-login','screen-profession',
 'screen-manager','screen-store','screen-store-login','screen-courier',
 'screen-worker','screen-delivery-note']
```
(Note: `screen-prep` is **deliberately absent**.)

### `goProfession()` `[L11641-11643]`
`showScreen('screen-profession')`. (Helper; `finishRegistration` calls `showScreen` directly.)

### `backToLogin()` / `backToProfession()` `[L11644]`,`[L11653]`
`showScreen('screen-login')` / `showScreen('screen-profession')`.

### `pickProfession(name, icon)` `[L11645-11652]`
1. `userProfession = name`.
2. Sets `#homeGreet` text to `icon+' שלום, '+name` (e.g. **🔧 שלום, אינסטלטור**) — the home hero tag `[L4428]`.
3. Sets `userLocation='site'` (the where-step is skipped).
4. Calls `enterApp()` → lands in the app on the **catalog** view.

### `enterApp()` `[L11756-11763]`
Hides **every** screen in `ONBOARD_SCREENS` (display:none), then `go('catalog')`. Comment: "initial flow opens straight on the catalog (home stays on its tab)" `[L11761]`. This is the single exit gate from onboarding into the contractor app.

### `enterRole(role)` `[L11806-11820]`
1. Removes `.show` from `#roleDrawer` and `#roleDrawerScrim` (closes drawer).
2. `appStore.set({role:role})` (RBAC sync) and `auditLog('מעבר תפקיד', role)`.
3. Dispatch:
   - `contractor` → `showScreen('screen-login')` then **return** (contractor goes through phone login).
   - `manager` → `showScreen('screen-manager')` + `admTab('m-products')`.
   - `store` → `showScreen('screen-store-login')` + `renderStoreLogin()`.
   - `courier` → `showScreen('screen-courier')` + `renderCourier()`.
   - `worker` → `showScreen('screen-worker')` + `renderWorker()`.

### `enterAsExisting()` `[L18354-18357]`
`applyEntryMode('existing')` (customer manages their own seeded sites) → `showScreen('screen-login')`.

### `enterAsDemo()` `[L18358-18361]`
`applyEntryMode('demo')` (keeps sample site name + demo history) → `showScreen('screen-login')`.

### `loginExisting()` `[L11823-11830]`
If `userProfession` empty, defaults it to **קבלן** and sets `#homeGreet` to **👷 שלום, קבלן**. Then `enterApp()`. (Both login buttons call this; the phone field is never read.)

### `finishRegistration()` `[L18345-18351]`
1. Reads trimmed `#regName` into `userName`.
2. `toast('נרשמת בהצלחה — ברוך הבא '+name)` → e.g. **נרשמת בהצלחה — ברוך הבא דנה**.
3. `applyEntryMode('new')` (brand-new customer; **no site yet**).
4. `showScreen('screen-profession')` (new users pick a trade).

### `checkRegistration()` `[L18332-18342]`
Live validation on every keystroke:
- `nameOk` = `regName` trimmed length ≥ 2.
- `contactOk` = `isValidContact(regContact)`.
- Toggles `.valid` on each field's parent (drives the ✓ pop-in `[L2540-2541]`).
- Toggles `.show` on `#regConfirm` only when **both** valid `[L18341]`.

### `isValidContact(v)` `[L18322-18329]`
Trims; empty→false. `phoneOk` = `/^0\d{8,9}$/` on digits (strip `-`/space) → 9–10 digits, leading 0. `emailOk` = `/^[^\s@]+@[^\s@]+\.[^\s@]+$/`. Returns `phoneOk || emailOk`.

### `openRegistration()` `[L6794-6802]`
From inside the app (e.g. settings): closes `settingsOverlay` + `rankDetailOverlay`, then `showScreen('screen-welcome')` — i.e. "log out" back to the welcome screen.

### `toggleRoleDrawer()` `[L18364-18370]`
Toggles `.show` on `#roleDrawer` + `#roleDrawerScrim` together (open = drawer not currently shown).

### `applyEntryMode(mode)` `[L6998-7009]`
Central entry-mode switch. Sets global `entryMode`. If `'new'`: replaces `PROJECTS` with a single empty site `{id:'PRJ-1',name:'',addr:'',manager:'',cart:[],treeProgress:{}}` and `activeProjectId='PRJ-1'`. `'demo'`/`'existing'` keep the seeded `PROJECTS`. Always: `refreshSiteLabel()`, `refreshIdentity()`, `renderReorderHistory()`.

**`entryMode`** `[L6465]` default `'demo'`. Drives:
- `refreshSiteLabel()` `[L6469-6480]`: in `'new'` with empty site → app-bar pill shows **הוסף אתר !** (red alert) + `.needs-site`; otherwise shows `name+' ›'`.
- `renderReorderHistory()` `[L7017-7038]`: `'demo'` shows `DEMO_HISTORY` `[L7013-7016]` (**מקדחה רוטטת בוש GBH** ₪640 / **שק מלט אפור 25 ק"ג** ₪31), else empty-state **עדיין אין הזמנות קודמות — לאחר ההזמנה הראשונה היא תופיע כאן.**
- `openSitePicker()` `[L7041-7057]`: `'existing'` lists user's sites (**האתרים שלך** / **בחר לאן לשלוח, או הוסף אתר חדש**) vs the name-entry path.
- `isDemoMode()` `[L6758]` = `entryMode==='demo'` (gates the demo banner in settings **🧪 חשבון הדגמה …** `[L6812]`).
- Once a `'new'` user names a site, mode auto-promotes to `'existing'` `[L7096]`.

**Identity globals:** `userProfession=''` `[L11633]`; `userLocation=''` `[L11657]`; `userName=''` `[L6490]`; `userProfile` `[L6492]` = `{name:'',phone:'',business:'עוסק מורשה',trade:'אינסטלציה',payment:''}`.

**Seeded `PROJECTS`** `[L6447-6451]` (demo/existing): `PRJ-1` **מגדל הרצליה — קומה 4** / רח' הנדיב 12, הרצליה / יוסי כהן · `PRJ-2` **וילה כפר שמריהו** / רח' האלון 4, כפר שמריהו / אבי מזרחי · `PRJ-3` **שיפוץ משרדים — רעננה** / אחוזה 88, רעננה / דנה לוי. `activeProjectId='PRJ-1'`, `projSeq=4` `[L6452-6453]`.

---

## 3. The hash router (BSRouter) + `go()`/`showScreen()` wrappers

### `BSRouter` `[L20291-20319]`
A tiny IIFE router over `location.hash`:
- `routes={}`; guard `inHandle` `[L20295]` prevents wrapper re-entry loops.
- `current()` `[L20296]` → `(location.hash||'#home').replace(/^#/,'')`.
- `parse(raw)` `[L20299-20302]` → splits on `/`: `{name:parts[0]||'home', params:parts.slice(1)}` (supports nested routes like `project/PRJ-1`).
- `handle()` `[L20303-20311]`: on hashchange, sets `appStore.screen=name`, then runs the registered route fn (params) if any, else falls back to `go(name)`. Wrapped in `safeRun('ניווט', …)`.
- Public: `register(name,fn)`, `navigate(name)`, `start()` (adds `hashchange` listener), `isHandling()`, `parse`. Started at `[L20371]`.

### `go(v)` `[L6407-6438]` — in-app view switch (the contractor app)
1. Removes `.active` from all `.view`, adds to `#view-<v>`.
2. `playPageTransition()`.
3. **Merged-tab mapping** `[L6413-6416]`: `project`/`sites`→`sites` tab; `cart`/`orders`→`cart` tab; `catnav`→`catalog` tab; else `v`. Highlights the matching `.tab` (toggles `.on` + recolors svg strokes teal `#1f6f6b` / grey `#8b8d8f`) `[L6417-6421]`.
4. Scrolls `.body` to top; clears the home-search dropdown/input when leaving home `[L6422-6428]`.
5. Per-view render dispatch `[L6429-6436]`: `cart`→renderCart · `home`→renderHomeProducts · `project`→renderSmartProject · `catalog`→renderCatChips+renderCatalog · `catnav`→renderCatNav · `orders`→renderMyOrders(+renderSupplyHub) · `sites`→renderProjects · `profile`→refreshIdentity. (`scan`/`stock`/`tasks` are static "coming soon" — no render.)

### Router ↔ navigation wiring `[L20392-20438]`
Re-wraps both globals so URL hash mirrors UI:
- **`window.showScreen`** wrapper `[L20396-20406]`: runs original, then (unless handling) writes `#<SCREEN_TO_HASH[id]>`.
- **`window.go`** wrapper `[L20408-20422]`: runs original, then (unless handling) writes `#<v>`; **special-cases** `project` → `#project/<activeProjectId>` for a real deep link `[L20414-20417]`.
- Registers every onboarding hash → `showScreen(...)` `[L20424-20427]`.
- Registers nested `project` route `[L20430-20437]`: if `params[0]` is a known project id → `switchProjectSilent(id)` then `go('project')`.

### `ONBOARD_HASH_MAP` `[L20383-20388]` and `SCREEN_TO_HASH` `[L20389-20390]`
`SCREEN_TO_HASH` is built by inverting the map `[L20390]`.

| hash | screen id |
|---|---|
| `splash` | `screen-splash` |
| `welcome` | `screen-welcome` |
| `login` | `screen-login` |
| `profession` | `screen-profession` |
| `prep` | `screen-prep` |
| `manager` | `screen-manager` |
| `store` | `screen-store` |
| `store-login` | `screen-store-login` |
| `courier` | `screen-courier` |
| `worker` | `screen-worker` |
| `delivery-note` | `screen-delivery-note` |

> Asymmetry to mind when porting: `screen-prep` is in the hash map (deep-linkable) but **not** in `ONBOARD_SCREENS` (so `showScreen('screen-prep')` would hide all the others without ever showing prep — prep is only revealed by a literal `#prep` hash via the registered route, which calls `showScreen('screen-prep')` → still hidden by the array logic; effectively dead). Treat prep as legacy.

### Test-impl nav contracts (regression harness) `[L15712-15721]`
`testImp_navSafe` wrappers assert representative args: `enterRole('contractor','כניסה לתפקיד')`, `enterApp(undefined,'כניסה לאפליקציה')`, `showScreen('screen-login','החלפת מסך')`, `go('catalog','ניווט בין טאבים')`, `admTab('m-products','החלפת טאב מנהל')`. Useful as the canonical "happy path" arguments.

### `closeDeliveryNote()` re-entry `[L17280-17288]`
If `deliveryNoteReturn==='app'`: `enterApp()` + `go('orders')` (returns into the contractor app, orders tab); else `showScreen(deliveryNoteReturn)` (returns to the role screen that opened it).

---

## 4. The app shell chrome (under the overlays)

Order inside `.screen`: `statusbar` → `appbar` → appbar pickers (overlays) → `body` (all `.view`s) → `tabbar` `[L4335-5405]`.

### 4.1 Status bar `[L4335-4341]`
`#clock` (default **9:41**, updated by `tick()` `[L11627-11631]` to `H:MM`). `#bsDeviceStatus` dots: `🔋` (`aria-label="סוללה"`) + `📶` (`aria-label="חיבור רשת"`).

### 4.2 App bar `[L4343-4387]`
- Brand: house logo + **BuildSmart** `[L4345-4350]`.
- `head-icons`:
  - Bell `.bell-btn` → `toggleNotifications(event)`; badge `#bellBadge` (hidden, default 0) `[L4352-4355]`.
  - Cart icon → `go('cart')`; `#cartCount` default 0 `[L4356-4359]`.
- Notification dropdown `#notifPanel` `[L4364-4370]`: head **התראות** + clear-all **נקה הכל** (`clearNotifications()`); list `#notifList`.
- `deliv-row` two pills `[L4371-4386]`:
  - **משלוח לאתר** / `#appbarSite` default **מגדל הרצליה ›** → `openSitePicker()` (site-needed state replaces text with **הוסף אתר !**).
  - **סטטוס משלוח** / `#appbarDelivery` default **צפה במשלוחים ›** → `openShipmentStatus()`.

Appbar-attached sheets: `#sitePickerOverlay` (head **בחר אתר משלוח** / **לאן לשלוח את החומרים?**) `[L4389-4399]`; `#deliveryPickerOverlay` (head **זמן אספקה** / **מתי להביא את החומרים לאתר?**) `[L4401-4411]`.

### 4.3 Body views `[L4413+]`
`.body` holds all `.view` panes; `#view-home` is `.active` by default `[L4416]`. Views: `home`, `catalog`, `catnav`, `project`, `sites`, `cart`, `orders`, `profile`, plus coming-soon `scan`/`stock`/`tasks`. (Detailed view content = other domains.) Home hero greet tag `#homeGreet` default **⚡ אקספרס לאתר** `[L4428]` (overwritten by `pickProfession`/`loginExisting`).

### 4.4 Tabbar — the *only* primary navigation in the prototype `[L5383-5405]`
`.tabbar` is `flex` of 5 `.tab`, `role="navigation"` `aria-label="ניווט ראשי"` added by `enhanceA11y()` `[L20489-20493]`. CSS `[L2161-2171]`.

| `data-tab` | onclick | label (verbatim) | extras |
|---|---|---|---|
| `home` | `go('home')` | **בית** | starts `.on` `[L5384]` |
| `catalog` | `go('catalog')` | **קטלוג** | |
| `sites` | `go('sites')` | **הפרויקטים** | |
| `cart` | `go('cart')` | **רכש** | `#tabDot` badge (hidden, 0) `[L5399]` |
| `profile` | `go('profile')` | **הגדרות** | |

> The labels **הפרויקטים** (tab→`go('sites')`) and **רכש** (tab→`go('cart')`) are the merged-tab anchors: per `go()`'s mapping, `project`+`sites` light the **הפרויקטים** tab and `cart`+`orders` light the **רכש** tab.

### 4.5 Tagline (outside `.screen`, the page chrome) `[L5409-5412]`
**אב-טיפוס אינטראקטיבי של BuildSmart · חוויית חנות במשלוח עד שעתיים · הלב של הדמו: לחיצה על מוצר ⚡חכם מפעילה את עץ המוצרים**

---

## 5. The "FAB / dial" system — **does not exist in the prototype**

Searched exhaustively: there is **no `.fab`, no speed-dial, no nav-rail, no floating action button** anywhere in `index.html`. The prototype's primary navigation is the 5-tab **tabbar** (§4.4); everything else opens as **bottom-sheet overlays** (`.overlay`/`.sheet` with a `.grip`) or full-screen `showScreen` overlays. The dark-backdrop tap-to-close handler lists ~60 such overlays `[L18419-18422]`.

The **FAB/dial concept (R1: 5 FABs · R2: "no window, everything is a dial")** is the **Flutter/Preact re-architecture**, not in this source. When porting, the prototype's tabs + sheets are the *content* spec; the *shell* is reframed as dials. See port notes.

---

## 6. The onboarding TOUR (data + render)

Distinct from entry-onboarding: a 6-step coach-mark tour shown **inside the app** (renders into `#serviceFeatureOverlay` via `svcFeature`), launched by `svcOnboarding()` `[L22382-22385]` (item "100 onboarding tour" `[L22048]`). It is **not** part of the splash→welcome→app entry flow.

`TOUR_STEPS` `[L22374-22381]` (verbatim):

| # | `ic` | `t` (title) | `d` (description) |
|---|---|---|---|
| 1 | 🏠 | **מסך הבית** | **כאן מתחילים — חיפוש מהיר, קטגוריות, וכלי ה-AI החכמים.** |
| 2 | 🛒 | **הזמנה** | **בוחרים מוצרים, מוסיפים לסל, ומאשרים — הכל מגיע ישר לאתר.** |
| 3 | 💰 | **תקציב** | **מרכז הפיננסים עוקב אחרי כל שקל — תקציב, חריגות ודוחות.** |
| 4 | 📋 | **משימות ואתר** | **ניהול אתר הבנייה — גאנט, ליקויים, נוכחות ובטיחות.** |
| 5 | 🎮 | **מועדון BuildSmart** | **צוברים BuildCoins על כל פעולה — וממשים בהטבות.** |
| 6 | 🎉 | **מוכנים!** | **זהו — אתם מכירים את BuildSmart. בהצלחה בעבודה!** |

### `renderTourStep()` `[L22386-22407]`
Builds `.svc-tour`: progress `'(step+1) / TOUR_STEPS.length'` `[L22389]`; `.svc-tour-ic` (emoji); `.svc-tour-t`; `.svc-tour-d`; a row of `.svc-tour-dot` (one per step, `.on` for current `[L22394-22396]`). Footer:
- non-last: `.ca-primary` **המשך ›** → `tourNext()`; `.svc-tour-skip` **דלג** → `closeOverlayById('serviceFeatureOverlay')` `[L22398-22400]`.
- last: `.ca-primary` **סיום** → close overlay + `toast('ברוך הבא ל-BuildSmart! 🎉')` `[L22401-22404]`.
Then `svcFeature(h)`.

### `tourNext()` `[L22408-22411]`
Increments `tourStep` (clamped to last) and re-renders.

Tour CSS classes `.svc-tour*` `[L1366-1381]` (dots `7px`, active dot widens to `18px`).

---

## 7. Quick reference — the complete entry-flow graph

```
[boot]
 screen-splash ──(1.6s setTimeout)──▶ screen-welcome
 screen-welcome:
   • "כניסה ללקוח קיים"        → enterAsExisting() → applyEntryMode('existing') → screen-login
   • "המשך ללא רישום (דוגמה)"  → enterAsDemo()     → applyEntryMode('demo')     → screen-login
   • fill regName+regContact (valid) → "אישור והמשך" → finishRegistration()
        → toast → applyEntryMode('new') → screen-profession
   • hamburger "מי אתה?" → role-drawer:
        contractor → screen-login
        manager    → screen-manager (admTab m-products)
        store      → screen-store-login (renderStoreLogin)
        courier    → screen-courier (renderCourier)
        worker     → screen-worker (renderWorker)
 screen-login:
   • "המשך" / "כניסה מהירה להדגמה" → loginExisting() → (default profession 'קבלן') → enterApp()
 screen-profession:
   • pickProfession(name,icon) → set greet + userLocation='site' → enterApp()
 enterApp() → hide all ONBOARD_SCREENS → go('catalog')   [lands in the app]
```

Every `showScreen`/`go` also writes the URL hash (deep-link + browser back/forward).

---

## → Flutter port notes

- **No FAB/dial in the prototype.** R1 (exactly 5 FABs) and R2 (no full-screen "window" — every action is a multi-level dial) are a *re-architecture*. The prototype's content (its tabbar destinations + the bottom-sheet overlays) is what gets *re-homed* into dials. Concretely:
  - The prototype **tabbar** (בית · קטלוג · הפרויקטים · רכש · הגדרות) is the legacy nav; in Flutter these become entries reachable via the **menu FAB dial**, not a bottom tab bar. The existing Flutter menu FAB already mirrors this (🏠 בית / 🏗️ הפרויקטים / 🛒 רכש / ⚙️ הגדרות per project CLAUDE.md).
  - The role-drawer (`enterRole`) becomes the **BS FAB dial** personas (👷/👔/🏪/🛵/🦺). The role-drawer strings (titles + `<small>` descriptions, §1.3) are the verbatim labels for those dial leaves.
  - The **onboarding tour** (§6) maps to a dial leaf (e.g. under settings/service "מרכז השירות"), **not** a full-screen coach-mark — render each `TOUR_STEPS` entry as a dial step. Reuse the 6 verbatim steps exactly.

- **Onboarding screens are full-screen by nature** (splash, welcome, login, profession). These are pre-app gates, so R2 ("no window") arguably does not bind them the same way — but if reframed, the welcome screen's choices (existing / demo / register / "מי אתה?") would be a **dial** rather than stacked buttons. Capture the strings regardless; they are currently **absent from the Flutter app** (Flutter starts post-auth in the prototype-parity work).

- **Entry-mode (`demo`/`existing`/`new`) is load-bearing logic**, not just UI: it controls seeded vs empty `PROJECTS`, reorder history, the "הוסף אתר !" alert, and the settings demo banner. Port `applyEntryMode` as app state (Riverpod provider), with the `'new'`→`'existing'` auto-promotion on first site-name save `[L7096]`.

- **Routing:** the prototype's hash router (`#welcome`, `#login`, `#profession`, `#project/PRJ-1`, role hashes) is a deep-link contract. Flutter equivalent = a router with the same route names + the nested `project/:id` param. Keep `ONBOARD_HASH_MAP`/`SCREEN_TO_HASH` as the canonical route table. Note `screen-prep` is legacy/dead — do **not** port it as a live route.

- **Validation:** `isValidContact` (Israeli phone `^0\d{8,9}$` OR basic email) + name ≥ 2 chars gate the register confirm. Port verbatim so the ✓-per-field UX matches.

- **Verbatim-string inventory** (must appear exactly, R6): all bold strings in §1, §3 table, §4, §6, and the toasts (**נרשמת בהצלחה — ברוך הבא <name>**, **ברוך הבא — <store>**, **ברוך הבא ל-BuildSmart! 🎉**, **מעבר תפקיד** audit). Greeting template: `<icon> שלום, <name>`.
