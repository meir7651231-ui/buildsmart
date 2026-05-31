# אכיפת הפרוטוקול — מבט כללי

> 4 שכבות אכיפה, 105 שערים, 8 בדיקות regression אוטומטיות.

---

## ארבע שכבות

### שכבה 1 — Git hooks מקומיים (`.githooks/`)
| Hook | מטרה | רץ ב |
|------|------|------|
| `pre-commit` | 105 שערים — כל הבדיקות לפני שמירה | `git commit` |
| `commit-msg` | מינימום 15 תווים + חסימת hodעות-זבל | `git commit` |
| `pre-push` | חסימת push ל-main, force push, commits עם הודעה ריקה | `git push` |

**הפעלה:** `git config core.hooksPath .githooks`

### שכבה 2 — Claude Code hooks (`.claude/hooks/`)
| Hook | מטרה |
|------|------|
| `session-start.sh` | משחזר hooks אוטומטית בתחילת כל session + סיכום מצב |
| `pre-tool.sh` | חוסם Bash/Edit/Write/NotebookEdit על קבצי הגנה ופקודות עקיפה |

ה-matcher ב-`.claude/settings.json`: `Bash|Edit|Write|NotebookEdit`.

### שכבה 3 — שחזור אוטומטי
`session-start.sh` רץ בכל פתיחת session:
1. מפעיל `core.hooksPath` ל-`.githooks`
2. מחזיר הרשאות executable לכל ה-hooks
3. מציג סיכום פרוטוקול

### שכבה 4 — GitHub Actions (`.github/workflows/protocol-enforce.yml`)
שכבה חיצונית שלא ניתן לעקוף מקומית:
- רץ על כל push וכל PR
- מפעיל את 7 השערים הקריטיים
- **דורש הגדרה ידנית ב-GitHub UI** (ראה למטה)

---

## הגדרת Branch Protection (חובה!)

> ⚠️ **התיקון לבאג #25** — ה-workflow רץ אוטומטית אבל לא חוסם merge עד שמגדירים branch protection.

### צעדים ידניים ב-GitHub UI:

1. עבור ל-**Settings → Branches** של הריפו
2. **Add rule** ל-`main`:
   - ☑ Require status checks to pass before merging
   - ☑ Require branches to be up to date before merging
   - בחר את `protocol-gates` כ-required check
   - ☑ Do not allow bypassing the above settings
3. שמור
4. הוסף rule נוסף לענפי feature (אופציונלי):
   - Pattern: `claude/**`
   - Require linear history

---

## שערי הפרוטוקול — סיכום

| קבוצה | שערים | קצב הרצה |
|--------|-------|----------|
| א — יסודות | 1-10 | מהיר (5sec) |
| ב — מצב | 11-20 | מהיר |
| ג — תכנון | 21-30 | מהיר |
| ד — בדיקה | 31-45 | **איטי (3-5min)** — רק אם השתנה `.dart`/`.yaml` |
| ה — איכות | 46-60 | מהיר |
| ו — שפה | 61-75 | מהיר |
| ז — דחיפה | 76-90 | מהיר |
| ח — סופי | 91-100 | מהיר |
| ט — למידה | 101-105 | מהיר |

**Tiered execution (תיקון באג #19):** commits של תיעוד בלבד מדלגים על flutter analyze/test/build. זמן ירד מ-3-5 דקות ל-5 שניות.

---

## וקטורי עקיפה חסומים

| וקטור | חסום ב | תיקון |
|--------|--------|-------|
| `--no-verify` | pre-tool.sh | #1 |
| `-c core.hooksPath=` | pre-tool.sh | #2 |
| `--force-with-lease/--force-if-includes` | pre-tool.sh | #3 |
| `rm/mv/find -delete/unlink/cp/sed` על hooks | pre-tool.sh | #4 |
| aliases מסוכנים | pre-tool.sh | #5 |
| `eval` של git | pre-tool.sh | #5 |
| Edit/Write על `.githooks/` | pre-tool.sh | #34 |
| Edit/Write על `.git/config` | pre-tool.sh | #34 |
| Edit/Write על `.claude/settings.json` | pre-tool.sh | #34 |
| push ל-main ללא אישור | pre-push | #23 |
| force push | pre-push | #23 |
| commits עם הודעה קצרה | commit-msg | #26 |
| הסרת secrets/keys מ-.gitignore | gate 70 | #27 |
| hook עצמו שונה | gate 81 (hash check) | #9 |

---

## bypass מאושר — `.allow_protocol_edit`

עריכת קובץ הגנה דורשת קובץ `.allow_protocol_edit` ב-repo root עם תוכן ההוראה.
- **הקובץ ב-.gitignore** — לא נדחף ל-origin
- כל עקיפה נרשמת ל-`.git/protocol_audit.log`

---

## תרשים זרימה

```
שינוי קוד
    ↓
PreToolUse (Bash/Edit/Write) ← חוסם 10 וקטורי עקיפה
    ↓
git commit
    ↓
commit-msg hook ← בודק הודעה (15+ תווים, לא wip/test/asdf)
    ↓
pre-commit hook ← 105 שערים
    ├─ קל (5sec): קבצי ידע, גרסאות, ענף, hooks integrity
    └─ כבד (3-5min, רק לקוד): analyze + test + build
    ↓
שמירה מקומית ✅
    ↓
git push
    ↓
pre-push hook ← לא ל-main, לא force, הודעות תקינות
    ↓
דחיפה לשרת
    ↓
GitHub Actions ← אותם 7 שערים בשרת
    ↓
[אם branch protection מוגדר] merge חסום אם נכשל
```

---

## הוספת בדיקה רגרסיה חדשה

1. תקן באג
2. עדכן `knowledge/stuck_log.md`:
   ```
   ## YYYY-MM-DD · תיאור
   ANTIPATTERN: regex_שמזהה_את_הבעיה
   RULE: כלל בעברית
   ```
3. `bash app_flutter/scripts/generate_stuck_regression.sh`
4. ה-test החדש ירוץ אוטומטית בכל `flutter test` — לנצח.

---

## מצב נוכחי (לבדיקה מהירה)

```bash
bash app_flutter/scripts/audit_gates.sh
```
