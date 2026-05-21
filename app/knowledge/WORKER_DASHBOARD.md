# עובד Field Worker Dashboard — Deep Dive
**Task Management Hub — Job Assignment & Progress Tracking**

---

## Overview — Role Context

**Role:** Field Worker (עובד שדה) / On-Site Crew Member  
**Entry Point:** Role Drawer → "עובד" button  
**First Screen:** Worker task hub (screen-worker)  
**Active Screen:** screen-worker (admin-screen class)  
**Layout:** Single pane (no tabs — task-centric view)  
**Render Function:** `renderWorker()`  
**Shared Model:** Uses `TASKS` array (same data model shared with manager task view)  
**Context:** `taskRole = 'worker'` (so openTask shows worker-specific controls)

---

## Screen Architecture — Worker Dashboard

### Entry Point

**Transition:** `enterRole('worker')` → `showScreen('screen-worker')` → `renderWorker()`

**Note:** Worker screen uses admin-screen class (like manager/store/courier) but operates independently.

**Appbar:**
```
[BS Logo] BuildSmart | [Notification Bell] [Menu Icon]
```

---

## Layout Structure

```
┌────────────────────────────────────┐
│ Appbar (top)                       │
├────────────────────────────────────┤
│                                    │
│ WORKER IDENTIFICATION SECTION      │
│ ┌──────────────────────────────────┤
│ │ Worker Name Picker (buttons)     │
│ │ [רן (עובד)] [עומר (עובד)]     │
│ │ (One selected with .on class)    │
│ └──────────────────────────────────┤
│                                    │
├────────────────────────────────────┤
│                                    │
│ WORKER HOME SUMMARY SECTION        │
│ ┌──────────────────────────────────┤
│ │ Hello greeting + status          │
│ │ Progress bar (% completed)       │
│ │ Stats grid (3 columns)           │
│ └──────────────────────────────────┤
│                                    │
├────────────────────────────────────┤
│                                    │
│ TASK SECTIONS                      │
│ ┌──────────────────────────────────┤
│ │ 🔨 CURRENT TASK (if active)     │
│ │ [Task card]                      │
│ │                                  │
│ │ ⏳ QUEUE (if pending)            │
│ │ [Task card]                      │
│ │ [Task card]                      │
│ │                                  │
│ │ 📋 SUBMITTED (if any)           │
│ │ [Task card]                      │
│ │ [Task card]                      │
│ └──────────────────────────────────┤
│                                    │
├────────────────────────────────────┤
│ FABs (5 standard buttons)          │
└────────────────────────────────────┘
```

---

## Worker Identification

**Data Source:** `WORKERS` array (fixed list of 2 workers)

```javascript
const WORKERS = ['רן (עובד)', 'עומר (עובד)'];
```

**Variable:** `activeWorker` (index: 0 or 1)

### Worker Picker Buttons

**Element ID:** `#workerPick`  
**Render Function:** `renderWorker()` creates buttons dynamically

```
[רן (עובד)] [עומר (עובד)]
    .on
```

**Interaction:** `pickWorkerScreen(i)`
- Sets `activeWorker = i`
- Calls `renderWorker()` (filters tasks for this worker + re-renders home)

**Note:** Clicking a worker button switches the entire view to that worker's tasks.

---

## Home Summary Section (Worker Profile)

**Element ID:** `#workerTasksBody` (parent container for all sections)

### Greeting Card

```
┌──────────────────────────────────────┐
│ שלום, [Worker Name] 👷              │
│                                      │
│ STATUS: [message based on current]  │
│ • "יש לך משימה פעילה"  (if active) │
│ • "יש משימות בתור"  (if queue)    │
│ • "אין משימות פתוחות"  (if none)  │
│                                      │
│ PROGRESS BADGE:                     │
│ [Done count]/[Total count] ✓        │
│ (e.g., "3/10")                      │
└──────────────────────────────────────┘
```

### Progress Bar + Stats

```
Progress Bar:
████████░░ (80% — shows completed/total)

Stats Grid (3 columns):
┌──────────┬──────────┬──────────┐
│ 🔨      │ ⏳      │ 📋     │
│ [N]     │ [N]     │ [N]    │
│ פעילה   │ בתור    │ הוגשו  │
└──────────┴──────────┴──────────┘
```

### Data Calculation

```javascript
const mine = TASKS.filter(t => t.worker === activeWorker);
const current = mine.find(t => 
  t.status === 'active' || t.status === 'rejected'
);
const queue = mine.filter(t => t.status === 'pending');
const submitted = mine.filter(t => 
  t.status === 'review' || t.status === 'done'
);
const doneCount = mine.filter(t => t.status === 'done').length;

const total = mine.length;
const pct = total ? Math.round(doneCount / total * 100) : 0;
```

---

## Current Task Section

**Heading:** "🔨 המשימה הנוכחית שלך"

**Shown If:** `current != null` (active or rejected task exists)

```
┌──────────────────────────────────────┐
│ [Task Card - see below]              │
└──────────────────────────────────────┘
```

**Alternate (no current task):**
```
┌──────────────────────────────────────┐
│ 🎉 אין משימה פעילה כרגע           │
└──────────────────────────────────────┘
```

---

## Task Card Component

**Render Function:** `taskCard(task)`

### Card Layout

```
┌──────────────────────────────────────┐
│ Task Header:                         │
│ 🏗️ [Task title]                    │
│ [Status: small badge] · [Site name] │
│                                      │
│ Description:                         │
│ [Task description line 1]            │
│ [Task description line 2...]         │
│                                      │
│ Details Row (grid):                  │
│ 📍 Location | 🕒 Due | 👔 Role     │
│ [site]     | [time]  | [role]     │
│                                      │
│ Status Bar:                          │
│ ✓ Completed  |  ⏳ Pending  | ✕ Rejected │
│                                      │
│ ACTION BUTTONS (context-dependent)  │
│ [Primary button] · [Secondary]      │
└──────────────────────────────────────┘
```

### Task Data Structure

```javascript
{
  id: 1,
  worker: 0,  // Index into WORKERS array
  title: 'Setup studs on wall A',
  desc: '4×4 pine studs, 16" spacing...',
  site: 'Downtown Office Renovation',
  when: '2:30 PM',
  role: 'Carpenter',
  status: 'pending' | 'active' | 'rejected' | 'review' | 'done',
  notes: 'Check level before securing',
  // For manager editing:
  assignTo: null,
  photo: null,
  approval: null
}
```

### Task Status Badge

| Status | Label | Class | Color |
|--------|-------|-------|-------|
| pending | ⏳ בתור | pending | Blue |
| active | 🔨 בביצוע | active | Green |
| rejected | ✕ דחוי | rejected | Red |
| review | 📋 בבדיקה | review | Yellow |
| done | ✓ הושלם | done | Green |

### Task Card Interaction

**Click Card:** `openTask(taskId)`
- Opens detail overlay
- Shows full information + action buttons

**Action Buttons (Context-Dependent):**

**If Status = 'pending':**
- **Start Work:** `startTask(taskId)` → `task.status = 'active'`
- **More Info:** Open detail overlay

**If Status = 'active':**
- **Mark Done:** `completeTask(taskId)` → `task.status = 'review'`
- **Reject/Issue:** Open detail overlay

**If Status = 'rejected':**
- **Retry:** `startTask(taskId)` → `task.status = 'active'`
- **View Feedback:** Open detail overlay

**If Status = 'review':**
- **Awaiting Approval** (disabled buttons)
- View feedback from manager

**If Status = 'done':**
- **Archived** (view-only card)
- Show completion info

---

## Queue Section (Pending Tasks)

**Heading:** "⏳ הבאות בתור (N)"

**Shown If:** `queue.length > 0`

```
┌──────────────────────────────────────┐
│ ⏳ הבאות בתור (3)                  │
├──────────────────────────────────────┤
│ [Task Card 1 - pending status]       │
│ [Task Card 2 - pending status]       │
│ [Task Card 3 - pending status]       │
└──────────────────────────────────────┘
```

**Each card shows:**
- Task title + site
- Description
- Due time
- [Start Work] button

---

## Submitted Section (In Review + Done)

**Heading:** "📋 שהגשת (N)"

**Shown If:** `submitted.length > 0`

```
┌──────────────────────────────────────┐
│ 📋 שהגשת (5)                        │
├──────────────────────────────────────┤
│ [Task Card 1 - review status]        │
│ [Task Card 2 - review status]        │
│ [Task Card 3 - done status]          │
│ [Task Card 4 - done status]          │
│ [Task Card 5 - done status]          │
└──────────────────────────────────────┘
```

**Each card shows:**
- Task title + status badge
- Approval info (if done)
- Manager feedback (if rejected)

---

## Task Detail Overlay

**Element:** (inferred, not shown in code — would be triggered by openTask)  
**Layout:** Sheet modal opening from bottom  
**Content:** Full task information + worker-specific actions

### Detail Content (Implied Structure)

```
┌────────────────────────────────────┐
│ Task Header:                       │
│ 🏗️ [Full Title]                  │
│ [Detailed Description]             │
├────────────────────────────────────┤
│ LOCATION & TIMING:                 │
│ 📍 [Site address]                 │
│ 🕒 Due: [Time] · 👔 [Role]       │
│ 📞 Supervisor: [Name & phone]      │
├────────────────────────────────────┤
│ NOTES FOR WORKER:                  │
│ [Manager notes: safety, special]   │
│ [reference diagrams if attached]   │
├────────────────────────────────────┤
│ STATUS & APPROVAL:                 │
│ Current: [Status badge]            │
│ [If rejected: Reason text]        │
│ [If done: Signed off by manager]  │
├────────────────────────────────────┤
│ ACTION BUTTONS:                    │
│ [Status-specific primary]          │
│ [Secondary action]                 │
│ [Cancel / Back]                    │
└────────────────────────────────────┘
```

---

## Task Lifecycle (Worker Perspective)

### Workflow States

```
PENDING (⏳ In queue)
  ↓ [Worker: "Start Work"]
ACTIVE (🔨 Currently doing)
  ↓ [Worker: "Mark Done" → sends for review]
REVIEW (📋 Awaiting manager approval)
  ├─ [Manager: ✓ Approve] → DONE
  └─ [Manager: ✕ Reject with feedback] → ACTIVE (retry) or REJECTED
DONE (✓ Completed)
  [Archived / History view]

REJECTED (✕ Not approved)
  ↓ [Worker: "Retry" → back to ACTIVE]
```

### Worker Actions Per Status

| Status | Worker Can | Result |
|--------|-----------|--------|
| pending | Start Work | → active |
| active | Mark Done / Submit | → review |
| review | View feedback | (wait for approval) |
| rejected | Retry | → active |
| done | View archive | (read-only) |

---

## Shared Task Model (TASKS)

**Data Location:** Global `TASKS` array (shared between worker and manager)

**Array Structure:**
```javascript
const TASKS = [
  {
    id: 1,
    worker: 0,        // WORKERS[0] = 'רן (עובד)'
    title: 'Setup studs on wall A',
    desc: '4×4 pine studs, 16" spacing, pre-drill holes',
    site: 'Downtown Office Renovation',
    when: '2:30 PM',
    role: 'Carpenter',
    status: 'active',
    notes: 'Check level before securing. Use spirit level.',
    assignTo: null,   // Manager editing
    photo: null,      // Worker upload
    approval: null    // Manager signature
  },
  // ... more tasks
];
```

**Shared Rendering:** Both manager task dashboard and worker dashboard use `taskCard()` function.

---

## Persistence & Sync

**Function:** `refreshTasks()`

```javascript
function refreshTasks() {
  const ws = document.getElementById('screen-worker');
  if (ws && ws.style.display !== 'none') {
    renderWorker();  // Refresh worker view
  } else {
    renderTasks();   // Refresh manager task view
  }
}
```

**Trigger:** Called after task status changes  
**Effect:** Updates whichever view is currently visible

---

## Key Functions

### renderWorker()

**Called by:**
- `enterRole('worker')`
- `pickWorkerScreen(i)`
- `refreshTasks()`

**Does:**
1. Sets `taskRole = 'worker'` (for openTask context)
2. Ensures `.adm-pane.on` class is set (survives manager visit)
3. Renders worker picker buttons
4. Filters tasks for `activeWorker`
5. Renders home summary
6. Renders task sections (current, queue, submitted)

### pickWorkerScreen(i)

**Triggered by:** Click on worker picker button

**Does:**
1. Sets `activeWorker = i`
2. Calls `renderWorker()` (filters tasks + re-renders view)

### startTask(taskId)

**Triggered by:** "Start Work" button on pending task

**Does:**
1. Sets `task.status = 'active'`
2. Calls `refreshTasks()` (re-renders appropriate view)

### completeTask(taskId)

**Triggered by:** "Mark Done" button on active task

**Does:**
1. Sets `task.status = 'review'` (sends to manager for approval)
2. Calls `refreshTasks()`
3. Toast: "המשימה הוגשה לבדיקה"

---

## Screen Registration

**HTML Structure:** (inferred from naming pattern)

```html
<div class="fullscreen admin-screen" id="screen-worker" style="display:none">
  <!-- Single pane (no tabs) -->
  <div class="adm-pane">
    <!-- Worker picker -->
    <div id="workerPick"></div>
    
    <!-- Tasks body (all sections) -->
    <div id="workerTasksBody"></div>
  </div>
</div>
```

**Associated Overlay:** (likely) Task detail sheet modal

---

## State Variables — Worker Screen

| Variable | Type | Purpose |
|----------|------|---------|
| `activeWorker` | number | Current worker index (0 or 1) |
| `taskRole` | string | Set to 'worker' (affects openTask behavior) |
| `currentTask` | object | Likely used by openTask for detail view |

---

## Key Algorithms

### Filter Tasks for Worker

```javascript
const mine = TASKS.filter(t => t.worker === activeWorker);
```

### Group by Status

```javascript
const current = mine.find(t => 
  t.status === 'active' || t.status === 'rejected'
);
const queue = mine.filter(t => t.status === 'pending');
const submitted = mine.filter(t => 
  t.status === 'review' || t.status === 'done'
);
```

### Calculate Progress

```javascript
const total = mine.length;
const doneCount = mine.filter(t => t.status === 'done').length;
const pct = total ? Math.round(doneCount / total * 100) : 0;
```

---

## Status Context in UI

**taskRole variable controls behavior:**

```javascript
if (taskRole === 'worker') {
  // openTask shows:
  // - [Start Work] if pending
  // - [Mark Done] if active
  // - [Retry] if rejected
  // - Awaiting message if review/done
} else if (taskRole === 'manager') {
  // openTask shows:
  // - [Assign] if unassigned
  // - [Mark Done] if in review
  // - [Reject with feedback]
  // - [View submitted work]
}
```

---

## Team Coordination

**Same Task, Multiple Views:**
1. Manager sees task in "Pending" state → assigns to worker
2. Worker sees task in "Queue" section → clicks "Start Work"
3. Manager sees task → now in "Active" state (real-time sync)
4. Worker completes → "Mark Done" → `status = 'review'`
5. Manager sees task → "Awaiting Approval" state
6. Manager reviews work → approves or rejects
7. Worker refreshes → sees approval or rejection feedback

**Sync Mechanism:** Likely uses storage events (same as order management)

---

## Mobile-First Design Notes

- **Single Pane Layout:** Optimized for vertical scrolling
- **Worker Picker:** Horizontal button row (swipe-able)
- **Progress Bar:** Visual indicator of work completion
- **Task Cards:** Touch-friendly, large action buttons
- **Sections:** Collapsible grouping by status
- **Detail Overlay:** Sheet modal from bottom, swipe-down to close

---

## Gamification & Motivation

**Visible Progress:**
- Percentage complete (progress bar)
- Done count vs. total
- Section headers show queue counts
- Status badges give visual feedback

**Potential Future:**
- Streak counter (consecutive completed days)
- Leaderboard (by site or week)
- Badges/achievements for milestones
- Bonus tracking (tied to performance)

---

## Notes for Future Implementation

1. **Photo Uploads:** Worker uploads completion photo to task.photo
2. **Supervisor Override:** Manager can mark done without worker submission
3. **Task Notes:** Worker can add notes before submitting
4. **Signature:** Manager signs off digitally on approval
5. **Scheduling:** Tasks shown with time estimates + calendar view
6. **Notifications:** Push when task assigned / approved / rejected
7. **Offline Mode:** Cache tasks locally, sync when online

