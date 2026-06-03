# תוכנית-עבודה — סיום "לוח קבלן" (= אפליקציית-הקבלן הקיימת)

> **הוגדר ע"י המשתמש (2026-06-03):** "לוח קבלן = האפליקציה של היום; כל מידע-הקבלן צריך להיכנס בה — **בלי כפתורים חדשים**."
> זה backlog לביצוע על ענף **`claude/whats-happening-LyY9G`** (שם האפליקציה+השערים), דרך הפרוטוקול (דוחות 21–22). מסמך זה = תכנון, לא ידע-מקור.

## עיקרון-העל (R2-safe — אומת מול הקוד)
- **העלים כבר קיימים** ב-`data/menu_trees.dart` (project · tasks · gantt · snag · נוכחות · מלאי · scan · מרכז-פיננסים · ניהול-אתר). **פונקציות-הפיצ'ר חסרות** (`finIndex`/`siteGantt`/`renderTasks`/`moveStock`/`openBudgetDetail` = ABSENT). ⇒ **ממלאים תוכן לעלים קיימים — אפס כפתורים/מסכים חדשים.**
- מקור-אמת מלא ו-verbatim: **`app_flutter/knowledge/port/proto/04-contractor-projects-tasks.md`** (546ש', כל String/מספר/`[L#]`). + proto/03 (commerce) · proto/05 (profile/hubs) · proto/07 (chat/notif).
- **R2:** אסור view מסך-מלא חדש. כל פיצ'ר = dial-leaf. ה-prototype views (project/sites/tasks/scan/stock) נשארים placeholder.
- **R6/R8:** כל מחרוזת עברית verbatim (כולל `₪`, `מ"מ`, `יח״ד`, `1.1/4"`, אימוג'י). **R9:** כל `prompt()` → שורת-קלט inline (לא dialog). server/print/camera/OCR → toast-stub.
- **גייטים:** כל phase = `flutter test` + 116-מספור-השערים + literal-push-gate (`תדחוף`/`push`/`approved`).

## מצב נוכחי מול יעד (אומת)
| תחום | במקור (proto/04) | בקוד היום | פער |
|---|---|---|---|
| בית/reorder | §1 (3 כרטיסים + DEMO_HISTORY) | חלקי | חיווט-תוכן |
| פרויקטים/אתרים | §2 (PROJECTS×3 + status/edit/picker) | leaf-stub | **מלא** |
| תקציב | §3 (projectBudget + 4 קטגוריות) | leaf-stub | **מלא** |
| מרכז-פיננסים | §4 (10 פיצ'רים) | leaf קיים, toast | **10 פיצ'רים** |
| ניהול-אתר | §5 (10 פיצ'רים) | leaf קיים, toast | **10 פיצ'רים** |
| משימות | §6 (5 משימות + מכונת-סטטוס + 2 תפקידים) | leaf-stub | **מלא** |
| פרויקט-חכם | §7 (9 stages day-by-day) | leaf-stub | **מלא** |
| מלאי | §8 (STOCK_DEMO 11 + move) | leaf-stub | **מלא** |
| סריקת-תוכנית | §9 (PLAN_TYPES×4 + zones + OCR) | leaf-stub | **מלא** |

---

## Phase 0 — תשתית: data-seeds + helpers (≈1 יום)
*כל ה-data verbatim → Dart immutables + Riverpod StateNotifiers. בלי UI.*
- **0.1** (3ש') seeds סטטיים: `PROJECTS`(3) · `ARCHIVED_PROJECTS`(3) · `SITE_TREE`(3 קומות) · `SIM_SITES`/`SIM_CUSTOMERS` · `DEMO_HISTORY`(2) · `WORK_LOG`(2) · `SAFETY_TIPS`(5) · `GANTT_TASKS`(6) · `PLAN_TYPES`(4 + כל zones/stores) · `PAYMENT_TERMS`(4) · `FX_RATES`/`BUILD_INDEX`.
- **0.2** (3ש') StateNotifiers (mutable): `projectsProvider` · `tasksProvider`(5+steps) · `projectBudgetProvider`+`budgetCategoriesProvider`(4) · `stockProvider`(11) · `smartDayDone`/`smartStepDone` · `snagListProvider`(2) · `inspectionsProvider`(2) · `attendanceLogProvider` · `workDiaryProvider` · `penaltyLedgerProvider` · `subcontractorsProvider`(3) · `approvalQueueProvider`(2) · `activePaymentTermProvider`.
- **0.3** (2ש') helpers + מתמטיקה-מדויקת: `fMoney(n)='₪'+round(n) (פסיק-אלפים)` · `caToday()` he-IL · pct=round(spent/total*100)=**66%** · ROI×1.42 · index×(1+pct/100) · invoice-split לפי-משקל · triangular site-weights `(n-i)/((n(n+1))/2)`. **gate-42:** test לכל helper.
- **בדיקות:** `*_seed_test.dart` (counts verbatim) + `contractor_math_test.dart` (pct=66, ROI, weights).

## Phase 1 — פרויקטים/אתרים + תקציב (≈1 יום)
- **1.1** (3ש') dial-leaf "האתרים שלי": רשימת `PROJECTS` (`renderProjects` §2f) · `switchProject` (שמירת/טעינת cart per-project) · `openSiteStatus` (sheet סטטוס §2h).
- **1.2** (2ש') `openSiteEditor`/`saveSiteEdit` + `openProjectModal`/`saveProject` + site-picker — כולם **R9 inline** (לא modal/prompt).
- **1.3** (3ש') תקציב: budget-box (provider יחיד מזין 2 widgets §3c) · `openBudgetDetail` (§3d: headline/3-מספרים/by-category/by-site) · `openBudgetEditor`+`adjustBudget` · category-editor. **R9 inline** לכל קלט.
- **בדיקות:** switchProject-cart-isolation · budget pct=66% · category CRUD.

## Phase 2 — מרכז-פיננסים: 10 פיצ'רים (≈1.5 ימים)
*כל פיצ'ר = sub-leaf תחת leaf `kFinanceHub` הקיים. proto/04 §4.*
- **2.1** (4ש') `finIndex`(הצמדה +6.10%) · `finPayTerms`(4 תנאים) · `finSubs`(3 קבלני-משנה) · `finROI`(×1.42) · `finInvoiceSplit`(₪12,800 לפי-משקל) · `finThresholds`(80/90/100%).
- **2.2** (4ש') `finApprovals`(2, **RBAC `requirePerm('order.approve')`** + `auditLog` + push) · `finPenalties`(R9 inline "כמה ימי איחור" — לא prompt · ₪500/יום) · `finFX`(מחשבון USD/EUR/GBP) · `finReports`(**toast-stub** במקום print/PDF).
- **בדיקות:** index-math · ROI-math · invoice-split-sum · RBAC-gate על approve.

## Phase 3 — ניהול-אתר: 10 פיצ'רים (≈1.5 ימים)
*sub-leaves תחת leaf SiteHub הקיים. proto/04 §5.*
- **3.1** (4ש') `siteGantt`(6 משימות, RTL `right:%`) · `siteLocations`(SITE_TREE) · `siteDeps`(4 תלויות) · `sitePhotos`(toast-stub camera) · `siteArchive`(3) · `siteSafety`(5 tips, rotation יומי + ack→push).
- **3.2** (4ש') `siteSnagging`(R9 inline "תאר ליקוי" + fix) · `siteAttendance`(clock-in/out GPS-demo) · `siteDiary`(R9 inline) · `siteInspect`(R9 inline + complete). כל ה-`prompt`→inline.
- **בדיקות:** snag-CRUD · attendance-state · gantt-span=27.

## Phase 4 — משימות + פרויקט-חכם (≈1.5 ימים)
- **4.1** (4ש') משימות §6: 5 משימות + מכונת-סטטוס 5-מצבים (`taskStatusInfo`) · worker-submit→review **auto-advance** · manager approve/reject · תצוגת-מנהל מול תצוגת-עובד (`renderTasks`) · `WORK_LOG`. photo='demo' → toast.
- **4.2** (4ש') פרויקט-חכם §7: flat day-stages (`task.days`→N, key `id-d`, **9 stages**) · done-marking לא-מסודר · `smartStepDone` · day-picker · התקדמות=done/total. (embed-diagram תלוי במערכת-הקטלוג — gate מאחורי זה.)
- **בדיקות:** status-transitions · auto-advance · 9-stages · progress-math.

## Phase 5 — מלאי + סריקת-תוכנית (≈1 יום)
- **5.1** (2ש') מלאי §8: `STOCK_DEMO`(11) · 2 tabs (מחסן/אתר) · `moveStock` · empty-states.
- **5.2** (5ש') סריקה §9: 4 `PLAN_TYPES` + zones/stores · `bestStore` (השוואת-מחיר) · flow (upload→canvas→results) · `addScanToCart` · doc-OCR §9d → **toast-stub** (server). canvas/blueprint = ויזואל סטטי, לא view-מלא.
- **בדיקות:** bestStore-min · scan-total-sum · stock-move.

## Phase 6 — בית + reorder + ליטוש (≈0.5 יום)
- **6.1** (2ש') `renderReorderHistory`(DEMO_HISTORY) + home product cards (3 keys) — קיפול למשטחים קיימים.
- **6.2** (2ש') ליטוש: RTL · a11y/Semantics · global-error-handler · בדיקות-רגרסיה לכל ANTIPATTERN חדש.

---

## סיכום
| Phase | תחום | אומדן |
|---|---|---|
| 0 | data + helpers | 1 יום |
| 1 | פרויקטים + תקציב | 1 יום |
| 2 | מרכז-פיננסים (10) | 1.5 ימים |
| 3 | ניהול-אתר (10) | 1.5 ימים |
| 4 | משימות + פרויקט-חכם | 1.5 ימים |
| 5 | מלאי + סריקה | 1 יום |
| 6 | בית + ליטוש | 0.5 יום |
| | **סה"כ parity-קבלן** | **~8 ימי-עבודה** |

**נפרד מזה — חוסמי-השקה (P0, לא-קוד, מ-`LAUNCH_READINESS.md`):** iOS usage-strings+signing · Android keystore+Play · Huliot R2-crops. (~1–2 ימים קונפיג + חשבונות-חנות.)

**מוכנות להתחלה:** ✅ מקור verbatim מלא (proto/04) · ✅ עלים קיימים (אפס כפתורים-חדשים) · ✅ אסטרטגיית-R2 כתובה · ✅ data-seeds ממופים. **המלצה: להתחיל ב-Phase 0** (תשתית) — הוא חוסם את כל השאר.
