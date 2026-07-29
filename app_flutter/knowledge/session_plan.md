# Session Plan — תשתית ארכיטקט: סביבה + שערים + אפס אזהרות

Owner: this session (architect-minimum-100-percent)
Scope: תשתית ריפו (scripts/, .claude/, CLAUDE.md, .gitignore) + ניקוי כל 33 אזהרות analyze
Style: audit (workflow 6 סוכנים) → build infra → fix warnings (workflow 8 סוכנים) → verify מלא → commit

## שלבים
1. ✅ baseline מאומת: Preact 21/21 smoke · Flutter 986 טסטים · maor 479 טסטים
2. ✅ scripts/bootstrap-env.sh + verify-flutter.sh + verify-preact.sh + FLUTTER_VERSION
3. ✅ session-start.sh — bootstrap אוטומטי (bypass מאושר, הוראת משתמש מפורשת)
4. ✅ CLAUDE.md/README עדכניים (ענף, INSP-0044, baseline אמיתי)
5. ✅ אפס אזהרות: 10 dart fix אוטומטי + 23 ידני (מחיקת קוד מת, טיפוסים מפורשים)
6. 🟦 commit דרך כל השערים + push לענף claude/architect-minimum-100-percent-ctk3w5

## כללי בטיחות
- כל commit דרך השערים המלאים — בלי עקיפות
- מחיקה-בלבד בקוד מת; אפס שינוי התנהגות; הסוויטה המלאה ירוקה לפני commit
