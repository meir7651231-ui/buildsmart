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

49. **זיהוי retry לפי HEAD, לא רק שמות-קבצים.** `CURRENT_FP` (sha של שמות staged) לבדו ניתן להתחמקות: שינוי סט-הקבצים בין ניסיונות → חתימה חדשה → שער 102 לא נורה. תוקן: הרישום כולל `head=$HEAD_SHA`, וזיהוי retry = `fp==CURRENT_FP || rec_head==HEAD_SHA`. עיקרון: HEAD זז רק ב-commit מוצלח, אז "אותו HEAD + כשל קודם" = retry ודאי, ללא תלות בקבצים. תאימות-לאחור לרשומות ישנות בלי `head=`.

50. **baseline (known-failing) חייב שמות מאומתים — מספר בלבד = phantom מסוכן.** סוכן הגדיר `known-failing: 16` בלי לאמת; בפועל 927 ✅ / 0 ✗ — ה-16 phantom, ו-gate 32 היה בולע עד 16 רגרסיות אמיתיות בשקט. תוקן: `knowledge/known_failing.txt` מפרט שמות, שער 32 דורש שמספר-השורות = known-failing (אחרת חוסם), ומדפיס שמות-בדיקות שנכשלו. כלל: לעולם לא להגדיר baseline מספרי בלי לאמת אילו בדיקות נכשלות **ושהן באמת נכשלות** (`flutter test test/X.dart`).

51. **grep של emoji ב-hook חייב `-aF` (binary + fixed-string).** `grep -q "🟦"` נכשל תחת locale של git-commit ב-Windows/MSYS (כמו 81/103) — emoji 4-בייט + regex-engine + locale = לא-דטרמיניסטי. `-a` (binary-safe) + `-F` (fixed-string, byte-match בלי regex) = locale-independent. חל על שערים 23 (🟦) ו-109 (✅/⬜). הערה: לא משוחזר על Linux — fragility ספציפי-MSYS, אך עקבי עם הדפוס המתועד.

63. **יישור-ענף = `merge --ff-only` אחרי בדיקת-ahead, לעולם לא `reset --hard` עיוור.** (תפס: בנצי) שלב-הפתיחה שכתבתי ל-3 פרוטוקולים (לקח #60) אמר `git reset --hard origin/<branch>` כצעד-חובה. בסביבת ריבוי-סוכנים על ענף משותף זה **footgun הרסני**: הוא מוחק (א) commits מקומיים לא-דחופים של הסוכן עצמו, (ב) שינויים ב-staging, (ג) ויכול להשחית repo אם `.git/index.lock` פעיל (commit/hook רץ). בנצי קיבל הוראה לאפס, זיהה שיש לו commit פעיל + 2 commits לא-דחופים, **ועצר נכון** במקום לציית. תוקן ב-3 הפרוטוקולים + AGENT_COORDINATION: (1) בדוק `[[ -f .git/index.lock ]]` — אם כן, אל תיגע ב-git; (2) `git fetch` (לא-הרסני); (3) `git rev-list --left-right --count origin/<branch>...HEAD` — אם `ahead>0` או tree dirty → **עצור**, דחוף/שמור קודם; (4) רק אם נקי+ahead=0 → `git merge --ff-only` (זהה-תוצאה ל-reset, אפס-סיכון). כלל-על: **פקודה הרסנית (reset --hard / clean -fd / checkout שמדריס) בפרוטוקול-חובה חייבת precondition-check לפניה** — אחרת היא תמחק עבודה של מישהו, מתישהו. "אל תניח שהעץ שלך זהה לרימוט" (#60) הורחב ל"ואל תהרוס אותו כדי לאמת".

62. **בסיס-ידע בריא = בעיית-אינדקס, לא בעיית-כפילות.** (לקח-מתודולוגיה מ-ליטוש פאזה K) הציפייה לפני הביקורת היתה "150 מסמכים עם כפילות המונית" — הממצא: 76 מסמכים, רובם עם תפקיד-נבדל, ובעיה **אחת** אמיתית: האינדקס הצביע על 13/76 בלבד (27 יתומים). תיקון האינדקס (K9) פתר 95% מה"בלגן". **כלל:** לפני biased-audit ("הכל בלגן") — בדוק את ה-README index ראשון; יתומים ≠ כפילות ≠ מיותר.

61. **verdict 4-שדות לפני כל נגיעה במסמך-ידע — גם כשהתשובה ברורה.** (לקח-מתודולוגיה מ-ליטוש פאזה K) "למה נכתב · תפקיד היום · רלוונטי? · למה-כן/לא" — הכריח עצירה ו-explicit reasoning גם על מסמכים שנראו ברורים. 3 מקרים שהוכחו כ-"keep" רק אחרי ה-verdict (נראו כמיועדים-למחיקה מבחוץ): `AGENT_READINESS.md`, `adr/003-*`, `PROTOCOL.md`-גרעין. כלל: הכרעה-ב-verdict מונעת "מחיקה כי זה נראה ישן" — ה-4 שדות חייבים להיות כתובים, לא מחשבה-פנימית.

60. **לפני ש"קובץ חסר" — אמת ענף+SHA אחרי fetch; "אותו commit" לא מניחים.** ליטוש דיווח ש-4 מסמכי-הליבה (POLISH/VERIFICATION/KNOWLEDGE_AUDIT) "לא קיימים באף ענף" — ובצדק עצר במקום להמציא. השורש: הסשן שלו נפתח על ענף אחר (`determined-mendel-gSDiq`, שלא קיים על הרימוט) שנוצר **לפני** 8 ה-commits, ומעולם לא עשה fetch. הוא הניח "אותו commit בדיוק" בלי לאמת SHA — אבל הקבצים כן היו ב-`whats-happening-LyY9G@7ab5b57`. כללים: (א) **צעד-פתיחה לכל סשן = `git fetch origin claude/whats-happening-LyY9G && git checkout` אליו**, ולאמת `git rev-parse HEAD` מול הרימוט לפני כל עבודה; (ב) "קובץ חסר" = בדוק `git ls-tree -r origin/<branch> | grep`, לא רק את ה-working-tree המקומי; (ג) "שני ענפים זהים" = הוכח ב-`git ls-remote`, לא בהנחה; (ד) הבחן **תוצר-נוצר-תוך-כדי** (כמו `POLISH_LOG.md` שליטוש כותב בעצמו) מ**מסמך-קיים-מראש** — חוסר של הראשון אינו באג.

59. **אין מסמך-יתום + לא R בעבודה חדשה.** שני בלגנים שהתגלו יחד: (א) ~150 מסמכי-ידע נכתבו ב-11 ימים, כל סשן פתח חדש בלי לאנדקס → `README` הצביע על 13/75 (68% יתומים). כלל: מסמך-ידע חדש = שורה ב-`README` (אינדקס-אמת) **באותו commit**, ולפני יצירה — חפש קיים-לעדכון. (ב) R1–R9 (חוקי-ה-UI הישנים) זלגו לפרוטוקולים חדשים (בנצי/ליטוש) למרות שהם של `app/` הישן ולא רלוונטיים לעבודה החדשה — כי הם ב-`CLAUDE.md` שנטען כל סשן. כלל: אל תצטט R בעבודה חדשה; הכוונה (verbatim/regression) בשפה רגילה. הערה: R לא נאכף באף שער (דוקומנטרי בלבד); המקור שמחזיר אותו = `CLAUDE.md`. (R8/ProGuard = כלי-אנדרואיד, לא חוק.)

58. **מסמך שאוחד/הוחלף → stub נאכף-בשער, לא "שלט רך".** כשמאחדים פרוטוקול (4 מסמכי-בדיקה → `VERIFICATION_PROTOCOL`), השארת ה-deprecated כקובץ עם סיכום-תוכן מאפשרת לסוכן לפתוח אותו, "לבדוק לפיו", ולהגיד "בדקתי לפי הפרוטוקול" — בעוד בדק לפי המסמך הישן. גם מחיקה לא אופציה: `knowledge_protocol_test` אוכף קיום `TESTING.md` (>400 ת'), ושער 2 אוכף `TESTS_OVERVIEW.md`. תוקן: ה-stub רוקן לשלט ⛔ DEPRECATED טהור, ו**שער 112** אוכף שלוש תכונות — שורה-1 מכילה `DEPRECATED`, הקובץ מצביע ל-`VERIFICATION_PROTOCOL`, והוא ≤20 שורות (מונע זליגת-תוכן חזרה). כלל: סמכות-יחידה נאכפת במכונה, לא בנימוס — אחרת היא נשחקת חזרה לפיזור.

57. **`ANTIPATTERN:` רק לדפוס רע-בכל-הקורפוס; token תלוי-הקשר → `GUARD: <test>`.** (דיווח קטלגן) `ANTIPATTERN:` הופך ל-grep על כל lib/ — עובד רק כשהדפוס רע בכל מקום. token שלגיטימי בקטלוג אחד ושגוי באחר (`'מ"מ',` שגוי בפולירול, נכון ב-lipskey) → grep false-positive שחוסם commits תמימים. לפני כתיבת ANTIPATTERN: `grep -rn '<regex>' lib/`; אם יש מקום לגיטימי — `GUARD: <test-name>` + בדיקה התנהגותית per-catalog. נלווים: `scripts/mutation_verify.sh` (buffer-restore, לא `git checkout`) · שער 111 (count(ANTIPATTERN)==count(tests) + אין מספור כפול → תופס drift אחרי rebase) · §14.E ב-CATALOG-CARD ("מוסתר-בתצוגה ≠ נמחק-מהמודל" — פילטר-UI חייב test ל-lossless recoverability).

56. **שער 102 דורש תיעוד רק על retry של כשל code/test (31-45) — לא bookkeeping.** (דיווח Finder) קודם כל retry אחרי חסימה כפה stuck_log+ANTIPATTERN, גם כשהכשל היה bookkeeping טהור (12 version-sync / 24 WIRING / 59 path) — אבל אי-אפשר לכתוב ANTIPATTERN regex משמעותי ל"שכחתי לבמפ version", וה-gate עצמו תופס אותם שוב ממילא. תוקן: `err()` רושם את מספרי השערים שנכשלו, ה-fingerprint שומר `gates=v2:12,24`, ושער 102 דורש תיעוד רק אם כשל קודם כלל שער 31-45 (שם ה-gate גנרי → antipattern אנושי מוסיף ערך). פורמט ישן/לא-מזוהה → conservative (דורש). כלל: gate-משמעת שדורש תיעוד צריך לסווג את סוג-הכשל — לא לכפות regression-entry על כשל שאין לו antipattern משמעותי.

55. **שערים 35-40 — בדוק קיום-קובץ, לא הופעה בפלט flutter test.** (דיווח Finder) `flutter test` ב-default-reporter כשהפלט נלכד (לא-TTY) מדפיס את שמות קבצי-הבדיקה **לא-דטרמיניסטית** — 3/6 חסרים בכל ריצה → `grep -q "$critical" $TEST_OUT` = warn שגוי קבוע. גרוע מכך: הצורה הישנה דילגה כש-`[[ -f ]]` נכשל → התעלמה מהסיכון האמיתי (מחיקת בדיקה חיונית). תוקן: warn אם הקובץ **חסר**; מעבר/כשל כבר מכוסה ע"י שער 32 (FAIL_COUNT מול baseline). כלל: "האם בדיקה חיונית קיימת" = `[[ -f ]]`, לא grep על פלט reporter (לא-אמין כשנלכד).

54. **שער 103 חייב להחריג את `stuck_regression_test.dart` מסריקת ה-dart.** הקובץ המיוצר מכיל את *כל* האנטי-פטרנים by-construction (כל ANTIPATTERN → `RegExp(...)`). כל commit שמ-regen אותו עם שינוי רב-שורות (למשל escape-refactor) מכניס את כל 40 הפטרנים ל-diff כ-added lines → שער 103 יורה false-positive על אלה שתואמים את צורתם-שלהם (7 ירו אצלי). תוקן: `git diff --cached -- '*.dart' ':(exclude)*stuck_regression_test.dart'` — מקביל ל-self-exclude של הבדיקה (`contains('stuck_regression')`). כלל: קובץ-רישום אוטומטי שמכיל את הפטרנים שהוא בודק חייב self-exclusion בכל סורק (גם הבדיקה, גם ה-gate).

53. **גנרטור הרגרסיה — escape ל-Dart string רגיל, לא `r'''…'''`.** דווח (קטלגן): ANTIPATTERN שמתחיל/נגמר בגרש בודד `'` יוצר 4 גרשים רצופים בגבול של `r'''…'''` ⇒ שגיאת קומפילציה בקובץ המיוצר ⇒ **כל הסוויטה נשברת לכל הסוכנים** (landmine high-impact). תוקן: הגנרטור עושה escape (`\`→`\\`, `$`→`\$`, `'`→`\'`, בסדר הזה — backslash ראשון) ועוטף ב-string רגיל `'…'`. semantics נשמרים (`\$`→תו `$`→anchor/literal כמו ב-raw). כלל: כשמטמיעים תוכן משתנה בתוך מחרוזת קוד מיוצרת — escape דטרמיניסטי תמיד עדיף על delimiter-wrapping שמניח שהתוכן לא מכיל את ה-delimiter.

52. **emoji-match ב-hook = bash `case`/glob builtin, לא grep כלל (אפילו לא `-aF`).** לקח #51 (`-aqF`) **לא הספיק**: סוכן (מקבץ) דיווח ששער 23 עדיין נכשל תחת `git commit` למרות ש-`grep -aqF "🟦"` עובר standalone בכל locale. השורש: git-for-windows מחליף את ה-grep binary/PATH ב-invocation של ה-hook — כך שכל תלות ב-binary חיצוני היא לא-אמינה, ללא קשר ל-flags. תוקן (אותו class כמו 103): `while IFS= read -r _l; do case "$_l" in *🟦*) ...;; esac; done < file` — builtin טהור, אפס binary חיצוני, byte-match עקבי. **כלל-על:** בדיקת-תוכן ב-hook שצריכה להיות אמינה בכל סביבה (emoji/multibyte/untrusted) → bash builtin (`case`/glob/`[[ == ]]`), לעולם לא pipe ל-grep/echo חיצוניים. זה מאחד את 45/51/52 לעיקרון אחד.
