# הנחיה: לוח-הבקרה של המנהל — מידע-אמת + כל הפיצ'רים 100%

> **ביצוע:** `claude/whats-happening-LyY9G` · **דחיפה: רק על "תדחוף".**
> **⚠️ הבהרה קריטית:** האפליקציה **כבר חיה** — `USE_FIREBASE_BACKEND` דלוק דרך `STUDIO_DART_DEFINES`.
> **זו לא בעיית-דגל ולא "מצב-דמו". הבעיה בקוד עצמו.** אל תפתור את זה בהדלקת-דגל — הדגל כבר דלוק.

---

## השורש האמיתי (מאומת · file:line · HEAD 03506f3c)
טאב ה-📊 **לוח-בקרה** מראה מספרים מזויפים **גם כשהאפליקציה חיה**, כי 4 מתוך 5 ה-KPI **כתובים כקבועי-קומפילציה בקוד** ולא קוראים מהשרת בכלל:

- `managerAnalyticsProvider` (`state/orders_engine.dart:682-683`) מזין:
  `stores: kManagerStores` · `catalogCategories: kManagerCatalogCategories` — **קבועים**, לא reads.
- הערכים המקובעים (`logic/manager_dashboard.dart`):
  - 🏪 חנויות → `kManagerStores` = תמיד **"3/3"** (`:57-76`).
  - 📦 קטלוג · 🧰 אביזרים(=148) · ✅ זמינים(=202) → `kManagerCatalogCategories` וכו' (`:158-174`).
- **רק 🚚 הזמנות-פתוחות חי** (`analytics.openOrders` ← `ordersEngineProvider`, מתעדכן אמיתית).
- docstring של הטאב עצמו מודה: *"catalog / accessories / available / stores are static-by-design ports"* (`manager_dashboard_screen.dart:426-430`).

**מסקנה:** גם עם בקאנד חי — 4/5 המספרים קבועים כי הם hardcoded. זה באג-קוד, לא תצורה.

---

## מה לתקן — טאב 0 (📊 לוח בקרה) · הליבה
1. **להחליף את 4 הקבועים בקריאה חיה** מהריפוזיטוריז שכבר קיימים וחיים:
   - 📦 **קטלוג** → ספירה אמיתית מ-`catalogProducts`/repo הקטלוג (השרת כבר מכיל ~3,614 מוצרים — לספור אותם, לא קבוע).
   - 🧰 **אביזרים** → ספירה אמיתית מ-`stockRepository`/קטלוג (קטגוריית-אביזרים).
   - ✅ **זמינים כעת** → ספירה אמיתית של פריטים-במלאי/זמינים מ-`stockRepository`.
   - 🏪 **חנויות פעילות** → מ-repo החנויות האמיתי (לא `kManagerStores` "3/3").
   - נקודת-החיבור: להזרים ל-`managerAnalyticsProvider` (`orders_engine.dart:678-685`) reads במקום ה-const inputs.
2. **אריחים לחיצים (drill-down)** — `_MetricTile` (`manager_dashboard_screen.dart:715-778`) + `_PipelineRow` (`:784-915`) חסרי `onTap`. להוסיף `onTap` לכל אריח → ניווט למסך/רשימה-מסוננת הרלוונטית (קטלוג→מסך-קטלוג, הזמנות→טאב-הזמנות מסונן לפי שלב, חנויות→רשימת-חנויות וכו').
3. **חיווי "חי" אמיתי** — `_LivePill` (`:277-309`) מציג טקסט קבוע "חי". לקשור לסטטוס-קישוריות/בקאנד אמיתי (מחובר=ירוק, לא=אדום).
4. **קו-פיילוט 🤖** (`_CopilotHero`, `:479-540` → `ManagerCopilotScreen`) — כרגע נוחת על "דורש חיבור לשרת" (`manager_copilot_screen.dart:152-158`) כי `claudeGatewayProvider` null בלי `CLAUDE_AI`. **לחווט שיעבוד באמת**: לוודא `CLAUDE_AI` דלוק + ה-gateway פרוס, ושהקו-פיילוט מחזיר תשובה אמיתית. אם לא ניתן כרגע — שלא יוצג ככפתור-פעיל שמוליך לקיר.

## טאבים 1/2/3 (🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול)
כבר מחווטים לכתיבות-אמת (advance/approve/credit/vacations/roles). **לוודא שבבניה-החיה הם קוראים/כותבים ל-Firestore האמיתי ומראים רשומות-אמת — לא seed ולא ריק.**
- אם טאב מראה נתוני-seed או ריק → לבדוק שהריפו החי (`FirebaseOrdersRepository`/customers/stock) הוא זה שנטען, שהאוסף בשרת **מאוכלס**, ושה-**Firestore rules** מתירים למנהל read/write. **חוסר-דאטה ≠ לתקן בקבוע-מזויף** — לאכלס/לתקן-הרשאה.

---

## DoD — הוכחה בבייטים, לא בפרוזה
- באפליקציה **החיה**: כל **5** ה-KPI = מידע-אמת. משנים דאטה בשרת → המספר בלוח **משתנה**. **אפס ערכים קבועים.**
- **כל אריח לחיץ** ומוביל למקום אמיתי (drill עובד).
- **הקו-פיילוט עונה** תשובה אמיתית (או לא מוצג כפעיל).
- **הזמנות/לקוחות/ניהול** פועלים על Firestore אמיתי, והשינויים **נשמרים** (רענון מראה אותם).
- אימות חי (צילום/הדגמה) + שער-אימות ירוק (`central-verify.sh` + טסטים).

## אזהרות
- **לא לשבור** את שלושת הטאבים שכבר עובדים ואת המנועים. רק **לחבר** את הלוח למנועים הקיימים — לא לכתוב מנוע חדש.
- לשמור מסלול-fallback (אם ריפו חי מחזיר שגיאה → לא לקרוס; להציג ריק/הודעה, לא להמציא מספר).
- הישן (const) יורד רק אחרי שהחי מוכח.

## מה כבר קיים לחיבור (לא לבנות מאפס)
`ordersEngineProvider` · `managerCustomersProvider` · `customersRepositoryProvider`+`customerCreditProvider` · `ordersRepositoryProvider`(+firebase/local) · `stockRepository` · `tasksProvider`/`pendingApprovalTasksProvider` · `vacationRequestsProvider` · `pendingRoleRequestsProvider` · `claudeGatewayProvider`(+`logic/manager_copilot.dart`). הכול חי כבר בטאבים האחרים — צריך רק להזרים ללוח.
