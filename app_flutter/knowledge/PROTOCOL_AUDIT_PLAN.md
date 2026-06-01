# תוכנית אודיט פרוטוקולים — 100 צעדי חקירה

> מטרה: למצוא פערים, סתירות, false positives, false negatives, ותיעוד מיושן.
> כל צעד = בדיקה אחת ספציפית. תסמן ✅/❌/⚠️ ליד כל צעד.

---

## חלק א׳ — ה-Hook: שערים חסרים (1–15)

1. אילו מספרי שערים **חסרים** מהhook? (קיימים: 1-6,10-11,13-15,18,21-26,28,31-35,41-55,58-77,80-81,83-84,86,88-110). מה היה בשערים 7,8,9,12,16,17,19,20,27,29,30,36-40,56,57,78,79,82,85,87?
2. האם השערים החסרים הוסרו בכוונה (מיושן) או שנשמטו בטעות?
3. האם יש פונקציות ב-hook שמוזכרות ב-`err()`/`warn()` אבל לא מוגדרות?
4. האם שער 32 (baseline) מתועד ב-CARRY_FORWARD כ-known fix?
5. האם שער 59 (path fix) מתועד ב-CARRY_FORWARD כ-known fix?
6. האם שער 103 (STAGED_DART לפני לולאה) מתועד ב-CARRY_FORWARD?
7. האם שער 81 (hook sync) עובד אחרי gate-59 fix (paths שונים)?
8. האם שער 33 (test count) מסונכרן עם STATUS.md הנוכחי?
9. האם שער 110 (CARRY_FORWARD entry) בודק מספר לקחים נכון?
10. האם `known-failing: 0` ב-STATUS.md מייצג את מצב הבדיקות הנוכחי?
11. בדוק שערים 35-40: האם הם רצים רק כשיש Dart staged?
12. האם שער 107 (visual log) מציג false positive על dead-code removal?
13. האם שער 88 (MASTER_PROTOCOL) מציג false positive על כל שינוי ב-knowledge/?
14. האם שער 24 (WIRING.md) מציג false positive על commits שלא נוגעים ב-UI?
15. האם שער 64 (emoji verbatim) מציג false positive על emoji ב-commit message?

---

## חלק ב׳ — ה-Hook: לוגיקה שגויה (16–30)

16. בדוק שער 32: `grep -oE "[0-9]+ ✗"` — האם pattern זה עובד על reporter compact?
17. בדוק שער 33: `grep -oE "[0-9]+\+ tests|[0-9]+ tests pass"` — האם pattern מעודכן לflutter output הנוכחי?
18. בדוק שער 59: `git diff --cached lib/screens/home_shell.dart` — האם עובד מ-app_flutter/?
19. בדוק שער 81: האם השוואת sha256sum מתחשבת ב-CRLF (לקח #29)?
20. בדוק שער 103: האם `STAGED_DART_103` מחושב לפני הלולאה?
21. בדוק שער 110: האם awk pattern לAudit Log סוגר נכון (לקח #26)?
22. בדוק שערים עם `grep -c`: האם כולם משתמשים ב-`${var:-0}` ולא ב-`|| echo 0`?
23. בדוק שערים עם sha256sum: האם כולם עוברים דרך `git diff` ולא השוואה ישירה?
24. בדוק: האם יש שערים שמשתמשים ב-`app_flutter/lib/` בתוך `cd app_flutter/`?
25. בדוק שער 42 (helper without test): האם הוא בודק גם `_` private functions?
26. בדוק שער 44 (mutation_log): האם הוא בודק שהקובץ **לא ריק**?
27. בדוק שער 102 (antipattern חוזר): האם regex patterns ב-stuck_log תקינים ב-bash?
28. בדוק שער 101 (בעיה לא תועדה): מה הloגיקה שמזהה "הייתה בעיה"?
29. בדוק שער 36-40 (tests ספציפיים): האם test files האלה קיימים בפועל?
30. בדוק: האם `REPO_ROOT` מוגדר לפני כל שימוש בו?

---

## חלק ג׳ — CARRY_FORWARD: כיסוי ואכיפה (31–50)

31. לקח #1 (tests-first): האם יש שער שמאכף אותו?
32. לקח #2 (visual verification): האם שער 107 מאכף אותו?
33. לקח #3 (clean run = finding): האם מתועד באיזה שלב?
34. לקח #4 (R4 label+circle): האם רלוונטי רק ל-Preact? לסמן אם כן.
35. לקח #5-15: בדוק — האם כל לקח יש לו שער מקביל ב-hook?
36. לקח #24 (gate-103): האם השער תוקן ב-hook ומסונכרן?
37. לקח #26 (awk range): האם יש regression test שבודק את הhook?
38. לקח #27 (grep -c double output): האם כל `grep -c` ב-hook תוקן?
39. לקח #28 (pipe exit code): האם כל pipe ב-hook בודק exit נכון?
40. לקח #29 (sha256 CRLF): האם שער 81 תוקן?
41. לקח #30 (tr -d '\r'): האם ה-generator script כולל זאת?
42. לקח #31 (emergency token): האם `.emergency_token` ב-`.gitignore`?
43. לקח #32 (flutter 6 paths): האם hook מכסה כל 6?
44. לקח #33 (cd app_flutter paths): האם כל `git diff` ב-hook עודכן?
45. לקח #34 (targeted test): האם מתועד בBUG_INVESTIGATION_PROTOCOL.md?
46. לקח #35 (תפקיד סוכן): האם מוצג ב-session-start?
47. לקח #36 (pre-existing failures): האם gate 32 baseline עובד כמצופה?
48. לקח #37 (פיבוט פקודה): האם ניתן לאכוף אוטומטית?
49. לקח #38 (לא מדבג סוכן אחר): האם ניתן לאכוף אוטומטית?
50. לקח #39 (פתרון אחרי אבחון): האם מוטמע ב-BUG_INVESTIGATION_PROTOCOL.md?

---

## חלק ד׳ — stuck_log: antipatterns ותקינות (51–65)

51. ספור: כמה `ANTIPATTERN:` שורות יש ב-stuck_log?
52. ספור: כמה regression tests קיימים ב-stuck_regression_test.dart?
53. בדוק: האם כל ANTIPATTERN ב-stuck_log מיוצג ב-regression test?
54. בדוק: האם כל regex ב-ANTIPATTERN תקין (לא שובר bash)?
55. בדוק: האם יש antipatterns שבודקים `.githooks/` ולא רק `lib/`?
56. בדוק: האם antipattern #26 (gate-59 path) בודק את הhook הנכון?
57. בדוק: האם antipattern #27 (flutter test expanded) מונע ריצה ב-lib/?
58. בדוק: האם `RULE:` שורות ב-stuck_log מספיק ברורות לsession חדש?
59. בדוק: האם יש entries ב-stuck_log ללא `### ג — כלל המניעה`?
60. בדוק: האם כל entry ב-stuck_log כולל תאריך?
61. בדוק: האם format של כל entry תואם את הtemplate בראש הקובץ?
62. בדוק: האם יש antipatterns שסותרים זה את זה?
63. בדוק: האם שער 102 בhook קורא את stuck_log נכון לאנטי-פטרנים?
64. בדוק: האם ה-generator של stuck_regression_test.dart עדכני?
65. בדוק: האם stuck_log מכסה את כל הבאגים שנמצאו ב-gates?

---

## חלק ה׳ — Session Start Hook: מה מוצג (66–75)

66. בדוק: האם session-start מציג את הגרסה הנוכחית?
67. בדוק: האם session-start מציג את הענף הנכון?
68. בדוק: האם session-start מציג commits ממתינים לדחיפה?
69. בדוק: האם session-start מציג את לקח #35 (תפקיד סוכן)?
70. בדוק: האם session-start מציג את לקח #39 (אבחון לפני פתרון)?
71. בדוק: האם session-start מריץ `flutter pub get` — כמה זמן לוקח?
72. בדוק: האם session-start בודק שה-hook מסונכרן (gate 81)?
73. בדוק: האם session-start מכיל הנחיה "אל תדחוף ללא תדחוף"?
74. בדוק: האם session-start מציג Group B remaining בצורה נכונה?
75. בדוק: האם session-start נכשל בחריגה אם flutter לא זמין?

---

## חלק ו׳ — Regression Tests: כיסוי (76–85)

76. הריץ: `flutter test --no-pub test/stuck_regression_test.dart` — כמה tests?
77. בדוק: האם כל 28 antipatterns (לפי ספירה בצעד 51) מיוצגים?
78. בדוק: האם test #26 (gate-59 hook path) בודק את הfile הנכון (`../.githooks/`)?
79. בדוק: האם tests בודקים `lib/` בלבד — או גם `test/`, `.githooks/`?
80. בדוק: האם יש antipattern שדורש בדיקה ב-STATUS.md ולא ב-lib/?
81. בדוק: האם ה-generator מוסיף test חדש אוטומטית לכל ANTIPATTERN ב-stuck_log?
82. בדוק: האם test #27 (flutter test expanded) בודק lib/ בלבד — מה עם `.githooks/`?
83. בדוק: האם regression tests עוברים על הענף הנוכחי — `flutter test test/stuck_regression_test.dart`.
84. בדוק: האם יש tests שבודקים דברים שאינם antipatterns (false coverage)?
85. בדוק: האם ה-generator מוסיף לnumbering נכון (לא כופל מספרים)?

---

## חלק ז׳ — עקביות בין קבצים (86–95)

86. בדוק: האם ROADMAP מסונכרן עם STATUS (גרסה, steps)?
87. בדוק: האם WIRING.md מעודכן עם כל השינויים מstep-9?
88. בדוק: האם session_plan.md מעודכן (כל phases מסומנים ✅)?
89. בדוק: האם BUG_INVESTIGATION_PROTOCOL.md מציין מספר צעדים נכון (100)?
90. בדוק: האם CARRY_FORWARD ו-stuck_log לא סותרים (אותו לקח, הגדרות שונות)?
91. בדוק: האם כל gate שתוקן מוזכר ב-CARRY_FORWARD וב-stuck_log?
92. בדוק: האם MASTER_PROTOCOL.md מעודכן עם gate-32 baseline ו-gate-59 fix?
93. בדוק: האם mutation_log.md כולל רשומה לכל helper שנוסף?
94. בדוק: האם `.emergency_token` קיים וב-`.gitignore`?
95. בדוק: האם `known-failing: 0` ב-STATUS.md תואם לתוצאות flutter test בפועל?

---

## חלק ח׳ — פערים שצריך לסגור (96–100)

96. בדוק: האם יש gate שתיארנו בCARRY_FORWARD כ"צריך תיקון" אבל עדיין לא תוקן?
97. בדוק: האם יש לקח ב-CARRY_FORWARD שאין לו שום מנגנון אכיפה (לא gate, לא regression)?
98. בדוק: האם BUG_INVESTIGATION_PROTOCOL.md מוזכר ב-session-start?
99. בדוק: האם תוצאות האודיט הזה תתועדנה ב-stuck_log וב-CARRY_FORWARD?
100. **שאל:** מה באג אחד שעדיין לא מכוסה ועלול לחזור?

---

## סיכום ממצאים (למלא בסוף האודיט)

| חלק | שערים בדוקים | ✅ תקין | ❌ בעיה | ⚠️ חסר |
|-----|-------------|--------|--------|--------|
| א — שערים חסרים | 1–15 | 10 | 1 (35-40 מחוץ ל-NEEDS_FLUTTER) | 4 (59/81 = false positive; 103 חסר ב-CF) |
| ב — לוגיקה שגויה | 16–30 | 13 | 1 (88 git diff exit) | 2 (36-40 לא `# שער NN`) |
| ג — CARRY_FORWARD | 31–50 | | | |
| ד — stuck_log | 51–65 | | | |
| ה — session-start | 66–75 | | | |
| ו — regression tests | 76–85 | | | |
| ז — עקביות | 86–95 | | | |
| ח — פערים | 96–100 | | | |

---

## ממצאים שתוקנו — אודיט 2026-06-01 (חלקים א׳+ב׳)

| # | ממצא | חומרה | תיקון |
|---|------|-------|-------|
| 1 | שער 32 — pattern `[0-9]+ ✗` לא מוצא דבר ב-compact mode | 🔴 חוסם baseline | `\+[0-9]+ -[0-9]+:` · לקח #40 |
| 2 | שערים 35-40 רצו אחרי `fi` של NEEDS_FLUTTER → 6 warn שגויים | 🟡 רעש | הועברו לתוך הבלוק · לקח #41 |
| 3 | שער 88 — `git diff --cached file >/dev/null`=0 כש-tracked-ולא-staged | 🟡 רעש | `--name-only \| grep -q` · לקח #42 |
| 4 | גייט 103 תועד ב-stuck_log אך לא ב-CARRY_FORWARD | 🟢 תיעוד | לקח #43 |
| — | גייטים 59/81 "לא מתועדים" | ✅ false positive | קיימים כלקחים #33/#29 (topic-based) |

**עדיין פתוח לחקירה:** חלקים ג׳–ח׳ (צעדים 31-100).
