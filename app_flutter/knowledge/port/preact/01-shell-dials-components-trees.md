# 01 — Shell, 5-FAB System, the 3 Dials, Views & Settings/Profile Trees

> **Scope.** Exhaustive map of the LIVE Preact production app's shell + dial layer that a
> Flutter port must mirror. Source root: `/home/user/buildsmart/app/src/`. Every Hebrew
> string, tree, binding and `file:line` ref below is copied/derived from the actual source
> as of this writing. The Preact app is the production realization of the prototype's dial
> pattern (R1–R9). Each section ends with how the Flutter side (`app_flutter/lib/`) compares.
>
> **The governing law (R2/R3).** No feature ever fills `<main class="content">`. Menu/search/BS
> destinations are *dial levels*, never page-swaps. The only thing that swaps `<main>` is the
> **persona** (identity), and four of the five personas render a placeholder. Keep this in mind:
> in Preact the "screen" is a dial overlay; the Flutter port has so far chosen a different shell
> shape (4 bottom-nav full screens) — see mirror notes.

---

## 0. File inventory (this domain)

| File | LOC | Role |
|---|---|---|
| `app/src/main.tsx` | 16 | mount + CSS/font imports + `registerSW` |
| `app/src/app.tsx` | 51 | shell, `ActiveView`, R2 enforcement |
| `app/src/components/floating-header.tsx` | 35 | BS logo button + persona name + cart |
| `app/src/components/fabs.tsx` | 43 | menu FAB + search FAB |
| `app/src/components/bs/bs-dial.tsx` | 361 | BS dial — 5 personas + section trees |
| `app/src/components/menu-speed-dial.tsx` | 297 | menu dial — 4 tabs + `SettingsLevel` |
| `app/src/components/menu/submenu-settings.tsx` | 1461 | **the big one** — settings/profile trees, bindings, LeafEditor, home/cart/projects dials |
| `app/src/components/search/search-panel.tsx` | 88 | search overlay shell |
| `app/src/components/search/tools-dial.tsx` | 99 | the 5-tool rail (`ToolsRail`) |
| `app/src/components/search/submenu-voice.tsx` | 93 | voice tool (real Web Speech) |
| `app/src/components/search/submenu-barcode.tsx` | 71 | barcode tool (real camera) |
| `app/src/components/search/submenu-filters.tsx` | 54 | 2 filter toggles |
| `app/src/components/search/submenu-sort.tsx` | 79 | 5 sort options |
| `app/src/components/search/submenu-catalog.tsx` | 41 | 11 catalog categories |
| `app/src/components/search/results-list.tsx` | 124 | live results / recent / fuzzy hint |
| `app/src/components/search/scope-chips.tsx` | 28 | 4 scope chips |
| `app/src/components/regression/regression-panel.tsx` | 135 | manager-view test runner UI |
| `app/src/components/category-circles.tsx` | 72 | home category drill bubbles |
| `app/src/components/product-grid.tsx` / `product-card.tsx` / `product-sheet.tsx` | 23/97/102 | home product grid + cart steppers |
| `app/src/components/toast.tsx` | 11 | toast renderer |
| `app/src/views/{home,manager,store,courier,worker}.tsx` | 11/16/303/12/12 | persona views |
| `app/src/store/app-store.ts` | 220 | overlays, menu/settings drill signals, cart, category drill |
| `app/src/store/bs-store.ts` | 83 | persona + BS drill signals |
| `app/src/store/app-settings.ts` | 221 | persisted preferences + DOM effect |
| `app/src/store/user-profile.ts` | 51 | 5 profile fields (R9) |
| `app/src/store/search-store.ts` | 103 | query/scope/sort/filters/recent + computed results |
| `app/src/store/toast-store.ts` | 14 | single toast signal |
| `app/src/store/regression-store.ts` | 30 | test status/results + summaries |
| `app/src/lib/search.ts` | 90 | `searchExact` + `searchFuzzy` (Levenshtein) |
| `app/src/data/{identity,projects,search-index}.ts` | 78/16/104 | ranks/achievements, 3 projects, search index |

---

## 1. Mount & shell

### `main.tsx`
- `registerSW({ immediate: true })` (PWA), imports `tokens.css` + `global.css`, Heebo (400/700/900) + Rubik (400/500/700) fonts. Renders `<App/>` into `#app` (`main.tsx:13-16`).

### `app.tsx` — the shell & R2 enforcement
```
<div class="screen">
  <div class="screen__bg" aria-hidden />
  <FloatingHeader/>
  <main class="content"><ActiveView/></main>   ← ONLY persona swaps this
  <Fabs/>                ← menu FAB + search FAB
  <MenuSpeedDial/>       ← menu dial overlay (conditionally rendered)
  <SearchPanel/>         ← search overlay (conditionally rendered)
  <BsDial/>              ← BS dial overlay (conditionally rendered)
  <ProductSheet/>        ← product bottom-sheet (conditionally rendered)
  <Toast/>
</div>
```
`ActiveView()` (`app.tsx:19-33`) is a pure switch on `activePersona.value`:

| `activePersona` | View | Renders |
|---|---|---|
| `manager` | `ManagerView` | regression panel |
| `store` | `StoreView` | a full WhatsApp-style store screen |
| `courier` | `CourierView` | placeholder |
| `worker` | `WorkerView` | placeholder |
| `contractor` / default | `HomeView` | category circles + product grid |

The R2 doctrine is enforced by *construction*: there is no router, no view stack. Dials are
sibling overlays that early-return `null` when closed. **View routing is purely persona-driven.**

---

## 2. The 5-FAB system

R1 mandates exactly 5 FABs: **BS · search · BS-mode · menu · BS**. In this Preact codebase they
are realized across two components:

### `floating-header.tsx` — the "BS" logo button (top)
- `<button class="float float--logo">` text `BS`, `aria-label="בחירת משתמש"`, `onClick={toggleBs}`,
  gets `is-open` while `bsOpen` (`floating-header.tsx:10-18`). This is the dial-opener for the BS tray.
- `<div class="float float--name" role="status" aria-live="polite">{personaName.value}</div>` — live
  persona label (`:20-22`).
- `<button class="float float--cart" aria-label="עגלת רכש">` — cart icon (SVG), with
  `{count > 0 && <span class="float__badge">{count}</span>}` from `cartCount` (`:24-32`). **Cart button has
  no onClick** — display-only badge.

### `fabs.tsx` — menu FAB + search FAB (bottom)
- **Menu FAB** `class="fab fab--menu"` (`fabs.tsx:8-27`): `onClick={toggleMenu}`,
  `aria-label` toggles `'סגור תפריט'`/`'פתח תפריט'`. Icon is a hamburger; while `menuOpen` it becomes an X.
- **Search FAB** `class="fab fab--search"` (`:29-40`): `onClick={toggleSearch}`,
  `aria-label` toggles `'סגור חיפוש'`/`'חיפוש'`. Magnifier icon; gets `is-search-open` while open.

> The other two of the "5 FABs" (BS-mode + the second BS) are realized through CSS/layout around the
> same logo/menu/search trio in the production build (the legacy 5-FAB row). For the port, the
> *interactive openers* are exactly: BS-logo (`toggleBs`), menu (`toggleMenu`), search (`toggleSearch`).

### → Flutter mirror notes (FABs & shell)
- **Shell shape DIVERGES.** `app_flutter/lib/screens/home_shell.dart:26-50` is a `Scaffold` with an
  AppBar + **4-tab bottom IndexedStack** of full screens: **קטלוג · שיחות · התראות · חנות** (`mainTabProvider`,
  `dial_state.dart:34`). This is a WhatsApp-style chrome, **not** the Preact persona-driven single
  `<main>` + overlay model. Preact has no bottom nav and no persistent tabs; its "tabs" live inside the
  menu dial.
- Dial open-state in Flutter is a single enum `OpenDial { none, bs, search, bsMode, menu }`
  (`dial_state.dart:5`) with a full-screen scrim (`home_shell.dart:53-60`) — good single-tray
  invariant (matches R1 "never two trays"). Preact instead has independent `menuOpen`/`searchOpen`/`bsOpen`
  booleans (they *can* technically coexist).
- Flutter positions BS dial at `right/bottom` (RTL leading) and search dial centered (`home_shell.dart:62-72`).
- `personaName`/cart-badge header equivalent exists in Flutter's `_HomeAppBar` (not audited in depth here).

---

## 3. BS dial — `components/bs/bs-dial.tsx`

Opened by the BS logo button. Early-returns `null` unless `bsOpen.value` (`bs-dial.tsx:264`).

### 3.1 Signals (`store/bs-store.ts`)
| Signal | Type | Meaning |
|---|---|---|
| `activePersona` | `signal<Persona>` | the user's *chosen identity* (persisted `bs.persona.v1`); drives `ActiveView` |
| `bsOpen` | `signal<boolean>` | dial open/closed |
| `bsDrillPersona` | `signal<Persona\|null>` | which persona's sub-tree the dial is *browsing* (null = L1 tiles) |
| `bsDrillPath` | `signal<string[]>` | drill depth within that persona's section tree (by `title`) |

`Persona = 'contractor'|'manager'|'store'|'courier'|'worker'` (`bs-store.ts:5`).
`PERSONA_NAMES` (`:32-38`): contractor `שלמה הקבלן`, manager `מנהל המערכת`, store `חנות הסניטריה`,
courier `שליח · משאית 14`, worker `יוסי העובד`. `personaName` is `computed` over `activePersona`.

Functions: `toggleBs` (`:56`, resets drill on close), `closeBs` (`:63`), `drillIntoPersona(p)` (`:68`,
sets `bsDrillPersona`, **does NOT change `activePersona`**), `popBsDrill` (`:72`), `pushBsDrill(label)`
(`:76`), `popBsDrillPathTo(depth)` (`:79`).

> **Critical distinction:** in Preact, *browsing* a persona's dial (`drillIntoPersona`) is decoupled
> from *being* that persona (`setPersona`/`activePersona`). The L1 tile shows `is-active` for the current
> identity but tapping it only drills.

### 3.2 L1 — the 5 persona tiles (`TILES`, `bs-dial.tsx:18-24`)
`@legacy index.html:4088-4113` (role-drawer "מי אתה?"). `aria-label="בחירת משתמש"`.

| id | emoji | label (verbatim) |
|---|---|---|
| `contractor` | 👷 | קבלן |
| `manager` | 👔 | מנהל המערכת |
| `store` | 🏪 | חנות ספק |
| `courier` | 🛵 | שליח |
| `worker` | 🦺 | עובד |

Each tile: `bsdial__btn` (+ `is-active` if `t.id===activePersona`), `onClick={() => drillIntoPersona(t.id)}`,
circle = emoji, label = `t.label`, staggered `animationDelay: i*30ms` (`:272-290`).

### 3.3 `Section` type & `PERSONA_SECTIONS`
`type Section = { id; emoji; title; children?: Section[] }` (`:27-32`). A `Section` is a branch if it
has non-empty `children`, else a leaf. `PERSONA_SECTIONS: Partial<Record<Persona, Section[]>>` (`:238-243`)
maps `store`/`courier`/`worker`/`manager`. **`contractor` has no sub-sections** → drilling shows only the
back anchor.

### 3.4 `walkBsDrill(persona, path)` (`:248-261`)
Walks `PERSONA_SECTIONS[persona]` following `path` labels. For each label finds `s.title===label`; if
missing OR no children → stop. Returns `{ anchors: Section[], current: Section[] }`. Anchors = one per
drill step; `current` = items at the deepest reached level.

### 3.5 Render L2+ (`:295-360`)
Renders, bottom→top (the dial `<ul>` is `column-reverse`):
1. persona anchor (`is-active`, `onClick=popBsDrill`, `aria-label="חזרה מ-{label}"`),
2. one anchor per `anchors[i]` (`onClick=() => popBsDrillPathTo(i)`),
3. each `current` item: if `hasChildren` → `pushBsDrill(s.title)`, else → `showToast('${s.title} — בבנייה')`.

### 3.6 The four persona section trees — VERBATIM

**STORE** (`STORE_SECTIONS`, `:44-93`; `@legacy :4260-4263`, store home `:17128-17132`, portal `:20762-20769`):
```
🏠 בית
  🔧 בהכנה · 📦 מוכן לאיסוף · 💰 מחזור פעיל
📥 הזמנות           (@legacy soChip :17310-17313)
  📥 לאישור · 🔧 בהכנה · 📦 מוכנות
📦 מלאי             (@legacy md-pmeta :17914)
  ✅ זמין במלאי · ❌ אזל
🧰 פורטל            (@legacy renderStorePortal :20762-20769)
  ⭐ דירוג ספקים · ⏱️ מעקב SLA · 🗺️ אזורי הפצה · 📉 הנחות כמות
  🏷️ הפקת ברקודים · 🚛 ניהול צי רכב · 💬 צ׳אט עם קבלן · 🔄 עדכון מלאי
```

**COURIER** (`COURIER_SECTIONS`, `:105-142`; `@legacy renderCourierHome :17991-18043`):
```
🛵 הרכב שלי היום    (HAUL_TYPES :11951-11953)
  🛵 משלוח קטן · 🚐 טנדר · 🚛 משאית
📦 משלוחים ממתינים לאיסוף   (leaf — no children)
🚚 משלוחים פעילים   (ch-btn labels :18112-18114)
  📦 אספתי מהחנות · 🚚 יצאתי לדרך · ✅ נמסר ללקוח
🧰 פורטל השליח       (openCourierPortal :20787-20792)
  🧭 ניווט למשלוח · 🚛 צי רכב · ⏱️ מעקב SLA · 🗺️ אזורי הפצה · 📸 אישור מסירה · 💬 צ׳אט עם חנות
```

**WORKER** (`WORKER_SECTIONS`, `:151-161`; `@legacy renderWorker :8099-8102`, `taskStatusInfo :8048-8054`).
Status leaves are shared consts `ST_PENDING/ST_ACTIVE/ST_REVIEW/ST_DONE/ST_REJECTED`:
```
🔨 המשימה הנוכחית שלך   → [🔨 בביצוע, ↩️ נדחה — לתקן]
⏳ הבאות בתור            → [⏳ ממתינה]
📋 שהגשת                 → [📸 ממתין לאישור, ✅ אושר ✓]
```

**MANAGER** (`MANAGER_SECTIONS`, `:177-235`; `@legacy admTab :4213-4216`, metrics `:12160-12164`,
order flow `:16943`/`:12041-12048`, manage `:16653-16745`, customers `:16608`/`:16617`):
```
📊 לוח בקרה
  🚚 הזמנות פתוחות · 📦 מוצרים בקטלוג · 🧰 אביזרים נלווים · ✅ זמינים כעת · 🏪 חנויות פעילות
🚚 הזמנות
  📥 התקבלה · 🔧 בהכנה · 📦 מוכן לאיסוף · 🚛 נאסף · 🚚 בדרך לאתר · ✅ נמסר ✓
👥 לקוחות
  🟢 פעיל · ⚠️ אשראי גבוה
🛠️ ניהול
  🌳 עץ המוצרים · 🏷️ מותגים ומחירים · 🗂️ קטגוריות · ⚙️ הגדרות אפליקציה
```

### → Flutter mirror notes (BS dial)
- **Near-verbatim mirror.** `app_flutter/lib/data/sections.dart` ports `Section`, `kStoreSections`,
  `kCourierSections`, `kWorkerSections`, `kManagerSections`, `kPersonaSections`, and `walkBsDrill` with
  identical ids/emoji/Hebrew. `kPersonas` (`data/personas.dart`) matches `TILES` exactly.
- **Two divergences:**
  1. Flutter adds a 5th manager leaf `🔬 בדיקות רגרסיה` (`id: 'mm-regression'`, `sections.dart` manage block)
     which the BS dial routes to `RegressionPanelScreen` (`bs_dial_widget.dart:73-76`). Preact has no such
     leaf; regression lives in `ManagerView` instead.
  2. **Identity vs browse conflation.** `bs_dial_widget.dart:26-30` taps an L1 tile by setting
     `activePersonaProvider` (the drill state) directly — there is no separate "chosen identity". Preact
     keeps `activePersona` (identity) and `bsDrillPersona` (browse) separate; the Flutter `activePersonaProvider`
     plays the role of Preact's `bsDrillPersona` only, and Flutter's bottom-nav shell means there is no
     persona-driven `ActiveView` at all.
- Flutter `DialRow` passes `icon: Icons.circle` as a fallback but shows the emoji — visually fine; the L1
  `is-active` identity highlight that Preact shows is **absent** (no current-identity concept).

---

## 4. Menu dial — `components/menu-speed-dial.tsx` (4 tabs)

Opened by the menu FAB. Early-returns `null` unless `menuOpen.value` (`menu-speed-dial.tsx:97`).
`@legacy index.html:5383-5403` (bottom tabbar — originally 5 tabs: בית/קטלוג/הפרויקטים/רכש/הגדרות).
**קטלוג was moved to the search FAB**, leaving 4 menu tabs.

### 4.1 `TABS` (`:43-83`) — SVG icons, all dials
| id | label | dial component |
|---|---|---|
| `home` | בית | `HomeSubmenu` |
| `projects` | הפרויקטים | `ProjectsSubmenu` |
| `cart` | רכש | `CartSubmenu` |
| `settings` | הגדרות | `SettingsLevel` (→ `SettingsTop/Profile/Settings*`) |

`TAB_HAS_SUBMENU` is all-true (`:89-94`). Backdrop `dial__backdrop` (`aria-label="סגור תפריט"`,
`onClick=closeMenu`). At root all 4 tabs render (staggered `i*28ms`). On tab tap → `setMenuTab(id)`.
When a tab is active: render its anchor (`onClick=() => setMenuTab(null)`, `aria-label="חזרה מ-{label}"`)
then the tab's submenu (`:141-161`).

### 4.2 Menu/settings drill signals (`store/app-store.ts`)
- Overlays: `menuOpen`/`searchOpen`/`openedProductId` (`:78-80`).
- `menuActiveTab: signal<MenuTab|null>` where `MenuTab='home'|'projects'|'cart'|'settings'` (`:84-85`).
- `settingsLevel: signal<'top'|'profile'|'advanced'>` (`:17`), `profilePath: signal<string[]>` (`:18`).
- `menuActiveSettingsGroup: signal<SettingsGroupId|null>` (`:98`) — 9 ids `account|notifications|display|
  accessibility|security|support|delivery|region|about` (note: **no `reset`** — reset is an action).
- `menuActiveSettingsPath: signal<string[]>` (`:104`) — drill within a group, keyed by label.
- `editingLeafKey: signal<string|null>` (`:109`) — the leaf currently in R9 inline-edit.
- Mutators: `setMenuTab` (`:111`, resets edit+settings sublevel), `setSettingsGroup` (`:122`),
  `pushSettingsPath`/`popSettingsPathTo` (`:128`/`:133`), `startEditingLeaf`/`stopEditingLeaf` (`:140`/`:143`),
  `toggleMenu`/`closeMenu` (`:147`/`:158`) both fully reset drill/edit state.
- `setSettingsLevel`/`enterAdvancedSettings`/`exitAdvancedSettings`/`enterProfile`/`exitProfile`/
  `pushProfilePath`/`popProfilePathTo` (`:20-43`).

### 4.3 `SettingsLevel()` (`menu-speed-dial.tsx:179-297`) — the 3-level settings router
- `level==='top'` → `<SettingsTopSubmenu/>` (the 2 branches).
- `level==='profile'` → profile anchor `הגדרות-פרופיל` (icon `PROFILE_TOP_ICON`, `onClick=exitProfile`)
  + one anchor per `profilePath` (`onClick=() => popProfilePathTo(i)`, icon via `profileAnchorIcon`)
  + `<ProfileTreeSubmenu/>`.
- `level==='advanced'`:
  - no group → anchor `הגדרות מתקדמות` (icon `ADVANCED_TOP_ICON`, `onClick=exitAdvancedSettings`) + `<SettingsSubmenu/>` (10 rows).
  - group set → `הגדרות מתקדמות` anchor + group anchor (`groupDef.icon`, `onClick=() => setSettingsGroup(null)`)
    + one anchor per `walkSettings` step (`onClick=() => popSettingsPathTo(i)`) + `<SettingsTreeSubmenu group nodes pathPrefix/>`.

---

## 5. THE BIG ONE — `components/menu/submenu-settings.tsx` (1461 LOC)

### 5.1 `SETTINGS_ROWS` (`:66-166`) — 10 group rows (SVG icons)
Reading order preserved from `@legacy renderSettings :6806`; **`reset` is last** and styled
`dial__item--danger`.

| id | label (verbatim) |
|---|---|
| `account` | חשבון |
| `notifications` | התראות |
| `display` | תצוגה |
| `accessibility` | נגישות |
| `security` | אבטחה והרשאות |
| `support` | שירות ותמיכה |
| `delivery` | משלוח ותשלום |
| `region` | אזור ושפה |
| `about` | מידע |
| `reset` | איפוס לברירת מחדל |

`SettingsSubmenu()` (`:343-376`) renders `[...SETTINGS_ROWS].reverse()` (column-reverse). Tap `reset` →
`resetSettings(); closeMenu()`. Tap any other → `setSettingsGroup(id)`.

### 5.2 `SETTINGS_SUB` — the full tree to depth 4 (`:185-322`), VERBATIM
`type Node = { label; children? }`. Sources: L2 `renderSettings :6817-6875`; L3 `SETTINGS_LABELS :6750-6757`,
`openSecurityHub :21752-21762`, `openServiceHub :22081-22090`; L4 `secRBAC :21812-21813`, `secSession :21922`,
`secEncryption :21952-21957`, `secPrivacy :22018-22023`, `svcQtyCalc :22289-22293`, `svcOnboarding :22374-22381`.

```
account:        שם הקבלן · טלפון · סוג עוסק · תחום מקצועי
notifications:  עדכוני משלוחים · מבצעים והטבות · התראות תקציב · עדכוני הזמנות
display:
  ערכת נושא → [בהיר, כהה]
  גודל טקסט → [קטן, בינוני, גדול]
  הפחתת אנימציות
accessibility:  מצב ניגודיות גבוהה (לשמש)
security:
  מרכז האבטחה →
    אימות דו-שלבי
    הרשאות גישה → [קבלן, מנהל מערכת, ספק / חנות, שליח, עובד]
    כניסה ביומטרית
    יומן ביקורת
    הרשאת מיקום
    נעילת הפעלה → [5 דק׳, 15 דק׳, 30 דק׳, 60 דק׳]
    הצפנת נתונים → [תקשורת מוצפנת (HTTPS/TLS), נתונים מקומיים מוגנים,
                     סיסמאות מאוחסנות כ-Hash, גיבוי מוצפן בענן]
    היסטוריית כניסות
    ניהול מכשירים
    בקרת פרטיות → [שיתוף נתוני שימוש, שירותי מיקום, התאמת תוכן שיווקי, שליחת דוחות תקלה]
support:
  מרכז השירות →
    מוקד תמיכה · צ׳אטבוט · דיווח על באג · המרת מידות
    מחשבון כמויות → [אריחים, צבע, בטון]
    סנכרון יומן · לוח דרושים
    סיור היכרות → [מסך הבית, הזמנה, תקציב, משימות ואתר, מועדון BuildSmart, מוכנים!]
delivery:
  סוג הובלה מועדף → [משלוח קטן, טנדר, משאית]
  ברירת מחדל — משלוח אקספרס
  אמצעי תשלום
region:
  שפה → [עברית, العربية, English]
  יחידות מידה → [מטרי (מ׳, ק״ג), אימפריאלי]
  מטבע → [₪ שקל, $ דולר]
about:          גרסה · תנאי שימוש · מדיניות פרטיות · יצירת קשר
```
`walkSettings(group, path)` (`:328-341`) mirrors `walkBsDrill`: anchors + current, stops on missing/childless.

### 5.3 `SettingsTreeSubmenu` (`:698-761`) — unified depth-N renderer
Renders `[...nodes].reverse()`. `leafKey(group, path, label) = [group, ...path, label].join('>')` (`:686`).
Tap logic (`handleClick`, `:711-726`):
1. has children → `pushSettingsPath(node.label)`.
2. binding with `.input` → `startEditingLeaf(key)` (R9 inline edit).
3. binding (no input) → `binding.action()` (menu stays open so user sees effect).
4. no binding → `closeMenu()` (legacy fallback).
Active bindings add `dial__item--leaf-on` + `dial__circle--on`; the circle always shows the **group's** icon.

### 5.4 `LEAF_BINDINGS` (`:416-684`) — the ~60 bound leaves
Key = `'group>...>label'`. Each `Binding = { action; isActive?; input? }`. Below: every bound key, what it
mutates (all settings setters live in `store/app-settings.ts`; profile in `store/user-profile.ts`).

**account — R9 inline text edit** via `profileBinding(key, rowLabel, toastLabel)` (`:399-414`). Renders an
`<input>`; on save calls `setProfileField` + toast `'{toastLabel} עודכן'`. `isActive` = field non-empty.

| key | mutates | toast label |
|---|---|---|
| `account>שם הקבלן` | `userProfile.name` | שם הקבלן |
| `account>טלפון` | `userProfile.phone` | מספר טלפון *(differs from row label 'טלפון')* |
| `account>סוג עוסק` | `userProfile.business` | סוג עוסק |
| `account>תחום מקצועי` | `userProfile.trade` | תחום מקצועי |
| `delivery>אמצעי תשלום` | `userProfile.payment` | אמצעי תשלום |

**display** → `setTheme` / `setTextSize` / `toggleReduceMotion`:
`display>ערכת נושא>בהיר`→`light`, `…>כהה`→`dark`; `display>גודל טקסט>קטן|בינוני|גדול`→`small|medium|large`;
`display>הפחתת אנימציות`→`reduceMotion`.

**notifications** → `toggleNotif(key)`: `עדכוני משלוחים`→`shipments`, `מבצעים והטבות`→`deals`,
`התראות תקציב`→`budget`, `עדכוני הזמנות`→`orders`.

**accessibility** → `accessibility>מצב ניגודיות גבוהה (לשמש)`→`toggleHighContrast`.

**region** → `setLang`/`setUnits`/`setCurrency`: `שפה>עברית|العربية|English`→`he|ar|en`;
`יחידות מידה>מטרי (מ׳, ק״ג)|אימפריאלי`→`metric|imperial`; `מטבע>₪ שקל|$ דולר`→`ils|usd`.

**delivery** → `setDefaultHaul`/`toggleExpress`: `סוג הובלה מועדף>משלוח קטן|טנדר|משאית`→`small|van|truck`;
`ברירת מחדל — משלוח אקספרס`→`express`. (`אמצעי תשלום` is R9 input, listed above.)

**security>מרכז האבטחה** (`:524-616`):
- toggles: `אימות דו-שלבי`→`toggleTwoFA`, `כניסה ביומטרית`→`toggleBiometric`, `הרשאת מיקום`→`toggleLocationPerm`.
- info toasts (no mutation): `יומן ביקורת`, `היסטוריית כניסות`, `ניהול מכשירים`.
- `נעילת הפעלה>5|15|30|60 דק׳`→`setSessionTimeout(5|15|30|60)`.
- `הרשאות גישה>קבלן|מנהל מערכת|ספק / חנות|שליח|עובד` → 5 RBAC info toasts (verbatim role-capability strings, `:570-584`).
- `הצפנת נתונים>…` → 4 encryption-status toasts (`:587-598`).
- `בקרת פרטיות>שיתוף נתוני שימוש|שירותי מיקום|התאמת תוכן שיווקי|שליחת דוחות תקלה` → `toggleSecPrivacy('analytics'|'location'|'marketing'|'crashReports')`.

**support>מרכז השירות** (`:618-669`): all info toasts (no state) — `מוקד תמיכה`, `צ׳אטבוט`, `דיווח על באג`,
`המרת מידות`, `סנכרון יומן`, `לוח דרושים`; `מחשבון כמויות>אריחים|צבע|בטון` (3 toasts);
`סיור היכרות>{מסך הבית, הזמנה, תקציב, משימות ואתר, מועדון BuildSmart, מוכנים!}` (6 tour-step toasts, verbatim).

**about** (`:671-683`): info toasts — `גרסה`→`'BuildSmart 1.0 · אב-טיפוס'`, `תנאי שימוש`, `מדיניות פרטיות`,
`יצירת קשר`→`'תמיכה — support@buildsmart.demo'`.

> Tally: 5 R9 inline-edit leaves + ~55 action leaves (toggles/selects/info-toasts) ≈ **60 bound leaves**.

### 5.5 `LeafEditor` (R9 inline input) (`:769-808`)
Replaces the leaf button with `<div class="dial__btn"><span circle/><input class="dial__input"/></div>`.
`autoFocus`, `defaultValue=input.get()`, `placeholder=input.label`, `dir="auto"`. Enter or blur → `commit()`
(trims, only writes if changed, then `stopEditingLeaf`). Esc sets a `cancelled` guard then `stopEditingLeaf`
(the guard prevents the unmount-blur from saving). **R9 = inline input row glued to the leaf — never a
prompt/sheet/modal.**

### 5.6 `app-settings.ts` — the persisted preference store
`AppSettings` shape (`:19-45`): `display{theme,textSize,reduceMotion}`, `notif{shipments,deals,budget,orders}`,
`region{lang,units,currency}`, `delivery{defaultHaul,express}`, `accessibility{highContrast}`,
`security{twoFA,biometric,locationPerm,sessionTimeout,privacy{analytics,location,marketing,crashReports}}`.
`DEFAULTS` (`:47-61`): light / medium / no-motion; all notif on; he/metric/ils; small haul / no express;
no high-contrast; security all-off except `sessionTimeout:15`, privacy analytics+location+crashReports on,
marketing off. Persisted to `bs.settings.v1`; `load()` validates each field (`pick<T>()`). An `effect()`
(`:202-221`) mirrors settings → `<html data-theme|data-text-size|data-reduce-motion|data-lang|data-units|
data-currency|data-haul|data-express|data-contrast>` and writes localStorage. `resetSettings()` (`:198`)
restores `DEFAULTS`.

### 5.7 `user-profile.ts` — R9 identity fields
`ProfileKey = 'name'|'phone'|'business'|'trade'|'payment'`, all `''` default; persisted `bs.profile.v1`
(`:6-37`). `setProfileField` trims; an `effect` persists (`:43-51`).

### 5.8 `PROFILE_TREE` (`:846-896`) — the profile branch, VERBATIM
Labels verbatim from `@legacy refreshIdentity :6545-6680` (except the grouping label `הגדרות-פרופיל`,
user-authored, `:817`). Two L2 branches:
```
כרטיס קבלן (ICON_CARD)
  אתה במצב הדגמה
  המספרים שלך → [הזמנות, אתרים פעילים, עצי מוצרים, אביזרים שהעץ הציל]
  סך הרכש דרך BuildSmart
דרגות הקבלן (ICON_RANKS)
  ההטבה שלך
  הישגים → [הזמנה ראשונה, 10 הזמנות, ריבוי אתרים, חובב עץ מוצרים, לא שוכח כלום, מחזור ₪10K]
  מועדון BuildSmart → [אתגרים חודשיים, לוח מובילים, תגי ירוק, קופונים לפי מיקום,
                        הזמן חבר, מועדון VIP, מימוש הטבות]   (@legacy openRewardsHub :21464-21471)
```

**`PROFILE_LEAF_ICONS`** (`:900-919`) — emoji per leaf (the stats + achievements + rewards leaves):
`המספרים שלך`: 📦🏗️🌳🧠; `הישגים`: 🚀📦🏗️🌳🧠💰; `מועדון BuildSmart`: 🎯🏆🌿📍👥💎🎁.

**`PROFILE_LEAVES`** (`:936-977`) — per-leaf behaviors, all toasts with *live data* from `identityStats()`:
- `כרטיס קבלן>אתה במצב הדגמה` → demo-mode toast.
- `המספרים שלך>{הזמנות|אתרים פעילים|עצי מוצרים|אביזרים שהעץ הציל}` → toast with `identityStats().{orders|sites|trees|autoSaved}`.
- `כרטיס קבלן>סך הרכש דרך BuildSmart` → `formatIls(identityStats().spent)`.
- `דרגות הקבלן>ההטבה שלך` → composes current rank perk + distance to next rank (`currentRank`/`nextRank`).
- `הישגים>…` (6 leaves) → `achToast(idx)` (shows ✓/🔒 + desc) with `isActive` = achievement unlocked.
- `דרגות הקבלן>מועדון BuildSmart` (the branch itself also has a toast at `:973`).

**`ProfileTreeSubmenu`** (`:1030-1090`): `walkProfile` (`:1013`), reversed render; circle icon priority =
leaf emoji → top-level branch icon (`PROFILE_BRANCH_ICON`) → ancestor branch icon. Branch tap →
`pushProfilePath`; leaf with binding → `binding.action()`; else → `'{label} — בבנייה'` toast.

### 5.9 `identity.ts` — ranks, stats, achievements (`data/identity.ts`)
`RANKS` (`:15-20`): 🔰 קבלן חדש (min 0) · 🔨 קבלן קבוע (3) · ⭐ קבלן מועדף (8) · 💎 קבלן פלטינום (15), each
with `perk` string. `identityStats()` (demo) = `{orders:0, sites:PROJECTS.length(=3), trees:0, spent:0,
autoSaved:0}`. `identityAchievements(s)` (`:64-73`): 6 achievements (🚀/📦/🏗️/🌳/🧠/💰) with `on` thresholds
(orders≥1, ≥10; sites≥3; trees≥5; autoSaved≥25; spent≥10000) → only "ריבוי אתרים" is unlocked in demo.
`formatIls(n)='₪'+round(n).toLocaleString('he-IL')`.

### 5.10 `SettingsTopSubmenu` (`:981-1009`)
2 rows (reversed so advanced sits below profile in the stack): `הגדרות מתקדמות` (`ICON_ADVANCED`,
`enterAdvancedSettings`) · `הגדרות-פרופיל` (`ICON_PROFILE`, `enterProfile`).

### 5.11 Home / Cart / Projects dials (same file)
These use *local* `@preact/signals` drill signals (`homeDrillPath`/`cartDrillPath`/`projectsDrillPath`),
not app-store signals. Pattern is identical: `walkX` → reversed render, branch tap pushes path, leaf →
`'{title} — בבנייה'` toast.

**HOME** (`HOME_LEAVES`, `:1105-1168`; `@legacy view-home :4416-4517`):
```
🤖 בינה מלאכותית ואוטומציה  (openAIHub :21125-21133)
  📦 חיזוי מלאי · 📷 סורק ברקוד · 🎙️ דיבור למשימה · 💡 חלופות זולות · 📐 סריקת תוכניות
  🔗 התאמה משולשת · 🌦️ אוטומציית מזג אוויר · 🔧 זיהוי בלאי · 📊 Analytics חכם
📐 סרוק תוכנית עבודה  (PLAN_TYPES :9659-9728)
  🚿 אינסטלציה · ⚡ חשמל · 🏛️ אדריכלות · 🎨 גמר
📦 המלאי שלי  (view-stock :5183-5184)
  🏬 המחסן · 🏗️ האתר
📋 משימות העבודה  (openSiteHub :19858-19868)
  📅 תרשים גאנט · 🔧 רשימת ליקויים · 🏢 קומה · דירה · חדר · 📍 נוכחות GPS · 📓 יומן עבודה
  🦺 התראות בטיחות · 🔗 תלויות חומרים · 📸 צילום לפני/אחרי · 🔍 ביקורות מפקח · 🗄️ ארכיון פרויקטים
```

**CART** (`CART_TOP`, `:1256-1270`; `@legacy :5060-5104` + ca-svc `:5074-5081`):
```
🛒 הסל שלי   (leaf)
📦 ההזמנות שלי →
  🔧 השכרת כלים · 💰 פקדונות · ↩️ החזרה חדשה · 📨 מכרז ספקים · 🧪 גיליונות בטיחות · 📊 השוואת מחירים
```

**PROJECTS** (`projectItems()`, `:1377-1387`): 3 project names from `PROJECTS` (`data/projects.ts`:
`PRJ-1 מגדל הרצליה — קומה 4`, `PRJ-2 וילה כפר שמריהו`, `PRJ-3 שיפוץ משרדים — רעננה`), each 🏗️, plus a
`📊 מרכז פיננסים` branch → **`FINANCE_HUB`** (`:1362-1373`; `@legacy openFinanceHub :19489-19498`):
```
📈 הצמדה למדד · 🗓️ תנאי תשלום · 👷 קבלני משנה · ✅ אישורי רכש · 🔔 התראות חריגה
📊 ניתוח ROI · 🧾 פיצול חשבוניות · ⏰ פיצויים וקנסות · 📄 דוחות PDF · 💱 רכש במט״ח
```
(Project leaves use `PROJECT_ICON` SVG unless emoji differs / has children — `usesEmoji` logic `:1430`.)

### → Flutter mirror notes (menu dial + settings/profile)
- **Menu tabs DIVERGE in role.** Flutter keeps `MenuTab { home, projects, cart, settings }`
  (`dial_state.dart:18`) and drill signals (`menu_state.dart`: `homeDrill/projectsDrill/cartDrill/
  settingsGroup/settingsDrill`). `menu_dial_widget.dart` renders the 4-tab dial. But the *primary* nav
  in Flutter is the bottom bar (catalog/chats/notifs/store), so the menu dial is a secondary surface, not
  the app's main spine as in Preact.
- **Home/Cart/Projects/Finance trees: verbatim mirror** in `data/menu_trees.dart` (`kHomeTree`, `kCartTree`,
  `kFinanceHub`, `projectsTree()`) — ids/emoji/Hebrew all match `submenu-settings.tsx`.
- **`SETTINGS_SUB`: mirrored AND extended.** `data/settings_tree.dart` has `SettingsGroup`/`SettingsNode`
  with **12 groups / 83 nodes** vs Preact's **10 groups**. The 9 drillable groups + `reset` match; Flutter
  adds 2 extra groups (likely the chat/store/catalog settings the bottom-nav shell needs) — **port must
  reconcile which groups are canonical**.
- **`LEAF_BINDINGS` model DIVERGES.** Preact keys bindings by full path (`'group>…>label'`) with explicit
  `action`/`isActive`/`input`. Flutter `menu_dial_widget.dart` resolves leaf behavior by **bare label** via
  `_applyLeaf(ref, context, label)` + `_isOn(ref, label)` (`:316-330`). Label-keyed lookup is collision-prone
  (e.g. `בהכנה`, `📦 מוכן לאיסוף` recur across trees) — a known risk the path-keyed Preact design avoids.
- **`PROFILE_TREE` is MISSING in Flutter.** No `כרטיס קבלן`/`דרגות הקבלן`/`מועדון BuildSmart` branch, no
  `identityStats`/`RANKS`/`identityAchievements`, no `PROFILE_LEAVES`/`PROFILE_LEAF_ICONS`. The 3-level
  settings router (`top → profile|advanced`) is **absent**; Flutter's settings dial goes straight to the
  group list. The profile/rewards/identity surface (see sibling `profile-rewards.md`) is unported here.
- **R9 LeafEditor is MISSING.** No inline `TextField` row; Flutter settings has no `account` text-edit
  equivalent (`_applyLeaf` only handles toggles/selects). `user-profile.ts`'s 5 fields have no Flutter mirror.
- `app_flutter/lib/state/app_settings.dart` exists (preferences); audit it against `AppSettings` shape for
  parity (theme/textSize/notif/region/delivery/accessibility/security.privacy) — names likely differ.

---

## 6. Search FAB — `components/search/*`

Opened by the search FAB. `SearchPanel` early-returns `null` unless `searchOpen.value` (`search-panel.tsx:14`).

### 6.1 `SearchPanel` layout (`search-panel.tsx:34-86`)
Backdrop (`spanel__backdrop`, `onClick=handleClose`→`resetSearch()+closeSearch()`); `spanel__stage`
(results, shown only when no tool active); `spanel__rail` (the active tool's submenu + always the
`<ToolsRail/>`); `<ScopeChips/>` (only when no tool); `sinput` (search field). On mount: clears query +
tool, focuses input after 60ms (`:22-27`). Field placeholder `'חיפוש מוצרים, קטגוריות, מסכים...'`,
clear button `✕`.

### 6.2 `ToolsRail` / `TOOLS` (`tools-dial.tsx:9-99`) — the 5-tool dial
| id | label | submenu |
|---|---|---|
| `voice` | קולי | `VoiceSubmenu` |
| `barcode` | ברקוד | `BarcodeSubmenu` |
| `filters` | פילטרים | `FiltersSubmenu` |
| `sort` | מיון | `SortSubmenu` |
| `catalog` | קטלוג | `CatalogSubmenu` *(moved here from menu FAB)* |

Root: 5 buttons (staggered `i*28ms`), tap → `setActiveTool(id)`. When active: a single
`trail__btn--active` anchor (`onClick=() => setActiveTool(null)`, `aria-label="חזרה מ-{label}"`).

### 6.3 Search state & engine (`store/search-store.ts` + `lib/search.ts`)
- Signals: `searchQuery`, `searchScope: 'all'|'prod'|'cat'|'screen'`, `searchSort:
  'default'|'name_asc'|'name_desc'|'price_asc'|'price_desc'`, `activeTool: ToolKind|null`,
  `searchFilters {hasPrice,hasImage}`, `recentSearches` (persisted `bs.search.recent.v1`, max 8).
- `exactResults` (computed): `applyFilters(applyScope(searchExact(q,60)))`.
- `fuzzyResults` (computed): only when `exactResults` empty → `searchFuzzy(q)`.
- **`searchExact`** (`search.ts:16-38`): substring match over `hit.keywords`, prefix-first ordering,
  `KIND_ORDER screen<cat<prod`. **`searchFuzzy`** (`:65-90`): Damerau-ish Levenshtein
  (`editDistance`, `:41-59`), tolerance `floor(len/3)+1`, ≥2 chars, sliding window per keyword; this is the
  **actually-working fuzzy fallback**.
- `searchIndex()` (`data/search-index.ts:56-104`): builds hits from 7 `SCREENS` (home/cart/projects/orders/
  notifications/profile/settings — each with `kw` synonyms), all `CATEGORIES`, all `PRODUCTS` (keywords =
  name + productType/series/material/note). Memoized.

### 6.4 `ResultsList` (`results-list.tsx`)
Empty query + no recents → hint `'התחל להקליד כדי לחפש מוצרים, קטגוריות ומסכים.'`. Empty query + recents →
`'חיפושים אחרונים'` chips (🕓) + `'נקה'`. No results → `'לא נמצאו תוצאות עבור "{q}".'`. Exact hits →
list. Fuzzy-only → hint `'לא נמצאו תוצאות מדויקות — האם התכוונת ל:'` + list. Each `Row` → `gotoHit` which
records recent, closes search, then navigates: `prod`→`openProduct`, `cat`→`resetCategory()+drillInto`,
`screen:home`→clears `categoryPath`. `kindBadge`: prod→`מוצר`, cat→`קטגוריה`, screen→`מסך`.

### 6.5 `ScopeChips` (`scope-chips.tsx`)
4 chips (`role=tablist`): `הכל`(all) · `מוצרים`(prod) · `קטגוריות`(cat) · `מסכים`(screen) → set `searchScope`.

### 6.6 The tool submenus
- **Voice** (`submenu-voice.tsx`): real Web Speech via `lib/voice.ts`. Tap = listen+autoCommit; long-press
  (≥280ms) = continuous dictation. Labels: `'הקש להפעלה · החזק לדיבור'` / `'מאזין... שחרר לסיום'` / error
  `'הדפדפן הזה לא תומך בחיפוש קולי'`. Live transcript → `searchQuery`.
- **Barcode** (`submenu-barcode.tsx`): real camera via `lib/barcode.ts` (`BarcodeDetector`). Shows video +
  reticle; on detect sets `searchQuery` + closes tool. Labels `'הפעל מצלמה'`/`'מחפש... עצור'`/`'זוהה: {v}'`/`'הדפדפן לא תומך'`.
- **Filters** (`submenu-filters.tsx`): 2 toggles → `searchFilters` — `עם תמונה`(hasImage) · `עם מחיר מוצג`(hasPrice).
- **Sort** (`submenu-sort.tsx`): 5 options → `searchSort` — `ברירת מחדל` · `שם א→ת` · `שם ת→א` · `מחיר ↑` · `מחיר ↓`.
- **Catalog** (`submenu-catalog.tsx`): 11 categories (`@legacy CATALOG :6046-6056`), each a toast `'{title} — בבנייה'`:
  🚰 ברזים וכיורים · 🚽 אסלות · 🚿 מקלחות ואמבטיות · ♨️ חימום מים · 🍽️ מטבח · 🕳️ ניקוז וצנרת ·
  🚾 גופי תברואה · 🔗 אביזרי קצה וחיבורים · 🧱 בנייה ומחיצות · 🎨 גמר · 🧰 אביזרים נלווים.

### → Flutter mirror notes (search)
- **Tools dial DIVERGES to 4 tools.** Flutter `SearchTool { voice, barcode, filters, sort }`
  (`dial_state.dart:23`) — **`catalog` is dropped** because catalog is a bottom-nav tab. Preact keeps catalog
  as a 5th search tool.
- **Fuzzy engine MISSING.** `data/search_index.dart` `SearchEntry.matches()` is a plain
  `title/breadcrumb.toLowerCase().contains(q)` — **no `searchExact` prefix-ordering, no Levenshtein
  `searchFuzzy`, no "did you mean" fallback**. No grep hit for `editDistance`/`fuzzy` in any `.dart`. This is
  the single biggest behavioral gap in the search area.
- Flutter search index types (`screen/persona/category/setting/action/menu`) differ from Preact's
  (`screen/cat/prod`) — Flutter indexes nav nodes, Preact indexes catalog products+categories+screens.
- Sort/filters submenus exist in `search_dial_widget.dart` but emit `'… — בבנייה'` toasts (non-functional);
  Preact's filters/sort actually drive `searchFilters`/`searchSort` computed results.
- Scope chips (`הכל/מוצרים/קטגוריות/מסכים`) and the recent-searches UX have a partial Flutter equivalent
  (`state/recent_searches.dart`) — verify the empty/fuzzy hint strings are ported verbatim.

---

## 7. Views — `views/*.tsx`

| View | Renders | Notes |
|---|---|---|
| `HomeView` (`home.tsx`) | `<CategoryCircles/>` + `<ProductGrid/>` | the contractor default; real catalog drill + cart |
| `ManagerView` (`manager.tsx`) | header (👔 `מנהל המערכת` / `לוח-בקרה, ניהול, בדיקות איכות`) + `<RegressionPanel/>` | the only "real" non-home view |
| `StoreView` (`store.tsx`) | full WhatsApp-style store screen | section chips, quick-actions, rows, **bottom sheets** |
| `CourierView` (`courier.tsx`) | placeholder | 🛵 `שליח · משאית 14` / hint / `בנייה בקרוב` |
| `WorkerView` (`worker.tsx`) | placeholder | 🦺 `עובד` / hint / `בנייה בקרוב` |

### 7.1 `CategoryCircles` + catalog drill (`category-circles.tsx` + `store/app-store.ts`)
Catalog drill signals: `categoryPath: signal<string[]>`; computed `currentCircles` (=`childrenOf(parent)`),
`currentParentId`, `currentProducts` (=`productsForPath(path)`). `drillInto`/`goUp`/`resetCategory`
(`app-store.ts:46-75`). Catalog data (`data/catalog.ts`, auto-generated from `index.html`): **242
categories** (14 top-level: אביזרים מכניים, אחר, ברזים וכיורים, אסלות, מקלחות ואמבטיות, בנייה ומחיצות, גמר,
אינסטלציה גסה, חימום מים, מטבח, ניקוז וצנרת, גופי תברואה, אביזרי קצה וחיבורים, אביזרים נלווים) + `PRODUCTS`.
Helpers `childrenOf`/`categoryById`/`productsForPath`/`productById` (`catalog.ts:4526-4544`). Circles row:
optional `חזור`(goUp) + current-parent bubble + child bubbles; row scroll resets on depth change.
Empty grid → `'אין מוצרים בקטגוריה הזו עדיין'` / `'בחר קטגוריה אחרת או חפש לפי שם.'`.

### 7.2 Cart (`store/app-store.ts:183-217`) + `ProductCard`/`ProductSheet`
`CartLine={productId,qty}`, `cart: signal<CartLine[]>`, `cartCount` computed. `qtyOf`/`setQty`(clamps ≥0,
removes at 0)/`incQty`/`decQty`. `ProductCard` (`product-card.tsx`): image/emoji + name + price
(`מחיר לפי ספק`/`כלול`/`₪…`), inline stepper (− / number / +) or `לעגלה` add button; tap → `openProduct`.
`ProductSheet` (`product-sheet.tsx`): bottom sheet `role=dialog`; image, name, productType, note, price,
local qty stepper, total `'סה״כ: …'`, CTA `הוסף לעגלה` → `setQty + closeProduct`.

### 7.3 `StoreView` deep structure (`store.tsx`, 303 LOC) — the one fleshed-out persona screen
Local signals: `activeSection ('all'|'cart'|'orders'|'services')`, `openSheet ('moadim'|'tizmon'|'sicha')`,
`openService (idx)`, `openOrder (id)`. Search input (display-only). 4 section chips: `הכל`/`🛒 הסל`/
`📦 הזמנות`/`🔧 שירותים`. 4 quick-actions: `♡ מועדפים`(toast) / `📅 מועדים`(MoadimSheet) / `📆 תזמון`(TizmonSheet)
/ `📞 שיחה`(SichaSheet). Data: `allItems` (8 rows w/ emoji/title/sub/time/badge), `orders` (5 BS-#### w/
stage pills), `services` (6, opening `ServiceSheet` with per-service sub-rows), `orderItems` (line items per
order). Sheets are `SheetWrap` bottom-sheets (handle + backdrop). Most actions toast `'… — בבנייה'`.
*(Note: `StoreView` itself uses sheets — a controlled exception inside a persona view, not the dial layer.)*

### 7.4 Toast (`toast-store.ts` + `toast.tsx`)
`toastMsg: signal<string|null>`; `showToast(msg, durationMs=3200)` debounced single toast.
`<Toast>` renders `div.toast` (`role=status aria-live=polite`) or `null`.

### → Flutter mirror notes (views)
- **No persona-driven views in Flutter.** Because the shell is bottom-nav, there is no `HomeView`/
  `ManagerView`/`CourierView`/`WorkerView` switch. Equivalents exist as bottom-nav screens
  (`catalog_screen.dart`, `store_screen.dart`, `chats_screen.dart`, `notifications_screen.dart`) but they are
  always-present tabs, not persona-selected. `home_shell.dart` shows קטלוג as tab 0.
- **Catalog drill / product grid / cart steppers** have rich Flutter equivalents (`catalog_screen.dart`,
  `lipskey_product_sheet.dart`, `state/smart_cart.dart`, `state/cart_lists_state.dart`) — the Flutter catalog
  is in fact *more* developed (brands, install engine, smart cart). Catalog data is `data/catalog.dart` +
  `data/catalog_tree.dart`.
- **`StoreView`** → `store_screen.dart` + `store_settings_screen.dart` exist; verify chips/quick-actions/
  sheet strings match the verbatim Hebrew above.
- **Manager regression** → `regression_panel_screen.dart` + `test_harness/` (runner + tests) is ported, and is
  reachable via the BS dial's extra `🔬 בדיקות רגרסיה` leaf rather than a manager view.
- Toast → `widgets/toast.dart` (`showToast(context, msg)`).

---

## 8. Regression — `components/regression/regression-panel.tsx` + `test/*`

`RegressionPanel` (rendered inside `ManagerView`): header `🔬 מרכז בדיקות רגרסיה` + sub
`'בודק את כל הפעולות, נתוני הקטלוג, ה-views והאינווריאנטים של המערכת'`; run button
(`▶ הרץ בדיקת רגרסיה מלאה` / `⏳ מריץ את הבדיקות... רגע` / `↻ הרץ שוב`); summary
(`✅ כל הבדיקות עברו` / `❌ נמצאו N כשלים`) + per-category line; 7 filter chips
(`הכל/כפתורים/טאבים/מוצרים/התנהגות/סנכרון/זהויות`); result cards with ✓/✗ + checks.

`store/regression-store.ts`: `regressionStatus 'idle'|'running'|'done'`, `regressionResults`,
`regressionFilter`; computed `filteredResults`/`filteredSummary`/`summaryByCategory`.
`test/types.ts`: `TestCategory = buttons|tabs|products|behavior|dsync|dupes`. `test/runner.ts`:
async `runRegression` runs dsync→buttons→tabs→products→dupes, yielding to UI, crash-guarded.
`test/registry.ts`: `BUTTON_REGISTRY` (≈19 entries) maps fn → area/does/ref (identity/menu/search/catalog/
product/cart). **`test/tests/tabs.tsx` (R7-protected):** renders each of the 5 views into a hidden
390×844 container, asserts non-empty HTML, no crash — `TABS` labels `קבלן · קטלוג`, `מנהל · לוח-בקרה`,
`חנות`, `שליח`, `עובד`.

### → Flutter mirror notes (regression)
- Mirrored and **expanded**: `test_harness/` has `runner.dart`, `regression_state.dart`, `types.dart`, and
  test files `behavior/buttons/cart/catalog/dsync/dupes/engine/finder/products/sections/settings/tabs` —
  more categories than Preact's 6 (adds cart/catalog/engine/finder/sections/settings). The
  R7 `tabs` equivalent exists (`tests/tabs.dart`). The panel UI is `regression_panel_screen.dart`.

---

## 9. Cross-cutting "walk*" drill pattern (recap)

Every dial level uses the same helper shape `walkX(key, path) → { anchors, current }`: start at the root
list, follow `path` labels by matching a title/label field, stop on missing or childless node. Render order
is **always reversed** (because `.dial`/`.bsdial` is `flex-direction: column-reverse`) so the JSX-last item
sits at the visual top. Anchors render first (bottom of stack, tappable to pop), `current` items rise above.

| Dial | walk fn | path signal | location |
|---|---|---|---|
| BS | `walkBsDrill` | `bsDrillPath` (store) | `bs-dial.tsx:248` |
| Settings (advanced) | `walkSettings` | `menuActiveSettingsPath` (store) | `submenu-settings.tsx:328` |
| Profile | `walkProfile` | `profilePath` (store) | `submenu-settings.tsx:1013` |
| Home | `walkHome` | `homeDrillPath` (local) | `submenu-settings.tsx:1172` |
| Cart | `walkCart` | `cartDrillPath` (local) | `submenu-settings.tsx:1276` |
| Projects | `walkProjects` | `projectsDrillPath` (local) | `submenu-settings.tsx:1389` |
| Catalog (home view) | `childrenOf` | `categoryPath` (store) | `app-store.ts:48` |

→ **Flutter mirror:** `walkBsDrill` (sections.dart) and the menu `walkSettings`-equivalent
(`menu_dial_widget.dart`) are ported with the same `{anchors, current}` record shape; drill paths live in
`menu_state.dart`/`dial_state.dart`. Profile walk is **absent** (no profile tree).

---

## 10. Summary scoreboard — Flutter has vs lacks (this domain)

| Area | Preact (live) | Flutter port status |
|---|---|---|
| Shell model | persona-driven single `<main>` + overlays (R2) | **DIVERGES** — 4-tab bottom-nav IndexedStack of full screens |
| FAB openers | toggleBs / toggleMenu / toggleSearch | present (single `OpenDial` enum + scrim) |
| BS dial L1 tiles | 5 personas, identity ≠ browse | mirrored; **identity/browse conflated**, no current-identity highlight |
| BS persona trees | 4 trees verbatim (~200 leaves) | **verbatim mirror** (sections.dart) + extra `mm-regression` |
| Menu 4 tabs | home/projects/cart/settings dials | present (secondary surface, not main spine) |
| Home/Cart/Projects/Finance trees | verbatim | **verbatim mirror** (menu_trees.dart) |
| `SETTINGS_SUB` (10 groups → depth 4) | verbatim | mirrored **+2 extra groups** (12/83) — reconcile |
| `LEAF_BINDINGS` (~60 path-keyed) | path-keyed action/isActive/input | **DIVERGES** — bare-label `_applyLeaf` (collision risk) |
| R9 inline `LeafEditor` + 5 profile fields | yes | **MISSING** |
| `PROFILE_TREE` + identity/ranks/achievements/rewards | yes (verbatim) | **MISSING** (3-level settings router absent) |
| `appSettings` + DOM/localStorage persist | yes | partial (`state/app_settings.dart`) — verify shape parity |
| Search 5-tool dial | voice/barcode/filters/sort/catalog | **4 tools** (catalog dropped) |
| Working search engine | `searchExact` + `searchFuzzy` (Levenshtein) | **MISSING fuzzy** — plain `.contains()` only |
| Filters/sort actually filter | yes | **non-functional** ("בבנייה" toasts) |
| Persona views (home/manager/store/courier/worker) | yes | **N/A** (bottom-nav screens instead) |
| Regression suite | 6 categories + R7 tabs test | **mirrored + expanded** (12 test files) |
| Toast | single debounced signal | mirrored (`widgets/toast.dart`) |

**Highest-priority gaps for a faithful port:** (1) decide the shell — Preact's R2 persona+dial model vs the
Flutter bottom-nav shell; (2) port `PROFILE_TREE` + identity/ranks/achievements + the 3-level settings
router; (3) port the path-keyed `LEAF_BINDINGS` + R9 `LeafEditor` + `user-profile` fields; (4) port the
real `searchExact`/`searchFuzzy` engine and make filters/sort functional; (5) restore `catalog` as the 5th
search tool (or formally bless its promotion to a tab).
