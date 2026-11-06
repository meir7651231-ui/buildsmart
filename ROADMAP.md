# Roadmap · מפת דרכים

Each item names its source in the repo. Items marked **proposal** have no owner decision yet.
כל פריט מציין את המקור שלו בריפו. פריט שמסומן **הצעה** עוד לא הוכרע.

## Now — store launch · עכשיו — השקה בחנויות

New features are frozen until launch (owner decision, 2026-11). · פיצ'רים חדשים מוקפאים עד ההשקה (הכרעת הבעלים, 11.2026).

| Item | פריט | State | Source |
|---|---|---|---|
| Signed Android App Bundle (AAB) built in CI | AAB חתום שנבנה ב-CI | 🟡 draft PR | PR #61 · `android-release.yml` |
| Unsigned iOS build (IPA) in CI, as build proof | בניית iOS לא-חתומה ב-CI | 🟡 draft PR | PR #61 · `ios-unsigned.yml` |
| Privacy policy v2, matching the code | מדיניות פרטיות v2 שתואמת לקוד | 🟡 draft — needs company details and a public URL | PR #61 · `app_flutter/LAUNCH_PACKAGE/privacy-policy.md` |
| Production deploys from `main` only | פריסות לפרודקשן רק מ-`main` | 🟡 decision pending | PR #61 · `docs/launch/W1-B2-decision.md` |
| Developer accounts, store listing copy, signing team (owner steps) | חשבונות מפתח, טקסט לחנות, צוות חתימה (צעדים של הבעלים) | ⬜ owner | `app_flutter/knowledge/LAUNCH_READINESS.md` |

## Next — after launch · הבא — אחרי ההשקה

| Item | פריט | Source |
|---|---|---|
| Web cutover from the Preact app to Flutter | מעבר של אתר הווב מ-Preact ל-Flutter | `CLAUDE.md` (two-projects table) |
| Contractor entry in the BS dial (deferred — no legacy sub-tree; the contractor uses the main app) | כניסת הקבלן בחוגת BS (נדחה — אין עץ בלגאסי; הקבלן משתמש באפליקציה הראשית) | `shell-and-dials.md` §2 · `app_flutter/README.md` roadmap |
| Wire the Menu and Search dials to a visible trigger | חיבור חוגות התפריט והחיפוש לכפתור גלוי | `app_flutter/README.md` (roadmap) |
| Dark theme and Arabic/English UI (v1 is Hebrew-only, light) | ערכת נושא כהה וממשק בערבית/אנגלית (v1 עברית בלבד, בהיר) | `LAUNCH_READINESS.md` F-A3 |
| Extend the catalog quality gate to every brand catalog — **proposal** | הרחבת שער האיכות לכל קטלוגי המותגים — **הצעה** | today it parses `lipskey_catalog.dart` only (`scripts/catalog_qa.py`) |
| First app release tag (see the SemVer proposal in `CHANGELOG.md`) — **proposal** | תגית שחרור ראשונה לאפליקציה (ראו הצעת SemVer ב-`CHANGELOG.md`) — **הצעה** | no app tags yet; `kiosk-v*` tags are a separate product |

## Done · בוצע

See [`CHANGELOG.md`](CHANGELOG.md). · ראו [`CHANGELOG.md`](CHANGELOG.md).
