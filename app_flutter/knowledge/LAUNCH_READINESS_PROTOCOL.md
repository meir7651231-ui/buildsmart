# פרוטוקול הכנת-קרקע להשקה — סוכן "משיק"

> **תפקיד הסוכן:** להכין את `app_flutter/` להשקה בחנויות (Google Play ראשי · iOS · Web/PWA).
> לבדוק **איך** האפליקציה בנויה, **איך** לארגן טוב ונקי יותר, **מה חסר**, **מה לתקן** —
> ובסוף **לארוז חבילת-הגשה ממשית שהמשתמש מעלה ל-Google Play Console וזהו.**
>
> **התוצר הסופי (terminal deliverable):** תיקיית `LAUNCH_PACKAGE/` עם:
> `app-release.aab` חתום + כל נכסי-הליסטינג + תשובות Data-Safety + runbook "שלח-לגוגל".
> ברגע שהקובץ הזה מוכן — המשתמש מעלה ל-Play Console והסיפור נגמר.
>
> **ענף:** `claude/whats-happening-LyY9G` · אין push ללא אישור מפורש.
> **שם הסוכן בטבלת התיאום:** בנצי (משיק).

---

## 0. כללי-יסוד — לקרוא לפני הכל

1. **אל תמציא.** טקסטים עבריים מגיעים verbatim מהמקור (`app/` Preact + `proto/`).
   הצעת-שיפור ל-UI נשארת בתוך מודל-הניווט הקיים — לא בונים מסכים-חדשים בלי אישור.
2. **שני פרויקטים:** `app/` (Preact, חי בפרודקשן — reference) ו-`app_flutter/`
   (Flutter, יעד ההשקה). **כל עבודת ההשקה היא ב-`app_flutter/` בלבד.**
3. **שער 25 — אסור לגעת ב-Preact-shared** (`app_settings`/`catalog_settings`/
   `chat_settings`/`notif_settings`/`store_settings`).
4. **100 שערי ה-pre-commit אוכפים אוטומטית.** אסור לעקוף. כל commit עובר אותם.
5. **`WIRING.md` משותף** — אם נגעת ב-`lib/screens|state|logic` חובה לעדכנו (שער 24).
6. **דווח בעיות-hook לפרוטוקוליסט** לפי הטמפלט ב-`AGENT_COORDINATION.md` — אל תעקוף.

---

## 1. מודל-העבודה — 3 שלבים

| שלב | מהות | פעולות מותרות |
|-----|------|----------------|
| **A — Audit** | קריאה-בלבד. מיפוי + איתור | קריאה, `flutter analyze/test/build`, devtools, מדידות. **אפס שינוי קוד.** |
| **B — Plan** | דוח + backlog מתועדף | כתיבת `LAUNCH_READINESS.md` בלבד (knowledge) |
| **C — Fix** | ביצוע מדורג אחרי אישור | תיקונים בטוחים מיד; refactor/ארכיטקטורה רק אחרי אישור-משתמש |

**כלל-זהב:** לא לקפוץ ל-C לפני ש-A+B הושלמו ואושרו. אבחון 100% לפני פתרון (לקח #39).
תיקון בטוח = `dart format`, הסרת dead-code חד-משמעי, הוספת `const`, תיקון lint —
כל אלה עם 100 השערים. **כל refactor מבני / שינוי-ניווט / מחיקה רחבה = אישור-משתמש.**

---

## 2. תוצרים (Deliverables)

> **התוצר הסופי = #1. כל השאר משרת אותו.** הפרוטוקול לא "נגמר" בדוח —
> הוא נגמר כש-`LAUNCH_PACKAGE/` מוכן-להעלאה ל-Google Play.

1. **`LAUNCH_PACKAGE/` — חבילת-ההגשה לגוגל פליי (terminal deliverable):**
   - `app-release.aab` — App Bundle **חתום** ב-release-keystore (לא debug).
   - `store-listing/` — כותרת+תיאור (he/en), screenshots לכל גודל-מכשיר נדרש,
     feature-graphic 1024×500, app-icon 512×512.
   - `data-safety.md` — תשובות מלאות לטופס Data-Safety של Google.
   - `privacy-policy-url.txt` — קישור פעיל למדיניות-פרטיות.
   - `release-notes-he.txt` — תיאור-שחרור לגרסה הראשונה.
   - `SEND_TO_GOOGLE.md` — runbook צעד-אחר-צעד: מה להעלות, לאן, באיזה סדר.
2. **`knowledge/LAUNCH_READINESS.md`** — הדוח המרכזי (הדרך לתוצר #1):
   - סיכום מנהלים + המלצת go/no-go
   - backlog מתועדף: P0 (blocker-השקה) · P1 (חשוב) · P2 (nice-to-have)
   - ממצאי כל 9 הפאזות
3. **עדכון `STATUS.md`** — שורת מוכנות-השקה (% מוכן).
4. **דוח ביצוע** ל-`AGENT_COORDINATION.md` בכל סשן (טמפלט קיים שם).

---

# הפרוטוקול — 100 צעדים

> סמן ליד כל צעד: ✅ בוצע · ⚠️ ממצא · ❌ חוסם · ⬜ טרם.
> צעדים 1–94 הם **Audit (קריאה)**. 95–100 **בונים ואורזים את חבילת-ההגשה לגוגל**.

## פאזה A — אוריינטציה ומיפוי (1–10)

0. **יישור-ענף בטוח (לפני הכל):** `git fetch` → בדוק `git status` + `git rev-list
   --left-right --count origin/<branch>...HEAD`. נקי+ahead=0 → `git merge --ff-only`.
   **ahead>0 או dirty → עצור, אל תאפס** (לקח #63 — `reset --hard` עיוור מוחק עבודה
   לא-דחופה; ראה AGENT_COORDINATION "יישור-ענף בטוח"). "קובץ חסר"? בדוק
   `git ls-tree -r origin/<branch>` לפני שמכריזים.
1. קרא `CLAUDE.md` — הפנם את מבנה שני-הפרויקטים (`app/` Preact · `app_flutter/`).
2. קרא `knowledge/README.md` · `STATUS.md` · `ARCHITECTURE.md` · `CONVENTIONS.md`.
3. קרא `WIRING.md` · `STATE_OVERVIEW.md` · `HELPER_INDEX.md` — מה כבר מתועד.
4. מפה את עץ `lib/`: `screens/ state/ logic/ data/ widgets/ services/ theme/ l10n/ features/`.
5. ספור: קבצי `.dart`, סך-שורות, מספר screens/providers/widgets (`grep -r`).
6. אתר את `main.dart` — מפה את שרשרת ה-bootstrap (ProviderScope, init, theme).
7. מפה את מודל-הניווט הקיים (FABs + dial) — תעד אותו כפי שהוא.
8. רשום גרסאות: Flutter, Dart SDK, Riverpod, ותלויות עיקריות מ-`pubspec.yaml`.
9. הרץ `flutter pub outdated` — רשום תלויות מיושנות + פערי-major.
10. צור שלד `knowledge/LAUNCH_READINESS.md` (כותרות 9 הפאזות, עדיין ריק).

## פאזה B — ארכיטקטורה (11–25)

11. מפה את שכבות הארכיטקטורה (UI/state/logic/data) — האם ההפרדה נקייה?
12. בדוק Riverpod: providers, scoping, autoDispose, יחסי-תלות בין providers.
13. אתר business-logic שדלף ל-widgets (חישובים/IO בתוך `build`).
14. בדוק שכבת `data/` — מקורות, repositories, מודלים, immutability.
15. מפה זרימת-נתונים: data → state → UI. יש single-source-of-truth?
16. אתר circular deps / coupling הדוק בין מודולים (`import` graph).
17. בדוק עקביות-דפוס: כל ה-screens באותו דפוס מבני? סטיות?
18. בדוק `theme/` ו-tokens — ריכוז מול פיזור של צבעים/מידות/typography.
19. בדוק error-handling — אחיד? יש crash boundaries / fallback-UI?
20. אמת עקביות-ניווט — כל המסלולים עקביים עם מודל-הניווט הקיים שמיפית בצעד 7.
21. אתר God-objects / קבצים >500 שורות — מועמדים לפיצול.
22. בדוק את ההפרדה Preact-shared ↔ Flutter-only (שער 25) — אין דליפה.
23. מפה persistence: `shared_preferences`/local-storage/cache — מה נשמר ואיפה.
24. בדוק async: `FutureProvider`/`StreamProvider`, race-conditions, loading/error states.
25. סכם ממצאי-ארכיטקטורה ב-LAUNCH_READINESS (+ דירוג חומרה לכל אחד).

## פאזה C — ניקיון וארגון-קוד (26–40)

26. `flutter analyze` — 0 errors? כמה warnings/infos? רשום לפי קטגוריה.
27. בדוק `dart format --output=none --set-exit-if-changed .` — הכל מפורמט?
28. אתר dead-code: providers/functions/widgets לא-בשימוש (`grep` cross-ref).
29. אתר duplication: helpers כפולים, מחרוזות חוזרות, widgets משוכפלים.
30. בדוק naming: קבצים snake_case, מחלקות PascalCase, עקביות שמות-תחום.
31. בדוק imports: package vs relative, imports לא-בשימוש.
32. אתר `TODO`/`FIXME`/`HACK` — רשום מיקום + הקשר.
33. אתר magic-numbers / hardcoded-values שצריכים להיות tokens/const.
34. אתר קבצים במיקום שגוי (screen ב-`data/`, logic ב-`widgets/`).
35. בדוק `const` חסרים ב-widgets (rebuilds מיותרים).
36. בדוק comments מיושנים/מטעים מול הקוד הנוכחי.
37. בדוק `analysis_options.yaml` — אילו lints מופעלים? חסרים lints מומלצים?
38. בדוק assets: לא-בשימוש, כפולים, לא-ממוטבים (גודל/פורמט).
39. הצע מבנה-תיקיות משופר **אם צריך** — רשום כהצעה, אל תבצע בלי אישור.
40. סכם ממצאי-ניקיון + רשימת תיקונים-בטוחים (format/dead/const) לפאזה C.

## פאזה D — נכונות וכיסוי-בדיקות (41–52)

41. `flutter test` — מצב נוכחי (מספר עובר/נכשל מול `known_failing.txt`).
42. מדוד coverage (`flutter test --coverage` + lcov) — אילו קבצים לא-מכוסים.
43. אתר screens/logic קריטיים-להשקה בלי בדיקות.
44. בדוק golden-tests — קיימים? עדכניים? יציבים בין-פלטפורמות?
45. אתר flaky-tests (הרץ פעמיים, השווה).
46. בדוק כיסוי edge-cases: empty / error / loading / offline states.
47. בדוק יחס widget/integration מול unit — חסר integration לזרימות-מפתח?
48. אמת שהבדיקות-החיוניות (שערים 35–40) קיימות ועוברות.
49. הצע בדיקות חסרות **קריטיות-להשקה** (לא כיסוי-מלא — רק blockers).
50. בדוק regression-coverage (`stuck_log` antipatterns) — מכסה את הסיכונים?
51. בדוק contract/schema tests (`smartproduct_contract_test` וכו').
52. סכם פערי-בדיקות + דירוג P0/P1/P2.

## פאזה E — ביצועים (53–64)

53. `flutter build web --release` — מדוד `main.dart.js` (יעד: שמור על המגמה ב-STATUS).
54. בדוק tree-shaking + deferred/lazy loading (split per route?).
55. מדוד startup (cold/warm) — TTI.
56. אתר jank: `build()` כבדים, עבודה סינכרונית ב-UI-thread.
57. בדוק תמונות: גדלים, פורמט (WebP?), resolution-variants, lazy-load.
58. בדוק list-performance: `ListView.builder` מול בנייה-מלאה; `itemExtent`.
59. בדוק memory: dispose ל-controllers/listeners, leaks.
60. בדוק network/data-loading: caching, pagination, debounce לחיפוש.
61. בדוק bundle לפי-פלטפורמה (web מול mobile) — assets מותנים.
62. בדוק font/icon-font loading — subsetting, preload.
63. profile עם flutter devtools (אם זמין) — timeline/frame-chart לזרימה אחת.
64. סכם ממצאי-ביצועים + יעדים מספריים.

## פאזה F — נגישות · i18n · RTL (65–74)

65. בדוק RTL: עברית, mirroring, `EdgeInsetsDirectional` (שערים 65/95) — אין `left/right` קשיח.
66. בדוק number/date formatting ב-RTL (LTR-isolate למספרים).
67. בדוק `Semantics` — screen-reader labels ל-FABs/dial/כפתורים.
68. בדוק contrast (WCAG AA) — טקסט מול רקע כהה.
69. בדוק text-scaling (`textScaler`) — layout שורד 200%?
70. בדוק touch-targets ≥48dp.
71. בדוק i18n scaffold (`lib/l10n/smart_card_strings.dart`) — מוכן להרחבה? כמה strings מחוץ לו?
72. אתר hardcoded-strings מול externalized — מפה היקף.
73. בדוק keyboard-navigation + focus-order (web).
74. סכם נגישות/i18n + מה blocker מול nice-to-have.

## פאזה G — מוכנות-פלטפורמה וחנויות (75–89)

75. **iOS** `Info.plist`: bundle-ID, display-name, permissions-usage-strings.
76. **iOS** app-icons (כל הגדלים), launch-screen, signing/provisioning.
77. **iOS** minimum-version, device-family, orientations.
78. **Android** `AndroidManifest.xml`: package-name, permissions (מינימליות).
79. **Android** app-icons (adaptive), splash, signing-keystore.
80. **Android** `minSdk`/`targetSdk`, R8/ProGuard rules.
81. **Web/PWA** `manifest.json` + service-worker — offline עובד? (פתח, נתק, רענן).
82. **Web/PWA** icons/splash/`theme-color`/install-prompt.
83. **Web** SEO/meta-tags + `base href` תקין ל-GitHub Pages (`/buildsmart/flutter/`).
84. Deep-links / universal-links / app-links — נדרש?
85. Push-notifications — נדרש להשקה? אם כן, setup לכל פלטפורמה.
86. Store-metadata: screenshots (לכל גודל-מכשיר), description, keywords (he/en).
87. Privacy-policy + data-safety (Google) + privacy-nutrition (Apple).
88. version/build-numbers — סכמה עקבית (`pubspec` `version:` + build).
89. סכם מוכנות-פלטפורמה — checklist נפרד לכל אחת מ-3 הפלטפורמות.

## פאזה H — אבטחה ונתונים (90–94)

90. אתר secrets: אין keys/tokens קשיחים בקוד/assets (תואם שער 53).
91. בדוק network-security: HTTPS-only, certificate-pinning (אם נדרש).
92. בדוק local-data: מה נשמר, האם רגיש, הצפנה נדרשת?
93. בדוק permissions: מינימליות ומוצדקות לכל פלטפורמה.
94. בדוק crash-reporting (`crashLogProvider`, step 90) — מוכן ל-telemetry חיצוני?

## פאזה I — ניתוח-פערים, go/no-go, ואריזת חבילת-ההגשה לגוגל (95–100)

95. רכז את **כל** הממצאים (פאזות A–H) ל-backlog אחד מתועדף; סווג כל פריט
    **P0** (חוסם השקה) · **P1** (חשוב) · **P2** (nice-to-have). כתוב סיכום-מנהלים
    ב-`LAUNCH_READINESS.md` + **המלצת go/no-go** מנומקת (חייב **P0=0** כדי לארוז).
96. **החלטת-משתמש לפני אריזה:** רשום ב-`LAUNCH_READINESS.md` את מה שדורש אישור/קלט
    מהמשתמש ואי-אפשר להמציא — **release-keystore + סיסמאות** (חתימה), `applicationId`
    סופי, חשבון Play Console, privacy-policy URL חי, אישורי-refactor. עצור כאן עד שיש keystore.
97. **בנה את ה-AAB החתום:** הגדר signing ב-`android/key.properties` +
    `app/build.gradle` (release signingConfig), ואז `flutter build appbundle --release`.
    אמת: הפלט `build/app/outputs/bundle/release/app-release.aab` חתום ב-release-key
    (לא debug), `applicationId` נכון, `versionCode`/`versionName` תואמים ל-`pubspec`.
98. **אסוף את נכסי-הליסטינג** ל-`LAUNCH_PACKAGE/store-listing/`: כותרת+תיאור he/en,
    screenshots לכל גודל-מכשיר, feature-graphic 1024×500, icon 512×512 — כולם verbatim/אמיתיים
    (אין המצאת טקסט-שיווק; מה שאין — סמן ⬜ "דרוש מהמשתמש", לא ממציאים).
99. **השלם compliance:** `data-safety.md` (כל שאלות הטופס נענו לפי מה שהאפליקציה באמת
    אוספת — צולב מול פאזה H), `privacy-policy-url.txt`, `release-notes-he.txt`.
100. **ארוז וכתוב את ה-runbook הסופי** `LAUNCH_PACKAGE/SEND_TO_GOOGLE.md`: רשימת-העלאה
     מסודרת ל-Play Console (איזה קובץ → איזה מסך → באיזה סדר), טבלת go/no-go סופית
     (P0=0 ✅), ומה נשאר ב-⬜ "דרוש מהמשתמש". **כשכל ה-⬜ נסגרו — המשתמש מעלה את
     `app-release.aab` + הליסטינג ל-Play Console והסיפור נגמר.**

---

## 3. סיום-סשן (חובה)

- [ ] `LAUNCH_READINESS.md` מעודכן עם הממצאים שנאספו בסשן.
- [ ] `flutter analyze` (0 errors) + `flutter test` (≤ known-failing) — אם נגעת בקוד.
- [ ] `WIRING.md` עודכן אם נגעת ב-`lib/screens|state|logic`.
- [ ] דוח-ביצוע ב-`AGENT_COORDINATION.md` (טמפלט קיים).
- [ ] commit עם הודעה ברורה. **push רק ב"תדחוף" מפורש** (לקח #48).

## 4. עקרונות-מנחים (מתוך CARRY_FORWARD)

- **לקח #39:** אבחן 100% לפני שמציעים פתרון. לא יודע → חקור עוד.
- **לקח #37:** פקודה שנכשלה פעמיים → פיבוט, לא ניסיון שלישי זהה.
- **לקח #17:** תיקון מדויק > תיקון רחב. שמור את הצורה הטובה איפה שאפשר.
- **אל תמציא:** אם זה לא בלגאסי/לא מאומת — אל תוסיף.
