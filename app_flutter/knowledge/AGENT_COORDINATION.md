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

## כלל זהב

**כל סוכן עובד על ענף `claude/whats-happening-LyY9G`.**
לפני כל commit: `flutter analyze` (0 errors) + `flutter test` (0 failures).
שערי ה-hook אוכפים אוטומטית — אין עקיפה.
