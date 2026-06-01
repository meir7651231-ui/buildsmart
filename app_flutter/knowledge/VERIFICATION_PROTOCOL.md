# פרוטוקול בדיקה מאוחד — BuildSmart Flutter

> **מסמך-חוק יחיד לאימות.** כל שינוי — קוד או ידע — עובר את **אותו סולם-בדיקה**
> לפני commit. אין יוצא-מן-הכלל. 100 שערי ה-pre-commit אוכפים אוטומטית.
>
> **מאחד** את: `TESTING.md` (3 שכבות) · `TESTS_OVERVIEW.md` (אינדקס-טסטים) ·
> `CHECKLISTS.md` (רשימות-פעולה) · `BUG_INVESTIGATION_PROTOCOL.md` (100 צעדי-חקירה) ·
> `scripts/mutation_verify.sh` (מוטציה בטוחה). ארבעת המקורות נשארים כ**נספחים-פירוט**
> (§7) — הפרוטוקול הזה הוא ה-**entry-point והסמכות**.
>
> **הסוכן ליטוש עובד לפי המסמך הזה** לכל שינוי (UI-polish ו-knowledge-polish כאחד).

---

## 0. העיקרון

**שינוי לא "נגמר" כשהוא נכתב — אלא כשהוא עבר את הסולם.** הקוד/המסמך הוא הצעה;
הסולם הוא מה שהופך אותה ל-done. אבחון 100% לפני פתרון (לקח #39); תיקון מדויק >
תיקון רחב (לקח #17); פעולה שנכשלה פעמיים → פיבוט (לקח #37).

---

## 1. סולם-הבדיקה (רוץ בסדר הזה, לפני כל commit)

| # | שכבה | פקודה / מנגנון | תנאי-מעבר |
|---|------|----------------|-----------|
| **L0** | סטטי | `flutter analyze` + `dart format --set-exit-if-changed .` | 0 errors · 0 שינויי-פורמט |
| **L1** | רגרסיה (129 קבצים, 10 דומיינים) | `flutter test` | ירוק · ≤ `known_failing.txt` |
| **L1c** | **חוזה-החיווט (חיווט)** | `wiring_test.dart` + `gaps_test.dart` מול `../WIRING.md` | כל שורת-WIRING מכוסה |
| **L2** | harness בתוך-האפליקציה | `runRegression(ref)` (פאנל BS-dial) | כל המודולים עוברים |
| **L3** | מוטציה (לשינוי-לוגיקה) | `scripts/mutation_verify.sh` ← **לא** `git checkout` | אדום→שחזור→ירוק |
| **L3g** | **stuck → regression** | `scripts/generate_stuck_regression.sh` | אנטי-פטרן חדש = טסט חדש |
| **L4** | build | `flutter build web --release` (+ `post_build.sh`) | עובר · גודל-bundle במגמה |
| **L5** | ויזואלי (לשינוי-UI) | screenshot before/after | מתועד ב-`POLISH_LOG.md` |
| **L6** | ידע (לשינוי-knowledge) | verdict + `knowledge_protocol_test` + `protocol_security_test` | ירוק · אין הפניות-שבורות |
| **L7** | **שרשרת hooks (3)** | `commit-msg` → `pre-commit` (100 שערים) → `pre-push` | כל 100 + פורמט + ענף-יעד |
| **L7a** | **גם השערים נבדקים** | `scripts/audit_gates.sh` (מזריק באג לכל שער) | כל שער חוסם הרמטית |

> **L7 חוסם — לא לעקוף.** בעיית-שער → דווח לפרוטוקוליסט (טמפלט ב-`AGENT_COORDINATION`).
> **`protocol_check.sh`** = הריצה המלאה של L0–L7 ידנית לפני commit/push.

---

## 2. אילו שכבות חלות על איזה שינוי

| סוג-שינוי | L0 | L1 | L2 | L3 | L4 | L5 | L6 | L7 |
|-----------|----|----|----|----|----|----|----|----|
| UI-presentation (spacing/צבע/motion) | ✅ | ✅ | — | — | ✅ | ✅ | — | ✅ |
| לוגיקה (helper/חישוב/predicate) | ✅ | ✅ | ✅ | **✅** | ✅ | — | — | ✅ |
| state/provider | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | ✅ |
| microcopy/string (verbatim) | ✅ | ✅ | — | — | — | — | — | ✅ |
| knowledge-doc (פאזה K) | — | — | — | — | — | — | **✅** | ✅ |

**כלל:** כל שינוי-לוגיקה **חייב** L3 (מוטציה). UI-only מכוסה דרך
providers/helpers — לא דרך pixel-rendering (גבול ידוע ומקובל).

---

## 3. מוטציה — השיטה המתוקנת (L3)

> ⚠️ **המתכון הישן (`git checkout -- file`) אסור.** הוא מוחק עריכות לא-מקומיטות
> באותו קובץ. השתמש ב-`scripts/mutation_verify.sh` שמשחזר byte-exact מ-גיבוי.

```bash
scripts/mutation_verify.sh <file> '<sed-expr>' '<test-path-or-name>'
# (1) גיבוי byte-exact → (2) הזרקת תקלה → (3) test מצופה אדום →
# (4) שחזור מהגיבוי → (5) test מצופה ירוק → (6) רישום ל-mutation_log.md
```

**כלל-הזהב:** לוגיקת-דומיין חייבת להיות **100% נתפסת-במוטציה**. כדי שלוגיקה תהיה
catchable — חלץ אותה מ-widget ל-top-level pure function (ראה `ARCHITECTURE.md`).
מוטנט שקול-באמת (equivalent) — מצמידים אותו בקלט-יריב, **לא** מתעלמים.

---

## 4. נמצא באג / טסט נצבע אדום → חקירת-100-צעדים (מקופל לכאן)

> **כלל #39:** לעולם לא להציע פתרון לפני שהבעיה ידועה ב-100%.
> חקור → חקור עמוק → ודא → רק אז פתרון. **אל תתקן מהיר.**

### Phase A — זיהוי וסיווג (1–15)
1. קרא את הודעת השגיאה **המלאה** — לא רק שורה אחת.
2. זהה: באיזה **שער** נכשל (31? 32? 59?).
3. זהה: **שגיאה** (❌) או **אזהרה** (⚠️) — אזהרה אינה חוסמת.
4. בדוק אם הכשל מתועד ב-`stuck_log.md` — אולי כבר נפתר.
5. בדוק אם הכשל מתועד ב-`CARRY_FORWARD.md` — אולי יש לקח קיים.
6. `git status --short` — שינויים לא-committed?
7. `git log --oneline -5` — מה השתנה לאחרונה?
8. `git diff --cached --name-only` — אילו קבצים staged?
9. הכשל חדש או קיים מלפני השינוי? (`git stash && commit-test && git stash pop`)
10. קבע: באג ב-**hook** / **קוד** / **תיעוד** / **סביבה**.
11. מדרג חומרה: חוסם commit / אזהרה / intermittent / תלוי-OS.
12. `.git/hooks/pre-commit` ≡ `.githooks/pre-commit`? (`sha256sum` שניהם).
13. Flutter זמין — `flutter --version`.
14. פועל מ-`app_flutter/` — `pwd`.
15. **עצור.** האם הבעיה מוגדרת במשפט אחד ברור?

### Phase B — שכפול (16–30)
16. שכפל בסביבה נקייה: `git stash && [commit מינימלי] && git stash pop`.
17. הכשל **בכל פעם** או רק לפעמים?
18. תלוי בתוכן הקובץ הספציפי או בכל שינוי?
19. הקטן repro למינימום — איזה קובץ staged גורם לכשל?
20. קורה גם עם `git commit --allow-empty`?
21. קורה רק ב-Dart staged? רק ב-knowledge? רק ב-lib/?
22. קורה בשני כיוונים (Bash בלבד ≠ Edit בלבד)?
23. שמור פלט מלא: `git commit 2>&1 | tee /tmp/gate_fail.txt`.
24. הרץ ידנית: `bash .githooks/pre-commit 2>&1 | head -50`.
25. `set -x` זמני לפני שורת-הכשל — לראות כל פקודה.
26. ה-cwd משפיע? נסה מ-root ומ-app_flutter/.
27. PATH משפיע? `echo $PATH | tr ':' '\n' | grep flutter`.
28. locale/encoding? `echo $LANG $LC_ALL`.
29. CRLF בקבצי hook? `file .githooks/pre-commit`.
30. **עצור.** יש repro מינימלי עקבי?

### Phase C — ניתוח שורש (31–55)
31. קרא את קוד-השער הכושל **במלואו** — `sed -n 'A,Bp' .githooks/pre-commit`.
32. זהה כל משתנה שהשער משתמש בו — מאיפה הוא מגיע?
33. הדפס ערך כל משתנה לפני הבדיקה: `echo "VAR=[$VAR]"`.
34. ה-match pattern נכון? `echo "test" | grep -E "pattern"`.
35. ה-path נכון אחרי `cd app_flutter/`? (לקח #33 — prefix כפול).
36. pipe exit code נלכד? `cmd1 | cmd2; echo ${PIPESTATUS[@]}`.
37. `grep -c` מחזיר כפול? (לקח #27).
38. awk range סוגר מוקדם? (לקח #26).
39. `sha256sum` מושפע מ-CRLF? (לקח #29).
40. `tr -d '\r'` נדרש? (לקח #30).
41. `STAGED_LIB` מחושב לפני הלולאה? (לקח #24 — gate 103).
42. baseline ב-STATUS.md מעודכן? `grep "known-failing" knowledge/STATUS.md`.
43. test count ב-STATUS.md מעודכן?
44. הגרסה ב-home_shell.dart שונה מה-commit האחרון?
45. WIRING.md עודכן עם השינוי?
46. mutation_log.md עודכן ל-helper חדש?
47. stuck_log.md מכיל antipattern שחוזר?
48. ה-test הכושל **חדש** (נוסף בסשן) או **קיים**?
49. ה-test הכושל **קשור** לשינוי?
50. test קיים ולא נגעת בו → `git stash` ובדוק אם נכשל גם בלי שינויים.
51. test קשור → קרא את ה-test ואת הקוד שהשתנה.
52. test לא קשור → תעד ב-STATUS.md `known-failing: N` והמשך.
53. הבעיה ב-**implementation** או ב-**expectation** (test שגוי)?
54. implementation → מה בדיוק השורה הלא-נכונה?
55. **עצור.** כתוב משפט: "הבעיה היא X כי Y."

### Phase D — תכנון פתרון (56–70)
56. כתוב את הפתרון בעברית לפני שורת-קוד.
57. פותר את השורש — לא רק סימפטום?
58. לא שובר gate אחר? 59. לא שובר test אחר?
60. לא יוצר regression ב-Windows/MSYS? 61. ב-macOS?
62. מינימלי — בלי לוגיקה מיותרת?
63. צריך לעדכן `CARRY_FORWARD.md`? 64. `stuck_log.md`? 65. regression test חדש?
66. לסנכרן `.git/hooks/pre-commit`? 67. bump גרסה (שינוי ב-lib/)? 68. WIRING.md?
69. תלויות — קבצים שמסתמכים על מה שמשתנה?
70. **עצור.** הפתרון ברור, מינימלי, ולא שובר כלום?

### Phase E — יישום (71–85)
71. ערוך — שינוי **מינימלי** בלבד.
72. קרא שוב — עושה בדיוק מה שתכננת?
73. בדוק שה-patch פותר repro: `bash .githooks/pre-commit`.
74. hook שונה → `cp .githooks/pre-commit .git/hooks/pre-commit`.
75. `flutter analyze --no-pub` — 0 errors.
76. `flutter test --no-pub test/SPECIFIC.dart` — רק הכושל.
77. ודא שעובר עכשיו. 78. הרץ tests קשורים (לא suite מלא עדיין).
79. stuck_log עודכן → regex תקין. 80. CARRY_FORWARD → לקח במשפט אחד.
81. STATUS.md → test count + known-failing נכונים.
82. `git add FILE1 FILE2`. 83. `git diff --cached --name-only` — רק מה שצריך.
84. `git diff --cached` — אין מיותר. 85. **עצור.** מינימלי, נכון, מוכן?

### Phase F — אימות (86–95)
86. `flutter test --no-pub` מלא — ≥ baseline ✅.
87. מספר הבדיקות לא ירד. 88. כל הכשלים ≤ `known-failing`.
89. commit — כל 100 השערים עוברים. 90. שער נכשל → חזור ל-Phase C (לא לנחש).
91. `sha256sum` של שני ה-hooks זהים. 92. אין uncommitted אחרי commit.
93. הודעת-commit מתארת **למה** לא **מה**. 94. אין `--no-verify`/`--force`/bypass.
95. **עצור.** עבר כל 100 שערים?

### Phase G — תיעוד ומניעה (96–100)
96. רשומה ל-`stuck_log.md`: בעיה · פתרון · ANTIPATTERN + RULE.
97. לקח ל-`CARRY_FORWARD.md` — משפט אחד, ממוספר.
98. regression — ודא שה-hook יצר אותו אוטומטית מ-ANTIPATTERN.
99. עדכן את הפרוטוקול אם גילית צעד חסר.
100. **מה הלקח שמונע שהבאג יחזור?** וודא שהוא מוטמע.

**כללי-ברזל:** לא פתרון לפני 55 · לא suite מלא לפני 86 · פקודה שנכשלה
פעמיים → פיבוט (#37) · בעיה של סוכן אחר → `git diff test/` ועצור (#38).

---

## 4b. Checklists להעתקה (מקופל מ-CHECKLISTS)

**חיווט הגדרה לאפקט אמיתי:**
- [ ] מצא את השדה ב-`lib/state/<area>_settings.dart`, ודא write-only כרגע.
- [ ] לוגיקה (math/filter/threshold) → **חלץ pure top-level helper**, ה-widget קורא לו.
- [ ] חווט widget → helper/provider.
- [ ] הוסף שורה ל-`../WIRING.md` עם ✅ + שם-ה-helper.
- [ ] בדיקה ב-`test/gaps_test.dart` (או `wiring_test.dart`).
- [ ] helper "enforced" → חתימה ב-`knowledge_protocol_test.dart` + הפניה ב-WIRING.
- [ ] L0+L1 ירוקים → מוטציה (`mutation_verify.sh`) → bump גרסה ב-`home_shell.dart`.

**הוספת/המרת מסך (light mode):**
- [ ] bg `0xFFF5F6FA`, cards `0xFFFFFFFF`, AppBar `foregroundColor 0xFF1A1A1A`.
- [ ] אין טקסט-לבן על משטח-בהיר (לבן רק על כפתורים/badges צבעוניים).
- [ ] light-mode guard ב-`knowledge_protocol_test` נשאר ירוק.

**placeholder → התנהגות אמיתית:**
- [ ] החלף toast "בבנייה" בפעולה האמיתית. הזז שורה ב-WIRING מ-🚧 ל-✅ + טסט.

**כשמוטציה מוצאת באג שלא-נתפס:** פער-כיסוי. חלץ לוגיקה אם embedded; הוסף
pinning test. מוטנט שקול → קלט-יריב (subtotal שלילי), לא להתעלם.

---

## 5. Definition of Done לשינוי (go/no-go)

שינוי הוא **done** רק כש:
- [ ] כל שכבות-הסולם הרלוונטיות (§2) ירוקות
- [ ] לשינוי-לוגיקה: מוטציה נתפסה (L3) + regression נוסף אם נמצא באג
- [ ] לשינוי-UI: before/after ב-`POLISH_LOG.md`
- [ ] לשינוי-ידע: verdict ב-`KNOWLEDGE_AUDIT.md` + `knowledge_protocol_test` ירוק
- [ ] `WIRING.md` עודכן אם נגעת ב-screens/state/logic
- [ ] 100 השערים עברו · **push רק ב"תדחוף" מפורש** (לקח #48)

---

## 6. הסוכן ליטוש — בדיקה לפי-פאזה

| פאזת-ליטוש | שכבות-חובה |
|-----------|-------------|
| B–G (spacing/צבע/motion/states/RTL/touch) | L0·L1·L4·L5·L7 |
| H (microcopy verbatim) | L0·L1·L7 |
| I (ליטוש-קוד) | L0·L1·(L3 אם נגע בלוגיקה)·L4·L7 |
| **K (ליטוש-ידע)** | **L6·L7** — verdict לכל מסמך לפני פעולה; אסור לשבור הפניה שהשערים בודקים |

---

## 7. סטטוס-האיחוד (מה קופל לכאן, מה נשאר נספח)

> **המסמך הזה הוא הסמכות היחידה לבדיקה.** התוכן הפרוצדורלי קופל פנימה.
> ה-verdict המלא לכל מקור ב-`KNOWLEDGE_AUDIT.md`.

| מקור | מה נעשה | למה |
|------|---------|------|
| `TESTING.md` | ✅ קופל (§1·§3) → **stub מנותב** | נאכף ע"י `knowledge_protocol_test` (>400 ת') — לא נמחק |
| `CHECKLISTS.md` | ✅ קופל (§4b) → **stub מנותב** | לא נאכף — הומר להפניה |
| `BUG_INVESTIGATION_PROTOCOL.md` | ✅ קופל (§4) → **stub מנותב** | 100 הצעדים עכשיו כאן |
| `TESTS_OVERVIEW.md` | **נשאר נספח** (לא קופל) | אינדקס 102-קבצים = lookup, לא פרוצדורה; נאכף ע"י שער 2 |
| `scripts/mutation_verify.sh` | הכלי של L3 | קוד, לא מסמך |

> **למה TESTS_OVERVIEW לא קופל (verdict מפורש):** הוא טבלת-lookup של 102 קבצי-טסט —
> נתוני-עזר, לא "איך מוודאים". קיפולו היה מנפח את המסמך ל-2× בלי ערך-פרוצדורלי.
> נשאר כ**אינדקס-הטסטים** שאליו §8 מפנה. (אם תרצה גם אותו פנימה — אמור ואכפיל.)

---

## 8. מרשם המנגנונים — איפה כל בדיקה רשומה בפועל

> כשמשהו נשבר, זה הטבלה שאומרת לאיזה קובץ ללכת.

### חיווט (WIRING)
| מנגנון | קובץ | מה הוא אוכף |
|--------|------|--------------|
| חוזה-החיווט | `../WIRING.md` (86 שורות) | כל כפתור/הגדרה → התנהגות → סטטוס |
| בדיקת-חיווט | `test/wiring_test.dart` | ה-wiring contract חי בקוד |
| פערים | `test/gaps_test.dart` | pure-logic contract + mirrors WIRING |

### שרשרת ה-hooks (3 שלבים)
| hook | קובץ | מה הוא בודק |
|------|------|--------------|
| הודעה | `.githooks/commit-msg` | פורמט-הודעה (באג #26) |
| לפני-commit | `.githooks/pre-commit` | **100 שערים** |
| לפני-push | `.githooks/pre-push` | כל commit עבר pre-commit + ענף-יעד נכון (באג #23) |

### סקריפטי-אכיפה (`scripts/`)
| סקריפט | תפקיד |
|--------|--------|
| `protocol_check.sh` | ריצת L0–L7 מלאה לפני commit/push |
| `audit_gates.sh` | מזריק באג מיקרוסקופי לכל שער — מוודא שהשער חוסם |
| `generate_stuck_regression.sh` | `stuck_log.md` → `test/stuck_regression_test.dart` |
| `mutation_verify.sh` | מוטציה בטוחה (backup byte-exact) |
| `post_build.sh` | canvasKit config ל-serving מקומי |

### הסוויטה — 129 קבצים, 10 דומיינים (אינדקס מלא ב-`TESTS_OVERVIEW.md`)
1. SmartProduct card · 2. Compat engine · 3. Install/studio · 4. Card helpers ·
5. Persisted state · 6. Cart/commerce · 7. **Mutation/regression gates** ·
8. Audits/health · 9. Interactions/robustness · 10. Misc helpers

### אכיפת-פרוטוקול כטסטים
| קובץ | מה הוא אוכף |
|------|--------------|
| `test/knowledge_protocol_test.dart` | הפרות-פרוטוקול מפילות את הסוויטה |
| `test/protocol_security_test.dart` | אבטחת-פרוטוקול |
| `test/stuck_regression_test.dart` | כל אנטי-פטרן מ-`stuck_log` נחסם לנצח |

### מערכות 100-צעדים נלוות
`BUG_INVESTIGATION_PROTOCOL` (חקירת-באג) · `SMARTPRODUCT_ROADMAP` (תוכנית-מוצר) ·
`LAUNCH_READINESS_PROTOCOL` (בנצי) · `POLISH_PROTOCOL` (ליטוש).

---

## 9. עקרונות-מנחים

- **הסוויטה היא ground-truth** לפני כל checkpoint/push (PLAYBOOK §C).
- **שם-קובץ-טסט = `_test.dart` (יחיד).** `_tests.dart` מדולג שקט ע"י flutter test.
- **כל helper מחווט חייב להיות מכוסה** בלפחות טסט אחד (regression_gate_test) + שורה ב-`WIRING.md`.
- **מוטציה > כיסוי-שורות.** טסט שלא נצבע אדום על באג-מוזרק = טסט-ראווה.
- **wire ⇒ contract ⇒ test.** כל אפקט מחווט = שורה ב-`WIRING.md` + בדיקה ב-`test/`.
