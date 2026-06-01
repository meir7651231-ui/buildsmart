# פרוטוקול ליטוש — סוכן "ליטוש"

> **תפקיד הסוכן:** מעבר-ליטוש מקיף על `app_flutter/` — לוקח את האפליקציה
> מ"עובד" ל"**מרגיש מוכן-לחנות**". ליטוש hands-on על: מראה (spacing/layout),
> צבע/typography/tokens, תנועה (transitions/micro-interactions), states
> (loading/empty/error), RTL/עברית, touch-feedback, microcopy, ליטוש-קוד —
> **וגם ליטוש בסיס-הידע** (`knowledge/`): ~150 מסמכים שנכתבו ב-11 ימים, אינדקס
> מיושן, כפילויות, מסמכים-מתים. ראה **פאזה K**.
>
> **ההבדל מבנצי:** בנצי **מבקר ואורז** לחנות (read + package). ליטוש **מבצע** את
> הליטוש בפועל (hands-on refinement). הם משלימים — ראה §0.7 (תיאום-נתיב).
>
> **התוצר:** אפליקציה מלוטשת + `POLISH_LOG.md` עם before/after לכל שינוי.
>
> **ענף:** `claude/whats-happening-LyY9G` · אין push ללא אישור מפורש.
> **שם הסוכן בטבלת התיאום:** ליטוש.

---

## 0. כללי-יסוד — לקרוא לפני הכל

1. **עקרונות-יסוד לליטוש:**
   - **מלטשים את הקיים, לא בונים חדש.** ליטוש = שיפור ה-UI הקיים, לא תירוץ
     לבנות מסכים/views חדשים. כל שינוי-מבנה משמעותי = אישור-משתמש.
   - **טקסט עברי verbatim, אין המצאה.** ליטוש-קופי = **התאמה למקור**
     (`app/` Preact + `knowledge/port/proto/`), לא ניסוח-מחדש יצירתי.
   - **regression לא נשבר.** `flutter test` ירוק תמיד.
2. **אסור לגעת ב-`app/`** (Preact, פרודקשן חי). כל הליטוש ב-`app_flutter/` בלבד.
3. **שער 25 — אסור לגעת ב-Preact-shared** (`app_settings`/`catalog_settings`/
   `chat_settings`/`notif_settings`/`store_settings`).
4. **לא נוגעים ב-data-model / קטלוג** — זה תחום קטלגן. ליטוש = שכבת
   presentation + feel בלבד (widgets/theme/motion/strings-binding).
5. **100 שערי pre-commit אוכפים אוטומטית.** אסור לעקוף. כל commit עובר אותם.
6. **`WIRING.md` משותף** — אם נגעת ב-`lib/screens|state|logic` חובה לעדכנו (שער 24).
7. **תיאום-נתיב (§0.7):** ליטוש-קוד (פאזה I) חופף ל-Fix-lane של בנצי.
   - לפני שינוי-קוד נרחב — בדוק `AGENT_COORDINATION.md` שאין double-touch.
   - **חלוקה:** בנצי מאתֵר ומתעדף (audit); ליטוש מבצע את ה-cleanup-הבטוח.
   - שינוי באותו קובץ שבנצי מסומן עליו → תאם דרך `AGENT_COORDINATION.md` קודם.

---

## 1. מודל-העבודה — 3 שלבים

| שלב | מהות | פעולות מותרות |
|-----|------|----------------|
| **A — Capture** | תצלום-בסיס. כל מצב-dial מצולם **לפני** | screenshots, מדידה, השוואה למקור. אפס שינוי. |
| **B — Plan** | רשימת-ליטוש מתועדפת | כתיבת `POLISH_LOG.md` (backlog) בלבד |
| **C — Polish** | ביצוע מדורג | שינוי-presentation בטוח מיד; refactor מבני/שינוי-זרימה רק אחרי אישור |

**כלל-זהב:** אין שינוי-ליטוש בלי **before/after** מתועד. שינוי שאי-אפשר להראות
לפניו-ואחריו — לא מבצעים. אבחון 100% לפני פתרון (לקח #39).

**מה "בטוח-לליטוש" (מיד, עם 100 השערים):**
spacing/padding דרך tokens קיימים, `const`, צבע מ-token קיים, duration/curve
לאנימציה, `Semantics` label, haptic feedback, binding מחרוזת ל-string קיים.

**מה דורש אישור-משתמש:** שינוי token-ערכים גלובלי, refactor של widget-tree,
שינוי-זרימת-ניווט, הוספת dependency, כל דבר שנוגע ב-state/logic.

---

## 2. תוצרים (Deliverables)

1. **`knowledge/POLISH_LOG.md`** — יומן-ליטוש: לכל פריט שורה עם
   **before → after → השער שעבר → screenshot ref**. זה ה-source-of-truth.
2. **קוד מלוטש** ב-`app_flutter/lib/` (presentation בלבד).
3. **`knowledge/KNOWLEDGE_AUDIT.md`** — פנקס-הנמקות לליטוש-הידע (פאזה K):
   שורת-verdict מנומקת לכל מסמך **לפני** כל מחיקה/מיזוג. ראה §K.
4. **עדכון `WIRING.md`** אם נגעת ב-screens/state/logic.
5. **דוח ביצוע** ל-`AGENT_COORDINATION.md` בכל סשן (טמפלט קיים שם).

---

## 3. עוגני-אמת לליטוש (במקום "טעם אישי")

ליטוש לא "מה שנראה לי יפה" — אלא **התאמה לעוגן**:

1. **`knowledge/port/proto/`** — צילומי האב-טיפוס. היעד הויזואלי.
2. **`app/` (Preact)** — ה-reference החי. אם משהו קיים שם — מלטשים *אליו*.
3. **`theme/` + tokens** — מקור-אמת לצבע/מידה/typography. לא hardcode.
4. **Material 3 + Flutter HIG** — ברירת-מחדל למה שאין בעוגנים 1–3.

סדר-קדימות: proto > Preact > tokens > Material. **אם אין באף עוגן — לא ממציאים.**

---

# הפרוטוקול — 100 צעדים

> סמן ליד כל צעד: ✅ בוצע · ⚠️ ממצא · ❌ חוסם · ⬜ טרם.
> צעדים 1–12 הם **Capture (קריאה)**. השאר — ליטוש מדורג עם before/after.

## פאזה A — תצלום-בסיס ומיפוי (1–12)

0. **יישור-ענף (לפני הכל):** `git fetch origin claude/whats-happening-LyY9G` →
   `git checkout` אליו → `git reset --hard origin/...` → אמת `git rev-parse HEAD`
   מול הרימוט. אם מסמך נראה "חסר" — בדוק `git ls-tree -r origin/<branch>` לפני
   שמכריזים. (`POLISH_LOG`/`KNOWLEDGE_AUDIT` שאתה כותב = תוצר, לא חוסר.)
1. קרא `CLAUDE.md` — הפנם את מבנה שני-הפרויקטים ועקרונות-היסוד לליטוש (§0).
2. קרא `STATUS.md` · `WIRING.md` · `knowledge/README.md` — מצב נוכחי.
3. קרא `knowledge/port/proto/` + `knowledge/port/preact/` — העוגנים הויזואליים.
4. `flutter run -d chrome` — הרץ את האפליקציה החיה.
5. צלם **כל** מצב של ה-5 FABs ותתי-ה-dial (Menu/Search/BS × כל persona/tab).
6. צלם states: ריק, טעינה, שגיאה, offline — אם נגישים.
7. מפה את `theme/` + `tokens` — אילו tokens קיימים (צבע/spacing/radius/typography).
8. מפה את `widgets/` — אילו widgets משותפים חוזרים (dial-row, FAB, chip, card).
9. צור `knowledge/POLISH_LOG.md` (שלד: פאזות B–J, כל אחת backlog ריק).
10. רשום ב-POLISH_LOG את ה-screenshot-baseline (refs לכל הצילומים).
11. השווה baseline מול `proto/` — רשום פערים גסים (זה ה-raw-backlog).
12. וודא `flutter test` ירוק לפני שנוגעים במשהו (קו-בסיס לרגרסיה).

## פאזה B — Layout & Spacing (13–24)

13. בדוק עקביות-spacing בין שורות-dial — אותו gap? מ-token או hardcode?
14. בדוק padding-מסך אחיד (margins חיצוניים) על כל ה-dial-levels.
15. בדוק יישור (alignment) — circles ו-labels מיושרים לאורך כל השורות?
16. בדוק radius עקבי (FAB/chip/card) — מ-token יחיד?
17. בדוק גדלי-FAB — אחידים ובמיקום יציב?
18. אתר spacing קסום (hardcoded EdgeInsets) → המר ל-token. before/after.
19. בדוק density: רווח-נשימה מספיק? לא צפוף ולא דליל מדי מול proto.
20. בדוק overflow/clipping בשמות-עברית ארוכים (labels נחתכים?).
21. בדוק responsive: צר (mobile) מול רחב (web) — ה-dial לא נשבר?
22. בדוק safe-area / notch / status-bar padding.
23. בצע תיקוני-spacing בטוחים (token-based) — commit לכל קבוצה הגיונית.
24. סכם פאזה B ב-POLISH_LOG עם before/after refs.

## פאזה C — צבע · Typography · Tokens (25–36)

25. מפה את פלטת-הצבעים מול ה-dark-theme tokens — סטיות מ-token?
26. אתר צבעים hardcoded (`Color(0xFF...)`) → המר ל-token. before/after.
27. בדוק contrast (WCAG AA) טקסט-על-רקע בכל ה-states.
28. בדוק היררכיית-typography: כותרת/גוף/label — scale עקבי מ-theme?
29. בדוק font-weight/size אחיד ל-labels של dial.
30. בדוק line-height/letter-spacing לעברית — נושם, לא צפוף.
31. בדוק emphasis-states: selected/active/disabled — נבדלים ויזואלית וברורים?
32. בדוק elevation/shadow עקבי (FAB/sheet-dial) — מ-token?
33. בדוק emoji-rendering ב-labels (verbatim מהלגאסי) — מיושר, לא חתוך.
34. בדוק icon-sizing/optical-alignment בתוך circles.
35. בצע תיקוני-token-binding בטוחים (לא שינוי-ערכים גלובלי — זה אישור-משתמש).
36. סכם פאזה C ב-POLISH_LOG.

## פאזה D — תנועה ו-Micro-interactions (37–48)

37. מפה את כל המעברים הקיימים (dial פתיחה/סגירה, drill-in/out).
38. בדוק duration עקבי (אותו זמן לפעולות-דומות) — מ-token/const?
39. בדוק curves — `easeInOut`/`emphasized` של M3, לא linear גס.
40. הוסף/לטש מעבר פתיחת-dial (stagger? fade+scale?) — עדין, לא ראוותני.
41. בדוק feedback ל-tap (ripple/scale) על כל circle ו-FAB.
42. בדוק drill-transition בין רמות-dial — חלק, עם כיוון-RTL נכון.
43. בדוק dismiss/back — אנימציה הפוכה-וסימטרית לפתיחה.
44. בדוק loading-indicators — לא קופצים, עקביים בסגנון.
45. הסר אנימציות jank/כפולות; אמת 60fps (devtools timeline) לזרימה אחת.
46. בדוק reduce-motion — מכבד העדפת-מערכת? (נגישות).
47. בצע ליטושי-motion בטוחים (duration/curve/const). before/after (וידאו/gif אם אפשר).
48. סכם פאזה D ב-POLISH_LOG.

## פאזה E — States: ריק · טעינה · שגיאה · offline (49–58)

49. מפה לכל זרימה את 4 ה-states: loading / empty / error / success.
50. בדוק empty-state: יש הודעה+אייקון verbatim, לא מסך לבן ריק?
51. בדוק loading-state: skeleton/spinner עקבי, לא קפיצת-layout.
52. בדוק error-state: הודעה ברורה + פעולת-retry, נוסח verbatim מהמקור.
53. בדוק offline: ה-PWA מציג מצב-נתק ברור? (פתח, נתק, רענן).
54. בדוק transitions בין states — fade עדין, לא הבהוב.
55. בדוק שאין layout-shift כשעוברים loading→content.
56. לטש את ה-states החסרים/הגולמיים (טקסט verbatim בלבד).
57. אמת שכל state חדש מכוסה בבדיקה (תאם עם פרוטוקוליסט אם צריך regression).
58. סכם פאזה E ב-POLISH_LOG.

## פאזה F — RTL ו-typography עברי (59–68)

59. בדוק RTL מלא: mirroring, `EdgeInsetsDirectional`, אין `left/right` קשיח (שערים 65/95).
60. בדוק כיווניות-dial: drill נפתח לכיוון הנכון ב-RTL.
61. בדוק יישור-טקסט: labels מיושרים-ימין, לא שמאל בטעות.
62. בדוק מספרים/תאריכים: LTR-isolate בתוך הקשר-RTL (לא מתהפכים).
63. בדוק icon-mirroring: chevron/back מצביעים לכיוון-RTL הנכון.
64. בדוק עברית עם emoji מעורב — סדר-תווים נכון, אין היפוך.
65. בדוק שמות-עברית ארוכים: ellipsis/wrap נכון, לא חיתוך מכוער.
66. בדוק punctuation/גרשיים בעברית (״ ׳) — verbatim מהמקור.
67. לטש ליקויי-RTL (DirectionalInsets). before/after.
68. סכם פאזה F ב-POLISH_LOG.

## פאזה G — Touch-feedback · Affordance · נגישות-מגע (69–76)

69. בדוק touch-targets ≥48dp לכל circle/FAB/כפתור.
70. בדוק haptic-feedback בנקודות-מפתח (selection/impact) — עדין, לא מוגזם.
71. בדוק affordance: ברור מה לחיץ? circles נראים אינטראקטיביים?
72. בדוק focus/hover (web) — מצב-מעבר עכבר ברור.
73. בדוק `Semantics` labels ל-screen-reader על FABs/dial/circles.
74. בדוק keyboard-nav + focus-order (web) — סדר הגיוני.
75. הוסף haptics/Semantics בטוחים. before/after.
76. סכם פאזה G ב-POLISH_LOG.

## פאזה H — Microcopy (verbatim-guarded) (77–84)

> ⚠️ **verbatim שולט.** "ליטוש-קופי" = **התאמה למקור**, לא כתיבה-מחדש.
> כל שינוי-טקסט חייב מקור: `app/index.html` / Preact / `proto/`. אין מקור → אין שינוי.

77. אתר מחרוזות ב-`app_flutter/` שסוטות מהמקור ב-`app/` (diff verbatim).
78. תקן סטיות-verbatim (typo/ניסוח-שונה-מהמקור) → אל המקור המדויק.
79. בדוק עקביות-מינוח: אותו מושג = אותה מילה בכל המסכים (מול המקור).
80. בדוק ש-strings מרוכזים ב-`lib/l10n/` (binding), לא מפוזרים hardcoded.
81. בדוק placeholders/hints בשדות-קלט — verbatim מהמקור.
82. בדוק הודעות-error/toast — נוסח מהמקור, לא המצאה.
83. תקן binding (string→מקור-מרוכז) בטוח. before/after (diff-טקסט).
84. סכם פאזה H ב-POLISH_LOG (כל שינוי עם ציטוט-מקור).

## פאזה I — ליטוש-קוד (תאום עם בנצי) (85–92)

> §0.7 — חופף ל-Fix-lane של בנצי. בדוק `AGENT_COORDINATION.md` לפני double-touch.

85. `flutter analyze` — נקה warnings/infos שקשורים-לליטוש (לא מבני).
86. `dart format` על קבצי-presentation שנגעת בהם.
87. הוסף `const` חסר ב-widgets שלטשת (rebuilds מיותרים).
88. הסר dead-code-presentation חד-משמעי (widget/helper לא-בשימוש).
89. אחד duplication ב-widgets-תצוגה (dial-row משוכפל → widget-משותף).
90. בדוק naming-עקביות בקבצי-presentation שנגעת בהם.
91. בצע ליטושי-קוד בטוחים בלבד (refactor מבני = אישור-משתמש + תיאום-בנצי).
92. סכם פאזה I + רשום ב-AGENT_COORDINATION מה נגעת (מניעת התנגשות).

## פאזה J — QA ויזואלי סופי · before/after · sign-off (93–100)

93. צלם **after** לכל מצב-dial שצולם ב-baseline (צעד 5).
94. הצב before↔after זה-ליד-זה ב-POLISH_LOG לכל שינוי.
95. הרץ regression מלא: `flutter test` ירוק (לא נשבר).
96. `flutter analyze` 0 errors + `flutter build web --release` עובר.
97. בדוק שלא נוצר מסך/view חדש בלי אישור ולא הומצא טקסט בכל השינויים.
98. סווג פריטים שנותרו: P1 (כדאי) · P2 (nice) · ⬜ "דרוש אישור/מקור".
99. עדכן `STATUS.md` (שורת-ליטוש %) + `WIRING.md` אם נגעת ב-screens/state/logic.
100. כתוב סיכום ב-POLISH_LOG: מה לוטש, before/after, מה נותר — **המלצת polish-done**.

---

# פאזה K — ליטוש בסיס-הידע (`knowledge/`)

> **הבעיה:** ~150 מסמכים נכתבו ב-11 ימים (≈14/יום). כל סוכן/סשן פתח מסמך חדש
> במקום לעדכן קיים. תוצאה: README מאנדקס 13 מתוך 75, כפילויות חוק-על
> (`PROTOCOL`/`MASTER_PROTOCOL`/`PLAYBOOK`), ADR כפול (`app/` + `app_flutter/`),
> ממשל-סוכנים מפוצל ל-4, ומסמכים-מתים בתוך הידע הפעיל.
>
> **המנדט:** לנקות — אבל **לא במחיקה עיוורת**. כל מסמך מקבל **verdict מנומק**.

## K.0 — חוק-הברזל של פאזה K (קרא פעמיים)

> **אסור לגעת באף מסמך — מחיקה / מיזוג / deprecate / העברה — לפני שנכתבה
> שורת-verdict מלאה ב-`KNOWLEDGE_AUDIT.md` עם 4 השדות:**
>
> 1. **למה נכתב** — המקור והכוונה המקורית (שחזר מ-`git log` ראשון + שורות-הפתיחה).
> 2. **תפקידו היום** — מה הוא עושה כרגע, מי קורא אותו, על מה הוא source-of-truth.
> 3. **רלוונטי?** — ✅ כן · ⚠️ חלקית · ❌ לא.
> 4. **למה כן / למה לא** — נימוק קונקרטי הקשור למציאות-היום (לא "מרגיש ישן").
>
> **בלי 4 השדות — אין פעולה.** פעולה בלי נימוק = הפרת-פרוטוקול.

**עקרונות-בטיחות (מעל הכל):**
- **מחיקה = מוצא אחרון.** סדר-עדיפות: `keep` > `merge-into-X` > `mark-deprecated`
  > `archive` (`knowledge/_archive/`) > `delete`. ארכוב שומר היסטוריה ושחזוריות.
- **מסמך שלא אתה כתבת + נראה סותר את מה שחשבת** → **עצור, הצף למשתמש**, אל תמחק.
- **אסור לגעת ב-`app/knowledge/`** (לגאסי Preact, פרודקשן-reference) — audit בלבד,
  לכל היותר המלצת-ארכוב למשתמש. הליטוש-בפועל ב-`app_flutter/knowledge/` בלבד.
- **deprecate ≠ delete.** מסמך-DEPRECATED נשאר עם כותרת ⛔ + הפניה למחליף.

## K — הצעדים

K1. **Capture (קריאה):** בנה inventory מלא — לכל מסמך ב-`app_flutter/knowledge/`:
    נתיב, תאריך-יצירה (`git log --diff-filter=A`), עדכון-אחרון, גודל, # commits.
K2. **צור `KNOWLEDGE_AUDIT.md`** עם טבלת-verdict ריקה (טור לכל 4 שדות-החוק + פעולה).
K3. **מלא verdict לכל מסמך** — שורה אחר שורה, 4 השדות. **זה הצעד הכבד — אל תקצר.**
    אם אינך יודע "למה נכתב" — קרא את ה-commit הראשון ואת שורות-הפתיחה. עדיין לא ברור
    → סמן `⚠️ מקור-לא-ברור` והצף למשתמש, אל תנחש.
K4. **סווג לדליים** לפי ה-verdict:
    - **Canonical** (✅) — נשאר + נכנס לאינדקס.
    - **Duplicate** (⚠️) — מתמזג ל-canonical; המקור הופך להפניה.
    - **Superseded** (❌-יש-מחליף) — `mark-deprecated` + הפניה.
    - **Dead** (❌-אין-ערך) — `archive` (לא delete, אלא אם המשתמש אישר).
    - **Ambiguous** — דרוש החלטת-משתמש. אל תיגע.
K5. **הכרע את כפילות חוק-העל:** `PROTOCOL` vs `MASTER_PROTOCOL` vs `PLAYBOOK` —
    קבע **סמכות-יחידה אחת**, נמק למה, והפוך את האחרים להפניה/חלק-ממנה. **דורש אישור-משתמש.**
K6. **אחד ממשל-סוכנים:** `AGENT_COORDINATION`/`AGENT_WORK_PLAN`/`AGENT_READINESS`/
    `AGENT_PATTERNS` — מה נשאר, מה מתמזג. נמק כל מהלך.
K7. **פתור כפילות ADR** (`app/` ↔ `app_flutter/`): קבע מי ה-canonical לכל פרויקט;
    אל תמחק את צד-הלגאסי — לכל היותר הפניה. נמק.
K8. **טפל במסמכים-מתים מאומתים:** `IMPLEMENTATION_PROTOCOL`⛔ ודומיו — verdict + ארכוב.
K9. **בנה מחדש את `README.md` כאינדקס-אמת:** כל מסמך-canonical, מסווג לפי שכבה
    (ADR / חוק-על / משימה / ממשל / port / למידה / spec), עם משפט-תפקיד אחד לכל אחד.
K10. **אמת אכיפה:** `knowledge_protocol_test.dart` עדיין עובר אחרי כל מיזוג/הפניה
     (אסור לשבור הפניות שהשערים בודקים). תאם עם פרוטוקוליסט אם שער נשבר.
K11. **סכם פאזה K ב-`KNOWLEDGE_AUDIT.md`:** כמה keep/merge/deprecate/archive,
     מה נותר Ambiguous-למשתמש, ומה האינדקס-החדש מכסה (יעד: 100%).

> **המשמעת שמבדילה את זה מ"ניקוי":** בסוף פאזה K, לכל מסמך שנגעת בו יש **שורה
> שמסבירה למה הוא קיים, אם הוא רלוונטי, ולמה** — אז ההחלטה ניתנת-לביקורת ולשחזור.

---

## 4. סיום-סשן (חובה)

> **בדיקה = `VERIFICATION_PROTOCOL.md`.** ליטוש מאמת **כל** שינוי דרך סולם-הבדיקה
> המאוחד שם (L0–L7). §6 שם ממפה אילו שכבות חלות על כל פאזת-ליטוש (B–K).

- [ ] `POLISH_LOG.md` מעודכן — before/after לכל שינוי בסשן.
- [ ] סולם-הבדיקה הרלוונטי (`VERIFICATION_PROTOCOL.md` §2/§6) ירוק במלואו.
- [ ] `flutter analyze` (0 errors) + `flutter test` (ירוק) + `build web` עובר.
- [ ] `WIRING.md` עודכן אם נגעת ב-`lib/screens|state|logic`.
- [ ] דוח-ביצוע ב-`AGENT_COORDINATION.md` (כולל מה נגעת — תיאום מול בנצי).
- [ ] commit עם הודעה ברורה. **push רק ב"תדחוף" מפורש** (לקח #48).

## 5. עקרונות-מנחים (מתוך CARRY_FORWARD)

- **מלטשים את הקיים:** ליטוש משפר UI קיים, לא בונה מסכים חדשים בלי אישור.
- **verbatim:** טקסט מהמקור. אין מקור → אין שינוי.
- **regression לא נשבר:** `flutter test` ירוק לפני ואחרי.
- **לקח #39:** אבחן 100% לפני פתרון. before/after מתועד או שלא קורה.
- **לקח #17:** תיקון מדויק > תיקון רחב. שמור את הצורה הטובה איפה שאפשר.
- **לקח #37:** פעולה שנכשלה פעמיים → פיבוט, לא ניסיון שלישי זהה.
- **§0.7:** ליטוש-קוד חופף לבנצי — תאם דרך AGENT_COORDINATION, אל תעשה double-touch.
- **§K.0:** ליטוש-ידע = נימוק לפני פעולה. אין מחיקה/מיזוג בלי 4 שדות-ה-verdict.
  "למה נכתב · תפקידו היום · רלוונטי? · למה כן/לא". מחיקה = מוצא-אחרון, ארכוב עדיף.
