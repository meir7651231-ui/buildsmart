// Phase-B (B0) data foundation — the seeds the finance-hub (T1), site-hub (T2)
// and the contractor feature tracks (T3) read. VERBATIM from the prototype
// (`/home/user/buildsmart/index.html`); every Hebrew string + number is copied
// exactly — do NOT paraphrase or invent (R6/R8). Each block notes its `[L####]`
// source anchor.
//
// Immutable `const` seeds only. Mutable runtime state (snag CRUD, approval
// decisions, penalty ledger, stock moves, task status) belongs in StateNotifiers
// that START from these seeds — these are the genesis values, not live state.
//
// Reuse note (grep-verified, T0/manager already shipped — NOT duplicated here):
//   • PROJECTS(3) + activeProjectId → `data/projects.dart` (`kProjects`).
//   • TASKS(5) rows + WORKERS(2) + status labels → `data/persona_data.dart`
//     (`kPersonaTasks` / `kWorkers` / `kTaskStatusLabel`). The prototype's
//     per-task `steps` STRING list was reduced to a count there; the verbatim
//     step lists live below in `kTaskSteps` (keyed by task id).
//   • projectBudget(15000/9840) + budgetCategories(4) + thresholds(80/90/100) +
//     budgetLevel + SAFETY_TIPS(5) → `data/contractor_seeds.dart`
//     (`kBudgetTotal`/`kBudgetSpent`/`kBudgetCategories`/`kBudgetThresholds`/
//     `budgetLevel`/`kSafetyTips`). The Phase-B math helpers at the bottom of
//     this file reuse those constants (no re-declaration).

import 'package:buildsmart/data/contractor_seeds.dart'
    show kBudgetTotal, kBudgetSpent, kBudgetCategories;

// ═════════════════════════════════════════════════════════════════════════════
// FINANCE HUB (Category B) seeds — index.html:19459-19482
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// BUILD_INDEX — construction-inputs index (demo). index.html:19459.
//   `{base:121.3, current:128.7, label:'מדד תשומות הבנייה'}`.
// ─────────────────────────────────────────────────────────────────────────────
class BuildIndex {
  const BuildIndex({required this.base, required this.current, required this.label});
  final double base;
  final double current;
  final String label;
}

const BuildIndex kBuildIndex = BuildIndex(
  base: 121.3,
  current: 128.7,
  label: 'מדד תשומות הבנייה',
);

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENT_TERMS (4) — index.html:19461. `activePaymentTerm='net30'` (19467).
//   `days==0` → מיידי · `days==null` → אבני דרך · else שוטף+N.
// ─────────────────────────────────────────────────────────────────────────────
class PaymentTerm {
  const PaymentTerm({required this.id, required this.name, required this.days});
  final String id;
  final String name;
  final int? days; // null == לפי אבני דרך
}

const List<PaymentTerm> kPaymentTerms = [
  PaymentTerm(id: 'now', name: 'מזומן / מיידי', days: 0),
  PaymentTerm(id: 'net30', name: 'שוטף + 30', days: 30),
  PaymentTerm(id: 'net60', name: 'שוטף + 60', days: 60),
  PaymentTerm(id: 'milestone', name: 'לפי אבני דרך', days: null),
];

const String kActivePaymentTerm = 'net30';

// ─────────────────────────────────────────────────────────────────────────────
// subcontractors (3) — index.html:19469. Each `{allocated, spent}` in ₪.
// ─────────────────────────────────────────────────────────────────────────────
class Subcontractor {
  const Subcontractor({
    required this.id,
    required this.name,
    required this.ic,
    required this.allocated,
    required this.spent,
  });
  final String id;
  final String name;
  final String ic;
  final int allocated;
  final int spent;
}

const List<Subcontractor> kSubcontractors = [
  Subcontractor(id: 'sub1', name: 'אינסטלציה — דוד לוי', ic: '🔧', allocated: 18000, spent: 11200),
  Subcontractor(id: 'sub2', name: 'חשמל — מ. כהן בע״מ', ic: '⚡', allocated: 14000, spent: 9600),
  Subcontractor(id: 'sub3', name: 'גמר וצבע — שיא הצבע', ic: '🎨', allocated: 9000, spent: 3100),
];

// ─────────────────────────────────────────────────────────────────────────────
// approvalQueue (2) — index.html:19475. Purchase-approval workflow (RBAC, T1.4).
// ─────────────────────────────────────────────────────────────────────────────
class ApprovalItem {
  const ApprovalItem({
    required this.id,
    required this.what,
    required this.amount,
    required this.by,
    required this.status,
  });
  final String id;
  final String what;
  final int amount;
  final String by;
  final String status;
}

const List<ApprovalItem> kApprovalQueue = [
  ApprovalItem(id: 'AP-201', what: 'הזמנת ברזל זיון', amount: 8400, by: 'מנהל עבודה', status: 'ממתין'),
  ApprovalItem(id: 'AP-202', what: '40 שק דבק אריחים', amount: 2600, by: 'רכש', status: 'ממתין'),
];

// ─────────────────────────────────────────────────────────────────────────────
// FX_RATES — index.html:19482. Live FX rates (demo): USD/EUR/GBP per ₪.
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, double> kFxRates = {
  'USD': 3.72,
  'EUR': 4.05,
  'GBP': 4.71,
};

// ═════════════════════════════════════════════════════════════════════════════
// SITE HUB (Category C) seeds — index.html:19815-19853
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// GANTT_TASKS (6) — index.html:19815. `{name, start, len, done%}`.
//   Schedule span = max(start+len) = 21+6 = 27 (T2.1).
// ─────────────────────────────────────────────────────────────────────────────
class GanttTask {
  const GanttTask({
    required this.name,
    required this.start,
    required this.len,
    required this.done,
  });
  final String name;
  final int start;
  final int len;
  final int done; // percent complete
}

const List<GanttTask> kGanttTasks = [
  GanttTask(name: 'יסודות וחפירה', start: 0, len: 5, done: 100),
  GanttTask(name: 'שלד וקירות', start: 4, len: 8, done: 100),
  GanttTask(name: 'אינסטלציה גסה', start: 10, len: 6, done: 70),
  GanttTask(name: 'חשמל גס', start: 11, len: 5, done: 55),
  GanttTask(name: 'טיח וריצוף', start: 15, len: 7, done: 20),
  GanttTask(name: 'גמר וצבע', start: 21, len: 6, done: 0),
];

/// Gantt schedule span in days — `max(start+len)` over [kGanttTasks] (== 27).
int ganttSpan() => kGanttTasks
    .map((t) => t.start + t.len)
    .fold<int>(0, (a, b) => b > a ? b : a);

// ─────────────────────────────────────────────────────────────────────────────
// snagList (2) — index.html:19823. Snagging list (T2.2 — CRUD seed).
// ─────────────────────────────────────────────────────────────────────────────
class SnagItem {
  const SnagItem({
    required this.id,
    required this.what,
    required this.loc,
    required this.severity,
    required this.status,
  });
  final String id;
  final String what;
  final String loc;
  final String severity;
  final String status;
}

const List<SnagItem> kSnagList = [
  SnagItem(id: 'SNG-01', what: 'סדק בקיר חדר שינה', loc: 'קומה 3 · דירה 7', severity: 'בינוני', status: 'פתוח'),
  SnagItem(id: 'SNG-02', what: 'נזילה מתחת לכיור', loc: 'קומה 2 · דירה 4', severity: 'חמור', status: 'פתוח'),
];

// ─────────────────────────────────────────────────────────────────────────────
// inspections (2) — index.html:19829. Inspector reminders (T2.9 — CRUD seed).
// ─────────────────────────────────────────────────────────────────────────────
class Inspection {
  const Inspection({
    required this.id,
    required this.what,
    required this.due,
    required this.status,
  });
  final String id;
  final String what;
  final String due;
  final String status;
}

const List<Inspection> kInspections = [
  Inspection(id: 'INS-1', what: 'ביקורת מהנדס — שלד', due: 'בעוד 3 ימים', status: 'מתוכננת'),
  Inspection(id: 'INS-2', what: 'ביקורת כיבוי אש', due: 'בעוד 8 ימים', status: 'מתוכננת'),
];

// ─────────────────────────────────────────────────────────────────────────────
// SITE_TREE (3 floors) — index.html:19841. floor → apartment → room hierarchy.
// ─────────────────────────────────────────────────────────────────────────────
class SiteApartment {
  const SiteApartment({required this.n, required this.rooms});
  final String n;
  final List<String> rooms;
}

class SiteFloor {
  const SiteFloor({required this.floor, required this.apts});
  final String floor;
  final List<SiteApartment> apts;
}

const List<SiteFloor> kSiteTree = [
  SiteFloor(floor: 'קומה 1', apts: [
    SiteApartment(n: 'דירה 1', rooms: ['סלון', 'מטבח', 'חדר רחצה']),
    SiteApartment(n: 'דירה 2', rooms: ['סלון', 'חדר שינה', 'שירותים']),
  ]),
  SiteFloor(floor: 'קומה 2', apts: [
    SiteApartment(n: 'דירה 3', rooms: ['סלון', 'מטבח', 'חדר רחצה', 'מרפסת']),
    SiteApartment(n: 'דירה 4', rooms: ['סלון', 'חדר שינה', 'חדר ילדים']),
  ]),
  SiteFloor(floor: 'קומה 3', apts: [
    SiteApartment(n: 'דירה 5', rooms: ['סלון', 'מטבח', 'חדר רחצה']),
    SiteApartment(n: 'דירה 6', rooms: ['סלון', 'חדר שינה', 'שירותים', 'מרפסת']),
  ]),
];

// ─────────────────────────────────────────────────────────────────────────────
// ARCHIVED_PROJECTS (3) — index.html:19849. Completed projects (T2.10 archive).
// ─────────────────────────────────────────────────────────────────────────────
class ArchivedProject {
  const ArchivedProject({
    required this.name,
    required this.year,
    required this.units,
    required this.status,
  });
  final String name;
  final String year;
  final int units;
  final String status;
}

const List<ArchivedProject> kArchivedProjects = [
  ArchivedProject(name: 'מגדל הרצליה — שלב א׳', year: '2024', units: 24, status: 'הושלם'),
  ArchivedProject(name: 'בית פרטי רעננה', year: '2023', units: 1, status: 'הושלם'),
  ArchivedProject(name: 'שיפוץ משרדים תל-אביב', year: '2023', units: 6, status: 'הושלם'),
];

// ═════════════════════════════════════════════════════════════════════════════
// TASKS / INVENTORY / HOME seeds — index.html:6202, 7013, 8023, 8156
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// kTaskSteps — the verbatim per-task `steps` STRING lists. index.html:8023-8033.
//   Keyed by `kPersonaTasks` id (1..5). `data/persona_data.dart` keeps only the
//   step COUNT; this restores the actual step names (T3.A needs the step text).
//   Per-id list length matches the count there: 4 / 4 / 6 / 3 / 4.
// ─────────────────────────────────────────────────────────────────────────────
const Map<int, List<String>> kTaskSteps = {
  1: [
    'סימון מסלול הצנרת על הקיר',
    'השחלת צינור PEX מהדוד',
    'חיבור לנקודות הקצה',
    'בדיקת אטימה בלחץ מים',
  ],
  2: [
    'סימון גובה המיכל',
    'קיבוע המסגרת לקיר',
    'חיבור לקו המים',
    'בדיקת מפלס ויישור',
  ],
  3: [
    'ניקוי והכנת הרצפה',
    'מריחת פריימר',
    'חיזוק פינות בסרט איטום',
    'מריחת שכבת איטום ראשונה',
    'מריחת שכבה שנייה',
    'בדיקת הצפה',
  ],
  4: [
    'סימון מיקום הנקז לפי השיפוע',
    'חיבור לקו ניקוז 50 מ"מ',
    'קיבוע ואיטום הנקז',
  ],
  5: [
    'התקנת ברזי ניל זוויתיים',
    'הרכבת הברז על הכיור',
    'חיבור צינורות גמישים',
    'בדיקת זרימה ואטימה',
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
// WORK_LOG (2 days) — index.html:8156. Daily work log {date, items:[{worker,
//   task, status}]}. Read-only history below the live "היום" bucket.
// ─────────────────────────────────────────────────────────────────────────────
class WorkLogItem {
  const WorkLogItem({required this.worker, required this.task, required this.status});
  final String worker;
  final String task;
  final String status;
}

class WorkLogDay {
  const WorkLogDay({required this.date, required this.items});
  final String date;
  final List<WorkLogItem> items;
}

const List<WorkLogDay> kWorkLog = [
  WorkLogDay(date: 'אתמול', items: [
    WorkLogItem(worker: 'רן', task: 'בניית מחיצת גבס — חדר רחצה', status: 'done'),
    WorkLogItem(worker: 'רן', task: 'העברת קו ביוב ראשי', status: 'done'),
    WorkLogItem(worker: 'עומר', task: 'יציקת מדה ושיפועים', status: 'done'),
  ]),
  WorkLogDay(date: 'שלשום', items: [
    WorkLogItem(worker: 'רן', task: 'סימון נקודות מים וחשמל', status: 'done'),
    WorkLogItem(worker: 'עומר', task: 'פירוק אינסטלציה ישנה', status: 'done'),
  ]),
];

// ─────────────────────────────────────────────────────────────────────────────
// STOCK_DEMO (11) — index.html:6202. name → location ('warehouse' | 'site').
//   The inventory screen filters by tab; `moveStock` flips a key's location.
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, String> kStockDemo = {
  'סרט טפלון': 'warehouse',
  'סרט טפלון (גליל)': 'warehouse',
  'סרט טפלון לאיטום': 'warehouse',
  'ברזי ניל זוויתיים': 'site',
  'ברז ניל זוויתי 1/2"': 'site',
  'ברז זוויתי לכיור 1/2"': 'site',
  'סיליקון סניטרי': 'warehouse',
  'סיליקון סניטרי שקוף': 'warehouse',
  'ברגי קיבוע': 'warehouse',
  'אטם גומי לברז': 'site',
  'מחברים וזוויות': 'warehouse',
};

// ─────────────────────────────────────────────────────────────────────────────
// DEMO_HISTORY (2) — index.html:7013. The home "reorder" sample history block.
// ─────────────────────────────────────────────────────────────────────────────
class ReorderHistoryItem {
  const ReorderHistoryItem({
    required this.name,
    required this.price,
    required this.icon,
    required this.cat,
    required this.ago,
  });
  final String name;
  final int price;
  final String icon;
  final String cat;
  final String ago;
}

const List<ReorderHistoryItem> kDemoHistory = [
  ReorderHistoryItem(name: 'מקדחה רוטטת בוש GBH', price: 640, icon: '🔩', cat: 'כלי עבודה', ago: 'הוזמן לפני 9 ימים'),
  ReorderHistoryItem(name: 'שק מלט אפור 25 ק"ג', price: 31, icon: '🪨', cat: 'בנייה', ago: 'הוזמן לפני 6 ימים'),
];

// ═════════════════════════════════════════════════════════════════════════════
// PHASE-B MATH HELPERS — pure functions over the verbatim constants.
//   The prototype computes these inline (finIndex/finROI/finInvoiceSplit/
//   finThresholds); restored here as testable pure functions. Constants come
//   from the budget seeds in `data/contractor_seeds.dart` (not re-declared).
// ═════════════════════════════════════════════════════════════════════════════

/// Budget spend as a whole percent — `round(spent/total*100)`. index.html:19634
/// (`finThresholds`) / :7162 (`renderBudget`). With 9840/15000 → 66.
int budgetPct() =>
    kBudgetTotal > 0 ? (kBudgetSpent / kBudgetTotal * 100).round() : 0;

/// Build-index change percent — `(current-base)/base*100`. index.html:19521-19522
/// (`finIndex`). With 121.3 → 128.7 → +6.0997…% (displayed `.toFixed(2)` = 6.10).
double buildIndexDeltaPct() =>
    (kBuildIndex.current - kBuildIndex.base) / kBuildIndex.base * 100;

/// Index-linked budget — `round(total*(1+pct/100))`. index.html:19524 (`finIndex`).
int linkedBudget(int budget) =>
    (budget * (1 + buildIndexDeltaPct() / 100)).round();

/// Demo contract value — `round(spent * 1.42)`. index.html:19659 (`finROI`).
/// NOTE: the prototype multiplies `projectBudget.total` by 1.42 for the contract
/// value; this generic helper applies the ×1.42 ROI factor to any [value].
int roiValue(num value) => (value * 1.42).round();

/// Demo project ROI percent — over the project budget. index.html:19657-19661
/// (`finROI`): value=round(total*1.42), profit=value-total, roi=profit/total*100.
({int contractValue, int profit, double roiPct}) projectRoi() {
  final value = roiValue(kBudgetTotal);
  final profit = value - kBudgetTotal;
  final roiPct = profit / kBudgetTotal * 100;
  return (contractValue: value, profit: profit, roiPct: roiPct);
}

/// The demo invoice total split across the budget categories. index.html:19679.
const int kInvoiceTotal = 12800;

/// Invoice split by category weight — `round(total*(amount/Σamount))` per
/// category. index.html:19679-19689 (`finInvoiceSplit`). Returns name→share (₪);
/// the shares sum to ~[kInvoiceTotal] (rounding per row, as the prototype shows).
Map<String, int> invoiceSplit([int total = kInvoiceTotal]) {
  final catTotal = kBudgetCategories.fold<int>(0, (s, c) => s + c.amount);
  final denom = catTotal == 0 ? 1 : catTotal;
  return {
    for (final c in kBudgetCategories)
      c.name: (total * (c.amount / denom)).round(),
  };
}
