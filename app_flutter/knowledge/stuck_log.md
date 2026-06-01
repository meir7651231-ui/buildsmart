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

## 2026-06-01 · שער 23 (+109) — emoji-regex grep נכשל תחת git-commit ב-MSYS

### א — הבעיה
שער 23: `grep -q "🟦" ROADMAP`. הקובץ מכיל 12 × 🟦, ה-grep מצליח אינטראקטיבית
(גם תחת LC_ALL=C ב-Linux) — אבל **תחת סביבת git-commit ב-Windows/MSYS הוא נכשל**,
ו-gate 23 חוסם כל commit שנוגע ב-lib/state/screens. אותו class בדיוק כמו
gate 81 (sha256 CRLF) ו-gate 103 (echo|grep) — fragility של locale/encoding ב-MSYS.
אותו דפוס גם בשער 109 (`grep -c "✅"/"⬜"` על session_plan).
(הערה: לא שוחזר על Linux — ספציפי-פלטפורמה, אך עקבי עם 81/103 המתועדים.)

### ב — הפתרון
emoji grep → `grep -aqF` / `grep -acF`: `-a` binary-safe, `-F` fixed-string
(byte-match בלי regex-engine) → locale-independent. תוקן ב-3 המקומות (23 + 109×2).

### ג — כלל המניעה
ANTIPATTERN[hook]: grep -[qc] "(🟦|✅|⬜)
RULE: grep של emoji ב-hook חייב `-aF` (binary + fixed-string), לא `-q`/`-c` רגיל — אחרת נכשל תחת locale של git-commit ב-MSYS.

---

## 2026-06-01 · baseline-phantom — known-failing: 16 בעוד 0 כשלים בפועל

### א — הבעיה
סוכן הגדיר `known-failing: 16` ב-STATUS.md (טען: paired_warning_test pre-existing).
אימות בפועל: `paired_warning_test` עובר 8/8, והסוויטה המלאה **927 ✅ / 0 ✗**.
ה-16 הוא **phantom**. סכנה: gate 32 עם baseline=16 בולע עד 16 רגרסיות אמיתיות
בשקט. בנוסף — agents נתקעים: "16" הוא מספר בלי שמות, אי-אפשר לדעת מה נכשל.

### ב — הפתרון
(1) תיקון known-failing → 0 (מאומת).
(2) `knowledge/known_failing.txt` — שמות הבדיקות הכושלות (ריק כשאין).
(3) שער 32: known-failing > 0 חייב מספר-שורות תואם ב-known_failing.txt (אחרת
baseline-phantom → חסום), ומדפיס שמות-בדיקות שנכשלו כדי שהסוכן ידע מה שלו.

### ג — כלל המניעה
ANTIPATTERN[hook]: grep -cvE.*\|\| echo 0
RULE: baseline (known-failing) חייב שמות מאומתים ב-known_failing.txt, לא מספר בלבד. מספר בלי שמות = phantom שבולע רגרסיות. ספירת שורות: grep -cvE → ${var:-0}, לא "|| echo 0".

---

## 2026-06-01 · זיהוי retry התחמק ע"י שינוי סט-הקבצים (פער #3 מהאודיט)

### א — הבעיה
שער 102 (דרישת תיעוד אחרי כשל) הסתמך על `CURRENT_FP` = sha256 של **שמות
הקבצים** ב-staging. אם סוכן שינה אילו קבצים staged בין ניסיונות → החתימה
משתנה → `IS_RETRY=false` → גם אחרי כשל חוזר, אין דרישת תיעוד. התחמקות.

### ב — הפתרון
הוספת זיהוי לפי **HEAD sha**: retry = ניסיון commit כש-HEAD לא זז מאז כשל
(אי-אפשר להצליח commit עם שער נכשל → HEAD זז רק בהצלחה). הרישום כולל
`head=$HEAD_SHA`, והזיהוי בודק `fp==CURRENT_FP || rec_head==HEAD_SHA`.
תאימות-לאחור: רשומה ישנה בלי `head=` → `${rest##*head=}` מחזיר את כל ה-rest,
לא מתאים ל-sha. נבדק על 6 תרחישים (כולל התחמקות, false-positive, פג-תוקף).

### ג — כלל המניעה
ANTIPATTERN[hook]: gates=\$FAIL"
RULE: רישום ה-fingerprint חייב לכלול `head=$HEAD_SHA` (לא `gates=$FAIL"` לבד) — אחרת שינוי סט-קבצים מתחמק מזיהוי retry.

---

## 2026-06-01 · `.emergency_token` לא ב-.gitignore — bypass token דליף (אודיט חלק ז׳)

### א — הבעיה
ה-hook קורא `.emergency_token` (שורה 30) כמקור token לעקיפת **כל** הפרוטוקול,
ומנחה `export ...="$(cat .emergency_token)"`. אבל `.gitignore` הכיל רק
`.allow_protocol_edit` — **לא** את `.emergency_token`. אף gate לא חסם staging שלו.
אם session ייצר אותו (כפי שה-hook מנחה) → committable → ה-bypass token נחשף
ב-git. סותר את לקח #31. נמצא באודיט PROTOCOL_AUDIT_PLAN צעד 94.

### ב — הפתרון
(1) הוספת `.emergency_token` ל-`.gitignore`.
(2) הרחבת שער 53 לחסום staging של `.emergency_token`/`.allow_protocol_edit`/
`.allow_master_protocol_edit` (defense-in-depth נגד `git add -f`).
(3) `protocol_security_test.dart` — מאמת ש-.gitignore מכיל את הtokens ושה-gate קיים.

### ג — כלל המניעה
ANTIPATTERN[hook]: git add.*emergency_token
RULE: כל token שה-hook קורא (bypass/emergency) חייב גם ב-.gitignore וגם חסום ב-staged ע"י שער 53. לעולם לא `git add` עליו.

---

## 2026-06-01 · שער 103 — `echo "$p" | grep -qE` לא-דטרמיניסטי בין סביבות

### א — הבעיה
בדיקת shell-meta של שער 103 השתמשה ב-`echo "$pattern" | grep -qE '\$\(|\`|\\$\{'`.
ב-commit (52430cb) היא סימנה את **כל 32** האנטי-פטרנים כ-shell-meta (false positive,
לא חוסם — רק רעש). אינטראקטיבית, אותו קלט, אותו קובץ, אותו hook: **0/32**.
הוכחה ל-non-determinism של `echo | grep` בין סביבות shell (variance של echo
ו/או binary של grep ב-PATH). המנגנון המדויק לא שוחזר — אבל אי-העקביות מוכחת.

### ב — הפתרון
החלפה ל-bash `case "$pattern" in *'$('*|*'\`'*|*'${'*) ... esac` — pattern-matching
builtin טהור, ללא echo/grep/regex-engine. דטרמיניסטי בכל סביבה: 0/32 false,
ועדיין תופס הזרקה אמיתית (`foo$(rm)bar` → flagged).

### ג — כלל המניעה
ANTIPATTERN[hook]: echo "\$[a-z_]+" \| grep -qE.*shell-meta
RULE: בדיקת תווים בתוך משתנה לא-מהימן → bash `case`/glob (builtin), לא `echo "$v" | grep` (לא-דטרמיניסטי בין סביבות).

---

## 2026-06-01 · שער 109 הפר את לקח #27 — grep -c || echo 0 (לא נתפס כי הרגרסיה סורקת רק lib/)

### א — הבעיה
שורות 647-648 (שער 109) השתמשו ב-`grep -c "✅" file 2>/dev/null || echo 0`.
זה בדיוק האנטי-פטרן של לקח #27: `grep -c` מדפיס `0` עם exit 1 כשאין התאמות →
`|| echo 0` יורה גם הוא → הערך הופך ל-`0\n0` → השוואת `[[ -gt 5 ]]` שבורה.
**למה לא נתפס:** `stuck_regression_test.dart` סורק רק `lib/` (Dart), והבאג ב-hook
(bash). 17 מתוך 31 האנטי-פטרנים הם hook-bash — אף אחד לא מוגן ע"י הרגרסיה.
נמצא ב-PROTOCOL_AUDIT_PLAN חלק ו׳ (steps 79/82).

### ב — הפתרון
שינוי ל-`X=$(grep -c ...); X=${X:-0}` (שורה נפרדת). תוקן בשתי השורות.

### ג — כלל המניעה
ANTIPATTERN[hook]: grep -c [^|]*2>/dev/null \|\| echo 0
RULE: ספירה עם grep -c → `X=$(grep -c ...); X=${X:-0}`. לעולם לא `grep -c ... || echo 0` (double-output כשהספירה 0).

---

## 2026-06-01 · שערים 35-40 רצים מחוץ ל-NEEDS_FLUTTER — warn שגוי בכל commit

### א — הבעיה
לולאת שערים 35-40 (בדיקות חיוניות) רצה **אחרי** ה-`fi` של בלוק `NEEDS_FLUTTER`.
כשcommit לא נוגע ב-Dart (תיעוד בלבד) → `$TEST_OUT` ריק → `grep -q "$critical"`
נכשל על כל 6 הבדיקות → 6 אזהרות שגויות (`compat_coverage_test לא רץ` וכו') בכל commit.
נראה בכל commit של תיעוד בסשן הזה.

### ב — הפתרון
העברת הלולאה **לתוך** בלוק `if [[ -n "$NEEDS_FLUTTER" ]]`. כשאין Dart staged —
flutter לא רץ בכלל, ולכן אין מה לבדוק שרץ. אין אזהרות שגויות.

### ג — כלל המניעה
ANTIPATTERN[hook]: ^for critical in compat_coverage_test
RULE: בדיקה שתלויה ב-$TEST_OUT (פלט flutter test) חייבת לרוץ בתוך בלוק NEEDS_FLUTTER (לולאת השערים 35-40 מוזחת 4 רווחים בתוך הבלוק). מחוץ לבלוק (`^for` ללא הזחה) → $TEST_OUT ריק → warn שגוי.

---

## 2026-06-01 · שער 88 — git diff --cached file מחזיר exit 0 כשלא-staged

### א — הבעיה
שער 88 בדק `git diff --cached knowledge/MASTER_PROTOCOL.md >/dev/null 2>&1 && warn`.
מ-`app_flutter/` הקובץ קיים ו-tracked → `git diff --cached file` מחזיר exit **0**
(no-diff = 0), לא משנה אם הקובץ staged. → התנאי תמיד אמת → warn 88 בכל commit.

### ב — הפתרון
שינוי ל-`git diff --cached --name-only | grep -q "MASTER_PROTOCOL.md"` — מחזיר 0
רק כשהקובץ באמת ברשימת ה-staged.

### ג — כלל המניעה
ANTIPATTERN[hook]: git diff --cached [a-z].*\.md >/dev/null
RULE: לזיהוי "האם קובץ X staged" — `git diff --cached --name-only | grep -q X`, לא `git diff --cached X >/dev/null` (מחזיר 0 גם בלי שינוי).

---

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

---

## 2026-05-31 · gate 103 — shell-meta warning מחוץ ל-Dart gate

### א — הבעיה
שער 103 בודק shell-meta chars בpatterns לפני בדיקת `STAGED_DART`.
`STAGED_DART` מחושב *בתוך* הלולאה, אחרי בדיקת shell-meta.
תוצאה: 24 אזהרות "מכיל shell-meta" ב-**כל** commit, גם ב-commits של תיעוד בלבד ללא Dart.

### ב — הפתרון
הוצאת `STAGED_DART_103` לפני הלולאה + עטיפת כל הלולאה ב-`if [[ -n "$STAGED_DART_103" ]]`.
הלולאה (כולל בדיקת shell-meta) רצה רק כשיש Dart staged.

### ג — כלל המניעה
ANTIPATTERN: while.*ANTIPATTERN.*done.*STAGED_DART=\$\(git diff
RULE: STAGED_DART חייב להיות מחושב לפני הלולאה שמשתמשת בו — לא בתוכה, כדי למנוע false-positive warnings על commits בלי Dart.

---

## 2026-05-31 · gate 59 — גרסה לא עלתה למרות שעלתה

### א — הבעיה
שער 59 בודק: `git diff --cached app_flutter/lib/screens/home_shell.dart`.
הhook מבצע `cd "$REPO_ROOT/app_flutter"` בשורה 44 — אז הנתיב הנכון הוא `lib/screens/home_shell.dart`, לא `app_flutter/lib/screens/home_shell.dart`.
מ-`app_flutter/`, `git diff --cached app_flutter/lib/screens/home_shell.dart` מחזיר ריק כי git מחפש `app_flutter/app_flutter/...`.

### ב — הפתרון
שינוי gate 59 מ-`app_flutter/lib/screens/home_shell.dart` ל-`lib/screens/home_shell.dart`.
סינכרון `.git/hooks/pre-commit` ← `.githooks/pre-commit`.

### ג — כלל המניעה
ANTIPATTERN: git diff --cached app_flutter/lib/screens/home_shell.dart
RULE: hook מבצע cd app_flutter — כל נתיב גיט בתוך ה-hook חייב להיות יחסי ל-app_flutter (ללא prefix app_flutter/).

---

## 2026-05-31 · rebase conflict v5.41→v5.42 ב-home_shell.dart
### א — הבעיה
שני sessions בחרו v5.41 בו-זמנית — git pull --rebase נתקע ב-home_shell.dart.
### ב — הפתרון
שינוי גרסה של הענף שלי ל-v5.42 בקובץ הconflict, המשך rebase.
### ג — כלל המניעה
ANTIPATTERN: 'v5\.\d+ · \d+\.\d+\.\d+' .*v5\.41
RULE: לפני שמתחיל עבודה — בדוק ב-origin מה הגרסה הנוכחית ותחשב את שלך כגרסה+1 כדי להימנע מconflict.

---

## 2026-05-31 · סוכן פרוטוקול נסחף לדבג קוד של סוכן אחר

### א — הבעיה
שלושה כשלים קשורים:
1. הריץ `flutter test --no-pub` מלא (15 דק') 3+ פעמים אחרי שלא עבד — במקום לעבור לגישה אחרת.
2. הועסק בדיבוג כשלי בדיקות של אגנט אחר (`paired_warning_test.dart`) במקום להישאר בתפקיד פרוטוקול-בלבד.
3. נתן אותה פקודה שוב ושוב — `git diff test/`, `flutter test --reporter expanded` — ללא תוצאה.

### ב — הפתרון
- פרוטוקול-אגנט: **לא** מדבג קוד של אגנט אחר. שולח אותו ל-`git diff test/` ועוצר.
- פקודה שנכשלה פעמיים = **פיבוט מיידי** — גישה אחרת לגמרי.
- אבחון gate: קובץ ספציפי תחילה (`flutter test test/X.dart`), לא suite מלא.

### ג — כלל המניעה
ANTIPATTERN: flutter test --no-pub --reporter expanded
RULE: אבחון gate → קובץ ספציפי בלבד. suite מלא רק לפני commit. אם פקודה נכשלה פעמיים — פיבוט, לא חזרה.

---

## 2026-06-01 · gate 32 — pattern שגוי לספירת כשלים ב-compact mode

### א — הבעיה
gate 32 ניסה לחלץ מספר כשלים עם pattern `[0-9]+ ✗`.
ב-flutter test compact output, כשלים מוצגים כ:`+888 -16: Some tests failed.`
Pattern `[0-9]+ ✗` לא מוצא דבר → `FAIL_COUNT=0` תמיד → השוואה ל-baseline לא עובדת.
תוצאה: גם אם `known-failing: 16` ב-STATUS.md, gate 32 לא מכבד אותו.

### ב — הפתרון
שינוי ל-`grep -oE "\+[0-9]+ -[0-9]+:" | grep -oE -- "-[0-9]+" | grep -oE "[0-9]+"`.
חולץ נכון: `+888 -16:` → `16`.

### ג — כלל המניעה
ANTIPATTERN[hook]: grep -oE "\[0-9\]\+ ✗"
RULE: flutter compact output מציג כשלים כ`-N:` (לא ✗). לחלץ FAIL_COUNT: `grep -oE "\+[0-9]+ -[0-9]+:"`

---

## 2026-05-31 · gate 32 חוסם commit נקי בגלל pre-existing failures ב-origin

### א — הבעיה
origin עצמו מכיל 16 כשלים ב-`paired_warning_test.dart`.
סוכן שלא נגע בקבצי בדיקה נחסם על ידי gate 32 — למרות שה-diff שלו נקי.
`git diff test/paired_warning_test.dart` ריק — הקובץ זהה ל-origin.

### ב — הפתרון
gate 32 שונה ל-baseline tracking: חוסם רק אם `FAIL_COUNT > known-failing` ב-STATUS.md.
הענף עם 16 כשלים צריך להוסיף `known-failing: 16` ל-STATUS.md.

### ג — כלל המניעה
ANTIPATTERN: err.*32.*exit=\$TEST_EXIT.*תקן את הבדיקות
RULE: gate 32 חייב לבדוק baseline מ-STATUS.md (known-failing: N) — לא לחסום על pre-existing failures שקיימות ב-origin.


---

## 2026-05-31 · gate 102 · p80 misrouted blue PPRCT pipes to green PPR spec

### א — הבעיה
`kPprPipesAC` (page 80 AQUATHERM blue pipes) ניתב 16 מוצרים ל-`spec_faser_20.jpg` (חתך-רוחב PPR ירוק). הקטלוג עצמו מציג צילום כחול חד-משמעי — אלה צינורות PPRCT. ה-spec הירוק היה חזותית שגוי לכל 16 המוצרים.

### ב — הפתרון
`case kPprPipesAC` ב-`_pprSpecFor` שונה להחזיר `spec_pprct_pipe.jpg` (חתך כחול, אותה משפחה כמו p86 PPRCT fiber).

### ג — כלל המניעה
ANTIPATTERN: case kPpr[A-Z][a-z]+:\s*\n\s*case kPpr[A-Z][a-z]+:\s*\n\s*return \[.spec_faser_20
RULE: case kPprPipesAC חייב להחזיר spec_pprct_pipe (כחול) — לא spec_faser_20 (ירוק). חיבור case-fall-through מסתיר שגיאות צבע. הפרד לכל case בנפרד.



---

## 2026-06-01 · gate 23/109 · emoji grep נכשל תחת git-commit (מקבץ) — גם `-aqF` לא הספיק

### א — הבעיה
סוכן (מקבץ) דיווח: שער 23 (`grep -aqF "🟦"`) עדיין נכשל תחת `git commit` למרות לקח #51.
ראיות מסביבתו: `grep -aqF "🟦"` עובר standalone בכל locale (`LC_ALL=C`/`LANG=C`/plain),
ה-ROADMAP מכיל 12 שורות 🟦, ה-cwd תקין (gates 44/59/72 עוברים) — אך תחת `git commit`
בלבד הוא נכשל. השורש: git-for-windows מחליף את ה-grep binary/PATH ב-invocation של
ה-hook, כך שכל תלות ב-binary חיצוני (ולא ה-flags) היא הבעיה. אותו class כמו gate 103.

### ב — הפתרון
שערים 23 ו-109 הומרו ל-bash builtin טהור — אפס grep חיצוני:
`while IFS= read -r _l; do case "$_l" in *🟦*) ...;; esac; done < file`.
byte-match עקבי בכל סביבה, ללא תלות ב-binary/PATH/locale.

### ג — כלל המניעה
ANTIPATTERN[hook]: grep [^|#]*(🟦|✅|⬜|🎯|🎨|🎮|🎪|🎲)
RULE: emoji/multibyte-match ב-hook = bash case/glob builtin בלבד — לעולם לא grep חיצוני (אפילו -aF / -oE / charclass). git מחליף את ה-grep binary ב-invocation, כך ש-standalone-pass לא מבטיח commit-pass. חל על שערים 23/64/93/109 — כולם הומרו ל-builtin.

---

## 2026-06-01 · gate 24 · finder group glyph נוסף בלי לתעד ב-WIRING.md

### א — הבעיה
הוספת `kFinderGroupImage` + `finderGroupGlyph` ל-`lib/screens/finder_screen.dart`
(אייקוני מוצר 3D לעיגולי הבית) בלי שורה מקבילה ב-`app_flutter/WIRING.md`.
שער 24 חסם את ה-commit. הנחה שגויה שהקובץ ב-knowledge ושייך לפרוטוקוליסט —
בפועל הוא ב-root ומשותף, וכל סוכן שנוגע ב-lib screens חייב לתעד שם.

### ב — הפתרון
נוספה שורת group glyph לטבלת ה-finder ב-WIRING.md: label לאייקון מוצר דרך
kFinderGroupImage עם fallback ל-Material icon, מאומת ב-finder_group_icons_test.
git add WIRING.md ואז commit חוזר — שער 24 עבר.

### ג — כלל המניעה
ANTIPATTERN: new provider or map in lib screens shipped without a matching WIRING row
RULE: כל provider או map חדש ב-lib screens שמניע UI מקבל שורת WIRING.md באותו commit. WIRING.md ב-root ומשותף לכל הסוכנים — לא בבעלות הפרוטוקוליסט.
---

## 2026-06-01 · gate 12 · bump גרסה ב-home_shell בלי לסנכרן STATUS.md

### א — הבעיה
שינוי גרסת ה-label ב-`lib/screens/home_shell.dart` (v5.44 -> v5.45) בלי לעדכן
את אותה גרסה ב-`knowledge/STATUS.md`. שער 12 חסם — הגרסאות לא מסונכרנות.

### ב — הפתרון
עדכון `_Version label:` ב-STATUS.md לאותה גרסה כמו ב-home_shell, באותו commit.

### ג — כלל המניעה
ANTIPATTERN: version label bumped in home_shell without the same bump in STATUS
RULE: כל שינוי של version label ב-home_shell מחייב את אותה גרסה ב-STATUS.md באותו commit. שתי הגרסאות תמיד זהות.


---

## 2026-06-01 · I5 · letter-size axis בלע L= length כ"מידה L"

### א — הבעיה
זיהוי מידות-אות (S/M/L) ל-pool ה-finder. regex תמים ל-L בודד תפס את ה-L
ב-"צינור אפור DN40 L=50 ס\"מ" (9 מוצרים) — כאן L הוא "אורך" (length=), לא מידה.
זה היה יוצר ציר "מידה: L" שגוי על כל הצינורות.

### ב — הפתרון
ה-regex של letterSizeTokens דורש שהאות לא תהיה צמודה לאות אחרת ולא ייעקב
אחריה תו שווה: lookahead שלילי על אות-לטינית/עברית ועל סימן-שווה. נדרש >1
מידות שונות ב-pool כדי שהציר יופיע (S יחיד בניקוז לא יוצר ציר).

### ג — כלל המניעה
ANTIPATTERN: letter size regex without a negative lookahead on equals sign
RULE: זיהוי מידת-אות בודדת חייב lookbehind/lookahead שמוציא אות צמודה וסימן שווה. L צמוד לשווה הוא אורך, לא מידה. דורשים יותר ממידה אחת ב-pool לפני הצגת ציר.

---

<<<<<<< HEAD
## 2026-06-01 · generator · ANTIPATTERN עם גרש בגבול שובר r'''…''' (קטלגן, 4ad3dbb)

### א — הבעיה
`generate_stuck_regression.sh` עטף כל pattern ב-`RegExp(r'''${pattern}''')`. אם
ה-ANTIPATTERN מתחיל או נגמר בגרש בודד `'` (למשל `'bs\.[a-z-]+'`), נוצרים 4 גרשים
רצופים בגבול (`r''''…''''`) ⇒ Dart לא יכול לזהות את גבול ה-raw-string ⇒ שגיאת
קומפילציה ב-`stuck_regression_test.dart` ⇒ כל סוויטת הבדיקות נשברת לכל הסוכנים.
landmine סמוי: אף antipattern נוכחי לא הפעיל אותו, אך הוספת אחד כזה הייתה מפוצצת.

### ב — הפתרון
הגנרטור עושה escape ל-Dart string רגיל (לא-raw) ועוטף ב-`'…'`:
`\`→`\\`, `$`→`\$`, `'`→`\'` (סדר קריטי — backslash ראשון, אחרת escape כפול).
semantics של regex נשמרים. אומת: pattern עם גרש בשני הקצוות מתקמפל ותופס נכון.

### ג — כלל המניעה
ANTIPATTERN[hook]: RegExp\(r'''
RULE: גנרטור קוד לא עוטף תוכן-משתנה ב-delimiter שמניח שהתוכן לא מכילו (r'''…'''). escape דטרמיניסטי ל-Dart string רגיל. הערה: ה-pattern הזה סורק את ה-hook (לא רלוונטי שם) — שמירה כתיעוד; הגנרטור עצמו נבדק ע"י torture-test ידני.


---

## 2026-06-01 · שער 103 — false-positive על הקובץ המיוצר אחרי regen רב-שורות

### א — הבעיה
שער 103 סורק `git diff --cached -- '*.dart'` לכל ANTIPATTERN. אבל
`stuck_regression_test.dart` מכיל את **כל** האנטי-פטרנים by-construction
(כל ANTIPATTERN נרשם בו כ-`RegExp(...)`). commit שמ-regen אותו עם שינוי רב-שורות
(escape-refactor: `r'''…'''`→`'…'`) הכניס את כל 40 הפטרנים ל-diff כ-added lines
→ 7 שערים נכשלו false-positive (הפטרנים שתואמים את צורתם-שלהם). חסם commit לגיטימי.

### ב — הפתרון
החרגת הקובץ המיוצר מסריקת ה-dart של שער 103 ע"י git pathspec:
`-- '*.dart' ':(exclude)*stuck_regression_test.dart'` (גם ב-STAGED_DART_103 וגם
בסריקת ה-MATCH). מקביל ל-self-exclude של הבדיקה עצמה (`contains('stuck_regression')`).

### ג — כלל המניעה
ANTIPATTERN[hook]: cached -- '\*\.dart' 2>/dev/null \| grep
RULE: סריקת שער 103 ב-dart חייבת `:(exclude)*stuck_regression_test.dart` — קובץ הרישום מכיל את כל הפטרנים, בלי החרגה כל regen מפיל false-positive. (ה-antipattern תופס את הצורה הישנה `'*.dart' 2>/dev/null | grep` בלי ה-exclude.)


---

## 2026-06-01 · שערים 36/37/40 — warn "test לא רץ" למרות שעבר (דיווח Finder)

### א — הבעיה
שערים 35-40 בדקו `echo "$TEST_OUT" | grep -q "$critical"` — האם שם הבדיקה החיונית
מופיע בפלט flutter test. אבל default-reporter כשהפלט נלכד (לא-TTY) מדפיס את שמות
הקבצים **לא-דטרמיניסטית**: אומת בריצה — 3/6 שמות מופיעים (compat_coverage,
smartproduct_contract, dedup) ו-3 חסרים (regression_gate, knowledge_protocol,
no_duplicate_specs) למרות ש-937/937 עברו. → warn שגוי קבוע בכל commit. בנוסף:
הצורה דילגה לגמרי כש-`[[ -f ]]` נכשל → התעלמה ממחיקת בדיקה חיונית (הסיכון האמיתי).

### ב — הפתרון
שינוי הבדיקה ל-`[[ -f "test/${critical}.dart" ]] || warn` — בודק קיום-קובץ
(תופס מחיקה), לא הופעה בפלט. מעבר/כשל מכוסה ע"י שער 32 (FAIL_COUNT מול baseline).

### ג — כלל המניעה
ANTIPATTERN[hook]: echo "\$TEST_OUT" \| grep -q "\$critical"
RULE: "האם בדיקה חיונית קיימת" ב-hook = `[[ -f test/X.dart ]]`, לא `grep -q` על פלט flutter test (default-reporter לא-דטרמיניסטי כשנלכד — 3/6 שמות חסרים).


---

## 2026-06-01 · שער 102 — לולאת תיעוד על כשלי-bookkeeping (דיווח Finder)

### א — הבעיה
שער 102 ירה "פתרת בעיה — לא תיעדת" על **כל** retry אחרי commit חסום, כולל כשהכשל
הקודם היה bookkeeping טהור (שער 12 version-sync / 24 WIRING / 59 path) — לא באג
code/test. כפה רשומת stuck_log + ANTIPATTERN + regression-test על "שכחתי לבמפ
STATUS" — רעש: אי-אפשר לכתוב ANTIPATTERN regex משמעותי לכשל bookkeeping, וה-gate
עצמו תופס אותו שוב ממילא (דטרמיניסטי).

### ב — הפתרון
`err()` רושם מספרי-שערים ל-FAILED_GATES; ה-fingerprint שומר `gates=v2:12,24`;
זיהוי ה-retry מחלץ PRIOR_GATES ומסווג PRIOR_HAS_CODE_TEST (שער 31-45). שער 102
דורש תיעוד רק כש-PRIOR_HAS_CODE_TEST. פורמט ישן (`gates=<count>`) → conservative.

### ג — כלל המניעה
ANTIPATTERN[hook]: IS_RETRY" == "true" && -f "\$STUCK_LOG"
RULE: שער 102 דורש תיעוד רק על retry של כשל code/test (31-45) — התנאי חייב לכלול `-n "$PRIOR_HAS_CODE_TEST"`. bookkeeping טהור (12/24/59) פטור.

---

## 2026-05-31 · §22.H · 75 photo-only products fell back to whole-page spec

### א — הבעיה
75 מוצרים (EF p72-74, כלי ריתוך p90-92) ללא דיאגרמת-מידה בקטלוג —
ה-spec שלהם נפל ל-`page_NN.jpg` (העמוד המלא, כולל מוצרים אחרים ותתי-סוגים).
המשתמש ראה עמוד שלם במקום את הבלוק של המוצר.

### ב — הפתרון
14 crops ממוקדים [צילום + טבלה] פר-תת-סוג. routing ב-`_pprSpecFor`:
`case kPprElectrofusion` (p72-74) + `case kPprTools` (p90-92) חדש, לפי nameHe.
העמוד המלא נשמר כסליד שני ב-specImageAssets (לא אבד). 0/774 על page primary.

### ג — כלל המניעה
ANTIPATTERN: return null;\s*//.*photo-only.*fall.*through
RULE: photo-only page ⇒ crop ממוקד [photo+table] פר-תת-סוג, לא page fallback מלא. R8: crop של אותו עמוד מותר; העמוד נשאר כסליד-פייג'ר שני.
