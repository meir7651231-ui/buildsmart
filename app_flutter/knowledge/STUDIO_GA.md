# STUDIO_GA — מוכנוּת-שיגור ל-No-Code Studio (Step 100 · GA-lock)

> **סטטוס: 🏁 Studio 100% בנוי · רדום · byte-identical · צעד-אישור-בעלים אחד מהחיים.**
> נחתם ב-Step 100 (2026-07-08). זהו מסמך-המקור-האמת למצב-המוכנוּת של הסטודיו
> ולרצף-ההדלקה שבשליטת-הבעלים. הוא **לא מדליק** דבר — הוא **נועל** את מצב-הכיבוי
> ומוכיח אותו ע"י שער #123.

---

## 1. מטריצת-שלמות — 5 עמודים

| עמוד | מה | שלבים | דגל-אב | שער | סטטוס |
|------|-----|-------|--------|-----|-------|
| ע1 | seams קפואים (`ElementDescriptor`/`ConfigOp`/`applyOps`) + config-store | 1–38 | `STUDIO` | #118 | ✅ |
| ע2 | בונה-חיבורים (trade/connection studio) | 39–50 | `STUDIO` | — | ✅ |
| ע5 | Scale/Data/Backend & Publish-to-All | 51–68 | `STUDIO_LIVE`·`CATALOG_*` | #121·#122 | ✅ |
| ע4 | עורך-AI מעוגן ("תגיד לאפליקציה מה לשנות, בעברית") | 69–85 | `STUDIO_CO_EDITOR` | #119 | ✅ |
| ע3 | מודיעין-לקוח חי (consent-gated · uid-keyed · erasable) | 86–99 | `INTEL_LIVE` | #120 | ✅ |
| — | **GA-lock (safe-by-default capstone)** | **100** | *(כל הדגלים)* | **#123** | ✅ |

**כל 5 העמודים בנויים end-to-end.** אין עמוד חלקי; אין TODO פתוח בקוד-הסטודיו.

---

## 2. אינווריאנט-הכיבוי (למה "בנוי" ≠ "חי")

כל שטח-הסטודיו רדום מאחורי דגלי-קומפילציה `bool.fromEnvironment` / `String.fromEnvironment`.
בבנייה **ללא** `--dart-define` כל דגל נטען לברירת-המחדל הבטוחה, התנאי `if (kXxx)` הופך
`const false`, וה-tree-shaker מוחק את הענף **וגם** את השטח המופנה רק ממנו ⇒ ה-`main.dart.js`
של ה-demo/פרודקשן **byte-identical** להיום. שער #123 מוכיח זאת מכנית.

| דגל | סוג | ברירת-מחדל | מה נדלק כשמפעילים | קובץ |
|-----|-----|------------|-------------------|------|
| `STUDIO` (`kStudioFlag`) | bool | `false` | בסיס-הסטודיו | `state/studio/studio_flags.dart` |
| `STUDIO_LIVE` (`kStudioLive`) | bool | `false` | config שרתי (draft→publish על Firestore) | `data/repositories/backend.dart:198` |
| `CATALOG_SERVER_SEARCH` (`kCatalogServerSearch`) | bool | `false` | חיפוש-קטלוג ממודד-שרת | `backend.dart:202` |
| `CATALOG_BASE_URL` (`kCatalogBaseUrl`) | String | `''` | ה-URL של ה-API (**ריק=נושא-משקל** — ברירת-מחדל לא-ריקה שוברת byte-identity) | `backend.dart:210` |
| `STUDIO_CO_EDITOR` (`kStudioCoEditor`) | bool | `false` | עורך-ה-AI המנהלי (ע4) | `backend.dart:236` |
| `INTEL_LIVE` (`kIntelLive`) | bool | `false` | מודיעין-לקוח חי (ע3) | `backend.dart:253` |

**מגן-שכבה-שנייה:** ה-guards המורכבים (`useCatalogServerSearch`, `analyticsForwardEnabled`,
ציר-ה-`enabled` של עורך-ה-AI) **מ-AND-ים** עם `useFirebaseBackend` (= `Firebase.apps.isNotEmpty`),
כך שגם דגל שהודלק בטעות **אינו מפעיל** דבר ללא backend חי. בדיקות לעולם לא מאתחלות Firebase
⇒ שום עמוד לא נדלק בטסטים. (נאכף ב-#123 part A.)

---

## 3. רצף-ההדלקה — **בשליטת-הבעלים בלבד** (runbook קונקרטי · fail-safe · הפיך)

**טופולוגיית-פריסה (מאומת מהקוד):** אפליקציית-ה-Flutter כבר **חיה** ב-`buildsmart-il.com` /
`buildsmart-b0b78.web.app` (ה-cutover מ-Preact בוצע 1/7). היא נפרסת מ-**`claude/whats-happening-LyY9G`**
דרך `web-deploy.yml` + `firebase-hosting.yml` (מרוץ; חייבים דגלים תואמים). ה-backend נפרס
בנפרד דרך `firebase-deploy.yml` (secrets: `FIREBASE_SERVICE_ACCOUNT`/`R2_*` — CI-בעלים בלבד).

**שלב 0 — המיזוג (בטוח, byte-identical):** מזג את ה-PR (`kind-dijkstra` → `whats-happening`).
המיזוג מפעיל אוטומטית את web-deploy+firebase-hosting → רה-בילד של `buildsmart-il.com`. מאחר
ש-`STUDIO_DART_DEFINES` **לא-מוגדר** (ברירת-מחדל), הבנייה **byte-identical** להיום — הסטודיו רדום
(tree-shaken). כלומר המיזוג עצמו לא משנה כלום למשתמשים; הוא רק מציב את הקוד מוכן-לחימוש.

**שלב 1 — פריסת-backend (לפני כל דגל):** הרץ `firebase-deploy.yml` (workflow_dispatch, הסודות
שלך). פורס Firestore rules+indexes בסדר-החובה (שער #121) → functions. אמת ירוק. **אסור** להדליק
דגל לפני שזה פרוס ומאומת — אחרת האפליקציה מצביעה על backend שאינו קיים.

**שלב 2 — הדלקה מדורגת דרך משתנה-מאגר (Settings → Actions → Variables → `STUDIO_DART_DEFINES`):**
קבע את המשתנה לערך-השלב, ואז הרץ מחדש את `web-deploy.yml` (dispatch). המשתנה **מתמיד** בין
פריסות (לא input חד-פעמי שpush הבא מבטל). דורג — אמת על ה-live בין שלב לשלב:

| שלב | ערך `STUDIO_DART_DEFINES` (מצטבר) | מדליק |
|-----|-----------------------------------|-------|
| 2a | `--dart-define=USE_FIREBASE_BACKEND=true` | האפליקציה מדברת ל-backend החי (הסטודיו עדיין כבוי) |
| 2b | `… --dart-define=STUDIO_LIVE=true` | config שרתי (draft→publish) |
| 2c | `… --dart-define=CATALOG_SERVER_SEARCH=true --dart-define=CATALOG_BASE_URL=<url>` | חיפוש-קטלוג שרתי (אם רוצים) |
| 2d | `… --dart-define=STUDIO_CO_EDITOR=true --dart-define=CLAUDE_AI=true` | עורך-ה-AI (דורש gateway חי) |
| 2e | `… --dart-define=INTEL_LIVE=true` | מודיעין-לקוח + מודאל-הסכמה (**go-live משפטי**) |

**שלב 3 — rollback (בכל שלב):** נקה/החזר את `STUDIO_DART_DEFINES` לערך-השלב-הקודם → הרץ מחדש
web-deploy → הפריסה חוזרת byte-identical לשלב-הקודם. הפיך לחלוטין, ללא שינוי-קוד.

**מעטפות-בטיחות שממשיכות לעבוד גם עם דגלים דלוקים:** כל שטחי-הסטודיו **role-gated למנהל בלבד**
(runtime) — משתמש רגיל לא רואה אותם גם כשהדגל דלוק. `INTEL_LIVE` **consent-gated default-DENY** —
איסוף רק אחרי הסכמה מפורשת פר-גרסת-מדיניות.

**הערה:** אף אחד משלבים 0–3 לא בוצע ולא ייעשה אוטונומית — כולם ממתינים להוראת-בעלים מפורשת,
ורובם (backend deploy, dispatch, קביעת-המשתנה) רצים מהסודות/החשבון שלך ב-CI, לא מהסביבה של הסוכן.

---

## 4. אימות (GA gate של Step 100)

- `flutter analyze --no-fatal-infos --no-fatal-warnings` → **0 errors**.
- `flutter test test/studio/gate_123_ga_safety_test.dart` → **3/3** (part A const-fold ·
  part A composed-guard · part B closed-set self-maintaining).
- כל דגלי-ה-Pillar מכוסים; דגל-Pillar חדש שיתווסף ללא assertion בטוחה **יפיל** את #123
  (part B) — רשת-הבטיחות לא מתיישנת.
- אפס-רגרסיה: הבסיס ה-flaky (~13) נשמר; שום כשל דטרמיניסטי חדש.

---

## 5. מה **לא** נכלל ב-"100%" (בכוונה)

- **הדלקה בפועל** — סעיף 3, החלטת-בעלים.
- **פריסת-backend / cutover** — תשתית, לא קוד-סטודיו.
- **מסכי typed-arg mutating** (ע4) — מוצגים GREYED/deferred במכוון (R1-5), יידרשו שער-P1
  נפרד (`AddComponent` / role-grant) — מחוץ להיקף-הסטודיו.

> **שורה-תחתונה:** הסטודיו **גמור, מלא, ומוכח-רדום.** מכאן זה החלטת-בעלים מתי לזרוע אותו לחיים.

---

## 6. Arming log (live)

- **2026-07-08 — backend deployed.** `firebase-deploy` green (run 28917096081): all
  request/trigger functions + the P5.66 rollup schedulers. Cloud Scheduler API enabled
  + CI service account granted `roles/cloudscheduler.admin`.
- **2026-07-08 — Studio stage-1 armed.** Repo variable `STUDIO_DART_DEFINES` set to
  `--dart-define=STUDIO_CO_EDITOR=true` → the manager-only Studio cockpit + no-code
  manual builder go live on buildsmart-il.com (draft-mode; the AI co-editor shows its
  off-state until `CLAUDE_AI` + `USE_FIREBASE_BACKEND` are added). Regular users: no
  change (manager-gated). Next stages 2–5 per §3, owner-paced.
- **2026-07-08 — full connect (stages 2a–2e).** `STUDIO_DART_DEFINES` extended to
  `USE_FIREBASE_BACKEND` + `STUDIO_LIVE` + `STUDIO_CO_EDITOR` + `CLAUDE_AI` + `INTEL_LIVE`.
  The live app now uses the Firestore backend; server-config publish, the AI co-editor,
  and consent-gated customer intelligence are armed. Rollback: restore the variable to
  the stage-1 value (`--dart-define=STUDIO_CO_EDITOR=true`) and re-deploy.
- **2026-07-08 — rolled back to stage-1.** Full connect broke the app boot on
  buildsmart-il.com (USE_FIREBASE_BACKEND on an unseeded/auth-unready backend →
  stuck on the initial screen). Variable restored to `--dart-define=STUDIO_CO_EDITOR=true`.
  Back to the working state: demo data, local board login (admin/5555), Studio visible.
  The full backend cutover needs prep first: Firestore seed + web Google OAuth client
  (web/index.html) + board-auth/UID_SCOPED_QUERIES coordination.
