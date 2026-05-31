# פרוטוקול חקירת באגים — 100 צעדים

> **כלל #39:** לעולם לא להציע פתרון לפני שהבעיה ידועה ב-100%.
> חקור → חקור עמוק → ודא → רק אז פתרון.

---

## Phase A — זיהוי וסיווג (1–15)

1. קרא את הודעת השגיאה **המלאה** — לא רק שורה אחת.
2. זהה: באיזה **שער** נכשל (31? 32? 59?).
3. זהה: האם זו **שגיאה** (❌) או **אזהרה** (⚠️) — אזהרה אינה חוסמת.
4. בדוק אם הכשל מתועד ב-`stuck_log.md` — אולי כבר נפתר.
5. בדוק אם הכשל מתועד ב-`CARRY_FORWARD.md` — אולי יש לקח קיים.
6. הריץ `git status --short` — האם יש שינויים לא-committed?
7. הריץ `git log --oneline -5` — מה השתנה לאחרונה?
8. הריץ `git diff --cached --name-only` — אילו קבצים staged?
9. בדוק: האם הכשל חדש או קיים מלפני השינוי? (`git stash && commit-test && git stash pop`)
10. קבע: האם זה **באג ב-hook**, **באג בקוד**, **באג בתיעוד**, או **בעיית סביבה**.
11. מדרג חומרה: חוסם commit / אזהרה בלבד / intermittent / תלוי-OS.
12. בדוק: האם `.git/hooks/pre-commit` ≡ `.githooks/pre-commit` (`sha256sum` שניהם).
13. בדוק: האם Flutter זמין — `flutter --version`.
14. בדוק: האם פועל מתיקיית `app_flutter/` — `pwd`.
15. **עצור.** לפני שממשיכים — האם הבעיה מוגדרת במשפט אחד ברור?

---

## Phase B — שכפול (16–30)

16. שכפל את הכשל בסביבה נקייה: `git stash && [commit מינימלי] && git stash pop`.
17. בדוק: האם הכשל מתרחש **בכל פעם** או רק לפעמים?
18. בדוק: האם הכשל תלוי בתוכן הקובץ הספציפי או בכל שינוי?
19. הקטן את הrepro למינימום — איזה קובץ staged גורם לכשל?
20. בדוק: האם הכשל קורה גם עם `git commit --allow-empty`?
21. בדוק: האם הכשל קורה רק ב-Dart staged? רק ב-knowledge? רק ב-lib/?
22. בדוק: האם הכשל קורה בשני כיוונים (Bash בלבד ≠ Edit בלבד)?
23. שמור את פלט הכשל המלא בקובץ זמני: `git commit 2>&1 | tee /tmp/gate_fail.txt`.
24. הריץ את הhook ידנית: `bash .githooks/pre-commit 2>&1 | head -50`.
25. הוסף `set -x` זמנית לhook לפני שורת הכשל — לראות כל פקודה.
26. בדוק: האם הcurrent directory משפיע? נסה מ-root ומ-app_flutter/.
27. בדוק: האם PATH משפיע? `echo $PATH | tr ':' '\n' | grep flutter`.
28. בדוק: האם locale/encoding משפיע? `echo $LANG $LC_ALL`.
29. בדוק: האם יש CRLF בקבצי hook? `file .githooks/pre-commit`.
30. **עצור.** האם יש לי repro מינימלי ברור ועקבי?

---

## Phase C — ניתוח שורש (31–55)

31. קרא את קוד השער הכושל **במלואו** — `sed -n 'START,ENDp' .githooks/pre-commit`.
32. זהה כל משתנה שהשער משתמש בו — מאיפה הוא מגיע?
33. הדפס ערך כל משתנה לפני בדיקת השגיאה: `echo "VAR=[$VAR]"`.
34. בדוק: האם הmatch pattern נכון? נסה ב-bash: `echo "test" | grep -E "pattern"`.
35. בדוק: האם ה-path נכון לאחר `cd app_flutter/`? (לקח #33 — prefix כפול).
36. בדוק: האם pipe exit code נלכד נכון? `cmd1 | cmd2; echo ${PIPESTATUS[@]}`.
37. בדוק: האם `grep -c` מחזיר כפול? (לקח #27 — `|| echo 0` בעיה).
38. בדוק: האם awk range סוגר מוקדם? (לקח #26 — `^##` באותה שורה).
39. בדוק: האם `sha256sum` מושפע מ-CRLF? (לקח #29).
40. בדוק: האם `tr -d '\r'` נדרש? (לקח #30).
41. בדוק: האם `STAGED_LIB` מחושב לפני הלולאה? (לקח #24 — gate 103).
42. בדוק: האם baseline בSTATUS.md מעודכן? `grep "known-failing" knowledge/STATUS.md`.
43. בדוק: האם test count בSTATUS.md מעודכן? `grep "tests" knowledge/STATUS.md`.
44. בדוק: האם הגרסה ב-home_shell.dart שונה מהcommit האחרון?
45. בדוק: האם WIRING.md עודכן עם השינוי?
46. בדוק: האם mutation_log.md עודכן לhelper חדש?
47. בדוק: האם stuck_log.md מכיל antipattern שחוזר?
48. בדוק: האם הtest הכושל **חדש** (נוסף בסשן) או **קיים** (pre-existing)?
49. בדוק: האם הtest הכושל **קשור** לשינוי שנעשה?
50. אם הtest קיים ולא נגעת בו: בצע `git stash` ובדוק אם נכשל גם ללא שינויים.
51. אם הtest כן קשור: קרא את הtest ואת הקוד שהשתנה — הבן מה השתבר.
52. אם הtest לא קשור: תעד ב-STATUS.md `known-failing: N` ועבור הלאה.
53. זהה: האם הבעיה ב-**implementation** (הקוד שגוי) או ב-**expectation** (הtest שגוי)?
54. אם implementation: מה בדיוק השורה הלא נכונה?
55. **עצור.** כתוב משפט אחד: "הבעיה היא X כי Y."

---

## Phase D — תכנון פתרון (56–70)

56. כתוב את הפתרון בעברית לפני שכותבים שורת קוד.
57. בדוק: האם הפתרון פותר את שורש הבעיה — לא רק הסימפטום?
58. בדוק: האם הפתרון לא שובר gate אחר?
59. בדוק: האם הפתרון לא שובר test אחר?
60. בדוק: האם הפתרון לא יוצר regression ב-Windows/MSYS?
61. בדוק: האם הפתרון לא יוצר regression ב-macOS?
62. בדוק: האם הפתרון מינימלי — לא מוסיף לוגיקה מיותרת?
63. בדוק: האם צריך לעדכן `CARRY_FORWARD.md` עם לקח חדש?
64. בדוק: האם צריך לעדכן `stuck_log.md` עם antipattern?
65. בדוק: האם צריך regression test חדש?
66. בדוק: האם צריך לסנכרן `.git/hooks/pre-commit`?
67. בדוק: האם צריך bump גרסה (שינוי ב-lib/)?
68. בדוק: האם צריך לעדכן WIRING.md?
69. בדוק: האם יש תלויות — קבצים אחרים שמסתמכים על מה שמשתנה?
70. **עצור.** האם הפתרון ברור, מינימלי, ולא שובר שום דבר?

---

## Phase E — יישום (71–85)

71. ערוך את הקובץ הרלוונטי — שינוי **מינימלי** בלבד.
72. קרא שוב את השינוי — האם הוא עושה בדיוק מה שתכננת?
73. בדוק ידנית שהpatch פותר את הrepro: הריץ `bash .githooks/pre-commit`.
74. אם hook שונה: `cp .githooks/pre-commit .git/hooks/pre-commit`.
75. הריץ `flutter analyze --no-pub` — 0 errors.
76. הריץ את הtest הכושל בלבד: `flutter test --no-pub test/SPECIFIC.dart`.
77. ודא שהtest עובר עכשיו.
78. הריץ את כל ה-tests הקשורים לשינוי (לא suite מלא עדיין).
79. אם stuck_log עודכן: ודא שה-antipattern pattern תקין (regex).
80. אם CARRY_FORWARD עודכן: ודא שהלקח במשפט אחד ברור.
81. אם STATUS.md עודכן: ודא שtest count ו-known-failing נכונים.
82. Stage כל הקבצים הרלוונטיים: `git add FILE1 FILE2 ...`.
83. בדוק staged: `git diff --cached --name-only` — רק מה שצריך.
84. בדוק diff: `git diff --cached` — אין שינויים מיותרים.
85. **עצור.** האם היישום מינימלי, נכון, ומוכן לcommit?

---

## Phase F — אימות (86–95)

86. הריץ `flutter test --no-pub` מלא — ≥ baseline tests ✅.
87. ודא: מספר הבדיקות לא ירד.
88. ודא: כל הכשלים ≤ `known-failing` ב-STATUS.md.
89. הריץ commit — ודא שכל 100 השערים עוברים.
90. אם שער נכשל: חזור ל-Phase C — לא לנחש, לחקור.
91. ודא: `sha256sum .githooks/pre-commit .git/hooks/pre-commit` — זהים.
92. ודא: אין uncommitted changes לאחר הcommit.
93. ודא: commit message מתאר **למה** לא **מה**.
94. ודא: אין `--no-verify`, אין `--force`, אין bypass.
95. **עצור.** הcommit עבר כל 100 שערים?

---

## Phase G — תיעוד ומניעה (96–100)

96. הוסף רשומה ל-`stuck_log.md`: א-בעיה, ב-פתרון, ג-ANTIPATTERN + RULE.
97. הוסף לקח ל-`CARRY_FORWARD.md` — משפט אחד, ממוספר, בקבוצה הנכונה.
98. אם צריך regression test — ודא שה-hook יצר אותו אוטומטית מ-ANTIPATTERN.
99. עדכן `BUG_INVESTIGATION_PROTOCOL.md` אם גילית צעד חסר.
100. שאל: **מה הלקח שמונע שהבאג הזה יחזור?** וודא שהוא מוטמע.

---

## כללי ברזל

- **לא מציע פתרון לפני צעד 55.**
- **לא רץ suite מלא לפני צעד 86.**
- **פקודה שנכשלה פעמיים → פיבוט** (לקח #37).
- **אם הבעיה של סוכן אחר → `git diff test/` ועצור** (לקח #38).
