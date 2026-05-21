# Inspector Checklist — by stage

Each item has an **ID**, a Hebrew description, and the **severity** to
report if it fails.

---

## Foundation — schemas, types, data, store

| ID | Check | Severity if failed |
|---|---|---|
| FND-01 | schemas ב-TypeScript תקפים — `npm run typecheck` PASS | CRITICAL |
| FND-02 | אין ID כפול ב-`PRODUCTS` | CRITICAL |
| FND-03 | אין ID כפול ב-`CATEGORIES` | CRITICAL |
| FND-04 | אין שם פונקציה כפול ב-`BUTTON_REGISTRY` | MAJOR |
| FND-05 | `PRODUCTS / CATEGORIES / VARIANTS / SUPPLIERS` לא ריקים | CRITICAL |
| FND-06 | כל SKU ב-`STORE_PRICING` קיים גם ב-`VARIANTS.opts[].sku` | MAJOR |
| FND-07 | כל מפתח ב-`VARIANTS` שייך למוצר ב-`PRODUCTS` | MAJOR |
| FND-08 | signals חדשים מאותחלים עם ערך ברירת-מחדל מפורש | MINOR |
| FND-09 | localStorage keys משתמשים בתבנית `bs.{thing}.v{N}` | MINOR |

---

## Frame — components, layout, visual rules

| ID | Check | Severity |
|---|---|---|
| FRM-01 (R1) | 5 הסמלים המרחפים שומרים מיקום קבוע — אין שינוי position-shifting class בכל מצב | CRITICAL |
| FRM-02 (R2) | אין `<div>` חדש עם `position: fixed; inset: 0` שמכסה את המסך, מעבר ל-product-sheet / search-panel / menu-speed-dial / bs-dial-scrim הקיימים | CRITICAL |
| FRM-03 (R3) | tools פתוחים כ-dial — אין list/drawer חדש | CRITICAL |
| FRM-04 (R4) | פריט dial = `circle` נפרד + `label` pill נפרד עם gap — לא container מאוחד | CRITICAL |
| FRM-05 (R5) | בבחירת tool: השאר מתעלמים, הנבחר נשאר ב-slot 1, sub-menu בסגנון של הדיאל ההורה | MAJOR |
| FRM-06 (R2 exception) | backdrops קיימים: opacity ≤ 0.45 ו-blur ≤ 3px | MAJOR |
| FRM-07 | persona views רנדור-בלי-קריסה — `testTabs` מחזיר PASS | CRITICAL |

---

## Wiring — handlers, signals, side-effects

| ID | Check | Severity |
|---|---|---|
| WIR-01 | handlers בבדיקות התנהגותיות משחזרים state אחרי mutation (`save → call → assert → restore`) | MAJOR |
| WIR-02 | `cartCount.value === sum(cart.value.qty)` — אינווריאנט שמירה | CRITICAL |
| WIR-03 | אין **infinite useEffect loop** — ראה `loops.md` patterns | CRITICAL |
| WIR-04 | אין **signal mutation inside effect that depends on the same signal** — ראה `loops.md` | CRITICAL |
| WIR-05 | אין **state setter ב-render body** של component (ללא effect/handler) | CRITICAL |
| WIR-06 | כל interactive button חדש נרשם ב-`BUTTON_REGISTRY` | MAJOR |
| WIR-07 | event handlers הם references יציבים — לא inline functions בלולאות גדולות | MINOR |

---

## Finish — CSS, RTL, accessibility

| ID | Check | Severity |
|---|---|---|
| FIN-01 (R8) | סמלי בית/חיפוש בצד ימני (`inset-inline-start` ב-RTL); סמלי חנות/עגלה בצד שמאלי (`inset-inline-end`) | MAJOR |
| FIN-02 | `safe-area-inset-top` / `safe-area-inset-bottom` מכובדים בכל element קבוע בקצה | MAJOR |
| FIN-03 | `aria-label` קיים בעברית לכל כפתור ללא טקסט גלוי | MAJOR |
| FIN-04 | `aria-expanded` קיים על toggles (BS, menu, search) | MINOR |
| FIN-05 | touch targets ≥ 44×44 px | MAJOR |
| FIN-06 | אין `outline: none` בלי `:focus-visible` שמחזיר אינדיקציה | MAJOR |
| FIN-07 | צבעי טקסט עומדים ב-WCAG AA ניגודיות (4.5:1 לטקסט רגיל) | MINOR |

---

## Operations — build / tests / regression / process-loop

| ID | Check | Severity |
|---|---|---|
| OPS-01 | `npm run typecheck` רץ ללא שגיאות | CRITICAL |
| OPS-02 | `npm run build` רץ ללא שגיאות | CRITICAL |
| OPS-03 | Regression suite (run inside the manager view OR via the runner) — אין FAIL | CRITICAL |
| OPS-04 | commit message מצטט `@rule` / `@adr` / `@legacy` כשרלוונטי | MINOR |
| OPS-05 | אם הוסיפו ADR חדש — קיים גם רישום ב-`spec.json` (כשהוא יבנה) | MAJOR |
| OPS-06 | **process-loop**: אותה finding ID לא חוזרת ב-2+ מתוך 3 דוחות אחרונים. ראה `prompt.md` "Stuck loop" — חובה לבדוק | CRITICAL |
