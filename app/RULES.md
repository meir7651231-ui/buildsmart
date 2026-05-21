# BuildSmart — חוקי עיצוב (Design Rules)

> מסמך זה הוא ה-spec הקובע ל**איך** מציגים. האב-טיפוס `../index.html` הוא ה-spec ל**מה** מציגים. בכל קונפליקט — האב-טיפוס מספק את התוכן, החוקים כאן מספקים את העטיפה.

> כל קוד שמופיע ב-`app/` חייב לעמוד בכל הכללים. חריגה היא **באג**, גם אם הקומפילציה עוברת.

---

## R1 · חמשת הסמלים הראשיים לא זזים. בשום מצב.

חמשת הכפתורים הבאים נשארים במיקום הקבוע שלהם בכל מצב של האפליקציה — כשמשהו אחר נפתח, נסגר, מתחלף, מתבטל. **אסור** להזיז אותם, להעלים אותם, להחביא אותם, או לשנות את גודלם.

| Slot | תפקיד | מיקום | רמז זיהוי |
|------|---|---|---|
| Top-right | זהות / BS Logo | `inset-inline-start: 14px; top: env(safe-area-inset-top)+12px` | פותח את ה-persona dial |
| Top-center | שם ה-persona | מרכז | טקסט בלבד, לא נלחץ |
| Top-left | עגלה | `inset-inline-end: 14px` | פותח עגלה |
| Bottom-left | תפריט FAB | `inset-inline-end: 18px; bottom: ...20px` | פותח menu speed-dial |
| Bottom-right | חיפוש FAB | `inset-inline-start: 18px; bottom: ...20px` | פותח search rail |

מותר רק:
- `:active` press-state (scale 0.92–0.95 לרגע הלחיצה ומיד חזרה)
- `z-index` להעלאה מעל backdrops זמניים — אבל ה-`bottom`/`top`/`inset` נשארים זהים

---

## R2 · אין חלון מלא. backdrop קל לסימון מצב פעיל בלבד.

### אסור
- drawer מלא-גובה שמחליק מהצד (translateX 100% → 0)
- bottom sheet / top sheet עם תוכן עיקרי
- modal / dialog שעוצר את ה-flow ומחייב פעולה
- `role="dialog" aria-modal="true"` על overlay של תפריטים/כלים
- backdrop כבד (אטימות מעל ~50% או blur מעל 4px) שחוסם הקשר ויזואלי

### מותר במפורש
- **product-sheet** — סקירת מוצר מפורטת, יוצא דופן יחיד מסוג "מסך משני".
- **search-panel + menu-speed-dial** — `backdrop` קל (אטימות 30-45%, blur עד 3px) שתפקידו **רק לסמן שהמצב פעיל ולקבל לחיצה-לסגירה**. אסור לחסום פעולות, אסור לתת תחושת "חלון נפרד".

### העיקרון
כשהאב-טיפוס פותח חלון מלא — אנחנו מתרגמים אותו ל-**dial**. ה-backdrop הקל הוא רק affordance לסגירה — לא ה-pattern עצמו.

---

## R3 · Dial — הצורה היחידה לפתיחת כלים

כשכפתור-על נלחץ, ה-tools שלו צצים כ-**dial**:

- **כיוון פתיחה** = הצד של הכפתור-על:
  - כפתור עליון (BS) → dial יורד מתחתיו
  - כפתור תחתון (search/menu FABs) → dial עולה מעליו
- **קו המגן** = הקיר בצד של הכפתור-על:
  - BS/search (ימני) → סמלים צמודים לקיר ימני
  - cart/menu (שמאלי) → סמלים צמודים לקיר שמאלי
- **אנימציה** = `dial-in` keyframe (opacity 0→1, translateY 8px → 0, stagger ~30ms)

אסור: רשימה מחוברת, scrim, full-screen drawer.

---

## R4 · פריט dial = שני אלמנטים נפרדים

כל פריט dial (ובכל sub-menu שלו) מורכב מ**שני** אלמנטים עם רווח ביניהם:

```
[עיגול-סמל]     [pill-תווית]
   48×48          padding 6×13
   var(--card)    var(--card)
   box-shadow     box-shadow נפרד
```

**אסור**: לארוז את הסמל והתווית בתוך אותו container/pill/row עם רקע יחיד. ה-`bsrow` של ה-drawer שעשיתי ב-`bs-panel.tsx` (שמחקנו) היה חריגה.

**מצב נבחר**: גם העיגול וגם ה-pill עוברים יחד ל-`background: var(--brand); color: #fff`. שניהם נדלקים, לא רק אחד.

---

## R5 · בחירת tool

כשמשתמש לוחץ tool מתוך dial פעיל:
1. שאר הכלים נעלמים מיד.
2. הנבחר נשאר ב-slot 1 (הסמוך לכפתור-על).
3. אם יש לו sub-menu — הוא נפתח **מעל הנבחר** (לכפתור תחתון) או **מתחתיו** (לכפתור עליון), באותו סגנון של R4.
4. לחיצה חוזרת על הנבחר → חזרה ל-dial המלא.
5. לחיצה חוזרת על הכפתור-על → סגירה מלאה.

---

## R6 · האב-טיפוס הוא ה-spec

כל מה שיש ב-`index.html` חייב להיות מיושם ב-`app/`. כולל:
- 5 ה-personas (קבלן/מנהל/חנות/שליח/עובד)
- כל המסכים של כל persona
- כל הזרימות (registration, login, checkout, וכו')
- כל הנתונים (TREES, VARIANTS, STORE_PRICING, TOOLS, SUPPLIER_STORES, וכו')

**אסור**:
- לחתוך פיצ'רים בלי הסכמה מפורשת
- להמציא תוכן שלא קיים באב-טיפוס (כמו "מצב כהה / שפה" שהוספתי ל-BS שלא ביקש אותם)
- להחליט "רק קבלן" כי "זה אב-טיפוס לפיתוח" — האב-טיפוס הוא ה-spec, לא ה-MVP

---

## R7 · אסור להמציא תוכן

לפני שמוסיפים כל פיצ'ר/טקסט/אופציה/כפתור — חייב לאמת שהוא קיים ב-`index.html`. אם לא קיים — אסור להוסיף בלי לשאול.

---

## R8 · RTL — סמלי בית/חיפוש בצד ימני, סמלי חנות/עגלה בצד שמאלי

זהו ה-mapping לחמשת הכפתורים-העל. גם רכיבים אחרים מצייתים לעיקרון:
- פעולות "זהות/חיפוש" → מסתדרות ימינה
- פעולות "מסחר/עגלה/חנות" → מסתדרות שמאלה

---

# פרוטוקול הביקורת (Verification Protocol)

לפני שאני (Claude) טוען "סיימתי" על feature, אני **חייב** להריץ ביקורת. הביקורת היא סוכן Explore עם ה-prompt למטה. אם הסוכן חוזר עם חריגה — אסור לקמט/לדחוף — חייב לתקן.

## מתי להריץ
- אחרי כל שינוי משמעותי ב-`app/src/`
- לפני כל `git commit`
- אם משנים את אחד מהקבצים הבאים: `floating-header.tsx`, `fabs.tsx`, `bs-*.tsx`, `search/*.tsx`, `menu-*.tsx`, `app.tsx`, `global.css`

## תבנית prompt לסוכן (העתק כפי שהוא)

```
Audit the BuildSmart app at /home/user/buildsmart/app/ for compliance
with RULES.md.

Read /home/user/buildsmart/app/RULES.md to understand the rules.

Then audit the following against every rule:
- All TSX files under src/components/
- All TSX files under src/views/
- src/app.tsx
- src/styles/global.css
- Recent diff: `git -C /home/user/buildsmart diff HEAD~1 -- app/src`

For each rule R1–R8, report:
- PASS / FAIL
- If FAIL: specific file:line + verbatim quote of the violating code
- If FAIL: exact text of which rule clause was broken

Return at the end a single line: "VERDICT: PASS" or "VERDICT: FAIL (N
violations)".

Be strict. Half-violations count. No leniency for "it might be OK".
```

## מה לעשות עם הפלט

- `VERDICT: PASS` → להמשיך ל-commit.
- `VERDICT: FAIL` → לתקן כל חריגה, להריץ שוב, ורק אחרי PASS לקמט.

**אסור** ל-commit עם FAIL בלי לציין מפורשות בהודעת ה-commit איזה חוק נשבר ולמה (לכל היותר חריגה זמנית מתועדת).
