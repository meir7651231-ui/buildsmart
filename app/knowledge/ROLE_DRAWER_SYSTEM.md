# Role Drawer System — Multi-Persona Architecture

**Document Version:** 1.0  
**Last Updated:** 2026-05-21  
**Deep Dive Scope:** 🎯 **Role Selection & Multi-Role Dashboard System** — Complete onboarding to role-specific dashboards  
**Status:** ✅ Complete — All 5 roles + flows documented  

---

## Table of Contents

1. [Overview](#overview)
2. [Role Drawer UI](#role-drawer-ui)
3. [Role 1: קבלן (Contractor)](#role-1-קבלן-contractor)
4. [Role 2: מנהל המערכת (System Manager)](#role-2-מנהל-המערכת-system-manager)
5. [Role 3: חנות ספק (Supplier Store)](#role-3-חנות-ספק-supplier-store)
6. [Role 4: שליח (Courier)](#role-4-שליח-courier)
7. [Role 5: עובד (Field Worker)](#role-5-עובד-field-worker)
8. [Role Selection Flow](#role-selection-flow)
9. [Data & State Management](#data--state-management)

---

# Overview

**BuildSmart Multi-Persona System:**

The application supports **5 distinct roles**, each with:
- Unique login/onboarding flow
- Role-specific dashboard
- Custom tab navigation
- Domain-specific features
- Different data access levels

**Entry Point:** Role Drawer accessible from Welcome screen via hamburger menu (☰ "מי אתה?")

**Shared Architecture:**
- All roles share same underlying data model (PROJECTS, TASKS, ORDERS, etc.)
- Single database/state tree
- RBAC layer controls visibility
- Demo mode allows seamless switching between roles

---

# Role Drawer UI

**Component:** `.role-drawer` with `.role-drawer-scrim` overlay

**Trigger:**
- Hamburger button: `.welcome-hamburger` on welcome screen
- `onclick="toggleRoleDrawer()"`
- Toggles `.show` class on drawer and scrim

**Visual Structure:**

```
╔════════════════════════════════╗
║ מי אתה?                         ║
║ בחר תפקיד כדי להיכנס             ║
├════════════════════════════════┤
║ 👷 קבלן                         ║
║ הזמנת חומרים, מלאי, משימות      ║
├════════════════════════════════┤
║ 👔 מנהל המערכת                   ║
║ ניהול מוצרים, חנויות, לקוחות    ║
├════════════════════════════════┤
║ 🏪 חנות ספק                     ║
║ הזמנות נכנסות, מלאי החנות       ║
├════════════════════════════════┤
║ 🛵 שליח                         ║
║ משלוחים ועדכוני סטטוס            ║
├════════════════════════════════┤
║ 🦺 עובד                         ║
║ המשימות שהוקצו לי בשטח           ║
├════════════════════════════════┤
║ הדגמה — כל התצוגות חולקות       ║
║ מאגר נתונים אחד                  ║
╚════════════════════════════════╝
```

## Drawer Header (rd-head):

- **Title:** "מי אתה?" (Who are you?)
- **Subtitle:** "בחר תפקיד כדי להיכנס" (Choose a role to enter)

---

## Role Selection Buttons (role-pick-btn):

**For Each Role:**

### Button Structure:
```
┌─ [icon] ── [title] ───────────────── [arrow] ─┐
│             [subtitle describing features]     │
└─────────────────────────────────────────────────┘
```

- **Left Icon (rpb-ic):** Emoji — 👷, 👔, 🏪, 🛵, 🦺
- **Center Text (rpb-txt):**
  - Bold title: Role name in Hebrew
  - Small gray subtitle: Key features/responsibilities
- **Right Arrow (rpb-arrow):** "‹" — visual affordance
- **Click Handler:** `onclick="enterRole('[role-name]')"`

### Buttons (in order):

1. **קבלן (Contractor)**
   - Icon: 👷
   - Features: הזמנת חומרים, מלאי, משימות
   - Action: `enterRole('contractor')`

2. **מנהל המערכת (System Manager)**
   - Icon: 👔
   - Features: ניהול מוצרים, חנויות, לקוחות
   - Action: `enterRole('manager')`

3. **חנות ספק (Supplier Store)**
   - Icon: 🏪
   - Features: הזמנות נכנסות, מלאי החנות
   - Action: `enterRole('store')`

4. **שליח (Courier)**
   - Icon: 🛵
   - Features: משלוחים ועדכוני סטטוס
   - Action: `enterRole('courier')`

5. **עובד (Field Worker)**
   - Icon: 🦺
   - Features: המשימות שהוקצו לי בשטח
   - Action: `enterRole('worker')`

---

## Drawer Footer (rd-foot):

- "הדגמה — כל התצוגות חולקות מאגר נתונים אחד"
- Translation: "Demo — all views share one database"
- Explains interconnected nature of the system

---

# Role 1: קבלן (Contractor)

**Primary Use Case:** Construction contractors ordering materials and managing projects  
**Entry Point:** Role Drawer → `enterRole('contractor')`

## Flow:

```
Role Drawer
    ↓
enterRole('contractor')
    ↓
showScreen('screen-login')  [Contractor login screen]
    ↓
(optional) screen-profession [Choose specialty]
    ↓
(optional) screen-prep [Loading/checklist]
    ↓
enterApp() [Main contractor dashboard — view-home]
```

---

## screen-login (Contractor Login Screen):

**Purpose:** Authenticate existing contractor or welcome new user

**Visual Elements:**

```
╔════════════════════════════════╗
║           [Back ‹]              ║
║                                 ║
║   🏠 Logo                        ║
║   BuildSmart                     ║
║   מהשרטוט עד האתר — בלי לשכוח כלום  ║
│                                 │
│ ברוך הבא 👋                     │
│ התחבר כדי להתחיל לעבוד           │
│                                 │
│ [📱 טלפון]                      │
│ 050-0000000                      │
│                                 │
│ [המשך] (Amber button)           │
│                                 │
│ או                              │
│                                 │
│ [כניסה עם פרטי אחרים]            │
╚════════════════════════════════╝
```

**Components:**

- **Back Button:** `onclick="showScreen('screen-welcome')"` → returns to role drawer
- **Logo Section:**
  - Branded SVG logo (house icon)
  - "BuildSmart" branding
  - Tagline: "מהשרטוט עד האתר — בלי לשכוח כלום" (From sketch to site — forget nothing)

- **Header:**
  - "ברוך הבא 👋" (Welcome 👋)
  - "התחבר כדי להתחיל לעבוד" (Log in to start working)

- **Phone Input (login-field):**
  - Label: "מספר טלפון"
  - Placeholder: "050-0000000"
  - Input type: `tel`
  - inputmode: `tel`

- **Continue Button:**
  - Style: `.btn.btn-amber`
  - Text: "המשך" (Continue)
  - `onclick="loginExisting()"`

- **Alternative Action:**
  - "או" (or)
  - Alternative button: "כניסה עם פרטי אחרים" (Login with other details)

---

## Contractor Dashboard (view-home):

**After login/profession selection, contractor enters the main 5-tab dashboard:**

1. 🏠 **בית** (Home)
   - Discovery, search, quick products
   - Reorder history
   - Quick action cards

2. 📋 **קטלוג** (Catalog)
   - Product browsing
   - Smart product trees
   - Categories and drill-down

3. 🏗️ **הפרויקטים** (Projects)
   - My Project (task breakdown)
   - My Sites (multi-site management)

4. 🛒 **רכש** (Cart)
   - Shopping cart
   - Order summary
   - Checkout

5. 👤 **חשבון** (Profile)
   - User profile
   - Gamification
   - Achievements

---

# Role 2: מנהל המערכת (System Manager)

**Primary Use Case:** Managing products, stores, customers, and system operations  
**Entry Point:** Role Drawer → `enterRole('manager')`

## Flow:

```
Role Drawer
    ↓
enterRole('manager')
    ↓
showScreen('screen-manager')  [Manager dashboard]
    ↓
admTab('m-products')  [Default tab]
```

---

## screen-manager (Manager Dashboard):

**Purpose:** System administration dashboard with 4 main tabs

**Visual Structure:**

```
╔════════════════════════════════╗
║  ‹ יציאה    👔 מנהל המערכת      ║
├════════════════════════════════┤
║ [📊] [🚚] [👥] [🛠️]            ║
║ לוח ה... הזמנות ... לקוחות ... ניהול ...  ║
├════════════════════════════════┤
│                                │
│  [Tab content here]            │
│                                │
└════════════════════════════════┘
```

### Header Section (adm-top):

- **Back Button (adm-back):**
  - Text: "‹ יציאה" (Exit)
  - `onclick="showScreen('screen-welcome')"` → back to role drawer

- **Title (adm-title):**
  - "👔 מנהל המערכת" (System Manager)

---

### Tab Navigation (adm-tabs):

4 tabs with icons and labels:

| Icon | Label | Handler | ID |
|------|-------|---------|-----|
| 📊 | לוח בקרה (Dashboard) | `admTab('m-products')` | `m-products` |
| 🚚 | הזמנות (Orders) | `admTab('m-orders')` | `m-orders` |
| 👥 | לקוחות (Customers) | `admTab('m-customers')` | `m-customers` |
| 🛠️ | ניהול (Management) | `admTab('m-manage')` | `m-manage` |

**Styling:**
- Active tab: `.on` class
- Click: `onclick="admTab('[tab-id]')"`

---

### Tab Panes (adm-body):

**Container Structure:**

```
adm-body
├── pane-m-products (default: .on)
│   └── mgrDashboard [content]
├── pane-m-orders
│   └── mgrOrderList [content]
├── pane-m-customers
│   └── mgrCustomers [content]
└── pane-m-manage
    └── mgrManage [content]
```

**Pane Architecture:**
- Class `.adm-pane` for each
- Default pane has `.on` class (visible)
- `admTab()` removes all `.on`, adds to selected pane

---

### Tab 1: 📊 לוח בקרה (Dashboard/Products):

**Container:** `mgrDashboard`

Content: Product management overview, metrics, analytics

---

### Tab 2: 🚚 הזמנות (Orders):

**Container:** `mgrOrderList`

Content: All contractor orders, statuses, fulfillment tracking

---

### Tab 3: 👥 לקוחות (Customers):

**Container:** `mgrCustomers`

Content: Contractor list, profiles, credit limits, history

---

### Tab 4: 🛠️ ניהול (Management):

**Container:** `mgrManage`

Content: Store management, system settings, configuration

---

### Detail Overlay (mgrStoreDetailOverlay):

Sheet-style modal for detailed operations

---

# Role 3: חנות ספק (Supplier Store)

**Primary Use Case:** Managing incoming orders and inventory from supplier perspective  
**Entry Point:** Role Drawer → `enterRole('store')`

## Flow:

```
Role Drawer
    ↓
enterRole('store')
    ↓
showScreen('screen-store-login')  [Store selection screen]
    ↓
renderStoreLogin() [Choose which store]
    ↓
storePortal() [Authenticate]
    ↓
showScreen('screen-store')  [Store dashboard]
```

---

## screen-store-login (Store Selection Screen):

**Purpose:** Multi-store access — store staff select their store

**Visual Structure:**

```
╔════════════════════════════════╗
║  ‹ חזרה                          ║
║                                 ║
║  🏪                              ║
║  כניסת ספקים                     ║
║  בחר את החנות שלך כדי להיכנס      ║
║  לפורטל הניהול                  ║
│                                 │
│  [Store 1] [Store 2] [Store 3]  │
│                                 │
│  🔒 באפליקציה האמיתית כל ספק   │
│  מתחבר עם קוד גישה אישי.       │
│  זוהי כניסת הדגמה.             │
╚════════════════════════════════╝
```

**Components:**

- **Back Button:**
  - `onclick="showScreen('screen-welcome')"`

- **Logo (sl-logo):** 🏪

- **Title (sl-title):** "כניסת ספקים" (Supplier Login)

- **Subtitle (sl-sub):** "בחר את החנות שלך כדי להיכנס לפורטל הניהול"

- **Store List (storeLoginList):**
  - Rendered by: `renderStoreLogin()`
  - List of selectable stores
  - Click store → authenticate and enter store dashboard

- **Security Note (sl-note):**
  - "🔒 באפליקציה האמיתית כל ספק מתחבר עם קוד גישה אישי. זוהי כניסת הדגמה."

---

## screen-store (Store Dashboard):

**Purpose:** Store staff dashboard with 4 tabs for order and inventory management

**Visual Structure:**

```
╔════════════════════════════════╗
║  ‹ יציאה    🏪 [Store Name]     ║
├════════════════════════════════┤
║ [🏠] [📥] [📦] [🧰]            ║
║  בית ... הזמנות ... מלאי ... פורטל  ║
├════════════════════════════════┤
│                                │
│  [Tab content here]            │
│                                │
└════════════════════════════════┘
```

### Header Section:

- **Back Button (adm-back):**
  - Text: "‹ יציאה" (Exit)
  - `onclick="storeLogout()"`

- **Title (adm-title):**
  - "🏪 חנות ספק" (with store name, e.g., "🏪 מחסני בנייה א'")
  - ID: `storeTitle` (dynamically set)

---

### Tab Navigation (adm-tabs):

4 tabs for store operations:

| Icon | Label | Handler | ID |
|------|-------|---------|-----|
| 🏠 | בית (Home) | `admTab('s-home')` | `s-home` |
| 📥 | הזמנות (Incoming Orders) | `admTab('s-orders')` | `s-orders` |
| 📦 | מלאי (Inventory) | `admTab('s-stock')` | `s-stock` |
| 🧰 | פורטל (Store Portal) | `admTab('s-portal')` | `s-portal` |

---

### Tab Panes:

**Pane 1: 🏠 בית (Home)**
- Container: `storeHome`
- Content: Store overview, key metrics, summary

**Pane 2: 📥 הזמנות (Orders)**
- Container: `storeOrderList`
- Note: "אשר הזמנות והכן אותן — הסטטוס יעבור לשליח ולמנהל."
- Content: List of incoming contractor orders, approval/preparation workflow

**Pane 3: 📦 מלאי (Stock)**
- Container: `storeStockList`
- Note: "מוצר שאזל לא יוצג לקבלנים בקטלוג."
- Content: Current inventory, stock levels, availability management

**Pane 4: 🧰 פורטל (Store Portal)**
- Container: `storePortal`
- Note: "כלי הספק — דירוג, SLA, אזורי הפצה, הנחות כמות וברקודים."
- Content: Store tools — ratings, SLA, delivery zones, volume discounts, barcodes

---

### Detail Overlay (storePickOverlay):

Sheet-style modal for store operations details

---

# Role 4: שליח (Courier)

**Primary Use Case:** Managing deliveries and updating order status in real-time  
**Entry Point:** Role Drawer → `enterRole('courier')`

## Flow:

```
Role Drawer
    ↓
enterRole('courier')
    ↓
showScreen('screen-courier')  [Courier dashboard]
    ↓
renderCourier() [Populate content]
```

---

## screen-courier (Courier Dashboard):

**Purpose:** Single-purpose dashboard for delivery management

**Visual Structure:**

```
╔════════════════════════════════╗
║  ‹ יציאה    🛵 שליח · משאית 14  ║
├════════════════════════════════┤
│                                │
│ [Courier home summary]         │
│ [Delivery queue list]          │
│                                │
└════════════════════════════════┘
```

**Note:** Unlike manager/store, courier has only ONE pane (no tabs)

### Header Section:

- **Back Button (adm-back):**
  - Text: "‹ יציאה" (Exit)
  - `onclick="showScreen('screen-welcome')"`

- **Title (adm-title):**
  - "🛵 שליח · משאית [vehicle ID]"
  - e.g., "🛵 שליח · משאית 14"

---

### Content Area (adm-body):

Single `.adm-pane` with `.on` class

**Sections:**

1. **Courier Home (courierHome):**
   - Summary of current day's deliveries
   - Route information
   - Current status
   - Rendered by: `renderCourierHome()`

2. **Delivery List (courierList):**
   - Queue of orders to deliver
   - Status updates for each
   - Route optimization info
   - Rendered by: `renderCourierList()`

---

### Detail Overlay (courierDetailOverlay):

Sheet-style modal for delivery details

---

# Role 5: עובד (Field Worker)

**Primary Use Case:** Field worker receiving and completing assigned tasks  
**Entry Point:** Role Drawer → `enterRole('worker')`

## Flow:

```
Role Drawer
    ↓
enterRole('worker')
    ↓
showScreen('screen-worker')  [Worker dashboard]
    ↓
renderWorker() [Populate content]
```

---

## screen-worker (Worker Dashboard):

**Purpose:** Simplest dashboard — field worker task management

**Visual Structure:**

```
╔════════════════════════════════╗
║  ‹ יציאה    🦺 עובד              ║
├════════════════════════════════┤
│                                │
│ בחר את שמך, בצע את המשימה,     │
│ צרף תמונה ושלח לאישור המנהל.   │
│                                │
│ [דוד כהן] [אברהם] [עלי]        │
│                                │
│ [Active tasks]                 │
│ [Queue tasks]                  │
│ [Submitted/done]               │
│                                │
└════════════════════════════════┘
```

### Header Section:

- **Back Button (adm-back):**
  - Text: "‹ יציאה" (Exit)
  - `onclick="showScreen('screen-welcome')"`

- **Title (adm-title):**
  - "🦺 עובד" (Field Worker)

---

### Content Area (adm-body):

Single `.adm-pane` with `.on` class

**Components:**

1. **Instruction (adm-note):**
   - "בחר את שמך, בצע את המשימה, צרף תמונה ושלח לאישור המנהל."
   - Translation: "Choose your name, complete the task, attach a photo, and submit for manager approval."

2. **Worker Picker (workerPick):**
   - List of worker names as buttons
   - e.g., [דוד כהן] [אברהם שחף] [עלי כהן]
   - `onclick="pickWorkerScreen([index])"`
   - Default: `activeWorker` is pre-selected

3. **Tasks Body (workerTasksBody):**
   - Rendered by: `renderWorker()`
   - Shows task queue in 3 sections:
     - **Active:** Current assigned task
     - **Queue:** Pending tasks waiting
     - **Submitted:** Tasks awaiting manager review or already completed

---

### Task Filtering Logic:

**For selected worker, tasks are categorized:**

- **Current Task:** `status === 'active'` OR `status === 'rejected'`
- **Queue:** `status === 'pending'`
- **Submitted:** `status === 'review'` OR `status === 'done'`

**Progress Metric:**
- `doneCount` = tasks with `status === 'done'`
- `total` = all assigned tasks to worker
- Progress % = `Math.round(doneCount / total * 100)`

---

# Role Selection Flow

## Complete User Journey:

### Entry Point:

1. **Welcome Screen (screen-welcome):**
   - Green button: "כניסה ללקוח קיים" (Existing customer login)
   - Registration form: name + contact
   - Demo button: "המשך ללא רישום"
   - Hamburger menu: "מי אתה?" (role drawer)

2. **Role Drawer Activation:**
   - Click hamburger: `toggleRoleDrawer()` → opens side drawer with 5 roles
   - Scrim overlay: `onclick="toggleRoleDrawer()"` to close
   - Select role: `enterRole('[role-name]')`

---

## Role-Specific Flows:

### Contractor Flow:
```
Role Drawer → enterRole('contractor')
  ↓
showScreen('screen-login')
  ↓ [optional] pickProfession()
  ↓
showScreen('screen-profession')  [Choose specialty]
  ↓ [optional]
showScreen('screen-prep')  [Loading checklist]
  ↓
enterApp()  [Main 5-tab dashboard]
```

### Manager Flow:
```
Role Drawer → enterRole('manager')
  ↓
showScreen('screen-manager')
  ↓
admTab('m-products')  [Default tab]
```

### Store Flow:
```
Role Drawer → enterRole('store')
  ↓
showScreen('screen-store-login')
  ↓
renderStoreLogin()  [Choose store]
  ↓
storePortal() → showScreen('screen-store')
```

### Courier Flow:
```
Role Drawer → enterRole('courier')
  ↓
showScreen('screen-courier')
  ↓
renderCourier()  [Populate delivery queue]
```

### Worker Flow:
```
Role Drawer → enterRole('worker')
  ↓
showScreen('screen-worker')
  ↓
renderWorker()  [Show task queue]
  ↓
pickWorkerScreen([index])  [Choose your name]
```

---

## Backend Actions on Role Selection:

**Function: `enterRole(role)`**

1. **Close drawer:** Remove `.show` class from drawer and scrim
2. **RBAC Sync:** `appStore.set({role: role})` — updates permissions layer
3. **Audit Log:** `auditLog('מעבר תפקיד', role)` — logs role switch
4. **Navigate:** Route to role-specific screen
5. **Render:** Populate content for selected role

---

# Data & State Management

## Global State Variables:

```javascript
let entryMode = 'demo'|'new'|'existing'
  // Tracks user entry state: demo, new customer, or returning customer

let userName = ''
  // Filled for registered/existing customers

let userProfession = 'קבלן'|'חשמלאי'|'קבלן שיפוצים'
  // Selected profession/specialty (contractor only)

let activeWorker = 0  // Index of selected worker in WORKERS[]

let taskRole = 'worker'  // Context for task operations
```

---

## RBAC (Role-Based Access Control):

**Implemented via:**
- `appStore` — centralized state management
- `role` property — tracks current role
- Conditional rendering based on `role` value

**Role Values:**
- `'contractor'` — Contractor dashboard
- `'manager'` — System manager dashboard
- `'store'` — Store dashboard
- `'courier'` — Courier dashboard
- `'worker'` — Field worker dashboard

---

## Shared Data Model:

**All roles access:**
- `PROJECTS[]` — sites/projects
- `TASKS[]` — work tasks
- `ORDERS[]` — system orders
- `WORKERS[]` — field workers list
- `SYS_ORDERS[]` — system-wide order queue

**Data is filtered/restricted per role:**
- Contractors see only their projects/orders
- Managers see all system data
- Store sees only their orders
- Courier sees only their assigned deliveries
- Worker sees only their assigned tasks

---

## Demo Note:

**Single Database for All Roles:**
- Bottom of role drawer: "הדגמה — כל התצוגות חולקות מאגר נתונים אחד"
- When switching roles, same underlying data is viewed through different lenses
- Changes in one role appear in other roles
- Useful for testing, demos, and understanding system integration

---

**צלילה הרול מסיימת.** ✓

