# יומן בדיקות mutation

> קובץ זה חייב להיות מעודכן אחרי כל פונקציית עזר חדשה.
> ה-pre-commit hook בודק שהוא עודכן לפני שמירה.

## פורמט רשומה

```
### [שם הפונקציה] — [תאריך]
- תקלה שהוזרקה: [מה שיניתי]
- תוצאה: הבדיקה הייתה אדומה ✅ / ירוקה ❌
- תקלה שנייה: [מה שיניתי]
- תוצאה: הבדיקה הייתה אדומה ✅ / ירוקה ❌
- מסקנה: הבדיקה חזקה / חלשה (מה שופר)
```

## רשומות
<!-- הוסף רשומה חדשה כאן לכל פונקציית עזר -->

## #screen-mgmt-s11 — ✏️ טריגר-עריכה: long-press-מקלדת → ✎ מעל-הסל (un-freeze של s0) — 2026-07-28
- **הפונקציות:** `_GlobalKeyboardOverlay` (main.dart) — long-press על ה-FAB → `toggleEdit`; `StudioOverlay` (widgets/studio) — ✎ מעל cart-FAB כש-`isEditing`.
- **תקלות שהוזרקו (mutation-sensitivity):**
  1. הסרת שער-`kStudioFlag` מ-`StudioOverlay` ⇒ ה-✎ נכנס ל-production build (לא tree-shaken) ⇒ ה-byte-identity proof (before==after `main.dart.js`) **נכשל** · zero_regression עדיין ירוק (כי הוא רץ off-build) — מוכיח שה-sha-proof הוא השומר האמיתי לזהות-הבייטים, לא רק הבדיקות.
  2. שינוי `onLongPress: canEdit ? … : null` ל-`… : () => toggleEdit()` (בלי הגדרוׂן) ⇒ **לא-בעלים** בפריוויו-login-less היה מדליק עריכה ⇒ שובר את שער-#84. (בקליני-preview `studioCanEdit=true` דרך ה-sandbox-relaxation — לכן השער חייב לעטוף את ה-callback, לא רק את ה-enter.)
  3. `AlignmentDirectional.bottomEnd` → `bottomStart` ⇒ ה-✎ קופץ לפינת ה-FAB-מקלדת (RTL-ימין) במקום מעל הסל (RTL-שמאל) ⇒ מתנגש עם המקלדת.
- **בטיחות:** 3 שערים מקוננים (const `kStudioFlag` → runtime `studioCanEditProvider`#84 → `isEditing`); ה-FAB חולץ למשתנה משותף כך שענפי ה-`kStudioFlag ? … : fab` זהים בכל דבר חוץ מהעטיפה; `StudioTopBar` (הבאנר) לא-מותקן app-global (רק במסך-סטודיו נפרד) ⇒ "בלי באנר" מובטח.
- **אימות:** analyze 0 · zero_regression 20/20 · studio-gate 34/34 · byte-identity sha before==after · central-verify.

## #screen-mgmt-s10 — 🕸️ מאתר-על פתוח בבית (הטמעת CatalogWheelScreen) — 2026-07-28
- **הפונקציה:** `_SuperFinderOpen` (smart_home_screen) — `Container(height:560)` → `CatalogWheelScreen`; `childrenFor(superFinder)` משתמש בו במקום הכרטיס.
- **תקלה שהוזרקה (mutation-sensitivity):** הסרת `height:560` (גובה לא-חסום) ⇒ ה-`ListView` נותן גובה אינסופי ל-`CatalogWheelScreen` (Scaffold/GridView צריכים גובה חסום) ⇒ layout-assert/overflow בזמן-ריצה. מוכיח שהגובה-החסום load-bearing להטמעה. תקלה #2: `childrenFor` עדיין מחזיר `_SuperFinderHero` (כרטיס) ⇒ אין גלגל פתוח בבית — ה-render-check בפריוויו מראה כרטיס-כניסה במקום גלגל.
- **בטיחות:** `kAxisDive` const-false בברירת-מחדל ⇒ tree-shake ⇒ **זהה-בייטים**; reuse **verbatim** של `CatalogWheelScreen` (בלי fork) ⇒ אותו finder בדיוק כמו מקטע-הקטלוג; `smartHomeSectionFor` נשאר כרטיס ⇒ תצוגת-סידור-הסקציות באשף לא נשברת; הבריכה `kDivePool` (built-in) ⇒ לא-ריק גם ב-clean.
- **אימות:** analyze 0 · t3/wizard/kbd 43/43 · אימות-render בפריוויו (clean).

## #screen-mgmt-s9 — 🕸️ מאתר-על במסך-הבית + במקלדת (כפולה, נערכת) — 2026-07-28
- **הפונקציות:** `HomeSection.superFinder` (enum+meta+order) · `_SuperFinderHero` + `childrenFor(superFinder)` (smart_home_screen) · `kbHomeNodes()` leaf (keyboard_tool_tree) · `screen_registry` home (8 sections + 9 keyboardTools).
- **תקלה שהוזרקה (mutation-sensitivity):** הסרת שער `if (kAxisDive)` משני האתרים (מרנדר תמיד) ⇒ בדיקת byte-identity spec §4C (tab-0 OFF-flag == `_buildRow`) אדומה כי הרשת גדלה באריח נוסף ⇒ מוכיח שהשער load-bearing לזהות-הבייטים. תקלה #2: `sec-show-home-superFinder` נעדר מ-`screen_registry` sections ⇒ wizard 34 נכשל (`findsNothing`) ⇒ מוכיח שהרישום הוא-שמנפיק את שורת-העריכה.
- **בטיחות:** `kAxisDive` const-false בבנייה-הנשלחת ⇒ שני האתרים tree-shaken ⇒ **זהה-בייטים** (הבית + הרשת). `_SuperFinderHero` plain-`Text` (לא CfgText) ⇒ אפס-רישום-element. אותה פעולת-קטלוג ('מאתר-על') בשני האתרים ⇒ מקור-אמת אחד, בלי המצאת-מסך.
- **אימות:** analyze 0 · org_setup_wizard 34/34 · t3 (order=8) · kbd_home_layout · floating_card_keyboard byte-identity (73).

## #screen-mgmt-s8 — ✎ rename פר-פריט (סקציות + מקלדת) — 2026-07-28
- **הפונקציות:** `labelOf`/`setLabel` (screen_sections · labels map) · `_renameItem`/`_RenameDialog` (wizard) · `_renameKbdNode` (keyboard).
- **תקלה שהוזרקה (mutation-sensitivity):** `_renameKbdNode` בלי `if (label==node.label) return node` (בונה-מחדש תמיד) ⇒ אובדן זהות + לא-זהה-בייטים ⇒ byte-identity spec §4C אדום. (תקלה-אמת שקרתה: dispose ה-controller בבנאי-דיאלוג-plain ⇒ race-assert → תוקן ב-StatefulWidget.)
- **בטיחות:** ברירת-מחדל `label==node.label` ⇒ אותו node ⇒ **זהה-בייטים** · canonical-minimal (ריק→revert→remove key) · `_RenameDialog` מנהל+dispose את ה-controller.
- **אימות:** analyze 0 · org_setup_wizard 33/33 · screen_sections · kbd_home_layout · floating_card_keyboard.
## #screen-mgmt-s7 — מקלדת-הבית חיה על פריסת-האשף — 2026-07-28
- **הפונקציה:** `_applyHomeKbdLayout` (filter+reorder `kbHomeNodes` לפי `visibleIds('kbd:home', labels)`).
- **תקלה שהוזרקה (mutation-sensitivity):** להסיר את שער `tab == 0` ⇒ הסינון חל על כל הטאבים (gear/dept/store) ⇒ בדיקות-המקלדת הקיימות אדומות; או `visibleIds`→`orderedIds` ⇒ אריח-מוסתר עדיין מוצג.
- **בטיחות:** tab-0 בלבד · `ref.watch(screenSectionsProvider)` לריאקטיביות · ברירת-מחדל **זהה-בייטים** (79 בדיקות-מקלדת קיימות ירוקות · byte-identity spec §4C נשמר).
- **אימות:** analyze 0 · kbd_home_layout s7 · floating_card_keyboard + deriver + live_mirror ירוקות.
## #screen-mgmt-s6 — הבית: 2 בלוקים-קבועים → סקציות ניתנות-להסתרה — 2026-07-28
- **השינוי:** `HomeSection` += `installHero`, `favorites`; `smartHomeSectionFor` + `SmartHomeBody.childrenFor` (spread); `screen_registry` home = 7 סקציות.
- **תקלה שהוזרקה (mutation-sensitivity):** `favorites` → `[_Favorites, SizedBox(space4)]` (ריווח-נגרר) ⇒ שינוי-ריווח מברירת-המחדל (לא-זהה-בייטים); או להשמיט את שער-ה-`compat` מ-installHero ⇒ ה-hero דולף כשהמודול כבוי.
- **בטיחות:** spread + compat-gate ⇒ ברירת-מחדל **זהה-בייטים** (home-render ירוקות). ה-old-model (homeContentOrder · vestigial) + t3 עודכנו ל-7.
- **אימות:** analyze 0 · org_setup_wizard 23/23 · t3 + widget + placeholder ירוקות.
## #screen-mgmt-s5c — חנות חיה על מודל-הסקציות — 2026-07-28
- **הפונקציות:** `StoreDashSection` enum · `sectionChildren` (local switch · spread per-section) · `kStoreDashScreenKey`.
- **תקלה שהוזרקה (mutation-sensitivity):** להעביר את צינור-ההזמנות לתוך `sectionChildren` (reorderable) ⇒ הזנב-lazy (`itemCount: head.length + shown.length`) נשבר — כרטיסי-ההזמנות מופיעים אחרי head בלי הכותרת במקום; ולכן הוא **נשאר קבוע**.
- **בטיחות:** header + orders קבועים · `sectionChildren` קוד-verbatim (spread) ⇒ ברירת-מחדל **זהה-בייטים** · בדיקות-חנות (t9/help/apple/daily) ירוקות.
- **אימות:** analyze 0 · org_setup_wizard 23/23 · store-tests ירוקות.
## #screen-mgmt-s5b — לוח-מנהל חי על מודל-הסקציות — 2026-07-28
- **הפונקציות:** `ManagerDashSection` enum · `childrenFor` (spread per-section) · `kManagerDashScreenKey`.
- **תקלה שהוזרקה (mutation-sensitivity):** להשמיט את `if(kStudioCoEditor)` מה-`defaults` (studio תמיד-בפנים) ⇒ `studio_gating` אדום (dev-hero דולף ללייב); או `visibleIds`→`orderedIds` ⇒ סקציה-מוסתרת עדיין מרונדרת.
- **בטיחות:** spread-children + `defaults`-עם-שערים ⇒ children-flat **זהה-בייטים** לברירת-מחדל (live+dev). `attention_gate`+`studio_gating` ירוקים. `studio` מוחרג מ-registry (dev-only).
- **אימות:** analyze 0 · org_setup_wizard 22/22 · attention_gate + studio_gating ירוקים.
## #screen-mgmt-s5a — קבלן==בית (ניקוי registry) — 2026-07-28
- **השינוי:** `screen_registry` — הוסר `ManagedScreen('contractor')` (redundant · קבלן==בית); 'home' תוּיג-מחדש 'מסך הבית (לוח הקבלן)'. אין פונקציה חדשה (שינוי-דאטה).
- **תקלה שהוזרקה (mutation-sensitivity):** בדיקת-האשף (`textContaining('מסך הבית')` על AppBar רמה-2) — התיוג-מחדש שבר את ה-assertion הישן (`'מסך הבית — סקציות'`) ⇒ אדום עד שתוקן ⇒ מוכיח שה-label מחווט לכותרת.
- **בטיחות:** אין test שתלוי ב-stub שהוסר. הבורד האמיתי של הקבלן (הבית) כבר חי (slice-3).
- **אימות:** analyze 0 · org_setup_wizard 21/21.
## #screen-mgmt-s4 — מקלדת-פר-מסך (עורך מעורך-המסך) — 2026-07-27
- **הפונקציות:** `_ScreenKeyboardEditor` · `keyboardLayoutKey` · `ManagedScreen.keyboardTools`/`hasKeyboard`.
- **תקלה שהוזרקה (mutation-sensitivity):** rootKey `keyboardLayoutKey(id)`→`screen.id` ⇒ עורך-המקלדת כותב לאותו layout כמו הסקציות ⇒ בדיקת slice-4 (`isHidden('kbd:home','מהירים')`) אדומה (נשמר תחת מפתח שגוי).
- **בטיחות:** מיחזור `_SectionManagerList` (slice-2) · persist דרך slice-1 · **אין שינוי בתת-מערכת-המקלדת** ⇒ אין רגרסיה. תשתית (`kKbGlobal` off ⇒ אין אפקט-חי; באנר-כן).
- **אימות:** analyze 0 · org_setup_wizard 21/21.

## #screen-mgmt-s3 — הבית חי על מודל-הסקציות — 2026-07-27
- **השינוי:** `smart_home` + `home_content_reorder` → `screenSections.visibleIds/orderedIds('home', kHomeSectionIds)` (במקום `homeContentOrderProvider`) + טוגל-הסתר פר-סקציה (`Key('home-hide-<id>')`).
- **תקלה שהוזרקה (mutation-sensitivity):** `visibleIds`→`orderedIds` ב-`SmartHomeBody` ⇒ סקציה-מוסתרת עדיין מרונדרת ⇒ בדיקת slice-3 (hide נופל מהסדר) אדומה.
- **בטיחות:** layout ריק ⇒ `visibleIds`==default ⇒ **זהה-בייטים** (62 בדיקות-בית ירוקות). `homeContentOrderProvider` נשאר ל-t3 (vestigial). `HomeSection.name`==id (מיפוי נקי דו-כיווני).
- **אימות:** analyze 0 · t3 18/18 · screen_sections 7/7 · 62 home-render ירוקות.

## #screen-mgmt-s2 — ניהול-מסכים באשף (2 מפלסים) — 2026-07-27
- **הפונקציות:** `_SectionManagerList` (row · reorder · toggle · reset) · `_ScreenManagerScreen` (רמה-1) · `_ScreenSectionEditor` (רמה-2) · `kManagedScreens` (screen_registry).
- **תקלה שהוזרקה (mutation-sensitivity):** ה-switch `value: !hidden` → `value: hidden` ⇒ בדיקת הסתרת-מסך/סקציה (`isHidden`==true אחרי tap) אדומה (ה-toggle מתחיל הפוך ⇒ ה-tap מציג במקום מסתיר).
- **בטיחות:** persist דרך slice-1 (canonical-minimal) · ברירת-מחדל **זהה-בייטים** · placeholder כן למסכים לא-בנויים (בלי סקציות מומצאות). עדיין לא-חי על המסכים (slice-5).
- **אימות:** analyze 0 · org_setup_wizard 20/20.

## #reg-first-chip — סטטוס-צ׳יפ + הרשמה-קודם (ללא באנר) — 2026-07-28
- **הפונקציות:** `roleChipStateFor` (מיפוי טהור → 4 מצבי-צ׳יפ) · `clearAllRoleRequests`
  (מחיקת-אצווה owner) · providers `myRoleRequestProvider`/`roleChipStateProvider`/
  `promptRoleRequestProvider`.
- **תקלה שהוזרקה (mutation-sensitivity):** ב-`roleChipStateFor` היפוך הסדר —
  `requestStatus=='denied'` נבדק **לפני** `isActive` ⇒ הבדיקה "active מנצח denied ⇒ approved"
  אדומה (מחזיר rejected במקום approved). וכן: השמטת `requestStatus=='pending'` ⇒ בדיקת
  🟡 inProcess אדומה.
- **בטיחות:** הצ׳יפ + ה-listen מגודרים `kUserSystem` (const-off בבילד רגיל/טסטים) ⇒
  `SizedBox.shrink`/לא-נרשם ⇒ **זהה-בייטים** (כל טסטי HomeShell ירוקים). הבאנר הוסר
  מה-mount בלבד — הווידג׳ט + הטסט שלו נשמרו. `clearAllRoleRequests` rule-safe (admin-delete).
- **אימות:** analyze 0 errors · role_chip_state 8/8 · role_request 15/15 (כולל owner-clear)
  · welcome_auth_gate + user_system_sync + pending_banner + onboarding ירוקים.

## #release-v7.01 — bump גרסה (STATUS label + versionCode) — 2026-07-28
- אין פונקציית-עזר חדשה: שינוי release/docs בלבד — תווית `v7.00→v7.01` ב-STATUS.md
  (מקור-האמת ל-`gen_version.sh`) + `pubspec.yaml 1.5.0+12→1.5.1+13` (versionName/Code
  לחנויות). `version.g.dart` gitignored ונוצר-מחדש. הכיסוי הקיים (`version_g_test`)
  ממשיך לנעול את פורמט-התווית `^v\d+\.\d+$` — v7.01 עובר.
- מסקנה: אין mutation-test חדש (אין לוגיקה חדשה); הבדיקה הקיימת מספיקה.

## #screen-mgmt-s1 — מודל-סקציות-פר-מסך (סדר + הסתר) — 2026-07-27
- **הפונקציות:** `ScreenSectionsNotifier` (`orderedIds`/`visibleIds`/`hide`/`show`/`toggle`/`reorder`/`moveUp`/`moveDown`/`resetScreen`) + `ScreenLayout` (order+hidden · JSON).
- **תקלה שהוזרקה (mutation-sensitivity):** `visibleIds` מחזיר `orderedIds` בלי סינון-`hidden` ⇒ בדיקת hide (`visibleIds==['a','c']`) אדומה.
- **בטיחות:** default ריק ⇒ `orderedIds==defaults` · אפס-persist ⇒ **זהה-בייטים**. non-destructive (order שומר את ה-id, רק visible מסנן). canonical-minimal (`resetScreen`→remove key). לא-נוגע בשני-המקורות החיים (home_content_order · hidden_catalog_sections).
- **אימות:** analyze 0 · screen_sections 7/7.

## #screen-mgmt-s0 — כיבוי טריגר-עריכה-על-המסך — 2026-07-27
- **השינוי:** `StudioOverlay.build` → `SizedBox.shrink()` **תמיד**; הוסרו הטוגל נווט⇄ערוך / בורר-הבורדים / publish + ה-imports המתים (analyze 0).
- **תקלה שהוזרקה (mutation-sensitivity):** להחזיר את הטוגל (on-gate מרנדר נווט/ערוך) ⇒ בדיקת "on-gate-owner עדיין-inert" (`find.text('ערוך') findsNothing`) אדומה.
- **בטיחות:** אין קורא-אחר ל-`enterEdit` בכל הקוד ⇒ freeze מלא (edit-mode לא-ניתן-להפעלה-מהמסך). `main.dart` mount לא-נגע. שער-#84 לא-שונה. לא-בעלים זהה-בייטים (tree-shake). re-enable = git revert.
- **אימות:** analyze 0 · zero_regression 20/20 · studio 192.

## X4 — StockNotifier.move delegation ל-FirebaseStockRepository (server-connect wave) — 2026-06-16

- **קובץ:** `test/stock_firebase_repo_test.dart` (קייס חדש: `move() routes through the repo + mirrors its cache`).
- תקלה שהוזרקה: `stock_screen.dart` `StockNotifier.move` — שבירת ה-delegation (`if (r != null) {` → `if (r != null && false) {`), כך שהמהלך נשאר in-memory בלבד (בדיוק באג X4 שלפני התיקון).
- תוצאה: **אדומה ✅** — נכשל `Expected: site / Actual: warehouse` (ה-repo cache לא זז → `r.stockDemo()[name]` ≠ `notifier.state[name]`; `+0 -1`). שחזור → ירוק ✅ (`+1`).
- מסקנה: הבדיקה חזקה — נועלת ש-`StockNotifier.move` **מנתב דרך** ה-`FirebaseStockRepository` המחובר (לא ה-fork ה-in-memory), כך שמהלך-מלאי של הקבלן מגיע ל-Firestore ולתצוגת ה-worker (`employer_stock.dart`). זהה-בייט במסלול ה-local (repo=null → flip in-memory verbatim).

## chat-sync — self-stamp participantUids (A14 last-mile) — 2026-06-15

- **קובץ:** `test/chat_uid_a14_populate_test.dart` (קייס חדש: `lookup: null` → self-stamp).
- תקלה שהוזרקה: `sys_chat.dart` `ensureParticipantUids` — `final union = <String>{me}` → `<String>{}` (לא לכלול את השולח).
- תוצאה: **אדומה ✅** — "NULL lookup ... SENDER's own uid STILL stamped" נכשל (participantUids ריק במקום `[uid-c]`; `+6 -1`). שחזור → ירוק ✅ (`+7`).
- מסקנה: הבדיקה חזקה — נועלת את ערובת ה-self-stamp (אנלוג ל-orders `contractorUid==auth.uid`): גם בלי users-directory (מצב-המכשיר שבו ה-lookup נכשל/null), ה-uid של השולח תמיד ב-participantUids → write/read של צ'אט אינם נדחים. לצד זה: `chat_repository` scope ל-`participantUids` (arrayContains, gated), ו-index+rules יושרו על אותו שדה.

## compatibleProductsCount/For — אינדקס-SKU O(1) (#2) — 2026-06-15

- **קובץ:** `test/compat_index_test.dart` (חדש — נועל את האופטימיזציה).
- תקלה שהוזרקה: getter `_skuIndex` (`related_info.dart`) → `<String,LipskeyCatalogProduct>{}` (אינדקס ריק) במקום `{for p in kCatalogProducts: p.sku: p}`.
- תוצאה: **אדומה ✅** — "compatibleProductsFor resolves real mates" נכשל (mates ריק; `+1 -1`). שחזור → ירוק ✅ (`+2`).
- מסקנה: הבדיקה חזקה — נועלת ש-`compatibleProductsCount`/`compatibleProductsFor` פותרים mates דרך אינדקס-ה-SKU המאוחד. השינוי (#2): החלפת ה-scan ה-O(catalog) (`kCatalogProducts.where((x)=>x.sku==key).first`) ב-`_skuIndex[key]` ה-O(1) — מאיץ את `cardReadinessScore` (מסך-הקטלוג קורא לו לכל כרטיס) מ-O(M×N) ל-O(M). זהה-בייט: SKUs ייחודיים (שער 86) → `_skuIndex[key]` == `.where(...).first`.

## de-bundle לוח-קבלן + tasks_screen.approve (גל DEBUNDLE, via /swarm) — 2026-06-14

- **קובץ:** `test/worker_approval_engine_test.dart` (טסט-ליבה: עובד מגיש → קבלן מאשר → `done` חי).
- תקלה שהוזרקה: `tasks_engine.dart:552` `approve` — `copyWith(status: 'done')` → `'review'`.
- תוצאה: **אדומה ✅** — 3 טסטים נכשלו (done-reflects-live · order-advance · WIDGET-manager badge). שחזור-מגיבוי → ירוק ✅ (7/7).
- מסקנה: הבדיקה חזקה — נועלת מעבר-אישור קבלן→עובד על המנוע המשותף. הפירוק (הסרת טוגל מנהל↔עובד + `_workerView` + 4 כפתורי-כלים כפולים; אריחי Site-Hub גאנט/ליקויים/נוכחות→מנועים חיים + אריח-HR + מחיקת 3 מסכי-דמו; scoping ל-`kDemoContractorId`; חסימת 6 `kWorkers[]`) עבר נקי: analyze 0 · +2509 · build web ✓ · supervisor 15/15.

## requestsForEmployer + vacation employerId (גל H1) — 2026-06-14

- **קובץ:** `test/contractor_vacation_approval_test.dart` (8 מקרים).
- 2 באגים שנתפסו בבדיקה ותוקנו: (1) decode `employerId as String? ?? ''` לא-בטוח → `is String ?` דפנסיבי (עקבי עם reason/role/status/signature האחים — לא יזרוק על JSON פגום); (2) newest-first לפי `createdTs` לא-דטרמיניסטי ב-tie (List.sort לא יציב) → `all.reversed` (סדר-הכנסה, יציב, עבר את "queue is newest-first").
- אימות: 8 טסטים נועלים (submit→scope · approve/reject · newest-first · back-compat employerId='' · role/employer-scope) + supervisor CLEAN (פעמון-אחד, מקבילי/מנהל-byte-identical, צ'אט→th-worker-contractor).
- mutation פורמלי דולג: 8 מקרים אסרטיביים + supervisor + 2 התיקונים שנתפסו = ה-RED→GREEN.

## MaterialRequest engine (גל E3) — 2026-06-14

- **קובץ:** `test/material_requests_test.dart` (7 מקרי דו-כיווני).
- אימות: 7 טסטים התנהגותיים נועלים — submit→inbox+worker (דו-כיווני) · setStatus live · decline · terminal-guard · empty-drop (אין-המצאות) · distinct-ids (_seq) · employer-scope. + supervisor CLEAN (ישות-אמיתית, ללא-שינוי-מלאי).
- mutation פורמלי **דולג**: הישות מבדקת-היטב (7 מקרים אסרטיביים) + המפקח אימת אי-ריקות → ה-RED→GREEN = כיסוי-הטסטים. (עקבי עם הקלת-רגור בגלים מבדקים-היטב/read-only.)

## availabilityFor — token-aware join (גל E2) — 2026-06-14

- **קובץ:** `test/equipment_stock_join_test.dart` (16 מקרים, 6 false-positive חדשים).
- מצב: **המפקח הריץ את הפונקציה האמיתית** והוכיח שה-contains הגולמי ממציא זמינות (מפתח→'מפתח חבישה DN25', שקע, גו⊂גומי, 'ור pe'⊂'צינור pex') — RED אמפירי על seed ערוך.
- תיקון: token-aware (exact / ≥2-token contiguous; single-token→exact-בלבד) → כל ה-false-positives → unknown (GREEN); 6 מקרים נועלים זאת.
- מסקנה: ה-RED→GREEN = הדגמת-המפקח + הנעילה; הבדיקה חזקה (תופסת המצאת-זמינות, אין-המצאות).

## employerStockProvider — empty-guard (גל E1) — 2026-06-14

- **קובץ:** `test/employer_stock_test.dart` (עובד קורא מלאי-מעסיק READ-ONLY).
- תקלה שהוזרקה: היפוך `if (employerId.isEmpty)` → `isNotEmpty`.
- תוצאה: **אדומה ✅** — 3 טסטים נכשלו (ריק→[] · non-empty→projection · seed-אמיתי). שחזור → ירוק ✅.
- מסקנה: הבדיקה חזקה — נועלת חוסר-קישור→ריק (אין-המצאות) + הפתרון-למלאי-הקבלן.

## TasksNotifier.createTask — id-minting (גל T2) — 2026-06-14

- **קובץ:** `test/contractor_task_authoring_test.dart` (headline: קבלן יוצר → עובד רואה חי, id חדש = 6).
- תקלה שהוזרקה: id-minting `+1`→`+0` (התנגשות עם max seed id).
- תוצאה: **אדומה ✅** — 3 טסטי-יצירה נכשלו (id מתנגש, headline). שחזור → ירוק ✅.
- מסקנה: הבדיקה חזקה — נועלת מינטינג-id ייחודי + הופעת-המשימה-בסקופ-העובד.

## TasksNotifier.approve — orderId→advance fold (גל T1) — 2026-06-14

- **קובץ:** `test/worker_approval_engine_test.dart` (אישור משימה-מקושרת → ההזמנה מתקדמת, open-orders 4→3).
- תקלה שהוזרקה: השבתת `r.read(ordersEngineProvider.notifier).advance(orderId)` ב-`approve`.
- תוצאה: **אדומה ✅** — טסט ה-order-advance נכשל (ההזמנה לא התקדמה). שחזור → ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת ניתוק של ה-fold (איחוד-המנוע לא שובר את קישור משימה↔הזמנה).

## employerProfileProvider (גל-0 חיווט קבלן↔עובד) — 2026-06-14

- **קובץ:** `test/employer_link_test.dart`.
- **מה עושה:** נועל ש-`employerId` ריק → `EmployerProfile.isEmpty` (אין-המצאות מעסיק), ולא-ריק → פותר את הקבלן-על-המכשיר (name/businessId/address/contact).
- תקלה שהוזרקה: היפוך השומר `if (employerId.isEmpty)` → `isNotEmpty` (כך שלא-ריק מחזיר פרופיל ריק).
- תוצאה: **אדומה ✅** — 3/3 נכשלו (empty→isEmpty · non-empty→resolves · server-swap-key). ביטול → ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת גם אובדן-פתרון וגם המצאת-זהות-מעסיק.

## kSearchIndex — copy פרסונה canonical (W0 microcopy) — 2026-06-08

- **קובץ:** `test/search_index_persona_copy_test.dart` (חדש).
- **מה עושה:** נועל שאף `SearchEntry.title` לא מכיל `מנהל מערכת` (חסר ה׳) + שה-canonical `מנהל המערכת` קיים. ('מנהל מערכת' אינו תת-מחרוזת של 'מנהל המערכת' → contains מבחין נקי.)
- תקלה שהוזרקה: replace_all `מנהל המערכת`→`מנהל מערכת` (החזרת ה-drift).
- תוצאה: **אדומה ✅** — 2/2 נכשלו (bad לא-ריק · canonical חסר). ביטול → ירוק ✅.
- מסקנה: הבדיקה **חזקה** — תופסת drift של שם-הפרסונה ב-search index.

## chatBubbleAlignment — צד-בועת-צ׳אט (W1 #1 · RTL) — 2026-06-08

- **קובץ:** `test/chat_bubble_side_test.dart` (חדש).
- **מה עושה:** נועל את חוזה ה-spec (`sys_chat.dart §1 כיווניות`): הודעות-עצמי בצד
  start (ימין ב-RTL), אחרים end (שמאל); ו-resolve נכון ל-RTL (own→x=+1, other→x=−1).
  התיקון מנתב גם בועת-הודעה וגם בועת-הקלדה דרך `chatBubbleAlignment`.
- תקלה שהוזרקה #1: החלפת start↔end (`isMe ? centerEnd : centerStart`).
- תוצאה: **אדומה ✅** — 3/4 נכשלו (own→start · other→end · resolve-RTL); רק "לא-חולקים-קצה" עבר.
- תקלה שהוזרקה #2 (מבנית): החזרת `Alignment` אבסולוטי (הבאג המקורי) → **אינו מתקמפל**
  (טיפוס-החזרה `AlignmentDirectional`) — חוסם רגרסיה ל-absolute.
- מסקנה: הבדיקה **חזקה** — תופסת היפוך-צד; טיפוס-ההחזרה חוסם חזרה ל-`Alignment.center(Left|Right)`.
## install_engine — הנחיית-כיווניות לכל שסתום (B13/#1) — 2026-06-08

- **קובץ:** `test/install_engine_b13_test.dart` (חדש). פונקציית-עזר חדשה: `_directionalContext`.
- **מה עושה:** נועל שהאזהרה הכללית של B11 הפכה ל-**צ'ק לכל שסתום חד-כיווני** —
  `lineComplianceChecklist` פולט "כיוון התקנה: <שם השסתום>" עם `_directionalContext`
  שמציין "בין <עליון> ל-<תחתון>" (או כניסת/יציאת הקו). שני שסתומים → שני צ'קים.
- תקלה שהוזרקה: `_directionalContext` → `return ''` (ביטול ההקשר).
- תוצאה: אדומה ✅ — "naming the valve + neighbours" + "lone contextualised" נכשלו
  (אבד 'בין'/שמות-השכנים/'בקו'); "two valves" + "no directional" נשארו ירוקים.
- ביטול → ירוק ✅ (B13 + B11 + auto_compliance + full_compliance).
- מסקנה: `_directionalContext` load-bearing. **תזכורת:** זו הנחיה, לא אכיפה —
  קצוות-השסתום זהים פיזית, אז דחיית-התקנה-הפוכה בלתי-אפשרית (task #20).

## install_studio — באנר עומס-יתר אמיתי (B12/#5) — 2026-06-08

- **שינוי:** UI בלבד ב-`install_studio_screen._assemble` — `branches` סופר רק
  target אמיתי (≠ המחלק), והבאנר מבהיר "N לא חוברו". **אין פונקציית-עזר חדשה.**
- **הלוגיקה כבר נבדקת:** התנהגות-העומס-יתר במנוע (cap + gaps + warning) נעולה
  ע"י `manifold_test` מקרה 10, שכבר mutation-proved ב-B7 (הסרת ה-cap → אדום).
- **אימות UI חי:** build web + דפדפן — קו 3-ענפים על מחלק 2-יציאות הציג
  "3 ענפים על מחלק 2-יציאות — 1 לא חוברו (חסר במחלק)". צילום נשמר (visual_log).
- מסקנה: אין פונקציה חדשה לבדוק; הספירה נגזרת מהקלט והבאנר אומת חזותית.

## install_engine — אזהרת כיווניות לשסתום חד-כיווני (D4/B11) — 2026-06-08

- **קובץ:** `test/install_engine_b11_test.dart` (חדש).
- **מה עושה:** נועל ש-`_isDirectionalDevice` מזהה אל-חזור/אלחוזר (נחושת) + אל-חזור-ביוב
  (קטגוריה 'אל חזור'), ושהצ'קליסט מוסיף אזהרת "כיוון התקנה" (warning) כשהקו כולל
  שסתום כזה. severity=warning → אפס השפעה על criticalOpen; deep_audit symmetry לא נגעה.
- תקלה שהוזרקה: `_isDirectionalDevice` — קטגוריה→'MUT', name-tokens→'MUTx/MUTy'.
- תוצאה: אדומה ✅ — 4 בדיקות-סימון נכשלו (כלפה/ביוב/אלכסוני/warning); "not flagged" עבר.
- ביטול → ירוק ✅ (B11 + auto_compliance + full_compliance + deep_audit).
- מסקנה: הזיהוי load-bearing. **חלקי במכוון** — זו אזהרה, לא אכיפה. **אכיפת-כיווניות
  מלאה** (port ל-ConnectorEnd + חיפוש-מכוון + הרפיית invariant-הסימטריה) היא שינוי-
  ארכיטקטוני שמחכה להחלטת-עיצוב (task #20).

## install_engine — אזהרת שובר-ואקום לברז-גן (E7/B10) — 2026-06-08

- **קובץ:** `test/install_engine_b10_test.dart` (חדש).
- **מה עושה:** נועל ש-`lineComplianceChecklist` מסמן קו-אספקה עם ברז-גן (`'ברזי גן'`)
  בבדיקת "שובר-ואקום" (warning, satisfied=false — אין מק"ט VB בקטלוג), ולא מסמן קו
  ללא ברז-גן. severity=warning כדי שלא ישפיע על `criticalOpen`.
- תקלה שהוזרקה: `hasGardenOutlet` → `categoryHe == 'MUT-B10'` (לא מזהה ברז-גן).
- תוצאה: אדומה ✅ — "garden-tap line flagged" + "WARNING/unsatisfiable" נכשלו;
  "non-garden NOT flagged" עבר (אישוש: ללא ברז-גן אין בדיקה).
- ביטול → ירוק ✅ (B10 + auto_compliance + full_compliance + install_plan_coverage).
- מסקנה: זיהוי-הגן load-bearing. **חלקי במכוון** — אין מוצר VB לחווט (task #20).

## lipskey_verified_connections — סריקת מקטינים/פקקים שטוחי-DN (B8) — 2026-06-08

- **קובץ:** `test/install_engine_b8_test.dart` (חדש).
- **מה עושה:** נועל ש-9 מק"טים שקצותיהם שוטחו ל-DN בודד (מצרה/מחבר/פקק) חושפים
  כעת את ה-DN משמם: מקטינים 218568→{50,40}/220316→{40,32}/116680→{50,32}/
  194897→{110,*}/218567→{160}, ופקקים חד-קצה 218569→[110]/218460→[50]/218560→[160]/220315→[40].
- תקלה שהוזרקה #1 (פקק): `218569` ends → [_c('50'),_c('50')] (חזרה ל-2-קצוות שטוח).
- תוצאה: אדומה ✅ — "a cap terminates ONE pipe" נכשל.
- תקלה שהוזרקה #2 (מקטין): `218568` ends → [_c('50'),_c('50')].
- תוצאה: אדומה ✅ — "reducers carry both named sizes" נכשל (חסר 40).
- ביטול שתיהן → ירוק ✅. **סוויטה-מלאה: 1569/1569 ירוק** (אפס רגרסיית-חיבור — אף
  בדיקה לא קידדה את החיבורים-השגויים האלה).
- מסקנה: ה-DN נגזרים משם-המוצר; 2 מקרים עמומים (ברך 40/49, אלקון 32/32 שסוג-הקצה
  לא ברור) הושארו לאישור-אנושי (task #20).

## install_engine — חסם עומס-יתר במחלק (E5/B7) — 2026-06-08

- **קובץ:** `test/manifold_test.dart` מקרה 10 (חוזק מבדיקת-אריתמטיקה לבנייה-אמיתית).
- **מה עושה:** נועל ש-`buildTreeInstallation` חוסם את מספר-הענפים למספר-היציאות
  הפיזי של המחלק; עודף → gaps (התקנה לא-שלמה) + אזהרה; TMTV/איזון רק לענף-מנותב.
- תקלה שהוזרקה: `cap = realTargets.length` (הסרת החסם) ב-buildTreeInstallation.
- תוצאה: אדומה ✅ — "4 ענפים על מחלק 2-יציאות" נכשל: 4 ענפים נותבו (zones>2),
  אין gaps עודף, אין אזהרה.
- ביטול → ירוק ✅ (manifold/zone_tmtv/twenty/auto_compliance, +59).
- מסקנה: החסם load-bearing; מחלק 2-יציאות לא פולט עוד 4 ענפי-פנטום עם ברזי-בטיחות.
- **ניקוי-אגב:** הוסר `mats` מת ב-`_autoAddCompliance` (שריד מ-B5 matsFinal) + import
  מיותר ב-manifold_test → analyze נקי.

## lipskey_verified_connections — מקטיני-DN שטוחים + טמפ'-חריג (B6) — 2026-06-08

- **קובץ:** `test/install_engine_b6_test.dart` (חדש).
- **מה עושה:** נועל (E6) `224156` maxTempC=70 (כמו האחים הזהים 224345/224169), ו-(E3)
  שמסעפי-ההקטנה חושפים את כל ה-DN משמם: 116558→{110,50}, 217533→{75,50}, 218564→{110,50}.
  ה-DN נגזרים מ**שם-המוצר** (מסעף 87° 110/50 וכו') — לא המצאה.
- תקלה שהוזרקה #1 (E6): `224156` maxTempC 70 → 80 (חזרה ל-typo).
- תוצאה: אדומה ✅ — "224156 maxTempC ... (70 not 80)" נכשל.
- תקלה שהוזרקה #2 (E3): `116558` ends → [_c('50'),_c('50'),_c('50')] (שיטוח חזרה).
- תוצאה: אדומה ✅ — "reducing branches expose ALL named DNs" נכשל (חסר 110).
- ביטול שתיהן → ירוק ✅ (B6 + pdf_parity + twenty_products + audit40 + deep_audit, +306).
- מסקנה: הבדיקה תופסת גם סטיית-טמפ' וגם מחיקת-DN.

## install_engine — גלוון מבוסס-קבוצות (E1) + ראש/מזלף-מקלחת טרמינל (E8) — 2026-06-07

- **קובץ:** `test/install_engine_b5_test.dart` (חדש, 8 בדיקות).
- **מה עושה:** (E1) נועל ש-`_galvanicallyDissimilar` דורש רקורד-דיאלקטרי רק בין
  קבוצות-מתכת שונות (נחושת/פליז × פלדה/נירוסטה) — דרך `lineComplianceChecklist`;
  (E8) נועל ש-`flowRole` של ראש-מקלחת/מזלף = fixture (קצה), זרוע/מערבל = connector.
- תקלה שהוזרקה #1 (E1): `_galvanicallyDissimilar` → `copperGroup.length>=2` (הסרת בדיקת iron-group).
- תוצאה: אדומה ✅ — כל 4 בדיקות-E1 נכשלו: פלדה↔פליז, נירוסטה↔פליז, נחושת↔פלדה
  (לא דרשו דיאלקטרי), ונחושת↔פליז (דרש דיאלקטרי בטעות = over-flag).
- תקלה שהוזרקה #2 (E8): הסרת `'ראשי מקלחת','מזלפי יד'` מ-`_terminalCats`.
- תוצאה: אדומה ✅ — ראש + מזלף חזרו ל-connector (2 בדיקות נכשלו); זרוע + מערבל
  נשארו connector (עברו) — מאשר שהזרוע/מערבל לא הושפעו.
- ביטול שתיהן → ירוק ✅ (B5 + auto_compliance + install_engine_safety עברו).
- **תיקון-סדר נוסף (חשף ע"י E1):** `_autoAddCompliance` חישב `mats` *לפני* הזרקת
  מיכל-ההתפשטות מ-פלדה → לא הוסיף רקורד-דיאלקטרי לזיווג פליז↔פלדה שהוא-עצמו יצר.
  עכשיו מחושב `matsFinal` על ה-items הסופיים → הדיאלקטרי מתווסף. מאומת ע"י
  `criticalOpen(60)==0` ב-install_plan_coverage/full_compliance_audit/engine_harness
  (היו אדומים "got 1" לפני התיקון) + בדיקת "hot line auto-adds dielectric".
- מסקנה: שלושה תיקונים load-bearing (גלוון, מקלחת, סדר-הדיאלקטרי); אפס over-flag.

## install_engine — מכשירי-קצה: אחד לקו, אין קצה→קצה (B4) — 2026-06-07

- **קובץ:** `test/install_engine_safety_test.dart` (קבוצה: terminal devices D1/D3/D5/D6).
- **מה עושה:** נועל ש-`_terminalCats` (סיפונים/מחסומים-גלויים/מחסומי-רצפה/מאספי-רצפה/
  תעלות/ניקוז-גג/מאספים · ברזי מטבח/כיור/קיר/אמבטיה/גן/דלי) הם `flowRole=fixture`
  (קצה בלבד), שאסור שני-טרמינלים על קו (double-trap / שני-ברזים), ושגם מקרה
  נפרד-ע"י-צינור נתפס ברמת-הקו (`buildInstallation` → gap → `isComplete=false`).
- תקלה שהוזרקה #1 (MUT-A, סיווג): הסרת `|| _terminalCats.contains(c)` מ-`flowRole`.
- תוצאה: אדומה ✅ — 4 בדיקות-terminal נכשלו (שני-סיפונים / שני-ברזים / שני-מחסומי-
  רצפה / trap→pipe→trap *מצאו* נתיב) + `audit40` "5 כשלים" (3/15/23/35/39 חזרו למצוא נתיב).
- תקלה שהוזרקה #2 (MUT-B, guard ברמת-קו): `if (terminals.length > 1)` → `> 99`.
- תוצאה: אדומה ✅ — **רק** "separated trap→pipe→trap" נכשל; המקרים הצמודים נשארו
  ירוקים (ה-path-guard תופס אותם) → מוכיח ששני ה-guards נחוצים, לא יתירים.
- ביטול שתיהן → ירוק ✅ (52 בדיקות B4-affected עברו, אפס רגרסיה).
- מסקנה: הסיווג, ה-path-guard וה-line-guard — שלושתם load-bearing.

## install_studio — חיווט בדיקת שיפוע-ניקוז (P3.9) — 2026-06-07

- **שינוי:** UI-wiring בלבד ב-`install_studio_screen.dart` — בלוק הלחץ
  (עלייה אנכית / ירידת לחץ) מסונן כעת ל-`lineIsSupply` בלבד, וקו ניקוז מקבל
  במקומו בלוק שיפוע (סליידרים אורך/מפל → `checkDrainageSlope`).
- **אין פונקציית-עזר חדשה** — הלוגיקה כבר קיימת ונבדקת:
  - `checkDrainageSlope` (pressure_drop): נבדק ב-`pressure_drop_advanced_test`
    גם למקרה תקין (ok) וגם למקרה כושל (bad, < 2% → ok:false) — מקרה-ה-bad הוא
    בעצם "הזרקת התקלה" שמוכיחה שספי ת"י 1205 (2%) נאכף ולא ואקום.
  - `lineIsSupply` (install_engine): קובע אספקה↔ניקוז, מכוסה בעקיפין בשערי
    audit40 / install_engine_safety (חוצה-מערכת).
- **אימות UI:** הודגם חי (build web + דפדפן) — קו ניקוז מציג "שיפוע ניקוז 2.0% —
  תקין (≥2% ת"י 1205)", ריאקטיבי לסליידרים (2.0%→4.6%). צילומי-מסך נשמרו.
- מסקנה: אין פונקציה חדשה לבדוק-מוטציה; ספי ה-2% כבר נעול בבדיקת-המנוע הקיימת.

## install_engine safety — _findBridge חוצה-מערכת (P2.4) + manifoldOutlets טקסונומיה (P2.5) — 2026-06-07

- **קובץ:** `test/install_engine_safety_test.dart` (חדש, 4 בדיקות).
- **מה עושה:** נועל (P2.4) ש-`buildInstallation` לעולם לא מגשר supply↔drainage —
  זוג חוצה-מערכת חייב לצאת כ-gap, לא כגשר; ו-(P2.5) ש-`manifoldOutlets` מסווג
  מחלק לפי טקסונומיית-הקטלוג (`'מחלקים'`), לא לפי ספירת-קצוות.
- תקלה שהוזרקה #1 (P2.5, שער-טקסונומיה): ניטרול
  `if (p.productType != 'מחלק' && p.categoryHe != 'מחלקים') return 0;` ב-`manifoldOutlets`.
- תוצאה: אדומה ✅ — "tee 116565 NOT a manifold" נכשל (החזיר 3 במקום 0).
  מחלקים אמיתיים (4/2/4) + צינור (0) נשארו ירוקים — הניטרול לא נוגע בהם.
- תקלה שהוזרקה #2 (P2.4, שתי שכבות-ההגנה): ניטרול גם ה-guard
  `if (shared.isEmpty) return null;` וגם פילטר ה-`canConnect` ב-`_findBridge`.
- תוצאה: אדומה ✅ — "never bridges supply↔drainage" נכשל עם **1600 גשרים
  חוצי-מערכת**. החזרת שכבה אחת בלבד → ירוק.
- ביטול שתיהן → ירוק ✅ — `+4 All tests passed`.
- מסקנה: P2.5 — שער אמיתי שתופס היפוך-סיווג (tee↔מחלק). P2.4 — הבדיקה אוכפת
  end-to-end את אי-חציית-המערכת; ה-guard הוא שכבת-בטיחות יתירה התואמת את ה-BFS
  (probe: 0/3600 ניתנים-להגעה היום, אז הגנה-בעומק ולא תיקון-דליפה-חי).

## install_engine hardening — kBspInchToMm + insertAt guard (B1) — 2026-06-07

- **קובץ:** `test/install_engine_hardening_test.dart` (חדש, 3 בדיקות).
- **מה עושה:** נועל (1) את `kBspInchToMm` — מקור-האמת היחיד לטבלת BSP אינץ׳→מ"מ
  שאוחד מ-3 עותקים מועתקים-ביד (install_engine `_minBoreMmOf` · pressure_drop
  `_boreMeters` · related_info `engineeringSpecFor`); ו-(2) את ה-guard ב-
  `_autoAddCompliance.insertAt` שמונע קריסת `clamp(1,0)` על קו חד-פריטי.
- תקלה שהוזרקה #1 (ערך-קוטר): `kBspInchToMm` `'1/2': 15` → `'1/2': 14`.
- תוצאה: אדומה ✅ — `at location ['1/2'] is <14> instead of <15>` (בדיקת הטבלה-המדויקת).
- תקלה שהוזרקה #2 (השבתת guard): `if (items.length < 2) return;` → `if (items.length < 0) return;`.
- תוצאה: אדומה ✅ — `buildInstallation([oneSupplyProduct], autoCompliance)` זרק
  `ArgumentError:<Invalid argument(s): 1>` (בדיוק קריסת ה-clamp שה-guard מונע);
  הבדיקה ציפתה `return normally`.
- ביטול שתיהן → ירוק ✅ — `+3: All tests passed!`.
- מסקנה: הבדיקה חזקה — תופסת גם סטיית ערך-בודד בטבלת-הקוטר המאוחדת וגם הסרה של
  ה-guard (רגרסיית-קריסה אמיתית), לא רק happy-path.

## cheaperAlternativesAcrossCatalog (T1) — 2026-06-04

- **קובץ:** `test/cheaper_alternatives_test.dart`
- **מה עושה:** סורק את `kHomeProductBrands` (proto §1b HOME_PRODUCTS) ומחזיר לכל מוצר את החלופה הזולה ביותר שמתחת למחיר ההמלצה; אוכף ≥3 חלופות, כל `altPrice<recPrice`, `savings>0`, וסדר-חיסכון יורד.
- תקלה שהוזרקה: `t.price < rec.price` → `t.price > rec.price` (בורר את הטיר היקר במקום הזול).
- תוצאה: אדומה ✅ — `Expected: a value less than <189> · Actual: <329>` (ברז לכיור בחר פרימיום).
- ביטול → ירוק ✅ — All tests passed.
- מסקנה: הבדיקה חזקה — תופסת היפוך של לוגיקת-הסינון המרכזית (זול↔יקר), לא רק קיום פלט.

## gate 117 closeout (v6.11) — full-snapshot parity לפולירול + חוליות — 2026-06-04

- **קבצים:** `test/_polyroll_snapshot.g.dart` (774) · `test/_huliot_snapshot.g.dart` (170).
- **מה עושים:** snapshot lock על כל nameHe+page של כל מק"טי הקטלוג.
- תקלה שהוזרקה (פולירול): `'צינור PPR אספקת מים 20'` → `'…אספקתX…'` (95016002).
  תוצאה: `Polyroll snapshot drift (1)` אדום ✅; ביטול → ירוק ✅.
- תקלה שהוזרקה (חוליות): `'ברך 15° צד אחד חלק 40'` → `'ברך 15X…'` (70041150).
  תוצאה: `Huliot snapshot drift (1)` אדום ✅; ביטול → ירוק ✅.
- מסקנה: ה-snapshots תופסים שינוי-תו-אחד בכל מ-944 המק"טים.

## gate 117 closeout — polyroll_pdf_parity_test — 2026-06-04

- **קובץ:** `test/polyroll_pdf_parity_test.dart` (חדש) — 20 SKUs מ-`kPolyrollCatalog`.
- **מה עושה:** snapshot lock על nameHe+page+brand של 20 פיפסים/אביזרים מייצגים.
- תקלה שהוזרקה: `'צינור PPR אספקת מים 20'` → `'…אספקתX…'` (95016002).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 closeout — huliot_pdf_parity_test — 2026-06-04

- **קובץ:** `test/huliot_pdf_parity_test.dart` (חדש) — 13 SKUs מ-`kHuliotCatalog`.
- **מה עושה:** snapshot lock על nameHe+page+brand של 13 ברכים/הגבהות/מכסים.
- תקלה שהוזרקה: `'ברך 15° צד אחד חלק 40'` → `'ברך 15X…'` (70041150).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 follow-up — lipskey_hierarchy_parity_test — 2026-06-04

- **קובץ:** `test/lipskey_hierarchy_parity_test.dart` (חדש) + `lib/data/chip_hierarchy.dart`.
- **מה עושה:** אוכף ש-parseChips מחזיר type+path תקינים ל-18 SKUs מייצגים של ליפסקי
  (תנאי-קדם להפעלת `_HierarchyChips` במקום `_NameWords`).
- תקלה שהוזרקה: `'מיכל הדחה'` → `'מיכלX הדחה'` ב-`_kCompoundTypes`.
- תוצאה: אדום ✅ — SKU 152785 (`מיכל הדחה טיטאן לבן`) נכשל ב-`type expected "מיכל הדחה"`.
- ביטול → ירוק ✅ — 18/18.
- מסקנה: הטסט אוכף את ה-compound-type lookup; שינוי שובר את שיוך-ה-type הגורף.

## gate 117 — lipskey_pdf_parity_test (מחסומי רצפה תיקניים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runFloorTrapGroup` (8 SKUs, עמ' 26–27).
- תקלה שהוזרקה: `'מחסום תיקני 140/50 פתוח'` → `'מחסום תיקניX 140/50 פתוח'` (218681).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (צינורות) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runPipeGroup` (57 SKUs, עמ' 47–48).
- תקלה שהוזרקה: ב-fixture 116101 color `'אפור'` → `'אפורX'`.
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (אביזרי תבריג) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runScrewOnGroup` (43 SKUs, עמ' 20–23).
- תקלה שהוזרקה: `'מחבר כפול תבריג 32/32'` → `'מחבר כפולX תבריג 32/32'` (116209).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (אטמים/פקקים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runGasketPlugGroup` (17 SKUs, עמ' 36–37).
- תקלה שהוזרקה: שינוי `'אטם לכוס 2"'` ל-`'אטם לכוסX 2qq'` (506525).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מאספים/כיסויים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runCollectorGroup` (19 SKUs, עמ' 30–33).
- תקלה שהוזרקה: `'רשת פנימית עגולה אפור'` → `'…אפורX'` (661360).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מצמדים/מצרות/פקקים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runConnectorGroup` (21 SKUs, עמ' 44–45).
- תקלה שהוזרקה: `'כובע אויר 110'` → `'כובע אוירX 110'` (120311).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מסעפים שקע-תקע) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runInsertionBranchGroup` (13 SKUs, עמ' 42).
- תקלה שהוזרקה: `'מסעף 45° 40/40'` → `'מסעף 45X 40/40'` (220305).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (ברכיים שקע-תקע) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה רביעית (`_runInsertionBendGroup`)
- **מה עושה:** fixture של 15 SKUs של ברכיים שקע-תקע (עמ' 40–41).
- תקלה שהוזרקה: `'ברך 87° 75'` → `'ברך 87X 75'` (116033).
- תוצאה: הבדיקה אדומה ✅.
- ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מחסומים גלויים) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה שלישית (`_runVisibleTrapGroup`)
- **מה עושה:** fixture של 32 SKUs מקטלוג ה-PDF (עמ' 8–15) — אגן 1.25", מטבח 2", אמריקאי 1.5"/2", צד, מאריכים+אביזרים.
- תקלה שהוזרקה: שינוי `'מחסום אמריקאי 1.5"'` → `'מחסום אמריקאיX 1.5"'` (218495).
- תוצאה: הבדיקה אדומה ✅ — `SKU 218495 · מחסום אמריקאי 1.5"`.
- ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מושבי אסלה) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה שנייה (`group('… מושבי אסלה')`)
- **מה עושה:** fixture של 26 SKUs מקטלוג ה-PDF (עמ' 53–55) + טסט פנטומים. אוכף `nameHe / color / qtyPack / qtyPallet / categoryHe / page` לכל מושב אסלה.
- תקלה שהוזרקה: `sed 's/מושב אסלה כרמל סגירה רכה לבן/מושב אסלה כרמלX סגירה רכה לבן/'` — שינוי שם דגם כרמל.
- תוצאה: הבדיקה אדומה ✅ — נכשלה ב-`SKU 195505 · מושב אסלה כרמל סגירה רכה לבן`.
- ביטול → ירוק ✅ — 51/51.
- מסקנה: הטסט תופס שינויי-שם גם בקטגוריה השנייה, באותה רמת דיוק.

## gate 117 — lipskey_pdf_parity_test (מיכלי הדחה) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` (חדש)
- **מה עושה:** fixture של 23 SKUs מקטלוג ה-PDF (עמ' 50–52) + טסט פנטומים. אוכף `nameHe / color / qtyPack / categoryHe / page / dims` של כל מיכל הדחה.
- תקלה שהוזרקה #1: `sed 's/מיכל הדחה ספיר לבן/מיכל הדחה ספירX לבן/' lib/data/lipskey_catalog.dart` — שינוי שם דגם של ספיר.
- תוצאה: הבדיקה אדומה ✅ — נכשלה ב-`SKU 124848 · מיכל הדחה ספיר לבן`.
- ביטול → ירוק ✅ — 24/24.
- מסקנה: הטסט תופס שינויי-שם ב-nameHe מקצה-לקצה, גם תווים בודדים.



- **קובץ:** `lib/data/polyroll_catalog.dart:609`
- **מה עושה:** factory function — יוצר `LipskeyCatalogProduct` לצינור PPR מיזוג אוויר (Aquatherm blue pipe). עוטף `_ppr()` עם קבועים ספציפיים ל-AC.
- **בדיקה:** `test/polyroll_catalog_test.dart` — ודא שמוצר AC Blue Pipe מופיע ב-`kPolyrollCatalog` עם SKU תקין.
- מסקנה: factory בלי לוגיקה — בדיקה מינימלית מספיקה (SKU קיים, קטגוריה נכונה)

## §22.H photo-only routing (_pprSpecFor: kPprElectrofusion + kPprTools) — 2026-05-31
- תקלה שהוזרקה #1: p72 routing `90→45` (כל ברך 90° מקבל spec של 45°).
- תוצאה: §22.H אדום ✅ (תפס את ה-swap, לא רק "לא page").
- תקלה שהוזרקה #2: p91 routing `תותב die→driver`.
- תוצאה: §22.H אדום ✅.
- מסקנה: הבדיקה חזקה — אחרי שחיזקתי מ-"not page + exists" ל-מיפוי-ספציפי
  פר-תת-סוג. הגרסה החלשה הראשונה הייתה עוברת את שני ה-swaps.

## §21 chip parser — angle vs size (parseChips/kChipLevel2Shape) — 2026-05-31
- תקלה שהוזרקה: החזרת bare '45','90' ל-kChipLevel2Shape (המצב הקודם).
- תוצאה: §21 angle test אדום ✅ — הקוטר 90mm נגנב לתא ה-shape, size=null.
- מסקנה: הבדיקה חזקה — תופסת גם את ה-collision של זווית-מול-קוטר וגם את
  הבליעה של sizeRe. הוזרק וחזר ירוק אחרי שחזור.

## §21 multi-word chip compound (_l3Compounds) — 2026-06-01
- תקלה שהוזרקה: מחיקת 'למיקום נקודת מים' מ-_l3Compounds.
- תוצאה: §21 multi-word test אדום ✅ — הביטוי התפזר ל-[מים, למיקום, נקודת].
- מסקנה: הבדיקה חזקה — מאמתת גם נוכחות הביטוי כ-chip אחד וגם היעדר פיזור.

## §21.B unit-fold — recoverability E2E (parseChips / _kChipUnits) — 2026-06-01
- תקלה שהוזרקה: הסרת ענף ה-unit-fold (`if (_kChipUnits.contains(t))`) מ-parseChips.
- תוצאה: §21.B test אדום ✅ — `מזוודת ריתוך קטנה 20-63 מ"מ` איבד את "מ"מ"
  (lost: מ"מ), השחזור מ-set-המילים נכשל.
- מסקנה: הבדיקה חזקה — תופסת כל נפילת token (לא רק מ"מ): משווה את כל set-המילים
  מקור↔שחזור על כל kPolyrollCatalog. הוזרק וחזר ירוק אחרי שחזור הענף.

## §21.C chip level labels (levelLabelOf / מידה anchor) — 2026-06-01
- תקלה שהוזרקה: שינוי `if (i == 0 && level5 != null) return 'מידה';` → return ''.
- תוצאה: §21.C test אדום ✅ — ציפי-הגודל בכל הקטלוג קיבלו label ריק, הבדיקה
  פלטה רשימה ארוכה של "size chip 'X' → '' (expected מידה)".
- מסקנה: הבדיקה חזקה — לא רק מאמתת קיום של אחת מ-5 תוויות אלא מצמידה את ציפ
  הגודל ספציפית ל-"מידה" (העוגן ל-leaf, כך שמשתמש תמיד יודע מה ה-bottom-of-chain).
  הוזרק, חזר ירוק אחרי שחזור.

### lib/data/polyroll_catalog.dart — 2026-06-01T15:00:31+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'מק"ט חוליות': sku,/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

## _sl — Huliot SmartLock factory (lib/data/huliot_smartlock_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart:61`
- **מה עושה:** factory — בונה `LipskeyCatalogProduct` עם brand='חוליות' ומזריק
  `יצרן='חוליות'` + `מק"ט חוליות'=sku` ל-dims אוטומטית (§22.I by-construction).
- תקלה שהוזרקה: הסרת `'יצרן': 'חוליות'` משדה ה-fullDims.
- תוצאה: הבדיקה הייתה אדומה ✅ — `§22.I every Huliot product carries יצרן`
  נכשל עם 170 קוויי "[no יצרן]".
- שחזור: byte-exact (החזרת השורה). הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת §22.I פר-מוצר. ה-factory pattern מבטיח שאי-אפשר
  לשכוח יצרן/מק"ט גם כשמוסיפים 170 מוצרים ב-batch.

## _brandDir — brand→dir mapping (lib/data/lipskey_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/lipskey_catalog.dart:49`
- **מה עושה:** static helper — ממפה brand string לתיקיית assets:
  פולירול→polyroll, חוליות→huliot_smartlock, אחר→lipskey.
- **בדיקה חיזק (2026-06-01 — סשן 100%):** נוסף `§22-Huliot every product
  asset resolves to assets/huliot_smartlock/` ב-spec_assets_test.dart שסורק
  כל imageAssets/specImageAssets של 170 מוצרי Huliot. בנוסף `§22-Huliot
  every Huliot page asset exists on disk` מוודא קיום פיזי.
- mutation_verify.sh ראשוני (תיעד את החולשה) → אחרי הוספת ה-test, mutation_verify
  שני (`s|if (brand == 'חוליות') return 'huliot_smartlock';|// removed|`) → אדום ✅.

### availableLensesForSet — 2026-05-31
- תקלה שהוזרקה: `>= smartTreeMinFraction` → `> smartTreeMinFraction` (סף עץ-חכם)
- תוצאה: הבדיקה הייתה אדומה ✅ ("exactly at the fraction → smart-tree included" נפל — 0.25 > 0.25 = false)
- תקלה שנייה: `if (products.any((p) => famSkus.contains(p.sku)))` → `if (true)` (variant תמיד)
- תוצאה: הבדיקה הייתה אדומה ✅ ("variant lens follows injected family membership" נפל — without-family ציפה לא-variant)
- מסקנה: הבדיקה חזקה — תופסת גם את גבול הסף (>=/>) וגם את תלות ה-variant במשפחה.

### groupByLens — 2026-05-31
- תקלה שהוזרקה: ב-smartTree case, `smartProductForSku(p.sku)` → `?? smartProductForSku(kLipskeyCatalog.first.sku)` (unmapped לא נזרק)
- תוצאה: הבדיקה הייתה אדומה ✅ ("smart-tree keeps ONLY mapped" — kept != mapped)
- תקלה שנייה: ב-variant case, `singletons.add(...)` → הוסר (singletons נזרקים)
- תוצאה: הבדיקה הייתה אדומה ✅ ("variant nothing dropped" — total != copper.length)
- מסקנה: הבדיקה חזקה — תופסת גם drop של unmapped ב-smartTree וגם drop של singletons ב-variant.

### cardReadinessScore (raised bar, 9 dims) — 2026-06-01
- שינוי: הנוסחה הורחבה מ-5 ל-9 ממדים (spec25/compat20/תקן12/התקנה13/קבלה5/תאימות5/מאתר5/מחיר5/וריאנט10), max 100.
- תקלה שהוזרקה: `score += 25` (spec) → `score += 0`.
- תוצאה: הבדיקה הייתה אדומה ✅ ("rich spec+connectable PPR hits top band" נפל — PPR ירד מ-95 ל-70 < 80).
- מסקנה: הבדיקה החדשה ("raised bar") חזקה — תופסת ירידת משקל ליבה. בנוסף: endpoint נשאר נמוך, ואין ממד יחיד שמגיע ל-100 (דורש רוחב).

### cardReadinessScore (quantity-aware) — 2026-06-01
- שינוי: הציון מודד עכשיו *כמות-ידע*, לא רק נוכחות בינארית. ממדים מדורגים: עומק-נתונים `p.dims.length` (≥8→15/4-7→10/1-3→5), חיבורים (≥20→18/≥5→12/>0→6), טיפים/קבלה/תאימות מדורגים לפי כמות. spec ירד 25→20, מחיר/מאתר ירדו.
- מניע (משוב משתמש): "לא תתסתכל על הכמות ידע שיש לו" — צינור PPR פייזר (dims=11, העשיר ביותר) קיבל ~75 בגלל compat=0; עכשיו 80 מצוין.
- תקלה שהוזרקה: ענף ה-dims `: 0` (אפס dims) → `: 50` (בונוס שמן ל-0 ידע).
- תוצאה: 2 בדיקות אדומות ✅ — "fixture endpoint (toilet seat) stays low" (אסלה קפצה 16→66 > 45) וגם "no single dimension reaches 100".
- מסקנה: הבדיקות תופסות ניפוח שגוי של מוצרים חסרי-ידע. אומת: PPR אספקה 98 · PPR פייזר 80 · אסלה 16 · סיפון כיור 63.

### cardReadinessScore (composite breadth+depth) — 2026-06-01
- מניע (משוב משתמש): "שישקף גם וגם משולב … ויתן ציון משוכלל משניהם" — ציון אחד שמשלב שני צירים.
- שינוי: הנוסחה פוצלה לשני תת-ציונים (כל אחד ≤50) ומוחזרים ב-record:
  • רוחב (breadth) — נוכחות משוקללת של *סוגי* ידע שונים (spec10/חיבור8/dims6/תקן6/התקנה5/וריאנט4/טיפים4/קבלה3/תאימות2/מאתר1/מחיר1).
  • עומק (depth) — *כמות* בתוך הסוגים המדידים (dims ≥8→18/4-7→12/1-3→6 · חיבורים ≥20→16/≥5→10/>0→5 · טיפים/קבלה/תאימות מדורגים).
  composite = breadth + depth (cap 100). מוצר רחב-ושטחי או עמוק-וצר נופל לאמצע; רק רחב+עמוק מגיע ל-מצוין.
- תוצאות מאומתות: PPR אספקה 99 (b49/d50) · PPR פייזר 75 (b41/d34, נענש על 0 חיבורים בשני הצירים אך מקבל קרדיט מלא על 11 dims) · אסלה 15 (b11/d4) · סיפון 55 (b40/d15). Lipskey top: 29 מוצרים ≥80, max 85 (צינורות גמישים b50/d35).
- תקלה שהוזרקה: `var score = breadth + depth` → `var score = breadth` (התעלמות מעומק).
- תוצאה: 2 בדיקות אדומות ✅ — "composite == breadth + depth" וגם "raised bar PPR hits top band" (PPR צנח ל-49<80).
- מסקנה: הבדיקות נועלות גם את הזהות composite=breadth+depth וגם את שילוב שני הצירים בפועל.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-01T19:21:42+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'יצרן': 'חוליות',/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/lipskey_catalog.dart — 2026-06-01T19:22:05+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (brand == 'חוליות') return 'huliot_smartlock';|// removed for mutation test|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Huliot smart-tree wiring (v5.62) — 2026-06-02
- שינוי: 17 מק"טי חוליות נוספו כ-SmartBrand ל-4 כרטיסי-ניקוז (floorDrain+7,
  basinTrap+3, kitchenDrain+4, washingMachineDrain+3). כיסוי עץ-חכם 293→310.
- תקלה שהוזרקה: מק"ט חוליות מחובר '70124599' → '00000000' (לא קיים בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — smartproduct_contract "Huliot … wired into the
  smart-tree" (spot-check sku→card + card-has-Huliot-brand) וגם "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: הקישור מוגן דו-שכבתית — test/smartproduct_contract_test + harness
  lib/test_harness/tests/catalog.dart (צעד 77).

### Huliot smart-tree wiring batch 2 (v5.63) — 2026-06-02
- שינוי: +62 מק"טי חוליות (צנרת PP) כ-SmartBrand ל-4 כרטיסים: pvcPipe+7,
  drainageElbow+27, drainageFittings+20, visibleTrap+8. כיסוי 310→372, חוליות 79/170.
- תקלה שהוזרקה: מק"ט ברך מחובר '70033960' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: הכיסוי המורחב מוגן; כל 8 הכרטיסים נבדקים שיש בהם מותג חוליות + spot-check.

### Huliot smart-tree wiring batch 3 (v5.64) — 2026-06-02
- שינוי: +38 מק"טי חוליות כ-SmartBrand: roofCollector+8 (מאספים), drainChannel+10
  (AQUA SLIM), floorCover+20 (מכסים/רשתות). כיסוי 372→410, חוליות 117/170.
- תקלה שהוזרקה: מק"ט AQUA SLIM מחובר '60150331' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 11 הכרטיסים מוגן (spot-check + ≥117 ממופים).

## _huliotImageFor — per-family crop routing (lib/data/huliot_smartlock_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart:46`
- **מה עושה:** switch פר-עמוד (11-43) שמנתב כל מוצר Huliot ל-crop פר-משפחה
  `sml_p{NN}_{a|b|c|d}.jpg` לפי keyword ב-nameHe. החליף את ה-fallback של
  עמוד-מוקטן (`page_NN.jpg`) ב-88 תמונות מוצר חתוכות (§17.1).
- **בדיקה:** `test/spec_assets_test.dart §17.1-Huliot every product front
  image exists + is a real crop` — מאמת (א) imageAsset קיים על דיסק; (ב) אינו
  `/pages/page_` (פרט לעמ' 27 AQUA SLIM). סורק 170/170.
- תקלה שהוזרקה: שינוי `case 11:` להחזיר `'page_11.jpg'` במקום `_p(11,'a')`.
- תוצאה: §17.1-Huliot אדום ✅ — "still on whole-page fallback" עם 7 מוצרי
  צינור (עמ' 11) שחזרו ל-page image.
- שחזור: החזרת `_p(11,'a')`. הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת כל regression לעמוד-מוקטן (הפרת §17.1). זו
  בדיוק התלונה של המשתמש ("איפה תמונות לפי פרוטוקול") — עכשיו test-guarded.

## parseChips — Huliot vocab + parser-skip cosmetics (lib/data/chip_hierarchy.dart) — 2026-06-01
- **קובץ:** `lib/data/chip_hierarchy.dart`
- **מה השתנה:** (א) tokenizer מדלג על '-', '—', '/' (separators קוסמטיים).
  (ב) ב-loop, raw token עם parens עוטפות → strip לפני vocab lookup.
  (ג) מספר נומרי אחרי `l5` נצמד אליו ב-space (היה ?? = pin to first only).
  (ד) kChipTypes/Level2/Level3 + _l3Compounds הורחבו ב-100+ tokens של Huliot.
- **בדיקות:**
  - `test/spec_assets_test.dart §21.B-Huliot every product fully recoverable
    via parseChips` — סורק 170/170; recon = type + path + leftover; כל מילה
    בשם (אחרי norm + skip '-/—//') חייבת להופיע ב-recon; leftover חייב להיות
    ריק. עבר 170/170.
  - `test/spec_assets_test.dart §21.C-Huliot every visible chip carries
    semantic level label` — כל chip ב-path מקבל אחת מ-{חיבור/צורה/תכונה/
    תבריג/מידה}; size chip תמיד 'מידה'. עבר.
- **תקלות שהוזרקו:**
  - הסרת ענף ה-`(raw.startsWith('(') && raw.endsWith(')'))` (paren-strip) →
    §21.B-Huliot אדום ✅ עם 12 מקרים `leftover: סיפון` (כש-(סיפון) לא matchen).
  - שינוי `l5 == null ? t : '$l5 $t'` → `l5 ??= t` (multi-numeric drop) →
    §21.B-Huliot אדום ✅ עם `missing: 3000/4000` ב-7 מוצרי צינור.
- שני המוטציות שוחזרו → ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת כל regression בפרסר שמשפיעה על תכולת ה-card
  (משאיר מילה מאחור = מילה מתאדה מה-UI = הפרת §14.E).

## FinderGroup 'דלוחין SmartLock' — finder_screen.dart — 2026-06-01
- **קובץ:** `lib/screens/finder_screen.dart:71` (אחרי 'צנרת PPR')
- **מה עושה:** קבוצת home שמאחדת 17 קטגוריות kSml* תחת label אחד
  ("🟢 דלוחין SmartLock"); 170 מוצרי Huliot נספרים תחתיה במסך הבית.
- **בדיקה:**
  - `test/wiring_test.dart` "named groups are pairwise disjoint" — מאמת
    שאין קטגוריה משותפת לשתי קבוצות. תפס שה-'סיפונים' הופיע גם בניקוז וגם
    ב-SmartLock; כשעדכנתי `kSmlSiphons = 'סיפונים SmartLock'`, הבדיקה עברה ירוק.
  - `test/finder_group_icons_test.dart` "every group has dedicated icon/image" —
    מאמת שלכל קבוצה יש Material icon ייעודי + תמונה ייעודית.
- תקלה שהוזרקה: החזרת `kSmlSiphons = 'סיפונים'` (הערך הקודם).
- תוצאה: שני בדיקות אדומות ✅ — `pairwise disjoint` שיכפל את 'סיפונים'
  בין ניקוז ו-SmartLock; `paranoid 12-check` לא נפגע (catRoot mapping של
  הבדיקה מסתמך על categoryHe).
- שחזור: החזרת `'סיפונים SmartLock'`. הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת collision של category-set בין שתי קבוצות
  finder. זו ההגנה היחידה שמבטיחה ש-finder.home לא מציג מוצר באותו פעם
  באף one of two distinct groups (UX duplicate).

### lib/data/related_info.dart — 2026-06-02T13:07:53+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#if (p.brand == 'חוליות') return (emoji: '🟢', label: 'דלוחין SmartLock');#// mutated#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/polyroll_e2e_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T13:42:06+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'יח׳\/ארגז': '90', 'יח׳\/משטח': '3,780'}/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T14:17:05+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#if (has('מוגבהת')) return _p(30, 'a');#// mutated#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T14:37:52+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#return _p(27, 'a');#return 'page_27.jpg';#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### system_division (productDivisionSystems · filterBySystem · nodeHasSystem) — 2026-06-02
- **קובץ:** `lib/logic/system_division.dart` · בדיקה: `test/system_division_test.dart`
- **מה עושה:** ליבת חלוקת מים/שפכים (בנצי #1) — סיווג מוצר/צומת-עץ ל-WaterSystem.
- תקלה שהוזרקה #1: ב-`productDivisionSystems` הפכתי את fallback ה-PPR מ-`supply` ל-`drainage`.
- תוצאה: אדום ✅ — `'PPR ... → supply'` נתפס (הכלל שהמשתמש קבע: PPR=מים נקיים).
- תקלה שהוזרקה #2: ב-`nodeHasSystem` הסרתי את שורת ה-`_fixtureTitles` (מתקנים
  לא יופיעו בשני הצדדים).
- תוצאה: אדום ✅ — `'fixture (אסלות) shows under BOTH systems'` נתפס (כלל option 2).
- תקלה שהוזרקה #3: ב-`filterBySystem` החזרתי `list` גם כש-system≠null (ביטול הסינון).
- תוצאה: אדום ✅ — `'supply filter keeps only supply'` נתפס.
- שחזור: שלושתן הוחזרו → הרצה ירוקה (9/9) ✅.
- מסקנה: הבדיקה חזקה — מכסה את שלושת הכללים (PPR=נקיים, מתקנים בשני צדדים, סינון ממשי).

### system_division — פאזה 2b (smartProductSystems · filterSmartBySystem) — 2026-06-02
- **קובץ:** `lib/logic/system_division.dart` · בדיקה: `test/system_division_test.dart`
- **מה עושה:** סינון עץ-חכם — ממפה את ה-SKU של מותגי ה-SmartProduct חזרה לקטלוג
  כדי לסווג כל מוצר-חכם למערכת (לא-פתיר → נשאר בשני הצדדים).
- תקלה שהוזרקה A: ב-`smartProductSystems` שיניתי `p.sku == sku` ל-SKU שלעולם
  אינו קיים (אף התאמה → כל מוצר "לא-פתיר").
- תוצאה: אדום ✅ — `'brand-SKU mapping resolves'` **וגם** `'filter discriminates'`
  נתפסו (הכול הפך ל"בשני הצדדים" → sup==dr==all).
- תקלה שהוזרקה B: ב-`filterSmartBySystem` החזרתי `list` תמיד (no-op, ביטול הסינון).
- תוצאה: אדום ✅ — `'filter discriminates — supply/drainage pools differ'` נתפס.
- שחזור: שתיהן הוחזרו → 14/14 ירוק ✅.
- מסקנה: הבדיקה חזקה — מכסה מיפוי-לא-no-op, אי-היעלמות (supply∪drainage מכסה הכול),
  והבחנה ממשית (48 נקיים · 58 שפכים מתוך 81; 23 supply-only · 33 drainage-only).

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T18:16:15+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|return 'spec_$img';|return 'spec_sml_p99_z.jpg';|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Huliot smart-tree wiring batch 4 (v5.72) — 2026-06-02
- שינוי: +9 מק"טי חוליות כ-SmartBrand: tools+4 (חותכים+מפתחות), drainageFittings+5
  (אומי-חיבור). חוליות 117→126/170. הנותרים (~44) = אביזרי-סיפון (SmartAcc), לא כרטיסים.
- תקלה שהוזרקה: מק"ט חותך מחובר '79904070' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 12 הכרטיסים מוגן (spot-check + ≥126 ממופים).

### _huliotImageForCrop — R2-fallback helper extraction (v5.80) — 2026-06-02
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart`
- **מה עושה:** ה-routing הקנוני (per-page tag mapping) חולץ ל-`_huliotImageForCrop`.
  `_huliotImageFor` עכשיו מחזיר `page_NN.jpg` כברירת-מחדל (R2-fallback)
  כל עוד `_routeCropDisabled = true`. כשהדגל יוסר → חוזר לקרוא ל-helper הקנוני.
- תקלה שהוזרקה: `s|return 'page_\${page.toString().padLeft(2, '0')}.jpg';|return null;|`
  (לדמות מצב שבו ה-fallback בעצמו נכשל).
- תוצאה: §17.1-Huliot אדום ✅ — `${p.sku} → null imageAsset`.
- מסקנה: ה-guard המוקל ("exists") עדיין תופס נפילה מוחלטת, ולא רק crop-vs-page.

### Huliot smart-tree wiring batch 5 — spare-parts card (v5.78) — 2026-06-02
- שינוי: כרטיס חדש `smlSpareParts` עם 44 מק"טי אביזרי-סיפון/מחסום כ-SmartBrand.
  כיסוי חוליות 126→**170/170 (100%)**.
- תקלה שהוזרקה: מק"ט אטם מחובר '67750440' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 13 הכרטיסים מוגן (spot-check + ≥170 ממופים).

### lib/logic/install_kit.dart — 2026-06-02T20:25:13+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (p.brand == 'חוליות')|if (p.brand == 'מותג-שלא-קיים')|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/polyroll_e2e_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Unified-catalog reads (v5.90) — 2026-06-03
- איחוד שלושה תיקונים על origin (עבודת v5.85–87, יושמה-מחדש אחרי ש-origin התקדם ל-v5.89):
  כרטיס-ריק (אחים מ-kCatalogProducts + guard), חיפוש-מק"ט (matchProducts על המאוחד),
  מועדפים/שורת-עגלה (kCatalogProducts).
- אימות: cartLineDisplay('lip:64032300') → שם-קטלוג ולא fallback;
  catalogProductMatchesQuery על kCatalogProducts מוצא 64032300, על kLipskeyCatalog ריק.
- נשאר Lipskey בכוונה: searchSuggestions (autocomplete) + ספירת-מתכנן.

### lib/data/chip_hierarchy.dart — 2026-06-03T17:46:43+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (brandOf(q) != brand) continue;|if (brandOf(q) == brand) continue;|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/huliot_picker_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

## resolveCatTitle / catNodeProductCount (category_division.dart) — 2026-06-03
- **קובץ:** `lib/logic/category_division.dart`
- **מה עושה:** ממפה כותרת-מחלקה (`kDeptCatHeadings.titles`) לצומת-עץ (top-node /
  leaf / synthetic) + סופר מוצרים תחתיו — הבסיס לתצוגת כלים-מול-צנרת (בנצי #1).
- תקלה שהוזרקה: `return null;` בראש `resolveCatTitle` (כל כותרת → לא-נפתרת).
- תוצאה: `category_division_test` אדום ✅ (3 בדיקות נפלו — "does not resolve" +
  flat-products ריקים למים/שפכים/אסלות).
- שחזור: byte-exact מ-backup; הרצה חוזרת 5/5 ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת מיפוי שבור (כל ערך חייב להיפתר לצומת עם >0 מוצרים, R8).

## דו-מערכתיים בשתי הכותרות (category_division.dart) — 2026-06-03 (v5.97)
- **קובץ:** `lib/logic/category_division.dart` (`kDeptCatHeadings['אינסטלציה']`)
- **מה עושה:** דו-מערכתיים (אטמים/חבקים/עוגנים/סטי-הידוק) רשומים תחת **שתי**
  הכותרות 💧 צינורות מים + 🟤 צינורות שפכים — נגישים מכל כותרת (בנצי #1).
- תקלה שהוזרקה: הסרת בלוק 5 הדו-מערכתיים מכותרת **שפכים**.
- תוצאה: `category_division_test` אדום ✅ (`+5 -1`) — נתפס ע"י הבדיקה החדשה
  "dual-system fittings appear under BOTH מים and שפכים headings (#1)"
  ("אטמים ופקקים missing from צינורות שפכים").
- שחזור: הבלוק הוחזר; הרצה חוזרת 6/6 ירוק ✅.
- מסקנה: הבדיקה חזקה — דורשת שכל דו-מערכתי יופיע בשתי הכותרות (ולא רק באחת).

### contractor_seeds helpers (T0) — 2026-06-04
- helpers: bestStore/fMoney/caToday/budgetLevel.
- אימות: שברתי מפריד-אלפים של fMoney (`% 3 == 0`→`% 3 == 9`) → contractor_seeds_test
  אדום ("Expected ₪9,840 · Actual ₪9840") ✅. שחזור → 8/8 ירוק.
- מסקנה: הבדיקה תופסת רגרסיה ב-helper.

### lib/data/persona_data.dart — 2026-06-03T23:58:26+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|t.worker == worker && statuses.contains|t.worker != worker \&\& statuses.contains|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/worker_app_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### ManagerAnalytics — 👔 dashboard derivations (lib/logic/manager_dashboard.dart) — 2026-06-03
- **קובץ:** `lib/logic/manager_dashboard.dart` · בדיקה: `test/manager_dashboard_test.dart`
- **מה עושה:** פורט PURE של `mgrAnalytics()` (@index.html:12081-12126) — `ManagerAnalytics`
  גוזר את 5 ה-mdMetric tiles (openOrders/catalogCount/accessoryCount/availableCount/
  storesLabel) ע"י fold על seed שפורט verbatim (STORES · SYS_ORDERS_SEED · התפלגות
  TREES · STORE_STOCK). כל מספר אומת מול הלולאה החיה ב-index.html (node-replay).
- תקלה שהוזרקה #1: ב-`catalogCount` הפכתי `totalProducts - accessoryCount` →
  `totalProducts + accessoryCount`.
- תוצאה: אדום ✅ — `'📦 catalogCount = non-accessory products = 54'` נפל (350≠54) וגם
  `'catalog + accessory == total'` (ה-split כבר לא ממצה).
- תקלה שהוזרקה #2: ב-`openOrders` הפכתי `o.isOpen` (`stage != 'delivered'`) ל-`!o.isOpen`.
- תוצאה: אדום ✅ — `'🚚 openOrders … = 4'` נפל (0≠4; אף הזמנה לא 'delivered').
- תקלה שהוזרקה #3: ב-`activeStores` הפכתי `where((s) => s.on)` ל-`where((s) => !s.on)`.
- תוצאה: אדום ✅ — `'🏪 stores = … 3/3'` נפל (`storesLabel`="0/3").
- שחזור: שלושתן הוחזרו → 12/12 ירוק ✅.
- מסקנה: הבדיקה חזקה — נועלת כל אחד מ-5 ה-tiles למספר ה-verbatim, וגם את אקסיומת
  ה-split (catalog+acc==total) ואת ה-flow (כל seed stage ∈ ORDER_FLOW). מוטציה בכל
  getter נתפסת. (`contractorCredit`/`mgrCustomerList` = foundation ל-M3, נבדקים גם הם:
  band 30k-120k · דטרמיניסטיות · group-by-buyer aggregation.)

### lib/screens/contractor_tools_sheets.dart — 2026-06-07T05:23:07+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/b.savings.compareTo(a.savings)/a.savings.compareTo(b.savings)/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/cheaper_alternatives_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/logic/ai_hub_logic.dart — 2026-06-07T18:44:40+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/int get save => fromPrice - toPrice/int get save => toPrice - fromPrice/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/t3_ghi_rewards_ai_home_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/settings_tree.dart (Wave 6 — מחיקה) — 2026-06-07
- שינוי ה-lib/(logic|data) ב-commit זה = **מחיקת data מת בלבד**: `kSettingsGroups`/`walkSettings`
  (~70 עלים const, 0 צרכנים, הוחלף ע"י מסכי-ההגדרות). אין logic/התנהגות למוטציה — נתון const שהוסר.
- שאר Wave 6 (autoStock→OOS · chat-history cleared-flag · העברת `storeOosProvider` ל-lib/state) ב-
  lib/screens|state; ל-`markOos` המועבר אין בדיקה ייעודית (ההתנהגות נשמרה verbatim בהעברה).
  מכוסה ב-suite הירוק של השער (analyze 0 · tests · build · conformance 7/7 · required-tests).

### lib/state/store_stock.dart — 2026-06-07T19:16:48+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/{...state, name}/{...state}/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/store_stock_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/state/sys_chat.dart — 2026-06-07T23:13:55+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/t.participants.contains(role)/true/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/sys_chat_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/repositories/stock_local.dart — 2026-06-08T00:12:00+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/stockDemo() => kStockDemo;/stockDemo() => const <String, String>{};/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/repositories_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/repositories/finance_local.dart — 2026-06-08T00:53:36+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/int budgetTotal() => kBudgetTotal;/int budgetTotal() => 0;/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/repositories_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/screens/profile_screen.dart — 2026-06-08T17:27:45+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/activePersona == null/activePersona != null/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/deep_fix_regression_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/lipskey_smart_data.dart — 2026-06-08T18:59:32+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/אטמים ופקקים/אטמים אומים ופקקים/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/lipskey_category_keys_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-08 (manual)
- שינוי: `_routeCropDisabled = true` → `false`, `_specCropDisabled = true` → `false`
- מטרה: הפעלת תמונות-מוצר חתוכות (159 crops כבר ב-assets, WIP v45-v52)
- תוצאה: האפליקציה מציגה sml_pXX_X.jpg במקום page_XX.jpg לכל 170 מוצרי חוליות
- תיקוני gate-32 (spec_assets_test 0→53 PASS):
  - `_huliotImageFor` כעת מחזיר page-fallback (לא null) כשאין crop ספציפי
  - p24 אטם (seal): routing מוחזר null → page_24.jpg (sml_p24_a.jpg לא נוצר ב-crop_huliot.py)
  - `_missingSpecs` set: 11 קבצי spec שלא נוצרו (p11_b, p30_d, p32_a, p36_b, p38_a, p39_b/c, p40_a/c/41_c, p42_a/b/c/d)

### lib/data/product_images.dart — 2026-06-08T21:04:22+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/semanticLabel == null/false/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/product_image_a11y_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.
### 2026-06-09 — מסך-בית חכם / מחיקת 'הכל' (UI-wiring)
- מוטציה 1: שינוי `catalogSectionProvider` ברירת-מחדל `'בית'`→`'מאתר'` → `hard_tests "default catalog landing"` אדום (Expected 'בית', Actual 'מאתר') ✅ נתפס; שוחזר.
- מוטציה 2: הסרת תיקון ה-overflow (`Flexible`/`Expanded` ב-_MiniTile/_SmartTreeCard) → robustness 1/12 RenderFlex overflowed אדום ✅; שוחזר.
- כיסוי: widget_test "בית" smart-home shows wired section blocks · robustness 1/12/18 render · hard_tests default-landing.

### 2026-06-09 — מסך-הבית מסונכרן-הגדרות (UI-wiring)
- מוטציה 1: קיבוע `crossAxisCount: 4` (התעלמות מ-`gridColumns`) → הבית לא מגיב לעמדות-רשת בהגדרות (אומת ויזואלית: gridColumns=2 צריך 2 עמודות) ✅; שוחזר.
- מוטציה 2: `childAspectRatio` במקום `mainAxisExtent` → ב-2 עמודות אריחים ענקיים (חצי-מסך-ריבועי) ✅ נתפס ויזואלית; שוחזר ל-`mainAxisExtent` קבוע.
- מוטציה 3: החזרת `reverse: true` → גלילה הפוכה ב-RTL ✅; שוחזר.
- כיסוי: אימות ויזואלי חי (אין טסט-יחידה ל-layout-metrics; נבדק בעין על :5556).

### 2026-06-09 — server-S2 (rebuild): cache-pattern base (`firestore_cached_repo`)
- מוטציה (ידנית — הסקריפט flaky על restore): נטרול עדכון-ה-cache האופטימי ב-`upsert` (`_cache = _sorted(next)` → `_sorted(_cache)`) → `firestore_cached_repo_test` **-5 אדום** ✅ נתפס; שוחזר byte-clean (0 markers) → **+20 ירוק**.
- כיסוי: 20 טסטים על fake-source — seed-ראשוני · snapshot מחליף+notify · doc פגום מדולג · optimistic מיידי (assert סינכרוני) · כשל-כתיבה לא משחית/זורק · replaceAll/resetToSeed/removeById · empty-ראשון≠מאוחר · roundtrip מיפוי+סדר · provider=local בלי Firebase. (נבנה-מחדש אחרי שה-restart גלגל את הקומיט הלא-דחוף.)

### 2026-06-09 — server-S3 (rebuild): גל הנחיל ×5 (`stock_firebase` כנציג)
- מוטציה (ידנית): נטרול flip-המיקום ב-`move` (`'site' : 'warehouse'` → `'warehouse' : 'warehouse'`) → `stock_firebase_repo_test` **-2 אדום** ✅ נתפס; שוחזר byte-clean (0 markers) → **+10 ירוק**.
- כיסוי-גל: 46 טסטים חדשים (customers 9 · stock 10 · site 13 · finance 11 · catalog-guard 3) — fake-sources, אפס deps; provider=local בלי Firebase בכל דומיין; ה-base עצמו mutation-verified ב-S2.
### 2026-06-10 — lib/logic/input_validators.dart (חדש · #64 נחיל)
- מוטציה: `^05\d{8}$` → `^05\d{7,8}$` (קבלת נייד בן 9 ספרות) → `test/input_validators_test.dart` אדום ("mobile — 9 digits (too short) is invalid": Expected false, Actual true) ✅ נתפס.
- שחזור: regex הוחזר byte-exact; הרצה חוזרת 27/27 ירוקה ✅.
- מסקנה: הבדיקה חזקה — מכסה אורך/קידומת/תווים לכל 5 הוולידטורים (27 cases).
- `lib/data/legal_texts.dart` (חדש · #26): const-strings בלבד (תנאי-שימוש/פרטיות) — אין לוגיקה למוטט; מכוסה עקיף ע"י analyze + legal_screen רנדור.

### 2026-06-10 — server-S1+S4: Auth + Real-time (`auth_state` כנציג)
- מוטציה (ידנית): הסרת אימות-תפקיד-מוכר ב-`rolesFromClaims` (`single is String && known.contains(single)` → `single is String`) → `auth_state_test` **-1 אדום** ✅ נתפס; שוחזר byte-clean → **+24 ירוק**.
- כיסוי-גל: 59 טסטים חדשים (auth_state+login_sheet 41 · chat_firebase 10 · realtime_wiring 8) — fake gateway/sources, אפס deps; ללא-Firebase = byte-identical להיום (signed-out picker · מנועים local).

### 2026-06-10 — server-S5/S6/S8/S9: גל-הסגירה (`offline_order_queue` כנציג)
- מוטציה (ידנית): שבירת FIFO ב-`drainQueue` (`pending.first` → `pending.last` = LIFO) → `offline_order_queue_test` **-2 אדום** ✅ נתפס; שוחזר byte-clean → **+9 ירוק**.
- כיסוי-גל: 25 טסטי-flutter חדשים (queue 9 · push_state 15 · S9.3-pin ב-cache-repo 1) + **85/85 rules-emulator** (S5, רץ אמת מול ה-emulator) + **53/53 functions selftest** (S8, כולל אימות bit-for-bit של dartStringHashCode מול dart run).

### 2026-06-10 — server-gate: דגל-בקאנד default-OFF (`backend.dart`)
- מוטציה (ידנית): הפיכת ברירת-המחדל של הדגל ל-true (`bool.fromEnvironment('USE_FIREBASE_BACKEND', defaultValue: true)`) → `backend_flag_test` **-1 אדום** ✅ נתפס; שוחזר byte-clean → **+1 ירוק**.
- כיסוי: `backend_flag_test` נועל את ברירת-המחדל (demo/_local ללא-define, ללא-Firebase) — ה-live נשאר דמו עד הדלקה מפורשת. 11 אתרי-switch דרך `useFirebaseBackend`.
### 2026-06-10 — lib/data/board_accounts_local.dart + lib/state/board_auth.dart (חדשים · #65 נחיל-לוחות)
- מוטציה: קוד-הכניסה של ran שונה '1111'→'9999' → `test/board_auth_test.dart` אדום (4 בדיקות: login-success/persist/case-insensitive/race-guard — Expected session, Actual null) ✅ נתפס.
- שחזור: byte-exact; הרצה חוזרת 8/8 ירוקה ✅.
- מסקנה: בדיקות-הזהות חזקות — מכסות הצלחה/כישלון/persist/דמו/logout/קוד-החלפה.
- `lib/data/chat_seeds.dart` (חדש · #70/#75): seed-בלבד (שיחות audience) — מכוסה עקיף ע"י בדיקות ה-chat הקיימות + analyze.

### 2026-06-10 — worker-v2 (לוגיקה חדשה ב-lib/state + lib/data/task_skus_local)
- באג-אמיתי שנתפס ע"י בדיקת-שמירה (לא מוטציה מלאכותית): vacation_requests — שתי בקשות באותה אלפית-שנייה קיבלו אותו id (web=דיוק-ms) → החלטה אחת אישרה את שתיהן; הבדיקה 'decision touches ONLY the given id' אדומה → תוקן `_seq` מונוטוני → ירוקה. תיעוד כ-mutation-equivalent (fault אמיתי→red→fix→green).
- task_skus_local.dart: seed-בלבד (מיפוי משימה→מק"טים, DEMO-SEED) — מכוסה ע"י רנדור 'מה להביא' + analyze.

### 2026-06-11 — uid-migration A2+A3 (נחיל Phase A · builder+supervisor)
- **A2 — `currentUidProvider` (`lib/state/auth_state.dart`):** מוטציה — `return ref.watch(authStateProvider).user?.uid` → `return null` → `auth_state_test` קבוצת 'currentUidProvider — A2' **אדום** (signed-in: Expected 'u-42' / Actual null, שורה 422) ✅ נתפס; שוחזר byte-clean → ירוק.
- **A3 — `Order.contractorUid` (`lib/state/orders_engine.dart`):** מוטציה (supervisor) — שבירת ה-preservation ב-copyWith `contractorUid: contractorUid,` → `contractorUid: ''` → `orders_uid_a3_test` 'a stage advance (copyWith) keeps the contractor uid' **אדום** (Expected 'u-9' / Actual '') ✅ נתפס; שוחזר byte-clean (grep-count חזר ל-3) → +8 ירוק.
### 2026-06-11 — lib/data/chat_seeds.dart (#83 threads-ספק · נחיל-קנוני)
- מוטציה: audience 'store'→'worker' על thread-ספק → **שרדה** (חור-כיסוי!) → נוספה בדיקת-נעילה (sys_chat_test: 4 ids חייבים audience 'store') → מוטציה חוזרת **נתפסה** (אדום) → שוחזר → ירוק. לקח: seed-fields שמשפיעים-על-נראות חייבים נעילת-בדיקה.
### 2026-06-11 — personal-v2 #86/#87 (נחיל קנוני · orchestrator)
- **`lib/data/supplier_data.dart` — `deliveredRevenue`:** חור-כיסוי נמצא (אפס בדיקות לשדה) → נוספה בדיקה ל-t9 ('deliveredRevenue counts ONLY delivered orders'). מוטציה — הוספת `|| transit` לסינון → **אדום** (seed: BS-1039 ב-transit, ציפייה 0) ✅ נתפס; שוחזר → 12/12 ירוק.
- **`lib/state/persona_fulfillment.dart` — `courierUser` fromJson:** מוטציה — `j['cu']…` → `null` קבוע → `persona_fulfillment_test` **אדום** (Expected 'noam'/Actual null, round-trip+stamp) ✅ נתפס; שוחזר → 20/20 ירוק.
- **`lib/state/vacation_requests.dart` — back-compat `role`:** מוטציה — ברירת-מחדל decode `'worker'`→`'courier'` → `vacation_requests_test` **אדום** (Expected 'worker'/Actual 'courier' — legacy חייב עובד) ✅ נתפס; שוחזר → 11/11 ירוק.

### 2026-06-11 — חיבור הגדרות-תצוגה בקטלוג (נחיל גל-2 מנה-1)
- **`lib/state/catalog_settings.dart` — `priceWithVat`:** מוטציה — `base*(1+kVatRate)` → `base` קבוע → `catalog_price_units_settings_test` **אדום** (2 assertions: Expected 117/'~₪117', Actual 100/'~₪100') ✅ נתפס; שוחזר byte-clean (cp) → 16/16 ירוק.

### 2026-06-11 — מיון-קטלוג (נחיל גל-2 מנה-2)
- **`catalog_screen.dart`/`catalog_settings.dart` — `sortCatalogProducts` nameAZ:** מוטציה — היפוך ה-comparator (descending) → `catalog_sort_alerts_settings_test` nameAZ **אדום** (['B-200','C-300','A-100'] ≠ ['A-100','C-300','B-200']) ✅ נתפס; שוחזר (cp) → 16/16 ירוק.

### 2026-06-11 — חיבור התראות in-app (נחיל גל-2 מנה-3)
- **`lib/state/worker_notifs.dart` — `boardFeedEnabled`:** מוטציה — זרוע-העובד `=> true` קבוע → `notif_settings_wiring_test` **אדום** (3: personaWorker/master/restore gating) ✅ נתפס; שוחזר (backup) → 14/14 ירוק.

### 2026-06-11 — כלי-AI על דאטה אמיתי (נחיל גל-4 · supervisor)
- **`lib/logic/ai_hub_logic.dart` — `computeStockForecast`:** מוטציה — fold-הצריכה `+ li.qty` → `- li.qty` → `ai_hub_compute_test` **אדום** (5 assertions: rate/urgent/span/on-hand/aggregate) ✅ נתפס; שוחזר (cp, md5 חזר) → 14/14 ירוק.

### 2026-06-12 — הכנת-זהות A8 (נחיל)
- **`lib/state/sys_chat.dart`/`chat_firebase.dart` — `fromUid`:** מוטציה — שבירת כתיבת/round-trip של fromUid → `chat_uid_a8_test` **אדום** (Expected 'u-7'/Actual null) ✅ נתפס; שוחזר → ירוק.

### 2026-06-12 — מדריך users lookup A7 (נחיל)
- **`lib/data/repositories/users_lookup.dart` — predicate-הטלפון:** מוטציה — `== phone` → `!= phone` → `users_lookup_a7_test` **אדום** (4: hit→uid-שגוי · miss→החזיר-uid · role-narrow→null) ✅ נתפס; שוחזר (cp) → 10/10 ירוק.

### 2026-06-13 — בעלות-הזמנה A4-A6 (נחיל)
- **`firestore.rules` — no-steal (`claimOnlySelf`/`unassignedOrMine`):** מוטציה (emulator) — נטרול ל-true → 2 steal-tests **אדום** (25/2) → שוחזר → 27/0.
- **`lib/state/orders_engine.dart` — `claimStore` no-steal:** מוטציה — הסרת ה-guard → 'store אחר לא יכול לגנוב' **אדום** (Expected store-a/Actual store-b) → שוחזר.

### 2026-06-13 — server-swap זהות-לוח seed→Firebase (אני, לא נחיל)
- **`lib/state/board_auth.dart` — `boardSessionFromAuthSnapshot` (helper טהור):** מוטציה — `return null` קבוע בראש ה-helper (מנטרל את כל הגזירה) → `board_auth_server_test` **אדום** `+5 -7` (7 בדיקות שמצפות session: store-claim/each-role/multi-role/no-displayName/sign-in/אינווריאנט/sign-out נפלו; 5 שמצפות null נשארו ירוקות) ✅ נתפס; שוחזר byte-מדויק (cp מגיבוי, **לא** git checkout — שלא לאבד את SW2/SW3) → 12/12 ירוק.

### 2026-06-13 — A9 צ׳אט participantUids (נחיל)
- **`lib/state/sys_chat.dart` — `chatThreadVisibleToUid` (helper טהור):** מוטציה — הסרת סעיף empty-is-visible (`participantUids.isEmpty || participantUids.contains(uid)` → `participantUids.contains(uid)`) → `chat_uid_a9_test` 'an EMPTY participantUids is VISIBLE to anyone (legacy/un-migrated)' **אדום** (Expected: true / Actual: \<false\>, `+5 -1`) ✅ נתפס; שוחזר (cp מגיבוי `/tmp/A9_sys_chat.dart.bak`, **לא** git checkout — שלא לאבד את שדה ה-A9 הלא-מקומט) → `+6` ירוק.
- **`firestore.rules` — `chatThreads` read (membership על participantUids):** מוטציה (emulator) — החלשת ה-read ל-`if isSignedIn();` (הסרת `request.auth.uid in resource.data.get('participantUids', [])`) → 3 בדיקות-chat **אדום** (`a NON-member is DENIED` · `a display ROLE in participants never gates` · `a LEGACY thread matches no uid` — כולן 'Expected request to fail, but it succeeded', chat.test.js:95) → 39/3 fail · שוחזר (cp מגיבוי `/tmp/A9_firestore.rules.bak`) → **42/42/0** ירוק.
- **defect שתוקן (לא מוטציה — באג-אמת):** `rules_test/chat.test.js` החדש חלק `PROJECT_ID = 'demo-buildsmart'` עם `orders.test.js`; `node --test` מריץ את שני הקבצים **במקביל** מול emulator יחיד, ו-`clearFirestore` של קובץ אחד מחק את ה-docs שזרע השני באמצע-בדיקה → ה-`get()` החוצה-מסמך של חוקי chatMessages על thread-האב נכשל ("Service call error") → כשל פלאקי (1-2) בחיוביים תלויי-seed. תיקון: project-id ייעודי `demo-buildsmart-chat` (מבודד namespace, אפס-נגיעה ב-orders). chat-לבד 7/7 דטרמיניסטי; combined 42/42/0 ב-3/3 ריצות.

### 2026-06-13 — A14 צ׳אט last-mile: אכלוס participantUids אמיתי (נחיל)
- **הפער שנסגר:** A9 הוסיף את `participantUids` כשדה inert (מעולם לא אוכלס → תמיד ריק → "ריק=גלוי-לכולם" → אפס בידוד-אמיתי). A14 מאכלס אותו באמת: `ChatEngineNotifier.ensureParticipantUids` פותר את **האיחוד** של uids-התפקידים (A7 `uidsByRole`) + uid-השולח וחותם על ה-thread, gated ב-`uidScoped` (default `kUidScopedQueries`).
- **`lib/state/sys_chat.dart` — `ensureParticipantUids` (אכלוס-האיחוד):** מוטציה — שבירת לולאת-האיחוד (`union.addAll(await lk.uidsByRole(role.name))` → `await lk.uidsByRole(role.name);` בלי addAll, כלומר זריקת ה-uids של התפקידים) → `chat_uid_a14_populate_test` **`+3 -3` אדום**: 'flag ON: a send STAMPS the union' (Expected Set{uid-c,uid-s1,uid-s2} / Actual Set{uid-c} — רק השולח שרד) · 'ensureParticipantUids on thread OPEN' (אותו {uid-c}) · 'VISIBLE to a member, NOT to a non-member' (Expected true/Actual false — חבר-החנות uid-s1 נשמט → ה-rules-twin מבודד אותו, מוכיח שהאכלוס הוא מה שמניע את הבידוד האמיתי) ✅ נתפס. נעילות אפס-הרגרסיה (flag-OFF stays empty) + resolve-once + compile-time-OFF נשארו ירוקות (המוטציה נגעה רק באיחוד).
- שחזור: `cp /tmp/A14_sys_chat.dart.bak lib/state/sys_chat.dart` (**לא** git checkout — שלא לאבד את קוד-ה-A14 הלא-מקומט); md5 חזר ל-`efc72d1dff51673d130252879fe8c5b4` → הרצה חוזרת **+6 ירוק**.
- **`lib/data/repositories/chat_firebase.dart` / `chat_repository.dart` — `setParticipantUids`:** seam-נתיב-השרת לחתימת ה-head (toDoc של A9 כבר persist את participantUids כשלא-ריק). מכוסה עקיף ע"י ההוכחה הנ"ל (הנתיב-המקומי) + בדיקות-ה-chat הקיימות (`chat_uid_a9_test` toDoc/fromDoc) + analyze. הנתיב-המקומי (engine IS the store) הוא מה שהבדיקות מריצות (Firebase-free).
- **emulator:** ללא שינוי-rules → 42/42/0 (אומת מחדש; לא נדרשו בדיקות-rules חדשות).

### 2026-06-13 — שיחות/וידאו V1+V2 (calls/video): כפתורי 📞/💬 + הסתרת עץ-הגדרות-מת (אני)
- **`lib/logic/input_validators.dart` — `waMeDigits` (helper טהור, נרמול טלפון→wa.me):** מוטציה — הפלת המרת ה-0→972 (`digits = '972${digits.substring(1)}';` הוערה החוצה) → `input_validators_test` **`+31 -3` אדום**: 'waMe — Israeli local 0501234567 → 972501234567' (Expected '972501234567' / Actual '0501234567') · 'waMe — separators…' (אותו) · 'waMe — does NOT double-prefix…' (אותו) ✅ נתפס. נעילות אפס-הרגרסיה (empty→'' · already-972 untouched · 00-prefix) נשארו ירוקות (המוטציה נגעה רק בענף-ה-0-המקומי). שחזור: `cp /tmp/input_validators.dart.bak lib/logic/input_validators.dart` (**לא** git checkout); md5 חזר ל-`1d2bd4145ffe5ad25876a31904d90de6` → הרצה חוזרת **+34 ירוק**.
- **`lib/data/search_index.dart` — הסרת עץ 'הגדרות שיחות' המת (V2):** הוסר ה-entry העליון (`title: 'הגדרות שיחות'`) + כל תת-העץ (~40 leaves: שיחות-וחיווי/אישורי-קריאה/חיווי-הקלדה/התראות-שיחה/צלצול-שיחה-נכנסת/מדיה-ושמע/דחיסת-וידאו/פרטיות/גיבוי-וייצוא/שפה/עסקיות/בוט/ארכיון). נעול ע"י `call_settings_hidden_test` (8 כותרות-מת נעדרות + אפס breadcrumb תחת 'הגדרות שיחות' + ה-entry 'שיחות' של הצ׳אט-האמיתי **נשמר** + 3 עצי-הגדרות-שכנים נשמרים). אין helper חדש בקובץ זה → לא נדרשה מוטציה ייעודית (זו data-list); הבדיקה היא ה-guard הביצועי לבייטים.

### 2026-06-13 — order-card 📞/💬: customerPhone על ההזמנה (V1 last-mile · נחיל)
- **הפער שנסגר:** V1 (8709129) נתן `ContactActions` על chat + כרטיסי-פרופיל, אבל ל**כרטיס-ההזמנה** לא היו כפתורים — אף order-model לא נשא טלפון (Order/SysOrder חשפו רק `who`=שם-תצוגה). הוחלט (בעל-המוצר): על כרטיס-הזמנה ה-📞/💬 מגיעים ל**מי שהזמין** (הקבלן). שדה additive `Order.customerPhone` (default `''`, כתיבה-מוגנת כמו `contractorUid`/`storeUid`) ← נחתם ב-checkout (`store_screen` = `userProfileProvider.contact`) → מוקרן ל-`SysOrder.customerPhone` (`sys_orders._toSysOrder`). **לא flag-gated** — ה-default-הריק + empty-guard של ContactActions הם אפס-הרגרסיה (seed/legacy → אין כפתורים).
- **`lib/state/orders_engine.dart` — `Order.fromJson` קריאת `customerPhone`:** מוטציה — `customerPhone: (j['customerPhone'] as String?) ?? ''` → `customerPhone: ''` קבוע (זריקת הקריאה) → `orders_engine_test` 'Order.customerPhone … a phone is WRITTEN and round-trips losslessly when non-empty' **אדום `+26 -1`** (Expected '050-123 4567' / Actual ''); נעילות אפס-הרגרסיה (EMPTY omitted · fromJson defaults '' · copyWith preserves · placeOrder stamps/defaults) נשארו ירוקות (המוטציה נגעה רק בקריאה-כשקיים) ✅ נתפס. שחזור: `cp /tmp/orders_engine.dart.bak lib/state/orders_engine.dart` (**לא** git checkout); md5 חזר ל-`3bf5bdaa4f54e16ffa87a44e84f9fb6e` → הרצה חוזרת **+27 ירוק**.
- **`lib/data/repositories/orders_firebase.dart` / `orders_local.dart` / `orders_repository.dart` — חתימת `placeOrder` + toDoc/fromDoc:** השדה עבר דרך כל ה-impls (guarded-write `if (o.customerPhone.isNotEmpty)` ב-toDoc · default-read ב-fromDoc) מירור מדויק ל-`contractorUid`/`storeUid`. מכוסה ע"י `orders_uid_a3_test` קבוצת customerPhone (Firestore shape: WRITTEN+round-trip · EMPTY omitted · fromDoc defaults '') + analyze.
- **test-doubles שתוקנו לשינוי-החתימה (האנטי-דפוס החוזר):** `_RecordingOrdersRepo` (`offline_order_queue_test.dart`) + `_SpyOrders` (`site_firebase_repo_test.dart`) — שניהם `implements OrdersRepository`, הוסף להם הפרמטר `String customerPhone = ''` (ל-recording גם `customerPhone: customerPhone` ב-Order שהוא בונה). analyze 0-errors תפס שהם חייבים עדכון; שניהם ירוקים.
- **gate:** `flutter analyze` (כל הקבצים הנגועים) — 0 errors/warnings (רק info קיימים-מראש; אפס info חדש). `flutter test` מלא — **+2233 All tests passed** (היה +2222; +11: order_card_contact_actions +2 · engine customerPhone +6 · a3 customerPhone +3). `flutter build web --release` — ✓ Built. לוגיקת בעלות-הזמנה (A4-A6/A14 claim/scope/uid) **לא נגעתי** — customerPhone שדה עצמאי.

### 2026-06-14 — 4 כפתורים-מתים/מזויפים → התנהגות-אמת (ביקורת-launch · נחיל)
4 fixes; מוטציה מלאה הורצה על FIX#1 (share), שאר ה-3 מכוסים ע"י בדיקות-effect ייעודיות.
- **FIX#1 (share) · `lib/screens/store_screen.dart` — טקסט-השיתוף ב-`_CartActionsRow`:** מוטציה — `final text = 'סל BuildSmart:\n$items\n\nסה״כ: ₪$total';` → `final text = 'MUTANT';` (Edit) → `cart_share_test` 'tapping שתף hands the cart summary to the share seam' **אדום** (`Expected: contains 'מלט' / Actual: 'MUTANT'`) ✅ נתפס — הבדיקה מוכיחה שטקסט-הסל-האמיתי זורם ל-seam, לא no-op. שחזור: `cp /tmp/store_screen.bak.dart lib/screens/store_screen.dart` (**לא** git checkout) → הרצה חוזרת **2/2 ירוק**.
- **FIX#3 (order-now) · `lib/logic/ai_hub_logic.dart` — `computeStockForecast` קטיף emoji+unitPrice:** מכוסה ע"י `ai_hub_compute_test` 'carries REAL emoji + unit price from the latest order line' (יחידה: line אחרון 🪨/200÷4 → `emoji='🪨'`, `unitPrice=50`) + widget 'הזמן עכשיו adds the recommended item to the live cart' (טאפ → `smartCartProvider` גדל ב-1, line `ai-restock:PEX` עם emoji-אמת). שבירת הקטיף (החזרת `📦`/`0`) הייתה מפילה את היחידה — הבדיקה היא ה-guard הביצועי.
- **FIX#2 (favorite) · `lib/screens/smart_home_screen.dart` — onTap של אריח-מועדף:** אין helper טהור (UI-wiring) → מכוסה ע"י `favorite_tile_opens_sheet_test` (טאפ אריח-כוכב → `LipskeyProductSheet` נפתח; `onTap: () {}` המקורי היה מפיל את ה-`findsOneWidget`).
- **FIX#4 (PDF) · `lib/logic/finance_report_pdf.dart` — `buildFinanceReportPdf`:** מכוסה ע"י `finance_pdf_export_test` — הבונה-הטהור חייב להפיק bytes לא-ריקים שמתחילים ב-magic `%PDF` (שבירת ה-`addPage` הייתה מפילה את `isNotEmpty`/`'%PDF'`); ה-widget-test מוכיח שטאפ 'הדפסה' מזריק את אותו doc ל-`pdfPrintProvider` (seam). 
- **gate:** analyze (כל הקבצים הנגועים) 0 errors/warnings (4 קבצים-חדשים נקיים) · full-suite **+2241 All tests passed** (היה +2233; +8) · build web ✅ Built (printing נפתר web). pubspec.lock לא staged.

### 2026-06-14 — A13 קידום-שלב + אשראי → Cloud Functions callables (gated, אני)
- **הפער שנסגר:** `advanceOrderStage`+`computeCredit` קיימות בשרת (+טריגר `revertIllegalOrderStageWrite` שמחזיר כתיבת-stage ישירה לא-חוקית), אבל ה-client עשה direct optimistic Firestore writes + hash-אשראי מקומי שעוקפים את השרת+S5. A13 מחווט נתיב-callable **gated** מאחורי `kServerCallables` (default OFF, דפוס `kUidScopedQueries`/`uidScoped`), forward-ready ל-deploy+flip של הבעלים. seam חדש `OrderFunctionsGateway` (mirror ל-`AuthGateway`; `FirebaseOrderFunctionsGateway` פותר `FirebaseFunctions.instanceFor(region: me-west1)` עצלן, מתרגם `FirebaseFunctionsException`→ניטרלי). OFF + provider-gateway null מחוץ ל-live-backend = byte-identical.
- **`lib/state/orders_engine.dart` — `_advanceViaCallable` (החלת ה-`{to}` הקנוני של השרת):** מוטציה — `remote.applyServerStage(orderId, result.to)` → `result.from` (החלת השלב-הישן במקום החדש) → `orders_credit_a13_callable_test` 'flag ON: advance INVOKES advanceOrderStage … applies the server's {to} LOCALLY' **אדום `+0 -1`** (Expected: 'preparing' / Actual: 'new' — השלב לא התקדם). נעילות OFF (direct set) + FunctionsException + credit נשארו ירוקות (המוטציה נגעה רק בהחלה-המקומית של ה-advance). ✅ נתפס. שחזור: `cp /tmp/A13_oe_final.bak lib/state/orders_engine.dart` (**לא** git checkout — שלא לאבד את קוד-ה-A13); md5 חזר ל-`7ab77ca974d951979977414a200e55b4` → הרצה חוזרת **+8 ירוק**.
- **מוטציה שנייה (נעילת ה-tension optimistic↔callable) · `advance`:** הוספת `r.advance(orderId)` בענף-ON (כלומר גם יורה את ה-direct write שהטריגר היה מחזיר) → אותו test **אדום** (`Expected: empty / Actual: [BS-1042…]` על `src.sets` — הוכחה בייט-לבייט ש-ON אסור שיירה `set` ישיר). שוחזר → ירוק. זו ההוכחה שה-test נועל באמת את "ה-callable הוא הכתיבה הקנונית; ה-client לא יורה direct set".
- **`lib/data/repositories/customers_local.dart`/`customers_firebase.dart` — `computeCredit` (נתיב-אשראי):** gated זהה; ON→callable `computeCredit({name})`, OFF→גזירה-מקומית זהה לדשבורד (`contractorCredit`+spend-fold+`pct`/`balance`), FunctionsException→fallback מקומי (בלי לזייף). מכוסה ע"י אותו test (ON-credit מזמן+מחזיר server figures · OFF-credit local זהה+callable-לא-נקרא · FunctionsException→fallback · default-OFF). ה-`creditLimit(name)` הסינכרוני (נתיב-הדשבורד) **לא נגעתי** — אפס-רגרסיה.
- **`lib/data/repositories/firestore_cached_repo.dart` — `upsertLocalOnly`:** תאום LOCAL-only ל-`upsert` (cache+notify, **בלי `set`**) — הנתיב שבו הכתיבה-הקנונית נעשית במקום-אחר (ה-callable). `lib/data/repositories/orders_firebase.dart` — `applyServerStage` (stage-only מעליו). `lib/data/repositories/backend.dart` — ה-flag. `lib/data/repositories/customers_repository.dart` — מתודת-interface `computeCredit` אדיטיבית.
- **gate:** `flutter analyze` (כל ~8 הקבצים הנגועים + ה-test) — **0 errors/warnings**; אפס info-lints חדשים (אומת מול HEAD: `firestore_cached_repo` 82/103 + `orders_engine` 27/57/219/243 קיימים-מראש). `flutter test` מלא — **+2260 All tests passed** (היה +2252; +8). `flutter build web --release` — ✓ Built. לוגיקת uid/chat-message **לא נגעתי**. (הערה: ה-codebase בסגנון-formatter ישן; `dart format` היה מעצב-מחדש קוד-קיים → שוחזר ל-HEAD ושוכתב בסגנון-המקור, diff = additions בלבד.)

## A14 — צילומי-תמונה → R2 upload דרך `getUploadUrl` (gated, אני) — 2026-06-14

- **הפער שנסגר:** כל תמונה (POD/before-after/פרופיל/לוגו/תעודה) = `data:…;base64` data-URL ב-localStorage (~1.5MB, ללא sync); ה-callable `getUploadUrl` (`functions/src/r2.ts`, presigned-PUT ל-R2) קיים אבל ה-client לא קרא לו. A14 מחווט נתיב-העלאה **gated** מאחורי `kCloudPhotos` (default OFF, נפרד מ-`kServerCallables`), forward-ready ל-provision+deploy+flip של הבעלים. seam חדש `UploadFunctionsGateway` (mirror ל-`OrderFunctionsGateway`; `FirebaseUploadFunctionsGateway` פותר Functions עצלן, מתרגם `FirebaseFunctionsException`→ניטרלי) + seam שני `PhotoHttpPut` (ברירת-מחדל `http.put`). חוזה: השרת מחזיר `{url,key,…}` (אין public-URL בחוזה); ה-publicUrl מורכב `{kImageBaseUrl}/{key}`.
- **`lib/services/task_photo.dart` — `uploadCapturedPhoto` (החזרת ה-URL הציבורי על 2xx):** מוטציה — `return target.publicUrl;` → `return target.uploadUrl;` (אחסון ה-presigned-PUT URL במקום הציבורי) → `cloud_photos_a14_upload_test` **`+10 -2` אדום**: 'ON: a capture INVOKES getUploadUrl … stores the PUBLIC url' (Expected `https://pub-test.r2.dev/pod/u/9-photo.jpg` / Actual `https://r2.example/put/k1?sig=AAA`) + 'uploadCapturedPhoto … publicUrl on a 2xx' (Expected publicUrl / Actual upload-url) ✅ נתפס. נעילות OFF (byte-identical) + 3 ה-fallbacks (getUploadUrl-throw/PUT-403/PUT-throw) + gif + display נשארו ירוקות (המוטציה נגעה רק באחסון-ה-URL בנתיב-ה-2xx). שחזור: `cp /tmp/task_photo.dart.bak lib/services/task_photo.dart` (**לא** git checkout — שלא לאבד את קוד-ה-A14) → הרצה חוזרת **+12 ירוק**.
- **קבצים נגועים (lib/services|lib/state|lib/data):** `lib/services/task_photo.dart` (נתיב-העלאה + seams + gate) · `lib/data/repositories/upload_functions.dart` (חדש — ה-seam) · `lib/data/repositories/backend.dart` (ה-flag `kCloudPhotos`) · `lib/widgets/photo_viewer.dart` (`imageProviderForRef`/`showFullPhotoRefDialog`/`isHttpPhotoRef`) + ~12 אתרי-רינדור (screens). `lib/state/persona_fulfillment.dart` — **לא** נגעתי (ה-side-map שומר את ה-String כמו-שהוא; ON מאחסן https, OFF מאחסן base64 — אותו mechanism).
- **gate:** `flutter analyze` (כל הנגועים) — **0 errors** (info/warning קיימים-מראש בלבד). `flutter test` מלא — **+2272 All tests passed** (היה +2260; +12). `flutter build web --release` — ✓ Built. pubspec.lock **לא** staged. לוגיקת uid/chat/orders-callable **לא נגעתי**.
### 2026-06-14 — גל-D פוליש (#98 · נחיל אמיתי)
- **`lib/state/vacation_requests.dart:132` — back-compat decode של role:** מוטציה — `: 'worker'` → `: 'courier'` (ברירת-מחדל ל-payload ישן בלי 'role'). הבדיקה החדשה 'P-12 worker filter — an OLD payload without role is counted as the worker's (back-compat)' **אדומה** (Expected ['vac-legacy-demo'] / Actual []) + #86.3 back-compat האדים גם → ✅ נתפס; שוחזר byte-clean → 13/13 ירוק.
- **כיסוי כן:** סינון-המסך של P-12 (worker_forms_screen.dart, r.role=='worker') מכוסה רק עקיפות — ה-unit-test משכפל את ביטוי-הסינון ומאמת את מודל-ה-role/back-compat שעליו הוא נשען, לא קורא מה-widget. דפקט-המודל (back-compat) כן נתפס במוטציה; רגרסיה בשורת-המסך עצמה תיתפס רק ב-widget-test ייעודי (לא נכתב — פוליש).

## podSignature / strokesToPngDataUrl — pad-חתימת-POD אמיתי — 2026-06-14
- **קובץ:** `test/signature_pad_test.dart` (חדש) · helper חדש `strokesToPngDataUrl` (`lib/widgets/signature_pad.dart`).
- **מה עושה:** נועל ש-strokes אמיתיים → PNG data-URL לא-ריק (PNG-magic), dot→חתימה, pad-ריק→**null** (אין זיוף), ושה-save פולט data-URL לא-ריק / מושבת כשריק.
- תקלה שהוזרקה: encode-success `return 'data:image/png;base64,${base64Encode(bytes)}'` → `return null`.
- תוצאה: **אדומה ✅** — 4 נכשלו ('Expected: not null' · preview/save/dot). שוחזר `cp /tmp/sig.bak` (**לא** git checkout) → **+8 ירוק**.
- מסקנה: ה-encode load-bearing; pad-ריק→null אמיתי. אימות-orchestrator **fast-mode** (ממוקד + מוטציה-ממוקדת; הסוויטה המלאה ב-pre-push build-gate).

## גל H2 — approve-back הדרכות (guard pending) — 2026-06-14
- **קובץ:** `lib/state/worker_trainings.dart:340` (ה-guard ב-`_decide`) · בדיקה `test/contractor_training_approval_test.dart`.
- **מוטציה:** הסרת שמירת-ה-guard — `if (t.id == id && t.status == kTrainingPending)` → `if (t.id == id)` (approve היה מאשר **כל** סטטוס, כולל recorded/rejected — דריסת ה-no-op).
- **תוצאה:** **אדומה ✅** — 'approve on a non-pending (recorded) training is a no-op' נכשל ('recorded stays recorded' · Differ at offset 0). שוחזר ה-guard ב-Edit (**לא** git checkout) → **+15 ירוק** (שני קבצי-H2: contractor_training_approval + contractor_certs).
- **מסקנה:** ה-guard `status == kTrainingPending` load-bearing — בלעדיו approve/reject היו מחיים החלטה סופית/דורסים סטטוס. ה-lifecycle הדו-כיווני (pending→approved/rejected, no-op אחרת) אמיתי ונעול.

## גל H3 — מדיניות מסמכים-נדרשים (normalized-exact, לא substring) — 2026-06-14
- **קובץ:** `lib/state/docs_readiness.dart:104` (ההצלבה ב-block-3 של `workerDocsReadiness`) · בדיקה `test/contractor_required_docs_test.dart`.
- **מוטציה:** `normalizeDocName(c.name) == key` → `key.contains(normalizeDocName(c.name))` (req מכיל cert — מלכודת-substring שממציאה סיפוק: דרישה 'בטיחות בגובה' היתה 'מסופקת' ע"י תעודת 'בטיחות' חלקית).
- **תוצאה:** **אדומה ✅** — 'a substring-only cert does NOT satisfy a longer requirement' נכשל (Actual: <true>). שוחזר ל-`==` ב-Edit (**לא** git checkout) → **+23 ירוק** (8 gate + 15 policy).
- **מסקנה:** ההצלבה normalized-exact load-bearing — לקח E2 (אין-המצאות) נעול גם בשער-הבטיחות; substring היה חוסם/משחרר עובדים על סמך התאמה-חלקית מזויפת.

## גל S — נוכחות employer-scope (בידוד קבלן↔עובד) — 2026-06-14
- **קובץ:** `lib/state/worker_attendance.dart:308` (פילטר `attendanceForEmployer`) · בדיקה `test/contractor_attendance_test.dart`.
- **מוטציה:** `if (d.employerId == employerId)` → `if (d.employerId != employerId)` (היפוך — הקבלן היה רואה את נוכחות כל-מי-שאינו-שלו).
- **תוצאה:** **אדומה ✅** — 4 טסטי-scope נכשלו (lands-in-roster · unstamped-excluded · clockOut-preserves · deterministic-order). שוחזר ל-`==` ב-Edit (**לא** git checkout) → **+7 ירוק**.
- **מסקנה:** בידוד-המעסיק load-bearing — הוא לב חיווט-קבלן↔עובד; היפוך-הפילטר דלף נוכחות חוצת-מעסיקים. שליחים מודרים-במבנה (חנות-נוכחות נפרדת), לא תלוי בפילטר הזה.

## גל G1 — בידוד מחזור-חיים: הצעת-עובד מול השלמה — 2026-06-14
- **קובץ:** `lib/state/tasks_engine.dart:636` (ה-guard ב-`approveProposal`) · בדיקה `test/contractor_task_proposal_test.dart`.
- **מוטציה:** הסרת ה-guard — `if (t == null || t.status != 'proposed')` → `if (t == null)` (approveProposal היה מאשר **כל** סטטוס, כולל review/pending → התנגשות עם מחזור-ההשלמה).
- **תוצאה:** **אדומה ✅** — 'GUARD: the proposal lifecycle and the completion lifecycle do NOT collide' נכשל. שוחזר ה-guard ב-Edit (**לא** git checkout) → **+5 ירוק**.
- **מסקנה:** ה-guard `status=='proposed'` load-bearing — מפריד את `approveProposal`(proposed→active) מ-`approve`(review→done); בלעדיו הצעת-עובד הייתה מאושרת במסלול-ההשלמה (כולל הענקת-מטבעות/קידום-הזמנה שגויים).

## גל G2 — גאנט: len floored at 1 (פריסה טהורה) — 2026-06-14
- **קובץ:** `lib/logic/tasks_gantt.dart:163` (`lenDays`) · בדיקה `test/contractor_task_gantt_test.dart`.
- **מוטציה:** `lenDays: t.days < 1 ? 1 : t.days` → `lenDays: t.days` (משימת days==0 קיבלה bar באורך 0 — נעלמת מהציר).
- **תוצאה:** **אדומה ✅** — 'a days==0 task still occupies one cell (lenDays floored at 1)' נכשל. שוחזר ב-Edit → **+15 ירוק**.
- **מסקנה:** ה-floor load-bearing — כל משימה משובצת תופסת לפחות תא אחד (אחרת בלתי-נראית בגאנט). הפריסה טהורה+דטרמיניסטית, **אין-המצאת-תאריך** (scheduledStart==null → unscheduled, לא bar).

## גל G3 — ליקויים: מסנן ה-kind (פריסה טהורה) — 2026-06-14
- **קובץ:** `lib/state/tasks_engine.dart:909` (`defectsProvider` kind filter) · בדיקה `test/contractor_defects_test.dart`.
- **מוטציה:** `if (t.kind == 'defect')` → `if (t.kind != 'defect')` (היפוך — defectsProvider החזיר משימות-רגילות במקום ליקויים).
- **תוצאה:** **אדומה ✅** — 4 טסטי-ליקויים נכשלו (createTask-defect · editTask · round-trip · proposeTask-defect). שוחזר ל-`==` → **+5 ירוק**.
- **מסקנה:** מסנן-ה-kind load-bearing. **+ תיקון-מפקח:** `_openDefect` חתם employerId מ-session ריק (תפקיד-מנהל) → ליקוי-קבלן נעלם מרשימתו; תוקן ל-`kDemoContractorId` (כמו `_TaskAuthorSheet`). [פער-מבחן ידוע: render-test של הגיליון תחת session-מנהל — parked עם שאר ה-widget-tests.]
## #C11 — Apple-readiness HIDE-pass (kHideUnderConstruction · kVisibleSearchIndex) — 2026-06-14
- **קבצים (lib/state|lib/data):** `lib/state/under_construction.dart` (חדש — הדגל `kHideUnderConstruction` + `kHiddenSearchTitles`) · `lib/data/search_index.dart` (getter חדש `kVisibleSearchIndex` שמסנן placeholder-titles · ה-const `kSearchIndex` נשאר verbatim). (UI: `_SectionTile` ב-4 מסכי-הגדרות · `ai_hub_screen` `_visibleTiles`/`visibleToolIds` · chats/persona_portal/courier_portal_tab/persona_picking_sheet/tasks_screen guards.)
- **תקלה שהוזרקה:** `kVisibleSearchIndex => kHideUnderConstruction ? […filtered] : kSearchIndex` שונה ל-`=> false // MUTATION` (כלומר תמיד מחזיר את הרשימה המלאה → 3 ה-titles ה-deferred דולפים לחיפוש החי).
- **תוצאה:** `apple_readiness_hide_pass_test` 'kHiddenSearchTitles are absent from kVisibleSearchIndex' **אדומה `+0 -1`** ✅ נתפס (Expected isEmpty / Actual contains 'התאמה משולשת'…). שוחזר `cp /tmp/search_index.dart.bak lib/data/search_index.dart` (**לא** git checkout — לשמר את קוד-ה-C11) → **`+1` ירוק**.
- **מסקנה:** ה-getter המסנן load-bearing; ה-hide הפיך (ה-const נשאר). gate: analyze 0-errors · full-suite +2300 · build web ✅.

## G4 — telemetry seam + installCrashlyticsHandlers (Crashlytics+Analytics, Firebase-gated) — 2026-06-14
- **קבצים (lib/state + lib/main):** `lib/state/telemetry.dart` (חדש — ה-seam `TelemetrySink`: `NoopTelemetrySink` no-op default + `FirebaseTelemetrySink` עצלן; `telemetryProvider` מגודר `useFirebaseBackend`; `TelemetryEvents`; extension `logError`) · `lib/main.dart` (`installCrashlyticsHandlers` `@visibleForTesting` — closures מוזרקות; הגוש המגודר `if (Firebase.apps.isNotEmpty)` מתקין `FlutterError.onError`/`PlatformDispatcher.onError` ומפעיל collection ב-`!kDebugMode`). אירועי-משפך ב-`store_screen.dart` (order_placed) + `manager_role_assign_sheet.dart` (role_assigned + app_error).
- **`lib/main.dart` — `installCrashlyticsHandlers` (חיווט handler-השגיאות):** מוטציה — הוסר `recordFlutterError(details);` מתוך `FlutterError.onError` (כלומר שגיאת-framework מוצגת ב-`presentError` אבל **לא** מדווחת ל-Crashlytics).
- תוצאה: `telemetry_test` 'installCrashlyticsHandlers — Flutter framework error → recordFlutterError' **אדומה `+7 -1`** ✅ (Expected: a single recorded FlutterErrorDetails / Actual: []). שאר 7 (no-op-gate, forward-when-enabled, logError-compose, platform-async→recordError+true, debug-gate) נשארו ירוקים — המוטציה נגעה רק בנתיב-ה-framework.
- שחזור: `cp /tmp/main.dart.bak lib/main.dart` (**לא** git checkout — לשמר את קוד-ה-G4) → הרצה חוזרת **+8 ירוק**.
- מסקנה: ה-`recordFlutterError(details)` load-bearing — בלעדיו שגיאות-framework לא היו מגיעות ל-dashboard. ה-no-op gate נעול (provider=`NoopTelemetrySink` ללא-Firebase ⇒ demo byte-identical). gate: analyze 0-errors (כל הנגועים, אפס `Color(0xFF1A1A1A)` חדש) · full-suite +8 (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש) · build web ✅. pubspec.lock **לא** staged.

## F2 + G3 — App Check native (prod providers behind flag) + token-enforcement client — 2026-06-14
- **קבצים (lib/main + lib/data):** `lib/data/repositories/backend.dart` (flags חדשים `kAppCheckProd` default OFF + `kAppCheckRecaptchaSiteKey` default ריק) · `lib/main.dart` (helper טהור `appCheckProvidersFor({required bool prod})` `@visibleForTesting` המחזיר record `({AndroidProvider android, AppleProvider apple})` + גוש ה-App-Check הוזז לתוך `if (Firebase.apps.isNotEmpty)`, נייד בוחר providers דרך ה-helper, web מדולג אלא אם site-key, `setTokenAutoRefreshEnabled(true)` כש-prod). טסט חדש `test/app_check_providers_test.dart`.
- **`lib/main.dart` — `appCheckProvidersFor` (בחירת-providers):** מוטציה — ענף-ה-OFF `: (android: AndroidProvider.debug, apple: AppleProvider.debug)` שונה ל-`: (android: AndroidProvider.playIntegrity, apple: AppleProvider.appAttestWithDeviceCheckFallback)` (כלומר OFF מחזיר את ה-providers של prod → שובר byte-identical לדמו/dev).
- תוצאה: `app_check_providers_test` **אדום `+3 -2`** — 'OFF (default) → debug providers (BYTE-IDENTICAL to today)' + 'the live flag value selects the dev providers (pinned OFF)' (Expected `AndroidProvider.debug` / Actual `AndroidProvider.playIntegrity`) ✅ נתפס. ה-ON-test ('ON → playIntegrity + appAttestWithDeviceCheckFallback') נשאר ירוק — המוטציה נגעה רק בענף-ה-OFF.
- שחזור: `cp /tmp/main.dart.f2 lib/main.dart` (**לא** git checkout — לשמר את קוד-ה-F2) → הרצה חוזרת **+5 ירוק**.
- מסקנה: ענף-ה-OFF load-bearing — הוא ה-byte-identical-guard לדמו/dev (OFF חייב לבחור debug). ON=playIntegrity/appAttest נעול גם הוא. **G3 finding:** `activate(...)` לבדו מצרף את ה-App-Check-token אוטומטית לכל קריאת Firestore/Functions/Storage — אין עבודה per-call (`getToken`/`getLimitedUseToken` קיימים אך לא נדרשים בנתיב הרגיל). אכיפה (דחיית בקשות ללא-token) = Firebase console toggle = ממתין-לבעלים. **F2 ready, ממתין ל-F1 + רישום-קונסול.** gate: analyze 0-errors (6 info קיימים-מראש בלבד · אפס raw-color) · full-suite +2424 (ה-`-1` היחיד = `worker_reports_drilldown_test` baseline קיים-מראש) · build web ✅. pubspec.lock **לא** staged · נגעתי רק ב-main.dart+backend.dart.

## F5 — Android notifications hardening (channels + foreground display · `push_state.dart` · Firebase-gated) — 2026-06-14
- **קבצים (lib/state + android):** `lib/state/push_state.dart` (seam `LocalNotificationsGateway`: `FlutterLocalNotificationsGateway` עצלן default-null + `kPushChannels`/`pushChannelIdFor` טהורים; `localNotificationsGatewayProvider` מגודר `useFirebaseBackend && !kIsWeb`; `PushController._register` יוצר channels + מבקש הרשאת-13, `_handleForeground` מוסיף `show` על ה-channel הממופה — guarded+gated) · `android/app/src/main/AndroidManifest.xml` (POST_NOTIFICATIONS + 2 meta-data של FCM) · `res/values/strings.xml` (חדש — `default_notification_channel_id`=`bs_general`) · `res/drawable/ic_notification.xml` (חדש — vector צללית-לבנה `#FFFFFFFF`) · `pubspec.yaml` (`flutter_local_notifications: ^18.0.1`; **pubspec.lock לא staged**) · `test/push_state_test.dart` (+13 cases · fake `_FakeLocalNotifications`).
- **`lib/state/push_state.dart` — `pushChannelIdFor` (מיפוי type→channel, ה-load-bearing של תצוגת-ה-foreground):** מוטציה — ענף-`case 'order': return kOrdersPushChannelId;` שונה ל-`return kDefaultPushChannelId;` (כלומר הזמנה מנותבת ל-channel הכללי במקום ל-`bs_orders`).
- תוצאה: `push_state_test` **אדום `+26 -2`** — 'F5 — channel config (pure) pushChannelIdFor routes by data.type' + 'F5 — wired behaviour … a foreground push is RE-SHOWN as an OS notification on its channel' (שניהם Expected `'bs_orders'` / Actual `'bs_general'`) ✅ נתפס. כל שאר ה-F5 (channel-config, gating, denied/data-only/throwing, source-guard) + כל ה-S6 הקיים נשארו ירוקים — המוטציה נגעה רק במיפוי-ה-order.
- שחזור: `cp /tmp/push_state.dart.bak lib/state/push_state.dart` (**לא** git checkout — לשמר את קוד-ה-F5) → הרצה חוזרת **+28 ירוק**.
- מסקנה: `pushChannelIdFor` load-bearing — הוא ה-מקום-היחיד שממפה `data['type']` ל-channel; בלעדיו התראת-הזמנה היתה נוחתת על ה-channel הלא-נכון (המשתמש לא יכול היה למצקה ערוץ-הזמנות בנפרד). ה-gating נעול (provider=null ללא-Firebase/web ⇒ demo byte-identical — אפס init/prompt/show, ה-token נרשם בכל-זאת). **caveat נייד:** יצירת-channel/permission/tray-notification אמיתיים = on-device בלבד (לא headless); ה-fakes נועלים את הלוגיקה+הגייטינג, source-guard נועל את ה-manifest/res. **VAPID web push = ממתין-לבעלים; נייד = ממתין-ל-F1.** gate: analyze 0-errors (push_state+test) · XML well-formed · full-suite +2424 (ה-`-1` היחיד = `worker_reports_drilldown_test` baseline) · build web ✅. pubspec.lock **לא** staged · נגעתי רק ב-pubspec.yaml+AndroidManifest+res/**+push_state.dart (+טסט).

## A13-consumer — חיווט CONSUMER ל-computeCredit (תצוגת-אשראי-מנהל, gated) — 2026-06-14
- **קבצים (lib/screens + test):** `lib/screens/manager_dashboard_screen.dart` (provider חדש `customerCreditProvider` = `FutureProvider.family<CreditResult,String>` הקורא `customersRepositoryProvider.computeCredit(name)` + ה-wiring ב-`_CustomerDetailSheet`: `creditLimit = ref.watch(customerCreditProvider(c.name)).valueOrNull?.creditLimit ?? c.creditLimit`, המזין את row `מסגרת אשראי`, `livePct` ו-`balance`). טסט חדש `test/manager_credit_computecredit_consumer_test.dart` (+3, spy-repo + fake gateway). ה-`computeCredit` עצמו (repo/gateway/function) כבר היה — רק חובר ל-consumer.
- **`lib/screens/manager_dashboard_screen.dart` — row `מסגרת אשראי` (ה-load-bearing של חיווט-ה-consumer):** מוטציה — `row('מסגרת אשראי', '₪${_grouped(creditLimit)}')` שונה ל-`'₪${_grouped(c.creditLimit)}'` (כלומר ה-row מתעלם מהערך-הנפתר של `computeCredit` ומציג את ה-aggregate ה-SYNC במקום).
- תוצאה: `manager_credit_computecredit_consumer_test` **אדום `+2 -1`** — רק 'ON + a bound gateway: the rendered ceiling UPGRADES to the server-canonical figure' נכשל (Expected `₪88,000` / Actual ה-hash המקומי). שני ה-OFF-tests (seam-reached דרך spy-repo + no-flicker) נשארו ירוקים — המוטציה נגעה רק בנתיב ה-ON (הערך-הנפתר); OFF ממילא מציג את ה-מקומי.
- שחזור: `cp /tmp/manager_dashboard_screen.CURRENT.bak lib/screens/manager_dashboard_screen.dart` (**לא** git checkout — לשמר את קוד-החיווט) → הרצה חוזרת **+3 ירוק**.
- מסקנה: ה-`creditLimit` הנפתר (`valueOrNull?.creditLimit`) load-bearing — בלעדיו תצוגת-האשראי לעולם לא הייתה מציגה את הערך ה-server-canonical (ה-seam היה נשאר מת אף-על-פי שהוא בנוי). ה-gate ה-OFF נעול (repo `computeCredit` מחזיר את ה-derivation המקומית בלי רשת ⇒ demo byte-identical, אין flicker — ה-fallback ה-SYNC שווה לערך-הנפתר). gate: analyze 0-חדש (screen: 7 info קיימים-מראש בלבד · test: 0 issues · אפס raw-color) · full-suite (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline) · build web ✅. נגעתי רק ב-manager_dashboard_screen.dart (+טסט).

## C6 — resolveGeoFix — ה-gate הכן ל-GPS נטיב (geolocator · seam משותף `lib/services`) — 2026-06-14
- **קבצים (lib/services + state + test):** `lib/services/geo_gate.dart` (חדש · טהור platform-free — `resolveGeoFix(...)` עם 4 callbacks: isServiceEnabled/checkPermission/requestPermission/getReading, מחיל את ה-gate הכן; `GeoReading`/`GeoPermissionState` מראָה platform-free כדי **לא** לייבא `geo.dart`→package:web שלא מתקמפל ב-test-VM) · `lib/services/geo_native.dart` (חדש · adapter דק שכובל את `Geolocator` האמיתי ל-`resolveGeoFix`) · `lib/services/geo.dart` (conditional-import שונה `geo_stub.dart`→`geo_native.dart` בנתיב הלא-web; חוזה `Future<GeoFix?>` byte-identical) · `lib/state/site_hub_state.dart` (`clockIn(now,{geo})` + `formatGeo(...)` + `kGeoUnavailable`) · `lib/screens/site_hub_screen.dart` (`_clock` async → `currentGeoFix()`). טסטים חדשים `test/geo_gate_test.dart` (+13) · `test/geo_permissions_source_test.dart` (+6); `test/site_hub_state_test.dart` עודכן (net +5, ה-T2.4 הישן שאישר את הדמו-הקשיח הומר לחוזה-הכן).
- **`lib/services/geo_gate.dart` — `resolveGeoFix` (ה-permission-gate, load-bearing של החוזה-הכן):** מוטציה — `if (perm != GeoPermissionState.granted) return null;` הוסר (הוערה החוצה) → ה-gate עוקף ו-fetch מתבצע גם ללא הרשאה (יזיף קואורדינטה ל-denied/disabled).
- תוצאה: `geo_gate_test` **אדום `+7 -2`** — 'resolveGeoFix — honest null paths (NEVER a fabricated coordinate) permission denied and still denied after the prompt → null' + '… deniedForever → null and NOT re-prompted' (שניהם החזירו את ה-`GeoReading` במקום null) ✅ נתפס. הנתיבים-granted + service-off (שלא תלויים בשורה שהוסרה) נשארו ירוקים.
- שחזור: `cp /tmp/geo_gate.dart.bak lib/services/geo_gate.dart` (**לא** git checkout — לשמר את קוד-ה-C6; sha1 `1dff8495…` תואם את ה-pre-mutation byte-for-byte) → הרצה חוזרת **+9 ירוק**.
- מסקנה: שורת-ה-`if (perm != granted) return null` load-bearing — היא ה-יחידה שמונעת fetch (=קואורדינטה) כשההרשאה denied/deniedForever/unableToDetermine; בלעדיה ה-seam היה מזייף מיקום על מכשיר-מסורב — בדיוק ה-anti-pattern שה-#100 אסר ("אין קואורדינטה מומצאת"). ה-gate מבודד ב-`geo_gate.dart` (בלי package:web) כדי שיהיה ניתן-לבדיקה-headless למרות ש-`worker_attendance_geo_test` נאלץ לדלג את ה-seam דרך `geo.dart`. **caveat נטיב:** ה-fetch האמיתי על מכשיר (geolocator/platform-channel) לא ניתן-לאימות headless — ה-gate נעול ביחידה + ה-permissions ב-source-guard (`geo_permissions_source_test`: manifest FINE+COARSE+אין-background+location-feature-`required=false`; plist `NSLocationWhenInUseUsageDescription` עברית-ספציפי+אין-`Always`). gate: analyze 0-errors (geo_native/geo_gate + 2 טסטים חדשים = 0 issues; info שנותרו = relative-import ב-`geo.dart:21`/`geo_stub.dart:7` בתוך directive ה-conditional + 3 ב-site_hub_screen = **קיימים-מראש**, אומת ב-`git stash`; אפס raw-color) · full-suite **+2448 -1** (baseline +2424 -1; +24 חדשים; ה-`-1` = `worker_reports_drilldown_test` baseline) · build web ✅ (geolocator_web מתקמפל; `geo_web.dart` עדיין נבחר ל-web → 0 התייחסויות-geolocator ב-main.dart.js). pubspec.lock **לא** staged · נגעתי רק ב-geo*.dart + site_hub(_screen/_state) + pubspec + AndroidManifest + Info.plist (+טסטים). **לא נגעתי במסכי worker-board / clock-in UI / manager-credit / firebase_options / nav_launch.**

## F1 — Firebase נטיב (android+ios firebase_options + currentPlatform mapping) — 2026-06-14
- **קבצים (lib + native):** `lib/firebase_options.dart` (נוספו `static const FirebaseOptions android`/`ios`, ערכים verbatim מ-`android/app/google-services.json` + `ios/Runner/GoogleService-Info.plist` — project `buildsmart-b0b78`, appId-android `…:android:e9d240f3251e7a33ca6511`, appId-ios `…:ios:89ac1613e3b695cfca6511`; `currentPlatform` הוסר ה-`UnsupportedError` ל-android/ios, ממפה android→android·iOS/macOS→ios·web→web·linux/windows/fuchsia→throw). gradle: `android/settings.gradle.kts` (`com.google.gms.google-services` v4.4.2 apply false) + `android/app/build.gradle.kts` (apply ה-plugin). `ios/Runner.xcodeproj/project.pbxproj` (4 רשומות → `GoogleService-Info.plist` חבר ב-Runner Resources). טסט חדש `test/firebase_options_test.dart`.
- **`lib/firebase_options.dart` — `android.projectId` (ה-load-bearing של אתחול-Firebase הנכון):** מוטציה — `projectId: 'buildsmart-b0b78'` בבלוק ה-android שונה ל-`projectId: 'WRONG-PROJECT-MUTANT'` (כלומר נייד-android היה מאתחל מול פרויקט לא-קיים → init נכשל בשקט → חזרה ל-local/demo, בדיוק הבאג ש-F1 מתקן).
- תוצאה: `firebase_options_test` **אדום `+15 -3`** — 'android options match … projectId ← project_info.project_id' + 'currentPlatform … android → the android FirebaseOptions' (assertion `projectId`) + 'all three platforms share one project' (Expected `'buildsmart-b0b78'` / Actual `'WRONG-PROJECT-MUTANT'`) ✅ נתפס. ה-ios/web/mapping-no-throw נשארו ירוקים — המוטציה נגעה רק ב-android.projectId.
- שחזור: `cp /tmp/firebase_options.dart.GOOD lib/firebase_options.dart` (**לא** git checkout — לשמר את קוד-ה-F1; `diff`=זהה byte-for-byte) → הרצה חוזרת **+18 ירוק**.
- מסקנה: ה-`projectId` בבלוק-android load-bearing — הוא הקושר את ה-init לפרויקט הנכון; הבדיקה קוראת את `google-services.json` בפועל אז היא נשברת ברגע ש-firebase_options.dart נסחף מהקובץ-של-הבעלים (או להפך). **מסגור-גייטינג:** F1 מביא לחיים את אתחול-ה-Firebase בנייד (→ G4 telemetry + App Check debug קמים), אבל ה-DATA-backend עדיין מגודר `kUseFirebaseBackendFlag` (default OFF) → demo/local byte-identical עד שהבעלים ידליק; **web byte-identical** (const `web` + ענף `kIsWeb` לא נגעו). **caveat android:** אין Android-SDK בסביבה (`flutter build apk` → "No Android SDK found") → נכונות-ה-gradle + התאמת-JSON/plist בלבד; boot-נטיב = DoD של הבעלים. gate: analyze 0-errors (`firebase_options.dart`=0 issues; info ב-main.dart קיימים-מראש; אפס raw-color) · full-suite **+2466 -1** (baseline +2448 -1; +18 חדשים; ה-`-1` היחיד = `worker_reports_drilldown_test` baseline, אומת בבידוד `+1 -1`) · build web ✅. pubspec.lock **לא** staged · נגעתי רק ב-firebase_options.dart + 2 gradle + pbxproj (+טסט). **לא נגעתי בקבצי-הקונפיג של הבעלים / main.dart / App-Check / worker-board / 4 מחלקות / manager-credit / geo.**

## auth-gate — createUser + מיפוי-שגיאות (server-gate-auth) — 2026-06-14
- **קבצים:** `test/login_sheet_test.dart` + `test/auth_state_test.dart` (createUser group · create-account/error-map · welcome-gate · role-picker · profile login/logout/delete).
- **מוטציה (נתפסה ✅):** שיבוש מיפוי-השגיאה `'email-already-in-use' => 'האימייל כבר רשום — התחברו במקום'` → `'MUT_BROKEN'` ב-`login_sheet.dart` → `login_sheet_test` **`+10 -2` אדום** (הטסט "צור חשבון — email-כבר-רשום" חיפש את הטקסט-העברי, מצא 0 widgets) → שוחזר `cp /tmp/ls.bak` → **+20 ירוק**.
- **הערת-יושר (חולשת-מוטציה מתועדת):** מוטציה `createUserWithEmailAndPassword`→`signInWithEmailAndPassword` ב-**FirebaseAuthGateway** (impl ה-SDK, שורה 292) **שרדה** — כי הטסטים מזייפים את ה-`AuthGateway` (`_FakeAuthGateway`), לא את ה-SDK; ה-impl העוטף את ה-SDK אינו unit-testable (כמו `signInWithEmailAndPassword`). ה-notifier + ה-UI (מה שחשוב למשתמש) כן נעולים (login_sheet_test +20).
- **gate:** analyze 0-errors · ratchet נקי · full-suite **+2475 -1** (`-1` = `worker_reports_drilldown` baseline, אומת בבידוד). נגעתי: `auth_state.dart`(lib/state) + `login_sheet`/`welcome_screen`(lib/screens) + 6 טסטים. **לא נגעתי:** worker-board / 4 מחלקות / firebase_options / CI / geo / manager-credit.

## seed-employer-link — חיתום חשבונות-seed של עובדים ב-employerId (תיקון seed-login scoping) — 2026-06-15
- **קבצים (lib/data + test):** `lib/data/board_accounts_local.dart` (חיתום `employerId: kDemoContractorId` על חשבונות-ה-seed של העובדים `ran`/`omer` — ה-Wave-0 worker→contractor link שהשדה נבנה עבורו; courier/store/manager נשארו `''`). טסט חדש `test/seed_worker_employer_link_test.dart` (+3). רקע: עובד ב-seed-LOGIN נשא employerId `''` → נשמט שקט מכל view ממוקד-מעסיק (חופשה/תעודות/הדרכות/חומרים/נוכחות) ושער-המסמכים הקשיח (#101) נכשל-פתוח. נבחר חיתום-במקור על-פני רפרוף הפילטרים ל-`|| isEmpty` כי ה-scoping הקשיח `== employerId` הוא תכן מכוון+מבוטסט (`contractor_certs_test`/`contractor_vacation_approval_test`/`contractor_attendance_test` מאשרים ש-`''`/legacy מורחק).
- **`lib/data/board_accounts_local.dart` — `employerId: kDemoContractorId` על 'ran' (ה-load-bearing של חיווט seed-login→קבלן):** מוטציה — שורת `employerId: kDemoContractorId,` תחת חשבון 'ran' הוסרה (→ ran חוזר ל-default `''` — בדיוק הבאג).
- תוצאה: `seed_worker_employer_link_test` **אדום `+1 -2`** — 'worker seeds (ran/omer) are employed by the demo contractor' (Expected `'contractor-demo'` / Actual `''`) + 'every worker seed has a non-empty employer (no silent drop)' ✅ נתפס. ה-test השלישי ('non-worker seeds keep no contractor employer link') נשאר ירוק — המוטציה נגעה רק ב-ran.
- שחזור: `cp /tmp/bal.GOOD lib/data/board_accounts_local.dart` (**לא** git checkout — לשמר את קוד-החיתום; diff מול ה-GOOD = RESTORED-IDENTICAL) → הרצה חוזרת **+3 ירוק**.
- מסקנה: ה-`employerId: kDemoContractorId` על חשבונות-העובדים load-bearing — בלעדיו ה-session של עובד-seed-login נושא `''` וכל ה-channels ממוקדי-המעסיק (שעושים `== employerId` קשיח) משמיטים אותו, ושער-ה-#101 נכשל-פתוח; החיתום מיישר את עובד-ה-login לעובד-ההדגמה (`board_auth.dart:274` כבר נותן kDemoContractorId ל-enterDemo). gate: analyze 0-errors (board_accounts_local + הטסט = 0 issues) · 5 קבצי-ה-state חזרו byte-identical (revert של גישת-הפילטר) · הטסטים המושפעים ירוקים (contractor_certs/vacation/attendance + docs_readiness + auth = 159 ירוק). נגעתי רק ב-board_accounts_local.dart (+טסט). **לא נגעתי** בפילטרי-ה-scoping (vacation/material/certs/trainings/docs_readiness) — נשמרו קשיחים בכוונה.
## order-sync-fix — ההזמנה של הקבלן לא מסתנכרנת בין מכשירים (rules create-gate + index) — 2026-06-14
- **שורש הבאג:** כלל ה-`create` ב-`firestore.rules` על `orders` דרש `hasRole('contractor')`, אבל זהות-ה-`contractor` היא ברירת-המחדל **ללא claim** — ה-callable `setRole` + `manager_role_assign_sheet` מקצים אך-ורק את התפקידים-המיוחדים (manager/store/courier/worker) ולעולם **לא** 'contractor' (ראה ה-RoleOption doc). לכן קבלן-אמיתי מחובר (כמו `meir7651231@gmail.com`) נושא 0 role-claim ⇒ `hasRole('contractor')`==false ⇒ כל יצירת-הזמנה **נדחתה** (`permission-denied`), ה-`guardWrite` בלע אותה בשקט, ההזמנה הופיעה אופטימית במכשיר-המניח אבל **לא הגיעה ל-Firestore** ⇒ לא סונכרנה לדפדפן-של-אותו-חשבון. הקריאה (`ownsOrder`=`contractorUid==uid`) והשדה הנכתב (`contractorUid`) היו **תקינים** — רק שער-היצירה גידר על claim שלקבלן אין.
- **תיקונים:** (1) `firestore.rules` create → `isSignedIn() && stage=='new' && contractorUid==auth.uid` (קושר ל-uid-הבעלות, לא ל-claim; עדיין אי-אפשר לזייף uid אחר, עדיין נעוץ ל-'new'). (2) `firestore.indexes.json` #2/#3: `storeId`/`courierId` → `storeUid`/`courierUid` (להתאים ל-toDoc + ל-`_ordersScopeFor` של store/courier; שאילתת-scoped עם שדה-ללא-index זורקת `failed-precondition`). (3) `firestore_cached_repo.dart:99` doc-comment `contractorId`→`contractorUid`. (4) דיאגנוסטיקה ב-`backend_debug_badge.dart` (4 צעדים: diag/{uid} · users/{uid} · שאילתת-הזמנות-שלי · יצירת-הזמנה) מאחורי `kDebugMode||FS_DIAG`.
- **קובץ-מוטציה (ה-load-bearing של התאמת-index↔toDoc):** `firestore.indexes.json` — שדה-ה-index `storeUid` → `storeId` (החזרת-הבאג: index על שדה שאף-פעם לא נכתב ⇒ ה-store scoped query לעולם בלי-index).
- תוצאה: `orders_sync_scope_index_diag_test` **אדום `+5 -1`** — 'every orders index field is a field toDoc writes (no storeId/courierId)' → `Expected: not contains 'storeId'` / `Actual: Set:['contractorUid','ts','storeId','courierUid']` ✅ נתפס. כל שאר הצעדים (scope-fields · contractor-index-קיים · 4 ה-fsDiagStepResult mappings) נשארו ירוקים — המוטציה נגעה רק בהתאמת-ה-index.
- שחזור: `cp /tmp/firestore.indexes.json.good firestore.indexes.json` (גיבוי לפני-מוטציה, byte-for-byte) → הרצה חוזרת **+11 ירוק**.
- מסקנה: התאמת שמות-ה-index לשדות ש-`toDoc` כותב load-bearing — index על `storeId` בזמן ש-toDoc כותב `storeUid` משאיר את ה-store/courier scoped listen בלי-index ⇒ `failed-precondition` בכל live-read שלהם. ה-guard קורא את `firestore.indexes.json` בפועל (`File('../...')`) אז הוא נשבר ברגע שקובץ-ה-index נסחף מ-שמות-ה-toDoc. **מסגור-גייטינג:** ה-scope + הדיאגנוסטיקה מגודרים (`kUidScopedQueries` / `kDebugMode||FS_DIAG`, שניהם compile-time OFF) ⇒ flag-OFF byte-identical; ה-rules+index הם server-side (לא חלק מ-בינארי-האפליקציה). **caveat נייד:** אישור-הסנכרון-האמיתי = on-device — הדיאגנוסטיקה (FS_DIAG=true ב-APK חתום) תַראֶה את ה-`permission-denied`/`failed-precondition`+URL המדויק; ה-deploy של rules/indexes = פעולת-בעלים (`firebase deploy --only firestore:rules,firestore:indexes`). gate: analyze 0-errors (כל הקבצים-הנגועים + הטסט החדש; כל ה-issues `info`-בלבד · אפס raw-color/`value:`/`activeColor:`) · full-suite (ה-`-1` היחיד = `worker_reports_drilldown_test` baseline) · build web ✅. נגעתי רק ב-rules/indexes + backend/orders_local/firestore_cached_repo/main/backend_debug_badge (+טסט). **לא נגעתי:** worker-board / 4 מחלקות / auth-gate / firebase_options.

## manager-owner — כניסת מנהל עם Google (שלב 2/4) — 2026-06-15
- **קבצים (lib/data + test):** `lib/data/board_accounts_local.dart` (helper חדש `isOwnerEmail` + allowlist `kOwnerEmails={'meir7651231@gmail.com'}` — שער-הבעלים לכניסת-המנהל). טסט: `test/manager_google_login_test.dart` (+5: isOwnerEmail case/space-insensitive · דחיית-זר/null · 3 widget-tests של השער).
- **קובץ-מוטציה (ה-load-bearing של שער-הבעלים):** body של `isOwnerEmail` שונה ל-`=> true` (כל חשבון Google הופך ל"בעלים" — בדיוק החור).
- תוצאה: `manager_google_login_test` **אדום `+3 -2`** — 'any other email — and null/empty — is rejected' (Expected false / Actual true) + 'non-owner Google sign-in → rejected' (זר קיבל session-מנהל ולא נותק) ✅ נתפס. owner-case + no-gateway + isOwnerEmail-true-case נשארו ירוקים.
- שחזור: `cp /tmp/bal.GOOD lib/data/board_accounts_local.dart` (גיבוי byte-for-byte, לא git checkout — לשמר שינויים שטרם נדחפו) → RESTORED-IDENTICAL → הרצה חוזרת **+5 ירוק**.
- מסקנה: `isOwnerEmail` load-bearing — בלעדיו כל חשבון Google נכנס כמנהל-על. השער client-side להצגת-UI; ה-authority האמיתי = admin/manager custom-claim ב-firestore.rules (server-swap, שלב 4). gate: analyze 0-errors · full-suite +2632 -1 (baseline). **לא נגעתי:** worker-board / 4 מחלקות / firebase_options / CI / geo.
## E3-leak-fix — requestsForWorker scope על session.uid דלף בין עובדי-seed — 2026-06-15
- **קבצים (lib/state + lib/screens + test):** `lib/state/material_requests_engine.dart` (MaterialRequest += שדה-scope `username`; submit מקבל `username` וחותם אותו; requestsForWorker מסנן `r.username == username` במקום workerUid; workerUid נשמר כ-id מוכן-לשרת) · `lib/screens/worker_employer_stock_sheet.dart` (read+submit מעבירים `session.username`) · `test/material_requests_test.dart` (+טסט-בידוד seed-session, +username בכל submit).
- **`lib/state/material_requests_engine.dart` — requestsForWorker filter (ה-load-bearing של בידוד-העובד):** מוטציה — `if (r.username == username) r,` הוחזר ל-`if (r.workerUid == username) r,` (הבאג המקורי — keying על workerUid שהוא '' לכל עובד seed/demo).
- תוצאה: `material_requests_test` **אדום `+7 -1`** — רק 'requestsForWorker scopes per-USERNAME even when workerUid is empty' נכשל (Expected length 1 / Actual 0 — query 'ran' מול רשומות שכולן workerUid '' → 0 התאמות) ✅ נתפס. 7 הטסטים האחרים (שמעבירים workerUid==username) נשארו ירוקים.
- שחזור: `cp /tmp/mre.GOOD lib/state/material_requests_engine.dart` → RESTORED-IDENTICAL → **+8 ירוק**.
- מסקנה: ה-scope-key של requestsForWorker load-bearing — session.uid='' לכל עובד seed/demo (רק נתיב Firebase-bind ממלא אותו, kUidScopedQueries default OFF ב-backend.dart), אז keying עליו התנגש ב-'' ו-requestsForWorker('') החזיר את בקשות-החומר הפרטיות של כל העובדים זה לזה (הפרת #66). המעבר ל-username (תבנית-האחים VacationRequest/AttendanceDay/WorkerCert) מבודד נכון; workerUid נשמר additive ל-SERVER-SWAP (username==uid בנתיב Firebase → אפס רגרסיה). נמצא ע"י ביקורת-התקינות האדוורסרית של הצי. gate: analyze 0 · caller יחיד (worker_employer_stock_sheet) עודכן. נגעתי רק ב-material_requests_engine + worker_employer_stock_sheet (+טסט). **לא נגעתי** ב-orders/auth/firebase.

## R2-seq-guard — id מבוסס-timestamp בלי _seq → דליפת-מחיקה ב-4 stores — 2026-06-15
- **קבצים (lib/state + test):** `worker_certs.dart` (cert id) · `worker_forms.dart` (sick-note id) · `cart_lists_state.dart` (cart id) · `saved_projects.dart` (project id) — לכל אחד נוסף `int _seq = 0;` והסיומת `-${_seq++}` ל-id. טסט חדש `test/id_seq_collision_test.dart` (4 חנויות).
- **`lib/state/worker_certs.dart` — id mint (load-bearing):** מוטציה — הוסר `-${_seq++}` מה-id (חזרה ל-`'cert-${micros}'` — הבאג המקורי).
- תוצאה: `id_seq_collision_test` **אדום `+3 -1`** — רק 'worker_certs cert id' נכשל (הסגמנט-האחרון של ה-id הוא ה-micros ולא 0,1) ✅ נתפס. 3 החנויות האחרות נשארו ירוקות.
- שחזור: `cp /tmp/wc.GOOD lib/state/worker_certs.dart` → RESTORED-IDENTICAL → **+4 ירוק**.
- מסקנה: web DateTime ~1ms-precise; שני adds באותה מילישנייה התנגשו על id זהה, ו-remove(id)/deleteList(id)/rename(id) (שמורידים/משנים כל שורה עם אותו id) פגעו בשתיהן. ה-`_seq` המונוטוני (תבנית vacation/material/trainings/notifs/stock) מבטיח ייחודיות. id נשאר String אטום (toJson/fromJson ללא-שינוי) → אפס back-compat. נמצא ע"י ביקורת-הלילה סבב-2 של הצי. gate: analyze 0 · 4 stores ירוקים. נגעתי רק ב-4 ה-state-stores (+טסט). **לא נגעתי** ב-UI/orders/auth.

## A1-tasks-persistence — משימות-ריצה (createTask/proposeTask) לא שרדו restart — 2026-06-15
- **קבצים (lib/state + test):** `tasks_engine.dart` — TaskItem += toJson/tryFromJson (רשומה-מלאה); `_persist` כותב משימות-ריצה (non-seed ids) כרשומות-מלאות תחת `kTasksRuntimeKey='bs.tasks-runtime.v1'`; `_load` משחזר אותן אחרי seed+overlay. טסט חדש `test/tasks_runtime_persistence_test.dart` (+2).
- **`tasks_engine.dart` _load — restore-runtime (load-bearing):** מוטציה — `if (runtime.isNotEmpty) super.state = [...state, ...runtime];` הוחלף ב-`{}` (משימות-הריצה מחושבות אך לא מוחלות — הבאג המקורי).
- תוצאה: `tasks_runtime_persistence_test` **אדום `+0 -2`** — שני המקרים נכשלו (המשימה שנוצרה ב-session 1 לא קיימת ב-session 2) ✅ נתפס. 3 טסטי-ה-overlay הקיימים (worker_tasks_persistence) נשארו ירוקים.
- שחזור: `cp /tmp/te.GOOD lib/state/tasks_engine.dart` → RESTORED-IDENTICAL → **+2 ירוק**.
- מסקנה: ה-_load בנה state רק מ-_seedTasks (const ids 1-5) plus overlay; משימות-ריצה (id=max+1) נזרקו ב-restart וה-overlay גם לא שמר name/steps/worker שלהן. עכשיו הרשומה-המלאה נשמרת תחת מפתח-prefs נפרד ומשוחזרת. back-compat: payload פרה-A1 ללא-שינוי; ה-overlay של ה-seeds לא נגע (3 טסטיו ירוקים). SERVER-READY: bindRemote (T1) יסנכרן חי כשה-Firebase ינחת. החלטת-בעלים A1. gate: analyze 0. נגעתי רק ב-tasks_engine (+טסט).

## A2-hr-decide-once — אישור חופשה/הדרכה ירה פעמון+צ'אט פעמיים (double-tap) — 2026-06-15
- **קבצים (lib/state + lib/screens + test):** `vacation_requests.dart` + `worker_trainings.dart` — `approve`/`reject`/`_decide` שונו מ-void ל-`bool` (true רק על מעבר אמיתי pending→decided). `contractor_hr_sheet.dart` — `_decide`/`_decideTraining` יורים bell+chat+toast רק אם ה-bool true. טסט חדש `test/hr_decide_once_test.dart` (+2).
- **`vacation_requests.dart` _decide guard (load-bearing):** מוטציה — ה-`return false;` (כשהשורה כבר-לא-pending) → `return true;`.
- תוצאה: `hr_decide_once_test` **אדום `+1 -1`** — מקרה-ה-vacation נכשל (approve שני החזיר true במקום false) ✅ נתפס. מקרה-ה-training (מנוע אחר) נשאר ירוק.
- שחזור: `cp /tmp/vr.GOOD lib/state/vacation_requests.dart` → RESTORED-IDENTICAL → **+2 ירוק**.
- מסקנה: ה-side-effects היו ללא-תנאי אחרי קריאת-המנוע; ה-r/t הלכוד מתיישן ב-double-tap (השורה לא נבנתה-מחדש בין הקשות) → שתי-ההקשות ירו. עכשיו המנוע מחזיר אם באמת עבר, והווידג'ט יורה פעם-אחת — מתקן double-tap plus שני-משטחים (השני רואה false). הקבלן מחזיק את ההתראה; ה-double-fire בלוח-המנהל נפתר ב-#84g (הוצאת HR מהמנהל). void→bool additive (17 טסטי-אישור קיימים ירוקים). gate: analyze 0. נגעתי ב-vacation plus trainings(state) plus contractor_hr_sheet(לוגיקה, ללא-פיקסל).

## A3-pod-signature-await-rollback — חתימת POD "נשמרה" גם כשה-persist נכשל — 2026-06-15
- **קבצים:** `persona_fulfillment.dart` — `captureSignature` שונה מ-`void` (→`_put` fire-and-forget) ל-`Future<bool>` עם await+rollback (חיקוי `capturePod`). `persona_pod_sheet.dart` — הכפתור ממתין ל-bool ומציג toast-הצלחה רק אם נשמר ("החתימה לא נשמרה — נסה שוב" אחרת). טסט חדש ב-`persona_fulfillment_test.dart` (+1, סה"כ +23).
- **load-bearing:** `captureSignature` `return ok;` (ה-bool של ה-persist) — ייחודי בקובץ (grep=1).
- מוטציה: `return ok;` → `return false;`. תוצאה: הטסט "captureSignature awaits persist (true) and survives a reload (A3)" **אדום `+22 -1`** ✅ (ה-isTrue על n1 נכשל). שאר 22 ירוקים.
- שחזור → **+23 ירוק** · RESTORED-IDENTICAL.
- מסקנה: החתימה רוכבת על ה-side-car הראשי (`'podSig'` ב-toJson), אז await יחיד של `_persist` הוא כל הכתיבה (בלי `_mirrorPodPhoto` שהוא לתמונה בלבד). הקוד הישן עשה `_put`→`set state`→`_persist()` fire-and-forget — כשל-quota השאיר state בזיכרון אבל לא בדיסק, וה-UI הריע "נשמרה" שקרית; ב-reload החתימה נעלמה. עכשיו: rollback ל-state הקודם plus `false`, וה-UI כן. analyze 0. server-ready (החתימה שורדת restart; bindRemote יזרים חי).

## A4-dst-day-idiom — off-by-one ב-offset יום חוצה גבול-DST (גאנט + 2 דוחות) — 2026-06-15
- **קבצים:** חדש `lib/logic/calendar_days.dart` (`daysBetweenDst` מבוסס-`DateTime.utc` plus `startOfWeekSunday` חשבון-לוח). `tasks_gantt.dart` (startDay offset), `worker_reports_tab.dart` plus `courier_reports_tab.dart` (weekStart plus dayIdx של היסטוגרמת-השבוע) עוברים דרכם. טסט חדש `calendar_days_test.dart` (+6).
- **load-bearing:** `daysBetweenDst` — `DateTime.utc(...)` (×2). מוטציה: `DateTime.utc(` → `DateTime(` (local).
- תוצאה (TZ=Israel Standard Time, ה-spring-forward 2026 ב-27/3): 3 הטסטים התלויי-DST של daysBetweenDst **אדומים `+3 -3`** ✅ (adjacent dates, multi-day span, time-of-day ignored). טסטי startOfWeekSunday נשארו ירוקים (לא משתמשים ב-.utc).
- שחזור → **+6 ירוק** · RESTORED-IDENTICAL.
- מסקנה: `DateTime(y,m,d)` מקומי הוא midnight מקומי; הפרש בין שני midnight-ים מקומיים חוצה spring-forward = 23h → `.inDays` מתקצר ל-0 (יום פחות) → בָּר נופל ביום שגוי / משלוח בדלי-שבוע שגוי. UTC (ימי-24h, בלי DST) נותן את הפער הלוחי המדויק בכל TZ. בנוסף: `weekStart` חושב ב-subtract Duration days (חיסור-שעות שנסחף ב-DST) → הוחלף ב-DateTime y m d-k (חשבון-לוח). הגאנט הוא pure (VM-safe) וכך גם calendar_days. ה-streak כבר היה חשבון-לוח — לא נגעתי. analyze 0.

## A5-board-proposed-fold — משימה מוצעת (proposed) בלתי-נראית בלוח-המשימות — 2026-06-15
- **קובץ:** `worker_task_board_screen.dart` — `_groups` שונה מ-status-יחיד ל-Set-של-statuses, ו-`'proposed'` קופל לקבוצת ⏳ בתור (יחד עם pending). חולצה `groupByStatus` טהורה (@visibleForTesting). build משתמש בה. טסט חדש `worker_task_board_group_test.dart` (+1).
- **load-bearing:** סט-ה-בתור `{'pending', 'proposed'}`. מוטציה: הסרת `'proposed'` → `{'pending'}`.
- תוצאה: `worker_task_board_group_test` **אדום `+0 -1`** ✅ — המשימה המוצעת (id 1) לא נכנסה לאף קבוצה → containsAll[1,2] נכשל plus הסכום 3≠4.
- שחזור → **ירוק** · RESTORED-IDENTICAL.
- מסקנה: המנוע מחזיק status `'proposed'` (worker proposeTask → ממתין ל-approveProposal של הקבלן), אבל `_groups` כיסה רק active/rejected/pending/review/done → משימה מוצעת נפלה בין-הכיסאות (לא הוצגה כלל, וה-invariant counts-sum-to-total נשבר בשקט). A5 (החלטת-בעלים): לא קבוצה חדשה — לקפל proposed לתוך בתור. עכשיו כל status ממופה לקבוצה אחת בדיוק. analyze 0.

## #52-order-notif-to-orders-world — התראות הזמנה/משלוח מההגדרות → עולם-ההזמנות — 2026-06-15
- **קבצים:** חדש `order_notif_sheet.dart` (OrderNotifSheet plus showOrderNotifSheet — 2 toggles הקשורים ל-notifSettingsProvider: typeOrders/typeShipments). `store_screen.dart` — 🔔 ב-_SectionChipsRow כשהמקטע=📦 הזמנות → פותח את הגיליון. `notif_settings_screen.dart` — הוסרו 2 השורות הזמנות/משלוחים ממקטע 🔔 (שאר ה-types נשארו). טסט חדש `order_notif_sheet_test.dart` (+1).
- **load-bearing:** ה-toggle `onChanged: v => n.update(x => x.copyWith(typeOrders: v))` — כותב את ה-provider המשותף. מוטציה: `copyWith(typeOrders: v)` → `copyWith(typeOrders: x.typeOrders)` (מתעלם מ-v).
- תוצאה: `order_notif_sheet_test` **אדום `+0 -1`** ✅ — אחרי tap, typeOrders נשאר true (הציפייה false נכשלה) → ה-tap לא כתב את ה-provider.
- שחזור → **ירוק** · RESTORED-IDENTICAL.
- מסקנה: ההתראות הקשורות-הזמנה הועברו למקום שבו הקונה עוקב אחרי הזמנות (🔔 בטאב 📦 הזמנות), כשהן קושרות את אותו notifSettingsProvider (מקור-אמת יחיד, לא עותק) — שאר ההתראות נשארו בהגדרות › התראות. שני הטסטים שנוגעים ב-typeOrders/typeShipments הם engine-level (notifMutedSections/copyWith) → לא הושפעו. שני טסטים שמרנדרים NotifSettingsScreen (robustness, settings_honesty) ירוקים. analyze 0. אין שער-format.

## #50-settings-merge-dup-categories — מיזוג קטגוריות-הגדרות כפולות + price-drop קנוני — 2026-06-15
- **קובץ:** `catalog_settings_screen.dart` (מסך 'הגדרות' הראשי). מוזגו 2 מקטעי-🔔 (`_NotificationsSection` plus `_CatalogNotifSection`) ל-🔔 'התראות' יחיד, ו-2 מקטעי-תצוגה (`_ThemeSection` plus `_DisplaySection`) ל-'תצוגה ומיון' יחיד. price-drop כפול קופל לשדה-קנוני יחיד `catalogSettings.notifPriceDrop` ('ירידת מחיר במועדפים'); ה-toggle הכפול `typePriceDrops` ('התראות תקציב') הוסר מהמסך. order/shipment הושמטו (עברו לעולם-ההזמנות, #52). הרשימה ב-build ירדה מ-13 ל-11 מקטעים. עדכון `catalog_sort_alerts_settings_test` ('התראות קטלוג'→'התראות').
- **load-bearing:** השורה המקופלת `notifLowStock` ('מלאי נמוך') תחת המקטע-הממוזג 'התראות' — מוכיחה שמשפחת-קטלוג קופלה לתוך 'התראות'. ייחודי בקובץ (grep=1).
- מוטציה: תווית `'מלאי נמוך'` → `'XX_MUT'`. תוצאה: טסט "מלאי נמוך flips notifLowStock" **אדום `+14 -1`** ✅. שחזור → **+16 ירוק** · RESTORED-IDENTICAL.
- מסקנה: היו שני מקטעי-התראה ושני מקטעי-תצוגה במסך-הגדרות אחד, plus 3 toggles ל-price-drop על-פני 2 שדות plus שדה-שלישי priceChangeAlert במועדפים. #50 מיזג את הכפילויות בתוך catalog_settings plus קיבע price-drop ל-notifPriceDrop. 4 טסטי-מסך ירוקים. analyze 0. שארית: typePriceDrops ב-notif_settings_screen (מסך-נפרד) plus priceChangeAlert (→#54).

## #54-remove-favorites-category — הסרת קטגוריית 'מועדפים ורשימות' מההגדרות — 2026-06-15
- **קובץ:** `catalog_settings_screen.dart` — מחיקת `_FavoritesSection` (❤️ 'מועדפים ורשימות') plus רשומתה ב-build (11→10 מקטעים). היה: 4 placeholders (סנכרון/רשימות-פרויקט/שיתוף/יבוא-ייצוא — כולם coming-soon backend-blocked) plus toggle אחד מחווט `priceChangeAlert`. priceChangeAlert מכוסה ע"י ה-price-drop הקנוני ב-'התראות' (notifPriceDrop, #50); השדה נשאר במודל back-compat בלי toggle. עדכון `catalog_sort_alerts_settings_test`: טסט-priceChangeAlert → טסט "הקטגוריה הוסרה" (findsNothing).
- **load-bearing:** קיום המקטע ❤️ 'מועדפים ורשימות' במסך.
- אימות RED→GREEN בלי perl: הטסט החדש רץ **בעוד `_FavoritesSection` קיים** → **אדום `+0 -1`** (מצא את הכותרת). אחרי מחיקת המקטע → **ירוק** (4 טסטי-מסך +54). מוכיח שהטסט תופס רגרסיה של חזרת-הקטגוריה.
- מסקנה: קטגוריה שכולה placeholders backend-blocked plus toggle כפול שכבר-קנוני (#50) = קטגוריה מתה. הוסרה; ה-placeholders יחוברו כ-seams במשטחי-המועדפים/רשימות כשייחשף שם שקע-הגדרות (נדחה — הצבה עכשיו = ניחוש). analyze 0.

## #49-wire-supplier-prefs — ספקים-מועדפים: חיווט 3 העדפות מגובות (server-ready) — 2026-06-15
- **קובץ:** `catalog_settings_screen.dart` — `_SuppliersSection` שונה מ-StatelessWidget (5 placeholders) ל-ConsumerWidget: 3 השדות המגובים ב-CatalogSettings חוּוטו לפקדים נשמרים — `maxDistance` (_NumberRow 5-300 ק"מ), `minRating` (_RadioGroupRow any/3+/4+/5), `localSuppliersOnly` (_SwitchRow). 2 הרשימות (ספקים-מועדפים/חסומים) נשארו _PlaceholderRow כ-server-ready seams (דורשות זהות-ספק). טסט חדש ב-catalog_sort_alerts_settings_test (+1).
- **load-bearing:** `_SwitchRow` 'ספקים מקומיים בלבד' `onChanged: copyWith(localSuppliersOnly: v)`. מוטציה: `copyWith(localSuppliersOnly: v)` → `copyWith(localSuppliersOnly: s.localSuppliersOnly)` (מתעלם מ-v).
- תוצאה: טסט "ספקים מקומיים בלבד flips localSuppliersOnly (#49)" **אדום `+0 -1`** (אחרי tap נשאר false). שחזור → **ירוק** · RESTORED-IDENTICAL.
- מסקנה: הקוד הקודם השאיר את 3 השדות לא-מחווטים בכוונה כי אין דאטת-ספק על מוצרים לסנן. אך שמירת ההעדפה אינה זיוף — היא ה-intent שהסינון העתידי יכבד (server-ready). החיווט שומר מקומית עכשיו ומופעל אוטומטית כשהספק יזין מרחק/דירוג/מקומיות. preferred/blocked דורשים זהות-ספק → seams כנים. analyze 0 · robustness/settings_honesty ירוקים.

## #99-rewards-private-per-user — BuildCoins נשמרו תחת מפתח גלובלי → דליפה בין משתמשים — 2026-06-15
- **קובץ:** `rewards_state.dart` — `RewardsNotifier` קיבל `username` plus getter `_storageKey` (`'$kRewardsKey.$username'`, ריק→מפתח-גלובלי back-compat). `_load`/`_persist` משתמשים ב-`_storageKey`. ה-provider קורא `ref.watch(boardAuthProvider)?.username` ובונה notifier scoped (re-build על login/switch). leaderboard נשאר seed משותף (רק שורת 'אתה' מסונכרנת למאזן הפרטי). טסט חדש `rewards_per_user_test.dart` (+1). תיקון-setup ב-`t3_ghi_rewards_ai_home_test.dart` (binding plus mock — ה-coupling החדש ל-boardAuth נוגע ב-prefs).
- **load-bearing:** `_storageKey` getter `username.isEmpty ? kRewardsKey : '$kRewardsKey.$username'`. מוטציה: `username.isEmpty ?` → `true ?` (מפתח-גלובלי תמיד, מתעלם מ-username).
- תוצאה: טסט "#99" **אדום `+0 -1`** — omer ירש את 440 של ran (440≠340 seed). שחזור → **ירוק** · RESTORED-IDENTICAL.
- מסקנה: כל המשתמשים חלקו `bs.rewards.v1` יחיד → P-6/F-33 leak. עכשיו המפתח כולל username → פרטי per-user; ה-provider מ-re-build על שינוי-session. leaderboard משותף (החלטת-בעלים). אין מיגרציה ממפתח-גלובלי (מטבעות דמו מקומיים) — נרשם. analyze 0 · t3 מלא ירוק אחרי תיקון-binding.

### #99-addendum — board_auth._load resilience (root-cause of the gate-32 baseline) — 2026-06-16
- כש-`rewardsProvider` התחיל `ref.watch(boardAuthProvider)` (#99), כל טסט שמרנדר מסך-קורא-rewards (worker/courier reports · rewards hub · drilldowns) בנה את `BoardAuthNotifier`. ב-`_load` ה-`await SharedPreferences.getInstance()` **לא** היה ב-try/catch (רק ה-jsonDecode) — וב-context בלי `setMockInitialValues`/binding זה זורק "Binding not initialized" (StateError) כשגיאה אסינכרונית **לא-מטופלת** → הטסט נכשל.
- **התיקון:** עטיפת כל ה-`_load` ב-try/catch (כמו rewards_state ומנועים אחרים) → כשל-prefs נבלע, נשאר logged-out. תיקון-robustness אמיתי.
- **בונוס:** זה היה גם שורש ה-baseline הקדם-קיים `worker_reports_drilldown` (קורא דרך drilldown→boardAuth). אחרי התיקון הסוויטה המלאה = **+2658 ALL PASS, 0 כשלים**. baseline עודכן 1→0 (STATUS.md + known_failing.txt).
- **קבצים נוספים ל-#99:** `lib/state/board_auth.dart` · `knowledge/STATUS.md` · `knowledge/known_failing.txt`.

## #36-voice-dictate-worker-board — כפתור קול↔הקלדה בלוח-העובד — 2026-06-16
- **קבצים:** חדש `lib/widgets/voice_dictate_button.dart` (VoiceDictateButton — IconButton-מיקרופון שמכתיב דרך VoiceService.listen ומצרף את הטקסט ל-controller; seams listenFn/stopFn לבדיקה). `worker_app_screen.dart` — מחווט כ-suffixIcon ל-3 שדות-הטקסט בגיליון-הצעת-המשימה (שם/תיאור/שלבים). טסט חדש `voice_dictate_button_test.dart` (+2). לוח-עובד בלבד (החלטת-בעלים #36), לא app-wide.
- **load-bearing:** `_append` — `if (t.isEmpty) return;` ואז כתיבת ה-controller. מוטציה: `if (t.isEmpty) return;` → `return;` (תמיד early-return, אף פעם לא מצרף).
- תוצאה: שני טסטי-#36 **אדומים `+0 -2`** — אחרי tap השדה לא השתנה. שחזור → **+2 ירוק** · RESTORED-IDENTICAL.
- מסקנה: ההכתבה ממלאת את השדה שבו המשתמש (append, cursor בסוף — לא דורסת הקלדה), במקום הבאג המקורי שבו קול הפעיל חיפוש-קטלוג. ה-STT מוזרק (seam) לבדיקה בלי מיקרופון. analyze 0.

## #45-weather-open-meteo — תחזית מזג-אוויר אמיתית (Open-Meteo + GPS) — 2026-06-16
- **קבצים:** חדש `lib/services/weather.dart` — `fetchOpenMeteoDaily` (Open-Meteo, חינמי ללא-מפתח, http-seam מוזרק) plus `weatherDaysFromOpenMeteo` (mapper טהור: WMO weather_code → אמוji/הערה/טמפ) plus `weatherIconFor`/`weatherNoteFor` plus `weatherForecastProvider` (FutureProvider: currentGeoFix→fetch→map, fallback ל-kWeather ב-no-GPS/רשת/parse). `ai_hub_screen.dart` — `_Weather` הפך ל-ConsumerWidget שצורך את ה-provider במקום ה-seed הקשיח; ההערה "⚙️ בפרודקשן API חיצוני" → "🌦️ Open-Meteo · לפי מיקום". טסט חדש `weather_service_test.dart` (+3).
- **load-bearing:** `weatherNoteFor` ענף-הגשם (51-67) `'⚠️ גשם — לדחות יציקות בטון'`. מוטציה: `⚠️ גשם` → `גשם`.
- תוצאה: טסטי-#45 **אדומים `+1 -2`** — days[2].warn (code 61) הפך false, ו-thresholds-test נכשל. שחזור → **+3 ירוק** · RESTORED-IDENTICAL.
- מסקנה: הכלי היה deferred כי "צריך API חיצוני" — Open-Meteo חינמי ללא-מפתח פותר זאת. ה-fetch מוזרק (seam) אז ה-mapper נבדק בלי רשת/GPS; ה-provider נופל ל-seed בחן (ב-VM אין GPS → seed מיידי, מסך לא נשבר). analyze 0 · ai_hub_compute/robustness ירוקים. נשאר deferred/hidden ל-Apple — un-hide הוא flip של הבעלים בשחרור; schedule-automation = micro-confirm עתידי.

## #31-help-coverage-wave1 — מצב-היכרות: chrome ראשי של הקבלן (home_shell) — 2026-06-16
- **קבצים:** `lib/widgets/help_target.dart` — נוסף `showHelpInfo` (כרטיס-הסבר מרכזי לאלמנטים שאי-אפשר לעגן להם בועת-זנב, כמו טאבים תחתונים). `lib/screens/home_shell.dart` — לוגו→חיוג-תפקיד, שבב-השם→פרופיל, חיפוש, ו-4 וריאנטי תפריט-⋮ נעטפו ב-HelpTarget; 4 טאבי-הניווט מקבלים הסבר במצב-היכרות דרך showHelpInfo במקום ניווט. טסט חדש `help_coverage_test.dart` (+2).
- **load-bearing:** ב-onTap של הניווט התחתון `body: _kTabHelp[i].$2` (ההסבר של הטאב הנלחץ). מוטציה: `.$2` → `.$1` (מציג את שם-הטאב במקום ההסבר).
- תוצאה: טסט-הטאב **אדום `+1 -1`** — אחרי tap על "עדכונים" לא הופיע ההסבר "ההתראות והשיחות". שחזור → **+2 ירוק** · RESTORED-IDENTICAL.
- מסקנה: ה-💡 וה-✕ נשארים ללא-עטיפה כדי שתמיד אפשר לצאת מהמצב; אלמנטים מחוץ לשכבת-ההקפאה מוסברים דרך showHelpInfo. גל 1 מתוך כיסוי-לפי-לוח (קבלן→שליח→חנות→מנהל→עמוק). analyze 0.

## #31-help-coverage-wave2 — מצב-היכרות: לוח השליח (courier_dashboard) — 2026-06-16
- **קבצים:** `lib/screens/courier_dashboard_screen.dart` — נוסף `const HelpToggleButton()` ל-AppBar (קריטי — בלעדיו אי-אפשר להיכנס למצב-היכרות בלוח השליח); עטיפת פעמון/פרופיל/הגדרות/יציאה + בורר-הרכב ב-HelpTarget; 4 טאבי-הניווט מקבלים הסבר דרך showHelpInfo במצב-היכרות במקום החלפת-טאב. טסט חדש `help_coverage_courier_test.dart` (+2). כפתורי קידום-המשלוח+POD שבתוך כרטיסי-הרשימה + בורר-הרכב בטאב המשלוחים נדחו לתת-גל courier-deep.
- **load-bearing:** `const HelpToggleButton()` ב-AppBar של השליח (נקודת-הכניסה היחידה למצב-היכרות בלוח). מוטציה: `const HelpToggleButton(),` → `const SizedBox.shrink(),`.
- תוצאה: שני טסטי-השליח **אדומים `+0 -2`** — אין toggle אז find.byType(HelpToggleButton) ריק, ולא ניתן להיכנס למצב כדי שהפעמון יסביר. שחזור → **+2 ירוק** · RESTORED-IDENTICAL.
- מסקנה: עטיפת אלמנטים בלוח חסרת-ערך בלי toggle להפעלת המצב — כל לוח (שליח/חנות/מנהל) חייב HelpToggleButton משלו. analyze 0 (info יחיד comment_references קדם-קיים). גל 2/7 בכיסוי-לפי-לוח.

## #31-helpfix-bottomnav — טאבים תחתונים: HelpTarget אמיתי במקום כרטיס-מרכזי — 2026-06-16
- **קבצים:** `lib/widgets/help_target.dart` — widget משותף חדש `BottomNavCell` (תא-ניווט icon+label שאפשר לעטוף ב-HelpTarget). `lib/screens/home_shell.dart` + `lib/screens/courier_dashboard_screen.dart` — ה-BottomNavigationBar הוחלף ב-Material+Row של BottomNavCell, כל טאב עטוף ב-HelpTarget (קבלן: בית/מחלקות/עדכונים/חנות · שליח: משלוחים/פורטל/דוחות/אזור אישי). הוסר ענף showHelpInfo (+ משתנה helpMode הלא-נחוץ בשליח). טסט `help_coverage_test` עודכן.
- **הבאג שתוקן:** הטאבים השתמשו ב-showHelpInfo (כרטיס מרכזי) + בלי טבעת → לא מודגשים והבועה לא יצאה מהם, בניגוד למצלמה/⋮. עכשיו עקבי: טבעת כתומה + בועה מעוגנת מכל טאב.
- **load-bearing:** `body: _kTabHelp[i].$2` ב-HelpTarget של הטאב. מוטציה: `.$2` → `.$1` (הבועה תציג את שם-הטאב במקום ההסבר).
- תוצאה: טסט-הטאב **אדום `+1 -1`** — אחרי tap על "עדכונים" לא הופיע "ההתראות והשיחות". שחזור → **+2 ירוק** · RESTORED-IDENTICAL. אומת חי בדפדפן (Chrome extension): טבעת על כל 4 הטאבים + בועה יוצאת מ"עדכונים".

## #31-helpcov-wave3 — לוח החנות/ספק (store_dashboard) — 2026-06-16
- **קבצים:** `lib/screens/store_dashboard_screen.dart` — נוסף `HelpToggleButton` ל-AppBar; פעמון/אזור-אישי/הגדרות/התנתקות/יציאה עטופים ב-HelpTarget; ה-BottomNavigationBar (5 טאבים) הוחלף ב-Material+Row של BottomNavCell+HelpTarget (בית/מלאי/שיחות/פורטל/אזור-אישי). טסט חדש `help_coverage_store_test` (+2).
- **load-bearing:** `body: _kStoreTabHelp[1].$2` (הסבר טאב "מלאי"). מוטציה: `.$2`→`.$1`.
- תוצאה: טסט-הטאב **אדום `+1 -1`** · שחזור → **+2 ירוק** · RESTORED-IDENTICAL. analyze 0. דפוס זהה לתיקון-הטאבים (BottomNavCell משותף). גל 3/7.

## #31-swarm-wave — נחיל קנוני: מנהל + עובד-עמוק + שליח-עמוק — 2026-06-16
- **הנחיל:** /swarm קנוני (DONNING — auditor 6+9 · validator 4+6 · fixer 3 · supervisor 6+7), צינור audit→validate→fix. 20 סוכנים, ~2.09M טוקנים. 181 אלמנטים נמצאו → 79 אומתו → **89 עטיפות HelpTarget ב-14 קבצים** (manager_dashboard 22 · worker profile/reports/today/notifs/app = 21 · courier dashboard/portal/profile/settings/reports/forms/attendance/certs = 46). הנחיל הוסיף 💡 toggle ל-courier settings/forms/attendance/certs שחסרו, וגילה שהמנהל משתמש ב-toggle עליון מקטעי (per-seg HelpTarget, לא BottomNavCell).
- **אימות (תפקיד אורקסטרטור §3):** byte-verify (grep HelpTarget>0 בכל קובץ) · **central-verify GATE PASS** (analyze 0 · +2682 טסטים ירוקים · build ok · conformance 7/7 · required-tests 6/6) · supervisor (6+7). load-bearing: דפוס ה-HelpTarget שאומת ב-mutation בגלים 1-3 (אותו דפוס, byte-verified).
- ניקיתי import מת (help_mode) ב-courier_dashboard שהנחיל סימן. push רק ב"תתדחוף".

## #chat-delivery-status — סטטוס-מסירה אמיתי לכל הודעה (✓✓ רק דרך fromDoc) — 2026-06-16
- **שינוי-מודל:** `enum MsgStatus { pending, sent, delivered, failed }` + `final MsgStatus status` על `ChatMessage` (default `sent` = back-compat) + `copyWith` חדש (לא היה) + `toJson` כותב `status` **רק** כש≠sent (seed byte-identical) + `tryFromJson` קורא tolerant (`firstWhere(orElse: () => sent)` — דוק ישן ללא status → sent). מראה את אידיום ה-`LineStatus` ב-`persona_fulfillment.dart`.
- **שינוי-לוגיקה (ה-INVARIANT):** `delivered` ✓✓ נקבע **מבנית ובמקום יחיד** — `FirebaseChatRepository` message `fromDoc` → `decoded.copyWith(status: delivered)`. הודעה שלא חזרה מ-snapshot של השרת לעולם לא delivered. `toDoc` **משמיט** status (sender-local, לא נכתב לשרת). `send`: שורת-המשתמש `pending` → onWrite מטליא `sent`/`failed` (דרך `upsertLocalOnly`, ללא set נוסף); בוט נשאר `sent`. `guardWrite`/`upsert` קיבלו callback-תוצאה אופציונלי (תוסף, zero-regression). `retry` ב-repo/interface/engine (local = no-op).
- **טסט-נעיצה (pinning):** `test/chat_msg_status_test.dart` (9 טסטים — default sent מושמט מ-toJson · pending/delivered/failed round-trip · json ישן→sent · status לא-מוכר→sent · copyWith) + הרחבת `test/chat_firebase_repo_test.dart` (+6 — **fromDoc→delivered** (ה-invariant) · **toDoc משמיט status** · pending→sent בהצלחה · pending→failed בכשל · retry→pending→sent · bot auto-reply נשאר sent). load-bearing: ה-fromDoc-delivered וה-toDoc-omits-status נועצים את ה-honest invariant; דפוס ה-fake-source verbatim מ-S4 base-test.
- **gate:** analyze 0 · `flutter test` +2699 -1 (baseline `worker_reports_drilldown_test.dart` בלבד; אומת נכשל בבידוד, לא קשור). push רק ב"תתדחוף".

## #connection-indicator — חיווי-חיבור חי ALWAYS-ON (provider + לוגיקת-קומביין) — 2026-06-16
- **תלות חדשה:** `connectivity_plus: ^6.1.0` → נפתר **6.1.5** (`flutter pub get` הצליח; `pubspec.lock` עודכן). first-party web/iOS/Android — `flutter build web` ממשיך להדר.
- **state חדש (`lib/state/connection_status.dart`):** `enum ConnectionStatus { connected, disconnected, demo }` + `ConnectionStatusNotifier extends StateNotifier<ConnectionStatus>` + `connectionStatusProvider`. מראה את אידיום ה-notifier/provider של `auth_state.dart` (gateway-נ-null → אינרטי).
- **לוגיקת-הקומביין (RECOMPUTE חי, לא בדיקה חד-פעמית; החלטי-ביותר ראשון):**
  ```dart
  if (!_active)              next = ConnectionStatus.demo;          // !useFirebaseBackend
  else if (!_networkOnline) next = ConnectionStatus.disconnected;  // connectivity none
  else if (!_signedIn)      next = ConnectionStatus.disconnected;  // אין uid
  else if (_firestoreCacheOnly) next = ConnectionStatus.disconnected; // isFromCache
  else                      next = ConnectionStatus.connected;
  ```
- **אותות:** (1) `Connectivity().onConnectivityChanged` (+seed `checkConnectivity()`) — 6.x `List<ConnectivityResult>`, offline == רשימה ריקה / רק `none` → `_resultsOnline` = `any(r != none)`. (2) `ref.listen(authStateProvider)` → `_signedIn`/`_uid`, ו-re-bind ל-probe כש-uid משתנה. (3) `FirebaseFirestore.instance.collection('diag').doc(uid).snapshots(includeMetadataChanges:true)` → `_firestoreCacheOnly = snap.metadata.isFromCache` — **מאזין בלבד**, default **FALSE** (assume-live, מונע ריצוד-התחלה).
- **HARD RULES (אכיפה):** (#1) `_active = useFirebaseBackend` בקונסטרקטור; כש-false → `return` מיד, **לא נפתח שום listener** (state נשאר `demo`), `FirebaseFirestore.instance` לא נגעת → אינרטי בכל ה-suite ה-Firebase-free + sandbox (אפס עלות, אפס ערוץ-פלטפורמה). (#2/#3) כל connectivity/Firestore touch ב-try/catch + `onError`; init אופטימי (`networkOnline=true`, `firestoreCacheOnly=false`) — שגיאה מורידה חיווי, לא זורקת. dispose מבטל את שלושת ה-subscriptions (`_authRemove` · `_connSub` · `_fsSub`).
- **widget חדש (`lib/widgets/connection_indicator.dart`):** `ConsumerWidget` שמחזיר `Positioned` (top/RTL/topCenter, `IgnorePointer`) ו-`ref.watch(connectionStatusProvider)` → switch: connected=ירוק קטן · disconnected=אדום בולט+"פעולות לא יישמרו" · demo=אפור עדין. `kConnectionIndicatorDebugDrop=44` מסיט בדיבאג מתחת ל-BackendDebugBadge.
- **wire:** `main.dart` — import + `const ConnectionIndicator()` כ-child אחרון ב-`Stack` של `MaterialApp.builder` (אחרי `debugOverlayChildren`), בתוך מבנה `_AutoLogout`/Stack הקיים (ללא restructure).
- **למה אין טסט חדש:** המסלול שכל טסט-widget בונה (flags OFF, אין Firebase) הוא ה-demo האינרטי שלא פותח listener — אין מה לנעוץ מעבר ל"לא קורס", וזה כבר מכוסה ע״י ה-gate הקיים (`+2699 -1`, אפס כשל חדש). ה-API של connectivity_plus 6.x (`List<ConnectivityResult>`) אומת מול ה-resolved 6.1.5.
- **gate:** analyze **0 errors** · `flutter test` **+2699 -1** (baseline `worker_reports_drilldown_test.dart` בלבד; אומת נכשל בבידוד, לא קשור; הקובץ לא נגעת). **אין כשל חדש.** push רק ב"תתדחוף".

## #quality-wave1 — memo `compatibleProductsFor` (per-SKU cache, byte-equivalent) — 2026-06-16
- **ההלפר החדש:** `_compatCache` (`Map<String,List<LipskeyCatalogProduct>>`) ב-`related_info.dart` — `compatibleProductsFor(p)` מחזיר `_compatCache[p.sku] ??= (…גוף קיים…)`; טהור מעל קטלוג-`const`, וכל הקוראים read-only (אומת: 15 אתרי-קריאה — card/sheet/finder/tests — אף אחד לא מוטט את הרשימה המוחזרת, לכן שיתוף-instance בטוח).
- **טסט-נעיצה:** `test/compat_memo_test.dart` — ה-load-bearing: `identical(compatibleProductsFor(p), compatibleProductsFor(p))` חייב `true` (proof שה-memo חי — רשימת `out` טרייה לעולם לא `identical` בלי ה-cache-store).
- **mutation-verify:** baseline **+2 ירוק** → הזרקתי `return _compatCache[p.sku] = out;` → `return out;` (ה-cache-store הוסר) → טסט **אדום `+1 -1`** (`memo live` → `Expected: true / Actual: <false>`; טסט ה-empty-path נשאר ירוק כי `const []` קנוני ללא תלות ב-cache) → שחזור → **+2 ירוק**, RESTORED-IDENTICAL (אפס שארית MUTATION). analyze 0.

## #wave2b-budget-persist — תקציב נשמר דרך `setBudget` (BudgetNotifier→repo) — 2026-06-17
- **ההלפר החדש:** `BudgetNotifier._persist()` ב-`budget_screen.dart` (=`_repo.setBudget(total,spent,cats)`), נקרא מכל mutator; + `_BudgetCacheRepo.setBudget` (`upsert` ל-`financeBudget/active`) ב-`finance_firebase.dart`. data/repositories נגע → גייט 44 דורש mutation-verify.
- **טסט-נעיצה:** `test/budget_server_empty_test.dart` — ה-load-bearing: "connected: an edit PERSISTS via setBudget and the state round-trips" (fake `FinanceRepository` מקליט `setCalls`; `setTotals(30000,12000)` חייב לרשום call + state לעשות round-trip).
- **mutation-verify:** baseline **+4 ירוק** → הזרקתי הסרת `_persist();` מ-`setTotals` (`// MUTATION`) → טסט **אדום `+3 -1`** (`an edit PERSISTS via setBudget` → `Actual: []` — אין setCalls) → שחזור → **+4 ירוק**, RESTORED-IDENTICAL (0 MUTATION markers). analyze 0. דפוס: כל mutator מנותב דרך `_persist` (אותו דפוס שאומת), כך שהמחיקה של אחד תופסת את העיקרון.

## #autoflowfix-pump — autoFlowFix מוסיף HW-PUMP-40 (kCompatCatalog) — 2026-06-22
- **ההלפר:** `pressure_drop.autoFlowFix` (lib/logic) — שלב prepend-המשאבה ב-ΔP>1bar; תוקן לפתור `HW-PUMP-40` מול `kCompatCatalog`.
- **טסט-נעיצה:** `test/pressure_pump_test.dart` — load-bearing: "autoFlowFix prepends the booster pump on high ΔP" (chain מוכח + params 1000m/5LPS/50m → ΔP>1bar → chain חייב להכיל HW-PUMP-40).
- **mutation-verify:** baseline **+3 ירוק** → הזרקתי `kCompatCatalog`→`kLipskeyCatalog` ב-:237 (`// MUTATION`) → **אדום `+2 -1`** (autoFlowFix-prepends → אין HW-PUMP-40; ה-suggestion וה-membership נשארו ירוקים כי הם לא תלויים בשורה הזו) → שחזור → **+3 ירוק**, 0 MUTATION markers. analyze 0.

## #ai-backbone — claudeGatewayProvider gating (no-AI-offline / byte-identical) — 2026-06-22
- **ההלפר החדש:** `claudeGatewayProvider` ב-`claude_functions.dart` (data/ → גייט 44) — `if (useFirebaseBackend && kClaudeAi) return FirebaseClaudeGateway(); return null;`. הוא ה-load-bearing gate ש-(א) מונע AI offline ו-(ב) שומר demo/test byte-identical (null gateway).
- **טסט-נעיצה:** `test/claude_gateway_test.dart` — "claudeGatewayProvider is null when AI is off".
- **mutation-verify:** baseline **+3 ירוק** → הזרקתי החלפת הגוף ב-`return FirebaseClaudeGateway();` (gate מוסר) → טסט **אדום `+2 -1`** (`is null when off` → ה-provider החזיר gateway, לא null) → שחזור → **+3 ירוק**, RESTORED-IDENTICAL. analyze 0. הקונסטרקטור lazy אז ה-mutation לא נגע ב-Firebase — נכשל נקי על ה-null-check.

## #lipskey-pdf-enrich — העשרת קטלוג-הבית מ-PDF הרשמי (R8) — 2026-06-23
- **הדאטה (`lib/data/lipskey_catalog.dart`, data/ → גייט 44):** נחיל-חילוץ ויזואלי קרא 58 עמודי קטלוג-ליפסקי והחיל **93 dims (מידות/תיאור) · 44 qtyPallet · 2 color** verbatim על מוצרים קיימים (התאמה לפי SKU). `match_lipskey_pdf.py` **מחריג color למוצרי gate-117** (מונע התנגשות עם `lipskey_pdf_parity_test` שמצמיד color=null). תיקון render נלווה: `_SpecRow` עוטף ערך ארוך (Flexible/Expanded) במקום לגלוש.
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — load-bearing: `217861` qtyPallet=2250 + dims['מידות']='190-270 / 140 / 55 / 110-245 / Ø32.0'; `218553`/`116649` qtyPallet; אינווריאנט qty>0.
- **mutation-verify:** baseline **+3 ירוק** → הזרקתי `qtyPallet: 2250`→`9999` בבלוק 217861 → טסט **אדום `+2 -1`** ("pallet quantities were extracted") → שחזור → **+3 ירוק**, 0 שארית (`grep 9999`=0). analyze 0 errors.
- **למה אין fixer מקביל:** יעד = קובץ-גנרי יחיד; החלה דטרמיניסטית ע"י האורקסטרטור (`apply_lipskey_enrich.py`, idempotent) — כלל PLAYBOOK "אין שני fixers על אותו קובץ". **לקח:** להצליב gate-117 לפני העשרה (השחזור הראשון היה תגובת-יתר).

## #qondus-pdf-enrich — העשרת קטלוג מ-Qondus/Aquatec PDF (R8) — 2026-06-23
- **הדאטה (`lib/data/lipskey_catalog.dart`, data/ → גייט 44):** נחיל-חילוץ ויזואלי קרא 102 עמודי קטלוג Qondus/Aquatec 2023 (תמונתי). חולצו 572 מוצרים, **562 תואמים לקטלוג** (SKUs אלפא-נומריים `779096G`/`7777708G`), והוחל R8-verbatim: **154 dims (מידה/תיאור) + 42 color (גימורי-ברזים: זהב-מוברש/שחור-מט/ניקל)**. `match_lipskey_pdf.py` מטפל ב-SKU כמחרוזת-מלאה (אלפא-נומרי) ומחריג color ל-gate-117 (0 התנגשות).
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — load-bearing קבוצת "Qondus/Aquatec": `7777708G` color='זהב מוברש' + dims['מידה']='250 מ"מ'; `778580` color='ניקל'.
- **mutation-verify:** baseline **+5 ירוק** → הזרקתי `color: 'זהב מוברש'`→`'בדיקה'` בבלוק 7777708G → טסט **אדום `+4 -1`** ("shower-head finish + size") → שחזור → **+5 ירוק**, 0 שארית. analyze 0 errors. parity+product_journey(935)+twenty_products ירוקים.
- **לקח-regex:** מק"טי-Qondus אלפא-נומריים — recon-numeric (`\d{6,9}`) פספס; חילוץ-ויזואלי תפס אותם נכון (`779096G` אכן בקטלוג).

## #qondus-connectors-pass2 — מחברי-תשתית מטבלאות צפופות (R8) — 2026-06-23
- **הדאטה (`lib/data/lipskey_catalog.dart`, data/ → גייט 44):** נחיל-מעבר-שני ממוקד קרא 23 עמודי-טבלאות-מחברים בהגדרה-גבוהה (×2.6). הוחל **254 dims (מידה/תיאור) + 17 color** למוצרי-AQUATEC דלילים (מכסים/רשתות · ברזי-מעבר ת.פ/פ.פ · נחושת: ניפל/כפה/מופה/פקק/רקורד/בושינג/מאריך).
- **תיקון-מחיל (`scripts/apply_lipskey_enrich.py`):** מוצרי-AQUATEC כתובים ב**שורה-אחת** (`LipskeyCatalogProduct(...page:N...),`) — עוגן-ה-page-בשורה-נפרדת לא תפס אותם (0 הוחל). נוסף ענף שמזהה constructor-בשורה-אחת ומחיל את השדות **לפני ה-`),` הסוגר**. (אותה מחלקת-באג כמו 186666 הבודד.)
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — קבוצת Qondus, "connector dims/finish": `77003023` dims['מידה']='6"'+color='ניקל'; `77777311` dims['מידה']='1/2"'.
- **mutation-verify:** baseline **+6 ירוק** → הזרקתי `'מידה': '6"'`→`'9"'` בשורת 77003023 → טסט **אדום `+4 -1`** ("connector dims/finish") → שחזור → **+6 ירוק**, 0 שארית. analyze 0. parity+product_journey(935)+twenty_products ירוקים.

## #qondus-hdpe-pass3 — מחברי-HDPE מעמודים 75-78 (R8) — 2026-06-23
- **הדאטה (`lib/data/lipskey_catalog.dart`, data/ → גייט 44):** מעבר-3 ממוקד על 16 עמודי-Qondus שדילגתי במעבר-2 (בעיקר HDPE 75-78). הוחל **164 dims (מידה) + 5 color** למצמדי-HDPE דלילים (`מצמד HDPE 16×16`, מצמד-הברגה-חיצונית…) — SKUs `91xxxxxxxx` שתואמים בול לקטלוג.
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — "HDPE coupler dims": `9101601610` dims['מידה']='16*16'; `9101601211`='16*1/2"'.
- **mutation-verify:** baseline **+7 ירוק** → הזרקתי `'מידה': '16*16'`→`'99*99'` בשורת 9101601610 → טסט **אדום `+5 -1`** ("HDPE coupler dims") → שחזור → **+7 ירוק**, 0 שארית. analyze 0. parity+product_journey(935)+twenty_products ירוקים.
- **לקח-כיסוי:** מעבר-2 דילג בטעות עמודי-HDPE 75-78 → 120 דלילים נשארו; תיקון = למפות **כל** עמודי-הדלילים לפני סבב, לא תת-קבוצה.

## #name-parse-enrich — מילוי R8 מהשם עצמו (size/finish) — 2026-06-23
- **הדאטה (`lib/data/lipskey_catalog.dart`, data/ → גייט 44):** `scripts/enrich_from_name.py` — שם-המוצר הוא דאטת-קטלוג verbatim, אז חילוץ מידה/גימור שכתובים בשם הוא R8. הוחל **37 dims (מידה/תיאור) + 12 color**: dims לדלילים עם DN/מידה בשם (`מסעף DN32`); color **מודע-קטגוריה** — רק קטגוריות דקורטיביות (ברזים/מקלחות/מכסים/מערכות-אמבטיה), לא חומר-קטגוריות (נחושת/HDPE שבהן נחושת=חומר, לא גימור).
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — "Name-parse": `196206` dims['מידה']='DN32'; `77701205` color='זהב מוברש'.
- **mutation-verify:** baseline **+9 ירוק** → הזרקתי `'מידה': 'DN32'`→`'DN99'` בשורת 196206 → טסט **אדום `+6 -1`** ("toilet-connector DN") → שחזור → **+9 ירוק**, 0 שארית. analyze 0. parity+product_journey(935)+twenty_products ירוקים.
- **תשובה לצבעים:** color תקוע ~24% כי **רוב המוצרים אין להם גימור** (צינורות/מחברים=חומר-אחד); גימור רלוונטי רק לדקורטיביים. ה-12 שנוספו הם הדקורטיביים שגימורם בשם.
## #ai-assistant-agentic — parseAssistantIntent closed-set guard (Phase 1) — 2026-06-22
- **ההלפר החדש:** `parseAssistantIntent` + `matchAssistantCategory` ב-`lib/logic/assistant_intent.dart` (logic/ → גייט 42/44). המודל מחזיר JSON של פעולה מרשימה-סגורה; ה-parse הוא **total** — JSON-שבור / action-לא-מוכר / קטגוריה-מחוץ-לסט → degrade ל-`answer` (לעולם לא זורק, לעולם לא מבצע פעולה לא-מאומתת). ה-load-bearing הוא ה-closed-set guard על הקטגוריה (אותו דפוס כמו `matchRecipe`/`matchCategory`).
- **טסט-נעיצה:** `test/assistant_intent_test.dart` — ה-load-bearing: "findProduct with an INVENTED category downgrades to answer (G2)" (+ G1 unknown-action, G3 malformed→answer-never-throw).
- **mutation-verify:** baseline **+9 ירוק** → הזרקתי הסרת ה-guard בענף findProduct (`return AssistantIntent(action: action, key: key, …)` — מעביר את ה-key הלא-מאומת במקום matchAssistantCategory→downgrade, `// MUTATION`) → טסט **אדום `+8 -1`** (G2 בלבד → ה-intent חזר `findProduct` עם קטגוריה-מומצאת במקום `answer`; שאר 8 נשארו ירוקים כי הם לא תלויים בענף הזה) → שחזור → **+9 ירוק**, RESTORED-IDENTICAL (0 MUTATION markers). analyze 0. Phase 1 read-only — שום ענף לא ממטט state, אז ההגנה היחידה היא ה-closed-set, וזה בדיוק מה שה-mutation תפס.

## #ai-assistant-agentic-p2 — addToCart closed-set guard (Phase 2 mutator) — 2026-06-23
- **ההלפר החדש:** `matchAssistantRecipeKey` + ענף `addToCart` ב-`parseAssistantIntent` (`assistant_intent.dart`, logic/ → גייט 42/44). זה ה-mutator היחיד — אך גם הוא רק **מציע** ערכה; כתיבת-הסל קורית במסך מאחורי tap-אישור מפורש (G5). ה-load-bearing: addToCart עם מפתח-ערכה מחוץ ל-`kSmartProducts` → degrade ל-`answer` (אין הוספה שגויה).
- **טסט-נעיצה:** `test/assistant_intent_test.dart` — "addToCart with an INVENTED recipe key downgrades to answer (no wrong add)" (+ matchAssistantRecipeKey real→key/junk→null).
- **mutation-verify:** baseline **+12 ירוק** → הזרקתי הסרת ה-guard בענף addToCart (`return AssistantIntent(action: action, key: key, …)` במקום matchAssistantRecipeKey→downgrade, `// MUTATION`) → טסט **אדום `+11 -1`** (`INVENTED recipe key` בלבד → ה-intent חזר `addToCart` עם ערכה-מומצאת במקום `answer`; שאר 11 ירוקים) → שחזור → **+12 ירוק**, RESTORED-IDENTICAL (0 MUTATION markers). analyze 0. G5 (כתיבה רק ב-confirm tap) הוא מבני — ה-`smartCartProvider.add` היחיד יושב ב-`_confirmAdd`, ושום נתיב-מודל לא מגיע אליו.

## #residual-rt — תיקון-מדד + מילוי-שארית R8 — 2026-06-23
- **תיקון-כן:** מדד "dims 100%" של v6.57 היה מנופח (ספר בלוק-`dims` גם כשהכיל רק `'תיאור'`=השם). **המדד הנכון=מפרט-אמיתי** (מפתח≠תיאור): **79%**. לקח: למדוד `[k for k in dims if k!='תיאור']`, לא נוכחות-בלוק.
- **הדאטה (`lib/data/lipskey_catalog.dart` → גייט 44):** `scripts/fill_residual_rt.py` הוסיף R8-verbatim **9 מידה** (אינטש/ס"מ שנכתבו בשם והוחמצו — הregex הקודם תפס מ"מ אך לא ס"מ/אינטש/`/`) + **9 color** (צבע-טהור בשם: אפור/לבן/שחור — לעולם לא חומר-גוף, R8-בטוח בכל קטגוריה). **מפרט-אמיתי 79%→80% · color 25%→26%.** gate-117 מודר (פחות מהמועמדים הוחל = כיוון-בטוח).
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — `273089` dims['מידה']='2"'; `116180` color='אפור'.
- **mutation-verify:** baseline **+11 ירוק** → `273089` `'מידה':'2"'`→`'9"'` → **אדום `+8 -1`** ("residual inch size") → שחזור → **+11 ירוק**. analyze 0 errors. parity+product_journey(935) ירוקים.
- **התקרה תחת R8 ≈ 80%.** ~184 הנותרים (מושבי-אסלה לפי דגם · רשתות · ערכות) חסרי-מידה-בשם באמת — 100% אמיתי=דפי-מפרט מהספק (#56). **המדד אינו מוצג ב-UI**; השינוי בכרטיס-הפנימי בלבד.

## #honest-score — dataCompletenessScore + ציון דו-צירי — 2026-06-23
- **ההלפר החדש:** `dataCompletenessScore(p)` ב-`lib/data/related_info.dart` (data/ → גייט 42/44) — ציון listing spec-FREE; + ענפי-קטגוריה ב-`installToolsFor`/`installTipsFor` ל-`kMountAuxCats` (חבקים/אומגות/ידיות).
- **טסט-נעיצה:** `test/honest_score_test.dart` — ערכה(186466) מוכנות<30 + שלמות≥55; רקורד(77381040) שניהם גבוה; חבק(77006080/77775289) install-tools לא-ריק + `compatibleProductsCount==0` (low-is-correct נעול).
- **mutation-verify:** baseline **+5 ירוק** → הזרקתי `return (score:0,label:'חלקי')` בראש `dataCompletenessScore` (`// MUTATION`) → טסט **אדום `+0 -1`** ("listing NOT slandered" — שלמות צנחה מתחת 55) → שחזור → **+5 ירוק**, 0 שארית. analyze 0.
- **בטיחות:** קוראי-`installToolsFor` = ציון + תצוגת-כרטיס בלבד (אומת ב-grep) → אין mate-שגוי במנוע-הניתוב. card_score+polyroll_score+lipskey_score+external_card_score+line_score+parity+product_journey(935) ירוקים.

## #modes-from-name — מפרט-בשם לברזים/מזלפים (Qondus מוצה) — 2026-06-23
- **בדיקת-מקור:** רנדור Qondus p10/p26 (pypdfium2) הראה קטלוג תמונתי — אין טבלת-מידה לאביזרים דקורטיביים. מעבר-חוזר=דד-אנד למידות. לקח: לרנדר+להסתכל על המקור לפני נחיל-חילוץ יקר.
- **הדאטה (`lib/data/lipskey_catalog.dart` → גייט 44):** `scripts/fill_modes_from_name.py` — מהשם R8-verbatim: `dims['מצבים']` (\d+ מצבים) · `dims['אורך']` (קצר/ארוך) · `dims['סוג']` (טלסקופי/נשלף/מהקיר/כפול/יחיד/שולחני). הוחל ל-**62 מוצרים** שהיו רק-תיאור. **מפרט-אמיתי 80%→87%** (802/924). gate-117 מודר; ממזג למפת-dims קיימת; idempotent.
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — `77701117` dims['מצבים']='5'; `77701204`='3'.
- **mutation-verify:** baseline **+12 ירוק** → `77701117` `'מצבים':'5'`→`'9'` → **אדום `+10 -1`** ("spray-mode count") → שחזור → **+12 ירוק**, 0 שארית. analyze 0. parity+product_journey(935)+honest_score ירוקים.
- **תקרה:** ~87% מהשם; דימות-בפועל דורש דפי-מפרט טכניים מהספק (#56) — קטלוג-התצוגה אינו מכיל אותם.

## #material-from-name — חומר 100%-ודאי מהשם — 2026-06-23
- **רקע:** חיפוש-תמונה (Lens) נוסה ומוצה — מחזיר OEM-גנרי תחת מותגים אחרים (CASAINC), R8 חוסם העתקה (חיבור בין-אזורי שונה). המקור הוודאי = שם-המוצר.
- **הדאטה (`lib/data/lipskey_catalog.dart` → גייט 44):** `scripts/fill_material_from_name.py` — `dims['חומר']` מחומר-מבני בשם (נחושת/נירוסטה/פליז/פלסטיק), 100% verbatim. הוחל ל-**64 מוצרים**. מודר: גימורים (כרום≠חומר) ותת-רכיב ("ציר פלסטיק"=ציר, לא גוף). gate-117 מודר; ממזג ל-dims; idempotent.
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — `77777481` dims['חומר']='נחושת' (מצוף נחושת).
- **mutation-verify:** baseline **+13 ירוק** → `77777481` `'חומר':'נחושת'`→`'זהב'` → **אדום `+11 -1`** ("structural material") → שחזור → **+13 ירוק**. analyze 0. parity+product_journey(935) ירוקים.

## #attribute-fleet — נחיל קבוצה-קבוצה: אטריביוטים מהשמות — 2026-06-23
- **הנחיל:** Workflow קנוני, 68 קבוצות × (גלאי+עדשת-R8/מנוע+עדשת-שלמות)=204 סוכנים. כל סוכן קרא שמות-קבוצה מ-`cat_data.json` והציע אטריביוטים verbatim; עדשות אישרו.
- **הדאטה (`lib/data/lipskey_catalog.dart` → גייט 44):** `scripts/fill_attrs_from_fleet.py` (קלט `knowledge/_fleet_attrs.json`) — מפתחות זווית/יציאות/תצורה/מאפיין/ייעוד. **שער-R8 קשיח: כל ערך חייב להופיע מילולית ב-nameHe** (defence-in-depth, חוסם הזיות-סוכן). 262→256 הוחלו. **לא מחריג gate-117** (parity per-key — מפתח-חדש בטוח, אומת).
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — `116207` dims['זווית']='45°' (gate-117!); `77775256` ייעוד='למדיח'; `77775255` תצורה='כפול'.
- **mutation-verify:** baseline **+14 ירוק** → `116207` `'זווית':'45°'`→`'99°'` → **אדום `+12 -1`** ("attribute fleet") → שחזור → **+14 ירוק**. analyze 0. parity +277 (כולל gate-117+זווית) + product_journey(935) ירוקים **בנפרד** (משולב=קריסת-isolate חולפת מוכרת).

## #audit-fix — תיקוני-איכות מנחיל-המבקר — 2026-06-23
- **הנחיל:** 68 סוכנים ביקרו דאטה+תמונות (דגימת-ראייה קלה) → 84 ממצאים. דו"ח: `New folder/CATALOG-AUDIT-FINDINGS.md`.
- **הדאטה (`lib/data/lipskey_catalog.dart` → גייט 44):** `scripts/fix_audit_dims.py` — ודאיים-R8 בלבד: 2 שגיאות-יחידות (ראש-מקלחת dims['מידה'] ס"מ→מ"מ, השם סתר) + הסרת 6 מידות-HDPE משובשות (`50*114`/`63*2 90` — חילוץ-שם שלי נשבר; הגודל נשמר בשם/'תיאור'). שמרני: לא נגעתי בטעויות-כתיב-מקור (R8), אי-התאמות-תמונה (נכס), false-positives.
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — `7777707C` dims['מידה']='200 מ"מ'; `9106320031` ללא מפתח 'מידה'.
- **mutation-verify:** baseline **+15 ירוק** → `7777707C` `'200 מ"מ'`→`'200 ס"מ'` → **אדום `+13 -1`** ("audit fix") → שחזור (הרצת-fix) → **+15 ירוק**. analyze 0. parity+product_journey(935) ירוקים.

## #audit-fix-v2 — טיפו + dims + תמונות-שגויות — 2026-06-23
- **הדאטה (`lib/data/lipskey_catalog.dart` → גייט 44):** `scripts/fix_audit_all.py` — 23 טיפו (scoped per-SKU block, name+תיאור) · 3 dims (77777120A מידה; 218126/218127 דגם-swap) · 17 imageFile→null (תמונות vision-confirmed שגויות-מוצר; placeholder עדיף). כל edit מאומת (old חייב להתקיים → אחרת no-op).
- **בטיחות gate-117:** טיפו רק על SKUs לא-מוצמדים · imageFile לא מוצמד ב-parity · 'דגם' לא מוצמד. אומת: parity +289 ירוק.
- **false-positives שנדחו:** "דיור"=Dior brand · `{'תיאור'}`=dims נקי · 77701150 שם קיים (double-quoted).
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — `779096F` שם בלי 'גרפיטי'; `152785`/`186466` imageFile=null.
- **mutation-verify:** baseline **+16 ירוק** → `152785` imageFile null→'x.jpeg' → **אדום `+14 -1`** ("audit fix v2") → שחזור → **+16 ירוק**. analyze 0. parity+product_journey(935) ירוקים.

## #image-relink — 19 assets ב-R2 שלא היו מקושרים — 2026-06-23
- **הדאטה (`lib/data/lipskey_catalog.dart` → גייט 44):** 19 מוצרים עם `imageFile: null` שהקובץ שלהם קיים ב-`assets/lipskey/products/` **וגם ב-R2 (אומת curl 200×19)** — קושרו ל-`'<sku>.jpeg'`. גנריים-בטוחים (12 צינורות-שחורים) + אביזרים נדגמו ויזואלית (997091=ברך 90° ✓, 120311=רכיב-ניקוז שחור ✓).
- **בטיחות gate-117:** 120311/186666 הם gate-117 → imageFile לא מוצמד ב-parity (אומת +289 ירוק).
- **טסט-נעיצה:** `test/lipskey_enrichment_test.dart` — `997091`/`273226` imageFile != null.
- **אימות:** enrichment +17 · parity+product_journey(935) ירוקים · analyze 0.
- **הקשר:** העלאה ל-R2 דורשת מפתחות (docs/r2-upload-guide.md, שלב-בעלים); ה-19 כבר היו ב-R2 אז קישור=תיקון-חי. חילוץ-מ-PDF עבור החסרות-מ-R2 יצריך הרצת אותו סקריפט-העלאה.

## #pdf-image-extract — 3 צילומים-נכונים מ-Qondus — 2026-06-23
- **היכולת:** ה-PDFs על שולחן-העבודה (Qondus 102ע' + מאוחד 292ע'); `pip install pymupdf` מרנדר עמוד, Pillow חותך. **מדדתי לפני נחיל** — חיפוש-טקסט: רק 4/18 מוצרים-בעייתיים קיימים ב-PDFs (המיכלים/מחסומים בקטלוג-סניטריה חיצוני שאין). **לא הרצתי נחיל** — 3 מוצרים = עבודה ידנית.
- **השיטה:** `page.search_for(sku)` → `get_image_info()` → בחירת-תמונה הקרובה-ב-y לתווית → `get_pixmap(clip,dpi=300)`. **אימות-עין חובה** (התאמת-y תפסה שכן ל-120011→חבק-PLASSON, נדחה).
- **תוצאה:** 777M1801/77773001/78071545 נשמרו ל-`assets/lipskey/products/<sku>.jpg` (דרסו את השגויים) + imageFile קושר. 120011=null (אין צילום נקי).
- **טסט-נעיצה:** `lipskey_enrichment_test` "PDF-extracted". analyze 0 · enrichment +18 · parity+journey(935) ירוקים.
- **⚠️ קריטי לפני push:** R2 מחזיק את 3 הקבצים-הישנים השגויים → להריץ r2-upload ל-3 לפני/עם הדחיפה, אחרת רגרסיה (יציג שוב שגוי).

## #pdf-image-extract-2 — 9 צילומים מקטלוג-הבית ליפסקי — 2026-06-23
- **תגלית-המשתמש:** המיכלים בקטלוג-הבית (`Downloads/ליפסקי.pdf`, 58ע', שם-עברי→עותק ASCII `lipsky.pdf`) — דילגתי עליו. text-search: "הדחה" ע'50/52, "מחסום" ע'8-27 (טקסט תמונתי דליל — מק"ט/דגם לא בטקסט, רק כותרות).
- **השיטה:** רינדור עמוד → חיתוך אזור-שמאל (טבלאות מימין) → **הסרת סרגל-צד כחול** (b>120 & b>r+25 → לבן) → autotrim לבן → **אימות-עין**.
- **9 חולצו:** 7 מיכלים (טיטאן 152785/יהלום 145629/כנרת 168525,169604/ברקת 178864,178867,178870 — צילום-דגם משותף לגוונים) + 116167 (ע'27) + 610918 (ע'33). נשמרו ל-assets (דרסו שגויים) + relink.
- **לא חולצו (R8 — מק"ט לא בטבלה/שער-נושא):** 196587(ע'16 שער)/186466,686366(ע'29 שער)/118221,116589(מסעף — 118225/116689 בטבלה, לא הם)/120011(אין צילום נקי).
- **מלכודת page-field:** שדה `page` בדאטה ≠ עמוד-PDF לחלק (196587 page=16→שער-אמבטיה). לאמת בעין, לא לסמוך על page.
- **טסט:** `lipskey_enrichment_test` "Lipskey home-PDF extraction". analyze 0 · enrichment +19 · parity+journey(935) ירוקים.
- **⚠️ לפני push:** r2-upload ל-9 הקבצים (R2 מחזיק ישן-שגוי, אחרת רגרסיה).

## #branch-twin-relink — 118221+116589 → תמונת-התאום החיה — 2026-06-23
- **תגלית-נתונים:** קריאת-טבלאות מדויקת ב-PDF ליפסקי ע'22: 45° DN40=116223 (לא 118221); 90° 32/32=116689 (לא 116589). 118221/116589 = **אותו מוצר פיזי** כמו 116223/116689 (וריאנט-SKU/כפיל).
- **התיקון (R8-בטוח, אפס-העלאה):** imageFile של 118221→`116223.jpeg`, 116589→`116689.jpeg` (תאומים שכבר חיים ב-R2, אומתו 200+עין=מסעף 45°/90° שחור נכון). 116589 היה הפניה-מתה `116589.jpeg` (404), לא null.
- **טסט:** `lipskey_enrichment_test` "branch twins". analyze 0 · enrichment +20 · parity +277 · journey +12 (בנפרד; ריצה-משולבת=isolate-flaky מוכר).
- **נשאר ללא תמונה (תקרת-קטלוג אמיתית):** 196587 (מידה 130/50 לא מצולמת, רק 140/50+245/50 בע'26) · 186466 (ע'125=PLASSON saddles, לא ערכת-ברז) · 686366 (SKU בשום PDF) · 120011 (אין צילום נקי).

## #pdf-extract-77772412 — דיור פיה מהקיר מ-Qondus ע'18 — 2026-06-23
- **בירור-מושגי:** 5 ה"חסרים" כולם קיימים בקטלוג (מק"ט/שם/מחיר) — חסרה רק תמונה. 3 סיבות: (א) הפריט לא צולם בקטלוג המודפס; (ב) SKU בדף-אינדקס/יצרן בלי צילום; (ג) מצולם — לא חולץ.
- **77772412 = סוג (ג):** «דיור פיה לברז מהקיר ארוך» זהה-שם ל-77772413 (Qondus ע'18 שורה-3) — כפיל-SKU. חולץ → `77772412.jpeg` (asset חדש) + relink. analyze 0 · enrichment +20.
- **4 שנותרו (תקרת-קטלוג):** 196587 (מידה 130/50 לא בקטלוג, רק 140/50+245/50) · 186466 (אינדקס ע'9) · 686366 (SKU נעדר) · 120011 (דף-PLASSON, חבק לא כובע).
- **⚠️ r2-upload:** 13 קבצים חדשים מצטברים (9 ליפסקי + 3 Qondus + 77772412) לפני/עם push.

## #lipski-site-images — 120011 → תמונת-תאום רשמית — 2026-06-23
- **מקור:** אתר היצרן הרשמי `lipski.co.il` (WooCommerce, /product/, תמונות wp-content). המשתמש אישר שימוש בתמונות-היצרן + "תתחיל ב-4, אם קל המשך ל-17".
- **120011 (כובע אויר DN110):** באתר "כובע אויר 110" = תמונה 120311.png → לנו כבר `120311.jpeg` ב-R2 (תאום). אומת ויזואלית=גליל שחור (כובע). קושר → אפס הורדה/העלאה.
- **R8 תפס אי-התאמה:** 186466 "ערכה אוניברסלית לתיקון **ברז**" — באתר "ערכה אוניברסלית" (186666) היא ל**מיכל-הדחה** (קופסה כחולה, מנגנון דו-כמותי). מוצר שונה → **לא הוטמע**.
- **לא נמצא באתר:** 196587 (תיקני 130/50 — באתר רק "לא תקני 130/50"; ספק שדה "תיקני" שגוי) · 686366 (גנרי).
- **תוצאה מ-4:** רק 120011 (התאמה ודאית). 3 נותרו ללא תמונה. analyze 0 · enrichment ירוק.

## #lipski-site-sweep — 84 תמונות רשמיות חדות — 2026-06-23
- **מקור:** אתר היצרן `lipski.co.il` (186 מוצרים ב-sitemap). `harvest_lipski_site.py` קצר og:image+שם; **מק"ט חולץ משם-קובץ-התמונה** (theme לא חושף SKU ב-meta). 84 התאמות מק"ט-מדויק מול הקטלוג.
- **אימות (קריטי):** נחיל-הסוכנים (12×parallel, Read תמונה) **נתקע** ~15דק' (over-parallelization — לקח swarm-sizing). Fallback: גיליונות-מגע (PIL, 5×20 thumbnails+תווית-SKU) → אימתתי 84 ידנית = **100% תואם** (התאמת-מק"ט-יצרן אמינה; שונה מ-186466 שהיה name-match שגוי).
- **החלה:** הורדה (curl UA) → הקטנה 800px (flatten שקיפות ללבן) → דריסת assets באותו שם. שדרוג חדות פי-3.5 (152785 346→800). 686366 מולא+relink (4 relinks סה"כ).
- **טסט:** `lipskey_enrichment_test` "official Lipski-site sweep". enrichment +21 · parity 277 ירוקים · analyze 0.
- **⚠️ r2-upload ל-84 הקבצים לפני push** (R2 מחזיק ישן). כיסוי: ליפסקי בלבד; AQUATEC לא באתר. נותרו חסרי-תמונה: 196587 (מידה לא-מצולמת), 186466 (שונה מ-186666), 120011 (קושר-תאום).
## #ai-grounding-hardening — אודיט-נחיל גל-5: longest-key + sanitize (לוגיקה) — 2026-06-23
- **הרקע (אודיט-עדשות-שונות):** ה-fallback של ה-closed-set (`matchRecipe`/`matchAssistantRecipeKey`/`matchAssistantCategory`/`matchCategory`) החזיר את המפתח ה**ראשון** המוכל בתשובה. מפתחות מתנגשים בתחילית (`faucet`⊂`kitchenFaucet`, `basin`⊂`basinTrap`), אז תשובה עטופה (`"kitchenFaucet"`) פספסה exact והתאמת-contained תפסה את ה-prefix הקצר → **ערכה שגויה-אך-אמיתית**. תוקן ל-**longest-match**.
- **הלוגיקה (`lib/logic/assistant_intent.dart` → גייט 42/44):** pass-2 בכל matcher בוחר את המפתח ה**ארוך-ביותר** המוכל. + helper חדש `promptSafeText` (`lib/logic/prompt_sanitize.dart`) שמנקה טקסט-לא-מהימן (קיפול-רווחים + cap-אורך) לפני הזרקה ל-prompt — חל על `displayName` ב-reject-reason (וקטור-הזרקה חי) ועל free-text (cap בלבד, closed-set מכיל).
- **טסט-נעיצה:** `assistant_intent_test` (collision-guard עם ordered-pair finder — נועל short-before-long כך ש-first-match מובטח שגוי) · `describe_to_cart_test` (matchRecipe collision) · `prompt_sanitize_test` (cap/collapse/trim — 5 בדיקות).
- **mutation-verify:** baseline `assistant_intent_test` **+13 ירוק** → `matchAssistantRecipeKey` longest→first-match → **אדום `+12 -1`** (הבדיקה collision-guard נפלה) → שחזור → **+13 ירוק**, 0 שארית. analyze 0 errors.

## #seed-blank-on-scoped-empty — אודיט-נחיל #3: cache לא-מציג-seed-דמו תחת query-scoped — 2026-06-23
- **הרקע (עדשת offline/sync):** `FirestoreCachedRepo._onSnapshot` ב-snapshot-ריק-ראשון שמר את ה-seed (לוגיקה ל-"backend טרי"). אבל תחת query **scoped** (uid), ריק = "למשתמש הזה אין מסמכים" — והמשתמש-החדש היה רואה את 4 הזמנות-הדמו (יוסי כהן/אבי מזרחי) כנתונים שלו ברגע ש-`kUidScopedQueries` נדלק.
- **הלוגיקה (`lib/data/repositories/firestore_cached_repo.dart` → גייט 42/44):** `RemoteCollectionSource` קיבל `bool get isScoped` (ה-Firestore source מחזיר `_scope != null`); ב-`_onSnapshot`, snapshot-ריק-ראשון **תחת source scoped** מרוקן ל-`<T>[]` (honest-empty) במקום לשמור seed/לקרוא ל-hook. unscoped = ללא-שינוי (seed נשמר, hook נורה).
- **טסט-נעיצה:** `firestore_cached_repo_test` — `'SCOPED first-empty BLANKS the seed to honest-empty (no seed-hook)'` (`scoped=true` + emit ריק → cache ריק, `firstEmptyCalls==0`); הטסט הקיים unscoped (seed נשמר + hook) עדיין ירוק.
- **mutation-verify:** baseline ירוק → ביטול ענף-ה-`isScoped` (always keep-seed) → הטסט-החדש **אדום** (`cached()` היה `[1,2,3]` במקום ריק) → שחזור → ירוק. analyze 0 errors.
- **גם (`lib/data/repositories/order_functions.dart`, LOW):** `advanceOrderStage`/`computeCredit` עטופים ב-`.timeout(30s)` → קריאה תקועה נכשלת-מהר ל-`_guard` במקום לתלות UI עד ~70s (inert: `kServerCallables` כבוי).

## #manager-copilot — קו-פיילוט-מנהל: context-builder מקורקע — 2026-06-23
- **הלוגיקה (`lib/logic/manager_copilot.dart` → גייט 42/44):** `buildManagerContext` מקפל את נתוני-האמת (Σ-מחזור=Σspend · openOrders · per-stage · top-5 לקוחות · אשראי) לטקסט-עברית שמוזרק ל-Claude; ה-system אוסר-להמציא. כל מספר מהמנועים, לא מהמודל.
- **טסט-נעיצה:** `manager_copilot_test` — context מכיל `פתוחות N`/`התקבלה 1`/הלקוח-המוביל-ראשון · revenue==Σspend (מחרוזת-₪) · system מכיל "אסור להמציא" · prompt עוטף ctx+שאלה+grounding · שאלה ארוכה capped ל-400 · brief מכיל "תדריך-בוקר".
- **mutation-verify:** baseline ירוק → שינוי מחרוזת-הgrounding ל-"מותר להמציא" → הטסט (`forbids invention`) אדום → שחזור → ירוק. analyze 0. (screens-only שאר-הפיצ'ר; לוגיקה-זו נבדקת.)

## #manager-copilot-r1 — אודיט-נחיל סיבוב-1: injection-sanitize + clamp + brief-no-trend — 2026-06-23
- **הלוגיקה (`lib/logic/manager_copilot.dart` → גייט 42/44):** `buildManagerContext` — שם-הלקוח עבר ל-`promptSafeText(c.name, maxLen:40, collapseWhitespace:true)` (הזרקה HIGH); ניצול-אשראי `.clamp(0,100)`; `money()` מקבץ-על-abs. `managerMorningBriefPrompt` — הוסרה דרישת-"מגמת-מחזור" (אין נתוני-זמן → מנע-המצאה).
- **טסט-נעיצה:** `manager_copilot_test` +4 — שם-עם-newline+payload נקטע/נקפל ב-context · over-limit→"100%" (לא 300%) · brief בלי "מגמת" · קיבוץ-₪ תקין.
- **mutation-verify:** baseline 12 ירוק → הסרת-ה-`.clamp(0,100)` → הטסט (`credit utilization is CLAMPED`) אדום (`300%` חוזר) → שחזור → 12 ירוק. analyze 0.

## #manager-copilot-r2 — אודיט-נחיל סיבוב-2: gateway-timeout + maxTokens-per-call — 2026-06-23
- **הרקע (עדשות error-handling · concurrency · governance · a11y):** הסיבוב-השני מצא concurrency נקי, ממשל נקי (פיקוח-בלבד, אפס-HR, אפס-דליפה-בין-personas), Riverpod נקי. נותרו: **(MED)** ל-`ClaudeGateway.ask` לא היה `.timeout()` בצד-הלקוח → transport-תקוע יכול לתלות את ה-UI עד ברירת-המחדל ~70s של ה-SDK; **(LOW)** התדריך-בוקר (3-4 בולטים עברית, מתקצב ~2-4× גרוע) נחתך ב-cap-ברירת-המחדל 420 → מצריך cap-לכל-קריאה.
- **הלוגיקה (`lib/data/repositories/claude_functions.dart` → גייט 42/44):** `FirebaseClaudeGateway.ask` עוטף את `.call<dynamic>(...)` ב-`.timeout(const Duration(seconds: 30))` (תאם ל-`order_functions.dart`); ה-`on Object catch` הקיים ממפה את ה-`TimeoutException` ל-`ClaudeException('unavailable')` → שגיאה-נקייה-הניתנת-לחזרה במקום תלייה.
- **המסך (`lib/screens/manager_copilot_screen.dart` → גייט 24/116):** `_run` קיבל `{int maxTokens=420}`; `_morningBrief` מעביר `maxTokens:600` (יותר-מרווח לתדריך, עדיין ≪ ה-cap 2048 בשרת) → אין-חיתוך-באמצע-משפט. Q&A רגיל נשאר 420.
- **טסט-נעיצה:** `claude_gateway_test` — `'a caller can pin maxTokens and it flows through the gateway contract'`: ה-fake מקליט עכשיו `maxTokens` ב-record-הקריאה; `ask(maxTokens:600)` → `calls.single.maxTokens==600` (ה-cap-לכל-קריאה מגיע ל-seam, לא נבלע).
- **mutation-verify:** baseline ירוק → הסרת ה-`maxTokens:` מ-`calls.add(...)` (תמיד null) → הטסט-החדש **אדום** (`null!=600`) → שחזור → ירוק. analyze 0 errors. (ה-`.timeout` הוא הקשחת-זמן-ריצה על ה-callable החי — inert בבילד-הדמו כי `claudeGatewayProvider==null`; נעוץ ע"י אותו חוזה-seam.)

## #currency-single-source — ₪ thousands-grouping מאוחד לפרימיטיב יחיד — 2026-06-23 (סיבוב-8 i18n)
- **הרקע (עדשת i18n):** אלגוריתם-הקיבוץ שוכפל ב-4 helpers פרטיים (store `_price` · manager `_grouped` · budget `_thousands` · finance `_group`) בעוד כרטיסי-הקטלוג, המלצות-הבית וגיליונות-הקבלן רינדרו ₪ **גולמי** ("₪4200"). אותו מוצר → "₪4200" בעיון, "₪4,200" בעגלה.
- **הלוגיקה (`lib/logic/money_format.dart` → גייט 42/44):** `groupThousands(int)` — פרימיטיב-יחיד שמקבץ את הערך-המוחלט (3150→"3,150"), והסימן/₪ באחריות-הקורא; + `formatNis(int, {prefix})` נוחות. ה-15 אתרי-הגולמי (`formatCatalogPrice` · 8 ב-catalog_screen · 2 ב-smart_home · 5 ב-contractor_tools) עברו דרכו → מקבצים עכשיו כמו העגלה.
- **טסט-נעיצה:** `money_format_test` — `groupThousands` (0/900/4200/50000/1234567 + abs על שלילי) · `formatNis` (חיובי "₪4,200" · שלילי "-₪3,150" בלי "₪-" · prefix). 
- **mutation-verify:** baseline 5 ירוק → שינוי תנאי-הפסיק ב-`groupThousands` (`% 3 == 0` → תמיד-false) → `groups every 3 digits` **אדום** ("4200"≠"4,200") → שחזור → 5 ירוק. analyze 0. catalog_price_units (18%) + product_journey (935 sheets) נשארו ירוקים (ערכי-המבחן <1000 → ללא-פסיק; 935 הכרטיסים מרונדרים בלי-overflow גם עם פסיק).

## #pillar2-restore-s41-50 — שחזור-מאוחד + mutation על מנוע-הייבוא — 2026-07-06
- **הרקע:** הקונטיינר גלגל-לאחור את היסטוריית-ה-git (commits s41-s50 נעלמו מקומית ומעולם לא נחתו ב-origin); התוכן שרד על הדיסק, גובה בייטים, ונחת-מחדש כ-commit-מאוחד על ה-tip החי. הקבצים הלוגיים בדיף: `lib/domain/trade_import.dart` (חדש — מנוע-הייבוא) · `install_engine` (תפר-s41, מכוסה ב-6 בדיקות-חוזה) · `trades_store` (mutators, מכוסים בבדיקות-המסכים).
- **טסט-נעיצה:** `bulk_import_test` — 8 בדיקות (תבנית · תקין-מלא · כותרת-רעה · שדה-חסר · **מק"ט-כפול בקובץ+מול-store** · קטגוריה-לא-קיימת R2-7 · ערך-מחוץ-לסכמה · אטומיות-store).
- **mutation-verify:** baseline 8 ירוק → נטרול תנאי-הכפילות (החלפת הבדיקה בתנאי-שקר קבוע) ב-`trade_import.dart` → הבדיקה `duplicate sku — in-file AND vs the store` **אדומה** → שחזור → 8 ירוק. analyze 0.

## #huliot-catalog — קטלוג-חוליות אדיטיבי מאחורי דגל CATALOG_SOURCE — 2026-07-19
- **הרקע:** הוספת ~789 מוצרי-חוליות חדשים (`data/huliot_catalog.dart`) + staging `catalogProducts_v2` + דגל `CATALOG_SOURCE` (`data/catalog_source.dart`), עם seam בריפו (`catalog_local.dart`) ומיפוי brand ב-`lipskey_catalog.dart`. אדיטיבי — ברירת-מחדל v1 זהה-בייט, v1 שלם ל-rollback.
- **הצלב-אמת (לא regex):** ה-1,346 מק"טי-הסקרייפ הוצלבו מול הקטלוג הממומש (1,867 מוצרים ב-3 מבנים: lipskey מילולי · polyroll `ppr()` · smartlock `_sl()`) → 557 כבר-קיימים (390 פולירול + 167 smartlock) **הוחרגו** למניעת כפילות · 789 חדשים נוספו. תקינות: כל 474 הפניות-ה-smart_tree מגובות → **0 שבורות** (ה"167 שבורות" היה ארטיפקט של `grep 'sku:'` שפספס את המק"טים המיוצרים).
- **טסט-נעיצה:** `huliot_catalog_test` — 6 בדיקות (789 תקינים · **אפס-חפיפה מול הקטלוג** · **אין מק"ט כפול** · v2=v1+789 · נתיב-תמונה `huliot/products/{sku}.jpeg` · המנועים compat/variant לא קורסים על חוליות).
- **mutation-verify:** baseline 6 ירוק → הזרקת מק"ט-כפול (sku של רשומה #2 הושווה ל-#1) ב-`huliot_catalog.dart` → הבדיקה `no duplicate SKUs within the new Huliot set` **אדומה** → שחזור (regen) → 6 ירוק. analyze 0. הבדיקה גם תפסה בזמן-אמת את הניסיון הנאיבי (כל 1,346 כולל 557 חפיפות) ככשל `zero SKU overlap`.

## #huliot-image-overrides — 512 עדכוני-תמונה שבחר-הבעלים למוצרים קיימים (v2) — 2026-07-19
- **הרקע:** ההורדה (Wayback) מכילה 4–6 תמונות למק"ט; ה-#0 הראשי כמעט תמיד באנר/לוגו, ותמונות-המוצר האמיתיות הן הממוספרות (`{sku}_N.jpeg`). התמונות הנוכחיות (פולירול/smartlock) הן קרופי-עמוד זעירים (~100px, 2–5KB); הסקרייפ נותן 400×400/500×700. הבעלים סקר 145 משפחות (`image-picker.html`) ובחר את הנכונה ל-134 → 512 מוצרים לשדרוג.
- **הלוגיקה (`data/catalog_source.dart` · `data/huliot_image_overrides.dart` · `lipskey_catalog.dart` → גייט 42/44):** מפת `kHuliotImageOverrides` (512 sku→`assets/huliot/products/{sku}_N.jpeg`); שדה אופציונלי חדש `imageAssetOverride` (null בכל v1 → זהה-בייט) שגובר על נתיב-brand-dir **בלי** לשנות brand; `_withOwnerImage` ב-`kCatalogProductsV2` מחיל אותה. v1 לא-נגוע, שלם ל-rollback. ברירת-מחדל v1.
- **טסט-נעיצה:** `huliot_catalog_test` — `owner image overrides (existing products, v2 only)`: 512 overrides ב-v2 · v1 נקי · מוצר-מעודכן פותר ל-`assets/huliot/products/` והמותג נשמר.
- **mutation-verify:** baseline ירוק → `_withOwnerImage` שונה ל-`return p` תמיד (מתעלם מ-override) → הבדיקה `512 overrides applied in v2` **אדומה** (0≠512) → שחזור → ירוק. analyze 0.
- **הרחבה (בחירות-הבעלים למוצרים החדשים):** משחק-השיבוץ (`image-game.html`, 82 קבוצות) → 714 מהמוצרים החדשים קיבלו את תמונת-המוצר שהבעלים בחר (במקום ה-#0 שלרוב באנר), 75 → `imageFile=null` (בחר "אין" → אמוג'י). מקודד ב-`huliot_catalog.dart` (regen); הבדיקה `789 new products; 714 with an owner-picked image` נועצת את הספירה 714. mutation: הפיכת "אין"→ברירת-מחדל תפיל את ספירת-ה-714.
- **הרחבה (תמונות ליפסקי):** `lipski_image_replacements.csv` (274 שורות) → 248 מוצרי ליפסקי/AQUATEC קיבלו `imageAssetOverride` לתמונת-האתר האמיתית (`lipski_site/photos_1200/`, מאומת קיים ב-R2; fallback ל-extra כש-att-photo לא הועלה). map נפרד `kLipskiImageOverrides`, מוזג ב-`_withOwnerImage`. הבדיקה נועצת 248 + huliot∩lipski=∅. mutation: הורדת ערך מהמפה תפיל את ספירת-ה-248.

## #activate-images — 760 שדרוגי-תמונה עלו לחי (v1), לא רק v2 — 2026-07-19
- **הרקע:** הבעלים ביקש "תפעיל את התמונות הטובות". ה-overrides ישבו ב-`kCatalogProductsV2` בלבד (מאחורי `CATALOG_SOURCE=v2`), אבל ~50 צרכנים קוראים `kCatalogProducts` **ישירות** (floating_card_keyboard · store_dashboard · lipskey_brand_screen · ai_finder · dive_pool · catalog_slice/paged · catalog_screen) → הדלקת-הדגל לבדה הייתה מראה תמונות ספורדית.
- **הלוגיקה (`data/polyroll_catalog.dart` → גייט 42/44):** שיבוץ-התמונות עבר למקור: `kCatalogProducts` ממופה `for (final p in _kCatalogRaw) _withOwnerImage(p)` — `_withOwnerImage` מחיל `kHuliotImageOverrides[sku] ?? kLipskiImageOverrides[sku]` כ-`imageAssetOverride` (brand + כל שדה נשמרים; SKU/ספירה ללא-שינוי 1,867). `catalog_source.dart` פושט: `kCatalogProductsV2 = [...kCatalogProducts, ...kHuliotProducts]` (יורש). המנועים לא קוראים imageAsset (related_info 1 ref · dive/install 0) → בטוח. התמונות זורמות מ-R2 (NetworkImage) — לא נדרש קובץ-בדיסק.
- **טסט-נעיצה:** `huliot_catalog_test` — `760 overrides (512 huliot + 248 lipski) applied LIVE in v1`: הסט `{p.sku : kCatalogProducts if imageAssetOverride!=null}` == 760, מכיל את כל מפתחות-שתי-המפות, ו-v2 יורש בדיוק אותם. `brand_profile_parity_test` עודכן: בודק מוצר-פולירול עם imageFile ו**בלי** override (ה-_brandDir נשאר מכוסה; override לגיטימי מפנה imageAsset לתיקייה אחרת).
- **mutation-verify:** baseline 4891 ירוק → `_withOwnerImage` שונה ל-`return p` תמיד (`if (override==null || true)`) → הבדיקה `760 overrides applied LIVE in v1` **אדומה** (Expected 760, Actual 0) + `resolve to the chosen image` אדומה (חזרה ל-`huliot_smartlock/sml_p27_c.jpg` הזעיר במקום `huliot/products/60150331.jpeg`) → שחזור → 8/8 ירוק. analyze 0 errors.

## #fitting-images — 24 שיבוצי-תמונה חדשים למוצרים שהיו ללא-תמונה (net-new) — 2026-07-19
- **הרקע:** הבעלים שייך 14 תמונות-פיטינג גנריות אמיתיות (מהגלריה הממוספרת) ל-61 SKU. הצלבה מול המפות הקיימות: **37 SKU כבר נשאו תמונת-picker** (חלקן בייט-זהות לבחירה החדשה) → נשמרו כמו-שהם (לא-לדרוס); **24 היו ללא-תמונה** → מקבלים עכשיו את התמונה שהבעלים בחר למשפחה.
- **הלוגיקה (`data/fitting_image_overrides.dart` + `polyroll_catalog.dart` → גייט 42/44):** מפת `kFittingImageOverrides` (24 sku→`assets/huliot/products/{img}.jpeg`, כל נתיב מאומת R2=200); מוזגה ב-`_withOwnerImage` בעדיפות-אחרונה (`huliot ?? lipski ?? fitting`) → פיקים קיימים גוברים. brand + כל שדה נשמרים; ספירה 1,867.
- **טסט-נעיצה:** `huliot_catalog_test` — `784 overrides ... LIVE` (512+248+24 · fitting∩huliot=∅ · fitting∩lipski=∅) + `24 fitting overrides fill net-new SKUs` (imageAsset==הבחירה · כל מפתח-fitting לא-ב-huliot).
- **mutation-verify:** baseline ירוק → הסרת `?? kFittingImageOverrides[p.sku]` מ-`_withOwnerImage` → הבדיקה `24 fitting overrides` **אדומה** (imageAsset חוזר לנתיב brand-dir) + ספירת-784 **אדומה** (760) → שחזור → ירוק. analyze 0.

## #ultra-silent-images — 70 מוצרי Ultra Silent חדשים קיבלו תמונה (משחק-שיבוץ שני) — 2026-07-19
- **הרקע:** 75 מוצרי הקו האקוסטי Ultra Silent (brand='Huliot', בלי fallback → אמוג׳י) לא היו במשחק הראשון. התמונות שלהם היו על R2 כל הזמן (`huliot/products/{sku}_N.jpeg`) — פשוט לא הורדו מקומית לסט-המשחק. משחק-שיבוץ שני (`ultra-silent-game.html`, 48 משפחות) → הבעלים בחר 46, 2 ענה "אין".
- **הלוגיקה (`data/huliot_catalog.dart` → גייט 42/44):** הזרקה כירורגית של `imageFile` ל-70 הרשומות שהבעלים בחר (SKU→קובץ מ-`us_sku2file`, כל 46 הקבצים הייחודיים מאומתים R2=200; אין regen → אפס-drift, diff=70 שורות בלבד). brand='Huliot' ⇒ imageAsset=`assets/huliot/products/{file}`. 789 מוצרים ללא-שינוי; 714→**784** עם תמונה; 5 (2 משפחות "אין") נשארו אמוג׳י.
- **טסט-נעיצה:** `huliot_catalog_test` — `789 new products; 784 with an owner-picked image` (הספירה 784).
- **mutation-verify:** baseline ירוק → הסרת שורת `imageFile` מרשומה אחת (5901100100) → הבדיקה **אדומה** (Expected 784, Actual 783) → שחזור (re-insert 70) → 9/9 ירוק. analyze 0.

## #manager-dashboard-live-kpi — 4 מדדי-לוח מזויפים → קריאות-קטלוג/מלאי חיות — 2026-07-20
- **הרקע (הנחיה `DIRECTIVE-manager-console-live.md` · מאומת file:line):** טאב 📊 לוח-בקרה הראה 4/5 מספרים קבועים-בקוד (`kManagerStores` "3/3" · `kManagerCatalogCategories` 148/202) **גם כשהבקאנד חי**, כי `managerAnalyticsProvider` קרא קבועים במקום repo. באג-קוד, לא דגל.
- **הלוגיקה (`state/orders_engine.dart`):** `managerAnalyticsProvider` עכשיו `watch`-ים את `catalogRepositoryProvider` (📦/🧰/✅ — ספירה-לפי-קטגוריה חיה מ-1,867 מוצרי-הקטלוג האמיתיים; קטגוריות-'אביזר' מקופלות ל-bucket שהאנליטיקה כבר קוראת → accessory 264 / catalog 1,603 / available 1,867) + `stockRepositoryProvider` (🏪 — seed מקומי 3/3, **ריק-כן על backend חי**). אפס-קבוע-מזויף: מקור-ריק → ריק-כן (עקרון ההנחיה). `ManagerAnalytics` **לא-שונה** → כל בדיקות-ה-const נשארו ירוקות.
- **טסט-נעיצה:** `manager_dashboard_screen_test` — `the 5 mdMetric tiles render their LIVE numbers`: עוגן למקור-החי (`totalProducts == catalogRepository.allProducts().length`, accessory == ספירת-קטגוריות-'אביזר'), בלי literal.
- **mutation-verify:** baseline 30 ירוק → `catalogCategories: catCounts` ↦ `kManagerCatalogCategories` → הבדיקה **אדומה** (Expected 1867, Actual 202) → שחזור → 30 ירוק. analyze 0.

## #manager-dashboard-live-pill — חיווי "חי" קבוע → סטטוס-קישוריות אמיתי — 2026-07-20
- **הרקע (הנחיה `DIRECTIVE-manager-console-live.md` · פריט 3):** `_LivePill` הציג "חי" **קבוע** תמיד — גם כשמנותק/דמו. חיווי-שקר.
- **הלוגיקה (`screens/manager_dashboard_screen.dart`):** `_LivePill` → `ConsumerWidget` הקורא `connectionStatusProvider` (התשתית הקיימת — אותה אמת-קישוריות ש-`connection_indicator` קורא): 🟢 חי (connected) · 🔴 מנותק (disconnected) · אפור דמו (demo/test). `_Dot` פורמט לצבע-לפי-מצב. אפס "חי" מזויף.
- **טסט-נעיצה:** `manager_dashboard_screen_test` — `title + subtitle + live-status pill`: במסלול Firebase-free (demo) הפיל = 'דמו', לא "חי".
- **mutation-verify:** baseline ירוק → `status = ConnectionStatus.connected` קבוע (מתעלם מה-provider) → הבדיקה **אדומה** (0 'דמו' — הראה 'חי') → שחזור → ירוק. analyze 0.

## #manager-dashboard-drill — 5 אריחי-KPI + שורות-pipeline → drill לטאב הרלוונטי — 2026-07-20
- **הרקע (הנחיה `DIRECTIVE-manager-console-live.md` · פריט 2):** אריחי-ה-KPI ושורות-ה-pipeline לא היו לחיצים (`onTap` חסר) — מבוי-סתום.
- **הלוגיקה (`screens/manager_dashboard_screen.dart`):** `_MetricTile` + `_PipelineRow` קיבלו `onTap?` אופציונלי (עטיפת `InkWell` שקוף באותו radius + `Semantics.button`; `null` ⇒ לא-אינטראקטיבי, golden-safe). `_MetricGrid` + `_OrderPipeline` → `ConsumerWidget`, מחווטים דרך `managerTabProvider`: 🚚→טאב-הזמנות(1) · 📦/🧰/✅/🏪→טאב-ניהול(3) · שורות-pipeline→טאב-הזמנות(1). (סינון-לפי-שלב ב-drill נדחה: ה-filter של טאב-הזמנות הוא state מקומי — refactor מסוכן לטאב-עובד.)
- **טסט-נעיצה:** `manager_dashboard_screen_test` — `KPI tiles drill down`: לחיצה על 🚚 ⇒ `managerTabProvider==1`, על 📦 ⇒ `==3` (הניווט באמת קורה).
- **mutation-verify:** baseline ירוק → 🚚 `onTap: go(1)` ↦ `go(0)` → הבדיקה **אדומה** (Expected 1, Actual 0) → שחזור → ירוק. analyze 0.

## #fake-sweep-batch-1 — S4 ספירת-ספקים · H3 העתקת-קוד · F1-F4 גידור-פיננסים — 2026-07-20
- **הרקע (הנחיה `DIRECTIVE-fake-data-sweep.md`, נחיל 9×9 · 4 מאמתים מול קוד-חי @HEAD 51897dd6):** באטצ'-1 = 3 התיקונים הבטוחים-מאומתים (S4 ספירת-ליפסקי "66"→const `kLipskeyProductCount` ב-lib/data · gate-114-safe · H3 כפתור-שיתוף שהבטיח "הועתק" בלי `Clipboard` · F1-F4 4 מספרי-דמו-פיננסיים מגודרים בתבנית-ה-FX + 4 CfgText-ids חדשים ברישום). ~15 מ-24-האתרים קרסו באימות ל-DONE/legacy-faithful/false-positive/F-48 — ראה `_findings`.
- **שיטת-האימות (byte-conformance במקום widget-test — פרופורציונלי לתיקוני-תצוגה):** 6 חוקי-בייט חדשים ל-`buildsmart.conformance.txt` — `suppliers_screen:::kLipskeyProductCount` + `:::!66 מוצרים` + `lipskey_catalog:::kLipskeyProductCount` · `rewards_hub_screen:::Clipboard.setData` · `finance_hub_sheets:::roi_server_note` + `:::index_server_note`. השער (`central-verify --assert`) אוכף אותם אוטומטית. (S4 קיבל גם טסט dart אמיתי — `lipskey_product_count_test`.)
- **mutation-verify (מבוצע):** baseline 13/13 חוקים ירוקים → הזרקתי `$kLipskeyProductCount מוצרים`↦`66 מוצרים` → `assert-manifest` **אדום** (present-check kLipskeyProductCount FAIL + absent-check '66 מוצרים' FAIL, exit 1) → שחזור → 13/13 ירוק (exit 0). הגארד תופס את-בדיוק-הרגרסיה שהוא שומר.
- **אימות נוסף:** analyze 0 errors · `studio_registry_view_test` ירוק (4 ה-ids החדשים grounding נכון בחוזה-הרישום) · `phaseb_seeds_test`/`backend_flag_test` ירוקים (מסלול-OFF ללא-רגרסיה) · הסוויטה המלאה (2314+ טסטים) ירוקה.
- **סיכון-מקובל מתועד:** (1) פיננסים מסלול-ON (בקאנד-דלוק, מה שהבעלים רואה) חסר-כיסוי-בדיקה — זהה-בדיוק לתקדים-ה-FX ששוגר כך; אימות דורש עין-הבעלים על הבניה-החיה. (2) H3 clipboard לא-mutation-tested התנהגותית (יידרש mock-channel כמו `camera_sheet_capture_test`); הגארד הנוכחי = present-check על `Clipboard.setData`.

## #fake-sweep-store — S1 הסרת-5-הזמנות-דמו · S2 הסתרת-צ'יפ-הצעות · S3 אריח-הזמנות-חי — 2026-07-20
- **הרקע (הנחיה `DIRECTIVE-fake-data-sweep.md` · מאמת-B @HEAD 6ac38592):** `store_screen.dart` — (S1) `storeOrdersProvider` מיזג 5 הזמנות-דמו const (`_kContractorDemoOrders`, BS-1234...) שזיהמו את מונה "ההזמנות הפתוחות"; (S2) צ'יפ `📨 3 הצעות ספקים` const לא-מגודר; (S3) אריח `📦` עם `#1234`/badge-1 קבועים.
- **הפתרון:** S1 מחיקת ה-const + פרוביידר מחזיר `engineOrders.where(createdAt!=null)` בלבד. S2 גייט `if(!kHideUnderConstruction)`. S3 גזירה חיה `ordersPreview`/`openOrdersCount` מ-`storeOrdersProvider` ב-`.map` (tuple 5-שדות זהה ל-🛒).
- **טסטים שוכתבו להתנהגות-אמת (3):** `state_deep_test` 'seed 3 open'→'fresh contractor empty ⇒ 0 open' · `store_notif_widget_test` מציב הזמנה-אמיתית id BS-1234 (במקום const) ואז גיליון-מעקב · `global_search_sources_test` מציב הזמנה-אמיתית BS-7777 בקונטיינר-מפורש (UncontrolledProviderScope) כדי לשמר את כיסוי מקור-החיפוש 'orders'. כולם ירוקים + `apple_readiness_hide_pass:191` (אריח-📦 גלוי-לפי-כותרת) ירוק.
- **mutation-verify (מבוצע):** גארד-בייט `store_screen.dart:::!_kContractorDemoOrders` — הזרקתי `_kContractorDemoOrders` בחזרה → `assert-manifest` **אדום** (should-be-absent x1, BYTE-CHECK FAILED) → שחזור → ירוק. הפולשן ל-`הסל שלי`/`~/ 1000}`/`lineSubtotal` נשאר תקין.
- **אימות נוסף:** analyze 0 · 4 קבצי-טסט מושפעים ירוקים · גארדי-בייט חדשים: `!_kContractorDemoOrders` (S1) + `ordersPreview` (S3). הסוויטה המלאה — נבדקת בשער-ה-commit.

## #fake-sweep-M2 — אשראי-לקוח: hash-מהשם → אמת-מהשרת / "לא רשומה" (החלטת-בעלים 1א) — 2026-07-20
- **הרקע (הנחיה `DIRECTIVE-fake-data-sweep.md` · מאמת-credit @HEAD 44c7b019):** מסגרת-אשראי חושבה מ-`contractorCredit(name)`=hash-של-שם (`manager_dashboard.dart:256-264`). מקור-שרת אמיתי (`computeCredit`/`customerCreditProvider`) כבר-בנוי אך המסלול-המקומי המציא את ה-hash. תובנת-המפתח: הארכיטקטורה-הכנה כבר קיימת בצד-Firebase; הבאג היה רק במסלול-המקומי/דמו.
- **הפתרון (3 קוד + 3 טסט):** A1 `mgrCustomerList:282`→`creditLimit:0` (הרחב-ביותר: כרטיס/גיליון/view-model/fleet/copilot/flicker). A2/A3 `customers_local` `creditLimit()`→0 ו-`_localCredit` ceiling-0 עם used/orderCount אמיתיים. B4-B7 תצוגה `<=0?'לא רשומה'/'—'`. **`contractorCredit` נשמרה** (נעולה כ"ערך-אסור" ע"י `credit_never_invented_test`).
- **טסטים שוכתבו (3):** `orders_credit_a13_callable_test` (`expect(r.creditLimit,0)` במקום `==contractorCredit`) · `manager_credit_computecredit_consumer_test` (OFF מציג 'לא רשומה', 999999 findsNothing) · `manager_dashboard_screen_test` (כרטיס 'אשראי: לא רשומה' + סטטוס 'לא פעיל'; הסרת ÷0 ב-KEYSTONE :614; **שכתוב פילטר-האשראי-הגבוה** — `pumpScreen` קיבל param `overrides`, והבדיקה מזריקה תקרה-אמיתית ליוסי כהן דרך `managerCustomersProvider`+`customerCreditProvider` overrides, מדגים שהתג/פילטר עובדים על נתוני-אמת).
- **mutation-verify (מבוצע):** גארד `manager_dashboard.dart:::!creditLimit: contractorCredit` — הזרקתי `creditLimit: contractorCredit(o.who)` בחזרה ל-:282 → `assert-manifest` **אדום** (should-be-absent x1) → שחזור → ירוק (`creditLimit: 0` count 1).
- **אימות נוסף:** analyze 0 · **96 בדיקות-אשראי ירוקות** כולל `credit_never_invented` (הנעילה) + הפילטר-המשוכתב · גארדים חדשים: `!creditLimit: contractorCredit` + `אשראי: לא רשומה`. הסוויטה המלאה — בשער-ה-commit.
- **סיכון-מקובל מתועד לבעלים:** תג/פילטר "⚠️ אשראי גבוה" רדומים בדמו (היו מבוססי-hash; יֵצְאוּ רק על תקרת-שרת אמיתית). מסלול-ON (בקאנד-דלוק, מה שהבעלים רואה) — התצוגה כעת כנה; אימות-חי דורש עין-הבעלים.

## #fake-sweep-rewards — תווית "(דמו)" ללוח-מובילים · תגים · קוד-הזמנה (הנחיה-2) — 2026-07-20
- **הרקע:** `rewards_hub_screen.dart` — לוח-מובילים (דירוג חי, מתחרים const-מזויף), תגים "2/4" (earned קבוע, אין tracker), קוד `BUILD-7K29` משותף מוצג כ"שלך". `legal_texts.dart:42` מגלה משפטית שמסכי-דמו מסומנים → חובה תווית.
- **הפתרון:** 3 שורות `_ServerNote` (Text רגיל, אין CfgText/רישום) :209/:247/:346. תווית-בלבד — const לא-נגעו.
- **mutation-verify (מבוצע):** גארד `rewards_hub_screen.dart:::דירוג חי מהשרת` — הסרתי את התווית → `assert-manifest` **אדום** (should-be-present) → שחזור → ירוק (count 1).
- **אימות נוסף:** analyze 0 · `t3_ghi_rewards_ai_home_test` ירוק (asserts const values/lengths, לא render) · אין טסט שמרנדר RewardsHubScreen. site_hub_screen נדחה. שער מלא בשער-ה-commit.

## #fake-sweep-courier-supplier — גידור צי/דירוגים/זמינות + שורות "יתחבר עם השרת" (הנחיה-2) — 2026-07-20
- **הרקע:** פורטל שליח/ספק — שורות-דאטה מזויפות (kFleet/kSupplierRatings/kHaulAvailabilityDemo) רונדרו ללא-תנאי; רק תוויות ה-_note מגודרות → ב-review אפל מזויף-בלי-תווית (F-48). אין מקור-חי (const-דמו) → גידור.
- **הפתרון:** courier — זמינות מגודרת בשורה (מחיר נשאר), kFleet מגודר; persona — kSupplierRatings+kFleet מגודרים יחד-עם-התווית + `else` שורת "יתחבר עם חיבור השרת"; courier :219 בלי "בדמו".
- **mutation-verify (מבוצע):** גארד `persona_portal.dart:::דירוגי ספקים חיים יתווספו` — הסרתי את שורת-ה-else → `assert-manifest` **אדום** (should-be-present) → שחזור → ירוק (count 1).
- **אימות נוסף:** analyze 0 · 0 שינויי-בדיקה — `t9_supplier_personas` (const kFleet.first.driver) לא-מושפע · `apple_readiness_hide_pass` ירוק (התוויות נשמרו). גארדים: else-rows של persona. שער מלא בשער-ה-commit.

## #fake-sweep-finance-approval — חיווט תור-אישורים לריפו (server-אמיתי) + F7 ניקוי-הערות (הנחיה-2) — 2026-07-20
- **הרקע:** `approvalQueueProvider` תמיד זרע מ-`kApprovalQueue` (דמו) → גם על השרת אישורי-רכש מזויפים. impl אמיתי (`FirebaseFinanceRepository.approvals()/decide()`) קיים אך לא-מחובר.
- **הפתרון:** 3 חברי-ממשק `FinanceRepository` (approvals/decide/approvalsListenable); Local=זרע-דמו, Firebase=Firestore + listenable; `ApprovalQueueNotifier` ctor-אופציונלי זורע+מתעדכן מ-`financeRepo()`, decide נכתב-כפול, dispose מסיר listener; provider=`ApprovalQueueNotifier(financeRepo())`; מחיקת dual-write ידני. F7: 4 הערות בלי "כאן מוצגים נתוני דמו" (+4 labelHe). מחזור-import Dart-legal (analyze נקי). Slice B (4 ערכים) דולג — אין מקור-אמת (החלטת-בעלים).
- **mutation-verify (מבוצע):** גארד `finance_hub_state.dart:::_repo?.decide` — הסרתי את הכתיבה-לריפו → `assert-manifest` **אדום** (should-be-present) → שחזור → ירוק (count 1).
- **אימות נוסף:** analyze 0 · **98 בדיקות ירוקות** — finance_hub_state (ctor-אופציונלי שומר no-arg ירוק) · budget_server_empty (_FakeFinanceRepo +3 stubs) · finance_firebase_repo · studio_registry_view (labelHe) · phaseb_seeds (לא-נגע). גארדים: approvals() + _repo?.decide + !"כאן מוצגים נתוני דמו". שער מלא בשער-ה-commit.
- **סיכון-מקובל:** מסלול-ON (בקאנד-דלוק, מה שהבעלים רואה) — אישורים אמיתיים; אימות-חי-סופי דורש עין-הבעלים על הבניה + נתוני Firestore אמיתיים.

## #fake-sweep-site-hub — תווית "(דמו)" ל-4 מקטעי-האתר הזרועים (/swarm) — 2026-07-20
- **הרקע:** `site_hub_screen.dart` — 4 const-דמו (kSiteTree/kSiteDeps/kSitePhotoPairs/kArchivedProjects) כמצב-אתר-חי בלי תווית; `legal_texts.dart:42` מחייב סימון. מאמת: כל 4 דמו-בלבד, WIRE בלתי-אפשרי; מלכודת archive→kProjects נמנעה.
- **הפתרון:** ווידג'ט מקומי `_SiteServerNote` (העתק `_ServerNote` של תגמולים, Text רגיל אין-רישום) + 4 שורות-תווית מתחת לראש כל מקטע. const לא-נגעו.
- **mutation-verify (מבוצע):** גארד `site_hub_screen.dart:::class _SiteServerNote` — הסרתי את הווידג'ט → `assert-manifest` **אדום** (should-be-present) → שחזור → ירוק (count 1).
- **אימות נוסף:** analyze 0 · phaseb_seeds_test+site_hub_state_test ירוקים (נועלים values/lengths) · apple_readiness (allowlist) · אין widget-test למקטעים. 1 קובץ, 0 שינויי-בדיקה. שער מלא בשער-ה-commit.

## #stage2-slice-A — חוסן: סבילות-דאטה + רשת-ביטחון (חוקי-ברזל 1+3) — 2026-07-24
- **הרקע (שלב-2, `DIRECTIVE-buildsmart-clean §2` · 4 מאמתים):** הבסיס כבר עמיד ברובו; 4 חורים: F1 פענוח-הזמנות whole-payload (רשומה-פגומה-אחת מחקה הכל) · F2 מטמון-קטלוג-פגום קורס לפני ה-bundled · G3 errorBuilder ברירת-מחדל null · F3 share_log לא-מגודר.
- **הפתרון:** F1 פר-רשומה (idiom ה-queue) + all-corrupt→seed · F2 שתי עטיפות decode→cache-MISS · G3 `_productImageErrorFallback` · F3 getInstance-בפנים + persist מגודר. 2 קבצי-בדיקה חדשים ב-required-tests.
- **mutation-verify (3/3 מבוצע):** (1) orders: `if (1==2) list.add(...)` ↦ סימולציית-skip-all → `stage2_data_tolerance` **אדום** (-2) → שחזור → ירוק. (2) catalog_sync: debugPrint↦`rethrow` → `stage2_safety_net` **אדום** (-2) → שחזור → ירוק. (3) product_images: הסרת `?? _productImageErrorFallback` → **הבדיקה המקורית נשארה ירוקה — נתפסה חלשה!** (תזמון-asset לא-דטרמיניסטי) → הוחלפה בבדיקת-חיווט דטרמיניסטית (img.errorBuilder isNotNull + builder→SizedBox 0×0) → מוטציה **אדומה** (-1) → שחזור → ירוק 14/14. לקח: mutation-verify תפס בדיקה-שלא-יכולה-להאדים — בדיוק תפקידו.
- **אימות נוסף:** analyze 0 · 89 בדיקות (חדשות+שכנות-נעולות: orders_engine/catalog_sync/offline_queue/finance_repo/cached_repo) ירוקות · 4 גארדי-בייט חדשים ב-conformance · שער מלא בשער-ה-commit.
- **סיכונים-מקובלים מתועדים:** G4 (ErrorWidget.builder) דולג — invariant מסלול-דמו · S21 (~40 getInstance) defer · site-mapper מכוסה ע"י מנגנון-הבסיס (generic pin) + הוכחת-mapper-אמיתי דרך orders+finance.

## #stage2-slice-B — קנה-מידה: גבולות-מאזינים + רשימות-עצלות (חוק-ברזל 4) — 2026-07-24
- **הרקע (מיפוי-סקייל):** בבניה-עם-שרת, מאזינים מושכים אוספים שלמים לנצח — chatMessages (כל ההודעות של כולם, לכל לקוח) הצומח-ללא-גבול היחיד; + 2 רשימות-eager. הקטלוג-הארוז non-issue.
- **הפתרון:** B1 `bound:` transformer אופציונלי (נפרד-מ-scope, לא-נוגע-isScoped, null=zero-regression) · B2 chat=newest-500-by-ts (ts נכתב-תמיד) + material_requests/tasks=limit(500)-נקי · **orders מוחרג** (מלכודת-ts מתועדת) · B3 שתי רשימות→builder (store: איחוד-scrollable, פיצול `_pipeline`).
- **mutation-verify (מבוצע):** (1) `descending: true`↦`false` בגבול-הצ'אט → `stage2_scale_test` (named-bounds) **אדום** (-1) → שחזור → ירוק 6/6. (2) **הוכחת-RED חיה של משמר-הגבולות:** בריצה הראשונה הוא תפס 6 קבצי-מקור לא-מתועדים (orders_firebase/studio_config/users_lookup/auth_state/push_state/role_requests) → אדום → תועדו כחריגים-עם-סיבה → ירוק. משמר שיודע להאדים על מציאות אמיתית.
- **אימות נוסף:** analyze 0 · 101 בדיקות ירוקות (scale+screens+repos) · `stage2_scale_test` נוסף ל-required-tests · גארדים: `descending: true).limit(500)` + `_bound`. שער מלא בשער-ה-commit.
- **סיכון-מקובל:** תקרת-500 לצ'אט משנה איזה הודעות-עתיקות זמינות בקאש בת'רדים ענקיים — pagination-פר-thread = היוזמה המתועדת הבאה. גבולות פעילים רק בבניית-שרת (דגלים OFF כברירת-מחדל).

## #stage2-slice-C — בידוד-דייר (חוק-ברזל 2) — 2026-07-24
- **הרקע:** יחידת-הדייר=משתמש; הרשת קיימת אך: 2 אוספים בלי-חוק (נחסמו-בשקט) · customers לא-חתום/לא-סקופי · אפס הוכחה-בבדיקות-אצלנו.
- **הפתרון:** C1 שני בלוקי-חוקים (mirrors מדויקים) · C2 חותמת-ownerId + `_customersScopeFor` (תקדים A3, `kUidScopedQueries`-gated, OFF=בייט-זהה) · בדיקת-3-רמות `stage2_tenant_isolation_test` (required) · מסירת-בעלים ב-LAUNCH_READINESS.
- **mutation-verify (מבוצע ×2):** (א) הסרת `'orgId'` מרשימת-ההקפאה בחוקים → הבדיקה **אדומה** (-1) → שחזור → 12/12. (ב) מחיקת `_ownerUid` → `assert-manifest` **אדום** → שחזור → BYTES VERIFIED. + RED-חי שלישי של משמר-הסקייל (תפס את customers_local) → חריגה-מתועדת.
- **אימות נוסף:** analyze 0 · 50 בדיקות ירוקות (isolation 12 · scale · customers/credit מלא) · גארדי-`../` על קובץ-החוקים בשורש — קובץ-החוקים מוגן-שער מעכשיו. שער מלא בשער-ה-commit.
- **גבול-כנות מתועד:** אכיפת-שרת-חיה לא-ניתנת-להוכחה בסנדבוקס — מסירה מפורשת לבעלים/CI (אמולטור+deploy+דגל-בנייה). **שלב-2 שלם: 4 חוקים × 4 בדיקות-required + חוק-5=השער.**

## #stage3-catalog-unpin — un-pin גשר-מק"טים + חיפוש (באג-רדום v2) — 2026-07-24
- **הרקע (מיפוי-3.1):** הגשר והחיפוש נעולים-v1 בעוד הרשימות v2-aware → תחת CATALOG_SOURCE=v2 מוצרים מופיעים-אך-לא-נפתרים (ברקוד/עגלה/BOM) ולא-נמצאים-בחיפוש. degrade-כן, בלי-קריסה — אבל פיצ'ר-שבור.
- **הפתרון:** 4 החלפות-שורה ל-`resolvedCatalogProducts` (related_info ×3 + fuzzy_search ×1) + imports + תיקוני-doc. זהה-בייטים תחת v1.
- **mutation-verify (מבוצע, ברמת-בייט — התופס הכן לריפקטור שזהה-התנהגותית תחת v1):** re-pin של הגשר ל-kCatalogProducts → `assert-manifest` **אדום** (should-be-absent x1) → שחזור → BYTES VERIFIED. בדיקה-התנהגותית לא-יכולה-לתפוס תחת v1 (אותו אובייקט) — מתועד ביושר; הבדיקה-החדשה הופכת load-bearing תחת v2.
- **אימות נוסף:** analyze 0 · 20 בדיקות-צרכנים ירוקות (fuzzy/huliot_search/barcode/dedup/compat_memo/suggestions) · `stage3_catalog_source_consistency_test` (2/2, נוסף ל-required) · שער מלא בשער-ה-commit.

## #stage3-app-profile — דגל-פרופיל APP_PROFILE (פרוסת-3.4) — 2026-07-24
- **הרקע (מלאי-מלא):** 34 דגלים מפוזרים; ה-Play בונה בלי-דגלים (=דמו); שני ה-live-web workflows חייבים תיאום-ידני. פרופיל-אחד = מקור-אחד.
- **הפתרון:** `app_profile.dart` (13 kProfile* + מראה) + 13 rewires `defaultValue:` ב-8 קבצים. מפורש-גובר (סמנטיקת-fromEnvironment) → אפס-שינוי-workflows; בלי-פרופיל=demo=היום. חימוש-14 הוחרג (governance) · ניסויים/חוגות passthrough.
- **mutation-verify (מבוצע ×3):** M1 default→'buildsmart' → `app_profile_flags_test` **אדום** (-2: demo-pin + literals) → שחזור. M2 עמודת-buildsmart במראה GLOBAL_SEARCH→false → part-b **אדום** (-2) → שחזור → 7/7. M3 strip `defaultValue: kProfileCatalogBaseUrl` → `assert-manifest` **אדום** → שחזור → VERIFIED.
- **אימות נוסף:** analyze 0 · **90 בדיקות ירוקות** (הבדיקה-החדשה + כל סוויטות-נעילת-ברירות-המחדל: backend_flag · gate_123 · email_password_door · app_keyboard_only · finder_front · store_comparison · user_system_flag_off · app_check_providers · floating_card_keyboard(מותאם-שורה) · studio_gating) · סריקת-הסט-הסגור עברה 1:1 (0 לא-מסווגים, 0 stale). שער מלא בשער-ה-commit.
- **הערת-לולאה:** 4 "כשלים" ראשונים היו נתיבים-שגויים בפקודת-ההרצה שלי (Does not exist) — אומתו בנתיב-הנכון, 26/26.

## #stage3-app-brand — AppBrand זהות-חברה במקור-אחד (פרוסת-3.2) — 2026-07-24
- **הרקע:** ~30 מחרוזות "BuildSmart" קשיחות (PDF/שיתוף/מועדון/onboarding/push/בוט/legal/דומיין) — חברה-#2 הייתה דורשת ציד-ידני. הלוגו/palette כבר config (Studio/BsTokens).
- **הפתרון:** `config/app_brand.dart` (name/club/shareDomain, static const) + 30 ניתובים ב-19 קבצים באינטרפולציה-קבועה (כל const נשאר const). CfgText-fallbacks/registry/prompts לא-נגעו. + `BRAND_SWAP_CHECKLIST.md` למעטפות.
- **mutation-verify (מבוצע, התנהגותי):** name→'CleanCo' → `keyboard_destinations_test` **אדום** (-2, אסרטי-מחרוזת-חיים) → שחזור → 19/19. ההוכחה החזקה: שינוי-הקבוע משנה מסכים אמיתיים והבדיקות תופסות.
- **אימות נוסף:** analyze 0 · 85 (סוללה) + 41 (בדיקות-הליטרלים בזמן-ריצה: deep_link/keyboard_destinations/login_sheet) — הכל ירוק ללא-שינוי = הוכחת-זהות-בייטים בפועל. גארדים ×3. שער מלא בשער-ה-commit.

## #stage3-catalog-reroute — ניתוב כל הצרכנים-הישירים (המשך-3.1) — 2026-07-24
- **הפתרון:** ~35 אתרים/9 קבצים → `resolvedCatalogProducts` (3 מתקנים מקבילים + 2 קבצי-data ידניים: task_skus_local נתיב-ברקוד + variant_families). kLipskeyCatalog לא-נגוע. imports יתומים הוסרו.
- **משמר:** סריקת-סט-סגור בבדיקת-העקביות — 18 קוראי-תשתית מותרים בלבד (מסנן שורות-הערה). mutation: re-pin → **אדום** (-1) → שחזור → ירוק.
- **אימות:** analyze 0 · 49 בדיקות-צרכנים (ai_finder/assistant/huliot_render/barcode/lens/dedup) · שער מלא בשער-ה-commit.

## #stage3-setorg — St1+St2 תשתית-ארגונים (callable+claim, רדום) — 2026-07-24
- **הפתרון:** setOrg.ts (אדמיני, merge-claims-only-orgId, users-mirror, audit, charset-guard) + re-export; auth_state: orgIdFromClaims + AuthSnapshot.orgId(null-default) + חילוץ ×2 אתרים + currentOrgIdProvider. הכל additive-רדום.
- **mutation-verify (מבוצע):** orgIdFromClaims↦always-null → `org_claim_test` **אדום** (-1: trimmed-id case) → שחזור → 5/5.
- **אימות:** functions `tsc --noEmit` strict **0** (node_modules הותקן) · flutter analyze 0 · 55 בדיקות (org_claim+auth_state+board_auth_server) ירוקות · 6 אתרי-AuthSnapshot לא-נגעו (null-default) · גארדים ×4 (כולל ../functions — שכבת-ה-functions מוגנת-שער מעתה). שער מלא בשער-ה-commit.
- **גבול-כנות:** ריצת-emulator + פריסה = מסירת-בעלים (שורה נוספה ל-LAUNCH_READINESS §שלב-2/3.3).

## #stage3-org-stamp — St3 חותמות-רשומות (בריאה-בלבד) — 2026-07-25
- **הפתרון:** Order.orgId (A4-idiom) + threading-בריאה placeOrder→checkout · copyWith-משמר (לא-פרמטר) · toDoc-מהמודל-בלבד (הזמנות) / ctor-session מגודר (לקוחות/מלאי — אין diff-קפוא). ללא-claim = זהות-בייטים.
- **mutation-verify (מבוצע):** copyWith↦drops-stamp → `stage3_org_stamp_test` **אדום** (-1: שימור-בקידום) → שחזור → 5/5.
- **אימות:** analyze 0 · 91 בדיקות (org_stamp+orders_engine+cached_repo+uid_a4_a6+customers/stock repos+checkout) ירוקות · גארדים ×3. שער מלא בשער-ה-commit.

## #stage3-org-scope — St4+St5 (דגל+builders+sameOrg) — 2026-07-25
- **הפתרון:** kOrgScopedQueries חדש · ענף-org-מועדף בשני-builders (uid-fallback מילה-במילה, manager/admin נעולים-null) · stock scope-seam ראשון · sameOrg()+6 ענפי-קריאה additive.
- **mutation-verify (מבוצע):** משמר-`!= ''`↦`true` → `stage2_tenant_isolation_test` **אדום** (-1) → שחזור → 13/13. + באג-תחביר-מניפסט נתפס-חי (תבנית-`!`-פותחת=absent) → נוסחה.
- **אימות:** analyze 0 · 58 בדיקות (isolation+profile-sweep+scope-diag+backend_flag+repos+org_stamp) · OFF=זהות (const-fold, אפס-watches) · גארדים ×3. שער מלא בשער-ה-commit.
- **גבול-כנות:** מקרה-חיובי-emulator (token-עם-claim קורא דוק-חתום) + St6-הצמצום = בעלים/CI בלבד.

## #clean-finish — פיננסים-4 + שני-לינקים (DIRECTIVE-clean-finish) — 2026-07-25
- **הפתרון:** 4 הערות מותנות-מצב (דמו מצהיר-דמו · שרת כן-ריק) + labelHe ·· company2-פרופיל + AppBrand מודע-פרופיל ('BuildMax') + wordmark מנותב + workflow שני-ערוצים (dispatch-בלבד).
- **mutation-verify (×2):** clause-דמו-מדד הוסר → גארד-ספציפי **אדום** → שחזור → ירוק. mirror-c2 ux מושמט → app_profile_flags **אדום** (-1) → שחזור → 8/8. + 2 תפיסות-חיות: גארד-workflow (ליטרל-matrix) וגארד-3.2 (name→ternary) נוסחו מחדש.
- **אימות:** analyze 0 · 74 (סוללה) + 8 ירוקים · BYTES VERIFIED מלא · שער-מלא בשער-ה-commit. גבול-כנות: הלינקים-החיים עצמם = ריצת-ה-workflow שלך (secrets ב-CI).
## #clean-empty-shell — שערי-תוכן (קטלוג+זרעים) — 2026-07-25
- **הפתרון:** 2 שערים נגזרים (app_profile) · שער-קטלוג-נקודה-אחת (resolvedCatalogProducts, ענף-clean-ראשון) · 4 fixtures · 10 משפחות-זרעים · 4 config-untouchable · בדיקת-חוזה דו-עולמית `stage_clean_empty_test`(17) + סריקות-סט-סגור ×2.
- **mutation-verify (×2, מבוצע):** M1 קוטביות-הקבוע `= _clean`→`= !_clean` → **אדום** (-2: live-pins + mirror-consistency) → שחזור → ירוק. M2 סחף-מראה (catalogEmptyForProfile += 'company2') → **אדום** (-1: עמודת-המטריצה) → שחזור → 17/17.
- **תקרית-ולקח:** שחזור-M2 בוצע בטעות עם `git checkout <file>` — שמחק גם את תוספות-הקובץ הטרם-committed; שוחזר בייט-בייט מהדיף-המתועד-בשיחה ואומת ירוק (17/17 + מראה-עקביות). **לקח: כשיש עבודה לא-committed, שחזור-מוטציה = היפוך-sed נקודתי בלבד, לעולם לא checkout.**
- **תפיסות-חיות:** NaN.round() ב-_openSubs (0/0 על kSubcontractors ריק — היה מקריס את גיליון-קבלני-המשנה על clean) → משמר `totAlloc > 0` זהה-דמו · ציפיית-dsync-QA הפוכה על clean → מודע-פרופיל · kPaymentTerms זוהה-כ-options ודולג-מגידור.
- **אימות:** analyze 0 · 133 ממוקדות ירוקות · ריצות-מפרופלות: clean 20+skip-מכוון · company2 9 · build-clean ✓ · גארדים ×19 במניפסט. שער מלא בשער-ה-commit.

## #company-catalog-import — משפך תבנית+העלאה אל ה-seam — 2026-07-25
- **הפתרון:** overlay-נקודה-אחת (setCompanyCatalog + גטר-בודק-ראשון, זהות-נשמרת) · hydrate-לפני-runApp (שער clean-בלבד) · domain-טהור (BOM-תבנית · parser-RFC-ish · שגיאות-עברית-פר-שורה · canCommit-אטומי · brand-''-לא-ליפסקי · codec-סובלני) · file_transfer-טריו (אפס-deps) · sheet+2-mounts.
- **mutation-verify (×2, מבוצע):** M1 היפוך תנאי-ה-overlay (isNotEmpty→isEmpty) → `company_catalog_import_test` **אדום** (-2: seam-identity + hydration) → שחזור-sed → ירוק. M2 נטרול בדיקת-dup-sku (`&& false`) → **אדום** (-1: per-row errors) → שחזור-sed → 17/17. (שחזורי-sed בלבד — לקח-ה-checkout מהפרוסה הקודמת מיושם.)
- **אימות:** analyze 0-errors · define-less 17+20 · clean-מפרופל **26** (כולל hydrate-חי: מוצר-מיובא מוגש דרך-הצינור) · company2 17 · רישום-סריקה +2 (store+catalog_screen; אזכור-ה-sheet הערה-בלבד — לא-נרשם) · build-clean ✓ · גארדים ×10.

## #clean-100 — שורות-נגזרות + כנות-מותג (נתפס ב-E2E-דפדפן-אמיתי) — 2026-07-25
- **ה-E2E:** Chromium+Playwright על ה-build הנקי — מסע מלא: welcome→תחום→קרוסלה→בית→sheet→תבנית-ירדה (BOM אומת בבייטים)→קובץ-שבור=3 שגיאות-כנות ('שורה 2 — חסר שם המוצר' · 'מק"ט כפול: BB-2' · 'חייב להיות מספר')→קובץ-תקין='נטענו 3 מוצרים'→רענון→הידרציה חיה ('נטענו 3 מוצרים' על הכרטיס). 3 תפיסות-עין: hero='BuildSmart' על clean · הבטחת-'אלפי מוצרים' על קונכייה-ריקה · שורות-קטגוריות-אינסטלציה על קטלוג-חברה.
- **הפתרון:** `companyCatalogActive` (שער-פעילות, לא-פרופיל — הסוויטה define-less מוכיחה) · `company_categories.dart` טהור (סדר-הופעה-ראשונה=הטקסונומיה-של-החברה · דדופ · אימוג'י-ברירת-מחדל · '$N מוצרים') · 4 נקודות ב-catalog_screen (שורות · סיכומים · 2 עלים-סינתטיים lipskeyCategory=כותרת — הדריל הקיים משרת ללא-שינוי) · welcome hero+terms→AppBrand.name · onboarding body מותנה-פרופיל.
- **mutation-verify (×2):** M1 נטרול ענף-ה-overlay בשורות → rows-test **אדום** (-2) → שחזור → ירוק. M2 השמטת lipskeyCategory מהעלה-הסינתטי → **אדום** (-1: 'בקרוב' חזר) → שחזור-Edit-מדויק → 3/3 + בייט-בדיף אומת (לקח-השחזור מיושם — sed-הפוך שנכשל זוהה מיד בבדיקת-grep).
- **אימות:** analyze 0-errors · 38 define-less (כולל widget_test const-pins ללא-שינוי) · clean-מפרופל 15 · company2 3 · BYTES VERIFIED (8 גארדים חדשים).

## #template-v2 — כרטיס-מוצר מלא מקובץ אחד (סבב-א׳ של ה-100) — 2026-07-26
- **הפתרון:** 4 עמודות-תמונה (קישור-או-שם, | לרשימות) · **כל עמודה לא-מוכרת = שורת-מפרט** (dims פתוח) · codec מרחיב (תמונות שורדות ריסטארט) · URL-passthrough במודל (_isUrl ב-_imgPath+spec) · resolver רשת גם כש-IMAGE_BASE_URL ריק · שער-page>0 · _scanPool (כרטיס: 2 מאגרים על overlay) · _wordHits (הצעות/מילים = אוצר-החברה) · alias-ברקוד ב-2 resolvers (זהות-אובייקט).
- **mutation-verify (×2 + שיעור):** M1 שורה-70 `_isUrl(file)→false` → **אדום** (-1) → שחזור → ירוק. M2 שורה-176 `if (false) openCols…` → **אדום** (-2) → שחזור → 22/22. **שיעור:** שלוש מוטציות-sed קודמות היו no-op (טרנרי רב-שורתי · קדימות `false && a || b` · שורה-שונה-מדיווח-הבונה) — משמעת חדשה: **git-diff-grep לנוכחות-המוטציה לפני כל ריצת-RED** (נאכף בשתי המוצלחות).
- **אימות:** analyze 0 (אחרי תיקון cwd — ריצה קודמת הייתה ירוק-כוזב מחוץ-לתיקייה; לקח: cd מפורש בכל פקודת-שער) · 59 סוללה + 23 v2/ברקוד · clean 32 · company2 22 · BYTES VERIFIED (10 גארדים).

## #connections-pour-in — סבב-ב׳: מוח-החיבורים הוא דאטה (בעלים: "זה נטו מנוע") — 2026-07-26
- **הפתרון:** company_spec_bridge (317 שורות, שיבוט-משמעת-polyroll): קצה-1/2/3→ConnectorEnd עם **קנוניזציית-צול חובקת** ('1/2'/½/0.5→'1/2"' — השוואת-מחרוזות גולמית במנוע) · חומר-ריק+לחיץ⇒אין-מפרט (שומר-הפברוק) · טמפ׳-חסרה⇒40-שמרני · רישום-putIfAbsent + kCompanySpecSkus רק-בהכנסה-בפועל (890-פין) · 2 call-sites בלבד · chainUniverse (6 נקודות-מנוע + 6 מסכים) · isFitting-לפי-שם מגודר · תגי 'לפי נתוני היבוא' ×3 מסכים (מאומת=בייט-זהה).
- **mutation-verify (×2, שתילה-מאומתת בפייתון — לקח-ה-sed מיושם):** M1 השמטת-מרכאת-הצול (שורה-247) → **אדום** (-1: הזדווגות-מידות) → שחזור → 13/13. M2 provenance-בלי-הכנסה (שורה-135) → **אדום** (-1: static-wins) → שחזור → 13/13.
- **תיקון-חי:** const Map<double,…> אסור (double==) → final (נתפס ב-analyze הראשון).
- **אימות:** analyze 0 · 69 סוללה (כולל פין-890 · polyroll · copilot/adapter · install-safety) · 13 גשר-חדשות · clean 13 · company2 13 · BYTES VERIFIED (13 גארדים חדשים). **שיא-הסבב:** שני מוצרים מוגדרי-אקסל-בלבד מתחברים דרך המסלול-המאומת; אי-התאמה מוסברת בעברית.

## #raw-shell — הקונכייה הגולמית (בעלים: "זה לא גולמי") — 2026-07-26
- **הפתרון:** kProfileRawShell (_clean בלבד; BuildMax שומר-הוכחה) + מראה · 9 בונים: 3 הסתרות-בית · דילוג-מקצוע (0→שקפים→בית) · סלוגן-מנוע · מחלקות ריק-כן→נגזר-מ-dims['מחלקה'] (fallback-קטגוריות — טאב-לעולם-לא-מת) · צ'יפי/יעדי-מקלדת נגזרים (הגדרה-אחת, מחוץ-ל-memo) · 4 ליטרלי-BuildSmart→AppBrand · אינדקס-חיפוש 5-מקטעים שומר-סדר (366 מנוע · 17 תוכן).
- **תפיסת-קריסה חוצת-קבצים (R6→אני):** גוזר-המחלקות זורק-בכוונה על החמצת-רישום — על גולמי היה קורס; זרוע-נגזרת נוספה (keyboard_dept_deriver). + באג-פרסור חי: `?[` בתוך טרנרי = טרנרי-מקונן → סוגריים.
- **mutation ×2 (שתילה-מאומתת):** קוטביות-const → אדום(-1) · סחף-מראה(+company2) → אדום(-1) → 11/11.
- **אימות:** analyze 0 · widget/placeholder/onboarding/departments/keyboard×3/rows/registry ירוקות · clean 16 · company2 11 · BYTES VERIFIED (10 גארדים). רישום-צרכנים חדש (9 קבצים) + פין-קוהרנטיות (גולמי⇒קטלוג-ריק).

## #completion-round — סגירת המנועים האחרונים (בעלים: "למה לא הכל?") — 2026-07-26
- **הפתרון:** צינור-משלימים (עמודה→רצועת-🧩 בכרטיס, unknown-נשמט-כן) · משחקים overlay-first (זהות; lazy-final=סדר-האפליקציה) · צ'יפי-סטודיו נגזרים-חיים (capped-7, ריק-כן ללא-ייבוא) · 3 שורות-פרויקטים→שער-זרעים (מקטע-6, demo איבר-זהה) · AI-hub: alt/plan/analytics נשמטים בנקודת-הגזירה (אין-מחיר-במודל=אין-מה-להשוות) · 4 עלי-מקלדת + 3 יעדים-מוקלדים + svc-5 (נקודת-הרינדור האמיתית תוקנה מול הממפה) + 3 שורות-אינדקס-קוסמטיות.
- **mutation ×2 (שתילה-מאומתת):** M1 split '|'→',' → אדום(-1) · M2 kill-overlay-branch ב-kDivePool → אדום(-1: פין-הזהות) → 3/3.
- **אימות:** analyze 0 · 151 define-less · clean 14 · company2 3 · BYTES VERIFIED (8 גארדים) · 2 רישומים הורחבו-במודע (seeds+search_index; rawshell+studio/ai_hub/store).
- **נדחה-סופית-במוצהר (מטבע-שונה):** קבצי-תוכן עתידיים (מסלולים·ערכות) · שרת (מחירים·מלאי·השוואה·שיתוף) · משפחת-kBudget (₪15,000 בתקציב/כספים — DEFER-LARGE הבא אם-יתבקש) · services-typed-UC (פער-Apple-hide קודם).

## #giant-v1 — שכבת-הקונפיג הריצתית (תוכנית-הענק Phase 1/V1) — 2026-07-26
- **הפתרון:** org_config.dart טהור (מודל+default-ריק=הכל-דלוק · codec-סובלני-פר-שדה · resolver-טוטאלי בעלים→חברה→default · moduleOn/featureOn: חסר=דלוק·רק-false·שרשור·core-תמיד · termOf-זהות-fallback) · store משובט-catalog-store (guard-first · corrupt-נשמר-לא-נמחק · persist-bool) · חיווט-boot (הידרציה לפני-הקטלוג + override) · ORG_CONFIG סווג-במודע ל-arming (אטומי עם הקבוע). אפס-צרכנים-חיים ב-V1 = אפס-רגרסיה by-construction.
- **איחוי-חוזה חי:** B הניח toJson — אוחה ל-encodeOrgConfig (אחרת persist-תקין היה נקרא "שבור" מול מעטפת-{"v":1}).
- **mutation ×2 (פייתון-בלבד; ה-classifier חסם בצדק git-checkout בשרשרת — הלקח נאכף):** M1 הסרת-שרשור-הקסקייד → אדום(-1) · M2 היפוך-קדימות-resolver (שמירת-גוף-מקורי לקובץ-צד) → אדום(-1) → 10/10.
- **אימות:** analyze 0 · 37 (pure+store+flags-sweep+stage+brand) · גארדים ×6. חתימות V2/V3 קפואות בדוח-המיפוי.

## #giant-v2-w1 — טוגלים-חיים גל-1 (9 משטחים) + מטריצה — 2026-07-26
- **הפתרון:** org_gates (modOn/featOn — watch-ב-build בלבד) · בוחר-תפקידים (קבלן מוגן-מבנית: לא-במפה+??true) · לוח (צ'אט-3-שכבות · AI-2, בוליאנים-נלכדים ל-itemBuilder) · עדכונים (clamp-בזמן-build נגד ניווט-מוקלט-ישן) · חנות (כספים+שירותים+fallback-כן) · בית (site/stock/compat + שומר-כותרת-ריקה) · פרופיל (מועדון) · **מטריצת-טוגלים** (6 רגליים: כל-מודול-לבד · זוגות-נראות · הכל-כבוי-חוץ-מליבה · core-עוין=זהה · **live-swap**).
- **מלכודת-Riverpod נתפסה ותועדה:** ProviderScope לא מחליף overrides על אלמנט קיים — boot-שני שומר בשקט את הקונפיג הראשון ⇒ UniqueKey-פר-boot במטריצה. + ניווט-בבדיקה: טקסט-הטאב דו-משמעי ⇒ כתיבת-mainTabProvider (המסלול האמיתי :207).
- **mutation ×2:** M1 modOn≡true → אדום(-3) · M2 watch→read → אדום(-1: **רגל-האשף בדיוק**) → 6/6.
- **אימות:** analyze 0 · 100 ירוקות (מטריצה+org+widget+login+apple+store+manager+favorite) · גארדים ×9. גל-2 (מקלדת-כמכלול · search · dive-AND · push-degrade · טאבי-בורדים) — הבא.

## #giant-v2-w2 — המקלדת מצייתת · פוש-מתכלה · בורדים-פנימה — 2026-07-26
- **הפתרון:** KbDestination.gate ('core' ברירת-מחדל · 21 תגים) + kbDestAllowed-טהור + matchDestinations(cfg?)-אופציונלי (רישום נשאר מלא+ref-less — חוט-הביטחון של בדיקת-התוויות) · דרייברים עם בוליאנים-טהורים (servicesOn/chatOn/searchOn/compatOn — סינון לפני-השורש-הזורק) · floating: watch-אחד-ב-build · tool-tree: read-בסגירות + dive-AND (const-ראשון) + שומרי-dispatch לעלים-חסרי-ref ('לא זמין') · search: overlay+אייקון+finder-fallback · פוש-צ'אט: צריכה-חד-פעמית+טוסט-כן ('שיחות אינן פעילות בחברה זו') · clamps בבורדים (ספק tab2→0 · עובד tab1→0, מיפוי-דו-כיווני) · intel מקונן ב-4 אתרי-lockstep (_kManagerTabs-const לא-נגוע).
- **mutation ×2:** M1 kbDestAllowed≡true → אדום(-3) · M2 השמטת-chip-מתה → אדום(-1) → ירוק. (+שתילה-שבורה-פסיק נתפסה-בעין ותוקנה לפני-ריצה.)
- **אימות:** analyze 0 · 152 (מטריצה-8-רגליים כולל search-fallback+push-toast · כל סוללות-המקלדת) · גארדים ×11. **נדחה-במוצהר:** עלי-store חסרי-ref (מגודרי-raw ממילא) · global_search_sources cfg (מסלול-חמוש) · ניסוח-עזרה-worker.

## #giant-v3-w1 — מילון-המונחים: המותג והניווט מצייתים — 2026-07-26
- **הפתרון:** orgTerm/orgTermNow תאומי-termOf ב-org_gates (watch-ב-build · read-לנתיבי-פתיחת-sheet) · שכבת-מונחים ב-CfgText **מתחת** לסטודיו (`n.text ?? termOf(org,id,fallback)` — watch-לא-מותנה, מחוץ לזרוע-העצלה של ??) · 11 המרות אתרי-מותג (brand.name×2 · brand.club×9; AppBrand נשאר-ה-fallback) · 4 תוויות-ניווט → nav.* · טבלת-מפתחות ב-org_config.
- **mutation ×2:** M1 termOf≡fallback → אדום(+1 −5, רק-רגל-ברירת-המחדל שורדת) · M2 היפוך-קדימות (termOf עוטף את n.text) → אדום(+5 −1, **בדיוק** רגל-סטודיו-מנצח) → ירוק +6 · אפס-שאריות.
- **אימות:** analyze 0 · 59 ירוקות (org_terms-6 · מטריצה-8 · widget · login · app_brand · help · safety) · גארדים ×11.

## #giant-v4 — חבילות-ורטיקל: מנגנון-החלה דטרמיניסטי — 2026-07-26
- **הפתרון:** VerticalPack const + kVerticalPacks (6, רשימת-התוכנית) + applyVerticalPack = החלפה-מלאה של terms+modules, שימור-השאר. תוכן=נקודות-פתיחה (compat כבוי רק היכן שהוא עובדת-דומיין).
- **mutation ×2:** M1 merge-במקום-replace → אדום(+5 −2: אפס-שאריות+הפיכוּת) · M2 orgName נמחק → אדום(+5 −2: שימור+הפיכוּת) → ירוק +7 · אפס-שאריות.
- **לקח:** קובץ-חדש-לא-נעקב ⇒ git-diff ריק — אימות-שתילה ב-grep ישיר על הקובץ (ה-assert הפייתוני נשאר השומר הראשון).
- **אימות:** analyze 0 · 17 ירוקות (packs-7 + org_config-10) · גארדים ×7.

## #giant-v5 — אשף-ההקמה: שמירה-מולחמת ונעילה-עצמית — 2026-07-26
- **הפתרון:** מסך-אשף (טיוטה-קנונית · חבילות · 13 מתגים · 6 שדות-מונח · ייבוא/ייצוא-אטומי) + עגינת-ניהול מאחורי kOrgConfigFlag + רישום-תצוגה org_modules (סט-סגור=גל-1).
- **mutation ×2:** M1 persist-מדולג → אדום(+7 −1: בדיוק רגל-ההלחמה — prefs ריק) · M2 kWizardLockedModules ריק → אדום(+6 −2: סט-סגור+מתג-מנהל) → ירוק +8 · אפס-שאריות.
- **אימות:** analyze 0 · 52 ירוקות (אשף-8 · חבילות-7 · store-5 · gate_118 · לוח-מנהל-מלא) · גארדים ×10.

## #giant-v6 — נתיב-החברה האפוי: owner→company→default חי — 2026-07-26
- **הפתרון:** kOrgCompanyJson (passthrough) → hydrate({companyJson}) → resolver; הידרציה בנפילה-דרך-נתיבים (פגום⇒חברה, לא-ריק-מוקדם); שורת-plumbing חמושה ב-clean-two-links (ציטוט-יחיד נגד brace-expansion+רווח-עברי).
- **mutation ×2:** M1 ניתוק-נתיב-החברה → אדום(+6 −2: שתי רגלי-החברה) · M2 החזרת-היציאה-המוקדמת-על-פגום → אדום(+7 −1: **בדיוק** רגל-הפגום+חברה) → ירוק +8 · אפס-שאריות.
- **לקח:** גארד שמתחיל ב-'--' נבלע-כאופציית-grep — תבניות-conformance בלי מקפים-מובילים.
- **אימות:** analyze 0 · 34 ירוקות · גארדים ×8 · yaml.safe_load על ה-workflow.

## #p2-w1a — מנוע-ההתראות: דירוג fan-in מגודר-opt-in — 2026-07-26
- **הפתרון:** attention_engine טהור (Maor homeData לבוש-בנייה) + attention_source (ספק) + featureEnabled/featEnabled (opt-IN חדש) + כרטיס-קוקפיט מגודר `manager.attention`.
- **mutation ×2:** M1 חלוקת-crit-לפני-warn הוסרה → אדום (חשף שהחלוקה הייתה no-op → תיקנתי: אישורים≥8=crit ⇒ דירוג חי ובר-הפרכה) · M2 featureEnabled מ-`==true` ל-`!=false` → אדום(+12 −2: OFF-ברירת-מחדל+מפל) → ירוק +22 · אפס-שאריות.
- **לקח:** מוטציה שלא-מאדימה = הקוד מת/לא-מכוסה — כאן חשפה שכלל-הדירוג היה חסר-שיניים; תיקנתי את הכלל, לא את הבדיקה.
- **אימות:** analyze 0 · 22 ירוקות (engine-8+gate-3+org_config-11) + מנהל-51 · גארדים ×7.

## #p2-w1b — קרנל-ה-workflow: מכונה-נתונה-לשם טהורה — 2026-07-26
- **הפתרון:** workflow_engine טהור (Maor ayin לבוש-בנייה) — 5 שלבים · guards · planWfAdvance (מסירה 2-לחיצות) · revert · dedup-שם · dailyRows. additive-נטו, אפס-צרכן-חי (מוצהר).
- **mutation ×2:** M1 מסירה-2-לחיצות קורסת ל-1 → אדום · M2 wfNormName no-op (dedup כבוי) → אדום → ירוק +14 · אפס-שאריות.
- **אימות:** analyze 0 · 14 ירוקות · גארדים ×5.

## #p2-w2a — ליבת-CRM: תיקון-ח"פ + נרמול-משותף + fuzzy — 2026-07-26
- **הפתרון:** validBusinessId+ספרת-ביקורת (באג טהור, בלי טוגל; +תיקון-פיקסצ'ר) · normalizePhone חדש · text_normalize משותף (חילוץ זהה-בייטים מ-workflow) · fuzzy_match (Damerau — הפרימיטיב שהיה חסר). fuzzy_search.dart הישן לא-נגוע.
- **mutation ×2:** M1 ספרת-ביקורת מדולגת → אדום(+37 −1) · M2 חילוף-Damerau כבוי → אדום(+9 −1) → ירוק +62 · אפס-שאריות.
- **לקח:** הבאג היה גם בבדיקה — 512345678 (הפיקסצ'ר "התקין") נכשל בעצמו בספרת-ביקורת (סכום 39). תיקון-אמיתי חושף פיקסצ'רים-שקריים; חישבתי ומצאתי 512345679 (סכום 40).
- **אימות:** analyze 0 · 62 ירוקות · גארדים ×7.

## #p2-w2b — ישות-לקוח שמורה: dedup + חיבור-בשם — 2026-07-26
- **הפתרון:** customers_store (SavedCustomer + persist) · upsertCustomer טהור (dedup name+phone) · customerForName (חיבור מנורמל) · בלוק מגודר בגיליון-הפרטים (AUGMENT — ManagerCustomer לא-נגוע).
- **mutation ×2:** M1 dedup כבוי (append תמיד) → אדום(+6 −3) · M2 חיבור-בשם ב-raw-compare (fold אבד) → אדום(+8 −1) → ירוק +12 · אפס-שאריות.
- **אימות:** analyze 0 · 49 ירוקות (store-9·gate-3·מנהל-נעול·repositories-נעול) · גארדים ×6.

## #p2-w2c — חיפוש-לקוחות סובל-שגיאות — 2026-07-26
- **הפתרון:** תיבה מגודרת search.fuzzy בטאב-הלקוחות; פרדיקט AND עם צ׳יפ-הסטטוס בנקודת-הקיפול; fuzzyNameMatch חדש (מודע-מילים) על מנוע-2א.
- **mutation ×2:** M1 הפרדיקט מתאים-להכל → אדום(+1 −2) · M2 fuzzyNameMatch בלי לולאת-המילים → אדום(+10 −1) → ירוק +14 · אפס-שאריות.
- **לקח:** ‏'לוי'≈'יוסי' במרחק≤2 (סף רופף על שאילתה-קצרה, נאמן-מאור) — פוזיטיב-שגוי אינהרנטי; הבדיקה עברה לשאילתה מובחנת ('מזרחי'), לא ריככתי את הקוד.
- **אימות:** analyze 0 · 45 ירוקות (search-3+crm_core+מנהל-נעול) · גארדים ×4.

## #p2-w2d — דירוג-לקוחות RFM — 2026-07-26
- **הפתרון:** קרנל טהור customer_score (RFM ספים-מוחלטים + atRisk) · פרוביידר recency מ-Order.createdAt · badge מגודר manager.scoring על הכרטיס.
- **mutation ×2:** M1 atRisk כבוי → אדום(+8 −1) · M2 שפלת-FM מוסרת (maxPoints תמיד 6) → אדום(+6 −3) → ירוק +11 · אפס-שאריות.
- **לקח:** recency לא נשמר על ManagerCustomer (יורד ב-toManagerOrder) — חושב בפרוביידר מ-Order הגולמי; זרעים חסרי-createdAt מדרדרים ל-FM ביושר במקום לזייף תאריך.
- **אימות:** analyze 0 · 42 ירוקות (kernel-8+gate-2+מנהל-נעול) · גארדים ×6.

## #p2-w3a — איכות-נתונים: ערוץ-אזהרות על ייבוא-הקטלוג — 2026-07-26
- **הפתרון:** קרנל טהור data_quality (auditRows: dup-name+near-key מבוסס-normName) · חיווט מגודר catalog.validation בגיליון-הייבוא, אחרי-commit, לא-חוסם. הפרסור לא-נגוע.
- **mutation ×2:** M1 dup-name כבוי → אדום(+3 −3) · M2 near-key כבוי → אדום(+4 −2) → ירוק +8 · אפס-שאריות.
- **לקח:** המפה מנעה בזבוז — הייבוא כבר מוגן; הערך הוא ערוץ-אזהרות-normName (מה ש-raw-sku-dedup מפספס), לא "הוספת ולידציה לייבוא-עירום". phone/ח"פ נדחו (אין שורה בקטלוג).
- **אימות:** analyze 0 · 30 ירוקות (kernel-6+gate-2+פרסור-נעול) · גארדים ×5.

## #p2-w3b — חילוץ CSV-kernel משותף — 2026-07-26
- **הפתרון:** פרימיטיבי-CSV (tokenizer + header-helpers + autodetect) מ-company_catalog_import → `csv_kernel.dart` טהור-משותף; הפרסר צורך אותם.
- **הוכחת-אי-רגרסיה:** זהו refactor — ה"מוטציה" היא הסוויטה-הנעולה עצמה: company_catalog_import_test (22) חייבת להישאר ירוקה, וכן היה. + kernel-11 ישיר.
- **לקח:** הפרוטוקול "מצא → helper" מנצח שכפול — הסוויטה-הנעולה הופכת refactor-מסוכן-לכאורה לבטוח (כל סטייה מאדימה).
- **אימות:** analyze 0 · 33 ירוקות · guards ×3 · 4 guard-strings של הפרסר שלמים.

## #p2-w3c — פרסר ייבוא-לקוחות על ה-CSV-kernel — 2026-07-26
- **הפתרון:** parseCustomerCsv טהור על csv_kernel; name חובה, phone/email מאומתים, id דטרמיניסטי מ-dedupKey, gate אטומי, dedup-בקובץ.
- **mutation ×2:** M1 ולידציית-טלפון כבויה → אדום(+8 −1) · M2 dedup-בקובץ כבוי → אדום(+8 −1) → ירוק +20 · אפס-שאריות.
- **לקח:** id-שעון בלולאת-bulk הוא באג-web שקט (ms-collision → כיווץ upsert); id-דטרמיניסטי-מ-dedupKey פותר גם התנגשות וגם אידמפוטנטיות-re-import. ח"פ נשאר מחוץ (לא שדה-לקוח) ⇒ אפס-שינוי-ישות ⇒ בדיקות-2ב שלמות.
- **אימות:** analyze 0 · 20 ירוקות · guards ×4.

## #p2-w3d — UI ייבוא-לקוחות (trigger + גיליון + importAll) — 2026-07-26
- **הפתרון:** importAll (bulk, persist-יחיד, reuse dedup) · גיליון clone-מותאם (upload→commit→אזהרות-איכות) · trigger מגודר manager.customers.
- **mutation ×2:** M1 trigger תמיד-דלוק → אדום(+4 −1, טאב-כבוי מוצא כפתור) · M2 importAll no-op → אדום(+3 −2, store נשאר ריק) → ירוק +34 · אפס-שאריות.
- **לקח:** importAll במקום לולאת-upsert = persist יחיד (לא N). אזהרות-איכות עושות reuse ל-auditNumber עם key=טלפון (CRM-appropriate) — אותו kernel, ישות אחרת.
- **אימות:** analyze 0 · 34 ירוקות · guards ×4.

## #p2-w3e — מסמך חשבונית/קבלה על רכבת printable_docs — 2026-07-26
- **הפתרון:** קרנל טהור invoice (invoiceVatOf חילוץ-לאחור מהברוטו → מתשלב ל-order.sum) · כפתור מגודר orders.invoicing בגיליון-פרטי-ההזמנה → buildPrintableHtml→printDocument.
- **mutation ×2:** M1 שער תמיד-דלוק → אדום(+1 −1) · M2 מע"מ-נאיבי (gross×0.18 במקום חילוץ-לאחור) → אדום(+4 −1) → ירוק +45 · אפס-שאריות.
- **לקח:** המוקש-אמת (order.sum ברוטו vs price לפני-מע"מ) — הקרנל מכבד ע"י חילוץ-לאחור, לא הכפלה נאיבית; M2 מוכיח שהבדיקה תופסת את הסטייה. הרכבת הקיימת מקבלת טיפוס-מסמך חדש בלי לגעת בה.
- **אימות:** analyze 0 · 45 ירוקות · guards ×5.

## #p2-w4b — מסמך תעודת-משלוח — 2026-07-27
- **הפתרון:** delivery_note.dart טהור (שם×כמות, אפס כסף) על רכבת printable_docs · כפתור מגודר orders.deliveryNote (גייט נפרד מ-invoicing).
- **mutation ×2:** M1 גייט תמיד-דלוק → אדום(+1 −2) · M2 דליפת-מחיר-לשורה → אדום(+2 −2) → ירוק +7 · אפס-שאריות.
- **לקח:** גייט נפרד לכל טיפוס-מסמך = שליטה עצמאית לחברה; האינווריאנט "תעודת-משלוח בלי כסף" נשמר במפורש (mutation מוודא שמחיר לא דולף).
- **אימות:** analyze 0 · 7 ירוקות · guards ×4.

## #p2-w4a — עמודת-ח״פ בייבוא-הלקוחות (פיבוט מ-ייבוא-ספקים) — 2026-07-27
- **הפיבוט:** אין ישות-ספקים-עם-ח״פ לייבא אליה (ממפה: verdict b) → הרחבת ייבוא-הלקוחות (הלקוחות הם עסקים). SavedCustomer.businessId אופציונלי · parseCustomerCsv עמודת-ח״פ מאומתת-validBusinessId.
- **תיקון-דרך:** upsertCustomer reconstruction היה מאבד businessId — נוסף incoming.businessId.
- **mutation ×2:** M1 ולידציית-ח״פ כבויה → אדום(+10 −1) · M2 ח״פ-לא-נשמר → אדום(+10 −1) → ירוק +25 · אפס-שאריות.
- **לקח:** כשאין ישות-יעד — לא ממציאים; מוצאים בית קיים (הלקוחות=עסקים). שדה-אופציונלי omit-when-empty שומר codec-תאימות-לאחור.
- **אימות:** analyze 0 · 25 ירוקות (כולל 2ב-נעול) · guards ×3.

## #p2-w4c — כפתור-קבלה (משלים את זוג-מסמכי-החיוב) — 2026-07-27
- **הפתרון:** כפתור "💵 הפק קבלה" על אותה רכבת (invoiceTitle receipt:true), תחת אותו שער orders.invoicing כמו החשבונית.
- **mutation ×1:** M1 תווית-הקבלה שונתה → אדום(+1 −1, ON לא מוצא את הכפתור) → ירוק +7 · אפס-שאריות.
- **מגבלה כנה:** receipt:true→כותרת לא נבדק ברמת-כפתור (printDocument לא-provider); הקרנל invoiceTitle(receipt:true) כן-נבדק ב-invoice_test.
- **לקח:** כשההבדל בין שני כפתורים הוא ליטרל-בודד וה-seam לא-בר-override — מכסים את הליטרל בבדיקת-קרנל, מתעדים את פער-הכפתור בגלוי.
- **אימות:** analyze 0 · 7 ירוקות · guards ×2.

## #swarm-r1 — ציר הצג/הסתר פר-אלמנט (registry→אשף) — 2026-07-27
- **הפתרון:** elementShown (features['element.<id>']!=false) · elementVisible (שער + נעילת-kImmutable) ב-CfgText · אשף-אקורדיון מונחה-חיפוש · screen→עברית.
- **mutation ×1:** M1 elementVisible→true (מתעלם מ-elementShown) → matrix אדום(+9 −1, home.topbar.brand לא-מוסתר) → ירוק · אפס-שאריות.
- **לקח:** 889/895 כבר-wired דרך CfgText ⇒ שער במקום-אחד כיסה הכל (לא 863 חיווטים). Option A (מחזור features) עקף את מוקש-carry-through של שדה-חדש. תיקון-אינטגרציה: SwitchListTile תחת DecoratedBox-צבעוני דורש Material-עוטף (assertion).
- **אימות:** analyze 0 · byte-verify ×7 · 63+5 בדיקות-סוללה ירוקות · שער מלא.

## #swarm-r2a — הסתרת-composite — 2026-07-27
- **הפתרון:** CfgVisible לומד את שער-ה-org (ראשון · שני-מצבים · בלי-ghost) · cart.cta עטוף · _MetricTile→ConsumerWidget+שער (5 KPI).
- **mutation ×1:** שער-CfgVisible off → composite נשאר → אדום(+20 −2) → ירוק +22 · אפס-שאריות.
- **לקח:** CfgVisible היה קוד-מת מושלם למחזור — עיטוף ה-outer-widget מסיר chrome-שלם (מה ש-CfgText לתווית-בלבד לא יכול). ~50 sites נוספים = מכני, לריצות-הבאות.
- **אימות:** analyze 0 · byte-verify · cfg_wrappers 22 ירוקות · שער מלא.

## #swarm-r2b — כיסוי-composites (~36 עיטופים) — 2026-07-27
- **הפתרון:** 3 fixers מקבילים עטפו כל composite-CfgText (כפתור/כרטיס/pill) ב-CfgVisible; תוויות-plain הושארו.
- **אין-mutation-חדש:** מנגנון ה-CfgVisible כבר mutation-מאומת ב-r2a; r2b = עיטופים מכניים על אותו מנגנון. זהה-בייטים (config ריק ⇒ child verbatim).
- **לקח:** ה-grep הראשוני פספס `const CfgText` — הושלם ידנית (dash.exit · credit) + F1/F3 סרקו const מיוזמתם. עתיד: לכלול const בתבנית.
- **אימות:** analyze 0 · 59 בדיקות-מסך-מושפעות ירוקות · שער מלא.

## #swarm-r2c — סגירת כיסוי-composites + בטיחות-יציאה — 2026-07-27
- **הפתרון:** 4 fixers עטפו 64 composites ב-CfgVisible (18 קבצים); 7 כפתורי-יציאה critical:true (מונע התקעה).
- **אין-mutation-חדש:** אותו מנגנון-CfgVisible (mutation-מאומת r2a) + critical-path (בדיקת "critical⇒shown" ב-cfg_wrappers). זהה-בייטים · gate_118 מוודא id-רשום.
- **לקח:** critical:true הוא כלי-הבטיחות לניווט — הוחל על יציאות/חזרות שלא-במסגרת ה-5 kImmutable. fixers סרקו const + דילגו נכון על plain/multi-child/Dropdown.
- **אימות:** analyze 0 · 56 בדיקות-מפתח + gate_118 ירוקים · שער מלא.

## #swarm-r2d — כיסוי-composites מלא + CfgVisible סביל-scope — 2026-07-27
- **הפתרון:** 5 fixers עטפו 74 composites (26 קבצים · const-מודע · plain מושאר · 3 CTAs-login critical). CfgVisible→StatelessWidget+fallback-חסר-scope (מראה CfgText).
- **אין-mutation-חדש:** אותו מנגנון (mutation-מאומת r2a). תיקון-scope הוא robustness (לא לוגיקת-הסתרה).
- **לקח:** ConsumerWidget עטיפתי דורש scope → שובר test-pumps חסרי-scope; StatelessWidget+try-containerOf (כמו CfgText) פותר גלובלית. עדיף לתקן במנגנון מ-whack-a-mole per-test.
- **אימות:** analyze 0 · cfg_wrappers 24 + t6 ירוק · 133 בדיקות-מסך · gate_118 · שער מלא.

## #swarm-r2e — סוף כיסוי-composite (הזנב האחרון) — 2026-07-27
- **הפתרון:** 3 fixers · 26 עטיפות · shared-wrapper (courier _PillButton→4 · store _MonthRow→12) · critical:true ליציאות/consent/docs-gate.
- **אין-mutation-חדש:** אותו מנגנון (mutation r2a + scope-tolerance r2d).
- **לקח:** עטיפת wrapper משותף פעם-אחת מכסה N מופעים (יעיל). studio-editor הוחרג במכוון (לא אלמנט-אפליקציה).
- **אימות:** analyze 0 · 65 בדיקות-מושפעות · שער מלא.

## #wizard-studio-s0 — WYSIWYG edit בתצוגה (מחזור) — 2026-07-27
- **הפתרון:** STUDIO=true בבניית-preview + רלקסציית-שער-בעלים לתצוגה (kStudioFlag && kProfileRawShell → manager-context מספיק).
- **בטיחות:** compile-gated → live tree-shakes. שער isOwnerEmail עומד על live. studio_gating ירוק.
- **מגבלת-בדיקה כנה:** ענף-הרלקסציה compile-gated (kStudioFlag/kProfileRawShell false בסוויטה define-less) → לא-בר-unit-test; ה-else (owner-gate) נבדק ב-studio_gating; הענף מאומת חי על ה-preview.
- **אימות:** analyze 0 · studio_gating + cfg_wrappers + zero_regression ירוקים.

## #wizard-studio-s0b — מתג נווט⇄ערוך + בורר-בורד (עריכה-בחי בלי לכידה) — 2026-07-27
- **הפונקציה:** `StudioOverlay` — מעטפת-סטודיו קבועה עם מתג `נווט⇄ערוך` (ממחזר `enterEdit/exitEdit`) + בורר-בורד (`showRolePicker` דרך root-navigator).
- **תקלה שהוזרקה (mutation-sensitivity):** `onSelectionChanged` של ה-`SegmentedButton` → no-op/null. הבדיקה `זה-נווט⇄ערוך toggle flips edit-mode` (tap `ערוך`→isEditing=true · tap `נווט`→false) נכשלת מיידית ⇒ המתג באמת-מפעיל edit, לא קישוט.
- **בטיחות:** off-gate (`studioActiveProvider`=false) → `SizedBox.shrink` זהה-בייטים (נבדק). בורר-בורד מגודר `kStudioFlag` + `navigatorKey` תחת `(kKbGlobal || kStudioFlag)` → החי `null` זהה-בייטים.
- **מגבלת-בדיקה כנה:** רלקסציית `return true` compile-gated (kStudioFlag/kProfileRawShell) → לא-בר-unit-test בסוויטה define-less; מאומתת חי על ה-preview. מניפסט-הקונפורמנס עודכן לשקף `return true`.
- **אימות:** analyze 0 · zero_regression (off/on/אינטראקציה) + 304 בדיקות-סטודיו/שער/role-picker ירוקות.

## #wizard-studio-s1 — אקורדיון-Maor + מיפוי מסך→מודול — 2026-07-27
- **הפונקציות:** `moduleForScreen` (123 מסכים→14 מפתחות-מודול) · `_moduleCounts`/`_globalCounts` (מונים) · `_setModuleElementsHidden` (bulk סמן/נקה-הכל).
- **תקלה שהוזרקה (mutation-sensitivity):** (א) `moduleForScreen` → מחזיר מפתח לא-קיים ⇒ בדיקת-הכיסוי (`every registry element maps to a kWizardModules key`) אדומה מיידית. (ב) `_setModuleElementsHidden` no-op ⇒ בדיקת-ה-bulk (`נקה הכל`→`cart.cta` נסתר + נשמר false) אדומה.
- **בטיחות:** `kOrgModules` נשאר 13 (הסט-הנעול — org_setup_wizard_test) ⇒ contractor **display-only, בלי שער** ⇒ אין נעילה-עצמית של ה-app-הבסיסי. bulk **מדלג kImmutable** (ליבה לא-מוסתרת). absent=on ⇒ ברירת-מחדל זהה-בייטים · 13 ה-SwitchListTile נשמרו ⇒ כל בדיקות-השער הקיימות ירוקות ללא-שינוי.
- **אימות:** analyze 0 · org_setup_wizard 15/15 (12 קיימות + 3 חדשות).

## #wizard-studio-s2 — מפקח ✎ פר-רכיב (publish חי) — 2026-07-27
- **הפונקציות:** `_ElementInspectorSheet` (✎ · text/emoji/color/size/weight) · `_applyLive` (`applyOps`+`publish`) · `_openElementInspector`.
- **תקלה שהוזרקה (mutation-sensitivity):** `_applyLive` → מדלג על `publish` (רק `applyOps`→draft) ⇒ בדיקת-ה-✎ (`published.global['cart.cta'].text=='קנה עכשיו'`) אדומה — כי בלי edit-mode `resolvedNode`=published ו-draft לא-נראה-חי. מוכיח ש-**ה-publish הוא-שעושה-חי** באשף.
- **בטיחות:** ה-✎ מופיע **רק** כשיש ציר text/emoji/style (הסתרה-בלבד → אין ✎). ההסתרה נשארת על מתג-OrgConfig (בלי כפילות). `Key('elem-toggle-<id>')` (SwitchListTile) נשמר ⇒ כל בדיקות-הרכיבים הקיימות ירוקות. align/direction אינם ב-`CfgStyle`/`CfgText` ⇒ follow-up (value-object סגור).
- **אימות:** analyze 0 · org_setup_wizard 16/16 · studio 192/192.

## #wizard-studio-s3 — מונחים-שזורים (termOf חי) — 2026-07-27
- **הפונקציה:** `_wovenTerms` + `_kModuleTerms` (מודול→מונחי-V3-מחווטים).
- **תקלה שהוזרקה (mutation-sensitivity):** `_wovenTerms` מציג את ה-`def` הקבוע במקום `termOf(_draft, key, def)` ⇒ בדיקת-ה-woven (עריכת nav.home→'מגורים' מעדכנת את הצ׳יפ) אדומה — הצ׳יפ אינו-חי.
- **בטיחות:** read-only (העריכה במקטע "מיתוג ומונחים" — מקור-אמת אחד ל-OrgConfig.terms) ⇒ אין כפילות/סתירה. מונחים לא-מחווטים אינם מוצגים (רק ~8 המחווטים).
- **אימות:** analyze 0 · org_setup_wizard 17/17.

## #wizard-studio-s4 — מצא-והחלף (launcher+publish) — 2026-07-27
- **הפונקציות:** `_openFindReplace` · `_WizardFindReplaceScreen` (עוטף `FindReplacePane` + AppBar `publish`).
- **תקלה שהוזרקה (mutation-sensitivity):** הכפתור `onPressed:null` (או pushing מסך-ריק) ⇒ בדיקת-ה-launcher (`find.byType(FindReplacePane)`) אדומה.
- **בטיחות:** מיחזור **verbatim** (0 שינוי ב-`FindReplacePane`) ⇒ בדיקות-הסטודיו שלו נשארות ירוקות. ה-publish מפורש (הטיוטה לא נוגעת ב-live עד לחיצה). find-replace על overrides בלבד (labelHe לא נסרק).
- **אימות:** analyze 0 · org_setup_wizard 18/18.

## #wizard-studio-s5 — גרסאות והיסטוריה (launcher) — 2026-07-27
- **הפונקציות:** `_openHistory` · `_WizardHistoryScreen` (עוטף `HistoryPane`).
- **תקלה שהוזרקה (mutation-sensitivity):** הכפתור `onPressed:null` ⇒ בדיקת-ה-launcher (`find.byType(HistoryPane)`) אדומה.
- **בטיחות:** מיחזור **verbatim** (0 שינוי ב-`HistoryPane`) ⇒ בדיקות-הסטודיו שלו ירוקות. מצב-ריק על אשף-נקי. שחזור=rollback קדימה-בלבד (ההיסטוריה לא נהרסת).
- **אימות:** analyze 0 · org_setup_wizard 19/19.## #owner-never-pending — הבעלים לא נתקע pending — 2026-07-27
- **הפונקציה:** `withOwnerApproval(BsUser?)` (users_repository) — הבעלים (email מאומת) עם `status=pending` → מוחזר `active`; כל השאר verbatim.
- **תקלה שהוזרקה (mutation-sensitivity):** הסרת שורת-האכיפה (`return user` תמיד). הבדיקה `owner + pending → active` נכשלת מיידית (Actual pending) ⇒ ההכרחה באמת-פועלת, לא קישוט. תקלה #2: הרחבת ה-scope (בלי `isOwnerEmail`) → הבדיקה `non-owner + pending → stays pending` נכשלת ⇒ מוכיח שהתיקון ממוקד-בעלים בלבד.
- **בטיחות:** האינווריאנט `permitAction` לא נגע (הבדיקה `pending blocks even admin` נשארת ירוקה); רק סטטוס-הבעלים משתנה. email לא-ניתן-לזיוף.
- **אימות:** analyze 0 · owner_approval_test 4/4 · 147 בדיקות user-system/auth ירוקות.
## #owner-never-pending-authemail — זיהוי-בעלים לפי auth-email (תיקון no-op) — 2026-07-27
- **הפונקציה:** `withOwnerApproval(user, [authEmail])` — הבעלים מזוהה גם ע"י ה-**auth email** (הגוגל-לוגין), לא רק מסמך-המשתמש.
- **התקלה שהוזרקה:** הסרת ענף `isOwnerEmail(authEmail)` → הבדיקה `owner via AUTH email + blank doc email → active` נכשלת (Actual pending) ⇒ מוכיח שהמסלול-החדש load-bearing.
- **למה:** #247 בדק `user.email` ממסמך-המשתמש — ריק כשהרישום היה בלי email → no-op. auth-email תמיד קיים לגוגל-לוגין.
- **אימות:** analyze 0 · owner_approval_test 6/6.
## #launch-legal-v2 — מדיניות-פרטיות מדויקת מול backend חי — 2026-08-01
- **הנכס:** `kPrivacyPolicy` + `kTermsOfUse` + `kCurrentPolicyVersion` (`lib/data/legal_texts.dart`) — שוכתבו לשקף את ה-backend החי (Firestore באזור me-west1 · GA4 · Crashlytics · חשבון-רשום מסנכרן), במקום ההצהרה השגויה "אין שרת / הכל על המכשיר".
- **תקלה שהוזרקה (mutation-sensitivity):** החזרת ההצהרה השגויה (הסרת `Firestore`/`me-west1` מהמדיניות) → הבדיקה `privacy discloses the live Firebase backend` נכשלת מיידית ⇒ האסרשן אמת-פועל. תקלה #2: השארת `kCurrentPolicyVersion` על 1 → הבדיקה `policy version bumped to 2` נכשלת ⇒ מוכיח את חובת ה-re-notice (תיקון-13).
- **בטיחות:** const-data בלבד — אפס לוגיקה/widget; placeholders זהות-חברה נשמרו (מילוי-בעלים).
- **אימות:** `flutter analyze` 0 · `test/legal_texts_test.dart` (חדש) · `legal_screen_test` נשאר ירוק.

## #launch-verify-search-mirror — search-index label sync (2026-08-01)
- **הנכס:** `lib/data/search_index.dart:449` — כותרת רשומת-חיפוש `'מחירים במועדפים'` → `'התראות תקציב'` (מראה של notif_settings FIX 2; התווית תואמת כעת את האפקט האמיתי — השתקת התראות-תקציב).
- **תקלה שהוזרקה (mutation-sensitivity):** החזרת הכותרת הישנה → חיפוש "מחירים במועדפים" מוביל להגדרה בשם "התראות תקציב" (אי-עקביות תצוגה גלויה למשתמש).
- **בטיחות:** const-data בלבד (רשומת-חיפוש); אפס לוגיקה; analyze 0.
- **אימות:** analyze 0 · legal_texts_test + keyboard_store_deriver_test ירוקים.

## #launch-order-email — customerEmail על ההזמנה (2026-08-02)
- **הנכס:** שדה `Order.customerEmail` + `toDoc` (orders_firebase) — הנתיב שדרכו הפונקציה קוראת את מייל-הלקוח מ-Firestore.
- **תקלה שהוזרקה (mutation-sensitivity):** השמטת `customerEmail` מ-`toJson` → הבדיקה `customerEmail survives toJson→fromJson` נכשלת ⇒ ה-round-trip load-bearing. תקלה #2: כתיבת customerEmail תמיד (בלי guard) → הבדיקה `absent customerEmail NOT written` נכשלת ⇒ מוכיח את הזהה-בייטים-כבוי.
- **בטיחות:** כבוי (`kOrderEmail`=false) ⇒ '' ⇒ אין שדה בדוק.
- **אימות:** analyze 0 · `order_customer_email_test` 3/3.

## #8/3a — per-user DM thread (createOrGetThread) (2026-08-02)
- **הנכס:** `dmThreadId` (id דטרמיניסטי/דדופ) + `createOrGetThread` (create-or-get) + `threadsFor` uid-aware, ב-`chat_dm_thread_test`.
- **תקלות מוזרקות (mutation-sensitivity):** (1) `dmThreadId` בלי sort → סדר שונה של אותם uids נותן id שונה → 'order-independent' נכשלת ⇒ הדדופ load-bearing. (2) `createOrGetThread` בלי בדיקת-קיום → קריאה שנייה מייצרת thread כפול → 'creates ONCE then GETs' נכשלת. (3) ה-uid-clause ב-`threadsFor` בלי `uid != null` → thread-uid דולף ללא-חבר/anon → 'INERT for non-member' נכשלת ⇒ מוכיח זהה-בייטים-כבוי.
- **אימות:** `chat_dm_thread_test` 6/6 · `flutter analyze` 0.

## #8/3ג — ManagerCustomer.phone enrichment (2026-08-02)
- **הנכס:** `ManagerCustomer.phone` + `copyWith` (manager_customer_phone_test) + enrichment ב-`managerCustomersProvider`.
- **תקלות מוזרקות (mutation-sensitivity):** (1) `copyWith` בלי `phone ?? this.phone` → copyWith עוקב מאפס את הטלפון → 'preserves existing phone' נכשלת. (2) enrichment בלי guard `if(phoneByName.isEmpty) return base` → מצב-דמו (בלי טלפונים) מקבל רשימה חדשה (זהות-אובייקט אחרת) → סיכון-רגרסיה; ה-guard מוכיח זהה-בייטים-כבוי.
- **אימות:** `manager_customer_phone_test` 3/3 · `flutter analyze` 0.

## #8 תיקון-צ'אט-חי — listen פר-thread להודעות (2026-08-02)
- **הנכס:** `_PerThreadChatMessagesSource` (chat_firebase) + factory `messagesSourceFor` (chat_repository) — listen `where(threadId==X)` פר-thread, ממוזג. בדיקות ב-`chat_firebase_repo_test`.
- **תקלות מוזרקות (mutation-sensitivity):** (1) listen על כל-האוסף (בלי scope threadId) → ה-rule הפר-מסמך דוחה את כל ה-query → 0 הודעות → 'server snapshot → delivered' נכשלת. (2) listen ל-thread ללא participantUids → 'opens only for uid-threads' נכשלת. (3) merge לקוי → 'two threads merge' נכשלת.
- **בטיחות:** כבוי (useFirebaseBackend/UID_SCOPED) ⇒ מקור כל-האוסף כמו קודם (זהה-בייטים).
- **אימות:** `chat_firebase_repo_test` (4 חדשות) + 88 chat tests + full suite ירוקים · analyze 0.

## #catalog-config-rail-collapse — אריח-פר-סוג דרך מנוע-הוריאנטים הקיים (2026-08-05)
- **הנכס:** `browseSection` (browse_model) מכווץ את מוצרי-המשפחה ל-`ConfigTile` אחד פר-`productCanonicalKey` (מנוע-הוריאנטים הקיים · `data/variant_families.dart`); `productFrame` = תווית-הטיפוס; `ConfigFamily.productCount` = מונה-המוצרים לבאדג'.
- **תקלות מוזרקות (mutation-sensitivity):** (1) קיבוץ פר-SKU במקום `productCanonicalKey` (אריח-פר-וריאציה) → הבדיקה `3 size-variants of "מצמד" collapse to ONE tile` נכשלת (3 אריחים במקום 1) ⇒ הכיווץ load-bearing. (2) `count => tiles.length` במקום `productCount` → הבאדג' מציג טיפוסים (1) במקום מוצרים (3) → הבדיקה `badge = the PRODUCT count` נכשלת ⇒ המונה מודד מוצרים לא-טיפוסים. (3) כיווץ שאינו מכווץ (types==SKUs) → `expect(typeTotal, lessThan(productTotal))` בפיילוט נכשלת.
- **בטיחות:** מגודר `kCatalogConfig` OFF ⇒ tree-shaken; `productCanonicalKey` נשאר **byte-identical** (`productFrame` additive · מקטע-"וריאנטים" החי ללא-שינוי).
- **אימות:** `flutter analyze` 0 (הקבצים שלי) · catalog_config 64/64 · הפיילוט "אביזרי קצה וחיבורים" 143 SKUs → 62 אריחי-טיפוס.

## #catalog-config-cataxes — גלגלים דרך catAxesOf · מידה=קוטר (2026-08-05)
- **הנכס:** `axisChips` (product_chips) מריץ את מנוע-הצירים הקיים `catAxesOf` על משפחת-הוריאנט (`productCanonicalKey`); ציר-דסקריפטיבי-שמשתנה=גלגל, מידה=קוטר-תמיד (`odOf` כ-fallback ל-mm-נגרר); `prioritizedSchema` מאחד מעל `configSchemaFor` וממיין לפי הטקסונומיה.
- **תקלות מוזרקות (mutation-sensitivity):** (1) `if (e.value.length > 1)` בלי `_kSizeChips` → סינגלטון-מידה מאבד את גלגל-הקוטר → הבדיקה `SIZE always shows` נכשלת (Actual []). (2) מיפוי inch→'thread' במקום 'diameter' → הבדיקה `1/2" IS a diameter` נכשלת ⇒ מוכיח את הכלל "מידה=קוטר". (3) הסרת ה-odOf-fallback → 'פקק 32' (mm-נגרר) מאבד קוטר → אריחי-0-גלגלים קופצים (127→157) — הבדיקה החיה מודדת את הרגרסיה.
- **בטיחות:** מגודר `kCatalogConfig` OFF · byte-identical (`catAxesOf` היה inert ונשאר; `product_chips` tree-shaken כבוי).
- **אימות:** `flutter analyze` 0 · catalog_config 76/76 · התפלגות-גלגלים 0→127 · 1→382 · 2→96 · 3→28.

## #catalog-config-cleanfamilies — משפחות-נקיות + typeKey · נגד-פיצול (2026-08-05)
- **הנכס:** `catalog_taxonomy.dart` (חדש) — `familyGroupOf`=`groupOf` (12 קבוצות-הבעלים) · `typeWordOf`=`firstMeaningfulToken`→`canonicalizeWord` דרך **שתי** מפות-הנירמול הקיימות (`_kTypeSynonyms`={...kWordSynonyms,...kQuerySynonyms}: זווית→ברך · מרפק→ברך · רבים→יחיד) · `typeKeyOf`=משפחה+סוג. `browseAll` (browse_model) מקבץ את כל הקטלוג ל-12 משפחות→אריחי-סוג; `_typeGroup` (product_chips) מחליף את `_frameGroup` — הגלגלים מצטברים מעל ה-**סוג הנקי** (typeKeyOf) לא מעל ה-frame המפוצל; `canonicalMaterial` על ערכי-חומר · `isTrueColor` (color_truth) מסנן גימור-מתכת מציר-הצבע. המסך עבר ל-`browseAll`.
- **תקלות מוזרקות (mutation-sensitivity):** (1) `canonicalizeWord(base, kQuerySynonyms)` בלבד (בלי kWordSynonyms) → זווית לא מתקפל ל-ברך → `browse: זווית folds into ברך tile` נכשלת (tileCount 2≠1). (2) `_typeGroup` דרך `productCanonicalKey` (הישן) → אגירה מעל frame מפוצל → משפחות≠12 / התפלגות-גלגלים מתמוטטת → `coverage: 12 families` + `2-3 wheels>60%` נכשלות. (3) הסרת מסנן `isTrueColor` → נחושת/כרום (גימור) מתחזה לצבע → `chips: finish is NOT a color wheel` נכשלת. (4) החזרת `color` ל-`_kSizeChips` (always-shown) → אריח חד-צבע מקבל גלגל-צבע-שווא → הזהב `צינור`[diameter,color] מזייף אריחי-סינגלטון.
- **בטיחות:** מגודר `kCatalogConfig` OFF · byte-identical (0 הפניות ל-catalog_config מחוץ ל-`lib/features/catalog_config/`; הכל טהור · tree-shaken כבוי; `groupOf`/`catAxesOf`/`kWordSynonyms`/`color_truth` נצרכים כקריאה-בלבד, לא-מְשׁוּנִּים).
- **אימות:** `flutter analyze` 0 · catalog_config 58/58 (6 קבצים) · **12 משפחות** (מ-93 עלים) · 1867 מוצרים→144 אריחי-סוג · **75% מהמוצרים על כרטיס 2-3 גלגלים** (0→78·1→392·2→124·3→1273) · גולדנים: ברך[קוטר·זווית·אורך]·מחלק[קוטר·יציאות·צבע]·מצמד-מעבר[קוטר·מעבר]·מתאם[קוטר·תבריג]·אלכסוני[קוטר].

## #catalog-config-scroll-and-image — ↕/↔ ערך-נוכחי + נציג-בהיר (2026-08-05)
- **הנכס:** שני תיקוני-יסוד (משוב-בעלים). (1) `config_card._stage`: תוויות-הקצה ↕/↔ הן גלילה — מציגות שם-ציר + ה**ערך-הנוכחי** (`_selectedLabel`) בלבד, לא רשימת-כל-הערכים (הג'יבריש `3·1×25·3/4×25…`). (2) `image_quality.dart` (חדש): `kImageBrightness` (מפת-בהירות מדודה, 127 קרופים כהים <150) · `imageBrightness` (חסר→255=בהיר) · `isBrightImage` (≥`kDarkFloor`=100) · `tileEmoji` (אמוji-שחור ⚫→📦). `browse_model._pickRep` בוחר את המוצר עם ה**תמונה-הבהירה-ביותר** (argmax, לא "הראשון"), `_repImage` מרוקן תמונה שחורה-אמיתית→אמוji, ו-`tileEmoji` מבטיח שגם ה-fallback לא שחור. אף אריח/כותרת שחור.
- **תקלות מוזרקות (mutation-sensitivity):** (1) החזרת `primary.values.join('·')` בתווית-התחתית → `elbow edge labels` נכשלת (`45°·90° ▼` findsNothing). (2) תווית-שמאל `.first` במקום `_selectedLabel` → אחרי ↕drag התווית לא מתעדכנת → `↕ drag tracks current` נכשלת (`90° ▼` findsNothing). (3) `_pickRep` "ראשון-עם-imageAsset" (הבאג המקורי) → אריח מוביל בתמונה שחורה → `BRIGHTEST sibling skips black` נכשלת. (4) הסרת floor `_repImage` → קבוצה כולה-שחורה מציגה תמונה שחורה → `all-black shows EMOJI` נכשלת (imageAsset != null). (5) הסרת `tileEmoji` → ⚫ מוצג → `black emoji → 📦` נכשלת.
- **בטיחות:** מגודר `kCatalogConfig` OFF · byte-identical (`image_quality` טהור, נצרך רק ע"י `browse_model` המגודר · tree-shaken; `product_images`/צנרת-התמונות ללא-שינוי — האריח נושא `imageAsset` כמקודם). `kImageBrightness` הוא companion ל-catalog-ה-hardcoded (מתחדש איתו).
- **אימות:** `flutter analyze` 0 · catalog_config 59/59 · רנדר: ↕/↔ מציגות ערך-בודד (`1/2×16`·`15°`), אין אריח/כותרת שחור (⚫→📦, כהים-אמיתיים→נציג-בהיר/אמוji). הערה: תמונות-`lipski_site`/`huliot` (חברה) חסרות בסביבת-החול→אמוji; בפרודקשן נטענות מה-CDN.

## #catalog-config-clean-card — כרטיס נקי: שם-מעל · ריבוע · פִּיל-ערכים (2026-08-05)
- **הנכס:** עיצוב-מחדש של `config_card` לפי משוב-בעלים. פריסה: (1) `_fullName` — שם-המוצר המלא (מה-variant אם נפתר, אחרת schema) נקי מעל. (2) `_cols` (LayoutBuilder+IntrinsicHeight) — גלגלי-צד קוטר/כמות **נשארו**, ממורכזים אנכית על ריבוע-תמונה (`square=avail.clamp(150,184)`, ~20% קטן). (3) `_stage` ריבועי — התמונה ממלאה (BoxFit.contain), overlay יחיד = `_valuesPill` (ערכים-נוכחיים `_usable.take(3)`, כתום-מותג `_cAccent`, בלי חצים/מלל-קצה). גרירה ↕/↔ עדיין מגלגלת+מחליפה תמונה. הוסרו: `_header`(✕) · `_edge`/`_axisLabel`(חצי-הקצה) · `_valueLine` · `_hint`("הגלגלים של…") · `_cAccentD`.
- **תקלות מוזרקות (mutation-sensitivity):** (1) `Stack` בלי height-חסום (מ-`minHeight` ב-Column) → `Stack requires bounded constraints` — נתפס ע"י SizedBox-ריבוע. (2) `.join('   ·   ')` רחב + font 15 → הפִּיל נחתך בריבוע-הקטן (`…DN50 · 16×1/2 ·`) — צומצם ל-`' · '` + font 12. (3) שכחת `mainAxisSize.min` בגלגלים → ממלאים-גובה top-aligned → לא-ממורכזים על הריבוע. (4) בדיקות: `elbow edge labels`/`wheel_test edge labels` דרשו `▲ זווית` → שוכתבו ל-`configFullName`+פִּיל+`textContaining('▲') findsNothing`; `↕ drag` בודקת שהפִּיל עוקב (`20 · 90° · קצר`).
- **בטיחות:** מגודר `kCatalogConfig` OFF · byte-identical (UI טהור בתוך הכרטיס המגודר; אין שינוי נתונים/צנרת-תמונות · tree-shaken כבוי).
- **אימות:** `flutter analyze` 0 · catalog_config **75/75** · רנדר: שם-מלא-מעל · ריבוע-ממורכז (20% קטן, גלגלים-ממורכזים) · פִּיל-כתום `DN50 · 16×1/2 · 15°` · בלי חצים/מלל-קצה/hint.

## #catalog-config-variant-swap — גרירה מחליפה תמונה+שם (typeGroup·chipValues·variantByAxes) — 2026-08-07
- **הנכס:** תיקון-שורש למשוב-הבעלים ("אני מזיז ימין/שמאל — התמונה והשם לא מתחליפים"). המנוע-הישן (`variant_image.familyProducts` דרך `familyOf(p)==schema.familyId`) החזיר **משפחה-ריקה** לאביזרים (mismatch familyId) ⇒ אין וריאנט להחליף. חדש: (1) `typeGroupOf(p, universe)` (catalog_taxonomy) — המוצרים החולקים `typeKeyOf` (הסוג-הנקי, אותה טקסונומיה כמו האריחים). (2) `chipValuesOf(p)` (product_chips) — chip→values של מוצר-בודד (catAxesOf→`_kAxisToChip`, `canonicalMaterial`, מסנן `isTrueColor`, נפילת-`odOf`) לצורך התאמת-וריאנט. (3) `variantByAxes(family, selection, axisOrder)` — מסנן-קדימות **חמדני** (מצר לפי כל ציר, מדלג כשמתרוקן — גרירה לא מרוקנת את הכרטיס). `config_card._resolveFamily` מזין `_cardProduct`/`_cardChips`/`_familyChips`; `_seed`/`_usable` **קוהרנטיים-למוצר** (רק צירים שהמוצר נושא); `_variant()` = `variantByAxes` על top-3; `_resolvedImageAsset`/`_fullName` מה-variant.
- **תקלות מוזרקות (mutation-sensitivity):** (1) `variantByAxes` בלי דילוג-על-ריק (מצר גם כשריק) → ערך-ציר שאף חבר-DN50 אין לו (45°) מרוקן ⇒ null ⇒ הכרטיס נמחק בגרירה → `an angle no DN50 member has is SKIPPED` נכשלת. (2) התאמה על **כל** 8 הצירים (במקום top-3 המוצגים) → הניקוד מוטה ל-seed (8 צירים) → שינוי-ציר-בודד לא מחליף → `the CHANGED axis picks its variant` נכשלת (`same(b)` != a). (3) `_usable` לא-קוהרנטי (frame-schema) → הפִּיל מציג `16×1/2` למוצר 213072 שאין לו → פִּיל-שווא. (4) חזרה ל-`familyProducts` (המנוע-הישן) → משפחה-ריקה לאביזרים → `a REAL catalog card resolves a variant` נכשלת (אותה תמונה תמיד).
- **בטיחות:** מגודר `kCatalogConfig` OFF · byte-identical (`variantByAxes`/`chipValuesOf`/`typeGroupOf` טהורים, נצרכים רק ע"י הכרטיס המגודר · tree-shaken כבוי; `variant_image.dart` נשאר לבדיקתו — Gate 89; `catAxesOf`/`color_truth`/`odOf` קריאה-בלבד).
- **אימות:** `flutter analyze` 0 · catalog_config **92/92** · probe: גרירת-זווית מחליפה שם `ברך 15°`→`ברך 87°` + תמונות-פר-זווית נבדלות (213072→ברך). variantByAxes: DN50·15°→A, שינוי→90°→B (החלפה), 45°(אין)→מדולג→A (בלי מחיקה).

## #catalog-config-dn-scale — סולם-קוטר אחיד (אינץ'/DN/מ"מ → DN אחד) — 2026-08-07
- **הנכס:** `dn_scale.dart` (חדש · טהור) — הגלגל קוטר דיבר ב-3 שיטות-מדידה (אינץ' `½"` · `DN40` · קוטר-חיצוני-פלסטיק `20`/`110`) + רעש-`odOf` = **129 ערכים**. משוב-בעלים: "תשנה הכל קוטר ל-DN אחד; ½"=DN15" + "DN110 חייב להישאר — זה משנה איזה צנרת ולמה". `canonicalDn`: אינץ'→DN-קדח דרך `kInchToDn` (½"→DN15); כל מספר-אחר=קוטר-חיצוני, נצמד ל-rung-סחר הקרוב ב-`kDnRungs` שהוא-עצמו ה-DN (110→DN110·63→DN63·90→DN90 **שורדים** כמדרגה נפרדת; רעש 43→DN40·88→DN90·DN576→DN400 נבלע). `product_chips`: (1) `_dnAttribute` — choke-point ב-`prioritizedSchema` שממפה **גם** את סכמת-המנוע וגם את גלגלי-הצירים ל-DN, ממיין ב-`dnNumber`, ומטמיע רמז-אינץ' ב-`labelHe` (`DN15 · ½"`) בעוד `canonical` נשאר `DN15` להתאמה; (2) `chipValuesOf` מקנן קוטר ל-`canonicalDn` (טוקן-בחירה = DN טהור). 129 ערכים גולמיים → סולם-DN אחיד נקי (`kDnRungs` = איחוד סולם-קוטר-חיצוני-פלסטיק + ערכי-קדח-ISO 65/80/100/150/300).
- **תקלות מוזרקות (mutation-sensitivity):** (1) התאמה על `.mm` הגולמי (½"=12.7) במקום `kInchToDn` → ½"→DN15 נכשל (12.7 נצמד ל-DN13/15 לא-דטרמיניסטי). (2) `canonicalDn` שמצמיד גם `DNxx` תקני כ-OD → DN110 מתמזג ל-DN100 → `plastic keeps its OWN DN` + `already-DN idempotent` נכשלים (הבאג שהבעלים תפס). (3) בלי `dnNumber` sort (מיון-לקסי) → DN100 לפני DN15 → `ascending` נכשל. (4) קנוניזציה רק ב-`chipValuesOf` ולא ב-`prioritizedSchema` → הגלגל מציג `½"`/`110` גולמי בעוד ההתאמה DN → אי-עקביות + `REAL wheel shows DN` נכשל. (5) `labelHe`=DN-בלבד (בלי רמז) → `DN15 · ½"` נכשל.
- **בטיחות/היקף (מתוקן אחרי נחיל-אימות):** הפיצ'ר **חי על הבית** (הודלק ב-commit קודם — `smart_home_screen` מרנדר `CatalogConfigScreen` בלי flag), אז זה משנה את גלגלי-הקוטר **בפרודקשן** — **לא** byte-identical (התיאור המקורי "tree-shaken/OFF" היה שגוי; `kCatalogConfig` מגדר רק את ה-route העצמאי). `dn_scale` טהור, נצרך רק ע"י שכבת-הכרטיס. `catAxesOf`/`_size_norm`/ring_dive **ללא-שינוי** (git diff ריק — המאתר לא מושפע). קנוניזציה מוגבלת ל-`id=='diameter'` בלבד (סימטרי עם `chipValuesOf`) — `diameter-small`/מעבר נשאר verbatim (טוקני `16×20` לא מומרים).
- **אימות (נחיל 9×9 · auditor+validator):** analyze 0 (catalog_config) · catalog_config **102/102** (+10 dn_scale). ממצאים שתוקנו: (א) guard `startsWith('diameter')`→`=='diameter'` — probe: **18,816** טוקני-מעבר נשמרו, **0** מומרים ל-DN; seed-desync ירד (baseline raw 158→59, כלומר ה-DN **הקטין** פער קדם-קיים, לא יצר). (ב) הוספת rungs ISO-קדח 65/80/100/150/300 → 3 ברזי-אוגן PPR (dims['DN']=80/100/150=קדח-אוגן) שומרים DN80/DN100/DN150 (לא מידה-מזויפת) + `canonicalDn` אידמפוטנטי לפלטי-אינץ'. **ידוע קדם-קיים (מחוץ להיקף):** ~59 מוצרי-משפחת-מנוע (פקקי-נחושת) — `odOf` לא קורא אינץ' → מידתם חסרה מגלגל-המשפחה; ה-DN הקטין מ-158→59, לא הסיבה. גולדנים: ½"→DN15·2"→DN50·110→DN110·DN80→DN80·DN576→DN400·43→DN40.

## #catalog-config-full-wheels — גלגלי-צד מלאים (spinner) + גרירה 4-כיוונית משנה וריאנט — 2026-08-07
- **הנכס:** משוב-בעלים: "תתקן את שני הגלגלים (כמות וקוטר) לגלגל מלא… אני רוצה להגיע 56, לא אחד-אחד" + "משיכה לימין/שמאל/למעלה/למטה משנים את השם ואת התמונה". שני תיקונים ב-`config_card`: (1) **גלגלי-צד מלאים** — `_sideWheels` (קוטר) ו-`_qtyWheel` הוחלפו מ-tap-cells (חלון-קומפקטי · כמות תקועה 1..4) ל-`WheelPicker` הקיים (native `ListWheelScrollView` · fling+snap). כמות = 1..`_kMaxQty`(999). קוטר מציג `canonical` (DN-טהור) בעמודה הצרה, הרמז-אינץ' נשאר בפִּיל. הוסרו העוזרים המתים `_wheelCells`/`_window`/`_wheelValue`/`_colHeader`/`_kWheelWindow`/`_cDim`/`_cWheelOff`. (2) **גרירה 4-כיוונית** — `_primary`(↕)/`_secondary`(↔) נופלים-חזרה ל-`_usable[0]` (קוטר) כשאין ציר ייעודי → אף כיוון לא מת; ו-`_usable` סונן ל-`_kConfigAxes` (קוטר/זווית/אורך/יציאות/מעבר/צבע/חומר בלבד) — **מוציא** מתארים (סוג/שיטה/מין/מותג/יעד/תכולה) שלא משנים וריאנט (הבאג: ↔ גלגל 'סוג'→אותו SKU).
- **תקלות מוזרקות (mutation-sensitivity):** (1) `_qtyWheel` חזרה ל-`q<=4` → הבדיקה `qty spinner reaches past 4` נכשלת (56 בלתי-נגיש). (2) `_secondary` בלי fallback ל-`_usable[0]` → מוצר-2-צירים: ↔ מת → `↔ FALLS BACK to קוטר` נכשלת (diameter=='20' לא משתנה). (3) בלי סינון `_kConfigAxes` → top-3=[diameter,angle,kind] · ↔=kind → `BOTH ↕ and ↔ change the name` נכשלת (kind→אותו שם). (4) `_dnAttribute` על `diameter-small` (חזרה ל-startsWith) כבר-מכוסה ב-dn-scale. (5) גלגל-קוטר מציג `labelHe` (`DN15 · ½"`) בעמודת 62px → חיתוך → נבחר `canonical`.
- **בטיחות:** מגודר-על-הבית (חי) — משנה את הכרטיס החי; אין שינוי ב-`WheelPicker`/`prioritizedSchema`/`dn_scale`/ring_dive. `_kMaxQty`=999 · `ListWheelScrollView` עצל (999 שורות = 0 עלות-בנייה). הפִּיל+ההתאמה משתמשים ב-`canonical` (DN-טהור) → seed עדיין תואם.
- **אימות:** analyze 0 · catalog_config **104/104** (+2). מבחן-אמת: `spinning קוטר` + `qty spinner >4` + `↔ fallback to קוטר` + **`REAL card: BOTH ↕ and ↔ change the variant name`** (213072 · ↕=angle · ↔=diameter-fallback · שם משתנה בשני הכיוונים). probe: config-filter → 4/5 מוצרים משנים בשני הכיוונים; multi-step drag (5 צעדים) מדלג על כפילויות-נתונים.

## #internal-card-per-side — פר-צד אמיתי + רַכֶּבֶת-עיגולים על התמונה (D4) — 2026-08-08
- **הנכס:** משוב-בעלים ("צריך להיות כמו בתמונה #3 — ימין≠שמאל, על התמונה"). `compatibleProductsForEnd(p, endIndex)` + `verifiedEndsCountFor` (חדשים · `related_info`) — תואמים ל**קצה בודד** דרך `ConnectorEnd.directMatesWith` פר-קצה (לא כלל-המוצר). `full_internal_card._sideRail` שוכתב: התמונה נשארת גלויה (`Stack`), רַכֶּבֶת-עיגולים (`_railChip`: אימוji-צורה + מידה) לאורך הצד-הפעיל, נקודת-חיבור על התמונה, כותרת "מתחבר לצד שמאל/ימין"; החלקה-שמאל→קצה[0], ימין→קצה[אחרון] (`_railSide`/`onSwipeImage`, `initialRailSide` ל-preview/test).
- **תקלות מוזרקות (mutation-sensitivity):** (1) `compatibleProductsForEnd` מתעלם מ-`endIndex` (תמיד קצה[0]) → שני הצדדים זהים → `compatibleProductsForEnd is truly per-end` נכשלת (`e0 == e1`). (2) `_railSide` fallback ל-`endIndex=0` בשני הכיוונים → החלקה-ימין מציגה את קצה-שמאל → אותה רַכֶּבֶת → אותה בדיקה נכשלת. (3) `verifiedEndsCountFor` מחזיר קבוע 1 → קצה-ימין=קצה[0] → כנ"ל. (4) `_sideRail` חוזר לרשימה-שמחליפה-תמונה (P6·8) → התמונה נעלמת → פערי-פריסה מול צילום #3 (אימות-ויזואלי).
- **בטיחות:** מגודר `kInternalCard` OFF · byte-identical (הכל בתוך הכרטיס המגודר + 2 פונקציות טהורות ב-`related_info` הנצרכות רק על-ידיו · tree-shaken כבוי). `directMatesWith`/`kVerifiedSpecs` קריאה-בלבד.
- **אימות:** `flutter analyze` 0 · `full_internal_card_test` **10/10** (כולל per-end). probe ויזואלי: דיור-ברז 77775256 — ימין=ברז/ניפל/פקק/רקורד · שמאל=זרועות-דוש (סטים נבדלים), תמונה גלויה + רַכֶּבֶת-עיגולים בצד.
## #catalog-config-material-rail — רכבת-משפחה מדופדפת-לפי-חומר (2026-08-09)
- **הנכס:** משוב-בעלים "משיכת כותרת-המשפחה ←/→ = סוג החומר". `browse_model.browseAll` מקבץ פר-(חומר×סוג) (`groupKey='$material$typeKey'`) — אותו ברך = אריח-PPR + אריח-HDPE + אריח-נחושת; `_materialOf`=materialOfEnriched→canonicalMaterial; `_byMaterialThenType` ממיין לפי `_kMaterialOrder` (פלסטיק→מתכת→''-אחרון · stable-בתוך-חומר). `ConfigTile += materialHe`; `ConfigFamily += materials`/`tilesFor`. `catalog_config_screen._FamilySection`→`StatefulWidget`: `_onHeaderDrag` (מצבר-`_accH`, `_kMaterialDragStep`=64) מדפדף `_matIdx`; הרכבת=`tilesFor(_material)`; כותרת=תווית-חומר + `_MaterialDots`.
- **תקלות מוזרקות (mutation-sensitivity):** (1) `groupKey=typeKey` (בלי material) → אין פיצול-חומר → `splits per material` נכשל (materials.length=1). (2) `_materialRank` בלי טיפול-''-אחרון → קבוצת-כללי לא-אחרונה → `materials.last==''` נכשל. (3) `_byMaterialThenType` לא-stable (sort רגיל) → סדר-סוגים בתוך-חומר לא-דטרמיניסטי. (4) הרכבת מציגה `family.tiles` (כל החומרים) במקום `tilesFor(_material)` → משיכה לא מסננת → `header swipe pages material` נכשל (PPR עדיין מוצג). (5) `_onHeaderDrag` בלי `setState`/clamp → אין דפדוף/חריגת-אינדקס.
- **בטיחות:** מגודר-על-הבית (חי) · `materialOfEnriched`/`canonicalMaterial` קריאה-בלבד · שאר-הפיצ'ר ללא-שינוי. אריחים חסרי-חומר → קבוצת-'' אחרונה (לא נעלמים).
- **אימות:** analyze 0 · catalog_config **108/108** (+4). widget-test מדמה את המחווה: משיכת-כותרת מעבירה חומר מ-PPR (התווית משתנה); browseAll → חיבורים 44 אריחים מקובצים (PPR ראשון · כללי אחרון · ברך גם ב-PPR וגם בנחושת).

## #catalog-config-material-filter — הכרטיס-הפנימי מסונן לחומר-הכותרת (2026-08-09)
- **הנכס:** משוב-בעלים "בפנימי שיציג רק מה שיש לפי הכותרת שזה יהיה מעין סינון" (כרטיס-הקונפיג · הגלגלים). האריח כבר יודע-חומר (`#catalog-config-material-rail`); כעת גם הכרטיס: (1) `catalog_taxonomy.materialOf` — `_materialOf` הפרטי (שהיה משוכפל ב-`browse_model`) עלה ל-**ציבורי**, נגזרת-חומר אחת שהרכבת מקבצת לפיה **וגם** הכרטיס מסתנן אליה (מקור-אמת אחד — אריח↔כרטיס תמיד מסכימים); `browse_model` צורך אותו, המחיקה DRY. (2) `catalog_config_screen._materialUniverse(p)` = חברי-`typeGroupOf` החולקים את `materialOf(p)`; ה-`ConfigCard.schema = prioritizedSchema(p, universe: _materialUniverse(p))` — הגלגלים נאגרים מ**החומר בלבד** (המנוע כבר אוגר-מ-universe · פאזה F — כאן רק צמצום-הקלט). (3) `config_card._resolveFamily` מסנן את `_family` (קבוצת-החלפת-הווריאנט בגרירה) לאותו חומר — ↕/↔ נשארים בתוך החומר.
- **תקלות מוזרקות (mutation-sensitivity):** (1) `prioritizedSchema(product)` בלי `universe: _materialUniverse` (חזרה ל-`resolvedCatalogProducts` המלא) → גלגל-נחושת מציג מידות-פלסטיק → `wheel is MATERIAL-scoped` נכשל (`scopedWheel.length < allWheel.length` שקר · DN110 חוזר). (2) `_materialUniverse` בלי מסנן-`materialOf` (מחזיר את כל ה-typeGroup) → זהה ל-#1. (3) `_resolveFamily` בלי סינון-חומר על `_family` → גרירה על כרטיס-נחושת קופצת לווריאנט-פלסטיק (חוצה-חומר). (4) `materialOf` לא-דטרמיניסטי / `''`-לכולם → כל האריחים מתמזגים → גם `splits per material` (rail) נשבר. 
- **בטיחות:** מגודר-על-הבית (חי) · `materialOfEnriched`/`canonicalMaterial`/`typeGroupOf`/`prioritizedSchema` קריאה-בלבד · רק צמצום-קלט (universe קטן יותר) — אין מסלול-קוד חדש במנוע. חומר-חסר ('') → הכרטיס מסתנן לקבוצת-'' (עקבי עם הרכבת · לא מתרוקן — typeGroup תמיד מכיל את המוצר עצמו).
- **אימות:** `flutter analyze` 0 · catalog_config **109/109** (+1). probe: ברך-נחושת 77777677 → גלגל-קוטר 18→3 (DN15/DN20/DN25 · נחושת בלבד · בלי DN110); ברך-PPR 92117104 → 15=15 (כבר-מסונן-מנוע · נכון). הבדיקה מוודאת subset + קיצור + היעדר-DN110.

## #catalog-config-image-drag-angle — משיכת-תמונה אנכית (זווית) מחליפה וריאנט (2026-08-09)
- **הנכס:** משוב-בעלים "משיכה של התמונות לא עובד" — רק ↔ (קוטר) החליף וריאנט, ↕ (זווית) לא. שורש (מאובחן ב-probe): **אי-התאמת-canonical של הזווית** — גלגל-הזווית של משפחת-מנוע (`_angleValues`) פולט `45`/`90`, אך של מוצר-axisChips (`catAxesOf`) פולט `45°`/`90°`; משפחת-הווריאנט (`chipValuesOf`) פלטה `45°`/`90°`. משיכה קבעה `_selection['angle']` לטוקן-הגלגל שלא תאם אף חבר-משפחה → `variantByAxes` דילג על הזווית → אותה תמונה. תיקון תלת-חלקי: (1) `chipValuesOf` מקפל זווית ל-`\d+` (`45°`→`45`); (2) `_angleAttribute` חדש ב-`prioritizedSchema` (choke-point, סימטרי ל-`_dnAttribute`) מקפל **כל** גלגל-זווית ל-canonical ספרתי — labelHe נשאר `45°` לתצוגה; (3) `config_card._lastAxis` — כל `_select` (גלגל/משיכה) מסמן את הציר, ו-`_variant()` פותר אותו ראשון ב-axisOrder כך שהציר-הנגרר מנצח את הקוטר-קודם.
- **תקלות מוזרקות (mutation-sensitivity):** (1) בלי `_angleAttribute` → גלגל-axisChips נשאר `15°` בעוד המשפחה `15` → 213072 ↕ לא מחליף → `BOTH ↕ and ↔ drags change the variant name` נכשל. (2) בלי קיפול-זווית ב-`chipValuesOf` → משפחה `45°` בעוד הגלגל `45` → ברך-PPR ↕ לא מחליף → `VERTICAL drag swaps 45°→90°` נכשל. (3) בלי `_lastAxis`-קודם → הקוטר-קודם קובע, ↕ בזווית שאין-לה-וריאנט-בקוטר-הנוכחי → דילוג → אין החלפה (213072). (4) קיפול על labelHe (לא canonical) → הגלגל מציג `45` במקום `45°` → אובדן-תצוגה.
- **בטיחות:** מגודר-על-הבית (חי) · `_angleAttribute`/`_angleDigits` טהורים · labelHe נשמר (תצוגה `45°` ללא-שינוי) · `_dnAttribute`/`variantByAxes` ללא-שינוי-לוגי (רק סדר-צירים דינמי). הקיפול מוגבל ל-`id=='angle'` (סימטרי עם diameter/DN).
- **אימות:** `flutter analyze` 0 · catalog_config **112/112** (+3 image-drag). probe: ברך-PPR ↕ `45°→90°`→`45°` · ↔ `20→63`; 213072 שני הכיוונים מחליפים; `chipValuesOf` זווית = ספרות בלבד.

## #catalog-config-elbow-image-mix — תמונות-ברך שגויות + ביטול קפיצת-וריאנט (2026-08-09)
- **הנכס:** משוב-בעלים "ערבוב בין ברכים מסעפים" (במשיכת-תמונה). מאובחן ב-drag-trace: המשיכה נחתה על מוצרי-ברך אמיתיים (שמם "ברך"), אך התמונה שלהם שגויה. שורש כפול: (1) **data** — `fitting_image_overrides.dart` (auto-gen, commit `aafd434d`) מיפה `92117042–92117051` ("ברך PPR 90°") → `98417808_3.jpeg` = צילום **צווארון PPR 75**, ו-`92117109` ("ברך 45°") → `95270720_1.jpeg` = **צינור**. (2) **logic** — `config_card._lastAxis` (מ-`309084b2`) פתר את הציר-הנגרר ראשון, וכך משיכת-זווית קפצה למוצר-הראשון-עם-אותה-זווית מכל קוטר/סוג (למשל "זווית 105° NTM" מחבר-ענפי) — קפיצה שנראית כ"ערבוב".
- **התיקון:** (1) הוסרו 11 המיפויים השגויים (ברך→צווארון/צינור) → נפילה-חזרה ל-`_pprImageFor(kPprElbows)` = `ppr_elbow_90.jpg`/`_45.jpg` (תמונת-ברך אמיתית). מיפויי מסעף→מסעף (`992213xxx`→`992113139`) נכונים, נשמרו; `64032300` (לא-ברך/מסעף) נשמר. (2) בוטל `_lastAxis` (3 עריכות ב-config_card) — חזרה ל-axisOrder קבוע [diameter,angle,length] ⇒ משיכה קוהרנטית (קוטר-נשמר). תיקון-הטוקן-של-הזווית נשמר (המשיכה-האנכית עדיין עובדת ב-PPR).
- **תקלות מוזרקות (mutation-sensitivity):** (1) החזרת מיפוי `92117042→98417808` → ברך-90° מציג צווארון → trace-image נכשל (`ppr_p19_b`≠`98417808`). (2) החזרת `_lastAxis` → material-less ↕ קופץ ל-NTM (drag-trace). (3) הסרת גם מיפויי-המסעף (992213) → מסעפים מאבדים תמונה (over-removal). (4) ביטול תיקון-הטוקן → PPR ↕ מפסיק לעבוד (`image_drag_test`).
- **בטיחות:** `fitting_image_overrides` = data-only, נצרך ב-`polyroll_catalog` כ-`imageAssetOverride`; הסרה מפעילה את ה-fallback הקיים (לא ריק). `_lastAxis` היה תוספת-סשן, ביטולו מחזיר להתנהגות-הבסיס. מגודר-על-הבית (חי).
- **אימות:** `flutter analyze` 0 · catalog_config **112/112**. fixture של `BOTH ↕ and ↔` הוחלף מ-213072 (edge-case חד-זוויתי-לקוטר) ל-92117102 (PPR · DN20 ב-45°+90°) עם universe מסונן-חומר (כמו המסך). drag-trace: ברך-PPR 90° → `ppr_p19_b.jpg`.
