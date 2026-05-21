# System Manager Dashboard — Admin Control Panel

**Document Version:** 1.0  
**Last Updated:** 2026-05-21  
**Deep Dive Scope:** 👔 **מנהל המערכת (System Manager) Dashboard** — Complete admin interface with 4 control tabs  
**Status:** ✅ Complete — All 4 tabs, layouts, components, and data flows documented  
**Part of Series:** BuildSmart Master Index (`UI_ARCHITECTURE.md`)

---

## Table of Contents

1. [Overview](#overview)
2. [Dashboard Access & Authentication](#dashboard-access--authentication)
3. [Screen Structure](#screen-structure)
4. [Tab 1: 📊 לוח בקרה (Dashboard/Products)](#tab-1--לוח-בקרה-dashboardproducts)
5. [Tab 2: 🚚 הזמנות (Orders)](#tab-2--הזמנות-orders)
6. [Tab 3: 👥 לקוחות (Customers)](#tab-3--לקוחות-customers)
7. [Tab 4: 🛠️ ניהול (Management)](#tab-4--ניהול-management)
8. [Detail Overlays & Modals](#detail-overlays--modals)
9. [Tab Navigation & State](#tab-navigation--state)
10. [Data Structures & APIs](#data-structures--apis)

---

# Overview

**Role:** System Manager / Administrator  
**Purpose:** Centralized control panel for all platform operations  
**Access Point:** Role Drawer → Select "מנהל המערכת" → Instant access to manager dashboard  
**Screen ID:** `screen-manager` (fullscreen admin-screen)

**Responsibilities:**
- Monitor product catalog and inventory
- Track all contractor orders system-wide
- Manage customer accounts and credit limits
- Configure system settings and operations
- View analytics and performance metrics

**Key Differentiator:** 
- Unrestricted access to ALL system data
- 4-tab interface for different operational areas
- Overlay modals for detailed operations
- Direct store management integration

---

# Dashboard Access & Authentication

## Entry Flow:

```
Role Drawer (screen-welcome)
    ↓
Click "👔 מנהל המערכת" button
    ↓
enterRole('manager')
    ↓
appStore.set({role: 'manager'})  [Update RBAC]
    ↓
showScreen('screen-manager')
    ↓
admTab('m-products')  [Default tab]
```

**No additional login required in demo mode** — role selection grants access

---

# Screen Structure

## HTML Layout:

```html
<div class="fullscreen admin-screen" id="screen-manager">
  <div class="adm-top">
    <div class="adm-back">‹ יציאה</div>
    <div class="adm-title">👔 מנהל המערכת</div>
  </div>
  <div class="adm-tabs">
    [4 tab buttons]
  </div>
  <div class="adm-body">
    [4 content panes]
  </div>
  <div class="overlay">
    [Detail overlay modals]
  </div>
</div>
```

---

## Visual Layout:

```
╔════════════════════════════════════════════╗
║  ‹ יציאה              👔 מנהל המערכת      ║  [adm-top]
╠════════════════════════════════════════════╣
║ [📊] [🚚] [👥] [🛠️]                       ║  [adm-tabs]
║  לוח בקרה  הזמנות  לקוחות  ניהול          ║
╠════════════════════════════════════════════╣
│                                            │
│  [Tab 1 Content]                           │
│  [Dashboard / Products]                    │
│                                            │
│  (switches based on selected tab)         │
│                                            │
└════════════════════════════════════════════┘
```

---

## Top Section (adm-top):

### Back Button (adm-back):

- **Text:** "‹ יציאה" (Exit)
- **Action:** `onclick="showScreen('screen-welcome')"`
- **Behavior:** Returns to role drawer
- **Style:** Left-aligned, clickable

### Title (adm-title):

- **Text:** "👔 מנהל המערכת" (System Manager)
- **Icon:** 👔 (business person emoji)
- **Alignment:** Center
- **Size:** Large, prominent

---

## Tab Navigation (adm-tabs):

**4 tabs for different management areas:**

### Structure Per Tab Button:

```
┌─────────────────────────┐
│ [icon] [label]          │
│                         │
│ onClick: admTab('id')   │
│ Class: .adm-tab (.on)   │
└─────────────────────────┘
```

---

### Tabs Overview:

| # | Icon | Label | ID | Handler | Purpose |
|---|------|-------|----|----|---------|
| 1 | 📊 | לוח בקרה | `m-products` | `admTab('m-products')` | Dashboard & product overview |
| 2 | 🚚 | הזמנות | `m-orders` | `admTab('m-orders')` | All system orders tracking |
| 3 | 👥 | לקוחות | `m-customers` | `admTab('m-customers')` | Contractor accounts management |
| 4 | 🛠️ | ניהול | `m-manage` | `admTab('m-manage')` | System configuration & tools |

---

### Tab Button Styling:

- **Default:** No special styling
- **Active (`.on`):** Highlighted, shows active state
- **Click:** Triggers `admTab('[tab-id]')`
- **Behavior:**
  - Removes `.on` from all panes
  - Adds `.on` to selected pane
  - Calls render function if needed

---

## Content Body (adm-body):

**Container for 4 content panes:**

### Pane Architecture:

```
adm-body
├── adm-pane (.on)  [pane-m-products]
│   └── mgrDashboard  [content container]
│
├── adm-pane         [pane-m-orders]
│   └── mgrOrderList  [content container]
│
├── adm-pane         [pane-m-customers]
│   └── mgrCustomers  [content container]
│
└── adm-pane         [pane-m-manage]
    └── mgrManage     [content container]
```

**CSS Classes:**
- `.adm-pane` — pane container
- `.on` — visible pane (only one at a time)

---

# Tab 1: 📊 לוח בקרה (Dashboard/Products)

**Purpose:** System overview and product catalog management  
**Container ID:** `mgrDashboard`  
**Pane ID:** `pane-m-products`  
**Tab ID:** `m-products`  
**Default:** Yes (loads first when entering manager role)

---

## Content Sections:

### A. System Overview Metrics

**Displays key performance indicators:**

```
╔═══════════════════════════════════════╗
║ System Overview                       ║
├───────────────────────────────────────┤
║ 📦 Products:          1,247           ║
║ 👥 Active Contractors: 156            ║
║ 🛒 Total Orders:      3,892           ║
║ 💰 Revenue (Month):   ₪847,500        ║
║ 📈 Growth:            +12% vs last mo  ║
╚═══════════════════════════════════════╝
```

**Metrics might include:**
- Total products in catalog
- Active contractor count
- Monthly order volume
- Revenue/sales metrics
- Growth indicators
- System health status

---

### B. Product Catalog Management

**Browsable product list with management controls:**

**For each product:**
```
┌─────────────────────────────────────────┐
│ 🚽 ברז אמבטיה        [קטגוריה: אינסטלציה] │
│ ספק: בנייני העיר     Stock: 156           │
│ מחיר: ₪245           [ערוך] [הסתר]        │
└─────────────────────────────────────────┘
```

**Available Actions Per Product:**
- View details
- Edit product info
- Update pricing
- Hide/show from catalog
- View usage statistics

---

### C. Analytics & Reports

**Performance visualization:**
- Top products (by orders)
- Sales trends (graph)
- Supplier performance
- Regional order distribution
- Seasonal patterns

---

## Interactions:

- **Click product row:** Opens detail overlay with full product information
- **Edit button:** Opens product editor modal
- **Hide button:** Toggles product visibility in contractor catalog
- **Stock indicator:** Shows current inventory level
- **Price display:** Current list price

---

# Tab 2: 🚚 הזמנות (Orders)

**Purpose:** Centralized order tracking and management  
**Container ID:** `mgrOrderList`  
**Pane ID:** `pane-m-orders`  
**Tab ID:** `m-orders`

---

## Content Structure:

### Order List Layout:

**System-wide view of ALL contractor orders:**

```
╔═══════════════════════════════════════════════════════════╗
║ הזמנות — סינון וחיפוש                                     ║
├───────────────────────────────────────────────────────────┤
║ [חיפוש הזמנה...]  [סינן לפי סטטוס ▼]  [מיין ▼]         ║
├───────────────────────────────────────────────────────────┤
║ הזמנה   | קבלן        | סכום    | סטטוס   | תאריך | פעולה ║
├─────────┼─────────────┼─────────┼─────────┼───────┼──────┤
║ BS-1042 | דוד כהן     | ₪1,560  | בהכנה   | 21/5  │ 📄   ║
║ BS-1041 | אברהם שחף   | ₪2,340  | בדרך    | 20/5  │ 📄   ║
║ BS-1040 | עלי כהן     | ₪890    | נמסרה   | 19/5  │ 📄   ║
║ ...                                                      ║
╚═══════════════════════════════════════════════════════════╝
```

---

### Order Card Components:

**For each order:**

| Field | Content | Action |
|-------|---------|--------|
| Order ID | BS-XXXX | Clickable → detail view |
| Contractor | Name | Click → customer profile |
| Amount | ₪[total] | View breakdown |
| Status | ממתינה/בהכנה/בדרך/נמסרה | Filter available |
| Date | DD/MM | Sort option |
| Action | 📄 icon | View delivery note |

---

### Status Categories:

**Orders grouped or filterable by:**

- **ממתינה** (Pending) — awaiting supplier confirmation
- **בהכנה** (Processing) — being packed/prepared
- **בדרך** (Shipped) — in courier delivery
- **נמסרה** (Delivered) — completed order

---

### Filtering & Sorting:

**Manager tools:**

- **Search:** Find orders by ID, contractor name, or date
- **Filter by Status:** Show only orders in specific status
- **Sort:** By date, amount, contractor, status
- **Date Range:** Optional date picker
- **Supplier Filter:** View orders from specific suppliers

---

### Order Details Access:

**Click order row or 📄 icon:**

Opens `mgrStoreDetailOverlay` sheet with:
- Full order details
- Line items with quantities and prices
- Delivery information
- Contractor notes
- Delivery note PDF/print option
- Status change controls
- Payment confirmation status

---

## Manager Order Actions:

- **View Details:** Full order breakdown
- **Print/PDF:** Delivery note for courier
- **Change Status:** Manual status override
- **Contact Contractor:** Send message/notification
- **View Contractor Profile:** Credit limit, history
- **Refund/Cancel:** Reverse order if needed
- **Reassign Courier:** Change delivery assignment

---

# Tab 3: 👥 לקוחות (Customers)

**Purpose:** Contractor account and credit management  
**Container ID:** `mgrCustomers`  
**Pane ID:** `pane-m-customers`  
**Tab ID:** `m-customers`

---

## Content Structure:

### Customer List Layout:

**All registered contractors with management options:**

```
╔═════════════════════════════════════════════════════════════╗
║ לקוחות — חיפוש וניהול                                      ║
├─────────────────────────────────────────────────────────────┤
║ [חיפוש שם/טלפון...]  [סינן לפי סטטוס ▼]  [מיין ▼]       ║
├─────────────────────────────────────────────────────────────┤
║ שם     | טלפון      | אשראי      | שימוש  | הזמנות | פעולה  ║
├────────┼────────────┼────────────┼────────┼────────┼──────┤
║ דוד    | 050-...    | ₪100,000   | 65%    | 47     │  ⚙️   ║
║ אברהם  | 052-...    | ₪150,000   | 42%    | 82     │  ⚙️   ║
║ עלי    | 054-...    | ₪75,000    | 88%    | 23     │  ⚙️   ║
║ ...                                                        ║
╚═════════════════════════════════════════════════════════════╝
```

---

### Customer Card Components:

**For each contractor:**

| Field | Content | Purpose |
|-------|---------|---------|
| Name | Contractor name | Click → profile details |
| Phone | Contact number | Click to call/SMS |
| Credit Limit | ₪[amount] | Total available credit |
| Usage % | [%]% | Visual bar showing usage |
| Orders | [N] | Total orders placed |
| Action | ⚙️ | Edit/manage settings |

---

### Customer Metrics Displayed:

**Per contractor:**
- **Total Credit Limit:** Assigned maximum
- **Credit Used:** Current balance
- **Credit Available:** Remaining balance
- **Usage Percentage:** Visual indicator
- **Total Orders:** Lifetime order count
- **Average Order Size:** ₪[amount]
- **Last Order Date:** DD/MM/YYYY
- **Payment Status:** On-time, Late, Overdue

---

## Customer Management Features:

### Click on Customer Row:

Opens detailed customer profile with:

**Profile Information:**
- Full name
- Contact phone
- Email address
- Business name (if registered)
- Registration date
- Account status

**Credit Management:**
- Current credit limit
- Credit used this month
- Credit available
- Payment history
- Overdue amounts (if any)
- Option to adjust credit limit

**Activity:**
- Total orders placed
- Last order date
- Repeat customer status
- Preferred suppliers
- Average order value

**Actions:**
- Send message/notification
- Adjust credit limit
- Suspend/activate account
- View order history
- Export customer data
- View payment history

---

### Edit Settings (⚙️ button):

Opens modal to:
- Update credit limit (increase/decrease)
- Set account status (active/suspended)
- Add notes/flags (VIP, high-risk, etc.)
- Configure notification preferences
- Set approval requirements
- View audit log of changes

---

### Filtering & Searching:

**Manager tools:**

- **Search:** By name, phone, email
- **Filter by Status:** Active, Suspended, Pending
- **Filter by Credit:** Low (<25%), Medium (25-75%), High (>75%)
- **Filter by Activity:** New, Regular, Inactive
- **Sort:** By name, credit usage, orders, registration date
- **Export:** CSV/PDF of customer list

---

# Tab 4: 🛠️ ניהול (Management)

**Purpose:** System configuration, settings, and advanced tools  
**Container ID:** `mgrManage`  
**Pane ID:** `pane-m-manage`  
**Tab ID:** `m-manage`

---

## Content Structure:

### Management Dashboard:

**Central hub for system administration:**

```
╔════════════════════════════════════════╗
║ ניהול מערכת                            ║
├────────────────────────────────────────┤
║ [⚙️ הגדרות מערכת]                      ║
║ [📦 ניהול מחסנים וספקים]               ║
║ [🏪 ניהול חנויות]                      ║
║ [📊 דוחות וניתוחים]                    ║
║ [🔐 ניהול הרשאות]                      ║
║ [📝 יומן ביקורת]                       ║
║ [🔧 כלים ופיתוח]                       ║
╚════════════════════════════════════════╝
```

---

## Management Sections:

### 1. ⚙️ הגדרות מערכת (System Settings)

**Global application configuration:**

- **Language & Localization:**
  - Default language (Hebrew/English)
  - Number format (₪/$ currency)
  - Date format (DD/MM/YYYY)
  - Timezone settings

- **Business Rules:**
  - VAT rate (מע"מ %)
  - Delivery fees configuration
  - Minimum order amount
  - Payment terms
  - Credit policies

- **Feature Flags:**
  - Enable/disable plan scanner
  - Enable/disable gamification
  - Multi-language support
  - Demo mode toggle

---

### 2. 📦 ניהול מחסנים וספקים (Warehouse & Supplier Management)

**Manage supplier relationships:**

**Suppliers List:**
- Supplier name and contact
- Performance rating
- Current SLA compliance
- Lead times
- Discount tiers
- Product count from each

**Actions:**
- Add new supplier
- Edit supplier info
- Update pricing agreements
- View order history with supplier
- Performance analytics
- Manage supply chain risk

---

### 3. 🏪 ניהול חנויות (Store Management)

**Configure supplier store network:**

**Stores:**
- Store name and location
- Manager contact info
- Inventory levels
- Service areas
- Operating hours
- Performance metrics

**Actions:**
- Add/remove stores
- Edit store details
- View store performance
- Manage store inventory
- Assign store managers
- Configure delivery zones

---

### 4. 📊 דוחות וניתוחים (Reports & Analytics)

**Business intelligence tools:**

**Available Reports:**
- **Sales Report:** Revenue by period, product, supplier
- **Order Analytics:** Volume trends, average order value
- **Customer Analytics:** Active customers, LTV, churn
- **Inventory Report:** Stock levels, turnover rates, slow-movers
- **Supplier Report:** Performance, lead times, quality
- **Financial Report:** Revenue, costs, margins, forecasts

**Reporting Features:**
- Date range selector
- Export to Excel/PDF
- Scheduled reports via email
- Comparison (vs previous period)
- Trend analysis
- Forecasting tools

---

### 5. 🔐 ניהול הרשאות (Permissions & RBAC)

**User role and access management:**

**Roles:**
- Define custom roles (if needed)
- Assign permissions per role
- Manager role (full access)
- Operator role (limited access)
- Viewer role (read-only)

**Features:**
- Create/edit roles
- Assign users to roles
- Set permission levels
- Audit access logs
- Session management
- IP whitelist (if applicable)

---

### 6. 📝 יומן ביקורת (Audit Log)

**System activity tracking:**

**Logs include:**
- All orders created/modified
- Price changes
- Credit limit adjustments
- User logins/logouts
- Role switches
- Configuration changes
- Deleted records (soft delete)

**Features:**
- Search and filter logs
- Export audit trail
- Date range selection
- User activity filter
- Change history per record
- Regulatory compliance export

---

### 7. 🔧 כלים ופיתוח (Tools & Development)

**Advanced admin tools:**

- **Data Tools:**
  - Bulk import/export
  - Database backup
  - Data cleanup utilities
  - Migration tools

- **Testing Tools:**
  - Demo data generation
  - System health check
  - Performance monitor
  - Log viewer

- **Development:**
  - API documentation
  - Webhook configuration
  - Third-party integrations
  - System version info

---

# Detail Overlays & Modals

## mgrStoreDetailOverlay

**Sheet-style modal for detailed operations**

**Structure:**
```
┌─────────────────────────────┐
│ [≡] grip                     │
├─────────────────────────────┤
│ Order BS-1042               │
│ Contractor: David Cohen     │
│                             │
│ Items:                      │
│ • ברז אמבטיה ×2  ₪490       │
│ • צינור PEX ×10 ₪280        │
│                             │
│ Status: בהכנה              │
│ Delivery: 22/5 - 14:00      │
│                             │
│ [PDF] [Edit] [Cancel]       │
└─────────────────────────────┘
```

**Components:**
- Order header with ID and status
- Contractor information
- Full line items with prices
- Delivery details
- Action buttons

**Actions:**
- Print/PDF delivery note
- Change status
- Add notes
- Assign courier
- Contact contractor
- Cancel order

---

# Tab Navigation & State

## admTab() Function

**Triggered by:** Tab button click  
**Handler:** `onclick="admTab('[tab-id]')"`

**Logic:**
```javascript
admTab('m-products')
  ↓
1. Remove .on class from ALL .adm-pane elements
2. Add .on class to pane-m-products
3. Render content if needed
4. Scroll pane to top
5. Update tab highlighting
```

---

## Tab State Variables:

```javascript
let currentManagerTab = 'm-products'  // Track current tab
let tabDataCache = {
  'mgrDashboard': null,      // Cache rendered content
  'mgrOrderList': null,
  'mgrCustomers': null,
  'mgrManage': null
}
```

---

## Tab Render Functions:

**Each tab has optional render function:**

- **Tab 1:** `renderMgrDashboard()` — load metrics, products
- **Tab 2:** `renderMgrOrderList()` — load orders from SYS_ORDERS
- **Tab 3:** `renderMgrCustomers()` — load contractors from PROJECTS
- **Tab 4:** `renderMgrManage()` — load settings options

---

# Data Structures & APIs

## Data Sources:

### PROJECTS Array:
```javascript
PROJECTS = [
  {
    id: 'PRJ-001',
    name: 'David Cohen',
    creditLimit: 100000,
    spent: 65000,
    // ... user data
  },
  // ... more contractors
]
```

### SYS_ORDERS Array:
```javascript
SYS_ORDERS = [
  {
    id: 'BS-1042',
    who: 'David Cohen',
    site: 'Tower Herzliya',
    items: 14,
    sum: 1560,
    stage: 'processing',  // new/preparing/ready/transit/delivered
    // ... order data
  },
  // ... more orders
]
```

### Derived Data:

**Metrics Calculated:**
- `mgrProducts.count` = TREES.length
- `mgrOrders.total` = SYS_ORDERS.length
- `mgrCustomers.active` = PROJECTS.filter(p => p.active).length
- `mgrRevenue.month` = SUM(SYS_ORDERS where stage='delivered')

---

## RBAC Rules:

**Manager role has:**
- ✅ Read access to all data
- ✅ Write access to products, prices
- ✅ Write access to orders (status changes)
- ✅ Write access to customers (credit limits)
- ✅ Write access to system settings
- ✅ Full audit log access

---

## REST API Endpoints (implied):

```
GET  /api/manager/dashboard
GET  /api/manager/orders
GET  /api/manager/customers
GET  /api/manager/products
POST /api/manager/products/:id/update
PATCH /api/manager/customers/:id/credit
POST /api/manager/settings/update
GET  /api/manager/audit-log
```

---

## Data Validation:

**Manager-side validation:**

- Credit limit: Positive number, ≤ company policy max
- Order status: Valid enum (new/preparing/ready/transit/delivered)
- Product price: Positive number
- Settings: Type-safe (strings, numbers, booleans)

---

**מנהל המערכת צלילה מסיימת.** ✓

