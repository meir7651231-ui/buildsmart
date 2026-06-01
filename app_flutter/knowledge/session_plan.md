# Session Plan — חלוקת קטלוג מים נקיים / שפכים דרך מחלקות (בנצי #1+#2)

Owner: this session
Scope: departments_screen.dart + catalog_screen.dart — חלוקת מערכת (WaterSystem) דרך כניסת מחלקה, לא דרך גיליון פילטרים. אסור לגעת בלוגיקת BFS / install_engine.

Style: department tile → set system filter → filtered category tree → verify (screenshot) → test → commit.

## ⚠️ כללי בטיחות לסשן זה
- **אין push** ללא "תדחוף" מפורש
- **אין המצאה (R8)** — עברית verbatim מהמקור; אין spec → PPR=נקיים, השאר=שפכים (הכרעת המשתמש)
- **כל שלב** = flutter analyze (0 errors) + flutter test (986) לפני commit
- visual verification = screenshot של שתי הכניסות (אינסטלציה / ברזים)

---

## מה נבנה (option 2 — דומיננטיות + מתקנים בשניהם)

1. **`departments_screen.dart`** — `homeDepartmentProvider` + רשת 9 מחלקות.
   אינסטלציה→`WaterSystem.drainage` · ברזים וסניטריים→`WaterSystem.supply` · 7 placeholders ("בקרוב").
2. **`catalog_screen.dart`** — `catalogSystemFilterProvider` + `productDivisionSystems` (spec.endSystems → PPR=supply → שאר=drainage) + `filterBySystem` + `nodeHasSystem` (מתקנים=שניהם; אחרת מערכת דומיננטית) + `kDepartmentTreeRoot`. עץ הקטגוריות, הספירות והתיאורים מסוננים לפי המערכת.
3. **`home_shell.dart`** — מחלקות = טאב 0; ניווט reset מאפס את 3 ה-providers.

## אימות ויזואלי (screenshot)
- `/tmp/polish/supply.png` — ברזים → מים נקיים (PPR נכלל, ~1257 מוצרים)
- `/tmp/polish/drainage.png` — אינסטלציה → שפכים (PPR לא נכלל, ~455)
- אסלות: "מיכלי הדחה" תחת נקיים · "מושבי אסלה · חיבורי אסלה" תחת שפכים ✅

## בדיקות
- 986/986 ✅ (תיקון: import חסר ל-departments_screen.dart ב-robustness_test → גרר "compiler exited unexpectedly" ב-widget_test).

---

## פתוח (→ ACTION_PLAN.md)
- הכרעת זרימת ניווט: tree-drill מסונן מול finder עם section-chips מסוננים (שאלת המשתמש "דרך איפה הניוט שלך ולמה")
- הסרת sysOpt כפול מגיליון הפילטרים (ceca667 — מיותר עכשיו)
- בנצי #4 (popup משלוח) · #5 (מוצרים רצף per-סניף) · #6 (autocomplete חיפוש)
- מילוי דאטה ל-7 המחלקות ה-placeholder
