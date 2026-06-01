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

## 4. נמצא באג / טסט נצבע אדום → חקירה

> **אל תתקן מהיר.** באג שנמצא = עבור ל-**`BUG_INVESTIGATION_PROTOCOL.md`** (100 צעדים,
> 7 פאזות: זיהוי → שכפול → שורש → תכנון → יישום → אימות → תיעוד).

החוק (#39): **אסור להציע פתרון לפני שהבעיה ידועה ב-100%.** אחרי תיקון —
הוסף regression שתופס את הבאג, ותעד ב-`stuck_log.md` אם זה אנטי-פטרן חוזר.

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

## 7. נספחי-הפירוט (המקורות שמאוחדים כאן)

| מסמך | מה הוא מוסיף | תפקיד היום |
|------|--------------|------------|
| `TESTING.md` | פילוסופיית 3-השכבות + היסטוריית-מוטציה | פירוט-רקע ל-L1–L3 |
| `TESTS_OVERVIEW.md` | אינדקס 102 קבצי-טסט לפי דומיין + ROADMAP-step | "איזה טסט שומר על מה" |
| `CHECKLISTS.md` | רשימות copy-paste (wire setting / add screen / before-commit) | quick-ref מעשי |
| `BUG_INVESTIGATION_PROTOCOL.md` | 100 צעדי-חקירה ב-7 פאזות | זרוע §4 (באג נמצא) |
| `scripts/mutation_verify.sh` | מוטציה בטוחה (backup-restore) | הכלי של L3 |

> **הערה לליטוש (פאזה K):** ארבעת הנספחים אינם כפילות — כל אחד עונה על שאלה אחרת
> (פילוסופיה / אינדקס / רשימות / חקירה). ה-verdict שלהם: **keep כנספח**, עם הפניה
> מ-`README` למסמך-הזה כ-entry-point. **אל תמחק אותם** — הם הפירוט.

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
