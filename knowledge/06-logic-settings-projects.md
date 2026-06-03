# לוגיקה: הגדרות · פרופיל · פרויקטים · תקציב · פרויקט-חכם · סטטוס (6560–7700)

> שיטת-לכידה לפונקציות: **תפקיד + זרימה + חיווט**, לא העתק-קוד. שמות+שורות מדויקים.

## הגדרות (6750–7012)
### `SETTINGS_LABELS` (6750) — מפות value→תווית
`textSize`(קטן/בינוני/גדול) · `theme`(בהיר/כהה) · `defaultHaul`(משלוח קטן/טנדר/משאית) · `lang`(עברית/العربية/English) · `units`(מטרי/אימפריאלי) · `currency`(₪/$).
### `renderSettings()` (6806) — sheet "הגדרות מתקדמות", **8 קבוצות + reset**:
1. 👤 **חשבון** — שם/טלפון/סוג-עוסק/תחום (`editAccountField`, מ-`userProfile`).
2. 🔔 **התראות** (toggles אמיתיים): shipments · deals · budget · orders.
3. 🎨 **תצוגה**: theme · textSize · reduceMotion.
4. ♿ **נגישות**: high-contrast (`toggleHighContrast`).
5. 🔒 **אבטחה**: → `openSecurityHub` (2FA·RBAC·יומן).
6. 🎧 **שירות**: → `openServiceHub` (תמיכה·צ׳אטבוט·כלים).
7. 🚚 **משלוח ותשלום**: defaultHaul · express · payment.
8. 🌍 **אזור**: lang · units · currency.
9. ℹ️ **מידע**: גרסה "BuildSmart 1.0 · אב-טיפוס" · תנאי/פרטיות · קשר `support@buildsmart.demo`.
10. ↺ **danger**: `resetSettings`.
- builders: `setGroup/setToggle/setSelect/setLink` (6883–6911). מצב ב-**`appSettings`**.
  `toggleSetting/cycleSetting` (6912/6921) — כולל haptic+ARIA+toast. **`applySettings()`** (6974) מחיל על ה-DOM. `applyEntryMode` (6998). `isDemoMode()` — חשבון-הדגמה (פעולות-חשבון תצוגה-בלבד).
### `openHelp()` + `HELP` (6765) — 5 שו"ת
צילום-תוכנית · עץ-המוצרים · הפרויקטים-שלי · איך-מזמינים · איך-מקבלים. CTA "הבנתי, אפשר להתחיל".

## פרופיל (6677–6745)
`statTile/settingRow` (builders) · `openIdentityEditor` · `openRankDetail/closeRankDetail` (sheet-דרגה).

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

## 🔄 Preact (`app/src/components/menu/submenu-settings.tsx`) — דלתא (הגדרות = dial, R3/R9)
> 1461 ש׳ — תרגום `renderSettings` (sheet) ל-**עץ-dial**. state ב-`app-store.ts` (settingsLevel/group/path).

⬆️ **שודרג:**
- **8 קבוצות (sheet) → `SETTINGS_ROWS` 9 קבוצות (dial):** account · notifications · display · accessibility · security · support · delivery · region · about (+reset). אותן קבוצות, כ-dial-rows (R3).
- **`SETTINGS_SUB`** = `Record<SettingsGroupId, Node[]>` — עץ-dial עמוק לכל קבוצה (`Node={label, children?}`). `walkSettings` מנווט; רנדרים `SettingsTopSubmenu`/`SettingsSubmenu`/`SettingsTreeSubmenu`.
- **`SETTINGS_LABELS` → `LEAF_BINDINGS`** = `Record<string, Binding>` — ~60 עלים מחווטים (toggle/select/link → אפקט אמיתי על `appSettings`).
- profile → **`PROFILE_TREE`** (עץ כרטיס-קבלן/דרגות/הישגים כ-dial), מול מסך-הפרופיל.

➕ **נוסף:** **R9 — עריכת-leaf inline** (`editingLeafKey` → `.dial__input` מחליף label). אין באב-הטיפוס (שם `editAccountField`=prompt/sheet).

➖ **הוחסר:** ה-`settingsOverlay` (sheet) — הכל dial. (מידע/גרסה/תנאי/פרטיות נשמרו כעלים.)
