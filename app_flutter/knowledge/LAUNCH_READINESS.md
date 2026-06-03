# דוח מוכנות-השקה — BuildSmart (`app_flutter/`)

> **סוכן:** משיק · **ענף:** `claude/whats-happening-LyY9G`
> **נוצר:** 2026-06-01 · **שלב נוכחי:** A (Audit — קריאה-בלבד) · **סטטוס:** 🚧 בעבודה
> **תוצר זה הוא ה-bible של ההשקה** — backlog מתועדף + המלצת go/no-go.
> מטרה: השקה ב-iOS · Android · Web/PWA.

מקרא צעדים: ✅ בוצע · ⚠️ ממצא · ❌ חוסם · ⬜ טרם.
מקרא חומרה: **P0** = חוסם-השקה · **P1** = חשוב לפני השקה · **P2** = nice-to-have.

> **עיקרון-מתודולוגי (verbatim + ללא-המצאה):** לא-מחווט ≠ "מת". פיצ׳ר מעוגן-ספק שאינו מחובר = **🚧** (לחווט/לגדר),
> **לא** מועמד-למחיקה. כל הסטטוסים אומתו מול `spec/` + `WIRING.md` (פרוטוקול-הבדיקה), לא מ-grep בלבד.
> *(תיקון לגרסה מוקדמת שתייגה dials/toggles כ"מתים" — הם פערים-ידועים מתועדים ב-`spec/shell-and-dials.md §7`.)*

---

## 🆕 עדכון P0 (2026-06-03 — בנצי · אחרי v5.97)
source-prep מתוך `PLAN-contractor-completion` (בלוק P0 השקה) + audit-חתימה:
- ✅ **iOS usage-strings** → `ios/Runner/Info.plist`: NSCamera + NSMicrophone + NSSpeechRecognition (ל-mobile_scanner + speech_to_text). חוסם-iOS-P0 הוסר ברמת-המקור.
- ✅ **Android permissions** → `AndroidManifest.xml`: CAMERA (+`uses-feature` required=false) + RECORD_AUDIO (לצד INTERNET הקיים).
- ✅ **חתימת-Android — מוכנה (תיקון: הסטטוס "debug keys" היה stale):** `build.gradle.kts` → `signingConfigs.create("release")` קורא מ-`key.properties` (קיים · **gitignored** · keyAlias=`upload`); ה-keystore **קיים בפועל** ב-`C:/Users/User/android-build/keystore/upload-keystore.jks`. `.gitignore` חוסם `key.properties`+`*.jks`. **חתימה אינה חוסם יותר.**
- ⬜ **נותר (user-step / CI, לא-קוד):** AAB ב-CI (`android-package.yml`) · iOS signing-team + Mac/CI build · חשבונות Apple/Google + privacy-policy (CAMERA/RECORD_AUDIO דורשים גילוי ב-Play).

## 0. סביבה וחוסמי-תשתית (לפני הכל)

> אלה לא ממצאי-קוד — אלה תנאים סביבתיים שמשפיעים על האודיט ועל שלב ה-Fix.

| # | נושא | מצב | השפעה |
|---|------|-----|--------|
| ENV-1 | **git — קונפליקט נפתר תוך-כדי ע״י סוכן אחר** | בתחילת הסשן: `HEAD (no branch)` + `UU`. בהמשך: חזר ל-branch `claude/whats-happening-LyY9G`, ללא קונפליקט, גרסה קפצה v5.49→v5.51 | 🟢 נפתר (לא על-ידי משיק). **אך:** מעיד על **עץ-עבודה תנודתי** — סוכנים מקבילים עורכים בזמן-אמת. |
| ENV-1b | **עץ-עבודה משותף ותנודתי** | `flutter test` הראשון נכשל כי `home_shell.dart` הכיל סמני-קונפליקט (`<<<<<<<`/`>>>>>>>`) באמצע rebase של סוכן אחר; דקות אחר-כך הקובץ נקי | 🟠 ה-audit הוא על "מטרה נעה". ממצאי-מבנה יציבים; מספרי-שורות עלולים להתיישן. ל-go/no-go אמין כדאי snapshot קפוא. |
| ENV-2 | **ספריית-עבודה שגויה** | CWD של הסשן = `Desktop\New folder` (ריק); הפרויקט ב-`Desktop\buildsmart` | 🟠 עוקף ב-audit (נתיב מוחלט). לפני git/flutter/push — להריץ מתוך `Desktop\buildsmart`. |
| ENV-3 | **גרסת Flutter — נפתר** | מותקן 3.44.0 / Dart 3.12 (`C:\flutter`). **`deploy.yml` (GitHub Pages) משתמש ב-3.44.0** | 🟢 3.44 = גרסת ה-deploy בפועל. `pubspec.lock` לא השתנה תחת `pub get` ב-3.44 (זהה). אין פער. |
| ENV-4 | **סביבת-בנייה למובייל חסרה (יעד=טלפון)** | `flutter doctor`: **[X] אין Android SDK**; המכונה = Windows → **iOS לא-בָּנִיק כלל** (חובה macOS+Xcode). web בלבד עובד מקומית | 🔴 לבניית-מובייל: או (א) התקנת Android SDK (אנדרואיד) + Mac/macOS-CI (iOS), או (ב) **CI ענן — GitHub Actions (כבר בריפו)** לשתי הפלטפורמות. **הכנת-המקור (Info.plist/manifest/icons/signing-struct/assets) תקינה ללא תלות בזה.** פרסום עדיין דורש חשבונות (ENV-חשבונות). |

**מסקנה:** האודיט (A–H) רץ על 3.44 (= גרסת deploy). ENV-1/ENV-3 נפתרו. הסיכון הפתוח = **תנודתיות העץ** (ENV-1b)
— מומלץ להקפיא עבודת-סוכנים בזמן אימות-השקה סופי. הערה: `flutter build --release` עדכן `pubspec.lock`
(11 transitive, intl 0.19→0.20 תחת 3.44) — **לא קומיטתי**; ייתכן שינוי לא-מקומט בעץ המשותף.

**עדכון-בנייה (2026-06-01):** Android SDK 36 הותקן מקומית (`flutter doctor` ✓ toolchain), אך **בניית-אנדרואיד
מקומית נתקעת שוב-ושוב** (Gradle hang ב-Windows; RAM 15.8GB → **לא** זיכרון; 2 ניסיונות, אותו `assembleDebug`).
**הוכרע: בנייה ב-CI (Linux)** — נוסף **`.github/workflows/android-package.yml`** (בונה AAB+APK, מעלה artifacts,
trigger ידני/push). `deploy.yml` ממילא כבר בונה APK. **הרצת ה-workflow דורשת push** (אישור-משתמש).
AAB יהיה debug-signed עד חיבור keystore → אז Play-ready.

---

## 1. סיכום מנהלים

**האפליקציה עצמה בריאה ומוכנה-פונקציונלית; חוסמי-ההשקה הם קונפיגורציית-חנות, לא קוד.**
~54.5k שורות Flutter (113 קבצי-lib). `flutter analyze` = **0 errors** (37 warn dead-code · ~1,656 info style).
`flutter test` = **ירוק מלא** (~948; 700+ בדיקות-דומיין, mutation + regression-gate). ארכיטקטורה **נקייה**
(הפרדת-שכבות, SSOT, בידוד-Preact מצוין). אבטחה **מצוינת** (offline מלא, 0 secrets, 0 PII).

**פערים עיקריים:** (1) קונפיג-חנות — signing iOS/Android + usage-strings iOS **[P0]**; (2) **assets 101MB**
לא-ממוטבים **[P1]**; (3) UI לא-מחווט (**🚧 פער-ידוע מתועד**, spec §7) — Search/Menu dials + פישוט status-line ב-AppBar **[P1]**;
(4) RTL polish + a11y/Semantics **[P1]**; (5) אין global-error-handler / autoDispose **[P1]**; (6) dead-code/
deps/duplication/~583 צבעים-קשיחים **[P2]**. **הקוד אינו דורש שכתוב** — ניקיון + קונפיג + נכסים בלבד.

## 2. המלצת go / no-go

**🔴 NO-GO היום ל-iOS/Android · 🟢 Web קרוב-לבשל (אחרי אופטימיזציית-assets P1).**

| פלטפורמה | החלטה | חוסמי-P0 |
|---|---|---|
| **Web/PWA** | 🟢 GO לאחר P1 | אין P0; assets 101MB = P1 לפני production |
| **iOS** | 🔴 NO-GO | usage-strings (NSCamera/NSMicrophone) + signing-team |
| **Android** | 🟡 קרוב-GO — חתימה מוכנה (v5.97) | AAB ב-CI · חשבון Play · privacy-policy — **לא** חתימה |

**קריטריון go:** P0=0 לפלטפורמה + אימות `flutter build` עובר על **snapshot קפוא** (ENV-1b).
**הערכת-מאמץ למובייל:** ~1-2 ימי-עבודה (קונפיג + ניקיון) **+ חשבונות-חנות** (Apple/Google — זמן-הקמה חיצוני).
אין חוסם-ארכיטקטורה. **הגבלה:** האימות בוצע על עץ תנודתי (סוכנים מקבילים) — סימן-סופי דורש הקפאה.

---

## 2.5 התוצר הסופי — `LAUNCH_PACKAGE/` (Google Play)  *(פרוטוקול מעודכן: terminal deliverable)*

> המטרה: **אפליקציית-טלפון לאנדרואיד** — חבילת-הגשה ל-Google Play (iOS/Web משניים).
> כשהחבילה מוכנה — המשתמש מעלה ל-Play Console וזהו. (אריזה ל-`app_flutter/LAUNCH_PACKAGE/`.)

| פריט | מי | מצב |
|---|---|---|
| `data-safety.md` (טופס Google) | בנצי | ✅ **נוצר** (מ-פאזה H: offline, 0 PII) |
| `SEND_TO_GOOGLE.md` (runbook) | בנצי | ניתן עכשיו (עם ⬜) |
| `privacy-policy` טיוטה + `release-notes-he.txt` | בנצי טיוטה | ניתן; URL חי = ⬜ משתמש |
| signing config (`key.properties` + `build.gradle.kts`) | בנצי מכין | מבנה עכשיו; keystore = ⬜ משתמש |
| `store-listing/` (כותרת/תיאור he-en · icon 512 · feature-graphic · screenshots) | בנצי מה-שאפשר | icon/screenshots חלקי; קופי-שיווק = ⬜ משתמש (אין-המצאת-טקסט) |
| **`app-release.aab` חתום** | build | ⬜ דורש keystore + (Android SDK מקומי **או** CI) |

**⬜ דרוש ממך (צעד 96 — עוצר-אריזה):** (1) **release keystore + סיסמאות**; (2) **applicationId** סופי
(כיום `com.buildsmart.buildsmart` — לאשר); (3) **חשבון Google Play**; (4) **privacy-policy URL** חי;
(5) דרך-בנייה: התקנת **Android SDK** כאן **או** **CI (GitHub Actions)**.

**ניקיון/ליטוש (RTL/a11y/dead-code/צבעים/dups/dark-gate)** → **מבוצע ע״י סוכן ליטוש** (בנצי מאתֵר+מתעדף; §0.7).

---

## פאזה A — אוריינטציה ומיפוי (1–10) — ✅ הושלם

**גרסאות (צעד 8):** Flutter יעד 3.29 (רץ 3.44) · Dart SDK `^3.7.2` · Riverpod `^2.6.1` ·
go_router `^14.6.2` · intl `any` · mobile_scanner `^5.2.3` · permission_handler `^11.3.1` ·
shared_preferences `^2.3.4` · speech_to_text `^7.0.0` · very_good_analysis `^7.0.0`.
**גרסת-אפליקציה:** `pubspec` `version: 1.4.1+6`; label ב-`home_shell` = `v5.49 · 1.6.26`.

**מדדי-קוד (צעד 5):**
| תיקייה | קבצים | שורות |
|---|---|---|
| `lib/` (סה״כ) | 113 | 54,537 |
| `lib/screens` | 24 | 27,662 |
| `lib/data` | 23 | 17,150 |
| `lib/state` | 39 | 3,936 |
| `lib/test_harness` | 15 | 2,983 |
| `lib/logic` | 4 | 2,078 |
| `lib/widgets` | 3 | 400 |
| `lib/theme` | 2 | 114 |
| `lib/l10n` | 1 | 109 |
| `lib/services` | 1 | 43 |
| `test/` | 142 | 12,947 |

**Bootstrap (צעד 6):** `main()` → `registerPolyrollSpecs()` (side-effect) → `ProviderScope` →
`BuildSmartApp` (`ConsumerWidget`) → `MaterialApp(home: HomeShell)`. תמה light/dark מ-`AppTheme`,
`themeMode` נשלט ע״י `settings.theme`. locale נשלט ע״י `settings.lang` (he/ar/en). RTL גלובלי +
`textScaler` גלובלי מ-`catalogSettings`. `debugShowCheckedModeBanner:false` ✅.

**ניווט (צעד 7) — מודל-הכפתורים + אין-חלון-מלא:** shell בסגנון WhatsApp — `IndexedStack` עם 4 טאבים
(קטלוג·שיחות·התראות·חנות) + 3 דיאלים (BS/search/menu, אחד-בכל-פעם, scrim שחור 45%) + Cart-FAB
צף (מוסתר בטאב חנות). הגדרות נפתחות כ-`Navigator.push` מסך-מלא; בוררים קצרים כ-`showModalBottomSheet`.
→ ראה ממצאים F-A1..F-A6.

**analyze (צעד 26, הוקדם):** **0 errors** ✅ · 37 warnings · ~1,568 infos. הקונפיג =
`very_good_analysis` (strict) עם `public_member_api_docs:false` + `lines_longer_than_80_chars:false`.

### ממצאי פאזה A
- **F-A1 (P1, איכות — מעוגן-ספק §1.3):** שורת ה-status ב-AppBar מציגה את לייבל-הגרסה + changelog
  (`home_shell:390`; **אלמנט מכוון** לפי spec §1.3 + קריטריון-קבלה 3, מסונכרן ע״י `knowledge_protocol_test`).
  לקהל-קצה זה נראה פנימי. **החלטת-launch:** לפשט לגרסה נקייה (שינוי-תצוגה, **לא** באג/מחיקה; לשמר את ה-gate שמסנכרן home_shell↔STATUS).
- **F-A2 (P1, ✅ מאומת):** `go_router ^14.6.2` תלוי ב-`pubspec` אך **0 שימושים** ב-`lib/`
  (אין `GoRoute`/`MaterialApp.router`/`context.go`). תלות מתה → להסיר מ-`pubspec`. כמו-כן:
  **אין תשתית-routing כלל** → deep-links (צעד 84) ידרשו בנייה מאפס.
- **F-A3 (P1, איכות — מעוגן-ספק, *לא* המצאה):** toggles dark + ar/en **מעוגנים ב-`settings_tree`** (spec §4.1,
  side-effects ב-`_applyLeaf`) — **לא "המצאה"** (תיקון לקביעתי הקודמת). מצב: (א) ב-Menu-dial ה-🚧 → לא נגישים
  כרגע (F-A5); (ב) **dark** = תמה-M3 אמיתית (`AppTheme.dark`) אך המסכים מקבעים light → כשה-dial יחווט,
  "כהה" תפיק UI שבור; (ג) ar/en לא-מתורגמים + RTL מקובע. **החלטה (עברית-בלבד v1 ✅):** לפני חיווט
  ה-settings-dial — לגדר `themeMode.light` ולהסתיר/לנטרל ar/en+כהה (**להשאיר במודל 🚧, לא למחוק**).
- **F-A4 (P1):** `lib/test_harness/` (2,983 שורות) נארז ב-bundle ה-production. להחריג מ-release
  (assert/kReleaseMode guard / הוצאה מ-`lib`). משפיע על צעד 53/54.
- **F-A5 (P1, 🚧 פער-ידוע מתועד — *לא* "מת"):** מאומת מול **`spec/shell-and-dials.md §7.1`**: ה-Search/Menu
  dials מצוירים (`home_shell:65-79`) אך אין trigger ב-UI שמציב `OpenDial.menu/.search` — בפועל רק BS-dial
  נגיש (wordmark). **הספק עצמו מסווג זאת כפער-ידוע, והפתרון המוגדר = להוסיף triggers (מודל-5-הכפתורים) — לא למחוק.**
  גם `OpenDial.bsMode` (§7.2) לא ממומש. עצי Menu/Search (כולל ההגדרות) = פיצ׳רים מעוגני-ספק במצב **🚧**.
  **החלטה:** לחווט לקראת השקה (5-FABs), **או** להשיק עם BS-dial בלבד ולתעד 🚧 (לא מחיקה).
- **F-A6 (דורש-החלטה — מודל-הניווט):** ה-Flutter מנווט בניגוד למודל ה-dial-בלבד הקשיח של `app/` (מסכי-מלא ל-settings,
  modal-sheets לבוררים). CONVENTIONS מפרש זאת ל-Flutter כ"אין persona-views מסך-מלא" (מרוכך).
  כל האפליקציה בנויה כך ועוברת `knowledge_protocol_test` — צריך אישור-משתמש האם זה תקין להשקה.

---

## פאזה B — ארכיטקטורה (11–25) — 🚧 חלקי (11–19,22–25 בסריקת-עומק רקע)
_צעדים: 11 שכבות · 12 Riverpod/scoping/autoDispose · 13 logic-ב-widgets · 14 data layer ·
15 data→state→UI SSOT · 16 circular deps · 17 עקביות-דפוס · 18 theme/tokens · 19 error-handling ·
20 ניווט (אין-חלון-מלא) · 21 God-objects >500 שורות · 22 הפרדת Preact-shared (שער 25) · 23 persistence ·
24 async/race · 25 סיכום._

- **F-B1 (P1/P2, צעד 21):** God-objects: `catalog_screen.dart` **7,136** · `install_studio_screen.dart`
  3,096 · `lipskey_product_sheet.dart` 2,809 · `store_screen.dart` 2,773 · `lipskey_products_screen.dart`
  2,057 · `chats_screen.dart` 1,327 (קבצי data גדולים = צפוי).
- **F-B2 (P2, צעד 18):** `BsTokens` מרכז brand+בסיס-light/dark+spacing+radii, אך **אין tokens סמנטיים**
  (status red/green/amber, divider) → מאלץ ~583 צבעים קשיחים (קושר ל-F-C5). `AppTheme.dark` הוא תמה-M3
  **אמיתית**, אך המסכים מקבעים צבעי-light → dark מפיק UI שבור/היברידי (קושר ל-F-A3; להמליץ לקבע `themeMode.light`).
- **ארגון/SSOT/Preact (11/15/22) ✅ חוזקות:** הפרדת UI/state/logic/data **נקייה** (לוגיקה כבדה ב-helpers/
  data, לא ב-build); SSOT יחיד ל-catalog/cart/settings; **בידוד Preact-shared מצוין** (5 קבצי-settings =
  חוזה-JSON טהור, TimeOfDay רק ב-getters לא-נשמרים; שער 25 מכובד); אין coupling הפוך data→screens, אין circular.
- **F-B3 (P1, צעד 12):** **`autoDispose` לא בשימוש כלל** — ~48 providers (13 StateProvider + 33 StateNotifier;
  0 Future/Stream) חיים-לעד. state-UI חולף (search/dial/menu) ראוי ל-autoDispose. צריכת-זיכרון.
- **F-B4 (P1, צעד 19):** **אין global error handler** — אין `FlutterError.onError`/`runZonedGuarded`/`ErrorWidget.builder`.
  קריסות → red-screen/console; **`crash_log.dart` קיים אך שום-דבר לא מזין אותו** מ-handler גלובלי. תיקון זול+חשוב.
- **F-B5 (P2, צעד 24):** async-init race — כל 6 notifiers-persistence עושים `unawaited(_load())` ב-ctor →
  ה-UI עלול לקרוא defaults 50-200ms לפני הידרציה (flash; קושר ל-F-A3 dark). אין `AsyncValue`/FutureProvider.
- **F-B6 (P2, צעד 19):** silent-swallow — `catch(_){}` ב-SharedPreferences/jsonDecode נופל ל-defaults ללא log/UI.
  **F-B7 (P2, צעד 16):** `catalog_screen` מייבא 5 מסכים (coupling-ניווט).

---

## פאזה C — ניקיון וארגון-קוד (26–40) — 🚧 חלקי
_צעדים: 26 analyze ✅ · 27 format · 28 dead-code · 29 duplication · 30 naming · 31 imports ·
32 TODO/FIXME · 33 magic-numbers · 34 קבצים-במיקום-שגוי · 35 const חסרים · 36 comments · 37 lints ·
38 assets · 39 מבנה-תיקיות · 40 סיכום._

- **F-C1 (P2):** ~1,568 infos של `very_good_analysis` (`avoid_redundant_argument_values`,
  `omit_local_variable_types`, `sort_constructors_first`, `cascade_invocations`…) — רבים auto-fix
  ב-`dart fix --apply`. תיקון-בטוח לפאזה C.
- **F-C2 (P2, dead-code, צעד 28):** 37 warnings; רובם `unused_element/import/local`:
  `_dnTok`, `_VariantSelector`, `_AccRow`, `_selectVariant`, `_sizeTokens`, `_attrEmoji`,
  `_sizeLabel`, `_firstSizeNum`, `_bySku/_byCat`, `jointB`, ועוד. **`_MiniPill` מת ומשוכפל ב-3
  מסכים** (chats/notifications/store) → גם duplication (צעד 29).
- **F-C3 (P2):** `unnecessary_non_null_assertion` (lipskey_products_screen 1921/1922) +
  `unnecessary_type_check` (test_harness/settings 264) + inference-failures (Future.delayed,
  MaterialPageRoute ×2, List ×2) — תיקוני-טייפ בטוחים.
- **F-C4 (P2, duplication, צעד 29):** ~20 מחלקות-widget פרטיות משוכפלות בין מסכים (~600 שורות):
  `_MiniPill`×3 (byte-identical, גם מת), `_Pill`×4, `_SearchBar`×3, `_SectionTile`×4, `_SwitchRow`×4,
  `_RadioGroupRow`×4, `_PlaceholderRow`×4, `_ActionRow`×3 ועוד. 4 מסכי-ההגדרות ~30-40% ניתנים-לשיתוף
  (→ `lib/widgets/shared_rows.dart`).
- **F-C5 (P2, magic, צעד 33):** 977 ליטרלי `Color(0x...)` ב-`lib/`, ~583 לא-מורשים. עיקריים:
  `0xFFFF7A18`×24 (=`BsTokens.brand`!), `0xFFF5F5F5`×68, `0xFFEF4444`×31 (status-red), `0xFFEEEEEE`×20
  (divider), `0xFF22C55E`×16 (success), `0xFFB45309`×11 (warning). → להוסיף `BsTokens.status*/divider`.
- **✅ נקי (צעדים 30/32/34):** 0 TODO/FIXME/HACK · שמות עקביים (snake_case/PascalCase) · **ארגון-תיקיות נקי**
  (אין קבצים-במיקום-שגוי).

---

## פאזה D — נכונות וכיסוי-בדיקות (41–52) — ✅ נסרק
- **41 ✅:** `flutter test` **exit 0 — כל ה-suite ירוק** על עץ נקי (baseline 927 + בדיקות-lens חדשות ≈948).
  הכישלון הראשון = ארטיפקט-rebase זמני (ENV-1b), **לא** רגרסיה.
- **כיסוי (42/43):** **לוגיקת-דומיין מכוסה מצוין** — 102 קבצי-test, 700+ בדיקות; pure-helpers,
  `mutation_test`, ו-meta `regression_gate_test` (כל 47 ה-helpers חייבים test). קטלוג/compat/engine/cart/persistence חסינים.
- **פער (43/44/47) [P1/P2]:** **כיסוי UI/widget/integration דליל בכוונה** — רק `widget_test` (boot smoke)
  + `product_journey` (pumps 935 sheets). המסכים הגדולים (catalog/store/chats/notifications/finder/
  settings/install_studio) **לא** נבדקים ברמת-UI/אינטראקציה/ניווט. **אין golden-tests** · **אין integration_test** (E2E מכשיר).
- **48 ✅:** שערי-hook (35–40) + `knowledge_protocol_test` (sync גרסה home_shell↔STATUS) קיימים ועוברים.
- **F-D1 (P1):** להוסיף לפני/אחרי השקה בדיקות-widget/integration לזרימות-ליבה (checkout · finder · search) +
  golden לכמה מסכים. לא חוסם (QA ידני + `QA_STORE_REPORT` מכסים חלקית), אך הסיכון = רגרסיות-UI/ניווט לא-נתפסות.

---

## פאזה E — ביצועים (53–64) — ✅ נסרק
- **53 ✅:** `flutter build web --release` עבר (exit 0, 147s). **`main.dart.js` = 5.33 MB** (uncompressed;
  ~1.3-1.6 MB gzipped). ⚠️ STATUS גרס "2.0 MB" — פער (doc-drift/גידול/3.44). step 53 מבקש לשמור מגמה.
- **54 [P2]:** אין code-splitting/deferred — `main.dart` מונוליטי (אין go_router→אין split-per-route).
  Wasm dry-run הצליח → `--wasm` אופציה לשיפור-ביצועים (משנה renderer).
- **57/61 [P1] — חוסם-משקל:** **`assets/` = 101.2 MB / 1,344 קבצים** — 1,317 JPEG לא-ממוטבים (98 MB!),
  ללא WebP, סריקות-עמוד עד 1.3MB. lipskey 90.8MB · polyroll 10.2MB. → גודל-הורדה ~100MB (mobile) +
  cache-PWA ענק (web). המרה ל-WebP + resize ↓ ~50-70%. **הנהג המרכזי לגודל-האפליקציה.**
- **58/59 [P2]:** רשימות `ListView`/grid (לא נמדד jank חי); ללא `autoDispose` (F-B3); תמונות `AssetImage`
  (טעינה-on-demand מרככת runtime, אך הכל נארז ב-bundle).
- **F-E1 (P1):** אופטימיזציית-assets (WebP/resize/הסרת-לא-בשימוש) — פתרון ל-v1 (101MB→~30-40MB).
- **F-E2 (P1, ארכיטקטורת-נכסים — קריטי-לסקייל):** המודל הנוכחי אורז את **כל** התמונות ב-bundle — **לא
  סקיילבילי.** בקטלוג גדול (עשרות/מאות-אלפי תמונות) האפליקציה תהיה GB-ים → בלתי-אפשרי לארוז/להעלות.
  **פתרון-סקייל:** תמונות ב-server/CDN, טעינה on-demand + cache מקומי (`cached_network_image`) →
  גודל-אפליקציה קבוע-וקטן ללא תלות בגודל-הקטלוג. **trade-off:** שובר את מודל ה-offline-מלא (דורש
  hosting + רשת לטעינה-ראשונה; משפיע על פאזה H). חלופות: **Play Asset Delivery** (גוגל מארחת, Android,
  מורכב) · **hybrid** (thumbnails ארוזים + full-res מהרשת). **v1:** דחיסה+אריזה. **לסקייל:** network+cache.
  **בעלות:** החלטת-מוצר + מימוש קטלגן/מקבץ (בנצי מאתֵר). **דורש-החלטת-משתמש.**

### תוכנית-תשתית: תמונות network+cache (סקיילבילי) — "לפי פרוטוקול"
> מעוגן ב-`offline_cache.dart` (step 83) שמצהיר ש-**image-cache הוא consumer-step מתוכנן**.
> מטרה: גודל-אפליקציה **קבוע** ללא תלות בגודל-הקטלוג (תומך 100k+ תמונות). תקן: `cached_network_image`.

**עיצוב מינימלי-נזק (seam):**
1. תלות: `cached_network_image` ל-`pubspec`.
2. **resolver מרכזי** `lib/data/product_images.dart` — `ImageProvider resolveProductImage(String rel)`:
   אם `kImageBaseUrl` מוגדר → `CachedNetworkImageProvider('$base/$rel')` (placeholder=אייקון, fallback=`AssetImage`);
   אחרת → `AssetImage` (התנהגות נוכחית). **config `kImageBaseUrl` ריק כברירת-מחדל → אפס שבירה.**
3. הגירת call-sites (product/page images: `Image.asset`/`AssetImage`) → `resolveProductImage` — **הדרגתי** (זה ה-refactor החוצה-נתיב → קטלגן/סדרן, בתיאום).
4. נשאר ארוז: אייקונים/glyphs/placeholders (קטן). זז לרשת: צילומי-מוצר + עמודי-קטלוג (המסה).
5. offline: טעינה-ראשונה דורשת רשת; אחר-כך disk-cache (cached_network_image). אפשר seed.

**✅ אירוח — הוכרע: Cloudflare R2** (object-storage + CDN; **egress חינם** → הגשת-תמונות זולה, S3-תקני,
סקייל ל-100k+). הקמת ה-bucket = ⬜ משתמש (free-tier, ~10 דק', עם החשבונות) → ראה `LAUNCH_PACKAGE/image-cdn-setup.md`.
התשתית **host-agnostic** → נבנית עכשיו; כתובת ה-R2 מתחברת דרך `kImageBaseUrl` בלבד.

**השפעות:** פאזה H — מוסיף fetch תמונות מ-CDN (היה offline-מלא) → לעדכן `data-safety` (תמונות מ-CDN; עדיין 0 PII).
**בעלות-מימוש:** seam+config = ניתן ע״י בנצי (additive) בתיאום; URL-mapping = קטלגן; החלפת-widget = סדרן/ליטוש.

---

## פאזה F — נגישות · i18n · RTL (65–74) — ✅ נסרק
**RTL (65):** פונקציונלי (Directionality מטפל ב-flex/טקסט) אך הרבה קוד directional לא-בטוח:
~110 `EdgeInsets.fromLTRB` (96 א-סימטריים), 25 `Positioned(left/right)`, 21 `Alignment.centerLeft/Right`,
14 `TextAlign.left/right`. `catalog_screen` החמור. הנראים-לעין (close-X/badge ב-overlay בצד שגוי,
`TextAlign.left` install_studio:2054) = P1; השאר polish = P2.
**a11y (67/70):** רק 12 `Semantics` בכל ה-UI (`dial.dart` טוב; 11 ב-catalog). ~116 אלמנטים אינטראקטיביים
ללא label, ~6 tooltips, Cart-FAB ללא tooltip/semantics. touch-targets רוב תקין; מעט <48dp (checkbox 24×24
catalog:6246, close 36×36).
**i18n (71/72):** **1,879 מחרוזות עברית קשיחות** ב-`lib/screens` מול 31 ב-l10n scaffold ("NOT wired").
externalization מלא ~2-3 שבועות → **post-launch**. **להשקה עברית-בלבד תקין כמות-שהוא** (מחזק F-A3:
ar/en אינם מתורגמים → להסיר toggles).

### ממצאי פאזה F
- **F-F1 (P1):** תיקוני-RTL לאלמנטים הנראים (overlay `Positioned`/`Alignment`/`TextAlign`).
- **F-F2 (P1):** `Semantics`/`tooltip` לאלמנטים אינטראקטיביים מרכזיים (FABs, icon-buttons, dial rows).
- **F-F3 (P2):** RTL polish לכל ה-fromLTRB הא-סימטריים · touch-targets <48dp · externalization (post-launch).

---

## פאזה G — מוכנות-פלטפורמה וחנויות (75–89) — ✅ נסרק
**Web/PWA — 🟢 READY.** `base href`=`$FLUTTER_BASE_HREF` (deploy.yml מציב `/buildsmart/flutter/`),
manifest תקין, icons 192/512/maskable, standalone. (P2: `theme_color`=`#0175C2` כחול-ברירת-מחדל לא כתום-מותג; שם "buildsmart" lowercase.)
**iOS — 🔴 NOT READY.** **P0:** חסרים `NSCameraUsageDescription`+`NSMicrophoneUsageDescription`
(mobile_scanner+speech_to_text) → דחיית App-Store + קריסה. **P0:** אין `DEVELOPMENT_TEAM`/signing.
P1: deployment-target 12.0. ✅ AppIcon מלא · LaunchScreen · bundle `com.buildsmart.buildsmart`.
**Android — 🟠 NOT READY.** **P0:** release חתום ב-**debug keys**
(`signingConfig = signingConfigs.getByName("debug")` + TODO) → אי-העלאה ל-Play. הרשאות
CAMERA/RECORD_AUDIO: app-manifest ריק → **כנראה ממוזגות מ-plugin-manifests, לאמת ב-merged**.
P1: אין adaptive-icon · אין ProGuard/minify · לאמת minSdk≥21. ✅ appId/versions מ-pubspec.
**versioning (88):** עקבי — iOS/Android נגזרים מ-`pubspec 1.4.1+6`.
**deep-links (84):** אין routing (F-A2) → ידרוש בנייה. **push (85):** לא מחווט (⛔, אין engine).
**store-metadata (86)/privacy (87):** טרם — screenshots/תיאור/keywords + privacy-policy + data-safety/nutrition. נדרש לפני הגשה.

---

## פאזה H — אבטחה ונתונים (90–94) — ✅ נסרק — 🟢 תקין להשקה
**posture: אפליקציה offline מלאה — P0-CLEAR בכל הקטגוריות.**
(90) **0 secrets/keys/tokens**; `.gitignore` חוסם bypass-tokens. (91) **0 קריאות-רשת/backend** —
היחיד: בניית-מחרוזת deep-link `related_info.dart:1092`, ללא HTTP; אין HTTP לא-מאובטח.
(93) הרשאות מינימליות ומוצדקות (camera→barcode, mic→voice; טיפול plugin-native).
(92) SharedPreferences = ~37 מפתחות UI-state בלבד, **0 PII**, אין צורך בהצפנה; crash/analytics in-memory בלבד (לא נשמרים — נכון).
- **F-H1 (P2):** crash-reporting in-memory בלבד; Sentry/Crashlytics (roadmap 90) נדחה — בטוח להשקה, ראות-קריסות מוגבלת post-launch.

---

## פאזה I — ניתוח-פערים ו-checklist השקה (95–100) — ⬜ טרם
_95 ריכוז backlog · 96 סיווג P0/P1/P2 · 97 go/no-go criteria · 98 סדר-ביצוע/תלויות ·
99 דורש-החלטת-משתמש · 100 סיכום-מנהלים + המלצה._

---

## Backlog מתועדף  *(ימולא בצעדים 95–96)*

> סטטוס: טיוטה (פאזות A/C/F/G/H + B/D-חלקי). יושלם בצעדים 95–96 אחרי E + B-deep + D.

### P0 — חוסם השקה
- **[iOS]** הוסף `NSCameraUsageDescription` + `NSMicrophoneUsageDescription` ל-`ios/Runner/Info.plist` — דחיית App-Store + קריסה. [G]
- **[iOS]** הגדר `DEVELOPMENT_TEAM` + signing/provisioning ל-release. [G] (דורש חשבון Apple Developer.)
- **[Android]** release signing אמיתי — keystore + `key.properties` (כיום debug keys). [G] (דורש חשבון Google Play.)
- **[All/תשתית]** אמת על snapshot קפוא ש-`flutter build` עובר ללא סמני-קונפליקט (ENV-1b). [ENV]
- _Web: אין P0._

### P1 — חשוב לפני השקה
- **F-A1** — פשט את status-line ב-AppBar לגרסה נקייה לקהל (שינוי-תצוגה; לשמר gate home_shell↔STATUS).
- **F-A2 + sec** — הסר 2 תלויות שאינן בשימוש: `go_router` + `permission_handler` (אומת: 0 imports).
- **F-A3** — (עברית-בלבד v1 ✅) גדר `themeMode.light` + הסתר/נטרל toggles ar/en+כהה (**לא למחוק; 🚧 לעתיד**).
- **F-A4** — החרג `lib/test_harness/` (~3k שורות) מ-release bundle (`kReleaseMode` guard).
- **F-A5** — חווט Search/Menu triggers (מודל-5-הכפתורים, spec §7.1) **או** השק עם BS-dial בלבד + 🚧 מתועד (**לא מחיקה**).
- **F-F1** — תיקוני-RTL לאלמנטים הנראים (overlay).
- **F-F2** — `Semantics`/`tooltip` לאלמנטים אינטראקטיביים מרכזיים.
- **[Android]** adaptive launcher icon + ProGuard/minify + אימות minSdk≥21.
- **[iOS]** שדרוג deployment-target (12.0→13+).
- **store** — metadata + privacy-policy + data-safety/nutrition (86/87).
- **F-E1** — אופטימיזציית-assets (101MB→~30-40MB): WebP + resize + הסרת-לא-בשימוש (משקל-השקה).
- **F-B4** — global error handler (`FlutterError.onError`/`runZonedGuarded`) שמזין את `crash_log`.

### P2 — nice-to-have
- **F-B1** פיצול God-objects (catalog_screen 7,136…) · **F-C1** `dart fix --apply` (~1,568 infos) ·
  **F-C2** dead-code (37 warn) · **F-C3** תיקוני-טייפ · **F-C4** extract ~20 widgets משוכפלים ·
  **F-C5** ריכוז ~583 צבעים קשיחים ל-tokens · **F-F3** RTL polish + touch-targets + i18n (post-launch) ·
  **F-H1** telemetry חיצוני (post-launch) · **Web** theme-color מותג.
- **F-B3** autoDispose ל-state-UI חולף · **F-B5** async-init race (FutureProvider/AsyncValue) ·
  **F-B6** silent error-swallow (הוסף log) · **F-B7** coupling-ניווט ב-catalog_screen · **F-E** code-split / `--wasm`.

---

## דורש החלטת-משתמש  *(צעד 99)*
- ✅ **שפה — הוכרע: עברית-בלבד (v1).** ar/en+dark → לגדר/להסתיר (🚧 לעתיד); i18n נדחה ל-post-launch.
- ✅ **dials — הוכרע: לא למחוק.** לעבוד לפי הספק (🚧 §7.1): לחווט לקראת השקה (5-FABs) או להשאיר BS-dial בלבד מתועד.
- ✅ **מקביליות — הוכרע:** לעבוד במקביל על העץ המשותף (Push & Sync). לאימות-השקה סופי כדאי snapshot קפוא.
- ✅ **יעד — הוכרע: אפליקציית-טלפון (Android / Google Play).** Web אינו היעד. iOS משני (גם דורש Mac/CI — ENV-4).
- ✅ **בנייה — הוכרע: Android SDK מקומי** (בהתקנה כעת על המכונה — JDK17 + cmdline-tools, ללא אדמין) → בניית-בדיקה (debug) מיד.
- ⬜ **keystore + applicationId — בהמשך** ("נטפל כשנגיע"): ה-AAB **החתום** + חשבון Google Play ממתינים להם (צעד 96 משאיר ⬜; אורז את כל השאר).
- **F-A6 (פתוח):** פרשנות מודל-הניווט ב-Flutter (מסכי-מלא ל-settings + modal-sheets) — מאושר? (הספק §5/§7.3 מתעד shell בסגנון WhatsApp; 5-FABs לא ממומש פיזית.)

---

## יומן-התקדמות (steps)
- ✅ **סריקת כל 9 הפאזות הושלמה** — A (1–10) · B (11–25) · C (26–40) · D (41–52) ·
  E (53–64) · F (65–74) · G (75–89) · H (90–94).
- ✅ I (95–100): סיכום-מנהלים · go/no-go · backlog מתועדף · דורש-החלטה.
- ⏭️ **ממתין לאישור-Plan לפני שלב Fix.** תיקונים-בטוחים (`dart fix`/dead-code/const/format) מותרים
  מיד לפי הפרוטוקול; refactor/מחיקה-רחבה/שינוי-ניווט = אישור-משתמש.
