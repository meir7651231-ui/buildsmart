# הנחיה גורפת: מיגור "מידע-מזויף שמתחזה לאמת" בכל האפליקציה → 100% מידע-אמת

> **ביצוע:** `claude/whats-happening-LyY9G` · **דחיפה: רק על "תדחוף".**
> **מקור:** סריקת-6-עדשות מאומתת @HEAD `03506f3c`. **~24 אתרי-רינדור מזויפים על ~15 שורשי-const.**
> **עיקרון:** כמו בלוח-הבקרה — להחליף const→קריאה-חיה, או לגדר/להסתיר ערך שאין לו מקור-אמת. **לא להמציא מספר.**

---

## שני השורשים המערכתיים (למה זה קורה)
1. **בקאנד כבוי כברירת-מחדל** (`backend.dart:12-17`, `USE_FIREBASE_BACKEND`). **אצל הבעלים דלוק** (STUDIO_DART_DEFINES) — לכן מה שמשנה לו זה ה-**★** שלמטה (נשארים מזויפים **גם כשהבקאנד דלוק**, כי הם עוקפים את ריפו-ה-Firebase לגמרי). ⚠️ בבניית-ה-Play (`android-package.yml` שלא מעביר דגלים) **הכול** מזויף — עוד סיבה לתקן את חוסם-ה-Play.
2. **`kHideUnderConstruction=true`** (`under_construction.dart:24`, ברירת-מחדל-חנות) מסיר כל תווית "(הדגמה)/בקרוב". איפה שהדאטה-המזויפת **לא** מגודרת יחד עם התווית → התווית נעלמת, המספר-המזויף נשאר. **תיקון-על:** לגדר את הדאטה-המזויפת יחד עם התווית, או לחווט למקור-אמת.

---

## ⭐ עדיפות-על — 13 ה-★ (מזויפים גם כשהבקאנד חי — מה שהבעלים רואה)

### מנהל (📊 לוח-בקרה · 👥 לקוחות · 🤖 קו-פיילוט)
- **★ `manager_dashboard_screen.dart:674/680/686/692`** — 4 אריחי-KPI (📦 קטלוג=54 · 🧰 אביזרים=148 · ✅ זמינים=202 · 🏪 חנויות="3/3"). שורש: `orders_engine.dart:682-683` מזין const `kManagerStores`/`kManagerCatalogCategories` ל-`managerAnalyticsProvider` **בלי ענף-בקאנד**. → **לקרוא מ-`catalogRepositoryProvider.allProducts()`** (‎‎`catalog_local.dart:182`, ~900 מוצרים אמיתיים) ל-📦/🧰/✅; 🏪 חנויות = אין registry אמיתי → לגדר/להסתיר עד שיהיה.
- **★ `manager_dashboard_screen.dart:2771-2776`** — treemap-קטגוריות + `totalProducts`(202), מסומן "LIVE" אך קורא אותו const. אותו תיקון.
- **★ `manager_dashboard_screen.dart:1758/2242-2254/2352/1846`** — מסגרת-אשראי/יתרה/ניצול-% של לקוח. `creditLimit=contractorCredit(name)` = **hash-של-שם** ל-30k–120k ₪ (`manager_dashboard.dart:256-264`). → **לקרוא `customerCreditProvider`/`computeCredit`**; אם 0 → "לא רשומה", לא hash.
- **★ `logic/manager_copilot.dart:93` (+88/94)** — הקו-פיילוט מזין ל-Claude const catalogCount/storesLabel + Σ-hash-אשראי בתור **"נתוני-אמת"**, ומציג לבעלים. → אותם מקורות-חיים כמו האריחים. *(תיקון #1 סוגר גם את זה.)*

### חנות/ספק (`store_screen.dart`)
- **★ `store_screen.dart:3705-3719`** (הכי חמור בחנות) — `storeOrdersProvider` מחזיר `[...חי, ...5 הזמנות-דמו קבועות]` (BS-1234 "₪5,420·בדרך"...). מרונדרות כאמיתיות, **ומזהמות את מונה ההזמנות-הפתוחות** (`:560-563`). קבלן חדש רואה 5 הזמנות + ~3 "פתוחות" שלא ביצע. → **להחזיר `liveOrders` בלבד** (למחוק `...demoOrders`).
- **★ `store_screen.dart:565/582-585`** — צ'יפ `📨 3 הצעות ספקים` = const `_kSupplierOffersCount=3`, יושב בין 2 צ'יפים חיים. → **להסתיר** עד שיהיה offers-repo.
- **★ `store_screen.dart:197-199`** — אריח 📦 "ההזמנות שלי": `preview:'הזמנה #1234·בדרך'`, `badge:1` קבועים; שורדים `kHideUnderConstruction`. כל משתמש (גם אפס-הזמנות) רואה "1" אדום. → **לגזור מ-`storeOrdersProvider`** (כמו אריח 🛒 ב-`:1135-1142`).
- **`suppliers_screen.dart:42`** — `subtitle:'…66 מוצרים'` קבוע; המסך מציג `kLipskeyCatalog.length`≈923. פי-14 טעות. → **`kLipskeyCatalog.length`** (`lipskey_catalog.dart:496`).

### פיננסים (`finance_hub_sheets.dart`)
- **★ `:1049`** — "ROI צפוי" = `(kBudgetTotal*1.42−…)` = **תמיד 42.0%** (`phaseb_seeds.dart:392`). שורת-התקציב מעליו (`:1042`) חיה → סתירה על הבקאנד. → `financeRepositoryProvider` + מקור-ערך-חוזה.
- **★ `:634/676`** — ניצול-קבלני-משנה % (66/62/69/34) מ-const `kSubcontractors`. → `financeRepository`.
- **★ `:473-478`** — "מדד תשומות-הבנייה" 121.3→128.7 מ-const `kBuildIndex`. → feed-אינדקס חי, או gate-to-empty כמו כלי-ה-FX.
- **★ `:1077/1085`** — פיצול-חשבונית ₪12,800 const. → `financeRepository`.
- **★ `finance_hub_state.dart:57-81 → finance_hub_sheets.dart:727`** — `approvalQueueProvider` (תור-אישורי-רכש AP-201/202) עוקף את הריפו. `FirebaseFinanceRepository.approvals()` **קיים ולא-נצרך**. → **לחווט ל-`financeRepositoryProvider.approvals()/decide()`**.

### בית / תגמולים
- **`smart_home_screen.dart:467-468`** — פס-התקדמות "גמר אמבטיה" = `value:0.38` קבוע, וגם **אין onTap** (עץ-4-שלבים לא נפתח). → provider-התקדמות אמיתי + onTap.
- **`rewards_hub_screen.dart:205/239/322`** — לוח-מובילים (קבלן-לוי 1240...) + תגים "2/4" + קוד-הזמנה `'BUILD-7K29'` — const לכל משתמש. → תווית "(דמו)" כמו לאחים, או חיווט ל-rewards-backend.

---

## 🟠 פקדים-מתים
- **`rewards_hub_screen.dart:338-341`** — "📤 שתף את הקוד" מקפיץ "הקוד **הועתק**" אבל **אין `Clipboard.setData`**. אישור-שקר. → לקרוא ל-Clipboard או להסיר את הטענה.
- **`store_screen.dart:1069-1070`** (גבולי) — pull-to-refresh מסתובב 800ms ואז no-op.

---

## 🚫 מה לא לגעת (מאומת תקין — לא "לתקן")
- **~30 stubs-כנים** מסומנים נכון ("יחובר עם השרת"/"בקרוב"/DEMO-SEED, gated): עובד (תלושים/101/ציוד/בטיחות) · שליח (nav/POD/שפות) · חנות (מסמכים/onboarding/הגדרות-בבנייה/OCR) · פיננסים (FX "שערי דמו" — **זו התבנית הנכונה** שה-5 ★ מפרים) · budget "להמחשה" · intel funnels (חי) · catalog placeholders.
- **מאומת-חי (עובד):** לוח-עובד (folds `tasksProvider`) · לוח+דוחות-שליח (`sysOrdersProvider`/`fulfillmentProvider`) · KPI-חנות-dashboard ("נתונים חיים ממנוע ההזמנות") · סיכום-הזמנות-מנהל total/open/**revenue** (`:975-980`) · spend-לקוח · AI-hub · rewards coins/redeem · departments (`catalogRepo().allProducts()`). **ריפו-ה-`*_firebase` כנים** (מחזירים 0/[] לאנליטיקות-מומצאות) — הבאג הוא ה-providers שעוקפים אותם.

---

## תוכנית-חיווט (שורה לכל תיקון)
1. `orders_engine.dart:682-683` — לבנות `ManagerAnalytics.stores/catalogCategories` מ-`catalogRepositoryProvider.allProducts()` (+פילטר-אביזרים) ו-stores-repo, לא const. (סוגר אריחים :674/680/686/692 + treemap :2772 + דליפת-קו-פיילוט manager_copilot.dart:93 בבת-אחת.)
2. אשראי-מנהל (1758/2242/1846) — `customerCreditProvider`/`computeCredit`; "לא רשומה" כש-0.
3. `store_screen.dart:3718` — למחוק `...demoOrders` → `liveOrders` בלבד (מתקן גם מונה-הפתוחות).
4. `store_screen.dart:583` — להסתיר צ'יפ `📨 offers` (למחוק `_kSupplierOffersCount`).
5. `store_screen.dart:197-199` — לגזור preview/badge מ-`storeOrdersProvider`.
6. `suppliers_screen.dart:42` — `kLipskeyCatalog.length`.
7. `finance_hub_sheets.dart (1049/634/473/1077)` — לנתב ROI/משנה/מדד/חשבונית דרך `financeRepositoryProvider`; לאינדקס — תבנית gate-to-empty + "דמו" של ה-FX.
8. `finance_hub_sheets.dart:727` — `approvalQueueProvider` → `financeRepositoryProvider.approvals()/decide()` (המימוש כבר בנוי).
9. `smart_home_screen.dart:468` — `value:` מ-provider-התקדמות + onTap לכרטיס.
10. `rewards_hub_screen.dart (205/239/322)` — תווית "(דמו)" או חיווט-backend.
11. `rewards_hub_screen.dart:340` — `Clipboard.setData` או להסיר "הועתק".
12. `courier_portal_tab.dart:180,188-189` + `persona_portal.dart:248-255,270-273` — לגדר את שורות-ה**דאטה** (kHaulAvailabilityDemo/kFleet/kSupplierRatings) יחד עם התווית, לא רק ההערה.
13. **מערכתי** — או לבנות עם `USE_FIREBASE_BACKEND=true`, או באנר-קבוע "מצב הדגמה"; ולהפסיק לתת ל-`kHideUnderConstruction` להסתיר תווית שהדאטה-המזויפת שלה נשארת.

## DoD (בייטים לא פרוזה)
- באפליקציה **החיה**: כל אתר-★ מציג מידע-אמת (משנים בשרת→משתנה במסך) או מוסתר/מגודר-בכנות. אפס-const-שמתחזה-לחי. אפס פקד-מת. `kHideUnderConstruction=true` **לא** מותיר מספר-מזויף בלי תווית.
- **לא לשבור** את המאומת-החי ואת ה-stubs-הכנים. הישן ל-rollback. שער-אימות ירוק + אימות-מסך.
