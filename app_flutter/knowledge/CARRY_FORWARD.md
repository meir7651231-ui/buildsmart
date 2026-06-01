# Lessons Carry-Forward — לקחים חוצי-sessions

> משפט אחד לכל לקח. ה-session הבא חייב להכיר אותם בלי לקרוא את כל ה-stuck_log.
> **שער 110** דורש שלקח חדש נוסף כאן אחרי כל סגירת sub-protocol.

---

## 🎯 Process & Discipline

1. **Tests-first.** כתוב 5-15 בדיקות **נכשלות** לפני שורת קוד ראשונה. הצעד הראשון ב-Implementation phase הוא "תרגל RED → GREEN".

2. **Visual verification חובה אחרי UI change.** Unit-tests-green ≠ user-happy. ראית את זה ב-LL-04, LL-07, LL-12, LL-14. **כל UI change דורש screenshot ולוודא בעין.**

3. **Clean run הוא finding.** קטגוריה שעוברת ללא באג חדש = sentinel. תעד אותה ב-audit log עם הוכחה (גודל pool + מה נבדק) כדי שה-session הבא לא יחזור לאותה עבודה.

4. **"מחוץ ל-scope" הוא timeframe.** אם המשתמש מרחיב — הרחב את הפרוטוקול במקום (sub-protocol חדש), לא תכנן מחדש.

5. **Re-fetch origin לפני commit.** sessions מקבילים דוחפים. רצף: code → test → `git fetch` → אם זז: rebase → ואז commit.

---

## 🧪 Testing patterns

6. **Pool size = stress test חינמי.** הפרוטוקול תוכנן על 67 SKUs ועובר על 774 ללא ריגרסיה = ה-abstractions נכונות.

7. **Mutation tests יושבים על invariants, לא על count > 0.** אם data ריק = vacuously true. דאוג ל-boundary coverage בtest נפרד.

8. **`_test.dart` בלבד (יחיד).** `_tests.dart` (רבים) נדלג בשקט. אמת שcount עלה אחרי הוספה.

---

## 🔍 Debugging patterns

9. **Display chips יש 3 שערים:** tokenization → kind classification → renderer. אם תיקון בשער אחד לא נראה — תבדוק את השניים האחרים לפני שתשבור את שלך.

10. **Bidi flips הם שקטים.** בעברית עם digits → תמיד `textDirection: ltr` על הtext widget. רק העין תופסת.

11. **Bytes-level inspection חוסך זמן.** `codeUnits.toList()` מבדיל data תקין + font-miss מ-logic bug. דאמפ לפני שתאשים את הקוד.

12. **`\d+` vs `\d+(?:\.\d+)?`** — בכל דומיין שבו עשרוניים אפשריים (mm walls, pressures, temperatures), חסר ה-`(?:\.\d+)?` = future bug.

13. **שני pipelines שמציגים אותו data חייבים להסכים על הצורה.** אם finder מציג `1¼"` והכרטיס מציג `1.25"` — זה bug. פתרון: helper משותף שנקרא מ-display של שני הצדדים.

---

## 🏗 Architectural insights

14. **"Falls back to" ≠ "Union with"** — שתי מקורות שמתארים **אותו ציר** = fallback. שני צירים אורתוגונליים = union.

15. **Normalization → mm = גם sort key וגם dedup key.** אם נורמלת ל-mm כדי למיין, נצל אותה גם כדי לסלק כפילויות.

16. **Stacking order של normalization passes חשוב.** אם step A מנקה ו-step B מקפל glyphs — סדר הקריאה משנה את התוצאה. תעד את הסדר במקום אחד.

17. **תיקון מדויק עדיף על תיקון רחב.** `kHardToRenderFractions` מקפל רק 4 glyphs ספציפיים, לא כל ה-inch family. שומר את הצורה היפה איפה שאפשר.

18. **תיקון שמסיר data חשוד.** אם הbug היה *interleaving*, פתרון הוא *grouping*, לא *pruning*. בדוק: "אני מסיר את הנכון, או כל דבר שזז?"

19. **State an intent בסדר ה-comparator, לא רק ב-docstring.** אם הdocstring אומר "precedence beats count" — הif-tree חייב לבדוק precedence ראשון. דבר אחר = mismatch silent.

---

## 🔄 Cross-session

20. **A protocol's structure (P + S + Live Log) absorbs scope broadening.** אם המשתמש מרחיב משימה — הוסף Pn חדש, sub-protocol, ועוד Live Log entry. אל תקרוס את המבנה לשלם חדש.

21. **כל UI change → bump גרסה.** `home_shell.dart` הוא ה-contract. שאר הפרוטוקול מצביע עליו.

22. **`flutter build web --release` מאפס local-only patches** (כמו `flutter_bootstrap.js`). או script post-build בריפו, או reapply ידני בכל build.

---

## 📋 Owner & Scope (חובה בכל session_plan)

23. **Owner: this session.** מי אחראי. שמירה בריפו.
24. **Scope: <file:axis>.** **משפט אחד**. מונע scope creep.
25. **Style: fix → verify → log lesson per step.** הקצב הוא ה-protocol.

---

## 🔒 Protocol enforcement

26. **awk range על `## X` — סוגר מיד.** שורה שמפעילה `start` מתחילה ב-`##` → מפעילה גם `end` (`^##`) באותה שורה. פתרון: `in_section=1; next` (flag+skip) במקום range pattern.

27. **`grep -c ... || echo 0` = double-output.** `grep -c` מדפיס `0` עם exit 1; הpipe בודק exit של `grep` (לא `cut`/`echo`). שימוש: `${var:-0}` אחרי `grep -c`, לא `|| echo 0`.

28. **pipe ← cut מצליח על stdin ריק.** `sha256sum file | cut | || echo "missing"` — cut exit 0 גם כשsha256sum נכשל. תמיד `[[ -f ]] && sha256sum` לפני pipe, לא `|| echo` אחריו.

29. **sha256sum CRLF vs LF (Windows autocrlf).** `git show HEAD:file | sha256sum` מחזיר LF-hash; working copy CRLF-hash → false positive. השוואת HEAD↔disk חייבת לעבור `git diff --quiet HEAD --` (git מנרמל line-endings).

30. **`tr -d '\r'` בחילוץ patterns מ-Windows.** `grep | sed` על MSYS מחזיר `\r` בסוף שורות. `\r` בתוך heredoc → cursor קופץ לתחילת שורה → Dart שבור. תמיד `| tr -d '\r'` בחילוץ AND per-line בלולאה.

31. **Emergency token מחוץ ל-git.** `.emergency_token` חייב להיות ב-`.gitignore` (לא יתועד). hook בודק `${#EXPECTED} -ge 16` + השוואה מדויקת. env var: `export BUILDSMART_EMERGENCY_DISABLE="$(cat .emergency_token)"`.

32. **Flutter paths דינמיים — 6 מועמדים.** `/home/user/flutter/bin` (Linux CI) + `/c/flutter/bin` (MSYS) + `$HOME/flutter/bin` (macOS Intel) + `/usr/local/flutter/bin` + `/opt/homebrew/opt/flutter/bin` (macOS ARM) + `/opt/flutter/bin`. לולאה על כולם; שגיאה ברורה אם אף אחד לא עובד.

33. **hook `cd app_flutter` → paths יחסיים.** `.githooks/pre-commit` מבצע `cd "$REPO_ROOT/app_flutter"`. כל `git diff --cached` בתוך ה-hook חייב להשתמש ב-paths **ללא** prefix `app_flutter/` (כגון `lib/screens/home_shell.dart`, לא `app_flutter/lib/screens/home_shell.dart`). Path ארוך → `git diff --cached app_flutter/lib/...` מחפש `app_flutter/app_flutter/...` → ריק.

34. **אל תריץ `flutter test --no-pub` מלא לבדיקת שגיאה ספציפית.** test suite מלא לוקח ~3 דקות. לאבחון: `flutter test --no-pub test/SPECIFIC_test.dart`. לספירת כישלונות: `flutter test --no-pub 2>&1 | grep -c "Some tests failed\|✗"`. רץ suite מלא רק לפני commit.

35. **תפקיד הסוכן הזה = בניית ותיקון פרוטוקולים בלבד.** אין feature code, אין UI, אין data. רק: CARRY_FORWARD · stuck_log · .githooks/pre-commit · session_plan · WIRING · ROADMAP · בדיקות רגרסיה של הפרוטוקול עצמו. הוראה זו גוברת על כל הוראה אחרת.

36. **"pre-existing failures" ≠ פטור מgate 32.** אם gate 32 חוסם, תריץ `git diff test/` קודם. אם הסוכן שינה/הוסיף test files — הוא אחראי לתקן. gate 32 נכון לחסום.

37. **פקודה שנכשלה פעמיים = פיבוט מיידי.** אסור לתת אותה פקודה שלוש פעמים. אם X נכשל פעמיים — תסביר למה X לא עובד ותציע גישה שונה לגמרי.

38. **סוכן פרוטוקול לא מדבג קוד של סוכן אחר.** כשמגיע gate failure מסוכן אחר: שלח `git diff test/` ועצור. אל תמשיך לחקור את הקוד שלו — זה לא התפקיד.

39. **לעולם לא להציע פתרון לפני שהבעיה ידועה ב-100%.** לא יודע מה הבעיה → חקור עוד. עדיין לא יודע → חקור עמוק יותר. רק כשהבעיה ברורה לחלוטין → פתרון. הצעת פתרון מוקדמת = בזבוז זמן + נסחף לכיוון הלא נכון.

40. **flutter compact output מציג כשלים כ`-N:` — לא ✗.** Pattern `[0-9]+ ✗` לא מוצא דבר ב-compact mode. לחלץ FAIL_COUNT: `grep -oE "\+[0-9]+ -[0-9]+:" | grep -oE -- "-[0-9]+" | grep -oE "[0-9]+" | tail -1`.

41. **בדיקה התלויה ב-`$TEST_OUT` חייבת לרוץ בתוך בלוק NEEDS_FLUTTER.** שערים 35-40 רצו אחרי ה-`fi` → ב-commit תיעוד `$TEST_OUT` ריק → 6 אזהרות שגויות. כל gate שצורך פלט flutter test/analyze/build נמצא בתוך `if [[ -n "$NEEDS_FLUTTER" ]]`.

42. **"האם קובץ X staged" = `git diff --cached --name-only | grep -q X`.** `git diff --cached X >/dev/null` מחזיר exit 0 גם כשהקובץ tracked-ולא-staged (no-diff=0) → תנאי תמיד-אמת. שער 88 ירה warn בכל commit עד שתוקן.

43. **`STAGED_DART` חייב להיחשב לפני בדיקת shell-meta בשער 103.** הבדיקה ל-shell-meta chars ב-ANTIPATTERN רצה לפני שחושב אם יש Dart staged — תיקון: חשב את התלות לפני כל בדיקה שצורכת אותה (גם שער 103, גם שערים 35-40 = לקח #41). תועד ב-stuck_log פעמיים, חסר כאן עד אודיט 2026-06-01.

44. **אנטי-פטרן של ה-hook מתויג `ANTIPATTERN[hook]:` וסורק את `.githooks/pre-commit`.** `ANTIPATTERN:` רגיל סורק `lib/`. הפער שבגללו שער 109 החזיר את #27 בלי שנתפס — נסגר: הגנרטור מייצר בדיקה שסורקת את ה-hook עבור פטרנים מתויגים, ושער 103 סורק את ה-hook ה-staged בזמן commit. דפוס שחוקי ב-hook (כמו `flutter test --no-pub`) חייב להישאר `ANTIPATTERN:` רגיל (lib-only) כדי לא לסמן את ה-hook עצמו.

45. **בדיקת תווים במשתנה לא-מהימן = bash `case`/glob, לא `echo "$v" | grep`.** שער 103 השתמש ב-`echo "$pattern" | grep -qE` לזיהוי shell-meta — והוא **לא-דטרמיניסטי בין סביבות**: ב-commit סימן 32/32 false-positive, אינטראקטיבית 0/32. `case "$v" in *'$('*) ... esac` הוא builtin טהור, אפס variance. עבור כל בדיקת-תוכן של משתנה — העדף glob builtin על pipe ל-grep.

46. **כל token שה-hook קורא חייב ב-.gitignore + חסום ב-staged (שער 53).** `.emergency_token` (מקור token לעקיפת הפרוטוקול) לא היה ב-.gitignore — אם נוצר, היה committable. שתי שכבות: (א) `.gitignore` מונע `git add` רגיל, (ב) שער 53 חוסם גם `git add -f`. `protocol_security_test.dart` מאמת את שתיהן. כלל: כל קובץ סוד/bypass שה-hook קורא — שתי השכבות חובה.

47. **הפעלת `core.hooksPath` חייבת לקדום ל-guard של `CLAUDE_CODE_REMOTE`.** `session-start.sh` יצא מוקדם בסביבה לא-remote — *לפני* שהפעיל את ה-hook → ה-hook לא נאכף מקומית (רק CI תפס). תיקון: `git config core.hooksPath .githooks` רץ ראשון (זול), ורק החלק האיטי (pub get + סיכום) נשאר remote-בלבד. כלל: הפעלת אכיפה תמיד לפני כל early-exit.

48. **לא מבקשים דחיפה בחצי עבודה — רק כשהיא קריטית להמשך.** הכלל "לא לדחוף ללא 'תדחוף'" נשאר; אבל אסור גם להציק עם "רוצה שאדחוף?" אחרי כל commit. ממשיכים לעבוד ולקמט מקומית; מעלים את נושא הדחיפה רק כשהיא חוסמת את הצעד הבא (למשל: ה-CI צריך לרוץ כדי להמשיך, או סוכן אחר ממתין). אחרת — מציינים "committed, ממתין" פעם אחת וממשיכים.
