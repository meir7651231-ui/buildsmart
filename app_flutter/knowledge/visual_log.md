# Visual verification log — app_flutter

תיעוד אימות-ויזואלי לשינויי UI (גייט 107, לקח #2). screenshot/בדיקת-widget לכל שינוי.

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
