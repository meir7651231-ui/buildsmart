// 📜 קובץ-ראשי · screens__store_settings_screen — פירוק הגדרות-החנות (בנייה-חכמה) לאטומים-נקיים.
// מוצא קדוש: scratchpad/all-screens/screens__store_settings_screen.dart (1,135 שורות) — לא נגענו.
// מפת-המכונה: screens-seed/machine/screens__store_settings_screen.json
// תוכן: new/dart-data-bs/screens__store_settings_screen_content.dart (verbatim, שמות-סמנטיים).
//
// ── אטומי-מדף שנצרכים (הכרעה-5: צורכים, לא משכפלים) — 7 מנגנונים ──────────────
// המסך הוא תאום-מנגנוני של screens__chat_settings_screen; אטומי-המדף שלו מתאימים 1:1:
// • SettingsScreenShell (new/dart-ui-bs/screens__chat_settings_screen/settings_screen_shell.dart)
//   ⇐ StoreSettingsScreen שורות 35–72: אותו Scaffold+AppBar+כפתור-איפוס+ListView.
//   הקופסה מזרימה: title=content.appBarTitle · resetTooltip · resetIcon=Icons.restart_alt ·
//   onResetTap=זרימת-האיפוס · titleColor=inkLight · iconColor=black54.
// • ConfirmDialog (screens__chat_settings_screen/confirm_dialog.dart)
//   ⇐ דיאלוג-האיפוס שורות 76–115 וגם confirmDestructive של מחיקת-חיפושים (653–658).
//   ההסתרה-המרוכבת של CfgVisible (cancel/reset_ok, שורות 94–113) = הקופסה מוסרת את
//   cancelLabel/confirmLabel; confirmColor=dangerDark (AA, הערת-המקור שורה 107) מוזרק.
// • SettingsSectionTile (screens__chat_settings_screen/settings_section_tile.dart)
//   ⇐ _SectionTile שורה 689. שער kHideUnderConstruction + _isUnderConstruction +
//   _activeCount + _visibleChildren (708–729) = ידע-קופסה: הקופסה מסננת children,
//   מחשבת badgeCount (null בסקציה-בבנייה/ריקה) ומזריקה subtitleNote=sectionNote או null.
// • SettingsSwitchRow (screens__chat_settings_screen/settings_switch_row.dart)
//   ⇐ _SwitchRow שורה 800. underConstruction ⇒ subtitleNote=rowNote (או null);
//   סימון _Inert לספירת-פעילים = ידע-קופסה.
// • SettingsRadioGroupRow (screens__chat_settings_screen/settings_radio_group_row.dart)
//   ⇐ _RadioGroupRow שורה 834 — זהה-מבנה כולל רשומות (value,label).
// • SettingsActionRow (screens__chat_settings_screen/settings_action_row.dart)
//   ⇐ _ActionRow שורה 1108; buttonColor=dangerDark (AA, הערת-המקור שורה 1127) מוזרק.
// • PlaceholderRow (new/dart-ui-bs/placeholder_row.dart)
//   ⇐ _PlaceholderRow שורה 1089; badge=underConstructionContent.badge, הטוסט
//   (tapToastTemplate, תבנית-$) מפורמט בקופסה ונמסר כ-onTap מוכן.
//
// ── אטומים חדשים בתיקייה זו (אין זהה-מנגנון במדף — עוגנים) ─────────────────────
// • settings_validated_text_row.dart — SettingsValidatedTextRow ⇐ _InlineTextRow שורה 896.
//   ≠ SettingsInlineTextRow שבמדף: המדף הוא maxLines:2 בלי errorText ובלי תת-כותרת;
//   כאן שורה-אחת + errorText (ולידציית ח.פ., מקור 288–293) + subtitleNote (מקור 952–960).
// • settings_number_row.dart — SettingsNumberRow ⇐ _NumberRow שורה 989. אין מקבילה
//   במדף (grep digitsOnly / TextInputType.number על new/dart-ui-bs ⇒ ריק): תווית
//   משמאל + שדה-ספרות ברוחב קבוע, פרסור int.tryParse??0 נשאר באטום (מנגנון-קלט).
//
// ── התרת-סבך: קריאות-provider ⇒ props/callbacks (מה הקופסה תזרים) ──────────────
// כל 9 הסקציות (_ShippingSection…_PrivacySection) קוראות storeSettingsProvider —
// באטומים אין ref: value של כל שורה מגיע כ-prop, כל עדכון כ-callback. הקופסה תזרים:
// • ref.watch(storeSettingsProvider) ⇒ ערכי value של כל המתגים/רדיו/טקסט/מספר.
// • ref.read(storeSettingsProvider.notifier).update((s)=>s.copyWith(...)) ⇒ onChanged
//   של כל שורה (defaultAddress, preferredDeliveryWindow, … dailyCreditLimit).
// • ref.read(storeSettingsProvider.notifier).reset() ⇒ אחרי ConfirmDialog=true;
//   ואז טוסט content.resetDoneToast (מקור 116–119).
// • ref.read(storeSearchQueryProvider.notifier).state = ריק (מקור 660) ⇒ onTap של
//   שורת מחיקת-החיפושים, אחרי ConfirmDialog הרסני; טוסט clearSearchDoneToast.
// • validBusinessId (logic/input_validators, מקור 291) ⇒ הקופסה מחשבת errorText
//   (ריק/תקין ⇒ null, אחרת businessIdError) — האטום רק מציג.
// • שורה-מותנית: סף-האישור-הכפול מרונדר רק כש-confirmLargeOrder דלוק (מקור 408) —
//   הרכב הילדים = תוכנית-חיווט של הקופסה.
// • אופציות-המיון מגודרות !kHideUnderConstruction (rating/distance, מקור 521–524) —
//   הקופסה בונה את רשימת-האופציות; האטום עיוור לשער (חוק-5).
// • KbScreen/kKbGlobal/kbStoreSettingsNodes (מקור 28, 73) — עטיפת-מראה-מקלדת = לוח/קופסה.
// • CfgText/CfgVisible עם מזהי store_settings_screen.* — חיווט-סטודיו של הקופסה;
//   האטומים מקבלים מחרוזות-מוכנות (או הסרת-prop כהסתרה-מרוכבת).
// • showToast — fx של הקופסה; אף אטום לא נוגע בטוסט.
// • הערות-WIRED במקור (מילוי-מוקדם openShipToSheet 135–137 · שער chip אשראי-ספק
//   ב-checkout ‏237–239 · שער כפתור-שיתוף-הסל 426–428 · שער הסתרת-הזמנות 638–640) —
//   חיווט-צולב-מסכים שהקופסה/לוח-האם מממשים; אינו ידע של האטומים.
//
// ── פיגמנטים (חוק-5: צבע=פיגמנט, התפקיד בקופסה) ────────────────────────────────
// BsTokens.inkLight/mutedLight/brand/dangerDark · Colors.black54 · Colors.white ·
// Color(0xFFF2F3F5) — כולם מוזרקים כפרמטרי-Color ע"י הקופסה; אפס token באטומים.
