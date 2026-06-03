# לוח-זמנים מפורק — סיום "לוח קבלן" (ימים · שעות · יעד)

> פירוק יום-אחר-יום של `PLAN-contractor-completion.md`. כל יום = ~7 שעות-עבודה, יעד-אחד, ו-DoD.
> מקור-אמת לכל שורה: `app_flutter/knowledge/port/proto/04-contractor-projects-tasks.md` (`§` = סעיף שם).
> אילוצים בכל משימה: R2 (dial-leaf, אין view) · R6/R8 (verbatim) · R9 (inline) · 116 שערים · push-מילולי.

---

## 📅 יום 1 — 🎯 יעד: תשתית-נתונים + helpers ירוקים (Sprint 0)
| שעות | משימה | מקור |
|---|---|---|
| 3ש׳ | data-seeds verbatim → Dart `const`: PROJECTS(3)·ARCHIVED(3)·SITE_TREE·STOCK_DEMO(11)·PLAN_TYPES(4)·budgetCategories(4)·projectBudget·PAYMENT_TERMS(4)·subcontractors(3)·approvalQueue(2)·FX·BUILD_INDEX·GANTT(6)·snag(2)·inspections(2)·SAFETY_TIPS(5)·WORK_LOG(2)·DEMO_HISTORY(2)·TASKS(5) | §0,§2–§9 |
| 3ש׳ | Riverpod `StateNotifier`-ים ל-mutable (projects/tasks/budget/stock/snag/inspections/attendance/diary/penalty/subs/approvals) | §port-notes#1 |
| 2ש׳ | helpers `fMoney`/`caToday` + מתמטיקה (pct=66%·ROI×1.42·index+6.10%·invoice-weights·triangular) + test/helper | §0,§3,§4 |
**DoD:** `seeds_test`+`math_test` ירוקים · `flutter analyze`=0.

## 📅 יום 2 — 🎯 יעד: קטלוג-⋮ חי (Tier-1 א׳)
| שעות | משימה | מקור |
|---|---|---|
| 4ש׳ | `1.1` קטלוג⋮ "סרוק תוכנית" → PLAN_TYPES מלא: 4 סוגים·zones·השוואת-חנויות·`addScanToCart` | §9 |
| 1ש׳ | `1.2` קטלוג⋮ "חלופות זולות" → `cheaperAlternativeBrand` (**helper קיים**) | helper |
| 2ש׳ | `1.3` קטלוג⋮ "השוואת מחירים" → store-compare | §9 |
**DoD:** 3 פריטי-קטלוג⋮ מציגים content (לא toast).

## 📅 יום 3 — 🎯 יעד: חנות+התראות+שיחות חיים (Tier-1 ב׳)
| שעות | משימה | מקור |
|---|---|---|
| 3ש׳ | `1.4` חנות→services → השכרה/פקדונות/RMA/RFQ/MSDS (**R9 inline**) | §3 |
| 2ש׳ | `1.5` חנות→orders → ORDER_STATUS + doc-OCR (OCR→toast) | §9d |
| 1.5ש׳ | `1.6` התראות→budget/safety → thresholds 80/90% · SAFETY_TIPS×5 | §3,§5 |
| 0.5ש׳ | `1.7` שיחות→chatbot (BOT_KB) · `1.8` מחלקות-"בקרוב" | §J,§1 |
**DoD:** 🎯 **Tier-1 מלא — הקבלן רואה תוכן-אמת בלי טריגר.**

## 📅 יום 4 — 🎯 יעד: התפריט נפתח + פיננסים מתחיל (Sprint 2 + 3A א׳)
| שעות | משימה | מקור |
|---|---|---|
| 2ש׳ | `2.0` טריגר `OpenDial.menu` (מחווה/פקד R2-safe) → 41 העלים נגישים | LAUNCH_READINESS P1 |
| 1ש׳ | `2.1` (אופ׳) טריגר `OpenDial.search` | — |
| 4ש׳ | `3A.1` פיננסים: finIndex(+6.10%)·finPayTerms(4)·finSubs(3) | §4 |
**DoD:** תפריט-dial נפתח · 3 פיצ'רי-פיננסים חיים.

## 📅 יום 5 — 🎯 יעד: מרכז-פיננסים מלא (Sprint 3A ב׳)
| שעות | משימה | מקור |
|---|---|---|
| 4ש׳ | finApprovals(**RBAC**+audit+push)·finThresholds·finROI·finInvoiceSplit | §4 |
| 3ש׳ | finPenalties(**R9**)·finReports(**toast**)·finFX(מחשבון) | §4 |
**DoD:** 10 פיצ'רי-פיננסים חיים · math תואם-פרוטוטייפ.

## 📅 יום 6 — 🎯 יעד: ניהול-אתר חצי (Sprint 3B א׳)
| שעות | משימה | מקור |
|---|---|---|
| 4ש׳ | siteGantt(RTL span=27)·siteLocations·siteDeps(4)·siteArchive(3)·siteSafety(5+ack) | §5 |
| 3ש׳ | siteSnagging(**R9**)·siteAttendance(clock GPS-demo)·siteDiary(**R9**) | §5 |
**DoD:** 7 כלי-אתר חיים.

## 📅 יום 7 — 🎯 יעד: אתר+מלאי+סריקה-תפריט (3B ג׳+3C+3D)
| שעות | משימה | מקור |
|---|---|---|
| 2ש׳ | siteInspect(**R9**)·sitePhotos(**toast**) — סיום אתר(10) | §5 |
| 2ש׳ | `3C` מלאי: 2 tabs מחסן/אתר + `moveStock` (11 פריטים) | §8 |
| 3ש׳ | `3D` סריקה-תפריט (4 — משתף לוגיקה עם 1.1) | §9 |
**DoD:** אתר(10)+מלאי+סריקה מלאים.

## 📅 יום 8 — 🎯 יעד: AI+פרויקטים → Tier-2 מלא (3E+3F)
| שעות | משימה | מקור |
|---|---|---|
| 4ש׳ | `3E` AI(9): ברקוד/דיבור **אמיתיים** · השאר honest-stub | AI-hub |
| 3ש׳ | `3F` פרויקטים(3): רשימה·`switchProject`(cart per-project)·סטטוס-אתר | §2 |
**DoD:** 🎯 **Tier-2 מלא — 41 העלים חיים.**

## 📅 יום 9 — 🎯 יעד: מערכת-המשימות (Sprint 4A)
| שעות | משימה | מקור |
|---|---|---|
| 6ש׳ | משימות: 5 + מכונת-סטטוס(5) + manager/worker + **auto-advance** + WORK_LOG | §6 |
| 1ש׳ | נקודת-תליה (dial-leaf) + בדיקות-מעבר | §6 |
**DoD:** מערכת-משימות מלאה (worker→review→approve).

## 📅 יום 10 — 🎯 יעד: פרויקט-חכם (Sprint 4B)
| שעות | משימה | מקור |
|---|---|---|
| 6ש׳ | "מאפס עד מסירה": 9 day-stages · done לא-מסודר · `smartStepDone` · day-picker | §7 |
| 1ש׳ | diagram-embed (gate מאחורי קטלוג) + בדיקות | §7 |
**DoD:** פרויקט-חכם מלא (progress=done/9).

## 📅 יום 11 — 🎯 יעד: תקציב + בית (Sprint 4C+4D)
| שעות | משימה | מקור |
|---|---|---|
| 4ש׳ | תקציב-בסיסי: box/detail/editor + 4 קטגוריות (provider יחיד) | §3 |
| 3ש׳ | תוכן-בית: reorder(DEMO_HISTORY)·home product-cards(3) | §1 |
**DoD:** תקציב(pct=66%)+בית חיים.

## 📅 יום 12 — 🎯 יעד: parity-קבלן מלא + ליטוש (Sprint 4E)
| שעות | משימה | מקור |
|---|---|---|
| 5ש׳ | BS-personas: מנהל/חנות/שליח/עובד → dial-content (R2-safe, לא views) | persona-dashboards |
| 2ש׳ | ליטוש: RTL·a11y/Semantics·global-error-handler + regression מלא | LAUNCH_READINESS P1 |
**DoD:** 🎯 **parity-קבלן מלא · כל הבדיקות ירוקות.**

---

## סיכום
| שלב | ימים | יעד-על |
|---|---|---|
| תשתית | 1 | data ירוק |
| Tier-1 נגיש | 2–3 | תוכן בלי-טריגר |
| טריגר+פיננסים | 4–5 | תפריט+פיננסים |
| אתר+מלאי+סריקה | 6–7 | ניהול-אתר |
| AI+פרויקטים | 8 | Tier-2 מלא |
| משימות+חכם+תקציב+בית | 9–11 | פיצ'רים-חסרים |
| personas+ליטוש | 12 | parity מלא |
| **סה"כ** | **12 ימי-עבודה** | |

**נפרד (P0 השקה · לא-קוד):** iOS usage-strings+signing · Android keystore+Play · Huliot R2-crops — ~1–2 ימים + חשבונות-חנות.
