# מאגר-הידע הישן `app/knowledge/` — אינדקס + החלטות-יסוד

> ההיסטוריה-המוסדית של מאמץ ה-Preact/dial (62 מסמכים). **מקור-משני** — מאונדקס כאן, לא מתועתק במלואו.

## מבנה (62 מסמכים)
| תיקייה | # | מה |
|---|---|---|
| `adr/` | 3 | החלטות-ארכיטקטורה (no-window · dial-pattern · README) |
| `inspections/` | 43 | `INSP-0001→0044` — היסטוריית-ביקורות (כל commit של menu/settings/dial) |
| `inspector/` | 4 | פרוטוקול-המפקח (checklist · loops · prompt · README) |
| root | 12 | dashboards (COURIER/STORE/SYSTEM_MANAGER/WORKER) · UI_ARCHITECTURE · ROLE_DRAWER_SYSTEM · IMPLEMENTATION_PROTOCOL(deprecated) · legacy-map · wip-menu-wiring · agent-board · reporting · README |
| `app/RULES.md` | 1 | R1–R9 — ה-spec ל"איך" |

## ⭐ החלטות-היסוד (ADR) — ה-WHY מאחורי ה-dial
- **ADR-001 · No-Window** (2026-05-20, Accepted): אוסר חלונות-מלאים (drawers/modals/sheets/overlays). הנמקה: משתמשי-אתר-בנייה (ידיים מלוכלכות/כפפות) — חלון חוסם מסך, גונב פוקוס, דורש סגירה. → R2/R3.
- **ADR-002 · Dial Pattern** (2026-05-20): החלופה — **dial** (טור-כפתורים קומפקטי שנפתח מתחת/מעל הכפתור-הראשי). → R3/R4/R5. **השורש של ה-dial pattern ב-Preact וב-Flutter** (דוחות 01/02).

## ⭐ R1–R9 (`app/RULES.md`) — ה-spec ל"איך" (verbatim)
| R | כלל |
|---|---|
| **R1** | חמשת הסמלים הראשיים לא זזים. בשום מצב. |
| **R2** | אין חלון מלא. backdrop קל לסימון מצב-פעיל בלבד. |
| **R3** | Dial — הצורה היחידה לפתיחת כלים. |
| **R4** | פריט dial = שני אלמנטים נפרדים (circle + label). |
| **R5** | בחירת tool. |
| **R6** | האב-טיפוס הוא ה-spec (ל"מה"). |
| **R7** | אסור להמציא תוכן. |
| **R8** | RTL — בית/חיפוש מימין, חנות/עגלה משמאל. |
| **R9** | שדות-טקסט = שורת-הקלדה inline, צמודה לעלה. |
> ⚠️ R1–R9 ב-`RULES.md` **שונים** מסיכום-ה-R ב-`CLAUDE.md` (שם R8="אין המצאה"). `RULES.md` הוא הקובע.

## dashboards + UI + history (root) — **specs עשירים (לא כותרות)**
- **`UI_ARCHITECTURE`** (1560 ש׳) — סדרת-spec UI/UX ב-**6 חלקים** (contractor + 4 פרסונות + role-drawer). מתעד מודל **5-FAB** (בית/חיפוש/BS-mode/תפריט/חשבון) + 4 סוגי-הצעות-חיפוש (nav/prod/acc/cat). תיאור-משני של אותו תוכן שלכדתי מהמקור (01–17).
- **`{COURIER,WORKER,STORE}_DASHBOARD`** (615–753 ש׳) — ⭐ **כן הוסיפו פרטים תפעוליים אמיתיים** שתיעדתי תמציתי-מדי מהמקור: courier job-model + vehicle-filter (→13) · worker task state-machine 5-מצבים (→07) · store order state-machine + held/resolved (→12). **נקראו, נשזרו.**
- **`SYSTEM_MANAGER_DASHBOARD`** (864 ש׳) — מבנה 4-הטאבים מאשר את המקור, אך ⚠️ **המספרים אידיאליים/מומצאים** (1,247 מוצרים · 156 קבלנים · ₪847K · +12%) — **לא** הנתונים-האמיתיים (4 הזמנות-דמו ב-SYS_ORDERS). לא ידע-נתונים.
- ⭐ **`legacy-map`** — port-map מדויק (לגאסי line-range → Preact file + status). ⚠️ **חלק מהספירות מיושנות** (ציין BUTTON_REGISTRY=176 בעוד המקור=350; store="stub" בעוד store.tsx=302 ש׳ כיום). מצוין ל-line-mapping, לא-מהימן-לגמרי לספירות.
- **`wip-menu-wiring`** — SSOT לחיווט-ההגדרות (~70 עלים, persist `bs.settings.v1`/`bs.profile.v1`).
- `IMPLEMENTATION_PROTOCOL` = **deprecated** (הנחה לבנות dashboards-as-views = הפרת R2).

## INSP — 43 ביקורות
`inspections/INSP-0001→0044` — כל commit של menu/settings/dial עבר Inspector subagent (typecheck + build + smoke 21/21 + דוח). `inspector/` = הפרוטוקול. ציר-הזמן: INSP-0009→0040 כולם GO.
**אופי (נדגם):** כל INSP = log-בנייה/QA (scope + טבלת-leaves verbatim + rule-checks R1–R8 + severity 0/0/0 + GO/NO-GO). מתעד את **בניית-ה-dial ב-Preact מול מבני-המקור** (citations ל-`index.html:NNNN`) — תהליך/QA, **לא ידע-מוצר חדש**. (למשל INSP-0040: Home→📐 PLAN_TYPES 4-leaves + 📦 stock-tabs 2-leaves.)

---
**הקשר:** זו ההיסטוריה-המוסדית של תרגום-אב-הטיפוס→Preact. ה-ADRs + R1–R9 הם ה-WHY מאחורי ה-dial pattern שתועד בדלתאות (01/02). מקור-משני — אינדקס, לא תעתוק.
