# תשתית: build · native · CI · tooling · protocol (חוצה-מקורות)

> "שאר הקבצים" — packaging/CI/tooling + שכבת-הפרוטוקול. לא ידע-מוצר, אבל חלק מהפרויקט.

## ⭐ אריזה ל-native (חנויות)
- **Preact → Capacitor** (`app/capacitor.config.ts`): `appId:'com.buildsmart.app'` · `webDir:'dist'` + ios/android. 🔧 **תיקון (app/README):** Capacitor **מוגדר אך טרם-נוסף** — "תיוסף בשלב הבא"; `npm i @capacitor/ios/android` + `npx cap add` עדיין ממתינים. כלומר native-packaging **מתוכנן, לא פעיל**. (Preact כיום = web/PWA.)
- **Flutter → native מובנה** (`flutter build ios/android/web`).
→ **שני מסלולים לחנויות:** Preact+Capacitor · Flutter-native.

## ⭐ צינור-הנתונים prototype→Preact (`app/scripts/extract-catalog.mjs`)
**הכלי שמחבר את המקורות:** קורא `../index.html`, מרים `CATALOG`/`VARIANTS`/`STORE_PRICING`/`TOOLS` ל-`src/data/*.ts` מטוייפים, **ומפענח base64-JPEGs מוטמעים → `public/catalog/*.jpg`**.
→ זה מקור השורות-הענק ב-index.html (תמונות base64) ושל `image:/catalog/*.jpg` (דוחות 03/04). הרצה: `node scripts/extract-catalog.mjs`.

## CI / deploy
- **`.github/workflows/deploy.yml`** — בונה **Preact** (`npm ci && npm run build`, `GITHUB_PAGES=1`) ופורס ל-**GitHub Pages**. trigger: `claude/whats-happening-LyY9G` + `main`.

## build configs
- **Preact:** `package.json`(+lock) · `tsconfig.json` · `vite.config.ts` · `app/index.html`(shell) · `.gitignore`/`README`.
  > ⚠️ **typecheck-caveat (INSP-0015, 2026-05-21):** `npx tsc -b --noEmit` פלט **2 שגיאות ידועות** (`vite.config.ts` + `worker.tsx`) — **build של Vite נקי**; tracked כ-MINOR-פתוח ב-`wip-menu-wiring.md`. (smoke 21/21 + in-app regression **236/236** עוברים בנפרד.)
- **Flutter:** `pubspec.yaml`(+lock) · `analysis_options.yaml` · `.metadata` · platform-scaffold (android/ios/web/macos/linux/windows — 66 קבצי-boilerplate).

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
