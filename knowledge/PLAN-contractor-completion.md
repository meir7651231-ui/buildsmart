# תוכנית-עבודה — סיום "לוח קבלן" (כל המשימות, לפי סדר ויעד)

> **מטרה:** להכניס את כל תוכן-הקבלן (מהאב-טיפוס) לאפליקציית-ה-Flutter הקיימת — **בלי כפתורים חדשים**.
> **אפליקציה:** `app_flutter/` (Flutter · סגנון-וואטסאפ · 4 טאבים **v5.96**: **בית · מחלקות · עדכונים · חנות**). ⚠️ "עדכונים" (`UpdatesScreen`) = התראות+שיחות **מוזגו** ל-sub-tabs [🔔 התראות · 💬 שיחות]. ⋮ של בית+מחלקות = `_CatalogMenuButton`.
> **ביצוע:** ענף `claude/whats-happening-LyY9G` · דרך השערים (`.githooks/pre-commit`) · push רק על מילה מפורשת.
> **מקור-אמת:** `app_flutter/knowledge/port/proto/04-contractor-projects-tasks.md` (`§` = סעיף) + proto §1–§9.
> **כללים (כל משימה):** מחרוזות+מספרים **verbatim** מהמקור · קלט inline · server/print/camera/OCR→toast-stub · להתאים לסגנון-הבנייה הקיים של האפליקציה.

## איך לעבוד
עבוד **לפי הסדר**, משימה-אחר-משימה, מלמעלה למטה. כל משימה = 🎯 יעד + צעדים מפורקים + מקור + ✅ DoD. אל תתחיל משימה לפני שהקודמת עברה DoD. **שלב א׳ (כפתורים קיימים) קודם — זו העדיפות. שלב ב׳ רק אחריו.**
> 🔴 **חובה — הקוד זז (נכון ל-v5.96, סוכנים מקבילים דוחפים):** **אל תסמוך על מספרי-שורות.** לכל משימה — **אתֵר ב-grep** את ה-stub האמיתי (למשל `grep -rn "חלופות זולות — בבנייה" lib/`) ועבוד מול מה שאתה מוצא *עכשיו*. תאר את הטאב לפי **שם**, לא מיקום. לפני התחלה: `git fetch origin claude/whats-happening-LyY9G && git log -1` — ודא שאתה על ה-tip.

---

# שלב א׳ — כפתורים קיימים-ונגישים (העדיפות העליונה)
*כל אלה נגישים-עכשיו במסך ומציגים "בבנייה"/toast. רק ממלאים תוכן.*

## T0 · תשתית-מינימלית (data + helpers) — ⏱️ ~1 יום
🎯 **יעד:** הנתונים והחישובים שהכפתורים צריכים קיימים ובדוקים.
- 0.1 — data-seeds verbatim → `const` (לכפתורי שלב-א׳): `PLAN_TYPES`(4+zones+stores §9) · `STORE services`/`ORDER_STATUS`(§3,§9d) · `SAFETY_TIPS`(5 §5) · budget-thresholds(§3) · `DEPT categories`(§1).
- 0.2 — `StateNotifier`-ים ל-mutable (mute-state · orders · favorites).
- 0.3 — helpers: `fMoney`/`caToday` + `cheaperAlternativeBrand` (כבר קיים — לוודא) + `bestStore` (min-price).
✅ **DoD:** `seeds_test` ירוק · `flutter analyze`=0 · test לכל helper (gate-42).

## T1 · קטלוג ⋮ → "חלופות זולות" — ⏱️ ~1ש׳
🎯 **יעד:** לחיצה מציגה חלופה-זולה אמיתית (לא "בבנייה").
- צעדים: אתֵר `grep -rn "חלופות זולות — בבנייה" lib/` (⋮ של בית/מחלקות = `_CatalogMenuButton`) → החלף ה-`showToast` בקריאה ל-`cheaperAlternativeBrand` → הצג שם+מחיר+חיסכון.
- מקור: helper קיים (`related_info.dart`).
✅ **DoD:** מציג חלופה · בדיקה ל-3 מוצרים.

## T2 · קטלוג ⋮ → "השוואת מחירים" — ⏱️ ~2ש׳
🎯 **יעד:** השוואת-מחיר בין חנויות למוצר.
- צעדים: אתֵר `grep -rn "השוואת מחירים — בבנייה" lib/` → החלף ה-toast → רשימת-חנויות+מחירים, הזול מסומן (`bestStore`).
- מקור: §9 (store-prices).
✅ **DoD:** מציג ≥3 חנויות, הזול מודגש.

## T3 · קטלוג ⋮ → "סרוק תוכנית" — ⏱️ ~4ש׳
🎯 **יעד:** סריקה מלאה (4 סוגים) → רשימת-חומרים + הוספה-לסל.
- צעדים: אתֵר `grep -rn "_ScanPlanSheet" lib/` — 4 ה-`${p.label} — בבנייה` → `PLAN_TYPES`: zones · items · השוואת-חנויות · `addScanToCart`. canvas=ויזואל-סטטי.
- מקור: §9 (PLAN_TYPES verbatim).
✅ **DoD:** 4 הסוגים פעילים · "הוסף לסל" עובד.

## T4 · טאב חנות → services — ⏱️ ~3ש׳
🎯 **יעד:** 6 השירותים פותחים flow אמיתי (לא רק preview).
- צעדים: השכרת-כלים · פקדונות · החזרה(RMA) · מכרז-ספקים(RFQ) · MSDS · השוואה. כל אחד → sheet/inline (לא prompt). חסר-flow→honest-stub.
- מקור: §3 (commerce-b2b).
✅ **DoD:** כל שירות פותח תוכן/flow.

## T5 · טאב חנות → orders — ⏱️ ~2ש׳
🎯 **יעד:** מעקב-הזמנה אמיתי + תעודת-משלוח.
- צעדים: `ORDER_STATUS` (pending/processing/shipped/delivered) · doc-OCR → **toast-stub** (§9d).
- מקור: §9d.
✅ **DoD:** סטטוס מוצג · OCR=toast.

## T6 · טאב **עדכונים** → sub-tab 🔔 התראות → budget + safety — ⏱️ ~1.5ש׳
🎯 **יעד:** התראות-תקציב והתראות-בטיחות אמיתיות.
- צעדים: בטאב "עדכונים" (`UpdatesScreen`) → sub-tab 🔔 התראות (`notifications_screen`). budget → thresholds 80/90/100% (§3) · safety → `SAFETY_TIPS`×5 + ack→push (§5).
- מקור: §3, §5.
✅ **DoD:** 2 הקטגוריות מציגות תוכן-אמת.

## T7 · ⋮ actions בטאב עדכונים (השתק/סמן/נקה) — ⏱️ ~1ש׳
🎯 **יעד:** הפעולות עושות משהו אמיתי, לא toast.
- צעדים: (שניהם תחת טאב "עדכונים") ⋮ sub-שיחות "השתק הכל" → mute-state · ⋮ sub-התראות "סמן-הכל"/"נקה" → פעולה על ה-state. אתֵר ב-grep: `mute_all` / `mark_all_read` / `clear_all`.
✅ **DoD:** הפעולה משנה state + נשמרת.

## T8 · טאב מחלקות → 5 "בקרוב" — ⏱️ ~0.5ש׳
🎯 **יעד:** המחלקות המושבתות פתוחות לקטלוג מסונן (או honest-stub).
- צעדים: חשמל/בנייה/גמר/בטיחות — `dept.live=true` + סינון, או השאר honest-stub אם אין data.
- מקור: §1.
✅ **DoD:** לחיצה פותחת תוכן (לא 'בקרוב' ריק).

## T9 · BS-dial → עלי 5 הפרסונות — ⏱️ ~1 יום
🎯 **יעד:** עלי הפרסונות (מנהל/חנות/שליח/עובד) מציגים תוכן (כעלים/sheets).
- צעדים: אתֵר `grep -rn "בבנייה" lib/screens/bs_dial_widget.dart` → החלף → תוכן-פרסונה כעלים.
- מקור: persona-dashboards (port/preact/03).
✅ **DoD:** עלי-פרסונה מציגים content.

> **🏁 סוף שלב א׳ — הקבלן רואה תוכן-אמת בכל הכפתורים הנגישים.**

---

# שלב ב׳ — מאוחר (תפריט-חבוי + פיצ'רים-חסרים) · *רק אחרי שלב א׳*
*דורש קודם טריגר; לא נגיש היום. סקופ-נפרד.*

## T10 · טריגר לתפריט-החבוי — ⏱️ ~2ש׳
🎯 **יעד:** התפריט (4 טאבים, 41 עלים) נפתח.
- צעדים: הצב `OpenDial.menu` ממחווה/פקד (`home_shell`). אז 41 העלים נגישים.
✅ **DoD:** התפריט נפתח.

## T11 · מרכז-פיננסים (10 עלים) — ⏱️ ~1.5 יום
🎯 **יעד:** 10 פיצ'רי-פיננסים חיים. מקור §4. (מדד+6.10%/תשלום/subs/אישורים-RBAC/חריגה/ROI×1.42/פיצול/קנסות-inline/דוחות-toast/מט״ח). ✅ math תואם.

## T12 · ניהול-אתר (10 עלים) — ⏱️ ~1.5 יום
🎯 **יעד:** 10 כלי-אתר חיים. מקור §5. (גאנט-RTL/ליקויים-inline/מיקום/נוכחות/יומן-inline/בטיחות/תלויות/צילום-toast/ביקורת-inline/ארכיון). ✅ CRUD עובד.

## T13 · מלאי (2 עלים) — ⏱️ ~0.25 יום
🎯 **יעד:** מחסן/אתר + move. מקור §8 (STOCK_DEMO 11). ✅ move עובד.

## T14 · סריקה-תפריט (4 עלים) — ⏱️ ~0.5 יום
🎯 **יעד:** 4 סוגי-סריקה (משתף לוגיקה עם T3). מקור §9.

## T15 · AI (9 עלים) — ⏱️ ~0.5 יום
🎯 **יעד:** ברקוד/דיבור אמיתיים · השאר honest-stub. מקור AI-hub.

## T16 · פרויקטים (3 עלים) — ⏱️ ~0.5 יום
🎯 **יעד:** רשימה/switch(cart per-project)/סטטוס. מקור §2.

## T17 · מערכת-משימות — ⏱️ ~1 יום
🎯 **יעד:** 5 משימות + מכונת-סטטוס(5) + מנהל/עובד + auto-advance + WORK_LOG. מקור §6.

## T18 · פרויקט-חכם — ⏱️ ~1 יום
🎯 **יעד:** 9 day-stages + day-picker + steps. מקור §7.

## T19 · תקציב-בסיסי — ⏱️ ~0.5 יום
🎯 **יעד:** box/detail/editor + 4 קטגוריות (pct=66%). מקור §3.

## T20 · תוכן-בית — ⏱️ ~0.5 יום
🎯 **יעד:** reorder + product-cards. מקור §1.

## T21 · ליטוש — ⏱️ ~0.5 יום
🎯 **יעד:** RTL · a11y · global-error-handler · regression מלא.

> **🏁 סוף שלב ב׳ — parity-קבלן מלא.**

---

## Definition-of-Done גלובלי (לכל משימה)
1. ✅ הכפתור מציג content (לא toast 'בבנייה') · 2. ✅ verbatim מהמקור · 3. ✅ קלט inline · 4. ✅ `analyze`=0 + `test` ירוק + test/helper · 5. ✅ עובר שערי-`.githooks/pre-commit` · 6. ✅ push רק על "תדחוף"/"push".

## אומדן
שלב א׳ (כפתורים קיימים) ≈ **3.5 ימים** · שלב ב׳ ≈ **8 ימים** · סה"כ ≈ **11–12 ימי-עבודה**.
*נפרד (P0 השקה, לא-קוד): iOS/Android signing + usage-strings + Huliot-R2 — ~1–2 ימים + חשבונות-חנות.*

## 🔒 תפיסות (claims log)
- 2026-06-03 · **מקבץ** · `claude/whats-happening-LyY9G` · לקח **T0 + T1** (תשתית-מינימלית + קטלוג-⋮ "חלופות זולות"). בעבודה — מיישם על whats-happening לפי הסדר (T0 DoD → T1).

- 2026-06-03 · **בנצי (משיק)** · `claude/whats-happening-LyY9G` · לקח **P0 השקה** (usage-strings iOS + scaffolding לחתימת-Android release) — source-prep, לא תלוי ב-T0. push קוד רק על "תדחוף".

- 2026-06-03 · **מקבץ-קבלן (סשן בנצי-features)** · `claude/whats-happening-LyY9G` · לקח **T9** (BS-dial — תוכן ל-leaves של הפרסונות: מנהל/חנות/שליח/עובד; קבלן deferred). מקור: `app_flutter/knowledge/port/preact/03-persona-dashboards.md`. **בלתי-תלוי ב-T0/T1.** push קוד רק על "תדחוף". בעבודה.
  - הערות-שטח (נכון ל-v5.97, אחרי 6 דרישות בנצי): **T7 כבר בוצע** — mute/mark/clear כבר קוראים ל-state אמיתי (`home_shell._onSelected`: `toggleMuteAllChats`/`markAllNotifsRead`/`dismissAllNotifs`), לא toast-stub. **T2 חסום (אין-data, אין-המצאה)** — אין dataset של מחירי-חנויות ב-`lib/data/` ו-`bestStore` לא קיים; ה-"4 ספקים עדכנו מחירים" הוא טקסט-התראה. **T8 = "בקרוב תשאיר"** לפי החלטת-משתמש (5 המחלקות בעלות 0 מוצרים — honest-stub כבר ממומש).

- 2026-06-03 · **בנצי (משיק)** · `claude/whats-happening-LyY9G` · לקח **T6** (טאב עדכונים → התראות תקציב + בטיחות). סקופ: ה-action-button בהתראות (`notifications_screen` ~1026) = toast "בבנייה" → מחליף ב-תוכן inline: safety→SAFETY_TIPS×5+ack (§5) · budget→ספי 80/90/100% (§3). בחירה: T2 חסום (אין-data) · T3/T4/T5 תלויים-T0 (WIP מקבץ) · Phase-B נעול-T10. T6 = התנגשות-מינימלית (notifications_screen). **תיאום:** התוכן יוגדר מקומית ב-notifications (לא ב-contractor_seeds של T0) — מקבץ, אין צורך ב-SAFETY_TIPS/thresholds ב-T0. push קוד רק על "תדחוף".
- 2026-06-04 · **מקבץ** · **T0 (ליבה: seeds+helpers+test) ✅ נדחף** ל-whats-happening (`contractor seeds foundation` · 8 בדיקות · fMoney/bestStore mutation-verified). דחוי: T0.2 StateNotifiers (→T7/T5) · ORDER_STATUS/STORE seeds (proto-gap →T4/T5). **T1 הבא.**
