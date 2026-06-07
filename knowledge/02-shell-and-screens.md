# מעטפת + מסכים + תיבות — `<body>` (index.html 4021–5419)

נלכד מקריאה מלאה. כל מחרוזת verbatim; כל `(handler)` הוא ה-onclick במקור;
מיקום = `index.html:NNNN`.

המבנה הפיזי: `stage > phone > notch > screen` (4022–4025). בתוך `.screen` יושבים:
(א) מסכי-onboarding במסך-מלא, (ב) המעטפת הקבועה (statusbar/appbar/tabbar),
(ג) `.body` עם כל ה-views של אפליקציית-הקבלן, (ד) overlays.

---

## A. מסכי Onboarding (fullscreen, 4030–4333)
מוצגים אחד-בכל-פעם; כולם `display:none` חוץ מ-splash.

### `screen-splash` (4030) — לוגו פתיחה
- לוגו SVG (בית: teal `#1f6f6b` + amber `#f2a516`) · מותג **Build​Smart** ·
  סלוגן: **"מהשרטוט עד האתר — בלי לשכוח כלום"** (4037).

### `screen-welcome` (4042) — חיבור / רישום
- המבורגר "מי אתה?" (`toggleRoleDrawer`) (4044) · לוגו + מותג.
- כפתור ירוק **"כניסה ללקוח קיים"** (`enterAsExisting`) (4054).
- מפריד **"או הירשם"** · כותרת **"רישום ראשוני"** · תת **"מלא את הפרטים — סימן ✓ יופיע כשהשדות תקינים"**.
- שדה `regName` placeholder **"שם מלא"** + צ'ק ✓ (`checkRegistration`) · שדה `regContact` placeholder **"טלפון או אימייל"** + צ'ק ✓.
- כפתור-אישור `regConfirm` **"אישור והמשך"** (`finishRegistration`) (4070).
- חלופה **"המשך ללא רישום (דוגמה)"** (`enterAsDemo`) (4074).
- foot: **"בהרשמה אתה מאשר את תנאי השימוש של BuildSmart"**.

### `roleDrawer` (4083) — מגירת-תפקידים "מי אתה?"
- כותרת **"מי אתה?"** / תת **"בחר תפקיד כדי להיכנס"**.
- 5 כפתורי-תפקיד (`enterRole('…')`):
  | אייקון | תפקיד | תיאור-משנה | role |
  |---|---|---|---|
  | 👷 | **קבלן** | הזמנת חומרים, מלאי, משימות | contractor |
  | 👔 | **מנהל המערכת** | ניהול מוצרים, חנויות, לקוחות | manager |
  | 🏪 | **חנות ספק** | הזמנות נכנסות, מלאי החנות | store |
  | 🛵 | **שליח** | משלוחים ועדכוני סטטוס | courier |
  | 🦺 | **עובד** | המשימות שהוקצו לי בשטח | worker |
- foot: **"הדגמה — כל התצוגות חולקות מאגר נתונים אחד"** (4113).

### `screen-login` (4116) — התחברות קבלן
- back→welcome · לוגו+מותג+סלוגן · כותרת **"ברוך הבא 👋"** · תת **"התחבר כדי להתחיל לעבוד"**.
- שדה `loginPhone` תווית **"מספר טלפון"**, placeholder **"050-0000000"**.
- כפתור amber **"המשך"** (`loginExisting`) · מפריד **"או"** · **"כניסה מהירה להדגמה"** (`loginExisting`).
- foot: **"בכניסה אתה מאשר את תנאי השימוש של BuildSmart"**.

### `screen-profession` (4148) — בחירת מקצוע
- back→welcome · כותרת **"מה התחום שלך?"** · תת **"נתאים לך את האפליקציה — קטלוג, כלים והמלצות לפי המקצוע"**.
- 3 כרטיסי-מקצוע (`pickProfession(name,emoji)`):
  | 🔧 | **אינסטלטור** | ברזים, אסלות, צנרת, חימום מים |
  | ⚡ | **חשמלאי** | נקודות, לוחות, כבלים, גופי תאורה |
  | 🔨 | **קבלן שיפוצים** | פרויקט שלם — מבנייה ועד גמר |
- foot: **"תוכל לשנות את הבחירה בכל עת מההגדרות"**.

### `screen-prep` (4188) — רשימת העמסה (לפני כניסה)
- back→profession · תג-שלב `prepStageTag` **"שלב נוכחי"** · כותרת `prepH` **"רשימת העמסה"** · `prepSub` (דינמי) · `prepBody` (דינמי).
- foot: כפתור `prepGo` **"המשך"** (`prepProceed`) · **"דלג — כניסה לאפליקציה"** (`enterApp`).

### `screen-manager` (4207) — דשבורד מנהל (admin-screen)
- adm-top: back **"‹ יציאה"**→welcome · כותרת **"👔 מנהל המערכת"**.
- 4 טאבים (`admTab('…')`): **📊 לוח בקרה** `m-products` · **🚚 הזמנות** `m-orders` · **👥 לקוחות** `m-customers` · **🛠️ ניהול** `m-manage`.
- panes דינמיים: `mgrDashboard` · `mgrOrderList` · `mgrCustomers` · `mgrManage`.
- overlay `mgrStoreDetailOverlay` → `mgrStoreDetailBody`.

### `screen-store-login` (4241) — כניסת ספקים
- back→welcome · 🏪 · כותרת **"כניסת ספקים"** · תת **"בחר את החנות שלך כדי להיכנס לפורטל הניהול"**.
- `storeLoginList` (דינמי) · note **"🔒 באפליקציה האמיתית כל ספק מתחבר עם קוד גישה אישי. זוהי כניסת הדגמה."**.

### `screen-store` (4254) — דשבורד חנות-ספק (admin-screen)
- adm-top: back **"‹ יציאה"** (`storeLogout`) · כותרת `storeTitle` **"🏪 חנות ספק"**.
- 4 טאבים: **🏠 בית** `s-home` · **📥 הזמנות** `s-orders` · **📦 מלאי** `s-stock` · **🧰 פורטל** `s-portal`.
- panes (+ הערות):
  - `s-home` → `storeHome`.
  - `s-orders`: note **"אשר הזמנות והכן אותן — הסטטוס יעבור לשליח ולמנהל."** → `storeOrderList`.
  - `s-stock`: note **"מוצר שאזל לא יוצג לקבלנים בקטלוג."** → `storeStockList`.
  - `s-portal`: note **"כלי הספק — דירוג, SLA, אזורי הפצה, הנחות כמות וברקודים."** → `storePortal`.
- overlay `storePickOverlay` → `storePickBody`.

### `screen-courier` (4291) — דשבורד שליח (admin-screen)
- adm-top: back→welcome · כותרת **"🛵 שליח · משאית 14"**.
- `courierHome` + `courierList` (דינמיים) · overlay `courierDetailOverlay` → `courierDetailBody`.

### `screen-delivery-note` (4311) — תעודת משלוח
- dn-bar: back **"‹ סגור"** (`closeDeliveryNote`) · כותרת **"תעודת משלוח"** · **"🖨️ הדפסה"** (`window.print`).
- `deliveryNoteBody` (דינמי).

### `screen-worker` (4321) — דשבורד עובד (admin-screen)
- adm-top: back→welcome · כותרת **"🦺 עובד"**.
- note **"בחר את שמך, בצע את המשימה, צרף תמונה ושלח לאישור המנהל."** · `workerPick` · `workerTasksBody`.

---

## B. המעטפת הקבועה (statusbar · appbar · tabbar)

### `statusbar` (4335)
- שעון `clock` **"9:41"** · `bsBattery` 🔋 (aria "סוללה") · `bsConn` 📶 (aria "חיבור רשת").

### `appbar` (4343)
- brand: לוגו-בית SVG + **Build​Smart**.
- head-icons:
  - פעמון `bell-btn` (`toggleNotifications(event)`) + `bellBadge` (מוסתר, "0").
  - עגלה (`go('cart')`) + `cartCount` "0".
- **`notifPanel`** (4364): head **"התראות"** + **"נקה הכל"** (`clearNotifications`) · `notifList` (דינמי).
- **`deliv-row`** (4371): שתי גלולות —
  - **"משלוח לאתר"** (`openSitePicker`) → `appbarSite` **"מגדל הרצליה ›"**.
  - **"סטטוס משלוח"** (`openShipmentStatus`) → `appbarDelivery` **"צפה במשלוחים ›"**.

### `tabbar` (5383) — 5 טאבים תחתונים
| data-tab | תווית | go() | הערה |
|---|---|---|---|
| home | **בית** | `go('home')` | |
| catalog | **קטלוג** | `go('catalog')` | |
| sites | **הפרויקטים** | `go('sites')` | |
| cart | **רכש** | `go('cart')` | + `tabDot` (מוסתר) |
| profile | **הגדרות** | `go('profile')` | התווית "הגדרות" אך מובילה ל-profile |

> הערה (לתיעוד): טאב "רכש" מצביע ל-cart, וטאב "הגדרות" מצביע ל-profile —
> אי-התאמה תווית↔יעד, נשמרת כעובדה מהמקור.

### `toast` (5381)
- `toast` עם `dot` + `toastMsg` (דינמי).

### tagline (מתחת ל-mockup, 5409)
- **"אב-טיפוס אינטראקטיבי של BuildSmart · חוויית חנות במשלוח עד שעתיים · הלב של הדמו: לחיצה על מוצר ⚡חכם מפעילה את עץ המוצרים"**.

---

## C. ה-views של אפליקציית-הקבלן (`.body`, 4413–5227)
ניווט: `go(v)` מציג `view-<v>` ומסמן את הטאב (project/sites→sites,
cart/orders→cart, catnav→catalog).

### `view-home` (4416) — בית
- searchwrap: `homeSearch` placeholder **"חפש כלי עבודה, חומר בניין, אביזר..."** + כפתור-ניקוי + dropdown הצעות `homeSearchSuggest` (`onHomeSearchInput`).
- hero: תג `homeGreet` **"⚡ אקספרס לאתר"** · כותרת **"הזמן עכשיו — קבל לאתר עד שעתיים"** · **"בלי לעצור את העבודה ובלי נסיעה לחנות. הכל מגיע אליך."**.
- כפתור-hub: **🤖 "בינה מלאכותית ואוטומציה"** / **"חיזוי מלאי, סורק ברקוד, חלופות זולות ותובנות"** (`openAIHub`) (4433).
- **קטגוריות** (cat-grid, 4444) — 8, כולן `go('catalog')`:
  🔧 כלי עבודה · 🚿 אינסטלציה · ⚡ חשמל · 🧱 בנייה · 🎨 גמר וצבע · 🔩 חיבורים · 🦺 בטיחות · ➕ הכל.
- **עץ התקנה חכם — אינסטלציה** (4457) + **"הצג הכל"** (`openSmartCatalog`) · hint **"💡 נסה את זה: בחר ברז או כלי סניטרי. עץ ההתקנה יקפיץ אוטומטית את כל האביזרים שצריך להרכבה — צינורות, אטמים, סיליקון — שהצוות תמיד שוכח."** · `homeProductRow` (דינמי).
- **מסלול עבודה חכם** (4466): project-hero (`go('project')`) — תג **"🛁 חדש — מאפס עד גמר"** · **"גמר אמבטיה — מלווה אותך שלב-שלב"** · **"4 שלבים בסדר הנכון. כל שלב: עץ מוצרים + חלון 'סדר הרכבה' שמראה מה לפני מה."** · progress 38% **"פתח מסלול ›"**.
- 3 promises (4479):
  - **📐 סרוק תוכנית עבודה** / **"צלם שרטוט אינסטלציה — נזהה מה צריך להזמין"** (`go('scan')`).
  - **📦 המלאי שלי** / **"מה כבר יש לך — במחסן ובאתר"** (`go('stock')`).
  - **📋 משימות העבודה** / **"חלק משימות לעובדים ועקוב אחרי הביצוע"** (`go('tasks')`).
- **הזמנה חוזרת לאתר זה** (4511) + **"היסטוריה"** (`go('orders')`) · `reorderHistory` (דינמי).

### `view-catalog` (4519) — קטלוג
- catnav-bar: `catSearch` placeholder **"חיפוש בכל הקטלוג..."** + ניקוי + הצעות (`onCatSearchInput`) · כפתור-מיון **⇅** (`toggleCatSort`) + תפריט.
- hint `catHint` **"💡 קטלוג אינסטלציה מלא — לחץ על מוצר לפתיחת עץ המוצרים."** · `catChips` · `catalogList` (דינמיים).

### `view-catnav` (4543) — ניווט-קטגוריות (מסך עצמאי)
- catnav-bar: back **›** (`catNavBackBtn`) · `catNavSearch` placeholder **"חיפוש בכל הקטלוג..."** (`onCatNavSearchInput`) · מיון **⇅** (`toggleCatNavSort`).
- `catNav` · `catDrill` · `catNavList` (דינמיים).

### `view-project` (4563) — פרויקט חכם
- view-switch: **🌳 הפרויקט שלי** (on) / **🏗️ האתרים שלי** (`go('sites')`).
- project-hero: תג **"🚽 פרויקט מלא · בחר יום ›"** (`openDayPicker`) · `smartProjTitle` **"מאפס עד מסירה"** · **"BuildSmart מפרק את המשימות לימי עבודה לפי הסדר הנכון בשטח."** · progress `smartHeroBar`/`smartHeroTxt` **"טוען…"**.
- **budget-box** `budgetBox` (`openBudgetDetail`): **"💰 תקציב הפרויקט"** + `bgPct` · בר `bgBar` · 3 עמודות: `bgSpent` **"הוצאת עד כה"** · `bgLeft` **"נשאר בתקציב"** (ירוק) · `bgTotal` **"תקציב כולל"** · foot **"הקש לפרטים וניתוח ›"** + **"✏️ עריכה"** (`openBudgetEditor`).
- כפתור-hub: **📊 "מרכז פיננסים"** / **"מדד, תנאי תשלום, ROI, דוחות וקבלני משנה"** (`openFinanceHub`).
- hint **"💡 הפרויקט החכם מפרק כל משימה לימי עבודה. אפשר לבצע ימים בכל סדר — ההתקדמות נספרת לפי מה שסומן כבוצע."** · `smartStages` (דינמי) · `smartProjDone` **"🎯 בסיום כל ימי העבודה — הפרויקט מוכן למסירה."**.

### `view-scan` (4984) — סורק תוכניות
- back-head→home **"סריקת תוכנית"**.
- scan-hero: תג **"📐 סריקה חכמה"** · **"צלם תוכנית — קבל רשימת חומרים"** · **"BuildSmart קורא כל סוג שרטוט, מזהה את הנקודות, ומשווה מחירים בין חנויות שותפות."**.
- שלב A `scanStepUpload`: **"בחר סוג תוכנית"** · `planTypePicker` · 2 כפתורי-העלאה (`startScan`): **"צלם תוכנית / פתח מצלמה"** · **"העלה קובץ / PDF · תמונה"** · hint **"💡 נסה את זה: בחר סוג תוכנית ולחץ 'צלם' — נשתמש בשרטוט לדוגמה כדי להדגים את הסריקה והשוואת המחירים."**.
- שלב B `scanStepCanvas` (מוסתר): קנבס-סריקה, `blueprintHolder`, tint/laser, `scanStatus` **"סורק את התוכנית..."**.
- שלב C `scanStepResults` (מוסתר): detect-summary ✓ `scanSummaryT` **"זוהו 4 נקודות"** / `scanSummaryS` **"— פריטים נדרשים"** · price-note **"💰 המחירים נמשכים מ-3 חנויות שותפות. BuildSmart בוחר אוטומטית את ההצעה המשתלמת ביותר לכל פריט."** · `scanZones` · כפתור **"אשר הכל — הוסף לסל"** (`addScanToCart`) · **"סרוק תוכנית אחרת"** (`resetScan`).

### `view-orders` (5057) — ההזמנות שלי
- view-switch: **🛒 הסל שלי** (`go('cart')`) / **📦 ההזמנות שלי** (on).
- **"ההזמנות שלי"** · כלים: **↻ רענן** (`renderMyOrders`) · **🧪 צור הזמנת בדיקה** (`generateMockOrder`) · `myOrdersList`.
- **"שירותי שרשרת אספקה"** — 6 כפתורים:
  🔧 **השכרת כלים** (`openToolRental`) · 💰 **פקדונות** (`openDeposits`) · ↩️ **החזרה חדשה** (`openRMA(null)`) · 📨 **מכרז ספקים** (`openRFQ`) · 🧪 **גיליונות בטיחות** (`openMSDS`) · 📊 **השוואת מחירים** (`openPriceCompare('מוצר')`).
- כותרות-משנה + רשימות: **📨 מכרזי ספקים** `rfqListBody` · **🔧 השכרות פעילות** `rentalListBody` · **💰 פקדונות** `depositListBody` · **↩️ בקשות החזרה** `rmaListBody`.

### `view-cart` (5100) — הסל שלי
- view-switch: **🛒 הסל שלי** (on) / **📦 ההזמנות שלי**.
- site-strip: **"ההזמנה תשויך ותישלח לאתר"** · `cartSiteName` **"—"** · **"החלף ›"** (`openCartSitePicker`).
- `cartShipPlan` · `cartItems` (דינמיים) · ריק `cartEmpty`: 🛒 **"הסל ריק"** / **"עבור לקטלוג ובחר מוצר אב — עץ המוצרים החכם יעשה את השאר."** · `cartSummary`.

### `view-sites` (5126) — האתרים שלי
- view-switch: **🌳 הפרויקט שלי** / **🏗️ האתרים שלי** (on).
- **"סקירת תקציב"** + budget-box `sitesBudgetBox` (תאומה ל-view-project; foot **"...· מסונכרן עם הפרויקט ›"**).
- **"האתרים שלי"** · **"＋ הוסף פרויקט / אתר חדש"** (`openProjectModal`) · `projectList`.

### `view-profile` (5167) — פרופיל / זהות
- `identityScreen` (דינמי).

### `view-stock` (5173) — מלאי
- back-head→home **"המלאי שלי"** · **"📦 המלאי שלי"**.
- stock-tabs: **🏬 המחסן** `warehouse` (on) / **🏗️ האתר** `site` (`pickStockTab`).
- `stockList` · hint **"💡 כשתסמן פריט כ'במחסן' או 'באתר' בעץ המוצרים — הוא יופיע כאן."**.

### `view-tasks` (5193) — משימות עבודה
- back-head→home **"משימות העבודה"** · **"📋 משימות העבודה"**.
- task-loc: **"📍 מיקום נוכחי"** select (`setTaskLocation`): **🏗️ באתר** `site` / **🏬 במחסן** `warehouse`.
- role-switch: **👔 מנהל** `manager` (on) / **👷 עובד** `worker` (`pickRole`).
- כפתור-hub: **🏗️ "ניהול אתר הבנייה"** / **"גאנט, ליקויים, נוכחות, יומן עבודה ובטיחות"** (`openSiteHub`) · `tasksBody`.

---

## D. Overlays (sheets) — בתוך `.body`
תבנית: `.overlay > .sheet > .grip + .sheet-head(h3+p) + .sheet-body(#id)`.
רובם נטענים דינמית; להלן הכותרות הסטטיות + מזהי-הגוף.

### בורר אתר / זמן / יום
- `sitePickerOverlay` (4390): **"בחר אתר משלוח"** / **"לאן לשלוח את החומרים?"** → `sitePickerBody`.
- `deliveryPickerOverlay` (4402): **"זמן אספקה"** / **"מתי להביא את החומרים לאתר?"** → `deliveryPickerBody`.
- `dayPickerOverlay` (4630): **"קפיצה ליום בפרויקט"** / **"בחר יום להצגה — ההתקדמות נשארת לפי מה שבוצע בפועל."** → `dayPickerBody`.

### תקציב / קטגוריה / אתר
- `budgetEditOverlay` (4642): **"עריכת תקציב הפרויקט"** / **"עדכן את התקציב הכולל, או הוסף / הורד עלות."** — שדות `beTotalInput` **"תקציב כולל (₪)"**, `beSpentInput` **"סך ההוצאות עד כה (₪)"** · **"שמור תקציב"** (`saveBudget`) · מפריד **"— או הוסף / הורד עלות —"** · `beCostInput` **"סכום העלות (₪)"** placeholder "לדוגמה: 500" · **➕ הוסף הוצאה** (`adjustBudget(1)`) / **➖ הורד הוצאה** (`adjustBudget(-1)`).
- `budgetDetailOverlay` (4673): **"תקציב הפרויקט — פרטים וניתוח"** / **"תמונת מצב מלאה. להזין נתונים אמיתיים — הקש 'עריכה'."** → `budgetDetailBody`.
- `catEditOverlay` (4685): `ceTitle` **"עריכת קטגוריה"** / **"עדכן את שם הקטגוריה והסכום שהוצא בה."** — `ceNameInput` **"שם הקטגוריה"**, `ceAmountInput` **"סכום שהוצא (₪)"** · **"שמור קטגוריה"** (`saveCategoryEdit`) · **"🗑️ מחק קטגוריה"** (`deleteCategory`).
- `siteEditOverlay` (4708): **"עריכת פרטי האתר"** / **"עדכן את שם האתר, הכתובת ומנהל העבודה."** — `seNameInput` **"שם האתר"**, `seAddrInput` **"כתובת"**, `seManagerInput` **"מנהל עבודה"** · **"שמור שינויים"** (`saveSiteEdit`).

### הגדרות / עזרה / דרגה / משלוח / התראה
- `settingsOverlay` (4734, sheet-tall): **"הגדרות מתקדמות"** / **"חשבון, התראות, תצוגה, משלוח ועוד."** → `settingsBody`.
- `helpOverlay` (4746, sheet-tall): **"איך זה עובד"** / **"כל מה שצריך לדעת כדי להתחיל"** → `helpBody`.
- `rankDetailOverlay` (4758) → `rankDetailBody`.
- `shipmentStatusOverlay` (4766): **"סטטוס משלוחים"** / **"כל המשלוחים שבדרך אליך כרגע."** → `shipmentStatusBody`.
- `notifDetailOverlay` (4778) → `notifDetailBody`.
- `missingDecisionOverlay` (4786) → `missingDecisionBody` (החלטת פריט-חסר לקבלן).

### Category A — שרשרת-אספקה (4793)
- `shipPlanOverlay` → `shipPlanBody` (מתכנן-משלוח; סגירה ב-click-מחוץ).
- `shipItemsOverlay` → `shipItemsBody` (שיוך שורות-סל למשלוח).
- `rmaOverlay`→`rmaBody` · `rentalOverlay`→`rentalBody` · `depositOverlay`→`depositBody`.
- `signatureOverlay` (4816): **✍️ "חתימה דיגיטלית"** / **"חתום באצבע על המסך לאישור קבלת המשלוח."** · קנבס `sigCanvas` · **"נקה"** (`clearSignature`) / **"אשר חתימה"** (`saveSignature`).
- `docScanOverlay`→`docScanBody` · `govXmlOverlay`→`govXmlBody` · `priceCmpOverlay`→`priceCmpBody` · `rfqOverlay`→`rfqBody` · `msdsOverlay`→`msdsBody`.

### Category B–J — hubs + feature-sheets (4851–4923)
זוג קבוע לכל קטגוריה: `*HubOverlay` (מרכז) + `*FeatureOverlay` (פיצ'ר בודד).
- **B פיננסים**: `financeHubOverlay`/`finFeatureOverlay` (`finFeatureBody`).
- **C ניהול-אתר**: `siteHubOverlay`/`siteFeatureOverlay`.
- **F פורטל ספק/שליח**: `portalFeatureOverlay` · `courierPortalOverlay` · `chatOverlay`→`chatBody`.
- **G AI/אוטומציה**: `aiHubOverlay`/`aiFeatureOverlay`.
- **H gamification**: `rewardsHubOverlay`/`rewardsFeatureOverlay`.
- **I אבטחה**: `securityHubOverlay`/`securityFeatureOverlay` + **`sessionLock`** (4926): 🔒 **"ההפעלה ננעלה"** / **"ננעלת אוטומטית עקב חוסר פעילות. אמת את זהותך כדי להמשיך."** · **"🔓 בטל נעילה והמשך"** (`unlockSession`).
- **J שירות/הרחבה**: `serviceHubOverlay`/`serviceFeatureOverlay`.

### תשלום / אשראי / סטטוס-אתר / שיוך-סל
- `cartSitePickerOverlay` (4936): **"שיוך ההזמנה לאתר"** / **"בחר לאיזה אתר ההזמנה תשויך ותישלח."** → `cartSitePickerBody`.
- `paymentDetailOverlay` (4948): **"פירוט תשלום מלא"** / **"כל מרכיבי החיוב — לפי חנות ספק."** → `paymentDetailBody`.
- `creditDetailOverlay` (4960): **"מסגרת אשראי — קבלן"** / **"תנאי האשראי והמסגרת הזמינה."** → `creditDetailBody`.
- `siteStatusOverlay` (4972): `ssTitle` **"סטטוס האתר"** / **"תמונת מצב מלאה — כל שורה לחיצה."** → `siteStatusBody`.

---

## E. Overlays ברמת `.screen` (אחרי `.body`)

### `taskSheet` (5230) — פרטי משימה
- `taskName` **"משימה"** / `taskFor` **"לעובד"** · `taskBody` · foot כפתור `taskAction` **"סגור"** (`taskActionClick`).

### `overlay` (5245) — **עץ מוצרים חכם** (לב הדמו)
- eyebrow: pulse + **"עץ מוצרים חכם הופעל"** · `treeTitle` **"צינור PVC 50 מ\"מ"** · **"אלה האביזרים שנדרשים להתקנה הזו — סמן מה שצריך והוסף לסל."**.
- tree-root: `rootImg` 🟦 · `rootName` **"צינור PVC 50 מ\"מ"** · `rootMeta` **"מוצר אב · כמות: 6 יח'"** · `rootPrice` **"₪228"** · כפתור `rootCheck` ✓ (`toggleRootInTree`, title "בחר את המוצר הראשי").
- `rootPickHint` **"סמן ✓ אם תרצה גם את המוצר הראשי בסל"** · `treeDiagram` · `branchLabel` **"אביזרים משלימים"** + **"מומלץ ע\"י BuildSmart"** · `accessoryList`.
- foot: **"סה\"כ כולל N פריטים שנבחרו"** (`pickCount`) + `treeTotal` · **"הוסף את הפריטים שנבחרו לסל"** (`addTreeToCart`).

### `brandOverlay` (5284) — בורר מותג
- **"בחר מותג"** / **"בחר מותג ל… — או השאר את ההמלצה שלנו ⭐"** (`brandProdName`) · `brandList` · **"סגור"** (`closeBrands`).

### `variantOverlay` (5299) — בורר סוג/מידה
- `variantLabel` **"בחר סוג / מידה"** / **"בחר את הסוג המתאים ל…"** (`variantProdName`) · `variantList` · **"סגור"** (`closeVariants`).

### `orderOverlay` (5314) — סדר הרכבה
- eyebrow: pulse + **"סדר הרכבה — איך העץ מורכב"** · `orderTitle` **"איטום והכנת רצפה"** · **"הרצף הנכון בשטח. סטייה מהסדר היא הטעות היקרה ביותר בגמר."**.
- ao-intro: `aoIntroT` **"מה הולך לפני מה"** / `aoIntroS` **"כל שלב מציג את החומרים שמשתתפים בו ואת התלות בשלב הקודם."** · `orderSteps` · foot **"הבנתי — סגור"** (`closeOrder`).

### `accDetailOverlay` (5339) — פרטי אביזר
- `accDetailName` **"פרטי האביזר"** / **"כל מה שצריך לדעת על האביזר הזה"** · `accDetailBody` · **"סגור"** (`closeAccDetail`).

### `projectModal` (5354) — פרויקט/אתר חדש
- **"פרויקט / אתר חדש"** / **"הוסף אתר בנייה — תוכל להחליף בינו לאחרים בכל רגע"**.
- שדות: `pmProjName` **"שם הפרויקט"** placeholder "לדוגמה: מגדל ויטה — תל אביב" · `pmProjAddr` **"כתובת האתר"** placeholder "רחוב, מספר, עיר" · `pmProjMgr` **"מנהל העבודה"** placeholder "שם מנהל העבודה".
- foot: **"הוסף פרויקט"** (`saveProject`).

---

## הערת-ארכיטקטורה (5415)
האפליקציה רצה standalone לחלוטין — לכל נתיב-נתונים יש fallback בזיכרון, אין שכבת-data חיצונית. (בנייה קודמת טענה `apiService.js` כאן; זה שבר את האפליקציה ב-viewers מבודדים.)

---

## 🔄 Preact (`app/`) — דלתא מול אב-הטיפוס (מעטפת)
> ה-Preact (החי בפרודקשן) תרגם את אב-הטיפוס ל-**dial pattern**. מקור: `app/src/`.
> הארכיטקטורה (`app/src/app.tsx`): `.screen` > `.screen__bg` + **`FloatingHeader`** + **`main.content`** (view יחיד לפי-פרסונה) + `Fabs` + `MenuSpeedDial` + `SearchPanel` + `BsDial` + `ProductSheet` + `Toast`.

⬆️ **שודרג (תורגם):**
- **מסכים-מלאים → dials.** אין החלפת-מסך-מלא; כל יעד-תפריט חי ב-dial. ה-views של אב-הטיפוס (home/catalog/cart/project/sites/scan/orders/stock/tasks) הומרו ל-speed-dials.
- **tabbar (5) → `MenuSpeedDial` (4 טאבים):** בית/הפרויקטים/רכש/הגדרות. **קטלוג עבר ל-search-FAB** (`app-store.ts`: "קטלוג moved to the search FAB").
- **appbar → `FloatingHeader`:** לוגו **BS** (→`toggleBs`, פותח BsDial) + שם-פרסונה + עגלה(+badge). פעמון → `notificationCount` signal.
- **routing → לפי-פרסונה** (`ActiveView`): manager/store/courier/worker/contractor(=Home). אין נתיבי-view.
- state ב-**signals** (`@preact/signals`, `app-store.ts`): `menuOpen`/`searchOpen`/`bsOpen` · `menuActiveTab`/`categoryPath`/`settingsLevel`/`profilePath` (drill) · `cart`/`cartCount` · `editingLeafKey`.

➕ **נוסף:**
- **הגדרות dial-בלבד:** `settingsLevel`(top/profile/advanced), 9 קבוצות (`SettingsGroupId`), drill-paths, ו-**עריכת-leaf inline** (`editingLeafKey`/`startEditingLeaf`).
- **FABs קבועים** (`fabs.tsx`): תפריט ☰ + חיפוש 🔍 (BS בהדר).

➖ **הוחסר / placeholder:**
- **12 מסכי-onboarding** (splash/welcome/login/profession/prep) — אין; כניסה לפי-פרסונה ישירה.
- **דשבורדי-פרסונה** (`views/*.tsx`, 11–302 ש') — placeholder מינימלי, מול המסכים-המלאים באב-הטיפוס.

---

## 📱 Flutter (`app_flutter/lib/screens/`) — האפליקציה האמיתית (מעטפת) ⭐ נכתב-מחדש מ-whats-happening
> מעטפת WhatsApp-style (`home_shell.dart`, **1033ש׳**): `Scaffold` + AppBar + **4 בוטם-טאבים** (`IndexedStack`) + dial-overlays (bs/search; **ה-menu-dial הוסר 07-06**) + cart-FAB. Riverpod.

🔀 **המבנה האמיתי:**
- **4 בוטם-טאבים:** **מחלקות · שיחות · התראות · חנות** (RTL). ✅ **אומת שורה-שורה** (`home_shell.dart:508–527` — labels מחלקות/שיחות/התראות/חנות). ⚠️ **תיקון:** טאב-0 = **`DepartmentsScreen`** (מחלקות: אינסטלציה · ברזים-וסניטריים · כלי-עבודה — 4 פעילות, 5 "בקרוב"), **לא "קטלוג"**. 🔎 **שורש-הבלבול נמצא:** אפילו ה-comment בקוד (ש׳32) כתוב "קטלוג", אבל ה-label המוצג בפועל = "מחלקות" — לכן ה-spec/KB רשמו "קטלוג". הקוד (ה-label) קובע. מחלקה → `CatalogScreen`.
- **AppBar:** "BuildSmart" (→BS/role-picker) + שם-משתמש-chip + version-label + 🔍חיפוש · 📷מצלמה (`camera_sheet`, 5 מצבים) · ⋮תפריט(per-tab) · 💡סיור.
- **dial-overlays** (`openDialProvider`+scrim): **bs** (5 פרסונות) · **search** (4 כלים) + **cart-FAB** (מוסתר בטאב-חנות). ⚠️ **07-06:** ה-**menu**-dial (4 tabs בית/הפרויקטים/רכש/הגדרות) **הוסר** (cutover `b9737cf`) → כלי-הקבלן עברו לגישה-נייטיב (תפריט-בית/חנות/פרופיל/projects; ר׳ `00-START-HERE` §4.6).

⭐ **האפליקציה בוגרת — לא "shell + toast" (תיקון לטענה הקודמת שלי):**
- **`CatalogScreen` (7,660ש׳)** = 8 sections (הכל · בית-Finder · תכנון-חיבור · קטגוריות · עץ-חכם · וריאנטים · מועדפים · חיפושים) · drill-עץ · חיפוש-עם-סינונימים · lens-selector · כרטיס-מוצר-חכם מלא.
- ⭐ **`InstallStudioScreen` (3,185ש׳) = יהלום-הכתר:** מתכנן-צנרת — גרירת-מוצרים→מנוע (`install_engine` 1391ש׳: Dijkstra + auto-compliance PRV/TMTV)→BOM + צ'קליסט-תקינות + pressure-drop + אומדן-מחיר + שמירת-פרויקטים. **עמוק מהפרוטוטייפ — אין מקבילה.**
- `FinderScreen` (מאתר לא-טכני) · `suppliers/lipskey_*` (מסכי-מותג) · **שיחות** (`chats_screen` **1437ש׳**, 6 threads + auto-reply + ארכוב) · **התראות** (**1081ש׳**, קיבוץ-run≥3 + סינון + swipe) · **חנות** (`store_screen` **3,131ש׳**, סל + checkout VAT-18% + הזמנות + שירותים ממוקדי-קבלן) · **4 מסכי-הגדרות** (~40 שדות כ"א, persisted).

➖ **מה כן toast 'בבנייה':** ה-dial-overlays (menu-leaves · פרסונות store/courier/worker/manager = leaves שמציגים toast) · חלק ממצבי-מצלמה · כפתורי-משנה. אבל ה-**ליבה אמיתית ופועלת** (מחלקות→קטלוג→install-studio→סל · chats · notifications · settings).
🔧 **מול פרוטוטייפ/Preact:** **לא** port של 5-הפרסונות — אפליקציית-אינסטלציה אמיתית. install-studio/chats/notifications = **חדשים לגמרי**. ~92% roadmap · 1,023 בדיקות (155 קבצים) · checkout בסיסי (mock).
⚠️ **drift:** ה-README של app_flutter מתאר Phase-0/5-FAB מיושן; הקוד = 4-tab בוגר. הקוד קובע.
