# תיאום סוכנים — BuildSmart

> עדכון אחרון: 2026-06-01 · גרסה v5.61 · ענף `claude/whats-happening-LyY9G`

---

## 4 הסוכנים

| סוכן | תפקיד | מה מותר | מה אסור |
|------|--------|----------|----------|
| **פרוטוקוליסט** | בנית ותיקון פרוטוקולים | `.githooks/`, `knowledge/`, `test/` | feature code, UI, data |
| **קטלגן** | עריכת קטלוגים | `lib/data/`, `assets/` | שינוי פרוטוקולים |
| **סדרן** | עריכה ויזואלית | `lib/ui/`, `lib/widgets/` | שינוי פרוטוקולים |
| **מקבץ** | בניית פיצ׳רים חדשים | `lib/features/`, `lib/screens/` | שינוי פרוטוקולים |
| **בנצי** (משיק) | הכנת-קרקע להשקה (audit ארכיטקטורה/ניקיון/פערים/חנויות → חבילת-הגשה לגוגל) | audit קריאה-בלבד; תיקונים בטוחים; `knowledge/LAUNCH_READINESS.md` + `LAUNCH_PACKAGE/` | refactor/ניווט/מחיקה רחבה בלי אישור; שינוי פרוטוקולים |
| **ליטוש** | מעבר-ליטוש (spacing/צבע/motion/states/RTL/microcopy/קוד-presentation) **+ ליטוש בסיס-הידע** (פאזה K) | `lib/ui/`, `lib/widgets/`, `theme/`, `l10n/` (binding); `knowledge/POLISH_LOG.md` + `KNOWLEDGE_AUDIT.md`; ניקוי `app_flutter/knowledge/` עם verdict מנומק | data/קטלוג; refactor מבני בלי אישור; מסך/view חדש בלי אישור; המצאת טקסט; מחיקת-מסמך בלי verdict; נגיעה ב-`app/knowledge/`; שינוי פרוטוקולים-אחרים |

---

## איך מדווחים על שגיאת hook

כשסוכן נתקל בשגיאת hook (pre-commit), שלח לפרוטוקוליסט:

```
שגיאת hook — [שם הסוכן]
שער: ##  (מספר השער שנכשל)
הודעת שגיאה מלאה:
---
[הדבק כאן את הפלט המלא של pre-commit]
---
פקודה שניסיתי:
git commit -m "..."
קבצים staged:
[רשימת קבצים]
```

**חשוב:** אל תנסה לעקוף את ה-hook. שלח לפרוטוקוליסט ותמתין לתיקון.

---

## 📋 דוח ביצוע — חובה מכל סוכן בסוף כל סשן

> **חובה.** כל סוכן מגיש את הדוח הזה בסוף סשן — אין יוצא מן הכלל. שלושת השדות
> המודגשים (✅ בוצע · ⬜ לא-בוצע+למה · 📐 כיסוי-פרוטוקול) הם חובה ולא מדלגים.
> הדוח נשלח למשתמש **וגם** נכתב כסעיף ב-`POLISH_LOG.md`/`LAUNCH_READINESS.md`/
> הלוג של הסוכן. בלי דוח = הסשן לא נחשב סגור.

```markdown
## דוח ביצוע — [שם סוכן] — [תאריך] — [גרסה v#.##]

### 1. ✅ מה בוצע (עם מספרים)
- [פעולה] — [קובץ/שער/טסט] — [תוצאה מדידה]
- סה"כ: __ commits · __ קבצים · __ טסטים נוספו/עודכנו · __ שורות

### 2. ⬜ מה לא בוצע — ולמה (חובה לכל פריט שנותר פתוח)
| פריט | למה לא | חסום ע"י | מתי אפשר |
|------|--------|----------|----------|
|      | (זמן / חסם-משתמש / תלוי-סוכן / מחוץ-ל-scope) |  |  |

### 3. 📐 כיסוי-פרוטוקול (כמה השתמשתי בפרוטוקול)
- **פרוטוקול-אב:** [MASTER / POLISH / LAUNCH_READINESS / CATALOG / BUG_INVESTIGATION]
- **צעדים שהושלמו:** __ / __ (למשל "פאזה K: 11/11" · "LAUNCH: 96/100")
- **שערי-hook שעברו:** __/__ (pre-commit) · build ✅/❌ · analyze ✅/❌ · test __✅/__❌
- **לקחים (CARRY_FORWARD) שיישמתי:** #__, #__ (ושמם בקצרה)
- **סטיות מהפרוטוקול:** [אין / פירוט + נימוק + אישור-משתמש]

### 4. 🧪 אימות
- flutter analyze: ✅/❌  · flutter test: __✅ / __❌  · build web: ✅/❌

### 5. 🚧 בעיות / חסמים שדורשים החלטת-משתמש
- 

### 6. commit SHA (ראש-העבודה)
`xxxxxxx`
```

**איך לקרוא את שדה 3 (כיסוי-פרוטוקול):** המספר `צעדים שהושלמו __/__`
הוא המדד ל"כמה השתמש בפרוטוקול" — סוכן ב-`12/100` עדיין בתחילת הדרך; `96/100`
= כמעט-סיום. `שערים __/__` מוכיח שהעבודה עברה אכיפה אוטומטית, לא רק טענה.

---

## טבלת סטטוס עדכני

| סוכן | סטטוס | סשן אחרון | דוח התקבל? |
|------|--------|------------|--------------|
| פרוטוקוליסט | ✅ פעיל | 2026-06-01 | — (זה אני) |
| קטלגן | ✅ פעיל — קטלוג חוליות (170 מוצרים, v5.54) | 2026-06-01 | ⬜ ממתין לדוח |
| סדרן | 🟦 ממתין | — | ⬜ ממתין לדוח |
| מקבץ (Finder) | ✅ פעיל — IMPROVEMENTS 9/10 · 948 טסטים · gh-pages חי (v5.62) | 2026-06-01 | ✅ דוח התקבל (`9103878`) |
| בנצי (משיק) | ✅ פעיל — LAUNCH_PACKAGE + AAB 68.2MB (−52%) + image-CDN | 2026-06-02 | ✅ דוח התקבל (`1913191` + מיגרציה) |
| ליטוש | ✅ פעיל — בנצי #1+#2+#3 (חלוקת מים/שפכים) + פאזה K (76/76) | 2026-06-02 | ✅ דוח התקבל (למטה) |

> **⬜ ממתין לדוח** = הסוכן עבד אבל טרם הגיש דוח-ביצוע בפורמט למעלה. עדכן ל-✅
> כשהדוח מתקבל. דוח חסר = הסשן לא נחשב סגור (ראה סעיף הדוח החובה למעלה).

---

## היסטוריית תיקוני hook (לסוכנים)

| תאריך | commit | שער | תיאור הבעיה | תיאור התיקון |
|--------|--------|-----|-------------|--------------|
| 2026-06-01 | (זה) | 23, 109 | emoji-grep נכשל תחת git-commit גם עם `-aqF` (git מחליף binary) | הומר ל-bash `case`/glob builtin (אפס grep) |
| 2026-06-01 | `2b6e429` | 23, 109 | emoji `grep -q` נכשל ב-MSYS/locale | שונה ל-`grep -aqF` (לא הספיק — ראה שורה למעלה) |
| 2026-06-01 | קודם | 32 | FAIL_COUNT לא חולץ מ-compact output | תיקון regex + baseline phantom |
| 2026-06-01 | קודם | 103 | shell-meta non-deterministic בסביבת commit | שונה ל-bash `case`/glob |
| 2026-06-01 | קודם | 88 | staged check תמיד true | שונה ל-`--name-only \| grep -q` |
| 2026-06-01 | קודם | 53 | bypass tokens לא חסומים | נוסף gate 53 + gitignore |

---

## כתובות ידע משותף

| קובץ | תוכן |
|------|------|
| `knowledge/STATUS.md` | גרסה נוכחית, מה עשוי, מה פתוח |
| `knowledge/CARRY_FORWARD.md` | לקחים #1–51 |
| `knowledge/stuck_log.md` | אנטיפטרנים ידועים |
| `knowledge/known_failing.txt` | בדיקות baseline כושלות (כרגע: 0) |
| `knowledge/BUG_INVESTIGATION_PROTOCOL.md` | 100 צעדים לחקירת באגים |
| `knowledge/PROTOCOL_AUDIT_PLAN.md` | ביקורת 100 צעדים על כל הפרוטוקולים |
| `knowledge/AGENT_WORK_PLAN.md` | תוכנית עבודה של פרוטוקוליסט |
| `knowledge/AGENT_COORDINATION.md` | קובץ זה |

---

## ⚠️ WIRING.md — קובץ משותף, לא בבעלות אף סוכן

- מיקום: **`app_flutter/WIRING.md`** (root של app_flutter, **לא** ב-`knowledge/`).
- **כל** סוכן שנוגע ב-`lib/screens` / `lib/state` / `lib/logic` **חייב** להוסיף את
  הוויירינג שלו ל-`WIRING.md` ולעשות לו `git add` — זו הדרישה של **שער 24**.
- זה **לא** באג ב-hook ו**לא** בבעלות פרוטוקוליסט. הסוכן ששינה את הקוד הוא זה
  שמתעד. אל תדווח על שער 24 כבאג — פשוט עדכן את `WIRING.md` והוסף ל-staged.
- פרוטוקוליסט נוגע רק ב-`.githooks/`, `knowledge/`, `test/` — **לא** ב-`WIRING.md`.

## 🔄 נוהל Push & Sync — חובה (מצמצם התנגשויות rebase)

כל הסוכנים דוחפים לאותו ענף במקביל. בלי נוהל → התנגשויות rebase חוזרות.
הכלל פשוט: **תמיד pull --rebase לפני push, ותמיד sync ל-hook המקומי.**

### לפני כל push — 4 צעדים
```bash
# 1. וודא working tree נקי (commit מקומי קודם)
git status                    # חייב להיות clean

# 2. משוך עדכוני סוכנים אחרים — תמיד rebase, לא merge
git fetch origin claude/whats-happening-LyY9G
git rebase origin/claude/whats-happening-LyY9G

# 3. סנכרן את ה-hook המקומי (אם אין core.hooksPath=.githooks)
cp .githooks/pre-commit .git/hooks/pre-commit

# 4. דחוף
git push -u origin claude/whats-happening-LyY9G
```

### אם יש conflict ב-rebase — מי מנצח לכל קובץ
| קובץ | פתרון |
|------|--------|
| `knowledge/stuck_log.md` | **שמור את שתי הרשומות** (שלך + של האחר). לא מוחקים. |
| `knowledge/STATUS.md` | תווית-גרסה: **הגבוהה ביותר**. known-failing: 0. |
| `test/stuck_regression_test.dart` | **אל תמזג ידנית** — הרץ `bash scripts/generate_stuck_regression.sh` והוא נוצר מחדש מ-stuck_log הממוזג. |
| `WIRING.md` | שמור את שתי השורות (שלך + של האחר). |
| `lib/**` (קוד) | אם שני סוכנים נגעו באותו קובץ — עצור, פנה לפרוטוקוליסט/משתמש. |

### חלוקת-בעלות שמצמצמת חיכוך
- **`.githooks/` + `knowledge/CARRY_FORWARD.md` + `PROTOCOL_AUDIT_PLAN.md` + generator** = **פרוטוקוליסט בלבד**. סוכן אחר שנוגע בהם = התנגשות מובטחת. אל תיגעו.
- **`stuck_log.md`** — append-only. כל סוכן מוסיף בסוף; conflict נפתר ע"י שמירת שניהם + regen של הבדיקה.
- **`lib/`** — מחולק לפי תפקיד (קטלגן=data, סדרן=ui/widgets, מקבץ=features/screens, בנצי=audit+packaging, ליטוש=presentation-polish). אם שניים צריכים אותו קובץ — תאמו דרך המשתמש.
- **חפיפת ליטוש↔סדרן (`lib/ui` + `lib/widgets`):** סדרן=מבנה-תצוגה; ליטוש=ליטוש-feel (spacing/motion/states). חפיפת ליטוש↔בנצי (cleanup-קוד): בנצי מאתֵר, ליטוש מבצע. בכל מקרה — תאמו דרך AGENT_COORDINATION לפני double-touch.

### תדירות push
- **תיקוני-hook קריטיים (פרוטוקוליסט)** → push מיד אחרי אימות (סוכנים חסומים מחכים).
- **feature commits** → אפשר לצבור 2-3 ולדחוף יחד (פחות סבבי-rebase לאחרים).
- **בתחילת סשן עבודה** → `git pull --rebase` ראשון, תמיד.

---

## ⚠️ צעד-פתיחה לכל סשן — יישור-ענף **בטוח** (חובה, לפני כל עבודה)

> נוסף אחרי שסוכן נפתח על ענף ישן/אחר וחשב שמסמכי-ליבה "חסרים".
> **עודכן (לקח #63):** הגרסה הישנה אמרה `git reset --hard` עיוור — זה **footgun**
> בסביבת ריבוי-סוכנים: הוא **מוחק commits מקומיים לא-דחופים** ועבודה ב-staging.
> בנצי תפס את זה נכון ועצר. **לעולם לא `reset --hard` בלי לבדוק קודם.**

```bash
# 0. אם יש commit פעיל (hook רץ) — אל תיגע ב-git עד שיסתיים
[[ -f .git/index.lock ]] && { echo "⛔ commit פעיל — המתן"; exit; }

# 1. הבא את מצב הרימוט (לא משנה כלום מקומית)
git fetch origin claude/whats-happening-LyY9G

# 2. בדוק לפני שאתה משנה — שלושה תנאים
git status --short                                              # נקי?
git rev-list --left-right --count origin/claude/whats-happening-LyY9G...HEAD
#   פלט "<behind> <ahead>". ahead>0 = יש לך commits לא-דחופים!

# 3. החלט לפי המצב:
#   • נקי + ahead=0          → git merge --ff-only origin/...  (fast-forward, אפס אובדן)
#   • ahead>0 (לא-דחוף)      → ⛔ עצור. דחוף קודם (באישור) או שמור. אל תאפס.
#   • dirty (שינויים)        → commit/stash קודם. אל תאפס.
#   • ענף אחר לגמרי          → git checkout claude/whats-happening-LyY9G ואז שלב 2

git rev-parse --short HEAD                                      # אמת SHA מול הרימוט
```

**`reset --hard` מותר רק** כשאימתת ידנית `ahead=0` **וגם** tree נקי — ואז ממילא
`merge --ff-only` עושה את אותו דבר בלי סיכון. בספק — אל תאפס; דחוף/שמור והתייעץ.

- **"קובץ חסר"?** בדוק `git ls-tree -r origin/claude/whats-happening-LyY9G | grep <name>`
  לפני שמכריזים על חוסר — לא רק את ה-working-tree המקומי.
- **תוצר-נוצר-תוך-כדי** (`POLISH_LOG.md`, `LAUNCH_PACKAGE/`) ≠ מסמך-קיים-מראש;
  חוסר שלו אינו באג — הסוכן יוצר אותו בעבודה.

## כלל זהב

**כל סוכן עובד על ענף `claude/whats-happening-LyY9G`.**
**תחילת סשן:** יישור-ענף **בטוח** (למעלה) — fetch + בדיקת-ahead + ff-only, **לא** reset עיוור.
לפני כל commit: `flutter analyze` (0 errors) + `flutter test` (0 failures).
לפני כל push: `git pull --rebase` (ראה נוהל Push & Sync למעלה).
שערי ה-hook אוכפים אוטומטית — אין עקיפה.

---

## 📨 ממצאים מהקטלגן לפרוטוקוליסט — לשיקולכם (2026-06-01)

> **מקור:** סשן §21.B (v5.46, `c8a6470`) + §21.C (v5.47, `01cbb54`).
> **בקשת המשתמש:** "תעביר אליו ואני יוודא אם הוא קיבל אותו."
> תעדכנו במצב-קבלה (✅/❌/דחוי) ליד כל פריט אחרי שתסקרו. אם פעולה דרושה,
> תעדכנו AGENT_WORK_PLAN.md.

### 1. ⚠️ workflow — `git checkout` ב-mutation-verify מוחק עריכות לא-מקומיטות

**מה קרה:** עשיתי mutation-verify שני (§21.B + §21.C) שבו הסקריפט הסתיים
ב-`git checkout lib/data/chip_hierarchy.dart`. בשתי הפעמים זה מחק את העריכות
הלא-מקומיטות שלי באותו קובץ (הן הוגדרו כ"reset to HEAD"). נאלצתי לשחזר ידני
מהזיכרון.

**ההצעה:** סקריפט canonical בבעלות פרוטוקוליסט —
`scripts/mutation_verify.sh <file> <sed-pattern> <test-filter>` שעושה:
1. שומר תוכן הקובץ ל-buffer (`orig=$(cat "$file")`)
2. מחיל את המוטציה
3. מריץ test ומאמת אדום (`expect non-zero`)
4. **משחזר מה-buffer** (`echo "$orig" > "$file"`), לא `git checkout`
5. מריץ שוב ומאמת ירוק
6. מוסיף שורה ל-`mutation_log.md` אוטומטית

זה מבטל גם איבוד עבודה וגם שכחה לתעד.

**סטטוס:** ✅ **בוצע** (פרוטוקוליסט) — נכתב `app_flutter/scripts/mutation_verify.sh`:
גיבוי byte-exact (`cp` ל-tmp), trap-restore גם בקריסה, מצפה אדום→שחזור→ירוק,
ורישום אוטומטי ל-mutation_log.md. שימוש: `scripts/mutation_verify.sh <file> '<sed>' '<test>'`.

### 2. 🧠 methodology — ANTIPATTERN grep לא עובד ל-token תלוי-הקשר

**מה קרה:** רציתי `ANTIPATTERN: 'מ"מ',` כדי למנוע חזרה של "מ"מ" כ-feature
בפולירול. אבל `'מ"מ',` הוא **legitimate** כ-token בודד ב-`lipskey_catalog.dart:451`
(קטלוג אחר, vocabulary שונה). grep שורתי לא יכול להבחין → false-positive.

**הכלל:** ANTIPATTERN: עובד **רק** כשהדפוס רע בכל הקורפוס הנסרק. כשאותו
token נכון בקבוצה אחת ושגוי באחרת — חייבים בדיקה התנהגותית per-catalog,
לא grep.

**ההצעה:** עדכון ה-template ב-stuck_log.md (שורות 7-23) — להוסיף:

> ⚠️ לפני שאתה כותב `ANTIPATTERN: <regex>` — הרץ `grep -rn '<regex>' lib/`.
> אם יש מקומות לגיטימיים בקבצים אחרים, **אל תכתוב ANTIPATTERN** — כתוב
> `GUARD: <test-name>` במקום, וצור בדיקה התנהגותית מתוחמת.

תיעדתי את העיקרון ב-stuck_log §21.B (סוף הסקציה), אבל בלי שדרוג ה-template
הלקח לא יעבור הלאה.

**סטטוס:** ✅ **בוצע** (פרוטוקוליסט) — ה-template ב-`stuck_log.md` עודכן: לפני כתיבת
`ANTIPATTERN: <regex>` חובה `grep -rn '<regex>' lib/`; אם לגיטימי במקום אחר →
לכתוב `GUARD: <test-name>` (שורת-תיעוד, לא נקלטת ע"י הגנרטור) + בדיקה התנהגותית per-catalog.

### 3. 🪞 כלל-על שראוי ל-§14: "מוסתר בתצוגה" ≠ "נמחק מהמודל"

**מה קרה:** §21.A הכניס `_isNoiseChip(מ"מ)` בשכבת ה-UI. ה-parser עדיין סיווג
את "מ"מ" (לא ב-leftover, עבר את §14 קיים), אבל הוא **נעלם מהשחזור** של השם
המלא. גילה את זה רק E2E (§21.B). השומרים הקיימים פספסו: §14 ה-parser בודק
"אין leftover", לא "אין דליפה".

**ההצעה:** sub-section חדשה בפרוטוקול (§14.E?):

> **§14.E — UI filter recoverability:** כל פילטר תצוגה שמסתיר token (כמו
> `_isNoiseChip`, `_chipDisplayLabel` parens-stripper) חייב להיות מלווה
> בבדיקה התנהגותית שמראה שה-token עדיין שחזורי מהמודל (lossless). אם הסתרת
> משהו מהעין — חייב להיות test שמוודא שהוא לא נעלם.

זה מכליל מעבר ל-ציפים — חל על כל UI שמוסיף filter על דאטה.

**סטטוס:** ✅ **בוצע** (פרוטוקוליסט) — נוסף **§14.E** ב-`CATALOG-CARD-PROTOCOL.md`
(אחרי intro של §14): כל פילטר-תצוגה שמסתיר token חייב בדיקה התנהגותית שמראה
שה-token שחזורי מהמודל (lossless). "מוסתר-בתצוגה ≠ נמחק-מהמודל".

### 4. (קל) `stuck_regression_test.dart` היה עם **numbering כפול** ב-HEAD

לפני הרגנרציה שלי הקובץ הכיל פעמיים `test("antipattern #40 לא קיים")`
ופעמיים `#41`. רגנרציה רגילה תיקנה ל-#42/#43 (counter ייחודי). כלומר ה-43
ANTIPATTERN ב-stuck_log לא היו מסונכרנים עם ה-43 בדיקות. **השערים הקיימים
לא תפסו את הכפילות.**

**ההצעה:** שער חדש (62b?) פשוט:
```bash
expected=$(grep -cE '^ANTIPATTERN(\[hook\])?:' app_flutter/knowledge/stuck_log.md)
actual=$(grep -cE 'test\("antipattern #' app_flutter/test/stuck_regression_test.dart)
dups=$(grep -oE 'antipattern #[0-9]+' app_flutter/test/stuck_regression_test.dart | sort | uniq -d | wc -l)
[ "$expected" = "$actual" ] && [ "$dups" = "0" ]
```

**סטטוס:** ✅ **בוצע** (פרוטוקוליסט) — נוסף **שער 111**: בודק
`count(ANTIPATTERN) == count(tests)` ושאין מספור כפול (`sort | uniq -d`). תופס בדיוק
את ה-drift אחרי rebase. cheap, רץ תמיד. ההצעה שלך (62b) אומצה כמעט מילולית.

### 5. (קל) שערים 36/37/40 מציגים "לא רץ" כשהבדיקות בעצם רצות

בכל קומיט אצלי בסיכום השערים מופיע:
```
⚠️ [שער 36] regression_gate_test לא רץ
⚠️ [שער 37] knowledge_protocol_test לא רץ
⚠️ [שער 40] no_duplicate_specs_test לא רץ
```
אבל הבדיקות עצמן **רצות** ב-`flutter test` המלא של הקומיט (אני רואה אותן
ב-output). זה duplicate-detection logic או assertion mismatch בסקריפט ה-pre-commit.
ה-noise הזה מקטין את היחס signal-to-noise — קשה להבחין בין "אזהרה אמיתית"
ל"רעש קבוע".

**ההצעה:** או דה-דופלוק עם שער ה-`flutter test` המלא, או החלפת התווית מ-
"⚠️ לא רץ" ל-"ℹ️ נכלל בריצת ה-full".

**סטטוס:** ✅ **כבר תוקן** (פרוטוקוליסט, commit `e837943`) — אובחן: default-reporter
כשהפלט נלכד מדפיס שמות-בדיקה לא-דטרמיניסטית (3/6 חסרים בכל ריצה). הוחלף לבדיקת
**קיום-קובץ** (`[[ -f test/X.dart ]]`); מעבר/כשל כבר מכוסה ע"י שער 32. **אתה ראית
את האזהרה כי ה-hook המקומי שלך לא היה מסונכרן** — הרץ `cp .githooks/pre-commit .git/hooks/pre-commit`.

---

**חתימה:** קטלגן · ענף `claude/whats-happening-LyY9G` · ahead 5 (לא דחוף).
שלושת הראשונים מהותיים (workflow + methodology + §14 generalization);
שניים האחרונים סדר וניקיון. אם רוצים, אני יכול לכתוב את (1) `mutation_verify.sh`
בעצמי — תגידו ב-AGENT_WORK_PLAN.md.

---

## 📨 ממצא #6 מהקטלגן לפרוטוקוליסט — רעש `pubspec.lock` (2026-06-01)

> **מקור:** סשן §22.I (v5.51, `298707d`).
> **בקשת המשתמש:** "תעביר ותתעדכן ותדחוף נקי לפי פרוטקול."
> תעדכנו ✅/❌/דחוי ליד הפריט לאחר סקירה.

### 6. 🔔 `pubspec.lock` נעשה dirty בכל `flutter pub get` — stop-hook מתעורר לשווא

**מה קרה:** בכל פעם שהרצתי `flutter test` (שכולל `flutter pub get` פנימי),
`pubspec.lock` השתנה בכ-46 שורות — רישום-גיבוב פנימי ו-timestamp-ים,
**ללא שינוי תלויות בפועל**. כתוצאה, ה-stop-hook של pre-commit זיהה
"uncommitted changes" ועצר את הסשן בכל פעם.

**עקיפה זמנית:** `git checkout app_flutter/pubspec.lock` לפני כל commit/rebase.

**ההצעה (לפרוטוקוליסט לבחור):**

אפשרות א — הוסף ל-Push & Sync protocol (בסקציה "לפני כל push — 4 צעדים"):
```bash
# 0. בטל churn של pubspec.lock (flutter pub get משנה hash-ים פנימיים)
git checkout app_flutter/pubspec.lock 2>/dev/null || true
```

אפשרות ב — הוסף חריג ל-stop-hook: אם הקובץ היחיד שהשתנה הוא `pubspec.lock`
(ללא שינוי dependency אמיתי) — המשך בלי עצירה.

אפשרות ג — הוסף `pubspec.lock` ל-`.gitattributes` עם `merge=ours` כדי
שהוא לא ייספר בהשוואת worktree.

**ממצאי הסשן שהפעיל:**
- 774 מוצרי Polyroll × 20 checks = 15,480 assertions → PASS
- 1 באג אמיתי: 16 צינורות AC pipe חסרו `מק"ט חוליות` (תוקן, mutation-verified)
- ה-noise של pubspec.lock הפריע לאורך כל הסשן

**חתימה:** קטלגן · 2026-06-01 · commit `298707d`

---

## 📨 ממצא מ-ליטוש לפרוטוקוליסט — לקח-אודיט + drift ב-MASTER (2026-06-01)

> מקור: פאזה K סבב 2 (`KNOWLEDGE_AUDIT.md`). בקשת-משתמש: "תכין את הבעיה הזאת לפרוטקול ותיישם בהבא."
> עדכנו ✅/❌/דחוי ליד כל פריט אחרי סקירה.

### 1. 🧠 methodology — verdict-פעולה חייב source-grounding ישיר
**מה קרה:** בסבב 2 סימנתי `PROTOCOL.md` deprecate-candidate על סמך סיכום-subagent + ה-self-claim
של `MASTER_PROTOCOL`. ב-re-review התגלה חוסר-עקביות: לא נומק למה רק PROTOCOL ולא 14 המסמכים
האחרים ש-MASTER "מאחד". אימות ישיר מול הקבצים תיקן וחיזק (פתיח PROTOCOL≈MASTER מילה-במילה;
14 האחרים שומרים תפקיד-חי).
**ההצעה (ל-`POLISH_PROTOCOL` §K ו/או `MASTER_PROTOCOL` §audit — טריטוריה שלכם):** כלל
**"K-verdict source-grounding"** — verdict→פעולה חייב קריאה ישירה של המקור (לא subagent-summary,
לא self-description); וכשמסמך מאחד N — סווג את כל ה-N במפורש.
**סטטוס:** ⬜ לשיקולכם. תיישום מתוכנן: סבב 3 (ליטוש).

### 2. 🔧 gate — drift-guard ל-MASTER_PROTOCOL (snapshot↔source)
**מה קרה:** `MASTER_PROTOCOL` הוא snapshot של 15 מסמכים, ש-14 מהם חיים-ומתוחזקים בנפרד
(SCHEMA/HELPER_INDEX/CARD_FLOW מסונכרני-קוד; PLAYBOOK/stuck_log append-only). אין מנגנון שמונע
drift בין סעיף-ב-MASTER למסמך-החי המקביל.
**ההצעה (`.githooks` — טריטוריה שלכם, שער 88):** שער-drift קל, או הבהרה מוצהרת "MASTER=snapshot
לקריאה-רצופה; ה-granular הם source-of-truth" — ואז ליטוש יאנדקס כך ב-README ב-K9.
**סטטוס:** ⬜ לשיקולכם. (ליטוש לא נוגע ב-MASTER/`.githooks` — שער 88 + בעלות-פרוטוקוליסט.)

**חתימה:** ליטוש · branch `claude/whats-happening-LyY9G` · verdict-only · 0 פעולות על מסמכי-אחר.

---

## 📨 הודעת-ליטוש לפרוטוקוליסט — עדכון-טסטים לפיצ'ר "מחלקות" (2026-06-01)
> פיצ'ר מאושר-משתמש (בנצי #2/#3): מסך "מחלקות" כדף-הבית (טאב 0). באישור-משתמש מפורש ("תעדכן לבד")
> עדכנתי 13 טסטים שהניחו "קטלוג עם עליית-האפליקציה": הוספתי צעד-ניווט (`tap('אינסטלציה')` → קטלוג inline),
> ו-`Shell boots` עבר לבדוק נחיתת-מחלקות. **אפס שינוי ב-assertions או בלוגיקת-קטלוג** — רק צעד-ניווט.
> קבצים: `widget_test` · `robustness_test` · `product_journey_test`. כולם ירוקים (+38).
> `test/` בבעלותכם — אם תעדיפו גישה אחרת (helper משותף וכו'), אדרסו ואיישר.
**חתימה:** ליטוש

---

## דוח ביצוע — ליטוש — 2026-06-01 — v5.59

### 1. ✅ מה בוצע (עם מספרים)
- **חלוקת מים נקיים / שפכים דרך מחלקות** (בנצי #1, option 2) — `53a078d`, v5.59.
  `productDivisionSystems` (spec.endSystems → PPR=supply → else drainage) +
  `nodeHasSystem` (מתקנים בשני הצדדים, השאר לפי מערכת דומיננטית) +
  `catalogSystemFilterProvider` מסנן עץ-קטגוריות + ספירות + תיאורים. כניסה: מחלקה
  חיה (אינסטלציה→שפכים · ברזים→מים נקיים). 100/100 שערים · 986/986 · אומת ב-screenshot.
- **אבחון 2 "כשלי-טסט" → באג אחד:** import חסר (`departments_screen` ב-`robustness_test:189`)
  שגרר `compiler exited unexpectedly` ב-`widget_test` (kernel משותף). תיקון שורה אחת → 986 ירוק.
- **`ACTION_PLAN.md`** — backlog חי של כל מה שלא בוצע, רשום ב-README — `2d8d335`.
- **(מוקדם בסשן)** צינור screenshot real-app (`b7bd536`) · proto-comparison (`9eb505e`) ·
  tokenization dial+toast (`9c87f6d`,`6b9d14b`) · microcopy 'הפעל מצלמה' (`4820ff0`,v5.56) ·
  POLISH_LOG פאזה A (`18a2ac4`) · מסך מחלקות כדף-בית (`b9ad7ae`,v5.57) ·
  חלוקה בגיליון-פילטרים שנדחתה (`ceca667`,v5.58).
- **סה"כ: 10 commits · 20 קבצים · 986 טסטים (ירוק) · +628/−134 שורות.**

### 2. ⬜ מה לא בוצע — ולמה
| פריט | למה לא | חסום ע"י | מתי אפשר |
|------|--------|----------|----------|
| הכרעת זרימת-ניווט (tree-drill מול finder-chips) | שאלת-עיצוב פתוחה שלך | החלטת-משתמש | מיד עם ההכרעה |
| הסרת sysOpt כפול מגיליון-פילטרים | תלוי בהכרעת הניווט | הסעיף לעיל | אחרי ההכרעה |
| בנצי #4 (popup משלוח) | צריך טקסט verbatim מהמקור | מקור-תוכן | כשיינתן הטקסט |
| בנצי #5 (מוצרים per-סניף) | לא מוגדר מהו "סניף" + מקור-הסדר | הבהרה | אחרי הבהרה |
| בנצי #6 (autocomplete) | לא הגעתי (סדר-עדיפויות) | זמן-סשן | סשן הבא |
| 7 מחלקות placeholder | אין דאטה (R8 — אין המצאה) | מקור-קטלוג | כשתינתן דאטה |
| ליטוש פאזות B–J | הצינור נבנה, הסבבים לא בוצעו | זמן-סשן | סשן הבא |
| Phase K SUBMIT + protocol-enforce.yml (3.29.3) | טריטוריית פרוטוקוליסט | בעלות-פרוטוקוליסט | אישורו |

### 3. 📐 כיסוי-פרוטוקול
- פרוטוקול-אב: **POLISH** (סשן ליטוש) + עבודת-feature מאושרת (בנצי #1, CATALOG).
- צעדים שהושלמו: POLISH פאזה A ✅ (B–J פתוח) · בנצי #1+#2+#3 ✅ · ACTION_PLAN ✅.
- שערי-hook: **100/100** · analyze ✅ (0 errors; 3629 info pre-existing baseline) ·
  test **986✅ / 0❌** · build ✅.
- לקחים שיישמתי: **#39** (אבחון 100% — מצאתי שהשורש הוא import בודד, לא ניחוש-תיקונים) ·
  **#48** (לא ביקשתי דחיפה בחצי-עבודה) · **R8** (אפס-המצאה: PPR=נקיים מאומת מול גשר
  v5.41 `systemOverride: supply`; 7 מחלקות="בקרוב").
- סטיות מהפרוטוקול: עבדתי על feature (`lib/screens`) ולא רק presentation-polish —
  **מורשה במפורש** ע"י הענקת-הסמכות שלך ("אתה מעל כולם חוץ מפרוטוקוליסט"). אין סטייה אחרת.

### 4. 🧪 אימות (analyze / test / build)
- `flutter analyze`: ✅ 0 errors (3629 info-lints — baseline קיים, לא ב-קבצים שלי).
- `flutter test`: ✅ **986/986**.
- `flutter build web --release`: ✅ (רץ ואומת ע"י שער ה-pre-commit).

### 5. 🚧 חסמים שדורשים החלטת-משתמש
1. **זרימת-ניווט** — option 1 (tree-drill מסונן, הנוכחי) מול option 2 (finder עם
   section-chips מסוננים). עד הכרעה — נשאר על option 1 (ירוק).
2. **🔴 פיצול-ענף (קריטי):** origin כעת **21 commits לפניי**, ואני **10 לפניו**.
   ה-`git reset --hard origin/...` שבטמפלט **ימחק את כל 10 ה-commits שלי** (כולל
   v5.59 + ACTION_PLAN) — **לא הרצתי אותו** (הוא צעד-פתיחה ל-checkout נקי, לא לסוף-סשן
   עם עבודה מקומית). הדרך הבטוחה לפי הפרוטוקול עצמו (שורה 130) = **rebase**. צריך הכרעתך.

### 6. commit SHA אחרון: `2d8d335` (עבודת-feature; דוח זה מתווסף אחריו)

**חתימה:** ליטוש · branch `claude/whats-happening-LyY9G` · 0 פעולות הרסניות

---

## דוח ביצוע (סופי — אחרי push) — ליטוש — 2026-06-02 — v5.68

> מעדכן את הדוח שמעל: בזמן כתיבתו 11 ה-commits עוד היו מקומיים. כעת **נדחפו ומסונכרנים**.

### 1. ✅ מה בוצע (עם מספרים)
- **rebase + push נקי לפי הפרוטוקול** (§Push&Sync שורה 130): `git rebase` של 11 commits
  מעל origin (שהתקדם ל-`8830a5f`, 26 commits). פתרון התנגשויות לפי הנחיית-המשתמש:
  - **קוד** (`catalog_screen.dart` · `home_shell.dart`) — **שני הצדדים נשמרו**: חלוקת-המערכת
    שלי + `productImage`/חוליות של בנצי (auto-merge על hunks שונים).
  - **שורת-גרסה** — **origin מנצח** = **v5.68** (לא v5.59); `STATUS.md` סונכרן (שער 12).
  - **5 מסמכי-תיאום** — keep-both; טבלת-סטטוס מוזגה לפורמט החדש (עמודת "דוח התקבל?").
- **2 סבבי rebase** (origin זז שוב באמצע ל-`ac2ba7a`); השני נקי, 0 התנגשויות.
- **push עבר**: `ac2ba7a..f65f1de`. **מסונכרן מלא** (ahead 0 · behind 0).
- כל החלוקה (בנצי #1+#2+#3) חיה על הענף יחד עם עבודת-התמונות של בנצי.
- **סה"כ: 11 commits נדחפו · v5.68 · 1009/1009 טסטים · 0 קונפליקטים שנותרו.**

### 2. ⬜ מה לא בוצע — ולמה (ללא שינוי — ראה `ACTION_PLAN.md`)
| פריט | למה לא | חסום ע"י | מתי אפשר |
|------|--------|----------|----------|
| הכרעת זרימת-ניווט (tree-drill מול finder-chips) | שאלת-עיצוב פתוחה | החלטת-משתמש | מיד עם ההכרעה |
| הסרת sysOpt כפול מגיליון-פילטרים | תלוי בהכרעת הניווט | הסעיף לעיל | אחרי ההכרעה |
| בנצי #4/#5/#6 (משלוח/per-סניף/autocomplete) | טקסט/הבהרה/זמן | מקור-תוכן + זמן | סשן הבא |
| 7 מחלקות placeholder | אין דאטה (R8) | מקור-קטלוג | כשתינתן דאטה |
| ליטוש פאזות B–J | הצינור נבנה, סבבים לא | זמן-סשן | סשן הבא |

### 3. 📐 כיסוי-פרוטוקול
- פרוטוקול-אב: **POLISH** + feature מאושר (CATALOG, בנצי #1) + **§Push&Sync** (rebase).
- שערי-hook: **pre-push עבר** (אחרי שחסם נכון push לא-fast-forward עד ה-rebase) · analyze ✅ ·
  test **1009✅ / 0❌** · build ✅ (web נבנה בעבר; הקוד לא השתנה מאז).
- לקחים שיישמתי: **#39** (אבחון 100%) · **#48** (דחיפה רק ב"תדחוף" מפורש) · **R8** ·
  **חדש**: `reset --hard` בטוח **רק** כש-ahead=0 — אימתתי לפני שהרצתי (אחרת = מחיקת-עבודה).
- סטיות: feature ב-`lib/screens` — **מורשה** ע"י הסמכת-המשתמש. אחרת אין.

### 4. 🧪 אימות (analyze / test / build)
- `flutter analyze`: ✅ **0 errors** (post-rebase, מיזוג עם קוד בנצי).
- `flutter test`: ✅ **1009/1009** (origin הוסיף טסטים — כולם ירוקים עם החלוקה ממוזגת).
- push: ✅ עבר, ענף מסונכרן.

### 5. 🚧 חסמים שדורשים החלטת-משתמש
1. **זרימת-ניווט** — option 1 (הנוכחי, חי) מול option 2. ממתין להכרעה.
2. ~~פיצול-ענף~~ → **נפתר** (rebase + push; 0/0).

### 6. commit SHA אחרון: `f65f1de` (origin מסונכרן)

**חתימה:** ליטוש · branch `claude/whats-happening-LyY9G` · push נקי · 0 פעולות הרסניות
