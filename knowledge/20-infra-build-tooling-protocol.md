# תשתית: build · native · CI · tooling · protocol (חוצה-מקורות)

> "שאר הקבצים" — packaging/CI/tooling + שכבת-הפרוטוקול. לא ידע-מוצר, אבל חלק מהפרויקט.

## ⭐ אריזה ל-native (חנויות)
- **Preact → Capacitor** (`app/capacitor.config.ts`): `appId:'com.buildsmart.app'` · `appName:'BuildSmart'` · `webDir:'dist'` · ios(`contentInset:'always'`)/android(`allowMixedContent:false`). 🔧 **דיוק (אומת מ-package.json):** `@capacitor/cli`+`@capacitor/core` ^6.2 **מותקנים** (devDeps) + scripts `cap:sync`/`cap:ios`/`cap:android` **קיימים** — אבל חבילות-הפלטפורמה (`@capacitor/ios`/`@capacitor/android`) **טרם הותקנו** ו-`npx cap add` לא רץ. native-packaging **מחווט אך לא-פעיל** (Preact כיום = web/PWA).
- **Flutter → native מובנה** (`flutter build ios/android/web`).
→ **שני מסלולים לחנויות:** Preact+Capacitor · Flutter-native.

## ⭐ צינור-הנתונים prototype→Preact (`app/scripts/extract-catalog.mjs`)
**הכלי שמחבר את המקורות:** קורא `../index.html`, מרים `CATALOG`/`VARIANTS`/`STORE_PRICING`/`TOOLS` ל-`src/data/*.ts` מטוייפים, **ומפענח base64-JPEGs מוטמעים → `public/catalog/*.jpg`**.
→ זה מקור השורות-הענק ב-index.html (תמונות base64) ושל `image:/catalog/*.jpg` (דוחות 03/04). הרצה: `node scripts/extract-catalog.mjs`.

## CI / deploy
- **`.github/workflows/deploy.yml`** — ⭐ **בונה ופורס את שתי האפליקציות** ל-**GitHub Pages** (branch `gh-pages`, force-push, `.nojekyll`): **Preact** (`npm ci && npm run build`, `GITHUB_PAGES=1`, node 20) → `/buildsmart/` · **Flutter web** (`flutter build web --release --base-href "/buildsmart/flutter/"`, flutter **3.29.3** stable) → מועתק ל-`app/dist/flutter/` → `/buildsmart/flutter/`. trigger: `claude/whats-happening-LyY9G` + `main` + `workflow_dispatch`. **תיקון: גם ה-Flutter חי כ-preview** (`/buildsmart/flutter/`) — לא רק Preact.

## build configs
- **Preact:** `package.json` (deps: preact 10 · @preact/signals · @fontsource/heebo+rubik; dev: vite 5 · vite-plugin-pwa · typescript 5.7 · @playwright/test 1.60 · @capacitor/cli+core 6.2; scripts: dev · **build=`tsc -b && vite build`** · typecheck=`tsc -b --noEmit` · cap:sync/ios/android)(+lock) · `tsconfig.json` (strict + noUnused* + noUncheckedIndexedAccess · jsx=preact) · `vite.config.ts` · `app/index.html`(shell) · `.gitignore`/`README`.
  > ⚠️ **typecheck-caveat (INSP-0015, 2026-05-21):** `npx tsc -b --noEmit` פלט **2 שגיאות ידועות** (`vite.config.ts` + `worker.tsx`) — **build של Vite נקי**; tracked כ-MINOR-פתוח ב-`wip-menu-wiring.md`. (smoke 21/21 + in-app regression **236/236** עוברים בנפרד.)
- **Flutter:** `pubspec.yaml` (sdk ^3.7.2; deps: flutter_riverpod ^2.6 · go_router ^14.6 · intl ^0.19 · flutter_localizations · mobile_scanner ^5.2 · speech_to_text ^7.0 · **permission_handler ^11.3** · shared_preferences ^2.3 · cupertino_icons; dev: very_good_analysis ^7.0; `generate:true`)(+lock) · `analysis_options.yaml` (very_good preset; ללא line-80/public-api-docs) · `.metadata` · platform-scaffold (android/ios/web/macos/linux/windows — 66 קבצי-boilerplate).
  > 🔧 **native-config (אומת מהמקור):** Android `applicationId`/`namespace` = **`com.buildsmart.buildsmart`** (≠ Capacitor `com.buildsmart.app` של Preact — שני bundle-IDs נפרדים) · `build.gradle.kts`: minSdk/targetSdk/compileSdk = ברירות-Flutter · base `AndroidManifest.xml` = boilerplate (label "buildsmart", **ללא הרשאות מותאמות** — plugins ממזגים CAMERA/MIC ב-build) · ⚠️ iOS `Info.plist` = boilerplate **ללא `NSCameraUsageDescription`/`NSMicrophoneUsageDescription`** → **חוסם-launch ל-iOS** (mobile_scanner/speech_to_text דורשים usage-strings; טרם נוספו).

## tests
- **Preact:** `app/src/test/` (8 — registry/runner/buttons/dsync/products/dupes/tabs — דוח 11) · `app/smoke-settings.mjs`.
- **Flutter:** `app_flutter/test/widget_test.dart` (1).

## ⭐ שכבת-פרוטוקול-אכיפה — על `whats-happening`, **לא על `nice-volta`**
> ה"דוחות-פרוטוקולים"/האכיפה. **נעדרת מענף-העבודה הזה** (לכן commits חופשיים כאן). תועד מקריאה בזמן חסימת-ה-commit:
- **`.githooks/pre-commit`** — ~100 "שערים" אוטומטיים; דורש `flutter` ב-PATH (6 נתיבים); חוסם כל הפרת-פרוטוקול. עקיפת-חירום דרך `.emergency_token`.
- **`.githooks/pre-push`** — חוסם push ל-`main|master|production` ללא `.allow_push_main`; חוסם force-push; בודק אורך-הודעה.
- **`.claude/hooks/pre-tool.sh`** — חוסם `--no-verify` · override של `core.hooksPath` · force-push · מחיקת קבצי-הגנה (PROTECTED_PATHS; דורש `.allow_protocol_edit`).
- **`.claude/hooks/session-start.sh`** — מפעיל `core.hooksPath=.githooks` + סיכום.
- **`.github/workflows/protocol-enforce.yml`** + **`scripts/preflight.sh`** (exit 0 ידידותי על ענפים אחרים).
> **תיקון-המשתמש (סשן זה):** כל אלה הוגבלו לרוץ **רק על `whats-happening`** → ענפים חדשים (`nice-volta`) מקבלים commits חופשיים. זו הסיבה שהמאגר הזה נבנה כאן.

---
**הקשר:** הליבה-התפעולית של הפרויקט — איך 3 המקורות נבנים, נארזים-ל-native, נפרסים, ונאכפים. ה-`extract-catalog.mjs` הוא הקשר-החי בין אב-הטיפוס ל-Preact.
