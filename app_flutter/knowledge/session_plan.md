# תכנון session נוכחי

## הצעד הנוכחי

**batch תיקונים שני (P1):**
- #11 — shell injection ב-gate 103
- #16 — gate 52 secrets regex שגוי
- #9 — hook integrity flaw
- #14 — gate 26 over-broad
- #15 — print() check רדוד
- #18 — gate 60 לא מבחין dev deps
- #29 — paths קשיחים
- #25 — תיעוד branch protection
- #23 — pre-push חלש
- #27 — .gitignore hide sensitive

**סטטוס:** 🟦 בתהליך

## שאלת פתיחה

**מה:** סגירת 10 באגים P1 שנותרו אחרי batch הראשון
**מקור:** החקירה המעמיקה
**שינוי:** pre-tool.sh + pre-commit + pre-push + .github/workflows + README

## 10 תת-צעדים

1. סגירת shell injection (gate 103) — quote pattern
2. תיקון regex של secrets (gate 52)
3. חיזוק hook integrity (hash מ-commit, לא מ-disk)
4. צמצום gate 26 לקבצי test/ בלבד
5. הרחבת gate 48 (print) לכל הקובץ
6. הפרדה בין dependencies ל-dev_dependencies
7. paths דינמיים (which/PATH search)
8. README.md ל-branch protection
9. pre-push: לבדוק שכל commit עבר pre-commit
10. שמירת .gitignore canonical
