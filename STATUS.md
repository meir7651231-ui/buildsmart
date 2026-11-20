# BuildSmart — STATUS

_עודכן: 2026-11-19 · ענף אחרון שמוזג ל-main: `claude/whats-happening-LyY9G` (PR #58, 2026-08-24)._
_יומן גרסאות מפורט ותווית הגרסה: `app_flutter/knowledge/STATUS.md` (כרגע **v7.02**)._

## מצב נוכחי
| רכיב | מצב | אימות בסשן זה (2026-11-03) |
|---|---|---|
| `app_flutter/` (Flutter, הפעיל) | 🟢 חי ב-buildsmart-il.com · Android AAB/APK ב-CI · iOS טרם נבנה | analyze: **0 errors** (56 warnings, infos) · tests: **6034 ✅ · 0 ✗ · 12 skip** (Flutter 3.44, ~18 דק׳) |
| `app/` (Preact legacy) | 🟡 GitHub Pages, תיקוני באגים בלבד | typecheck ✅ · build ✅ · smoke **21/21** ✅ |
| `functions/` | 🟢 me-west1, gen2 | typecheck ✅ · selftest **100/100** ✅ |
| קטלוג (`scripts/catalog_qa.py`) | 🟢 | selftest ✅ · audit: אפס שגיאות חוסמות ✅ |

עבודה אחרונה שנכנסה (אוגוסט 2026): dark-mode waves 1–16 (מסכים theme-aware), server-sync ל"ניהול מסך"
(`SCREEN_SECTIONS_LIVE`, ברירת-מחדל OFF), הכרטיס הפנימי באנדרואיד (v7.02), תיקון אישור-הבעלים (v7.01).

## בעיות פתוחות
1. **🔴 Dark mode — רגרסיית טקסט (התגלתה 2026-11-19).** גלים 1–16 המירו רק משטחים; הטקסט נשאר `BsTokens.inkLight` קבוע ⇒ במצב
   כהה כותרות בלתי-נראות (~1:1, אומת בצילום). **פיילוט תוקן** (10 מסכים + `AiOffState`/`AiFailedState`, helpers `bsInk`/`bsMuted`/`bsDangerText`,
   גארד `test/dark_mode_ink_test.dart`). **גל 2 (2026-11-20):** +17 קבצים (copilot · studio · consent · role_picker · audit …), גארד 68.
   **נותר:** ~78 קבצים · ~1,400 אתרי ink קבוע + atlas משטחים 45 + קבועי `_ink` ברמת-קובץ (budget/install_studio/stock).
2. ~~smoke-settings מקודד נתיב Chromium~~ — ✅ תוקן 2026-11-19 (איתור אוטומטי + `PW_CHROMIUM`). נותר: להכניס ל-CI.
3. **פער גרסאות Flutter ב-CI** — `protocol-enforce.yml`/`catalog-qa.yml` על 3.29.3, build/deploy על 3.44.0; `flutter analyze` ב-3.44 מציג 56 warnings (לא חוסם).
4. **הוראות סשן ישנות** — הענף `claude/whats-happening-LyY9G` עדיין מפעיל deploy לפרודקשן בכל push (`web-deploy.yml`, `firebase-hosting.yml`, `firebase-deploy.yml`); מסמכי `orchestrator/`/`knowledge/` עדיין מפנים אליו כענף העבודה.
5. **PRs פתוחים לא מטופלים** — [#59](https://github.com/meir7651231-ui/buildsmart/pull/59) (הצלת נכסי-ענפים ל-`rescue/`) ו-[#5](https://github.com/meir7651231-ui/buildsmart/pull/5) (`.gitignore` ל-`.claude/`) — ממתינים להחלטת מאיר.
6. **השקה בחנויות** — iOS: אין signing/build (דורש Mac/CI); חשבונות Apple/Google + privacy-policy עדיין פתוחים (`app_flutter/knowledge/LAUNCH_READINESS.md`).
7. **Spec מיושן** — `app_flutter/knowledge/spec/shell-and-dials.md` §7 עדיין מתאר dials וטאבים שהוסרו (היום: בית · מחלקות · עדכונים · חנות). לעדכן.
8. **ניגודיות פלטת-המותג (החלטת-עיצוב)** — לבן על כתום-המותג 3.05:1 בכפתורים ראשיים, כתום-על-כהה 2.87:1, chips צבעוניים ~2.6–3.7:1 (מתחת ל-AA 4.5). high-contrast מכסה חלק; ברירת-המחדל דורשת החלטה של מאיר.

## Next (3–5 משימות הבאות)
1. **להשלים dark mode (טקסט + משטחים)** — codemod בגלים של 8–10 קבצים לפי דפוס הפיילוט (`bsInk`/`bsMuted` + הסרת const),
   כל גל מוסיף את מסכיו ל-`dark_mode_ink_test.dart`; עדיפות ל-manager_copilot (כותרת בלתי-נראית) ולמסכים הנפוצים.
2. **smoke ב-CI** — הנתיב תוקן; להוסיף job שמריץ build + smoke 21/21 על PR (שינוי workflow — באישור מאיר).
3. **ליישר CI ל-Flutter 3.44.0** בכל ה-workflows ולנקות את ה-warnings של analyze (דורש אישור — `protocol-enforce.yml` קובץ מוגן).
4. **החלטה על ענף ה-deploy** — להעביר את הטריגרים של הפרודקשן ל-`main` בלבד (באישור מאיר) ולעדכן את המסמכים.
5. **iOS build ב-CI** (macOS runner) + השלמת P0 של `LAUNCH_READINESS.md` לקראת הגשה לחנויות.
