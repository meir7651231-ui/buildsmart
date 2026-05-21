# ⛔ DEPRECATED — אל תפעל לפי המסמך הזה

**סטטוס:** המסמך הזה **בוטל** ב-2026-05-21 בעקבות כלל R2 המוחלט.

**הסיבה:** הוא מנחה לבנות את Store/Courier/Worker dashboards כ-views
מלאים שממלאים את `<main class="content">`. זה **הפרת R2** (אין חלון
מלא, נקודה). 3 ניסיונות לפעול לפי המסמך הזה נדחפו ונרברטו (INSP-0016,
INSP-0017, INSP-0022/0023/0024).

**מה כן עושים:** persona functions חיים ב-**BS dial drill**, לא ב-views.
ראה:
- `CLAUDE.md` בשורש — סטטוס נוכחי + R2 absolute
- `app/RULES.md` — R2 מקור
- `app/knowledge/inspections/INSP-0025-*.md` ואילך — BS dial drill ב-pattern הנכון

המסמך נשמר רק לצורך היסטוריה (immutable per Inspector protocol).
**אל תקרא ממנו כאל הנחיה לעבודה.**

---

# פרוטוקול טמעון — Store + Courier + Worker Dashboards
**App/Src Implementation Guide**

**Document:** Implementation Protocol for 3 role views  
**Date:** 2026-05-21  
**Branch:** claude/whats-happening-LyY9G  
**Target:** Transform 3 placeholder Views into full-featured dashboards per R1-R9 + Inspector checklist

---

## 📌 Executive Summary

Convert 3 empty View components into production-ready dashboards following the established **Design Rules (R1-R9)** and **Inspector Protocol (FND/FRM/WIR/FIN/OPS)**.

### Current State
- ✅ All 5 personas documented (ROLE_DRAWER_SYSTEM.md)
- ✅ Contractor dashboard implemented (5 tabs working)
- ✅ Manager dashboard implemented (regression panel)
- ❌ Store placeholder (🏪 emoji + "בנייה בקרוב")
- ❌ Courier placeholder (🛵 emoji + "בנייה בקרוב")
- ❌ Worker placeholder (👷 emoji + "בנייה בקרוב")

### Target State
- ✅ Store Dashboard: 4-tab interface (Home, Orders, Stock, Portal)
- ✅ Courier Dashboard: Single-pane delivery hub + portal
- ✅ Worker Dashboard: Task management with multi-worker picker

---

## 🏛️ Architecture Overview

### File Structure (New)

```
app/src/
├── store/
│   ├── app-store.ts          (existing)
│   ├── store-role.ts         (NEW)
│   ├── courier-role.ts       (NEW)
│   └── worker-role.ts        (NEW)
│
├── components/
│   ├── store/                (NEW folder)
│   │   ├── store-home.tsx
│   │   ├── store-orders.tsx
│   │   ├── store-stock.tsx
│   │   └── store-portal.tsx
│   ├── courier/              (NEW folder)
│   │   ├── courier-home.tsx
│   │   ├── courier-list.tsx
│   │   └── courier-detail.tsx
│   └── worker/               (NEW folder)
│       ├── worker-picker.tsx
│       ├── worker-summary.tsx
│       └── worker-tasks.tsx
│
├── views/
│   ├── store.tsx             (REPLACE placeholder)
│   ├── courier.tsx           (REPLACE placeholder)
│   └── worker.tsx            (REPLACE placeholder)
│
└── styles/
    ├── store.css             (NEW)
    ├── courier.css           (NEW)
    └── worker.css            (NEW)
```

---

## 📐 Implementation Stages

### Stage 1️⃣: Store Dashboard

**Scope:** Order fulfillment + inventory hub  
**Complexity:** HIGH (4 tabs, overlays, multi-state)  
**Duration:** ~4-6 hours of focused work

#### 1a. Foundation (FND) — State + Data

**File:** `app/src/store/store-role.ts` (NEW)

```typescript
import { signal, computed } from '@preact/signals';
import { STORES, SYS_ORDERS, STORE_STOCK, TREES } from '../data/...';

// ===== Store Login =====
export const activeStoreIndex = signal<0 | 1 | 2 | null>(null);

// ===== Orders Tab =====
export type OrderStage = 'new' | 'preparing' | 'ready' | 'pickup' | 'transit' | 'delivered';
export const storeOrderFilter = signal<'active' | 'new' | 'preparing' | 'ready'>('active');
export const storePickId = signal<string | null>(null);  // Currently open picking sheet

// ===== Stock Tab =====
export const storeStockSearch = signal('');
export const storeStockFilter = signal<'all' | 'in' | 'out'>('all');

// ===== Portal =====
export const storePortalOpen = signal(false);

// ===== Computed =====
export const ordersForActiveStore = computed(() => {
  if (activeStoreIndex.value === null) return [];
  // Filter SYS_ORDERS by activeStoreIndex
  // In the future, match order.suppliers[].storeId to STORE_IDS
  return SYS_ORDERS.filter(o => /* match store */);
});

// ===== Actions =====
export function storeLogin(storeIndex: 0 | 1 | 2): void {
  activeStoreIndex.value = storeIndex;
  // Trigger View re-render to show dashboard
}

export function storeLogout(): void {
  activeStoreIndex.value = null;
  storeOrderFilter.value = 'active';
  storeStockSearch.value = '';
  storePortalOpen.value = false;
}

export function storeAdvance(orderId: string): void {
  const order = SYS_ORDERS.find(o => o.id === orderId);
  if (!order) return;
  
  // Validate RBAC (future)
  // if (!requirePerm('order.fulfill', '...')) return;
  
  // Stage transition
  if (order.stage === 'new') order.stage = 'preparing';
  else if (order.stage === 'preparing') order.stage = 'ready';
  
  // Persist
  localStorage.setItem('bs.orders.v1', JSON.stringify(SYS_ORDERS));
}

export function toggleStoreStock(productKey: string): void {
  // Validate RBAC (future)
  // if (!requirePerm('stock.edit', '...')) return;
  
  STORE_STOCK[productKey] = !STORE_STOCK[productKey];
  localStorage.setItem('bs.stock.v1', JSON.stringify(STORE_STOCK));
}
```

**Checklist (FND):**
- ☐ FND-01: `npm run typecheck` PASS
- ☐ FND-05: STORES, SYS_ORDERS, STORE_STOCK not empty (use mocked data if needed)
- ☐ FND-08: All signals initialized with explicit defaults
- ☐ FND-09: localStorage keys follow `bs.{thing}.v1` pattern

#### 1b. Frame (FRM) — Components + Layout

**File:** `app/src/views/store.tsx` (REPLACE)

```typescript
import { activeStoreIndex } from '../store/store-role';
import { StoreLoginScreen } from '../components/store/store-login';
import { StoreDashboard } from '../components/store/store-dashboard';

export function StoreView() {
  const idx = activeStoreIndex.value;
  
  // Login screen or dashboard
  return idx === null ? <StoreLoginScreen /> : <StoreDashboard storeIndex={idx} />;
}
```

**File:** `app/src/components/store/store-login.tsx` (NEW)

```typescript
import { STORES } from '../../data/...';
import { storeLogin } from '../../store/store-role';

export function StoreLoginScreen() {
  return (
    <div class="store-login">
      <header class="store-login__head">
        <span class="store-login__emoji">🏪</span>
        <h2 class="store-login__title">בחר חנות</h2>
      </header>
      
      <ul class="store-login__list">
        {STORES.map((store, i) => (
          <li key={i} class="store-login__item" onclick={() => storeLogin(i as any)}>
            <div class="store-login__name">{store.name}</div>
            <div class="store-login__meta">
              📍 {store.area} · 🕐 {store.eta}
            </div>
            <div class="store-login__status">
              {store.on ? '🟢 פעילה' : '🔴 מושבתת'}
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

**File:** `app/src/components/store/store-dashboard.tsx` (NEW)

```typescript
import { menuActiveTab, setMenuTab } from '../../store/app-store';
import { STORES } from '../../data/...';
import { StoreHomeTab } from './store-home';
import { StoreOrdersTab } from './store-orders';
import { StoreStockTab } from './store-stock';
import { StorePortalTab } from './store-portal';

export function StoreDashboard({ storeIndex }: { storeIndex: 0 | 1 | 2 }) {
  const store = STORES[storeIndex];
  const tab = menuActiveTab.value;
  
  return (
    <div class="store-dashboard">
      <header class="store-dashboard__head">
        <span class="store-dashboard__emoji">🏪</span>
        <div>
          <h2 class="store-dashboard__name">{store.name}</h2>
          <p class="store-dashboard__sub">ניהול הזמנות ומלאי</p>
        </div>
      </header>
      
      <nav class="store-dashboard__tabs">
        <button 
          class={`store-dashboard__tab ${tab === 's-home' ? 'on' : ''}`}
          onclick={() => setMenuTab('home')}  // or use store-specific signal
          aria-label="בית"
        >
          📊
        </button>
        <button 
          class={`store-dashboard__tab ${tab === 's-orders' ? 'on' : ''}`}
          onclick={() => setMenuTab('home')}  // Navigate to orders
          aria-label="הזמנות"
        >
          📥
        </button>
        {/* stock, portal tabs */}
      </nav>
      
      <main class="store-dashboard__pane">
        {tab === 's-home' && <StoreHomeTab storeIndex={storeIndex} />}
        {tab === 's-orders' && <StoreOrdersTab storeIndex={storeIndex} />}
        {tab === 's-stock' && <StoreStockTab storeIndex={storeIndex} />}
        {tab === 's-portal' && <StorePortalTab storeIndex={storeIndex} />}
      </main>
    </div>
  );
}
```

**Files:** `store-home.tsx`, `store-orders.tsx`, `store-stock.tsx`, `store-portal.tsx` (NEW)

Each component:
- Takes `storeIndex` as prop
- Uses computed signals from `store-role.ts`
- Renders filtered data
- Calls action handlers on user interaction

**Checklist (FRM):**
- ☐ FRM-01: 5 FABs unmoved (position fixed, bottom/top/inset unchanged)
- ☐ FRM-02: No new fullscreen overlays (only use existing product-sheet, search-panel, menu-speed-dial patterns)
- ☐ FRM-03: Tools open as dial (R3) — if Store needs submenu, add to menu-speed-dial.tsx
- ☐ FRM-04: Dialog items = circle + label (2 separate elements) (R4)
- ☐ FRM-07: Components render without crash (`testTabs` PASS)

#### 1c. Wiring (WIR) — Handlers + Mutations

**Pattern:** All state mutations go through action functions in `store-role.ts`

```typescript
// In store-orders.tsx
function handleOrderAdvance(orderId: string) {
  storeAdvance(orderId);  // Signal mutation + localStorage
  // Component re-renders automatically (signal.value changed)
}

// In store-stock.tsx
function handleStockToggle(productKey: string) {
  toggleStoreStock(productKey);  // Signal mutation
}
```

**Rules:**
- ✅ Actions are in `store-role.ts`, not in components
- ✅ State mutations (`.value =`) only in actions
- ✅ Components call actions on user interaction
- ✅ Components read signals via `.value` in JSX

**Checklist (WIR):**
- ☐ WIR-03: No infinite useEffect loops (use Preact signals, not effects if possible)
- ☐ WIR-04: No signal mutations inside effects of same signal
- ☐ WIR-05: No state setter in render body
- ☐ WIR-06: All interactive buttons have aria-label or text
- ☐ WIR-07: Event handlers are stable (not inline closures in loops)

#### 1d. Finish (FIN) — CSS + RTL + Accessibility

**File:** `app/src/styles/store.css` (NEW)

```css
/* Store Dashboard Layout */
.store-dashboard {
  display: flex;
  flex-direction: column;
  height: 100%;
  gap: 0;
}

.store-dashboard__head {
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 12px 16px;
  background: var(--brand);
  color: white;
  flex-shrink: 0;
}

.store-dashboard__tabs {
  display: flex;
  gap: 8px;
  padding: 12px 16px;
  border-bottom: 1px solid var(--line);
  overflow-x: auto;
  flex-shrink: 0;
}

.store-dashboard__tab {
  padding: 8px 12px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 20px;
  min-width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.store-dashboard__tab[aria-selected="true"],
.store-dashboard__tab.on {
  background: var(--brand);
  color: white;
}

.store-dashboard__pane {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

/* Store Login */
.store-login {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 16px;
}

.store-login__list {
  list-style: none;
  padding: 0;
  margin: 16px 0 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.store-login__item {
  padding: 12px 16px;
  border-radius: 12px;
  background: var(--card);
  border: 1px solid var(--line);
  cursor: pointer;
  display: flex;
  flex-direction: column;
  gap: 6px;
  min-height: 44px;
  justify-content: center;
  transition: all 200ms ease;
}

.store-login__item:active {
  background: var(--brand);
  color: white;
  transform: scale(0.98);
}

/* RTL (R8) */
.store-login__item {
  text-align: end;
  direction: rtl;
}

/* Accessibility */
.store-login__item:focus-visible {
  outline: 2px solid var(--brand);
  outline-offset: 2px;
}
```

**Checklist (FIN):**
- ☐ FIN-01 (R8): RTL text direction (`direction: rtl`, `text-align: end`)
- ☐ FIN-02: `safe-area-inset-top` / `safe-area-inset-bottom` on fixed elements
- ☐ FIN-03: `aria-label` on all icon buttons (store tabs)
- ☐ FIN-05: Touch targets ≥ 44×44px (all buttons, list items)
- ☐ FIN-06: `:focus-visible` outline visible on all interactive elements
- ☐ FIN-07: Text contrast ≥ 4.5:1 (check against WCAG AA)

#### 1e. Operations (OPS) — Build + Test

```bash
# Step 1: Typecheck
npm run typecheck
# Expected: 0 errors

# Step 2: Build
npm run build
# Expected: No errors, bundle successful

# Step 3: Regression test
npm run test:regression
# If exists; expected: all PASS

# Step 4: Smoke test (if created)
node app/smoke-store.mjs
# Expected: Order advancement works

# Step 5: Inspector (Explore subagent)
# Run with prompt from app/knowledge/inspector/prompt.md
# Replace {STAGE} with: foundation, frame, wiring, finish, operations
# Expected: VERDICT = GO
```

**Checklist (OPS):**
- ☐ OPS-01: `npm run typecheck` PASS
- ☐ OPS-02: `npm run build` PASS
- ☐ OPS-03: Regression suite PASS (or no crash)
- ☐ OPS-04: Commit message cites @rule @adr
- ☐ OPS-06: Stuck-loop check: no Finding ID repeats in last 3 INSP reports

---

### Stage 2️⃣: Courier Dashboard

**Scope:** Real-time delivery management  
**Complexity:** MEDIUM (1 pane, vehicle picker, split shipments)  
**Duration:** ~3-4 hours

**Differences from Store:**
- Single pane (no tabs) — home summary + delivery list
- Vehicle picker with capacity filtering
- Split shipment support (per-shipment jobs)
- No login screen (direct entry)

**New Files:**
- `app/src/store/courier-role.ts`
- `app/src/components/courier/courier-home.tsx`
- `app/src/components/courier/courier-list.tsx`
- `app/src/components/courier/courier-detail.tsx`
- `app/src/styles/courier.css`

**Key Signals:**
```typescript
export const courierVehicle = signal<'small' | 'van' | 'truck'>('truck');
export const courierDetailOpen = signal<string | null>(null);  // orderId#shipIdx
```

---

### Stage 3️⃣: Worker Dashboard

**Scope:** Task management for field crews  
**Complexity:** MEDIUM (task list, multi-worker, shared TASKS model)  
**Duration:** ~3-4 hours

**Differences:**
- Multi-worker picker (2 workers from WORKERS array)
- Single TASKS array shared with Manager
- Task card rendering (use from manager/task-card.tsx?)
- Progress bar calculation

**New Files:**
- `app/src/store/worker-role.ts`
- `app/src/components/worker/worker-picker.tsx`
- `app/src/components/worker/worker-summary.tsx`
- `app/src/components/worker/worker-tasks.tsx`
- `app/src/styles/worker.css`

**Key Signals:**
```typescript
export const activeWorker = signal<0 | 1>(0);  // Index into WORKERS array
```

---

## 🔍 Pre-Commit Checklist (All Stages)

```markdown
## Before every `git commit`:

### 1. Type Safety
- [ ] `npm run typecheck` — 0 errors
- [ ] No `@ts-ignore` comments (unless approved ADR)

### 2. Build
- [ ] `npm run build` — SUCCESS
- [ ] No warnings in console

### 3. Visual Regression
- [ ] Run app locally (`npm run dev`)
- [ ] Navigate to each new View (Store, Courier, Worker)
- [ ] Verify no layout shift, no missing elements

### 4. Accessibility
- [ ] Tab through all buttons (keyboard navigation works)
- [ ] Screen reader test: buttons have aria-label
- [ ] Focus indicator visible on all interactive elements

### 5. Smoke Tests
- [ ] `node app/smoke-store.mjs` — PASS (if implemented)
- [ ] `node app/smoke-courier.mjs` — PASS (if implemented)
- [ ] `node app/smoke-worker.mjs` — PASS (if implemented)

### 6. Inspector Validation
- [ ] Run Explore subagent with Inspector prompt
- [ ] Check VERDICT (must be GO or explain NO-GO)
- [ ] Save report to `knowledge/inspections/INSP-NNNN-*.md`

### 7. Stuck-Loop Detection
- [ ] Read 3 latest INSP reports
- [ ] Verify no Finding ID appears in 2+ reports
- [ ] If found: escalate to user (not automated fix)

### 8. Commit
```

---

## 📋 Git Commit Template

```
feat: Implement [Store|Courier|Worker] Dashboard

Brief description of what was built.

Components:
- app/src/store/[role]-role.ts: State management
- app/src/views/[role].tsx: Main View
- app/src/components/[role]/: Feature components
- app/src/styles/[role].css: Styling
- app/smoke-[role].mjs: End-to-end tests

Inspector:
- Verdict: GO ✅ / NO-GO ❌
- CRITICAL: 0 | MAJOR: 0 | MINOR: X
- Stuck-loop: NONE

Rules Cited:
@rule R1 R2 R3 R4 R9
@adr [role]-as-dial
@legacy index.html:NNNN

Breaking Changes: None
```

---

## 🎯 Validation Checklist by Role

### Store Dashboard ✓

| Check | Status | Notes |
|-------|--------|-------|
| StoreView renders | ☐ | No crash, shows login or dashboard |
| Store login works | ☐ | Click store → activeStoreIndex updates |
| Tab navigation works | ☐ | Click tab → correct pane visible |
| Order advance works | ☐ | Click button → stage changes, toast shows |
| Stock toggle works | ☐ | Click switch → availability toggles |
| localStorage persists | ☐ | Reload page → state restored |
| Smoke test PASS | ☐ | `node app/smoke-store.mjs` — all assertions pass |
| Inspector GO | ☐ | All FND/FRM/WIR/FIN/OPS checks pass |

### Courier Dashboard ✓

| Check | Status | Notes |
|-------|--------|-------|
| CourierView renders | ☐ | Shows home + delivery list |
| Vehicle picker works | ☐ | Click vehicle → list re-filters |
| Delivery list shows | ☐ | Correct count, correct orders |
| Detail sheet opens | ☐ | Click card → overlay shows |
| Advance button works | ☐ | Stage progression ready→pickup→transit |
| Smoke test PASS | ☐ | `node app/smoke-courier.mjs` |
| Inspector GO | ☐ | All checks pass |

### Worker Dashboard ✓

| Check | Status | Notes |
|-------|--------|-------|
| WorkerView renders | ☐ | Shows worker picker + task list |
| Worker picker works | ☐ | Click worker → tasks filter |
| Task sections show | ☐ | Current, Queue, Submitted |
| Progress bar updates | ☐ | Calculation correct |
| Start/Complete buttons work | ☐ | Task status advances |
| Smoke test PASS | ☐ | `node app/smoke-worker.mjs` |
| Inspector GO | ☐ | All checks pass |

---

## 📚 Reference Documents

- **R1-R9 Rules:** `app/RULES.md`
- **Inspector Checklist:** `app/knowledge/inspector/checklist.md`
- **Inspector Prompt:** `app/knowledge/inspector/prompt.md`
- **Store Deep Dive:** `app/knowledge/STORE_DASHBOARD.md`
- **Courier Deep Dive:** `app/knowledge/COURIER_DASHBOARD.md`
- **Worker Deep Dive:** `app/knowledge/WORKER_DASHBOARD.md`
- **Latest INSP Report:** `app/knowledge/inspections/INSP-0018-*.md`

---

## ❓ Q&A for Implementation Agent

**Q: Where do I get mock data for SYS_ORDERS, STORE_STOCK, etc.?**  
A: See `app/src/data/` folder. If not present, copy from legacy `index.html` line ~6000–8000.

**Q: Do I need to implement full RBAC (requirePerm)?**  
A: Not for MVP. Leave comments `// TODO: requirePerm('order.fulfill', ...)` and proceed.

**Q: Should Store/Courier/Worker tabs use app-store.ts or separate signals?**  
A: Prefer separate `*-role.ts` files for clarity. Menu tabs managed by existing `app-store.ts`.

**Q: What if a Smoke test file doesn't exist?**  
A: Create a stub that navigates to the View and checks for key elements (buttons, text). See `app/smoke-settings.mjs` as template.

**Q: How do I run Inspector locally?**  
A: Use Explore subagent with the prompt from `app/knowledge/inspector/prompt.md`.

---

## 🚀 Next Steps After Implementation

1. **Create Smoke Tests**
   - `app/smoke-store.mjs`
   - `app/smoke-courier.mjs`
   - `app/smoke-worker.mjs`

2. **Run Full Regression**
   - Ensure Contractor tabs still work
   - Ensure Manager regression still passes

3. **Merge to Main**
   - After 3 successful INSP reports (GO verdicts)
   - Create PR with all 3 Dashboards

4. **Document Integration**
   - Update `app/knowledge/agent-board.md` with completion status
   - Add to `app/knowledge/INSP-SUMMARY.md` (future)

