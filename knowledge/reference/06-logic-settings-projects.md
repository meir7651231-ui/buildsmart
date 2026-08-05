# לוגיקה: הגדרות · פרופיל · פרויקטים · תקציב · פרויקט-חכם · סטטוס (6560–7700)

> שיטת-לכידה לפונקציות: **תפקיד + זרימה + חיווט**, לא העתק-קוד. שמות+שורות מדויקים.

## הגדרות (6750–7012)
### `SETTINGS_LABELS` (6750) — מפות value→תווית
`textSize`(קטן/בינוני/גדול) · `theme`(בהיר/כהה) · `defaultHaul`(משלוח קטן/טנדר/משאית) · `lang`(עברית/العربية/English) · `units`(`מטרי (מ׳, ק״ג)`/`אימפריאלי`) · `currency`(`₪ שקל`/`$ דולר`). (verbatim units/currency: INSP-0007.)
### `renderSettings()` (6806) — sheet "הגדרות מתקדמות", **8 קבוצות + reset**:
1. 👤 **חשבון** — שם/טלפון/סוג-עוסק/תחום (`editAccountField`, מ-`userProfile`).
2. 🔔 **התראות** (toggles אמיתיים): shipments · deals · budget · orders.
3. 🎨 **תצוגה**: theme · textSize · reduceMotion.
4. ♿ **נגישות**: `מצב ניגודיות גבוהה (לשמש)` (`toggleHighContrast`, verbatim @6842 / INSP-0006).
5. 🔒 **אבטחה והרשאות**: → `openSecurityHub` (2FA·RBAC·יומן).
6. 🎧 **שירות ותמיכה**: → `openServiceHub` (תמיכה·צ׳אטבוט·כלים).
7. 🚚 **משלוח ותשלום**: defaultHaul · express (`ברירת מחדל — משלוח אקספרס`, verbatim/INSP-0006) · payment.
8. 🌍 **אזור ושפה**: lang · units · currency.
> כותרות-הקבוצות verbatim בסדר-המקור (`renderSettings` @6806, INSP-0005): חשבון · התראות · תצוגה · נגישות · אבטחה והרשאות · שירות ותמיכה · משלוח ותשלום · אזור ושפה · מידע · איפוס.
9. ℹ️ **מידע**: גרסה "BuildSmart 1.0 · אב-טיפוס" · תנאי/פרטיות · קשר `support@buildsmart.demo`.
10. ↺ **danger**: `resetSettings`.
- builders: `setGroup/setToggle/setSelect/setLink` (6883–6911). מצב ב-**`appSettings`**.
  `toggleSetting/cycleSetting` (6912/6921) — כולל haptic+ARIA+toast. **`applySettings()`** (6974) מחיל על ה-DOM. `applyEntryMode` (6998). `isDemoMode()` — חשבון-הדגמה (פעולות-חשבון תצוגה-בלבד).
### `openHelp()` + `HELP` (6765) — 5 שו"ת
צילום-תוכנית · עץ-המוצרים · הפרויקטים-שלי · איך-מזמינים · איך-מקבלים. CTA "הבנתי, אפשר להתחיל".

## פרופיל (6677–6745)
`statTile/settingRow` (builders) · `openIdentityEditor` · `openRankDetail/closeRankDetail` (sheet-דרגה).
> ⭐ **מבנה (INSP-0017):** טאב-`הגדרות` בלגאסי הוא בעצם **טאב-פרופיל/זהות בן 10 sections** (`refreshIdentity` @6545–6680); ה-dial של "הגדרות-מתקדמות" = **רק section #9** מתוכם (8 sections-תוכן + קישור-הגדרות + footer).

## היסטוריה + בוררי אתר/זמן (7013–7131)
- `DEMO_HISTORY` (7013) — הזמנות-חוזרות (name/price/icon/cat/ago): מקדחה בוש GBH ₪640 · שק מלט ₪31. `renderReorderHistory` (7017).
- **בורר-אתר** (7041): `openSitePicker/chooseSite/saveSiteName`.
- `DELIVERY_WINDOWS` (7103) = `['עד שעה','עד שעתיים','היום אחה"צ','מחר בבוקר','חלון מתוזמן']`. **בורר-זמן**: `openDeliveryPicker/chooseDelivery`.
- `saveTreeProgress` (7132) — שומר התקדמות-עץ ל-`treeProgress` של האתר הפעיל.

## תקציב (7159–7297)
`renderBudget` · `openBudgetEditor/Detail` · `openCategoryEditor`/`addBudgetCategory`/`saveCategoryEdit`/`deleteCategory` · `saveBudget` · **`adjustBudget(dir)`** (הוסף/הורד עלות, ±).

## פרויקט-חכם (7299–7454)
- בורר-יום: `openDayPicker/jumpToDay`.
- **`renderSmartProject()`** (7348) → `view-project` (פירוק שלבים לימי-עבודה). `toggleStageCard`/`toggleSmartDay`/`toggleSmartStep` · `taskTreeKey`.

## אתרים/פרויקטים (7455–7630)
**`renderProjects()`** (7455) → `view-sites`. `openSiteCart`/`openSiteProject` · `switchProject`/`switchProjectSilent` · `openSiteStatus`/`closeSiteStatus` (sheet-סטטוס) · `openSiteEditor`/`saveSiteEdit` · `openProjectModal`/`saveProject`.

## סטטוס-הזמנה (7632–7700)
- `ORDER_STATUS` (7632) — 4 סטטוסי-תצוגה: `pending`(ממתינה) · `processing`(בהכנה) · `shipped`(בדרך) · `delivered`(נמסרה) + CSS-cls.
- **`resolveStatus(o)`** (7641) — מנרמל `status` (הזמנות-חדשות) **ו**-`stage` (seed: new/preparing/ready/transit/delivered) ל-4 הסטטוסים. `fmtOrderDate` · **`orderTotal`** · `orderItemCount` · `syncStatusFromSystem`.

---

## 🔄 Preact (`app/src/components/menu/submenu-settings.tsx`) — דלתא (הגדרות = dial)
> 1461 ש׳ — תרגום `renderSettings` (sheet) ל-**עץ-dial**. state ב-`app-store.ts` (settingsLevel/group/path).

⬆️ **שודרג:**
- **8 קבוצות (sheet) → `SETTINGS_ROWS` 9 קבוצות (dial):** account · notifications · display · accessibility · security · support · delivery · region · about (+reset). אותן קבוצות, כ-dial-rows.
- **`SETTINGS_SUB`** = `Record<SettingsGroupId, Node[]>` — עץ-dial עמוק לכל קבוצה (`Node={label, children?}`). `walkSettings` מנווט; רנדרים `SettingsTopSubmenu`/`SettingsSubmenu`/`SettingsTreeSubmenu`.
- **`SETTINGS_LABELS` → `LEAF_BINDINGS`** = `Record<string, Binding>` (key=`'group>label>label'`) — **72 עלים מחווטים** (אומת מהמקור `submenu-settings.tsx`; פירוט מ-`wip-menu-wiring.md`: security 23 · support 15 · region 7 · display 6 · delivery 5 · about 4 · account 4 · notif 4 · accessibility 1 · reset 1). persist: **`bs.settings.v1`** (app-settings) + **`bs.profile.v1`** (user-profile); toast 3200ms. smoke 21/21 · runRegression 236/236.
- ⭐ **סה"כ PROFILE_TREE + SETTINGS_SUB = 117 labels** — כולל **subtrees מלאים** של מרכז-אבטחה (~23) · מרכז-שירות (~16) · מועדון/תגמולים (7) · מרכז-פיננסים · B2B-services (verbatim). כלומר ה-hubs **כן ported כ-dial-leaves** (לא רק 9 הקבוצות) — ראה תיקונים בדוחות 14–17. (~84 leaves "אינטראקטיביים" סה"כ; ~70 מחווטים, השאר branches.)
- **`app-settings.ts` ארכיטקטורה (INSP-0010, אומת מהמקור):** `AppSettings = {display, notif, region, delivery, accessibility, **security**}` (6 מפתחות; `security`={twoFA,biometric,locationPerm,sessionTimeout,privacy} — לא ממופה ל-data-attr) · setters = **shallow-clone** (אין mutation) · **`effect()` יחיד חד-כיווני** → 9 `<html>` data-attrs (`data-theme/text-size/reduce-motion/lang/units/currency/haul/express/contrast`) + LS · **`load()`+`pick()`** = enum-validator (anti-corruption, אין feedback-loop). בדיקות **Playwright** התנהגותיות (currency→attr→stored→reset).
- profile → **`PROFILE_TREE`** (עץ כרטיס-קבלן/דרגות/הישגים כ-dial), מול מסך-הפרופיל. **מבנה verbatim (INSP-0019):** L1 `הגדרות-פרופיל`·`הגדרות מתקדמות` → L2 `כרטיס קבלן`·`דרגות הקבלן` → L3-כרטיס `אתה במצב הדגמה`·`המספרים שלך`·`סך הרכש דרך BuildSmart` / L3-דרגות `ההטבה שלך`·`הישגים`·`מועדון BuildSmart`. ⚠️ `הגדרות-פרופיל` = **label שחיבר הבעלים** (לא-verbatim; חריג מתועד, INSP-0019).

➕ **נוסף:** **עריכת-leaf inline** (`editingLeafKey` → `.dial__input` מחליף label). אין באב-הטיפוס (שם `editAccountField`=prompt/sheet).

➖ **הוחסר:** ה-`settingsOverlay` (sheet) — הכל dial. (מידע/גרסה/תנאי/פרטיות נשמרו כעלים.)

---

## 📱 Flutter — דלתא (הגדרות) ⭐ נכתב-מחדש מהמציאות
> ב-Flutter ההגדרות = **מסכי-הגדרות נייטיב** + תפריט-⋮ פר-טאב. ⚠️ **07-06: ה-menu-dial הוסר** (`b9737cf`) — ההגדרות נגישות נייטיב בלבד (עצי-ההגדרות ב-`data/settings_tree.dart` מוגשים נייטיב).
⬆️ ⚠️ **`data/settings_tree.dart` הוסר 07-06** (ההגדרות נייטיב ב-4 מסכי-ה-settings למטה). [היסטורי] עצי-הגדרות `kSettingsGroups` — **10 קבוצות** (חשבון/התראות/תצוגה/נגישות/אבטחה/שירות/משלוח/אזור/מידע/איפוס), ~38 leaves (theme/textSize/lang/units/haul/express/contrast/2FA/biometric/notif/privacy). מצב ב-`state/app_settings.dart` (Riverpod + `bs.settings.v1`).
➕ **נוסף — 4 מסכי-הגדרות native** (~140 שדות, persist אמיתי, ExpansionTile עם count-badge, reset-dialog): **`catalog_settings_screen`** (~40: חיפוש/תצוגה/מחירים/מועדפים/יחידות/ספקים/AI/נגישות — פעילים: view/grid/image-size/text-size/contrast/reduced-motion/search-history) · **`chat_settings_screen`** (~30: presence/notif/media/privacy/backup/bot) · **`notif_settings_screen`** (~40: snooze/channels/types/quiet-hours/per-persona/lock-screen) · **`store_settings_screen`** (~30: shipping/payment/invoices/cart-gates). keys `bs.{catalog/chat/notif/store}-settings.v1`.
🔧 **מול פרוטוטייפ/Preact:** שם הגדרות = dial-עץ בלבד; ב-Flutter **מסכים-מלאים נייטיב** (הדיאל הוסר 07-06) — עשיר יותר (~140 שדות מול ~70).
