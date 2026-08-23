# בעלות-סוכנים · קבצים-חמים · מלכודות

## הסוכנים (נכון ל-2026-06-03)
| סוכן | תחום | ודאות |
|---|---|---|
| **בנצי (משיק)** | השקה · R2/CDN · Google Play · אונבורדינג/זרימת-פתיחה | firsthand |
| **קטלגן** | assets · קרופי-חוליות · קטלוג · `home_shell` · store | firsthand (commits) |
| **פרוטוקוליסט** | הפרוטוקול · 100-שערים hook · `AGENT_COORDINATION.md` · לקחים | firsthand (hook) |
| מקבץ · הסדרן · ליטוש | (תחומים לא מאומתים) | לפי הודעת-הפרוטוקוליסט |

> ⚠️ "סוכן X אמר" בסבבי-ביקורת = לרוב **סימולציה** (הפרוטוקוליסט מקים sub-agent שמגלם פרסונה לפי דוח), **לא** הסוכן האמיתי. אין ערוץ-חי בין סוכנים — ראה `lessons.md`.

## קבצים-חמים (תפוס/claim לפני עריכה — P1)
- **`lib/screens/home_shell.dart`** — הקובץ-החם של הקטלגן, משתנה תכופות.
  - **מלכודת מאומתת (2026-06-03):** `test/widget_test.dart` בודק `find.byTooltip('BS')` + drilling של פרסונות ("BS dial opens 5 personas" / "Manager → לוח בקרה" / "Worker → headers"). שינוי ה-**tooltip** מ-`'BS'` שובר את 3 הבדיקות. פתרון: השאר `message: 'BS'` גם אם הלוגו פותח משהו אחר (הבורר עדיין עובד תחת tooltip 'BS').
- **`lib/main.dart`** — נקודת-החיווט הראשית (`home:`), tracked.

## מלכודות-שערים (100-hook)
- **gate 12/59 — גרסה ב-3 מקומות מסונכרנת:** מחרוזת `v5.XX` ב-`home_shell.dart` == `knowledge/STATUS.md` == build-number ב-`pubspec.yaml`. bump את שלושתם יחד. נדלק רק על שינוי ב-`lib/(screens|state|logic)`.
- **gate 24 — WIRING.md:** הוספת מסך/כפתור → חובה לעדכן `app_flutter/WIRING.md` (חוזה שנאכף ב-`wiring_test.dart`). (חסם commit ב-2026-06-03.)
- **gate 32 — בדיקות:** סוויטה מלאה; baseline `known-failing: N` ב-STATUS.md.
- **gate 92 — STATUS:** שינוי ב-`lib/state` → עדכן STATUS.md.
- שערים-מהירים רצים **לפני** הבדיקות (נכשל מוקדם → חוסך ~13 דק').
- docs בלבד (`knowledge/`, `*.md`) → לרוב לא מדליק את שערי-הגרסה/WIRING.

## git (זהירות-היסטוריה)
- **`git reset --hard origin` (+ `clean`) מוחק עבודה לא-מקומיט — tracked וגם untracked.** רק מה ש**נדחף ל-origin** שורד. (2026-06-03: נמחקה כל עבודת home_shell+main+הקבצים-החדשים; שוחזרה מגיבוי-חיצוני ב-`~/Desktop/benzi-backup`.)
- **pre-push חוסם force-push** → `git pull --rebase` ואז `git push`.
- הענף: `claude/whats-happening-LyY9G`. כולם דוחפים אליו (זה ערוץ-תקשורת בפני עצמו).
