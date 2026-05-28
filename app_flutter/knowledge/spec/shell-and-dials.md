# אפיון — מעטפת ו-FAB Dials

> מסמך אפיון פורמלי, מעוגן כולו בקוד המקור (R8 — אין המצאה). כל הטקסטים העבריים verbatim מהקוד.
> תצורה: RTL, עברית, ערכת נושא בהירה. עיקרון R2: כל פיצ׳ר הוא **dial** רב-רמתי דרך FAB — לעולם לא חלון מלא; מסכי persona נשארים placeholder מינימלי.
>
> קבצי מקור: `lib/main.dart` · `lib/screens/home_shell.dart` · `lib/screens/bs_dial_widget.dart` · `lib/screens/search_dial_widget.dart` · `lib/screens/menu_dial_widget.dart` · `lib/data/personas.dart` · `lib/data/sections.dart` · `lib/data/menu_trees.dart` · `lib/data/settings_tree.dart` · `lib/data/projects.dart` · `lib/state/dial_state.dart`.

---

## 1. מעטפת האפליקציה (home_shell.dart)

### 1.1 מבנה כללי

| שכבה | מקור | תיאור |
|---|---|---|
| `MaterialApp` | `main.dart:31` | `title:'BuildSmart'`, `debugShowCheckedModeBanner:false`. theme בהיר/כהה דרך `AppTheme.light/dark(highContrast)`, `themeMode` לפי `settings.theme`. locale לפי `settings.lang` (he-IL / ar / en-US). delegates: Material/Widgets/Cupertino. `home: HomeShell()`. |
| textScaler גלובלי | `main.dart:49-51` | `builder` עוטף ב-`MediaQuery` עם `textScaler: TextScaler.linear(textScale)`; `textScale` = small 0.9 · medium 1.0 · large 1.15 (מתוך `catalogSettingsProvider`). מתחת לזה `Directionality(TextDirection.rtl)`. |
| `HomeShell` (Scaffold) | `home_shell.dart:23-95` | `appBar:_HomeAppBar`, `body:Stack`, `bottomNavigationBar:_BottomNav`, FAB עגלה, `floatingActionButtonLocation: endFloat`. |
| `IndexedStack` | `home_shell.dart:36-44` | 4 לשוניות לפי `mainTabProvider`: `[CatalogScreen, ChatsScreen, NotificationsScreen, StoreScreen]`. סדר RTL: קטלוג בימין. |
| Bottom nav | `home_shell.dart:259-303` | `BottomNavigationBar` fixed, רקע לבן `0xFFFFFFFF`, נבחר=`BsTokens.brand`, לא-נבחר=`0xFF888888`. החלפת לשונית קוראת `resetAllDials(ref)` ואז מעדכנת `mainTabProvider`. |

### 1.2 לשוניות ה-Bottom Nav (verbatim)

| index | אייקון | activeIcon | label | הערה |
|---|---|---|---|---|
| 0 | `Icons.grid_view` | — | `קטלוג` | |
| 1 | `Icons.chat_bubble_outline` | — | `שיחות` | |
| 2 | `Icons.notifications_outlined` | `Icons.notifications` | `התראות` | badge `_BadgedIcon` לפי `notifUnreadCountProvider`; מציג `9+` כש->9 |
| 3 | `Icons.shopping_cart_outlined` | — | `חנות` | |

### 1.3 AppBar — `_HomeAppBar` (`home_shell.dart:162-257`)

רקע לבן `0xFFFFFFFF`, `elevation:0`, `automaticallyImplyLeading:false`.

| אלמנט | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|
| Wordmark `BuildSmart` (title, ימין ב-RTL; `BsTokens.brand`, w800, 22) + Tooltip `BS` | tap (`_toggle(ref, OpenDial.bs)`) ⇐ פותח/סוגר את BS dial. `_toggle` מאפס persona/drill/menuTab/searchTool | פעיל |
| שורת status מתחת ל-wordmark | מצב A: בלשונית קטלוג עם `catalogSectionProvider == 'עץ חכם'` ⇐ `_PulsingStatus(text:'עץ חכם הופעל')` (נקודה ירוקה פועמת `0xFF22C55E`, מכבדת `reducedMotion`). מצב B (אחרת): נקודה ירוקה `0xFF4CAF50` + הטקסט: `לייבל הגרסה הנוכחי (vX.YY · DD.M.YY · «תיאור») מ-home_shell.dart` | פעיל |
| אייקון חיפוש `Icons.search` (action) | מוצג רק כש-`tabHeaderHiddenProvider==true`; tooltip `חיפוש`. tap ⇐ מאפס `tabHeaderHiddenProvider=false` (מחזיר את ה-header של הלשונית) | פעיל |
| אייקון מצלמה `Icons.photo_camera_outlined` (action) | tooltip `מצלמה`. tap ⇐ `openCameraSheet(context)` | פעיל |
| תפריט ⋮ per-tab (`Icons.more_vert`) | משתנה לפי `tabIndex` — ראה 1.4 | פעיל |

### 1.4 תפריטי ⋮ per-tab (verbatim)

כל הפריטים דרך `_MenuRow(emoji,label)`. סדר וטקסט verbatim:

**לשונית 0 — קטלוג** (`_CatalogMenuButton`, `:349-408`)

| emoji | label | תוצאה |
|---|---|---|
| 📐 | `סרוק תוכנית עבודה` | `_ScanPlanSheet` (bottom sheet): 🚵 `אינסטלציה` · ⚡ `חשמל` · 🏙️ `אדריכלות` · 🎨 `גמר` → כל אחד `«label» — בבנייה` |
| 💡 | `חלופות זולות` | toast `חלופות זולות — בבנייה` |
| 📊 | `השוואת מחירים` | toast `השוואת מחירים — בבנייה` |
| ❤️ | `מועדפים` | `catalogSectionProvider='מועדפים'` |
| — | divider | |
| ⚙️ | `הגדרות` | `CatalogSettingsScreen.route()` |

**לשונית 1 — שיחות** (`_ChatsMenuButton`, `:412-476`)

| emoji | label | תוצאה |
|---|---|---|
| ✏️ | `שיחה חדשה` | `_NewChatSheet`: 👷 `קבלן` · 🏪 `ספק` · 🛵 `שליח` · 🦺 `עובד` · 💬 `תמיכה` → `openNewChatWith` |
| 🗂️ | `ארכיון שיחות` | `ChatsArchiveScreen.route()` |
| 🔇/🔔 | `השתק הכל` / `בטל השתקת הכל` (דינמי לפי `allChatsMuted`) | `toggleMuteAllChats` + toast `כל השיחות הושתקו` / `ההשתקה בוטלה` |
| — | divider | |
| ⚙️ | `הגדרות` | `ChatSettingsScreen.route()` |

**לשונית 2 — התראות** (`_NotificationsMenuButton`, `:480-521`)

| emoji | label | תוצאה |
|---|---|---|
| ✅ | `סמן הכל כנקרא` | `markAllNotifsRead` + toast `כל ההתראות סומנו כנקרא` |
| 🗑️ | `נקה הכל` | `dismissAllNotifs` + toast `כל ההתראות נמחקו` |
| 🔔 | `הגדרות התראות` | `NotifSettingsScreen.route()` |

**לשונית 3 — חנות** (`_StoreMenuButton`, `:525-571`)

| emoji | label | תוצאה |
|---|---|---|
| 🛒 | `הסל שלי` | `storeSectionProvider=StoreSection.cart` |
| 📦 | `הזמנות` | `storeSectionProvider=StoreSection.orders` |
| 🔧 | `שירותים` | `storeSectionProvider=StoreSection.services` |
| — | divider | |
| ⚙️ | `הגדרות` | `StoreSettingsScreen.route()` |

### 1.5 Cart FAB — `_CartFab` (`home_shell.dart:99-157`)

| מאפיין | ערך |
|---|---|
| צבע | `backgroundColor: BsTokens.brand` (כתום), `foregroundColor` לבן, `elevation:4`, מסגרת לבנה `CircleBorder` רוחב 2 |
| תוכן | `Icons.shopping_cart` לבן (26) + `Icons.add` כתום (12) על הסל |
| badge | מוצג כש-`count>0` (סכום `productQty` מ-`smartCartProvider`); עיגול לבן, מסגרת כתומה, טקסט כתום w800 |
| מתי מוסתר | מוצג רק כאשר `open == OpenDial.none && tabIndex != 3`. כלומר: מוסתר בלשונית חנות (3) ו/או כאשר dial כלשהו פתוח |
| tap | `resetAllDials(ref)` + `mainTabProvider=3` (קפיצה לחנות) |

### 1.6 חוק: dial אחד בכל רגע

- `openDialProvider` (`dial_state.dart:5-7`) — `enum OpenDial { none, bs, search, bsMode, menu }`, ברירת מחדל `none`. רק dial אחד פתוח בכל רגע (R1).
- ה-`Stack` ב-body מצייר scrim כש-`open != none`: `Positioned.fill` שקוף-שחור `alpha 0.45`; tap עליו ⇐ `resetAllDials(ref)` (סוגר הכל).
- מיקום ה-dials: BS עוגן ימין (`right/bottom = space5`), Search ממורכז (`left/right space4`, `bottom space5`), Menu עוגן שמאל (`left/bottom space5`).
- `resetAllDials` (`dial_state.dart:35-41`) מאפס: `openDial=none`, `activePersona=null`, `bsDrillPath=[]`, `menuTab=null`, `searchTool=null`.

---

## 2. BS Dial (bs_dial_widget.dart)

L1 = 5 פרסונות (`kPersonas`, `personas.dart`). בחירת persona מציבה `activePersonaProvider`; אחר כך drill לפי `bsDrillPathProvider` דרך `walkBsDrill`. עוגן persona + עוגן לכל שלב drill (active=true) → tap על עוגן קופץ לאותו עומק. עלה ללא ילדים → toast `«title» — בבנייה`; מקרה מיוחד `mm-regression` → סוגר dial ופותח `RegressionPanelScreen.route()`.

### 2.1 חמש הפרסונות (verbatim) + תתי-עצים

| emoji | title (id) | תת-עץ | סטטוס |
|---|---|---|---|
| 👷 | `קבלן` (contractor) | — אין תת-סקשנים בלגאסי. tap על L1 מציב persona, אך אין `current` להציג | **deferred** (placeholder) |
| 👔 | `מנהל המערכת` (manager) | `kManagerSections` — 4 sections, ראה 2.2 | פעיל |
| 🏪 | `חנות ספק` (store) | `kStoreSections` — 4 sections, ראה 2.3 | פעיל |
| 🛵 | `שליח` (courier) | `kCourierSections` — 4 sections, ראה 2.4 | פעיל |
| 🦺 | `עובד` (worker) | `kWorkerSections` — 3 task-groups, ראה 2.5 | פעיל |

### 2.2 מנהל המערכת — `kManagerSections` (`sections.dart:152-199`)

| L2 | L3 (children) |
|---|---|
| 📊 `לוח בקרה` | 🚚 `הזמנות פתוחות` · 📦 `מוצרים בקטלוג` · 🧰 `אביזרים נלווים` · ✅ `זמינים כעת` · 🏪 `חנויות פעילות` |
| 🚚 `הזמנות` | 📥 `התקבלה` · 🔧 `בהכנה` · 📦 `מוכן לאיסוף` · 🚛 `נאסף` · 🚚 `בדרך לאתר` · ✅ `נמסר ✓` |
| 👥 `לקוחות` | 🟢 `פעיל` · ⚠️ `אשראי גבוה` |
| 🛠️ `ניהול` | 🌳 `עץ המוצרים` · 🏷️ `מותגים ומחירים` · 🗂️ `קטגוריות` · ⚙️ `הגדרות אפליקציה` · 🔬 `בדיקות רגרסיה` (id `mm-regression` → פותח Regression Panel) |

### 2.3 חנות ספק — `kStoreSections` (`sections.dart:29-74`)

| L2 | L3 (children) |
|---|---|
| 🏠 `בית` | 🔧 `בהכנה` · 📦 `מוכן לאיסוף` · 💰 `מחזור פעיל` |
| 📥 `הזמנות` | 📥 `לאישור` · 🔧 `בהכנה` · 📦 `מוכנות` |
| 📦 `מלאי` | ✅ `זמין במלאי` · ❌ `אזל` |
| 🧰 `פורטל` | ⭐ `דירוג ספקים` · ⏱️ `מעקב SLA` · 🗺️ `אזורי הפצה` · 📉 `הנחות כמות` · 🏷️ `הפקת ברקודים` · 🚛 `ניהול צי רכב` · 💬 `צ׳אט עם קבלן` · 🔄 `עדכון מלאי` (8) |

### 2.4 שליח — `kCourierSections` (`sections.dart:80-115`)

| L2 | L3 (children) |
|---|---|
| 🛵 `הרכב שלי היום` | 🛵 `משלוח קטן` · 🚐 `טנדר` · 🚛 `משאית` |
| 📦 `משלוחים ממתינים לאיסוף` | — (עלה) |
| 🚚 `משלוחים פעילים` | 📦 `אספתי מהחנות` · 🚚 `יצאתי לדרך` · ✅ `נמסר ללקוח` |
| 🧰 `פורטל השליח` | 🧭 `ניווט למשלוח` · 🚛 `צי רכב` · ⏱️ `מעקב SLA` · 🗺️ `אזורי הפצה` · 📸 `אישור מסירה` · 💬 `צ׳אט עם חנות` (6) |

### 2.5 עובד — `kWorkerSections` (`sections.dart:126-145`)

| L2 (task-group) | L3 (children) |
|---|---|
| 🔨 `המשימה הנוכחית שלך` | 🔨 `בביצוע` · ↩️ `נדחה — לתקן` |
| ⏳ `הבאות בתור` | ⏳ `ממתינה` |
| 📋 `שהגשת` | 📸 `ממתין לאישור` · ✅ `אושר ✓` |

### 2.6 ששת ה-hubs מהלגאסי

הוטמעו כעצי dial (לא חלונות), פזורים בעצי BS / Menu / Settings:

| Hub (legacy) | היכן |
|---|---|
| `openAIHub` | Menu › בית › 🤖 `בינה מלאכותית ואוטומציה` (9 כלים) — `menu_trees.dart` |
| `openSiteHub` | Menu › בית › 📋 `משימות העבודה` (10 כלים) — `menu_trees.dart` |
| `openFinanceHub` | Menu › הפרויקטים › 📊 `מרכז פיננסים` (`kFinanceHub`, 10) — `menu_trees.dart` |
| `openServiceHub` | Settings › שירות ותמיכה › `מרכז השירות` — `settings_tree.dart` |
| `openSecurityHub` | Settings › אבטחה והרשאות › `מרכז האבטחה` — `settings_tree.dart` |
| `openRewardsHub` | מועדון BuildSmart מופיע כצומת ב-`סיור היכרות` (Settings › מרכז השירות); hub פרופיל/דרגות מלא — ראה פערים §7 |

---

## 3. Search Dial (search_dial_widget.dart)

L1 = 4 כלים (`searchToolProvider`). בחירה מציבה את הכלי ומציגה עוגן + תת-תפריט; tap על העוגן חוזר ל-root. הערה בקוד: הקטלוג הועבר ללשונית bottom-nav — אינו כלי חיפוש יותר.

| emoji | label | מה עושה | סטטוס |
|---|---|---|---|
| 🎤 | `קולי` | תת-שורה 🎤 `הקש להפעלה` → `VoiceService.listen`; תוצאה סופית → toast עם הטקסט; כשל → toast `הדפדפן הזה לא תומך בחיפוש קולי` | פעיל |
| 📷 | `ברקוד` | תת-שורה 📷 `פתח מצלמה` → `openBarcodeScanner(context)` | פעיל |
| ⚙️ | `פילטרים` | 2 toggles: 🖼️ `עם תמונה` · 💲 `עם מחיר מוצג` → כל אחד `«label» — בבנייה` | placeholder |
| ↕️ | `מיון` | 5 אפשרויות: 🔀 `ברירת מחדל` · 🔡 `שם א→ת` · 🔠 `שם ת→א` · ⬆️ `מחיר ↑` · ⬇️ `מחיר ↓` → כל אחד `«label» — בבנייה` | placeholder |

> הערת אפיון: הכותרת בקובץ מציגה את "קטלוג" כ-5th tool היסטורי, אך הקוד הנוכחי מגדיר 4 כלים בלבד (ראה §7).

---

## 4. Menu Dial (menu_dial_widget.dart)

L1 = 4 לשוניות (`menuTabProvider`). כל לשונית פותחת עץ sections עם drill בעומק שרירותי דרך `_SectionDrill` (home/projects/cart) או `_SettingsDrill` (settings). עוגן לשונית + עוגן לכל שלב (active) → tap קופץ לעומק. עלה ללא ילדים → toast `«title» — בבנייה`.

| emoji | label (tab) | עץ | מבנה רב-רמתי | סטטוס |
|---|---|---|---|---|
| 🏠 | `בית` | `kHomeTree` | 4 עלים: 🤖 `בינה מלאכותית ואוטומציה` (9) · 📐 `סרוק תוכנית עבודה` (4: 🚿/⚡/🏛️/🎨) · 📦 `המלאי שלי` (2: 🏬 `המחסן`/🏗️ `האתר`) · 📋 `משימות העבודה` (10) | פעיל |
| 🏗️ | `הפרויקטים` | `projectsTree()` | 3 פרויקטים מ-`kProjects` (🏗️ `מגדל הרצליה — קומה 4` · `וילה כפר שמריהו` · `שיפוץ משרדים — רעננה`) + 📊 `מרכז פיננסים` (`kFinanceHub`, 10 leaves) | פעיל |
| 🛒 | `רכש` | `kCartTree` | 🛒 `הסל שלי` (עלה) · 📦 `ההזמנות שלי` (6: 🔧 `השכרת כלים`/💰 `פקדונות`/↩️ `החזרה חדשה`/📨 `מכרז ספקים`/🧪 `גיליונות בטיחות`/📊 `השוואת מחירים`) | פעיל |
| ⚙️ | `הגדרות` | `kSettingsGroups` | L2 = 10 קבוצות → drill פנימי. עלי toggle/בחירה מחילים `_applyLeaf` (theme/textSize/currency/lang/units/haul/express/security/notifs/privacy/sessionTimeout) + toast `«label» עודכן`; `_isOn` צובע את העלה הפעיל ב-brand | פעיל (חלקי — ראה להלן) |

### 4.1 לשונית הגדרות — 10 הקבוצות (`settings_tree.dart`)

👤 `חשבון` · 🔔 `התראות` · 🖥️ `תצוגה` · ♿ `נגישות` · 🛡️ `אבטחה והרשאות` (כולל `מרכז האבטחה`: אימות דו-שלבי, `הרשאות גישה` 5, ביומטרי, `הצפנת נתונים` 4, `נעילת הפעלה` 4, `בקרת פרטיות` 4) · 🎧 `שירות ותמיכה` (`מרכז השירות`: מוקד/צ׳אטבוט/דיווח באג/המרת מידות/`מחשבון כמויות` 3/סנכרון/דרושים/`סיור היכרות` 6) · 🚚 `משלוח ותשלום` · 🌐 `אזור ושפה` (שפה 3/יחידות 2/מטבע 2) · ℹ️ `מידע` · 🔄 `איפוס לברירת מחדל` (action → `reset()` + toast `איפוס לברירת מחדל`).

עלים עם side-effect ממשי (מתוך `_applyLeaf`): `בהיר`/`כהה`, `קטן`/`בינוני`/`גדול`, `הפחתת אנימציות`, `₪ שקל`/`$ דולר`, `עברית`/`العربية`/`English`, `מטרי (מ׳, ק״ג)`/`אימפריאלי`, `משלוח קטן`/`טנדר`/`משאית`, `ברירת מחדל — משלוח אקספרס`, `מצב ניגודיות גבוהה (לשמש)`, `אימות דו-שלבי`, `כניסה ביומטרית`, `הרשאת מיקום`, `5/15/30/60 דק׳`, `עדכוני משלוחים`/`מבצעים והטבות`/`התראות תקציב`/`עדכוני הזמנות`, `שיתוף נתוני שימוש`/`שירותי מיקום`/`התאמת תוכן שיווקי`/`שליחת דוחות תקלה`. כל יתר העלים → `«label» — בבנייה`.

---

## 5. חוקים עסקיים (R1 / R2)

| כלל | יישום בקוד | סטטוס |
|---|---|---|
| **R1 — 5 FABs בדיוק** | `OpenDial { none, bs, search, bsMode, menu }`. רק dial אחד פתוח בכל רגע (`openDialProvider`). | חלקי — ראה §7: בקוד הנוכחי קיים trigger רק ל-`bs` (wordmark); `bsMode` לא מיושם; `search`/`menu` מצוירים אך ללא trigger גלוי |
| **R2 — אין חלון מלא** | כל פיצ׳ר נפרש כ-`DialColumn`/`DialRow` overlay מעל ה-`IndexedStack`, לא מחליף את ה-main. | מקוים |
| כל פיצ׳ר = dial | BS / Search / Menu = עצי dial רב-רמתיים; settings = dial בלבד (R3). | מקוים |
| persona = placeholder מינימלי | 👷 `קבלן` deferred (אין תת-סקשנים); מסכי persona לא נבנו כ-views. | מקוים |
| שורת dial = circle + label | `DialRow(emoji, icon: Icons.circle, label)`. | מקוים |
| טקסטים verbatim | כל הטקסטים מ-`personas`/`sections`/`menu_trees`/`settings_tree` מצוינים `@legacy`. | מקוים |

---

## 6. קריטריוני קבלה

1. `MaterialApp` נטען RTL, theme בהיר כברירת מחדל, textScaler גלובלי מגיב ל-`catalogSettings.textSize` (0.9/1.0/1.15).
2. 4 לשוניות bottom-nav (`קטלוג`/`שיחות`/`התראות`/`חנות`) ב-`IndexedStack`; החלפת לשונית מאפסת dials.
3. AppBar: wordmark `BuildSmart` פותח/סוגר BS dial; שורת status מציגה `לייבל הגרסה הנוכחי (vX.YY · DD.M.YY · «תיאור») מ-home_shell.dart` (או `עץ חכם הופעל` בקטלוג + עץ חכם); מצלמה ⇐ camera sheet; ⋮ per-tab מציג את הפריטים הנכונים לכל לשונית verbatim.
4. badge התראות מציג `9+` כש->9; badge עגלה מציג `count`.
5. Cart FAB מוסתר בלשונית חנות ובכל זמן ש-dial פתוח; tap קופץ לחנות.
6. dial אחד פתוח בלבד; scrim שחור-45% סוגר את כל ה-dials ב-tap.
7. BS dial: 5 פרסונות verbatim; 4 בעלות תתי-עצים; 👷 קבלן deferred; `🔬 בדיקות רגרסיה` פותח `RegressionPanelScreen`; עלה ללא ילדים → toast `«title» — בבנייה`.
8. Search dial: 4 כלים; 🎤 קולי + 📷 ברקוד פעילים; ⚙️ פילטרים + ↕️ מיון = placeholder (toast בבנייה).
9. Menu dial: 4 לשוניות; עצי בית/הפרויקטים/רכש/הגדרות נפרשים בעומק; עלי הגדרות עם side-effect מחילים + toast `«label» עודכן`; עלה פעיל נצבע ב-brand.
10. אין חלון מלא לאף פיצ׳ר (R2); persona = placeholder.

---

## 7. פערים ידועים

1. **חוסר trigger ל-Search ו-Menu dials.** ב-`home_shell.dart` מצוירים `OpenDial.search` ו-`OpenDial.menu` (שורות 65-79), אך לא נמצא בקוד שום אלמנט UI שמציב מצבים אלה (חיפוש בכל `lib/` החזיר רק את ה-render ב-shell ואת ה-test harness). בפועל רק BS dial ניתן לפתיחה (wordmark). יש להוסיף FABs/triggers ל-Search ו-Menu כדי לעמוד ב-R1 (5 FABs).
2. **`OpenDial.bsMode` לא מיושם.** הערך קיים ב-enum אך אין לו render ואין trigger.
3. **המעטפת אינה "5-FAB row".** במקום שורת 5 FABs, ה-shell בנוי כ-WhatsApp-style: 4 לשוניות bottom-nav + AppBar (wordmark+מצלמה+⋮ per-tab) + FAB עגלה יחיד. R1 (5 FABs) אינו ממומש פיזית במעטפת הנוכחית.
4. **👷 קבלן — deferred.** אין תת-סקשנים ב-`kPersonaSections` (`contractor` חסר במפה); tap מציב persona ללא פריטים להצגה.
5. **Search "קטלוג" ככלי חמישי — הוסר.** התיעוד ב-`dial_state.dart`/`search_dial_widget.dart` מציין שהקטלוג הפך ללשונית; כיום 4 כלים בלבד ב-Search.
6. **`openRewardsHub` (מועדון BuildSmart) — חלקי.** מופיע רק כצומת בתוך `סיור היכרות` (Settings); אין עץ פרופיל/דרגות/מועדון מלא במקור ה-Flutter שנקרא.
7. **עלי הגדרות רבים ללא side-effect.** קבוצות `חשבון`, `מידע`, רוב `מרכז האבטחה`/`מרכז השירות` ועוד → `«label» — בבנייה` בלבד.
