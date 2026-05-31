# יומן בעיות-פתרון-מניעה

> **קובץ זה נאכף אוטומטית.** כל בעיה שנפתרה חייבת רשומה כאן.
> ה-pre-commit חוסם שמירה אם:
> 1. הייתה בעיה ב-commit הקודם והיא נפתרה — אבל לא תועדה כאן (שער 101)
> 2. אנטי-פטרן שתועד כאן חוזר בקוד החדש (שער 102)

## פורמט רשומה — חובה למלא את כל הסעיפים

```
## YYYY-MM-DD · [כותרת קצרה]
### א — הבעיה
[מה קרה. שורת השגיאה המדויקת. באיזה שער נתפס.]

### ב — הפתרון
[הפקודה/השינוי שעבד]

### ג — כלל המניעה (יישום להבא)
ANTIPATTERN-EXAMPLE: [regex שמזהה את הבעיה בקוד עתידי]
RULE-EXAMPLE: [משפט אחד בעברית — מה לעשות אחרת]
```

> ⚠️ ברשומה האמיתית — השתמש ב-`ANTIPATTERN:` (לא ANTIPATTERN-EXAMPLE)
> ה-template למעלה הוא רק דוגמה; ה-regex נקלט רק משורות שמתחילות ב-`ANTIPATTERN:` בדיוק.

---

## רשומות

<!-- הוסף רשומה חדשה כאן אחרי כל בעיה שנפתרה -->

## 2026-05-31 · באג לדוגמה — שימוש ב-print במקום debugPrint
### א — הבעיה
שער 48 חסם commit כי היה `print()` בקוד production.

### ב — הפתרון
החלפת `print(x)` ב-`debugPrint(x)`.

### ג — כלל המניעה
ANTIPATTERN: ^\s*print\(
RULE: בקוד production השתמש ב-debugPrint, לא ב-print

---

## 2026-05-31 · #34 — Edit/Write עוקפים את PreToolUse
### א — הבעיה
PreToolUse hook חסם רק `Bash`. מודל יכל ל-Edit את `.githooks/pre-commit`,
את `.git/config`, או את `.claude/settings.json` ולעקוף את כל ההגנות.

### ב — הפתרון
1. הוספת `matcher: "Bash|Edit|Write|NotebookEdit"` ב-settings.json
2. הוספת רשימת קבצים מוגנים ב-pre-tool.sh
3. אישור עקיפה דורש קובץ `.allow_protocol_edit` בריפו

### ג — כלל המניעה
ANTIPATTERN: matcher.*[\"\']Bash[\"\']\s*$
RULE: PreToolUse matcher חייב לכלול את כל הכלים שכותבים — Bash וגם Edit/Write/NotebookEdit

---

## 2026-05-31 · #1-#5 — וקטורי עקיפה נוספים
### א — הבעיה
PreToolUse חסם רק patterns רדודים. ניתן היה לעקוף ב:
- `git -c core.hooksPath=/dev/null commit`
- `--force-with-lease` / `--force-if-includes`
- `> .githooks/pre-commit` (truncate)
- `mv .githooks /tmp` / `find -delete` / `unlink`
- aliases: `git config alias.x 'commit --no-verify'`

### ב — הפתרון
הוספת בדיקות ב-pre-tool.sh:
- `git -c core.hooksPath` / `git config core.hooksPath` שאינו .githooks
- כל push עם force בכל וריאציה
- מחיקות עקיפות: rm/mv/find/unlink/redirect/cp/sed-i
- חסימת aliases מסוכנים
- חסימת eval של git

### ג — כלל המניעה
ANTIPATTERN: core\.hooksPath\s*=\s*[^.]
RULE: שינוי core.hooksPath חייב להיות ל-.githooks בדיוק

---

## 2026-05-31 · #6 — gate 32 לא בדק exit code
### א — הבעיה
gate 32 בדק רק string "FAILED" בפלט של flutter test. אם flutter קרס
(OOM/timeout/missing dep) — אין FAILED והgate עובר בכזב.

### ב — הפתרון
הוספת `TEST_EXIT=$?` ובדיקה `if [[ $TEST_EXIT -ne 0 ]]`.

### ג — כלל המניעה
ANTIPATTERN: TEST_OUT=\$\([^)]+\)\s*$
RULE: כל פלט של command חייב להיות מלווה ב-EXIT=$? אם משתמשים בexit code

---

## 2026-05-31 · #10 — gate 33 חיפש pattern שלא קיים
### א — הבעיה
gate 33 חיפש `[0-9]+ tests` ב-STATUS.md, אבל הניסוח שם הוא
"102 test files" — לא "X tests".

### ב — הפתרון
שיניתי ל-`[0-9]+\+ tests|[0-9]+ tests pass`.

### ג — כלל המניעה
ANTIPATTERN: grep -oE "\[0-9\]\+ tests"\s
RULE: לפני שמשתמשים ב-grep pattern — לוודא שהוא תופס את הקובץ האמיתי

---

## 2026-05-31 · #28 — SKU dup רק ב-diff
### א — הבעיה
gate 86 בדק כפילויות רק ב-staged diff. SKU שכפל קיים בקובץ אבל לא בdiff
— לא נתפס.

### ב — הפתרון
בדיקת כל הקובץ אחרי השינוי: `grep -oE "sku: '[^']+'" file | sort | uniq -d`.

### ג — כלל המניעה
ANTIPATTERN: git diff --cached.*\| sort \| uniq -d
RULE: בדיקת ייחודיות חייבת לרוץ על הקובץ המלא, לא רק על השינוי

---

## 2026-05-31 · #19 — tiered execution
### א — הבעיה
כל commit הריץ flutter analyze+test+build (3-5 דק'). גם commits של
תיעוד בלבד שילמו את המחיר המלא.

### ב — הפתרון
דילוג על שערים 31-34 אם אין שינוי `*.dart|*.yaml`.
תיעוד בלבד = ~5 שניות במקום 3-5 דק'.

### ג — כלל המניעה
ANTIPATTERN: flutter (test|analyze|build).*--no-pub
RULE: שערים יקרים חייבים gate מקדים שבודק רלוונטיות

---

## 2026-05-31 · #26 — אין commit-msg hook
### א — הבעיה
`git commit -m "wip"` או `git commit -m ""` עברו ללא בדיקה.

### ב — הפתרון
יצרתי `.githooks/commit-msg`:
- מינימום 15 תווים
- חסימת trash patterns (wip/test/asdf/...)
- אזהרה לconventional commits

### ג — כלל המניעה
ANTIPATTERN: ^(wip|test|asdf|tmp)$
RULE: הודעת commit חייבת לתאר את השינוי, לא רק מילה גנרית
