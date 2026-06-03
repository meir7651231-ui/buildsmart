# תוכנית-עבודה — סיום "לוח קבלן"

> **מטרה:** להכניס את כל תוכן-הקבלן (מהאב-טיפוס) לתוך אפליקציית-ה-Flutter הקיימת — **בלי כפתורים חדשים**.
> **אפליקציה:** `app_flutter/` (Flutter · סגנון-וואטסאפ · 4 טאבים: מחלקות/שיחות/התראות/חנות).
> **ביצוע:** ענף `claude/whats-happening-LyY9G` · דרך 116 השערים (דוחות 21–22) · literal-push-gate.
> **מקור-אמת:** `app_flutter/knowledge/port/proto/04-contractor-projects-tasks.md` (546ש' verbatim) + proto §1–§9.
> **כללים:** R2 (אין view חדש · dial-leaf בלבד) · R6/R8 (מחרוזות verbatim) · R9 (`prompt`→inline) · server/print/camera/OCR→toast-stub.

---

## חלק א׳ — מודל-העבודה (אומת בקוד 2026-06-03)

**3 שכבות-נגישות של הכפתורים הקיימים:**

| Tier | מהות | נגישות | מספר |
|---|---|---|---|
| 🟢 **1** | משטחים נגישים-עכשיו שמציגים "בבנייה" | מיידי, אפס-טריגר | ~9 |
| 🟡 **2** | תפריט-dial בנוי אבל **מוסתר** (`OpenDial.menu` לא-מוצב) | צריך טריגר-אחד | 41 עלים |
| 🔵 **3** | BS-personas (מנהל/חנות/שליח/עובד) | נגיש (לוגו-BS) | 4 תת-עצים |

**אסטרטגיה:** תשתית → Tier-1 (ניצחונות-נגישים) → טריגר → Tier-2 → חסרים+personas.
**עיקרון anti-כפילות:** לוגיקה משותפת (scan, services) נבנית **פעם-אחת** וצפה בכמה משטחים.

---

## חלק ב׳ — רצף-ה-Sprints (מסודר לפי תלות + ערך)

### 🔧 Sprint 0 — תשתית (≈1 יום) · **חוסם הכל**
| # | משימה | מקור | DoD |
|---|---|---|---|
| 0.1 | data-seeds verbatim → Dart immutables (PROJECTS·budget·finance·site·stock·PLAN_TYPES·tasks·…) | §0,§2–§9 | counts-test verbatim |
| 0.2 | StateNotifiers (mutable: projects/tasks/budget/stock/snag/…) | §port-notes #1 | persist-test |
| 0.3 | helpers `fMoney`/`caToday` + מתמטיקה (pct=66%·ROI×1.42·index+6.10%·weights) | §0,§3,§4 | gate-42 test/helper |

### 🟢 Sprint 1 — Tier-1: ניצחונות-נגישים (≈2 ימים) · ערך-מיידי
| # | כפתור (נתיב) | היום | תוכן | מקור |
|---|---|---|---|---|
| 1.1 | קטלוג ⋮ → סרוק תוכנית | sheet, 4×toast | PLAN_TYPES מלא (zones/חנויות/cart) | §9 |
| 1.2 | קטלוג ⋮ → חלופות זולות | toast | `cheaperAlternativeBrand` (**helper קיים**) | helper |
| 1.3 | קטלוג ⋮ → השוואת מחירים | toast | השוואת-חנויות | §9/store |
| 1.4 | חנות → services | items בלי-flow | RFQ/RMA/MSDS/השכרה/פקדונות (**R9 inline**) | §3 |
| 1.5 | חנות → orders | items | ORDER_STATUS + doc-OCR (OCR→toast) | §9d |
| 1.6 | התראות → budget/safety | sections | thresholds 80/90% · SAFETY_TIPS×5 | §3,§5 |
| 1.7 | שיחות → chatbot | auto-reply בסיסי | BOT_KB (kw→תשובה) | §J |
| 1.8 | מחלקות "בקרוב" (5) | toast 'בקרוב' | קטגוריות (חשמל/בנייה/גמר/בטיחות) או honest-stub | §1 |

### 🟡 Sprint 2 — פתיחת-התפריט (≈0.5 יום) · **חוסם את Tier-2**
| # | משימה | הערה |
|---|---|---|
| 2.0 | לחווט טריגר `OpenDial.menu` (מחווה/פקד R2-safe) → 41 העלים נגישים | פער-ידוע (LAUNCH_READINESS P1) |
| 2.1 | (אופ׳) טריגר `OpenDial.search` (קולי/ברקוד כבר אמיתיים) | — |

### 🟡 Sprint 3 — Tier-2: תוכן 41 העלים (≈5 ימים)
| # | קבוצה | כפתורים | מקור | אומדן |
|---|---|---|---|---|
| 3A | מרכז-פיננסים | 10 (מדד/תשלום/subs/אישורים-RBAC/חריגה/ROI/פיצול/קנסות/דוחות/מט״ח) | §4 | 1.5 |
| 3B | ניהול-אתר | 10 (גאנט/ליקויים/מיקום/נוכחות/יומן/בטיחות/תלויות/צילום/ביקורת/ארכיון) | §5 | 1.5 |
| 3C | מלאי | 2 (מחסן/אתר + move) | §8 | 0.25 |
| 3D | סריקה (תפריט) | 4 — *משתף לוגיקה עם 1.1* | §9 | 0.5 |
| 3E | AI | 9 (ברקוד/דיבור אמיתיים · השאר honest-stub) | AI-hub | 0.5 |
| 3F | פרויקטים | 3 (רשימה/switch/סטטוס) | §2 | 0.5 |

### 🔵 Sprint 4 — פיצ'רים-חסרים + personas (≈4 ימים)
| # | פיצ'ר | הערה | מקור | אומדן |
|---|---|---|---|---|
| 4A | מערכת-משימות (מנהל/עובד · מכונת-סטטוס 5) | אין-לו-כפתור → צריך נקודת-תליה | §6 | 1 |
| 4B | פרויקט-חכם "מאפס עד מסירה" (9 stages) | תלוי-diagram | §7 | 1 |
| 4C | תקציב-בסיסי (box/detail/editor + 4 קט') | קפל-לפרויקטים | §3 | 0.5 |
| 4D | תוכן-בית (reorder · product-cards) | — | §1 | 0.5 |
| 4E | BS-personas (מנהל/חנות/שליח/עובד) | dial-content R2-safe | persona-dashboards | 1 |

---

## חלק ג׳ — אומדן ו-milestones

| Sprint | תוכן | אומדן | Milestone |
|---|---|---|---|
| 0 | תשתית | 1 יום | data+helpers ירוקים |
| 1 | Tier-1 נגיש | 2 ימים | **🎯 הקבלן רואה תוכן-אמת בלי טריגר** |
| 2 | טריגר-תפריט | 0.5 | התפריט נפתח |
| 3 | Tier-2 (41) | 5 ימים | **🎯 פיננסים+אתר+מלאי+סריקה חיים** |
| 4 | חסרים+personas | 4 ימים | **🎯 parity-קבלן מלא** |
| | **סה"כ** | **~12.5 ימים** | (ניכוי-כפילות scan/services ≈ −1) → **~11–12** |

**נפרד (לא-קוד · P0 השקה):** iOS usage-strings+signing · Android keystore+Play · Huliot R2-crops · ~1–2 ימים + חשבונות-חנות.

---

## חלק ד׳ — Definition-of-Done (לכל משימה)
1. ✅ הכפתור מציג content-אמת (לא toast 'בבנייה')
2. ✅ מחרוזות/מספרים **verbatim** מהאב-טיפוס (R6/R8)
3. ✅ קלטים = R9-inline (לא prompt/modal) · אין view-מסך-מלא חדש (R2)
4. ✅ `flutter analyze`=0 · `flutter test`=ירוק · test לכל helper (gate-42)
5. ✅ עובר 116-מספור-השערים + ANTIPATTERN-clean (gate-103/111)
6. ✅ push רק אחרי אישור-מילולי (`תדחוף`/`push`)

## חלק ה׳ — נקודת-התחלה
**Sprint 0 → Sprint 1.** התשתית חוסמת הכל; אחריה Tier-1 נותן ערך-נראה-לקבלן מיד בלי תלות בטריגר. רק אז Sprint 2 (טריגר) פותח את Tier-2.
