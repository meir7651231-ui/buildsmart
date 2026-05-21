# 📚 BuildSmart UI Architecture — Master Index

**Project:** BuildSmart Contractor & Multi-Role Platform  
**Last Updated:** 2026-05-21  
**Scope:** Complete UI/UX documentation across all user roles and screens

---

## 📖 Documentation Series

### **PART 1: CONTRACTOR DASHBOARD** ✅ Complete
**File:** `UI_ARCHITECTURE.md` (this file)

Complete deep dive into the contractor's main 5-tab interface:
- 🏠 בית (Home) — discovery, search, quick products
- 📋 קטלוג (Catalog) — product browsing, smart trees, plan scanner
- 🏗️ הפרויקטים (Projects) — task management, site coordination
- 🛒 רכש (Cart) — shopping, checkout, orders
- 👤 חשבון (Profile) — gamification, achievements, user stats

---

### **PART 2: ROLE DRAWER & MULTI-PERSONA SYSTEM** ✅ Complete
**File:** `ROLE_DRAWER_SYSTEM.md`

Entry point and 5 complete role systems:
1. 👷 **קבלן (Contractor)** — order materials, manage projects
2. 👔 **מנהל המערכת (System Manager)** — manage products, stores, customers
3. 🏪 **חנות ספק (Supplier Store)** — handle incoming orders, inventory
4. 🛵 **שליח (Courier)** — manage deliveries
5. 🦺 **עובד (Field Worker)** — complete assigned tasks

---

### **PART 3: SYSTEM MANAGER DASHBOARD** ⏳ In Progress
**File:** `SYSTEM_MANAGER_DASHBOARD.md` (coming next)

Complete deep dive into the 4-tab system manager interface:
- 📊 לוח בקרה (Dashboard/Products)
- 🚚 הזמנות (Orders)
- 👥 לקוחות (Customers)
- 🛠️ ניהול (Management)

---

## Table of Contents — Contractor Dashboard

1. [App-Wide Navigation](#app-wide-navigation)
2. [Tab 1: בית (Home)](#tab-1-בית-home)
3. [Tab 2: קטלוג (Catalog)](#tab-2-קטלוג-catalog)
4. [Tab 3: הפרויקטים (Projects)](#tab-3-הפרויקטים-projects)
5. [Tab 4: רכש (Cart)](#tab-4-רכש-cart)
6. [Tab 5: Profile/Identity](#tab-5-profileidentity)
7. [Overlays & Modals](#overlays--modals)
8. [Data Structures](#data-structures)
9. [Key Patterns](#key-patterns)

---

# App-Wide Navigation

## Bottom Navigation Bar (5 FABs)

Fixed at bottom of all views. All 5 tabs always visible.

| Tab | Icon | Label | ID | Handler |
|-----|------|-------|----|----|
| Home | BS | בית | `tabHome` | `go('home')` |
| Search | 🔍 | חיפוש | `tabSearch` | Opens search overlay |
| BS Mode | ⚙️ | BS-mode | `tabMode` | Toggles BS-mode (demo setting) |
| Menu | ☰ | תפריט | `tabMenu` | Opens settings menu |
| Profile | 👤 | חשבון | `tabProfile` | `go('profile')` |

### App Bar Header
- **Left:** Site/Project name badge with pin icon
  - Clickable: `openCartSitePicker()` → change destination site
- **Center:** Page title (dynamic based on current view)
- **Right:** 
  - Notification bell 🔔 with unread count badge
  - Cart count badge 🛒 with item count

---

# Tab 1: בית (Home)

**Primary:** Discovery, quick actions, search  
**Layout:** Vertical stack of 8 sections

## Section 1: Global Search Bar

**Component:** `searchwrap` → `homeSearchBox`

- **Search Input (homeSearch):**
  - Placeholder: "חפש כלי עבודה, חומר בנייה, אביזר..."
  - Event: `oninput="onHomeSearchInput()"`
  - Auto-complete: off
  
- **Clear Button (homeSearchClear):**
  - "✕" icon
  - Hidden when no text
  - `onclick="clearHomeSearch()"`

- **Suggestions Dropdown (homeSearchSuggest):**
  - Rendered by: `renderHomeSearchSuggest()`
  - **Suggestion Types:**
    - **nav:** screens/features (screens, with label/path/icon)
    - **prod:** products (with category breadcrumb)
    - **acc:** accessories (with hierarchy)
    - **cat:** categories
  - **Fallback:** Fuzzy search with "Did you mean...?" for typos
  - **Click Action:** `homeSearchGoTo(index)` → navigate to result
  - Shows path breadcrumb: "category › subcategory › item"

---

## Section 2: Hero Banner

**Component:** `.hero`

- **Tag:** "⚡ אקספרס לאתר"
- **Headline:** "הזמן עכשיו — קבל לאתר עד שעתיים"
- **Subtext:** "בלי לעצור את העבודה ובלי נסיעה לחנות. הכל מגיע אליך."

---

## Section 3: AI Hub Button

**Component:** `.fin-hub-btn`

- **Icon:** 🤖
- **Title:** "בינה מלאכותית ואוטומציה"
- **Subtitle:** "חיזוי מלאי, סורק ברקוד, חלופות זולות ותובנות"
- **Action:** `onclick="openAIHub()"`

---

## Section 4: Category Grid

**Component:** `.cat-grid` (8 cards)

Each card:
- Icon emoji (🔧, 🚿, ⚡, 🧱, 🎨, 🔩, 🦺, ➕)
- Label: כלי עבודה, אינסטלציה, חשמל, בנייה, גמר וצבע, חיבורים, בטיחות, הכל
- Action: `onclick="go('catalog')"` (all navigate to catalog)
- Grid: 4 columns, responsive

---

## Section 5: Smart Product Picker

**Component:** Product row with heading

### Header:
- Title: "עץ התקנה חכם — אינסטלציה"
- Link: `onclick="openSmartCatalog()"` → full catalog
- Hint: "💡 נסה את זה: בחר ברז או כלי סניטרי..."

### Product Row (homeProductRow):
**Horizontal scrollable row of product cards**

Populated by: `renderHomeProducts()` from `HOME_PRODUCTS[]` array

#### Each Product Card (pcard):

```
┌─────────────────────────────────────┐
│ 🔧 אינסטלציה  (category badge)     │
├─────────────────────────────────────┤
│         🚽 (product icon)           │
├─────────────────────────────────────┤
│ ברז אמבטיה         [✓ checkbox]     │  (pname + prod-check)
├─────────────────────────────────────┤
│ ₪245 / יח'                          │  (pprice)
├─────────────────────────────────────┤
│  −  [2]  +                          │  (qty-wheel)
├─────────────────────────────────────┤
│ 🌳 עץ מוצרים · 6 אביזרים          │  (tree button - rich products only)
└─────────────────────────────────────┘
```

- **Category Badge:** "🔧 אינסטלציה" (static)
- **Thumbnail:** Product icon/emoji
- **Info Line:**
  - Left: Product name (pname)
  - Right: Checkbox for quick add (prod-check)
    - Class `.on` if in cart
    - Click: `toggleProductInCart(key, qty)`
- **Price:** "₪[amount] / יח'" (per unit)
- **Quantity Controls:** − [qty] + buttons
  - Minus: `stepCatQty(key, -1)`
  - Display: Click to input via `openCatQtyInput(key)`
  - Plus: `stepCatQty(key, 1)`
- **Smart Tree Button** (if rich product):
  - "🌳 עץ מוצרים · [N] אביזרים"
  - Click: `openTree(key)`
- **Expanded Detail** (if card expanded):
  - Shows tree info or product details

---

## Section 6: Smart Workflow

**Component:** `.project-hero` (clickable)

- **Tag:** "🛁 חדש — מאפס עד גמר"
- **Headline:** "גמר אמבטיה — מלווה אותך שלב-שלב"
- **Subtitle:** "4 שלבים בסדר הנכון..."
- **Progress:** Visual bar + "פתח מסלול ›" text
- **Click:** `onclick="go('project')"`

---

## Section 7: Quick Action Cards

**Component:** 3 `.promise` cards

### Card 1: Plan Scanner
- **Background:** Amber color
- **Icon:** Crosshair (📐)
- **Title:** "📐 סרוק תוכנית עבודה"
- **Subtitle:** "צלם שרטוט אינסטלציה — נזהה מה צריך להזמין"
- **Action:** `onclick="go('scan')"`

### Card 2: My Inventory
- **Background:** Brand color (#1f6f6b)
- **Icon:** 3D box (📦)
- **Title:** "📦 המלאי שלי"
- **Subtitle:** "מה כבר יש לך — במחסן ובאתר"
- **Action:** `onclick="go('stock')"`

### Card 3: Work Tasks
- **Background:** Ink color
- **Icon:** Checkbox clipboard (📋)
- **Title:** "📋 משימות העבודה"
- **Subtitle:** "חלק משימות לעובדים ועקוב אחרי הביצוע"
- **Action:** `onclick="go('tasks')"`

---

## Section 8: Reorder History

**Component:** Section with heading + container

### Header:
- Title: "הזמנה חוזרת לאתר זה"
- Link: `onclick="go('orders')"` → full orders history

### Container (reorderHistory):
Populated by: `renderReorderHistory()` from `DEMO_HISTORY[]` (demo mode only)

#### Empty State:
- Message: "עדיין אין הזמנות קודמות..."

#### Each Item (plist):

```
┌────────────────────────────────────────┐
│ 🚽 | ברז אמבטיה           | + icon    │
│    | אינסטלציה · לפני שבוע |           │
│    | ₪245                   |           │
└────────────────────────────────────────┘
```

- **Full Row Clickable:** `onclick="addSingle(name, price, icon)"`
- **Thumbnail (lthumb):** Product icon
- **Info (linfo):**
  - Product name (lname)
  - Meta: "[category] · [time ago]" (lmeta)
  - Price (lprice)
- **Quick Add Button (add-mini):**
  - "+" icon
  - `onclick="event.stopPropagation();addSingle(...)"`

---

# Tab 2: קטלוג (Catalog)

**Primary:** Browse and search products with smart filtering  
**Two Views:** Flat catalog + navigated drill-down

## View 1: Main Catalog (view-catalog)

### Top Navigation Bar

**Search Section (catnav-search):**
- Icon: Magnifying glass
- Input: "חיפוש בכל הקטלוג..."
- Auto-complete: off
- Event: `oninput="onCatSearchInput()"`
- **Suggestions Dropdown (catSearchSuggest):**
  - Filters all products by name OR accessory names
  - Real-time rendering
- **Clear Button (catSearchClear):**
  - Hidden when no search
  - `onclick="clearCatSearch()"`

**Sort Button (catSortBtn):**
- Text: "⇅"
- Click: `toggleCatSort()`
- **Sort Menu (catSortMenu):** Hidden dropdown
  - Sort by name (A-Z)
  - Sort by name (Z-A)
  - Sort by price (low to high)
  - Sort by price (high to low)
  - Variable: `catMainSort`

### Info Hint
- "💡 קטלוג אינסטלציה מלא — לחץ על מוצר לפתיחת עץ המוצרים."

### Category Chips (catChips)
Horizontal scrollable filter buttons

- **"All" Chip:**
  - Icon: 📋
  - Label: "הכל"
  - Always available
  - Class `.on` when selected
  - Click: `setCatalogCategory('all')`

- **Category Chips:**
  - Generated from `CATALOG` array (catalogGroupsForMode())
  - Each has: icon, category name, items[]
  - Examples: "ברזים", "אסלות", "מקלחות", etc.
  - Class `.on` when `catalogCategory === name`
  - Click: `setCatalogCategory(name)`

### Product List Container (catalogList)

**Rendered by:** `renderCatalog()`

#### When catalogCategory === 'all':
- Flat continuous list
- All products, no category headers
- Sorted by selected sort mode
- No deduplication (each appears once)

#### When specific category selected:
- Products grouped by category
- Category header: "[icon] [category-name]"
- Products under header sorted
- Empty categories hidden

#### Search Results:
- Filters across: product name OR any accessory name
- Applied regardless of category selection
- Empty result: "לא נמצאו מוצרים לחיפוש זה"

### Product Row (catalogRowHtml)

```
┌─────────────────────────────────────────┐
│ 🚽 | ברז אמבטיה    | ₪245 | [brand ▼] │
│    | subcategory   |      | qty: − 1 + │
│    |               |      | [add ►]    │
└─────────────────────────────────────────┘
```

- **Left Thumbnail:** Product icon/image
- **Center:**
  - Product name (clickable to tree)
  - Meta: category/subcategory
- **Right:**
  - Price: "₪[amount]"
  - Brand/variant selector (if applicable)
  - Quantity spinner
  - Add to cart button: `addCatalogProduct(key)`

---

## View 2: Category Navigation (view-catnav)

**Drill-down navigation for large categories**

### Structure:
1. **Category Selection** → 2. **Attribute Drill Steps** → 3. **Product List**

### Auto-Drill Reduction Logic:
- For each attribute in `ATTR_SCHEMA`:
  - Count distinct values among products in current category
  - 0-1 values → skip (auto-selected)
  - >1 values → show as drill step
- Result: Small categories jump to products; large ones have 2-5 steps

### Navigation Bar:
- Back button: "›" → `catNavBackBtn()`
- Search: same as main catalog
- Sort: same as main catalog

### Attribute Drill Levels:

**ATTR_SCHEMA** (5 standard attributes):
```
1. productType      (סוג מוצר)      - icon: 📦
2. secondary        (מאפיין)        - icon: 🔧
3. diameter         (קוטר / מידה)   - icon: 📏
4. variantOpt       (דגם)          - icon: 🔩
5. brandName        (מותג)         - icon: 🏷️
```

**Drill State Object (catNav):**
```javascript
{
  cat: 'selected category',
  type: 'selected product type',
  secondary: 'selected secondary attr',
  diameter: 'selected diameter',
  prod: null,
  accMode: boolean,
  picks: {}  // all selections
}
```

### Dynamic Rendering:
- Each step shows: label, icon, list of values
- Click value → `catNav.picks[attributeKey] = value`
- Re-filters products and advances to next step
- State tracked in: `catNav.picks{}`

---

## Product Tree Overlay (overlay)

**Opens when user clicks a product**

### Hero Section:

**Product Image (rootImg):**
- Large icon or image
- If `.image` exists: `<img>` with lazy loading
- Otherwise: emoji from `.img`
- Error handling: fallback to emoji

**Title (treeTitle):**
- From: `TREES[key].note || TREES[key].name`

**Name (rootName):**
- From: `TREES[key].name`

**Meta Information (rootMeta):**
- Varies by product type:
  - Catalog: "[category] · [variant]"
  - Rich: "⭐ [brand] · [variant]"
  - Legacy: "Project stage · all components"

**Price (rootPrice):**
- Catalog/Rich: "₪[price]"
- Legacy: "Full product tree"

---

### Installation Diagram (treeDiagram)

**SVG-based flow visualization with interactive stages**

**8 Diagram Types:**
- faucet, toilet, shower, infra, sealing, tiling, cable, profile

**Each Diagram:**
- Title: e.g., "תהליך התקנת ברז — מהזנה עד קצה"
- 4-5 stages with arrows
- Each stage:
  - Icon (ICN[]) — custom SVG
  - Label: e.g., "רכיבים"
  - Subtitle: e.g., "אטמים, צינורות"

**Interaction:**
- Click stage → highlights accessories for that stage
- Active stage shows: "⤵ הודגשו האביזרים לשלב..."
- Click again to clear
- Non-clickable: "💡 הקש על שלב..."

---

### Accessories Section (treeState)

**Branch Label (branchLabel):**
- Hidden for catalog products without accessories
- Otherwise: "רכיבים ואביזרים"

**For Each Accessory:**

```
┌──────────────────────────────────────────┐
│ ☑ | סרט טפלון      | ₪9  | [32mm▼] [📦] │
└──────────────────────────────────────────┘
```

- **Checkbox:** picked/unpicked toggle
- **Icon + Name:** Accessory display
- **Price:** `accTypePrice()` — estimated based on type
- **Size Selector** (if item has SIZES):
  - Dropdown for diameter/variant
  - Click: `openAccSize(index)`
- **Stock Status:** in-stock, limited, order
- **Quantity:** +/− spinner

**Expandable Details (expandedAcc):**
- Click accessory → detail sheet opens
- Shows: full specs, size options, availability
- Can change qty, size, pick/unpick

**Stage Filtering (activeStage):**
- When diagram stage selected, filter accessories
- Match logic: stage.match[] keywords → filter by name

---

### Tool Bag Section (optional):
- For some trees: expandable tool list
- Each tool: icon, name, optional note
- Can pick tools needed
- State: `toolsExpanded`

---

### Action Buttons:

**Root Checkbox:**
- Add entire product to cart
- Synced with cart state: `refreshRootCheck()`

**Add to Cart Button:**
- "הוסף לסל"
- `onclick="addCatalogProduct(key)"`
- Takes all picked accessories
- Toast: "[product-name] × [qty] נוסף לסל"

**Brand/Variant Selectors:**
- If has brands: "בחר מותג" → brand overlay
- If has variants: "בחר דגם" → variant overlay

---

## Supporting Overlays:

### Brand Picker (brandOverlay)
- Shows all brands for product
- Each: name, supplier, lead time, price difference
- Click to select → updates price, display
- State: `chosenBrand(key)`

### Variant Picker (variantOverlay)
- Shows all variants (sizes, styles)
- Each: name, specs, availability, price
- Click to select → updates price
- State: `chosenVariant(key)`

### Accessory Detail (accDetailOverlay)
- Full details for one accessory
- Shows: name, description, specs, size options, stock

---

## Plan Scanner Feature (bonus)

**4 Plan Types:**
1. **Plumbing (אינסטלציה):** Detects fixtures, water points
2. **Electrical (חשמל):** Detects panels, outlets, lights
3. **Architectural (אדריכלות):** Detects walls, openings, dimensions

**Flow:**
- Upload/scan plan image
- Detection: "סורק..." → "מזהה סמלים..." → "מאתר נקודות..."
- Results: Detected zones with confidence (84%-98%)
- **Price Comparison:** Each item shows 3-store pricing

---

# Tab 3: הפרויקטים (Projects)

**Primary:** Project/site management with two sub-tabs  
**Structure:** My Project + My Sites

## Sub-Tab 1: 🌳 הפרויקט שלי (My Project)

### View Switch:
- 🌳 הפרויקט שלי (selected)
- 🏗️ האתרים שלי

---

### Hero Section (project-hero):

**Tag/Badge:**
- "🚽 פרויקט מלא · בחר יום ›"
- Click: `openDayPicker()` → jump to specific work day

**Title (smartProjTitle):**
- Dynamic: "[Site Name] — מאפס עד מסירה"
- Example: "מגדל הרצליה — מאפס עד מסירה"

**Subtitle:**
- Static: "BuildSmart מפרק את המשימות לימי עבודה לפי הסדר הנכון בשטח."

**Progress Bar (project-prog):**
- Visual bar: `width = [done days / total days × 100]%`
- Text: "[N] מתוך [Total] ימים בוצעו · [%]%"
- Updates dynamically

---

### Budget Box (budget-box):

Clickable: `onclick="openBudgetDetail()"`

```
┌──────────────────────────────────────┐
│ 💰 תקציב הפרויקט        [65%]        │
├─[████░░░░░░░░░░░░░░░░]──────────────┤
│ ₪150,000     ₪85,000     ₪235,000    │
│ הוצאת עד כה  נשאר בתקציב  תקציב כולל │
├──────────────────────────────────────┤
│ הקש לפרטים וניתוח ›  [✏️ עריכה]    │
└──────────────────────────────────────┘
```

- **Header:** "💰 תקציב הפרויקט" + percentage
- **Progress bar:** width = `[spent / total × 100]%`
- **Three columns:**
  - Spent (הוצאת עד כה)
  - Remaining (נשאר בתקציב) — green color
  - Total (תקציב כולל)
- **Footer:** Info link + Edit button

---

### Finance Hub Button:
- Icon: 📊
- Title: "מרכז פיננסים"
- Subtitle: "מדד, תנאי תשלום, ROI, דוחות וקבלני משנה"
- Click: `openFinanceHub()`

---

### Info Hint:
- "💡 הפרויקט החכם מפרק כל משימה לימי עבודה. אפשר לבצע ימים בכל סדר..."

---

### Stage Cards (smartStages):

**For each work day in all tasks:**

#### Stage Card (stage-card):

```
┌────────────────────────────────────┐
│ 2  | יסודות              [לא בוצע] ▾ │  (header - clickable)
│    | יום 1 מתוך 5 · יסוד בטון     │
├────────────────────────────────────┤
│ פירוט: יסוד בטון מעולה         │  (expanded detail)
│ עובד אחראי: דוד כהן            │
│ היקף: 5 ימי עבודה            │
│                                │
│ [Installation diagram SVG]     │
│                                │
│ שלבי ביצוע                    │
│ ☑ חפירה ויישור בסיס        │
│ ☐ הנחת חוליות               │
│ ☑ ניקוז וקירור               │
├────────────────────────────────────┤
│ [🌳 עץ מוצרים] [✓ סמן בוצע]     │  (footer)
└────────────────────────────────────┘
```

- **Card Header (stage-head)** — clickable to expand/collapse:
  - Left: Stage number (1, 2, 3...) or ✓ if done
  - Center: Task name + day range info
  - Right: Status badge (בוצע/לא בוצע)
  - Expand arrow: ▾

- **Expanded Detail (stage-detail)** — shown when expanded:
  - **Detail Row:** [label] : [value]
  - **Worker Row:** "עובד אחראי" : [name or לא שובץ]
  - **Scope Row:** "[N] ימי עבודה"
  - **Note Row** (if present): [task note]
  - **Installation Diagram:** SVG flow with interactive stages
  - **Execution Steps** (if present):
    - Header: "שלבי ביצוע"
    - Each step: checkbox + name + state (בוצע/לא בוצע)
    - Click checkbox: `toggleSmartStep(key)`

- **Card Footer (stage-foot)**:
  - **Tree Button** (if task has tree):
    - Icon: Tree SVG
    - Text: "עץ מוצרים"
    - Click: `openTree(treeKey)`
  
  - **Action Button:**
    - If not done: "✓ סמן יום כבוצע" → `toggleSmartDay(key)`
    - If done: "↩ בטל סימון" → `toggleSmartDay(key)`

---

### Completion Banner (proj-done):

Visibility: `.display: block` only when all days complete

- "🎯 בסיום כל ימי העבודה — הפרויקט מוכן למסירה."

---

## Sub-Tab 2: 🏗️ האתרים שלי (My Sites)

### View Switch:
- 🌳 הפרויקט שלי
- 🏗️ האתרים שלי (selected)

---

### Budget Overview (sitesBudgetBox):

Similar to project budget (see above)
- Shows: total spent, remaining, total budget across all sites

---

### Section Header:
- "האתרים שלי" (My Sites)

---

### Add New Site Button:

"＋ הוסף פרויקט / אתר חדש"
- Click: `openProjectModal()` → modal to create new site

---

### Projects/Sites List (projectList):

**For each project in PROJECTS array:**

#### Site Card (site-card):

```
┌─────────────────────────────────────────┐
│ מגדל הרצליה        [🟢 פעיל עכשיו]  │ (sc-top)
│ תל אביב, קרית שמונה                   │
├─────────────────────────────────────────┤
│ 👷 מנהל עבודה: אברהם שחף              │ (sc-pm)
├─────────────────────────────────────────┤
│ 🛒 3 פריטים בעגלה ›                   │ (sc-links)
│ 🌳 2 עצי מוצרים ›                      │
├─────────────────────────────────────────┤
│ 📊 הקש לסטטוס האתר המלא              │ (sc-edit-hint)
└─────────────────────────────────────────┘
```

**Classes:**
- `.current` if active project
- Default otherwise

- **Top Section (sc-top)** — clickable for status view:
  - Click: `openSiteStatus(id)`
  - Left:
    - **Site Name (sc-name):** [project.name]
    - **Address (sc-addr):** [project.addr]
  - Right: Status Badge
    - Active: "🟢 פעיל עכשיו" → `switchProject(id)`
    - Inactive: "החלף ›" → `switchProject(id)`

- **Manager Row (sc-pm)** — clickable for status:
  - Click: `openSiteStatus(id)`
  - Text: "👷 מנהל עבודה: [name or —]"

- **Quick Links (sc-links):**
  - Cart Link: "🛒 [N] פריטים בעגלה ›"
    - `onclick="openSiteCart(id)"`
    - Shows item count for this site
  - Trees Link: "🌳 [N] עצי מוצרים ›"
    - `onclick="openSiteProject(id)"`
    - Shows active product tree count

- **Status Hint (sc-edit-hint)** — clickable:
  - Click: `openSiteStatus(id)`
  - "📊 הקש לסטטוס האתר המלא"

---

## Modal: Site Status (siteStatusOverlay)

**Opens when clicking on a site card**

### Title (ssTitle):
- [Site name]

### Active State Indicator (ss-state):

Clickable: `onclick="closeSiteStatus();switchProject(id)"`

- Active: "🟢 אתר פעיל עכשיו"
- Inactive: "⚪ לא פעיל — הקש כדי להפעיל"

---

### Details Card (ss-card):

Clickable: `onclick="closeSiteStatus();openSiteEditor(id)"`

**Rows:**
- "📍 כתובת" : [address or —]
- "👷 מנהל עבודה" : [manager or —]

**Edit Hint:** "✏️ הקש לעריכת הפרטים"

---

### Project Progress Tile (ss-tile):

Clickable: `onclick="closeSiteStatus();openSiteProject(id)"`

- **Top Row:**
  - Left: "🌳 התקדמות הפרויקט"
  - Right: "[%]%" completion
- **Progress Bar:** width = `[done / total × 100]%`
- **Info:** "[N] מתוך [Total] ימי עבודה בוצעו · הקש לפרויקט ›"

---

### Budget Tile (ss-tile):

Clickable: `onclick="closeSiteStatus();openBudgetDetail()"`

- **Top Row:**
  - Left: "💰 תקציב"
  - Right: "[%]%" usage
- **Progress Bar:** width = `[min(100, spent/total×100)]%`
- **Info:** "₪[spent] מתוך ₪[total] · הקש לפרטים ›"

---

### Quick Links (ss-links):

- Cart: "🛒 [N] פריטים בעגלה ›" → `openSiteCart(id)`
- Trees: "🌳 [N] עצי מוצרים ›" → `openSiteProject(id)`

---

### Edit Button:

"✏️ עריכת פרטי האתר"
- `onclick="closeSiteStatus();openSiteEditor(id)"`
- Green button style

---

## Modal: Site Editor (siteEditOverlay)

**Opens when clicking edit on a site**

### Input Fields:

- **Site Name (seNameInput):**
  - Type: text input
  - Value: current site name

- **Address (seAddrInput):**
  - Type: text input
  - Value: current address

- **Manager (seManagerInput):**
  - Type: text input
  - Value: current manager name

### Save Button:

"שמור" → `saveSiteEdit()`
- Validates name is filled
- Updates site data
- Toast: "פרטי האתר עודכנו"

---

## Modal: Add New Project (projectModal)

**Opens when clicking "הוסף פרויקט" button**

### Input Fields:

- **Project Name (pmProjName):** text input, required
- **Address (pmProjAddr):** text input, optional
- **Manager (pmProjMgr):** text input, optional

### Save Button:

Creates new project with:
- Auto-generated ID: `PRJ-[sequence]`
- Empty cart: `[]`
- Empty tree progress: `{}`
- Toast: 'הפרויקט "[name]" נוסף'

---

# Tab 4: רכש (Cart)

**Primary:** Shopping cart management, checkout, shipment planning

---

## View Switch:

- 🛒 הסל שלי (selected)
- 📦 ההזמנות שלי

---

## Site Assignment Strip (site-strip):

```
┌──────────────────────────────────────────┐
│ ההזמנה תשויך ותישלח לאתר               │
│ 📍 מגדל הרצליה              [החלף ›]   │
└──────────────────────────────────────────┘
```

**Left Section:**
- Label: "ההזמנה תשויך ותישלח לאתר"
- **Site Display:**
  - Pin icon 📍
  - Site name (from `activeProject()`)
  - Default: "—" if no project

**Right Section:**
- "החלף ›" button
- Click: `openCartSitePicker()`
- Changes destination site

---

## Shipment Planning Strip (cartShipPlan):

### Single Shipment Mode (default):
```
🚚 אספקה אחת · יום חמישי 14:00–17:00 · מגדל הרצליה
[חלק לגלים ›]
```

- Icon: 🚚
- Text: "אספקה אחת · [day] [time] · [site name]"
- Button: "חלק לגלים ›" → `openCartShipPlanner()`

### Multi-Wave Mode (when split):
```
🚚 ההזמנה תגיע ב-3 גלים
3 פריטים לא משויכים (red)
[ערוך ›]
```

- Icon: 🚚
- Text: "ההזמנה תגיע ב-**[N] גלים**"
- If unassigned: "[U] פריטים לא משויכים" (red #a93226)
- Button: "ערוך ›" → `openCartShipPlanner()`

---

## Cart Items Section (cartItems)

**Grouped by Supplier Store**

### For Each Store:

#### Store Header:
- Store icon + name: e.g., "🏭 חנות מחסן א"
- ETA badge: e.g., "2-3 ימים"

---

#### For Each Item in Store:

##### Item Row (cart-line):

```
┌─────────────────────────────────────────────┐
│ 🚽 | ברז אמבטיה        ₪245 ליח'          │
│    | ⚡ עץ מוצרים                          │
│    | − [2] +  [🗑️]                        │
│    | ₪490                                  │
└─────────────────────────────────────────────┘
```

- **Left Thumbnail (cl-thumb):** Product icon/image

- **Center Info (cl-info):**
  - **Name (cl-link):** Clickable → `goToProductByName(name)`
    - Shows product name
  - **Price Line (cl-priceline):**
    - "₪[price per unit] ליח'"
    - If auto-added: "· ⚡ עץ מוצרים" (green teal #1f6f6b)
  - **Controls (cl-controls):**
    - **Quantity Wheel (qty-wheel):**
      - Minus: "−" → `stepCartQty(index, -1)`
      - Qty display (centered, clickable):
        - Click: `openCartQtyInput(index)` → modal
      - Plus: "+" → `stepCartQty(index, 1)`
    - **Delete Button:** "🗑️" → `removeCartItem(index)` title="הסר"

- **Right Price (cl-price):**
  - "₪[price × qty]" (total for this line)

---

##### Haul Type Selector (sg-haul) — *single-wave mode only*:

```
סוג הובלה
[🚗 קטן] [🚐 וואן] [🚛 משאית]
```

- Label: "סוג הובלה"
- **Haul Buttons** (for each haul type):
  - Icon + name + extra charge (if any)
  - Active class: `.on`
  - Click: `pickHaul(storeId, haulId)`

---

##### Store Subtotal:
- "סכום ביניים · [store name]" — ₪[subtotal]

---

##### Store Shipping:
- "🚚 משלוח · [store name]" [+ "(כולל הובלה)" if applicable]
- Price: ₪[shipping amount]

---

## Empty Cart State (cartEmpty):

*Hidden if items exist*

```
🛒

הסל ריק

עבור לקטלוג ובחר מוצר אב...
```

- Emoji: 🛒
- Title: "הסל ריק"
- Subtitle: "עבור לקטלוג ובחר מוצר אב..."

---

## Checkout Summary Section (cartSummary)

### Delivery Slot Picker (deliv-pick) — *hidden in multi-wave mode*:

```
⏰ בחר חלון משלוח לאתר

[ ב׳ | ג׳ 14:00–17:00 | ד׳ | ה׳ 08:00–10:00 ]
```

- **Title:**
  - Clock icon ⏰
  - "בחר חלון משלוח לאתר"

- **Slot Buttons:**
  - For each delivery slot:
    - Clickable container: `onclick="pickSlot(index)"`
    - Active class: `.on`
    - Shows: day abbreviation + time window
    - Example: "ה׳ 14:00–17:00"
    - With express fee (if applicable): "+ ₪[fee]"

---

### Payment Details Box (checkout-box):

Clickable: `onclick="openPaymentDetail()"`

```
💳 פירוט תשלום  [פרטים מלאים ›]
سכום ביניים · 3 פריטים      ₪735
דמי משלוח · 2 חנויות         ₪85
⚡ תוספת אקספרס              ₪50
מע"מ (17%)                    ₪159

⚡ אביזרים שעץ המוצרים מנע שתשכח  3 פריטים

סה"כ לתשלום                  ₪1,029

💳 זמין לקבלנים מאושרי חיתום: תשלום בשוטף +60
[🧪 בדוק את החישוב]
```

- **Header (co-title):**
  - "💳 פירוט תשלום"
  - "פרטים מלאים ›" link

- **Subtotal Row:**
  - "סכום ביניים · [item count] פריטים" — ₪[subtotal]

- **Shipping Rows:**
  - *Single shipment:*
    - "דמי משלוח · [store count] חנויות" — ₪[total]
  - *Multiple shipments:*
    - "דמי משלוח · [number] גלים נפרדים" — ₪[total]
    - Sub-rows for each wave:
      - "· משלוח [wave#] ([haul name])" — ₪[wave amount]

- **Express Fee** (if applicable):
  - "⚡ תוספת אקספרס" — ₪[fee]

- **VAT Row:**
  - "מע"מ ([%]%)" — ₪[vat amount]

- **Auto-Added Items Row** (info style, teal color #1f6f6b):
  - "⚡ אביזרים שעץ המוצרים מנע שתשכח" — "[N] פריטים"

- **Grand Total Row** (emphasized):
  - "סה"כ לתשלום" — "₪[grand total]"

- **Payment Terms Note:**
  - "💳 זמין לקבלנים מאושרי חיתום: תשלום בשוטף +60"

- **Test Button** (debug, emoji 🧪):
  - "🧪 בדוק את החישוב" → `testCheckoutLayout()`

---

### Credit Limit Box (credit-box):

Clickable: `onclick="openCreditDetail()"`

```
מסגרת אשראי — קבלן
שוטף +60 · פרטים ›

[████░░░░░░░░░░░░░░]

נוצל: ₪150,000         פנוי: ₪85,000 מתוך ₪235,000
```

- **Top Row (cb-top):**
  - Left: "מסגרת אשראי — קבלן"
  - Right: "שוטף +60 · פרטים ›"

- **Progress Bar (cb-bar):**
  - Visual bar showing credit used
  - Width: `[grandTotal / creditLimit × 100]%` (max 100%)

- **Bottom Row (cb-row):**
  - Left: "נוצל: ₪[used amount]"
  - Right: "פנוי: ₪[available] מתוך ₪[limit]"

---

### Confirm Order Button:

```
✓ אשר הזמנה · משלוח למגדל הרצליה
```

- Large primary button (blue #1f6f6b, white text)
- Icon: Checkmark SVG
- Text: "אשר הזמנה · משלוח ל[project name]"
- Click: `checkout()`
- Top margin: 12px

---

## Key Interactive Flows:

### Remove Item:
- Click 🗑️ → `removeCartItem(index)` → re-render

### Adjust Quantity:
- Click ± → `stepCartQty(index, ±1)` → re-render
- Click qty → `openCartQtyInput(index)` → modal

### Change Haul Type (single-wave):
- Click haul → `pickHaul(storeId, haulId)` → re-render

### Choose Delivery Slot (single-wave):
- Click slot → `pickSlot(index)` → re-render

### Split into Multi-Wave:
- Click "חלק לגלים ›" → `openCartShipPlanner()`

### Change Site:
- Click "החלף ›" → `openCartSitePicker()`

### View Payment Details:
- Click checkout-box → `openPaymentDetail()` → modal

### View Credit Details:
- Click credit-box → `openCreditDetail()` → modal

### Confirm Order:
- Click "אשר הזמנה" → `checkout()`
  - Validates stock
  - Creates order object
  - Saves via API/localStorage
  - Toast confirmation
  - Redirects to orders tab

---

# Tab 5: Profile/Identity

**Primary:** User profile, gamification, stats, achievements

---

## Hero Card:

```
🧪 דוגמה (demo mode)

Benjamin Kahana
Contractor · בונה
⭐⭐⭐⭐⭐ (5 stars)

🏗️ מגדל הרצליה
```

- **Avatar/Icon:** 🧪 (demo) or emoji
- **Name:** User's full name (or בונה/contractor in demo)
- **Title/Role:** Contractor + specialty
- **Star Rating:** 1-5 stars
- **Current Site:** 🏗️ [site name]

---

## Stats Section:

```
📊 הנתונים שלך
₪342,500     18       7       94%
הוצאה עד כה  הזמנות  אתרים   דירוג
```

Four stat columns:
- **Spent:** "₪[amount]" — הוצאה עד כה
- **Orders:** "[N]" — הזמנות
- **Sites:** "[N]" — אתרים
- **Rating:** "[%]%" — דירוג

---

## Spending Section:

```
💰 הוצאה על אתר זה
₪150,000 / ₪235,000 תקציב

[██████░░░░░░░░░░░░]
63% ניצול תקציב
```

- Header: "💰 הוצאה על אתר זה"
- Progress bar: `[spent / budget × 100]%`
- Usage text: "[%]% ניצול תקציב"
- Clickable: `onclick="go('sites')"` → view full budget detail

---

## Perk Section:

```
🎁 היתרון שלך
⭐⭐⭐ ערכת נושא מותאמת אישית

השתתפות: 7 פרויקטים
```

- Header: "🎁 היתרון שלך"
- **Perk Card:**
  - Icon + name: e.g., "⭐⭐⭐ ערכת נושא מותאמת אישית"
- **Stats:** "השתתפות: [N] פרויקטים"

---

## Achievements Section:

```
🏆 התוצאות שלך
🔨 בנאי   🚿 מתקין   💪 חזק   🌟 מובהק
📚 חוקר   🎯 מדויק   ⚡ מהיר    🏅 חיסכון
```

**8 Achievement Badges:**
- Each badge: emoji + Hebrew label
- Examples: 🔨 בנאי, 🚿 מתקין, 💪 חזק, etc.
- Icons indicate skills/accomplishments

---

## Ranks Ladder Section:

```
🪜 סולם הדרגות

🟢 דרגה 1 — קבלן חדש              (current)
🔵 דרגה 2 — קבלן מנוסה            
⭐ דרגה 3 — קבלן בכיר             
👑 דרגה 4 — מנהל פרויקטים         
```

- **Ladder:**
  - Each rank: level + title
  - Current rank highlighted (green 🟢)
  - Next ranks: blue 🔵, star ⭐, crown 👑
- **Progress to next:** implicit or percentage

---

## Gamification Hub:

**Clickable section:** `onclick="openGamificationHub()"`

- Shows detailed breakdown of achievements, unlocked perks
- Experience points, progress toward next rank
- Interactive challenges/goals

---

## Settings Links:

```
🔗 מהירות גישה

⚙️ הגדרות [›]
```

- Links to Settings menu
- Quick access to configuration

---

# Overlays & Modals

## Settings Menu (Dial-Based)

**Structure:** Hierarchical tree with dials and toggles

- **Top Level Sections:**
  1. תצוגה (Display)
  2. התראות (Notifications)
  3. נגישות (Accessibility)
  4. אזור ושפה (Region & Language)
  5. משלוח (Delivery)
  6. מידע (About)
  7. איפוס (Reset)
  8. אבטחה (Security) — 23 items
  9. שירות ותמיכה (Support) — 15 items

**For Each Setting:**
- Option component (dial, toggle, select, or link)
- Hebrew label
- Icon (emoji)
- Sub-options (if hierarchical)

**Dials:** Each setting option = circle + label (R4 compliance)

---

## Notification Bell

**List of notifications with unread count:**

- Notification item: icon, text, timestamp
- Click item → opens detail sheet
- Mark as read on view
- Breadcrumb path: "title › detail lines › action button"

---

## Search Overlays

**Catalog Search:** `catSearchSuggest`  
**Home Search:** `homeSearchSuggest`  
**Category Navigation Search:** `catNavSuggest`

All follow same pattern:
- Real-time results
- Breadcrumb paths
- Kind labels (product, accessory, category, screen)
- Fuzzy fallback for typos

---

# Data Structures

## TREES Object:

```javascript
TREES[key] = {
  name: string,
  img: emoji or icon,
  image: optional URL,
  category: string,
  subcat: string,
  brands: [{brand, price, rec, tag}, ...],
  acc: [{name, img, price, stock}, ...],  // accessories
  catalogProduct: boolean,
  productType: string,
  secondary: string,
  diameter: string,
  // ... other attributes for drill navigation
}
```

## VARIANTS Object:

```javascript
VARIANTS[key] = {
  label: string,
  opts: [
    {name, diameter, delta, ...},
    ...
  ]
}
```

## CATALOG Array:

```javascript
CATALOG = [
  {cat: "ברזים", icon: "🚰", items: [key1, key2, ...]},
  {cat: "אסלות", icon: "🚽", items: [...]},
  ...
]
```

## DIAGRAMS Object:

```javascript
DIAGRAMS[treeKey] = {
  title: string,
  stages: [
    {ic: "icon_key", l: "label", s: "subtitle", match: [keywords]},
    ...
  ]
}
```

## Projects Array:

```javascript
PROJECTS = [
  {
    id: string,
    name: string,
    addr: string,
    manager: string,
    cart: [],
    treeProgress: {}
  },
  ...
]
```

## Cart Item:

```javascript
{
  name: string,
  img: emoji,
  price: number,
  qty: number,
  auto: boolean,  // auto-added from tree
  store: string   // supplier store ID
}
```

## Order Object:

```javascript
{
  id: string,
  createdAt: ISO string,
  status: 'pending'|'processing'|'shipped'|'delivered',
  project: {site, stage},
  delivery: {day, window},
  items: [{name, qty, price, auto, store, supplier}, ...],
  suppliers: [{store, storeId, subtotal, shipping}, ...],
  totals: {itemsSubtotal, shippingTotal, vatRate, vat, grandTotal},
  shipments: optional [{idx, lineIdx, when, site, haul}, ...] // multi-wave
}
```

---

# Key Patterns

## Search Pattern:

Home/Catalog → Search input → Real-time suggestions → Breadcrumb path → Click → Navigate

## Drill-Down Pattern:

Catalog categories → Attribute steps (auto-skipped if 0-1 values) → Products → Product tree

## Product Tree Pattern:

Product card → Click → Overlay opens → Hero section + diagram + accessories + tree button → Add to cart

## Cart Flow:

Add product → Quantity controls → Choose haul/slot → View summary → Confirm order → Redirect to orders

## Site Management:

View all sites → Select active → View/edit details → Switch project → Cart follows

## Smart Project:

Day-by-day breakdown → Mark complete → Track progress → Accessories tied to stages → View diagram

## Mobile Gestures:

- Tap to select/toggle
- Swipe to scroll (horizontal rows)
- Long-press (if applicable)
- Pull-down to refresh (implied)

---

**הועד בהצלחה.** ✓

