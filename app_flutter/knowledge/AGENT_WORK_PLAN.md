# תוכנית עבודה — פרוטוקוליסט

> תפקיד: בנית ותיקון פרוטוקולים בלבד — אין feature code, אין UI, אין data.
> ענף: `claude/whats-happening-LyY9G`

---

## עדיפויות קבועות (לכל סשן)

| עדיפות | פעולה |
|--------|--------|
| 1 | קבלת דוחות שגיאה מסוכנים אחרים → אבחון 100% לפי `BUG_INVESTIGATION_PROTOCOL.md` |
| 2 | תיקון שערי hook שנכשלים |
| 3 | עדכון `stuck_log.md` + `CARRY_FORWARD.md` |
| 4 | עדכון `STATUS.md` + `known_failing.txt` |
| 5 | דחיפה רק לאחר: build נקי + 100 שערים עוברים + 0 שגיאות |

---

## תהליך קבלת באג מסוכן אחר

```
1. קבל את שגיאת הסוכן (שם שער + הודעת שגיאה מדויקת)
2. קרא BUG_INVESTIGATION_PROTOCOL.md שלבים 1–55 (אבחון בלבד)
3. רק אחרי שלב 55 — הצע פתרון
4. תקן ב-.githooks/pre-commit
5. סנכרן ל-.git/hooks/pre-commit
6. הרץ flutter test (כולם עוברים)
7. הוסף ANTIPATTERN ל-stuck_log.md
8. עדכן CARRY_FORWARD.md + לקח ממוספר
9. הרץ scripts/generate_stuck_regression.sh
10. commit + push
11. שלח לסוכן: הסוכן ← commit SHA + מה תוקן
```

---

## סדר עבודה בסשן

### שלב 1 — תחילת סשן
- [ ] קרא `STATUS.md` — מה הגרסה הנוכחית ומה פתוח
- [ ] קרא `CARRY_FORWARD.md` — לקחים אחרונים
- [ ] קרא `stuck_log.md` — אנטיפטרנים ידועים
- [ ] הרץ: `cd app_flutter && flutter test` — וודא 0 כשלים

### שלב 2 — טיפול בדרישות נכנסות
- [ ] פרסר את שגיאת הסוכן (מה השער, מה הקוד, מה ההודעה)
- [ ] אבחן 100% — אל תציע פתרון לפני שלב 55
- [ ] תקן → בדוק → commit → push

### שלב 3 — סוף סשן
- [ ] וודא `STATUS.md` מעודכן
- [ ] וודא `known_failing.txt` תואם `STATUS.md`
- [ ] וודא `CARRY_FORWARD.md` מכיל לקח לכל תיקון
- [ ] וודא `.git/hooks/pre-commit` מסונכרן
- [ ] push נקי

---

## פריטים פתוחים

| # | פריט | סטטוס |
|---|------|--------|
| A | תגובות לשגיאות מסוכנים | ממתין לדרישות |
| B | מיזוג ל-main (PR #4) | ממתין לאישור משתמש מפורש |
| C | Group B: שערים 86/88/90 | לא התחיל |

---

## פעולות שבוצעו מ-5 הממצאים של קטלגן (2026-06-01)

| # | ממצא | פעולה | מיקום |
|---|------|--------|--------|
| 1 | git checkout במוטציה מוחק עריכות | ✅ נכתב `scripts/mutation_verify.sh` (buffer-restore) | scripts/ |
| 2 | ANTIPATTERN grep ל-token תלוי-הקשר | ✅ template עודכן (`grep -rn` לפני + `GUARD:` חלופי) | stuck_log.md header |
| 3 | "מוסתר-בתצוגה ≠ נמחק-מהמודל" | ✅ נוסף §14.E | CATALOG-CARD-PROTOCOL.md |
| 4 | stuck_regression numbering כפול | ✅ נוסף שער 111 (count + dup check) | .githooks/pre-commit |
| 5 | שערים 36/37/40 "לא רץ" | ✅ כבר תוקן (`e837943`) — קטלגן צריך sync hook מקומי | — |

לקח #57 ב-CARRY_FORWARD מסכם את 1–4.

---

## כללים קריטיים לסוכן זה

- **לא feature code, לא UI, לא data** — רק hook/knowledge/tests
- **לא מבקשים דחיפה בחצי עבודה** (לקח #48)
- **אבחון 100% לפני פתרון** (לקח #39)
- **פקודה שנכשלה פעמיים → פיבוט** (לקח #37)
- **emoji grep = `-aqF` תמיד** (לקח #51)
