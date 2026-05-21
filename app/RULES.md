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

# פרוטוקול מפקח בנייה (Building Inspector Protocol)

**מחליף את פרוטוקול הביקורת הישן** (PASS/FAIL בצ'אט). המפקח עצמאי,
מובנה לפי 5 שלבי בנייה, עם רמות חומרה וסמכות חסימה.

## נקודות הביקורת

| שלב | מתי המפקח רץ |
|---|---|
| **foundation** | שינוי ב-`src/store/`, `src/data/`, `src/test/types.ts` |
| **frame** | שינוי ב-`src/components/`, `src/views/`, `src/app.tsx` |
| **wiring** | handlers / signal mutations / effects חדשים |
| **finish** | שינוי ב-`src/styles/` / classes / ARIA |
| **operations** | תמיד — לפני כל `git commit` |

## איך להפעיל

1. בחר shtage רלוונטי (אחד או יותר לפי ה-diff).
2. הפעל Explore agent עם ה-prompt ב-`knowledge/inspector/prompt.md`,
   החלף `{STAGE}` בשלב.
3. שמור את הדוח המוחזר ל-`knowledge/inspections/INSP-NNNN-{stage}-{date}.md`.
4. פעל לפי ה-VERDICT.

## רמות חומרה והשלכות

| חומרה | פעולה |
|---|---|
| **CRITICAL** | commit חסום אוטומטית. תקן או כתוב ADR. |
| **MAJOR** | דורש אישור הבעלים. אסור להמשיך בלי. |
| **MINOR** | מתועד בלבד. לא חוסם. |

## זיהוי לולאות (חובה)

המפקח בודק **בכל ריצה**:

### Code loops
דפוסים ב-`knowledge/inspector/loops.md` (L-01 עד L-08):
- `useEffect` עם setter ושדה תלות סותר
- mutation של signal בתוך effect שמאזין לאותו signal
- state setter ב-render body
- `while(true)` / recursion ללא base case

### Process loop (stuck-loop)
המפקח קורא את **3 הדוחות האחרונים** מ-`knowledge/inspections/`.
אם אותה finding ID מופיעה ב-2+ מהם:
- הממצא מוקפץ ל-**CRITICAL**
- מתויג `stuck-loop`
- הדוח חוזר `VERDICT: NO-GO (stuck loop)` ומתעצר.
- **Claude מפסיק לנסות לתקן** ופונה לבעלים להחלטה.

## מה לעשות עם הפלט

| VERDICT | פעולה |
|---|---|
| `GO` | המשך ל-`git commit` |
| `NO-GO` ללא stuck-loop | תקן CRITICAL/MAJOR, הרץ מחדש |
| `NO-GO (stuck loop)` | **עצור.** דווח לבעלים. אסור ניסיון נוסף. |

## אסור

- לדחוף עם CRITICAL בלי תיקון
- לדחוף עם MAJOR בלי אישור הבעלים מפורש
- להריץ מחדש אחרי stuck-loop בלי הוראה מהבעלים
- לערוך/למחוק דוחות ישנים ב-`inspections/` — הם מקור-האמת ההיסטורי

## הקשר למסמכים אחרים

- `knowledge/inspector/prompt.md` — ה-prompt הקבוע לסוכן (replace `{STAGE}`)
- `knowledge/inspector/checklist.md` — כל ה-checklists לפי שלב (FND/FRM/WIR/FIN/OPS)
- `knowledge/inspector/loops.md` — דפוסי לולאה מפורטים
- `knowledge/inspections/` — ארכיון דוחות (immutable, ב-git)
