# ROADMAP — תוכנית פעולה מלאה עד השקה

> **מקור-האמת לסדר-העבודה.** מבוסס על ידע-מלא מהפרוטוטייפ (`/index.html` 22,416
> שורות) + Preact (`app/` 43 ביקורות) + מצב Flutter הנוכחי. כל שלב מוגדר: **מה
> בונים**, **מאיפה לוקחים** (מקור), **כיצד** (dial, verbatim, helper+test),
> **קריטריון סיום** (definition of done). מתעדכן ככל שמתקדמים.

---

## מפת-מצב נוכחית (נקודת-פתיחה)

### מה חזק וסגור ✅
| תחום | פירוט |
|---|---|
| קטלוג | 935 מוצרי Lipskey · חיפוש + מגדיר + עץ-חכם · גיליון-מוצר עם צ׳יפים |
| Install Studio + BOM | מנוע Dijkstra · שער-תאימות · 887 חיבורים (עמוק מהפרוטוטייפ!) |
| סל + checkout | סל מלא · תשלום בסיסי |
| צ׳אטים + התראות | רשימות · סינון · הגדרות |
| הגדרות | 4 מסכים · ~20 הגדרות פעילות · persist |
| BS dial | 5 personas × עצים · 4 עם תוכן-עלים |
| בדיקות | 52 קבצי-בדיקה · 12 suites · flutter analyze clean |

### מה בנוי אך מנותק 🔌
| תחום | פירוט |
|---|---|
| תפריט-קבלן (Menu FAB) | בנוי מלא (`menu_dial_widget.dart`) — אין trigger |
| חיפוש FAB | בנוי (`search_dial_widget.dart`) — אין trigger |
| 4 persona tiles | עצים קיימים → כל עלה = toast "בבנייה" |
| מרכז-פיננסים + 5 hubs | עלים בנויים verbatim → toast |

### מה חסר לגמרי ❌
- כרטיס-קבלן · דרגות · הישגים · BuildCoins · מועדון VIP
- פרויקטים · אתרים · תקציב · ניהול-אתר · משימות
- RFQ · RMA · השכרה · פקדונות · MSDS · XML ממשלתי · חתימה
- מנוע-הזמנות משותף (SYS_ORDERS) · RBAC · Onboarding
- 4 אפליקציות-תפקיד פונקציונאליות (חנות/שליח/עובד/מנהל)

### חסום תמיד ⛔ (תלוי-בקצה, לא בונים עכשיו)
- מחירים · AI אמיתי · geo/ספקים-מקומיים · push-notifications · telephony · backend API

---

## כלל-ברזל בכל שלב (R1–R9)

> **R2 אבסולוטי:** כל פיצ׳ר = **dial**. לא מסך מלא, לא dashboard.
> 3 רברטים הוכיחו — אפילו "לוח-קבלן" = dial.
> **R6/R8:** כל מחרוזת עברית = verbatim מהפרוטוטייפ. אסור להמציא.
> **wire → helper → test → commit** — לא commit ללא בדיקה.

---

## שלב 0 — חיבור (מה שקיים → נגיש)
> **מטרה:** כל מה שבנוי נהיה נגיש. אפס פיתוח חדש — רק חיווט.
> **משך משוער:** 1–2 ימים

### 0-A · חיבור Menu FAB ל-trigger
- **מה:** FAB של תפריט-הקבלן שמוכן ב-`menu_dial_widget.dart` צריך trigger לפתיחה.
- **מאיפה:** Preact `menu-speed-dial.tsx` — אותו FAB, אותו trigger.
- **כיצד:** הוסף `FloatingActionButton` עם icon תפריט ל-`home_shell.dart` (בצד שמאל, RTL). לחיצה → `setState` פותח את `MenuDialWidget`.
- **DoD:** לחיצה על ה-FAB → dial נפתח עם 4 טאבים (בית/פרויקטים/רכש/הגדרות).

### 0-B · חיבור Search FAB ל-trigger
- **מה:** `search_dial_widget.dart` בנוי — צריך כפתור-פתיחה.
- **כיצד:** הוסף icon חיפוש מתאים ב-`AppBar` (או FAB שניה). לחיצה → `SearchDialWidget`.
- **DoD:** הדיאל נפתח עם 5 כלים (קולי/ברקוד/פילטרים/מיון/קטלוג).

### 0-C · ממשק BS persona — מה שקיים
- **מה:** tile קבלן ב-BS dial כרגע ריק. להוסיף navigation ל-tabs/menu של הקבלן.
- **כיצד:** קבלן tile → פותח את menu dial (4 טאבים = תפריט הקבלן).
- **DoD:** לחיצה על קבלן ב-BS dial → menu dial נפתח.

---

## שלב 1 — פרופיל וגיימיפיקציה (E)
> **מטרה:** כרטיס-קבלן מלא + דרגות + הישגים + מועדון.
> **ערך:** ויזואלי מיידי · לא תלוי בנתוני-backend · ידע-מלא קיים ב-`port/proto/05` + `port/profile-rewards.md`.
> **משך משוער:** 3–5 ימים

### 1-A · כרטיס-קבלן + סטטיסטיקות
- **מקור:** proto `refreshIdentity` [L6545], `CONTRACTOR_ID`, `identityStats`
- **מחרוזות verbatim:** `"הזמנות"` · `"חיסכון"` · `"דרגה"` · `"ניקוד"` · `"ספקים"` · `"מוצרים"` · `"אתרים"` · `"פרויקטים"` (ראה `port/proto/05` §פרופיל)
- **כיצד:** dial-tree `PROFILE_TREE` (כמו Preact `settings-tree.dart` pattern) → עלה ראשי מציג שם+דרגה+avatar badge; sub-tree עם סטטיסטיקות
- **helper:** `identityStatsHelper(orders, savings, ...) → ProfileStats` — ניתן לבדיקה
- **DoD:** dial מציג name/rank/stats מ-mock; helper בדיקה עוברת.

### 1-B · מערכת-דרגות (RANKS)
- **מקור:** proto `RANKS` [L6499] — 4 דרגות: `{id:'bronze',label:'ברונז',minOrders:0,discount:0}` / `silver/3/2%` / `gold/8/5%` / `platinum/15/8%`
- **כיצד:** `rank_engine.dart` — pure helper `currentRank(orders) → Rank`, `nextRank(orders) → Rank?`, `discountFor(orders) → double`; dial מציג דרגה נוכחית + progress לבאה
- **DoD:** unit tests לכל ערך-גבול (0/2/7/8/14/15 הזמנות); dial מציג נכון.

### 1-C · הישגים (6 badges)
- **מקור:** proto `identityAchievements` [L6535] — 6 תנאים: הזמנה ראשונה / 5 הזמנות / חיסכון ראשון / ... (verbatim מ-`port/proto/05`)
- **כיצד:** dial-עלים עם icon badge + תיאור verbatim + locked/unlocked state
- **DoD:** 6 עלים; כל badge מציג תנאי נכון לפי state.

### 1-D · מועדון BuildCoins + אתגרים + VIP
- **מקור:** proto `openRewardsHub` [L21452] — `DAILY_CHALLENGES`, `LEADERBOARD_DATA`, `VIP_PERKS`
- **כיצד:** dial-drill (כמו finance-hub pattern) — 4 תת-עצים: `"מטבעות"` / `"אתגרים"` / `"לוח-מובילים"` / `"VIP"`
- **DoD:** dial-drill פתיח; כל תת-עץ מציג נתוני-mock verbatim.

---

## שלב 2 — קבלן: בית, פרויקטים, פיננסים, משימות (B + C)
> **מטרה:** הליבה היומיומית של הקבלן — ניהול עבודה.
> **ידע:** `port/proto/04` (פרויקטים/אתרים/תקציב/משימות) + `port/proto/06` (SYS_ORDERS light).
> **משך משוער:** 5–8 ימים

### 2-A · פרויקטים + אתרים
- **מקור:** proto `renderProjects` [L7455], `PROJECTS` (4 mock projects), `SIM_SITES`
- **מחרוזות:** `"פרויקטים"` · `"אתרים"` · `"סטטוס"` · `"תקציב"` · `"אחוז-ביצוע"` (verbatim)
- **כיצד:** dial-tree ב-menu FAB → tab "הפרויקטים" → projects list dial; כל פרויקט → sub-dial עם אתרים
- **helper:** `projectStats(project) → {budget, spent, pct}` — formula: `spent/budget*100`
- **DoD:** 4 פרויקטים mock מוצגים; אחוז-ביצוע נכון; helper נבדק.

### 2-B · תקציב חי
- **מקור:** proto `renderBudget` [L7159], `openBudgetDetail` [L7190] — קטגוריות תקציב + חריגה + progress bar
- **כיצד:** עלה תקציב ב-sub-dial של פרויקט → 5 קטגוריות + total + חריגה בצבע אדום
- **DoD:** תקציב mock מוצג; חריגה מסומנת אוטומטית.

### 2-C · מסלול-עבודה חכם
- **מקור:** proto `renderSmartProject` [L7348], `TASKS` — פיצול משימות לימים + done/step states
- **כיצד:** dial-drill: כל משימה → circle + label + status chip (ממתין/בביצוע/הושלם)
- **DoD:** tasks mock עם 3 סטטוסים; toggle מעדכן state.

### 2-D · ניהול-אתר (Site Hub — 10 כלים)
- **מקור:** proto `openSiteHub` [L19856], `SITE_TREE` — גאנט / ליקויים / קומה-דירה-חדר / יומן-עבודה / בטיחות / ...
- **כיצד:** dial-drill 10 עלים verbatim (מחרוזות מ-proto); כל עלה = content-placeholder אמיתי (לא toast)
- **DoD:** 10 עלים מוצגים verbatim; 3 עלים מרכזיים (גאנט/ליקויים/יומן) עם mock data.

### 2-E · מרכז-פיננסים חי (Finance Hub — 10 כלים)
- **מקור:** proto `openFinanceHub` [L19487], `kFinanceHub` — מדד-מחירים / תנאי-תשלום / ROI / מט"ח / ...
- **כיצד:** dial-drill 10 עלים (כבר בנויים כ-toast) → להחליף toast בתוכן אמיתי במה שיש נתון
- **עלים אמיתיים:** ROI helper · מחשבון-מט"ח (ER mock) · פירוט-תנאים
- **DoD:** 7/10 עלים עם תוכן אמיתי; 3 ⛔ חסומים מסומנים.

### 2-F · משימות + אינטגרציה
- **מקור:** proto `renderTasks` [L8421], `TASKS` — 5 מצבים: ממתין/בדיקה/מאושר/בביצוע/הושלם
- **כיצד:** dial-drill; state-machine `taskTransition(task, action) → TaskState`
- **DoD:** 5 מצבים; transition helper נבדק ב-unit test.

---

## שלב 3 — מסחר ו-B2B (D)
> **מטרה:** הזרימות הטרנזקציוניות — RFQ/RMA/השכרה/MSDS/XML/חתימה.
> **ידע:** `port/proto/03` — כל פרוטוקול מתועד עם מחרוזות + helper-signatures.
> **משך משוער:** 5–8 ימים

### 3-A · מתכנן-משלוחים
- **מקור:** proto `renderShipPlanner` [L18583] — מודל: `lines=[{idx,qty,wave,shipTo}]`
- **helper:** `buildShipPlan(cartLines, suppliers) → ShipPlan` — פיצול לגלי-משלוח
- **DoD:** dial מציג גלים; helper נבדק.

### 3-B · RFQ מכרזים
- **מקור:** proto `openRFQ`/`submitRFQ` [L19357] — draft → list → submit
- **כיצד:** dial-drill: רשימת מכרזים + "מכרז חדש" (R9: שדה-טקסט inline) + submit
- **DoD:** create + submit mock; state שמור.

### 3-C · RMA החזרות
- **מקור:** proto `openRMA`/`submitRMA` [L18978] — פריטים + סיבה + אישור
- **כיצד:** dial-drill: items list + סיבה dropdown + submit
- **DoD:** flow מלא mock.

### 3-D · השכרת כלים + פקדונות
- **מקור:** proto `RENTAL_TOOLS` / `DEPOSIT_ITEMS` [L19040/19115]
- **helper:** `rentalCost(tool, days) → double` (ימים × תעריף)
- **DoD:** helper נבדק; dial מציג חישוב נכון.

### 3-E · MSDS גיליונות-בטיחות
- **מקור:** proto `openMSDS` [L19420], `MSDS_SHEETS` — סיכון/טיפול/עזרה-ראשונה verbatim
- **כיצד:** dial עם dropdown → content verbatim
- **DoD:** 3 גיליונות mock מוצגים.

### 3-F · ייצוא XML ממשלתי
- **מקור:** proto `buildGovXML` [L19298] — מבנה DocumentType 305, מבנה 1.31
- **helper:** `buildGovXml(order) → String` — pure XML builder (ניתן לבדיקה)
- **DoD:** helper מחזיר XML תקין; unit test מאמת מבנה.

### 3-G · חתימה + תעודת-משלוח
- **מקור:** proto `initSignaturePad` [L19166] / `showDeliveryNote` [L17212]
- **כיצד:** `SignatureCanvas` widget + PDF-style delivery note (Flutter `CustomPainter`)
- **DoD:** חתימה נשמרת כ-image; תעודה מוצגת.

### 3-H · עומק-checkout (per-supplier billing + credit)
- **מקור:** proto `computeCheckout` [L10838] — חלוקה-לפי-ספק, קרדיט-קבלן
- **מקור credit:** proto `openCreditDetail` [L11005], `CONTRACTOR_CREDIT`
- **כיצד:** הרחבת `checkout_helper.dart`; dial credit לצד הסל
- **DoD:** split-billing helper נבדק; credit dial מציג מסגרת/ניצול.

---

## שלב 4 — מנוע-הזמנות + 4 אפליקציות-תפקיד (G)
> **מטרה:** SYS_ORDERS המשותף → 4 personas פונקציונאליות.
> **ידע:** `port/proto/06` — מכונת-מצבים מלאה + 4 persona flows.
> **⚠️ R2 מוחלט:** dial-drill בלבד, לא dashboards!
> **משך משוער:** 8–12 ימים

### 4-A · מנוע-הזמנות המשותף (SYS_ORDERS)
- **מקור:** proto `SYS_ORDERS` [L11970] — 6 שלבים: `new→confirmed→picked→shipped→delivered→closed`
- **כיצד:** `order_engine.dart` — Riverpod provider `ordersProvider`; state machine `transition(order, action, role) → Order`; כל persona קורא אותו provider
- **events:** `onOrderCreated`, `onOrderConfirmed`, `onOrderShipped`, `onOrderDelivered`
- **DoD:** מכונת-מצבים unit test (כל 6 שלבים × 5 roles); provider מחובר לסל.

### 4-B · חנות-ספק (🏪)
- **מקור:** proto `renderStoreOrders` [L17080], `renderStoreStock` [L17352], `STORES`/`STORE_STOCK`
- **flows:** אישור-הזמנה → ליקוט → שיגור → toggle-מלאי → פורטל (8 עלים)
- **כיצד:** BS dial → חנות tile → dial-drill; כל פעולה קוראת ל-`ordersProvider.transition`
- **DoD:** flow מלא mock; מעבר `new→picked` ב-test.

### 4-C · שליח (🛵)
- **מקור:** proto `renderCourierJobs` [L17963], `FLEET`/`DIST_ZONES`
- **flows:** jobs-list → קבלת-משלוח → progress (pickup→transit→delivered) → POD חתימה
- **DoD:** flow mock; `shipped→delivered` transition ב-test.

### 4-D · עובד (🦺)
- **מקור:** proto `renderWorker` [L11832], `WORK_LOG`/`WORK_SHIFTS`
- **flows:** משימות-פעילות → approval loop (עובד מסמן → מנהל מאשר) → work-log
- **DoD:** approval loop mock; state transition ב-test.

### 4-E · מנהל (👔)
- **מקור:** proto `renderMgr*` [L12133+] — KPI / הזמנות / לקוחות / CRUD
- **flows:** KPI חי (helper) → הזמנות כל-הסטטוסים → לקוחות → ניהול-מוצרים
- **helper:** `kpiSnapshot(orders) → KpiData` — pure, נבדק
- **DoD:** KPI helper נבדק; 4 sections מוצגים; CRUD mock.

---

## שלב 5 — Onboarding + RBAC + אבטחה (F)
> **מטרה:** זרימת-כניסה · בחירת-מקצוע · RBAC מלא.
> **ידע:** `port/proto/05` (RBAC_MATRIX) + `port/proto/01` (ONBOARD_SCREENS).
> **משך משוער:** 3–5 ימים

### 5-A · Onboarding (הכרעה קודם)
- **מקור:** proto `ONBOARD_SCREENS` [L11634] — splash → welcome → login → מקצוע → app
- **הכרעה נדרשת:** האם מממשים onboarding מלא (תלוי backend) או מדלגים ב-v1?
- **v1 מינימום:** בחירת-מקצוע ב-settings; splash screen עם logo

### 5-B · RBAC matrix
- **מקור:** proto `RBAC_MATRIX` [L21675] — 5 roles × טבלת-הרשאות; `can(role, perm) → bool`
- **helper:** `rbac_engine.dart` — `canDo(UserRole, Permission) → bool`; permissions enum
- **DoD:** unit test לכל תא ב-matrix (5×N); UI מסתיר פעולות לפי role.

### 5-C · מרכז-אבטחה
- **מקור:** proto `openSecurityHub` [L21751] — 2FA / ביומטרי / session / פרטיות / audit-log
- **כיצד:** dial-drill; audit-log = רשימת events בפועל מ-`ordersProvider`
- **DoD:** 5 קטגוריות; audit-log מציג events אמיתיים.

---

## שלב 6 — ליטוש חוצה-מערכת (H + I)
> **מטרה:** איכות, השלמות, i18n, הגדרות-שנשארו.
> **משך משוער:** 3–4 ימים

### 6-A · מועדפים
- **מה:** כפתור ♡ על גיליון-מוצר; `favoritesProvider` persist; מסנן "מועדפים" בחיפוש
- **DoD:** toggle שמור cross-launch; מסנן עובד.

### 6-B · חיפוש כללי (SearchIndex הרחב)
- **מקור:** proto `buildSearchIndex` [L8591] — אינדקס שמכסה גם פרויקטים/אתרים/משימות
- **כיצד:** הרחבת `search_index.dart` עם entities חדשים משלבים 1–5
- **DoD:** חיפוש `"פרויקט"` מחזיר תוצאות.

### 6-C · i18n
- **מצב:** he מלא; ar/en stub
- **הכרעה:** ar RTL מלא (תלוי-תרגום) או להשאיר stub עד launch?
- **v1 מינימום:** לוודא he ARB שלם; כל מחרוזת חדשה נכנסת ל-ARB.

### 6-D · הגדרות-נשארו
- **מה:** ~130 הגדרות mock שנשארו toast → לחבר מה שיש להן נתון (כ-10 נוספות); השאר = ⛔
- **DoD:** `WIRING.md` מעודכן; אין הגדרה שכתוב בה "⛔" ובפועל ניתנת לחיבור.

---

## שלב 7 — יציבות, בדיקות, השקה
> **מטרה:** אפס regressions · build מוצלח · store-ready.
> **משך משוער:** 3–5 ימים

### 7-A · כיסוי-בדיקות
- כל helper חדש משלבים 1–5 = unit test
- כל dial חדש = widget smoke-test (נפתח, מציג עלים)
- כל state-machine = unit test לכל מעבר
- **יעד:** flutter test 100% green (ללא skip)

### 7-B · flutter analyze clean
- אפס errors + warnings ב-`very_good_analysis`
- **יעד:** `flutter analyze` → `No issues found!`

### 7-C · build ייצור
```bash
flutter build web --release    # < 5 MB main.dart.js
flutter build apk --release    # APK לבדיקה
flutter build ios --release    # להגשה ל-App Store
```

### 7-D · regression smoke
- 12 suites in-app harness: כולן ✅
- WIRING.md: כל שורה מתועדת ועדכנית

### 7-E · GitHub Pages deploy
- `build/web/` → deploy.yml → Pages URL עדכנית
- בדיקה: app נטען ב-Chrome + Safari + Firefox

---

## לוח-זמנים משוער

| שלב | תוכן | ימים |
|---|---|---|
| **0** | חיבור מה-שקיים | 1–2 |
| **1** | פרופיל + גיימיפיקציה | 3–5 |
| **2** | קבלן: בית/פרויקטים/פיננסים/משימות | 5–8 |
| **3** | מסחר B2B | 5–8 |
| **4** | SYS_ORDERS + 4 personas | 8–12 |
| **5** | Onboarding + RBAC | 3–5 |
| **6** | ליטוש חוצה | 3–4 |
| **7** | יציבות + השקה | 3–5 |
| **סה"כ** | | **31–49 ימי-עבודה** |

---

## כלל "Done" לכל פריט

```
[ ] Helper טהור + unit test
[ ] Dial נפתח (widget smoke test)
[ ] מחרוזות verbatim (לא המצאה)
[ ] WIRING.md מעודכן
[ ] flutter analyze clean
[ ] גרסה bump + commit
```

---

## קישורים לידע

| מה צריך לדעת | מסמך |
|---|---|
| proto — כל שורת-מקור | `port/proto/01`–`08` |
| Preact — כיצד תורגם ל-dial | `port/preact/01`–`05` |
| תחום E מוכן-ליישום | `port/profile-rewards.md` |
| מצב נוכחי Flutter | `SPEC.md` + `WIRING.md` |
| R1–R9 | `../app/RULES.md` |
| master status | `PARITY.md` |
| כיסוי-ידע | `port/COVERAGE.md` |
