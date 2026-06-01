# KNOWLEDGE_AUDIT — פנקס-הנמקות לליטוש-הידע (פאזה K)

> כל שינוי על מסמך — מיזוג / deprecate / ארכוב / מחיקה — נרשם כאן **לפני** הפעולה,
> עם 4 שדות-החוק (POLISH_PROTOCOL §K.0). בלי 4 השדות — אין פעולה.

---

## סבב 1 — איחוד פרוטוקול-הבדיקה (2026-06-01)

### `TESTING.md`
- **למה נכתב:** 2026-05-26, "the verification protocol — 3 layers". פילוסופיית-הבדיקה הראשונה ל-Flutter.
- **תפקידו היום:** רקע ל-3 השכבות + היסטוריית-מוטציה. נאכף ע"י `knowledge_protocol_test` (קיים + >400 ת').
- **רלוונטי?** ⚠️ חלקית — התוכן קופל ל-`VERIFICATION_PROTOCOL` §1/§3.
- **למה כן/לא:** התוכן כפול עכשיו, אבל **אסור למחוק** — טסט אוכף קיום+אורך. → **deprecate-stub** (>400 ת', מנותב).

### `CHECKLISTS.md`
- **למה נכתב:** 2026-05-26, "copy-paste checklists for common changes".
- **תפקידו היום:** 5 רשימות-פעולה. מופנה רק מ-README (לא נאכף).
- **רלוונטי?** ⚠️ חלקית — קופל ל-`VERIFICATION_PROTOCOL` §4b.
- **למה כן/לא:** לא נאכף → אפשר להמיר חופשי. → **deprecate-stub** מנותב.

### `BUG_INVESTIGATION_PROTOCOL.md`
- **למה נכתב:** 2026-05-31, "100 צעדים — אבחון לפני פתרון" (כלל #39).
- **תפקידו היום:** זרוע-החקירה כשטסט/שער נצבע אדום.
- **רלוונטי?** ⚠️ חלקית — 100 הצעדים קופלו ל-`VERIFICATION_PROTOCOL` §4.
- **למה כן/לא:** לא נאכף ע"י שער/טסט. → **deprecate-stub** מנותב.

### `TESTS_OVERVIEW.md`
- **למה נכתב:** 2026-05-31, "what each test/ file guards" — אינדקס 102 קבצי-טסט.
- **תפקידו היום:** lookup "איזה טסט שומר על מה". נאכף ע"י **שער 2** (קיום).
- **רלוונטי?** ✅ כן — אינדקס חי, לא כפילות.
- **למה כן/לא:** טבלת-lookup, לא פרוצדורה. קיפול = ניפוח בלי ערך. → **keep כנספח**;
  `VERIFICATION_PROTOCOL` §8 מפנה אליו.

**סיכום סבב 1:** 3 deprecate-stub · 1 keep · 0 delete · 0 archive.
ארבעתם עדיין קיימים (אין הפניה-שבורה; שער 2 + knowledge_protocol_test ירוקים).

---

## סבב 2 — מצאי top-level מלא + פער-אינדקס (2026-06-01 · סוכן: ליטוש)

> פאזה K, צעדים K1–K4. **Verdict-only pass** — הסבב הזה **כותב verdict ומסווג בלבד**.
> **אפס פעולות בוצעו** (לא מיזוג / deprecate / מחיקה / העברה). פריט **SUBMIT** דורש
> אישור-משתמש (K5/K.0). פריט **🔒** בבעלות פרוטוקוליסט — ליטוש מבקר בלבד, לא נוגע
> (טבלת-בעלות `AGENT_COORDINATION.md`: `.githooks/` · `CARRY_FORWARD` · `PROTOCOL_AUDIT_PLAN` ·
> `AGENT_WORK_PLAN` · generator · `stuck_log`/`mutation_log` append-only).

### K1 — ממצא-על
- 76 מסמכי `.md`: **44 top-level + 32 בתתי-תיקיות** (`port/` 19 · `spec/` 9 · `adr/` 3 · `inspections/` 1).
  כמעט כולם נוצרו 2026-05-31 בקומיט-על יחיד ("close M1-M7 session").
- **הבעיה אינה כפילות המונית.** סקירת-תוכן מצביעה על **היררכיות-תכלית נבדלות**, לא שכפול.
  הבעיה האמיתית: **פער-אינדקס** — README מאנדקס 18 שמות בלבד, ו-**27 מסמכי top-level יתומים**.
  אפילו חוק-העל הקנוני (`MASTER_PROTOCOL`) ותוכנית-העבודה הראשית (`ROADMAP`) **אינם** ב-README.
- **בלם-בטיחות:** 9 מסמכים נאכפים ע"י `knowledge_protocol_test` (אסור לשבור הפניה):
  ARCHITECTURE · CONVENTIONS · DECISIONS · README · SPEC · STATUS · TARGET · TESTING · WIRING.

### K3+K4 — verdict + סיווג (מקובץ לפי שכבת-אינדקס; משמש גם כשלד ל-K9)

מקרא: ✅ keep-canonical (כבר באינדקס) · 🗂 keep + להוסיף-לאינדקס (יתום תקֵף) ·
🔒 בעלות-פרוטוקוליסט (audit-only) · 🔁 deprecate-candidate (**SUBMIT**) · ⛔ stub מסבב 1

**meta / אינדקס**
| מסמך | תפקיד | verdict |
|------|-------|---------|
| README.md | אינדקס + פרוטוקול-על | ✅ |
| STATUS.md | snapshot גרסה/מצב (נאכף) | ✅ |
| KNOWLEDGE_AUDIT.md | פנקס-verdict פאזה K (שלי) | ✅ |

**חוק-על (process law)**
| מסמך | תפקיד | verdict |
|------|-------|---------|
| MASTER_PROTOCOL.md | חוק-תהליך מאוחד (1628 ש') — נכתב לאחד 14 מסמכים | 🗂 🔒 |
| PROTOCOL.md | חוק-תהליך ישן (462) — קדם ל-MASTER | 🔁 **SUBMIT** |
| PLAYBOOK.md | יומן-למידה רציף (stuck→solved) + PUSH POLICY | ✅ 🔒 |
| PROTOCOL_ENFORCEMENT.md | סקירת 4 שכבות-אכיפה | 🗂 |

**אימות (verification)**
| מסמך | תפקיד | verdict |
|------|-------|---------|
| VERIFICATION_PROTOCOL.md | סולם L0–L7 — סמכות-בדיקה יחידה | ✅ |
| TESTS_OVERVIEW.md | אינדקס 102 קבצי-טסט (נספח) | ✅ |
| mutation_log.md | יומן מוטציות (נאכף) | 🗂 🔒 |
| TESTING.md / CHECKLISTS.md / BUG_INVESTIGATION_PROTOCOL.md | קופלו → VERIFICATION | ⛔ (סבב 1) |

**ממשל-סוכנים (agent governance)**
| מסמך | תפקיד | verdict |
|------|-------|---------|
| AGENT_COORDINATION.md | מטריצת-הרשאות 6 סוכנים + נוהל push/sync (חי, v5.43) | 🗂 |
| AGENT_WORK_PLAN.md | משימות פרוטוקוליסט | 🗂 🔒 |
| AGENT_READINESS.md | צ'קליסט מוכנות לפני האצלה | 🗂 |
| AGENT_PATTERNS.md | playbook עבודה מקבילה (קבצים-זרים, תקרת-3) | 🗂 |

**תוכניות-עבודה (roadmaps / fix-protocols)**
| מסמך | תפקיד | verdict |
|------|-------|---------|
| ROADMAP.md | תוכנית 100-צעד עד השקה (כללי) | 🗂 |
| SMARTPRODUCT_ROADMAP.md | תוכנית 100-צעד לכרטיס בלבד (תת-קבוצה) | ✅ |
| SIZE_FILTER_PROTOCOL.md | בעיה→תיקון→לקח לציר-גודל (P1–P10) | ✅ |
| IMPROVEMENTS_PROTOCOL.md | שיפורי סבב-2 (I1–I10+) מעל SIZE_FILTER | 🗂 |
| PROTOCOL_AUDIT_PLAN.md | ביקורת 100-צעד על לוגיקת השערים | 🗂 🔒 |

**port / parity / target**
| מסמך | תפקיד | verdict |
|------|-------|---------|
| TARGET.md | הגדרת-יעד (proto/reference/target, cutover) (נאכף) | ✅ |
| PARITY.md | port-map מפורט proto+Preact→Flutter | ✅ |
| SPEC.md | מפת-פונקציה מתומצתת לכל מסך/אלמנט (נאכף) | ✅ |

**ארכיטקטורה + מודל-נתונים**
| מסמך | תפקיד | verdict |
|------|-------|---------|
| ARCHITECTURE.md | סקירת-מערכת (screens/state/data/nav) (נאכף) | ✅ |
| STATE_OVERVIEW.md | מצאי ~28 קבצי-state + מפתחות-persist | 🗂 |
| SCHEMA.md | איחוד מודל-נתונים (3 עמודי-תווך + גשר-SKU) | 🗂 |
| HELPER_INDEX.md | רישום ~45 helpers ב-`related_info.dart` | 🗂 |
| CONVENTIONS.md | פלטה light/RTL/tokens/wiring (נאכף) | ✅ |
| DECISIONS.md | יומן-ADR (D-013/D-012…) (נאכף) | ✅ |

**כרטיס-מוצר + קטלוג**
| מסמך | תפקיד | verdict |
|------|-------|---------|
| CATALOG-CARD-PROTOCOL.md | צ'קליסט בניית-כרטיס (1143; §14.E) | 🗂 |
| CARD_FLOW.md | סדר-render של הכרטיס מלמעלה-למטה | 🗂 |
| COACH_MODE.md | חזון coaching (ROADMAP 99–100) | 🗂 |
| PROJECTS_GUIDE.md | פיצ'ר "פרויקטים" (ROADMAP 71–80) | 🗂 |
| REVIEW-product-card-nontech.md | משוב-משתמש לא-טכני על הציפים | 🗂 |
| polyroll-ingest-spec.md | spec קליטת קטלוג Polyroll (774 פריטים) | 🗂 |

**למידה (lessons)**
| מסמך | תפקיד | verdict |
|------|-------|---------|
| CARRY_FORWARD.md | 22 לקחים מנוסחים (זיקוק מ-stuck_log) | 🗂 🔒 |
| stuck_log.md | יומן בעיה-פתרון-ANTIPATTERN (997, append-only נאכף) | 🗂 🔒 |

**הגדרות-תפקיד (agent protocols) · session · build**
| מסמך | תפקיד | verdict |
|------|-------|---------|
| POLISH_PROTOCOL.md | פרוטוקול ליטוש (שלי) | 🗂 |
| LAUNCH_READINESS_PROTOCOL.md | פרוטוקול בנצי (משיק) | 🗂 |
| SESSION_PLAN_TEMPLATE.md | מבנה-חובה ל-session_plan (שערים 21/22/106) | 🗂 |
| session_plan.md | artifact סשן נוכחי (ephemeral) | 🗂 |
| BUNDLE_SPLIT.md | תכנון code-split ל-web payload (ROADMAP 88) | 🗂 |

### Verdict מלא (4 שדות) — הפריט היחיד עם פעולה מוצעת

#### `PROTOCOL.md` → 🔁 deprecate-candidate · **SUBMIT (K5 — דורש אישור-משתמש)**
1. **למה נכתב:** 2026-05-31, "חוק-תהליך" ראשון ל-Flutter (R2/R6/R8, dial-not-window, test-first, helper, wiring, build-order).
2. **תפקידו היום:** 462 שורות חוק-תהליך. לפי כותרת `MASTER_PROTOCOL`, התוכן שלו **קופל** ל-MASTER (1628). **לא** נאכף ע"י טסט/שער (אינו ברשימת 9 הנאכפים). אינו ב-README. לא מוזכר כ-source-of-truth באף מקום פעיל שמצאתי.
3. **רלוונטי?** ⚠️ חלקית — כפילות-על מול `MASTER_PROTOCOL`.
4. **למה כן/לא:** התוכן הוחלף ע"י MASTER. אבל זה **חוק-על = טריטוריית פרוטוקוליסט**, וההכרעה "מי הסמכות הקנונית" היא בדיוק מה ש-K5 דורש עליו אישור. **המלצה:** `mark-deprecated` (כותרת ⛔ + הפניה ל-MASTER), **לא מחיקה** — בכפוף לאישורך ולאישור הפרוטוקוליסט. עד אז: ללא נגיעה.

> **שאלת-K5 הנלווית:** גם `MASTER_PROTOCOL` עצמו אינו ב-README. אם MASTER הוא הסמכות —
> חובה לאנדקס אותו (K9). אם בכוונה משאירים גם את 14 המקורות הגרנולריים כ-source-of-truth
> נפרד — אז MASTER הוא ה-mega-doc הכפול. זו הכרעת-בעלים, לא של ליטוש.

### פעולות
- **בטוח לביצוע (בנתיב ליטוש, אחרי GO לכיוון):** K9 — בניית `README.md` כאינדקס-אמת המכסה את 27 היתומים, מסווגים לפי השכבות לעיל, משפט-תפקיד לכל אחד. אינו נוגע בתוכן מסמך אחר, אינו שובר הפניה נאכפת (רק מוסיף).
- **SUBMIT (דורש אישור-משתמש):** deprecate ל-`PROTOCOL.md` + הכרעת-סמכות חוק-העל (K5).
- **🔒 audit-only (לא לגעת):** MASTER_PROTOCOL · CARRY_FORWARD · PROTOCOL_AUDIT_PLAN · AGENT_WORK_PLAN · mutation_log · stuck_log + `.githooks/`. אאנדקס אותם ב-K9, **בלי לערוך** את גופם.

**סיכום סבב 2 (pass ראשון):** 44 מסמכי top-level מסווגים · 27 לאינדקס (K9) · 1 deprecate-candidate
(SUBMIT) · 6 audit-only(🔒) · **0 פעולות בוצעו**. אפס הפניות נשברו.

---

### ביקורת-עצמית — re-review מול הקבצים (2026-06-01)
> אומת ישירות מול גוף-המסמכים (לא רק סיכום-subagent). זהו ה-grounding שדרוש לפני כל פעולה.
- ✅ **`PROTOCOL.md` → deprecate-candidate אומת.** פתיח PROTOCOL ≈ פתיח MASTER מילה-במילה (אותו
  ציטוט INSP-0025, אותה שורת "source of truth לתהליך"); MASTER הוא ה-evolution הישיר (החליף רק
  `ROADMAP`→`SMARTPRODUCT_ROADMAP`). אף מקום פעיל לא מצטט את PROTOCOL.md כחוק. הוורדיקט מחוזק.
- ✅ **MASTER = הסמכות הפעילה** — מוגן ע"י **שער 88** (`.allow_master_protocol_edit`), מצוטט
  מ-hook/stuck_log/POLISH/PROTOCOL_AUDIT_PLAN. מאשר 🔒 + SUBMIT.
- ⚠️ **למה רק PROTOCOL (ולא 14 ש-MASTER "מאחד"):** 14 שומרים תפקיד-חי נבדל (SMARTPRODUCT_ROADMAP=
  מקור-תוכן מוצהר; PLAYBOOK/stuck_log=append-only; SCHEMA/HELPER_INDEX/CARD_FLOW=reference מסונכרן-קוד).
  PROTOCOL לבדו חסר תפקיד-חי — הגרסה הישנה בלבד.
- ⚠️ **Watch-item (לא פעולה):** MASTER הקפיא snapshot של 14 מסמכים חיים → **סיכון-drift**. הוגש
  לפרוטוקוליסט (`AGENT_COORDINATION.md` §ממצא ליטוש).
- ⚠️ **תיקוני-ספירה:** top-level=44 (לא 45) · subdir=32 (לא 31). תוקן לעיל.

### לקח-מתודולוגיה — הוכן לפרוטוקול · תיישום בסבב 3
> **K-verdict source-grounding:** verdict שמוביל לפעולה (deprecate/merge/delete) חייב קריאה
> **ישירה** של מסמך-המקור — לא סיכום-subagent ולא ה-self-description של המסמך.
> **Consolidation-consistency:** כשמסמך טוען שהוא מאחד N מסמכים — סווג את **כל ה-N** במפורש
> (superseded מול שומר-תפקיד-חי), אל תבודד אחד בלי נימוק.
> הוגש כהצעה לפרוטוקוליסט (`AGENT_COORDINATION.md`). **תיישום: סבב 3.**

### סבב 3 — מתוכנן (טרם בוצע)
1. verdict ל-32 מסמכי תת-תיקייה (`port/`/`spec/`/`adr/`/`inspections/`) — צפי keep (עוגנים/אפיון).
2. יישום לקח-המתודולוגיה: סיווג עקבי ומאומת-מקור של 15 מסמכי-ה-consolidation של MASTER.
3. K9 (בניית README index) — לאחר GO + הכרעת יחס MASTER↔granular.

---

## סבב 3 — תת-תיקיות (בוצע · 2026-06-01 · source-grounded)

> יישום לקח-המתודולוגיה מסבב 2: כל verdict מאומת בקריאה ישירה של ה-README של תת-התיקייה
> (לא הנחה). **verdict-only — 0 פעולות.**

### K1 — מצאי תת-תיקיות (32 מסמכים · ~10,000 שורות)
- `port/` (19) — ידע-הטמעה: עוגני-המקור (`proto/` = הפרוטוטייפ, `preact/` = התרגום-ל-dial),
  `design-system`, `COVERAGE`. אינדקס פנימי: `port/README.md`. (עוגן §3 בפרוטוקול-הליטוש.)
- `spec/` (9) — אפיון פורמלי מסך-אחר-מסך (10 סעיפים, R8). אינדקס פנימי: `spec/README.md`.
- `adr/` (3) — Architecture Decision Records (ADR-001 No-Window · ADR-002 Dial). אינדקס: `adr/README.md`.
- `inspections/` (1) — README בלבד (אין עדיין ביקורות Flutter; הלגאסי ב-`port/preact/05`).

### K3+K4 — verdict
**כל 32 — ✅ keep-canonical.** אפס כפילות, אפס מסמך-מת. כל אשכול מאונדקס פנימית ב-README שלו.

| אשכול | verdict | אינדקס מ-top-level? |
|------|---------|---------------------|
| `port/*` (19) | ✅ keep — עוגן-מקור לפאריטי | 🟡 עקיף (דרך `PARITY.md`), לא ישיר |
| `spec/*` (9) | ✅ keep — אפיון פורמלי | ✅ כן (README שורה 17) |
| `adr/*` (3) | ✅ keep — החלטות-אדריכלות | ❌ לא |
| `inspections/README` (1) | ✅ keep — שלד-ארכיון | ❌ לא |

### ⚠️ תלות שהתגלתה (source-grounding תפס) — נוגעת ל-SUBMIT של `PROTOCOL.md`
`adr/README.md` ו-`inspections/README.md` מפנים ל-**`PROTOCOL.md` חלק 5/8** (תבנית-ADR · תהליך-ביקורת).
מסקנה: אם PROTOCOL.md יקבל deprecate — ה-stub **חייב** לשמר נגישות לחלקים 5/8 (או להפנותם ל-MASTER),
אחרת שתי ההפניות יישברו. מחזק את הכלל: **deprecate-stub-עם-הפניה, לא מחיקה.** (טרם בוצע — SUBMIT.)

### K9 — פערי-אינדקס top-level שנותרו (להשלמה לאחר GO)
README מאנדקס רק `spec/`. חסרים מצביעים ל-`port/` (או הבהרה ש-`PARITY.md` מכסה) · `adr/` · `inspections/`.

**סיכום סבב 3:** 32 keep-canonical · 0 פעולות · גילוי-תלות אחד (adr/inspections → `PROTOCOL.md` חלק 5/8).
**כיסוי-אודיט מצטבר: 76/76 מסמכים קיבלו verdict** (44 top-level [סבב 2] + 32 תת-תיקייה [סבב 3]).
פעולות עדיין ממתינות לאישור: deprecate ל-PROTOCOL · K9 (אינדקס) · drift-guard ל-MASTER.
