# תוכנית — סיום "לוח קבלן": גל 1 (חיווט כפתורים קיימים) → גל 2 (פיצ'רים חסרים)

> **הגדרת-המשתמש (2026-06-03):** לוח-קבלן = אפליקציית-ה-Flutter הקיימת (`app_flutter/`, סגנון-וואטסאפ, 4 טאבים). "להכניס את כל מידע-הקבלן **בלי כפתורים חדשים**. קודם חיווט-מלא על בסיס הכפתורים הקיימים, אחר-כך הפיצ'רים החסרים."
> ביצוע על **`claude/whats-happening-LyY9G`** דרך הפרוטוקול (116 שערים, דוחות 21–22). מסמך זה = תכנון.

## עיקרון-העל (אומת מול הקוד)
- **כל עלי-התפריט הקיימים = toast "בבנייה"** היום (`menu_dial_widget.dart:118` → `showToast('${s.title} — בבנייה')`; גם ב-`bs_dial_widget.dart:79`). ⇒ **גל 1 = להחליף את ה-toast בהתנהגות-אמת. אפס כפתורים/מסכים חדשים.**
- מקור-אמת verbatim: **`app_flutter/knowledge/port/proto/04-contractor-projects-tasks.md`** (546ש', כל String/מספר/`[L#]`).
- **R2** (אין view חדש) · **R6/R8** (מחרוזות verbatim) · **R9** (`prompt`→inline) · server/print/camera/OCR→toast-stub.
- **קדימות:** פיצ'ר שיש לו כפתור (גל 1) לפני פיצ'ר בלי כפתור (גל 2).

## מצאי-הכפתורים הקיימים (מ-`data/menu_trees.dart`, אומת)
| dial-tree | כפתורים | סטטוס היום |
|---|---|---|
| `kHomeTree` 🤖 | 9 כלי-AI | toast "בבנייה" |
| `kHomeTree` 📐 | 4 סוגי-תוכנית (סריקה) | toast |
| `kHomeTree` 📦 | 2 (מחסן/אתר) | toast |
| `kHomeTree` 📋 | 10 כלי ניהול-אתר | toast |
| `kCartTree` 🛒/📦 | סל + 6 שירותים | סל=אמת; שירותים=toast |
| `kFinanceHub` | 10 פיצ'רי-פיננסים | toast |
| `projectsTree()` | 3 פרויקטים + מרכז-פיננסים | toast |
**סה"כ גל-1 = ~41 עלים קיימים לחיווט.**

---

# 🌊 גל 1 — חיווט מלא של הכפתורים הקיימים (~6.5 ימים)

## W1.0 — תשתית (חוסם — חייב ראשון) ≈1 יום
data verbatim → Dart immutables + Riverpod StateNotifiers + helpers (proto/04 §0,§דata-notes).
- seeds: `PROJECTS`(3) · `budgetCategories`(4)+`projectBudget` · `subcontractors`(3) · `approvalQueue`(2) · `PAYMENT_TERMS`(4) · `FX_RATES`/`BUILD_INDEX` · `GANTT_TASKS`(6) · `snagList`(2) · `inspections`(2) · `SAFETY_TIPS`(5) · `SITE_TREE`(3) · `ARCHIVED_PROJECTS`(3) · `STOCK_DEMO`(11) · `PLAN_TYPES`(4+zones/stores).
- helpers + מתמטיקה-מדויקת: `fMoney`/`caToday` · pct=**66%** · ROI×1.42 · index +6.10% · invoice-split-לפי-משקל · triangular-weights. **gate-42: test לכל helper.**

## W1.A — מרכז-פיננסים: 10 כפתורים (`kFinanceHub`) ≈1.5 ימים
*proto/04 §4. כל leaf מחליף toast ב-render-אמת.*
| כפתור | מקור | מהות |
|---|---|---|
| 📈 הצמדה למדד | §4 finIndex `[L19520]` | base121.3/cur128.7/+6.10%/צמוד |
| 🗓️ תנאי תשלום | finPayTerms `[L19545]` | 4 תנאים + בחירה |
| 👷 קבלני משנה | finSubs `[L19569]` | 3 subs + ניצול |
| ✅ אישורי רכש | finApprovals `[L19594]` | **RBAC `requirePerm`** + audit + push |
| 🔔 התראות חריגה | finThresholds `[L19633]` | 80/90/100% gauge |
| 📊 ניתוח ROI | finROI `[L19657]` | ×1.42 |
| 🧾 פיצול חשבוניות | finInvoiceSplit `[L19678]` | ₪12,800 לפי-משקל |
| ⏰ פיצויים וקנסות | finPenalties `[L19698]` | **R9 inline** + ₪500/יום |
| 📄 דוחות PDF | finReports `[L19729]` | **toast-stub** (print) |
| 💱 רכש במט״ח | finFX `[L19773]` | מחשבון USD/EUR/GBP |

## W1.B — ניהול-אתר: 10 כפתורים (`kHomeTree` 📋) ≈1.5 ימים
*proto/04 §5.*
📅 גאנט(6, RTL) · 🔧 ליקויים(**R9 inline**+fix) · 🏢 קומה·דירה·חדר(SITE_TREE) · 📍 נוכחות(clock GPS-demo) · 📓 יומן(**R9 inline**) · 🦺 בטיחות(5 tips+ack→push) · 🔗 תלויות(4) · 📸 צילום(**toast camera**) · 🔍 ביקורות(**R9 inline**+complete) · 🗄️ ארכיון(3).

## W1.C — מלאי: 2 כפתורים (`kHomeTree` 📦) ≈0.25 יום
*proto/04 §8.* מחסן/אתר · `STOCK_DEMO`(11) · `moveStock` · empty-states.

## W1.D — סריקת-תוכנית: 4 כפתורים (`kHomeTree` 📐) ≈0.75 יום
*proto/04 §9.* אינסטלציה/חשמל/אדריכלות/גמר · `PLAN_TYPES`+zones+stores · `bestStore`(השוואה) · `addScanToCart` · OCR→**toast-stub**. canvas=ויזואל-סטטי (לא view).

## W1.E — AI hub: 9 כפתורים (`kHomeTree` 🤖) ≈0.5 יום
חיזוי-מלאי · **ברקוד(אמת — mobile_scanner קיים)** · **דיבור(אמת — speech_to_text)** · חלופות-זולות · סריקת-תוכניות(→W1.D) · התאמה-משולשת(→VerifiedSpec) · מזג-אוויר · בלאי · analytics. *רוב = honest-toast (server-side); ברקוד/דיבור כבר אמיתיים — לחווט.*

## W1.F — הזמנות/שירותים: 6 כפתורים (`kCartTree` 📦) ≈0.75 יום
*proto/03.* השכרת-כלים · פקדונות · החזרה(RMA) · מכרז-ספקים(RFQ) · גיליונות-בטיחות(MSDS) · השוואת-מחירים. (חלק demo-stubs ב-store היום → לחווט מלא או honest-stub.)

## W1.G — פרויקטים: 3 כפתורים (`projectsTree`) ≈0.5 יום
*proto/04 §2.* רשימת `PROJECTS` · `switchProject`(cart per-project) · סטטוס-אתר. (עריכה/הוספה = **R9 inline**.)

---

# 🌊 גל 2 — הפיצ'רים החסרים (אין כפתור היום) (~3.5 ימים)
*תוכן-קבלן מ-proto/04 שאין לו leaf קיים → כאן צריך להחליט איפה לתלות (R2: dial-leaf, לא view).*

## W2.A — מערכת-המשימות (proto/04 §6) ≈1 יום
5 משימות + מכונת-סטטוס 5-מצבים · worker-submit→review **auto-advance** · manager approve/reject · תצוגת-מנהל/עובד · `WORK_LOG`. *(העלה 📋 הנוכחי מוביל ל-ניהול-אתר, לא לזה — צריך נקודת-תליה.)*

## W2.B — פרויקט-חכם "מאפס עד מסירה" (§7) ≈1 יום
9 day-stages · done-marking לא-מסודר · `smartStepDone` · day-picker · diagram-embed (תלוי בקטלוג).

## W2.C — תקציב-בסיסי (§3) ≈0.5 יום
`projectBudget` box/detail/editor + 4 קטגוריות (provider יחיד). *(מרכז-הפיננסים ≠ תקציב-בסיסי; כדאי לקפל לפרויקטים.)*

## W2.D — תוכן-בית (§1) ≈0.5 יום
reorder-history(DEMO_HISTORY 2) · home product-cards(3) · smart-work-route hero.

## W2.E — flows מפורטים של אתרים (§2) ≈0.5 יום
site-status-sheet · site-editor · site-picker (מעבר ל-3 השמות).

---

## סיכום
| גל | תוכן | אומדן |
|---|---|---|
| **1** | חיווט 41 הכפתורים הקיימים (תשתית→פיננסים→אתר→מלאי→סריקה→AI→שירותים→פרויקטים) | **~6.5 ימים** |
| **2** | פיצ'רים חסרים (משימות · פרויקט-חכם · תקציב · בית · אתרים) | **~3.5 ימים** |
| | **סה"כ parity-קבלן מלא** | **~10 ימים** |

*נפרד: חוסמי-השקה P0 (קונפיג-חנות, לא-קוד) — iOS/Android signing + usage-strings. ~1–2 ימים + חשבונות.*

## נקודת-התחלה
**W1.0 (תשתית)** — חוסם את כל גל 1. בלי ה-data-seeds + helpers אי-אפשר לחווט אף כפתור. אחריו W1.A (פיננסים) — 10 כפתורים, ההשפעה-הכי-גדולה-לקבלן.
