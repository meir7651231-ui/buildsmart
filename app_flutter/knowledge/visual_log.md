# Visual verification log — app_flutter

תיעוד אימות-ויזואלי לשינויי UI (גייט 107, לקח #2). screenshot/בדיקת-widget לכל שינוי.

---

## #org-config-publish-decouple — 📤 "שמור" מפרסם בלי לדרוש ORG_CONFIG_LIVE — 2026-08-13
**תיקון-התנהגות (חי):** `_save` מפרסם לפי `canPublishOrgConfig` (`ORG_CONFIG` חמוש + Firebase) במקום `useOrgConfigLive`. אבחון-שדה על ה-web הראה: בעלים ✅ + כתיבה-לשרת ✅ אבל `ORG_CONFIG_LIVE` ❌ → "שמור" לא פרסם. עכשיו יפרסם בכל build חמוש. הכפתור-אבחון מפריד "✅ פרסום מופעל" מ"מנוי-חי".
**אימות:** `flutter analyze` 0 errors. הבדיקות define-less (כל הדגלים false + אין Firebase) ⇒ `canPublishOrgConfig` false ⇒ `published=null` ⇒ byte-identical.
**שקיפות:** eye-check — על build חמוש (web/בדיקה) הבעלים שומר → הדוח מראה "✅ פרסום מופעל" והשינוי מגיע לאחרים.

## #org-config-diag — 🔍 כפתור אבחון-סנכרון באשף — 2026-08-13
**שינוי-UI (חי · לא מגודר · בקשת-בעלים):** כפתור חדש **"🔍 אבחון סנכרון (למה לא מגיע לאחרים)"** באשף-ההקמה, מעל "שמור והפעל" → דיאלוג עם דוח-אבחון חי: Firebase מאותחל? · דגלים חמושים (`useOrgConfigLive`)? · מחובר + בעלים? · **כתיבה-לשרת + אימות round-trip** (`Source.server`).
**למה זה נבנה:** האשף אמר "נשמר ופורסם" אבל המסמך בשרת היה 404 — מלכודת ה-persistence (`set()` מצליח מקומית, השרת דוחה ברקע). הכפתור חושף חי איפה השרשרת נשברת.
**אימות:** `flutter analyze` 0 errors. best-effort (לא זורק). ה-round-trip מאמת מהשרת האמיתי (כמו `backend_debug_badge`).
**שקיפות:** eye-check חי — "🔍 אבחון סנכרון" → רואים שורה-שורה; הכי סביר "❌ סנכרון-חי כבוי (build ישן)" או "❌ לא בעלים".

## #kb-letters-first — ⌨️ המקלדת נפתחת על האותיות (ברירת-מחדל) — 2026-08-13
**שינוי-UI (חי · לא מגודר — בקשת-בעלים מפורשת):** `floating_card_keyboard.dart` — `_typing` ברירת-מחדל שונתה `false→true`. עכשיו כל פתיחה של המקלדת **מובילה עם האותיות (הקלדה)**, מוכן להקליד, במקום מראה-הכלים/mirror. ▦/⚙️ עדיין עוברים לכלים.
**למה בטוח + נכון:** ה-`_GlobalKeyboardOverlay` מכניס/מסיר את המקלדת בכל פתיחה ⇒ ה-State נוצר-מחדש ⇒ ברירת-המחדל חלה בכל פתיחה. `kFinderFront` (`FINDER_FRONT`) כבוי בכל build ⇒ אין finder-lead שדורס. שורה 666: `if (_typing)` מפרק את context-base ומציג את האותיות.
**אימות:** keyboard tests ירוקים (generated + card_keyboard + word_keyboard) · "empty/whitespace keeps the opening surface" עובר · `flutter analyze` 0.
**שקיפות:** eye-check חי — פותחים את ה-FAB של המקלדת ⇒ אותיות עבריות מוכנות להקלדה, לא כלים.

## #access-lock-universal — 🔒 קיר-הסיסמה בכל build (כולל האתר הציבורי) — 2026-08-13
**שינוי-UI:** `access_lock_gate.dart` — אותו מסך-נעילה, אך עכשיו קורא את ה-hash מהמסמך הציבורי (fetch) ⇒ חוסם ב**כל build** (חנות/web/בדיקה), לא רק בבדיקה. `ACCESS_LOCK=true` נוסף ל-`android-package` + `web-deploy`. **⚠️ האתר הציבורי `buildsmart-il.com` יציג קיר-סיסמה לכל מבקר** (החלטת-בעלים מפורשת "נעול הכל").
**מגודר `kAccessLock` (OFF ⇒ ה-`home` ternary מתקפל ⇒ byte-identical).** עם הדגל דלוק וללא-סיסמה-שהוגדרה ⇒ ה-fetch מחזיר '' ⇒ passthrough (אין נעילה עד שקובעים סיסמה).
**אימות:** `access_lock_test` **7/7** (hash · match · round-trip · gate: ריק⇒פתוח · שגוי⇒נעול · נכון⇒נפתח — דרך `accessHashFetchProvider`). `flutter analyze` 0 errors.
**שקיפות:** eye-check נטיב חי — הבעלים קובע סיסמה, וכל build (כולל האתר) חוסם עד שמקישים אותה.

## #access-lock — 🔒 מסך-נעילה + שדה-סיסמה באשף (מגודר · off-live) — 2026-08-13
**שינוי-UI:** (1) `access_lock_gate.dart` (חדש) — מסך-נעילה: אייקון-מנעול + "הזן סיסמת גישה" + שדה-obscure + כפתור "כניסה" + errorText "סיסמה שגויה". (2) `org_setup_wizard_screen` — סקציה "🔒 נעילת גישה" (שורת-סטטוס 🔓/🔒 + שדה-סיסמה obscure) אחרי שם-החברה. (3) `main.dart` — עוטף את ה-home ב-`AccessLockGate` מגודר `kAccessLock`.
**מגודר `kAccessLock` (OFF בכל build/בדיקה) ⇒ ה-`home` ternary מתקפל ל-`const OnboardingGate()` ⇒ מסך-הנעילה tree-shaken ⇒ byte-identical — אפס שינוי-UI חי.** שדה-האשף מופיע רק כשהאשף פתוח (מסך מגודר/persona-מנהל ממילא).
**אימות:** (א) **byte-identical כבוי** — `kAccessLock` OFF ⇒ ה-ternary מתקפל ל-OnboardingGate; הסוויטה המלאה עוברת ללא-שינוי. (ב) **התנהגות** — `access_lock_test` (gate widget): hash-ריק⇒child (אין נעילה) · hash-מוגדר+שגויה⇒נעול · נכונה⇒נפתח+persist; + hash/match/round-trip. `flutter analyze` 0.
**שקיפות:** eye-check נטיב חי של מסך-הנעילה + השדה-באשף — על ה-build החי אחרי הדלקת הדגל.

## #org-config-live-sync — 🌐 אשף-ההקמה: פרסום-לשרת + הודעת-סטטוס (מגודר · off-live) — 2026-08-13
**שינוי:** `org_setup_wizard_screen.dart` — `_save()` בלבד (לא layout): אחרי ה-persist המקומי, כשהדגל `useOrgConfigLive` דלוק, גם **מפרסם את ההגדרה לשרת** (`publishOrgConfig`), וההודעה `_note` הפכה ל-`switch` על tri-state ("✅ נשמר ופורסם — פעיל אצל כל המשתמשים" / "✅ נשמר מקומית — הפרסום לכולם לא עבר (כתיבה לבעלים בלבד)"). **מגודר `useOrgConfigLive` (= `kOrgConfigLive && kOrgConfigFlag && Firebase` — OFF בכל build/בדיקה) ⇒ `published==null` ⇒ ההודעה נשארת "✅ נשמר ופעיל בכל האפליקציה" הקיימת ⇒ byte-identical — אפס שינוי-UI חי.** אין שינוי ב-layout/widgets/FAB — רק נתיב-שמירה + מחרוזת-הודעה כבויה.
**אימות:** (א) **byte-identical כבוי** — כל הבדיקות define-less (הדגל OFF) ⇒ ה-`_save` פוגע בענף `published==null` המחזיר את ההודעה הישנה; הסוויטה המלאה עברה בשער ללא-שינוי. (ב) **נתיב-הכתיבה** — `org_config_sink_firebase_test` (4/4): publishOrgConfig כותב/מסיר/בולע-שגיאה. (ג) **אבטחה** — `rules_test/org_config.test.js` (10 · רק-הבעלים כותב). `flutter analyze` 0 · הסוויטה + build web עברו בשער-ה-pre-commit.
**שקיפות:** eye-check נטיב חי של שלוש-ההודעות (הבעלים מפרסם ורואה "פעיל אצל כל המשתמשים") — על ה-build החי אחרי הדלקת הדגל.

## #catalog-config-details-fix — 🔗 כפתור "📄 פרטים" + פתיחת הגיליון-הפנימי — 2026-08-06
**שינוי-UI:** `config_card.dart` — כפתור **"📄 פרטים"** חדש (full-width · מילוי-כתום-רך · טקסט-כתום-מודגש) מתחת לתמונה/גלגלים, מעל שורת הוסף-לסל/בנה-קו. פותח את `LipskeyProductSheet` (הזוג חיצוני↔פנימי); גם tap על התמונה עובר אותו נתיב.
**אימות:** `config_card_open_details_real_test` — הנתיב האמיתי (לא mock) פותח את הגיליון (image-tap + כפתור) על טייל שבו variantForSelection=null; RED לפני, GREEN אחרי; mutation-verified (שבירת ה-fallback/הכפתור ⇒ אדום). 82 catalog_config + 32 רגרסיה (favorite_tile/product_journey/card_interactions/sheet) ירוקים · analyze נקי.
**שקיפות:** eye-check נטיב חי ייבדק אחרי ה-deploy הבא (owner מריץ web-deploy).

## #catalog-config-goes-live — 🎛️ הקטלוג-המגדיר גלוי-תמיד על הבית (owner "תדליק") — 2026-08-06
**שינוי-UI:** `smart_home_screen.dart` — מקטע `catalogConfig` כבר **לא מגודר**: `_CatalogConfigOpen` (⟵ `CatalogConfigScreen`) מרונדר **תמיד** על הבית (כמו categories/products). **⚠️ שינוי-UI חי אמיתי** — לא byte-identical (בשונה מהרשומות המגודרות): הסקשן מופיע לכל המשתמשים.
**אימות:** בדיקות-הבית (`widget_test`, `help_coverage`, `t3_ghi`, reorder, placeholder) — **+33 ירוק** (הסקשן נבנה עצל ב-ListView, מחוץ-למסך ב-viewport הבדיקה ⇒ אין רגרסיה). ה-toggle הצג/הסתר של "סידור מסך הבית" חל עליו כמו כל סקשן.
**שקיפות:** eye-check נטיב חי של הסקשן בהקשר-הבית טרם הורץ (ה-shoot המבודד רונדר את המסך נקי — `catalog_config_home.png`); הרנדר מאומת ע"י בדיקות-הבית העוברות.

## #home-catalog-config-section — 🎛️ מסך-הקטלוג-המגדיר על הבית (מגודר · off-live) — 2026-08-06
**שינוי-UI:** `smart_home_screen.dart` — סקשן-בית חדש `_CatalogConfigOpen` (מירור `_SuperFinderOpen`) מרנדר את `CatalogConfigScreen` פתוח בקופסת-560. **מגודר `kCatalogConfig` (OFF) ⇒ tree-shaken ⇒ הבית החי byte-identical — אפס שינוי-UI חי** (בדיוק כמו superFinder תחת kAxisDive).
**אימות:** (א) **byte-identical כבוי** — כל בדיקות-הבית (`widget_test`, `help_coverage_test`, `t3_ghi`, …) עוברות ללא-שינוי כי הסקשן tree-shaken בברירת-מחדל (full-suite ripple-check ירוק). (ב) **מבנה** — `home_catalog_config_section_test`: הסקשן ב-kDefaultHomeOrder + מטא-🎛️ · smartHomeSectionFor בונה בלי-קריסה.
**שקיפות:** eye-check נטיב חי לא הורץ (מגודר · דורש `--dart-define=CATALOG_CONFIG=true`); הביטחון נשען על byte-identical-כבוי + מקבילות verbatim ל-`_SuperFinderOpen` המאומת.

## #catalog-config-internal-link — 🔗 tap כרטיס-חיצוני → גיליון-פנימי (מגודר · off-live) — 2026-08-06
**שינוי-UI:** `config_card.dart` — `onTap` על תמונת-הכרטיס (`_stage()`) פותח את `LipskeyProductSheet`. **מגודר `kCatalogConfig` (OFF) ⇒ tree-shaken ⇒ האפליקציה החיה byte-identical — אפס שינוי-UI חי.** הגרירה (↕/↔ החלפת-ווריאנט) לא-מושפעת; ה-tap תוספתי בלבד.
**אימות:** (א) **byte-identical כבוי** — עץ ה-`catalog_config/` tree-shaken בברירת-מחדל (הדגל OFF). (ב) **התנהגות-widget** — `config_card_open_details_test` (3): tap פותח (callback עם schema+selection+qty) · נושא את הווריאנט הנוכחי אחרי שינוי-גלגל+כמות · null⇒inert בלי-קריסה. **mutation-verified** (שבירת ה-onTap → אדום; שחזור → ירוק).
**שקיפות:** eye-check נטיב חי לא הורץ (מגודר · דורש `--dart-define=CATALOG_CONFIG=true`); הביטחון נשען על byte-identical-כבוי + widget-behaviour-tests + mutation-verify.

## #courier-profile-card-material — 🛵 עטיפת Material שקוף ל-_CourierPersonalAreaCard (ink/lint) — 2026-08-04
**שינוי-UI:** ה-`Column` של `_CourierPersonalAreaCard` נעטף ב-`Material(type: MaterialType.transparency)` (אותו תיקון כמו worker_profile). **ציפייה: אפס שינוי-סטטי** — Material שקוף לא צובע; רקע-הכרטיס עדיין מה-`Container`. הדלתא היחידה = tap-ripple שכעת נראה.
**אימות (screenshot אמיתי · `CourierProfileBody(standalone:true)` בתוך Scaffold · courier-seed=דמו · Heebo · 390 logical · toImage):** צולם והוצג בעין. כל הכרטיסים נקי — כרטיס-זהות (דמו · @demo · שליח), סטטיסטיקת-מסירות (0 נמסרו · 1 בדרך · 0 POD · סה"כ 0₪), כרטיס אזור-אישי המתוקן (נוכחות · טפסים · תעודות נהג · תלושי שכר — רקעים/dividers תקינים), וכרטיס-הפעולות (הגדרות שליח · החלפת תפקיד · יציאה מהחשבון-אדום). העטיפה השקופה בלתי-נראית. (□ = חוסר-גליף-emoji בפונט-הטסט.)
**מקור:** `tools/atom/testgen` (List A · פיילוט אחרון). מאומת: 35 crash → 30 pass + 5 not-found · main-suite 5601/12/0 · analyze 0 חדשים · `git diff -w` = עטיפה אחת. **List A סגורה.**

---

## #worker-profile-card-material — 🦺 עטיפת Material שקוף לשורות-כרטיס (ink/lint) — 2026-08-04
**שינוי-UI:** `_PersonalAreaRow.build` + `Column` של `_ActionsCard` נעטפו ב-`Material(type: MaterialType.transparency)` כדי לתת ל-`ListTile`ים משטח-ink מעל רקע-הכרטיס (תיקון debug-assertion "ListTile ink may be invisible" · release: ink-ripple בלתי-נראה). **הציפייה: אפס שינוי-סטטי** — `MaterialType.transparency` לא צובע כלום; רקע-הכרטיס עדיין מגיע מה-`Container`. הדלתא-הוויזואלית היחידה = ה-tap-ripple שכעת *נראה* (התיקון עצמו).
**אימות (screenshot אמיתי · pump WorkerProfileScreen · worker-seed=רן · Heebo · 390 logical · toImage):** צולם והוצג בעין. כל הכרטיסים נרנדרו נקי — כרטיס-זהות (רן · דמו · @ran), כרטיס-סטטיסטיקה (המשימות שלי 0/3 · נדחו/ממתינות/הושלמו), אזור-אישי (נוכחות/טפסים/תיק בטיחות/תלושי שכר עם פילי-סטטוס "לא נרשם היום"/"אין תעודות"/"מוכן לשרת"), וכרטיס-פעולות (הגדרות עובד · החלפת תפקיד · יציאה-אדום). רקעים לבנים · צללים · dividers · פילי-הסטטוס (ה-`Material`+`InkWell` הקיים בשורה 714) — כולם ללא רגרסיה. העטיפה השקופה בלתי-נראית כצפוי. (ה-□ = חוסר-גליף-emoji בפונט-הטסט, לא רגרסיה.)
**מקור:** `tools/atom/testgen` (List A) · הטסטים הגנרטיביים מאמתים render (find.text עבר) · main-suite 5572/12/0 · analyze 0 חדשים · `git diff -w` = שני העיטופים בלבד.

---

## #launch-g3 — 🙈 הסתרת 3 placeholders פומביים (hide-only · fallbacks קיימים) — 2026-08-01
**קבוצה 3 מתוך SSOT סגירת-האתר-להשקה — leak-hunt.** נחיל 4-auditors אימת נגישות; 3 placeholders "בבנייה"/"בקרוב" הגיעו למשתמש-לא-בעלים ב-web החי וגודרו. **שינויי הסתרה בלבד — אפס UI חדש**, ולכן ה-visual-verify הוא אישור *היעדר* ה-placeholder + שה-fallback הוא משטח-קיים-מאומת:
- **store services** (מקלדת → יעד "שירותים" עקף את השער) → כעת `_AllList` (רשימת-הכל הקיימת) במקום גריד-"🚧 בבנייה".
- **store portal "הפקת ברקודים"** → האריח סונן מהגריד תחת `kHideUnderConstruction` (בדיוק כמו fleet/autoStock שכבר מסוננים). אריח אחד פחות, אפס משטח חדש.
- **category strip** (חי תחת `SMART_INPUT=true`) → מסונן לקטגוריות-עם-תוכן בלבד; פחות chips, ה-drill ל-`_TreeComingSoon` "הקטגוריה הזו בבנייה" (App-Store reject) לא נגיש.
**אימות:** traces פר-נתיב של 4 auditors + `flutter analyze` **0 errors** + כל ה-fallbacks הם widgets קיימים-ומאומתים (לא נוצר UI חדש לצלם). הכול הפיך (keyed על `kHideUnderConstruction`). **שקיפות:** eye-check חי של זרימת store→services לא הורץ (דורש build עם backend מלא + persona-store); הביטחון נשען על אופי ההסתרה-בלבד + ה-fallbacks הקיימים + ה-traces.

## #launch-g1 — 🟠 מותג + PWA: שם/כותרת עברית · RTL · splash ממותג · באנר-התקנה — 2026-08-01
**קבוצה 1 מתוך הנחיית סגירת-האתר-להשקה** (SSOT: `knowledge/DIRECTIVE-close-web-for-launch.md` @nice-volta). **הפער האמיתי היה קטן מהמתואר** — האייקונים כבר מותגים (קסדה-כתומה, לא ה-Flutter-הכחול) וה-manifest כבר כתום `#FF7A18`; ה-SSOT תיאר "כחול-ברירת-מחדל" אך זה כבר בוצע בסבב קודם. מה שהושלם עכשיו:
- **`web/index.html`:** `<html lang="he" dir="rtl">` · `<title>בנייה חכמה</title>` · `apple-mobile-web-app-title` + `apple-mobile-web-app-capable` + `<meta theme-color #FF7A18>` + `viewport viewport-fit=cover` + description עברית.
- **splash ממותג:** מסך-פתיחה כתום עם לוגו-הקסדה + "בנייה חכמה" + ספינר, נמחק ב-`flutter-first-frame` (עם fallback 12s שלא ייתקע).
- **באנר "התקן למסך הבית":** לוכד `beforeinstallprompt`, כפתור התקן/סגור, זוכר dismissal ב-localStorage, נעלם ב-`appinstalled`.
- **`web/manifest.json`:** `name`/`short_name` = "בנייה חכמה" (היה "BuildSmart") + `lang:he`/`dir:rtl` + description עברית. צבעים/icons/display נשמרו.

**byte-verified:** build web --release ✅ (Flutter **3.44.0** — לא 3.29; כל workflows-הדיפלוי מצמידים 3.44 · ה-`initialValue` API מאשר) · base-href הוחלף · **5/5 אייקונים byte-identical למקור** (לא-נגעתי) · manifest name="בנייה חכמה". גייט-commit: web-only ⇒ מדלג analyze/test · pre-push מריץ build מלא. ה-push → `firebase-hosting.yml` channel **live** ⇒ עולה לאתר-החי.

## #screen-mgmt-s11b — ✏️ דיוק-מיקום: ה-✎ מנקה את badge מספר-הפריטים — 2026-07-28
**תיקון-דיוק (לאחר בדיקת-מספרים מול הקוד):** המרווח של ה-✎ מעל cart-FAB היה `+12px`, אך ה-badge (מספר-פריטים) בולט `top:-10` מעל הכפתור → נשארו רק **~2px** בין ה-✎ ל-badge (כמעט-נגיעה כשיש פריטים בסל). הוגדל ל-`+28px` ⇒ ~18px מעל ה-badge. שינוי בתוך גוף StudioOverlay המגודר `kStudioFlag` ⇒ production זהה-בייטים (ללא שינוי). analyze 0 · zero_regression 20/20.

## #screen-mgmt-s11 — ✏️ טריגר-עריכה: long-press-מקלדת → ✎ מעל-הסל (STUDIO-build בלבד / production זהה-בייטים) — 2026-07-28

**שינוי-UI (מגודר `kStudioFlag` const — off-build tree-shaken ⇒ production/לא-בעלים זהה-בייטים):** ה-s0 freeze הוסר. הבעלים עושה **long-press על ה-FAB-מקלדת** (על כל מסך) → מצב-עריכה נדלק, וכפתור **✎** מופיע מעל כפתור-הסל (פינת ה-cart-FAB, מוגבּה מעליו) כאינדיקטור-הפעיל. **בלי באנר עליון.** לחיצה-רגילה על המקלדת = מקלדת כרגיל. long-press שוב (או לחיצה על ה-✎) = יציאה, ✎ נעלם. הפעולות (הצג/הסתר/סדר/ניהול-מסכים) — כמו s1-s10.

**מיפוי-נראוּת:** ✎ נדלק רק כש-`kStudioFlag ∧ studioCanEdit(#84) ∧ isEditing`. production (STUDIO unset) → StudioOverlay=`SizedBox.shrink`, ה-FAB=רגיל (tree-shaken). לא-בעלים → `onLongPress=null`, אין ✎.

**אימות:** `analyze` 0 · zero_regression **20/20** · studio-gate (cfg_wrappers · studio_screen · resolved_node) **34/34** · **byte-identity:** default-build `main.dart.js` before==after · אימות-ויזואלי בפריוויו (clean · STUDIO on) — long-press מדליק ✎ מעל הסל, בלי באנר.

---

## #screen-mgmt-s10 — 🕸️ מאתר-על **פתוח** במסך-הבית (שינוי-נראה: לא בברירת-מחדל / כן ב-kAxisDive) — 2026-07-28

**שינוי-UI (מגודר `kAxisDive`, const-false בבנייה-הנשלחת ⇒ ברירת-מחדל זהה-בייטים):** במקום כרטיס-כניסה שצריך ללחוץ, מסך-הבית מציג עכשיו את **גלגל מאתר-על פתוח** — בורר-הצירים ("ממה נתחיל?") + גלריית-המוצרים החיה — בתוך אזור בגובה 560. הצלילה (ציר→ערך→מוצרים) קורית **במקום**, ולחיצת-מוצר פותחת גיליון-מוצר. עדיין נשלט מהאשף כסקציה ("ניהול מסכים → בית" — סדר/הסתר/✎). הבריכה מ-`kDivePool` (built-in) ⇒ מלא גם ב-clean.

**אימות:** `analyze` 0 · t3 (order=8) · `org_setup_wizard` (34) · `kbd_home_layout` = **43/43** ירוקות (ללא-רגרסיה, ברירת-מחדל tree-shaken) · אימות-ויזואלי בפריוויו (clean · `kAxisDive` on) — הגלגל פתוח בבית.

---

## #screen-mgmt-s9 — 🕸️ "מאתר-על" במסך-הבית + במקלדת (שינוי-נראה: לא בברירת-מחדל / כן ב-kAxisDive) — 2026-07-28

**שינוי-UI (מגודר `kAxisDive`, const-false בבנייה-הנשלחת ⇒ ברירת-מחדל זהה-בייטים):** כשה-super-wheel דלוק, מסך-הבית מציג כרטיס **"🕸️ מאתר-על — גלגל-חיפוש-על, בחר מאיזה ציר להתחיל"** (מתחת למועדפים; הקשה → קטלוג במקטע "מאתר-על"), **וגם** רשת-מקלדת-הבית מקבלת אריח **🕸️ מאתר-על** (אותה פעולה). שניהם נערכים מהאשף — הכרטיס דרך "ניהול מסכים → בית" (סדר/הסתר/שם), האריח דרך "בית → ⌨️ מקלדת".

**אימות (בדיקת-widget):** `org_setup_wizard` **34/34** (`sec-show-home-superFinder` בעורך-הסקציות · `sec-show-kbd:home-מאתר-על` בעורך-המקלדת) · `t3` (`kDefaultHomeOrder` = 8 · superFinder אחרון) · `kbd_home_layout` · `floating_card_keyboard` byte-identity (73, tab-0 OFF-flag == `_buildRow`) ירוקות · analyze 0. **ברירת-מחדל:** `kAxisDive`=false בטסטים ⇒ הענף tree-shaken ⇒ הבית + הרשת ללא-שינוי.

---

## #screen-mgmt-s8 — ✎ עריכת-שם פר-פריט (סקציות + מקלדת) — 2026-07-28

**שינוי-UI:** בכל שורה בעורך-הסקציות **וגם** בעורך-המקלדת (widget משותף) נוסף כפתור **✎** → דיאלוג "ערוך שם" (שמור / אפס-לברירת-מחדל). על **אריח-מקלדת** → האריח **החי במקלדת** מקבל את השם החדש; על **סקציה** → השם מתעדכן בעורך.

**אימות (בדיקת-widget):** `org_setup_wizard` **33/33** (✎ `sec-edit-home-workPath` פותח את הדיאלוג · "שמור" → `labelOf('home','workPath')` == השם החדש) · `screen_sections` (`setLabel`/revert · canonical-minimal) · `kbd_home_layout` (rename על labels אמיתיים) · `floating_card_keyboard` byte-identity (79) ירוקות · analyze 0.

---

## #screen-mgmt-s7 — עורך-המקלדת חי (מכבד את "ניהול מסכים") — 2026-07-28

**שינוי-UI:** רשת-הבית של המקלדת-הצפה (8 האריחים שהמשתמש צילם: מחלקות/מסלול/הזמנות/חיבור/עץ-חכם/מהירים/מאתר/מועדפים) מכבדת כעת את פריסת-המקלדת-פר-מסך ('kbd:home') — הסתרת/סידור אריח ב"ניהול מסכים → בית → ⌨️ מקלדת" משנה את המקלדת **האמיתית** מיד. ברירת-מחדל **זהה-בייטים**.

**אימות:** `floating_card_keyboard` + `keyboard_catalog_deriver` + `live_mirror_screen_tools` (79) ירוקות (זהה-בייטים · הרינדור לא-נשבר) · `kbd_home_layout` s7 (hide-drops · reorder על labels אמיתיים) · analyze 0.

---

## #screen-mgmt-s6 — הבית: "תכנון חיבור" + "מועדפים" ניתנים-להסתרה — 2026-07-28

**שינוי-UI:** מסך-הבית (`SmartHomeBody`) — 2 הבלוקים שהיו **קבועים** בתחתית ("🔌 תכנון חיבור" · "⭐ מועדפים") הפכו לסקציות בעורך "ניהול מסכים → בית" (home = 7 סקציות). ברירת-מחדל **זהה-בייטים** (`childrenFor` spread · שער-`compat` ל-installHero · מועדפים בלי-ריווח-נגרר).

**אימות (בדיקת-widget + צילום-משתמש):** צילום-המסך של המשתמש הראה את "תכנון חיבור"+"מועדפים" על הבית — הם הבלוקים שנוספו לעורך. `org_setup_wizard` **23/23** (`sec-show-home-installHero`/`sec-show-home-favorites` מוצגים ב-level-2) · `t3` + `widget_test` + `placeholder_hide` ירוקות (הבית מרונדר זהה-בייטים) · analyze 0.

---

## #screen-mgmt-s5c — חנות חיה (סדר + הסתר כרטיסים) — 2026-07-28 ✅ כל 4 המסכים חיים

**שינוי-UI:** ה-store home (5 כרטיסים: אישור / ממתין / סטטיסטיקה / מלאי / פעולות-מהירות) נשלט כעת מהאשף (**ניהול-מסכים → 🏪 חנות ספק**). הכותרת + צינור-ההזמנות נשארים קבועים. spread-children שומר **זהה-בייטים**.

**אימות:** `org_setup_wizard` **23/23** (store section-built · הסתרת-`stock` נשמרת ל-'store') · בדיקות-חנות (t9_supplier / help_coverage / apple_readiness / daily_report) ירוקות · analyze 0. **כל 4 המסכים בהנחיה חיים (בית=קבלן · מנהל · חנות).**

---

## #screen-mgmt-s5b — לוח-מנהל חי (סדר + הסתר סקציות) — 2026-07-28

**שינוי-UI:** לוח-הבקרה של המנהל (`_DashboardTab` · 6 בלוקים: קו-פיילוט / סטודיו / כניסת-סטודיו / דורש-טיפול / מדדים / צינור-הזמנות) קורא כעת את מודל-הסקציות-פר-מסך → האשף (**ניהול-מסכים → 👔 לוח מנהל**) עורך אותו **חי**. spread-children שומר על ריווח **זהה-בייטים**.

**אימות:** `org_setup_wizard` **22/22** (מנהל section-built · הסתרת-`kpis` נשמרת ל-'manager') · `attention_gate` + `studio_gating` ירוקים (הקוקפיט זהה-בייטים) · analyze 0.
## #reg-first-chip — צ׳יפ-סטטוס מתחת ללוגו (במקום הבאנר) + הרשמה-קודם — 2026-07-28

**שינוי-UI:** הבאנר העליון "ממתין לאישור" **הוסר**. במקומו **צ׳יפ-סטטוס קומפקטי מתחת ללוגו** (נקודה-צבעונית + טקסט), 4 מצבים: 🟠 **דרוש הרשמה** (כתום) · 🟡 **בתהליך** (צהוב) · 🟢 **מאושר** (ירוק) · 🔴 **נדחה** (אדום). הקשה על הצ׳יפ: לא-רשום → מסך-הרשמה ייעודי (`WelcomeScreen`); רשום → גיליון בחירת-תפקיד; מאושר → בורר-לוחות. אחרי הרשמה נפתח גיליון-בחירת-התפקיד פעם אחת. תיבת-האישורים קיבלה כפתור **🧹 "מחק את כל הבקשות"** (owner-only, מאחורי דיאלוג-אישור הרסני).

**אימות:** widget-test — `role_request` 15/15 (הכפתור מופיע לבעלים בלבד · דיאלוג → מחיקת 2 בקשות דרך ה-seam · non-owner לא רואה); `roleChipStateFor` 8/8 (כל 4 המצבים + עדיפויות). הצ׳יפ עצמו `kUserSystem`-gated ⇒ בטסטים/OFF `SizedBox.shrink` (זהה-בייטים · כל טסטי HomeShell ירוקים) — לכן אין screenshot-בטסט; אומת בקוד + מיפוי-טהור. analyze 0 errors.

---

## #screen-mgmt-s4 — עורך מקלדת-פר-מסך (מעורך-המסך) — 2026-07-27

**שינוי-UI:** עורך-המסך (רמה-2) קיבל כפתור **"⌨️ מקלדת"** → מסך עריכת-אריחי-המקלדת של המסך (סדר+הסתר · אותו `_SectionManagerList`) + באנר-כן שהאפקט-החי מחכה ל-`kKbGlobal`. home: 8 אריחים.

**אימות:** `org_setup_wizard` **21/21** — level-2 → ⌨️ פותח את עורך-המקלדת (AppBar 'מקלדת · מסך הבית'), הסתרת-אריח ('מהירים') נשמרת ל-`kbd:home`. analyze 0.

---

## #screen-mgmt-s3 — הבית חי על מודל-הסקציות (הסתר פר-סקציה) — 2026-07-27

**שינוי-UI:** מסך-הבית (`smart_home`) + "🏠 תוכן הבית" (`home_content_reorder`) קוראים כעת את מודל-הסקציות-פר-מסך (slice-1) לסדר+הסתר. home_content_reorder קיבל **טוגל הצג/הסתר (👁) פר-סקציה** במצב-עריכה + strike-through למוסתר; התצוגה מסתירה סקציות-מוסתרות (תואם-ללייב). כעת עורך-הסקציות באשף (slice-2) **חי** על הבית.

**אימות:** 62 בדיקות-רינדור-בית ירוקות (זהה-בייטים · ברירת-מחדל) · `t3` 18/18 (slice-3: hide נופל מ-`visibleIds` · reorder פר-מסך) · analyze 0.

---

## #screen-mgmt-s2 — "ניהול מסכים" באשף (רמה-1 מסכים → רמה-2 סקציות) — 2026-07-27

**שינוי-UI:** כפתור **"🖥️ ניהול מסכים"** (מתחת למצא-והחלף/גרסאות) → מסלול-מלא 2-מפלסים: **רמה-1** רשימת-מסכים (drag לסדר · switch הצג/הסתר · חץ פנימה), **רמה-2** עורך-הסקציות של המסך (home: 5 סקציות אמת; contractor/manager/store: placeholder "טרם-נבנה-כסקציות · slice-5"). על מודל-slice-1, persist.

**אימות:** `org_setup_wizard` **20/20** — ה-launcher פותח רמה-1 (4 מסכים, keys), הסתרת-מסך (store) נשמרת ל-root, חץ-home פותח רמה-2, הסתרת-סקציה (workPath) נשמרת ונופלת מ-`visibleIds`. analyze 0.

---

## #screen-mgmt-s0 — כיבוי chrome-העריכה-על-המסך (הוקפא) — 2026-07-27

**שינוי-UI:** `studio_overlay.dart` — המעטפת-על-המסך (**נווט⇄ערוך** + **🔀 בורד**) **הוקפאה** → `StudioOverlay` מרנדר `SizedBox.shrink()` תמיד. אין יותר טריגר-עריכה על המסך; העריכה עוברת **כולה לאשף** (org_setup_wizard = הכניסה היחידה).

**אימות:** `zero_regression` **20/20** — overlay: off-gate inert + **on-gate-owner עדיין-inert** (נווט/ערוך/בורד `findsNothing`, `SegmentedButton` נעדר, edit-mode לא-ניתן-להפעלה-מהמסך) · 192 studio · analyze 0 · לא-בעלים **זהה-בייטים** (kStudioFlag const-off ⇒ tree-shake).

---

## #wizard-studio-s5 — גרסאות והיסטוריה באשף (מיחזור HistoryPane) — 2026-07-27 ✅ דירקטיבה הושלמה

**שינוי-UI:** כפתור **"🕘 גרסאות"** (ב-Row עם מצא-והחלף) → מסלול-מלא `_WizardHistoryScreen` המארח את **`HistoryPane` של הסטודיו (verbatim)** — רשימת גרסאות + "שחזר".

**אימות:** `org_setup_wizard_test` **19/19** — ה-launcher פותח את `HistoryPane`, מצב-ריק 'עדיין לא פורסמו גרסאות' (הפאנל חי וקורא `configStore.history`). לוגיקת-השחזור מכוסה ב-studio. analyze 0.

**5 פרוסות הושלמו:** אקורדיון (s1) · ✎ מפקח (s2) · מונחים-שזורים (s3) · מצא-והחלף (s4) · גרסאות (s5) — כולן על ה-Studio-store הקיים.

## #wizard-studio-s4 — מצא-והחלף באשף (מיחזור FindReplacePane) — 2026-07-27

**שינוי-UI:** `org_setup_wizard_screen.dart` — כפתור **"🔎 מצא והחלף בטקסטים"** (מתחת למונחים) → מסלול-מלא `_WizardFindReplaceScreen` המארח את **`FindReplacePane` של הסטודיו (verbatim)** + פעולת-AppBar **"פרסם לכולם (חי)"** (`configStore.publish`).

**אימות:** `org_setup_wizard_test` **18/18** — ה-launcher פותח את הפאנל (שדה 'מצא טקסט' נוכח) + פעולת ה-publish. לוגיקת-ההחלפה עצמה מכוסה ב-`find_replace_pane_test` (studio) — כאן רק החיווט. analyze 0.

## #wizard-studio-s3 — מונחים-שזורים פר-מודול ("→ תצוגה" חיה) — 2026-07-27

**שינוי-UI:** `org_setup_wizard_screen.dart` — כל סקציית-מודול קיבלה צ׳יפי-מונח **"🏷️ תווית → ערך"** (`termOf`, חי) מתחת לכותרת. `_kModuleTerms` ממפה מודול→מונחי-V3-מחווטים (`nav.*` · `entity.customer` · `brand.club`). עריכה נשארת במקטע "מיתוג ומונחים" (מקור-אמת אחד) → הצ׳יפ מתעדכן חי.

**אימות:** `org_setup_wizard_test` **17/17** — קבלן מציג `שם המסך → בית`; עריכת `nav.home`→'מגורים' מעדכנת ל-`שם המסך → מגורים` (והישן נעלם — מקור-אמת אחד). analyze 0.

## #wizard-studio-s2 — מפקח מלא פר-רכיב (✎ text/color/size/weight חי) — 2026-07-27

**שינוי-UI:** `org_setup_wizard_screen.dart` — כל שורת-רכיב (עם ציר text/emoji/style) קיבלה **✎** ליד מתג-ההסתרה → פותח bottom-sheet `_ElementInspectorSheet`: **טקסט · אמוג׳י · צבע · גודל · משקל** (contextual לפי `editableProps`) + תצוגה-חיה + "אפס לברירת-מחדל"/"החל וסגור (חי)". כל שינוי → `applyOps`+`publish` ל-Studio store ⇒ **חי בכל האפליקציה**. הסתרה נשארת על מתג-השורה (OrgConfig) — שני צירים נפרדים.

**אימות-ויזואלי:** `org_setup_wizard_test` **16/16** — ה-✎ נפתח, חושף **צבע/גודל/משקל** ("לא רק הצג/הסתר"), ועריכת-טקסט מתפרסמת חי (`published.global['cart.cta'].text=='קנה עכשיו'`, resolved==published כי לא-edit-mode). 192 studio ירוקות · analyze 0. תצוגה-חיה מ-`applyCfgTextStyle` (מנוע-הרינדור של האפליקציה עצמה).

## #wizard-studio-s1 — אקורדיון-Maor באשף (מודול-קבלן ראשון · מונה · סמן/נקה-הכל) — 2026-07-27

**שינוי-UI:** `org_setup_wizard_screen.dart` — "מודולים"+"רכיבים" הנפרדים → **אקורדיון-Maor אחד** (14 סקציות, 👷 קבלן ראשון): שער-פרסונה (13 gated · manager נעול · קבלן בלי-שער=ה-app-הבסיסי) + **מונה N/M פעילים** + רצועת-פתיחה-עצלה + **סמן/נקה-הכל** (bulk, מדלג kImmutable) + מתגי-רכיבים מקובצי-מסך; מונה גלובלי **"X מתוך Y רכיבים פעילים"**; **חיפוש+צ׳יפים = מסננים** (לא תנאי-הצגה — תיקון "התיבה-הריקה"). `org_modules.dart` — `kContractorModule` + `kWizardModules`(14) + `moduleForScreen` (כיסוי-מלא 123→14).

**אימות-ויזואלי:** `org_setup_wizard_test` **15/15** — **13 ה-SwitchListTile נשמרו** ⇒ renders(13)/pack-chip/self-lock/save/terms/reset/import/element-search ירוקות ללא-שינוי. חדשות: `moduleForScreen` כיסוי-מלא (כל אלמנט→kWizardModules) · קבלן-נגלל-בלי-חיפוש + מונה-גלובלי + עדיין-13-tiles · **נקה-הכל** bulk→`cart.cta` נסתר (canonical-minimal persist). analyze 0.
## s0c-fix — 🙈 הסתרה עובדת על תוויות-טקסט + toggle הצג/הסתר — 2026-07-27

**באג (לקח #39):** מתג-ההסתרה כתב `SetHidden` לטיוטה, אבל `CfgText` (עטיפת 117 תוויות-הטקסט) לא קרא `n.hidden` — רק `CfgVisible` (56 composite) כיבד אותו ⇒ הסתרת תווית = "לא קורה כלום".

**שינוי-UI:** (1) `cfg_text.dart` — פלט-העריכה נעטף כעת ב-`CfgVisible(id, …)` ⇒ כל תווית מכבדת הסתרה: ghost-35%+"מוסתר" בעריכה · `SizedBox` למשתמש-קצה · critical לעולם-לא-מוסתר · בלי-override→child verbatim (זהה-בייטים). (2) `edit_handle.dart` — הכפתור הפך ל-**toggle**: רכיב-מוסתר→"הצג רכיב" (ירוק, `SetHidden(id,null)`); אחרת "הסתר רכיב" (אדום).

**אימות-ויזואלי:** `cfg_wrappers_test` מרנדר בפועל את מצבי-ה-`CfgVisible`: hidden+editing⇒ghost+"מוסתר" · hidden+not-editing⇒removed · critical⇒shown · no-override⇒verbatim. 193 בדיקות-סטודיו ירוקות · analyze 0. **eyeball חי על buildsmart-il.com ממתין לבעלים** (Chromium חסום מסביבת-הסוכן; ה-widget-test מנהיג את מסלול-הרינדור המדויק).

## s0c — 🙈 מתג "הסתר רכיב" בעורך-החי (WYSIWYG) — 2026-07-27

**שינוי-UI:** `edit_handle.dart` — חלון-העריכה-החי (`_openInlineEditor`) קיבל כפתור **"הסתר רכיב"** (אדום, `BsTokens.danger`) לצד ביטול/שמור; כותרת 'עריכת טקסט'→'עריכת רכיב'. tap→`SetHidden(id,true)` על הטיוטה. הגנה: `cfgOpError(SetHidden, criticalIds:criticalIdsProvider)` חוסם רכיב-חובה (`kImmutable`) → snackbar-שגיאה, לא-מוסתר.

**אימות-ויזואלי:** `cfg_wrappers_test` — בדיקה חדשה מנהיגה את החלון בפועל: pump → `tap('הזמן')` → החלון נפתח → `tap('הסתר רכיב')` → `draft.global['cart.cta'].hidden == true` ✓. בדיקת-הכותרת עודכנה ל-'עריכת רכיב' ✓. 23/23 בסוללה · analyze 0. **eyeball חי על buildsmart-il.com ממתין לבעלים** (Chromium חסום מסביבת-הסוכן; ה-widget-test מנהיג את אותו מסלול tap→dialog→SetHidden).

## #wizard-studio-s0b — מעטפת-סטודיו קבועה: מתג נווט⇄ערוך + בורר-בורד — 2026-07-27

**שינוי-UI:** `studio_overlay.dart` — המעטפת (מעל ה-Navigator) הפכה מ-banner-של-editing-בלבד ל**כרום קבוע** כש-`studioActiveProvider` דלוק: (1) מתג `SegmentedButton` `נווט⇄ערוך` (ברירת-מחדל **נווט**=edit-off ⇒ כל tap ניווט רגיל) · (2) בורר-בורד (`🔀 בורד`→`showRolePicker` דרך ה-root-navigator, מגודר `kStudioFlag`) · (3) ב-editing: מונה-טיוטה + `פרסם`. **off-gate (active=false) → `SizedBox.shrink` (זהה-בייטים).** `main.dart` — `navigatorKey` מחווט גם תחת `kStudioFlag`.

**אימות-ויזואלי:** `zero_regression_test` — off-gate: אין `נווט`/`ערוך` (מעטפת נעדרת) · on-gate: `נווט`+`ערוך` נוכחים, ברירת-מחדל `isEditing=false` · **אינטראקציה:** tap `ערוך`→`isEditing=true` · tap `נווט`→`isEditing=false` (תיקון לכידת-ה-edit-mode). 304 בדיקות-סטודיו/שער/role-picker ירוקות · analyze 0.

## s49b — 🔌 7 תפרים מגודרים במסך-ההתקנות (בונה-הענפים) — 2026-07-06

**שינוי-UI:** `install_studio_screen.dart` — 7 תפרי-config מגודרים ב-guard יחיד (`resolvedActiveTradeIdProvider=='plumbing'` → **null-config → כל נתיב-legacy בייט-זהה, R1-2**): צבעי-מערכת · picker · checklist · חום · canConnect · שיפוע · kit. insert-only 366+/18− (מחיקות=בליעות-משמרות-טוקנים). NEW `trade_physics_config.dart` (אינסטלציה לעולם לא קוראת).

**אימות-ויזואלי:** `install_studio_flag_off_test` (G-flag-off) **5/5** — ברזולוציית-ברירת-המחדל (אינסטלציה): עוגני-shell ('תכנון חיבור' · 'מה אתה רוצה לחבר?' · CTA-ים) · **פאנל-השיפוע ת"י-1205 נוכח** ('מינ׳ 2% · ת"י 1205' + 'שיפוע ניקוז: 2.0%') · תוויות-חיבור positional-בלבד · צבעי-המערכת הקבועים (0xFF0284C7/0xFFD97706/0xFF7C3AED) דרך ווידג׳טים מרונדרים. הערה: פילטר-onError ל-RenderFlex-overflow קיים-מראש בשורת-השרשרת :1139 (חוב-layout ישן בקוד לא-נגוע; רק overflow מסונן).

## s50 — 🏆 G-newtrade + הרחבת-r3 בשער-הפרסום — 2026-07-06

**שינוי-UI יחיד:** `trade_publish_sheet.dart` — r3 ('אין כלל-חיבור יתום') בודק עכשיו **גם** CompletionRules עם type-fields לא-ריקים (כלל-רפאים → ✗ → 'פרסם' חסום). אותה שורה, אותו label — רק היקף-הבדיקה גדל. שאר השינויים data-layer (repo read-path) — אפס-UI.

**אימות-ויזואלי:** `trade_publish_sheet_test` 5/5 ללא-שינוי + acceptance test 4 (orphan-CompletionRule → r3 ✗ → no-op-בלי-pop; החלפה לכלל-חומר → ✓ → publish+pop). כל הדגלים OFF → אפס שינוי (acceptance test 5).

## s48 — 📥 ייבוא-CSV מגודר (בונה-הענפים) — 2026-07-06

**שינוי-UI:** `product_authoring_screen.dart` — סקציית 'ייבוא מ-CSV' **מאחורי `kTradeImportFlag` (collection-if → OFF = המסך בייט-זהה ל-s47)**: 'הורד תבנית' (ממלא תבנית מ-AttributeDefs) · 'הדבק CSV' (multiline) · 'בדוק (dry-run)' → 'תקינים: N · שגיאות: M' + עד 5 'שורה R: <שגיאה>' · 'ייבא' (רק כש-canCommit; עריכת-ההדבקה מבטלת דוח ישן) → 'יובאו N מוצרים'. המנוע: NEW `lib/domain/trade_import.dart` (Dart טהור).

**אימות-ויזואלי:** `bulk_import_test` 8/8 (לוגיקה טהורה + אטומיות-דרך-store: קובץ-מעורב = אפס-כתיבה) + רגרסיית product_authoring/home 11/11 — המסך ב-flag-OFF לא-נגוע.

## s47 — 🔌 סטודיו כללי-חיבור + 🚀 שער-פרסום FK (בונה-הענפים) — 2026-07-06

**שינויי-UI:** (1) NEW `connection_rule_studio.dart` — '🔌 כללי חיבור': 'מחברים' (הוספה/מחיקה), **'מטריצת חיבורים' N×N** (Semantics לכל תא 'חיבור A אל B'; '·'→dialog 'תווית שיטה'→'✓'; תא-עם-כלל → 'מחק כלל'), **'ספסל בדיקה' חי** — dropdowns 'מחבר א/ב' + 'בדוק חיבור' מפעילים את **ה-ConnectionResolver האמיתי** (מקור-אמת יחיד) → תווית-שיטה או 'לא מתחבר'; (2) NEW `trade_publish_sheet.dart` — '🚀 פרסום ענף': 4 שערי-ולידציה ✓/✗ (קטגוריה-עם-מוצר · ציר-עם-ערכים · אין-כלל-יתום · **FK: כל מוצר→קטגוריה קיימת, R2-7**) + שורת-dry-run 'קטגוריות/מוצרים/כללים' + 'פרסם' שנחסם על ✗; (3) חיווט: 🚀 על tile-ענף בבית, 🔌 ב-AppBar של המוצרים.

**אימות-ויזואלי:** widget-tests — `connection_rule_studio_test` 5/5 (כולל bench-behavioral: התווית מופיעה רק אחרי הלחיצה = ה-resolver ענה) + `trade_publish_sheet_test` 5/5 (עצמאות-שורות r1..r4; פרסום flip+pop; חסימה=no-op-בלי-pop). רגרסיית-המשפחה המלאה 35/35. גליפים ✓/✗/· אומתו בבייטים.

## s46 — 📦 עורך-מוצרים + 🧩 עורך-אביזרים (בונה-הענפים) — 2026-07-06

**שינויי-UI:** (1) NEW `product_authoring_screen.dart` — '📦 מוצרים': tiles (שם/מק"ט/קטגוריה), טופס עם **קלט-מונחה-סכמה** (AttributeDef עם ערכים → dropdown של labelHe — ערך-מחוץ-לסכמה בלתי-אפשרי; freeText/number → TextField), משמר-כפילויות ('מק"ט כבר קיים'), דרישת-קטגוריה ('צור קטגוריה קודם'), פעולת-AppBar '🧩'; (2) NEW `accessory_rule_editor.dart` — '🧩 אביזרים': טופס (שם/למה-חשוב/חובה?/מחיר-digits עם 'מחיר לא תקין'/קטגוריה/'מוצר מקושר' **חסין-יתומים** — רק מוצרי-הענף, 'ללא' ראשון), chips 'חובה'/'₪'; (3) `category_tree_editor.dart` — פעולת-AppBar '📦' (insert-only).

**אימות-ויזואלי:** widget-tests — `product_authoring_screen_test` 5/5 + `accessory_rule_editor_test` 4/4 (כולל: מוצר-ענף-זר **נעדר** מהמקשר; ה-linkSku נשמר כ-id; המוצר הראשון שורד כפילות; non-digit-price חסום). רגרסיית-s45 10/10. const seed files — git diff ריק.

## s45 — 🗂️ עורך עץ-קטגוריות + 🏷️ עורך מאפיינים (בונה-הענפים) — 2026-07-06

**שינויי-UI:** (1) NEW `category_tree_editor.dart` — RTL+clamp-1.35, '🗂️ עץ קטגוריות', ReorderableListView לפי sortIndex, הוסף/שנה-שם (dialog)/מחק (Semantics+tooltip 'מחק'), פעולת-AppBar '🏷️'; (2) NEW `attribute_schema_editor.dart` — '🏷️ מאפיינים': טופס (שם/kind-dropdown/ערכים-chips/'ציר וריאנט?') + **אזהרה צהובה 'ציר וריאנט ללא ערכים'** (edit-time, גם על הטופס וגם על tile שמור) + **תצוגת-פירוק-שם חיה** ('בדיקת פירוק שם' → chips ירוקים 'קוטר: 16'); (3) `trade_builder_home.dart` — tile-ענף נהיה tappable → פותח את עורך-הקטגוריות.

**אימות-ויזואלי:** widget-tests — `category_tree_editor_test` 5/5 (RTL · write-path scoped-tradeId · rename-stable-id · delete-והחזרת-empty-state · sortIndex 0,1 דטרמיניסטי) + `attribute_schema_editor_test` 5/5 (RTL · AttributeDef-write · אזהרת-axis חיה · פירוק-שם '16' · 2 chips). const files (variant_families/catalog_tree) — git diff ריק. תיקון-יישוב יחיד: tooltip 'מחק' על ה-IconButton (a11y אמיתי + עצמאי מ-timing של semantics-tree).

## s44 — 🏗️ בונה-ענפים: כניסה מגודרת בלוח-המנהל + 2 מסכי-authoring — 2026-07-06

**שינויי-UI:** (1) `manager_dashboard_screen.dart` — כרטיס `_ManageSection` "🏗️ בונה ענפים" בסוף טאב-הניהול, **מאחורי `kTradeBuilderFlag` (collection-if → flag-OFF = העץ בייט-זהה)**; (2) NEW `trade_builder_home.dart` — RTL, כותרת '🏗️ בונה ענפים', wizard 'שלב 1 מתוך 6', empty-state, כפתור 'הוסף ענף' (Semantics button), clamp טקסט 1.35; (3) NEW `trade_define_step.dart` — טופס RTL (שם/אימוג׳י/פרסונה-dropdown/6-swatches) → 'שמור טיוטה' כותב Trade-טיוטה ל-store.

**אימות-ויזואלי:** widget-tests — `trade_builder_home_test` 6/6 (RTL directionality · semantics-button · clamp-1.35 עם anti-vacuity · wizard-literal · ניווט · write-path טיוטה + הרשימה מתעדכנת) + **flag-OFF absent נבדק גם offstage** (סריקת skipOffstage:false על ה-IndexedStack). `manager_dashboard_screen_test` — 36/36 ללא-שינוי (הלוח בייט-זהה ב-OFF). השפה הוויזואלית שוכפלה מהלוח (LIGHT · _ManageSection · brand-pill).

## merge — איחוד workstream המקלדת/חיפוש (origin) לקו Studio/עמוד-2 — 2026-06-30

**שינויי-UI נכנסים (lib/screens, מ-merge):** 95 commits של ה-workstream האחר (card-keyboard/finder) כוללים שינויי-מסך כגון `lipskey_product_sheet.dart`. **אלו שינויים שכבר אומתו ע"י אותו workstream על origin** — לא שינויי-UI חדשים מהקו שלי. **קו עמוד-2/Studio שלי הוא state/domain בלבד — אפס שינוי-מסך.** אימות-ויזואלי של המסכים הנכנסים באחריות ה-workstream שיצר אותם; כאן רק מיזוג (אפס קונפליקטים, analyze 0).

## v6.76 — 🤖 קו-פיילוט-מנהל + כרטיס-hero בקוקפיט — 2026-06-23

**שינויי-UI (lib/screens):** מסך חדש `ManagerCopilotScreen` + כרטיס-hero חדש בראש 📊 לוח-בקרה.

**אימות-ויזואלי:**
- **כרטיס-hero (`_CopilotHero`):** כרטיס brand-gradient (`brand`→`brandDark`, top-right→bottom-left) בראש הקוקפיט: 🤖 + "שאל את העסק שלך" + שורת-משנה (live: "מה בוער?..." / off: "דורש חיבור") + chevron. `Semantics(button)`. נבדק ע"י 49 טסטי-מנהל שמרנדרים את הקוקפיט (כולם ירוקים, כולל "builds as LIGHT frame").
- **מסך-הקו-פיילוט:** RTL · AppBar "🤖 קו-פיילוט / שאל את העסק שלך" · `_Welcome` (🤖 + צ'יפי-שאלות + כפתור-תדריך) · בועות-צ'אט (משתמש=brand-ימין · עוזר=card-שמאל, maxWidth 82%) · `_Typing` spinner · `_InputBar` (TextField + שלח). off-state = `AiOffState` כשאין-gateway. נבדק ב-`manager_copilot_screen_test`.
- **אפס שינוי-מבני בלוח** — רק כרטיס-hero additive בראש הרשימה. שאר הקוקפיט (5 מדדים + צינור) ללא-שינוי. **AppBar לא שונה** (הסרתי action-6 שגרם overflow).
- **תואם-ממשל:** מודיעין/פיקוח · אפס-HR.

**טסט:** `manager_copilot_test` 7 + `manager_copilot_screen_test` 1 + 49 מנהל ירוקים · analyze 0 · full-suite.

## v6.73 — חיפוש-AI היברידי · כותרת-תוצאה משתנה לפי-מסלול — 2026-06-23

**שינוי-UI (lib/screens):** `ai_finder_screen` + `ai_assistant_screen` (findProduct) — החיפוש עכשיו literal-first.

**אימות-ויזואלי:**
- **ai_finder:** כותרת-התוצאה משתנה לפי-מסלול — מסלול-literal: `🔎 "<query>"  ·  N מוצרים`; מסלול-AI: `📂 <קטגוריה>  ·  N מוצרים` (כמו קודם). הודעת-אין-תוצאות שונתה מ"לא זוהתה קטגוריה" ל"לא נמצאו תוצאות — נסה מילים אחרות" (כללי יותר, כי כעת מחפש מוצרים לא רק קטגוריות). שאר המסך (טופס, ListTile, SliverList עצל) ללא-שינוי-מבני.
- **assistant findProduct:** שורת-התווית בתשובה משתנה מ`📂 <קטגוריה>` ל`🔎 "<query>"` כשהתאמה-מילולית; פורמט-הבועה (head + label + שורות-`•`) זהה.
- **אפס שינוי-מבני** — רק טקסט-כותרת/תווית דינמי. הזרימה, ה-widgets, וה-layout נשמרים.

**טסט:** `ai_finder_test` +4 (שחור→שחורים-לא-נחושת · ברז→הרבה · 1"→נגיש · חיווט) · assistant/intent ירוקים · analyze 0 · full-suite baseline.

## v6.71 — אודיט-נחיל #3 · 4 תיקוני-overflow בגרידים (layout-robustness) — 2026-06-23

**שינויי-UI (lib/screens):** 4 תיקוני-חוסן-overflow מעדשת-ה-layout. **שינוי-התנהגות בקצוות-קיצון בלבד** (טקסט-ארוך/text-scaling 1.35x) — תצוגה רגילה ללא-שינוי.
- `persona_portal.dart` `PortalTileButton` — `title` קיבל `maxLines:2`, `sub` קיבל `maxLines:1` + `ellipsis` (היו ללא-גבול → גלישה בתווית-ארוכה).
- `departments_screen.dart` `_DeptTile` — `dept.name` קיבל `maxLines:2`+`ellipsis` (textAlign.center נשמר).
- `store_screen.dart` `_GridHubCard` — ה-`Column` הפנימי קיבל `mainAxisSize:min` (ה-Texts כבר היו עם maxLines/ellipsis) → לא דוחף-גלישה בתא-קבוע.
- `store_screen.dart` גיליון-הזמנה — הוסר `SingleChildScrollView` **פנימי-כפול** מיותר (אותו ציר; הפנימי בלע גלילה). נשאר scroll-view יחיד (אומת ע"י הסוכן: סוגריים מאוזנים).

**אימות:** כל ה-widgets נשמרים verbatim; השינויים הם maxLines/ellipsis/mainAxisSize/הסרת-עטיפה-כפולה — **אפס שינוי בתצוגה הרגילה**, רק מניעת גלישה במצבי-קצה. הגלובלי `clamp(0.85,1.35)` של text-scale (main.dart) חוסם את משרעת-הסיכון.

**שאר v6.71 לא-ויזואלי:** שרת (reviewRoleRequest/credit) · rules (chat-thread) · cache (seed-blank) · kb_golden · callable-timeout · 5 טסטים. analyze 0 · full-suite (kb_golden skipped).

## v6.70 — אודיט-עדשות-שונות · ai_finder → CustomScrollView (תוצאות עצלות) — 2026-06-23

**שינוי-UI יחיד (lib/screens):** `ai_finder_screen.dart` — גוף-המסך עבר מ-`ListView(children:[…for…])` ל-
`CustomScrollView` עם `SliverList.builder` לתוצאות (perf: עד ~120 tiles נבנו eager בכל חיפוש).

**אימות-ויזואלי:** **רפקטור-מבנה בלבד — אפס שינוי-תצוגה מכוון.** ה-padding פוצל לשקילות מדויקת ל-
`EdgeInsets.all(space4)` המקורי: ה-sliver-הראשון `fromLTRB(space4,space4,space4,0)` (טופס+סטטוס+כותרת-קטגוריה),
ה-sliver-השני `symmetric(horizontal:space4)` (ה-tiles), ו-`SliverToBoxAdapter(SizedBox(space4))` סוגר את התחתית —
top/sides/bottom = space4, והרווח כותרת↔tiles = ה-`SizedBox(space2)` הקיים. כל widget נשמר verbatim
(טקסט-off, TextField, FilledButton, כותרת-📂, ה-ListTile עם chevron, מצב "לא זוהתה קטגוריה").

**שאר השינויים — לא-ויזואליים:** matchers (לוגיקה), race-gates (`|| _loading`, התנהגות), sanitize (prompt),
server (`claude.ts`). אין להם שינוי-מסך.

**טסט:** full-suite baseline · analyze 0 errors.

## v6.69 — swarm-fixes גל-4 · de-dup סולם-התוצאה ב-8 מסכי-נרטיב — 2026-06-23

**שינוי (lib/widgets + lib/screens):** 3 widgets חדשים ב-`ai_result_states.dart` (`AiOffState`/`AiLoadingState`/
`AiFailedState`) מחליפים את סולם-המצבים off/loading/failed שהיה משוכפל ב-8 מסכי-AI.

**אימות-ויזואלי:**
- **off/loading:** ה-widgets מרנדרים **בדיוק** אותם bytes כמו קודם (`Text(text, mutedLight/13)` · `Center(CircularProgressIndicator())`) — אומת ב-`ai_result_states_test` (צבע+גודל-גופן).
- **failed:** זהה-מבנית, **למעט** צבע-הטקסט `danger`→`dangerDark` — שינוי-WCAG **מכוון** (AA על הרקע-הבהיר; `danger` 0xFFEF4444 נכשל). אומת ב-test (`color == dangerDark`, `!= danger`).
- **שלב-התוצאה לא נגע** (per-screen, כולל ה-spreads עם כפתור-העתקה) → אפס שינוי-פריסה.
- **token-drift:** `Color(0xFFEEEEEE)`/`0xFF9AA3B2`/`0xFFB91C1C` → `BsTokens.divider`/`mutedDark`/`dangerDark` — **ערכים זהים-לפיקסל** (אומת מול `tokens.dart`), אפס שינוי-צבע.

**טסט:** `ai_result_states_test` 4/4 ירוק · full-suite `+3333 -1` (kb_golden הידוע) · analyze 0 errors.

## v6.68 — swarm-fixes גל-3 · narrate-bridge refactor (סיכום-אתר) — 2026-06-23

**שינוי (lib/screens):** `site_hub_screen.dart` — `_openSiteSummary` עבר מבניית-שורות-inline לקריאה ל-helper
טהור `siteSummaryReportLines` (חולץ ל-`site_hub_state.dart`). **רפקטור בלבד — אפס שינוי-תצוגה.**

**אימות:** ה-helper מחזיר **בדיוק** את אותן שורות שהיו inline (אותו פורמט, אותם פילטרי-סטטוס) — אומת ב-
`narrate_bridge_test` (4 בדיקות) + הקריאה ב-`_openSiteSummary` מעבירה את אותם 3 ה-providers. הכפתור/המסך
זהים ויזואלית; ההבדל היחיד הוא שהלוגיקה עכשיו בדיקה.

**תוצאה:** ✅ אפס שינוי ויזואלי, כיסוי-טסט חדש לגשר-הקריטי. analyze 0 errors.

---

## v6.65 — swarm-fixes גל-2 · a11y button-role בכרטיס-הקטלוג — 2026-06-23

**שינוי (lib/screens):** `catalog_screen.dart` — כפתורי "✨ נסח" + "🔌 איך לגשר?" (GestureDetector חשופים) עטופים
ב-`Semantics(button: true, label: …)`. (השינוי השני הוא בשרת `functions/src/claude.ts`, לא-UI.)

**אימות (reasoning):** המראה זהה לחלוטין (אותו טקסט/צבע/מיקום); ההבדל היחיד הוא שכעת קורא-מסך מכריז עליהם
כ-"כפתור" עם תווית. אפס שינוי-תצוגה ויזואלי, אפס שינוי-התנהגות. (גודל-היעד עדיין מוגבל ע"י עיצוב-השורה הצפופה
— משותף עם צ'יפים קיימים, מתועד כדחוי.)

**תוצאה:** ✅ שיפור-a11y בלבד, byte-identical ויזואלית. analyze 0.

---

## v6.64 — swarm-fixes גל-1 · a11y + spec_copilot (אודיט-הנחיל) — 2026-06-23

**שינויים (lib/screens):** `contractor_tools_sheets.dart` — כפתור "🤔 למה כדאי?" ל-≥48dp (היה 32dp).
`spec_copilot_screen.dart` — טקסט-הוורדיקט (✓/✗) ל-`successDark`/`dangerDark` (ניגודיות) + מירוץ-טמפרטורה.
(`ai_assistant_screen.dart` — הסרת prompt-מת, ללא שינוי-תצוגה.)

**אימות (reasoning + טסטים — אין מכשיר):**
- כפתור-החלופה: יעד-מגע גדל מ-32dp ל-48dp; הטקסט/האייקון ללא-שינוי → רק קל יותר ללחוץ.
- spec_copilot: צבע-הטקסט כהה יותר (ירוק/אדום-כהה) על אותו רקע-תינט → קריא יותר, אותו תוכן. מירוץ: בחירת
  טמפ' חדשה בזמן-בקשה כבר לא מציגה הסבר של הטמפ' הישנה (snapshot של `_temp`) ולא משאירה spinner תקוע.

**תוצאה:** ✅ שינויי-UI מינוריים ובטוחים, אפס שינוי-תוכן. analyze 0 · spec_copilot/ai_assistant/alt טסטים ירוקים.

---

## v6.62 — #ai-reject-reason · בקשות-תפקיד (מנהל): כפתור "✨ נסח סיבת-דחייה" — 2026-06-23

**שינוי (lib/screens):** `role_requests_inbox_screen.dart` (`_RequestCard`) — מתחת לאישור/דחייה נוסף `Consumer`
עם "✨ נסח סיבת-דחייה" → `RejectReasonScreen` (חדש). המסך מנסח נוסח-דחייה מנומס מ-closed-set קטגוריות.

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`): בכרטיס-בקשה, מתחת לאישור/דחייה, מופיע "✨ נסח סיבת-דחייה";
  לחיצה פותחת מסך שמנסח נוסח-דחייה כללי-מכובד (loader → טקסט) + "📋 העתק". המנהל עורך/מעתיק.
- **AI כבוי** (demo/web · gateway null): ה-`Consumer` מחזיר `SizedBox.shrink()` → הכפתור **לא בעץ** →
  כרטיס-הבקשה byte-identical (כפתורי אישור/דחייה בלבד, כמו קודם).

**תוצאה:** ✅ שני המצבים נכונים, אפס רגרסיה בדמו. analyze 0 errors/warnings · `reject_reason_test` ירוק.
צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.62).

---

## v6.61 — #ai-site-summary · יומן-אתר: כפתור "✨ סכם התקדמות עם AI" — 2026-06-23

**שינוי (lib/screens):** `site_hub_screen.dart` (`_SiteDiary`) — אחרי "+ רישום יומן" נוסף `if (gateway != null)`
עם "✨ סכם התקדמות עם AI" → `_openSiteSummary` (קורא diary+snags+inspections) → `DailyReportScreen` (reuse;
ה-AppBar הוכלל ל-"✨ ניסוח חכם").

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`): בראש יומן-האתר מופיע "✨ סכם התקדמות"; לחיצה פותחת מסך עם
  שורות-האתר האמיתיות (רישומי-יומן · ליקויים · ביקורות) → נרטיב Claude + "העתק לשליחה".
- **AI כבוי** (demo/web · gateway null): ה-`if` שקרי → הכפתור **לא בעץ** → יומן-האתר byte-identical
  (כפתור "+ רישום יומן" + הרשומות בלבד, כמו קודם).

**תוצאה:** ✅ שני המצבים נכונים, אפס רגרסיה בדמו. analyze 0 errors · `daily_report_test` (ה-prompt המשותף) ירוק.
צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.61).

---

## v6.60 — #ai-daily-report · טאבי-דוחות (עובד+שליח): כפתור "✨ נסח דוח עם AI" — 2026-06-23

**שינוי (lib/screens):** `worker_reports_tab.dart` + `courier_reports_tab.dart` — ליד "💬 שלח דוח יומי" נוסף
`if (gateway != null)` עם "✨ נסח דוח עם AI" → `DailyReportScreen` (חדש, משותף). כל טאב בונה reportLines
מאותם מספרים-חיים שה-chat-report משתמש בהם.

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`): ליד כפתור-השליחה מופיע "✨ נסח דוח עם AI"; לחיצה פותחת מסך עם
  שורות-הדוח האמיתיות (loader → נרטיב Claude) + "📋 העתק לשליחה". עובד=סטטוסי-משימות · שליח=מוני-מסירות.
- **AI כבוי** (demo/web · gateway null): ה-`if` שקרי → הכפתור **לא בעץ** → שני הטאבים byte-identical
  (כפתור "💬 שלח דוח יומי" הקיים בלבד, כמו קודם).

**תוצאה:** ✅ שני המצבים נכונים בשני הטאבים, אפס רגרסיה בדמו. analyze 0 errors · `daily_report_test` ירוק.
צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.60).

---

## v6.59 — #ai-credit-explain · sheet-לקוח (מנהל): כפתור "💳 הסבר אשראי" — 2026-06-23

**שינוי (lib/screens):** `manager_dashboard_screen.dart` — ב-`_CustomerDetailSheet`, מתחת לשורות-האשראי,
נוסף `if (gateway != null)` עם "💳 הסבר אשראי" → `CreditExplainScreen`. `credit_explain_screen.dart` (חדש) —
מציג את 4 המספרים האמיתיים (מסגרת/נוצל/יתרה/ניצול%) וקורא ל-Claude להסבר.

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`): ב-sheet הלקוח, מתחת לשורות-האשראי, מופיע "💳 הסבר אשראי";
  לחיצה פותחת מסך עם המספרים האמיתיים בראש (loader → הסבר Claude מה הניצול אומר לפני אישור הזמנה). כשל → "נסה שוב".
- **AI כבוי** (demo/web · gateway null): ה-`if` שקרי → הכפתור **לא בעץ** → ה-sheet byte-identical
  (שורות-האשראי + רשימת-ההזמנות בלבד, כמו קודם).

**תוצאה:** ✅ שני המצבים נכונים, אפס רגרסיה בדמו. analyze 0 · `credit_explain_test` ירוק.
צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.59).

---

## v6.56 — #ai-assistant-agentic Phase 2 · "הוסף לסל" עם אישור בבועה — 2026-06-23

**שינוי (lib/screens):** `ai_assistant_screen.dart` — בועת-עוזר עבור `addToCart` מציגה את הערכה (רשימת-פריטים אמיתית)
+ כפתור **"🛒 הוסף N לסל"**; לחיצה → `_confirmAdd` כותב לסל ומחליף ל-"✓ נוסף לסל". מצב-ריק עודכן (העוזר עכשיו *עושה*).

**אימות (reasoning + קוד + טסטים):**
- **AI דלוק** + "תוסיף ערכה לסל": המודל מחזיר `{"action":"addToCart","key":"<recipe>"}` → בועה עם הפריטים האמיתיים
  + כפתור-אישור. **רק לחיצה** מוסיפה (G5 — ה-`smartCartProvider.add` היחיד ב-`_confirmAdd`); אחרי לחיצה → "✓ נוסף".
- **מפתח-ערכה מומצא / JSON שבור** → `parseAssistantIntent` → `answer` → בועת-שיחה, **בלי כפתור** ובלי הוספה.
- **AI כבוי** (gateway null): off-state קיים, ללא-שינוי. byte-identical.

**תוצאה:** ✅ הוספה רק אחרי אישור-משתמש (אף נתיב-מודל לא כותב לסל לבד). `ai_assistant_test` הישן ירוק · analyze 0 ·
mutation-verify (#ai-assistant-agentic-p2). צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.56).

---

## v6.55 — #ai-assistant-agentic · העוזר לוקח פעולות (Phase 1 read-only) — 2026-06-22

**שינוי (lib/screens):** `ai_assistant_screen.dart` — ה-`_send` שוכתב: במקום reply-טקסט, המודל מחזיר JSON-פעולה,
`parseAssistantIntent` מאמת, ו-`_dispatchIntent` מריץ מעל המנועים ומחזיר טקסט-בועה. **שום widget חדש** —
אותן בועות-טקסט/typing/קלט כמו v6.51 (לכן אין צילום נדרש מעבר ל-widget-pump הקיים).

**אימות (reasoning + קוד + טסטים):**
- **AI דלוק:** "תמצא לי ברז" → המודל מחזיר `{"action":"findProduct","key":"<קטגוריה>"}` → בועה עם המוצרים האמיתיים
  (`productsInCategory`). "מה מצב ההזמנות?" → `summarizeOrders` → בועה עם תובנות-אמת (`computeAnalyticsInsights`).
  "כמה בתקציב?" → `checkBudget`. כל השאר → `answer` (שיחה רגילה, בדיוק כמו קודם).
- **JSON שבור / קטגוריה מומצאת / action לא-מוכר** → `parseAssistantIntent` מחזיר `answer` → המשתמש מקבל תשובת-שיחה,
  **לעולם לא פעולה שגויה** (G1/G2/G3 ב-`assistant_intent_test`, + mutation-verify).
- **AI כבוי** (demo/web · gateway null): ה-off-state הקיים ("דורש חיבור"), ללא-שינוי. byte-identical.

**תוצאה:** ✅ כל המצבים נכונים, `ai_assistant_test` הישן נשאר ירוק (הפונקציות הישנות נשמרו). analyze 0.
צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.55).

---

## v6.54 — #ai-business-summary · Analytics: כפתור "✨ סיכום בעברית" — 2026-06-22

**שינוי (lib/screens):** `ai_hub_screen.dart` — בתוך מסך-ה-`_Analytics` (לא ברשימת-ה-tiles!), אחרי הערת-השרת,
נוסף `if (gateway != null && insights.isNotEmpty)` עם `OutlinedButton.icon` "✨ סיכום בעברית" → `BusinessSummaryScreen`.
`business_summary_screen.dart` (חדש) — מציג את שורות-התובנה האמיתיות (bullets) וקורא ל-Claude לסיכום-עסקי זורם.

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`) + יש תובנות: בראש מסך-ה-Analytics (מעל כרטיסי-התובנה) מופיע
  "✨ סיכום בעברית"; לחיצה פותחת מסך עם ה-bullets האמיתיים (loader → נרטיב של Claude). כשל → "נסה שוב".
- **AI כבוי** (demo/web · gateway null): ה-`if` שקרי → הכפתור **לא בעץ** → מסך-ה-Analytics byte-identical
  (כרטיסי-התובנה בלבד, בדיוק כמו קודם). **לא נגעתי ברשימת-ה-tiles** → tile-position-tests נשארים ירוקים.

**תוצאה:** ✅ שני המצבים נכונים, אפס רגרסיה בדמו. analyze 0 errors/warnings · `business_summary_test` ירוק.
צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.54).

---

## v6.53 — #ai-quote-polish · קטלוג: כפתור "✨ נסח" ליד "📋 הצעה" — 2026-06-22

**שינוי (lib/screens):** `catalog_screen.dart` — ליד כפתור "📋 הצעה" (העתק-גולמי) נוסף `Builder` gated עם "✨ נסח"
→ `QuotePolishScreen`. `quote_polish_screen.dart` (חדש) — מציג את ההצעה הגולמית, קורא ל-Claude לניסוח מקצועי,
ומאפשר "📋 העתק לשליחה".

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`): ליד "📋 הצעה" מופיע "✨ נסח"; לחיצה פותחת מסך עם ההצעה-הגולמית
  למעלה (loader → טקסט מנוסח של Claude) + כפתור העתקה. המספרים זהים לגולמי (rewrite-only). כשל → "נסה שוב".
- **AI כבוי** (demo/web · gateway null): ה-`Builder` מחזיר `SizedBox.shrink()` → הכפתור **לא בעץ** →
  שורת-הכפתורים בכרטיס byte-identical (רק "📋 הצעה" הגולמי, כמו קודם).

**תוצאה:** ✅ שני המצבים נכונים, אפס רגרסיה בדמו. analyze 0 errors/warnings · `quote_polish_test` ירוק.
צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.53).

---

## v6.52 — #ai-adapter-explain · קטלוג: לינק "🔌 איך לגשר?" מתחת לאזהרת-החיבור — 2026-06-22

**שינוי (lib/screens):** `catalog_screen.dart` — ה-Builder של אזהרת-החיבור (step 29) הורחב מ-`Text` ל-`Column`:
האזהרה "נדרש מתאם" + לינק **"🔌 איך לגשר?"** (רק כש-`aiOn`) → `AdapterExplainScreen`. `adapter_explain_screen.dart`
(חדש) — מציג את הקצוות האמיתיים (chips מ-`kVerifiedSpecs[sku].ends`) + חומר, וקורא ל-Claude להסבר "למה + איזה מתאם".

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`) + אזהרת-חיבור פעילה: מתחת ל"נדרש מתאם" מופיע לינק "🔌 איך לגשר?";
  לחיצה פותחת מסך עם ה-chips של הקצוות האמיתיים (loader → הסבר Claude ברמת סוג-מתאם). כשל → "נסה שוב".
- **AI כבוי** (demo/web · gateway null): ה-`if (aiOn)` שקרי → הלינק **לא בעץ** → הכרטיס byte-identical
  (אזהרת-החיבור עצמה ללא-שינוי; ה-`Column` עוטף רק את ה-`Text` הקיים).

**תוצאה:** ✅ שני המצבים נכונים, אפס רגרסיה בדמו. analyze 0 errors/warnings · `adapter_explain_test` ירוק.
צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.52).

---

## v6.51 — #ai-assistant · "🤖 העוזר החכם" — צ'אט-AI מעוגן ב-AI hub — 2026-06-22

**שינוי (lib/screens):** `ai_hub_screen.dart` — tile חדש "🤖 עוזר חכם" בסוף הגריד (tail — שומר index לטסטי-position) → `AiAssistantScreen`.
`ai_assistant_screen.dart` (חדש) — מסך-צ'אט: בועות משתמש/עוזר, typing-indicator, שורת-קלט. כל הודעה →
Claude (system מעוגן) → תשובה. **לא נוגע ב-sys_chat** (מנוע-הצ'אט בפרודקשן).

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`): tile פותח את המסך; הקלדה+שליחה → בועת-משתמש (ימין) +
  typing → בועת-עוזר (שמאל). שאלה "תבנה לי סל" → ה-system מפנה ל"תאר עבודה → סל", **לא** ממציא מוצרים.
  כשל-רשת → בועת "משהו השתבש — נסה שוב". היסטוריה חסומה ל-12 תורות.
- **AI כבוי** (demo/web · gateway null): המסך מציג "💡 העוזר החכם דורש חיבור לשרת" + קלט מושבת. ה-tile
  עצמו תמיד גלוי (כמו describe→cart) — אין שינוי בדמו מעבר ל-tile החדש שמוביל ל-off-state כן.

**תוצאה:** ✅ שני המצבים נכונים. analyze 0 errors/warnings · 6 טסטי-grounding + readiness 8-visible ירוקים.
צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.51).

---

## v6.50 — #ai-paired-explain · כרטיס-מוצר: כפתור "🧩 מה עוד צריך להתקנה?" — 2026-06-22

**שינוי (lib/screens):** `lipskey_product_sheet.dart` — ליד "מתאים לתנאים שלי?" נוסף `Builder`+`Consumer`
שמרנדר `OutlinedButton.icon` **"🧩 מה עוד צריך להתקנה?"** → `PairedExplainScreen.route(...)`.
`paired_explain_screen.dart` (חדש) — מציג את המוצר + chips של סוגי-המוצרים המשלימים (data) וקורא ל-Claude
ב-`initState` להסבר "למה כל סוג + אל תשכח".

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`) ויש סוגים-משלימים (`frequentlyPairedTypesFor(p).isNotEmpty`):
  הכפתור מופיע מתחת ל-spec-copilot; לחיצה פותחת מסך עם ה-chips האמיתיים (loader → הסבר Claude). כשל → "נסה שוב".
- **AI כבוי / אין סוגים** (demo/web · gateway null · רשימה ריקה): ה-`Builder`/`Consumer` מחזיר `SizedBox.shrink()`
  → הכפתור **לא בעץ** → ה-sheet נשאר **byte-identical** (כולל מקרה ה-spec-copilot-בלבד שכבר קיים).

**תוצאה:** ✅ שלושת המצבים נכונים, אפס רגרסיה בדמו. analyze 0 errors (4 warnings dead-code ישנים, לא שלי).
צילום על-מכשיר ע"י הבעלים בבילד הבא (v6.50).

---

## v6.49 — #ai-alt-explain · sheet החלופות: כפתור "🤔 למה כדאי?" לכל שורה — 2026-06-22

**שינוי (lib/screens):** `contractor_tools_sheets.dart` — בכל שורת-חלופה ב-`_CheaperAlternativesSheet`
נוסף `Consumer` שמרנדר `TextButton.icon` **"🤔 למה כדאי?"** מתחת לבאדג'-החיסכון → `AltExplainScreen.route(...)`.
`alt_explain_screen.dart` (חדש) — מסך שמציג את ההחלפה האמיתית (שמות+מחירים+חיסכון מה-data) וקורא ל-Claude
ב-`initState` להסבר ה-tradeoff.

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`): כל שורה בסheet מציגה את הכפתור; לחיצה פותחת את `AltExplainScreen`
  עם המספרים האמיתיים בראש (loader → טקסט-הסבר של Claude). אם הקריאה נכשלת → "נסה שוב".
- **AI כבוי** (demo/web, gateway null): ה-`Consumer` מחזיר `SizedBox.shrink()` → הכפתור **לא בעץ** → ה-sheet
  נשאר **byte-identical** (שורת-מוצר + המלצה + חלופה + באדג'-חיסכון, בדיוק כמו קודם).

**תוצאה:** ✅ שני המצבים נכונים, אפס רגרסיה בדמו. analyze 0 errors/warnings. צילום על-מכשיר ע"י הבעלים
בבילד הבא (v6.49).

---

## v6.48 — #ai-search-fallback · קטלוג: כפתור "נסה חיפוש חכם" במצב no-results — 2026-06-22

**שינוי (lib/screens):** `catalog_screen.dart` — מצב "אין תוצאות" (`filtered.isEmpty && products.isEmpty`)
הוחלף מ-`Text` בודד ל-`Column`: אותה הודעת "לא נמצאו תוצאות עבור …" + מתחתיה `OutlinedButton.icon`
**"🗣️ נסה חיפוש חכם"** → `AiFinderScreen.route(initialQuery: query)`. `ai_finder_screen.dart` — `initialQuery`
חדש + `initState` מריץ `_search()` ב-`addPostFrameCallback` (חיפוש-אוטומטי כשמגיעים עם שאילתה).

**אימות (reasoning + קוד — אין מכשיר כאן):**
- **AI דלוק** (`claudeGatewayProvider != null`): חיפוש ללא-תוצאות מציג טקסט + כפתור; לחיצה פותחת את ה-AI
  finder עם השדה **כבר ממולא** והחיפוש רץ אוטומטית (loader → קטגוריה + מוצרים אמיתיים). הכפתור עטוף ב-
  `if (query.isNotEmpty && gateway != null)`.
- **AI כבוי** (demo/web, gateway null): ה-`if` נופל → הכפתור **לא בעץ** → ה-no-results נשאר **byte-identical**
  ל-`Text` המקורי; `initialQuery` ברירת-מחדל null → `initState` no-op → המסך הידני ללא-שינוי.

**תוצאה:** ✅ שני המצבים נכונים, אפס רגרסיה בדמו. analyze 0 errors/warnings. צילום על-מכשיר ע"י הבעלים
בבילד הבא (v6.48).

---

## 2026-06-17 — תיקון כניסת-בעלים: כפתור "כניסה עם Google" במסך הראשון

**שינוי (lib/screens):** `welcome_screen.dart` — בנתיב-הקבלן (`boardRole == null`), כשמחובר
(`useFirebaseBackend`), נוסף בראש כרטיס-הכניסה כפתור **FilledButton כתום "כניסה עם Google (בעלים)"**
(קורא ל-`_managerGoogleLogin` הקיים). הוסתר בדמו (אין Firebase). **ויזואלית:** כפתור מלא בצבע-המותג מעל
"כניסה ללקוח קיים", באותו סגנון (radius 14, padding space4) — אין layout חדש, מתווסף ל-Column הקיים.
**למה:** מבוי-הסתום שבו כניסת-ה-Google של הבעלים הייתה נגישה רק מתוך HomeShell (שלא נגיש בלי התחברות).
**אימות:** analyze 0; הכפתור מופיע רק כשמחובר (gated), בדמו המסך byte-identical (לא נוגעים בנתיב flag-OFF).
צילום על-מכשיר ע"י הבעלים בבילד הבא (1.4.6 / build #42) — המטרה: הכפתור גלוי ומחבר ב-tap אחד.

---

## 2026-06-16 — server-connect fix wave (התראות: feed כן כשמחובר)

**שינוי (lib/screens):** `notifications_screen.dart` (S2) — בבילד מחובר (`useFirebaseBackend`) ה-feed
מציג **ריק-כן** במקום רשימת-הדמו הקשיחה (`_kNotifs`) + ביטול באדג'-ה"לא-נקרא" המזויף. הגזירה דרך getter
יחיד `_activeNotifs` (`useFirebaseBackend ? const [] : _kNotifs`); כל הצרכנים (badge, רשימה, mark-all,
dismiss-all, header) עברו דרכו.
**אימות ויזואלי (reasoning, לא screenshot — אין מכשיר כאן):** אין layout/widget חדש — המסך עובר
ל-**empty-state הקיים** (אותה רשימה, ריקה). נתיב הדמו (`flag OFF`) **byte-identical** (`_activeNotifs ==
_kNotifs`), מאומת ע"י הסוויטה (store_notif_widget_test ירוק). במחובר: הרשימה ריקה (אפס התראות מזויפות) עד
שהשרת יכתוב `notifications/{uid}` אמיתיות — זה ה-empty-state ההגון, אותו רכיב, לא מסך חדש. analyze 0.
**TODO (DEFER):** feed-התראות אמיתי (השרת כותב doc-ים) — גל נפרד.

---

## 2026-06-15 — מעבר צי כפתור-כפתור (4 traces) + תיקונים

**שינוי (lib/screens):** 4 סוכנים read-only עברו על **כל פקד + כל זרימה** (כניסה/הרשמה/חשבונות/מנגנון).
ורדיקט: כל הפקדים מחוּוטים נכון, כל הזרימות תקינות end-to-end, חוזי-callable + מטריצת-האישור **עקביים 3-כיוונית**,
flag-OFF אפס-רגרסיה. **תוקן:** (MED) ה-mirror של הרשמת-מייל כתב את המייל לשדה `phone` ב-`users/{uid}` — עכשיו
טלפון→`phone`, מייל→`email` (לפי `validIsraeliMobile`/`validEmail`). (קוסמטי) doc-comment של מחיקה
(`user.delete`→callable); מחרוזת תוקף-OTP אוחדה. **מקובל (נרשם):** inbox בקשות-תפקיד לא-נגיש ל-admin-בלבד
(`rolesFromClaims` לא חושף את claim ה-admin) — אך לכל תפקיד-מבוקש יש מאשר תפעולי, ול-admin יש `setRole`, אז שום
בקשה לא נשארת ללא-מאשר; חשיפת admin ל-inbox = שיפור עתידי. **אימות:** `analyze` 0 (שלי) · welcome+login 29/29.

---

## 2026-06-15 — fleet VERIFICATION-scan fixes (מעבר 3, סופי)

**שינוי (lib/screens + lib/state):** המעבר ה-3 של הצי (על הקוד הסופי) חזר נקי על אבטחה (0) + רוב
lifecycle/gating, ותפס 1 HIGH + 3 MEDIUM — נסגרו: **(HIGH)** `_registerViaAuth` כבר לא תלוי ב-snapshot
`signedIn` שטרם התעדכן אחרי יצירת-חשבון → מתקדם ללא-תנאי אחרי create מוצלח, ו-`_finishAfterAuth` נופל ל-
`currentUser.uid` של ה-gateway כך שה-mirror ל-users/{uid} עדיין נכתב (משתמש-מייל רשום היה נתקע ב-welcome).
**(MED)** הקטע ה-3 של טקסט-ההסכמה הוכהה ל-mutedLight (התיקון הקודם פספס אותו). **(MED)** ל-welcome
`_register`/`_existingLogin` נוסף latch `_busy` + השבתת-CTA (אין double-submit). **(MED)** `signInWithSmsCode`
עושה PEEK ל-ConfirmationResult של web ומסיר רק בהצלחה (retry של קוד-שגוי ב-web נשאר תקף).
**אימות:** `analyze` 0 (שלי) · welcome_auth_gate + login + auth_state 60/60.

---

## 2026-06-15 — fleet RE-SCAN fixes (כניסה/הרשמה)

**שינוי (lib/screens + lib/state):** ה-re-scan (4 עדשות) חזר נקי על אבטחה+lifecycle (0 ממצאים), אישר
שהתיקונים מחזיקים, והעלה MEDIUM חדש + פער-עקביות LOW — נסגרו: (1) `submitRoleRequest` כבר לא בולע את
ה-`delete` שלפני הכתיבה → re-request אחרי דחייה מתחיל מ-CREATE נקי (לא `merge:true` על שדות-reviewer ישנים),
bail ל-false אם ה-delete נכשל. (2) ל-welcome `_field` נוסף `onSubmitted`→`_register` (מקש "סיום" שולח, כמו
login). (3) טקסט-ההסכמה הוכהה ל-`mutedLight` (ניגודיות AA). **אימות:** `analyze` 0 (שלי) · role_request 5/5 +
welcome_auth_gate 6/6. LOW שנותרו (מקובל, נימוק): Semantics לקישורים, textAlign בשדות-ltr (תואם idiom),
בורר-מקצוע חד-אופציה (owner/UX).

---

## 2026-06-15 — fleet-review MEDIUM+LOW batch (כניסה/הרשמה)

**שינוי (UI, lib/screens + lib/state):** מקלדת+נגישות+תקינות בשדות הכניסה/הרשמה: `autofillHints` +
`textInputAction` (autofill + מקש הבא/שלח; ב-login גם `onSubmitted` בפיינים חד-שדה), `ltr` סלקטיבי
(שם עברי RTL — תיקון גם לשדה-השם ב-login; ספרות/מייל/קוד/סיסמה LTR), ו-`keyboardType: emailAddress`
לשדה-הקשר בהרשמה. login_sheet: ולידציית-מייל לפני round-trip, OTP בדיוק-6-ספרות, latch `_popped` +
איפוס `_justCreated` (אין טוסט-שגוי / pop-כפול). auth_state: timeout-גיבוי 120ש׳ ל-completer של ה-OTP.
role_request: ניקוי busy לפני ה-pop + `ExcludeSemantics` לאייקון. **אימות:** `analyze` 0 (שלי) ·
login_sheet+role_request+auth_state 59/59. **דחוי (נימוק):** אמוji-בכותרות (סגנון אפליקציה-רוחבי;
canvaskit-tofu הוא web-only וה-launch mobile) + micro-leak של מפת web-OTP (סיכון > תועלת).

---

## 2026-06-15 — fleet-review HIGH fixes (כניסה/הרשמה)

**שינוי (UI, lib/screens + lib/state):** (1) `role_requests.dart` — `submitRoleRequest` עוטף את
הכתיבה ב-try/catch (כשל-רשת/הרשאה → `false` במקום throw שהשאיר את הגיליון תקוע "טוען" בלי הודעה;
רגרסיה מ-#6 inc.2). (2) `welcome_screen.dart` — ל-`_field` נוסף `ltr`: טלפון/מייל/קוד/סיסמה מיושרים
LTR (`textDirection`), שדה-השם העברי נשאר RTL — תואם ל-`login_sheet` (במסך-ההרשמה היה caret/סדר הפוך).
**אימות:** `analyze` 0 (חדש) · `role_request_test` 5/5 (נוסף טסט: כתיבה-כושלת → "לא ניתן לשלוח" +
הגיליון נשאר שמיש). תיקון-ה-RTL = שינוי-תכונה 2-שדות, mirror ל-login_sheet הבדוק (אומת ויזואלית).

---

## 2026-06-15 — auth #6 inc.3: inbox אישור בקשות-תפקיד (#6 הושלם)

**שינוי (UI, lib/screens + lib/state):** `role_requests_inbox_screen.dart` (חדש) + שורת "📋 בקשות תפקיד"
בפרופיל — מוצגת רק כש-claim-roles של הקורא מאשרות tier (`approvableRolesForClaims`). ה-inbox מזרים
`roleRequests` scoped ל-tier (`pendingRoleRequestsProvider` — תואם ל-`canReview` ברולס, לעולם לא query
שייחסם), אישור/דחייה קוראים ל-callable `reviewRoleRequest` דרך seam-פונקציה `RoleReviewer`. החלטה מוציאה
את הכרטיס מ-query-ה-pending → הרשימה מתרוקנת מעצמה. **אימות:** `analyze` 0 (שלי) · `role_request_test`
4/4 (מטריצה + inbox-approve). #6 שלם: inc.1 שרת + inc.2 בקשה + inc.3 inbox.

---

## 2026-06-15 — auth #6 inc.2: UI בקשת-תפקיד

**שינוי (UI, lib/screens + lib/state):** `role_request_sheet.dart` (חדש) + שורת "🪪 בקשת תפקיד"
ב-`profile_screen` (signed-in). הגיליון מציג 4 תפקידים תפעוליים (worker/courier/store/contractor)
עם "מי מאשר" לכל אחד (לפי המטריצה); בחירה כותבת `roleRequests/{uid}` (status:pending,
displayName/phone מהפרופיל-המקומי) דרך `roleRequestWriterProvider` (null ללא backend → no-op).
ה-`reviewRoleRequest` בשרת (inc.1) מאשר/דוחה; ה-inbox = inc.3. **אימות:** `analyze` 0 ·
`role_request_test` 2/2 (כתיבת pending + gate ה-null).

---

## 2026-06-15 — auth P2: displayName ביצירת-חשבון-מייל

**שינוי (UI, lib/screens):** `login_sheet.dart` — פיין-"צור חשבון" מקבל שדה "שם מלא (לא חובה)" מעל המייל;
בהצלחה `register` שומר את השם בפרופיל-המקומי, וצעד-ה-post-auth של welcome (`_finishAfterAuth`) כבר ממראה
אותו ל-`users/{uid}.displayName` (נקרא ע"י `computeCredit` + שם-השולח ב-push). client-only, ללא שינוי
gateway/interface, ללא churn ב-fakes. **אימות:** `analyze` 0 · `login_sheet_test` 23/23 (נוסף טסט: שם→profile.name).

---

## 2026-06-15 — auth P2: OTP resend cooldown + תוקף-קוד

**שינוי (UI, lib/screens):** `login_sheet.dart` — צעד-הקוד אוכף cooldown של 30ש׳ ל"שליחת קוד חדש"
(re-tap בתוך החלון → טוסט "אפשר לשלוח קוד חדש בעוד N שניות", בלי send חוזר), pre-check לתוקף ~2 דק׳
לפני round-trip (ה-session-expired של השרת = backstop), וכותרת-המשנה של צעד-הקוד מציינת את חלון-התוקף
("תקף לכ-2 דקות"). מבוסס-timestamp (**ללא Timer**) כדי ש-pumpAndSettle של טסטי-ה-OTP ימשיכו ל-settle.
**אימות:** `analyze` 0 · `login_sheet_test` 22/22 (נוסף טסט-cooldown; כותרת-המשנה → `textContaining`).

---

## 2026-06-15 — auth P2: ליטוש כניסה (אנונימיות, הצג-סיסמה, אורך-סיסמה)

**שינוי (UI, lib/screens):** `login_sheet.dart` — (1) **anti-enumeration:** `hebrewAuthError('user-not-found')`
מקופל לאותה הודעה גנרית "אימייל או סיסמה שגויים" כמו סיסמה-שגויה (היה "לא נמצא חשבון" נפרד שאיפשר probing של
מיילים רשומים); (2) **eye toggle** להצגת/הסתרת הסיסמה בפיין-המייל; (3) **בדיקת-אורך ≥6 בצד-לקוח** ב"צור חשבון"
(פידבק מיידי לפני round-trip; ה-weak-password של השרת עדיין ממופה כ-backstop). **אימות:** `analyze` 0 ·
`login_sheet_test` 21/21 ירוקים (נוספו unit-אנונימיות + widget-אורך; טסט-ה-create עם ה-eye עדיין עובר).

---

## 2026-06-15 — auth #3: הודעת מייל-אימות במסלול "צור חשבון"

**שינוי (UI, lib/screens):** `login_sheet.dart` — דגל `_justCreated` + ה-auth-listener מציג במסלול-יצירה
"✓ החשבון נוצר — שלחנו מייל אימות…" במקום הטוסט הגנרי (ה-`sendEmailVerification` כבר לא שקט). **אימות:**
`analyze` 0 · `login_sheet_test` +20 ירוקים (טסט-ה-create עודכן לטוסט החדש; טסטי-הטלפון נשמרו). אכיפת
`emailVerified` נדחתה (backend-ON בלבד, החלטת-מוצר; החנות נשלחת דמו).

---

## 2026-06-15 — auth #1: auth-gate ב-OnboardingGate (backend-ON בלבד)

**שינוי (UI, lib/screens):** `onboarding_screen.dart` — `OnboardingGate` מנתב משתמש לא-מחובר ל-`_OpeningFlow`
(welcome/login) כש-`useFirebaseBackend` ON ו-auth נטען (`auth.loaded && auth.user==null`); כניסה → HomeShell,
logout → re-gate (ה-widget צופה ב-`authStateProvider`). **בילד-דמו (flag OFF) byte-identical** — וכך גם הסוויטה
(הדגל const, false בטסטים). **אימות:** `analyze` 0 · welcome_auth_gate+widget+onboarding +24 ירוקים.

---

## 2026-06-15 — auth #2: קישור "שכחתי סיסמה" בלשונית-הכניסה

**שינוי (UI, lib/screens):** `login_sheet.dart` — קישור "שכחתי סיסמה" בפאנל-האימייל (מצב כניסה בלבד,
`if(!_emailCreateMode)`) → `resetPassword` → `sendPasswordResetEmail`. טוסט-הצלחה ניטרלי ("אם קיים חשבון —
נשלח אליו מייל") בלי לחשוף אילו אימיילים רשומים (אנטי-enumeration). **אימות:** `analyze` 0 · טסטי-auth +102
ירוקים (6 fakes עודכנו ל-interface). אין שינוי-זרימה אחר; הקישור מוסתר במצב "צור חשבון".

---

## 2026-06-15 — chat-sync: FS_DIAG step-4 probe (אין שינוי-UI נראה)

**שינוי (lib/widgets):** `backend_debug_badge.dart` — שלב-4 (orders-create probe) משתמש ב-id ייחודי
(`BS-diag-$uid-${ms}`) במקום קבוע → תמיד CREATE (היה UPDATE בריצה-שנייה → role=— → ❌ כוזב). **אין שינוי
ויזואלי** בתג — רק לוגיקת-הבדיקה-הפנימית. **אימות:** `fsDiagStepResult` tests ירוקים, `analyze` 0.
(שאר תיקון-הצ'אט — sys_chat/chat_repository/firestore rules+index — לוגי/שרת, לא-UI.)

---

## 2026-06-15 — launch #6: פאנל-רגרסיה מגודר ל-debug (לוח-מנהל)

**שינוי (UI):** `manager_dashboard_screen.dart` — סעיף "🔬 בדיקות רגרסיה" נעטף ב-`if(kDebugMode) ...[]`.
ב-**release** הסעיף לא מוצג (משתמש שבוחר persona מנהל לא רואה כלי-פיתוח פנימי); ב-**debug** ללא שינוי
(הדגל `true`). מראה כמו ה-`BackendDebugBadge` שכבר מגודר באותו דפוס.
**אימות:** `flutter test` — `manager_dashboard_screen_test` + `manager_dashboard_test` ירוקים (+42);
`kDebugMode`=true תחת flutter test → הסעיף עדיין נבדק (אפס רגרסיה); `analyze` 0 errors. הקוד נשאר (reversible).

---

## v6.20 — חיווט קבלן↔עובד · גל DEBUNDLE (פירוק לוח-הקבלן — אימות חי בכרום)

**שינוי (UI ב-5 מסכים):** `tasks_screen.dart` (הוסרו טוגל מנהל↔עובד + `_workerView` + `_RolePicker` + 4 כפתורי-כלים כפולים → לוח-קבלן ממוקד: יצירה+אישורים+הצעות) · `site_hub_screen.dart` (אריחי גאנט/ליקויים/נוכחות → גיליונות חיים `showTasksGanttSheet`/`showDefectsSheet`/`showContractorAttendanceSheet`; אריח חדש 👷 חופשות; נמחקו 3 מסכי-דמו `_SiteGantt`/`_SiteSnagging`/`_SiteAttendance`; הוחזר אריח **focused** 📋 משימות צוות → openTasks) · `manager_dashboard_screen.dart` (בדיקת-גבולות ל-`kWorkers[task.worker]`) · `worker_app_screen.dart` (`_SubmitButton` ≥48px tap-target + `EdgeInsetsDirectional` ל-5 כפתורים) · `tasks_gantt_sheet.dart` (scope לפי צופה: עובד→tasks שלו · קבלן→employerId==demo||ריק).

**אימות (חי בכרום + אוטומטי):** הורצה הבנייה (build web release) על `localhost` ונוּוטה ידנית בעין: (1) **אתר-הבנייה אחרי הפירוק** — אין אריח-באנדל, האריחים הנכונים; (2) **גאנט** נפתח על המנוע החי (`tasksProvider`) ולא על דמו; (3) **גיליון-HR (👷 חופשות)** חי עם הדרכות-עובד אמיתיות; (4) **לוח-העובד** (אחרי מעבר שער-המסמכים) — אותן משימות מהמנוע, פתיחת כרטיס עם תיאור/שלבים/חומרים/כלים; (5) **זרם דו-כיווני חי** — העובד הציע "בדיקת לחץ מים — קומה 2" → הופיע מיד בגאנט-הקבלן מתויג 'הוצעה'. בנוסף: `analyze` 0 · `flutter test` +2509 ירוקים · `build web` · mutation RED→GREEN (על `approve`) · supervisor 15/15 · ביקורת-צי 7 ערוצים עובד↔קבלן (0 פערים).

---

## v6.20 — חיווט קבלן↔עובד · גל 0 (בלוק-המעסיק בטופס 101)

**שינוי (מקור-בלבד, ללא שינוי-layout):** `worker_forms_screen.dart` — בלוק '📄 פרטי המעסיק' בטופס 101 עבר ממקור `userProfileProvider` (פרופיל-המכשיר) ל-`employerProfileProvider(session.employerId)` (הקבלן-המקושר, גל 0). אותן שורות read-only, אותו widget; הדלתא הויזואלית היחידה: טקסט-הרמז (`!employer.isEmpty` → 'פרטי המעסיק נמשכים מהקבלן' · ריק → 'פרטי המעסיק יוחברו עם השרת') ושורות-הפירוט מוצגות רק כשיש ערך (`rows.isNotEmpty`). אין שינוי בפריסה/כפתורים/זרימה — ההצהרה+חתימה+שליחה+PDF זהים.

**אימות:** `worker_forms_v2_widget_test.dart` מעלה את כרטיס-101 ומאשר שטקסט-ההצהרה + מקטע-החתימה (✍️) + ה-send-gate מרונדרים אחרי החיווט (ירוק) — מכסה את המקרה הריק (employerId='' → רמז 'יוחברו עם השרת'). המקרה-המקושר source-equivalent (אותו עץ-widget מוזן ב-`EmployerProfile` שנפתר; ה-resolver עצמו נעול ב-`employer_link_test`). analyze 0 · אין רכיב/פריסה חדשים → אין צורך ב-screenshot. (follow-up אפשרי: widget-test ל-render-מקושר.)

---

## v6.20 — חיווט קבלן↔עובד · גל T1 (איחוד מנוע-המשימות — מסכים)

**שינוי (מקור-בלבד, ללא שינוי-layout):** `worker_app_screen.dart` (מחיקת `_mirrorManagerDecisions` post-frame — לוגיקה פנימית, אפס שינוי-תצוגה), `worker_task_detail_sheet.dart` (השליחה חותמת `workerUid`/`employerId` — אותו UI בדיוק), `manager_dashboard_screen.dart` (קריאת approve/reject מצביעה למנוע-המאוחד — אותו בלוק 'אישורי עובדים', ללא שינוי-מבנה). אין שינוי בפריסה/כפתורים/זרימה — איחוד-מנוע מאחורי-הקלעים.

**אימות:** 6 טסטי-המשימות (כולל ה-WIDGET של "📸 שלח לאישור" של העובד + מקטע 'אישורי עובדים' של המנהל שמאשר חי) ירוקים אחרי האיחוד · analyze 0 · supervisor CLEAN · mutation RED→GREEN. כל 3 המסכים source-only (אותו עץ-widget) → אין דלתא ויזואלית.

---

## v6.20 — חיווט קבלן↔עובד · גל T2 (יצירת-משימה + אישור-קבלן ב-tasks_screen)

**שינוי (UI חדש בקבלן):** `tasks_screen.dart` (מסך-הקבלן, תצוגת-מנהל/קבלן) קיבל: ＋'משימה חדשה' → גיליון-יצירה RTL (שם/פירוט/שלבים/דדליין/בורר-עובד), ✏️ עריכה לכל כרטיס (תצוגת-קבלן בלבד), ומקטע 'אישורי עובדים (קבלן)' עם אשר/דחה. הרכיבים משתמשים בדפוסים קיימים (`_TaskSheet`/`_WorkerPick`/`_ApprovalCard`/`_PrimaryBtn`). תצוגת-העובד לא-נגעה.

**אימות:** התנהגות-המנוע (createTask→עובד-רואה-חי · editTask · assignTask · approve/reject + order-fold) נעולה ב-2 טסטים (`contractor_task_authoring_test` + `contractor_task_approval_test`) · analyze 0 · supervisor CLEAN (בדק חיווט-UI + scope) · mutation RED→GREEN. **חוסר-כיסוי מוכר (follow-up):** רינדור גיליון-היצירה עצמו לא נבדק ב-widget-test (רק התנהגות-המנוע + סקירת-מפקח) — widget-test לגיליון = follow-up.

---

## v6.20 — חיווט קבלן↔עובד · גל E1 (כפתור+גיליון מלאי-הקבלן בלוח-העובד)

**שינוי (UI חדש בעובד):** `worker_app_screen.dart` קיבל כפתור '📦 מלאי הקבלן' ב-_TasksTab (אחרי 'בדוק ציוד נדרש') → גיליון חדש `worker_employer_stock_sheet.dart` (RTL, רשימת-מלאי READ-ONLY: שם + 🏬מחסן/🏗️אתר, מצב-ריק כן 'הקבלן טרם שיתף מלאי'). אין edit/move (העובד read-only). דפוסים קיימים (DraggableScrollableSheet + grab-handle + ✕).

**אימות:** ה-provider (ריק→[] · projection+sort · id-agnostic · seed-אמיתי) נעול ב-4 טסטים (`employer_stock_test`) · worker_app רגרסיה ירוקה · analyze 0 · mutation RED→GREEN. **follow-up:** widget-test לרינדור הגיליון (ה-provider + wiring-הכפתור נבדקו/נסקרו).

---

## v6.20 — חיווט קבלן↔עובד · גל E2 (צ'יפ-זמינות ב-#112)

**שינוי (UI בעובד):** `worker_equipment_checklist_sheet.dart` — כל שורת-ציוד קיבלה צ'יפ-זמינות (🏬 מחסן / 🏗️ אתר / 'זמינות לא ידועה' אפור-מנוטרל) מ-`availabilityFor(label, employerStock)`. invariant ה'לא-קורא-מלאי' הופך ל-'קורא מלאי-מעסיק READ-ONLY'. אין edit (העובד read-only). `equipmentForTasks` byte-identical.

**אימות:** ה-join טהור נעול ב-16 טסטים (כולל 6 false-positive→unknown שהמפקח חשף) · #112 regression ירוק · analyze 0 · המפקח תפס פגם-יושר (contains גולמי→המצאה) שתוקן ל-token-aware. **follow-up:** רינדור-הצ'יפ ב-sheet לא ב-widget-test (ה-join הטהור + ה-regression כן); curated mapping-table = refinement.

---

## v6.20 — חיווט קבלן↔עובד · גל E3 (בקשת-חומר: גיליון-עובד + תיבת-קבלן)

**שינוי (UI דו-צדדי):** `worker_employer_stock_sheet.dart` — '🧱 בקש חומרים' (קלט-פריטים multiline + הערה) + 'הבקשות שלי' (סטטוס חי). `contractor_material_requests_sheet.dart` (חדש) — תיבת-קבלן '📥 בקשות חומר' (כפתור ב-stock_screen AppBar) עם קידום-סטטוס. דפוסים קיימים (modal RTL + ✕ + grabber). העובד read-only על מלאי (הבקשה ישות נפרדת).

**אימות:** 7 טסטי-מנוע (דו-כיווני · setStatus live · decline · terminal-guard · empty-drop · ids · scope) · analyze 0 · supervisor CLEAN. **follow-up:** רינדור הגיליונות לא ב-widget-test (המנוע + הזרימה הדו-כיוונית כן).

---

## v6.20 — חיווט קבלן↔עובד · גל H1 (אישור-חופשה אצל הקבלן)

**שינוי (UI):** `worker_forms_screen.dart` — copy 'לאישור המנהל'→'לאישור הקבלן' (כפתור-חופשה + toast). `contractor_hr_sheet.dart` (חדש) — מסך-קבלן לאישור/דחיית חופשות-עובד (שם + תאריכים + סיבה + chip-סטטוס, אשר/דחה). `tasks_screen.dart` — כפתור '👷 חופשות עובדים' (תצוגת-קבלן). דפוסים קיימים (modal RTL, _EntryButton, promptRejectReason). מקבילי — מסך-המנהל לא נגע.

**אימות:** 8 טסטי-מנוע (scope/approve/reject/newest-first/back-compat) · analyze 0 · supervisor CLEAN (פעמון-אחד, מקבילי, צ'אט→th-worker-contractor, מנהל byte-identical). **follow-up:** רינדור contractor_hr_sheet לא ב-widget-test (המנוע + הזרימה כן).

---

## v6.16 — fix-fleet · round-3 (ציד עמוק יותר: data/RTL/UX)

**שינוי:** סבב-3 עמוק (data-integrity · RTL · error-paths) תפס באגים שהסבבים הקודמים פספסו.
- **HIGH×2 (data):** מפתחות-קטגוריה ב-`lipskey_smart_data` לא תאמו ל-`categoryHe` → **52 מוצרים** איבדו אביזרים+שלבים + אריחים-מתים. תוקנו (`'אטמים ופקקים'` / `'מחסומים גלויים'`). guard: `lipskey_category_keys_test` (mutation-verified).
- **MED×2 (data):** 2 עלים ב-`catalog_tree` עם `lipskeyCategory` ללא-מוצרים נעלמו תחת פילטר-מערכת → ה-`lipskeyCategory` הוסר (ה-`smartKey` מניע).
- **MED:** image-placeholder — `productImage` קיבל `frameBuilder` ברירת-מחדל (grey-skeleton + fade-in, מכסה 15 call-sites).
- **התכנסות:** FX-RTL + arrow_back כבר תוקנו ע"י הקולגה (rebase).
- **נדחה:** lipskey mixed-string (cosmetic, data-field) · voice-indicator (feature) · 7 LOWs.

**אימות:** `lipskey_category_keys_test` + catalog/lipskey tests ירוקים · analyze 0 · mutation-verified · `central-verify` gate.

---

## v6.16 — fix-fleet · גל 12 (deep bug-hunt fixes + hardening)

**שינוי:** ציד-עמוק (5 עדשות סמנטיות/אינטגרציה — business-logic/RBAC · e2e-flow · edge-cases · dead-interactions · races) מצא באגים שהשערים הרגילים לא יכלו לתפוס (פיצ'רים שלא חוּוטו נכון · תפרים חוצי-פיצ'ר · races). תוקנו:
- **HIGH עגלה-לכל-פרויקט (עכשיו עובדת):** `_switch` לא העביר `outgoingCart` וזרק את ה-snapshot → תוקן + `SmartCartNotifier.loadSnapshot`.
- **HIGH חור-בידוד §2.5:** לינק "🔄 החלפת תפקיד" ב-ProfileScreen נגדר ל-`activePersona == null`.
- **MED בטיחות-אינסטלציה:** vacuum-breaker הורחב ל-`'ציוד גן'`.
- **MED איבוד-נתונים:** `saved_projects._persist` עטוף try/catch.
- **MED load-clobber (4 notifiers):** הוסף `_loaded`-guard ל-`store_stock`/`smart_project`/`saved_projects`/`card_projects` — סוגר spec-divergence. (ה-cross-engine mutator-guard נוסה ובוטל — חוסם פעולה סינכרונית; ה-mitigations הקיימים מספיקים.)
- **hardening:** `state_loaded_guard_test` — שער-מקור שאוכף `bool _loaded` על כל notifier מתמיד שדורס `set state` (12 guarded / 0 offenders).
- **HIGH site-של-הזמנה (נפתר):** החלטה = מנוע-הפרויקטים קנוני. צ׳קאאוט: `cartProjectProvider` ברירת-מחדל מ-`activeProjectProvider`, picker מ-`projectsProvider` + 'ללא פרויקט', add→engine, 2 reset-points→active; `storeProjectsProvider` הוסר. ה-site עוקב אחר הפרויקט-הפעיל. guard: `order_site_canonical_test` (5).

**אימות:** `deep_fix_regression_test` (3) + `state_loaded_guard_test` ירוקים · analyze 0 · `central-verify` gate.

---

## v6.16 — fix-fleet · גל 11 (server-ready 6/6 — סגירת finance + catalog pure-logic)

**שינוי (לא-ויזואלי — refactor, byte-identical):** סגירת התקרה-הארכיטקטונית מגל 10. הקריאות שנותרו ישבו בהקשרים ללא-`ref` (top-level functions / StatelessWidget), אז **accessor גלובלי Ref-free** מנתב אותן — בלי שינוי-חתימות, בלי להמיר מסך-מאומת ל-Consumer.
- **finance:** `financeRepo()` גלובלי (const) לנתוני-התקציב; `finance_hub_sheets` קורא דרכו (10 ערכים byte-identical). `activeRevenue` נשאר Ref-based.
- **catalog:** `catalogRepo()` גלובלי; הלוגיקה-הטהורה (category_division · system_division · pressure_drop · finder · departments · card_projects) קוראת דרכו. (חריג R8 כן: `kLipskeyCatalog` ב-pressure_drop — const נפרד.)
- **server-ready עכשיו 6/6:** orders · customers · catalog · site · stock · finance — כולם דרך repositories. swap-לשרת = החלפת-impl בלבד.

**אימות (refactor, אין שינוי ויזואלי):** mutation-verified · `central-verify` gate ירוק. ערכים זהים byte-for-byte.

---

## v6.16 — fix-fleet · גל 10 (server-ready: catalog/site/stock דרך repositories)

**שינוי (לא-ויזואלי — refactor פנימי, byte-identical):** הרחבת ה-server-ready seam ל-domains הנקיים שנותרו (גל 9 = orders/customers). 29/29 ה-hubs קוראים את אותם consts — עכשיו דרך ה-repos.
- **catalog:** `catalog_local` + רוּתּמו 21 reads (catalog_screen 19 + lipskey_products 2) דרך `catalogRepositoryProvider`.
- **site:** `site_local` + `kProjects` דרך `siteRepositoryProvider` (budget_screen + projects_engine, seed acyclic).
- **stock:** `stock_local` + `kStockDemo` דרך `stockRepositoryProvider` (11 פריטים).
- **תקרה ארכיטקטונית (R8 — לא נכפה):** מסכי finance/site-hub + pure-logic של catalog (category_division/pressure_drop/system_division) + finder/departments קוראים const בהקשרים ללא-`ref`. לרתום = להמיר מסך-מאומת ל-Consumer = סיכון-רגרסיה. ה-interfaces+impls עומדים. (`finance_local` הוסר — בלי צרכן בטוח.)

**אימות (refactor, אין שינוי ויזואלי):** mutation-verified · `central-verify` gate ירוק (analyze 0 · `flutter test` · build · conformance · required-tests). הערכים זהים byte-for-byte.
## B12 — באנר עומס-יתר במחלק משקף את הספירה האמיתית (#5) — 2026-06-08

**שינוי:** ה-BOM-sheet סימן עומס-יתר לפי `branchTargets.length` הגולמי. אחרי B7
(המנוע חוסם ל-מספר-היציאות ורושם את העודף כ-gap), עודכן: `branches` סופר רק
target אמיתי (≠ המחלק), והבאנר מבהיר כמה לא-חוברו.

**אימות ויזואלי חי (build web + דפדפן localhost:5556):**
- בניתי קו: מחלק 1" 2-יציאות (`76032202`) + 3 ברזי-קצה → עומס-יתר (3>2).
- ✅ הבאנר הציג: **"⚠️ 3 ענפים על מחלק 2-יציאות — 1 לא חוברו (חסר במחלק)"** —
  בדיוק הספירה הנכונה (3 ביקש, 2 יציאות, 3−2=1 עודף לא-חובר). צילום-מסך נשמר.
- העומס-יתר עצמו (cap + gaps) נעול ע"י `manifold_test` מקרה 10 (mutation-proved ב-B7).

---

## v6.16 — fix-fleet · גל 9 (T7 צ׳אט חוצה-פרסונות + server-ready + P1)

**שינוי:** 3 ה-tracks שנותרו, במקביל (קבצים disjoint), gate אחד מאומת.
- **T7 צ׳אט חוצה-פרסונות:** מנוע משותף מתמיד (`state/sys_chat.dart`, `bs.sys-chat.v1`) במקום ה-`const _kThreads` של הקבלן. הודעה מהחנות נראית אצל הקבלן ולהפך; כל פרסונה רואה **רק** את השיחות שלה (`threadsFor`). ה-UI נשמר verbatim (emoji/מצלמה/ארכיון/בוט). בידוד §2.5: פרסונה לא-קבלן = Scaffold **standalone** (בלי home_shell/role-picker, back→pop). חיווט 5 פרסונות (contractor/store/courier/worker/manager).
- **server-ready:** orders + customers מחווטים דרך ה-Repository (T6.2/T6.3, byte-identical); 4 האחרים נדחו (diffuse — R8).
- **P1:** 20 צבעים גולמיים → BsTokens (14 tokens חדשים, hex זהה, screenshot-identical).

**אימות (בדיקת-widget/unit, לקח #2):** `sys_chat_test` (חוצה-פרסונה + restart + בידוד) · `repositories_test` · `central-verify` gate ירוק (analyze 0 · `flutter test` · build · conformance · required-tests). צילומי צ׳אט-פרסונה יישלחו.

---

## v6.16 — fix-fleet · גל 8 (honesty-pass — מקטעי-הגדרות מתים)

**שינוי (חלק א׳ — מקטעים מתים):** 3 auditors (store/notif/chat settings) אימתו ב-bytes (grep) אילו toggles מתמידים אך **אין להם צרכן** באפליקציה. 13 מקטעים יצאו **מתים לחלוטין** — נראו כמו מתגים חיים עם badge-ספירה, ומיתעו את המשתמש. נוסף ל-`_SectionTile` דגל `underConstruction`: מציג subtitle כן — **"בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות"** ו**מסתיר את badge-הספירה** (additive — `children`/`_activeCount` לא נגעו). סומנו 13: store (התראות חנות · ספקים מועדפים · שירות ולוגיסטיקה) · notif (ערוצי קבלה · צליל ורטט · לפי תפקיד · סיכומים תקופתיים · פרטיות במסך נעול) · chat (מדיה ושמע · גיבוי וייצוא · שפה ותרגום · שיחות עסקיות · ארכיון וניקיון).

**שינוי (חלק ב׳ — full pass, מתגים מתים בתוך מקטעי MIXED):** 3 auditors מיפו את **29 המתגים המתים** שיושבים בתוך מקטעים מעורבים (store 17 · notif 8 · chat 4). כל אחד קיבל marker כן ברמת-השורה — **"בבנייה — עדיין לא משפיע"** (subtitle ב-`_SwitchRow`; הערה מתחת ל-label ב-`_RadioGroupRow`/`_InlineTextRow`/`_NumberRow`) ונשאר פונקציונלי (עדיין מתמיד). interface משותף `_Inert` גורם ל-`_activeCount` להחריג אותם — כך ש-badge הספירה בכל מקטע MIXED מציג עכשיו רק את המספר ה**חי** (למשל סוגי-התראות 9→4). מתגים חיים לא נגעו.

**אימות ויזואלי (בדיקת-widget, לקח #2):** `test/settings_honesty_test.dart` (6 בדיקות) — מוודא את ה-subtitle ברמת-המקטע ב-3 המסכים, ומרחיב מקטע MIXED בכל מסך כדי לוודא שה-marker ברמת-השורה מופיע. + `central-verify` gate — analyze 0 · `flutter test` · build · conformance · required-tests. צילומי-מסך נשלחו למשתמש.

---

## v6.16 — fix-fleet · גל 7 (הסרת ה-search-dial — ה-FAB-dial האחרון)

**שינוי:** ה-search-dial (ה-FAB-dial האחרון; menu + BS כבר הוסרו) **נמחק** — reachability-audit אישר ש-`OpenDial.search` לא נקבע ע"י שום פעולת-משתמש (אין search-FAB), וכל כליו חיים ב-`_SearchToolsRow` של הקטלוג (מחווט טוב יותר). נמחק `search_dial_widget.dart`; הוסרו `OpenDial`/`openDialProvider`/`SearchTool`/`searchToolProvider` + scrim + render (dial_state · home_shell · buttons). **אין יותר FAB-dial באפליקציה.** 0 הפניות נותרו (byte-verified).

**אימות:** `central-verify` gate — analyze 0 · `flutter test` · build · conformance 7/7 · required-tests.

---

## v6.16 — fix-fleet · גל 6 (deferred resolved + D3)

**שינוי:** סגירת ה"deferred" של גל 5 + D3.
- **autoStock→OOS חי:** `storeOosProvider` הועבר ל-`lib/state/store_stock.dart` (screens→state, בלי מעגל); עלה ה-autoStock מציג את המוצרים שאזלו (היה stub).
- **מחיקת-היסטוריית-צ׳אט:** `chatHistoryClearedProvider` מתמיד (light cleared-flag, R8) + confirm-dialog.
- **D3:** `settings_tree.dart` המת (~70 עלים, 0 צרכנים) **נמחק** + ניתוק 2 קטעי-harness.

**אימות:** `central-verify` gate — analyze 0 · `flutter test` · build · conformance 7/7 · required-tests.

---

## v6.16 — audit מלא + fix-fleet · גל 5 (נחיל 9×9: dead-code + wiring)

**שינוי:** audit-שלמות מלא (6 auditors סרקו את כל האפליקציה) → fix-fleet. האפליקציה נמצאה **מחווטת היטב ברובה**; הפערים מעטים.
- **נמחק dead-code:** `_MiniPill` (notif+chats) · קבועים-יתומים `kVoiceSamples`/`PlanItem`/`kPlanResult` ב-`ai_hub_logic` (+ ההצהרות בבדיקה).
- **חוּוט:** **רשימות-שמורות** בחנות (היו write-only → sheet שטוען-לסל/מוחק) · **אינדיקטור פיצול-משלוח** בכרטיס-שליח (🚚×N מ-`fulfillmentProvider.splitInto`).
- **validation תפסה:** `aiAlternatives()` **לא מת** (בדיקה חיה מפעילה אותו) → נשמר · השוואת-מחירים בחנות כבר-מנותבת (false-positive).
- **נדחה ביושר (R8 — לא לאלץ/להמציא):** autoStock→OOS (צריך העברת `storeOosProvider` ל-`lib/state/`) · מחיקת-היסטוריית-צ׳אט (צריך `chatHistoryProvider` — state מקומי היום).

**אימות:** `central-verify` gate — analyze 0 · `flutter test` · build web · conformance 7/7 · required-tests. byte-verify (grep) של כל ה-fixers.

---

## v6.16 — פירוק ה-dial · גל 4 (נחיל 9×9: הסרת BS-dial + ניקויים)

**שינוי:** ה-BS-dial (חוגת 5 הפרסונות הישנה) **נמחק** — לאחר **parity-audit של 4 פרסונות** (מנהל/חנות/שליח/עובד) שאישר שכל עלה מכוסה במסכים-המלאים (לרוב superset; חלק מעלי-החוגה היו placeholder 'בבנייה' toasts), על אותם engines. נמחקו `bs_dial_widget.dart` (~1670 שורות) + 4 בדיקות `bs_dial_manager_*`; נוקו `dial_state` (OpenDial.bs + 8 providers) / `home_shell` / `role_picker` / harness; 2 בדיקות stage-advance נכתבו-מחדש ל-**engine-direct** (כיסוי order-flow נשמר). ניקויים נוספים: הערות `menu_dial_widget` מיושנות, כותרת `הגדרות קטלוג`→`הגדרות`.

**אימות:** `central-verify` gate — analyze 0 · `flutter test` · build web · conformance 7/7 · required-tests. **0 הפניות-קוד ל-BS-dial** (byte-verified). ההסרה אומתה ע"י parity-audit *לפני* המחיקה (בקשת בעל-המוצר: "ווידוא מלא"); תמונת ה-BS-dial נשלחה לאישור לפני ההסרה.

---

## v6.16 — פירוק ה-dial · גל 3b (נחיל 9×9: מחיקת ה-menu-dial · cutover)

**שינוי:** ה-menu-dial (ה-FAB של 🏠/פרויקטים/הגדרות) **נמחק** — כל תוכנו חי נייטיב (⋮ קטלוג · פרופיל via שם · הגדרות-קטלוג מורחבות · בורר-חנות · גישה ב-4 דאשבורדים). נמחקו `menu_dial_widget.dart` + `menu_state.dart`; הוסרו ההמבורגר + render-הדיאל + dial-state (`OpenDial.menu`/`menuTabProvider`/`MenuTab`); נוקו harness (`tabs:menu` + `resetAllDials`); ה-reset הורחב (catalog+app+notif). BS-dial/search-dial נשארו (נפרד).

**אימות:** `central-verify` gate — analyze 0 · `flutter test` 1645 · build web · **conformance 7/7** · required-tests. **0 הפניות-קוד תלויות** (byte-verified ל-8 סמלי-דיאל; 9 הפניות שנותרו הן הערות בלבד). הדיאל פורק בלי לשבור קומפילציה או טסט.

---

## v6.16 — פירוק ה-dial · גל 3a (נחיל 9×9: הגדרות נייטיב + גישה לכל פרסונה)

**שינוי:** גל 3a (5 `fixer`-ים אמיתיים, edit-only) — לפי הכרעות בעל-המוצר:
- **`CatalogSettingsScreen` הורחב** (לא מסך חדש): שורת '👤 הפרופיל שלי' **תמיד-גלויה** → ProfileScreen (גישת-אורח/רישום); + ערכת-נושא · 4 התראות · שפה — פורט מהדיאל עם provider-split זהה (theme/lang→`appSettings` · notif→`notifSettings` · text/motion/contrast→`catalogSettings`), מחרוזות verbatim מ-`settings_tree`.
- **4 הדאשבורדים** (מנהל/חנות/שליח/עובד): 2 כפתורי-AppBar → 👤 פרופיל + ⚙️ הגדרות, **כל פרסונה בנפרד** (tooltips=Semantics, RTL).

**אימות:** `central-verify` gate — analyze 0 · `flutter test` 1645 · build web · **conformance 7/7** · required-tests present. byte-verify (grep) של 5 ה-fixers ✅. המסכים שהשתנו מכוסים ב-render smoke-tests (`robustness_test` מרנדר `CatalogSettingsScreen`; dashboard-tests מרנדרים את ה-AppBar).

---

## v6.16 — פירוק ה-dial · גל 2 (נחיל 9×9: כלי-בית מחוּוטים + a11y)

**שינוי:** גל 2 של נחיל ה-9×9 (audit 7 עדשות → validate → fix) — פירוק ה-dial אל משטחים נייטיב:
- **home_shell ⋮**: חוּוטו 3 כלי-הבית שהיו no-op מת — 🤖 בינה→`AIHubScreen.route()` · 📦 מלאי→`StockScreen.route()` · 📋 משימות→`openSiteHub()`. (תפיסה של 2 עדשות בלתי-תלויות [ניווט + edge-crash], מאומת בבייטים מול mis-narration של האדריכל — לקח-הנחיל בפעולה.)
- **text-parity**: '🤖 בינה מלאכותית' → 'בינה מלאכותית ואוטומציה' (verbatim מ-`menu_trees.dart`).
- **a11y-rtl** (עדשת accessibility-rtl): צ׳יפ-השם — 48dp + `Semantics(button,'הפרופיל שלי')` + Tooltip; `profile_screen` — chevron→`mutedLight` · `_LinkRow` button-role + ExcludeSemantics · textAlign/textDirection ל-inputs · ChoiceChip showCheckmark.

**אימות:** `central-verify` gate — analyze 0 · `flutter test` 1645 · build web · **conformance 7/7 BYTES VERIFIED** (כולל תיקון drift: חוק 'הסל שלי' עודכן menu_trees→store_screen — המחרוזת חיה בחנות ×3). byte-verify (grep) של שני ה-fixers ✅.

---

## v6.16 — איחוד משטחים כפולים (consolidate duplicate contractor surfaces)

**שינוי:** איחוד משטחים כפולים שהתגלו ב-wiring audit:
- **AI-hub** (`ai_hub_screen.dart`): עלי '💡 חלופות זולות' / '📐 סריקת תוכניות' פתחו
  *מסכים מלאים כפולים* (`_Alternatives`/`_PlanScan`) שכפלו את גיליונות-המודאל הקנוניים
  (R9, `contractor_tools_sheets.dart`). הוסבו לפתוח את הגיליון הקנוני; 155 שורות
  קוד-כפול נמחקו + `ScanMenuScreen` הכפול נמחק.
- **Store** (`store_screen.dart`): action '💰 כספים' ב-quick-actions → `openFinanceHub`.
- **menu-dial**: טאב 'רכש' הוסר (Store מכסה סל/הזמנות/שירותים 100%).

**אימות ויזואלי:**
- ✅ **screenshot אמיתי** (נשלח למשתמש): האפליקציה המרופקטרת עולה ומרנדרת נקי — מסך
  הכניסה/רישום (BuildSmart logo · 'כניסה ללקוח קיים' · 'רישום ראשוני' · RTL · fonts ·
  canvaskit מקומי) ללא קריסה/מסך-ריק. `build web --release --no-web-resources-cdn` ✓.
  (Flutter-web מצייר ל-canvas → אין DOM ל-click; משטחי-הפנים מאומתים ב-render-test.)
- ✅ **render-test** `test/ai_hub_dedup_test.dart` (חדש): pump `AIHubScreen` → הגריד שלם
  (2 העלים נוכחים) → tap '💡 חלופות זולות' → **הגיליון הקנוני נפתח** ומרנדר שורות-חיסכון
  (`חיסכון ₪…`), `takeException()==null`. מוכיח גיליון-מודאל (לא מסך-דחוף) ונועל את ה-dedup.
- ✅ store '💰 כספים' / הסרת 'רכש': data+wiring — reuse של ה-chip הקיים ושל `openFinanceHub`
  שכבר באפליקציה (אפס widget חדש בעל סיכון-ויזואלי), מכוסים ב-suite הירוק.
- ✅ analyze 0 · `flutter test` ירוק (1642 + render-guard חדש) · build web ✓ ·
  mutation_verify (היפוך sort-החלופות → אדום ✅, שוחזר → ירוק) ב-`mutation_log.md`.
## P3.9 — בלוק שיפוע-ניקוז בקו ניקוז (install_studio BOM sheet) — 2026-06-07

**שינוי:** בלוק הלחץ של אספקה ("עלייה אנכית / ירידת לחץ") סונן ל-`lineIsSupply`
בלבד; קו ניקוז מקבל במקומו בלוק שיפוע (סליידרים אורך-אופקי + מפל-אנכי →
`checkDrainageSlope` → "שיפוע ניקוז X% + פסק ת"י 1205").

**אימות ויזואלי חי (build web + דפדפן localhost:5556):**
- בניתי קו ניקוז (סיפון 218553 → צינור 116180 → סיפון 217861, כולם DN32),
  פתחתי "צור רשימת קנייה" → "התקנה שלמה".
- ✅ הבלוק החדש מופיע: "שיפוע ניקוז: 2.0%" · "מינ׳ 2% · ת"י 1205" · סליידר
  "אורך אופקי 3.0 מ׳" · סליידר "מפל אנכי 6 ס"מ" · פסק "תקין (≥2% ת"י 1205)" ירוק.
- ✅ ריאקטיבי — הזזת סליידר שינתה 2.0%→4.6% בזמן-אמת.
- ✅ בלוק-הלחץ של אספקה **לא** מופיע על קו ניקוז (הסינון עובד).
- צילומי-מסך נשמרו במהלך ההדגמה.

> הערה כנה (לקח מהמשתמש): קו ה-סיפון→צינור→סיפון ששימש להדגמה הוא בעצמו לא-תקין
> פיזיקלית (double-trap) — המנוע אישר אותו על גאומטריה. זו בעיית-נכונות נפרדת
> שנפתחה לאודיט (לא קשורה לבלוק השיפוע עצמו, שתקין).

---

## v6.11 — 100% PDF-parity coverage לכל 3 המותגים (gate 117 closeout)

**שינוי:** הרחבת ה-parity tests של פולירול וחוליות מ-20+13 מדגם ל-**snapshot מלא**
(774 + 170 = 944 SKUs). ה-snapshot נוצר מ-runtime dump של `kPolyrollCatalog`/
`kHuliotCatalog` כך שכל מק"ט נכלל אוטומטית. הסקירה הוויזואלית על 13 עמודים-מדגם
(8 פולירול + 5 חוליות) הראתה 97/97 התאמה ל-PDF — ה-snapshot נועל את המצב הזה.

**ארבעת הטסטים בכל parity:**
1. snapshot SKUs קיימים ב-catalog.
2. catalog SKUs כולם ב-snapshot (תופס "תוספות שקטות").
3. nameHe + page תואמים.
4. brand נכון לכל מוצר.

**אימות:**
- ✅ `flutter test` — 1435/1435 (אפס regressions).
- ✅ `flutter analyze` — 0 errors.
- ✅ mutation_verify: typo בשם → "snapshot drift (1)" אדום ✅; ביטול → ירוק ✅.

---

## v6.10 — PDF-parity tests for Polyroll + Huliot (gate 117 closeout)

**שינוי:** טסטים חדשים שאוכפים שהדאטה של פולירול וחוליות תואמת לקטלוגים המקוריים
(תמונות-עמוד שכבר ברפו). 20 SKUs פולירול + 13 SKUs חוליות מ-עמודי-מדגם.
לא נדרשו תיקוני-דאטה — הסקירה הראתה 44/44 התאמה ל-PDF.

**אימות:**
- ✅ `polyroll_pdf_parity_test` — 20/20 (עמ' 18, 40).
- ✅ `huliot_pdf_parity_test` — 13/13 (עמ' 12, 28).
- ✅ mutation_verify לשני המותגים: typo → אדום ✅; ביטול → ירוק ✅.
- ✅ `flutter test` — 1460/1460 ירוקים.

---

## v6.09 — Lipski UI parity with Polyroll/Huliot (gate 117 follow-up)

**שינוי:** רנדור כרטיסי ליפסקי עבר מ-`_NameWords` ל-`_HierarchyChips` (ברירת-מחדל
מובנית כמו פולירול/חוליות). `parseChips` הורחב לתמוך-compound-types (`מיכל הדחה`,
`מושב אסלה`) + dictionaries עשירים יותר ל-Lipski (דגמי-מותג, תכונות, מס. 1-9,
ציר, סגירה רכה, אנטי ונדליזם, DN-prefix sizing).

**אימות:**
- ✅ `test/lipskey_hierarchy_parity_test.dart` (חדש) — 18/18, מוודא breadcrumb
  על 18 SKUs מ-9 הקטגוריות.
- ✅ `test/product_journey_test.dart · HARD · all 935 sheets` — אפס overflow
  (וידוא ש-_HierarchyChips לא גולש למסכים-צרים אחרי שהוא מקבל גם את כל הלקוחות הליפסקיים).
- ✅ `flutter test` — 1418/1418 ירוקים (אפס regressions בפולירול/חוליות).
- ✅ `flutter analyze` — 0 errors.
- 📷 רנדור-בדפדפן ידני לא בוצע (CanvasKit screenshots לא-אמינים פה, לפי תקדים v5.92/v6.04);
  HARD widget test מרנדר את כל 935 הכרטיסים תחת גדלי-טקסט+רוחב-מסך קיצוניים.

---

## v6.08 — Lipski floor traps parity to PDF (gate 117 · קטגוריה 9/9 — **המסע הושלם**)

**שינוי:** 8 SKUs (עמ' 26–27): 4 `מחסום תיקני 140/50 / 245/50` (פתוח/סגור/גבוה),
4 `מחסום (תופי-)קומקום 40/155 / 50/175` (פתוח/סגור למקלחת). שמות תוקנו (תופי-,
גבוה), qty הושלם ל-2 רשומות null, דפים 14 → 26/27.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 277/277.
- ✅ `flutter analyze` — 0 errors.
- ✅ `flutter test` — 1400/1400 ירוקים.

**סיכום מסע 9/9:** 274 SKUs של ליפסקי סונכרנו ל-PDF המקורי 2024 (ראה STATUS.md).

---

## v6.07 — Lipski pipes parity to PDF (gate 117 · קטגוריה 8/9)

**שינוי:** 57 SKUs (עמ' 47–48): צינורות אפור/שחור (DN40/50/75/110), כתום PP-MD-ML
SN4/SN8, שחור SUPER BETON/SILENT. 13 stubs אוחדו ל-real entries, שמות אוחדו
ל-`'צינור {color} DN{N} L={L} ס"מ'`, dims הושלמו, דפים 24/25→47/48.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 269/269.
- ✅ `flutter analyze` — 0 errors.
- ✅ `flutter test` — 1392/1392 ירוקים.

---

## v6.06 — Lipski screw-on accessories parity to PDF (gate 117 · קטגוריה 7/9)

**שינוי:** 43 SKUs (עמ' 20–23) — אביזרי תבריג: ברכים תבריג (90°/45°/30°/15°/טלסקופית),
מסעפי-תבריג, מחברים, מצרות, מפתחות. שמות אוחדו ל-`'ברך {זווית}° תבריג {sub} {D1/D2}'`,
DN+qty הושלמו. 116589 נוסף (חסר היה לחלוטין) + spec ב-verified_connections.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 212/212.
- ✅ `flutter analyze` — 0 errors.
- ✅ `compat_coverage` — 100% (116589 קיבל spec).
- ✅ `flutter test` — 1328/1328 ירוקים.

---

## v6.05 — T9: מסכי-פרסונה מלאים 🏪 חנות + 🛵 שליח [בנצי]

**שינוי:** הושלם הנותר ב-T9 — פרסונת **חנות** (`StoreDashboardScreen`) ו**שליח**
(`CourierDashboardScreen`) כמסכים-מלאים בסגנון האפליקציה (לא דיאל — אישור-משתמש,
כמו עובד). חנות = 4 טאבים (בית/הזמנות/מלאי/פורטל); שליח = בורר-רכב + בית +
רשימת-משלוחים + פורטל (6 אריחים). נוסף **מנוע-הזמנות משותף** `sysOrdersProvider`
(6 שלבים): קידום חנות `new→preparing→ready` + שליח `ready→pickup→transit→delivered`
מסונכרן בין שני המסכים. תוכן verbatim מ-`supplier_data.dart` (proto 06 §1/§7, R8).
`role_picker_sheet` מנתב חנות/שליח ל-`Navigator.push`.

**אימות:**
- ✅ `t9_supplier_personas_test` — 9/9 (seed verbatim · מנוע store↔courier · vehicle-gating · רינדור שני המסכים · אפס "בבנייה").
- ✅ `flutter analyze` (6 קבצים) — 0 errors (רק info-לינטים, תואם `persona_data`).
- 🔜 אימות-ויזואלי חי (Chrome, על gh-pages) — לאחר הדיפלוי (לקח v6.04: visual-verify חי, לא רק test).

---

## v6.05 — T3 · catalog ⋮ "סרוק תוכנית" scan flow [מקבץ]

**שינוי:** ה-⋮ בקטלוג, "סרוק תוכנית עבודה" — `_ScanPlanSheet` מ-stub ('בבנייה') ל-**זרימה מלאה**
(ConsumerStatefulWidget, ללא route חדש): בורר 4 plan-types (`kPlanTypes`, proto §9) → אנימציית-סריקה
(steps verbatim) → תוצאות (zones + ודאות% + השוואת-חנויות per פריט, הזול מסומן) → "אשר הכל — הוסף לסל".

**אימות:**
- ✅ `flutter test test/scan_plan_test.dart` — ירוק (4 types active · כל line=הזול · qty 1 · אסלה→אבן קיסר 740).
- ✅ `flutter analyze` (קבצים חדשים) — אפס issues.
- ✅ 📷 **רנדור-בדפדפן חי** (Chrome · `localhost:5556` · build/web v6.05 · 4.6.2026) — הזרימה המלאה צולמה:
  - בורר: 4 סוגים (אינסטלציה 🚿 · חשמל ⚡ · אדריכלות 🏛️ · גמר 🎨) עם sub-labels.
  - תוצאות אינסטלציה: "✓ זוהו 4 נקודות אינסטלציה · 6 פריטים · הזול ₪1557"; 4 zones עם ודאות% (98/95/92/**81 כתום** כי <88); כל פריט עם 3 חנויות, הזול מסומן ✓ (אסלה→אבן קיסר 740 · מקלחת→טמבור הום 520).
  - "אשר הכל — הוסף 6 פריטים לסל" → **6 פריטים נוספו לסל** (טאב חנות/הסל · 7 בסל · toast "6 פריטים מהתוכנית נוספו לסל"). add-to-cart עובד E2E.

---

## P-3 — typography tokenization (ליטוש · zero-visual)
**שינוי:** font-size literals → `BsTokens.fontXs/Sm/Md/Lg` ב-`toast.dart` (14) +
`chain_diagram.dart` (9/22/8). **ערכי-הטוקנים זהים ל-literals המקוריים** (14==14 וכו') →
**אפס שינוי-render** (token-binding). `chain_diagram` קיבל `import theme/tokens.dart`.
**אימות:** `analyze` 0 errors · 0 magic-fontSize נותרו בקבצים · token-equal מבטיח
זהות-פיקסל (כתקדים v5.92/#1/#3/#4 — שינוי דטרמיניסטי נשען על token-equal, לא screenshot).

---

## P-1 wave-1 — color tokenization בארבעת מסכי-ה-settings (ליטוש · zero-visual)
**שינוי:** 44 text-colors קשיחים → טוקנים ב-`catalog/notif/chat/store_settings_screen`:
`Color(0xFF1A1A1A)` → `BsTokens.inkLight` (39×) · `Color(0xFF666666)` → `BsTokens.mutedLight` (5×).
**ערכי-הטוקנים זהים** (0xFF1A1A1A==inkLight וכו') → **אפס שינוי-render** (token-binding).
רק text-colors חד-משמעיים נכבלו; surface-לבן/bg/צללים/accents → הצעות ב-POLISH_LOG (לא הומצא ערך).
**אימות:** `analyze` 0 errors · 0 literals של שני ה-hexes נותרו בקבצים · token-equal = זהות-פיקסל.

---

## v6.05 — Lipski gaskets/plugs parity to PDF (gate 117 · קטגוריה 6/9)

**שינוי:** 17 SKUs (עמ' 36–37) — אטמים/אומים/פקקים. תסבוכת SKU תוקנה: 506525
("אטם דו צדדי" → אטם לכוס 2"), 610708 ("אטם לכוס" → פקק שטוח 2⅜"), 610706
phantom נמחק (+ ref ב-verified_connections). 614783 1/2"→1½", qty 506540 750→500,
דפים 19→36/37.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 169/169.
- ✅ `flutter analyze` (catalog + verified_connections) — 0 errors.
- ✅ `catalog_regression`/`compat_coverage` — GREEN (610706 לא יתום אחרי הסרה).
- ✅ `flutter test` — אפס regressions.

**תיקון נלווה (`store_screen.dart` · `_OrderSheet`):** טסט `store_notif_widget_test`
נכשל על baseline (לא קשור לקטלוג — overflow 3.6px). תוקן ע"י עטיפת ה-Column
ב-`SingleChildScrollView` — משלים את תיקון ה-`isScrollControlled` (v6.04 בנצי):
ה-modal מתרחב לגובה-התוכן **וגם** התוכן עצמו גולל. הטסט ירוק, `analyze` 0 errors.

---

## v6.04 — fix(T5): order sheet isScrollControlled (כפתור תעודת-משלוח היה חתוך) [בנצי]

**באג שנתפס ב-QA-חי (snapshot v6.04, Chrome, 4.6.2026):** ה-order sheet
(`showModalBottomSheet` ב-`store_screen` ~2756) היה **ללא** `isScrollControlled` → גובה-קבוע →
הכפתור "סרוק תעודת-משלוח" (T5, אחרי ה-timeline) **נחתך מתחת לקצה, בלתי-נגיש** (הגיליון לא נגלל,
וגרירה סגרה אותו). ה-widget-test עבר כי רינדר מסך-מלא — ה-modal האמיתי חתך. **לקח: visual-verify חי, לא רק test.**

**תיקון:** הוספת `isScrollControlled: true` ל-showModalBottomSheet של ההזמנה — התאמה לגיליונות
העובדים (`store_screen` 1734/2158) → הגיליון מתרחב לגובה-התוכן → הכפתור נגיש.

**אימות:** ✅ `flutter build web --release` — `√ Built` (מתקמפל). הבאג אומת חי (before-screenshot
מ-snapshot v6.04). התיקון = דפוס-מוכח בקוד. (re-verify ויזואלי סופי לא הושלם — קונפליקטי פורט/cache בסביבה; הדפוס ודאי.)

---

## v6.04 — T2 · catalog ⋮ "השוואת מחירים" sheet [מקבץ]

**שינוי:** ה-⋮ בקטלוג, פעולת "השוואת מחירים" — מ-toast "בבנייה" ל-**sheet inline**
(`_StorePriceComparisonSheet`, ללא view/route חדש): לכל מוצר 3 מחירי-חנויות מ-`kPlanTypes`
(proto §9b verbatim), הזול מסומן (`bestStore`) בכתום + ✓.

**אימות:**
- ✅ `flutter test test/store_price_comparison_test.dart` — ירוק (≥3 מוצרים · כל ≥3 חנויות · best==הזול · מחירי §9b verbatim).
- ✅ `flutter analyze` (קבצים חדשים) — אפס issues.
- ✅ 📷 **רנדור-בדפדפן חי** (Chrome · `localhost:5556` · build/web v6.04 · 4.6.2026):
  - sheet "📊 השוואת מחירים" נפתח מ-⋮ ומרונדר השוואה אמיתית פר-מוצר, הזול בכתום+✓:
    אסלה תלויה (אבן קיסר ₪740✓ · 789/765) · סוללת מקלחת (טמבור הום ₪520✓ · 560/538) · ברז אמבטיה (אבן קיסר ₪189✓) · לוח חשמל (אבן קיסר ₪389✓) ועוד.
  - הזול משתנה פר-מוצר (לא קבוע) → `bestStore` אמיתי. footer §9b verbatim. אפס overflow.

---

## v6.04 — T1 · catalog ⋮ "חלופות זולות" sheet [מקבץ]

**שינוי:** ה-⋮ בקטלוג, פעולת "חלופות זולות" — מ-toast "בבנייה" ל-**sheet inline**
(`_CheaperAlternativesSheet`, ללא view/route חדש): לכל מוצר חלופת-מותג זולה יותר
מ-`kHomeProductBrands` (proto §1b), ממוין לפי חיסכון.

**אימות:**
- ✅ `flutter test test/cheaper_alternatives_test.dart` — ירוק (≥3 חלופות · כל altPrice<recPrice · ממוין; filter mutation-verified: `<`→`>` נתפס אדום).
- ✅ 📷 **רנדור-בדפדפן חי** (Chrome · `localhost:5556` · build/web release · 4.6.2026):
  - sheet "💡 חלופות זולות" נפתח מ-⋮ ומרונדר 3 שורות אמיתיות:
    אסלה תלויה ₪740→₪560 (חיסכון 180) · סוללת מקלחת ₪520→₪380 (140) · ברז לכיור ₪189→₪139 (50).
  - chip-חיסכון כתום + footer "בפרודקשן: השוואת-מחירים חיה מול מחירוני הספקים". אפס overflow.

---

## v6.04 — Lipski collectors/covers parity to PDF (gate 117 · קטגוריה 5/9)

**שינוי:** 19 SKUs (עמ' 30–33) — מאספים/קולטים + כיסויים/רשתות. באגי-צבע תוקנו
(661360 לבן→אפור, 610920 פרגמון→אפור, 610911/635736 null→לבן/פרגמון), 196687
DN 130/40→130/50, דפים 16/17→30-33, qty הושלם.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 151/151.
- ✅ `flutter analyze lib/data/lipskey_catalog.dart` — 0 errors.
- ✅ `flutter test` — אפס regressions.

---

## v6.03 — Lipski connectors/reducers/plugs parity to PDF (gate 117 · קטגוריה 4c/9)

**שינוי:** 21 SKUs (עמ' 44–45) — מצמדים/מצרות/פקקים/כובע אויר. 17 שמות שגויים
תוקנו (re-read מהמקור): 120311 היה "פקק להכנסה" → כובע אויר 110; מצרות תויגו
"מחבר כפול"; פקקים תויגו "צינור הכנסה". DN+qty+page הושלמו. categoryHe לא שונה.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 132/132.
- ✅ `flutter analyze lib/data/lipskey_catalog.dart` — 0 errors.
- ✅ `flutter test` — אפס regressions.

---

## v6.02 — T5 · תעודת-משלוח (OCR→toast) בגיליון-הזמנה [בנצי]

**שינוי:** `_OrderSheet` (`store_screen`) — נוסף כפתור "📄 סרוק תעודת-משלוח" → toast
(OCR=stub לפי §9d + R-rule camera/OCR→toast). מעקב-הסטטוס (`_OrderTimeline` · 4 stages ·
`liveOrdersProvider`) כבר היה בנוי → זה משלים את DoD T5 ("סטטוס מוצג · OCR=toast").

**אימות:**
- ✅ `flutter analyze` (`store_screen`) — 0 errors (ב-commit-hook).
- ✅ UI דטרמיניסטי (`OutlinedButton`→`showToast`, ללא layout-risk) — לפי תקדים v5.92/v5.96
  (CanvasKit screenshots לא-אמינים → נשען על analyze + תוספת-מינימלית).

---

## v6.02 — Lipski insertion-branch parity to PDF (gate 117 · קטגוריה 4b/9)

**שינוי:** 13 SKUs של מסעפים שקע-תקע (עמ' 42): שמות תוקנו (היו "מחבר כפול"/
"מסעף 90° - תבריג"/"45° - תבריג כפול" → "מסעף {45°|87°|כפול} {DN}"), DN+qty
הושלמו ל-5 רשומות, דפים 22 → 42.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 111/111.
- ✅ `flutter analyze lib/data/lipskey_catalog.dart` — 0 errors (וידוא ש-dims insert תקין).
- ✅ `flutter test` — אפס regressions.

---

## v6.01 — Lipski insertion-bend parity to PDF (gate 117 · קטגוריה 4a/9)

**שינוי:** 15 SKUs של ברכיים שקע-תקע (עמ' 40–41): כל השמות תוקנו (היו זווית שגויה +
"תבריג כפול" שגוי — בעצם שקע-תקע). דפים תוקנו 21 → 41.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 98/98 (24+27+32+15).
- ✅ `flutter test` — אפס regressions.

---

## v6.00 — T6 · sheets לפעולות התראה בטיחות+תקציב [בנצי]

**שינוי:** ה-action-button בהתראות בטיחות/תקציב (`notifications_screen`) — מ-toast
"בבנייה" ל-**sheet inline** (R9, `showNotifActionSheet`, ללא view/route חדש):
- 🦺 safety → "תדריך בטיחות יומי" = `kSafetyTips`×5 + כפתור "אשר תדריך".
- 💰 budget → "התראת תקציב" = status + `kBudgetThresholds` (80/90/100%).
- צורך seeds מ-T0 (`contractor_seeds.dart`) — אפס כפילות.

**אימות:**
- ✅ `flutter analyze` (notifications_screen + test) — 0 errors (5 info/warn קיימים-מראש).
- ✅ `test/t6_notif_action_test.dart` — 2 ירוקות.
- ✅ 📷 **רנדור-בדפדפן חי** (Chrome · localhost:5556 · build/web release, 4.6.2026):
  מסך-בית (4 קטגוריות · 143 מוצרים · 4 טאבים) · sheet בטיחות (5 טיפים + אישור) · sheet תקציב (80/90/100% + status) — הכל נקי.

---

## v6.00 — Lipski visible-trap parity to PDF (gate 117 · קטגוריה 3/9)

**שינוי:** סנכרון `kLipskeyCatalog` ל-32 SKUs של מחסומים גלויים (עמ' 8–15):
- דפים תוקנו (היו 5/6/7/8 → 8/10/12/14, לפי הקטלוג המודפס).
- שמות תוקנו ב-213054 (היה duplicate של 213055 עם "אמריקאי") ו-218495
  (היה duplicate של 171189 עם "עם יציאה למדיח").

**אימות:**
- ✅ `test/lipskey_pdf_parity_test.dart` — 83/83 (24 מיכלים + 27 מושבים + 32 מחסומים).
- ✅ `test/product_journey_test.dart · HARD` — אפס overflow.
- ✅ `flutter test` — כל הסיוט ירוק.

---

## v5.99 — Lipski toilet-seat parity to PDF (gate 117 · קטגוריה 2/9)

**שינוי:** סנכרון `kLipskeyCatalog` ל-26 SKUs של מושבי אסלה מהקטלוג (עמ' 53–55):
- 20 רשומות `nameHe` גנרי תוקנו לשמות-מודל מפורשים (`מס. 1`, `מס. 4 ציר פלסטיק/ניירוסטה`,
  `מס. 9 ציר ניירוסטה אנטי ונדליזם`, `חרמון`, `אדיר`, `תבור סגירה רכה`,
  `כרמל סגירה רכה`, `הגייני אנטי ונדליזם ציר ניירוסטה`, `טרמו ULTRA`).
- 4 phantom SKUs נמחקו (179370/197134/195425/107222) + 5 stub placeholders אוחדו.
- `smart_tree.dart` עודכן (195425→195505, 197134→187134).

**אימות:**
- ✅ `test/lipskey_pdf_parity_test.dart` (gate 117) — 51/51 (24 מיכלים + 27 מושבים).
- ✅ `test/product_journey_test.dart · HARD · all 935 sheets` — אפס overflow על מסכים-צרים+טקסט-מוגדל.
- ✅ `test/catalog_regression_test.dart · אין קישור-SmartProduct יתום` — GREEN.
- ✅ `test/catalog_spec_coverage_test.dart` — מושבי אסלה לא ב-non-exempt.
- ✅ `flutter test` — 1149/1149 ירוקים.

---

## v5.96 — Lipski toilet-tank parity to PDF (gate 117 · קטגוריה 1/9)

**שינוי:** סנכרון `kLipskeyCatalog` למיכלי הדחה לפי קטלוג ה-PDF המקורי (עמ' 50–52):
- 17 רשומות שתויקו שגוי (152785-152787 / 145629-145631 / 168525-169604 / 178864-178870 כ-"מושבי אסלה"; 116795/116798/154069/154413 כ-`nameHe: 'התקנה נמוכה/צמודה'`) → כל אחת קיבלה `nameHe` מפורש מהקטלוג (`מיכל הדחה ברקת לבן`, `מיכל הדחה כנרת מונובלוק לבן` וכו'), `categoryHe` נכון, `page` נכון (היה 26/27, אמור להיות 50/51/52), `dims` עם תכולה+גובה+רוחב+עומק (שדות נפרדים — manyHe אחיד עם תווית מהקטלוג).
- 8 phantom SKUs נמחקו (124040/124050/124051/170862/170866/170869/116752/154058 — לא קיימים ב-PDF). מופעים ב-`smart_tree.dart` ו-`lipskey_verified_connections.dart` עודכנו למק"טים האמיתיים.

**אימות (HARD test = visual-render אוטומטי):**
- ✅ `test/product_journey_test.dart · HARD · all 935 sheets render at large text + narrow phone` — 0 overflow (היה 75px overflow על 152785 לפני פיצול ה-dims לשדות-נפרדים).
- ✅ `test/lipskey_pdf_parity_test.dart` (gate 117, 24 expectations) — GREEN.
- ✅ `test/catalog_regression_test.dart · אין קישור-SmartProduct יתום` — GREEN (לאחר עדכון `smart_tree.dart`).
- ✅ `test/catalog_spec_coverage_test.dart` — `התקנה גבוהה` 6/6, `התקנה צמודה` 5/5 (היה 0/0 בקטגוריות החדשות).
- ✅ `flutter test` — **1114/1114 ירוקים**.
- 📷 רנדור-בדפדפן ידני לא בוצע (סביבה דרומה ללא Chromium); ה-HARD widget test רץ על כל 935 כרטיסים בגדלי-טקסט+רוחב-מסך קיצוניים והוא ה-gate הרגרסיבי.

---

## v5.92 — Version chrome decoupled (לקח #72, P0)
**שינוי:** תווית-הגרסה ב-AppBar (`home_shell.dart`) עברה ממחרוזת-קשיחה
(`v5.91 · 1.6.48 · 🚚 בנצי #4 — ...`) ל-`kVersionLabel` בלבד מ-`version.g.dart`.
- **לפני:** נקודה ירוקה + טקסט ירוק 10px עם changelog חופשי, 2 שורות ellipsis.
- **אחרי:** `kVersionLabel` בלבד (`v5.92`), אפור-secondary (`BsTokens.mutedLight`),
  שורה אחת, `Key('version_chrome')`. אין נקודה-ירוקה (שמורה ל-`_PulsingStatus`).

**אימות:**
- ✅ `flutter analyze lib/screens/home_shell.dart` — 0 errors (3 info pre-existing).
- ✅ `test/version_g_test.dart` — contract locked (kReleaseNote='' תמיד, label vX.Y).
- ✅ `flutter build web --release` — קומפילציה end-to-end.
- ⏳ **visual sign-off סופי (feel) — ליטוש**, לפי קונצנזוס (סוכן-UI הוא בעל ה-feel).
  הצורה דטרמיניסטית (Text widget פשוט); CanvasKit screenshots לא-אמינים →
  נשענים על widget-test, כהמלצת ליטוש/מקבץ.

---

## v5.93 — תפריט 4 טאבים + מיזוג עדכונים (בנצי #3)
**שינוי:** `home_shell` (IndexedStack + `_BottomNav`) + `updates_screen.dart` חדש +
`catalog_screen` (default section 'בית'→'הכל'). תפריט תחתון: 🏠 בית · ▦ מחלקות ·
🔔 עדכונים · 🛒 חנות. "עדכונים" = מיזוג התראות+שיחות עם מתג עליון.

**אימות ויזואלי (5 screenshots, נסקרו ונשלחו למשתמש לאישור):**
- ✅ טאב בית — חלון "הכל" של הקטלוג (overview קטגוריות, 'הכל' chip פעיל).
- ✅ טאב מחלקות — גריד 9 המחלקות (ללא שינוי, מיקום חדש).
- ✅ טאב עדכונים → התראות — המתג העליון [🔔 התראות · 💬 שיחות], מסך ההתראות מתחת.
- ✅ טאב עדכונים → שיחות — מתג מחליף ל-inbox השיחות (state נשמר ב-IndexedStack).
- ✅ טאב חנות — StoreScreen (ללא שינוי, מיקום חדש).
- ✅ `flutter analyze` lib — 0 errors · `flutter test` — 1084 ✅ · `build web` — ✓.
- bottom-nav עקבי בכל הטאבים; הסל = FAB צף (מוסתר ב-חנות).

---

## v5.94 — "לאן לשלוח" חלונית חד-פעמית בבחירת מוצר ראשונה (בנצי #4, תיקון)
**שינוי:** `store_screen` (הוסר `_ShipToRow` מה-checkout; `openShipToSheet` public +
`shipToPromptedProvider`) + `home_shell` (listener על `smartCartProvider`) + `main`.
החלונית עברה מ-checkout ל-auto-popup חד-פעמי בהוספת המוצר הראשון.

**אימות ויזואלי (screenshot, נסקר):**
- ✅ הוספת מוצר ראשון (cart 0→1) → חלונית "לאן לשלוח?" קופצת אוטומטית מלמטה,
  לא-מחייבת ("לא חובה — אפשר לאשר גם בלי כתובת"), שדה כתובת + דלג/שמירה.
- ✅ ה-checkout sheet כבר לא מכיל את שורת ה-ship-to.
- ✅ `flutter analyze` lib — 0 errors · `flutter test` — 1086 ✅ · `build web` — ✓.
- חד-פעמיות: `shipToPromptedProvider` נשמר (prefs) → לא קופץ שוב.

---

## v5.95 — Huliot chip picker (בורר) opens (T8 visual verify)
**שינוי:** התיקון של `_cycleHierarchy` + `findHierarchySiblings` שמפעיל את
הבורר הפאסטי למוצרי חוליות (היה מת — אחים ריקים).
- **אימות ויזואלי:** רונדר כרטיס `ברך 45° 32` (SKU 70033460) ב-widget-test
  → הקלקה על chip הצורה (`45°`) → צילום PNG.
  - **לפני התיקון:** הקלקה לא פתחה כלום (שורת-בורר ריקה).
  - **אחרי:** נפתחה שורת-בורר מתחת לכרטיס עם **6 pills של אחים** (45°/90° +
    מידות 32/40/50/63). screenshot: `knowledge/visual/v5.93_huliot_picker_open.png`.
  - הטקסט מרובע (אין פונט עברי ב-test env) אבל המבנה ודאי: pill כתום (גודל)
    + אפור (צורה) בכרטיס, שורת-בורר עם 6 pills מתחתיו.
- **אימות לוגי:** `huliot_picker_test` (4) — shape→{45°,90°}, size→{32,40,50,63},
  Huliot-only, Polyroll regression-guard. mutation_verify על brand-gate (red→green).

---

## v5.96 — חלוקת מים/שפכים: כלים מול צנרת (בנצי #1 reframed)
**שינוי:** `category_division.dart` + `_DeptCatGroups` ב-`departments_screen` —
ברזים/אינסטלציה עוברים מ-WaterSystem-filter לתצוגת כותרות+קטגוריות.

**אימות ויזואלי (screenshots, נסקרו):**
- ✅ **אינסטלציה** → כותרת קטנה **💧 צינורות מים** (PPR 774 · אביזרי קצה 143 ·
  גינון 21 · ברזי-מעבר 20 · ברזי-ניל 17 · מחלקים 11 · רב-שכבתי 9) + **🟤 צינורות
  שפכים** (ניקוז 481 · SmartLock 170 · מסעפי-אסלה 24), קטגוריות מתחת לכל כותרת.
- ✅ **ברזים וסניטריים** → **🚽 כלים לבנים** (אסלות 87) + **🛁 כלים גמר**
  (מקלחות 78 · אביזרים 18 · ברזי כיור/מטבח/קיר/אמבטיה/מקלחת/דלי · אביזרי-ברזים).
- ✅ פיצול דו-מערכתי: ברז-כיור תחת גמר, ברז-מעבר תחת מים. טאפ על קטגוריה → מוצרים.
- ✅ `flutter analyze` lib — 0 errors · `flutter test` — 1086 ✅ · `build web` — ✓.

### v5.97 — דו-מערכתיים בשתי הכותרות + החץ הוסר (`_CatGroupRow`)
- ✅ אומת בצילום: בסוף **💧 צינורות מים** מופיעים אטמים-ופקקים (18) · חבקי-תליה (25)
  · חבקי-צינור (14) · עוגנים-ובנדים (8) · סטי-הידוק (2) — ואותם 5 גם בסוף
  **🟤 צינורות שפכים**. (פריט שמתאים לשני סוגי הצנרת נגיש מכל כותרת.)
- ✅ **בנצי #2:** הוסר ה-chevron (`Icon(Icons.chevron_left)`) משורת-הקטגוריה;
  עיגול-הספירה (badge כתום) הוא עכשיו האלמנט האחרון — בקצה השורה (RTL-שמאל),
  במקום שבו היה החץ. אומת בצילום (`אינסטלציה`: 774/143/21/20/17/11/3/10/9 בקצה,
  ללא חץ). השורה עדיין לחיצה (`InkWell`) → drill לקטגוריה.
- ✅ analyze 0 errors · `category_division_test` 5 ✅ · `flutter test` ✅ · build ✓.

## T9 — אפליקציית-עובד (`WorkerAppScreen`) — סגנון זהה לאפליקציה, תוכן משתנה
**רקע:** הניסיון הראשון (תוכן-בתוך-הדיאל + toast מומצא) **נדחה ע"י המשתמש** ("סגנון
חדש — אני לא מסכים"). נבנה מחדש לפי בקשתו: **אותו שלד בנייה כמו האפליקציה הראשית
(4-טאבים ווצאפ), רק התוכן משתנה.** המקור (`bs-dial.tsx`) מראה את עלי-הדיאל כ-"בבנייה"
verbatim → הדיאל הוחזר ל-placeholder; "עובד" נפתח כעת כאפליקציית-תפקיד מלאה.

**אימות ויזואלי (screenshot אמיתי, נשלח למשתמש ואושר):**
- ✅ AppBar לבן (`🦺 עובד` מימין · `‹ יציאה` משמאל) — זהה לסגנון `home_shell`.
- ✅ בורר-עובד (רן/עובד · עומר/עובד) — pill כתום לנבחר.
- ✅ כרטיס-סיכום: `שלום, רן 👷` · `יש לך משימה פעילה` · badge `0/3` · progress-bar ·
  סטטיסטיקות `1 פעילה · 2 בתור · 0 הוגשו` (verbatim §4.2).
- ✅ 3 מקטעים עם **כרטיסי-משימה לבנים מעוגלים** (badge-סטטוס + שם + `🕒 N ימים · M שלבים`
  + הערה): 🔨 המשימה הנוכחית שלך (התקנת קו מים חם) · ⏳ הבאות בתור (2) · 📋 שהגשת (0).
- ✅ אפס "בבנייה", אפס דיאל, אפס פורמט-מומצא. R8 — כל מחרוזת/מספר מ-proto 06 §4.1/§4.2.
- ✅ analyze 0 · `worker_app_test` 4 ✅ (כולל widget-test: מרנדר כרטיסים, אין "בבנייה")
  · mutation-verified · `flutter test` מלא ✅ · build web ✓.

## W1 #1 — בועות-צ׳אט RTL (before→after) — 2026-06-08
- **before:** `Align(alignment: isMe ? Alignment.centerLeft : centerRight)` — **אבסולוטי**, לא מתהפך ל-RTL → הודעות-**עצמי משמאל** (הפוך מוואטסאפ העברי, מפר `sys_chat:37`); זנב חד בפינה הלא-נכונה.
- **after:** `chatBubbleAlignment(isMe:)` → `AlignmentDirectional.centerStart/End` → own **מימין**, other משמאל; `BorderRadiusDirectional` → הזנב בצד-הדובר; בועת-הקלדה (incoming) → משמאל.
- guard: `chat_bubble_side_test` (own→start · other→end · resolve-RTL x=±1) · mutation אדומה ✅ · analyze 0.

## teal→כתום (before→after · W0) — 2026-06-08
- **before:** מסכי 'אתר' (site_hub) ו'כספים' (finance) הציגו accent **טורקיז** (0xFF1F6F6B) במקום הכתום של המותג — ההערה ב-site_hub אף הצהירה "orange brand" אך הערך teal.
- **after:** `_kBrand`/`_kBrandDark`/`_kBrandTeal` → `BsTokens.brand`/`brandDark` → כל ה-FAB/כפתורים/accents באזורים האלה כתומים-מותג.
- guard: analyze/test/build · systemic ratchet-color (§3.5) ינעל teal-raw עתידי.

## microcopy (before→after · W0) — 2026-06-08
- **before:** `מנהל מערכת` (חסר ה׳) ב-RBAC/דשבורד-התראות · `AI`/`מבוססות AI` בהגדרות-קטלוג.
- **after:** `מנהל המערכת` (כמו persona canonical) · `בינה מלאכותית`/`מבוססות בינה מלאכותית`.
- guard: analyze/test/build · systemic string-consistency (§3.5).

## #+-עגלה כפול (before→after · W1) — 2026-06-08
- **before:** ב-list-card, `+` קרא `_addToCart`→`smartCart.add()`; אחרי גלילה (recycle) ה-row חוזר ל-`_open=false` בעוד המוצר בעגלה → tap נוסף = **שורה שנייה** לאותו מוצר.
- **after:** `_addToCart`→`setQtyForKey` (אידמפוטנטי) → tap-חוזר מעדכן את השורה, לא מכפיל.
- guard: `lipskey_plus_no_dup_test` (idempotency של setQtyForKey, 2).

## #perf — install_studio repaint-per-frame (before→after · W1) — 2026-06-08
- **before:** `AnimatedBuilder(builder: (_,__) => CustomPaint(painter, child: Column[header/canvas/dock]))` → כל המסך נבנה-מחדש 60fps.
- **after:** `child: Column[...]` (פעם-אחת) → `builder: (_,child) => RepaintBoundary(CustomPaint(painter, child: child))`. אפס שינוי-מראה; ה-rebuild-per-frame נעלם.
- guard: pattern ידוע + full test/build (אין unit — build-count דורש harness כבד).

## #weld-key — תזמון-ריתוך PPR (before→after · W1) — 2026-06-08
- **before:** `dn = product.dims['dn נומינלי']` → ל-supply/faser PPR (שנושאים `'קוטר חיצוני'`) = null → "תוכנית ריתוך-שקע" ריקה לרוב ה-PPR.
- **after:** `pprWeldDn(dims)` = `dn נומינלי ?? קוטר חיצוני` → התזמון (עומק/חימום/קירור) מופיע.
- guard: `ppr_weld_dn_test` (4) · mutation (הסרת fallback → אדום).

## #₪-truncation — עגלה-שמורה (before→after · W1) — 2026-06-08
- **before:** טעינת רשימה-שמורה: `brandPrice = total ~/ qty` → שורה של ₪340 בכמות 3 נטענת כ-₪339 (איבוד עד qty-1 ₪).
- **after:** `savedLineReconstruct` שומר total מדויק → ₪340 נשאר ₪340.
- guard: `saved_line_reconstruct_test` (4 · sweep total==brandPrice×qty) · mutation (revert→אדום).

## #camera — מסך-שחור→הודעה (before→after · W1) — 2026-06-08
- **before:** הרשאת-מצלמה נדחית → MobileScanner מציג **מסך-שחור ריק** (המשתמש תקוע).
- **after:** `errorBuilder` → `cameraPermissionErrorView`: "לא ניתן לגשת למצלמה. אפשר/י הרשאת-מצלמה בהגדרות ונסה/י שוב." (קופי מאושר).
- guard: `camera_error_view_test` (מרנדר את ההודעה).

## #bind-color — inkLight ×150 (W3 batch 1) — 2026-06-08
- **שינוי-קוד בלבד · אפס שינוי-עין:** `Color(0xFF1A1A1A)` → `BsTokens.inkLight` (אותו hex) ב-17 screens.
- guard: `color_token_ratchet_test` — ratchet שנועל את הליטרל מלחזור (down-only).

## #a11y-contrast — מצב ניגודיות גבוהה מכסה foregrounds-של-מותג (before→after) — 2026-06-08
- **before:** "ניגודיות גבוהה" לא נגע ב-FAB לבן-על-כתום (2.61:1), מחיר/online ירוק-על-לבן (2.28:1), או ~40 chip/CTA פעילים — נשארו לא-קריאים (מתחת WCAG) **גם כשהטוגל דלוק**.
- **after (HC דלוק בלבד):** ה-foreground מתכהה — אייקון/טקסט על כתום → `inkLight` (6.7:1), ירוק-טקסט → `successDark`=#15803D (5.0:1). המילוי הכתום והנקודה הירוקה נשמרים.
- **המצב הרגיל: אפס שינוי-עין** (`bsOnAccent`/`bsSuccess` מחזירים white/#22C55E כש-HC כבוי).
- guard: `a11y_contrast_theme_test` (5).

## #a11y-noncolor — Dynamic-Type + tooltips (before→after) — 2026-06-08
- **before:** ה-OS Dynamic-Type הוזנח (טקסט ננעל על 0.9/1.0/1.15 בלבד); 13 `IconButton` icon-only בלי tooltip/semantics; תמונת-מוצר לא-מתויגת הוקראה ע"י screen-reader כ"תמונה" ריק.
- **after:** הטקסט מכבד את הגדרת-ה-OS (מקופל עם העדפת-האפליקציה · clamp 1.35); כל `IconButton` עם tooltip עברי; תמונות-מוצר דקורטיביות (`excludeFromSemantics`) אלא אם הועבר `semanticLabel`.
- guard: `a11y_contrast_theme_test` (5) · analyze 0 · tooltips/semantics additive.
### 2026-06-09 — מסך-בית חכם + מחיקת 'הכל' + מצב-היכרות (אומת חי על :5556)
- **בית = הבית-החכם:** אריחי מחלקות (2 שורות + "עוד") · 🌳 עץ-חכם עם תמונות-מוצר אמיתיות · מסלול-עבודה · כלים-מהירים · תכנון-חיבור · מועדפים · הזמנות-אחרונות (כרטיסים). צ'יפ 'הכל' נעלם; 'מאתר' → finder. אומת בצילומים (chips: ...·תכנון חיבור·מאתר·בית; 'בית' פעיל=קוביות).
- **מצב-היכרות:** 💡 מקפיא + באנר (דוחף תוכן, לא חופף) + לחיצה על אלמנט = בועת-צ'אט עם זנב המצביע על הכפתור (מיקום מעל/מתחת אוטומטי). אומת בבית (📷/סל) + פתיחה/מקצוע/שקופיות.
- **עמידות:** תוקן RenderFlex overflow באריחי/כרטיסי הבית תחת רוחב-זעיר/טקסט-גדול (Flexible לתווית `_MiniTile`, Expanded לתמונת `_SmartTreeCard`) — robustness 1/12 ירוקים.

## #a11y-round3 — Semantics + round-3 cosmetics (before→after) — 2026-06-08
- **before:** 7 כפתורי-אייקון זעירים לא נקראו ע"י screen-reader; סכום שלילי `₪-3,150`; חץ-breadcrumb `›` הפוך ב-RTL; zoom-תמונה שנכשלת = קופסת-שבר; חיפוש >40 תוצאות נחתך בשקט.
- **after:** `Semantics(button,label)` על כולם; `-₪3,150`; `‹`; emoji-fallback ב-zoom; footer "מציג 40 תוצאות ראשונות".
- guard: full suite 1737/1737 green · analyze 0.
### 2026-06-09 — מסך-הבית מסונכרן עם הגדרות-התצוגה + גלילה (אומת חי על :5556)
- **גלילה:** שורות עץ-חכם/הזמנות גוללות טבעי ב-RTL (כרטיס ראשון מימין) — `reverse: true` הוסר.
- **עמודות:** מחלקות/מועדפים לפי `gridColumns` — אומת `gridColumns=2` → 2 עמודות (במקום 4 קבוע), בגובה-אריח תקין (~104, לא ענק; תוקן ל-`mainAxisExtent` קבוע).
- **תמה+ניגודיות:** צבעים מ-`Theme.of(context).colorScheme` → כהה/ניגודיות חלים.
- **גודל-תמונות/קומפקטי:** גודל כרטיסים/תמונות מגיב.
- **גודל-טקסט:** גבהים אדפטיביים (`textScaler`) — טקסט גדל בלי `...`.

## 2026-06-09 — כפתור X (סגור) ל-3 sheets ה-AI + מירכוז AI-Hub (נחיל 9×9 · #38/#40/#48)
- **before:** 3 ה-modal-sheets (חלופות זולות/השוואת מחירים/סרוק תוכנית) נסגרו רק בגרירה/scrim — אין X גלוי; אריחי AI-Hub עם טקסט מיושר-ימין.
- **after:** `_SheetHandle` משותף — X (`Icons.close`, tooltip 'סגור') ב-visual-top-left מעל ידית-הגרירה (RTL, 48dp, Semantics); אריחי AI-Hub ממורכזים.
- **אימות:** בדיקת-widget התנהגותית `test/sheet_close_test.dart` 3/3 — פתח sheet → `find.byTooltip('סגור')` קיים → tap → כותרת-ה-sheet נעלמת (הוכחת dismiss). אימות-פיקסל חי על :5556 בתור לנקודת-בדיקה הבאה של הריצה.
- guard: analyze 0 · suite ירוק.

## 2026-06-09 — declutter תפריט ⋮ + הגדרות-הוגנות + מסך-בקרוב (נחיל 9×9 · #34/#53/#51/#29)
- **תפריט ⋮ הבית:** before 9 פריטים → after 2 (🤖 בינה מלאכותית · ⚙️ הגדרות). 7 הוסרו (כולם נגישים ממקום אחר — אומת בקוד).
- **אזור ושפה:** العربية + English עכשיו מציגים badge 'בקרוב' ואינם ניתנים-לבחירה; עברית פעילה (אין זיוף החלפת-שפה).
- **תצוגה ומיון:** רשת/רשימה עם אייקונים (grid_view/view_list); "גודל תמונות" — קטן/בינוני/גדול מוצגים בגדלים 13/15/18 (ההבדל נראה לעין). "מיון ברירת מחדל" נשאר 'בקרוב' הוגן (אין consumer אמיתי — לא זויף).
- **מסך "בקרוב":** בחירת חשמלאי/קבלן-שיפוצים → מסך 🚧 'בקרוב' שמנמן את המקצוע + '‹ חזור לבחירת מקצוע'. אינסטלטור ללא שינוי.
- **אימות:** `test/coming_soon_screen_test.dart` (push→מציג מקצוע→חזור-pops) + onboarding/profile ירוקים. אימות-פיקסל חי בתור לנקודת-בדיקה. guard: analyze 0 errors · suite ירוק.

## 2026-06-09 — מחלקות-רשת-קבועה + חיפוש-חלופות + בחירה-ידנית-בסריקה (נחיל 9×9 · #33/#37/#41)
- **מחלקות:** רשת קבועה 2-עמודות (3 מחלקות + "עוד") — לא משתנה יותר עם gridColumns. המוצרים/מועדפים עדיין מגיבים להגדרה.
- **חלופות זולות:** שדה חיפוש 'חפש מוצר…' מסנן את הרשימה; אין-התאמה → 'לא נמצאו חלופות תואמות.'; ריק → הרשימה האוטומטית המלאה.
- **סרוק תוכנית:** checkbox לכל פריט (ברירת-מחדל הכל מסומן); הכפתור משתנה 'אשר הכל' ↔ 'אשר את הבחירה' לפי הבחירה; נוסף לסל רק מה שסומן.
- **אימות:** `test/plan_select_alt_search_test.dart` 2/2 (חיפוש→empty-state; deselect→הכפתור מתחלף) + רגרסיה ירוקה. אימות-פיקסל חי בתור. guard: analyze 0 errors.

## 2026-06-09 — הרחבת פרופיל + כרטיסיית-פרופיל בצ'יפ-השם (נחיל 9×9 · #55)
- **עורך פרופיל:** נוספו 2 שדות — כתובת · ח.פ./עוסק מורשה (מתחת לטלפון/אימייל), נשמרים ב"שמור".
- **צ'יפ-השם (כותרת הבית):** לחיצה פותחת **כרטיסייה** read-only יפה עם הפרטים המלאים (שם/מקצוע/כתובת/ח.פ.; ריקים מושמטים) + כפתור 'ערוך פרופיל' → העורך. (קודם: פתח ישר את העורך.)
- **לוגו/תמונה:** נדחה (needs-decision — דורש image-picker; לא זויף).
- **אימות:** `test/user_profile_fields_test.dart` 4/4 (round-trip + legacy-default + registered-logic) + profile/deep_fix/onboarding ירוקים. אימות-פיקסל חי בתור. guard: analyze 0 errors.

## 2026-06-09 — כפתור-סל צף + משוב מיידי בהוספה (נחיל 9×9 · #47)
- **כפתור-סל צף** מופיע עכשיו גם ב-AI Hub (וב-feature-screens שלו) — לא רק בבית. מוצג רק כשהסל לא-ריק, עם ספירה חיה.
- **משוב מיידי:** הוספה לסל מהסריקה כבר **לא זורקת אותך לטאב-חנות** — נשארים בהקשר, וכפתור-הסל הצף מתעדכן מיד עם הספירה החדשה (+ toast). לחיצה על הכפתור ב-AI Hub סוגרת אותו ונוחתת בסל.
- **אימות:** widget_test (ה-shell עולה תקין עם CartFab) + scan/budget/sheets/plan-select 28/28 ירוקים. אימות-פיקסל חי בתור. guard: analyze 0 errors.

## 2026-06-09 — תיקון באג load-race ברישום-חוזר (נחיל 9×9 · #24)
- **לוגי, לא ויזואלי:** משתמש חוזר (פרופיל ישן שמור) שמקליד שם/טלפון טריים ונרשם — הקלט הטרי כבר **לא נדרס** ע"י טעינת-ה-prefs המאוחרת. guard `_userTouched` ב-UserProfileNotifier.
- **אימות:** `test/profile_loadrace_test.dart` משחזר את ה-race (prefs ישן + register טרי) ומאשר שהטרי שורד; onboarding/profile ירוקים. guard: analyze 0 errors.

## 2026-06-09 — נגישות: Semantics/Tooltip לכפתורי-אייקון ב-10 מסכים (נחיל 9×9 · a11y)
- **before:** כפתורי-אייקון/glyph (הוסף-לסל +, הסר ✓, סטפר כמות ±, סגור ×, חזרה, נהל-קטגוריות) ב-10 מסכים — לא נקראו ע"י screen-reader (אין Semantics/Tooltip).
- **after:** עטיפה אדּיטיבית Semantics(button)+Tooltip עם תווית-עברית מדויקת לכל אחד — **בלי שינוי-גודל/מראה** (round-3 idiom). 25 כפתורים.
- מסכים: lipskey-products/product-sheet/brand · catalog · store · install-studio · camera · home_shell · notifications · smart-home.
- **אימות:** analyze 0 errors; הסמנטיקה אדּיטיבית (לא משנה layout). אימות-פיקסל-חי + screen-reader בתור לנקודת-בדיקה.

## 2026-06-09 — השלמת a11y/rtl (נחיל 44-fixers → 9 אמיתיים)
- נחיל סרק את כל 44 המסכים שנותרו; רוב המסכים כבר תקינים (round3). 9 תיקונים אמיתיים: תוויות screen-reader לכפתורי-X/חזרה ב-finder/audit/chats/home-content-reorder/install-studio/lipskey-products.
- אדּיטיבי בלבד (Semantics+Tooltip), בלי שינוי-מראה. analyze 0 errors.

## 2026-06-10 — נחיל 9-משימות: בטיחות-לחיצה, נגישות-מגע, מצבי-ריק, משפטי (#57·58·59·60·62·63·64·26·61)
- **חזור ברישום:** לחיצת חזור (דפדפן/מכשיר) בתוך הזרם מחזירה שלב-אחורה (רישום→מקצוע→פתיחה) במקום לזרוק החוצה.
- **חצי-חזרה:** 5 חצים שהצביעו לכיוון הלא-נכון ב-RTL (צ'אטים/קטלוג/אודיט) מצביעים עכשיו ימינה=חזרה תקין.
- **אזורי-מגע:** ~44 כפתורי-אייקון קטנים (X-הסרה, ±כמות, לב-מועדף, ✕-סגירה...) — אזור הלחיצה גדל ל-≥48dp בלי שינוי-מראה (האייקון נשאר זהה; halo שקוף).
- **דיאלוגי-אישור:** 19 פעולות בלתי-הפיכות (נקה-סל, מחיקת-רשימה/קטגוריה/פרויקט, נקה-התראות, השתק-הכל, מסירה-לשליח, נמסר-ללקוח, מימוש-פרס, אישור/דחיית-משימה...) שואלות עכשיו "בטוח?" עם ביטול/אישור-בצבע.
- **מצבי-ריק:** 11 מסכים מציגים הודעה עברית ידידותית (אימוג'י+הסבר+פעולה) במקום מסך ריק/שבור.
- **חיווט-אמת:** שתף-סל משתף באמת (Web Share/clipboard) · 'עקוב' במשלוחים = toggle אמיתי שנשמר · רענון-משוך אמיתי (בוטל delay-פייק) · מונה לא-נקרא בצ'אטים אמיתי (הודעות חדשות מאז כניסה אחרונה) · ערוצי-קבלה: in-app חי, אימייל/SMS מסומנים 'דורש שרת' מושבתים.
- **ולידציה:** טלפון/אימייל/ח.פ./סכומים מסומנים אדום עם הודעה עברית כששגויים; אישור-רישום ושמירת-פרופיל חסומים עד תיקון.
- **משפטי חדש:** מסך 'תנאי שימוש ופרטיות' (טאבים, נגיש מהגדרות→מידע, מהחיפוש ומקישורי-הרישום) — תוכן אמיתי לפי תיקון-13; באנר-ענבר מציין placeholders לפרטי-חברה.
- **אימות:** analyze 0 errors · בדיקות חדשות 31/31 · מוטציה נתפסה (mutation_log) · full-suite בריצה · אימות-פיקסל-חי בתור.
## 2026-06-10 — login_sheet חדש (server-S1) — visual-verify
- **מסך חדש:** sheet-התחברות RTL — כותרת "🔐 התחברות לחשבון" + תת-כותרת SMS · שדה-טלפון (אייקון 📱, hint "מספר טלפון נייד") · CTA כתום מלא-רוחב "שלח קוד אימות" (פיל) · קישור "כניסה עם אימייל וסיסמה". שלבי OTP/מייל באותו idiom (persona_pod).
- **אומת ברינדור אמיתי** (harness עם Heebo · 420×760): layout תקין, RTL נכון, אפס overflow. (emoji-tofu ב-harness בלבד — אין פונט-emoji בטסטים; במכשיר תקין.) screenshot נשלח למשתמש: /tmp/login_sheet.png.
- נגיש רק כש-gateway קיים (Firebase חי) — ללא-Firebase האפליקציה byte-identical (נעוץ בטסט).

## 2026-06-10 — toast.dart: מפתח-messenger גלובלי (server-S6) — אפס שינוי-עין
- **שינוי-קוד בלבד:** `bsMessengerKey` + `showGlobalToast` (ל-push בחזית בלי context); ה-pill מוגדר פעם אחת ב-`_toastBar` ו-`showToast` הקיים זהה התנהגותית.
- **אומת:** widget-test (push_state_test) מרנדר את ה-pill האמיתי דרך המסלול הגלובלי; analyze 0.

## 2026-06-10 — welcome→auth wiring (server-gate-auth) — visual-verify
- **שינוי-זרימה (flag ON בלבד):** "כניסה ללקוח קיים" + "רישום" ב-welcome מנתבים עכשיו ל-`showLoginSheet` (Firebase phone-OTP); אחרי `signedIn` → mirror פרופיל ל-`users/{uid}` + כניסה לאפליקציה. flag OFF = דמו כמו היום (`continueAsDemo`).
- **אומת ברינדור** (Heebo · 430×932): מסך-הכניסה **ללא שינוי-עין** (hero + "כניסה ללקוח קיים" + טופס-רישום + "המשך ללא רישום (דוגמה)") — הניתוב הוא בלוגיקת-ה-onPressed, לא בפריסה. screenshot: /tmp/welcome.png. נתיב flag-ON (OTP) נבדק ב-preview-channel האמיתי (מכשיר).
- guard: `welcome_auth_gate_test` (3 · flag-OFF דמו · writer=null בלי Firebase).

## 2026-06-10 — לוחות עובד+שליח: רישום, טאבים, פירוט, פרופילים (#65-76 נחיל)
- **שער-רישום לכל לוח:** כניסה לעובד/שליח/חנות/מנהל דורשת שם-משתמש+קוד (מהקבלן/חנות) או דמו — מסך הרישום המוכר, בלי שום שינוי ויזואלי. בלי קוד — רואים רק את השער.
- **לוח עובד:** בלי מתג רן/עומר — העובד המחובר רואה רק את שלו (דמו=רן+צ'יפ) · 4 טאבים למטה: משימות·שיחות·דוחות·אזור-אישי · לחיצה על משימה פותחת פירוט אמיתי (שלבים✓, תמונה, שלח-לאישור) · פרופיל-עובד עם החלפת-תפקיד בקוד 1234 · הגדרות-עובד מצומצמות · צ'אט קבלן·מנהל·בוט.
- **לוח שליח:** בחירת-רכב ואז בית · 4 טאבים: משלוחים·פורטל·דוחות·אזור-אישי · "הקש לפרטים" עובד (פריטים/לקוח/מסלול/POD) · משלוחים שדורשים רכב אחר מקובצים בנפרד · פורטל: POD/צ'אט/צי/אזורים חיים, ניווט/SLA "יחובר עם השרת" · צ'אט חנות·לקוח·שליחים·בוט.
- **אימות:** analyze 0 errors · board_auth 8/8 · מוטציה נתפסה · full-suite בריצה · אימות-פיקסל-חי בתור אחרי build.

## 2026-06-10 — לוח עובד v2 (#85) + 23 תיקוני-אודיט
- כניסת-לוח דרך "כניסה ללקוח קיים" · מצלמת-דסקטופ אמיתית (תצוגה-חיה+צלם) · שלח-לאישור עם preview והמנהל רואה תמונה+הערה · "היום שלי"+"מה להביא"+ברקוד+💡+🔔 · דוחות עם גרף/רצף-אמיתי/תמונות-לחיצות/סיבת-דחייה · נוכחות/טופס-101/חופשה→מנהל→פעמון/תיק-בטיחות/תלושים(שרת) · פרופיל-עריכה+תמונה · מנהל: פרופיל+התנתקות.
- אימות: analyze 0 · 21/21 · אודיט 114: הכל תוקן · פיקסל-חי נבדק ע"י המשתמש לפני הקומיט.

## 2026-06-10 (ערב) — יישוב-מיזוג מול server-track + שחרור הלוגו
- **תג-הדיאגנוסטיקה** (🔴 דמו/🟢 שרת) עבר מימין-עליון למרכז-עליון — ב-RTL הוא ישב בדיוק על לוגו BuildSmart ובלע את הלחיצה לבוחר-התפקידים (לכל משתמש). עכשיו הלוגו לחיץ והתג גלוי במרכז.
- **"כניסה ללקוח קיים" (קבלן):** סדר ממוזג — לוח=קוד · שרת-פעיל=OTP · דמו=דיאלוג-גילוי "נכנסים כאורח" לפני הכניסה.
- אימות: widget_test 'BS dial opens 5 personas' ירוק (היה חסום ע"י התג) + 30/30 רגישות.

## 2026-06-11 — build-fix: DropdownButtonFormField value: (worker_forms טופס-101)
- **שינוי-קומפילציה בלבד (לא ויזואלי):** `initialValue:` → `value:` על dropdown "מצב משפחתי" ב-`worker_forms_screen.dart:172`. מיזוג e8ae1dd השאיר API של Flutter מאוחר; בטולצ'יין 3.29 הפרמטר הוא `value:`. לפני התיקון המסך **לא קומפל כלל** (build web שבור → חסם push).
- **ללא שינוי-עין:** אותו dropdown value-bound בדיוק (אותו ערך-נבחר · אותם items · אותו decoration) — רק שם-הפרמטר הנכון לגרסה. כמו תקדים welcome→auth: השינוי בחתימה, לא בפריסה.
- **אימות:** analyze 0 errors · build web --release ירוק (46s). לא צולם screenshot נפרד — ה-render זהה וה-state שלפני לא קומפל; האימות הוא הקומפילציה+build (loud: זו הסיבה שאין פיקסל-לוג חדש).

## 2026-06-11 — A3 orders contractorUid (store_screen checkout) — לוגיקה בלבד
- **שינוי-לוגיקה ב-checkout (לא ויזואלי):** ה-checkout מטביע עכשיו `contractorUid` (מ-`currentUidProvider`) על ההזמנה הנוצרת — בתוך ה-onPressed, ליד `who`. אפס שינוי בפריסה/טקסט/כפתורים.
- **ללא שינוי-עין:** השדה נכתב ל-doc בלבד (ל-scoping עתידי ב-A4); המסך מרנדר זהה. כמו תקדים welcome→auth / A2 — שינוי בלוגיקה, לא בתצוגה.
- **אימות (supervisor):** analyze 0 · סוויטה מלאה +2008 · build web ✅ · mutation (שבירת copyWith) נתפסה ושוחזרה.
## 2026-06-11 — שליח-v2 + ספק #77-83 (נחיל קנוני)
- שליח: צילום-מסירה אמיתי במצלמה + נראה לחנות/מנהל · מטבעות ופעמון במסירה · דוחות-עשירים עם תמונות.
- ספק: 4 טאבים למטה (בית=הזמנות) · צי+עדכון-מלאי בבית · מוצרי-ספק חדשים עם תג · חוסר עובר לקבלן להחלטה אמיתית · צ'אט-ספק מלא · הגדרות-עסק.
- אימות: central-verify ירוק על ה-worktree · פיקסל-חי בתור אחרי merge+build.

## 2026-06-11 — הסתרת מחלקות+מקצועות לא-בנויים (נחיל-placeholders גל-1) — שינוי-עין
- **שינוי ויזואלי (הסרה):** 5 מחלקות (חשמל·חומרי בניין·צבע·גבס·אספקה טכנית) ו-2 מקצועות (חשמלאי·קבלן שיפוצים) **נעלמו** מ-מסך-המחלקות, מ-smart-home, ומבוחר-המקצוע — אין יותר אריחי-"בקרוב" עמומים. נותרו רק הפעילים (אינסטלציה·ברזים·כלי-עבודה / אינסטלטור).
- **ללא שינוי-עין נוסף:** תיקון `activeThumbColor`→`activeColor` ב-store_dashboard הוא ויזואלית-נייטרלי (אותו Switch, שם-פרמטר תקף ל-3.29).
- **אימות:** `placeholder_hide_test` 3/3 (המוסתרים findsNothing, החיים present) · analyze 0 · full-suite +2012 · build web ✅.
## 2026-06-11 — אזור אישי v2 שליח+ספק (#86/#87, נחיל קנוני)
- שליח · אזור אישי: כרטיס-זהות עם תמונת-פרופיל אמיתית + ✏️ עריכה (שם/טלפון/רכב-מועדף/צילום) · סטטיסטיקה אישית "נמסרו על-ידי / POD שלי / בדרך" עם תוויות כנות (לא עוד מספרים גלובליים) · כרטיס 4 כניסות: נוכחות · טפסים · תעודות נהג · תלושי שכר · צ'יפ "דמו" אחיד · נוסחי יציאה/החלפת-תפקיד יושרו לעובד.
- שליח · מסכים חדשים: נוכחות (שעון ענק + יומן חודשי + שלח-דוח-לחנות) · טפסים (101 · חופשה · מחלה) · תעודות נהג (presets + רמזור תפוגה). שער-רכב מציג "★ מועדף" ומדלג בכנות כשיש רכב-מועדף.
- ספק · טאב חמישי "אזור אישי": זהות-עסק (לוגו/שם חי גם בכותרת הלוח ובברכה) · פרופיל-עסק בעריכה עם שמירה מפורשת 💾 · תעודות עסק · מסמכים 🧾 נעולים-בכנות · סטטיסטיקה עם "מחזור שנמסר".
- רוחבי: ירוק-הצלחה כהה (successDark) וטקסט-על-מותג (bsOnAccent) במקומות שנכשלו ב-AA · "הסר"/"יציאה" ב-dangerDark · גלולת POD מיושרת כיוונית (RTL).
- אימות: analyze 0 · supervisor CLEAN · t9 ‎11/11 כולל טאב-הספק החדש · central-verify על ה-worktree.

## 2026-06-11 — הגדרות-תצוגה בקטלוג מופעלות (נחיל גל-2 מנה-1) — שינוי-עין
- **שינוי ויזואלי:** ב-catalog_settings 5 שורות "בבנייה" הוחלפו בפקדים אמיתיים (Switch/בחירה). ובקטלוג (lipskey_product_sheet): מחירים מוצגים עכשיו לפי ההגדרה — **כולל מע"מ** (×1.17) · סמל-מטבע נבחר (₪/$/€) · סיומת "ליחידה" · מידות מומרות מטרי↔אימפריאלי.
- **אימות:** `catalog_price_units_settings_test` 16/16 (כולל 3 widget) · analyze 0 · full-suite +2028 · build web ✅.

## 2026-06-11 — מיון+התראות-קטלוג מופעלים (נחיל גל-2 מנה-2) — שינוי-עין
- **שינוי ויזואלי:** ב-catalog_settings — "מיון ברירת מחדל" ו-5 toggles-התראות הוחלפו בפקדים אמיתיים (בורר/Switch). בחירת-מיון משנה **מיד** את סדר הקטלוג.
- **אימות:** `catalog_sort_alerts_settings_test` 16/16 · analyze 0 · full-suite 2096 · build web ✅.

## 2026-06-11 — הגדרות-התראות in-app מופעלות (נחיל גל-2 מנה-3) — התנהגות
- **שינוי:** במסך-ההתראות — מתגי עובד/שליח · push-master · sound/vibration כעת **משפיעים על פעמון-ההתראות החי** (כיבוי → badge 0 + sheet ריק; sound+רטט בעליית unread, מושתק ב-quiet/snooze). הוסרו markers-"בבנייה" מהסקשנים שחוברו (Sound/Persona); נשמרו על הנדחים.
- **אימות:** `notif_settings_wiring_test` 14/14 · analyze 0 · full-suite 2110 · build web ✅.

## 2026-06-11 — כלי-AI מציגים תוצאות אמיתיות (נחיל גל-4) — שינוי-עין
- **שינוי:** ב-ai_hub — חיזוי-מלאי · analytics · חלופות מציגים עכשיו מספרים **מחושבים מהדאטה החי** (תג 🧮 מחושב) במקום קבועים. 3 כלים שדורשים מקור-חיצוני נושאים הערת "⚙️ בפרודקשן: דורש X" (גלוי-יושר, לא "בקרוב").
- **אימות (supervisor):** `ai_hub_compute_test` 14/14 · analyze 0 · full-suite +2124 · build web ✅ · mutation נתפסה.

## 2026-06-11 — ניקוי-אפל: תג-בדיקה + קטגוריות-ריקות (נחיל) — שינוי-עין
- **שינוי ויזואלי:** (B1) תג-הבדיקה (🔴/🟢) **נעלם ב-release** (נשאר רק ב-debug). (B4) 5 קטגוריות-קטלוג ריקות (חימום מים·מטבח·גופי תברואה·בנייה ומחיצות·גמר) **לא מוצגות יותר** — אפס "בקרוב" בקטלוג; 8 קטגוריות-תוכן נשארות.
- **אימות:** `debug_badge_gate_test` 3/3 · `catalog_coming_soon_hide_test` 2/2 · widget_test מעודכן · analyze 0 · full-suite +2129 · build web ✅.

## 2026-06-11 — מצלמה אמיתית ב-camera_sheet (נחיל גל-3) — שינוי-עין
- **שינוי ויזואלי:** כפתור-המצלמה (לפני/POD/משימה) ו"כל הגלריה" — היו תג "🚧 בבנייה" מדומה — עכשיו **כפתור-צמצם אמיתי** שפותח לכידה (web webcam חי · mobile מצלמה/גלריה) + דיאלוג-תצוגה-מקדימה לפני אישור. ביטול = נשאר במסך בלי תמונה מזויפת.
- **אימות:** `camera_sheet_capture_test` 3/3 (seam מוזרק) · analyze 0 · full-suite +2132 · build web ✅. (חומרה-אמיתית = בדיקת-מכשיר owner.)

## 2026-06-12 — הכנת-זהות A8/A11 (chats_screen) — לוגיקה בלבד
- **שינוי-לוגיקה (לא ויזואלי):** שליחת-הודעה מטביעה עכשיו `fromUid` (מ-`currentUidProvider`) — בתוך לוגיקת-ה-send, אפס שינוי בפריסת-הצ׳אט. (A11 לקוחות = data-layer בלבד, ללא UI.)
- **אימות:** `chat_uid_a8_test` + `customers_uid_a11_test` · analyze 0 · full-suite ירוק · build web ✅.

## 2026-06-12 — מסך הקצאת-תפקיד למנהל (נחיל A12) — שינוי-עין
- **שינוי ויזואלי:** ניהול-tab של המנהל — סקשן חדש "🔑 שיוך תפקידים" שפותח sheet: חיפוש-משתמש לפי טלפון + בחירת-תפקיד + שיוך. בלי-backend: שדות/כפתור מושבתים + banner "זמין רק עם חיבור לשרת".
- **אימות:** `manager_role_assign_sheet_a12_test` 5/5 · analyze 0 · full-suite +2160 · build web ✅. (שיוך-אמת = setRole בשרת, owner.)

## 2026-06-13 — בעלות-הזמנה multi-user (נחיל A4-A6) — התנהגות (gated)
- **שינוי (כש-flag `kUidScopedQueries` ON):** חנות/שליח רואים רק בריכה∪שלהם בדשבורד (במקום כל-ההזמנות); הזמנה נתבעת ע"י הראשון שמקדם אותה. **flag OFF (היום) = אפס שינוי-עין** (זירו-רגרסיה).
- **אימות:** `orders_uid_a4_a6_test` 22/22 · analyze 0 · full-suite +2176 · build ✅ · emulator-rules 27/0.

## 2026-06-13 — שיחות/וידאו V1+V2 (calls/video) — שינוי-עין
- **שינוי ויזואלי (V1 — כפתורים חיים):** בכל מקום שמוצג טלפון של אדם נוספו שני כפתורי-פעולה אמיתיים — **📞** (פותח את החייגן הנייטיב, `tel:`) ו-**💬** (פותח WhatsApp, `https://wa.me/<ספרות-בינ"ל>`), דרך `url_launcher` (seam `urlLauncherProvider`, חיצוני). מיקומים: כרטיס-זהות פרופיל **ספק/עובד/שליח** (מתחת לשורת המטא — מקור `profile.phone`) + **כותרת-הצ׳אט** (`_ChatPage` ב-`chats_screen`), שם הם **מחליפים** את כפתורי שיחת-הוידאו/הקול המתים שהציגו "לא זמין בדמו" — מקור `userProfileProvider.contact`. אין שיחות בתוך האפליקציה (אין Agora) — רק hand-off ל-OS. **שמירת-יושר:** כש-אין טלפון הכפתורים **נעלמים** (`SizedBox.shrink`) — אף פעם לא `tel:`/`wa.me/` ריק. עץ-ההזמנות (Order/SysOrder/ManagerOrder/ManagerCustomer) **אינו נושא שדה-טלפון** → אין שם כפתורים (guard ה-empty), בהתאם לעקרון "אין המצאות".
- **שינוי ויזואלי (V2 — הסתרת הבטחה-מתה):** עץ-ההגדרות **"הגדרות שיחות"** (אישורי-קריאה/חיווי-הקלדה/צלצול-שיחה-נכנסת/דחיסת-וידאו/גיבוי-לענן — תכונות שאינן קיימות) הוסר מהחיפוש (`search_index`) ופריט-התפריט "הגדרות" בתפריט ה-⋮ של הצ׳אט (שפתח את `ChatSettingsScreen`) **הוסר** — המסך לא נגיש יותר מתפריט/חיפוש (קובץ-המסך נשמר, reversible). הצ׳אט-העובד עצמו (entry 'שיחות') **נשמר** ללא שינוי. אפס הבטחת-וידאו/שיחות בשום מקום.
- **אימות:** `input_validators_test` 34/34 (כולל 7 waMe חדשים) · `contact_actions_test` 4/4 (לכידת `tel:`/`wa.me` דרך seam מוזרק + guard empty-מסתיר) · `call_settings_hidden_test` (כותרות-מת נעדרות + צ׳אט נשמר) · analyze 0 errors (קבצים נגועים, אפס lint חדש) · mutation 0→972 נתפסה (אדום→ירוק-אחרי-cp) · build web + full-suite — ראה דוח.

## 2026-06-13 — order-card 📞/💬: כפתורי-קשר על כרטיס-ההזמנה (V1 last-mile · נחיל) — שינוי-עין
- **שינוי ויזואלי:** ל**כרטיס/דף-ההזמנה** נוספו `ContactActions(phone: order.customerPhone)` — 📞 (חייגן `tel:`) / 💬 (WhatsApp `wa.me/`) שמגיעים ל**קבלן שהזמין** (החלטת בעל-המוצר: ספק/שליח שמתקשר ללקוח-הקבלן על ההזמנה). מיקומים: **חנות** — `_StoreOrderCard` + `_DeliveredCard` (`store_dashboard_screen`, מתחת לשורת `who · site`, compact); **שליח** — `_CourierJobCard` (`courier_dashboard_screen`, מתחת ל-`📍 site`) + `CourierDeliveryDetailSheet` (אחרי שורת 👤); **מנהל** — `_OrderRow` (`manager_dashboard_screen`, מתחת ל-`who · site`) + `_OrderDetailSheet` (מתחת לשורת 'קבלן'). מקור-הטלפון: `Order.customerPhone` נחתם ב-checkout מ-`userProfileProvider.contact`, מוקרן ל-`SysOrder.customerPhone`.
- **שמירת-יושר / אפס-רגרסיה:** הזמנות seed/legacy (טלפון ריק — כל ההזמנות עד עכשיו) → **אין כפתורים** (empty-guard של ContactActions, `SizedBox.shrink`) — בדיוק כמו היום. הזמנות הקבלן-עצמו (`store_screen` order-list/sheet · `smart_home` recent-orders) **לא** קיבלו כפתורים — הן לא מציגות שם-לקוח (הקבלן רואה את ההזמנה-שלו; אין למי להתקשר).
- **אימות:** `order_card_contact_actions_test` 2/2 (כרטיס-שליח אמיתי מעל מנוע-מוזרק: stamped→📞/💬 חיים עם Uris נכונים · empty→אפס-כפתורים) · `orders_engine_test` customerPhone 6/6 · `orders_uid_a3_test` customerPhone 3/3 · analyze 0 errors/warnings (אפס lint חדש) · mutation fromJson נתפסה (אדום `+26 -1`→ירוק-אחרי-cp `+27`) · full-suite **+2233 All tests passed** · build web ✅.

## 2026-06-14 — 4 כפתורים-מתים/מזויפים → התנהגות-אמת (ביקורת-launch · נחיל) — שינוי-עין
- **שינוי ויזואלי (4 כפתורים, אותו מראה — התנהגות-אמת חדשה):**
  - **שיתוף-סל** (חנות → הסל → 'שתף'): במקום toast שמציג את סיכום-הסל, נפתח עכשיו **share-sheet הנייטיב/Web** עם הסיכום (שורות-מוצר + סה״כ) — שיתוף-אמת ל-WhatsApp/מייל/וכו'. הכפתור עצמו (אייקון-share + 'שתף') ללא שינוי-מראה.
  - **אריח-מועדף** (בית → מועדפים): אריח-מוצר עם כוכב שהיה **מת** (טאפ לא עשה כלום) פותח עכשיו את **גיליון-המוצר** — בדיוק כמו טאפ על אותו מוצר בקטלוג. אפס שינוי-מראה לאריח.
  - **"הזמן עכשיו"** (AI → חיזוי מלאי → פריט-דחוף): במקום toast "נוסף לרשימת רכש מומלצת" (שלא עשה כלום), הפריט **באמת נוסף לעגלה החיה** (יחידה אחת, עם השם/emoji/מחיר-יחידה מההזמנה-האמיתית שהניבה את התחזית). הכפתור ללא שינוי-מראה.
  - **דוח-PDF** (כספים → דוחות PDF → 'הפק והורד' → view → 'הדפסה'): במקום toast 'בחר "שמור כ-PDF"…', מופק עכשיו **PDF אמיתי** (גיליון RTL בעברית — תקציב + פירוט-קטגוריות, גופן-Heebo) ונפתח דיאלוג print/save נייטיב/Web. ה-view-על-מסך נשמר כתצוגה-מקדימה; כפתור 'הדפסה' ללא שינוי-מראה.
- **שמירת-יושר:** שיתוף — סל-ריק → toast 'הסל ריק', אפס-שיתוף. order-now — נתוני-המוצר אמיתיים שנלכדו משורת-הזמנה (לא מומצאים). PDF — מסונן-emoji בגיליון (השם+₪ נשמרים, אפס crash).
- **אימות:** `cart_share_test` 2/2 · `favorite_tile_opens_sheet_test` 1/1 · `ai_hub_compute_test` +2 (order-now) · `finance_pdf_export_test` 3/3 (magic `%PDF`) · analyze 0 errors/warnings · mutation share-text נתפסה (אדום→ירוק-אחרי-cp) · full-suite **+2241 All tests passed** (היה +2233) · build web ✅ Built (printing נפתר web-side, 7.7MB).

---

## #B5 — store settings "בבנייה" → effect-אמת (3 wired) — 2026-06-14

**שינוי:** 3 הגדרות-חנות מתות הופכות ל-effect-לקוח נצפה. אימות = widget-tests שמוכיחים את ההבדל הויזואלי (flip → שינוי-UI נצפה), בהיעדר screenshot-tooling בסביבה זו.
- **`shareCartWithTeam`** → כפתור 'שתף' בשורת-פעולות-הסל: OFF ⇒ נעדר מה-Row (נראה: רשימות/שמור/נקה בלבד) · ON ⇒ מופיע ביניהם. נצפה ב-`store_settings_wiring_test` (`find.text('שתף')` findsNothing↔findsOneWidget, אחרי jump-to-bottom של ה-cart ListView).
- **`supplierCreditEnabled`** → chip 'אשראי ספק' ב-`_PaymentSelector`: OFF ⇒ רק 💳כרטיס/📲ביט מוצגים · ON ⇒ 🤝אשראי-ספק מצטרף. נצפה (chip findsNothing↔findsOneWidget; 'כרטיס' תמיד findsOneWidget).
- **`defaultAddress`** → שדה 'לאן לשלוח?': default-ריק ⇒ TextField ריק (hint בלבד) · default-שמור ⇒ הטקסט מקדים-ממולא · shipTo-בתהליך גובר. נצפה דרך `TextField.controller.text`.

**אימות:** `store_settings_wiring_test` 8/8 · `cart_share_test` 2/2 (עודכן) · analyze 0-errors · build web ✅. mutation-verified (ראה `knowledge/mutation_log.md` §B5).

## #B5-cont — `purchaseHistory` → טוגל-פרטיות על רשימת-ההיסטוריה — 2026-06-14

**שינוי:** ההגדרה המתה `purchaseHistory` מגטה כעת את רשימת היסטוריית-ההזמנות. אימות = widget-test (בהיעדר screenshot-tooling).
- **`purchaseHistory`** → רשימת order-history: ON (ברירת-מחדל) ⇒ שורות-ההזמנה נראות, אין הודעת-פרטיות · OFF ⇒ הרשימה מוחלפת בהודעת-פרטיות + כפתור "הצג היסטוריה" · tap-הכפתור ⇒ ON חוזר והרשימה שבה. נצפה ב-`store_purchase_history_settings_test` (order-rows findsWidgets↔findsNothing; הודעת-הפרטיות findsOneWidget כש-OFF).

**אימות:** `store_purchase_history_settings_test` 3/3 · analyze 0-errors · build web ✅.

## #A14 — צילומי-תמונה: רינדור דו-צורתי (data-URL + https) — 2026-06-14

**שינוי:** כל אתר-רינדור-תמונה מנותב כעת דרך `imageProviderForRef` (`widgets/photo_viewer.dart`) שמרנדר **שתי הצורות**: data-URL base64 (כמו היום) **או** `https://…` URL שהועלה ל-R2 (כש-`kCloudPhotos` ON). **OFF (ברירת-מחדל) = ללא שינוי-מראה כלל** — התמונה נשארת base64 ומרונדרת בדיוק כמו היום (byte-identical). כש-ON, אותה תמונה מוצגת מ-`NetworkImage` (זורמת מ-R2, עם `ResizeImage` לאותו thumb-downscale שהיה ל-`cacheWidth`). אין screenshot-tooling — האימות הוא הבדיקות (`imageProviderForRef`: http→NetworkImage / data→MemoryImage / null+demo→null).
- **אתרי-רינדור שנותבו (אותו מראה, מקור-תמונה דו-צורתי):**
  - **POD** (`worker_task_detail_sheet.dart` `taskPhotoWidget` — נצרך ע"י persona_pod / manager-approvals / store_dashboard) + thumb+full-screen ב-`courier_reports_tab.dart`.
  - **אווטאר-פרופיל** עובד (`worker_profile_screen.dart`) + שליח (`courier_profile_screen.dart`) — `ClipOval`+`Image`.
  - **לוגו-חנות** (`store_profile_screen.dart` `_StoreLogoAvatar` + edit-preview) — `ClipOval`+`ResizeImage` thumb.
  - **תעודות** שליח (`courier_certs_screen.dart`) · עובד/בטיחות (`worker_safety_screen.dart`) · עסק (`store_profile_screen.dart` `_StoreCertRow`) — thumb 40px + tap→full-screen.
  - **sick-notes** (`courier_forms_screen.dart`) · **proof-thumb**+דיאלוג (`worker_reports_tab.dart`).
  - full-screen viewer: `showFullPhotoRefDialog(ref)` פותח את שתי הצורות (data-URL דרך `MemoryImage`, https דרך `NetworkImage`).
  - **ללא שינוי:** `camera_sheet.dart` preview — מציג את ה-data-URL-שזה-עתה-נקלט (לפני-העלאה, תמיד base64), נשאר `Image.memory`.
- **שמירת-יושר:** payload פגום / fetch שנכשל → `errorBuilder` מרנדר את ה-placeholder/אווטאר-ברירת-המחדל הקיים (לעולם לא crash). ref לא-ניתן-לרינדור (legacy 'demo' / null) → אותו placeholder ישר כמו היום.

**אימות:** `cloud_photos_a14_upload_test` 12/12 (כולל display dual-render) · analyze 0-errors (כל הנגועים) · full-suite **+2272** (היה +2260) · build web ✅. mutation-verified (ראה `knowledge/mutation_log.md` §A14).
## 2026-06-14 — גל-D פוליש עובד/שליח/חנות (#98)
- עובד · הגדרות: שורת 'פרופיל עובד' ירדה (אין יותר לולאת-ניווט) — הפרופיל נגיש מטאב-4.
- עובד · נוכחות: אחרי שליחת-דוח הכפתור הופך ל'הדוח נשלח ✓' ולא נשלח שוב.
- עובד: גווני-יציאה/הסר-תמונה כהים יותר (dangerDark, AA) · כפתור-השעון וכפתורי-המילוי עם טקסט bsOnAccent (ניגודיות).
- רובם בלתי-נראים-לעין (נגישות לקוראי-מסך, cacheWidth לזיכרון, מגני-double-tap) — אך אמיתיים ומאומתים.
- אימות: GATE PASS עם מאניפסטים · mutation red→green.

## #POD-signature — pad-חתימה אמיתי (במקום "(הדגמה)") — 2026-06-14

**שינוי:** כפתור ✍️ ב-POD-sheet פתח placeholder כן "(הדגמה)"; כעת פותח **pad-ציור אמיתי** (`SignaturePadSheet`) — חתימה באצבע/עכבר על קנבס לבן, כפתורי נקה/שמור, השמור מושבת עד שיש דיו (אין חתימה מזויפת). החתימה נשמרת כ-PNG data-URL (`podSignature`) ומוצגת כתצוגה (כמו podPhoto).
**אימות (בדיקת-widget):** `signature_pad_test` 8/8 — ציור→PNG-לא-ריק · dot · pad-ריק→null · save-פולט/מושבת-כשריק · preview-רנדר. analyze 0-errors · mutation-verified (§mutation_log). build web ב-pre-push gate.

## גל H2 — תעודות/הדרכות עובד גלויים-לקבלן + approve-back — 2026-06-14
- **קבלן (`contractor_hr_sheet`):** נוספו שני מקטעים מתחת לחופשות — 🎓 **הדרכות-עובדים** (כל ההדרכות newest-first + status-pill ממתין/אושר/נדחה/נרשם; שורת-pending → ✅ אשר / ❌ דחה) + 📜 **תעודות-עובדים READ-ONLY** (עובד/שם/מנפיק/תוקף + רמזור 🔴 פג / 🟡 לקראת / 🟢 בתוקף מ-`statusAt`) עם **באנר-תוקף מאוגד** ('⚠️ N פגות תוקף · M לקראת חידוש', צד-אפס מושמט, מוצג רק אם >0).
- **עובד (`worker_safety_screen`):** ללא שינוי-מראה — הוספת-תעודה/הוספת-הדרכה מטביעות `employerId` ברקע (העובד לא רואה הבדל; הקבלן מתחיל לראות את הרשומה).
- אישור-הדרכה → **פעמון-עובד אחד** + צ'אט `th-worker-contractor` (כמו חופשה). הלוגיקה רובה מאחורי-הקלעים; שני המקטעים בלוח-הקבלן נראים-לעין.
- **אימות:** analyze 0 (כל 4 הקבצים) · +30 (סוויטת certs/trainings) · supervisor CLEAN (11/11) · mutation RED→GREEN (guard pending).

## גל H3 — עורך מדיניות מסמכים-נדרשים בלוח-הקבלן — 2026-06-14
- **קבלן (`contractor_hr_sheet`):** מקטע רביעי 📋 'מסמכים נדרשים מהעובדים' (אחרי תעודות) — עורך-כתיב: שדה-טקסט + '➕ הוסף', צ'יפי-הצעה (היתר עבודה בגובה / מפעיל מלגזה / חשמלאי), כל פריט עם ❌ הסרה. empty-state כן ('עובד נחסם רק על 101 לא-חתום או תעודה שפגה'). הומר ל-ConsumerStatefulWidget (controller, disposed) — שאר המקטעים ללא-שינוי-התנהגות.
- **עובד:** ללא שינוי-מראה — שער-המוכנות (#101) פשוט נעשה מחמיר יותר אם הקבלן הגדיר דרישות (מסך-החסימה הקיים מציג 'חסרה תעודה נדרשת: X').
- **אימות:** analyze 0 (3 קבצים) · +52 טסטים · supervisor CLEAN (10/10) · mutation RED→GREEN (substring-trap).

## גל S — תצוגת-נוכחות-עובדים בלוח-הקבלן — 2026-06-14
- **קבלן (`contractor_attendance_sheet`, חדש):** גיליון '🕒 נוכחות עובדים' (כניסה מ-tasks_screen) — '🟢 נוכחים עכשיו (N)' (username + שעת-כניסה + צ'יפ-📍 דרך openNavSheet, רק כש-GPS אמיתי) + 'היום' (כניסה→יציאה + שעות; יציאה='—' עד החתמה). read-only — אין עריכת-נוכחות.
- **עובד:** ללא שינוי-מראה — clockIn מטביע employerId ברקע (worker_attendance_screen + כפתור-GPS בבית). שליחים לא-נגעו.
- **אימות:** analyze 0-errors (5 קבצים) · +26 טסטים · supervisor CLEAN (10/10) · mutation RED→GREEN (employer-scope).

## גל G1 — העובד פותח משימה + מקטע-אישור-הצעות בלוח-הקבלן — 2026-06-14
- **עובד (`worker_app_screen`):** כפתור '➕ הוסף משימה' (גיליון: שם/פירוט/ימים/שלבים) → `proposeTask` → המשימה מופיעה במקטע חדש '📝 הצעות שממתינות לאישור' עם תווית '📝 הוצעה' (מוחרגת מטבעת-ההתקדמות `total`).
- **קבלן (`tasks_screen`):** מקטע נפרד '📝 משימות שהעובד הציע (N)' מתחת לאישורי-ההשלמה — ✅אשר/❌דחה → `approveProposal`/`rejectProposal` + צ'אט th-worker-contractor (פעמון מהמנוע, לא כפול).
- **המפקח תפס:** ההצעה לא-נראתה-לעובד (3 דליים בלבד) → תוקן במקטע ייעודי + החרגה מ-total (כנות + סגירת drift-בספירה).
- **אימות:** analyze 0-errors · +15 טסטים · supervisor CLEAN · mutation RED→GREEN (בידוד-guard).

## גל G2 — מסך גאנט-משימות + שיבוץ-תאריך — 2026-06-14
- **מסך חדש `tasks_gantt_sheet` (read-only):** '📊 גאנט משימות' — בר פרופורציונלי לכל משימה משובצת (תאריך-התחלה אמיתי dd.MM + N ימים + אחוז-ביצוע), ומקטע '🗓️ ללא תאריך מתוזמן' למשימות בלי scheduledStart (אין-המצאת-תאריך). נגיש מלוח-הקבלן (contractor-gantt-entry) ומלוח-העובד (worker-gantt-entry).
- **קבלן (`tasks_screen`):** `_TaskAuthorSheet` קיבל בורר-תאריך '📅 תאריך התחלה (לגאנט)' (author-start) → נשמר ב-createTask/editTask.
- **אימות:** analyze 0-errors · +23 טסטים · supervisor CLEAN (10/10) · mutation RED→GREEN (len≥1).

## גל G3 — מסך ליקויים (פתיחה/דיווח/רשימה) — 2026-06-14
- **מסך חדש `defects_sheet` (🔧 ליקויים, תלוי-תפקיד):** הקבלן — '➕ פתח ליקוי' (שם/מיקום/חומרה) → משימת-ליקוי pending; העובד — '➕ דווח ליקוי' → proposed (אישור דרך בלוק-ההצעות של G1). רשימת-ליקויים עם מיקום/חומרה/סטטוס (מוצגים רק כשקיימים — אין-המצאה). נגיש מלוח-הקבלן (contractor-defects-entry) ומלוח-העובד (worker-defects-entry).
- **תיקון-מפקח:** ליקוי-שהקבלן-פתח נחתם ב-employerId ריק → לא הופיע ברשימת-הקבלן; תוקן ל-kDemoContractorId.
- **אימות:** analyze 0-errors (מסך-חדש נקי) · +29 טסטים · supervisor (תפס scope→תוקן) · mutation RED→GREEN (kind filter).
## #C11 — Apple-readiness HIDE-pass: placeholders "בבנייה"/"בקרוב"/"(הדגמה)" מוסתרים (הפיך) — 2026-06-14

**שינוי:** ל-App Store review הוסתר כל placeholder גלוי של פיצ׳ר backend-blocked, דרך דגל-קומפילציה יחיד `kHideUnderConstruction` (`lib/state/under_construction.dart`, default true; הפיך — flip מחזיר הכל).
- **מסכי-הגדרות:** ה-`_SectionTile` מסנן מ-`children` כל `_PlaceholderRow`/`_Inert.underConstruction`/`_SwitchRow.requiresServer`, ומרנדר `SizedBox.shrink()` לסקשן כולו-בבנייה או שכל שורותיו סוננו (store/notif/chat/catalog; ~79 פריטים). courier — ללא placeholders.
- **AI-hub:** 3 ה-tiles deferred (התאמה משולשת/מזג-אוויר/זיהוי-בלאי · "⚙️ בפרודקשן") מסוננים מהרשת; הברז האמיתי 'סריקת תוכניות' (C7) **נשאר**.
- **חיפוש:** `kVisibleSearchIndex` משמיט את 3 ה-deferred.
- **צ׳אט:** שורות-צירוף "מסמך"/"מיקום" ("לא זמין בדמו") מוסתרות — נשאר "מצלמה".
- **portal:** הערות "נתוני הדגמה"/"זמינות להדגמה" מוסתרות (הנתונים עצמם נשארים).
- **persona_picking:** כפתור 'ביטול ההזמנה כולה — בקרוב' מוסתר כשלא-מחווט.
- **משימות:** clause "(בהדגמה…)" + suffix toast "(הדגמה)" מותנים בדגל.
- **לא הוסתר:** מחלקות-ריקות (בעלים) · electrician/renovation + קטגוריות-קטלוג חסרות-תוכן (sanctioned) · שפה ar/en (#53) · "מצב הדגמה" badge (session-indicator) · GPS/map/nav (C6) · worker-board.

**אימות (בדיקת-widget+data):** `apple_readiness_hide_pass_test` (search filtered/reversible · `AIHubScreen.visibleToolIds` 6 ללא-deferred · B6 sort/filter · source-guard) · `settings_honesty_test` עודכן (placeholders findsNothing + שורה-פונקציונלית findsOneWidget). analyze 0-errors · full-suite +2300 · build web ✅ · mutation-verified (§mutation_log).

## #C11 סבב-3 — דליפות "(הדגמה)"/"בקרוב" נוספות (מסקירת-audit) נסגרו (הפיך) — 2026-06-14

**שינוי גלוי-לעין (6 דליפות נגישות):**
- **משימות-צוות (board מנהל):** כפתור-העובד "דווח על הביצוע" פתח-קודם שקר-הצלחה — toast "תמונה צורפה" בלי תמונה (שמר marker 'demo'). כעת פותח **מצלמה אמיתית** (`pickTaskPhoto`, כמו ה-sheet) → ביטול=toast 'לא צולמה תמונה'; צילום=toast '📷 תמונת ההוכחה צורפה'. אזור "תמונת ביצוע" עבר מקופסה-אפורה-סטטית ל-`taskPhotoWidget` המשותף (מציג תמונה אמיתית).
- **תמונת-הוכחה (כל ה-sites):** ה-marker הלגאסי 'demo' שהציג "📷 תמונה מהשטח (הדגמה)" — כעת **לא מוצג כלל** (`SizedBox.shrink`) ב-worker-sheet · manager-approvals · POD-preview. תמונה אמיתית לא מושפעת.
- **קטלוג-מותג ליפסקי:** 2 קטגוריות ריקות ("אמבט ואגנית"/"מאספים וקולטים") שהציגו badge "בקרוב" מעומעם — מסוננות מהרשת (וספירת-הכותרת מתעדכנת). [ביטול החלטת-"נשאר" של סבב-2.]
- **לוח-חנות:** כפתור "➕ סימולציית הזמנה נכנסת (כלי הדגמה)" מוסתר.
- **פרופיל-מנהל:** badge "מצב הדגמה" מוסתר. [ביטול החלטת-"נשאר".] · **welcome:** "עדיין אין שרת התחברות … (דוגמה)" רוכך ל"נכנסים כאורח כדי לעיין באפליקציה."

**הפיך:** הכל מאחורי `kHideUnderConstruction`; const/seeds/widgets נשארים — flip מחזיר.
**אימות:** `apple_readiness_missed_leaks_test` 12/12 (helper-demo→shrink · data-URL-אמיתי-לא-מוסתר · lipskey-filter+const-הפיך · 6 source-guards) · analyze 6-הנגועים **0-errors/0-warnings** · color-ratchet ירוק · full-suite **+2397 -1** (ה-1 = `worker_reports_drilldown` קיים-מראש) · build web ✅ · mutation red `+4 -1`→green `+12` (§mutation_log). **לא נגעתי:** worker-board-v3/GPS/4-מחלקות-ריקות/docs_readiness_gate/backend-gating.

## #G4 — טלמטרי (Crashlytics+Analytics) — שינוי לא-ויזואלי במסכים — 2026-06-14

**שינוי:** `store_screen.dart` + `manager_role_assign_sheet.dart` קיבלו **רק קריאות-טלמטרי** (side-effects): `order_placed` אחרי checkout מוצלח, `role_assigned`/`logError` אחרי הקצאת-תפקיד. **אין שום שינוי-רינדור/widget** — אותו עץ-UI בדיוק, רק לוג ברקע כשיש Firebase. לכן אין screenshot; האימות הוא קריאת-ה-diff + `telemetry_test` (8/8) שמוכיח שה-sink הוא no-op בלי Firebase (דמו byte-identical).
**אימות:** `telemetry_test` 8/8 · analyze 0-errors · full-suite **+2406 -1** (ה-1 = worker_reports_drilldown הידוע) · build web ✅ · mutation red→green (§mutation_log).

## #A13-consumer — חיווט CONSUMER ל-computeCredit (תצוגת-אשראי-מנהל) — שינוי מקור-נתונים, OFF byte-identical — 2026-06-14

**שינוי:** sheet-הפירוט של 👥 לקוחות (`_CustomerDetailSheet`, מסך-מנהל) — שורת `מסגרת אשראי` (וכן אריח `אשראי`=`livePct` ושורת `יתרה זמינה`=`balance`) כעת מקבלת את תקרת-האשראי דרך ה-seam `computeCredit` (`customerCreditProvider`) במקום מ-ה-aggregate ה-SYNC בלבד. **אין שינוי-layout/widget** — אותו עץ-UI, אותן שורות, רק מקור-הספרה השתנה.

**OFF byte-identical (אין שינוי-נראה):** ברירת-המחדל (`kServerCallables` OFF · כל ה-demo) — ה-repo `computeCredit` מחזיר את ה-derivation המקומית, שהיא byte-identical ל-sync (`creditLimit == contractorCredit(name)`). ה-sheet מציג את ה-`c.creditLimit` ה-SYNC **מיד** (fallback) ומעדן אל הערך-הנפתר — OFF השניים שווים, אז **המספר המוצג זהה לחלוטין להיום, ואין flicker** (אין frame עם מספר שונה/ריק). לכן אין screenshot — האימות הוא קריאת-ה-diff + ה-widget-test. רק ON + gateway-bound (ממתין-לבעלים: deploy + flag) מעלה את הספרה לערך ה-server-canonical.

**הפיך:** הכל מאחורי `kServerCallables` (compile-time, OFF) + ה-gating הפנימי של ה-repo; flip-בלבד משנה התנהגות.
**אימות:** `manager_credit_computecredit_consumer_test` 3/3 (OFF: seam-reached דרך spy-repo + ספרה-מקומית · OFF: server-figure לעולם-לא-מופיע · ON: שדרוג ל-server-figure) · `manager_dashboard_screen_test` (sheet-detail הקיים) נשאר ירוק (label+ספרה-מקומית OFF) · analyze screen 0-חדש / test 0-issues / אפס raw-color · full-suite (ה-`-1` היחיד = `worker_reports_drilldown` הקיים-מראש) · build web ✅ · mutation red `+2 -1`→green `+3` (§mutation_log). **לא נגעתי:** geo/site_hub/manifest/pubspec (סוכן מקביל GPS) · worker-board / 4 המחלקות · F1/firebase_options · ה-repo/gateway/function של computeCredit (כבר היו).

---

## #C6 — GPS אמיתי ל-site-hub נוכחות (T2.4) — טקסט-טוסט כן כשאין-fix, אותו עץ-UI — 2026-06-14

**שינוי:** מסך 📍 נוכחות (`_SiteAttendance` ב-`site_hub_screen.dart`) — לחיצת "החתם כניסה 📍" כעת קוראת `currentGeoFix()` (geolocator נטיב / `geo_web.dart` בדפדפן) במקום להטביע את קואורדינטת-הדמו-הקשיחה `'32.07°N, 34.79°E (±12מ׳)'`. **אין שינוי-layout/widget** — אותו עץ (אותו box-נוכחות, אותו כפתור, אותה כרטיסיית-היסטוריה `📍 ${a.geo}`); רק (א) הקואורדינטה במחרוזת `a.geo` עברה מ-דמו-קבוע ל-fix-אמיתי (`formatGeo(lat,lng,±מטר)`), ו-(ב) **כשאין fix** (הרשאה-מסורבת / שירות-כבוי / שגיאה) ה-string הוא `'מיקום לא זמין'` (לא קואורדינטה) וה-טוסט הופך מ-'כניסה נרשמה ב-HH:MM 📍' ל-`'מיקום לא זמין — כניסה נרשמה ב-HH:MM בלי מיקום'` (אותו idiom-כן בדיוק כמו ה-worker clock-in הקיים, `worker_attendance_screen`/`worker_app_screen`). ה-יציאה ללא-שינוי.

**אין screenshot — למה:** השינוי הוא טקסט-תוכן (מחרוזת `geo` + מחרוזת-טוסט) בתוך widgets קיימים שלא שינו צורה/צבע/פריסה; ה-toast/string מאומתים ב-widget-state-test (`site_hub_state_test` — `clockIn` בלי-fix→`kGeoUnavailable`='מיקום לא זמין', עם-fix→הקואורדינטה verbatim; `formatGeo` N/E·S/W·עיגול-מטר). ההתנהגות-הויזואלית-החדשה היחידה (מצב "מיקום לא זמין") היא מצב-ריק-כן מבוקש מפורשות.

**הפיך:** ה-seam additive — web byte-identical (`geo_web.dart` עדיין נבחר); נטיב עבר מ-null-stub ל-geolocator חי. אפס Color/`value:`/`activeColor:` חדש.
**אימות:** `geo_gate_test` (+13) · `geo_permissions_source_test` (+6) · `site_hub_state_test` (net +5) · analyze 0-errors (geo_native/geo_gate/2-טסטים = 0 issues; info שנותרו קיימים-מראש) · full-suite **+2448 -1** (ה-`-1` היחיד = `worker_reports_drilldown` הקיים-מראש) · build web ✅ (0 geolocator ב-main.dart.js) · mutation red `+7 -2`→green `+9` (§mutation_log). **לא נגעתי:** מסכי/UI worker-board / clock-in (נחיל-העובדים) · manager-credit (סוכן מקביל) · 4 המחלקות · F1 · `nav_launch`.

## #auth-gate — הרשמה אמיתית + שער-כניסה (flag ON) — 2026-06-14

**שינוי (גלוי רק כש-`useFirebaseBackend` ON):** מסך-welcome "אישור והמשך" קיבל **שדה-סיסמה** ויוצר חשבון-Firebase אמיתי (במקום register-מקומי); ל-login_sheet email-pane נוסף toggle **"צור חשבון"**; כניסת-"דמו" מסומנת בבירור כדמו; profile — שורת-כניסה + 🚪 התנתקות. flag OFF = הזרימה הנוכחית verbatim (אפס-רגרסיה).
**אימות (בדיקת-widget):** `login_sheet_test` +20 (create-account · toasts-עבריים · role-gate · profile login/logout/delete) · `welcome_auth_gate_test` · analyze 0-errors · full-suite **+2475 -1** (baseline) · build web ✅ · mutation red `+10 -2`→green +20 (§mutation_log).

## #order-sync-fix — באדג'-דיאגנוסטיקה מורחב (4 צעדי self-test) + תיקון סנכרון-הזמנות — 2026-06-14

**שינוי גלוי (דיאגנוסטיקה בלבד, זמני):** ה-`BackendDebugBadge` הקיים (הצ'יפ בראש-המסך 🟢שרת/🔴דמו) הורחב: כפתור "🔌 בדוק חיבור לשרת" כעת מריץ **4 צעדים** ומדפיס שורת-תוצאה לכל אחד (✅ או ❌+הקוד-המדויק):
1. **כתיבה/קריאה `diag/{uid}`** — "מחובר ומשהו נשמר?" (ה-baseline שהבעלים ביקש).
2. **כתיבת `users/{uid}`** — מותר לכל מחובר (אין-תפקיד) ⇒ מבדיל "מחובר" מ-"אין-תפקיד".
3. **שאילתת ההזמנות שלי** — `where('contractorUid'==uid).orderBy('ts' desc).limit(1)`, **בדיוק** הקריאה שהמכשיר-השני מריץ; index-חסר מופיע כאן כ-`failed-precondition` + **ה-URL ליצירת-index**.
4. **יצירת הזמנה (בדיקה)** — כותב מסמך-הזמנה-עצמי אמיתי (ואז מנקה); דחיית-rules מופיעה כאן כ-`permission-denied` — **זה ה-smoking-gun** של הבאג (ההזמנה לא מגיעה לשרת).
הכותרת: כש-הכול עבר → "✅ הכול עבר! ההזמנות יסונכרנו בין המכשירים"; אחרת → "❌ נמצאה תקלה — הצעד שנכשל מראה את הקוד המדויק".

**איך מפעילים:** ב-debug — הבאדג' תמיד מורכב; ב-APK-חתום (release) — `flutter build … --dart-define=FS_DIAG=true` (+`--dart-define=USE_FIREBASE_BACKEND=true`), אז להקיש על הצ'יפ → "בדוק חיבור לשרת". (בלי `FS_DIAG` ה-release לא מראה כלום — מדיניות-הבעלים.)

**אין screenshot — למה:** הצ'יפ קיים מראש (אותו עץ-widget, אותו צבע/פריסה — `modeColor`/`_panel` קיימים); השינוי הוא **תוכן-טקסט** (4 שורות-תוצאה במקום 1) בתוך אותו פאנל. אין מצב-ויזואלי-חדש מלבד טקסט-תוצאה — הלוגיקה (מיפוי הצלחה/שגיאה→שורה) מאומתת ב-`fsDiagStepResult` (4 טסטים headless). ה-self-test האמיתי מול Firestore = on-device בלבד (לא headless).

**OFF byte-identical:** `kFsDiag` + `kUidScopedQueries` שניהם compile-time OFF ⇒ ה-gate `debugOverlayChildren` נשאר `isDebug` בלבד (release לא-מראה כלום), וה-scope של ה-orders נשאר whole-collection — בדיוק כהיום. ה-rules+index הם server-side (אינם משפיעים על בייטי-האפליקציה). אפס `Color(0x…)`/`value:`/`activeColor:` חדש (השתמשתי בקבועי-הצבע הקיימים בקובץ).

**הפיך:** הדיאגנוסטיקה + ה-flag `FS_DIAG` מסומנים "REMOVE after go-live"; ה-fix של ה-rules/index הוא קבוע (תיקון-באג). **אימות:** `orders_sync_scope_index_diag_test` 13/13 (scope-fields · index↔toDoc · 4 mappings) · `debug_badge_gate_test` נשאר ירוק (FS_DIAG=false בטסט ⇒ gate ללא-שינוי) · analyze 0-errors · full-suite (ה-`-1` היחיד = `worker_reports_drilldown` baseline) · build web ✅ · mutation red `+5 -1`→green `+11` (§mutation_log). **לא נגעתי:** worker-board / 4 מחלקות / auth-gate / firebase_options / manager-credit / geo.

## #manager-owner — מנהל = בעלים: בלי logout, בלי demo (שלב 1/4) — 2026-06-15

**שינוי גלוי:** (א) לוח-המנהל (מרכז השליטה) — נעלם כפתור ה-logout מסרגל-הפעולות; נשארו 💬 שיחות · 👤 פרופיל · ⚙️ הגדרות · '‹ יציאה' (ניווט-בלבד). (ב) פרופיל-המנהל — נעלמה שורת '🚪 יציאה מהחשבון'; נשארו ⚙️ הגדרות + 🔁 החלפת תפקיד. (ג) שער-הכניסה ללוח-המנהל — נעלם כפתור "מצב דמו"; עובד/שליח/ספק עדיין מציגים אותו.

**אין screenshot — למה:** השינוי הוא **הסרת אלמנטים** (כפתורים/שורה) מעצים-קיימים שלא שינו צורה/צבע/פריסה; אין מצב-ויזואלי-חדש. ההיעדרות מאומתת בהעדר-רגרסיה בטסטי-המסך (manager_dashboard_screen_test ירוק; אין טסט שמקיש על ה-logout/demo שהוסרו).

**הפיך:** הסרת-affordance בלבד; המודל (`logout()`/`enterDemo()`) נשאר callable. אפס Color/value:/activeColor: חדש.
**אימות:** analyze 0-errors · full-suite **+2626 -1** (ה-`-1` היחיד = `worker_reports_drilldown` baseline; 0 חדשים) · isolation manager_dashboard/apple_readiness/widget ירוקים. **לא נגעתי:** board_auth model / עובד·שליח·ספק / auth-gate.

## #manager-owner — שער-מנהל "כניסה עם Google" (שלב 2/4) — 2026-06-15

**שינוי גלוי:** שער כניסת-המנהל (welcome ב-role-mode עבור manager) הוחלף לחלוטין: במקום "כניסה ללקוח קיים" + שדות שם-משתמש/קוד, מוצג עכשיו כותרת "כניסת מנהל המערכת" + שורת-הסבר + כפתור כתום יחיד **"המשך עם Google"** (FilledButton.icon, אייקון login, ספינר בזמן טעינה). אין שדה-קוד ואין "מצב דמו". כשאין Firebase — במקום הכפתור מוצגת כרטיסיה צהובה כנה: "כניסת מנהל דורשת חיבור לאינטרנט". שאר הלוחות (עובד/שליח/ספק) — שער ה-seed ללא-שינוי.

**אין screenshot — למה:** רכיבים סטנדרטיים (FilledButton.icon + Text + Container צהוב) על אותו עץ-welcome; ההסתעפות (כפתור מול הודעה) + זרימת-הכניסה (בעלים→מנהל, זר→דחייה+טוסט, בלי-Firebase→הודעה) מאומתות ב-`manager_google_login_test` (widget-tests). אין מצב-ויזואלי-חדש מעבר לשניים אלה.

**הפיך:** השער מסתעף על `role==manager` בלבד; שאר הפרסונות verbatim. אפס Color/value:/activeColor: חדש (BsTokens + צבעי-אזהרה קיימים). flag-OFF: ה-DATA נשאר demo; ה-auth-gateway live כש-Firebase אותחל אך signed-out ⇒ התנהגות זהה כשאיש לא נכנס.
**אימות:** analyze 0-errors · full-suite **+2632 -1** (baseline) · mutation §mutation_log. **caveat בעלים:** דורש 3 צעדי Firebase-Console (`knowledge/owner/google-signin-setup.md`). **לא נגעתי:** worker-board / 4 מחלקות.
### #E3-leak-fix — worker_employer_stock_sheet: scope-key uid→username (לוגיקה-בלבד) — 2026-06-15
**אין screenshot — למה:** השינוי בקובץ-המסך הוא מפתח-ה-scope של רשימת "הבקשות שלי" בלבד — `requestsForWorker(session.uid)` → `requestsForWorker(session.username)` (+`username` בקריאת-ה-submit). **אפס שינוי פריסה/צבע/widget** — אותו עץ, אותו עיצוב. ההשפעה הנראית-לעין היחידה: העובד רואה כעת רק את בקשות-החומר שלו (לפני-כן, בגלל uid ריק לכל עובד seed/demo, ראה את של כולם). למשתמש-יחיד הרשימה זהה לחלוטין.
**אימות:** ההתנהגות (בידוד פר-עובד) מאומתת ב-`material_requests_test` (טסט-בידוד seed-session, mutation RED `+7 -1`→GREEN `+8` §mutation_log) — בידוד רב-עובדים אינו ניתן-לאימות-בצילום-בודד (דורש שתי הפעלות). analyze 0 · full-suite ירוק. **לא נגעתי** בפריסה/עיצוב/צבעים של הגיליון.

## 2026-06-15 — #A2-hr-decide-once — contractor_hr_sheet: gate side-effects על decide-bool (לוגיקה-בלבד)
**אין screenshot — למה:** השינוי בקובץ-המסך הוא 2 שורות בכל מתודת-החלטה — `final fired = approve ? notifier.approve(id) : notifier.reject(id); if (!fired) return;` לפני בלוק-ה-side-effects הקיים. **אפס שינוי פריסה/צבע/widget** — אותו עץ. ההשפעה הנראית: פעמון/צ'אט/toast יורים פעם-אחת במקום פעמיים ב-double-tap. מאומת ב-`hr_decide_once_test` (engine-level, mutation RED→GREEN §mutation_log). analyze 0.

## 2026-06-15 — #A3-pod-signature — persona_pod_sheet: toast לא-משקר אחרי await (לוגיקה-בלבד)
**אין screenshot — למה:** השינוי בקובץ-המסך הוא ב-onPressed של כפתור-החתימה הקיים: `final ok = await fn.captureSignature(...)` ואז `showToast(ok ? 'נשמרה ✍️' : 'לא נשמרה — נסה שוב')`. אפס שינוי פריסה/widget — אותו כפתור, אותו עיצוב. ההשפעה הנראית: בכשל-אחסון מופיע "לא נשמרה — נסה שוב" במקום "נשמרה" שקרית. מאומת ב-persona_fulfillment_test (engine-level, mutation RED→GREEN §mutation_log). analyze 0.

## 2026-06-15 — #A4-dst-day-idiom — worker/courier reports: dayIdx+weekStart דרך עוזר DST-safe (לוגיקה-בלבד)
**אין screenshot — למה:** השינוי בשני קבצי-המסך הוא 3 שורות בכל אחד — שורת ה-import של calendar_days, `weekStart = startOfWeekSunday(today)` (במקום subtract Duration), ו-`dayIdx = daysBetweenDst(weekStart, c/d)` (במקום DateTime difference inDays). אפס שינוי פריסה/widget/צבע — אותה היסטוגרמת-שבוע, אותו עיצוב. ההשפעה הנראית מופיעה רק על גבול-DST (שבוע ה-spring-forward/fall-back): הדלי-יומי נכון במקום נסחף-ביום. מאומת ב-calendar_days_test (pure, mutation RED→GREEN §mutation_log, TZ=Israel). analyze 0.

## 2026-06-15 — #A5-board-proposed-fold — worker_task_board: proposed מופיע תחת בתור (שינוי-נראות)
**שינוי נראה (בלי screenshot — pure-verified):** משימה ב-status proposed שהייתה קודם בלתי-נראית בלוח מופיעה כעת תחת קבוצת "⏳ בתור" (יחד עם pending). אין שינוי בעיצוב/פריסת ה-_StatusGroup עצמו — אותו widget, אותו סגנון; רק תוכן-הדלי השתנה (כיסוי מלא של ה-statuses). מאומת ב-groupByStatus הטהורה (worker_task_board_group_test, mutation RED→GREEN §mutation_log) — הסכום-על-הקבוצות שווה ל-total. analyze 0.

## 2026-06-15 — #52-order-notif-to-orders-world — 🔔 בטאב הזמנות + הסרה מהגדרות
**שינוי נראה (בלי screenshot — widget-verified):** בטאב 📦 הזמנות (store_screen) נוסף כפתור 🔔 בכותרת המקטע — גלוי רק כשהמקטע=הזמנות — שפותח גיליון תחתון "🔔 התראות הזמנות ומשלוחים" עם 2 toggles. במסך ההגדרות › התראות, שורות "הזמנות" plus "משלוחים" הוסרו ממקטע 🔔 (שאר ה-types נשארו). אין שינוי-עיצוב לרכיבים קיימים — 🔔 הוא IconButton סטנדרטי, הגיליון SwitchListTile-ים סטנדרטיים. מאומת ב-order_notif_sheet_test (mutation RED→GREEN §mutation_log) plus 2 טסטי-מסך קיימים ירוקים. analyze 0.

## 2026-06-15 — #50-settings-merge-dup-categories — catalog_settings: 13→11 מקטעים (מיזוג כפולים)
**שינוי נראה (בלי screenshot — 4 טסטי-מסך ירוקים):** במסך 'הגדרות' שני מקטעי-🔔 הפכו ל-🔔 'התראות' יחיד (כולל המשפחה מ-'התראות קטלוג'), ושני מקטעי-תצוגה הפכו ל-'תצוגה ומיון' יחיד (theme plus view/sort/grid/image plus סידור-בית). price-drop יחיד ('ירידת מחיר במועדפים'). אין שינוי-עיצוב ל-_SectionTile/_SwitchRow עצמם — אותם רכיבים, פחות מקטעים. מאומת ב-catalog_sort_alerts (טאפ 'התראות'+'תצוגה ומיון', toggling שדות מקופלים, mutation RED→GREEN §mutation_log) plus robustness/settings_honesty render. analyze 0.

## 2026-06-15 — #54-remove-favorites-category — catalog_settings: הקטגוריה ❤️ הוסרה (10 מקטעים)
**שינוי נראה (בלי screenshot — 4 טסטי-מסך ירוקים):** במסך 'הגדרות' המקטע ❤️ 'מועדפים ורשימות' אינו מוצג עוד (10 מקטעים במקום 11). אין שינוי-עיצוב לרכיבים אחרים. מאומת ב-catalog_sort_alerts (טסט findsNothing — RED בעוד המקטע קיים → GREEN אחרי הסרה §mutation_log) plus robustness/settings_honesty render. analyze 0.

## 2026-06-15 — #49-wire-supplier-prefs — catalog_settings: ספקים מועדפים מחווט (3 פקדים אמיתיים)
**שינוי נראה (בלי screenshot — widget-test ירוק):** מקטע '🏪 ספקים מועדפים' — 3 השורות הראשונות שהיו placeholders ("בבנייה") הן עכשיו פקדים אמיתיים: 'מרחק מקסימלי' (_NumberRow 5-300 ק"מ), 'דירוג מינימלי' (radio הכל/3+/4+/5), 'ספקים מקומיים בלבד' (switch). 'ספקים מסומנים כמועדפים'/'ספקים חסומים' נשארו placeholders (seam). מאומת ב-catalog_sort_alerts (tap → localSuppliersOnly נשמר, mutation RED→GREEN §mutation_log) plus robustness render. analyze 0.

## 2026-06-16 — #36-voice-dictate-worker-board — מיקרופון בשדות הצעת-המשימה (לוח עובד)
**שינוי נראה (בלי screenshot — widget-test ירוק):** בגיליון "הצע משימה" בלוח-העובד, 3 שדות-הטקסט (שם/תיאור/שלבים) קיבלו suffixIcon 🎤 (Icons.mic_none, אדום בזמן הקלטה Icons.mic). לחיצה מתחילה הכתבה קולית שמצרפת לשדה; לחיצה-שנייה עוצרת. אין שינוי-פריסה אחר — IconButton סטנדרטי בתוך ה-InputDecoration הקיים. מאומת ב-voice_dictate_button_test (fake-STT → controller מתמלא, mutation RED→GREEN §mutation_log). analyze 0.

## 2026-06-16 — #45-weather-open-meteo — _Weather: תחזית אמיתית במקום seed
**שינוי נראה (בלי screenshot — mapper נבדק + robustness render):** בכלי 🌦️ אוטומציית-מזג-אוויר (ai_hub), הכרטיסים מציגים עכשיו תחזית אמיתית מ-Open-Meteo לפי מיקום-המכשיר (כשזמין); ההערה "בפרודקשן API חיצוני" הוחלפה ב-"🌦️ תחזית Open-Meteo · לפי מיקום המכשיר". אין שינוי-פריסה לכרטיסים — אותו AiCard, רק מקור-הדאטה. ב-VM אין GPS → fallback ל-seed (המסך מרנדר כרגיל). מאומת ב-weather_service_test (mapper, mutation RED→GREEN §mutation_log) plus robustness render. analyze 0.

## #manager-owner — מנהל: מעבר בין מסכים (התחזות · שלב 3/4) — 2026-06-16

**שינוי גלוי:** (א) בפרופיל-המנהל הפעולה "🔁 החלפת תפקיד (מוגן בקוד)" הוחלפה ב-"🖥️ מעבר בין מסכים · צפייה בכל לוח — מצב מנהל". (ב) הקשה פותחת sheet עם 4 יעדים (🦺 עובד · 🛵 שליח · 🏪 חנות ספק · 👷 קבלן). (ג) בחירת יעד פותחת את הלוח עם **באנר כתום עליון** "👔 צפייה כ-X · מצב מנהל" + כפתור "חזרה לניהול"; חזרה (כפתור/back) מחזירה את session-המנהל.

**אין screenshot — למה:** רכיבים סטנדרטיים (modal sheet + ListTiles + Material banner) על idiom קיים; זרימת-ההתחזות (manager→seed→back · no-op-ללא-מנהל · store-בלי-employer) מאומתת ב-`manager_impersonate_test`. אין מצב-ויזואלי-חדש מעבר לבאנר (Row פשוט).

**הפיך:** ה-session-swap ephemeral (לא נשמר); שערי-הלוחות לא נגעו. אפס Color/value:/activeColor: חדש (BsTokens + brandDark הקיים).
**אימות:** analyze 0-errors · full-suite **+2675 -1** (baseline) · manager_impersonate_test 3/3. **לא נגעתי:** worker/courier/store gates.
## 2026-06-16 — #31-help-coverage-wave1 — מצב-היכרות: chrome ראשי של הקבלן
**שינוי נראה (בלי screenshot — 2 טסטי-מסך ירוקים):** במצב-היכרות (💡) במסך-הבית, אלמנטים נוספים בסרגל-העליון מודגשים וניתנים-להסבר: הלוגו (החלפת לוח/זהות), שבב-השם (פרופיל), חיפוש, ותפריט ה-⋮ (מותאם לטאב). לחיצה על אחד מ-4 הטאבים התחתונים במצב-היכרות פותחת כרטיס-הסבר ("הבנתי" לסגירה) במקום לנווט. מחוץ למצב-היכרות — אפס שינוי-התנהגות. מאומת ב-help_coverage_test (mutation RED→GREEN §mutation_log) plus full analyze 0.

## 2026-06-16 — #31-help-coverage-wave2 — מצב-היכרות בלוח השליח
**שינוי נראה (בלי screenshot — 2 טסטי-מסך ירוקים):** ב-AppBar של לוח-השליח נוסף כפתור 💡 (כמו בלוח-העובד) — לחיצה מפעילה מצב-היכרות. במצב זה הפעמון, הפרופיל, ההגדרות, היציאה ובורר-הרכב מודגשים וניתנים-להסבר; לחיצה על אחד מ-4 הטאבים התחתונים פותחת כרטיס-הסבר ("הבנתי") במקום להחליף טאב. מחוץ למצב — אפס שינוי-התנהגות. מאומת ב-help_coverage_courier_test (mutation RED→GREEN §mutation_log) plus analyze 0.

## 2026-06-16 — #31-helpfix-bottomnav — טאבים תחתונים מודגשים + בועה מעוגנת
**שינוי נראה (אומת חי בדפדפן + 2 טסטי-מסך):** במצב-היכרות, 4 הטאבים התחתונים (קבלן: בית/מחלקות/עדכונים/חנות · שליח: משלוחים/פורטל/דוחות/אזור אישי) מקבלים עכשיו **טבעת כתומה** ולחיצה פותחת **בועת-הסבר שיוצאת מהטאב** (זנב מצביע עליו) — במקום הכרטיס-המרכזי הקודם. מחוץ למצב-היכרות הניווט זהה (אותם אייקונים+תוויות, כתום כשנבחר). ה-BottomNavigationBar הוחלף ב-Material+Row של BottomNavCell. analyze 0.

## 2026-06-16 — #31-helpcov-wave3 — מצב-היכרות בלוח החנות
**שינוי נראה (2 טסטי-מסך ירוקים):** ב-AppBar של לוח-החנות נוסף 💡 (מצב-היכרות). במצב זה הפעמון/אזור-אישי/הגדרות/התנתקות/יציאה מודגשים, ו-5 הטאבים התחתונים (בית/מלאי/שיחות/פורטל/אזור-אישי) מקבלים טבעת כתומה + בועה-מעוגנת בלחיצה (BottomNavCell במקום BottomNavigationBar). מחוץ למצב — אפס שינוי-התנהגות. analyze 0.

## 2026-06-16 — #31-swarm-wave — כיסוי מצב-היכרות: מנהל + עובד-עמוק + שליח-עמוק
**שינוי נראה (central-verify GATE PASS, +2682 טסטים):** במצב-היכרות, 89 אלמנטים נוספים ב-3 לוחות מקבלים טבעת כתומה + בועת-הסבר: לוח-המנהל (💡 חדש ב-AppBar + 3 אייקוני-סרגל + 4 טאבי-toggle עליון + צ'יפים/כרטיסים/קדם-שלב/אישורי-משימה/שיוך-תפקיד), אזור-אישי+דוחות+רצועת-יום+פעמון של העובד, וכל מסכי-השליח העמוקים (כפתורי קידום-משלוח/POD, 6 אריחי-פורטל, פרופיל, הגדרות, דוחות, טפסים, נוכחות, תעודות — חלקם קיבלו 💡 toggle חדש). מחוץ למצב — אפס שינוי-התנהגות. analyze 0.

## 2026-06-16 — #chat-delivery-status — צ׳ק-מרק אמיתי לכל הודעה (🕐/✓/✓✓/❌ + "נסה שוב")
**שינוי נראה (analyze 0 · +6 טסטי-repo/מודל · 84 טסטי-צ׳אט+repo ירוקים יחד):** בבועת-הצ׳אט, ה-✓✓ הקוסמטי (שהודלק לכל הודעה ע״י toggle ה-`readReceipts`) הוחלף בצ׳ק-מרק **אמיתי לפי סטטוס-מסירה**:
- 🕐 (`Icons.access_time`, אפור 0xFF999999) = `pending` — כתיבה אופטימית בתעופה;
- ✓ (`Icons.done`, אפור) = `sent` — ב-outbox / demo-local (ברירת-מחדל, כל seed/legacy/demo);
- ✓✓ (`Icons.done_all`, כחול 0xFF4FC3F7) = `delivered` — **אושר ע״י השרת** (snapshot→`fromDoc`); כש-`readReceipts` כבוי, מוגבל ל-✓ אפור יחיד (ה-toggle נשאר משמעותי, ההודעה עדיין delivered מתחת);
- ❌ (`Icons.error_outline`, אדום) + טקסט **"נסה שוב"** לחיץ (אדום, קו-תחתי) = `failed` — הכתיבה ברקע נכשלה; לחיצה מפעילה retry/re-send דרך המנוע.

**למה אין צילום-מסך:** widgets סטנדרטיים בלבד (`Icon`/`Row`/`GestureDetector`/`Text`) — אין asset/layout חדש; RTL ופריסת-הבועה/הצבעים ללא שינוי, רק לוגיקת הצ׳ק-מרק הוחלפה. הרינדור מפוסל ע״י `sys_chat_test.dart` (טסטי-מסך של `ChatsScreen`).

**הפיכות:** לחזרה ל-✓✓-הקוסמטי — להחזיר ב-`_Bubble` את `Icon(readReceipts ? Icons.done_all : Icons.done, ...)` ולהסיר את `_DeliveryStatus`; השדה/enum תוספים ו-default `sent` שומר על seed byte-identical, כך שהמודל יכול להישאר בלי השפעה נראית.

## 2026-06-16 — #connection-indicator — חיווי-חיבור חי ALWAYS-ON (🟢/🔴/דמו) בראש כל מסך
**שינוי נראה (analyze 0 · +2699 -1, רק baseline · אומת ע״י ה-gate הקיים):** נוספה **גלולת-חיווי קבועה (always-on pill) בראש כל מסך** שמשקפת אמיתית האם פעולות יישמרו לשרת:
- 🟢 **"מחובר לשרת"** — גלולה ירוקה (`BsTokens.success` 0xFF22C55E), **קטנה ולא-פולשנית** (`typeCaption` 11px, padding דק, שקיפות 92%) — רשת+מחובר+Firestore חי;
- 🔴 **"מנותק · פעולות לא יישמרו"** — גלולה אדומה (`BsTokens.danger` 0xFFEF4444), **בולטת יותר** (`typeMicro` 12px, w800, אטומה) — אזהרת-איבוד-נתונים כש-wifi כבוי / לא-מחובר / Firestore cache-only;
- **"מצב דמו"** — גלולה אפורה ניטרלית (`BsTokens.chainSlate` 0xFF64748B), כנה — אין שרת אמיתי לטעון אליו חיבור (מסלול ה-demo / no-Firebase), עדינה.

**מיקום:** `Positioned` בראש, RTL, `Alignment.topCenter`, עטוף `IgnorePointer` (לא בולע tap). ב-debug מוסט מטה +44px שלא יתנגש ב-BackendDebugBadge; ב-release הוא לבדו בראש. מעבר-מצב מונפש (`AnimatedContainer`, `microIn` 150ms).

**למה אין צילום-מסך:** widgets סטנדרטיים בלבד (`Positioned`/`Align`/`AnimatedContainer`/`Text`) — אין asset/layout/פונט חדש; טוקני-צבע קיימים (success/danger/chainSlate). הרינדור על המסלול שטסטים מריצים הוא תמיד "מצב דמו" האינרטי (אין Firebase), כך שהמראה החי (🟢/🔴) נצפה רק בבילד-שרת אמיתי.

**הפיכות:** הסרה = למחוק את `const ConnectionIndicator()` מה-Stack ב-`main.dart` (+ ה-import) ולהסיר את שני הקבצים החדשים + `connectivity_plus` מ-pubspec. אין שינוי-מצב שמורה — החיווי הוא קריאה-בלבד (read-only) ולעולם לא כותב.

## 2026-06-16 — #quality-wave1 — ליטוש a11y/ניווט (tooltips · LTR-numeric · 48dp · כפתור-יציאה)
**שינוי נראה (analyze 0 · +2700 -1 רק baseline · ה-perf-memo אומת byte-equivalent):** גל-איכות. הנראה הוא a11y+ניווט בלבד (ה-perf-memo אינו נראה — תוצאה byte-identical):
- **tooltips עבריים** על כפתורי-אייקון שהיו ללא-תווית: `ערוך`/`מחק` (catalog) · `הפחת`/`הוסף` (catalog-settings stepper) · `מחק` (store) — long-press/hover מראה את הפעולה (חשוב ל-screen-reader + בהירות).
- **כיוון-טקסט LTR לשדות-מספר**: טלפון/ת.ז/ח.פ ב-store-dashboard · פרופיל עובד/שליח/חנות · טפסי עובד/שליח · שם-משתמש בכניסת-לוח (welcome) — מספרים+ID נקראים עכשיו שמאל-לימין (טבעי למספרים) בעוד שדות-שם עבריים נשארים RTL. אין שינוי-פריסה, רק כיוון הקלדה/תצוגה של הספרות.
- **יעד-מגע 48dp**: כפתורי +/− ב-install-studio עטופים ב-`SizedBox(48,48)`+`Center`+`HitTestBehavior.opaque` — אזור-הלחיצה גדל לתקן-הנגישות, המראה (האייקון) זהה.
- **טוקן-צבע**: `Color(0xFFAAAAAA)`→`BsTokens.mutedLight` (×3, store) — אחידות עם שאר ה-muted, הפרש-גוון מינימלי.
- **כפתור-יציאה**: ב-`docs_readiness_gate` נוסף AppBar עם `‹ יציאה` (`maybePop`) — קודם המסך היה מלכודת ללא דרך-חזרה גלויה.

**למה אין צילום-מסך:** widgets/מאפיינים סטנדרטיים בלבד (`Tooltip`/`textDirection`/`SizedBox`/`AppBar`/`TextButton`) — אין asset/layout/פונט חדש. ה-a11y-fields אומתו ע״י הסוויטה (+2700; מסכי-הפרופיל/טפסים נבנים בטסטי-מסך); ה-perf-memo ע״י `compat_memo_test` + 75 טסטי compat/system_division ירוקים.

**הפיכות:** כל פריט עצמאי — הסרת `tooltip:`/`textDirection:`/ה-`SizedBox`-wrap/ה-AppBar מחזירה למצב הקודם; ה-memo נשלף ע״י החזרת הגוף ל-`return out;` (ללא ה-cache). אף שינוי לא נוגע ב-state שמור.

## 2026-06-17 — #wave2a-connect — פיננסים נשמרים לשרת (ללא שינוי-מראה)
**שינוי נראה: אין.** השינוי ב-`finance_hub_sheets.dart` הוא **side-effect של שמירה בלבד** על המסלול-המחובר (`if (useFirebaseBackend)`): אישור/דחייה, קנס-איחור ותנאי-תשלום נכתבים עכשיו גם ל-Firestore דרך `FirebaseFinanceRepository`. ה-UI, ה-toasts, וה-state-בזיכרון זהים-לחלוטין; במצב-דמו/טסטים (flags OFF) הקוד החדש כלל לא רץ → byte-identical. אין widget/layout/צבע/טקסט חדש.
**אימות:** `flutter analyze` 0 errors; הפורטים שמאחורי השמירה (`decide`/`addPenalty`/`setPaymentTerm`) מכוסים ב-`finance_firebase_repo_test.dart`. הקריאות (approvals/penalties/payment-term) כבר עברו דרך `financeRepo()` מקודם (CLEAN), כך שהמראה על הבילד-המחובר כבר היה נכון — רק הכתיבה הושלמה.
**הפיכות:** הסרת שלושת בלוקי ה-`if (useFirebaseBackend) { … r.<port>() }` + ה-import של `FirebaseFinanceRepository` מחזירה למצב הקודם (כתיבה-לזיכרון בלבד).

## 2026-06-17 — #wave2b-projects — לוח-פרויקטים ריק כן על המחובר (במקום 3 דמו מזויפים)
**שינוי נראה (רק על הבילד-המחובר; demo/טסטים byte-identical):** קודם משתמש מחובר ראה **3 פרויקטי-דמו מזויפים** (אתר-מגורים/משרדים/וכו') כאילו היו שלו. עכשיו הוא רואה את **מסך הריק-הכן שכבר היה בנוי**: 🏗️ "אין פרויקטים עדיין" + "צרו פרויקט חדש כדי לנהל סל, תקציב ומשימות לכל אתר" + כפתור "פרויקט חדש". במצב-דמו — בדיוק 3 הפרויקטים כמו קודם (אפס שינוי). כותרת "פרויקט חכם" נופלת לטקסט גנרי כשאין active (כבר היה מטופל ב-`smart_project_screen:50`).
**למה אין צילום:** אין widget/asset/layout חדש — רק נתיב-הנתונים השתנה (המנוע קורא את חוזה-השרת). מסכי-הריק והכותרת-הגנרית כבר היו קיימים; אומת ב-`projects_server_empty_test` (+2, empty→ללא-קריסה) + 14 טסטי tasks/smart-project ירוקים.
**הפיכות:** להחזיר את `projectsProvider` ל-`if (repo is LocalSiteRepository) {seed()} else ProjectsNotifier()` + להסיר את ה-guard ב-`active` — חוזר למצב הקודם (3 דמו על המחובר).

## 2026-06-17 — #wave2b-customerlist — מסגרת-אשראי חיה בכרטיסי רשימת-הלקוחות
**שינוי נראה (רק על המחובר; demo/טסטים byte-identical):** בכרטיס-לקוח ברשימת לוח-המנהל, מספר **מסגרת-האשראי** (ושורת "ניצול אשראי: ₪נוצל / ₪מסגרת (אחוז%)" + פס-ההתקדמות + תווית-הסטטוס) מגיעים עכשיו מ-`computeCredit` החי במקום מה-seed המפוברק. כבוי (demo/טסטים) — אותו מספר בדיוק (ה-provider מחזיר `contractorCredit(name)` הזהה); מחובר — התקרה והאחוז מתעדכנים לערך-השרת. אין שינוי layout/צבע/אייקון — רק מקור-הנתון של המספר.
**למה אין צילום:** אין widget/asset חדש — `_CustomerCard` רק עבר ל-`ConsumerWidget` ושולף ערך דרך provider קיים. אומת ב-`manager_credit_computecredit_consumer_test` (+1, list מגיעה ל-seam בעת-רינדור) + 80 טסטי manager/customer ירוקים (byte-identical כבוי).
**הפיכות:** להחזיר `_CustomerCard` ל-`StatelessWidget` ולהשתמש ב-`c.creditLimit`/`view.pct` במקום `liveLimit`/`pct` המקומיים — חוזר למצב הקודם.

## 2026-06-17 — #wave2b-budget — מסך-תקציב כן על המחובר (בלי כסף-דמו מזויף)
**שינוי נראה (רק על המחובר; demo/טסטים byte-identical):** קודם מסך-התקציב הציג למשתמש מחובר תקציב-דמו מזויף (₪15,000 / ₪9,840 + 4 קטגוריות) כאילו היה שלו. עכשיו על המחובר הוא מציג את המצב הכן — תקציב ריק (₪0 / ₪0, 0%, ללא קטגוריות) עם מסך-הריק הקיים ("אין קטגוריות"/כפתורי-הוספה), בדיוק כמו תיבת-התקציב של מרכז-הפיננסים שכבר נהגה כך. בדמו — בדיוק אותו תקציב כמו קודם (אפס שינוי).
**למה אין צילום:** אין widget/asset/layout חדש — רק מקור-ה-seed של ה-state השתנה (דרך `financeRepo()` במקום const ישיר). ענף ה-`categories.isEmpty` שמרנדר את הריק כבר היה קיים. אומת ב-`budget_server_empty_test` (+2) + `budget_stock_scan_test` (+14).
**מגבלה מתועדת:** עריכות-תקציב עדיין לא נשמרות (in-memory, נמחקות ברענון — כך היה גם בדמו מאז ומתמיד). שמירה-לשרת = פיצ'ר נפרד שנדחה (collection חדש). התיקון הזה רק מפסיק להציג כסף-דמו מזויף.
**הפיכות:** להחזיר `budgetProvider` ל-`((_) => BudgetNotifier())` — חוזר להצגת ה-const demo על המחובר.

## 2026-06-17 — #wave2b-budget-persist — עריכות-תקציב נשמרות לשרת (שורדות רענון)
**שינוי נראה (רק על המחובר; demo/טסטים byte-identical):** המשך ל-v6.28 — עכשיו כשמשתמש מחובר עורך תקציב (סכום/נוצל/קטגוריות), העריכה **נשמרת לשרת ושורדת רענון/החלפת-מכשיר**. קודם (v6.28) הוא ראה ריק-כן אבל עריכות נמחקו ברענון. אין שינוי layout/widget — אותו עורך-תקציב בדיוק; רק שהנתונים נשמרים מאחורי-הקלעים (`financeBudget/active` ב-Firestore) ונטענים-מחדש כש-snapshot נוחת. בדמו — אפמרי כתמיד (אפס שינוי).
**למה אין צילום:** אין UI חדש — רק שכבת-persistence מאחורי `budgetProvider`. אומת ב-`budget_server_empty_test` (4: empty/local-demo/persist/re-seed, fake repo) + `budget_stock_scan_test` (+14) + `finance_firebase_repo_test` (+ budget source). mutation-verified (§mutation_log).
**הפיכות:** להחזיר `BudgetNotifier` ל-seed-only (בלי `_persist`/listener) ו-`budgetProvider` ל-seed הישיר; להסיר את `_BudgetCacheRepo` + `setBudget`/`budgetListenable` מה-repos — חוזר ל-read-honesty (v6.28).

## 2026-06-17 — #wave2b-fleetpct — רצועת-סיכום אשראי-הצי מחושבת חי (סגירת גל 2)
**שינוי נראה (רק על המחובר; demo/טסטים byte-identical):** בראש טאב-הלקוחות בלוח-המנהל, מספר ה"ניצול אשראי %" המצרפי (3-stat summary) מחושב עכשיו מסכום-התקרות החי (`computeCredit` לכל הלקוחות) במקום מסכום ה-seed המזויף. כבוי — אותו אחוז בדיוק (הסכום זהה); מחובר — האחוז משקף את תקרות-השרת. אין שינוי layout/widget — רק מקור-הנתון של המספר. בזמן טעינה מוצג סכום-ה-seed (אפס ריצוד) עד שהחי נפתר.
**למה אין צילום:** אין UI חדש — רק provider מצרף (`fleetCreditProvider`) מאחורי מספר קיים. אומת ב-46 טסטי manager ירוקים (byte-identical כבוי) + ה-seam מכוסה ב-`manager_credit_computecredit_consumer_test`.
**הפיכות:** להחזיר את `totalCredit` ל-`views.fold(Σ c.creditLimit)` ולמחוק את `fleetCreditProvider` — חוזר לסכום ה-seed.

## 2026-06-22 — #twin-spend-by-site — "הוצאות לפי אתר" מהזמנות אמיתיות (מחובר)
**שינוי נראה (רק מחובר; דמו/טסטים byte-identical):** ברשימת "הוצאות לפי אתר" בתקציב, הסכום לכל אתר מגיע עכשיו מ**סכום ההזמנות האמיתיות** לאותו פרויקט (לא ממשקל-המחשה). דמו — אותו נתון-המחשה כקודם. אין שינוי layout — רק מקור-המספר.
**למה אין צילום:** רק נתיב-נתון השתנה (fold של הזמנות לפי site, מאחורי מספר קיים). אומת ב-budget tests +18 (byte-identical כבוי).
**הפיכות:** להחזיר את ערך ה-`_SiteRow` למשקל בלבד ולמחוק את `spendBySite` — חוזר ל"להמחשה".

## 2026-06-22 — #guarantee-seal — חותם "אין נסיעה שנייה" ב-install-studio
**שינוי נראה:** ליד "הוסף לסל" ב-install-studio מופיע חותם ירוק "🛡️ אחריות: הסל משלים את העבודה — אין נסיעה שנייה" — **רק** כשהקו שלם פיזית (אפס חיבורים חסרים) ואין בדיקת-בטיחות קריטית פתוחה. אחרת (gaps) — האזהרה הכתומה הקיימת. אין שינוי אחר בלייאאוט.
**למה אין צילום:** widget סטנדרטי (Row+Text) מותנה על אותות קיימים; אומת ב-`robustness_test` +19 (install studio renders).
**הפיכות:** למחוק את בלוק ה-`if (ok && checkCritical == 0)` — חוזר למצב הקודם.

## 2026-06-22 — #autobom-saved-job — פתיחת עבודה-שמורה בונה רשימת-חומרים מיד
**שינוי נראה:** ב-install-studio, לחיצה על "עבודה שמורה" (≥2 עוגנים) **פותחת מיד את גיליון רשימת-החומרים המלא** (במקום רק לטעון לקנבס ולחכות ללחיצת "הרכב"). עבודה חד-עוגן — נטענת לקנבס כקודם. גיליון-הרשימה-השמורות נסגר לפני פתיחת ה-BOM (אין הערמת-גיליונות).
**למה אין צילום:** מנצל את גיליון-ה-BOM הקיים; רק קיצור-דרך בלחיצה. אומת ב-robustness +install-engine +77.
**הפיכות:** להסיר את בלוק ה-`if (found.length >= 2) _assemble(...)` מ-`_loadProject` ולהחזיר את סדר ה-tap-handler — חוזר ל"טען לקנבס בלבד".

## 2026-06-22 — #barcode-plus-wiring — סריקת-ברקוד פותחת כרטיס-מוצר
**שינוי נראה:** בכלי-המצלמה (מצב ברקוד), סריקת קוד שתואם מק"ט-קטלוג **פותחת את כרטיס-המוצר המלא** (עם הוסף-לסל/הזמנה-חוזרת + רצועת-תאימות) במקום toast "נקלט". קוד שלא תואם — toast כן כקודם.
**למה אין צילום:** מנצל את כרטיס-המוצר הקיים (`showLipskeyProductSheet`); רק החלפת ה-toast בפתיחת-כרטיס. אומת ב-camera/scan tests +24.
**הפיכות:** להחזיר את `_onDetect` ל-`showToast('נקלט: code')` בלבד + להסיר את 2 ה-imports — חוזר למבוי-הסתום.

## 2026-06-22 — #barcode-harden — תיקון פתיחת-כרטיס אחרי סריקה + הודעת-כשל כנה
**שינוי נראה:** סריקת-ברקוד שמוצאת מוצר פותחת עכשיו את הכרטיס **באופן אמין** (תוקן anchor אחרי סגירת-המצלמה). קוד שלא נמצא מציג "הקוד … לא נמצא במק"ט" (במקום "נקלט" המטעה). אין שינוי-לייאאוט אחר.
**למה אין צילום:** תיקון-context + טקסט; אומת ב-barcode_resolve_test +5.
**הפיכות:** להחזיר ל-`Navigator.pop(context)` + `showToast('נקלט')` — חוזר למצב הקודם (כולל ה-use-after-pop).

## 2026-06-22 — #twin-harden — הערת-שוליים כנה + שורת "אחר/ללא פרויקט" בתקציב
**שינוי נראה (מחובר):** בסעיף "הוצאות לפי אתר" — הערת-השוליים מתחלפת ל"מבוסס על ההזמנות בפועל" (במקום "להמחשה" השקרי), ונוספת שורת "אחר / ללא פרויקט" להזמנות שאינן משויכות לפרויקט (כך שהשורות מסתכמות לסך האמיתי). דמו — ללא שינוי. **ידוע (נדחה):** הכותרת הגדולה (%נוצל/הוצא) עדיין מהתקציב-הנערך, לא מההזמנות — סתירה שתידון בנפרד.
**למה אין צילום:** טקסט + שורה מותנית; אומת ב-budget_twin_test +20.
**הפיכות:** להחזיר את הערת-השוליים ל-const ולמחוק את `residualSpend`/שורת-"אחר" — חוזר ל-v6.31.

## 2026-06-22 — #barcode-allscanners — סריקה פותחת כרטיס גם בקטלוג וב-AI-hub
**שינוי נראה:** הכלי 📷 בקטלוג ובמרכז-ה-AI — סריקת מק"ט פותחת עכשיו את כרטיס-המוצר (כמו במצלמת-הבית), במקום רק לדחוף את הקוד לחיפוש (שהחטיא מק"טים קצרים). קוד לא-מק"ט → חיפוש כקודם.
**למה אין צילום:** מנצל את showLipskeyProductSheet הקיים; אומת ב-+141 (robustness+catalog+ai_hub).
**הפיכות:** להחזיר את שני ה-callers ל-`searchQueryProvider.state = code` בלבד.

## 2026-06-22 — #twin-residual-pin + barcode-siblings-DRY — ללא שינוי-נראה
**שינוי נראה: אין.** refactor טהור: חילוץ `budgetResidualSpend` (היה inline, אותו חישוב) + האחדת רשימת-האחים ב-2 סורקי-ברקוד ל-helper הקיים `catalogSiblingsFor` (ביטוי זהה). התנהגות/מראה זהים לחלוטין; נוסף כיסוי-טסט לשורת-"אחר".
**למה אין צילום:** אין שינוי-UI. אומת ב-budget_twin (+3 residual) + robustness +22.

## 2026-06-22 — #autobom-hotwater-fix — עוגני מים-חמים בעבודה-שמורה
**שינוי נראה (תיקון-באג):** פתיחת עבודה-שמורה שכוללת עוגן מים-חם (דוד/קולט וכו') — קודם העוגן נשר בשקט (וה-auto-BOM לא נבנה / נבנה חסר); עכשיו הוא נטען ונבנה כראוי. גם "הוסף מוצר מומלץ" לא מדווח יותר בטעות "המוצר אינו במאגר" על אביזר מים-חם.
**למה אין צילום:** תיקון פתרון-קטלוג (kLipskeyCatalog→kCompatCatalog); אומת ב-+27 כולל case מים-חם.
**הפיכות:** להחזיר `kCompatCatalog`→`kLipskeyCatalog` בשני המקומות — חוזר לבאג (עוגני HW נושרים).

## 2026-06-22 — #ai-spec-copilot — כפתור "מתאים לתנאים שלי?" בכרטיס-מוצר + מסך-קופיילוט
**שינוי נראה:** בכרטיס-מוצר (עם מפרט מאומת), מתחת ל"הוסף לסל", כפתור-מתאר "🌡️ מתאים לתנאים שלי?". לחיצה → מסך חדש: צ'יפים לבחירת טמפ׳ (40/60/80/95) + **חיווי כן/לא ברור** (ירוק ✓ / אדום ✗, עם המקס׳ המאומת) + (כשמחובר ודגל-AI דלוק) כפתור "🤖 הסבר לי" → הסבר במשפט. כבוי → רק החיווי הדטרמיניסטי + "הסבר-AI דורש חיבור".
**למה אין צילום:** widgets סטנדרטיים (ChoiceChip/Container/TextButton); הלוגיקה (verdict) = `suitableForTemp` הקיים. אומת ב-`spec_copilot_test` +3 + render +2. החיווי עובד גם offline; ההסבר-החי רק בבילד-מחובר עם `CLAUDE_AI=true`.
**הפיכות:** למחוק את בלוק ה-`if (kVerifiedSpecs.containsKey...)` בכרטיס + הקובץ `spec_copilot_screen.dart` — חוזר למצב הקודם.

## 2026-06-22 — #ai-describe-to-cart — "תאר עבודה → סל" ב-AI hub
**שינוי נראה:** ב-AI hub אריח חדש ראשון "🗣️ תאר עבודה → סל". לחיצה → מסך עם שדה-טקסט ("יש לי נזילה מתחת לכיור") + "🔎 מצא לי את הסל" → Claude מזהה את העבודה → מציג את שם-העבודה + רשימת החלקים האמיתיים + "הוסף N לסל". כבוי/לא-מחובר → "הפיצ'ר דורש חיבור". כשלא זוהתה עבודה → "נסה לתאר אחרת".
**למה אין צילום:** widgets סטנדרטיים (TextField/FilledButton/ListView); הלוגיקה (closed-set match + assembleKit) ב-`describe_to_cart_test` +. ה-AI-hub grid גדל ל-10 אריחים.
**הפיכות:** להסיר את אריח 'describe' + ה-case + הקובץ `describe_to_cart_screen.dart`, ולהחזיר `apple_readiness` ל-6 — חוזר ל-9 אריחים.

## 2026-06-22 — #ai-finder — שדרוג-המאתר "תאר → מצא"
**שינוי נראה:** בפתיחת ה**מאתר-החכם** נוסף כפתור "🗣️ תאר במילים שלך → חיפוש חכם" (ליד "לפי חומר"/"לפי עבודה"). לחיצה → מסך חדש: שדה-טקסט ("ברז למטבח") + "🔎 מצא לי" → Claude מזהה קטגוריה → "📂 <קטגוריה> · N מוצרים" + רשימה (לחיצה → כרטיס-מוצר). כבוי/לא-מחובר → "החיפוש החכם דורש חיבור". לא-זוהתה → "נסה לתאר אחרת".
**הדמייה (stand-in ל-Claude, ב-ai_finder_test):** "ברז למטבח"→📂 אביזרי ברזים (4) · "חיבור HDPE"→📂 מחברי HDPE (120) · "נחושת"→📂 אביזרי נחושת (71).
**למה אין צילום:** widgets סטנדרטיים; הזרימה נעוצה ב-`ai_finder_test`. נגיעה מינימלית במסך-המאתר (אריח-פתיחה בלבד).
**הפיכות:** להסיר את `if (showJobsEntry) _buildAiFinderEntry()` + המתודה + ה-import מ-word_finder_screen, ולמחוק את ai_finder_screen — חוזר למאתר המקורי.

## 2026-06-23 — #lipskey-pdf-enrich — טבלת-מפרט עשירה + עטיפת-ערך ב-_SpecRow
**שינוי נראה:** בכרטיס-המוצר הפנימי, מקטע "📐 פרטי מוצר" — מוצרי קטלוג-הבית (סיפונים/מחסומים/מטבח) מציגים עכשיו **שורות-מפרט חדשות** שחולצו מה-PDF: 📐 מידות (`190-270 / 140 / 55 / 110-245 / Ø32.0`), 🏗️ כמות במשטח, תיאור. השדות מונעי-דאטה — מופיעים אוטומטית למוצרים שקיבלו dims.
**תיקון-רינדור:** `_SpecRow` — ערך-מפרט ארוך (מידות/תיאור) היה גולש מימין (`Text` אחרי `Spacer`). תוקן ל-`Flexible(label)` + `Expanded(Text(value, textAlign:end))` — ערך ארוך **נגלל לשורה שנייה**, ערך קצר נשאר מיושר-ימין זהה.
**אימות (אוטומטי, לא צילום):** `product_journey_test` → "HARD · all 935 sheets render at large text + narrow phone" **ירוק** — כל 935 הכרטיסים, כולל מוצרי-בית עם מידות-ארוכות, מרונדרים **ללא overflow** בפלאפון-צר+טקסט-גדול. זה האימות-הויזואלי המחמיר ביותר (הסביבה שגרמה ל-overflow לפני התיקון).
**הפיכות:** `git checkout lib/screens/lipskey_product_sheet.dart` (מחזיר Spacer+Text) + שחזור `lipskey_catalog.dart` — חוזר לטבלה הדלילה.

## v6.59 — שני שבבי-ציון כנים בכרטיס המוצר (במקום "ציון נתונים" המטעה)
**שינוי:** מתחת לשם-המוצר, במקום שבב יחיד "📊 ציון נתונים N · label" — עכשיו `Wrap` של **שני שבבים**: "📋 שלמות נתונים X% · label" (שלמות-listing, spec-free) + "🔧 מוכנות התקנה N · label" (מוכנות-חיבור). כל שבב בצבע-band משלו (`scoreBandColors`).
**למה:** השבב הישן נקרא "נתונים" אך מדד מוכנות-חיבור → אביזר שלא-מתחבר (חבק/ערכה/מושב) נראה כ"דאטה גרועה" 25 למרות listing מלא. השבב החדש מזכה אותו (ערכה: שלמות 67% · מוכנות 23).
**אימות (אוטומטי, לא צילום):** `product_journey_test` → "HARD · all 935 sheets render at large text + narrow phone" **ירוק** — שני-השבבים ב-`Wrap(spacing:6,runSpacing:6)` נכנסים/נשברים-לשורה בלי overflow גם בפלאפון-צר+טקסט-גדול.
**הפיכות:** `git checkout lib/screens/lipskey_product_sheet.dart lib/data/related_info.dart` — חוזר לשבב-יחיד.

## v6.77 — אודיט-נחיל קו-פיילוט ס1: תיקוני-ניגודיות + a11y — 2026-06-23
**שינויי-UI (lib/screens):** תיקוני-WCAG מעדשת-ה-UI-robustness.
- בועת-משתמש בקו-פיילוט: טקסט לבן-על-brand (~2.7:1, נכשל AA) → **טקסט-כהה `inkLight` (~6:1)**. הבועה נשארת brand-צבע.
- כפתור-שלח: נוסף `tooltip: 'שלח'` (קורא-מסך).
- כרטיס-hero בקוקפיט: כותרת-המשנה `white70`→`white` (ניגודיות על ה-gradient).
**אימות:** שינויי-צבע/tooltip בלבד — אפס שינוי-מבני. 12 טסטי-copilot + 49 מנהל ירוקים · analyze 0.

## v6.78 — קו-פיילוט ס2: תדריך-בוקר בלי-חיתוך + כשל-מהיר — 2026-06-23
**שינוי נראה (lib/screens/manager_copilot_screen.dart):** התדריך-בוקר (☀️) קיבל יותר-מרווח-תווים (420→600) — בולטי-העברית כבר **לא נחתכים באמצע-משפט** (עברית מתקצבת ~2-4× גרוע מאנגלית). שאלות-ה-Q&A הרגילות נשארות 420 (תשובה תמציתית). אין שינוי-פריסה/צבע/widget — רק אורך-התשובה-המקסימלי.
**שינוי-התנהגות (lib/data/repositories/claude_functions.dart):** קריאה תקועה לשרת נכשלת-מהר אחרי 30s (`.timeout`) עם בועת "משהו השתבש בחיבור — נסה שוב עוד רגע" במקום ספינר-תלוי עד ~70s. נראה רק במצב-תקלת-רשת.
**אימות (אוטומטי, לא צילום):** `claude_gateway_test` (חוזה-maxTokens ירוק) + `manager_copilot_screen_test` (off-state) + 49 טסטי-מנהל ירוקים · analyze 0. שינוי inert בבילד-הדמו (`claudeGatewayProvider==null`); חי על App Tester.
**הפיכות:** `git checkout lib/screens/manager_copilot_screen.dart lib/data/repositories/claude_functions.dart` — חוזר ל-cap-420-קבוע ול-`.call` ללא-timeout.

## v6.79 — קו-פיילוט ס3: a11y-כותרת + S0 ממשל (מנהל בלי שורת-פרופיל-קבלן) — 2026-06-23
**שינוי נראה (S0 · governance):** כפתור-ההגדרות בלוח-המנהל ובפרופיל-המנהל פותח עכשיו את הגדרות-ה-No-Code **בלי** שורת "👤 הפרופיל שלי" שבראש (שהובילה לפרופיל-הקבלן). המנהל רואה את אותן קטגוריות-הגדרה גלובליות (תצוגה/התראות/אזור/חיפוש/מחירים/יחידות/ספקים/AI/נגישות/מידע) — תחומו כ-platform-admin — אך **לא** את שורת-הפרופיל-האישית. הקבלן (home/keyboard) ללא-שינוי — עדיין רואה אותה.
**שינוי נראה (a11y):** כותרות-ה-AppBar בקו-פיילוט (דו-שורתי) ובלוח-המנהל קיבלו `maxLines:1 + ellipsis` — בטקסט-מוגדל הן נחתכות-בנקודותיים במקום לגלוש מחוץ ל-toolbar. `_Typing` עבר ל-`EdgeInsetsDirectional` (אפס שינוי-מראה ב-RTL).
**אימות (אוטומטי, לא צילום):** `catalog_price_units_settings_test` +2 (קבלן מציג "הפרופיל שלי" · מנהל מסתיר אותו ושומר 'תצוגה ומיון'+'מחירים ומטבע') = 18 ירוק · `manager_dashboard_screen_test` 30 ירוק (כותרת-AppBar עדיין מרונדרת) · analyze 0.
**הפיכות:** `git checkout lib/screens/catalog_settings_screen.dart lib/screens/manager_dashboard_screen.dart lib/screens/manager_profile_screen.dart lib/screens/manager_copilot_screen.dart` — מחזיר את שורת-הפרופיל לכולם + כותרות בלי-ellipsis.

## v6.81 — סריקת-AI-רוחבית ס5: ניגודיות-בועה בעוזר + הקשחת-הזרקה — 2026-06-23
**שינוי נראה (lib/screens/ai_assistant_screen.dart):** בועת-המשתמש בעוזר-ה-AI — הטקסט עבר מלבן-על-brand (~2.7:1, נכשל WCAG AA) ל-**כהה `inkLight` (~6:1)**, בדיוק כמו התיקון שכבר נעשה בקו-פיילוט. הבועה נשארת brand-צבע; רק הטקסט קריא יותר.
**שינוי לא-נראה (prompt-internal · אפס-UI):** הסבר-האשראי (`credit_explain`) ודוח-היום (`daily_report`) מנקים עכשיו את שם-הלקוח/כותרת-השליח לפני הזרקה ל-prompt (`promptSafeText` — קיפול-newline + cap) — הקשחת-הזרקה; אין שינוי במה שהמשתמש רואה. גם docstring בלוח-המנהל דויק (אין שינוי-UI).
**אימות (אוטומטי, לא צילום):** `ai_assistant_test` 11 ירוק (הבועה עדיין מרונדרת) · `credit_explain_test` +1 (sanitize) · `daily_report_test` +1 (sanitize) · analyze 0.
**הפיכות:** `git checkout lib/screens/ai_assistant_screen.dart` — מחזיר לבן-על-brand; `git checkout lib/screens/credit_explain_screen.dart lib/screens/daily_report_screen.dart` — מחזיר הזרקה-גולמית.

## v6.82 — אחי-ה-AI ס6: הסבר-ספק עם retry כן + ניגודיות-כשל — 2026-06-23
**שינוי נראה (lib/screens/spec_copilot_screen.dart):** כשהמודל מחזיר תשובה ריקה (200-empty), המסך מציג עכשיו את מצב-הכשל הכן עם כפתור "נסה שוב" — במקום כרטיס-"🤖 " ריק שתקע את המשתמש בלי דרך-לנסות-שוב. הוורדיקט הדטרמיניסטי (כן/לא מחזיק) ממשיך להופיע תמיד ממילא.
**שינוי נראה (ai_finder + describe_to_cart):** שורת-הכשל "משהו השתבש — נסה שוב" עברה מ-`danger` ל-`dangerDark` — ניגודיות WCAG-AA זהה ל-AiFailedState המשותף (קריאה יותר).
**שינוי לא-נראה (lib/state/board_auth.dart):** logout מתוך board-מתחזה כבר לא מנתק את המנהל לגמרי — חוזר לסשן-המנהל.
**אימות (אוטומטי, לא צילום):** `manager_impersonate_test` +2 (logout בזמן/מחוץ-impersonation) · `board_auth_test` 20 · spec_copilot/ai_finder/describe_to_cart analyze 0. (סבב-בדיקות-מסך לאחים = ממתין, מתועד ב-WIRING.)
**הפיכות:** `git checkout lib/screens/spec_copilot_screen.dart lib/screens/ai_finder_screen.dart lib/screens/describe_to_cart_screen.dart lib/state/board_auth.dart`.

## v6.83 — מע״מ קטלוג 17%→18% (יישור לחיוב-הקופה · מקור-אמת-יחיד) — 2026-06-23
**שינוי נראה:** מחירי-הקטלוג עם "כולל מע״מ" עלו ב~0.85% (17%→18%) — כי המחיר-המוצג עכשיו תואם בדיוק את מה שנגבה בקופה (שכבר חייבה 18%). דוגמה: מוצר ב-₪100 בסיס הציג ₪117, עכשיו ₪118 (=מה שהקופה גבתה ממילא). מסך-הניהול ממשיך להציג "שיעור מע״מ 18%" (עכשיו נגזר מאותו קבוע). **זה תיקון-נכונות:** קודם הקבלן ראה מחיר אחד בעיון ושילם יותר בקופה.
**אימות (אוטומטי, לא צילום):** `catalog_price_units_settings_test` (18%) + 5 חבילות-עגלה (נשארו 18% ירוקות) + `manager_dashboard_screen_test` (שורת-מע״מ עדיין מרונדרת) = 122 ירוקים · analyze 0.
**הפיכות:** `git checkout lib/state/catalog_settings.dart lib/screens/store_screen.dart lib/screens/manager_dashboard_screen.dart` — מחזיר ל-`kVatRate=0.17` ולפיצול 17/18.

## v6.84 — a11y: ניגודיות-AA + tooltips + מנעול-double-tap בחנות — 2026-06-23
**שינוי נראה (ניגודיות):** טקסט-אפור בהיר שנכשל WCAG-AA הוכהה — שבבי-פילטר לא-פעילים בחנות (#AAAAAA→#595959), כותרת-מותג ותווית-תאימות בקטלוג. עכשיו קריא לבעלי-ראייה-חלשה.
**שינוי נראה (a11y, לא-ויזואלי לרואים):** כפתורי-אייקון (אישור/סגירה/חזרה/נקה/הסר-מהסל/...) קיבלו tooltip → קורא-מסך מכריז עליהם; חיווי "לא-נקרא" בהתראות-החנות קיבל `Semantics` (קודם צבע-בלבד).
**שינוי התנהגות (חנות):** double-tap מהיר על "הכן"/"מוכן" כבר לא מקפיץ 2 שלבים — מנעול-staleness כמו אצל השליח.
**אימות (אוטומטי):** `product_journey` (935 sheets · large-text · narrow-phone — אפס overflow) + `persona_fulfillment` + `store_notif_widget` ירוקים · analyze 0.
**הפיכות:** `git checkout lib/screens/catalog_screen.dart lib/screens/store_screen.dart lib/screens/store_dashboard_screen.dart`.

## v6.85 — ₪ מקובץ אחיד: קטלוג/בית/קבלן עכשיו "₪4,200" (כמו העגלה) — 2026-06-23
**שינוי נראה:** מחירי-₪ בני 4+ ספרות שהוצגו גולמיים ("₪4200") עכשיו מקובצים-בפסיק ("₪4,200") — כרטיס-המוצר בקטלוג, עלויות-קו ב-build-a-list, אביזרים, המלצות-בית, וגיליונות-הקבלן (המלצה/חלופה/חיסכון/הצעת-ספק). תואם לעגלה/מנהל/תקציב שכבר קיבצו. אפס שינוי-ערך — רק פסיק-אלפים.
**אימות (אוטומטי):** `money_format_test` (5) + `catalog_price_units_settings` (19) + `product_journey` (935 sheets · large-text · narrow-phone — אפס overflow גם עם הפסיק) ירוקים · analyze 0.
**הפיכות:** `git checkout lib/state/catalog_settings.dart lib/screens/catalog_screen.dart lib/screens/smart_home_screen.dart lib/screens/contractor_tools_sheets.dart` + מחיקת `lib/logic/money_format.dart`.

## v6.86 — perf קטלוג (hoist-RegExp + suggestions-provider) — אפס שינוי ויזואלי — 2026-06-23
**שינוי נראה:** אין. זהו תיקון-ביצועים פנימי בלבד — תוצאות-החיפוש, ההצעות וכרטיסי-הקטלוג נראים זהה לחלוטין. השיפור: פחות עבודת-CPU per-keystroke (RegExp לא-מתקמפל-מחדש; סריקת-ההצעות יצאה מ-build ל-provider).
**אימות (אוטומטי):** 19 בדיקות-חיפוש ירוקות (אותו פלט) · analyze 0 · full-suite (incl. product_journey 935-sheet render — ללא-שינוי).
**הפיכות:** `git checkout lib/screens/catalog_screen.dart`.

## v6.87 — hygiene: disposal + trim + camera-toast-fix — שינוי-נראה מינימלי — 2026-06-23
**שינוי נראה:** כמעט-אפס. (1) צילום-מצלמה: ה-toast "📸 התמונה נקלטה" עכשיו **באמת מופיע** (קודם נשמט שקט כי נקרא על context שכבר-נסגר). (2) רישום-משתמש: רווחים-מיותרים בשם/קשר נחתכים. שאר השינויים פנימיים (שחרור-controllers בדיאלוגים — אפס שינוי-מראה).
**אימות (אוטומטי):** analyze 0 · product_journey (935 sheets) + cart_stress/safety/bulk ירוקים.
**הפיכות:** `git checkout` על 6 הקבצים (store/catalog/install_studio/lipskey_products/welcome/camera).

## v6.88 — date: "עכשיו" + צורות-יחיד בזמן-יחסי (install-studio) — 2026-06-23
**שינוי נראה:** ב-install-studio, חותמת-הזמן-היחסית של פרויקט שמור: timestamp-עתידי (שעון אחורה) כבר לא מציג "לפני -3 דקות" אלא "עכשיו"; ו-1 מציג צורת-יחיד ("לפני דקה" · "לפני שעה" · "אתמול") במקום "לפני 1 דקות". פורמט-תאריך מלא (>שבוע) ללא-שינוי.
**אימות (אוטומטי):** analyze 0 · install_builder + full-suite ירוקים. (formatter טהור — אפס שינוי-מבני.)
**הפיכות:** `git checkout lib/screens/install_studio_screen.dart`.

## studio-s9 — EditHandle (אפשר-עריכה-במקום) — שינוי-נראה: אפס (מגודר) — 2026-06-29
**שינוי נראה:** **אפס.** `EditHandle.maybe(ref, id, child:)` עוטף רכיב באפשר-עריכה **רק** ב-edit-mode (שמצריך `kStudioFlag`/runtime + owner+manager — כבוי כברירת-מחדל). מחוץ ל-edit-mode (כלומר תמיד, בבילד הרגיל) הוא מחזיר את ה-`child` **מילולית** — אפס widgets נוספים, אפס שינוי-פיקסל. רק ב-edit-mode (בעלים בלבד): מתאר-מסגרת brand (1.5px, `Positioned.fill` — לא משנה layout) + תג `StudioEditTarget(id)` (`MetaData`) ל-hit-test מרכזי בשלב-13 (R2-#3 — לא GestureDetector פר-wrapper).
**אימות (אוטומטי):** `cfg_wrappers_test` 2 ירוקים (OFF = child verbatim, `MetaData` findsNothing · ON = tag+outline) · analyze 0. **אין מסך אמיתי שצורך אותו עדיין** (אימוץ-פיילוט בשלב-14) ⇒ אפס שינוי גלוי למשתמש כרגע.
**הפיכות:** `git rm lib/widgets/studio/edit_handle.dart` (אין צרכן).

## studio-s10 — CfgText (עוטפן-תוכן עריך) — שינוי-נראה: אפס (מגודר) — 2026-06-29
**שינוי נראה:** **אפס.** `CfgText(id, fallback)` הוא drop-in ל-`Text(fallback)`. עם doc ריק (kStudioFlag כבוי) ה-node המ-resolved הוא identity ⇒ מרנדר את ה-literal העברי **מילולית**, אותו style/align/maxLines כמו Text גולמי. **אין מסך שצורך אותו עדיין** (אימוץ-פיילוט בשלב-14) ⇒ אפס שינוי גלוי. רק עם override מפורסם (בעלים): טקסט/אמוג'י/style-לפי-token חלים; ב-edit-mode עטוף ב-EditHandle.
**אימות (אוטומטי):** `cfg_wrappers_test` +4 ל-CfgText (empty⇒verbatim+RTL+style-null · text-override · emoji-prepend · token-color=brand) = 6 ירוקים בקובץ · analyze 0.
**הפיכות:** `git rm lib/widgets/studio/cfg_text.dart` (אין צרכן).

## studio-s11 — CfgVisible/CfgBox/CfgList/CfgAction — שינוי-נראה: אפס (מגודר) — 2026-06-29
**שינוי נראה:** **אפס.** ארבעה עוטפנים נוספים, כולם drop-in: **ללא override ⇒ ה-child מילולית.** `CfgVisible` (הסתרה; ב-edit-mode ghost+badge "מוסתר" כדי שאפשר יהיה לשחזר), `CfgBox` (רקע/padding לפי token), `CfgList` (סדר לפי `order`), `cfgAction` (resolver — v1 fallthrough ל-onTap המקורי). **אין מסך שצורך אותם עדיין** (אימוץ-פיילוט שלב-14) ⇒ אפס שינוי גלוי.
**אימות (אוטומטי):** `cfg_wrappers_test` 16 ירוקים (no-override⇒verbatim לכל wrapper · hidden+editing⇒ghost · order-resort · action-fallthrough) · analyze 0.
**הפיכות:** `git rm` על 4 הקבצים (אין צרכן).

## studio-s13 — StudioOverlay (באנר מצב-עריכה) — שינוי-נראה: אפס off-gate — 2026-06-29
**שינוי נראה:** off-gate (הבילד הרגיל) = **אפס** — `StudioOverlay` מחזיר `SizedBox.shrink` (inert, אפס pointer-area, בדיוק כמו `ConnectionIndicator`; עם `kStudioFlag` const-OFF נעלם ב-tree-shaking). on-gate (בעלים + דגל פעיל + edit-mode) = באנר עליון "✏️ מצב עריכה" + כפתור "צא". שורה אחת **additive** ב-`main.dart` ליד `ConnectionIndicator`.
**אימות (אוטומטי):** `zero_regression_test` +2 (off⇒SizedBox/ללא-באנר · on⇒באנר) = 14 ירוקים · analyze 0 בקבצים החדשים (ב-main.dart 6 infos קיימים-מראש — לא מהשינוי).
**הפיכות:** הסר את שורת `const StudioOverlay()` מ-main.dart + `git rm studio_overlay.dart`.

## studio-s14 — אימוץ פיילוט: 5 כותרות KPI בקוקפיט — שינוי-נראה: אפס (OFF) — 2026-06-29
**שינוי נראה:** **אפס** (OFF = answer-equivalent + golden). 5 כותרות ה-KPI בלוח-הבקרה של המנהל (הזמנות פתוחות · מוצרים בקטלוג · אביזרים נלווים · זמינים כעת · חנויות פעילות) עברו מ-`Text(label,…)` ל-`CfgText(id, label,…)` — **אותו style/maxLines/overflow בדיוק.** עם doc ריק (kStudioFlag כבוי) ⇒ אותו פיקסל. `_MetricTile` קיבל `cfgId`; 5 descriptors (wired:true) נוספו ל-registry.
**אימות (אוטומטי):** `registry_contract_test` +1 (5 pilot-ids ⊆ registry) = 7 · `descriptor_contract` 3 · analyze 0 (5 infos קיימים-מראש ב-mega-file, לא מהשינוי). revert = `CfgText→Text` טהור.
**הפיכות:** `git checkout lib/screens/manager_dashboard_screen.dart` + הסר 5 descriptors מ-`element_registry.dart`.

## studio-s16 — קונכיית-הסטודיו: שלד המסך — שינוי-נראה: אפס (לא-נגיש) — 2026-06-29
**שינוי נראה:** **אפס.** `lib/screens/studio/studio_screen.dart` — מסך-הסטודיו (RTL + scaffold בהיר + AppBar לבן + 4 panes ב-`IndexedStack` עם placeholders + ChoiceChips למעבר). **בלתי-נגיש** — `route()` גדור ב-`studioActiveProvider` (מחזיר null כש-OFF), והכניסה מהמנהל מחווטת רק ב-s20. אין נתיב למסך ⇒ אפס שינוי גלוי.
**אימות (אוטומטי):** `studio_screen_test` 2 ירוקים (RTL + AppBar לבן · route()==null כש-inactive / !=null כש-active) · analyze 0.
**הפיכות:** `git rm -r lib/screens/studio/` (אין נתיב/צרכן).

## studio-s17 — קונכיית-הסטודיו: top-bar (פרסם/בטל/עריכה) — שינוי-נראה: אפס (לא-נגיש) — 2026-06-29
**שינוי נראה:** **אפס** (המסך עדיין בלתי-נגיש עד s20). top-bar למסך-הסטודיו: badge "טיוטה · N שינויים" · מתג "מצב עריכה" · "בטל טיוטה" · "פרסם לכולם" (כבוי כש-N=0). פרסום → bottom-sheet אישור-היקף (R2-#13): "ישפיע על כל המשתמשים — N" + שדה-note inline + dropdown "צפה כפי ש-<פרסונה>" (מספר-שינויים-לפי-roleKey) + פרסם/ביטול → `publish(note, byEmail=owner)`. discard → אישור → discardDraft.
**אימות (אוטומטי):** `studio_screen_test` +1 (publish כבוי על draft ריק → פעיל עם draft + badge) = 3 ירוקים · analyze 0.
**הפיכות:** `git rm lib/screens/studio/studio_top_bar.dart` + הסר `const StudioTopBar()` מ-studio_screen.

## studio-audit-r1-A — הקשחת ממשל #84 (publish/route owner-gated) — שינוי-נראה: אפס — 2026-06-29
**שינוי נראה:** **אפס** (המסך עדיין לא-נגיש). תוצאת נחיל-ביקורת היסוד: publish/discard/route עברו להיגדר ב-`studioCanEditProvider` (owner∧manager∧active) ולא רק ב-draft-count/active — לא ניתן לפרסם/לפתוח את הסטודיו כלא-בעלים גם אם הוא ירונדר (defence-in-depth). + EdgeInsetsDirectional ב-_PublishSheet.
**אימות (אוטומטי):** כל חבילת studio (100 בדיקות) ירוקה — כולל route-null-ל-non-owner + publish-disabled-for-non-owner-even-with-draft · analyze 0.
**הפיכות:** `git revert` של קומיט ה-audit-r1-A.

## studio-s18 — קונכיית-הסטודיו: Pane A עץ-הרכיבים — שינוי-נראה: אפס (לא-נגיש) — 2026-06-29
**שינוי נראה:** **אפס** (המסך עדיין לא-נגיש עד s20). Pane A — עץ screen→area→element מ-`elementRegistryProvider`, **וירטואלי** (`ListView.builder` על flattened-rows, לא nested ExpansionTile — scale). חיפוש לפי labelHe/id + dropdown persona (scope) + tap→בחירה (`studioSelectedIdProvider`, ל-inspector s19). read-only.
**אימות (אוטומטי):** `tree_pane_test` 4 ירוקים (lists · search-filter · tap-selects · persona-scope) · `studio_screen` 4 (לא נשבר) · analyze 0.
**הפיכות:** `git rm` tree_pane.dart + studio_nav.dart, החזר placeholder ל-pane 0.

## studio-s19 — קונכיית-הסטודיו: Pane B המפקח — שינוי-נראה: אפס (לא-נגיש) — 2026-06-29
**שינוי נראה:** **אפס** (המסך עדיין לא-נגיש עד s20). Pane B — מפקח-עריכה לאלמנט הנבחר (`studioSelectedIdProvider`). לפי `descriptor.editableProps`: תוכן (TextField טקסט + אמוג'י, controller מקומי decoupled — R2-#2) · נראות (Switch, נעול אם `kImmutable`) · תצוגה-חיה + 'אפס רכיב' (`resetDraftNode`). כל עריכה → draft דרך `applyOps` (**לא חי עד "פרסם לכולם"**). v1 עורך global. style→s24, behavior→Pillar-4.
**אימות (אוטומטי):** `inspector_pane_test` 4 ירוקים (no-selection · fail-closed · text→draft · reset) · analyze 0.
**הפיכות:** `git rm inspector_pane.dart`, החזר placeholder ל-pane 1.

## studio-s20 — הכניסה ⭐: שורת "🎨 סטודיו" אצל המנהל — אפס לכולם · כרטיס-חדש לבעלים — 2026-06-29
**שינוי נראה:** **אפס לכל המשתמשים** (`StudioEntryCard` = `SizedBox.shrink` ל-non-owner; הקוקפיט זהה byte-for-byte). **לבעלים-מנהל בלבד** (signed-in owner email): כרטיס "🎨 סטודיו (בטא)" חדש בראש לוח-הבקרה, אחרי הקו-פיילוט. לחיצה → מפעילה את דגל-הריצה `kStudio` + פותחת את מסך-הסטודיו (route גדור-בעלים). **זו הפעם הראשונה שהסטודיו נגיש end-to-end: הבעלים פותח → עץ → בוחר → מפקח → מקליד → "פרסם לכולם" → חי.**
**אימות (אוטומטי):** `studio_entry_test` 3 ירוקים (hidden ל-non-owner · visible לבעלים · tap מפעיל+פותח) · **כל חבילת studio 115 ירוקים** · analyze 0 (5 infos קיימים-מראש ב-mega-file).
**הפיכות:** הסר `const StudioEntryCard()` מהקוקפיט + `git rm studio_entry.dart`.

## studio-s21 — קונכיית-הסטודיו: Pane D היסטוריית-גרסאות — שינוי-נראה: אפס (מגודר) — 2026-06-29
**שינוי נראה:** **אפס** (בתוך הסטודיו המגודר). Pane D — רשימת `ConfigVersion` (note · byEmail · זמן) חדש-לישן; "שחזר" → אישור → rollback **forward-only** (snapshot מתפרסם כגרסה חדשה, ההיסטוריה נשמרת). ריק → placeholder. מחובר pane 3.
**אימות (אוטומטי):** `history_pane_test` 3 ירוקים (empty · shows-version · restore-forward) · `studio_screen` 4 (לא נשבר) · analyze 0.
**הפיכות:** `git rm history_pane.dart`, החזר placeholder ל-pane 3.

## studio-s24a — חיווט config→theme (תצוגה-חיה כלל-אפליקציה) — שינוי-נראה: אפס (ברירת-מחדל) — 2026-06-29
**שינוי נראה:** **אפס בבילד רגיל** (`configThemeProvider` = fallback = BsTokens ⇒ scheme.primary/FAB זהים). חוברה תשתית theme-override: `configThemeProvider` (draft⊕published `structure['theme']` → CfgTheme), `setThemeDraft`, `_promote` ממזג structure, `draftNodeCount` סופר theme-draft, ו-main.dart מזריק את ה-CfgTheme ל-`AppTheme.light/dark(cfg:)` (seed/primary/FAB = cfg.brand). **כשהבעלים יפרסם override של brand — כל האפליקציה תשקף אותו חי.** עורך-ה-UI = s24b.
**אימות (אוטומטי):** `config_theme_wiring_test` 4 + `config_theme_test` 6 + כל חבילת studio + `a11y_contrast_theme_test` — הכל ירוק · analyze 0 (infos קיימים-מראש).
**הפיכות:** `git revert` של s24a.

## studio-s24b — Pane C: עורך ערכת-נושא — שינוי-נראה: אפס (מגודר) — 2026-06-29
**שינוי נראה:** **אפס** (בתוך הסטודיו המגודר; non-owner לא מגיע). Pane C — עורך-עיצוב חי: בורר-צבע-מותג (Wrap של 8 swatches מוגדרים-מראש, ללא dep חיצוני) · Slider עיגול-פינות (0–28) · Slider גודל-גופן (0.8–1.6) · תצוגה-חיה (כרטיס+כותרת+גוף+כפתור, קורא cfg ישירות) · כפתור אפס (`setThemeDraft(CfgTheme.fallback)`). כל שינוי → draft דרך `setThemeDraft` (**לא חי עד "פרסם לכולם"**). בדיקת-AA: ניגודיות brand מול לבן <4.5 ⇒ אזהרה מיידעת (לא חוסמת). מחובר pane 2 (במקום placeholder).
**אימות (אוטומטי):** `theme_pane_test` 4 ירוקים (2-sliders+swatches · tap⇒draft-live+publishable · warning toggles · reset⇒fallback) · `studio_screen` + `zero_regression` לא נשברו · analyze 0.
**הפיכות:** `git rm theme_pane.dart`, החזר `_PanePlaceholder` ל-pane 2 ב-studio_screen.

## studio-s25 — מצא-והחלף גלובלי על תוכן → טיוטה — שינוי-נראה: אפס (מגודר) — 2026-06-29
**שינוי נראה:** **אפס** (בתוך הסטודיו המגודר; non-owner לא מגיע). pane 5 חדש ('🔎 מצא והחלף') — שדה-מצא + שדה-החלף → רשימת-hits (כל אחד checkbox + `labelHe` + "לפני ← אחרי") על שכבת-ה-overrides (draft⊕published, **לא** labelHe). "החלף בנבחרים (N)" → `applyOps` batch-יחיד = undo-יחיד, ל-**draft בלבד** (published לא נגע). `kImmutable` = קריאה-בלבד. אזהרת >50. SnackBar-אישור + ניקוי. מחובר segment-5 ב-studio_screen.
**אימות (אוטומטי):** `find_replace_test` 3 ירוקים (preview-by-labelHe + replace→draft-only/published-untouched · single-undo · kImmutable-read-only) · `studio_screen` (5 panes) + `zero_regression` לא נשברו · analyze 0.
**הפיכות:** `git rm find_replace_pane.dart`, הסר segment-5 + ילד-5 מ-studio_screen.

## studio-r2-fix-2 — תיקוני נחיל round-2 (panes: a11y + find-replace כנה) — שינוי-נראה: מינימלי (מגודר) — 2026-06-29
**שינוי נראה:** **מינימלי, בתוך הסטודיו המגודר.** (א) צ'יפים של ה-panes קיבלו `tooltip` עם שם מלא (קורא-מסך/hover). (ב) סליידרים (radius/fontScale) קיבלו `semanticFormatterCallback` עברי. (ג) שורת before→after במצא-והחלף עטופה ב-`Semantics(label:'מ־…ל־…')` + `ExcludeSemantics` (קורא-מסך שומע ישן/חדש, לא רק קו-חוצה ויזואלי). (ד) SnackBar במצא-והחלף מדווח כעת ספירה **כנה** (`applied` מ-applyOps, לא ops.length) + "(N נדחו — טקסט ארוך/לא תקין)" כשהוולידטור דחה. (ה) מספרי-ניגודיות עטופים LTR-isolate (`⁦…⁩`). (ו) publish מעביר `criticalIds` ⇒ sanitize רץ בפרודקשן.
**אימות (אוטומטי):** `find_replace_test` 4 (+over-length-dropped) · `theme_pane` 4 · `studio_screen` 11 — כולם ירוקים · analyze 0 (אפס warnings — תווי-isolate כ-escapes).
**הפיכות:** `git revert` של r2-fix-2.

## studio-s29-b1 — Phase E אימוץ-תוכן: קוקפיט copilot-title → CfgText — שינוי-נראה: אפס — 2026-06-29
**שינוי נראה:** **אפס (answer-equivalent).** Batch-1 של אימוץ-התוכן: `const Text('שאל את העסק שלך', …)` בקוקפיט (hero קו-פיילוט) → `const CfgText('manager.cockpit.copilot.title', 'שאל את העסק שלך', …)`. הליטרל נשאר fallback ⇒ doc-ריק/OFF מציג אותו verbatim עם אותו style (CfgText = wrapper-זהות מוכח, EditHandle.maybe מחזיר child כשלא-עורכים). `const` נשמר (ל-CfgText יש const-ctor). id נוסף ל-registry (append-only, wired:true, לא-kImmutable — תוכן ולא ניווט).
**אימות (אוטומטי):** `gate_118_test` (id מאומץ ⊆ registry) · `registry_contract`/`descriptor_contract` (8+3) · `zero_regression` 31 — כולם ירוקים · analyze 0.
**הפיכות:** `CfgText→Text` חזרה + הסר את שורת ה-registry.

## studio-s29-b2 — Phase E אימוץ-עיצוב: cfgRadius בכרטיס קו-פיילוט — שינוי-נראה: אפס (default) — 2026-06-29
**שינוי נראה:** **אפס בברירת-מחדל.** Batch-2 (אימוץ-radius): שני אתרי `BorderRadius.circular(BsTokens.radiusCard)` בכרטיס `_CopilotHero` (InkWell + BoxDecoration, שניהם non-const, `context` זמין) → `BorderRadius.circular(cfgRadius(context))`. `cfgRadius` default = radiusCard = 20 = נוכחי ⇒ פיקסל-זהה. **כשהבעלים יזיז את ה-radius-slider ויפרסם — פינות-הכרטיס ישתנו חי** (מתחיל לסגור את ה-deferred מ-r2-fix-3). ללא registry (קורא theme גלובלי, לא id פר-אלמנט).
**אימות (אוטומטי):** `config_theme_test` 12 (+cfgRadius: override⇒8 · fallback⇒radiusCard, דרך `Theme` מפורש כדי לעקוף את אנימציית-ה-theme של MaterialApp) · `zero_regression` 16 — ירוקים · analyze 0.
**הפיכות:** `cfgRadius(context)→BsTokens.radiusCard` חזרה (2 אתרים).

## studio-s29-b3 — Phase E אימוץ-עיצוב: כל קוקפיט-המנהל → cfgRadius — שינוי-נראה: אפס (default) — 2026-06-29
**שינוי נראה:** **אפס בברירת-מחדל.** Batch-3: כל 14 אתרי `BorderRadius.circular(BsTokens.radiusCard)` שנותרו ב-`manager_dashboard_screen.dart` → `cfgRadius(context)` (replace_all; כולם non-const + `context` זמין — אומת ע"י analyze נקי, שתופס const/missing-context מיידית). סך-הכל 16 אתרים בקובץ עכשיו עם cfgRadius. **כל כרטיסי לוח-המנהל (KPI · הזמנות · קופי-פיילוט · ...) מגיבים עכשיו ל-radius-slider חי.** `Radius.circular(radiusCard)` ב-const RoundedRectangleBorder (922/1734 · גליונות-תחתית) נשארו — const, מחוץ ל-pattern. cfgRadius default=20 ⇒ פיקסל-זהה.
**אימות (אוטומטי):** `zero_regression` 16 · `config_theme_test` 12 · `gate_118` · `a11y_contrast_theme_test` 5 — כולם ירוקים · analyze 0 (תופס כל const/context-error — נקי ⇒ כל 14 חוקיים).
**הפיכות:** replace_all חזרה `cfgRadius(context)→BsTokens.radiusCard`.

## studio-s29-b4 — Phase E אימוץ-עיצוב: לוח-ספק (store_dashboard) → cfgRadius — שינוי-נראה: אפס (default) — 2026-06-29
**שינוי נראה:** **אפס בברירת-מחדל.** Batch-4: כל 24 אתרי `BorderRadius.circular(BsTokens.radiusCard)` ב-`store_dashboard_screen.dart` → `cfgRadius(context)` (replace_all + import). אומת ע"י analyze נקי (תופס const/missing-context). **כל כרטיסי לוח-הספק (24) מגיבים עכשיו ל-radius-slider.** cfgRadius default=20 ⇒ פיקסל-זהה.
**אימות (אוטומטי):** analyze 0 (כל 24 חוקיים) · `config_theme_test` 12 · `a11y_contrast_theme_test` 5 — ירוקים.
**הפיכות:** replace_all חזרה.

## studio-s29-b5 — Phase E אימוץ-עיצוב: 4 מסכים (finance/worker/smart-home/rewards) → cfgRadius — שינוי-נראה: אפס (default) — 2026-06-29
**שינוי נראה:** **אפס בברירת-מחדל.** Batch-5 (יעיל — 4 מסכים ב-commit אחד): cfgRadius adoption ב-`finance_hub_sheets`(13) · `worker_app_screen`(11) · `smart_home_screen`(11) · `rewards_hub_screen`(11) = **46 אתרים**. כל אחד: import + replace_all, אומת ע"י analyze נקי. **כרטיסי 4 מסכים-נוספים מגיבים עכשיו ל-radius-slider.** cfgRadius default=20 ⇒ פיקסל-זהה.
**אימות (אוטומטי):** analyze 0 (כל 46 חוקיים) · `config_theme_test` 12 · `a11y_contrast_theme_test` 5 — ירוקים.
**הפיכות:** replace_all חזרה (4 קבצים).

## studio-s29-b6 — Phase E אימוץ-עיצוב: 5 מסכים (tasks/profile/smart-project/projects/courier) → cfgRadius — שינוי-נראה: אפס (default) — 2026-06-29
**שינוי נראה:** **אפס בברירת-מחדל.** Batch-6: cfgRadius adoption ב-`tasks_screen`(8)·`profile_screen`(9)·`smart_project_screen`(6)·`projects_screen`(6)·`courier_dashboard_screen`(7) = **36 אתרים**. **2 אתרים ב-helpers חסרי-context** (`_kvTile`/`_logDay`) הושארו ב-radiusCard קבוע (analyze תפס אותם — יאומצו כש-context יושחל). **הוסר import מת** (`under_construction` ב-tasks_screen — אומת לא-בשימוש). cfgRadius default=20 ⇒ פיקסל-זהה.
**אימות (אוטומטי):** analyze 0 (errors+warnings) · `config_theme_test` 12 · `a11y_contrast_theme_test` 5 — ירוקים.
**הפיכות:** replace_all חזרה (5 קבצים) + החזר import.

## studio-s29-b7 — Phase E אימוץ-עיצוב: 5 מסכים (store_profile/departments/worker_attendance/courier_profile/ai_hub) → cfgRadius — שינוי-נראה: אפס (default) — 2026-06-29
**שינוי נראה:** **אפס בברירת-מחדל.** Batch-7: cfgRadius ב-`store_profile`(6)·`departments`(6)·`worker_attendance`(5)·`courier_profile`(5)·`ai_hub`(5) = **27 אתרים**. `courier_portal_tab`+`persona_portal` **הוחזרו לגמרי** (helpers חסרי-context — analyze תפס 3 אתרים → נדחים ל-context-threading; net-zero, לא ב-commit). cfgRadius default=20 ⇒ פיקסל-זהה. **16 מסכים מאומצים-radius.**
**אימות (אוטומטי):** analyze 0 (errors+warnings) · `config_theme_test` 12 · `a11y_contrast_theme_test` 5 — ירוקים.
**הפיכות:** replace_all חזרה (5 קבצים).

## studio-s29-b8 — Phase E אימוץ-תוכן (CfgText): כותרות פרטי-מוצר בקטלוג — שינוי-נראה: אפס — 2026-06-29
**שינוי נראה:** **אפס (answer-equivalent).** Batch-8 — **ציר-התוכן (לב s29)**: 5 כותרות-סקשן סטטיות בעמוד פרטי-המוצר ב-`catalog_screen.dart` (mega-file, section-by-section) → CfgText: 'תקינות נדרשת'·'מה הקו צריך לחיבור'·'בדיקת קבלה (סיום התקנה)'·'תקן ישראלי רלוונטי'·'טעויות נפוצות וטיפים' → `catalog.detail.{requiredStandards/connectionNeeds/acceptanceCheck/israeliStandard/commonMistakes}`. הליטרל+style נשמרים fallback (const נשמר). +5 שורות registry (append-only, wired, content). **הבעלים יכול עכשיו לערוך את כותרות פרטי-המוצר.** רק static `Text('ליטרל')`; interpolated/`for-in` בסביבה לא נגעו.
**אימות (אוטומטי):** `gate_118_test` (5 ids ⊆ registry) · `registry_contract` 8 · `zero_regression` 28 · analyze 0.
**הפיכות:** `CfgText→Text` (5) + הסר 5 registry rows + import.

## studio-s29-b9 — Phase E אימוץ-תוכן (CfgText): עוד 5 תוויות-קטלוג — שינוי-נראה: אפס — 2026-06-29
**שינוי נראה:** **אפס (answer-equivalent).** Batch-9 — עוד 5 ליטרלי-קטלוג סטטיים → CfgText: 'מוצר' (תג-כרטיס)·'תבניות:' (תווית)·'מתי לבחור איזה מותג' (כותרת)·'נצפו לאחרונה' (כותרת)·'נקה הכל' (כפתור) → `catalog.{card.productBadge/templates.label/detail.brandGuide/detail.recentlyViewed/search.clearAll}`. ליטרל+style fallback (const נשמר). +5 registry rows. **10 תוויות-קטלוג ניתנות-לעריכה.**
**אימות (אוטומטי):** `gate_118_test` (ids⊆registry) · `registry_contract` 8 · `zero_regression` 28 · analyze 0.
**הפיכות:** `CfgText→Text` (5) + הסר 5 registry rows.

## studio-s29-b10 — Phase E אימוץ-תוכן (CfgText): כפתורי-פעולה בקטלוג — שינוי-נראה: אפס — 2026-06-29
**שינוי נראה:** **אפס (answer-equivalent).** Batch-10 — 4 ליטרלים עם emoji-לגאסי בקטלוג → CfgText: '📦 נתוני קטלוג' (כותרת)·'🔧 בנה לי קו (BOM)'·'➕ הוסף לפרויקט'·'💾 שמור גרסה' (כפתורי-פעולה) → `catalog.detail.dataHeader`·`catalog.action.{buildBom/addToProject/saveVersion}`. ה-emoji כבר-לגאסי (אין emoji חדש → gate-64 בטוח). ליטרל+style fallback (const נשמר). +4 registry rows. **14 תוויות-קטלוג ניתנות-לעריכה.**
**אימות (אוטומטי):** `gate_118_test` (ids⊆registry) · `registry_contract` 8 · `zero_regression` 28 · analyze 0.
**הפיכות:** `CfgText→Text` (4) + הסר 4 registry rows.

## studio-s29-b11 — Phase E אימוץ-תוכן (CfgText): כפתורי-צ'יפ בקטלוג — שינוי-נראה: אפס — 2026-06-29
**שינוי נראה:** **אפס (answer-equivalent).** Batch-11 — 3 כפתורי-צ'יפ בקטלוג → CfgText: '📋 הצעה'·'✨ נסח'·'🔌 איך לגשר?' → `catalog.action.{proposal/draft/howToBridge}`. (היו `Text(` לא-const עם args-const ⇒ עטפתי כ-`const CfgText`, analyze אישר.) +3 registry rows. **17 תוויות-קטלוג ניתנות-לעריכה — אימוץ-הטקסט-הסטטי בקטלוג הושלם מהותית.** הנותר בקטלוג = interpolated/`Text.rich` (out-of-v1).
**אימות (אוטומטי):** `gate_118_test` (ids⊆registry) · `zero_regression` · analyze 0.
**הפיכות:** `CfgText→Text` (3) + הסר 3 registry rows.

## manager-dashboard-live-pill — חיווי "חי" → צבע-לפי-סטטוס-קישוריות — שינוי-נראה: כן — 2026-07-20
**שינוי נראה:** הפיל בכותרת לוח-המנהל היה **ירוק "חי" קבוע תמיד**. עכשיו הוא קורא `connectionStatusProvider` ומשנה צבע+טקסט לפי המצב: 🟢 ירוק "חי" (מחובר · רקע `0xFFE7F6EC`/טקסט `0xFF1B7A3D`) · 🔴 אדום "מנותק" (רקע `0xFFFCE9E7`/טקסט `0xFFB23B3B`) · ⚪ אפור "דמו" (רקע `0xFFEDEAE3`/טקסט `0xFF6F6656` — מסלול Firebase-free/test). `_Dot` מקבל את צבע-המצב. הטקסט קוצר למילה-אחת (חי/מנותק/דמו) — נתפס בעין overflow של RenderFlex 32px ב-Row-הכותרת ותוקן (הכותרת כבר `Expanded`).
**אימות (עין + אוטומטי):** רונדר בטסט — `manager_dashboard_screen_test` (30 ירוקים) מאמת שבמסלול-דמו הפיל = **'דמו'** (לא "חי"), והתיקון-אחרי-overflow הוכיח שה-Row נפרש נכון ללא פסים צהובים-שחורים. mutation-verify: hardcode `connected` ⇒ 0 'דמו' (הראה "חי") ⇒ אדום ⇒ שחזור. analyze 0 errors.
**הפיכות:** `_LivePill`→StatelessWidget-הירוק-הקבוע + `_Dot` חזרה ל-const-ירוק + הסר import `connection_status`.

## manager-dashboard-drill — אריחי-KPI + שורות-pipeline לחיצים — שינוי-נראה: כן — 2026-07-20
**שינוי נראה:** 5 אריחי-ה-KPI ו-6 שורות-ה-pipeline בלוח-המנהל **לחיצים עכשיו** — `InkWell` שקוף (ripple + סמנטיקת-כפתור) באותו radius של הכרטיס. לחיצה מנווטת: 🚚→טאב הזמנות · 📦/🧰/✅/🏪→טאב ניהול · שורת-pipeline→טאב הזמנות. **עיצוב-הכרטיס עצמו לא-שונה** (אותו רקע `cardLight`/רדיוס/גבול); אריח בלי `onTap` נשאר פיקסל-זהה (golden-safe). הריפל נצבע ע"י ה-Material-השקוף, לא גולש מהכרטיס.
**אימות (עין + אוטומטי):** `manager_dashboard_screen_test` (31 ירוקים) — `KPI tiles drill down` מאמת ש-tap 🚚 ⇒ tab 1 ו-tap 📦 ⇒ tab 3 (הניווט באמת מתרחש, לא רק נוכחות). mutation-verify: 🚚 `go(1)`↦`go(0)` ⇒ אדום ⇒ שחזור. analyze 0 errors.
**הפיכות:** הסר `onTap` מ-5 האריחים + 6 השורות · `_MetricTile`/`_PipelineRow` בלי InkWell · `_MetricGrid`/`_OrderPipeline` חזרה ל-StatelessWidget.

## fake-sweep-suppliers-count — כיתוב "66 מוצרים" קבוע → ספירת-קטלוג חיה — שינוי-נראה: כן — 2026-07-20
**רקע (הנחיה `DIRECTIVE-fake-data-sweep.md` · S4 · מאומת file:line @HEAD 51897dd6):** אריח "ליפסקי ברקן" ב-`suppliers_screen.dart:42` הראה כיתוב-משנה **"66 מוצרים" קבוע-בקוד** — שקר פי-~14 (הקטלוג האמיתי `kLipskeyCatalog` = ~923 מוצרים), וסתר את המסך שהאריח עצמו פותח (`lipskey_brand_screen.dart:68` כבר מציג `kLipskeyCatalog.length`).
**שינוי נראה:** הכיתוב עכשיו `'…• $kLipskeyProductCount מוצרים'` → המספר האמיתי (~923), זהה למסך-היעד. הוספתי const `kLipskeyProductCount = kLipskeyCatalog.length` ב-`lib/data/lipskey_catalog.dart` — **המסך קורא את הקבוע, לא את הקטלוג** (gate 114 / לקח #69: קריאת `kLipskeyCatalog` מ-UI מפספסת Huliot/PPR → כרטיס לבן; screens חייבים לקרוא את הספירה מ-data). import כבר קיים (:2).
**אימות (אוטומטי):** analyze 0 · byte-verify: '66 מוצרים' נעלם (grep 0) · `kLipskeyProductCount` נוכח בשני הקבצים · טסט חדש `lipskey_product_count_test` (count==length && >900). mutation-verify (conformance): הזרקת '66 מוצרים' חזרה → `assert-manifest` אדום (present+absent שניהם FAIL, exit 1) → שחזור → ירוק.
**הפיכות:** `$kLipskeyProductCount`→`66` בכיתוב + הסר const מ-data + הסר הטסט.

## fake-sweep-share-clipboard — כפתור "שתף קוד" הבטיח "הועתק" בלי להעתיק → העתקה אמיתית — שינוי-נראה: התנהגות — 2026-07-20
**רקע (הנחיה `DIRECTIVE-fake-data-sweep.md` · H3 · פקד-מת · מאומת):** כפתור "📤 שתף את הקוד" ב-`rewards_hub_screen.dart` הקפיץ toast "קוד ההזמנה הועתק" אבל **אפס `Clipboard` בקובץ** (grep 0) — אישור-שקר.
**שינוי נראה (התנהגות, לא-פיקסל):** ה-onTap עכשיו `Clipboard.setData(const ClipboardData(text: kReferralCode))` ואז ה-toast → ההבטחה אמת. טקסט ה-toast **לא-שונה** (עכשיו נכון). + import `flutter/services.dart`.
**אימות (אוטומטי):** analyze 0 · byte-verify: `Clipboard.setData` נוכח (:342) · import services נוכח (:9) · מחרוזת-ה-toast ללא-שינוי (grep 1). (כיסוי-בדיקה: לשקול mutation-test עם mock-channel שלוכד `Clipboard.setData` — נשקל בסיום ה-batch.)
**הפיכות:** onTap חזרה ל-`() => showToast(...)` + הסר import services.

## fake-sweep-finance-fxgate — 4 מספרי-הדגמה בפיננסים שסתרו נתונים-חיים → גידור בתבנית-ה-FX — שינוי-נראה: כן — 2026-07-20
**רקע (הנחיה `DIRECTIVE-fake-data-sweep.md` · F1/F2/F3/F4 · מאומת @HEAD 51897dd6):** 4 גיליונות ב-`finance_hub_sheets.dart` הציגו מספרי-const שאין להם מקור-שרת: **ROI צפוי** (מבנית תמיד 42.0% — `projectRoi()`) · **קבלני-משנה** (ניצול% מ-`kSubcontractors`) · **מדד תשומות-בנייה** (`kBuildIndex` 121.3→128.7) · **פיצול-חשבונית** (`kInvoiceTotal` ₪12,800). כשהבקאנד דלוק (מצב-הבעלים) הם סתרו את השורות-החיות-הריקות לצידם.
**שינוי נראה:** מיושמת **בדיוק תבנית-ה-FX שכבר בקובץ** (`_openFx`/`_fxRatesToShow`): כל גיליון קיבל הערת-שרת קבועה (`⚙️ …מתעדכנים מהשרת — כאן מוצגים נתוני דמו`, `CfgText` ניתן-לעריכה, 4 ids חדשים ברישום) + גייט `useFirebaseBackend ? ריק : דמו` בכל צרכן-מזויף. **מסלול-OFF (דמו/טסטים) = בייט-זהה לקודם + ההערה בלבד**; מסלול-ON (בקאנד) = הערכים המזויפים נעלמים ל"מהשרת" במקום להתנגש. הערכים המזויפים לא-נמחקו (עטופים) — ה-*_seeds test-locked לא-נגעו. סימון-כן (MARKED), לא חיווט (אין feed).
**אימות (אוטומטי + עין-קוד):** analyze 0 · `studio_registry_view_test` ירוק (4 ה-ids החדשים grounding נכון) · `phaseb_seeds_test`/`backend_flag_test` ירוקים (מסלול-OFF ללא-רגרסיה) · הסוויטה המלאה ירוקה. **סיכון-מקובל מתועד:** מסלול-ON (בקאנד-דלוק) חסר-כיסוי-בדיקה — זהה-בדיוק לתקדים-ה-FX ששוגר כך; אימות-סופי דורש עין-הבעלים על הבניה-החיה.
**הפיכות:** להסיר 4 בלוקי הערת-שרת + לפרק כל `useFirebaseBackend ? …` חזרה לענף-הדמו + להסיר 4 שורות register.

## fake-sweep-store — חנות: הסרת 5 הזמנות-דמו · הסתרת צ'יפ-הצעות · אריח-הזמנות חי — שינוי-נראה: כן — 2026-07-20
**רקע (הנחיה `DIRECTIVE-fake-data-sweep.md` · S1/S2/S3 · מאומת ע"י מאמת-B @HEAD 6ac38592):** `store_screen.dart` הראה 3 שקרים לקבלן: (S1) `storeOrdersProvider` מיזג `[...חי, ...5 הזמנות-דמו קבועות]` (BS-1234 ₪5,420 'בדרך' ...) שזיהמו את מונה "ההזמנות הפתוחות" — כל קבלן-חדש ראה 5 הזמנות + ~3 "פתוחות" שלא ביצע; (S2) צ'יפ `📨 3 הצעות ספקים` = const `_kSupplierOffersCount`, מרונדר בין 2 צ'יפים חיים ולא מגודר; (S3) אריח `📦 ההזמנות שלי` עם `preview:'הזמנה #1234'`+`badge:1` קבועים — כל משתמש-אפס ראה "1" אדום.
**שינוי נראה:** (S1) הוסר const `_kContractorDemoOrders`; הפרוביידר מחזיר את ההזמנות-החיות בלבד → קבלן-חדש רואה **מצב-ריק כן** (0 פתוחות) במקום 5 מזויפות. (S2) הצ'יפ `📨` מגודר `if (!kHideUnderConstruction)` → לא מוצג בבניה-החיה. (S3) ה-`.map` גוזר את אריח-📦 מ-`storeOrdersProvider`: `badge`=מספר-הזמנות-פתוחות, `preview`= הזמנה-אחרונה או 'אין הזמנות פעילות' — אפס-מזויף.
**אימות:** analyze 0 · **2 בדיקות שוכתבו להתנהגות-אמת:** `state_deep_test` 'seed 3 open'→'fresh ⇒ empty ⇒ 0 open' (הגארד ל-S1); `store_notif_widget_test` מציב הזמנה-אמיתית (id BS-1234) במקום const-דמו ואז בודק את גיליון-המעקב על הזמנה-חיה. `apple_readiness_hide_pass_test:191` (אריח-📦 גלוי לפי כותרת 'ההזמנות שלי') נשאר ירוק — שיניתי preview/badge, לא כותרת. הסוויטה המלאה ירוקה בשער.
**הפיכות:** להחזיר את const `_kContractorDemoOrders` + הספרייד `[...liveOrders, ...demoOrders]`; להסיר את גייט-ה-`if` מצ'יפ-📨; להחזיר את ה-`.map` לענף-🛒-בלבד + preview/badge קבועים. ולשחזר את 2 הבדיקות.

## fake-sweep-H1 — הסרת פס-התקדמות מזויף 38% ("גמר אמבטיה") — שינוי-נראה: כן — 2026-07-20
**רקע (הנחיה `DIRECTIVE-fake-data-sweep.md` · H1 · החלטת-בעלים "2א"=להסיר):** כרטיס "מסלול עבודה חכם / גמר אמבטיה" ב-`smart_home_screen.dart:465-472` הכיל `const LinearProgressIndicator(value: 0.38)` — פס-התקדמות **קבוע-מזויף** (38% זהה לכל משתמש), והכרטיס גם לא-נפתח בלחיצה (העץ-4-שלבים שמאחוריו לא נבנה — מאמת-D אישר: אין provider-התקדמות ואין מסך-יעד). "לחבר onTap/ערך-אמת" = לבנות פיצ'ר לא-קיים (defer). התיקון הכן = להסיר את הפס.
**שינוי נראה:** הוסר ה-`ClipRRect`+`LinearProgressIndicator`(38%) + ה-`SizedBox(height:10)` שלפניו. הכרטיס נשאר כ**טיזר-כן** (badge "🛁 חדש" + כותרת "גמר אמבטיה" + תת-כותרת "4 שלבים...") בלי מחוון-אחוז מזויף. אין CfgText id בפס → אין נגיעה ברישום.
**אימות:** analyze 0 · אין טסט שבדק את הפס (grep 0.38/workpath/LinearProgressIndicator = 0 בטסטים) · שער מלא ירוק. גארד-רגרסיה: `smart_home_screen.dart:::!value: 0.38`.
**הפיכות:** להחזיר את בלוק ה-`ClipRRect`/`LinearProgressIndicator` + `SizedBox(height:10)`.

## fake-sweep-M2 — אשראי-לקוח: מספר-מהשם → מספר-אמת-מהשרת או "לא רשומה" — שינוי-נראה: כן — 2026-07-20
**רקע (הנחיה `DIRECTIVE-fake-data-sweep.md` · M2/M3 · החלטת-בעלים "1א" · מאמת @HEAD 44c7b019):** מסגרת-האשראי של כל לקוח (30–120 אלף ₪) חושבה מ-`contractorCredit(name)` = **hash של השם** (`manager_dashboard.dart:256-264`), לא מרשומה. מקור-שרת אמיתי (`computeCredit`/`customerCreditProvider`) כבר בנוי, אבל המסלול-המקומי/דמו ומונה-הפיקוח עקפו אותו והמציאו את ה-hash — כולל דליפה לקו-פיילוט.
**שינוי נראה:** (A1) `mgrCustomerList:282` `creditLimit: contractorCredit(o.who)` → `0` (סוגר בבת-אחת: כרטיס+גיליון-fallback · `_customerViewsProvider` · fleet · דליפת-קו-פיילוט · flicker). (A2/A3) `customers_local` `creditLimit()`→`0` ו-`_localCredit` מחזיר `creditLimit:0/balance:0/pct:0` אבל **`used`/`orderCount` נשארים אמיתיים** (מראה FirebaseCustomersRepository). (B4-B7) התצוגה: כרטיס `liveLimit<=0 ? 'אשראי: לא רשומה'` · גיליון tile `'—'` · שורת מסגרת `'לא רשומה'` · שורת יתרה `'—'`. **`contractorCredit` נשמרה** (לא-נמחקה) — `credit_never_invented_test` נועל אותה כ"ערך-אסור". על השרת: מספר-אמת/"לא רשומה". בדמו: הכל "לא רשומה".
**תוצאה מודעת:** תג "⚠️ אשראי גבוה" + פילטר-האשראי-הגבוה **רדומים בדמו** (היו מבוססי-hash מזויף; pct תמיד 0 בלי תקרה-אמיתית). יֵצְאוּ רק על נתוני-שרת אמיתיים — מתועד לבעלים.
**אימות:** analyze 0 · 96 בדיקות-אשראי ירוקות כולל `credit_never_invented` (הנעילה) · 3 בדיקות שוכתבו (orders_credit_a13/manager_credit_computecredit_consumer/manager_dashboard_screen — כולל שכתוב פילטר-האשראי-הגבוה עם תקרה-מוזרקת דרך override, המדגים שהפיצ'ר עובד על נתוני-אמת) · הסרת חלוקה-באפס (KEYSTONE :614). שער מלא ירוק.
**הפיכות:** להחזיר `contractorCredit(o.who)` ב-:282, `contractorCredit(name)` ב-customers_local, ולפרק את 4 גייטי-ה-`<=0` בתצוגה. ולשחזר את 3 הבדיקות.

## fake-sweep-rewards — תווית "(דמו)" ללוח-מובילים · תגים · קוד-הזמנה — שינוי-נראה: כן — 2026-07-20
**רקע (הנחיה 2 · פרוסת-תגמולים · מאמת-3 @HEAD 66f8ca33):** ב-`rewards_hub_screen.dart` — לוח-המובילים: הדירוג *חי* (`rewardsProvider.leaderboard`, שורת-"אתה" מסונכרנת למטבעות אמיתיים) אבל **המתחרים const-מזויף** (`kLeaderboardSeed`: לוי-ובניו 1240... לא-משתנים), מוצג ככותרת "דירוג הקבלנים החודש". תגים "N/4": הספירה מחושבת אך ה-earned קבועים (תמיד "2/4", אין tracker). קוד-הזמנה `BUILD-7K29` const משותף מוצג כ"הקוד **שלך**". **גילוי מכריע:** ה-"(דמו)" **לא verbatim** (הפורט הוסיף אותו; פרוטו 21461 בלי) + `legal_texts.dart:42` **מגלה משפטית** שמסכי-דמו מסומנים → דמו לא-מסומן = חוסר-עקביות (לא legacy-faithful).
**שינוי נראה:** 3 שורות `_ServerNote('⚙️ בפרודקשן: … — כאן … דמו')` (הווידג'ט הקיים ב-`:956`, Text רגיל — **אין CfgText/רישום**) מתחת לראש כל אחד: לוח-מובילים (:209) · תגים (:247) · קוד-הזמנה (:346). **תווית-בלבד** — ערכי ה-const לא-נגעו (הדירוג-החי, הספירה, הקוד נשארים; `t3_ghi` נועל values/lengths ועובר). המנגנון-החי (דירוג/ספירה) לא-שונה — רק סומן שהתוכן דמו.
**אימות:** analyze 0 · אין טסט שמרנדר RewardsHubScreen (מאמת-3) · `t3_ghi_rewards_ai_home_test` ירוק (asserts consts, לא render). שער מלא — בשער-ה-commit. גארד: `rewards_hub_screen.dart:::דירוג חי מהשרת`.
**הפיכות:** להסיר 3 שורות ה-`_ServerNote` (:209/:247/:346).

## fake-sweep-courier-supplier — גידור צי-דמו · דירוגי-ספקים · זמינות + שורות "יתחבר עם השרת" — שינוי-נראה: כן — 2026-07-20
**רקע (הנחיה-2 · פרוסת-שליח+ספק · מאמת-2 @HEAD 4ad56946):** בפורטל השליח/ספק שורות-דאטה מזויפות רונדרו **ללא-תנאי** (רק תוויות ה-`_note` היו מגודרות ב-`kHideUnderConstruction`) — כלומר ב-review של אפל התווית נעלמת אך הצי/הדירוגים המזויפים נשארים (F-48). אין מקור-חי לאף אחד (kFleet=`supplier_data.dart:225` · kSupplierRatings=`:274` · kHaulAvailabilityDemo — כולם const-דמו) → "לחווט" בלתי-אפשרי, גידור הוא הפתרון הכן.
**שינוי נראה:** (courier_portal_tab) זמינות-הדמו מגודרת **בתוך השורה** (סוג-רכב+מחיר אמיתיים נשארים תמיד) · `kFleet` (V14/נהגים) מגודר `if(!kHideUnderConstruction)` (הטירים שומרים על הגיליון לא-ריק) · הערת-המפה :219 נוסחה נקי (הוסר "בדמו" שדלף ל-review). (persona_portal) `kSupplierRatings` + `kFleet` מגודרים **יחד-עם-התווית**, ובמקום גיליון-ריק — `else` עם שורה כנה: "דירוגי ספקים חיים / ניהול צי חי יתחבר עם חיבור השרת". **תוצאה ב-review אפל: אין נתון-מזויף ואין מסך-ריק — מוצג "יתחבר עם השרת".**
**אימות:** analyze 0 · **0 שינויי-בדיקה** (מאמת-2) — `t9_supplier_personas_test` (const `kFleet.first.driver=='אבי'`) לא-מושפע (const נשמר) · `apple_readiness_hide_pass_test` ירוק (התוויות 'זמינות להדגמה'/'נתוני הדגמה' + kHideUnderConstruction נשמרו). שער מלא בשער-ה-commit. גארדים: `persona_portal.dart:::דירוגי ספקים חיים יתווספו` + `:::ניהול צי חי יתחבר`.
**הפיכות:** להוציא את שורות-הדאטה מהגייטים (חזרה ל-render-ללא-תנאי) + להחזיר את הערת-המפה הישנה.

## fake-sweep-finance-approval — חיווט תור-אישורי-רכש לריפו (server-אמיתי) + ניקוי 4 הערות (F7) — שינוי-נראה: כן — 2026-07-20
**רקע (הנחיה-2 · פרוסת-פיננסים · מאמת-finance @HEAD bcf3bf52):** `approvalQueueProvider` תמיד זרע מ-`kApprovalQueue` (דמו AP-201/202) — כלומר **גם על השרת הבעלים ראה אישורי-רכש מזויפים**, לא אמיתיים. ה-impl האמיתי (`FirebaseFinanceRepository.approvals()/decide()`) היה קיים אך לא-מחובר (הבעלים ביקש: "יש impl — לחווט"). *(4 ערכי-הפיננסים ROI/משנה/מדד/חשבונית — אין להם מקור-אמת → Slice B דולג בהחלטת-בעלים; נשאר ה-FX-gate.)*
**שינוי (חיווט אמיתי):** 3 חברים חדשים לממשק `FinanceRepository` (`approvals()/decide()/approvalsListenable`); `LocalFinanceRepository` מחזיר את זרע-הדמו, `FirebaseFinanceRepository` מחזיר את הרשימה-המתמשכת מ-Firestore + `approvalsListenable=>_approvals` (ChangeNotifier, כמו budgetListenable). `ApprovalQueueNotifier` קיבל ctor-אופציונלי: זורע ומתעדכן-מחדש מ-`financeRepo().approvals()` (שרת=אמיתי · דמו/no-arg=seed), ו-`decide` נכתב-כפול לריפו; נמחק ה-dual-write הידני בגיליון (:788-793, הנוטיפייר מחזיק אותו). **תוצאה: על הבניה-החיה — אישורי-רכש אמיתיים מהשרת, לא AP-201/202.**
**F7 (ניקוי הערות):** 4 הערות-השרת (מדד/משנה/ROI/חשבונית) הורידו את "— כאן מוצגים נתוני דמו" המבלבל (שקרי כשריק על השרת) → "⚙️ נתוני X מתעדכנים מהשרת" (נכון בשני המצבים); עודכנו גם 4 ה-labelHe ברישום.
**אימות:** analyze 0 (מחזור-import Dart-legal מתקמפל) · **98 בדיקות ירוקות** — finance_hub_state (ctor-אופציונלי, no-arg עדיין ירוק) · budget_server_empty (fake+3 stubs) · finance_firebase_repo (@override) · studio_registry_view (labelHe) · phaseb_seeds (לא-נגע). שער מלא בשער-ה-commit.
**הפיכות:** להסיר 3 חברי-הממשק + חזרה ל-`ApprovalQueueNotifier()` ללא-repo + החזרת ה-dual-write הידני + החזרת סיומת-ההערות.

## fake-sweep-site-hub — תווית "(דמו)" ל-4 מקטעי-האתר הזרועים — שינוי-נראה: כן — 2026-07-20
**רקע (`/swarm` · site_hub · מאמת @HEAD acc48469):** `site_hub_screen.dart` הציג 4 const-דמו כמצב-אתר-חי **בלי שום תווית** — בניגוד לבני-הדוד המסומנים (תגמולים/AI/פיננסים/persona) ול-`legal_texts.dart:42` (מסכי-דמו מסומנים בכוונה). כל 4 = דמו-בלבד, אין מקור-אמת (מאמת: WIRE בלתי-אפשרי לכולם; מלכודת שנמנעה: archive→`kProjects` = סמנטיקה-שגויה active≠archived + עדיין-מזויף).
**שינוי נראה:** נוסף ווידג'ט מקומי `_SiteServerNote` (העתק idiom-ה-`_ServerNote` של תגמולים; radius ליטרלי כי site_hub בלי `cfgRadius`; `Text` רגיל — אין CfgText/רישום), ושורת-תווית מתחת לראש כל מקטע: מבנה-האתר (`kSiteTree` :591) · תלויות (`kSiteDeps` :944) · צילומים (`kSitePhotoPairs` :1024) · ארכיון (`kArchivedProjects` :1227). **תווית-בלבד** — ערכי ה-const (verbatim proto) לא-נגעו.
**אימות:** analyze 0 · בדיקות ירוקות — `phaseb_seeds_test`+`site_hub_state_test` (נועלים values/lengths, לא render) · `apple_readiness_*` (allowlist, site_hub לא-רשום; note לא-מגודר תואם תקדים-תגמולים) · אין widget-test שמרנדר את המקטעים. **1 קובץ · 0 שינויי-בדיקה/רישום.** גארד: `site_hub_screen.dart:::class _SiteServerNote`.
**הפיכות:** להסיר את ווידג'ט `_SiteServerNote` + 4 שורות-התווית.

## stage2-slice-B — רשימות-הזמנות עצלות (builder) — שינוי-נראה: **לא** (ניטרלי-חזותית) — 2026-07-24
**רקע (שלב-2 חוק-4 · B3):** רשימות-ההזמנות של לוח-המנהל (`_OrdersTab`) ולוח-החנות (`_homeTab`) נבנו eager — `ListView(children:[for …])` — כל השורות נבנות בכל rebuild (ב-10k הזמנות = 10k ווידג'טים). הומרו ל-`ListView.builder` (רק הנראות נבנות): manager — דפוס head+offset (תקדים `manager_copilot_screen.dart:167`); store — שני "האתרים" התגלו כ-scrollable אחד → השורות הועברו ל-builder החיצוני (nested-shrinkWrap אינו עצל), `_pipeline` פוצל ל-`_shownOrders`+`_pipelineHead`.
**מה רואים:** **שום שינוי** — אותם ווידג'טים, אותם strings (כולל `₪120` הנעול), אותו padding/סדר; בנייה עצלה בלבד. `manager_dashboard_screen_test` (101 ירוקות כולל drill/פילטרים) + `apple_readiness_missed_leaks` מאשרים.
**הפיכות:** להחזיר את שתי ה-`ListView(children:)` + לאחד את `_pipeline`.

## stage3-app-profile — ברירות-מחדל מודעות-פרופיל — שינוי-נראה: **לא** (plumbing בלבד) — 2026-07-24
**רקע (פרוסת-3.4):** 13 הצהרות-דגל ב-8 קבצים (בהם 2 קבצי-widgets: `bs_keyboard_host` · `store_comparison_line`) קיבלו `defaultValue: kProfile…` מ-`app_profile.dart` החדש. **מה רואים: שום שינוי** — בבניה ללא-פרופיל (וכל הסוויטה) כל ברירת-מחדל שווה לליטרל-של-היום; define-מפורש ממשיך-לגבור. 90 בדיקות ירוקות כולל כל סוויטות-נעילת-ברירות-המחדל. **הפיכות:** הסרת ה-`defaultValue:` וה-imports + מחיקת `app_profile.dart`.

## stage3-app-brand — ניתוב זהות-חברה — שינוי-נראה: **לא** (זהות-בייטים) — 2026-07-24
**רקע (פרוסת-3.2):** 30 מחרוזות-מותג ב-19 קבצים (בהם מסכים) הוחלפו לאינטרפולציית `AppBrand` — הפלט זהה-תו-לתו ('מועדון BuildSmart' וכו'). **מה רואים: שום שינוי** — 41 אסרטי-מחרוזת-חיים עברו ללא-עדכון; מוטציית name→'CleanCo' האדימה אותם (ההוכחה ההפוכה). **הפיכות:** שחזור הליטרלים + מחיקת app_brand.dart.

## stage3-catalog-reroute — ניתוב צרכני-קטלוג למקור-הפעיל — שינוי-נראה: **לא** (זהה-בייטים v1) — 2026-07-24
**רקע (המשך-3.1):** ~35 אתרי-קוד ב-9 קבצים (בהם 7 מסכים: catalog_screen · lipskey×2 · floating_card_keyboard · store_dashboard · ai_finder · worker-path דרך task_skus) הוחלפו `kCatalogProducts`→`resolvedCatalogProducts`. **מה רואים: שום שינוי** — תחת v1 ה-getter מחזיר את אותו אובייקט-const בדיוק; 49 בדיקות-צרכנים עברו ללא-עדכון. משמר-סט-סגור חדש מוכח-מוטציה. **הפיכות:** שחזור הליטרלים + ה-imports.

## stage3-org-stamp — חותמת-ארגון בצ'קאאוט — שינוי-נראה: **לא** (שדה-מודל רדום) — 2026-07-25
**רקע (St3):** `store_screen.dart` — קריאת `placeOrder` בצ'קאאוט מעבירה עכשיו גם `orgId: currentOrgIdProvider ?? ''` (לצד contractorUid, אותו idiom-A3). **מה רואים: שום שינוי** — אין משתמש עם claim עד ש-setOrg יופעל; ללא-claim השדה ריק ולא-מסודרל. 91 בדיקות ירוקות. **הפיכות:** הסרת השורה.

## clean-finish — הערות-פיננסים מצהירות-דמו + wordmark מודע-פרופיל — שינוי-נראה: **כן (דמו: 4 הערות) / לא (ברירת-מחדל wordmark)** — 2026-07-25
**פיננסים:** בבניית-הדמו 4 ההערות אומרות עכשיו '⚙️ בפרודקשן: נתוני X מהשרת — **כאן נתוני דמו**' (היה: בלי הצהרת-דמו — החלשת-F7 תוקנה); על-השרת הנוסח הקיים. **wordmark:** home_shell fallback→`AppBrand.name` — בברירת-מחדל 'BuildSmart' זהה-בייטים (שינוי גלוי רק בפרופילי clean/company2 — הפואנטה של שני-הלינקים). **הפיכות:** החזרת המחרוזות הבודדות.
## clean-empty-shell — מה נראה בכל פרופיל — שינוי-נראה: **לא (demo/buildsmart) / כן (clean/company2 בלבד)** — 2026-07-25
**רקע (הנחיית-בעלים "הקטלוג גם צריך להיות נקי"):** כל שערי-התוכן הם const-ternary שזרוע-ה-demo שלהם היא הליטרל-הקיים ללא-שינוי — **בבניית demo/buildsmart שום פיקסל לא זז** (133 בדיקות ממוקדות + כל סוללות-נעילת-הערכים עברו ללא-עדכון). **מה נראה ב-clean:** קטלוג/חיפוש/מחלקות — ה-empty-states הכנים הקיימים ('אין מוצרים תואמים' · 'לא נמצאו תוצאות' · 'אין קטגוריות במחלקה זו'); ספקים — empty-state חדש '🏪 אין ספקים עדיין · ספקים ומותגים יופיעו כשקטלוג החברה ייטען' (היה: רקע-חשוף); בית-חכם — שורת '🌳 עץ חכם' מוסתרת (היה: כותרת + פס-ריק 192px); הזמנות/משימות/תגמולים(0 מטבעות)/אתר/צ'אט('אין שיחות')/התראות/פיננסים/מלאי('המחסן ריק') — ריקים עם ה-empty-states הקיימים. **ב-company2:** קטלוג מלא (v2) + רשומות ריקות. **ידוע-ומקובל (פוליש-עתידי):** מקלדת-הכלים במסך-ספקים מקרינה 0 אריחי-מסך על clean (ה-fallback הקיים תופס רק סטאק-ריק). **הפיכות:** מחיקת שני-השערים + החזרת 15 הזרועות — demo זהה by-construction.

## company-catalog-import — כפתורי תבנית+העלאה — שינוי-נראה: **לא (demo/buildsmart) / כן (clean בלבד)** — 2026-07-25
**רקע (בעלים "כן"):** כל ה-mounts מאחורי `kProfileEmptyCatalog` (const-false בדמו — מקופל-החוצה, זהות-בייטים; הסוויטה עברה ללא-עדכון). **מה נראה ב-clean:** (1) כרטיס '📦 טעינת קטלוג החברה' בראש טאב-הקטלוג (idiom כרטיס-ספק: לבן·radius-14·chevron); (2) כפתור-טקסט '📦 טעינת קטלוג החברה' מתחת ל-empty-state של הספקים; (3) ה-sheet: כותרת+שורת-כנות ("מחירים והשוואת-חנויות יתווספו בשלב חיבור-השרת"), '⬇️ הורד תבנית לדוגמה', '⬆️ העלה נתונים', סטטוס 'נטענו N מוצרים'/'עדיין לא נטען קטלוג', רשימת-שגיאות גלילה ('שורה 12 — חסר שם המוצר'), הצלחה '✅ נטענו N מוצרים' + '🔄 רענן להחלת הקטלוג בכל המסכים'. sheet בסגנון-האחיות (rounded-top-22 · cardLight — כמו role_request/finance). **הפיכות:** הסרת 2 ה-mounts + הקבצים החדשים.

## clean-100 — שורות-נגזרות + כנות-מותג — שינוי-נראה: **לא (demo/buildsmart) / כן (clean · overlay חי)** — 2026-07-25
**רקע (E2E בדפדפן אמיתי, צילומי-מסך בתיעוד-הסשן):** demo — אפס שינוי (widget_test עבר ללא-עדכון; hero='BuildSmart' זהה-בייטים דרך AppBrand). **ב-clean:** hero+terms='BuildSmart Clean' (היה: 'BuildSmart' קשיח — נתפס-עין) · שקופית-הפתיחה אומרת 'קטלוג, חיפוש חכם, סל והזמנות — הכול במקום אחד. טוענים את קטלוג החברה ומתחילים לעבוד.' (היה: 'אלפי מוצרים') · 'קטגוריות' בלי-ייבוא=ריק-כן (היה: 8 שורות-אינסטלציה-0) · עם-ייבוא=קטגוריות-החברה בסדר-הקובץ עם '$N מוצרים', והקשה נכנסת לרשימת-המוצרים האמיתית (היה: 'בקרוב'). **הפיכות:** הסרת ענפי-companyCatalogActive + החזרת 3 המחרוזות.

## template-v2 — כרטיס מלא מקובץ + תיקוני-דליפה — שינוי-נראה: **לא (demo) / כן (חברה עם קטלוג)** — 2026-07-26
**רקע:** כל השינויים מאחורי companyCatalogActive / נתוני-ייבוא — demo זהה-בייטים (59 בדיקות ללא-עדכון; שלושת מסלולי-const נשמרו כ-else). **מה נראה אצל חברה:** כרטיס-מוצר עם תמונות אמיתיות (קישורים · פייג'ר 1/N) · טבלת-מפרט מכל עמודה שהוסיפה בקובץ · בלי "עמוד 0" · "חיבורים לפי מידה"/עמיתים/הצעות/לחיצת-מילה — הכול מאוצר-החברה בלבד (היו 4 דליפות-BuildSmart) · סריקת ברקוד-יצרן. **הפיכות:** הסרת השערים והעמודות.

## connections-pour-in — תכנון-חיבור על קטלוג מיובא — שינוי-נראה: **לא (demo) / כן (חברה)** — 2026-07-26
**רקע:** overlay-off ⇒ chainUniverse==kCompatCatalog (אותו אובייקט) ותגי-'מאומת' בייט-זהים — demo ללא-שינוי (69 בדיקות עברו כמות-שהן). **אצל חברה:** תכנון-חיבור, בוררי-הסטודיו ומפל-הלחץ עובדים על המוצרים *שלה*; כרטיס עם עמודות-קצה מציג "חיבורים תואמים" אמיתיים בכותרת **'לפי נתוני היבוא'** (לעולם לא 'מאומת' על יבוא); זיהוי-מגשרים (מצמד/מתאם/ברך) לפי שם. **הפיכות:** הסרת הגשר + 12 נקודות-chainUniverse + התגים.

## raw-shell — הקונכייה הגולמית — שינוי-נראה: **לא (demo/buildsmart/BuildMax) / כן (clean)** — 2026-07-26
**demo:** אפס שינוי (כל השערים const-false; הסוללה עברה ללא-עדכון). **ב-clean:** אין "מה התחום שלך?" (ישר שקפים) · סלוגן: 'קטלוג, חיפוש חכם, סל והזמנות — הכול במקום אחד' · בית בלי רצועת-מחלקות/'גמר אמבטיה'/'סרוק תוכנית' · טאב-מחלקות: '🗂️ אין מחלקות עדיין — יופיעו עם טעינת קטלוג החברה' → אחרי ייבוא: ריבועי המחלקות של-החברה (עמודת "מחלקה"; בלעדיה — הקטגוריות) עם כניסה-לרשימת-מוצרים · מקלדת בלי צ'יפי-מחלקות-BuildSmart (נגזרים-מהחברה) · חיפוש בלי טקסונומיית-אינסטלציה · 'דוח פיננסי — BuildSmart Clean'. **הפיכות:** הסרת השער ו-9 קבצי-הצרכנים.

## completion-round — שינוי-נראה: **לא (demo) / כן (clean±ייבוא)** — 2026-07-26
**demo:** אפס (151 ללא-עדכון). **clean בלי-ייבוא:** ⋮-בינה בלי חלופות/סריקה/Analytics · חנות-שירותים בלי השוואת-מחירים · צ'יפי-תכנון-חיבור ריקים · חיפוש בלי שמות-כלים-נסתרים ובלי פרויקטי-דמו. **clean עם-ייבוא:** משחקי-מילים/צלילות על מוצרי-החברה · רצועת-'מוצרים משלימים 🧩' בכרטיס (מהעמודה) · צ'יפי-קטגוריות-חיים בתכנון-חיבור. **הפיכות:** הסרת השערים/הצינורות.

## giant-v1 — שכבת-קונפיג ריצתית — שינוי-נראה: **לא** (plumbing; אפס-צרכנים) — 2026-07-26
דגל ORG_CONFIG כבוי-כברירת-מחדל + default=הכל-דלוק + אפס קוראים ב-V1 ⇒ שום פיקסל לא זז באף פרופיל (37 בדיקות ללא-עדכון). **הפיכות:** מחיקת 2 הקבצים + 2 שורות-boot + שורת-הסיווג.

## giant-v2-w1 — טוגלי-מודולים חיים — שינוי-נראה: **לא (ברירת-מחדל הכל-דלוק) / כן (קונפיג-חברה)** — 2026-07-26
**ברירת-מחדל:** אפס שינוי (100 בדיקות ללא-עדכון — חסר=דלוק). **עם קונפיג:** chat-off⇒עדכונים=התראות-בלבד (בלי סגמנט) · manager/supplier/courier/worker-off⇒נעלמים מהבוחר (קבלן לעולם-נשאר) · finance-off⇒'כספים' נעלם מהחנות · rewards-off⇒שורת-המועדון נעלמת · site/stock/compat-off⇒שורות-הבית · ai-off⇒שורת-⋮ · **החלפת-קונפיג חיה מרנדרת מיד בלי ריסטארט** (חוזה-האשף, מוכח-מוטציה). **הפיכות:** מחיקת org_gates + 9 ה-collection-if.

## giant-v2-w2 — שינוי-נראה: **לא (הכל-דלוק) / כן (קונפיג)** — 2026-07-26
**ברירת-מחדל:** אפס (152 ללא-עדכון). **עם קונפיג:** הקלדת 'שיח' לא מציעה שיחות/ארכיון · צ'יפי-חנות בלי שירותים/השוואה · צ'יפי-dive נעלמים · פוש-לצ'אט-כבוי=טוסט-כן ונצרך · תא-שיחות נעלם בבורד-ספק/עובד (בלי-שבירת-אינדקסים) · טאב-intel נעלם למנהל כשכבוי. **הפיכות:** הסרת התגים/הפרמטרים.

## giant-v3-w1 — מילון-מונחים — שינוי-נראה: **לא (בלי terms) / כן (קונפיג-חברה)** — 2026-07-26
**ברירת-מחדל:** אפס שינוי (termOf מחזיר את אובייקט-ה-fallback עצמו — זהות). **עם terms:** 4 טאבי-הניווט מתמתגים (nav.*) · שם-האפליקציה וכל אתרי-'מועדון BuildSmart' הרצים מתמתגים (brand.name/brand.club — פרופיל·פרסים·דוחות-עובד/שליח·פיננסים·drilldown) · **כל תווית-CfgText** מתמתגת לפי-המזהה-שלה — ודריסת-סטודיו שפורסמה עדיין מנצחת. החלפה-חיה מרנדרת מיד (חוזה-האשף). **הפיכות:** הסרת שכבת-ה-CfgText + החזרת 15 הליטרלים.

## giant-v4 — חבילות-ורטיקל — שינוי-נראה: **לא (אין צרכן-UI עדיין)** — 2026-07-26
**קובץ-דאטה+פונקציה טהורים** — האשף (V5) יהיה הצרכן המרנדר. שום מסך לא השתנה; ברירת-המחדל זהה-בייטים בהגדרה (אפס-imports מהאפליקציה אל הקובץ החדש). **הפיכות:** מחיקת הקובץ+הבדיקה.

## giant-v5 — אשף-ההקמה — שינוי-נראה: **לא (build רגיל) / כן (build חמוש ORG_CONFIG)** — 2026-07-26
**ברירת-מחדל:** אפס — הסקשן נעלם-בקומפילציה (collection-if על const). **חמוש:** טאב-ניהול מקבל סקשן-אחרון '🔌 אשף הקמת חברה' → מסך: פתק-חימוש (אם-רלוונטי) · שם-חברה · 6 שבבי-ורטיקל · 13 מתגי-מודול (מנהל-מושבת) · 6 שדות-מיתוג · שמור-והפעל/ייצוא/ייבוא/איפוס עם פתקי-כן. **הפיכות:** הסרת הסקשן+המסך+הרישום.

## giant-v6 — ערוץ-plumbing אפוי — שינוי-נראה: **לא (הערוצים הקיימים) / כן (הערוץ החדש)** — 2026-07-26
**clean/company2:** אפס-שינוי (defines זהים). **plumbing (חדש, אחרי הרצת-workflow):** נבנה clean+חמוש עם פרוסת-אינסטלציה בנתיב-החברה — מסלולי-עומק וטאב-המודיעין כבויים מהקופסה, שם-הארגון 'אינסטלציה דמו'; שמירת-אשף מקומית עדיין דורסת (owner מעל company). **הפיכות:** מחיקת שורת-המטריצה + הקבוע.

## giant-v6.1 — הוכחת-הדפדפן: אותו קומיט, שתי זהויות — 2026-07-26
**4 פריימים (נמסרו לבעלים):** A1 בית-בסיס — "BuildSmart Clean"+"מחלקות" · A2 עדכונים-בסיס — סגמנטי שיחות+התראות · B1 בית-אינסטלציה — **"אינסטלציה דמו"+"צנרת"** (terms מהנתיב-האפוי דרך שכבת-CfgText/nav) · B2 עדכונים-אינסטלציה — **סרגל-הסגמנטים איננו** (chat:false ⇒ התראות-בלבד, דגרדציית-V2). השרשרת המלאה חיה: define → kOrgCompanyJson → hydrate(company) → resolver → provider → שערים+מונחים.

## p2-w1a — מנוע-ההתראות — שינוי-נראה: **לא (ברירת-מחדל/חי) / כן (חברה שמדליקה manager.attention)** — 2026-07-26
**ברירת-מחדל (opt-in כבוי):** אפס — הקוקפיט זהה-בייטים (22+51 בדיקות, הכרטיס לא-מרונדר גם כשיש פריטים). **חברה שמדליקה:** מעל ה-KPIs מופיע כרטיס "🔔 דורש טיפול" — שורות מדורגות (crit אדום קודם, warn כתום), כל שורה → drill לטאב-המנהל הרלוונטי; אפס-פריטים=כלום. **הפיכות:** הסרת ה-collection-if + המנוע/הספק.

## p2-w1b — קרנל-ה-workflow — שינוי-נראה: **לא (אין צרכן-UI בפרוסה)** — 2026-07-26
**קובץ-לוגיקה טהור** — אין מסך שמייבא אותו עדיין (מוצהר: הצרכן-החי בעיצוב-עם-הבעלים). ברירת-מחדל זהה-בייטים בהגדרה. **הפיכות:** מחיקת הקובץ+הבדיקה.

## p2-w2a — ליבת-CRM — שינוי-נראה: **מינימלי (רק ח"פ שגוי נדחה בטפסים)** — 2026-07-26
**נראה למשתמש:** ח"פ עם ספרת-ביקורת שגויה מציג שגיאה בטפסי-הפרופיל/חנות (היה עובר בטעות). כל השאר — פרימיטיבים טהורים בלי צרכן-UI (normalizePhone/fuzzy/normSearch — צרכנים מגודרים בפרוסות הבאות). **הפיכות:** החזרת validBusinessId ל-9-ספרות + מחיקת הקבצים החדשים.

## p2-w2b — ישות-לקוח שמורה — שינוי-נראה: **לא (ברירת-מחדל) / כן (manager.customers)** — 2026-07-26
**ברירת-מחדל (opt-in כבוי):** אפס — גיליון-פרטי-הלקוח זהה-בייטים (הבלוק לא-מרונדר; רגרסיית-המנהל הנעולה עוברת). **חברה שמדליקה:** בגיליון-הפרטים מופיע "פרטי לקוח" — טלפון/מייל/הערות/תגיות של הישות-השמורה (חיבור-בשם), + כפתור הוסף/ערוך → עורך עם dedup. **הפיכות:** הסרת ה-collection-if + הקובץ.

## p2-w2c — חיפוש-לקוחות — שינוי-נראה: **לא (ברירת-מחדל) / כן (search.fuzzy)** — 2026-07-26
**ברירת-מחדל:** אפס — אין תיבה, טאב-הלקוחות זהה-בייטים (4 כרטיסי-זרע, צ׳יפים עובדים). **חברה שמדליקה:** מעל הרשימה תיבת "חיפוש לקוחות" — הקלדה מסננת סובל-שגיאות (Damerau, מודע-מילים), מרכיב עם צ׳יפ-הסטטוס, ריק=הכל. **הפיכות:** הסרת ה-collection-if + הפרדיקט.

## p2-w2d — דירוג RFM — שינוי-נראה: **לא (ברירת-מחדל) / כן (manager.scoring)** — 2026-07-26
**ברירת-מחדל:** אפס — אין badge, כרטיסי-הלקוח זהה-בייטים (רגרסיית-מנהל הנעולה עוברת). **חברה שמדליקה:** על כל כרטיס-לקוח pill-דרגה (🏆 לקוח מוביל / ⭐ קבוע / 🔹 מזדמן / 💤 רדום · נק'/מקס), ו-⚠️ בסיכון ללקוח-שהתקרר. **הפיכות:** הסרת ה-collection-if + 2 הקבצים.

## p2-w3a — איכות-נתונים — שינוי-נראה: **לא (ברירת-מחדל) / כן (catalog.validation)** — 2026-07-26
**ברירת-מחדל:** אפס — גיליון-הייבוא מתחייב בדיוק כמו היום, אין סעיף-אזהרות (הפרסור הנעול עובר). **חברה שמדליקה:** אחרי טעינה מוצלחת מופיע "⚠️ N אזהרות איכות (לא חוסמות)" עם כפילויות-שם/מק"ט לבדיקה — לא חוסם את ההתחייבות. **הפיכות:** הסרת ה-collection-if + הקובץ.

## p2-w3d — ייבוא-לקוחות — שינוי-נראה: **לא (ברירת-מחדל) / כן (manager.customers)** — 2026-07-26
**ברירת-מחדל:** אפס — טאב-הלקוחות זהה-בייטים, אין כפתור-ייבוא. **מנהל שמדליק manager.customers:** מתחת ל-chips מופיע "⬆️ ייבוא לקוחות מ-CSV" → גיליון (תבנית/העלאה/שגיאות-אטומי/הצלחה+אזהרות-איכות). **הפיכות:** collection-if + 2 קבצים.

## p2-w3e — חשבונית/קבלה — שינוי-נראה: **לא (ברירת-מחדל) / כן (orders.invoicing)** — 2026-07-26
**ברירת-מחדל:** אפס — גיליון-פרטי-ההזמנה זהה-בייטים, אין כפתור. **חברה שמדליקה orders.invoicing:** באזור-הפעולה מופיע "🧾 הפק חשבונית" → מסמך HTML RTL (מספר·לקוח·פריטים·סה"כ כולל-מע"מ) לדפדפן/Save-as-PDF. **הפיכות:** collection-if + קובץ-קרנל.

## p2-w4b — תעודת-משלוח — שינוי-נראה: **לא (ברירת-מחדל) / כן (orders.deliveryNote)** — 2026-07-27
**ברירת-מחדל:** אפס — גיליון-ההזמנה זהה-בייטים, אין כפתור. **מנהל שמדליק orders.deliveryNote:** מופיע "📦 תעודת משלוח" → הדפסת מסמך-סחורה (שם×כמות, בלי מחירים). **הפיכות:** collection-if + הקובץ.

## p2-w4c — כפתור-קבלה — שינוי-נראה: **לא (ברירת-מחדל) / כן (orders.invoicing)** — 2026-07-27
**ברירת-מחדל:** אפס — גיליון-ההזמנה זהה-בייטים. **מנהל שמדליק orders.invoicing:** מתחת לכפתור "🧾 הפק חשבונית" מופיע גם "💵 הפק קבלה" (אותה רכבת printable_docs, receipt:true → כותרת "קבלה"). מאומת ב-invoice_gate_test (OFF שניהם נעדרים · ON שניהם נוכחים). **הפיכות:** collection-if תחת אותו שער.

## swarm-r1 — אשף "רכיבים" — שינוי-נראה: **לא (ברירת-מחדל) / כן (ORG_CONFIG+חיפוש)** — 2026-07-27
**ברירת-מחדל (features ריק):** אפס — כל 895 האלמנטים גלויים, האפליקציה זהה-בייטים. **מנהל עם ORG_CONFIG:** אשף→סעיף "רכיבים"→חיפוש→קבוצות-מסך בעברית (אקורדיון)→טוגל פר-אלמנט (labelHe); כיבוי מסתיר את האלמנט (תווית) בכל האפליקציה; ליבה 🔒 נעולה. **הפיכות:** collection-if + הסרת השער מ-CfgText.

## swarm-r2a — הסתרת-composite — שינוי-נראה: **לא (ברירת-מחדל) / כן (org מסתיר)** — 2026-07-27
**ברירת-מחדל:** אפס — cart.cta + 5 ה-KPI מרונדרים כרגיל. **org שמסתיר element.cart.cta:** כל כפתור-ההזמנה נעלם (לא shell-ריק); הסתרת KPI → הכרטיס כולו נעלם. **הפיכות:** CfgVisible-wrap + שער _MetricTile.

## swarm-r2b — כיסוי-composites — שינוי-נראה: **לא (ברירת-מחדל) / כן (org מסתיר)** — 2026-07-27
**ברירת-מחדל:** אפס — כל ~36 הכפתורים/כרטיסים מרונדרים כרגיל. **org שמסתיר element.<id>:** הכפתור/כרטיס/pill השלם נעלם (לא shell-ריק) בכל המסכים שכוסו. **הפיכות:** הסרת עטיפות-CfgVisible.

## swarm-r2c — סגירת כיסוי-composites + בטיחות-יציאה — 2026-07-27
**ברירת-מחדל:** אפס — כל ~64 הכפתורים/כרטיסים/pills במסכי profiles·worker/courier-ops·dashboards-2·trade_builder·tasks מרונדרים כרגיל. **org שמסתיר element.<id>:** הכפתור/כרטיס/pill השלם נעלם (לא chrome-ריק). **בטיחות:** 7 כפתורי-יציאה/חזרה `critical:true` — לעולם לא-מוסתרים (org לא מתקיע משתמש). **הפיכות:** הסרת עטיפות-CfgVisible / ה-critical.

## swarm-r2d — כיסוי-composites מלא — שינוי-נראה: **לא (ברירת-מחדל) / כן (org מסתיר)** — 2026-07-27
**ברירת-מחדל:** אפס — כל 74 הכפתורים/pills/chips ב-catalog·entry·settings·worker-sheets·contractor מרונדרים כרגיל. **org שמסתיר:** הפריט השלם נעלם. **בטיחות:** 3 CTAs-login (welcome) `critical:true` — org לא חוסם כניסה. **הפיכות:** הסרת עטיפות.

## swarm-r2e — סוף כיסוי-composite — שינוי-נראה: **לא (ברירת-מחדל) / כן (org מסתיר)** — 2026-07-27
**ברירת-מחדל:** אפס. **org שמסתיר:** הכפתור/כרטיס/pill השלם נעלם בכל הזנב (signature/consent/coming_soon/courier/docs/smart…). **בטיחות:** יציאות+consent-accept+docs-gate `critical:true`. **הפיכות:** הסרת עטיפות.

## #launch-verify-fixes — 🔧 17 באגי-פקד תוקנו (audit 12-lens · "עושה מה שצריך") — 2026-08-01
נחיל 12-auditors סרק **כל ~1369 הפקדים** ב-~171 מסכים/widgets על 3 צירים (מחווט · מציג · נרשם). מ-~1369, ~1352 עשו בדיוק את עבודתם; **17 באגים אמיתיים** ("מחווט אך לא עושה את עבודתו") תוקנו — כולם הפיכים/כנים:
- **[HIGH crash]** `catalog_screen:6541` — ⓘ אביזר עשה `acc.price!` על nullable → קריסה. גודר: `acc.price!=null ? ₪.. : 'לפי ספק'` (מראה `_AccRow`).
- **[MED]** תגמול-משלוח (`courier_delivery_detail`+`persona_pod`) → נוסף awardCoins+פעמון (מראה כרטיס-הלוח) · vacation double-notify → `if(!fired)return` (`manager_dashboard`) · "שמור קופון" (`rewards_hub`) → מוסתר תחת kHideUnderConstruction (אין ארנק — לא toast-מזויף) · 6 צ'יפי-"שירותים" (`keyboard_store_deriver`) → `_comingSoon('פתיחת שירות')` במקום no-op שקט · CSV cross-trade (`product_authoring`) → בדיקת-כפילות גלובלית (לא דורס מסחר אחר) · cart qty (`lipskey_products` list-row) → sync מ-smartCartProvider (לא דורס 5→1) · notif toggle (`notif_settings`) → תווית 'התראות תקציב' (תואם האפקט האמיתי) + מראה ב-`search_index`.
- **[LOW]** vacation reason מושחל לפעמון/צ'אט (`contractor_hr`) · busy-guard חי (`customer_import`) · isActive מת הוסר (`role_picker`) · sortDefault דירוג/מרחק מוסתרים (`store_settings`) · טיר 'קריטיות' כפול הוסר (`notif_settings`) · worker-attendance send-guard (`worker_attendance`) · ai-finder תוצאות-ליטרל מוצגות גם ב-AI-off (`ai_finder`).
**אימות:** `flutter analyze` **0 errors** · `keyboard_store_deriver_test` (updated) + `legal_texts_test` ירוקים · כל fixer אימת שאין test שנשבר. visual-verify: שינויי-התנהגות/תווית/הסתרה — נבדקו דרך traces של ה-auditors + analyze + tests; ה-runtime smoke (Chromium) בשלב הבא מאשר חזותית.

## #launch-real-photos — 🖼️ אמוג'י → תמונות-מוצר אמיתיות (קטלוג + סל) — 2026-08-02
לבקשת הבעלים (2 צילומי-מסך: כרטיסי-קטלוג + סל עם אמוג'י). כרטיסי-קטגוריה/עץ-חכם ו-thumbnails של שורות-הסל הציגו אמוג'י כשלא היה imageAsset — כעת תמונות-אמת:
- קטגוריות → `assets/lipskey/categories/*.png` (11 תמונות-מוצר מעוצבות) לפי keyword resolver.
- שורות-סל → תמונת-ה-CDN של המוצר לפי SKU (אותו נתיב imageAsset שדף-המוצר כבר מציג).
**visual-verify:** צפיתי ב-`faucets.png` = תמונת-ברז-כרום אמיתית ✓; הרזולבר ממפה נכון את 6 הכרטיסים בצילומים (faucets/shower_bath/pipes/drainage); תמונות-הסל בנתיב-ה-CDN המוכח של דף-המוצר; fallback לאמוג'י לכל פריט חסר-תמונה. `analyze` 0 errors.

## #launch-kbd-stable — ⌨️ כפתור-המקלדת במיקום-קבוע (לא קופץ בניווט) — 2026-08-02
`main.dart` `_GlobalKeyboardOverlay`: `navOffset` היה `routePushed ? 0 : _kHomeNavHeight` → קפץ בגובה-הסרגל בין הבית (יש nav) למסך-פתוח (אין nav). תוקן ל-`navOffset = _kHomeNavHeight` **קבוע** → מיקום זהה בכל מסך; בבית מנקה את הסרגל, במסך-פתוח צף באותו מקום (רווח קטן מתחת, לא זז). owner-gate (long-press kStudioFlag) לא-נגע. analyze 0.

## #launch-order-email — 📧 מייל-אישור-הזמנה יפה (RTL) — 2026-08-02
מייל-HTML נשלח בסיום-הזמנה (מגודר `kOrderEmail`/`ORDER_EMAIL`, default-off). **visual-verify: רינדרתי את התבנית ב-Chromium** (email-preview.png) — header כתום-מדורג + לוגו + "בנייה חכמה / אישור הזמנה" · ברכה · טבלת-מוצרים (מוצר/כמות/מחיר) · **סה"כ ₪ בכתום** · פרטי-קשר · footer · RTL תקין. יפה+מקצועי — עומד ב-DoD "מייל יפה". הלוגו נטען מ-`buildsmart-il.com/icons/Icon-192.png` אצל הלקוח האמיתי (headless לא הגיע ל-CDN דרך הפרוקסי — placeholder בתצוגה בלבד).

## #identity פאזה 2 — auth (2026-08-02)
אין שינוי ויזואלי: `login_sheet.dart` רק מחרוזות-שגיאה (`hebrewAuthError`); `auth_state.dart`/`main.dart` לוגיקת-auth בלבד (שחזור-סשן + קישור-חשבונות) — אין רכיב-UI חדש/משתנה. `flutter analyze` 0 errors · `flutter test` ירוק. אימות התנהגות (נזכר/קישור) — על האתר החי, כי אין unit-test ל-Firebase Auth בסביבה.

## #identity #5 — סליק-תפקיד + שם (2026-08-02)
`home_shell.dart`: תיקון-תזמון לפתיחת סליק-בחירת-התפקיד (נפתח עכשיו אחרי הרשמה במקום להישאר סגור). `welcome_screen.dart`: אימוץ שם-Google ל-`displayName`. שינוי התנהגותי (מתי נפתח סליק קיים + מה נשמר), לא עיצוב רכיב חדש. `flutter analyze` 0 errors · `flutter test` ירוק. אימות פתיחת-הסליק + השם בפועל — על האתר החי.

## #8/3ב — מסך-אנשים בצ'אט (2026-08-02)
**שינוי-UI:** סליק "שיחה חדשה" (`_NewChatSheet`) — כבוי: 5 סוגי-הקשר הקבועים (ללא שינוי, זהה-בייטים); דלוק (backend חי): **רשימת-אנשים אמיתית** מה-directory (שם + תפקיד/emoji) עם spinner בטעינה ו"אין עדיין משתמשים" בריק/שגיאה; הקשה פותחת שיחה אמיתית. בנוסף — שיחות-uid מרונדרות עכשיו ברשימת-הצ'אט (`_visibleToAudience` uid-aware). `flutter analyze` 0 · 128 tests. אימות ה-UI בפועל (הרשימה + פתיחת-שיחה) — על האתר החי (Firebase, לא unit-testable).

## #8/3ג — קישור-צ'אט במסך-לקוחות (2026-08-02)
**שינוי-UI:** בכרטיס-פרטי-הלקוח של המנהל (`_CustomerDetailSheet`) — כפתור-צ'אט חדש (גדור backend חי): פותח שיחה עם הלקוח (resolve טלפון→uid) עם spinner בזמן ה-resolve; אם הלקוח לא רשום — toast + כפתורי 📞/💬 (WhatsApp). כבוי → אין שינוי (זהה-בייטים). `flutter analyze` 0 · tests עוברים. אימות ה-UI בפועל — על האתר החי.

## #reg-approval — פאנל אישור-הרשמה בטאב 👥 לקוחות (2026-08-02)
**שינוי-UI (גדור `useFirebaseBackend` + persona מנהל):** טאב-הלקוחות של המנהל חוּוט (לא נבנה-מחדש):
- **`_PendingApprovalPanel`** בראש הטאב — כרטיס עם מסגרת-כתומה, כותרת "🔔 אישור משתמשים חדשים (N)", צ'ק-ליסט של הממתינים (כל שורה: checkbox + שם + תפקיד + תג ⏳ ממתין, **מסומן כברירת-מחדל**), ושני כפתורים: **"אשר הכל (N)"** (brand מלא) + **"אשר מסומנים (M)"** (outline; מושבת כשאין סימון). ריק-ממתינים ⇒ הפאנל נעלם לגמרי (`SizedBox.shrink`). בעת-אישור ⇒ spinner במקום הכפתורים.
- **`_ApprovalBadge`** פר-כרטיס-לקוח: ⏳ ממתין (ענבר) / ✓ פעיל (ירוק) — live-only. (התווית עודכנה `מאושר`→`פעיל` ב-#user-hub, 2026-08-11.)
- **רשימת-הלקוחות** מציגה כעת את **כל** הרשומים (איחוד directory + הזמנות), לא רק מי שהזמין.
**מדוע אין screenshot מקומי (זהה ל-#8/3ב · #8/3ג · #identity):** כל המשטח גדור `useFirebaseBackend` (compile-time const) + persona מנהל — בכל build ללא הדגל הוא **tree-shaken/נעדר**, ואי-אפשר לרנדר אותו בסביבת-הסוכן בלי backend חי + התחברות-מנהל + משתמשים-ממתינים זרועים. **מה כן אומת:** לוגיקת-הצ'ק-ליסט (all/selected/all-except + stale-exclusion + OFF-gate) ב-`manager_approval_panel_test` **8/8**; **כל חבילת-הבדיקות ירוקה (baseline 0, אפס רגרסיה)**; `flutter analyze` **0 errors**; מבנה-ה-widget נסקר בקוד; מסלול-כבוי מוכח זהה-בייטים (directory ריק ⇒ מתקפל לרשימת-היום). **אימות חזותי בפועל — על האתר החי לאחר הפריסה** (הבעלים רואה את הפאנל בכניסת-מנהל · חסימת-הקופה עד אישור · הזרימה ⏳→✓).

## #reg-approval launch-clean — סינון לקוחות-דמו מרשימת-הלקוחות (2026-08-02)
**מקור (מצילום-מסך של הבעלים, האתר החי):** טאב 👥 לקוחות הראה 4 שמות (משה אברהם · יוסי כהן · אבי מזרחי · דוד לוי) עם הזמנה-אחת + תקרות-אשראי עגולות — אלה **לקוחות ה-seed המובנה** (`kOrdersEngineSeed`), לא חשבונות אמיתיים ב-DB. הם צצים כי אוסף ה-`orders` האמיתי ריק ו-`firestore_cached_repo._onSnapshot` **שומר את ה-born-seed** על snapshot-ריק-ראשון לא-scoped (עיצוב "לא מסך ריק"). **מחיקת-DB לא הייתה מסירה אותם** (הם חוזרים מה-seed). Meir (הבעלים) הופיע עם **0 הזמנות + ✓ מאושר** — נכון (מהספרייה, לא-מסונן).
**שינוי-UI (גדור `useFirebaseBackend`):** `_customerViewsProvider` מדלג על שורה גזורת-הזמנה עם `phone` ריק — לקוחות-ה-seed נעלמים מהרשימה החיה; Meir וכל לקוח-אמיתי (נושא `customerPhone`) או משתמש-רשום (בספרייה) נשמרים. לבקשת-הבעלים "מי שאין לו מייל או מספר — תעיף".
**מדוע אין screenshot מקומי:** אותה מגבלה — הסינון `useFirebaseBackend`-gated (const), נעדר בכל build מקומי, וה-seed-דרך-DB-ריק דורש backend חי. **מה כן אומת:** `flutter analyze` **0 errors** (הקובץ, `c.phone.isEmpty` מהדר); מסלול-כבוי זהה-בייטים (הסינון const-false ⇒ ה-seed מוצג כרגיל בדמו); כל חבילת-הבדיקות ירוקה. **אימות חזותי — על האתר החי לאחר הפריסה** (הבעלים מרענן → 4 שמות-הדמו נעלמים, נשארים רק אנשים אמיתיים).

## #internal-card — הכרטיס-הפנימי המלא על מסך-הבית (2026-08-07)
**שינוי-UI (מגודר `kInternalCard` · P1 מתוך D1–D18):** מקטע-בית "🃏 כרטיס פנימי" מרנדר את `FullInternalCard` — 13 סקציות-נתונים ל-SmartLock ברך 90° 50 (`70055960`), פורט 1:1 מ-`knowledge/internal-card/card-max-internal.png`. כל סקציה מחווטת לפונקציית-מנוע חיה ומוצגת רק כשיש נתונים.
**אימות חזותי:** `full_internal_card_test` מפמפם את הכרטיס עם ה-hero האמיתי ומאשר כותרת + כפתור-הוספה + סקציות מונחות-מנוע (מפרט-הנדסי · טמפרטורה) — נתונים חיים, לא mock. render מצורף לבעלים. כבוי → tree-shaken → **byte-identical**; חי דרך `--dart-define=INTERNAL_CARD=true`.

## #internal-card P2 — תמונה + גלריה (2026-08-07)
**שינוי-UI (מגודר `kInternalCard` · D3):** ה-thumb בכותרת = תמונת-מוצר אמיתית; לחיצה → גלריה מלאת-מסך עם pager (מוצר + מפרט), pinch-zoom, נקודות-עמוד, ✕. **אימות:** `full_internal_card_test` **2/2** — הכרטיס מרנדר עם נתוני-מנוע חיים + הקשה על התמונה פותחת את הגלריה. כבוי → tree-shaken → **byte-identical**.

## #internal-card P3 — משיכת-שם → וריאנטים (2026-08-07)
**שינוי-UI (מגודר `kInternalCard` · D5):** משיכה אופקית על שם-המוצר מדלגת בין וריאנטי-המידה (ברך 90° 32/40/50), עם נקודות-pagination תחת השם; הכרטיס כולו מתעדכן לווריאנט. **אימות:** `full_internal_card_test` **3/3** — משיכה מחליפה את השם המוצג לווריאנט השכן. כבוי → tree-shaken → **byte-identical**.

## #internal-card P4 — הוסף-לסל + יחידות (2026-08-07)
**שינוי-UI (מגודר `kInternalCard` · D6):** כפתור "הוסף לסל" מוסיף עכשיו שורה אמיתית לסל (`SmartCartLine` + toast); מוצרים עם נתוני-אריזה מציגים צ'יפי בודד/ארגז/משטח (SmartLock = בודד בלבד לפי R8). **אימות:** `full_internal_card_test` **4/4** — הקשה מוסיפה שורה עם שם-הווריאנט הנוכחי. כבוי → tree-shaken → **byte-identical**.

## #internal-card P5 — כפתורי-קו D14 (2026-08-08)
**שינוי-UI (מגודר `kInternalCard` · D14):** שורת [🔗 קו][🔍 בדיקה][🧩 השלם] מתחת לסקציות. **בדיקה** ו**השלם** מחווטים למנועים אמיתיים (`connectionNeedsHe` / `findShortestPath`) — הפותר **הודלק** ומציג נתיב-חיבור אמיתי עם מחברים מושחלים. **אימות:** `full_internal_card_test` **7/7**. כבוי → tree-shaken → **byte-identical**.

## #fittings P6·שלב-1 — פורטים-מכוונים D12 (2026-08-08)
**ללא שינוי-UI — תשתית טהורה (מגודרת `kFittingEngine`):** `directedPortsOf(RunElement)` מוסיף את כיווני-הפורט המרחביים שה-turtle זרק — הפרימיטיב שחסר ל-D12. **אימות:** `directed_ports_test` **8/8**. אין צרכן עדיין → נטרף בבנייה; שלב-1 מתוך ~4 של מנוע-הכיוונים.

## #fittings P6·שלב-2 — שכנוּת-גריד D12 (2026-08-08)
**ללא שינוי-UI — תשתית (מגודר `kFittingEngine`):** `snapToGrid` / `portsFace` / `gridPortsOf` — ההיטל רציף→בדיד שממיר את כיווני-הפורט לצעדי-גריד ומזהה פורטים-נגדיים. **אימות:** `grid_adjacency_test` **5/5**. שלב-2 מתוך ~4 של מנוע-הכיוונים.

## #internal-card P7 — פִּיבוֹט תמונה-תחילה (2026-08-08)
**תיקון-כיוון (מגודר `kInternalCard` · D15):** הכרטיס עבר מרשימת-13-סקציות-טקסט ל**כרטיס תמונה-תחילה** לפי צילומי-העיצוב — הספק מוסתר מאחורי 📋 ונפתח במקומה. **אימות:** `full_internal_card_test` **7/7**. כבוי → tree-shaken → **byte-identical**.

## #internal-card P8 — פולס קונטקסטואלי (2026-08-08)
**שינוי-UI (מגודר · D6/D14):** 3 הכפתורים (קו/בדיקה/השלם) כבר לא על כרטיס-הבסיס — מופיעים רק אחרי 'הוסף לסל', בעיגול-הפולס מתחת לכפתור. **אימות:** `full_internal_card_test` **7/7**.

## #internal-card P9 — מיפוי-אימוג'י (2026-08-08)
**שינוי-UI (מגודר · D17):** תמונת-הגיבור מציגה כעת את אימוג'י-הצורה לפי הצילומים — ברך=🦵 וכו'. **אימות:** `full_internal_card_test` **7/7**.

## #internal-card P10 — 📋 טאבים inline (2026-08-08)
**שינוי-UI (מגודר · D15):** 📋 פותח 5 טאבים (מפרט/תקן/אזהרה/חומר/טמפ') במקום התמונה; הקשה מחליפה תוכן. **אימות:** `full_internal_card_test` **7/7**.

## #fittings P6·שלב-3 — חיבור-תאים D12 (2026-08-08)
**ללא שינוי-UI — תשתית (מגודר `kFittingEngine`):** `cellsConnect` — שני תאים מחוברים לפי שכנוּת + פורט-פונה + od. **אימות:** `grid_cell_test` **6/6**. שלב 3/4 של מנוע-הכיוונים.

## #fittings P6·שלב-4 — קצה-פנוי D12 (2026-08-08)
**ללא שינוי-UI — תשתית (מגודר `kFittingEngine`):** `freeEndsOf` עוקב אחר פורטים-פנויים על תאים-מונחים. **אימות:** `grid_topology_test` **5/5**. **מנוע-הכיוונים 4/4 שכבות-היסוד הושלם**; נותר ה-UI.

## #fittings P6·שלב-5 — סינון-הסודוקו D5/D13 (2026-08-08)
**ללא שינוי-UI — תשתית (מגודר):** `gridSuggestionsAt` — "רק מה שמתחבר לשכן". **מנוע-הכיוונים 5/5 שכבות-לוגיקה הושלם**; נותר רק ה-UI (צרכן דק). **אימות:** `grid_topology_test` **8/8**.

## #fittings P6·שלב-6 — UI גריד-הסודוקו (2026-08-08)
**שינוי-UI (מגודר `kFittingEngine`):** גריד-סודוקו — משבצת מסומנת → 💡 "מתחברים לשכן" (הצעות-מנוע בלבד) → הנחה; כפתורי השלם/בדיקה/קו דרך `freeEndsOf`. **אימות:** `sudoku_grid_test` **4/4** + screenshot תואם צילום 5.

## #internal-card P6·7 — קו→גריד (2026-08-08)
**שינוי-UI (מגודר `kInternalCard`):** כפתור קו פותח את גריד-הסודוקו ב-sheet — הגריד נגיש דרך הכרטיס, ושניהם deployable (INTERNAL_CARD כבר דלוק ב-web-deploy). **אימות:** `full_internal_card_test` **8/8**.

## #catalog-config-home-fullscreen — הקטלוג מסך-מלא על הבית (2026-08-09)
**שינוי-UI:** משוב-בעלים "תן אותו מסך מלא · פתוח מלא · לא בתוך חלון · על מסך הבית ללא חלון". `_CatalogConfigOpen` (smart_home_screen) רינדר את `CatalogConfigScreen` בתוך `Container(height:560 + border)` — "חלון" מגודר על הבית. כעת `SizedBox(height: viewport − status-bar)` בלי מסגרת/כותרת-מקומית → הקטלוג ממלא את הבית **edge-to-edge**, כשה-AppBar של המסך עצמו הוא הכותרת.
**אימות חזותי:** רנדר-web (`flutter build web -t main_fs_render` → chromium headless, `fs_home.png`) — **אישר שהתוכן ממלא את ה-viewport מקצה-לקצה, ללא תיבת-560px/מסגרת** (מסילות-משפחה + אריחים פרוסים על כל הרוחב/גובה). הטקסט וה-CDN-images לא נטענו בסביבת-ה-headless (CanvasKit ללא-פונטים + `--no-proxy-server` חוסם R2) — artifact-סביבה, לא באג-פריסה; בפרודקשן הטקסט+התמונות נטענים (ראה renders קודמים). בנוסף: בדיקות-בית ירוקות (t3 · screen_sections · hidden_sections · 28), `flutter analyze` 0 באזור-השינוי, ואותה תבנית-הטמעה מוכחת כמו ה-560px (רק מלא-גובה). אימות-פוליש סופי — על האתר החי.
## #internal-card P6·8 — רַכֶּבֶת "מה מתחבר" (2026-08-08)
**שינוי-UI (מגודר `kInternalCard` · D4):** החלקת-תמונה חושפת רַכֶּבֶת תואמים (אימוג'י+שם). **אימות:** `full_internal_card_test` **9/9**. (פר-צד-מובחן = עידון עתידי.)

## #fittings P6·9 — קוביות-3D (2026-08-08)
**שינוי-UI (מגודר `kFittingEngine`):** תצוגת קוביות-3D איזומטרית לקו + toggle 📦3D↔▦2D בגריד. **אימות:** fittings **33/33**.

## #catalog-config-home-fullscreen-fit — תיקון-חיתוך (2026-08-09)
**באג (צילום-בעלים "נחתך באמצע"):** התיבה קיבלה גובה `viewport − status-bar` בלבד; לא הופחתו כותרת-הבית (56) + סרגל-הניווט (58), אז חרגה ~114px — התחתית מאחורי הניווט (dead-zone גלילה-מקוננת) והשורה העליונה חתוכה מתחת לכותרת.
**תיקון + אימות:** הגובה = `screen − padding.top − padding.bottom − kToolbarHeight(56) − 58` = **גוף-ה-viewport המדויק של HomeShell** (מקורות: `home_shell.dart` `_HomeAppBar`/`_BottomNav` + `_kHomeNavHeight` ב-main.dart). רנדר-headless בסביבה זו לא טוען פונטים (CanvasKit) + באנר-PWA חוסם — לא ניתן לצילום-נקי; **האימות הוא מתמטי** (התיבה = viewport מדויק ⇒ אין חריגה מאחורי ה-chrome ⇒ אין dead-zone ⇒ אין חיתוך) + בדיקות-בית ירוקות + `flutter analyze` 0. אימות חזותי סופי — על האתר החי אחרי הפריסה (הבעלים רואה שהקטלוג נכנס בין הכותרת לניווט, גולל בלי חיתוך).

## #catalog-config-fab-clearance — פינוי מעל הכפתורים-הצפים (2026-08-09)
**באג (המשך "אחר נחתך מתחת לכפתורים"):** גם עם הגובה המתוקן, המשפחה האחרונה נגללה לתחתית-התיבה שם מרחפים כפתורי-הבית הצפים (FAB עגלה + FAB מקלדת) ומכסים אותה. **תיקון:** `browse` `ListView` קיבל ריפוד-תחתון 104px → המשפחה האחרונה נגללת מעל הכפתורים. **אימות:** `flutter analyze` 0 · שינוי-ריפוד בטוח (רק מוסיף מרחב-גלילה תחתון). רנדר-headless עדיין ללא-פונטים בסביבה זו → אימות חזותי סופי על האתר החי (הבעלים גולל לתחתית → "אחר" מעל הכפתורים, לא מתחתם).
## #internal-card P6·10 — פר-צד אמיתי (2026-08-08)
**שינוי-UI (מגודר · D4):** כל קצה של המוצר → סט-תואמים משלו (`compatibleProductsForEnd`); ימין≠שמאל (הוכח על דיור-ברז: ברז מול זרועות-דוש). **אימות:** `full_internal_card_test` **9/9**.

## #internal-card P6·11 — כרטיס-חיצוני→פנימי-חדש (2026-08-08)
**חיווט (מגודר `kInternalCard`):** לחיצה על תמונת הכרטיס-החיצוני פותחת כעת את `FullInternalCard` החדש (route מסך-מלא) במקום הסֵשן הישן. הישן = fallback כבוי.

## #internal-card P6·12 — כרטיס מסך-מלא (2026-08-08)
**שינוי-UI (מגודר `kInternalCard`):** הכרטיס-הפנימי נפתח במסך-מלא (ממלא-רוחב edge-to-edge) במקום חלון-440-ממורכז על אפור.

## #catalog-config-material-rail — משיכת-כותרת = חומר (2026-08-09)
**שינוי-UI:** כותרת-המשפחה הפכה **נגררת** — משיכה ←/→ מדפדפת את החומר (PPR→HDPE→נחושת→כללי), עם תווית-חומר בכותרת + נקודות-`_MaterialDots` (↔ + נקודה מלאה לחומר הנוכחי). שורת-האריחים מציגה את הסוגים של החומר הנבחר: אריחים משותפים (ברך·מצמד) מחליפים תמונה [א], ייחודיים-לחומר מופיעים/נעלמים [ב]. השורה עדיין נגללת אופקית לסוגים.
**אימות:** במקום צילום-סטטי (headless ללא-פונטים) — **בדיקת-widget שמדמה את המחווה**: `catalog_config_material_rail_test` פותח את המסך, מאשר שכותרת "חיבורים ומחברים · PPR" מוצגת, **מבצע משיכה על הכותרת ומוודא שהחומר עבר מ-PPR** (התווית משתנה) — כלומר המחווה עצמה נבדקה, לא רק הפריסה. + `browseAll` מקבץ 44 אריחים ל-חיבורים לפי חומר (PPR ראשון, כללי אחרון). `flutter analyze` 0 · catalog_config 108/108. פוליש-חזותי סופי — על האתר החי.

## #catalog-config-material-filter — הכרטיס מסונן לחומר-הכותרת (2026-08-09)
**שינוי-UI:** משוב-בעלים "בפנימי שיציג רק מה שיש לפי הכותרת — מעין סינון" (כרטיס-הקונפיג/הגלגלים). הכרטיס שנפתח מאריח-חומר מציג כעת **רק את מידות/זוויות אותו חומר** — ברך-נחושת → גלגל-קוטר של נחושת בלבד (DN15·DN20·DN25), בלי מידות-פלסטיק (DN110 נעלם); ברך-PPR → הסולם המלא של PPR. הגרירה (↕/↔) גם היא נשארת בתוך החומר.
**אימות:** במקום צילום-סטטי (headless ללא-פונטים) — **בדיקת-יחידה על הסינון עצמו**: `catalog_config_material_rail_test` פותח את גלגל-הקוטר של ברך-נחושת (77777677) עם ה-universe המסונן-לחומר מול הלא-מסונן ומוודא שהמסונן **קצר יותר**, **תת-קבוצה** של המלא, ו**חסר DN110** (מידת-פלסטיק). + `flutter analyze` 0 · catalog_config 109/109. פוליש-חזותי סופי — על האתר החי.

## #catalog-config-image-drag-angle — משיכת-תמונה אנכית מחליפה וריאנט (2026-08-09)
**באג-UI (משוב-בעלים "משיכה של התמונות לא עובד"):** משיכת-התמונה האנכית (ציר-הזווית) לא החליפה את התמונה/השם — רק האופקית (קוטר). שורש: טוקן-הזווית בגלגל (`45`/`90` או `45°`/`90°` תלוי-מקור) לא תאם את טוקן-משפחת-הווריאנט (`45°`/`90°`), אז המשיכה בחרה ערך שאף וריאנט לא נשא → אין החלפה.
**תיקון:** נרמול-טוקן-זווית לספרות בשני הצדדים (גלגל `_angleAttribute` + משפחה `chipValuesOf`) + הציר-האחרון-שזז נפתר-ראשון. **אימות:** במקום צילום (headless ללא-פונטים) — **בדיקת-widget שמושכת את התמונה**: `catalog_config_image_drag_test` מושך אנכית על ברך-PPR ומוודא שהשם עבר `45°→90°` (וגם אופקית `20→63`), + `chipValuesOf` זווית בלי `°`. `flutter analyze` 0 · catalog_config 112/112. פוליש-חזותי סופי — על האתר החי.

## #catalog-config-elbow-image-mix — תמונות-ברך שגויות + קפיצת-וריאנט (2026-08-09)
**באג-UI (משוב-בעלים "ערבוב בין ברכים מסעפים" · במשיכת התמונה):** משיכת-תמונה של ברך הציגה צילום מסוג-אחר. שורש כפול: (1) **data** — `fitting_image_overrides` מיפה ברכיים (92117042-51, 92117109) לתמונות של **צווארון**/**צינור**; (2) **logic** — `_lastAxis` (מהתיקון הקודם) גרם למשיכה לקפוץ לווריאנט-רחוק/ענפי (NTM 105°). **תיקון:** הוסרו המיפויים השגויים (ברך→ppr_elbow הנכון) + בוטל `_lastAxis` (משיכה קוהרנטית קוטר-קודם). **אימות:** trace-widget מדמה משיכה ומדפיס את התמונה-הנפתרת — ברך-PPR 90° עבר מ-`98417808_3.jpeg` (צווארון) ל-`ppr_p19_b.jpg` (ברך), ו-material-less לא קופץ ל-NTM. `flutter analyze` 0 · catalog_config 112/112. פוליש-חזותי סופי — על האתר החי.

## #auth-registration-audit — welcome_screen register-ordering (ללא שינוי-חזותי · 2026-08-11)
**שינוי:** `welcome_screen._registerViaAuth` — הזזת `userProfileProvider.register(...)` לאחר הצלחת `createUserWithEmailPassword` (במקום לפניה) + הערות. **visual-verify: אין שינוי חזותי.** הענף היחיד שנגע (`if (kEmailPasswordAuth && validEmail(contact))`) **מגודר מאחורי `kEmailPasswordAuth` שכבוי** — לא נרנדר ב-build המשווק. השינוי מזיז אך ורק את **סדר קריאת state מקומית** (register) על מסלול שאינו מצייר widget; ה-layout, הטקסט, ה-FAB וזרימת-המסך זהים בייט-לבייט. אומת: `flutter test test/welcome_auth_gate_test.dart` (נתיב flag-OFF, המסלול החי) ירוק, ו-`git diff` מראה 0 שינוי ב-build()/render. אין screenshot כי אין פיקסל שהשתנה.

## #user-hub — מרכז ניהול-משתמשים אחד בטאב 👥 (2026-08-11)
**שינוי-UI (גדור `useFirebaseBackend` + persona מנהל · המשך #reg-approval):** טאב-הלקוחות הפך למרכז-המשתמשים היחיד — כל ניהול-המשתמשים במקום אחד, לא מפורק (לבקשת-הבעלים):
- **תגי-שורה:** ליד שם כל רשומה — תג-סטטוס (⏳ ממתין / ✓ פעיל, `_ApprovalBadge`) + תג-תפקיד (`_RoleBadge`, מ-`_kBsRoleLabel`). מוצג רק live + כשיש סטטוס/תפקיד; שורות order-derived/CRM נקיות.
- **צ׳יפי-סינון (`_AccountFilterChips`):** הכל / ממתינים / פעילים / לקוחות בלבד — מעל הרשימה ליד צ׳יפי-האשראי. data-gated (`if hasDirectory`), predicate טהור `accountFilterMatch`.
- **פעולות-בגיליון (`_CustomerActionRow`, `if uid.isNotEmpty`):** ✓ אשר / ⏸️ השהה (`userApproverProvider`) + 🔑 שנה תפקיד → בורר-התפקידים **ממוקד** ל-uid (`showManagerRoleAssignSheet(targetUid,targetName)`). מעל פירוט-ה-CRM הקיים.
- **איחוד:** 2 סעיפי-הכפילות בטאב 🛠️ ניהול (🔑 שיוך תפקידים · 📋 אישור חשבונות) הוסרו — הפונקציונליות עברה למרכז. אין "איפה זה היה".
**מדוע אין screenshot מקומי (זהה ל-#reg-approval):** כל המשטח גדור `useFirebaseBackend` const + persona מנהל → tree-shaken בכל build ללא הדגל; אי-אפשר לרנדר בסביבת-הסוכן בלי backend חי + כניסת-מנהל + directory זרוע. **מה כן אומת:** מיקוד-הבורר (`manager_role_assign_sheet_a12_test`, 3 טסטים חדשים — picker מוסתר · 👤 subject · `{targetUid,role}` לשרת) + role-sheet **8/8**; predicate-הסינון (`user_hub_filter_test`, 4 טסטים, **mutation-verified** RED→GREEN); מסלול-כבוי מוכח זהה-בייטים (`manager_dashboard_screen_test` ירוק — 5 כלי-הניהול + גיליון-הלקוח); `flutter analyze` **0 errors** · כל החבילה ירוקה. **אימות חזותי בפועל — על האתר החי לאחר הפריסה** (הבעלים רואה תגים/סינון/פעולות בטאב 👥 בכניסת-מנהל).

## #user-delete — כפתור 🗑️ מחק בגיליון-הפעולות (2026-08-11)
**שינוי-UI (גדור `useFirebaseBackend` · המשך #user-hub):** ב-`_CustomerActionRow` (גיליון-משתמש בטאב 👥) נוסף כפתור **🗑️ מחק** אדום/הרסני, אחרי "🔑 שנה תפקיד", מוצג רק כש-`uid.isNotEmpty`. לחיצה → דיאלוג-אישור `confirmDestructive` ("למחוק לצמיתות … מכל המערכות (חשבון + כל הנתונים)? בלתי-הפיך.") → קריאת-שרת `deleteUser` → toast "המשתמש נמחק" → השורה נעלמת דרך הזרם-החי.
**מדוע אין screenshot מקומי (זהה ל-#reg-approval/#user-hub):** גדור `useFirebaseBackend` + persona מנהל → מסלול-כבוי `uid==''` → הכפתור נעדר, הגיליון בייט-זהה. **מה כן אומת:** `userDeleterProvider` OFF-null (`manager_approval_panel_test`) · client analyze 0 · 59 טסטים ירוקים · functions `tsc` נקי · שער-הבטיחות (owner-guard/manager-auth) אומת-בבייטים. **אימות חזותי — על האתר החי** (הבעלים מוחק את 6-הזבל ורואה אותם נעלמים).

## #system-setup-unified — כניסה מאוחדת "🔌 הקמת המערכת" בטאב 🛠️ ניהול (2026-08-13)
**שינוי-UI (גדור `kOrgConfigFlag` · מנהל בלבד):** 2 אריחי-הכניסה הנפרדים (🏗️ בונה ענפים · 🔌 אשף הקמת חברה) אוחדו לאריח אחד **"🔌 הקמת המערכת"** (sub: "בניית ענף חדש והגדרת החברה — הכל במקום אחד"). לחיצה → `SystemSetupHostScreen`: זרימה דו-שלבית — פאזה-1 בונה-הענף (עם כפתור-חדש **"המשך להגדרת החברה ←"** ב-bottom-bar) → פאזה-2 אשף-הארגון. שאר טאב-הניהול (5 כלים + תורי-אישורים) ללא-שינוי.
**מדוע אין screenshot מקומי (זהה לקונבנציית #user-hub/#user-delete):** האריח והמסלול גדורים `kOrgConfigFlag` (compile-const, כבוי ב-build ללא-דגל → tree-shaken); אי-אפשר לרנדר בסביבת-הסוכן בלי build עם `--dart-define=ORG_CONFIG=true` + כניסת-מנהל. **מה כן אומת:** בדיקת-widget חדשה `system_setup_host_test` (3 טסטים) שמפעילה את ה-host **ישירות** (עוקף את ה-compile-flag) ו**מדמה את המחווה בעין**: פאזה-1 מציגה '🏗️ בונה ענפים' + הכפתור-החדש → **הקשה על "המשך" מעבירה בפועל לפאזה-2** '🔌 אשף הקמת חברה' (OrgSetupWizard נטען, פאזה-1 נעלמת) → מסלול-עצמאי (onContinue=null) בלי הכפתור (byte-identical). **mutation-verified** (שבירת-מעבר-הפאזה → RED → שחזור → GREEN). מסלול-כבוי מוכח זהה-בייטים (`manager_dashboard_screen_test` ירוק — 5 כלי-הניהול). `flutter analyze` **0 errors**. **אימות חזותי בפועל — על האתר החי** (המנהל פותח 🛠️ ניהול → 🔌 הקמת המערכת → מקים ענף → "המשך" → מגדיר חברה).

## #hr-courier-clock — שעון-משלוחים מקומי→שרת (ללא שינוי-חזותי · 2026-08-13)
**שינוי:** הגירת `courier_clock` לשרת (`courierClock/{uid}`, self-only, מאחורי `kUserDataServer` כבוי). נגעתי ב-4 קבצי-UI רק כדי להשחיל את ה-repo דרך ה-writer/reader: `stampCourierClock(..., repo:)` בשלושת נקודות-ה-advance (`courier_dashboard_screen`/`courier_delivery_detail_sheet`/`persona_pod_sheet`) + ענף-שרת ב-`courierClockProvider` (`courier_reports_tab`). **visual-verify: אין שינוי חזותי.** ה-reader מחזיר את אותו `Map<String,CourierClockEntry>` (אותו פענוח pickedUpAt/deliveredAt/attempts), רק המקור הוא `courierClock/{uid}` במקום SharedPreferences כשהדגל דלוק; כבוי (repo==null) — מסלול-הבייט זהה. אין widget שהשתנה — layout/טקסט/דוחות-השליח מרונדרים זהה. **מה כן אומת:** `courier_clock_repository_test` (5 — OFF-null + round-trip + write-once) · **mutation-verified** (`load` decode→ריק → RED round-trip → שחזור → GREEN) · `flutter analyze` **0 errors** · courier_hr/courier-reports ירוקים. **אימות חזותי בפועל — על האתר החי** (השליח משלים משלוח → דוחות-השליח מציגים את זמן-המדידה, כעת מהשרת).

## #taskT3-2b — משטחי-עובד: סינון int→uid (ללא שינוי-חזותי OFF · 2026-08-13)
**שינוי:** 7 משטחי-עובד (worker_task_board · worker_app_screen · worker_reports_tab ×3 · worker_report_drilldowns ×4 · worker_profile_screen · tasks_gantt_sheet · defects_sheet) עברו מ-`t.worker == index` ל-`workerOwnsTask(t, index, uid)` — predicate OR-סובלני. **visual-verify: אין שינוי חזותי כבוי.** עם `uid` ריק (OFF / session דמו — `board.uid==''`) ה-predicate שקול-בייט ל-`t.worker == index`, אז אותן משימות בדיוק מסוננות → אותם כרטיסים/סטטיסטיקות/gantt. רק כש-`kTasksServer` (OFF כברירת-מחדל, טרם ב-workflows) ידליק ויְמַדֵּר את ה-repo ל-`assignedWorkerUid==uid`, יתווספו משימות שהוקצו-לפי-uid. **אומת:** `worker_owns_task_test` (2 — OFF byte-identical + ענף-uid) **mutation-verified** · `worker_task_scope_test` + `worker_app_test` ירוקים (אפס-שינוי מקומי) · analyze 0. אין screenshot — אין פיקסל שהשתנה.

## #taskT3-2c — בורר-עובד directory + חתימת-uid (גדור kTasksServer · 2026-08-13)
**שינוי-UI (גדור `kTasksServer` compile-const, OFF כברירת-מחדל → tree-shaken):** ב-`_TaskAuthorSheet` (tasks_screen) — כשהדגל דלוק ויש עובדים רשומים ב-directory (role==worker), בורר-העובד מתחלף מ-`kWorkers` (2 שמות-דמו, int) ל-`_DirWorkerPick` (Wrap של שבבי-שמות אמיתיים מה-directory, בחירה לפי **uid**). הבחירה חותמת `assignedWorkerUid` אמיתי + `employerId=currentUid`. defects `_openDefect` חותם employerId אמיתי גם.
**מדוע אין screenshot מקומי (קונבנציית #user-hub/#org-config):** הענף `kTasksServer ?` הוא compile-const כבוי → tree-shaken בכל build ללא `--dart-define=TASKS_SERVER=true`, ו-`directoryProvider` ריק ללא backend חי + עובדים רשומים. **מה כן אומת:** `tasks_cross_party_closure_test` (3 — createTask/assignTask חותמים את ה-uid + `workerOwnsTask` מקבל לפי-uid למרות index-דמו) · **16 טסטי-האוthoring/defects הקיימים ירוקים (OFF byte-identical — authoringEmployerId=kDemoContractorId, _workerUid='')** · analyze 0. **אימות חזותי — על האתר החי** (קבלן פותח "משימה חדשה" → בוחר עובד רשום → העובד רואה אותה בלוח שלו).

## #taskT3-2d — פעמון-עובד server merge (ללא שינוי-פריסה · 2026-08-13)
**שינוי:** `worker_notifs_sheet` — הפיד ממזג server task-bells + local, ניתוב markRead/clear לפי-מקור. **אין שינוי-פריסה:** אותן שורות-בל (`_NotifRow`), אותו badge. OFF (server ריק) — הפיד זהה-בייט ללוקאלי. ON — עובד-אמיתי רואה גם את הבלים שהטריגר יצר (שקודם אבדו במיפוי-שם-הדמו). **אומת:** worker_notifs_repository_test (3, mutation-verified) + 10 טסטי-notifs קיימים ירוקים · analyze 0. **אימות חזותי — על האתר החי** (עובד רשום מקבל בל '✅ אושרה' כשקבלן מאשר).

## #install-recirc-safety — BOM עם פריטי-בטיחות-מחזור בעץ (שינוי-דאטה בלבד · 2026-08-15)
**שינוי:** `install_studio_screen:1254` מעביר `loop: _loop` ל-`buildTreeInstallation` (תיקון-בטיחות HIGH — עיצוב מחזור-מים-חמים על מחלק+ענפים קודם איבד את קבוצת-הבטיחות של הלולאה). **אין שינוי-פריסה:** אותו וידג'ט רשימת-BOM, אותם `_BomRow`/zones — רק תוכן-הרשימה גדל בפריטי-הבטיחות הנכונים (ברז-ניתוק 3 · אל-חזור · ברז-איזון · מפריד-אוויר · דגימת-לגיונלה) כשה-toggle "מחזור מים חמים" דלוק ומדובר בעץ. **מדוע אין screenshot מקומי:** הפלט החזותי נגזר דטרמיניסטית מפלט-המנוע הנבדק (אותה פריסה, שורות נוספות) — אין שינוי layout/style לרנדר. **מה כן אומת:** `auto_compliance_test` 11 (loop:true → 4 פריטי-הבטיחות נוכחים ב-BOM) + 12 (loop:false → נעדרים) · **mutation-verified** (הסרת ה-loop → RED → שחזור → GREEN) · analyze 0. **אימות חזותי — על האתר החי** (הקבלן פותח סטודיו-התקנה → בונה עץ מחלק → מדליק "מחזור מים חמים" → רשימת-ה-BOM כוללת את פריטי-הבטיחות).

## #polish-run3-tail — 2 תיקוני-run3 קטנים (שינוי-דאטה/state בלבד · 2026-08-15)
שני באגי-run3 שנותרו אמיתיים (השאר כבר-תוקנו/by-design):
- **FX thousands-grouping** (`finance_hub_sheets` `_FxCalc`): echo-הסכום איבד פסיקי-אלפים בקלט **שברי** (`v.toString()`). `fxGroupAmount` (top-level, ציבורי) מקבץ את החלק-השלם ושומר את השבר. **אין שינוי-פריסה** — אותו `Text` תוצאה, מחרוזת מקובצת נכון. אומת: `fx_group_test` (3, mutation-verified) · analyze 0.
- **יחידה נדבקת בהחלפת-variant** (`lipskey_product_sheet` `_switchByChip`): נוסף `_unit = _Unit.single` (מראה את 3 ה-resets הקיימים באותה מתודה). **אין שינוי-פריסה** — בורר-היחידה חוזר ל'בודד' בהחלפה, כמו שאר איפוסי-הבחירה. אומת: `product_sheet_strips_test` ירוק (אפס-רגרסיה במעבר-variant) · תיקון-עקביות חד-שורתי.
**מדוע אין screenshot:** שניהם שינוי דאטה/state נגזר, לא layout — הפלט מאומת ע"י הטסטים. **אימות חזותי — על האתר החי** (המרת-מט"ח עם סכום שברי מציגה פסיקים · החלפת-variant מאפסת יחידה ל'בודד').

## #sheet-no-double-push — guard re-entrancy לכרטיס-המוצר (2026-08-16)
**שינוי:** `showLipskeyProductSheet` קיבל guard frame-scoped — שתי פתיחות same-frame (הקשה מהירה על 2 כרטיסים לפני שה-barrier עולה) לא מערמות עוד 2 sheets. **אין שינוי-פריסה:** אותו sheet, אותו תוכן — פשוט לא-כפול. גדר מרכזית ⇒ כל ~15 ה-call-sites מכוסים. **אומת:** `lipskey_sheet_no_double_push_test` (שתי פתיחות → sheet יחיד) mutation-verified · `product_sheet_strips_test` ירוק (אין leak של הגדר בין-טסטים — reset הוא frame-scoped, לא dismiss-scoped) · analyze 0. **אימות חזותי — על האתר החי** (הקשה כפולה-מהירה על מוצר פותחת sheet אחד).

## #polish-hardening-AB — 7 תיקוני-הקשחה (שינוי-דאטה/state/perf · 2026-08-16)
טריאז' A+B → 7 חיים. הנוגעים ב-UI (**אין שינוי-פריסה** בשום אחד):
- **6 דליפות controller** (`budget_screen` ×5 · `site_hub_screen` ×1): `.whenComplete(() => ctrl.dispose())` על ה-showModal/showDialog — משאב-בלבד, אותה תצוגה.
- **cacheWidth** (`product_images` + `catalog:6705` 48px→96): פענוח-תמונה קטן יותר, אותו פיקסל על המסך.
- **`chain_diagram`**: RepaintBoundary + shouldRepaint short-circuit — perf, אותה דיאגרמה.
- **reduced-motion** (`main.dart`): מכבד אות-OS בנוסף ל-toggle — אנימציות פחותות למי שביקש, לא שינוי-layout.
- **finance div-zero** (`_SubRow`): guard על allocated==0 (מונע crash `.round()` על NaN) — אותה שורה.
- **`home_shell` `.select`**: פחות rebuilds ל-app-bar, אותו תוכן.
**מדוע אין screenshot:** כולם משאב/perf/robustness — אין שינוי חזותי לרנדר. **מה כן אומת:** `product_image_cache_test` (2, mutation-verified) · 53 טסטי chain/finance/budget/cart ירוקים · analyze 0. **אימות חזותי — על האתר החי** (thumbnails חדים · דיאגרמת-שרשרת חלקה · reduce-motion מ-OS מכובד).

## #edit-sheet-guards + voice-guard — מניעת-אובדן-קלט (2026-08-16)
3 באגים אחרונים מרשימה-2:
- **voice double-fire** (`ai_hub_screen`): דגל `_voiceBusy` (מראה את VoiceDictateButton הבדוק) חוסם הקשת-🎙️-שנייה בזמן האזנה; נוסף גם `onError` (קודם חסר → שגיאות נבלעו). **אין שינוי-פריסה.**
- **PopScope חכם לגיליונות-עריכה** (`projects._EditSheet` — שם/כתובת/מנהל · `catalog._ItemPickerSheet` — בחירות): swipe/drag/back כשיש שינוי-לא-שמור → דיאלוג **"לבטל את השינויים?"** (`confirmDestructive`); נקי (לא-dirty) → סגירה רגילה; Save (pop ישיר) עוקף. מראה את ה-PopScope הקיים בפרודקשן (`manager_screens_sheet`).
- **install_studio describe sheet** (inline, parent-state · מסך 6k-שורות): הבחירה-הזהירה — `enableDrag: false` חוסם את ה-drag-dismiss המקרי בלי retrofit-PopScope שביר. scrim-tap מכוון עדיין סוגר.
**מדוע אין screenshot / בדיקת-gesture:** UX-מחוות על גיליונות פרטיים; הדפוס מראה קוד-פרודקשן קיים, analyze 0 · 61 טסטי projects/catalog/ai_hub/install_studio ירוקים (אפס-רגרסיה). **אימות חזותי — על האתר החי** (הקלד בגיליון-עריכה → החלק-לסגור → מופיע "לבטל את השינויים?" · הקשה-כפולה 🎙️ = האזנה אחת).

## #w0-slice1 — פלטת-ניטרלים חמה (§W0, אישור-בעלים) (2026-08-16)
**החלטה:** הבעלים אישר הצעת-עיצוב ויזואלית (artifact) — כיוון "חם-תעשייתי". **סלייס-1 (בטוח, unpinned, AA-verified):** חימום ה-ניטרלים בלבד — `bgLightAlt` #F5F6FA→#FAF8F5 (רקע-האפליקציה, הכי-נראה) · `mutedLight` #666666→#6E655B (5.8:1 על לבן) · `divider` #EEEEEE→#E9E2D9 · **כל פלטת-הכהה** cool→warm (`bgDark`/`cardDark`/`inkDark`/`mutedDark`, AA 16.4:1/7.3:1/6.5:1). **לא נגעתי (pinned/רופל):** brand · success/danger (ננעלים ב-a11y_contrast_theme_test) · inkLight (= onAccent ב-HC). **אימות:** analyze 0 · a11y_contrast_theme_test + manager_dashboard_screen_test (36) ירוקים. **מדוע אין screenshot:** `lib/theme` (לא screens/widgets) — שינוי-ערכי-טוקן; המראה נגזר דרך הטוקנים. **אימות חזותי — על האתר החי** (רקע חם יותר · מצב-כהה חם). **סלייסים הבאים (עדינים, דורשים תיאום):** brand deepening + hex-sweep · semantic + ink (עם עדכון ה-a11y test).

## #w0-slice2 — כתום-מותג עמוק + טאטוא-צבעים (§W0, אישור-בעלים) (2026-08-16)
**החלטה:** המשך אישור-הבעלים ("תמשיך"). **סלייס-2:** הכתום-המותג הועמק `#FF7A18`→`#F26B1D` — גם **משפר נגישות** (לבן-על-כתום 2.9:1→4.4:1, עובר את סף-3:1 לטקסט-גדול/כפתורים). `brandDark`→`#D65A0E` · `kbSeam` תוקן לגוון החדש. **טאטוא single-source:** כל 28 ה-`Color(0xFFFF7A18)` הקשיחים ב-10 קבצים הוחלפו ל-`BsTokens.brand` (שני מעברי-sed מסודרים: const-prefixed ואז bare), + 2 imports חסרים נוספו (ring_dive · backend_debug_badge). כך ההעמקה **אחידה** — אין חצי-ישן-חצי-חדש. **הושארו בכוונה:** 2 raw-int (`plumbing_trade_seed:107` ברירת-מחדל-נתונים · `trade_define_step:44` swatch-פלטה) — שכבת-דאטה, לא chrome. **אימות:** analyze 0 · a11y_contrast_theme_test ירוק · אף טסט לא נועל את הכתום-הישן. **אימות חזותי — על האתר החי** (הכתום עמוק ופרימיום יותר, אחיד בכל המסכים).

## #w0-slice3 — זיקוק ירוק/אדום סטטוס (§W0 סיום, אישור-בעלים "תסיים") (2026-08-16)
**סלייס-3 (אחרון):** `success` #22C55E→#1F9D57 (ירוק-מקורקע, on-white 2.2→3.5:1) · `danger` #EF4444→#CE3A32 (אדום-סטטוס, **עובר AA לטקסט**: 3.2→4.9:1). **טאטוא single-source:** 14 #22C55E + 33 #EF4444 קשיחים הוחלפו לטוקנים (כולל fallback ב-app_theme). **`chainWarning` נשאר #EF4444** — data-viz alert עצמאי (התיעוד עודכן: danger/chainWarning התפצלו בכוונה). עודכנו הנעילות: `a11y_contrast_theme_test` (success→#1F9D57) · `tokens_w0_test`. **אימות:** analyze 0 (כל lib/) · a11y + tokens_w0 ירוקים. **אימות חזותי — על האתר החי** ("במלאי" ירוק-עמוק · שגיאות אדום-מקורקע). **§W0 הושלם:** 3 סלייסים — ניטרלים חמים+כהה · כתום עמוק · ירוק/אדום מזוקק, כולם single-source ו-AA.

## #w0-followup-warm-hero — שני צבעים קרים שנותרו → פלטה חמה (2026-08-18)
**רקע (משוב-בעלים חי):** על מסך-הבית הבהיר הבעלים ראה "כהה ובהיר מעורב". אבחון: אין ערבוב-טמות — המסך כולו בהיר, אבל **שני אלמנטים קרים** שנותרו מ-§W0 בעטו בפלטה החמה:
- **כרטיס ה-hero "מסלול עבודה חכם"** (`smart_home_screen.dart`): גרדיאנט טורקיז קשיח `#1F6F6B→#155350` — שארית מהמותג הישן (טורקיז), מקודד לשני המצבים.
- **גלולת "מצב דמו"** (`connection_indicator.dart`): `chainSlate` (כחלחל-קר מפלטת ה-data-viz).
**התיקון:** hero → גרדיאנט **המותג** `BsTokens.brand→brandDark` (טקסט לבן נשאר ≥4.4:1) · demo-pill → `BsTokens.mutedLight` (אפור-חם). שניהם לטוקנים חמים **קיימים** (single-source, אפס-ערך-חדש).
**אימות חזותי — screenshot אמיתי מהאפליקציה הרצה:** build web (`--no-web-resources-cdn`) + צילום headless של מסך-הבית → הכרטיס עכשיו כתום-מותג, הגלולה אפורה-חמה, המסך כולו חם-על-חם (v7.02 · build 9e0d955f-בסיס). `flutter analyze` 0 · `flutter test` ירוק מלא.

## #darkmode-wave1 — catalog_screen + home_shell → theme-aware surfaces (2026-08-18)
**רקע:** מצב-כהה היה "מעורבב" (חלק מהמסכים כהים, רוב בהירים) כי ~659 משטחים מקודדים צבע-בהיר קשיח מעל ה-Scaffold המתוכן. מנוע-הפירוק-עם-צבעים (`tools/atom/decompose/bin/colors.dart`) הפיק אטלס מדויק (`knowledge/colors/ATLAS.md`) — work-list + נעילת-רגרסיה.
**גל 1 (data-driven, 2 fixers מקבילים):** 34 light-surfaces → תמה: `home_shell.dart` (8: app-bar · bottom-nav · בועות-צ'אט · sheets) + `catalog_screen.dart` (26: sheets · dialogs · tileColor · כרטיסים · avatar-circles). ההמרה: לבן→`colorScheme.surface` · אפור-בהיר→`surfaceContainerHighest`/`dividerColor` · const הוסר · context מאומת (context/ctx/dCtx). foreground (checkColor/טקסט) לא נגעו.
**אימות חזותי — צילום אמיתי מ-build כהה:** טאב מחלקות + ה-shell כעת **כהים** (היו בהירים); מסך store (גל-2, לא תוקן) עדיין עם עיגולים לבנים — מוכיח מיקוד מדויק. `flutter analyze` 0 errors/warnings. **אטלס re-run: 659→625** (‎-34, בדיוק הגל; catalog+home_shell ירדו ל-0).

## #darkmode-wave2 — store cluster → theme-aware surfaces (2026-08-18)
**גל 2 (3 fixers מקבילים, קבצים נפרדים):** 64 light-surfaces → תמה ב-`store_screen.dart`(27) + `store_dashboard_screen.dart`(20) + `store_profile_screen.dart`(17). כלל נוסף מעבר לגל-1: `BsTokens.bgLight`→`scaffoldBackgroundColor` (רקע-עמוד) / `colorScheme.surface` (תיבה-פנימית); `BsTokens.cardLight`→`colorScheme.surface`. const הוסר, context מאומת (context/ctx/dCtx/sheetCtx). **אימות:** `flutter analyze` 0 errors/warnings על 3 הקבצים · **אטלס 625→561** (‎-64, store cluster→0). (הצילום-כהה של גל-1 כבר הוכיח שהדפוס-המכני עובד; לגל-2 מסתמכים על analyze+אטלס+שער-ה-build.)

## #darkmode-wave3 — 8 screens (manager/chats/org-setup/site-hub/worker-safety/courier-dash/rewards/tasks) (2026-08-18)
**גל 3 (8 fixers מקבילים, קבצים נפרדים):** 114 light-surfaces → תמה. manager_dashboard(30)·chats(16)·org_setup(15)·worker_safety(12)·courier_dashboard(12)·rewards(12)·tasks(11)·site_hub(6). אותם כללי-המרה (cardLight→surface · bgLight→scaffoldBackgroundColor/surface · white→surface · greys→surfaceContainerHighest · const הוסר · context מאומת). **7 דולגו** ב-site_hub — offenders בתוך פונקציות-עזר בלי BuildContext (`_floor`/`_apt`/`_room`/`_safetyRow`/`_dep`/`_pair`/`_photo`); דורש context-threading — נדחה לפעולת-המשך. **אימות:** `flutter analyze` 0 errors (4 warnings קדם-קיימים ב-site_hub, dead-code, לא-חוסמים; שער נכשל רק על error•). **אטלס 561→447** (‎-114; 7 המסכים נוקו, site_hub נשאר 7). מצטבר 659→447 (212 תוקנו).

## #darkmode-wave3-testfix — manager_dashboard_screen_test theme-aware (2026-08-18)
גל 3 חשף חוזה-טסט: `manager_dashboard_screen_test` נעל צבעים בהירים מדויקים (`scaffold==bgLight`, "NO dark tokens"). מאחר שהמסך עכשiw תמה-מודע, עודכן הטסט (אישור-בעלים "א"): pump נעטף ב-`AppTheme.light()` (התמה האמיתית), ו-5 assertion-י רקע-Scaffold עברו `bgLight→bgLightAlt` (הרקע-הבהיר של התמה). assertion-י `cardLight` עברו כמו-שהם (surface-בהיר=לבן=cardLight). אומת בבידוד: 31/31 עובר. (store_notif/product_journey שהופיעו בסוויטה-המלאה = flakes תחת concurrency — עוברים לבד.)

## #darkmode-wave4 — 8 screens (connection_rule_studio/courier_profile/worker_app/lipskey_product_sheet/worker_profile/contractor_hr/worker_forms/courier_certs) (2026-08-18)
**גל 4 (8 fixers מקבילים, קבצים נפרדים):** 72 light-surfaces → תמה, 0 דולגו. connection_rule_studio(11)·courier_profile(10)·worker_app(9)·lipskey_product_sheet(9)·worker_profile(9)·contractor_hr(8)·worker_forms(8)·courier_certs(8). אותם כללי-המרה (cardLight→surface · bgLight→scaffoldBackgroundColor/surface · white→surface · greys→surfaceContainerHighest · const הוסר · context מאומת). **אין טסטי-נועלי-צבע לאף מסך בגל זה** (בדיקה יזומה מראש — הבעיה של manager_dashboard לא חזרה). `flutter analyze` 0 errors/warnings. **אטלס 447→375** (‎-72). מצטבר 659→375 (284 תוקנו).

## #darkmode-wave5 — 8 screens (accessory_rule/ai_hub/persona_picking/courier_forms/worker_employer_stock/product_authoring/attribute_schema/profile) (2026-08-23)
**גל 5 (8 fixers מקבילים, קבצים נפרדים):** 56 light-surfaces → תמה. accessory_rule_editor(8)·ai_hub(7)·product_authoring(7)·courier_forms(7)·worker_employer_stock(7)·attribute_schema_editor(7)·profile_screen(7)·persona_picking_sheet(6). אותם כללי-המרה (cardLight→`colorScheme.surface` · bgLight→`scaffoldBackgroundColor`/`surface` · white→surface · greys(0xFFF0F0F0)→`surfaceContainerHighest` · const הוסר · context מאומת). **1 דולג** ב-persona_picking_sheet:777 (`_decisionRow` — בלי BuildContext; context-threading בהמשך). **אין טסטי-נועלי-צבע לאף מסך בגל זה** (בדיקה יזומה מראש). `flutter analyze` 0 errors (32 info-level: unintended_html/prefer_const — קדם-קיימים ולא-חוסמים; שער נכשל רק על error•). **אטלס 375→319** (‎-56). מצטבר 659→319 (340 תוקנו).

## #darkmode-wave6 — 8 screens (category_tree/lipskey_brand/budget/smart_project/studio_rules/signature_pad/chat_settings/notif_settings) (2026-08-23)
**גל 6 (8 fixers מקבילים, קבצים נפרדים):** 49 light-surfaces → תמה. category_tree_editor(7)·lipskey_brand(7)·budget(7)·smart_project(6)·studio_rules(6)·chat_settings(6)·notif_settings(6)·signature_pad(4). אותם כללי-המרה (cardLight/white→`colorScheme.surface` · bgLight/0xFFF5F6FA→`scaffoldBackgroundColor` · surfaceMid/0xFFF5F5F5→`surfaceContainerHighest` · const הוסר · context מאומת). **2 דולגו (know-exclusion קבוע)** ב-signature_pad:206,440 — משטח-לכידת-החתימה (canvas לבן שדיו-כהה נמשך עליו; חייב להישאר לבן ל-PNG המיוצא, לא chrome). **אין טסטי-נועלי-צבע לאף מסך בגל זה** (בדיקה יזומה מראש — כולל בדיקת test/generated). `flutter analyze` 0 errors. **אטלס 319→270** (‎-49; signature_pad נשאר 2=canvas). מצטבר 659→270 (389 תוקנו; 270 כוללים את 2 ה-canvas ואת 7 site_hub הדחויים).

## #darkmode-wave7 — 8 screens (manager_profile/manager_copilot/regression_panel/finance_hub_sheets/projects/worker_attendance/courier_portal_tab/notifications) (2026-08-23)
**גל 7 (8 fixers מקבילים, קבצים נפרדים):** 43 light-surfaces → תמה. manager_profile(6)·manager_copilot(6)·regression_panel(6)·finance_hub_sheets(5)·projects(5)·worker_attendance(5)·notifications(5)·courier_portal_tab(4). אותם כללי-המרה (cardLight/white→`colorScheme.surface` · bgLight/F5F6FA→`scaffoldBackgroundColor` · F5F5F5→`surfaceContainerHighest` · const הוסר · context מאומת). **תיקון-אורקסטרייטור:** RefreshIndicator חמישי ב-notifications:796 (`Color(0xFFFFFFFF)`) נותר אחרי התנגשות-Edit של ה-fixer (מספרי-שורה זזו) — תוקן ידנית ל-`colorScheme.surface`. **1 דולג** ב-courier_portal_tab:359 (`_row` arrow-method בלי BuildContext — context-threading בהמשך, כמו site_hub). **בדיקת טסטים יזומה:** knowledge_protocol_test נועל רק חתימות-עזר (לא צבעים) · manager_dashboard_test מאמת רק ניתוב ל-RegressionPanelScreen (לא צבעיו) — אף נעילת-צבע לא נשברה. `flutter analyze` 0 errors. **אטלס 270→228** (‎-42). מצטבר 659→228 (431 תוקנו).

## #darkmode-wave8 — 8 screens (trade_builder_home/catalog_config/catalog_settings/persona_portal/ai_assistant/stock/install_studio/courier_reports) (2026-08-23)
**גל 8 (8 fixers מקבילים, קבצים נפרדים):** 37 light-surfaces → תמה. trade_builder_home(5)·catalog_config(5)·catalog_settings(5)·ai_assistant(5)·stock(5)·persona_portal(4)·courier_reports(4)·install_studio(4). אותם כללי-המרה (cardLight/white→`colorScheme.surface` · bgLight/bgLightAlt/F5F6FA→`scaffoldBackgroundColor`/`surface` · F5F5F5→`surfaceContainerHighest` · const הוסר · context מאומת — כולל capture דרך Builder-closure ב-install_studio). **1 דולג** ב-persona_portal:325 (`_row` arrow-method בלי context — context-threading בהמשך). `flutter analyze` 0 errors. **אטלס 228→191** (‎-37). מצטבר 659→191 (468 תוקנו).

## #darkmode-wave9 — 8 screens (intel_tab/store_settings/courier_attendance/studio_top_bar/worker_settings/trade_define_step/suppliers/legal) (2026-08-23)
**גל 9 (8 fixers מקבילים, קבצים נפרדים):** 31 light-surfaces → תמה. intel_tab(4)·store_settings(4)·courier_attendance(4)·studio_top_bar(4)·worker_settings(4)·trade_define_step(4)·suppliers(4)·legal(3). אותם כללי-המרה (cardLight/white→`colorScheme.surface` · bgLight/bgLightAlt/F5F6FA→`scaffoldBackgroundColor` · surfaceMid/F5F5F5→`surfaceContainerHighest` · const הוסר · context מאומת). trade_define_step: פלטת-`_kTradeColors` (data-samples) הושארה כמצוות CLAUDE.md. **1 דולג** ב-legal_screen:209 (`_segment` helper בלי context). **bs_keyboard נדחה** מהגל — נעול ב-golden-PNG test (`kb_golden_test`) שמריץ ThemeData ברירת-מחדל; המרת לבן ל-surface הייתה משנה פיקסלים ושוברת golden — דורש regen נפרד. `flutter analyze` 0 errors. **אטלס 191→160** (‎-31). מצטבר 659→160 (499 תוקנו).

## #darkmode-wave10 — 8 files (contractor_tools/defects/worker_task_board/docs_readiness/manager_role_assign/contractor_attendance/help_target/tasks_gantt) (2026-08-23)
**גל 10 (8 fixers מקבילים, קבצים נפרדים):** 23 light-surfaces → תמה. contractor_tools_sheets(3)·defects(3)·worker_task_board(3)·docs_readiness_gate(3)·manager_role_assign(3)·contractor_attendance(3)·tasks_gantt(3)·help_target(2). אותם כללי-המרה (cardLight/white→`colorScheme.surface` · bgLight→`scaffoldBackgroundColor`/`surface` · const הוסר · context מאומת). **1 דולג** ב-help_target:464 (`_TailPainter.paint` — CustomPainter בלי BuildContext; דורש העברת Color פרמטר מהקורא — נדחה). `flutter analyze` 0 errors. **אטלס 160→137** (‎-23). מצטבר 659→137 (522 תוקנו).

## #darkmode-wave11 — studio_screen ×2 + test-contract fix (2026-08-23)
**גל 11 (2 קבצי studio + עדכון-טסט):** 9 light-surfaces → תמה בשני קבצי `studio_screen.dart` (יש שניים: `lib/screens/studio_screen.dart` 7 · `lib/screens/studio/studio_screen.dart` 2). כללי-המרה רגילים (cardLight→`colorScheme.surface` · bgLight→`scaffoldBackgroundColor` · surfaceMid→`surfaceContainerHighest`). **תיקון-חוזה-טסט (כמו manager_dashboard):** `test/studio/studio_screen_test.dart` נעל `AppBar.backgroundColor == BsTokens.cardLight` תוך pump ללא-תמה. מאחר שהמסך עכשיו תמה-מודע, ה-pump נעטף ב-`AppTheme.light()` (+import). ה-assertion `== BsTokens.cardLight` נשאר תקף כי `colorScheme.surface(light) == Colors.white == cardLight (#FFFFFF)` — אומת מ-app_theme.dart:31 + tokens.dart:65. **אימות:** studio_screen_test 4/4 · studio_screen_behavior_test 10/10 · analyze 0 errors. **אטלס 137→128** (‎-9). מצטבר 659→128 (531 תוקנו).

## #darkmode-wave12 — site_hub context-threading (הדחוי מגל 3) (2026-08-23)
**גל 12 (context-threading ידני):** 7 ה-offenders הדחויים של `site_hub_screen.dart` (מגל 3 — פונקציות-עזר בלי BuildContext) נפתרו. **אבחון:** 4 מהם ב-StatelessWidget-ים (`_floor`/`_apt`/`_room` ב-`_SiteLocations` · `_dep` ב-`_SiteDeps`) — נדרש **context-threading**: הוספת פרמטר `BuildContext context` לכל helper + העברתו מ-build ומ-helper-ל-helper (`_floor(context,f)→_apt(context,a)→_room(context,r)`). 3 האחרים (`_safetyRow` ב-`_SiteSafetyState` · `_pair`/`_photo` ב-`_SitePhotosState`) הם **מתודות-State** — ל-State יש getter מובנה `context`, כך שאין צורך ב-threading (הדחייה בגל 3 הייתה זהירה-מדי). כל 7 → cardLight/bgLight→`colorScheme.surface`. **אימות:** site_hub_state_test 23/23 (state-logic, לא נשבר משינוי חתימות) · analyze 0 errors. **אטלס 128→121** (‎-7). מצטבר 659→121 (538 תוקנו). **לקח:** מתודות-State תמיד עם context — לא לדלג עליהן; רק StatelessWidget-helpers/CustomPainter/arrow-top-level דורשים threading.

## #darkmode-wave13 — 8 screens (studio_component_builder/home_content_reorder/trade_publish/spec_copilot/courier_settings/role_requests_inbox/ai_finder/describe_to_cart) (2026-08-23)
**גל 13 (8 fixers מקבילים):** 24 light-surfaces → תמה, 3 בכל קובץ, 0 דולגו. אותם כללי-המרה (cardLight/white→`colorScheme.surface` · bgLight/F5F6FA→`scaffoldBackgroundColor` · surfaceMid→`surfaceContainerHighest`). כל ה-offenders היו במתודות-build או מתודות-State (context זמין ישירות). `flutter analyze` 0 errors. **אטלס 121→97** (‎-24; מתחת ל-100). מצטבר 659→97 (562 תוקנו).

## #darkmode-wave14 — 8 files (ring_dive/welcome/worker_reports/worker_task_detail/courier_delivery_detail/lipskey_products/contractor_material_requests/persona_pod) (2026-08-23)
**גל 14 (8 fixers מקבילים):** 16 light-surfaces → תמה, 2 בכל קובץ, 0 דולגו. cardLight/white→`colorScheme.surface` · bgLight→`scaffoldBackgroundColor`/`surface`. כל ה-offenders במתודות-build/State (context ישיר). `flutter analyze` 0 errors. **אטלס 97→81** (‎-16). מצטבר 659→81 (578 תוקנו).

## #darkmode-wave15 — 8 files (worker_notifs/worker_payslips/role_request/store_documents/audit/profession/consent_modal/role_picker) (2026-08-23)
**גל 15 (8 fixers מקבילים):** 16 light-surfaces → תמה, 2 בכל קובץ, 0 דולגו. cardLight/white→`colorScheme.surface` · bgLight/bgLightAlt/FAFAFA→`scaffoldBackgroundColor`/`surface` · F5F5F5→`surfaceContainerHighest`. **אימות נוסף:** role_picker_sheet מרונדר ב-manager_dashboard_screen_test (ניתוב showRolePicker) — הרצנו, 31/31 עוברים. `flutter analyze` 0 errors. **אטלס 81→65** (‎-16). מצטבר 659→65 (594 תוקנו).

## #darkmode-wave16 — 8 files (alt/quote_polish/coming_soon/adapter/paired/daily_report/credit/manager_screens) (2026-08-23)
**גל 16 (8 fixers מקבילים):** 16 light-surfaces → תמה, 2 בכל קובץ, 0 דולגו. משפחת מסכי-explain (alt/adapter/paired/credit) + quote_polish + coming_soon + daily_report + manager_screens — כולם דפוס Scaffold(bgLight)+AppBar(cardLight). bgLight→`scaffoldBackgroundColor` · cardLight/white→`colorScheme.surface`. `flutter analyze` 0 errors. **אטלס 65→49** (‎-16). מצטבר 659→49 (610 תוקנו).

## #darkmode-wave17 — 8 files (supplier_onboarding/reject_reason/business_summary/worker_report_drilldowns/login_sheet/worker_equipment_checklist/camera_sheet/word_finder) (2026-08-23)
**גל 17 (8 fixers מקבילים):** 11 light-surfaces → תמה, 0 דולגו. cardLight/white→`colorScheme.surface` · bgLight→`scaffoldBackgroundColor` · surfaceMid→`surfaceContainerHighest`. **camera_sheet:404** אומת כדיאלוג-אישור (chrome) ולא preview-מצלמה → הומר בבטחה. `flutter analyze` 0 errors. **אטלס 49→38** (‎-11). מצטבר 659→38 (621 תוקנו).
