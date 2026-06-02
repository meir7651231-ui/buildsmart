# ACTION_PLAN — מה עוד לא בוצע (live backlog)

> נכון ל-**v5.78** · ענף `claude/whats-happening-LyY9G` · **דחוף עד v5.77**
> (בנצי #1 phases 1–3 + Huliot P1–P9 ממוזגים על origin); **v5.78 (בנצי #6) מקומי**.
> זהו האינדקס של העבודה הפתוחה. (סטטוס חי מפורט: `STATUS.md`.)

מקרא: 🔴 חוסם / דורש הכרעת משתמש · 🟧 פתוח · 🟩 בוצע (לעיון) · ⛔ חסום על דאטה/שרת.

---

## 0 · 🟩 הוכרע — זרימת הניווט לחלוקה (option 2, דרך ה-finder)

**המשתמש בחר option 2** ומומש במלואו (v5.69–v5.71, דחוף): מחלקה → ה-finder המסונן,
וכל סקשני ה-browse (בית · עץ · חיפוש · קטגוריות · הכל · מועדפים · עץ חכם) מסוננים
ל-WaterSystem. ראה `STATUS.md`. הסעיף ההיסטורי למטה נשמר לעיון בלבד.

<details><summary>הקשר היסטורי (לפני ההכרעה)</summary>

**השאלה שלך:** _"יש הכל / בית / תכנון חיבור / חיפושים אחרונים — דרך איפה הניווט שלך ולמה?"_
ו: _"למה לא דרך מחלקות ואז בית, למה קטגוריות?"_

**מה בנוי כרגע (v5.59):** מחלקה חיה → קובע `catalogSystemFilterProvider` → פותח
**עץ קטגוריות מסונן** ישירות (`kDepartmentTreeRoot`), עוקף את ה-section-chips
(הכל / בית / תכנון חיבור / חיפושים אחרונים).

**שתי האפשרויות שצריך להכריע ביניהן:**

| | אופציה 1 — *tree-drill* (הנוכחי) | אופציה 2 — *finder עם chips מסוננים* |
|---|---|---|
| כניסה | מחלקה → ישר לעץ הקטגוריות המסונן | מחלקה → ה-finder הרגיל, אבל כל ה-sections (הכל/בית/חיפושים) מסוננים למערכת |
| יתרון | ממוקד, פחות הסחות | משמר את כל כלי ה-finder הקיימים שבנינו |
| חיסרון | עוקף chips קיימים שהשקענו בהם | יותר עבודת חיווט — לסנן כל section בנפרד |

**→ צריך תשובה ממך לפני שממשיכים.** עד אז הקוד נשאר על אופציה 1 (ירוק, בדוק).

</details>

---

## 1 · בנצי — דרישות בעל המוצר

| # | דרישה | סטטוס | פירוט / היכן |
|---|--------|--------|---------------|
| 1 | חלוקת מים נקיים / שפכים | 🟩 **בוצע מלא + דחוף (v5.69–v5.71)** | option 2 דרך ה-finder; כל סקשני ה-browse מסוננים (`logic/system_division.dart`). |
| 2 | מסך מחלקות (9) | 🟩 בוצע (v5.57) | `departments_screen.dart` — 2 חיות + 7 placeholder |
| 3 | bottom-nav 4 טאבים | 🟩 בוצע | מחלקות / צ'אטים / התראות / חנות — `home_shell.dart` |
| 4 | popup משלוח ב-checkout | 🟧 פתוח | יעד: `store_screen.dart` checkout flow. צריך טקסט verbatim מהמקור (Preact) + שדות (כתובת/חלון זמן). אין דאטת מחיר-משלוח → להציג כ-UI, לא לחשב. |
| 5 | מוצרים ברצף per-סניף | 🟧 פתוח | תצוגת מוצרים סדרתית לפי סניף. צריך הבהרה: מהו "סניף" כאן (ספק? חנות?) ומה מקור הסדר. |
| 6 | autocomplete לחיפוש | 🟩 **בוצע (v5.78, מקומי)** | `searchSuggestions` → `_SearchSuggestions` chip-row; קטגוריות מסונני-מערכת, cap 6. `search_suggestions_test`. |
| … | "עוד יגיע" | 🟧 ממתין | בנצי ציין שיגיעו דרישות נוספות. |

---

## 2 · ניקוי / חוב טכני (מהעבודה הנוכחית)

- 🟩 **הוסר sysOpt כפול מגיליון הפילטרים (v5.71, פאזה 3)** — המערכת מגיעה רק מהמחלקות
  + סרגל-scope (source-of-truth אחד). נשאר רק פילטר התמונה.
- 🟧 **7 מחלקות placeholder ללא דאטה** — חשמל / חומרי בניין / כלי עבודה ידני / חשמלי /
  צבע / גבס ופרופילים / אספקה טכנית. כרגע toast "בקרוב" (R8 — אין דאטה, אין המצאה).
  פתיחתן דורשת מקור קטלוג אמיתי לכל מחלקה.

---

## 3 · ליטוש (POLISH) — פאזות B–J

הצינור ל-screenshots אמיתי (real-app, local-canvaskit + Playwright) **נבנה ועובד**
(`scripts/polish_shot.sh` + `.js`, commit b7bd536) — זה היה החוסם לפאזות B–F. נותר:

- 🟧 **B–F** — סבבי ליטוש ויזואלי (spacing / typography / color / motion / states)
  לפי `POLISH_LOG.md` backlog. עכשיו אפשר לאמת לפני/אחרי ב-screenshot.
- 🟧 **G–J** — נגישות, RTL edge-cases, large-text, dark-mode contrast.
- מקור האמת לליטוש: `POLISH_LOG.md` (קו-בסיס + backlog מעוגן B–J).

---

## 4 · פרוטוקול / CI (חלק בידי הפרוטוקוליסט — לא אני)

- 🟧 **protocol-enforce.yml** — ה-workflow מתקין Flutter 3.29.0 (Dart 3.7.0) אבל
  `pubspec` דורש `sdk: ^3.7.2` → `pub get` נכשל ב-CI. **תוקן מקומית** ע"י 3.29.3.
  הצעה הוגשה לפרוטוקוליסט (זה קובץ שלו). דורש אישורו.
- 🟧 **Phase K — SUBMIT items** (סגירת אודיט הידע): deprecate `PROTOCOL.md` הישן,
  הוספת MASTER drift-guard. ממתין לפרוטוקוליסט (`PROTOCOL_AUDIT_PLAN.md`).
- 🟩 Phase K rounds 1–3 + README-as-index (27→0 יתומים) — בוצע ודחוף קודם.

---

## 5 · דחיפה — 9 commits מקומיים ממתינים

```
53a078d feat(catalog): חלוקת מים נקיים / שפכים דרך מחלקות (v5.59)   ← הנוכחי
ceca667 feat(catalog): חלוקת מים נקיים / שפכים בגיליון פילטרים (v5.58)
b9ad7ae feat(home): מסך מחלקות כדף-הבית (v5.57)
9eb505e docs(polish): proto comparison
b7bd536 feat(polish): headless screenshot pipeline
9c87f6d refactor(widgets): tokenize dial stagger + toast
4820ff0 fix(search): microcopy 'הפעל מצלמה' (v5.56)
6b9d14b polish(dial): tokenize DialRow padding
18a2ac4 docs(polish): POLISH_LOG.md (פאזה A)
```

🚫 **אין push ללא "תדחוף" מפורש.** הענף diverged מ-origin (9 מקומי מול 5 remote) —
דחיפה תדרוש כנראה pull/merge או force-with-lease; להחליט ברגע ה"תדחוף".

---

## 6 · איך להמשיך (resume — הצעד הבא)

1. **קבל הכרעה בסעיף 0** (זרימת ניווט) — זה פותח את סעיפים 1.1 ו-2.
2. אם אופציה 1 נשארת → הסר sysOpt כפול (סעיף 2) → bump → commit.
3. אחרת → חווט סינון-מערכת לכל section ב-finder.
4. המשך לבנצי #4 (popup משלוח) — הכי מוגדר מבין הפתוחים; צריך טקסט verbatim.
5. כל commit: 6 כללים (מצא → helper → בדיקה → analyze 0 → test 986 → build) +
   bump גרסה (home_shell + STATUS) + WIRING + session_plan.

> **סיכון ephemeral:** המכולה זמנית — כל עבודה לא-מחויבת אובדת. לכן חויב מקומית
> הכל (v5.59 ירוק) למרות שלא דוחפים. תוכנית זו = נקודת-המשך בטוחה.
