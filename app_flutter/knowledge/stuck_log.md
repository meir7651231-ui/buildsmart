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

---

## 2026-05-31 · #11 — shell injection ב-gate 103
### א — הבעיה
gate 103 העביר ANTIPATTERN ל-`grep -E "$pattern"` ללא וידוא.
פטרן עם `$(cmd)` או backtick יורץ כshell command.

### ב — הפתרון
בדיקה מקדימה: `if echo "$pattern" | grep -qE '\$\(|\`|\\$\{'` — דילוג + warning.
שימוש ב-`grep -E -- "$pattern"` עם `--` למניעת flag injection.

### ג — כלל המניעה
ANTIPATTERN: grep -E "\$[a-z]+"
RULE: פטרן ממקור חיצוני חייב לעבור validation לפני שימוש ב-grep -E

---

## 2026-05-31 · #16 — gate 52 secrets false-positive
### א — הבעיה
`final passwordRegex = RegExp(r"^[a-z]{8,}$")` — מילה "password" + string ארוך → flag שגוי.

### ב — הפתרון
1. דרשנו string של 16+ תווים (לא 8)
2. צמצמנו לתווי secret אמיתי: `[A-Za-z0-9+/_-]`
3. החרגנו: regex/pattern/kSecret/kToken/.test(/expect(

### ג — כלל המניעה
ANTIPATTERN: kSecret\w*\s*=\s*compute
RULE: שמות משתנים שמכילים Secret/Token/Password חייבים להיות kPrefix או להכיל "regex"

---

## 2026-05-31 · #29 — paths קשיחים
### א — הבעיה
`export PATH="/home/user/flutter/bin"` עבד רק במחשב אחד.

### ב — הפתרון
לולאה על מועמדים: `/home/user/flutter/bin`, `/c/flutter/bin`, `$HOME/flutter/bin`, `/usr/local/flutter/bin`.
שגיאה ברורה אם flutter לא נמצא.

### ג — כלל המניעה
ANTIPATTERN: export PATH=.*[/]home[/]user
RULE: paths קשיחים אסורים — חפש דינמית

---

## 2026-05-31 · לקחים מ-SIZE_FILTER_PROTOCOL (session מקביל)
### א — הבעיה
ה-session המקביל פיתח 16 תיקונים על מסנן גודל ב-finder. בסוף הוא כתב פרוטוקול
544 שורות עם 25 לקחים — אבל לא היה לי דרך לאמץ אותם אוטומטית.

### ב — הפתרון
1. יצרתי `CARRY_FORWARD.md` — לקחים קבועים חוצי-sessions
2. יצרתי `SESSION_PLAN_TEMPLATE.md` — מבנה חובה
3. הוספתי שערים 106-110 לפרוטוקול
4. שער 107 דורש visual log לשינויי UI

### ג — כללי המניעה
ANTIPATTERN: ^Owner:\s*$
RULE: כל session_plan חייב שורת Owner: + Scope: בראש
ANTIPATTERN: lib/screens/.*\.dart.*\+\+\+.*no visual
RULE: שינוי UI דורש screenshot או visual_log entry

---

## 2026-05-31 · LL-04 (מ-size protocol) — 2 pipelines, 2 display forms
### א — הבעיה
Finder הציג `1¼"` והכרטיס הציג `1.25"` — אותו מוצר, אותו גודל פיזי, שתי צורות
ויזואליות. unit tests היו ירוקות, רק העין תפסה.

### ב — הפתרון
helper משותף `displaySizeLabel()` שנקרא משתי הpipelines.

### ג — כללי המניעה
ANTIPATTERN: prettyInch\([a-z]+\).*finder
RULE: כל פונקציית display של chip חייבת להיקרא משני הצדדים — finder + card

---

## 2026-05-31 · LL-05 (מ-size protocol) — "falls back" ≠ "union"
### א — הבעיה
`_productSizeTokens` היה name-or-dims (else-if). פייפ שמכיל אורך בשם וקוטר ב-dims —
רק האחד הופיע.

### ב — הפתרון
union — שני המקורות תורמים. הdedup והגrouping עושים את העבודה.

### ג — כללי המניעה
ANTIPATTERN: parseSizeTokens.*\?\?.*tokensFromDims
RULE: כששני מקורות מתארים צירים אורתוגונליים — union. רק כשהם substitutes — fallback.

---

## 2026-05-31 · LL-08 (מ-size protocol) — \\d+ vs \\d+(?:\\.\\d+)?
### א — הבעיה
`'\d+×\d+'` חתך עשרוני (`20×2.8` → `20×2`) כי הregex לא קיבל נקודה.

### ב — הפתרון
תמיד `\d+(?:\.\d+)?` בדומיין שבו עשרוניים אפשריים.

### ג — כללי המניעה
ANTIPATTERN: \\\\d\\+×\\\\d\\+
RULE: regex על מספרים בדומיין הנדסי חייב לקבל נקודה עשרונית

---

## 2026-05-31 · LL-14 (מ-size protocol) — bidi flips silent
### א — הבעיה
Filter chip הציג `60×40`, card chip הציג `40×60`. data היה זהה — RTL paragraph
direction רק היפך את הdisplay.

### ב — הפתרון
`textDirection: label.contains(RegExp(r'\d')) ? LTR : null` על כל Text widget
שעלול להכיל digits בעברית.

### ג — כללי המניעה
NOTE: pattern קיים אבל לא נאכף אוטומטית — יוצר too-many-positives ב-Text widgets שכבר תחת LTR ancestor. נשמר כ-manual review point ב-CARRY_FORWARD לקח #10.
RULE: text widget שהמחרוזת בתוכו מכילה גם עברית וגם מספרים → textDirection ltr חובה

---

## 2026-05-31 · #14, #15, #18, #9, #23, #25 — שיפורי דיוק
### א — הבעיות
- gate 26: תפס שמות `_tests.dart` גם בlib/ (לא רק test/)
- gate 48: print() pattern רדוד — תפס רק תחילת שורה
- gate 60: לא הבחין בין dependencies ל-dev_dependencies
- gate 81: hash check רק מול disk, לא מול HEAD
- pre-push: בודק רק fast-forward — לא ענף יעד או הודעה
- אין הוראה ל-branch protection ב-GitHub UI

### ב — הפתרונות
- gate 26: `^app_flutter/test/.*_tests\.dart$` בלבד
- gate 48: pattern `(^|[^a-zA-Z0-9_])print\s*\(` + exclude debugPrint/comments/strings
- gate 60: awk מבדיל בין dependencies ו-dev_dependencies
- gate 81: hash גם מול `git show HEAD:.githooks/pre-commit`
- pre-push: חוסם main/master ללא `.allow_push_main` + מוודא commit messages
- צרתי `knowledge/PROTOCOL_ENFORCEMENT.md` עם הוראות branch protection

### ג — כלל המניעה
ANTIPATTERN: pubspec.yaml.*grep.*"\^"
RULE: בדיקת dependencies חייבת להבחין dev מ-prod
ANTIPATTERN: sha256sum.*\.git/hooks.*compare
RULE: integrity check חייב להיות גם מול HEAD, לא רק disk

---

## 2026-05-31 · gate 110 — awk range pattern סוגר על אותה שורה

### א — הבעיה
שער 110 אמור לספור שורות טבלה ב-Audit Log של session_plan.
`awk '/[Aa]udit [Ll]og/,/^---|^##/'` — השורה `## Audit Log` מפעילה
גם את start וגם את end pattern (`^##`), ולכן awk סוגר את הrange מיד. תוצאה: AUDIT_LINES=0 תמיד.
שגיאת syntax נוספת: `grep -c ... || echo 0` מייצר שתי שורות (count + "0") — arithmetic comparison נכשלת.

### ב — הפתרון
שינוי ל-awk עם flag: `in_section=1; next` כשמגיע ל-Audit Log (דילוג על השורה עצמה).
`AUDIT_LINES=${AUDIT_LINES:-0}` במקום `|| echo 0`.

### ג — כלל המניעה
ANTIPATTERN: awk.*Audit.*,.*\^##
RULE: awk range pattern עם ^## כ-end יסגור מיד אם השורה ה-start מתחילה ב-##. השתמש ב-flag (in_section) במקום range.
ANTIPATTERN: grep -c.*\|\| echo 0
RULE: grep -c תמיד מדפיס count (גם 0) — || echo 0 יוצר double-output. השתמש ב- ${var:-0} אחרי grep -c.

---

## 2026-05-31 · gate 81 — pipe ל-cut מצליח כשsha256sum נכשל (Windows/MSYS)

### א — הבעיה
שער 81 בדק `sha256sum "$REPO_ROOT/.git/hooks/pre-commit" 2>/dev/null | cut -d' ' -f1 || echo "missing"`.
כש-.git/hooks/pre-commit לא קיים: sha256sum נכשל, אבל cut מצליח (stdin ריק → exit 0).
הביטוי `|| echo "missing"` בודק את exit code של cut (לא sha256sum).
התוצאה: LOCAL_HOOK_HASH="" (לא "missing") — gate נכשל בטעות על Windows/MSYS ועל כל מכונה ללא hook מקומי.

### ב — הפתרון
בדיקת קיום קובץ לפני sha256sum:
```bash
if [[ -f "$REPO_ROOT/.git/hooks/pre-commit" ]]; then
    LOCAL_HOOK_HASH=$(sha256sum ... | cut ...); LOCAL_HOOK_HASH=${LOCAL_HOOK_HASH:-missing}
else
    LOCAL_HOOK_HASH="missing"
fi
```

### ג — כלל המניעה
ANTIPATTERN: sha256sum.*2>/dev/null.*\|.*cut.*\|\| echo "missing"
RULE: pipe מחזיר exit code של הפקודה האחרונה — בדוק קיום קובץ ב-if לפני sha256sum, אל תסמוך על || אחרי pipe.

---

## 2026-05-31 · generate_stuck_regression — CRLF מ-Windows משבש heredoc

### א — הבעיה
על Windows/MSYS, `grep | sed` מחזיר שורות עם `\r` בסוף (CRLF).
כשה-pattern מוכנס לתוך heredoc Dart (`r'''${pattern}'''`),
ה-`\r` גורם ל-cursor לקפוץ לתחילת השורה ולדרוס תוכן,
מייצר Dart שבור (למשל: `y.readAsStringSync()` במקום `entity.readAsStringSync()`).

### ב — הפתרון
הוספת `| tr -d '\r'` אחרי ה-sed בחילוץ הpatterns,
וגם `pattern=$(echo "$pattern" | tr -d '\r')` בתוך הלולאה.

### ג — כלל המניעה
ANTIPATTERN: grep.*ANTIPATTERN.*\|.*sed.*pattern\b[^|]
RULE: כל חילוץ pattern מקובץ עלול לכלול \r על Windows — תמיד pipe ל-tr -d '\r' לפני שימוש בheredoc.

---

## 2026-05-31 · gate 81 — sha256sum רואה CRLF vs LF (Windows autocrlf)

### א — הבעיה
gate 81 השווה `sha256sum HEAD:.githooks/pre-commit` מול `sha256sum` על הworking copy.
`git show` מחזיר LF. Windows עם `autocrlf=true` שומר CRLF בworking copy.
hash שונה → gate נכשל בטעות גם כשהקובץ זהה לוגית.

### ב — הפתרון
החלפת השוואת sha256sum ב-`git diff --quiet HEAD -- .githooks/pre-commit`.
git diff מנרמל line-endings לפי `.gitattributes` — לא מושפע מ-autocrlf.

### ג — כלל המניעה
ANTIPATTERN: sha256sum.*git show.*HEAD.*githooks
RULE: השוואת קבצים בין HEAD לworking copy חייבת לעבור דרך git diff, לא sha256sum — git מנרמל line endings, sha256sum לא.
