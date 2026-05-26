# אפיון — מסכי הגדרות (4 מסכים)

> מסמך אפיון פורמלי. כל שורה מעוגנת בקוד מקור בלבד (R8 — אין המצאה). טקסטים עבריים verbatim כפי שמופיעים בקוד.
> קבצי מקור: `lib/screens/{catalog,chat,notif,store}_settings_screen.dart` + `lib/state/{catalog,chat,notif,store}_settings.dart`.

## 0. כללי

תבנית משותפת לכל 4 המסכים:

- **Scaffold**: רקע `0xFFF5F6FA`, light mode בלבד. `AppBar` לבן (`0xFFFFFFFF`), elevation 0, כותרת verbatim.
- **כפתור איפוס**: ב-`AppBar.actions` יש `IconButton` עם `Icons.restart_alt` ו-tooltip `'איפוס לברירת מחדל'`. לחיצה פותחת `AlertDialog` עם כותרת `'איפוס הגדרות?'`, פעולות `'ביטול'` / `'אפס'` (אדום). באישור: `notifier.reset()` → state חוזר ל-`defaults` + `prefs.remove(key)`, ואז toast `'הגדרות אופסו'`.
- **count-badge**: כל קטגוריה היא `ExpansionTile` שבמקום ה-chevron מציג badge עגול (צבע `BsTokens.brand`) עם מספר השורות הפעילות — `_activeCount` סופר את כל ה-children פרט ל-`_PlaceholderRow` (שורות "בבנייה").
- **Persistence**: כל מסך מנוהל ע"י `StateNotifierProvider` ייעודי. `update()` מעדכן state ומיד `unawaited(_persist())` שכותב JSON ל-`SharedPreferences` תחת מפתח ייעודי. בעת אתחול `_load()` קורא ומפענח (`fromJson`); בשגיאה/חוסר — נשמרים ה-defaults.
  - מפתחות אחסון: קטלוג `bs.catalog-settings.v1` · שיחות `bs.chat-settings.v1` · התראות `bs.notif-settings.v1` · חנות `bs.store-settings.v1`.
- **סוגי בקרות בפועל**: `_SwitchRow` (toggle), `_RadioGroupRow<T>` (קבוצת רדיו / segmented), `_NumberRow` (stepper +/- בקטלוג; שדה מספר חופשי בחנות), `_InlineTextRow` (שדה טקסט inline — R9), `_TimeRow` (`showTimePicker`), `_ActionRow` (כפתור פעולה), `_PlaceholderRow` ("בבנייה" + toast).
- **משמעות סטטוס**: ✅ = יש אפקט אמיתי מעבר ל-persist (נצרך ע"י מסך אחר/לוגיקה — מצוין שם ההלפר). 🚧 = נשמר ב-prefs בלבד, אין צרכן בקוד. ⛔ = `_PlaceholderRow` חסום (אין שדה state כלל; toast "בבנייה").

---

## 1. הגדרות קטלוג (catalog_settings_screen.dart)

### מטרה
ניהול חוויית הקטלוג: חיפוש, תצוגה/מיון, מחירים, מועדפים, התראות קטלוג, יחידות מידה, ספקים, AI ונגישות. 9 קטגוריות. provider: `catalogSettingsProvider`.

### טבלת הגדרות

| שם (verbatim) | סוג בקרה | ברירת מחדל | טווח/ערכים | נשמר ב | אפקט | סטטוס |
|---|---|---|---|---|---|---|
| **🔍 חיפוש וסינון** | | | | | | |
| שמור היסטוריית חיפוש | toggle | `true` | bool | `searchHistoryEnabled` | נצרך ב-`catalog_screen.dart` (חוסם הוספה ל-recent searches) | ✅ |
| סרגל מיון מהיר במוצרים | toggle | `true` | bool | `quickFilterBar` | נצרך ב-`catalog_screen.dart` (מציג סרגל סינון מהיר) | ✅ |
| רדיוס חיפוש | stepper | `50` | 5–500, צעד 25, סיומת ק"מ | `searchRadius` | persist בלבד | 🚧 |
| ניקוי היסטוריה | action | — | — | — (מאפס `recentSearchesProvider`) | מנקה היסטוריה + toast `'ההיסטוריה נוקתה'` | ✅ |
| **📊 תצוגה ומיון** | | | | | | |
| סוג תצוגה | segmented | `list` | רשת (Grid) / רשימה (List) | `viewMode` | נצרך ב-`catalog_screen.dart` + `lipskey_products_screen.dart` (grid↔list) | ✅ |
| מיון ברירת מחדל | segmented | `relevance` | רלוונטיות / מחיר: זול → יקר / דירוג גבוה / חדש ביותר | `sortDefault` | persist בלבד | 🚧 |
| עמודות בתצוגת רשת | stepper | `2` | 1–4 | `gridColumns` | נצרך ב-`lipskey_products_screen.dart` (`crossAxisCount`) | ✅ |
| גודל תמונות | segmented | `medium` | קטן / בינוני / גדול | `imageSize` | נצרך ב-`lipskey_products_screen.dart` | ✅ |
| **💰 מחירים ומטבע** | | | | | | |
| הצג מחירים כולל מע"מ | toggle | `true` | bool | `showVat` | persist בלבד | 🚧 |
| מטבע | segmented | `ils` | ₪ שקל / $ דולר / € יורו | `currency` | persist בלבד | 🚧 |
| הצגת מחיר ליחידה | toggle | `true` | bool | `showUnitPrice` | persist בלבד | 🚧 |
| השוואת מחירים בין ספקים | toggle | `true` | bool | `priceComparison` | persist בלבד | 🚧 |
| **❤️ מועדפים ורשימות** | | | | | | |
| סנכרון מועדפים בין מכשירים | toggle | `true` | bool | `syncFavorites` | persist בלבד | 🚧 |
| רשימות קנייה לפי פרויקט | toggle | `true` | bool | `listsPerProject` | persist בלבד | 🚧 |
| שיתוף רשימה עם צוות | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| יבוא / ייצוא רשימה | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| התראה על שינוי מחיר במועדפים | toggle | `true` | bool | `priceChangeAlert` | persist בלבד | 🚧 |
| **🔔 התראות קטלוג** | | | | | | |
| ירידת מחיר במועדפים | toggle | `true` | bool | `notifPriceDrop` | persist בלבד | 🚧 |
| חזר למלאי | toggle | `true` | bool | `notifBackInStock` | persist בלבד | 🚧 |
| מלאי נמוך | toggle | `true` | bool | `notifLowStock` | persist בלבד | 🚧 |
| מוצרים חדשים בקטגוריה | toggle | `false` | bool | `notifNewProducts` | persist בלבד | 🚧 |
| **📏 יחידות מידה** | | | | | | |
| מערכת מידה | segmented | `metric` | מטרי (ס"מ / ק"ג) / אימפריאלי (אינץ' / לב') | `unit` | persist בלבד | 🚧 |
| פורמט מידות בכרטיס מוצר | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| פורמט הצגה | segmented | `decimal` | עשרוני (1.5) / שברי (1½) | `decimalFormat` | persist בלבד | 🚧 |
| **🏪 ספקים מועדפים** | | | | | | |
| ספקים מסומנים כמועדפים | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| ספקים חסומים | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| מרחק מקסימלי | stepper | `100` | 5–500, צעד 25, סיומת ק"מ | `maxDistance` | persist בלבד | 🚧 |
| דירוג מינימלי | segmented | `any` | ללא הגבלה / 3+ כוכבים / 4+ כוכבים / 5 כוכבים | `minRating` | persist בלבד | 🚧 |
| ספקים מקומיים בלבד | toggle | `false` | bool | `localSuppliersOnly` | persist בלבד | 🚧 |
| **🤖 AI והמלצות** | | | | | | |
| המלצות מבוססות AI | toggle | `true` | bool | `aiRecommendations` | persist בלבד | 🚧 |
| התאמה לפי היסטוריית הזמנות | toggle | `true` | bool | `historyBased` | persist בלבד | 🚧 |
| סינון לפי פרויקט פעיל | toggle | `false` | bool | `activeProjectFilter` | persist בלבד | 🚧 |
| חלופות זולות אוטומטיות | toggle | `true` | bool | `cheapAlternatives` | persist בלבד | 🚧 |
| **📱 ממשק ונגישות** | | | | | | |
| מצב קומפקטי (כרטיסים קטנים) | toggle | `false` | bool | `compactMode` | נצרך ב-`lipskey_products_screen.dart` | ✅ |
| גודל טקסט (כל האפליקציה) | segmented | `medium` | קטן / בינוני / גדול | `textSize` | נצרך ב-`main.dart` (`textScaler` 0.9/1.0/1.15) | ✅ |
| ניגודיות גבוהה (כל האפליקציה) | toggle | `false` | bool | `highContrast` | נצרך ב-`main.dart` (`AppTheme.light/dark(highContrast:)`) | ✅ |
| הנפשות מופחתות (כל האפליקציה) | toggle | `false` | bool | `reducedMotion` | נצרך ב-`home_shell.dart` + `catalog_screen.dart` (דילוג אנימציות) | ✅ |

### קריטריוני קבלה
- שינוי בכל toggle/segmented/stepper נשמר מיד ב-`bs.catalog-settings.v1` ושורד restart.
- 9 ✅: searchHistoryEnabled, quickFilterBar, ניקוי היסטוריה, viewMode, gridColumns, imageSize, compactMode, textSize, highContrast, reducedMotion (אפקט ממשי במסכים אחרים).
- badge בכל קטגוריה סופר רק שורות פעילות (לא placeholders).
- "איפוס לברירת מחדל" מחזיר את כל 30 השדות ל-`CatalogSettings.defaults`.

---

## 2. הגדרות שיחות (chat_settings_screen.dart)

### מטרה
ניהול שיחות: נוכחות/חיווי, התראות שיחה, מדיה, פרטיות, גיבוי, שפה, שיחות עסקיות, בוט, ארכיון. 9 קטגוריות + באנר "תשובות מהירות" עליון. provider: `chatSettingsProvider`.

### טבלת הגדרות

| שם (verbatim) | סוג בקרה | ברירת מחדל | טווח/ערכים | נשמר ב | אפקט | סטטוס |
|---|---|---|---|---|---|---|
| **⚡ תשובות מהירות (באנר)** | | | | | | |
| ערוך / 4 תבניות צ'יפ | action | — | תבניות: בדרך אליך 🚗 / אאשר בקרוב ✅ / קיבלתי, תודה 🙏 / נחזור אליך 📞 | — | toast "בבנייה" | ⛔ |
| **💬 שיחות וחיווי** | | | | | | |
| אישורי קריאה | toggle | `true` | bool | `readReceipts` | נצרך ב-`chats_screen.dart` (`_Bubble` — הצגת אישור קריאה) | ✅ |
| חיווי הקלדה | toggle | `true` | bool | `typingIndicator` | נצרך ב-`chats_screen.dart` (`showTyping` יחד עם `botEnabled`) | ✅ |
| תצוגה מקדימה בנעילה | toggle | `true` | bool | `lockScreenPreview` | persist בלבד | 🚧 |
| פתיחת שיחה (מענה ראשוני) | toggle | `false` | bool | `initialResponseEnabled` | persist בלבד | 🚧 |
| זמן מקוון אחרון | segmented | `contacts` | כולם / אנשי קשר / אף אחד | `lastSeenPrivacy` | נצרך ב-`chats_screen.dart` (`showOnlinePresence`) | ✅ |
| **🔔 התראות שיחה** | | | | | | |
| צלצול שיחה נכנסת | toggle | `true` | bool | `callRingEnabled` | persist בלבד | 🚧 |
| התראת הודעה חדשה | toggle | `true` | bool | `messageAlertEnabled` | persist בלבד | 🚧 |
| רטט | toggle | `true` | bool | `chatVibration` | נצרך ב-`chats_screen.dart` (`HapticFeedback.lightImpact` בשליחה) | ✅ |
| צלצול לפי איש קשר | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| השתקת שיחה ספציפית | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| **🎙️ מדיה ושמע** | | | | | | |
| הורדה אוטומטית | segmented | `wifiOnly` | WiFi בלבד / WiFi + סלולרי / תמיד / אף פעם | `mediaDownload` | persist בלבד | 🚧 |
| איכות תמונות נשלחות | segmented | `high` | מקורית / גבוהה / בינונית | `imageQuality` | persist בלבד | 🚧 |
| דחיסת וידאו | toggle | `true` | bool | `compressVideo` | persist בלבד | 🚧 |
| ניהול אחסון | action ("נקה") | — | — | — | toast `'אחסון נוקה'` (ללא לוגיקה) | ⛔ |
| **👥 פרטיות** | | | | | | |
| מי יכול לפתוח שיחה | segmented | `contacts` | כולם / אנשי קשר בלבד / שמורים בלבד | `chatPrivacy` | persist בלבד | 🚧 |
| חסימת משתמשים | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| פרטי הפרופיל (תמונה / ביוגרפיה) | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| מחיקת היסטוריה | action ("מחק", אדום) | — | — | — | toast `'היסטוריה נמחקה'` (ללא לוגיקה) | ⛔ |
| **💾 גיבוי וייצוא** | | | | | | |
| גיבוי לענן | toggle | `false` | bool | `backupEnabled` | persist בלבד (חושף "תדירות גיבוי") | 🚧 |
| תדירות גיבוי (מותנה) | segmented | `daily` | יומי / שבועי / חודשי | `backupFreq` | persist בלבד; מוצג רק אם `backupEnabled` | 🚧 |
| ייצוא היסטוריה (CSV) | action ("ייצא") | — | — | — | toast `'מייצא...'` (ללא לוגיקה) | ⛔ |
| מחיקת גיבוי ענן | action ("מחק", אדום) | — | — | — | toast `'גיבוי נמחק'` (ללא לוגיקה) | ⛔ |
| **🌐 שפה ותרגום** | | | | | | |
| שפת ממשק | segmented | `he` | עברית / ערבית / אנגלית | `lang` | persist בלבד (אינו משפיע על locale — זה `appSettingsProvider`) | 🚧 |
| תרגום אוטומטי | toggle | `false` | bool | `autoTranslate` | persist בלבד | 🚧 |
| שפת מקלדת | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| **🏪 שיחות עסקיות** | | | | | | |
| שעות פעילות עסקית | toggle | `false` | bool | `businessHoursEnabled` | persist בלבד (חושף שדות מתחת) | 🚧 |
| פתיחה (מותנה) | time picker | `08:00` | hour/min | `businessStartHour`/`Min` | persist בלבד | 🚧 |
| סגירה (מותנה) | time picker | `18:00` | hour/min | `businessEndHour`/`Min` | persist בלבד | 🚧 |
| הודעת מחוץ לשעות (מותנה) | inline text (R9) | `''` | מחרוזת, hint: "אנחנו סגורים, נחזור אליך בשעות הפעילות..." | `autoReplyMessage` | persist בלבד | 🚧 |
| קטלוג מוצרים בשיחה | toggle | `false` | bool | `catalogInChat` | persist בלבד | 🚧 |
| תשלום מתוך שיחה | toggle | `false` | bool | `paymentInChat` | persist בלבד | 🚧 |
| **🤖 בוט ואוטומציה** | | | | | | |
| בוט שאלות נפוצות | toggle | `false` | bool | `botEnabled` | נצרך ב-`chats_screen.dart` (מפעיל מענה אוטומטי + typing) | ✅ |
| ניתוב שיחות | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| ברכת פתיחה | toggle | `false` | bool | `greetingEnabled` | נצרך ב-`chats_screen.dart` (זריעת הודעת פתיחה בשיחה ריקה) | ✅ |
| טקסט הברכה (מותנה) | inline text (R9) | `''` | מחרוזת, hint: "שלום! איך אפשר לעזור?" | `greetingMessage` | persist בלבד; מוצג רק אם `greetingEnabled` | 🚧 |
| תגובה מחוץ לשעות פעילות | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| **🗂️ ארכיון וניקיון** | | | | | | |
| ארכוב אוטומטי | toggle | `false` | bool | `autoArchive` | persist בלבד | 🚧 |
| מחיקה אוטומטית | segmented | `disabled` | כבוי / 30 יום / 90 יום / 180 יום | `autoDeletePolicy` | persist בלבד | 🚧 |
| סינון ספאם | toggle | `true` | bool | `spamFilter` | persist בלבד | 🚧 |
| גיבוי לפני מחיקה | toggle | `true` | bool | `backupBeforeDelete` | persist בלבד | 🚧 |

### קריטריוני קבלה
- שינוי כל שדה נשמר מיד ב-`bs.chat-settings.v1`.
- 5 ✅: readReceipts, typingIndicator, lastSeenPrivacy, chatVibration, botEnabled, greetingEnabled (אפקט ב-`chats_screen.dart`).
- שדות מותנים (תדירות גיבוי, שעות עסקיות, טקסט ברכה) מופיעים רק כשה-toggle ההורה פעיל.
- כל ה-`_ActionRow` בשיחות מציגים toast בלבד — אין לוגיקה מאחוריהם (⛔).
- שים לב: `lang` כאן הוא שדה נפרד מ-`appSettingsProvider.lang` שקובע את ה-locale באמת.

---

## 3. הגדרות התראות (notif_settings_screen.dart)

### מטרה
ניהול התראות: ערוצי קבלה, סוגים, שעות שקט, צליל, חשיבות, לפי תפקיד, סיכומים, מסך נעול, פעולות מהירות. 9 קטגוריות + באנר השתקה זמנית עליון. provider: `notifSettingsProvider`.

### טבלת הגדרות

| שם (verbatim) | סוג בקרה | ברירת מחדל | טווח/ערכים | נשמר ב | אפקט | סטטוס |
|---|---|---|---|---|---|---|
| **🔇 השתק התראות זמנית (באנר)** | bottom-sheet | `0` (לא מושתק) | 15 דקות / שעה / 4 שעות / יום שלם | `snoozeUntilMs` | `snoozeForMinutes`/`cancelSnooze` + toast; מצב UI בלבד — אין צרכן שמסנן בפועל | 🚧 |
| **📱 ערוצי קבלה** | | | | | | |
| Push (אפליקציה) | toggle | `true` | bool | `pushEnabled` | persist בלבד | 🚧 |
| אימייל | toggle | `true` | bool | `emailEnabled` | persist בלבד | 🚧 |
| SMS | toggle | `false` | bool | `smsEnabled` | persist בלבד | 🚧 |
| WhatsApp | toggle | `false` | bool | `whatsappEnabled` | persist בלבד | 🚧 |
| **🔔 סוגי התראות** | | | | | | |
| הזמנות | toggle | `true` | bool | `typeOrders` | נצרך ב-`notifications_screen.dart` (`notifMutedSections` → מסתיר `orders`) | ✅ |
| משלוחים | toggle | `true` | bool | `typeShipments` | נצרך ב-`notifications_screen.dart` (מסתיר `shipments`) | ✅ |
| מחירים במועדפים | toggle | `true` | bool | `typePriceDrops` | נצרך ב-`notifications_screen.dart` (מסתיר `budget`) | ✅ |
| מבצעים | toggle | `true` | bool | `typeDeals` | נצרך ב-`notifications_screen.dart` (מסתיר `deals`) | ✅ |
| הצעות ספקים | toggle | `true` | bool | `typeSupplierOffers` | persist בלבד | 🚧 |
| חזר למלאי | toggle | `true` | bool | `typeBackInStock` | persist בלבד | 🚧 |
| תזכורות | toggle | `true` | bool | `typeReminders` | persist בלבד | 🚧 |
| שיחות חדשות | toggle | `true` | bool | `typeNewChats` | persist בלבד | 🚧 |
| עדכוני פרויקטים | toggle | `true` | bool | `typeProjectUpdates` | persist בלבד | 🚧 |
| **⏰ שעות שקט (DND)** | | | | | | |
| הפעל שעות שקט | toggle | `false` | bool | `quietHoursEnabled` | persist בלבד (חושף שדות זמן) | 🚧 |
| מתחיל בשעה (מותנה) | time picker | `22:00` | hour/min | `quietStartHour`/`Min` | persist בלבד | 🚧 |
| מסתיים בשעה (מותנה) | time picker | `07:00` | hour/min | `quietEndHour`/`Min` | persist בלבד | 🚧 |
| ימי שבת/חג | toggle | `false` | bool | `quietOnShabbat` | persist בלבד | 🚧 |
| תוך פגישות | toggle | `false` | bool | `quietInMeetings` | persist בלבד | 🚧 |
| מצב נהיגה | toggle | `false` | bool | `quietWhileDriving` | persist בלבד | 🚧 |
| **🔊 צליל ורטט** | | | | | | |
| צליל מופעל | toggle | `true` | bool | `soundEnabled` | persist בלבד | 🚧 |
| רטט | toggle | `true` | bool | `vibrationEnabled` | persist בלבד | 🚧 |
| צלילים שונים לפי סוג | toggle | `false` | bool | `soundPerType` | persist בלבד | 🚧 |
| LED (אנדרואיד) | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| **🎯 חשיבות וסינון** | | | | | | |
| רמת חשיבות | segmented | `all` | הכל / חשובות בלבד / קריטיות בלבד | `importanceFilter` | נצרך ב-`notifications_screen.dart` (`passesImportance`) | ✅ |
| דחייה (1ש' / 4ש' / יום) | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| חסימת שולח | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| **👤 לפי תפקיד** | | | | | | |
| 👷 קבלן — התראות פרויקט | toggle | `true` | bool | `personaContractor` | persist בלבד | 🚧 |
| 🏪 חנות — הזמנות + מלאי | toggle | `true` | bool | `personaStore` | persist בלבד | 🚧 |
| 🛵 שליח — pickup + active | toggle | `true` | bool | `personaCourier` | persist בלבד | 🚧 |
| 🦺 עובד — משימות | toggle | `true` | bool | `personaWorker` | persist בלבד | 🚧 |
| 👔 מנהל מערכת — דשבורד | toggle | `true` | bool | `personaAdmin` | persist בלבד | 🚧 |
| **📊 סיכומים תקופתיים** | | | | | | |
| סיכום יומי | toggle | `false` | bool | `dailySummary` | persist בלבד (חושף שעת שליחה) | 🚧 |
| שעת שליחה (מותנה) | time picker | `08:00` | hour/min | `dailySummaryHour`/`Min` | persist בלבד | 🚧 |
| דוח בוקר | toggle | `false` | bool | `morningReport` | persist בלבד (חושף שעה) | 🚧 |
| שעת דוח בוקר (מותנה) | time picker | `07:00` | hour/min | `morningReportHour`/`Min` | persist בלבד | 🚧 |
| סיכום ערב | toggle | `false` | bool | `eveningSummary` | persist בלבד (חושף שעה) | 🚧 |
| שעת סיכום ערב (מותנה) | time picker | `18:00` | hour/min | `eveningSummaryHour`/`Min` | persist בלבד | 🚧 |
| סיכום שבועי (ראשון) | toggle | `false` | bool | `weeklySummary` | persist בלבד | 🚧 |
| סיכום חודשי | toggle | `false` | bool | `monthlySummary` | persist בלבד | 🚧 |
| **🔐 פרטיות במסך נעול** | | | | | | |
| תצוגה במסך נעול | segmented | `full` | הצג תוכן מלא / רק שם השולח / הסתר לחלוטין | `lockScreen` | persist בלבד | 🚧 |
| אישור ביומטרי לפתיחה | toggle | `false` | bool | `biometricToOpen` | persist בלבד | 🚧 |
| אל תעבר לשעון/רכב | toggle | `false` | bool | `dontForwardToWatch` | persist בלבד | 🚧 |
| **⚡ פעולות מהירות** | | | | | | |
| כפתורי תגובה בהתראה | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| אישור בלי פתיחת אפליקציה | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| דחייה מהירה | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| תשובה ישירה | placeholder | — | — | — | toast "בבנייה" | ⛔ |

### קריטריוני קבלה
- שינוי כל שדה נשמר מיד ב-`bs.notif-settings.v1`.
- 5 ✅: typeOrders, typeShipments, typePriceDrops, typeDeals (מסתירים סקשנים ב-`notifications_screen.dart`), importanceFilter (`passesImportance`).
- באנר ההשתקה אינטראקטיבי (toggle state + toast), אך אין צרכן שמסנן התראות לפי `isSnoozedNow` — סטטוס 🚧.
- כל קטגוריית "פעולות מהירות" היא placeholders בלבד (`_activeCount == 0` → ללא badge).

---

## 4. הגדרות חנות (store_settings_screen.dart)

### מטרה
ניהול חוויית הרכש/חנות: משלוחים, תשלום, חשבוניות, התראות, סל, ספקים, תצוגה, לוגיסטיקה, פרטיות. 9 קטגוריות. provider: `storeSettingsProvider`.

### טבלת הגדרות

| שם (verbatim) | סוג בקרה | ברירת מחדל | טווח/ערכים | נשמר ב | אפקט | סטטוס |
|---|---|---|---|---|---|---|
| **📍 משלוחים וכתובות** | | | | | | |
| כתובת ברירת מחדל | inline text (R9) | `''` | מחרוזת, hint: "רחוב, מספר, עיר" | `defaultAddress` | persist בלבד | 🚧 |
| חלון זמן מועדף | segmented | `flexible` | בוקר / צהריים / ערב / גמיש | `preferredDeliveryWindow` | persist בלבד | 🚧 |
| אזורי משלוח | inline text (R9) | `''` | מחרוזת, hint: "ת"א, רמת גן, הרצליה..." | `deliveryAreas` | persist בלבד | 🚧 |
| הוראות לשליח | inline text (R9) | `''` | מחרוזת, hint: "הערות למשלוח..." | `courierInstructions` | persist בלבד | 🚧 |
| איסוף עצמי כברירת מחדל | toggle | `false` | bool | `selfPickupDefault` | נצרך ב-`store_screen.dart` (`cartDeliveryProvider` → `cartDeliveryFor`) | ✅ |
| **💳 אמצעי תשלום** | | | | | | |
| ברירת מחדל | segmented | `card` | כרטיס אשראי / ביט / Apple/Google Pay / אשראי ספק | `defaultPayment` | נצרך ב-`store_screen.dart` (`cartPaymentProvider` → `cartPaymentFor`) | ✅ |
| כרטיסים שמורים | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| תשלומים (1/3/6/12) | segmented | `one` | תשלום אחד / 3 / 6 / 12 תשלומים | `defaultInstallments` | persist בלבד | 🚧 |
| הסדר אשראי ספק | toggle | `false` | bool | `supplierCreditEnabled` | persist בלבד | 🚧 |
| **🧾 חשבוניות ומס** | | | | | | |
| הצג מחירים כולל מע"מ | toggle | `true` | bool | `vatInclusive` | נצרך ב-`store_screen.dart` (`cartVat`/`cartTotal`) | ✅ |
| פרטי עוסק/חברה | inline text (R9) | `''` | מחרוזת, hint: "שם עסק..." | `businessName` | persist בלבד | 🚧 |
| ח.פ. / ע.מ. | inline text (R9) | `''` | מחרוזת, hint: "מספר..." | `businessId` | persist בלבד | 🚧 |
| ייצוא לרו"ח | toggle | `false` | bool | `exportToAccountant` | persist בלבד | 🚧 |
| קבלות אוטומטיות | toggle | `true` | bool | `autoReceipts` | persist בלבד | 🚧 |
| **🔔 התראות חנות** | | | | | | |
| התראות מבצעים | toggle | `true` | bool | `notifDeals` | persist בלבד | 🚧 |
| חזר למלאי במועדפים | toggle | `true` | bool | `notifBackInStock` | persist בלבד | 🚧 |
| ירידת מחיר במועדפים | toggle | `true` | bool | `notifPriceDrop` | persist בלבד | 🚧 |
| סטטוס הזמנה | toggle | `true` | bool | `notifOrderStatus` | persist בלבד | 🚧 |
| משלוח בדרך | toggle | `true` | bool | `notifShipmentEnRoute` | persist בלבד | 🚧 |
| **🛒 סל והזמנות** | | | | | | |
| מינימום הזמנה (₪) | number field | `0` | מספר חופשי (digits) | `minOrderAmount` | נצרך ב-`store_screen.dart` (`cartBelowMinimum` חוסם checkout) | ✅ |
| אישור כפול לרכישה גדולה | toggle | `true` | bool | `confirmLargeOrder` | נצרך ב-`store_screen.dart` (`cartNeedsLargeConfirm`) | ✅ |
| סף לאישור כפול (₪) (מותנה) | number field | `5000` | מספר חופשי | `largeOrderThreshold` | נצרך ב-`store_screen.dart` (`cartNeedsLargeConfirm`); מוצג רק אם `confirmLargeOrder` | ✅ |
| הזמנות חוזרות | toggle | `true` | bool | `repeatOrders` | persist בלבד | 🚧 |
| שיתוף סל עם צוות | toggle | `false` | bool | `shareCartWithTeam` | persist בלבד | 🚧 |
| שמירת סל לפרויקט | toggle | `true` | bool | `saveCartToProject` | נצרך ב-`store_screen.dart` (מציג בורר פרויקט בסל) | ✅ |
| **🏪 ספקים מועדפים** | | | | | | |
| חנויות מסומנות | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| ספקים חסומים | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| מרחק מקסימלי (ק"מ, 0=ללא) | number field | `0` | מספר חופשי | `maxSupplierDistance` | persist בלבד | 🚧 |
| דירוג מינימלי | segmented | `any` | ללא סינון / ★★+ / ★★★+ / ★★★★+ / ★★★★★ | `minSupplierRating` | persist בלבד | 🚧 |
| ספקים מקומיים בלבד | toggle | `false` | bool | `localSuppliersOnly` | persist בלבד | 🚧 |
| **📊 תצוגה ומיון** | | | | | | |
| מיון ברירת מחדל | segmented | `priceAsc` | מחיר: זול → יקר / דירוג גבוה / מרחק קרוב | `sortDefault` | persist בלבד | 🚧 |
| תצוגה (רשת / רשימה) | segmented | `list` | רשימה / רשת | `displayMode` | persist בלבד | 🚧 |
| יחידות (מטר / אינץ') | segmented | `metric` | מטרי / אינגלי | `unitSystem` | persist בלבד | 🚧 |
| הצגת מלאי | toggle | `true` | bool | `showStock` | persist בלבד | 🚧 |
| **⚡ שירות ולוגיסטיקה** | | | | | | |
| משלוח מהיר (תוך 4 שעות) | toggle | `true` | bool | `fastDelivery` | persist בלבד | 🚧 |
| משלוח רגיל (יום-יומיים) | toggle | `true` | bool | `regularDelivery` | persist בלבד | 🚧 |
| ייעוץ טכני | placeholder | — | — | — | toast "בבנייה" | ⛔ |
| מדיניות החזרות | segmented | `days14` | 7 ימים / 14 יום / 30 יום | `returnPolicy` | persist בלבד | 🚧 |
| אחריות מורחבת | toggle | `false` | bool | `extendedWarranty` | persist בלבד | 🚧 |
| **🔐 פרטיות ורכישות** | | | | | | |
| היסטוריית רכישות | toggle | `true` | bool | `purchaseHistory` | persist בלבד | 🚧 |
| מחיקת חיפושים | action ("מחק", אדום) | — | — | — | toast `'החיפושים נמחקו'` (ללא לוגיקה) | ⛔ |
| אישור ביומטרי לרכישה | toggle | `false` | bool | `biometricConfirm` | persist בלבד | 🚧 |
| מגבלת אשראי יומית (₪, 0=ללא) | number field | `0` | מספר חופשי | `dailyCreditLimit` | persist בלבד | 🚧 |

### קריטריוני קבלה
- שינוי כל שדה נשמר מיד ב-`bs.store-settings.v1`.
- 7 ✅: selfPickupDefault, defaultPayment, vatInclusive, saveCartToProject, minOrderAmount, confirmLargeOrder, largeOrderThreshold — כולם נצרכים בלוגיקת הסל/checkout ב-`store_screen.dart`.
- `largeOrderThreshold` מוצג רק כאשר `confirmLargeOrder` פעיל.
- שדות number מקבלים digits בלבד (`FilteringTextInputFormatter.digitsOnly`).

---

## 5. פערים ידועים (כל ה-⛔ מרוכזים)

כל הבאים הם `_PlaceholderRow` או `_ActionRow` ללא שדה state וללא לוגיקה — לחיצה מציגה toast בלבד:

**קטלוג (5):**
- שיתוף רשימה עם צוות · יבוא / ייצוא רשימה (מועדפים)
- פורמט מידות בכרטיס מוצר (יחידות)
- ספקים מסומנים כמועדפים · ספקים חסומים (ספקים)

**שיחות (9):**
- ערוך / תבניות (באנר תשובות מהירות)
- צלצול לפי איש קשר · השתקת שיחה ספציפית (התראות)
- ניהול אחסון ("נקה") (מדיה)
- חסימת משתמשים · פרטי הפרופיל · מחיקת היסטוריה ("מחק") (פרטיות)
- ייצוא היסטוריה (CSV) · מחיקת גיבוי ענן (גיבוי)
- שפת מקלדת (שפה)
- ניתוב שיחות · תגובה מחוץ לשעות פעילות (בוט)

**התראות (7):**
- LED (אנדרואיד) (צליל)
- דחייה (1ש' / 4ש' / יום) · חסימת שולח (חשיבות)
- כפתורי תגובה בהתראה · אישור בלי פתיחת אפליקציה · דחייה מהירה · תשובה ישירה (פעולות מהירות)

**חנות (4):**
- כרטיסים שמורים (תשלום)
- חנויות מסומנות · ספקים חסומים (ספקים)
- ייעוץ טכני (לוגיסטיקה)
- מחיקת חיפושים ("מחק") (פרטיות)

> הערה: מעבר ל-⛔ הללו, רוב השדות מסומנים 🚧 — הם נשמרים תקין ב-SharedPreferences אך טרם נצרכים ע"י לוגיקה/מסך אחר. ה-✅ הם השדות היחידים עם אפקט ממשי מעבר ל-persist.
