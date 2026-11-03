# BuildSmart — הוראות לכל סשן

## המוצר ולמי
אפליקציית רכש, קטלוג ומשימות לאתרי בנייה — עם דגש על קטלוג אינסטלציה ומנוע תאימות "מה מתחבר למה".
משתמשים (personas): 👷 קבלן · 🦺 עובד · 🏪 חנות ספק · 🛵 שליח · 👔 מנהל המערכת.
עברית, RTL. חי ב-**buildsmart-il.com** (Firebase Hosting, פרויקט `buildsmart-b0b78`). מטרה: השקה בחנויות iOS/Android.
בעלים ומאשר יחיד: **מאיר**.

## 🔴 כללי עבודה (מחייבים)
1. **עברית** — כל תשובה, סטטוס ודוח בעברית. קוד/מזהים באנגלית כרגיל.
2. **מינימום 100%** — לא אומרים "גמור" בלי הוכחה: הפקודות בסעיף "פקודות" רצו ירוקות, ובשינוי UI — צילום מסך.
   מדווחים כשל כפי שהוא, עם הפלט. לא מדלגים/משתיקים טסט כדי לקבל ירוק.
3. **ענפים בלבד** — כל עבודה על ענף `claude/<שם>`. אין commit ישיר ל-main.
4. **בלי אישור מפורש של מאיר — אסור:** push ל-`main` · מיזוג PR · פרסום (deploy, ריפו ציבורי, רשת) · מחיקה · שליחת מיילים/הודעות · תשלום.
   ⚠️ push ל-`claude/whats-happening-LyY9G` **מפעיל deploy לפרודקשן** (`web-deploy.yml` + `firebase-hosting.yml` → Hosting live;
   `firebase-deploy.yml` → rules+functions). push ל-`main` מפעיל `deploy.yml` (GitHub Pages). כל אלה = פרסום.
5. PR נפתח כ-**draft**, ולא ממוזג על ידי Claude.
6. עבודה רציפה: צעדים הפיכים (עריכה, טסט, commit בענף) — בלי לעצור לשאול.
7. **נחיל 9×9** (חוק-על של הבעלים): משימות קוד מתחילות בנחיל — 9 תפקידים × 9 עדשות
   (`orchestrator/lenses/registry.txt`), זרימה: מבקרים → מאמת → בונים לפי קבצים דיסיונקטיים → מפקח + השער
   `orchestrator/scripts/central-verify.sh`. הפעלה: skill `swarm`. המוח: `orchestrator/PLAYBOOK.md`.

## Stack
| תיקייה | מה | סטטוס |
|---|---|---|
| `app_flutter/` | Flutter (Dart) + Riverpod, iOS/Android/Web | **🟢 הפעיל — כל פיצ'ר חדש כאן.** זה מה שחי ב-buildsmart-il.com |
| `app/` | Preact + TypeScript + Vite + PWA (+Capacitor) | 🟡 legacy/reference (GitHub Pages). תיקוני באגים בלבד |
| `functions/` | Firebase Cloud Functions v2, Node 20, TS strict, region `me-west1` | שרת: תפקידים, שלבי-הזמנה, R2, AI |
| `edge-proxy/` | Cloudflare Worker (`api.buildsmart-il.com`) | מתווך לכל תעבורת Google |
| `scripts/` | Python QA קטלוג + `gen_version.sh` | |
| `firestore.rules` · `rules_test/` | חוקי אבטחה + טסטים שלהם | |
| `orchestrator/` · `atom-engine/` · `tools/atom` | מנגנון הנחיל ומחולל ה-atoms | |

גרסאות: CI בונה ב-**Flutter 3.44.0** (Dart 3.12); `protocol-enforce.yml` ו-`catalog-qa.yml` רצים על **3.29.3**. `pubspec`: `sdk: ^3.7.2`.

## פקודות (אומתו בסשן 2026-11-03)
**Flutter** — אם אין Flutter מקומי:
```bash
curl -sSfL -o /home/user/flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.44.0-stable.tar.xz && tar xf /home/user/flutter.tar.xz -C /home/user
```
```bash
export PATH="/home/user/flutter/bin:$PATH"
cd app_flutter && flutter pub get                 # install
bash ../scripts/gen_version.sh                     # חובה לפני analyze — מייצר lib/version.g.dart (gitignored)
flutter analyze --no-pub                           # lint — השער: 0 errors (warnings/infos קיימים, לא חוסמים)
flutter test --reporter=compact                    # כל הטסטים: 6034 ✅ · 12 skip (~18 דק')
flutter test test/<file>_test.dart                 # טסט בודד
flutter build web --release                        # build (ה-deploy מוסיף --dart-define רבים — ראה web-deploy.yml)
```
השער המלא (pub get + codegen + analyze + test + build): `bash orchestrator/scripts/central-verify.sh app_flutter`

**Preact (`app/`)**
```bash
cd app && npm ci                 # install
npx tsc -b --noEmit              # typecheck
npm run build                    # build → app/dist
```
smoke (מהשורש, אחרי build) — 21/21:
```bash
npx --yes http-server app/dist -p 8123 -s &
node app/smoke-settings.mjs
```
⚠️ `smoke-settings.mjs` מקודד נתיב Chromium `/opt/pw-browsers/chromium-1194/...`; בסביבה הנוכחית הוא `chromium-1243/chrome-linux64/chrome` — יש להחליף בהעתק זמני (ראה STATUS.md).

**Functions**
```bash
cd functions && npm ci && npm run typecheck && npm run selftest   # selftest 100/100
```
**קטלוג**
```bash
python3 scripts/catalog_qa.py selftest && python3 scripts/catalog_qa.py audit
```

## ארכיטקטורה (Flutter) — בקצרה
- כניסה: `lib/main.dart` → `MaterialApp` (he-IL, RTL) → `HomeShell` (`lib/screens/home_shell.dart`).
- Shell: AppBar + 4 טאבים ב-`IndexedStack` — בית (`CatalogScreen`) · מחלקות · עדכונים (התראות+שיחות) · חנות; FAB עגלה (+ FAB מקלדת מגודר בדגל).
  ה-dials הישנים (BS/חיפוש/תפריט) הוסרו — הפרסונות עברו ל-dashboards; `lib/state/dial_state.dart` נשאר ל-`mainTabProvider`/`activePersonaProvider`.
- `lib/screens/` (~120 מסכים) · `lib/state/` (Riverpod providers, persist ב-SharedPreferences) ·
  `lib/logic/` (לוגיקה טהורה) · `lib/data/` (קטלוג, מותגים) · `lib/services/` (Firebase, AI, R2) ·
  `lib/features/` (פיצ'רים מגודרים בדגל) · `lib/theme/` (tokens, light+dark) · `lib/atoms/` (קוד מחולל).
- פיצ'רים מגודרים ב-`--dart-define` (const, ברירת-מחדל OFF ⇒ ה-demo byte-identical). הדגלים החיים ב-`.github/workflows/web-deploy.yml`.
- Backend: Firebase Auth + Firestore (`firestore.rules`) + Functions; תמונות מוצר ב-Cloudflare R2 (`lib/data/product_images.dart` — resolver יחיד).
- פירוט: `app_flutter/knowledge/ARCHITECTURE.md` · חיווט: `app_flutter/WIRING.md` · מפת ידע: `app_flutter/knowledge/README.md`.

## מוסכמות
- Lints: `very_good_analysis` (`app_flutter/analysis_options.yaml`). אסור error אחד ב-analyze.
- Commit: conventional (`feat:`/`fix:`/`docs:`…). `.githooks/commit-msg` אוכף ≥15 תווים וחוסם הודעות-זבל; הפורמט — אזהרה בלבד.
- Hooks: `.githooks/` (pre-commit עם שערי-פרוטוקול; בשינוי Dart דורש עדכון `WIRING.md`, `knowledge/STATUS.md` ועוד).
  אסור `--no-verify`, force-push, או עריכת קבצי הגנה (`.claude/hooks`, `.githooks`, `protocol-enforce.yml`) — חסום ע"י `.claude/hooks/pre-tool.sh`.
- גרסה: תווית `vX.YY` נקבעת **רק** ב-`app_flutter/knowledge/STATUS.md` (ההופעה הראשונה של `vX.YY` בקובץ, כיום שורה 3); `gen_version.sh` גוזר ממנה. לא לערוך את `version.g.dart`.
- `known-failing: N` ב-`app_flutter/knowledge/STATUS.md` = baseline לכשלים; היעד 0.
- טקסטים בעברית verbatim מה-legacy; string חדש ב-`app/` מועתק verbatim ל-`app_flutter/`.
- Theme: צבעים רק דרך tokens של `lib/theme/` (לא hex קשיח); מסכים חייבים לתמוך light+dark.
- כל טענת "תוקן" מגובה בטסט. באג = טסט רגרסיה.

## Preact `app/` — זרימת Inspector (רק בשינוי settings/menu/dial)
typecheck + build + smoke 21/21 + סוכן Explore בלתי-תלוי (GO) → דוח `app/knowledge/inspections/INSP-NNNN-*.md`.
אל תיגע בלי בקשה מפורשת: `app/src/components/menu/`, `app/src/components/bs/`, `app/src/store/{app-settings,bs-store,toast-store}.ts`, `app/knowledge/`, `app/RULES.md`.
`app/knowledge/IMPLEMENTATION_PROTOCOL.md` — DEPRECATED, היסטורי בלבד.

## קבצי מפתח
| קובץ | תפקיד |
|---|---|
| `STATUS.md` (שורש) | מצב נוכחי, בעיות פתוחות, Next |
| `app_flutter/knowledge/STATUS.md` | יומן גרסאות מפורט + תווית הגרסה |
| `app_flutter/WIRING.md` | מפת חיווט מסכים/providers |
| `app_flutter/knowledge/GATE_REGISTRY.md` | רישום השערים (gates) |
| `orchestrator/PLAYBOOK.md` · `FACTORY.md` | מנגנון הנחיל |
| `CATALOG_PROTOCOL.md` | פרוטוקול נתוני הקטלוג |
| `.github/workflows/` | CI + deploy (שים לב לענפי הטריגר) |
