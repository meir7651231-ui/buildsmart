# תכנון session נוכחי

> קובץ זה חייב להיות מעודכן לפני כתיבת קוד כלשהו.

## הצעד הנוכחי

**מספר תיקון:** #34 (הקריטי ביותר)
**שם:** חסימת Edit/Write לקבצי הגנה
**סטטוס:** 🟦 בתהליך

## שאלת פתיחה

**מה:** Claude יכול לעקוף את כל ה-hooks על-ידי שימוש ב-Edit/Write על:
- `.githooks/pre-commit` — להריק את הקובץ
- `.git/config` — לשנות `core.hooksPath`
- `.claude/settings.json` — להסיר hooks
- `.claude/hooks/pre-tool.sh` — להפוך לריק
- `.github/workflows/protocol-enforce.yml` — להסיר workflow

**מאיפה הנתונים:** PreToolUse hook עם `matcher: "Edit|Write"`

**שינוי נדרש:** `.claude/settings.json` — להוסיף matcher חדש שמפעיל את `pre-tool.sh` גם על Edit/Write

**בדיקה שתוכיח:** ניסיון Edit על `.githooks/pre-commit` → נחסם

**מה חסום:** אין

## 10 תת-צעדים

1. דרישה: pre-tool.sh חוסם Edit/Write לקבצי הגנה
2. מקורות נתונים: tool_input.file_path
3. patterns קיימים: pre-tool.sh כבר מעבד Bash
4. עיצוב: בדוק את `file_path` או `tool_input.file_path` מ-jq
5. כתוב בדיקה: ניסה Edit/Write על קובץ הגנה ← נכשל
6. מימוש: הוסף סעיף ב-pre-tool.sh + matcher ב-settings.json
7. flutter analyze → לא רלוונטי (shell)
8. wire: עדכון settings.json
9. בדיקות ירוקות: audit_gates + ניסיון אמיתי
10. עדכן: stuck_log + commit
