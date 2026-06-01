# תיאום סוכנים — BuildSmart

> עדכון אחרון: 2026-06-01 · גרסה v5.43 · ענף `claude/whats-happening-LyY9G`

---

## 4 הסוכנים

| סוכן | תפקיד | מה מותר | מה אסור |
|------|--------|----------|----------|
| **פרוטוקוליסט** | בנית ותיקון פרוטוקולים | `.githooks/`, `knowledge/`, `test/` | feature code, UI, data |
| **קטלגן** | עריכת קטלוגים | `lib/data/`, `assets/` | שינוי פרוטוקולים |
| **סדרן** | עריכה ויזואלית | `lib/ui/`, `lib/widgets/` | שינוי פרוטוקולים |
| **מקבץ** | בניית פיצ׳רים חדשים | `lib/features/`, `lib/screens/` | שינוי פרוטוקולים |
| **משיק** | הכנת-קרקע להשקה (audit ארכיטקטורה/ניקיון/פערים/חנויות) | audit קריאה-בלבד; תיקונים בטוחים; `knowledge/LAUNCH_READINESS.md` | refactor/ניווט/מחיקה רחבה בלי אישור; שינוי פרוטוקולים |

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

## טמפלט דוח ביצוע — כל סוכן

```markdown
## דוח ביצוע — [שם סוכן] — [תאריך]

### מה בוצע
- 

### קבצים שעודכנו
- 

### בדיקות
- flutter test: ✅/❌
- flutter analyze: ✅/❌

### בעיות שנתקלתי בהן
- 

### מה נשאר לסשן הבא
- 

### commit SHA
`xxxxxxx`
```

---

## טבלת סטטוס עדכני

| סוכן | סטטוס | סשן אחרון | commit אחרון |
|------|--------|------------|--------------|
| פרוטוקוליסט | ✅ פעיל | 2026-06-01 | (ראה למטה) |
| קטלגן | 🟦 ממתין | — | — |
| סדרן | 🟦 ממתין | — | — |
| מקבץ | ✅ שוחרר (שער 23/109 תוקן ב-bash builtin) | 2026-06-01 | lens step 2/3 |
| משיק | 🟦 חדש — פרוטוקול מוכן (`LAUNCH_READINESS_PROTOCOL.md`) | 2026-06-01 | — |

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
- **`lib/`** — מחולק לפי תפקיד (קטלגן=data, סדרן=ui/widgets, מקבץ=features/screens, משיק=audit). אם שניים צריכים אותו קובץ — תאמו דרך המשתמש.

### תדירות push
- **תיקוני-hook קריטיים (פרוטוקוליסט)** → push מיד אחרי אימות (סוכנים חסומים מחכים).
- **feature commits** → אפשר לצבור 2-3 ולדחוף יחד (פחות סבבי-rebase לאחרים).
- **בתחילת סשן עבודה** → `git pull --rebase` ראשון, תמיד.

---

## כלל זהב

**כל סוכן עובד על ענף `claude/whats-happening-LyY9G`.**
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

**סטטוס:** ⬜ ממתין לפרוטוקוליסט

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

**סטטוס:** ⬜ ממתין לפרוטוקוליסט

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

**סטטוס:** ⬜ ממתין לפרוטוקוליסט

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

**סטטוס:** ⬜ ממתין לפרוטוקוליסט

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

**סטטוס:** ⬜ ממתין לפרוטוקוליסט

---

**חתימה:** קטלגן · ענף `claude/whats-happening-LyY9G` · ahead 5 (לא דחוף).
שלושת הראשונים מהותיים (workflow + methodology + §14 generalization);
שניים האחרונים סדר וניקיון. אם רוצים, אני יכול לכתוב את (1) `mutation_verify.sh`
בעצמי — תגידו ב-AGENT_WORK_PLAN.md.
