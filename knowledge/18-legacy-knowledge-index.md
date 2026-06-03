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

## dashboards + UI + history (root)
`UI_ARCHITECTURE` · `ROLE_DRAWER_SYSTEM` (5 personas/RBAC/enterRole) · `{COURIER,STORE,SYSTEM_MANAGER,WORKER}_DASHBOARD` (spec/פרסונה) · `legacy-map` (לגאסי→Preact) · `wip-menu-wiring` (מה בנוי). `IMPLEMENTATION_PROTOCOL` = **deprecated** (הנחה לבנות dashboards-as-views = הפרת R2).

## INSP — 43 ביקורות
`inspections/INSP-0001→0044` — כל commit של menu/settings/dial עבר Inspector subagent (typecheck + build + smoke 21/21 + דוח). `inspector/` = הפרוטוקול. ציר-הזמן: INSP-0009→0040 כולם GO.

---
**הקשר:** זו ההיסטוריה-המוסדית של תרגום-אב-הטיפוס→Preact. ה-ADRs + R1–R9 הם ה-WHY מאחורי ה-dial pattern שתועד בדלתאות (01/02). מקור-משני — אינדקס, לא תעתוק.
