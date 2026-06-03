# תוכנית-עבודה — בניית "לוח מנהל-המערכת" (כל המשימות, לפי סדר ויעד)

> **מטרה:** למלא את תוכן פרסונת **👔 מנהל-המערכת** ב-BS-dial — **בלי כפתורים חדשים** (העלים כבר קיימים).
> **אפליקציה:** `app_flutter/` (Flutter, v5.96). פרסונת `manager` ב-BS-dial → `kManagerSections` (`lib/data/sections.dart`).
> **ביצוע:** ענף `claude/whats-happening-LyY9G` · דרך השערים · push רק על מילה מפורשת.
> **מקור-אמת:** `index.html` בשורות המעוגנות ב-`sections.dart:147-151` + `port/proto/06-personas-engine-selftest.md`. ⚠️ **אל תשתמש ב-`SYSTEM_MANAGER.md`** — תועד כמכיל מספרים/סעיפים/REST-API **מומצאים**. רק `index.html` קובע (אין-המצאה).
> **כללים:** מחרוזות+מספרים **verbatim** מהמקור · קלט inline · server→toast-stub · להתאים לסגנון-הבנייה הקיים של האפליקציה.

## איך לעבוד
לפי הסדר, משימה-אחר-משימה. כל משימה = 🎯 יעד + צעדים + מקור + ✅ DoD. אל תתחיל לפני שהקודמת עברה DoD.
> 🔴 **חובה — הקוד זז (סוכנים מקבילים):** אל תסמוך על מספרי-שורות. אתֵר ב-grep (`grep -rn "בבנייה" lib/screens/bs_dial_widget.dart`, `kManagerSections`). לפני התחלה: `git fetch origin claude/whats-happening-LyY9G && git log -1`.

## המבנה הקיים (v5.96, אומת — `kManagerSections`)
| סעיף | עלים | מקור index.html |
|---|---|---|
| 📊 לוח בקרה (`m-products`) | 5: הזמנות-פתוחות·מוצרים-בקטלוג·אביזרים·זמינים·חנויות-פעילות | `:12160-12164` (mdMetric tiles) |
| 🚚 הזמנות (`m-orders`) | 6: התקבלה·בהכנה·מוכן·נאסף·בדרך·נמסר | ORDER_FLOW `@16943` · stage-labels `@12041-12048` |
| 👥 לקוחות (`m-customers`) | 2: פעיל·אשראי-גבוה | mc-pill `:16608/:16617` |
| 🛠️ ניהול (`m-manage`) | 5: עץ-מוצרים·מותגים·קטגוריות·הגדרות·רגרסיה | renderMgrManage `:16653-16745` |

---

## M0 · תשתית-מנהל (data + derivations) — ⏱️ ~1 יום
🎯 **יעד:** הנתונים והחישובים של 4 הסעיפים קיימים ובדוקים.
- M0.1 — `ORDER_FLOW` (6 שלבים, `@16943`) + `ORDER_STAGE` labels (`@12041-12048`) + הזמנות-דמו (`SYS_ORDERS` sim) verbatim.
- M0.2 — נגזרות-לוח-בקרה (`mdMetric`): ספירות אמיתיות מ-`kCatalogProducts`/orders/stores (`@12160-12164`).
- M0.3 — `contractorCredit` (hash דטרמיניסטי 30k–120k) + `mgrCustomerList` (group-by-`who` מ-SYS_ORDERS) — sim (`@16608`).
✅ **DoD:** `manager_seed_test` ירוק · `analyze`=0 · test לכל helper (gate-42).

---

## M1 · 📊 לוח בקרה — 5 עלי-מטריקה — ⏱️ ~0.5 יום
🎯 **יעד:** כל אריח מציג מספר-אמת (לא "בבנייה").
- M1.1 — `md-open-orders` 🚚 הזמנות-פתוחות → count(orders לא-נמסר).
- M1.2 — `md-catalog` 📦 מוצרים-בקטלוג → `kCatalogProducts.length`.
- M1.3 — `md-accessories` 🧰 אביזרים נלווים → count(accessories).
- M1.4 — `md-available` ✅ זמינים-כעת → count(in-stock).
- M1.5 — `md-stores` 🏪 חנויות-פעילות → count(stores).
- מקור: `index.html:12160-12164` (verbatim labels).
✅ **DoD:** 5 האריחים מציגים מספרים נגזרים-אמיתית.

## M2 · 🚚 הזמנות — 6 עלי-שלב — ⏱️ ~1.5 יום
🎯 **יעד:** כל שלב מציג את ההזמנות בו + מעבר-שלב (god-mode).
- M2.1 — לכל שלב (התקבלה/בהכנה/מוכן/נאסף/בדרך/נמסר) → רשימת ההזמנות (`SYS_ORDERS` filter by stage).
- M2.2 — `mgrAdvanceOrder` (god-mode, `@17022`) → קידום-שלב **inline** (לא prompt).
- M2.3 — sync cross-role (localStorage) → השאר sim/honest-stub (אין backend).
- מקור: ORDER_FLOW `@16943` · `@12041-12048` · proto/06 §1.
✅ **DoD:** 6 השלבים מציגים הזמנות · קידום עובד.

## M3 · 👥 לקוחות — 2 עלים — ⏱️ ~0.5 יום
🎯 **יעד:** רשימת-לקוחות עם מצב-אשראי.
- M3.1 — `mc-live` 🟢 פעיל → לקוחות פעילים (`mgrCustomerList`).
- M3.2 — `mc-low` ⚠️ אשראי-גבוה → לקוחות ≥90% ניצול (`contractorCredit`).
- כל לקוח: מסגרת/נוצל/יתרה/אתרים + הזמנות (כעלה/sheet, סגנון-האפליקציה).
- מקור: `@16608/:16617` (mc-pill verbatim).
✅ **DoD:** 2 העלים מציגים לקוחות-אמת מ-SYS_ORDERS.

## M4 · 🛠️ ניהול — 5 עלים — ⏱️ ~1.5 יום
🎯 **יעד:** כלי-הניהול חיים (חלקם מחוברים לדאטה-אמיתית קיימת).
- M4.1 — `mm-trees` 🌳 עץ-המוצרים → תצוגת `catalog_tree` (read-only dial).
- M4.2 — `mm-brands` 🏷️ מותגים-ומחירים → `brands.dart`(8) + מחירים.
- M4.3 — `mm-cats` 🗂️ קטגוריות → קטגוריות-קטלוג.
- M4.4 — `mm-settings` ⚙️ הגדרות-אפליקציה → "פרמטרים שהקבלן רואה" (אקספרס-fee וכו', `@16653+`) — **inline**.
- M4.5 — `mm-regression` 🔬 בדיקות-רגרסיה → חיבור ל-`test_harness` הקיים (155 קבצים) — להריץ/להציג.
- מקור: renderMgrManage `:16653-16745`.
✅ **DoD:** 5 העלים מציגים/מפעילים תוכן-אמת.

---

## Definition-of-Done (לכל משימה)
1. ✅ העלה מציג content (לא toast 'בבנייה') · 2. ✅ verbatim מ-`index.html` · 3. ✅ קלט inline · 4. ✅ `analyze`=0 + `test` ירוק + test/helper · 5. ✅ עובר שערי-`.githooks/pre-commit` · 6. ✅ push רק על "תדחוף"/"push".

## אומדן
| משימה | תוכן | אומדן |
|---|---|---|
| M0 | תשתית | 1 יום |
| M1 | לוח בקרה (5) | 0.5 |
| M2 | הזמנות (6) | 1.5 |
| M3 | לקוחות (2) | 0.5 |
| M4 | ניהול (5) | 1.5 |
| | **סה"כ מנהל-מערכת** | **~5 ימים** |

## ⚠️ הערות-עיגון (אין-המצאה)
- **god-mode/SYS_ORDERS** = סימולציה ללא-backend (proto/06 §1) — לא להמציא REST/API.
- מספרי-לקוחות (`contractorCredit`) = hash-דטרמיניסטי, לא נתון-אמת — verbatim מהנוסחה.
- `SYSTEM_MANAGER.md` (7-manage-sections/מספרים) = **מומצא, לא מקור.** רק `index.html` קובע.
