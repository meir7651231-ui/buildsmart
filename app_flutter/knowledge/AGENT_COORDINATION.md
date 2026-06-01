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
| פרוטוקוליסט | ✅ פעיל | 2026-06-01 | `2b6e429` |
| קטלגן | 🟦 ממתין | — | — |
| סדרן | 🟦 ממתין | — | — |
| מקבץ | 🟦 ממתין (שער 23 תוקן) | — | — |

---

## היסטוריית תיקוני hook (לסוכנים)

| תאריך | commit | שער | תיאור הבעיה | תיאור התיקון |
|--------|--------|-----|-------------|--------------|
| 2026-06-01 | `2b6e429` | 23, 109 | emoji `grep -q` נכשל ב-MSYS/locale | שונה ל-`grep -aqF` |
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

## כלל זהב

**כל סוכן עובד על ענף `claude/whats-happening-LyY9G`.**
לפני כל commit: `flutter analyze` (0 errors) + `flutter test` (0 failures).
שערי ה-hook אוכפים אוטומטית — אין עקיפה.
