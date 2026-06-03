# מרכז-פיננסים (Category B) + ניהול-אתר (Category C) (19452–20800)

## ⭐ מרכז-פיננסים `fin-*` (19452–19807)
**נתונים:**
- `BUILD_INDEX` (19459) = `{base:121.3, current:128.7, 'מדד תשומות הבנייה'}`.
- `PAYMENT_TERMS` (19461) — מזומן(0) · שוטף+30 · שוטף+60 · לפי-אבני-דרך. `activePaymentTerm='net30'`.
- `subcontractors` (19469) — 3 קבלני-משנה (אינסטלציה/חשמל/גמר), כל אחד `{allocated, spent}`.
- `approvalQueue` (19475) — 2 אישורי-רכש ממתינים (ברזל-זיון ₪8400 · דבק ₪2600).
- `penaltyLedger` (19480) — קנסות-איחור · `FX_RATES` (19482) = USD 3.72 · EUR 4.05 · GBP 4.71.

**פונקציות** (`openFinanceHub`→`finFeature`): **`finIndex`** (מדד-תשומות) · `finPayTerms`/`setPaymentTerm` · **`finSubs`** (קבלני-משנה) · `finApprovals`/**`decideApproval`** (אישור/דחייה) · `finThresholds` (ספי-תקציב) · **`finROI`** · `finInvoiceSplit` (פיצול-חשבונית) · `finPenalties`/`addPenalty` · **`finReports`**/`downloadFinReport` · `finFX`/`updateFXCalc` (מחשבון-מטבע).

## ⭐ ניהול-אתר `site*` (19808–20800)
**נתונים:**
- `GANTT_TASKS` (19815) — `{name, start, len, done%}`: יסודות 100% · שלד 100% · אינסטלציה-גסה 70% · חשמל-גס 55% · טיח-וריצוף 20%.
- `SAFETY_TIPS` (19833) — קסדות+אפודים · ניתוק-מתח · יציבות-פיגומים.
- `SITE_TREE` (19841) — `{floor, apts:[{n, rooms[]}]}` (קומות→דירות→חדרים).
- `ARCHIVED_PROJECTS` (19849) — שהושלמו: מגדל-הרצליה(2024,24יח׳) · בית-רעננה(2023) · משרדים-ת"א(2023).

**פונקציות** (`openSiteHub`→`siteFeature`): **`siteGantt`** (לוח-זמנים) · **`siteSnagging`**/`addSnag`/`fixSnag` (ליקויים) · `siteLocations` (עץ-אתר) · **`siteAttendance`**/`clockAttendance` (נוכחות-שעון) · `siteDiary`/`addDiaryEntry` (יומן-עבודה) · `siteSafety`/`ackSafety` (אישור-בטיחות) · `siteDeps` (תלויות-משימות) · `sitePhotos` (תיעוד before/after).
**10 כלי-site-hub verbatim** (Preact dial, INSP-0037): 📅 תרשים-גאנט · 🔧 רשימת-ליקויים · 🏢 קומה·דירה·חדר · 📍 נוכחות-GPS · 📓 יומן-עבודה · 🦺 התראות-בטיחות · 🔗 תלויות-חומרים · 📸 צילום-לפני/אחרי · 🔍 **ביקורות-מפקח** (חדש — לא היה בפונקציות) · 🗄️ ארכיון-פרויקטים.

---
**תובנה:** שני ה-hubs האלה (B/C) הם "מרכז-פיננסים" (כפתור ב-`view-project`) ו"ניהול אתר הבנייה" (כפתור ב-`view-tasks`) — כל אחד hub-overlay עם רשת-tiles → feature-overlay לכל כלי. הם הרחבת-העומק של אפליקציית-הקבלן מעבר לרכש.

---

## 🔄 Preact — דלתא מול אב-הטיפוס
🔧 **תיקון (INSP-0039 + grep):** **מרכז-פיננסים (B) = subtree של 10 dial-leaves** ב-Preact (לא leaf בודד), verbatim — התוכן ported, הפונקציונליות (מדד/ROI/calculators) = drill/toast, לא רצה. **site-hub (C) גם נשזר — 10 dial-leaves** (INSP-0037!) — תיקון נוסף: ניהול-אתר **כן** ב-Preact כ-leaves (לא 'נעדר'), אך הגאנט/ליקויים-flows לא רצים.

---

## 📱 Flutter — דלתא
⭐ **`kFinanceHub`** (`menu_trees.dart`) — מרכז-פיננסים קיים כ**עץ-dial** (יותר מ-Preact שהשמיט אותו). ➖ ניהול-אתר (C — גאנט/ליקויים/נוכחות/יומן) — לא הומר.
