# תוכנית-עבודה — "לוח מנהל-המערכת" = **מסך-מלא חדש** (בנוי בדיוק כמו האפליקציה)

## ✅ סטטוס: בוצע (אומת-קוד 2026-06-05) — מסמך תיעוד-היסטורי
> **המנהל כבר בנוי ומאוחד לטרנק (v6.12).** אומת מהקוד: `lib/screens/manager_dashboard_screen.dart` + `lib/logic/manager_dashboard.dart` + `lib/state/manager_dashboard_state.dart` קיימים · נגיש מ-`role_picker` (`Navigator.push`) · מנוע-הזמנות-משותף (`sys_orders`) · הוקשח ב-audit-passes v6.13–v6.16 (`app_flutter/knowledge/WIRING_AUDIT.md`). M0–M5 שלמטה = **תוכנית-המקור (היסטורי)**, לא עבודה-פתוחה. **אל תבנה מחדש.**

> **הגדרת-המשתמש (2026-06-04):** לוח-מנהל = **מסך חדש מלא**, בנוי **בדיוק כמו לוח-קבלן** — אותו דפוס-בנייה (מסך עם טאבים + כפתורים), רק טאבים וכפתורים שונים. **לא** עלי-dial.
> **אפליקציה:** `app_flutter/` (Flutter, v5.96). **ביצוע:** ענף `claude/whats-happening-LyY9G` · push רק על מילה מפורשת.
> **מקור-תוכן:** `index.html` `screen-manager` (`:4207-4240`) + הרינדורים (mgrDashboard/mgrOrders/mgrCustomers/mgrManage) + `kManagerSections` (`lib/data/sections.dart:147-199`). רק `index.html` קובע — **אל** `SYSTEM_MANAGER.md` (מומצא).

## סגנון-הבנייה (העתק מהאפליקציה — אלה הדגמים)
- **מסך:** `ManagerDashboardScreen extends ConsumerStatefulWidget` → `Scaffold` + `AppBar` (כותרת "👔 מנהל המערכת" + back). דגם: `store_screen.dart` / `install_studio_screen.dart`.
- **טאבים-במסך:** `StateProvider<int>` לטאב-פעיל + segmented-toggle + `IndexedStack` לשמירת-state. **דגם מדויק: `updates_screen.dart`** (`_UpdatesToggle` · `seg(i,icon,label)` · `updatesSubTabProvider`). (חלופה: chips כמו `store_screen._SectionChipsRow`.)
- **כניסה:** `role_picker_sheet.dart` — היום מנהל→`OpenDial.bs`. **לשנות:** מנהל → `Navigator.push(ManagerDashboardScreen)` (כמו שהקבלן→HomeShell).
- **תוכן-טאב:** widgets פרטיים `_Xxx` (cards/rows/tiles) ב-`BsTokens` (space 4-32 · radiusCard 16 · כתום #FF7A18 · Heebo) · `showToast` · Riverpod · RTL. בלי מספרי-קסם/צבע-קשיח.
- **קלטים:** inline (לא prompt). server/print → toast-stub.

## 4 הטאבים (verbatim מ-`index.html:4213-4216` + `kManagerSections`)
📊 **לוח בקרה** (`m-products`) · 🚚 **הזמנות** (`m-orders`) · 👥 **לקוחות** (`m-customers`) · 🛠️ **ניהול** (`m-manage`).

---

## M0 · תשתית-נתונים (data + helpers) — ⏱️ ~1 יום
🎯 **יעד:** הנתונים והחישובים של 4 הטאבים קיימים ובדוקים.
- M0.1 — seeds verbatim: `ORDER_FLOW`(6, `@16943`)+`ORDER_STAGE`(`@12041-12048`) · `SYS_ORDERS`-sim · `CONTRACTOR_CREDIT`(`@16537`) · metric-sources.
- M0.2 — helpers: נגזרות-מטריקה (`mdMetric` `@12160`) · `contractorCredit`(hash 30k-120k) · `mgrCustomerList`(group-by-who) · order-advance (טהור).
- M0.3 — providers (Riverpod, `bs.*.v1`): managerTab(int) · orders · customers.
✅ **DoD:** `manager_seed_test` + helper-tests ירוקים · `analyze`=0.

## M1 · שלד-המסך + טאבים + כניסה — ⏱️ ~0.5 יום
🎯 **יעד:** `ManagerDashboardScreen` נפתח מ-role-picker, עם 4 טאבים מתחלפים (ריקים-עדיין).
- M1.1 — `ManagerDashboardScreen` (Scaffold+AppBar) + segmented-toggle ל-4 טאבים + `IndexedStack` (העתק `updates_screen`).
- M1.2 — `managerTabProvider` (StateProvider<int>).
- M1.3 — חיווט-כניסה: `role_picker` מנהל → `Navigator.push(ManagerDashboardScreen)` (במקום OpenDial.bs).
✅ **DoD:** מנהל ב-role-picker → המסך נפתח · 4 הטאבים מתחלפים.

## M2 · 📊 טאב "לוח בקרה" — ⏱️ ~1 יום
🎯 **יעד:** 5 metric-tiles + pipeline-הזמנות, נתונים-אמת.
- 5 אריחים (`mdMetric`, verbatim `@12160-12164`): 🚚 הזמנות-פתוחות · 📦 מוצרים-בקטלוג(`kCatalogProducts.length`) · 🧰 אביזרים · ✅ זמינים · 🏪 חנויות-פעילות.
- order-pipeline (ספירה לכל שלב) + (אופ׳) hero-הכנסות.
- מקור: `renderMgrDashboard` `@12133`.
✅ **DoD:** 5 אריחים מציגים מספרים נגזרים-אמיתית.

## M3 · 🚚 טאב "הזמנות" — ⏱️ ~1 יום
🎯 **יעד:** רשימת-הזמנות לפי-שלב + קידום (god-mode).
- רשימה מסוננת לפי 6 השלבים (התקבלה/בהכנה/מוכן/נאסף/בדרך/נמסר) · `mgrAdvanceOrder`(`@17022`) inline · `mgrOrderDetail` (מעקב) → bottom-sheet.
- מקור: `renderMgrOrders` `@16939-17075`. sync cross-role = sim (אין backend).
✅ **DoD:** הזמנות מוצגות לפי-שלב · קידום עובד.

## M4 · 👥 טאב "לקוחות" — ⏱️ ~0.5 יום
🎯 **יעד:** רשימת-לקוחות + מצב-אשראי.
- `mgrCustomerList` (פעיל / אשראי-גבוה ≥90%) · כרטיס-לקוח (מסגרת/נוצל/יתרה/אתרים+הזמנות) → bottom-sheet (`mgrCustomerDetail`).
- מקור: `@16533-16644`.
✅ **DoD:** לקוחות-אמת מ-SYS_ORDERS, עם בר-אשראי.

## M5 · 🛠️ טאב "ניהול" — ⏱️ ~1 יום
🎯 **יעד:** 5 כלי-ניהול (חלקם מחוברים לדאטה-קיימת).
- 🌳 עץ-המוצרים (`catalog_tree`) · 🏷️ מותגים-ומחירים (`brands.dart` 8) · 🗂️ קטגוריות · ⚙️ הגדרות-אפליקציה (אקספרס-fee inline, `@16653`) · 🔬 בדיקות-רגרסיה (→ `RegressionPanelScreen` הקיים).
- מקור: `renderMgrManage` `@16645-16890`.
✅ **DoD:** 5 הכלים מציגים/מפעילים תוכן-אמת.

---

## Definition-of-Done (לכל משימה)
1. ✅ מסך/טאב מציג content-אמת · 2. ✅ verbatim מ-`index.html` · 3. ✅ קלט inline, בנוי בדפוסי-האפליקציה (Scaffold/segmented/BsTokens/Riverpod/RTL) · 4. ✅ `analyze`=0 + `test` ירוק + test/helper · 5. ✅ עובר שערי-`.githooks/pre-commit` · 6. ✅ push רק על "תדחוף"/"push".

## אומדן
| משימה | תוכן | אומדן |
|---|---|---|
| M0 | תשתית | 1 יום |
| M1 | שלד-מסך + טאבים + כניסה | 0.5 |
| M2 | לוח בקרה (5 מטריקות) | 1 |
| M3 | הזמנות (6 שלבים) | 1 |
| M4 | לקוחות (אשראי) | 0.5 |
| M5 | ניהול (5 כלים) | 1 |
| | **סה"כ** | **~5 ימים** |

## ⚠️ עיגון (אל תמציא)
- `SYS_ORDERS`/god-mode = סימולציה ללא-backend — לא REST/API.
- `contractorCredit` = hash-דטרמיניסטי (לא נתון-אמת) — verbatim מהנוסחה.
- `SYSTEM_MANAGER.md` (7-sections/מספרים) = **מומצא** — רק `index.html`.
- **כל פרסונה אחרת** (חנות/שליח/עובד) = מסך-משלה באותו דפוס (תוכנית נפרדת בעתיד).
