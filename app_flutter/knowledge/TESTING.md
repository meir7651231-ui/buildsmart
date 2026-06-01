# Testing — ⛔ אוחד תחת VERIFICATION_PROTOCOL.md

> **המסמך הזה אוחד.** פרוטוקול-הבדיקה המלא והמאוחד חי עכשיו ב-
> **`VERIFICATION_PROTOCOL.md`** — שם נמצאים סולם-הבדיקה (L0–L7), שלוש השכבות
> (`flutter test` · in-app harness · mutation), השיטה הבטוחה למוטציה
> (`scripts/mutation_verify.sh` — backup byte-exact, **לא** `git checkout`),
> מרשם-המנגנונים המלא (חיווט · hooks · scripts · 10 דומיינים), וה-checklists.
>
> **אל תוסיף תוכן כאן.** הקובץ נשאר רק כדי לא לשבור הפניות
> (`knowledge_protocol_test.dart` אוכף את קיומו). כל עדכון → `VERIFICATION_PROTOCOL.md`.

## למה אוחד
~150 מסמכים נכתבו ב-11 ימים; הבדיקה התפזרה ל-4 קבצים. האיחוד מרכז הכל
ל-entry-point אחד כך שסוכן קורא מסמך אחד ויודע איך לוודא כל שינוי.
ה-verdict המלא של האיחוד: `KNOWLEDGE_AUDIT.md` (סבב 1).

## שלוש השכבות (תקציר — הפירוט ב-VERIFICATION_PROTOCOL §1)
1. **`flutter test`** — סוויטת-הרגרסיה (129 קבצים, 10 דומיינים) = ground-truth.
2. **in-app harness** (`runRegression`) — מודולים נבדקים בתוך-האפליקציה.
3. **mutation** — לוגיקת-דומיין חייבת 100% נתפסת; הזרק→אדום→שחזר→ירוק.
