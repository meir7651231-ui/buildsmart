# אפיון — מסך התראות (notifications_screen.dart)

## 1. מזהה ומיקום

- **קובץ:** `lib/screens/notifications_screen.dart` (1030 שורות).
- **מיקום בניווט:** הטאב השלישי ב-`IndexedStack` של `lib/screens/home_shell.dart` (`index: 2`). הסדר: 0=`CatalogScreen`, 1=`ChatsScreen`, **2=`NotificationsScreen`**, 3=`StoreScreen`.
- **Widget שורש:** `NotificationsScreen extends ConsumerStatefulWidget` (`_NotificationsScreenState`).
- **Providers שמוגדרים בקובץ:**
  - `notifSectionProvider` — `StateProvider<NotifSection>`, ברירת מחדל `NotifSection.all` (הצ'יפ הפעיל).
  - `notifReadIdsProvider` — `StateProvider<Set<String>>`, ברירת מחדל `{}` (מזהי התראות שסומנו כנקראו).
  - `notifDismissedIdsProvider` — `StateProvider<Set<String>>`, ברירת מחדל `{}` (מזהי התראות שנמחקו/swipe).
  - `notifSearchQueryProvider` — `StateProvider<String>`, ברירת מחדל `''` (טקסט חיפוש).
  - `notifExpandedGroupsProvider` — `StateProvider<Set<String>>`, ברירת מחדל `{}` (מפתחות groupKey של ריצות שנפתחו ידנית מ-"הצג עוד").
  - `notifUnreadCountProvider` — `Provider<int>` נגזר; סופר התראות עם `badge > 0` שאינן ב-readIds ואינן ב-dismissedIds. **נצרך גם ע"י badge ב-home_shell.**
- **Providers חיצוניים שנצרכים:**
  - `notifSettingsProvider` (`lib/state/notif_settings.dart`) — מצב הגדרות ההתראות.
  - `tabHeaderHiddenProvider` (`lib/state/dial_state.dart`, `StateProvider<bool>` ברירת מחדל `false`) — מסתיר/מציג את הכותרת בגלילה.

## 2. מטרה

מרכז ההתראות של המשתמש: רשימת עדכונים (משלוחים / הזמנות / בטיחות / תקציב / מבצעים) ממוינים לקבוצות תאריך, עם סינון לפי סוג (צ'יפים), חיפוש טקסטואלי, סינון חשיבות (מהגדרות), קיפול ריצות ארוכות מאותו סוג, סימון כנקרא, מחיקה (swipe / long-press / "נקה נקראו"), וכיבוד השתקות-לפי-סוג והשתקה זמנית (snooze) שמוגדרות במסך ההגדרות.

## 3. מבנה ופריסה (מלמעלה למטה)

`Column` שורש:
1. **אזור כותרת מתקפל** (`ClipRect` > `AnimatedSize` 220ms `easeInOut`) — נראה רק כש-`_headerVisible == true`. כשנראה מכיל `Column` של שלושה רכיבים:
   - `_Header` — כותרת "התראות" + badge "N חדשות" + כפתורי done_all / clear_all.
   - `_NotifSearchBar` — שדה חיפוש.
   - `_SectionChipsRow` — שורת צ'יפים אופקית נגללת.
2. **`Expanded`** > `NotificationListener<ScrollNotification>` > `_NotifList` — הרשימה עצמה.

**התנהגות הסתרת כותרת (`_handleScroll`):** בגלילה למטה (`delta > 6`) כשהכותרת נראית וה-`pixels > 50` → מסתיר ומעדכן `tabHeaderHiddenProvider = true`. בגלילה למעלה (`delta < -6`) כשהכותרת מוסתרת → מציג. ב-`pixels <= 2` כשמוסתרת → מציג. `ref.listen` על `tabHeaderHiddenProvider`: כשהופך ל-`false` חיצונית והכותרת מוסתרת → מציג.

> הערה: שורת ה-**snooze banner** ("🔇 השתק התראות זמנית" / "התראות מושתקות עד HH:MM") נמצאת בפועל ב-`lib/screens/notif_settings_screen.dart` (`_SnoozeBanner`), **לא** במסך זה. מסך ההתראות צורך את תוצאות ה-snooze דרך `notifSettingsProvider` (ר' פער ב-§10).

## 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| כותרת "התראות" | `Text` | מחרוזת קבועה `'התראות'`, גודל 20, `w700`, `#1A1A1A` | — | ✅ |
| Badge לא-נקראו | `Container` (brand, radius 12) | `'$unread חדשות'` מתוך `notifUnreadCountProvider` | מוצג רק כש-`unread > 0` | ✅ |
| כפתור "סמן הכל כנקרא" | `IconButton(Icons.done_all)` | tooltip `'סמן הכל כנקרא'`, `#888888` | tap ⇐ `notifReadIdsProvider = כל ה-ids`. מוצג רק כש-`unread > 0` | ✅ |
| כפתור "נקה נקראו" | `IconButton(Icons.clear_all)` | tooltip `'נקה נקראו'`, `#888888` | tap ⇐ מוסיף את כל readIds ל-dismissedIds. מוצג רק כש-`hasReadNotDismissed` (קיים id נקרא ולא-מבוטל) | ✅ |
| שדה חיפוש | `TextField` RTL | hint `'חיפוש התראות...'`, `prefixIcon` search, מילוי `#F5F5F5`, radius 24, focus border brand | onChanged ⇐ `notifSearchQueryProvider = v` | ✅ |
| כפתור ניקוי חיפוש | `IconButton(Icons.close)` (suffix) | מוצג רק כשיש טקסט | tap ⇐ מנקה controller + `notifSearchQueryProvider = ''` | ✅ |
| צ'יפ "הכל" | `_Pill` | `'הכל'` | tap ⇐ `notifSectionProvider = all` | ✅ |
| צ'יפ "📦 משלוחים" | `_Pill` | `'📦 משלוחים'` | tap ⇐ `section = shipments` | ✅ |
| צ'יפ "🛒 הזמנות" | `_Pill` | `'🛒 הזמנות'` | tap ⇐ `section = orders` | ✅ |
| צ'יפ "🦺 בטיחות" | `_Pill` | `'🦺 בטיחות'` | tap ⇐ `section = safety` | ✅ |
| צ'יפ "💰 תקציב" | `_Pill` | `'💰 תקציב'` | tap ⇐ `section = budget` | ✅ |
| צ'יפ "🎁 מבצעים" | `_Pill` | `'🎁 מבצעים'` | tap ⇐ `section = deals` | ✅ |
| צ'יפ פעיל | סגנון `_Pill` | רקע brand + טקסט לבן `w600`; לא-פעיל רקע `#F5F5F5` טקסט `#AAAAAA` `w400` | — | ✅ |
| כותרת קבוצת תאריך | `_DateHeader` | label = `dateGroup` ('היום'/'אתמול'/'מוקדם יותר'), `#888888` 12 `w600` | — | ✅ |
| שורת התראה | `_NotifRow` בתוך `_DismissibleRow` | emoji בעיגול 50×50 + title + time + preview | tap ⇐ אם לא-נקרא: מוסיף ל-readIds | ✅ |
| אווטאר עדיפות גבוהה | `Container` עיגול | רקע `#3D1515` + מסגרת אדומה (redAccent 0.6, רוחב 2) | — | ✅ |
| אווטאר לא-נקרא רגיל | `Container` עיגול | רקע `brand` opacity 0.15 | — | ✅ |
| כותרת high-priority | `Text` | צבע `Colors.redAccent` (במקום `#1A1A1A`) | — | ✅ |
| חותם זמן | `Text` | `notif.time`; כשלא-נקרא צבע brand `w600`, אחרת `#888888` `w400` | — | ✅ |
| Badge מספרי בשורה | `Container` brand radius 10 | `'${notif.badge}'`; מוצג רק כש-`isUnread` | — | ✅ |
| Action chip "אשר איסוף" | `GestureDetector` > `Container` (border brand 0.7) | מסוג orders | tap ⇐ `onTap: () {}` (no-op) | 🚧 |
| Action chip "טפל כעת" | כנ"ל | מסוג safety | tap ⇐ no-op | 🚧 |
| Action chip "פרטים" | כנ"ל | מסוג budget | tap ⇐ no-op | 🚧 |
| Action chip "עקוב" | כנ"ל | מסוג shipments | tap ⇐ no-op | 🚧 |
| (deals — ללא action) | — | `_actionLabel(deals)=null` | — | ✅ |
| Swipe למחיקה | `Dismissible` `endToStart` | רקע אדום (`redAccent`) + `Icons.delete_outline` | swipe ⇐ מוסיף id ל-dismissedIds + SnackBar `'התראה נמחקה'` עם action `'ביטול'` (מסיר id) | ✅ |
| תפריט לחיצה-ארוכה | `showMenu` (רקע `#1E1E1E`) | `'סמן כנקרא'` (רק כש-isUnread) / `'מחק'` | בחירה `read` ⇐ readIds; `delete` ⇐ dismissedIds | ✅ |
| שורת "הצג עוד" | `_ShowMoreRow` (`InkWell`) | `'הצג עוד ${hiddenCount} ↓'`, brand 13 `w600` | tap ⇐ מוסיף `groupKey` ל-`notifExpandedGroupsProvider` (פותח את הריצה) | ✅ |
| מצב ריק | `Center` > `Column` | `'🔔'` (48) + `'אין התראות'` (18 `w600`) + `'כשיהיו עדכונים — הם יופיעו כאן'` (13 `#888888`) | — | ✅ |
| Pull-to-refresh | `RefreshIndicator` (צבע brand) | — | משיכה ⇐ `Future.delayed(800ms)` (אין רענון נתונים אמיתי) | 🚧 |
| `_MiniPill` | `GestureDetector` | רכיב מוגדר אך **לא בשימוש** בעץ הווידג'טים | — | ⛔ |

## 5. מצבים

- **ריק:** כש-`items.isEmpty` (אחרי סינון/השתקה/חיפוש או הכל נמחק) — `RefreshIndicator` עם מצב ריק "🔔 / אין התראות / כשיהיו עדכונים — הם יופיעו כאן".
- **מסונן — כל סוג מושתק:** אם המשתמש כיבה toggle בהגדרות, `notifMutedSections` מוסיף את הקטגוריה ל-`muted` ו-`notifPasses` מסנן אותה החוצה. אם כל הסוגים שיש להם seed מושתקים → מצב ריק.
- **importance filter דולק:** כש-`importanceFilter != all`, `passesImportance` משאיר רק שורות `highPriority` (n3 בטיחות, n4 תקציב). שאר ה-8 נעלמות.
- **snooze פעיל:** `isSnoozedNow == true` (`snoozeUntilMs > now`). משפיע על ה-banner במסך ההגדרות; מסך ההתראות עצמו **אינו** מסנן את הרשימה לפי snooze (ר' §10).
- **קיבוץ תאריכים:** כותרת תאריך מוזרקת בכל שינוי `dateGroup` (`isNewDateGroup`). שלוש קבוצות בנתוני seed: 'היום' (5), 'אתמול' (2), 'מוקדם יותר' (3).
- **run מקופל:** ריצה של ≥3 התראות רצופות מאותו `dateGroup`+`type` שלא נפתחה → מוצגת הראשונה + `_ShowMore` עם `hiddenCount = groupCount-1`. בנתוני seed: שלושת המשלוחים (n2,n9,n10) ב-'היום' מקופלים → "הצג עוד 2 ↓".

## 6. חוקים עסקיים ולוגיקה (מפורט)

**`notifPasses({type, title, preview, dismissed, section, query, muted})` → bool** (נבדק רגרסיה ב-`test/gaps_test.dart`):
1. `if (dismissed) return false;` — שורה מבוטלת לא עוברת.
2. `if (muted.contains(type)) return false;` — סוג מושתק לא עובר.
3. `if (section != NotifSection.all && type != section) return false;` — סינון צ'יפ: ב-'הכל' הכל עובר, אחרת רק התואם לסוג.
4. אם `query` לא ריק: ממיר ל-lowercase ובודק `title.contains(q) || preview.contains(q)`; אם אף אחד לא מכיל → `false`.
5. אחרת `return true`.

**`notifMutedSections(NotifSettings ns)` → `Set<NotifSection>`:** ממפה toggles להסתרת קטגוריות —
- `!ns.typeOrders` → `orders`
- `!ns.typeShipments` → `shipments`
- `!ns.typeDeals` → `deals`
- `!ns.typePriceDrops` → `budget` (שים לב: price-drops ממפה ל-`budget`).
- אין מיפוי ל-`safety` → התראות בטיחות לעולם לא מושתקות דרך toggle.

**`passesImportance(NotifImportance filter, bool highPriority)` → bool:** `filter == NotifImportance.all || highPriority`. כלומר `all` מעביר הכל; `important` או `critical` מעבירים רק `highPriority == true`. (אין הבחנה בפועל בין important ל-critical — שניהם מתנהגים זהה.)

**`shouldCollapseNotifRun(int runLength)` → bool:** `runLength >= kNotifCollapseRunMin`. **`kNotifCollapseRunMin = 3`** (קבוע). כלומר: 2 → false, 3 → true, 4 → true.

**`isNewDateGroup(String? current, String next)` → bool:** `next != current`. מ-`null` תמיד true (מזריק כותרת ראשונה). שווה → false. שונה → true.

**`_withHeadersAndCollapse(notifs, expandedKeys)`:** לולאה: בכל שינוי `dateGroup` מזריק כותרת. לכל ריצה רצופה של אותו `dateGroup`+`type.name` (groupKey=`'${dateGroup}__${type.name}'`): אם `shouldCollapseNotifRun(groupCount)` וה-`groupKey` לא ב-expandedKeys → מוסיף שורה ראשונה + `_ShowMore(hiddenCount: groupCount-1)`; אחרת מוסיף את כל שורות הריצה.

**`_filtered(...)`:** מחיל `passesImportance(importance, highPriority) && notifPasses(...)` על `_kNotifs`.

**`_actionLabel(type)`:** orders→`'אשר איסוף'`, safety→`'טפל כעת'`, budget→`'פרטים'`, shipments→`'עקוב'`, אחרת→`null`.

**לוגיקת שורה (`_NotifRow`):** `isUnread = notif.badge > 0 && !isRead`. tap על שורה לא-נקראת → מסמן נקרא. `Opacity 0.5` כשנקרא. long-press → תפריט קונטקסט.

## 7. נתונים ומקורות ושמירה

**`_kNotifs` — 10 התראות seed קבועות (`const`):**

| id | emoji | title | preview | time | dateGroup | badge | type | highPriority |
|---|---|---|---|---|---|---|---|---|
| n1 | 📦 | הזמנה #1234 | מוכנה לאיסוף — צור קשר עם הספק | עכשיו | היום | 1 | orders | false |
| n2 | 🚛 | משלוח #892 | יגיע עד מחר 14:00 | לפני שעה | היום | 0 | shipments | false |
| n9 | 🚛 | משלוח #893 | חבילה ממתינה לאיסוף בחנות | לפני שעתיים | היום | 1 | shipments | false |
| n10 | 🚛 | משלוח #894 | מסלול עודכן — עצור בשוק עכו | לפני 3 שעות | היום | 0 | shipments | false |
| n3 | 🦺 | התראת בטיחות | דרגת סיכון עודכנה לאדום — קומה 3 | לפני 3 שעות | היום | 1 | safety | **true** |
| n4 | 🔔 | חריגת תקציב | פרויקט A חרג ב-12% מהתקציב | אתמול | אתמול | 1 | budget | **true** |
| n5 | 🎁 | מבצע שבועי | ציוד חשמל -15% עד יום ראשון | אתמול | אתמול | 0 | deals | false |
| n6 | 📦 | הזמנה #1198 | אושרה ונמצאת בהכנה | 21.5 | מוקדם יותר | 0 | orders | false |
| n7 | 💱 | עדכון מחיר | ברזל 12mm · ₪4.20 → ₪3.85 | 20.5 | מוקדם יותר | 0 | deals | false |
| n8 | 🎁 | תגמול נצבר | 120 נקודות נוספו למועדון | 20.5 | מוקדם יותר | 0 | deals | false |

הערות seed: n2,n9,n10 הם ריצה של 3 משלוחים רצופים ב-'היום' → מפעילים קיפול. ל-4 בלבד יש `badge>0` ו-`highPriority` רק ל-n3,n4.

**שמירה:** מצב הרשימה (readIds / dismissedIds / search / section / expandedGroups) נשמר **בזיכרון בלבד** (StateProvider, לא נשמר ל-disk; מתאפס בהפעלה מחדש). **רק** `notifSettingsProvider` נשמר ב-`SharedPreferences` תחת המפתח `'bs.notif-settings.v1'` (JSON), כולל `snoozeUntilMs`, ה-type toggles ו-`importanceFilter`.

## 8. תלות בהגדרות (`notifSettingsProvider` / `NotifSettings`)

- **type toggles** — `typeOrders`, `typeShipments`, `typeDeals`, `typePriceDrops` (ברירת מחדל כולם `true`). כיבוי מזין את `notifMutedSections` → מסנן את הקטגוריה התואמת מהרשימה. (שאר ה-toggles — `typeSupplierOffers`/`typeBackInStock`/`typeReminders`/`typeNewChats`/`typeProjectUpdates` — לא משפיעים על מסך זה כי אין להם seed/mapping.)
- **importanceFilter** (`NotifImportance.all|important|critical`, ברירת מחדל `all`) — דרך `passesImportance`; כל ערך שאינו `all` משאיר רק `highPriority`.
- **snooze** (`snoozeUntilMs` / `isSnoozedNow` / `snoozeForMinutes` / `cancelSnooze`) — נשמר ב-settings; ה-banner וה-bottom-sheet לבחירת משך מצויים ב-`notif_settings_screen.dart`. מסך ההתראות אינו מסנן לפי snooze.

## 9. קריטריוני קבלה (Given/When/Then)

- **notifPasses — dismissed:** Given התראה ב-dismissedIds, When מחושב סינון, Then לא מופיעה.
- **notifPasses — muted:** Given `typeShipments=false`, When הרשימה נבנית, Then כל המשלוחים (n2,n9,n10) נעלמים.
- **notifPasses — section:** Given הצ'יפ הפעיל `orders`, Then מופיעות רק n1,n6; ב-`all` מופיעות כולן.
- **notifPasses — query:** Given חיפוש "12mm", Then רק n7 (preview מכיל) מופיעה; חיפוש ריק → אין סינון טקסט.
- **passesImportance:** Given `importanceFilter=important`, Then רק n3,n4 (highPriority) מופיעות; Given `all`, Then כל ה-10 עוברות את מסנן החשיבות.
- **shouldCollapseNotifRun:** Given runLength=2 → לא מקפל; =3 → מקפל; =4 → מקפל (`kNotifCollapseRunMin=3`).
- **isNewDateGroup:** Given (null,'היום') → true; ('היום','היום') → false; ('היום','אתמול') → true.
- **קיפול ריצה:** Given 'הכל' פעיל + שום סינון, When הרשימה נבנית, Then שלושת המשלוחים מקופלים ל-n2 + "הצג עוד 2 ↓"; When לוחצים "הצג עוד", Then groupKey נכנס ל-expandedKeys וכל ה-3 מוצגים.
- **mark-all-read:** Given לחיצה על done_all, Then readIds=כל ה-ids, ה-badge "N חדשות" נעלם, unread=0.
- **clear-all (נקה נקראו):** Given קיימות התראות נקראו-ולא-נמחקו, When לוחצים clear_all, Then dismissedIds מתמלא ב-readIds והן נעלמות.
- **swipe:** Given swipe endToStart על שורה, Then id ב-dismissedIds + SnackBar "התראה נמחקה"; When לוחצים "ביטול", Then id מוסר ו-(לוגית) חוזרת.

## 10. פערים ידועים

- **Action chips** (אשר איסוף / טפל כעת / פרטים / עקוב) — `onTap: () {}` ריק. 🚧
- **Pull-to-refresh** — `Future.delayed(800ms)` ללא רענון נתונים אמיתי. 🚧
- **`_MiniPill`** — רכיב מוגדר אך לא מחווט לעץ. ⛔
- **snooze אינו מסנן את הרשימה** — `isSnoozedNow` משפיע על banner בהגדרות בלבד; שורות עדיין מוצגות במסך זה. 🚧
- **push / email / sms / whatsapp** — שדות ב-`NotifSettings`, אינם משפיעים על מסך זה. ⛔
- **quiet-hours** (`quietHoursEnabled`, שעות, shabbat/meetings/driving) — לא נאכפות במסך. ⛔
- **summaries** (`dailySummary`, `morningReport`, `eveningSummary`, `weeklySummary`, `monthlySummary`) — לא ממומשות. ⛔
- **sound / vibration** (`soundEnabled`, `vibrationEnabled`, `soundPerType`) — לא ממומשות. ⛔
- **lock-screen** (`NotifLockScreen.full/senderOnly/hidden`, `biometricToOpen`, `dontForwardToWatch`) — לא ממומשות. ⛔
- **by-role / persona** (`personaContractor/Store/Courier/Worker/Admin`) — לא מסננות את הרשימה. ⛔
- **התמדה של מצב הרשימה** — readIds/dismissedIds/section/search/expanded לא נשמרים ל-disk, מתאפסים בהפעלה. 🚧
