# תוכנית-עבודה — סיום "לוח קבלן" (כל המשימות, לפי סדר ויעד)

> 🧭 **לפיצול-סוכנים: קרא `00-START-HERE.md` ראשון.** המספור כאן (T0–T22) = **מאסטר/היסטוריה** (T0–T9 בוצעו); ל"מה-לבנות-עכשיו" → `TASKS-to-full.md` (Track Tn).
> **מטרה: מלא מלא — front-end של מוצר אמיתי, שלם.** כל תוכן-הקבלן באפליקציה (parity-מלא לפרוטוטייפ), **בלי כפתורים חדשים**, כל פיצ'ר **עובד**. **אין toast-stub** — כל פיצ'ר ממומש במלואו מול **נתוני-ביניים מקומיים** (פיגום זמני, **server-ready**) שיוחלפו בשרת-האמיתי בסוף (drop-in ברמת-provider). **שום דבר לא "מזויף-לתצוגה" — הכל קוד-מוצר אמיתי.**
> **אפליקציה:** `app_flutter/` (Flutter · סגנון-וואטסאפ · 4 טאבים **v5.96**: **בית · מחלקות · עדכונים · חנות**). ⚠️ "עדכונים" (`UpdatesScreen`) = התראות+שיחות **מוזגו** ל-sub-tabs [🔔 התראות · 💬 שיחות]. ⋮ של בית+מחלקות = `_CatalogMenuButton`.
> **ביצוע:** ענף `claude/whats-happening-LyY9G` · דרך השערים (`.githooks/pre-commit`) · push רק על מילה מפורשת.
> **מקור-אמת:** `app_flutter/knowledge/port/proto/04-contractor-projects-tasks.md` (`§` = סעיף) + proto §1–§9.
> **כללים (כל משימה):** מחרוזות+מספרים **verbatim** מהמקור · קלט inline · server/print/camera/OCR → **מעתיקים את התנהגות-הדמו של הפרוטוטייפ** (תוצאה-מדומה/sim, **לא** toast) · להתאים לסגנון-הבנייה הקיים של האפליקציה.

## 📊 סטטוס (אומת-קוד 2026-06-08 · tip `1d292aa`)
**שלב-א ✅ הושלם** (T0–T9; T8 stub-מכוון) — אומת-קוד: כל הכפתורים + 3 פרסונות (עובד/חנות/שליח, 0 חורים-נסתרים).
→ **איחוד הושלם** (v6.12 cutover): מנהל (2,682ש') + מנוע-הזמנות-משותף + קטלוג על הטרנק · מנהל נגיש מ-role_picker. **הקשחה:** 6 סבבי-audit v6.13–v6.16 (`WIRING_AUDIT.md`) + 2 באגי-HIGH נסגרו (H2 persistence משימות-עובד · H3 פיוס-total) · **1,539 טסטים ירוקים** · קטלוג 100% (gate 117).
→ **שלב-ב (T10–T22) ✅ נבנה ומחווט נייטיב** (`ac3073d` + דיאל-הפצה `b9737cf`; הדיאל הוסר, T10 מבוטל). נותר: אימות-עומק + ליטוש + server-ready. **📋 קצוות-הסגירה: `PLAN-closeout.md` · מפת-הגישה: `00-START-HERE` §4.6.**

## איך לעבוד
עבוד **לפי הסדר**, משימה-אחר-משימה, מלמעלה למטה. כל משימה = 🎯 יעד + צעדים מפורקים + מקור + ✅ DoD. אל תתחיל משימה לפני שהקודמת עברה DoD. **שלב א׳ (כפתורים קיימים) קודם — זו העדיפות. שלב ב׳ רק אחריו.**
> 🔴 **חובה — הקוד זז (נכון ל-v5.96, סוכנים מקבילים דוחפים):** **אל תסמוך על מספרי-שורות.** לכל משימה — **אתֵר ב-grep** את ה-stub האמיתי (למשל `grep -rn "חלופות זולות — בבנייה" lib/`) ועבוד מול מה שאתה מוצא *עכשיו*. תאר את הטאב לפי **שם**, לא מיקום. לפני התחלה: `git fetch origin claude/whats-happening-LyY9G && git log -1` — ודא שאתה על ה-tip.

---

## 🎨 סגנון-הבנייה (חובה — אומת מהקוד v5.96; התאם בדיוק, אל תנחש)
1. **State:** Riverpod (`ConsumerWidget`/`ConsumerStatefulWidget`, לא setState).
2. **ניווט:** אין go_router. **מסך-יעד** = `Navigator.push` + `Scaffold`+`AppBar` (דגם: `store_screen`/`updates_screen`/`install_studio_screen`). **תוכן-נקודתי** = `showModalBottomSheet`+`DraggableScrollableSheet`+`Directionality(rtl)`+`_SheetClose` (דגם: `_BomSheet`/`_SmartProductSheet`).
3. **טאבים-במסך:** `StateProvider<int>` + segmented-toggle + `IndexedStack` (דגם `updates_screen`) · או chips (`store_screen._SectionChipsRow`).
4. **עלה ב-dial:** `DialRow` (`widgets/dial.dart`) — circle+label-pill נפרדים.
5. **אבני-בניין:** widgets פרטיים `_Xxx` (`_SheetSection`/`_SectionHeader`/`_…Row`/`_ChipWrap`).
6. **Tokens:** `BsTokens` בלבד (space 4-32 · radiusCard 16 · radiusPill 999 · כתום #FF7A18 · Heebo). אסור מספרי-קסם/צבע-קשיח.
7. **Toast:** `showToast(context, msg)`. **RTL · Material-3 · light.**
8. **🔌 server-ready (חובה — זה מוצר אמיתי, לא תצוגה):** כל נתון עובר דרך **provider/repository** (לעולם לא מקודד בתוך מסך/widget) · **צורת-נתונים אחידה** (אותם שדות עכשiv ובשרת) · הנתונים המקומיים = **פיגום זמני** שיוחלף בשרת. **מטרה: חיבור-השרת בסוף = drop-in ברמת-ה-provider, בלי לגעת ב-UI.** (לכל domain: `XxxRepository` עם מימוש-מקומי היום → מימוש-שרת בעתיד, מאחורי אותו interface.)

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
- צעדים: אתֵר `grep -rn "השוואת מחירים — בבנייה" lib/` → החלף ה-toast → רשימת-חנויות+מחירים, הזול מסומן. **מקור-מחירים (פותר brandPrice=0):** `price_estimate.dart` (אומדן-קטגוריה, קיים) + וריאנט-חנויות-דמו (±%, כמו store-prices ב-PLAN_TYPES של הפרוטוטייפ).
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
- צעדים: `ORDER_STATUS` (pending/processing/shipped/delivered) · doc-OCR → **תוצאת-OCR מדומה** (כמו §9d: מס'-תעודה/תאריך/ספק/פריטים).
- מקור: §9d.
✅ **DoD:** סטטוס מוצג · OCR מציג תוצאה-מדומה (לא toast).

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

## T9 · פרסונות → **מסכים-מלאים** (חנות / שליח / עובד) — ⏱️ ~3 ימים
🎯 **יעד:** כל פרסונה = **מסך-מלא חדש, בנוי בדיוק כמו האפליקציה** (תבנית `ManagerDashboardScreen`) — **לא** עלי-dial.
- דפוס (לכל פרסונה): `XxxDashboardScreen` (Scaffold+AppBar) + טאבים (segmented כמו `updates_screen`) + `role_picker` → `Navigator.push` (במקום `OpenDial.bs`). תוכן ב-BsTokens/Riverpod/RTL.
  - 🏪 **חנות** — 4 טאבים (בית/הזמנות/מלאי/פורטל), `kStoreSections` + picking 6-states + state-machine. מקור: `index.html` screen-store + proto/06 §2.
  - 🛵 **שליח** — 4 (הרכב/pickup/active/פורטל), `kCourierSections`. מקור: screen-courier + proto/06 §3.
  - 🦺 **עובד** — 3 (status-groups), `kWorkerSections`. מקור: screen-worker + proto/06 §4.
- ⚠️ **מנהל = מדולג** (עדיפות-נמוכה — תוכנית-נפרדת `PLAN-manager-completion.md`; "שלי", לא קריטי).
✅ **DoD:** 3 הפרסונות נפתחות כמסכים-מלאים עם תוכן-אמת.

> **🏁 סוף שלב א׳ — הקבלן רואה תוכן-אמת בכל הכפתורים הנגישים.**

---

# שלב ב׳ — ✅ **נבנה** (היסטורי) · *הדיאל הוסר 07-06 → גישה-נייטיב; ר׳ `00-START-HERE` §4.6*
*דורש קודם טריגר; לא נגיש היום. סקופ-נפרד.*

## ~~T10 · טריגר לתפריט-החבוי~~ — ❌ **מבוטל (07-06; דיאל הוסר)**
🎯 ~~יעד: התפריט (4 טאבים, 41 עלים) נפתח.~~ — ❌ **בוטל: הדיאל הוסר (07-06); הכלים נגישים נייטיב** (ר׳ `00-START-HERE` §4.6).
✅ **DoD:** התפריט נפתח.

## T11 · מרכז-פיננסים (10 עלים) — ⏱️ ~1.5 יום
🎯 **יעד:** 10 פיצ'רי-פיננסים חיים. מקור §4. (מדד+6.10%/תשלום/subs/אישורים-RBAC/חריגה/ROI×1.42/פיצול/קנסות-inline/דוחות=report-view-מודפס/מט״ח). ✅ math תואם.

## T12 · ניהול-אתר (10 עלים) — ⏱️ ~1.5 יום
🎯 **יעד:** 10 כלי-אתר חיים. מקור §5. (גאנט-RTL/ליקויים-inline/מיקום/נוכחות/יומן-inline/בטיחות/תלויות/צילום-toast/ביקורת-inline/ארכיון). ✅ CRUD עובד.

## T13 · מלאי (2 עלים) — ⏱️ ~0.25 יום
🎯 **יעד:** מחסן/אתר + move. מקור §8 (STOCK_DEMO 11). ✅ move עובד.

## T14 · סריקה-תפריט (4 עלים) — ⏱️ ~0.5 יום
🎯 **יעד:** 4 סוגי-סריקה (משתף לוגיקה עם T3). מקור §9.

## T15 · AI (9 עלים) — ⏱️ ~0.5 יום
🎯 **יעד:** ברקוד/דיבור אמיתיים · השאר = **תצוגת-תוצאת-AI מדומה** (חיזוי/חלופות[`cheaperAlternativeBrand`]/מזג-אוויר/בלאי — כמו בפרוטוטייפ, **לא** toast). מקור AI-hub.

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

## T22 · מרכז-תגמולים / מועדון (Category H) — ⏱️ ~1 יום
🎯 **יעד:** הוב-התגמולים של הקבלן חי (היה נעדר מהאפליקציה — החור היחיד שמצאנו).
- 7 פיצ'רים verbatim (`@21464-21471`): 🎯 אתגרים · 🏆 לוח-מובילים · 🌿 תגי-ירוק · 📍 קופונים · 👥 חבר-מביא-חבר · 💎 VIP · 🎁 מימוש (`awardCoins`/`rwChallenges`/`rwLeaderboard`/`rwCoupons`/`rwReferral`/`rwVIP`/`rwRedeem`).
- נקודת-תליה: עלה/כפתור קיים (פרופיל/menu) → screen/sheet בסגנון-האפליקציה · נתוני-דמו verbatim מהפרוטוטייפ.
- מקור: `index.html` `openRewardsHub` `@21402-21659` (doc 16 §H).
✅ **DoD:** 7 הפיצ'רים מציגים תוכן-דמו (לא נעדר/toast).

## T21 · ליטוש — ⏱️ ~0.5 יום
🎯 **יעד:** RTL · a11y · global-error-handler · regression מלא.

> **🏁 סוף — לוח-קבלן מלא-מלא (parity-מלא לפרוטוטייפ): כל פיצ'ר עובד כ-demo, אפס toast-stub.**

---

## Definition-of-Done גלובלי (לכל משימה)
1. ✅ הכפתור מציג content (לא toast 'בבנייה') · 2. ✅ verbatim מהמקור · 3. ✅ קלט inline · 4. ✅ `analyze`=0 + `test` ירוק + test/helper · 5. ✅ עובר שערי-`.githooks/pre-commit` · 6. ✅ push רק על "תדחוף"/"push".

## אומדן
שלב א׳ (כפתורים T0–T8 ≈ 3.5 + פרסונות-מסכים T9 ≈ 3) ≈ **6.5 ימים** · שלב ב׳ (תפריט+חסרים+מועדון T22) ≈ **9 ימים** · סה"כ ≈ **15–16 ימי-עבודה** (= מלא-מלא, parity-מלא לפרוטוטייפ).
*נפרד (P0 השקה, לא-קוד): iOS/Android signing + usage-strings + Huliot-R2 — ~1–2 ימים + חשבונות-חנות.*

## 🔒 תפיסות (claims log)
- 2026-06-03 · **מקבץ** · `claude/whats-happening-LyY9G` · לקח **T0 + T1** (תשתית-מינימלית + קטלוג-⋮ "חלופות זולות"). בעבודה — מיישם על whats-happening לפי הסדר (T0 DoD → T1).

- 2026-06-03 · **בנצי (משיק)** · `claude/whats-happening-LyY9G` · לקח **P0 השקה** (usage-strings iOS + scaffolding לחתימת-Android release) — source-prep, לא תלוי ב-T0. push קוד רק על "תדחוף".

- 2026-06-03 · **מקבץ-קבלן (סשן בנצי-features)** · `claude/whats-happening-LyY9G` · לקח **T9** (BS-dial — תוכן ל-leaves של הפרסונות: מנהל/חנות/שליח/עובד; קבלן deferred). מקור: `app_flutter/knowledge/port/preact/03-persona-dashboards.md`. **בלתי-תלוי ב-T0/T1.** push קוד רק על "תדחוף". בעבודה.
  - הערות-שטח (נכון ל-v5.97, אחרי 6 דרישות בנצי): **T7 כבר בוצע** — mute/mark/clear כבר קוראים ל-state אמיתי (`home_shell._onSelected`: `toggleMuteAllChats`/`markAllNotifsRead`/`dismissAllNotifs`), לא toast-stub. **T2 חסום (אין-data, אין-המצאה)** — אין dataset של מחירי-חנויות ב-`lib/data/` ו-`bestStore` לא קיים; ה-"4 ספקים עדכנו מחירים" הוא טקסט-התראה. **T8 = "בקרוב תשאיר"** לפי החלטת-משתמש (5 המחלקות בעלות 0 מוצרים — honest-stub כבר ממומש).

- 2026-06-03 · **בנצי (משיק)** · `claude/whats-happening-LyY9G` · לקח **T6** (טאב עדכונים → התראות תקציב + בטיחות). סקופ: ה-action-button בהתראות (`notifications_screen` ~1026) = toast "בבנייה" → מחליף ב-תוכן inline: safety→SAFETY_TIPS×5+ack (§5) · budget→ספי 80/90/100% (§3). בחירה: T2 חסום (אין-data) · T3/T4/T5 תלויים-T0 (WIP מקבץ) · Phase-B נעול-T10. T6 = התנגשות-מינימלית (notifications_screen). **תיאום:** התוכן יוגדר מקומית ב-notifications (לא ב-contractor_seeds של T0) — מקבץ, אין צורך ב-SAFETY_TIPS/thresholds ב-T0. push קוד רק על "תדחוף".
- 2026-06-04 · **מקבץ** · **T0 (ליבה: seeds+helpers+test) ✅ נדחף** ל-whats-happening (`contractor seeds foundation` · 8 בדיקות · fMoney/bestStore mutation-verified). דחוי: T0.2 StateNotifiers (→T7/T5) · ORDER_STATUS/STORE seeds (proto-gap →T4/T5). **T1 הבא.**

- 2026-06-04 · **בנצי (משיק)** · **T6 ✅ הושלם ונדחף** (fb9aff0). התראות בטיחות+תקציב → sheet inline (R9). אומת ויזואלית (רנדור-בדפדפן חי). seeds מ-T0. gates 24/102/116 ✓.

- 2026-06-04 · **בנצי (משיק)** · לקח **T5** (טאב חנות → orders: מעקב-הזמנה + תעודת-משלוח). ORDER_STATUS 4-states (§9d; מקבץ דחה ל-T5) + doc-OCR→toast. התנגשות-מינ׳ (store orders, לא קטלוג). worktree מבודד. push קוד רק על "תדחוף".

- 2026-06-04 · **בנצי (משיק)** · **T5 ✅ הושלם ונדחף** (3ea5a8d). תעודת-משלוח (OCR→toast) ב-_OrderSheet; מעקב-סטטוס כבר היה בנוי. gates 24/116 ✓.

- 2026-06-04 · **מקבץ** · **T1 ✅ הושלם ונדחף** (bb6a751). קטלוג ⋮ "חלופות זולות" → sheet inline (`_CheaperAlternativesSheet`) עם 3 חלופות אמיתיות מ-`kHomeProductBrands` (proto §1b, verbatim): אסלה 740→560 · מקלחת 520→380 · ברז 189→139, ממוין לפי חיסכון. gates 24/42/44/102/103/111/116 ✓ · mutation-verified · רנדר-בדפדפן חי. **T2 הבא** — הבלוקר "T2 חסום (אין-data)" (שורה 162, נכון ל-v5.97) **הוסר ע"י T0**: קיים `StoreOffer` (`kPlanTypes` · 13 zones × 3 חנויות · proto §9b verbatim) + `bestStore`. לוקח **T2** (קטלוג ⋮ "השוואת מחירים" — ≥3 חנויות, הזול מודגש).

- 2026-06-04 · **מקבץ-קבלן** · **T9 — פרסונת עובד ✅ הושלם ונדחף (1 מ-3)** (`c2e3395` על whats-happening, מעל v6.04). פרסונת **עובד** = **אפליקציית-תפקיד מלאה** (`WorkerAppScreen`, שלד `home_shell` — סגנון זהה לאפליקציה, **לא דיאל**) לפי החלטת-משתמש; ניסיון "תוכן-בתוך-דיאל" ראשון נדחה ("סגנון חדש") ובוטל, הדיאל הוחזר ל-"בבנייה" verbatim. תוכן verbatim מ-proto 06 §4.2 (בורר-עובד · סיכום · 3 buckets ככרטיסים). `worker_app_test` 4 · `widget_test` עודכן · mutation-verified · אומת בצילום · gates 24/42/44/102/111/116 ✓. **חנות+שליח הושלמו מאז** ע״י בנצי (`a85467d`, ר׳ שורה 188) → **T9 ✅ מלא (3/3)** — אומת-קוד v6.16, אותו דפוס role-app שהתחלתי ב-`WorkerAppScreen`. (מנהל נבנה בנפרד ב-cutover v6.12 — מחוץ להגדרת-T9 המקורית.)

- 2026-06-04 · **בנצי (משיק)** · **סיכום-השלמות (סשן):** ✅ P0-source-prep · ✅ SEND_TO_GOOGLE · ✅ T6 · ✅ T5 — כולם על origin. ✅ **T5-fix (`e64a6e8`):** `_OrderSheet` עטוף ב-`SingleChildScrollView` + `isScrollControlled` — תיקן `RenderFlex overflow` (3.6px) שהכשיל `store_notif_widget_test` וחסם את `deploy.yml` ל-4 קומיטים → **deploy שוחרר.** ✅ **QA-audit (v6.04 חי):** T4 (6 שירותים + `_ServiceSheet`) + T2 (השוואת-מחירים, תוכן ב-`_kServiceSheets`) **אומתו כבר-בנויים** — אין צורך לקחת. לקח (stuck_log): visual-verify חי, לא רק test; `isScrollControlled`/`SingleChildScrollView` לגיליונות-ארוכים.

- 2026-06-04 · **מקבץ** · **T2 ✅ הושלם ונדחף** (`2937eb8`). קטלוג ⋮ "השוואת מחירים" — היה `showToast('בבנייה')` (`case 'price_compare'`) → **sheet inline** (`_StorePriceComparisonSheet`): לכל מוצר 3 מחירי-חנויות מ-`kPlanTypes` (proto §9b verbatim, T0) + `bestStore` — הזול מסומן בכתום+✓ (אסלה→אבן קיסר 740 · מקלחת→טמבור הום 520; משתנה פר-מוצר). guard `store_price_comparison_test` · gates 24/102/103/111/116 ✓ · רנדר-בדפדפן חי. **הבהרה ל-QA של בנצי (שורה 177):** ה-"כבר-בנוי ב-`_kServiceSheets`" הוא **טאב חנות→שירותים (T4)**; ה-PLAN-T2 הוא **קטלוג ⋮** שהיה toast-stub אמיתי — זה מה שמילאתי (משטחים שונים, אפס כפילות). **שלב-א כמעט גמור:** T0/T1/T2/T5/T6/T7/T9 ✅ · T4 בנוי (QA) · T8 stub-מכוון. **הבא: T3** (קטלוג ⋮ → "סרוק תוכנית") — בכפוף לאישור-המשתמש.

- 2026-06-04 · **מקבץ** · **לוקח T3** (קטלוג ⋮ → "סרוק תוכנית"). אישור-משתמש התקבל. מיישם על whats-happening לפי הסדר: 4 plan-types (`kPlanTypes`, proto §9) · אנימציית-סריקה (steps verbatim) · תוצאות (zones/items/store-offers) · "הוסף לסל". בעבודה — push רק על מילה מפורשת.

- 2026-06-04 · **בנצי (משיק)** · `claude/whats-happening-LyY9G` · לקח את **הנותר ב-T9** = **מסכי-פרסונה מלאים: 🏪 חנות + 🛵 שליח** (פרסונת 🦺 עובד כבר נבנתה ע"י מקבץ ב-`c2e3395`). דפוס: `StoreDashboardScreen`/`CourierDashboardScreen` בסגנון `WorkerAppScreen` (Scaffold+AppBar+טאבים, `Navigator.push` מ-`role_picker`, BsTokens/RTL). חנות=4 טאבים (בית/הזמנות/מלאי/פורטל)+picking 6-states; שליח=4 (רכב/pickup/active/פורטל). מקור: proto/06 §2/§3 + screen-store/courier. **תיאום עם מקבץ:** אני נוגע ב-`role_picker_sheet.dart` + `persona_data.dart` (הוספת `kStoreSections`/`kCourierSections`) + 2 קבצי-מסך חדשים — נא לא להתנגש. worktree מבודד. push קוד רק על "תדחוף".

- 2026-06-04 · **מקבץ** · **T3 ✅ הושלם ונדחף** (`58e46a2`). קטלוג ⋮ "סרוק תוכנית עבודה" — `_ScanPlanSheet` מ-toast-stub ל-**זרימה מלאה** (ConsumerStatefulWidget, ללא route): בורר 4 plan-types (`kPlanTypes`, proto §9) → סריקה (steps verbatim) → תוצאות (zones · ודאות% · השוואת-חנויות per פריט, הזול מסומן) → "אשר הכל — הוסף N פריטים לסל" מוסיף כל פריט במחיר-הזול (`bestStore`) ל-`smartCart`. guard `scan_plan_test` · gates 24/116 ✓ · **אומת חי E2E** (picker→scan→results→6 פריטים בסל). **שלב-א גמור** (T0–T9 ✅; T8 stub-מכוון). שלב-ב (T10–T22) ממתין לאישור.

- 2026-06-04 · **בנצי (משיק)** · **T9 (חנות + שליח) ✅ הושלם ונדחף** (`a85467d` על whats-happening). הנותר ב-T9 (עובד כבר נבנה): מסכי-פרסונה מלאים `StoreDashboardScreen` (4 טאבים: בית/הזמנות/מלאי/פורטל) + `CourierDashboardScreen` (בורר-רכב + רשימת-משלוחים + tracker + פורטל) + **מנוע-הזמנות משותף** `sysOrdersProvider` (6 שלבים): חנות `new→preparing→ready`, שליח `ready→pickup→transit→delivered`, מסונכרן. נתונים verbatim `supplier_data.dart` (proto 06 §1/§7, R8). `role_picker` מנתב חנות/שליח ל-push. **בדיקות:** `t9_supplier_personas_test` 9/9 + מערך מלא ירוק. **אומת חי ב-Chrome** (build/web v6.08): welcome→בית→בורר→🏪 חנות (שלום👋 · ₪5,070 מחזור [חישוב נכון] · BS-1042 "אשר וקבל להכנה" → **קודם חי ל"בהכנה"**) → 🛵 שליח (בורר-רכב · BS-1040 לאיסוף+tracker · **סנכרון store↔courier מאומת**). אפס overflow, אפס "בבנייה". gates 24/107/116 ✓. **נותר deferred** (proto "adds beyond"): גיליון-ליקוט, פריט-חסר, פיצול-משלוחים, POD, תעודת-משלוח-מודפסת, persistence. **🏁 שלב-א הושלם: T0-T7 + T9 ✅ · T8 stub-מכוון.**

- 2026-06-04 · **בנצי (משיק)** · **T9 — אימות-לייב סופי + דגל-deploy.** כל 3 הפרסונות מרונדרות חי (build/web v6.08, `localhost:5574`): 🦺 עובד · 🏪 חנות (4 טאבים + קידום-הזמנה חי) · 🛵 שליח (בורר-רכב + tracker + סנכרון store↔courier). הקוד על origin (`a85467d`) + מאומת מקומית. ⚠️ **דגל-deploy:** ה-gh-pages הציבורי (`/buildsmart/flutter/`) מציג גרסה ישנה מאוד (טורקיז "שלמה הקבלן") — סיבה לא ודאית (SW-cache או deploy תקוע); **לא אומת שהקומיט חי ציבורית** (gh לא מאומת → דרושה בדיקת לשונית Actions / תשתית-הדיפלוי).

- 2026-06-05 · **ספרן (תיעוד)** · עדכון-סטטוס אומת-קוד מול tip `b4e2198`: **2 באגי-HIGH דחויים נסגרו** — H2 = persistence למשימות-עובד (`bs.worker-tasks.v1`, מונע double-advance חוצה-סשן, +`worker_tasks_persistence_test` 3 cases — סוגר חלק מ-deferred "persistence" שבשורה 192) · H3 = פיוס-total בכרטיס-הזמנה. **טסטים: 1,539 ירוקים.** **deploy:** gh-pages נדחף-מחדש 15:41 (דרוש אימות-חי). **orchestrator-kit v2** (`orchestrator/`): ה-gate כולל עכשיו conformance+required-tests; נוספו `ckpt.sh`/`diff-coverage.sh`/manifests + `perfect-agent/` (ר׳ דוח 24 §G). שלב-ב עדיין ממתין ל-GO.

- 2026-06-06 · **ספרן (תיעוד)** · חוליית-audit (5-עדשות) המשיכה אוטונומית (`b4e2198..190856e`): **`efb0840`** M4 persistence + M5 (6 עלי-"רכש" ב-`menu_dial_widget` → hub-החנות) · **`39ab239`** מסירה דו-שלבית חנות→שליח (תיקון-בעלות ב-`sys_orders`; נוגע T5) · **`190856e`** 4 פקדים חוברו (🎤 קולי/📷 ברקוד→חיפוש · stepper-כמות→סל · פקד-chats). **השפעה:** T4 (~43) וקצה-1 (עלי-תפריט) **מצטמקים בזמן-אמת**; **ליבת שלב-ב (Track T1–T6) לא נגעה.** gh-pages פורסם-מחדש 22:30. הסוכנים בודקים מצב-חי לפני לקיחה.

- 2026-06-07 · **ספרן (שחזור-מצב)** · **שלב-ב נבנה ונדחף — אומת מהבייטים אחרי שהארכיטקט איבד context.** origin/whats-happening = `ac3073d`. **2 commits:** `a337944` (שלב-0: B0 seeds + T10 טריגר + T6.1 repo-interfaces) · `ac3073d` (Phase-1: 35 קבצים · 13,588 שורות). **כל ה-tracks נחתו:** T1 `finance_hub_sheets`+state · T2 `site_hub_screen`+state · T3.A `tasks` · T3.B `smart_project` · T3.C `budget` · T3.D `stock` · T3.E `scan_menu` · T3.F `projects` · T3.G `rewards_hub` · T3.H `ai_hub` · T3.I `home_content_reorder` (+engines) · T4 (`camera_sheet`/`chats`/`chat_settings` ערוכים) · T5 (`persona_picking_sheet`/`persona_pod_sheet`/`fulfillment`+store/courier) · **חיווט-מרכזי** (`home_shell`+`menu_dial_widget`) · 6 קבצי-test. **זה ה-source-of-truth — לא זיכרון-הסוכן. נותר:** gate v2 חי + screenshots + אימות-deploy.

- 2026-06-07 · **ספרן (שינוי-ארכיטקטורה)** · **ה-menu-dial הוסר (dial-distribution cutover `b9737cf`).** הכלים הופצו לגישה-נייטיב: finance←טאב-חנות (`openFinanceHub`) · site←תפריט-בית (`openSiteHub`) · projects←`install_studio`→משימות/תקציב/פרויקט-חכם · scan/AI/stock/home←תפריט-בית · rewards←מסך-פרופיל-חדש (`profile_screen.dart`) · הגדרות←תפריט-⋮ פר-טאב. עצי-הכלים → `data/menu_trees.dart`. **T10 (טריגר) מבוטל.** **LAW #0 נחקק** (`3186f9c`): אין עבודה בלי הפעלת צי-9x9. גם: איחוד משטחים-כפולים (`1cef025`). מפת-הגישה המלאה: `00-START-HERE` §4.6.
