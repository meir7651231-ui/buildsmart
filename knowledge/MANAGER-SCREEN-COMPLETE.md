# מסך הניהול (מנהל המערכת 👔) — מסמך‑אב מלא לבנייה

> נכתב 23/6 ממחקר‑3‑חוקרים (מקור‑קנוני Preact · קוד‑Flutter חי · מסמכי‑ידע). **כל עברית = verbatim · כל שורה = file:line.**
> **גילוי‑מפתח:** מסך‑הניהול **כבר בנוי ב‑Flutter כלוח מלא 4‑טאבים, ורובו חי.** "לבנות" = להשלים את **פערי‑העריכה** + פיצ'רים חדשים. **ה‑dial הישן של המנהל deprecated → אין מוקש‑R2.**

---

## 0. TL;DR
- **נקודת‑כניסה:** role‑picker → 👔 מנהל המערכת → **כניסת‑בעלים עם Google** (allowlist `meir7651231@gmail.com`) **או** seed `admin`/`5555`. **המנהל לא מתנתק · אין דמו.**
- **מסך:** `ManagerDashboardScreen` (`manager_dashboard_screen.dart`, ~3,409 שורות) · כותרת **"מרכז השליטה"** · 4 טאבים.
- **חי:** 3 הטאבים הראשונים + רוב טאב‑הניהול + impersonation + role‑assign + AI‑אשראי.
- **פערים (לבנות):** עריכת **עץ‑מוצרים · הגדרות‑אפליקציה · מותגים‑ומחירים** (תצוגה‑בלבד היום) · ניהול‑מוצרים/חנויות CRUD · יומן‑ביקורת · אכיפת‑RBAC בשרת.

---

## 1. כניסה וזהות
| רכיב | קובץ | פרט |
|---|---|---|
| בורר‑persona | `role_picker_sheet.dart` | "מי אתה?" → 👔 מנהל · subtitle "ניהול מוצרים, חנויות, לקוחות" |
| שער‑כניסה (בעלים) | `welcome_screen.dart:283‑395` | **"כניסה עם Google" בלבד** — allowlist `isOwnerEmail()`; דחייה ביושר ללא‑בעלים |
| כניסת‑seed | `board_auth.dart:243‑266` | `admin` / `5555` (תצוגה: "מנהל המערכת") |
| כניסת‑בעלים אמיתית | `board_auth.dart:286‑303` | `loginManagerViaGoogle{uid,displayName}` · **NO DEMO · NO LOGOUT** |
| פרופיל | `manager_profile_screen.dart` | "אזור אישי — מנהל המערכת" · סטטיסטיקת‑הזמנות חיה · ⚙️ הגדרות · 🖥️ מעבר‑בין‑מסכים |
| יציאה | AppBar | "‹ יציאה" → welcome |

---

## 2. ארבעת הטאבים (`managerTabProvider` 0‑3)

### 📊 טאב 1 — לוח בקרה  ✅ חי  (`:371‑599`)
- **5 מדדים חיים** מ‑`managerAnalyticsProvider` (`:426‑451`): 🚚 הזמנות פתוחות · 📦 מוצרים בקטלוג · 🧰 אביזרים נלווים · ✅ זמינים כעת · 🏪 חנויות פעילות.
- **צינור ההזמנות** (`:529‑599`) — 6 שלבים עם ספירה חיה + צבע פר‑שלב.
- *(בפרוטוטייפ יש כאן גם: מחזור‑כולל · תמהיל‑קטגוריות · ביצועי‑חנויות 🥇🥈🥉 · ניהול‑מוצרים עם toggle‑זמינות · `＋ מוצר`/`＋ חנות` — **לא פורט מלא ל‑Flutter** = פער.)*

### 🚚 טאב 2 — הזמנות  ✅ חי  (`:665‑1389`)
- רשימה חיה מ‑`ordersEngineProvider` · 3 מדדים: הזמנות / פתוחות / מחזור.
- צ'יפ‑סינון: הכל + 6 שלבים (התקבלה/בהכנה/מוכן לאיסוף/נאסף/בדרך לאתר/נמסר ✓).
- שורת‑הזמנה: 📦 ID · 📞/💬 · מיני‑tracker · פריטים · ₪סכום · **"קדם שלב ›" (שליטת‑על — מקדם כל שלב, `:1149‑1175`)**.
- כרטיס‑פירוט (`:1178‑1389`): tracker מלא · פריטים · קבלן/אתר/סטטוס.

### 👥 טאב 3 — לקוחות  ✅ חי  (`:1404‑2145`)
- רשימת‑קבלנים חיה מ‑`managerCustomersProvider` (נגזר מההזמנות) · 3 מדדים: קבלנים / סך רכש / ניצול אשראי %.
- סינון: הכל / פעיל / ⚠️ אשראי גבוה · כרטיס: 👷 שם · N הזמנות · M אתרים · מד‑אשראי (אדום ב‑90%).
- כרטיס‑פירוט: מסגרת / נוצל / יתרה / אתרים + רשימת‑הזמנות + **"💳 הסבר אשראי"** (`:2075‑2093`).
- **אשראי:** `contractorCredit(name)` hash מקומי 30k‑120k · **A13** `computeCredit()` בשרת כשהדגל ON (`orders_engine.dart:1502`).

### 🛠️ טאב 4 — ניהול  (אקורדיון, `:2147‑3409`)
| מדור | קובץ | סטטוס |
|---|---|---|
| 👷 **אישורי עובדים** | `:2279‑2311` + `:2737‑2773` | ✅ **חי** — תור‑אישור (status `review`), תמונת‑הוכחה, ✅ אשר/↩️ דחה, מזין `tasksProvider`+🔔+מטבעות |
| 🏖️ **בקשות חופשה** | `:2314‑2331` | ✅ **חי** — עובד+שליח, ✅ אשר/❌ דחה, מזין 🔔+thread |
| 🗂️ קטגוריות | `:2334‑2343` | ✅ חי‑תצוגה — ספירה פר‑קטגוריה (אין שינוי‑שם עדיין) |
| 🏷️ מותגים ומחירים | `:2373‑2382` | ⚠️ **תצוגה‑בלבד** (מ‑`kBrands`) — **אין עריכה** |
| ⚙️ הגדרות אפליקציה | `:2346‑2355` | ⚠️ **תצוגה‑בלבד** (אקספרס ₪120 · אשראי ₪50,000 · מע״מ 18%) — **אין עריכה** |
| 🌳 עץ המוצרים | `:2358‑2370` | ⚠️ **סיכום‑בלבד** — **אין עריכת‑אביזרים** |
| 🔑 **שיוך תפקידים** | `:2407‑2422` | ✅ חי (מגודר `authGatewayProvider`) → `ManagerRoleAssignSheet` |
| 🔬 בדיקות רגרסיה | `:2385‑2405` | debug‑only (tree‑shaken ב‑release) |

---

## 3. מערכות מנהל‑בלעדיות
- **🖥️ Impersonation — "מעבר בין מסכים"** (`manager_screens_sheet.dart`): צפייה כעובד/שליח/חנות/קבלן עם באנר **"👔 צפייה כ{label} · מצב מנהל"** + "חזרה לניהול" בנגיעה. one‑deep, לא‑נשמר, ישר seed אמיתי. (`board_auth.dart:305‑344`)
- **🔑 שיוך תפקידים** (`manager_role_assign_sheet.dart`): טלפון→uid (`UsersLookup.uidByPhone`) → בחירת תפקיד (🏪/🛵/🦺/👔 — **לעולם לא 'contractor'**) → `assignRole()` → `setRole` Cloud Function (השרת מאמת admin‑claim). בלי שרת → disabled+באנר "⚠️ שיוך תפקידים זמין רק עם חיבור לשרת... לא בוצע שיוך." אין הצלחה‑מזויפת.
- **🔬 self‑test harness** (`test_harness/runner.dart`): **11 חבילות, 1,539+ טסטים** (catalog/dsync/tabs/buttons/dupes/sections/settings/behavior/products/engine/cart). אמיתי, נאכף ב‑CI.
- **💳 AI אשראי** (`credit_explain_screen.dart`): Claude מסביר את מספרי‑האשראי האמיתיים (אסור להמציא), מגודר `claudeGatewayProvider`. + reject‑reason AI ("✨ נסח סיבת דחייה").

---

## 4. מודל‑דאטה (אמיתי מול seed)
| דאטה | מקור | סטטוס |
|---|---|---|
| הזמנות (רשימה+pipeline+מדדים) | `ordersEngineProvider` | ✅ חי (משותף) |
| לקוחות | `managerCustomersProvider` (נגזר) | ✅ חי |
| קטגוריות | `managerAnalyticsProvider` | ✅ חי |
| אשראי‑קבלן | `contractorCredit` מקומי / `computeCredit` שרת (A13) | מקומי OFF · שרת ON (`kServerCallables`) |
| מותגים | `kBrands` const | ⚠️ seed‑תצוגה |
| הגדרות (אקספרס/אשראי/מע״מ) | const | ⚠️ seed‑תצוגה |
| עץ‑מוצרים | counts בלבד | ⚠️ stub |
| אישורי‑עובדים / חופשות | `tasksProvider` / `vacationRequestsProvider` | ✅ חי (משותף) |
| session‑מנהל | SharedPreferences | ✅ נשמר |
> **הערה:** seed‑המנהל (`managerAnalytics`/`kManagerStores`/`kManagerOrderSeed` ב‑`logic/manager_dashboard.dart`) רץ רק כשאין נתונים‑חיים; כשהדגל ON המסך מציג נתוני‑אמת (P2: seed מזויף גודר ל‑0).

---

## 5. המקור הקנוני (Preact reference — R6/R8)
- **`bs-dial.tsx:177‑235`** ↔ `index.html:4213‑4216` — 4 מדורים: 📊 לוח בקרה (5) · 🚚 הזמנות (6) · 👥 לקוחות (2: 🟢 פעיל · ⚠️ אשראי גבוה) · 🛠️ ניהול (4: 🌳 עץ · 🏷️ מותגים · 🗂️ קטגוריות · ⚙️ הגדרות).
- **`SYSTEM_MANAGER_DASHBOARD.md` (863 שורות)** — המפרט השאפתני המלא: טבלת‑הזמנות (עמודות הזמנה/קבלן/סכום/סטטוס/תאריך/פעולה) · טבלת‑לקוחות (שם/טלפון/אשראי/שימוש/הזמנות/פעולה) · **7 מדורי‑ניהול:** הגדרות‑מערכת · ניהול‑מחסנים‑וספקים · ניהול‑חנויות · דוחות‑וניתוחים · **ניהול‑הרשאות (RBAC)** · **יומן‑ביקורת** · כלים‑ופיתוח.
- **RBAC (verbatim):** "מנהל מערכת: ניהול מלא — הזמנות · קטלוג · משתמשים · דוחות".
- **עורכי‑הפרוטוטייפ (R9 inline):** `mgrAddAcc`/`mgrEditBrand`/`mgrRenameCat`/`mgrEditExpress`/`mgrToggleAvail`/`openMgrStore` — כל אלה **קיימים בפרוטוטייפ אך לא פורטו ל‑Flutter** = רשימת‑הפערים.

---

## 6. 🔧 תוכנית‑בנייה — הפערים (מה למסור לצי)
**עיקרון:** R9 — כל עריכה = **inline input צמוד**, לא modal/prompt. מגודר, אפס‑רגרסיה.

| # | פער | מקור‑פרוטוטייפ | מאמץ |
|---|---|---|---|
| **G1** | **עריכת ⚙️ הגדרות‑אפליקציה** — אקספרס‑fee + מסגרת‑אשראי ניתנים‑לעריכה (מע״מ קבוע), נשמר ומשתקף בעגלת‑הקבלן | `mgrEditExpress`/`mgrEditCredit` | S |
| **G2** | **עריכת 🏷️ מותגים‑ומחירים** — add/edit/remove מותג+מחיר פר‑מוצר | `mgrAddBrand`/`mgrEditBrand`/`mgrDelBrand` | M |
| **G3** | **עריכת 🌳 עץ‑מוצרים** — add/edit/remove אביזר (חובה/אופציונלי + מחיר) פר‑מוצר | `mgrAddAcc`/`mgrEditAcc`/`mgrDelAcc` | M |
| **G4** | **🗂️ שינוי‑שם קטגוריה** (מעדכן כל המוצרים) | `mgrRenameCat` | S |
| **G5** | **ניהול‑מוצרים** בלוח‑בקרה — חיפוש + toggle‑זמינות + add/edit/remove מוצר | `mgrToggleAvail`/`openMgrProduct` | L |
| **G6** | **ניהול‑חנויות** — add/toggle/remove חנות | `openMgrStore`/`toggleMgrStore` | M |
| **G7** | **יומן‑ביקורת** (audit log) — מי עשה מה, server‑persisted | `auditLog` | M |
| **G8** | **אכיפת‑RBAC בשרת** — Firestore rules בודקות manager‑claim לפעולות‑רגישות (חלקי: owner‑claim כבר מאומת‑שרת ca3261e) | RBAC_MATRIX | L |
| **G9** | (אופ׳, v2) 2FA · נעילת‑סשן · דוחות‑וניתוחים מתקדמים | security/service hubs | L |
> **כל ה‑G* כותבים ל‑provider המשותף** (drop‑in server‑ready) — כשהדגל ON, השינוי מסתנכרן לכל הלוחות (כמו ההזמנות).

---

## 7. אינדקס‑קבצים (source‑of‑truth ל‑Flutter)
`manager_dashboard_screen.dart` (4 טאבים) · `manager_profile_screen.dart` · `manager_role_assign_sheet.dart` · `manager_screens_sheet.dart` (impersonation) · `credit_explain_screen.dart` · `regression_panel_screen.dart` · `logic/manager_dashboard.dart` (analytics+seeds) · `state/manager_dashboard_state.dart` · `state/board_auth.dart` (owner/impersonate) · `state/orders_engine.dart:678‑1523` (providers) · `data/sections.dart:152‑199` (dial deprecated) · `test_harness/`.

## ⚠️ R2 — הבהרה
R2 ("אין חלון") הוא כלל **פרויקט‑ה‑Preact (dial)**. ב‑Flutter המנהל **כבר board מלא‑מסך** (החלטה ארכיטקטונית קיימת, ה‑dial deprecated) — **בנייה כאן לא מפֵרה R2.** ✅
