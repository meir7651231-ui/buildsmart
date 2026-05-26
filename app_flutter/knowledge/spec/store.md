# אפיון — מסך חנות (store_screen.dart)

> מסמך אפיון פורמלי. כל מחרוזת עברית מועתקת verbatim מהקוד (R8 — אין המצאה).
> מקור: `lib/screens/store_screen.dart` (2808 שורות), `lib/state/smart_cart.dart`, `lib/state/store_settings.dart`.

---

## 1. מזהה ומיקום

| פריט | ערך |
|---|---|
| קובץ | `app_flutter/lib/screens/store_screen.dart` |
| Widget שורש | `StoreScreen` (`ConsumerStatefulWidget`) |
| מיקום בניווט | **Tab רביעי** ב-`IndexedStack` של `home_shell.dart` (אינדקס `3`, מתחת ל-Catalog / Chats / Notifications). מגיעים אליו דרך bottom-nav של ה-shell. |
| state פנימי | `_headerVisible` (bool) — מסתיר/מציג את כותרת ה-tab בעת גלילה דרך `tabHeaderHiddenProvider`. |

**Providers מרכזיים שהמסך צורך:**

| Provider | סוג | תפקיד |
|---|---|---|
| `storeSectionProvider` | `StateProvider<StoreSection>` | ה-section הפעיל: `all` / `cart` / `orders` / `services`. ברירת מחדל `all`. |
| `storeSearchQueryProvider` | `StateProvider<String>` | מחרוזת החיפוש החופשי. |
| `storeFavoritesProvider` | `StateProvider<Set<String>>` | קבוצת כותרות פריטים מסומנים כמועדפים. |
| `cartQtysProvider` | `StateProvider<Map<String,int>>` | כמויות פריטי הסל הקבועים. ברירת מחדל `{'blk':150,'pls':5,'blt':80,'bm':10}`. |
| `cartDeliveryProvider` | `StateProvider<CartDelivery>` | שיטת משלוח נבחרת. אתחול לפי `selfPickupDefault` בהגדרות. |
| `cartPaymentProvider` | `StateProvider<CartPaymentMethod>` | אמצעי תשלום נבחר. אתחול לפי `defaultPayment` בהגדרות. |
| `cartProjectProvider` | `StateProvider<String>` | פרויקט משויך. ברירת מחדל `'בית דוד 3'`. |
| `smartCartProvider` | `StateNotifierProvider<List<SmartCartLine>>` | שורות "מוצרים חכמים" שנוספו ממסך מוצר. |
| `storeSettingsProvider` | `StateNotifierProvider<StoreSettings>` | הגדרות החנות (persist ל-SharedPreferences מפתח `bs.store-settings.v1`). |
| `cartListsProvider` | (cart_lists_state) | שמירת סל כרשימה בשם. |
| `tabHeaderHiddenProvider` | (dial_state) | הסתרת כותרת tab בגלילה. |

---

## 2. מטרה

מסך החנות מרכז את כל פעולות הקנייה והשירות של המשתמש מול ספקי חומרי הבנייה:
עיון בפריטי החנות, ניהול הסל הפעיל וביצוע checkout, מעקב אחר הזמנות, וגישה לשירותי שרשרת אספקה (השכרת כלים, פקדונות, החזרות, מכרזי ספקים, גיליונות בטיחות, השוואת מחירים). המסך משמש כ"מרכז רכש" שמתבסס על הגדרות החנות (מע"מ, מינימום, סף הזמנה גדולה, אמצעי תשלום ברירת מחדל וכו').

---

## 3. מבנה ופריסה (מלמעלה למטה)

המסך הוא `Column` עם שני חלקים:

**א. כותרת מתקפלת (`_headerVisible`, נסתרת בגלילה למטה):**
1. **`_SearchBar`** — שדה חיפוש עגול, hint `'חיפוש הזמנות ומוצרים...'`, אייקון חיפוש + כפתור X לניקוי כשיש טקסט.
2. **`_SectionChipsRow`** — שורת 4 pills אופקית: `'הכל'`, `'🛒 הסל'`, `'📦 הזמנות'`, `'🔧 שירותים'`. הפעיל צבוע ב-`BsTokens.brand`.
3. **`_SummaryRow`** — 3 summary chips קבועים (לא אינטראקטיביים): `'🛒 3 פריטים בסל'` (brand), `'📦 2 הזמנות פתוחות'` (`0xFF4CAF50`), `'📨 3 הצעות ספקים'` (`0xFFFF9800`).
4. **`_QuickActionsRow`** — 4 פעולות מהירות (כפתורי עיגול): `'מועדפים'` (עם badge לפי מספר המועדפים) · `'מועדים'` · `'תזמון'` · `'שיחה'`. כל אחת פותחת bottom-sheet.

**ב. אזור התוכן (`_StoreList`, עם RefreshIndicator / pull-to-refresh בן 800ms):**
תוכן נבחר לפי ה-section הפעיל:
- `all` ⇐ `_AllList` — רשימת כל 8 פריטי החנות.
- `cart` ⇐ `_CartView` — תצוגת הסל המלאה (פירוט בהמשך).
- `orders` ⇐ `_OrdersList` — רשימת 5 הזמנות.
- `services` ⇐ `_ServicesGrid` — רשימת 6 שירותים.

**תצוגת הסל (`_CartView`, מלמעלה למטה):**
1. `_ProjectSelector` ("🏗️ שיוך לפרויקט") — **רק אם** `saveCartToProject == true`.
2. כותרת `🛠️ מוצרים חכמים` + שורות smart-cart — **רק אם** `smartLines` לא ריק.
3. כותרות ספקים (`_SupplierHeader`) + שורות פריט (`_CartItemRow`) מקובצות לפי ספק.
4. `_DeliverySelector` ("🚚 אפשרויות משלוח") — 3 כרטיסי משלוח.
5. `_NotesField` ("📝 הערות לשליח").
6. `_SummaryCard` — סכום ביניים / מע"מ / משלוח / סה"כ.
7. `_PaymentSelector` ("💳 אמצעי תשלום") — 3 chips.
8. `_CheckoutButton` ("הזמן עכשיו · ₪X →").
9. `_CartActionsRow` — שמור / שתף / נקה.

---

## 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| `_SearchBar` | TextField | hint `'חיפוש הזמנות ומוצרים...'` | הקלדה ⇐ עדכון `storeSearchQueryProvider`; X ⇐ ניקוי | ✅ |
| Pill `'הכל'` | chip | קבוע | tap ⇐ `StoreSection.all` | ✅ |
| Pill `'🛒 הסל'` | chip | קבוע | tap ⇐ `StoreSection.cart` | ✅ |
| Pill `'📦 הזמנות'` | chip | קבוע | tap ⇐ `StoreSection.orders` | ✅ |
| Pill `'🔧 שירותים'` | chip | קבוע | tap ⇐ `StoreSection.services` | ✅ |
| Summary chip `'🛒 N פריטים בסל'` | label | **נגזר**: `cartItemCount(cartQtys, smartLines)` | מתעדכן עם הסל | ✅ |
| Summary chip `'📦 N הזמנות פתוחות'` | label | **נגזר**: `_kOrders.where(isOrderOpen)` (stage≠delivered) | — | ✅ |
| Summary chip `'📨 N הצעות ספקים'` | label | **נגזר** מ-badge של שורת "מכרז ספקים" (`_kSupplierOffersCount`) | — | ✅ (מקור-יחיד, נתון mock) |
| QuickAction `'מועדפים'` | כפתור+badge | `storeFavoritesProvider` | tap ⇐ אם ריק toast `'אין פריטים מועדפים'`; אחרת sheet `_FavoritesSheet` | ✅ |
| QuickAction `'מועדים'` | כפתור | קבוע | tap ⇐ `_MoadimSheet` (לוח שנה / אירועים קרובים / לוח עבודה / תזכורות) | 🚧 (פריטים → toast "בבנייה") |
| QuickAction `'תזמון'` | כפתור | קבוע | tap ⇐ `_TizmonSheet` (תזמן פגישה/משלוח/עובד/ביקורת) | 🚧 |
| QuickAction `'שיחה'` | כפתור | קבוע | tap ⇐ `_SichaSheet` (4 אנשי קשר) → toast `'שיחה עם … — בבנייה'` | 🚧 |
| `_StoreRow` `'הסל שלי'` 🛒 | שורת רשימה | `_kAllItems[0]` preview `'3 פריטים ממתינים לסיכום'` badge 3 | tap ⇐ מעבר ל-`StoreSection.cart` | ✅ |
| `_StoreRow` `'ההזמנות שלי'` 📦 | שורה | preview `'הזמנה #1234 · בדרך אליך'` badge 1 | tap ⇐ מעבר ל-`StoreSection.orders` | ✅ |
| `_StoreRow` `'השכרת כלים'` 🔧 | שורה | `'2 כלים מושכרים עד 30.5'` | tap ⇐ `_ServiceSheet(0)` | ✅ |
| `_StoreRow` `'פקדונות'` 💰 | שורה | `'פיקדון פעיל · ₪350'` | tap ⇐ `_ServiceSheet(1)` | ✅ |
| `_StoreRow` `'החזרה חדשה'` ↩️ | שורה | `'בקשה #567 ממתינה לאישור'` | tap ⇐ `_ServiceSheet(2)` | ✅ |
| `_StoreRow` `'מכרז ספקים'` 📨 | שורה | `'3 הצעות חדשות התקבלו'` badge 3 | tap ⇐ `_ServiceSheet(3)` | ✅ |
| `_StoreRow` `'גיליונות בטיחות'` 🧪 | שורה | `'5 גיליונות זמינים להורדה'` | tap ⇐ `_ServiceSheet(4)` | ✅ |
| `_StoreRow` `'השוואת מחירים'` 📊 | שורה | `'4 ספקים עדכנו מחירים'` badge 2 | tap ⇐ `_ServiceSheet(5)` | ✅ |
| Swipe על שורה | Dismissible (endToStart) | — | swipe ⇐ toggle מועדף (לא מוחק) | ✅ |
| `_OrderRow` BS-1234 | כרטיס הזמנה | `'12 פריטים'` · `'₪5,420'` · `'24.5, 14:00'` | tap ⇐ `_OrderSheet` | ✅ |
| `_OrderRow` BS-1221 | כרטיס | `'5 פריטים'` · `'₪1,890'` | tap ⇐ `_OrderSheet` | ✅ |
| `_OrderRow` BS-1198 | כרטיס | `'3 פריטים'` · `'₪630'` | tap ⇐ `_OrderSheet` | ✅ |
| `_OrderRow` BS-1171 | כרטיס | `'8 פריטים'` · `'₪2,240'` | tap ⇐ `_OrderSheet` | ✅ |
| `_OrderRow` BS-1155 | כרטיס | `'2 פריטים'` · `'₪310'` | tap ⇐ `_OrderSheet` | ✅ |
| status chip `'בדרך 🚛'` | תווית סטטוס | stage `transit`, צבע `0xFF4CAF50` (ירוק) | — | ✅ |
| status chip `'מוכן 📦'` | תווית | stage `ready`, צבע `0xFF2196F3` (כחול) | — | ✅ |
| status chip `'בהכנה 🔧'` | תווית | stage `preparing`, צבע `0xFFFF9800` (כתום) | — | ✅ |
| status chip `'הסתיימה ✓'` | תווית | stage `delivered`, צבע `0xFF888888` (אפור) | — | ✅ |
| כפתור `'מעקב הזמנה 🚛'` (ב-`_OrderSheet`) | כפתור | — | tap ⇐ toast `'מעקב הזמנה … — בבנייה'` | 🚧 |
| `_ProjectChip` (×3 + "+ הוסף") | chip | `_kProjects` = `['בית דוד 3','מגדל עזריאלי','ללא פרויקט']` | tap ⇐ עדכון `cartProjectProvider`; "+ הוסף" ⇐ toast `'הוספת פרויקט — בבנייה'` | ✅ / 🚧 |
| `_SmartCartRow` | כרטיס | `line.productName × qty`, `brandName`, `₪total`, אביזרים | X ⇐ `smartCartProvider.remove(index)` | ✅ |
| `_CartItemRow` stepper | + / − / כמות | `_kCItems` (blk/pls/blt/bm) | − (אם qty>1) / + ⇐ `setQty`; X ⇐ `setQty(0)` (הסרה) | ✅ |
| `_CartItemRow` line total | טקסט | `unitPrice × qty` דרך `_price()` | — | ✅ |
| `_DeliveryCard` `'4 שעות'` ⚡ | בורר משלוח | fee 120 → `'₪120'` | tap ⇐ `cartDeliveryProvider = express` | ✅ |
| `_DeliveryCard` `'יום-יומיים'` 📦 | בורר | fee 45 → `'₪45'` | tap ⇐ `standard` | ✅ |
| `_DeliveryCard` `'איסוף עצמי'` 🏪 | בורר | fee 0 → `'חינם'` | tap ⇐ `pickup` | ✅ |
| `_NotesField` | TextField | hint `'קומה / כניסה / שם האתר / הוראות לנהג...'` | הקלדה (לא נשמר/לא נשלח) | 🚧 |
| `_SummaryCard` "סכום ביניים" | שורת סיכום | label `'סכום ביניים'` / `'סכום ביניים (ללא מע"מ)'` | — | ✅ |
| `_SummaryCard` `'מע"מ 18%'` | שורת סיכום | `_price(vat)` | — | ✅ |
| `_SummaryCard` `'משלוח'` | שורת סיכום | `'חינם'` או `_price(deliveryFee)` | — | ✅ |
| `_SummaryCard` `'סה"כ לתשלום'` | שורת סיכום (bold) | `_price(total)` | — | ✅ |
| `_PaymentChip` `'כרטיס'` 💳 | בורר תשלום | `card` | tap ⇐ `cartPaymentProvider = card` | ✅ |
| `_PaymentChip` `'ביט'` 📲 | בורר | `bit` | tap ⇐ `bit` | ✅ |
| `_PaymentChip` `'אשראי ספק'` 🤝 | בורר | `supplierCredit` | tap ⇐ `supplierCredit` | ✅ |
| `_CheckoutButton` | כפתור ראשי | `'הזמן עכשיו · ${_price(total)} →'` | tap ⇐ `_checkout()` (gates → `_CheckoutSheet`) | ✅ (mock) |
| `_CheckoutSheet` `'אישור הזמנה'` | כפתור | מציג פרויקט/משלוח/תשלום/סה"כ | tap ⇐ toast `'הזמנה #{second} אושרה! 🎉'` (לא יוצרת הזמנה אמיתית) | 🚧 |
| `_CartActionsRow` `'שמור'` | TextButton | — | tap ⇐ דיאלוג `'שמור סל כרשימה'` → `cartListsProvider.saveCart` → toast `'הרשימה נשמרה בהצלחה'` | ✅ |
| `_CartActionsRow` `'שתף'` | TextButton | — | tap ⇐ toast `'סל שותף:\n…'` (3s) | 🚧 |
| `_CartActionsRow` `'נקה'` | TextButton | — | tap ⇐ `cartQtysProvider = {}` + toast `'הסל נוקה'` | ✅ |

---

## 5. מצבים

| מצב | תנאי | תוצאה ב-UI |
|---|---|---|
| **סל ריק (חיפוש ללא תוצאות)** | רשימה מסוננת ריקה / `_itemsForSection` ריק | `_EmptyState` — 🔍 + `'אין פריטים'` או `'לא נמצאו תוצאות\nעבור "$query"'`. בסל עצמו: `cartQtys={}` ו-`smartLines=[]` ⇒ subtotal=0, אין שורות פריט, אך הבוררים והסיכום עדיין מוצגים. |
| **סל מלא (ברירת מחדל)** | `cartQtys` מאוכלס + אולי smartLines | שורות מקובצות לפי ספק + smart-cart, סיכום מלא, כפתור checkout עם total. |
| **מתחת מינימום** | `minOrderAmount > 0` ו-`subtotal < minOrderAmount` | לחיצה על checkout ⇐ toast `'מינימום להזמנה: ${_price(minOrderAmount)}'` ו-**חסימת** המעבר ל-sheet. |
| **הזמנה גדולה** | `confirmLargeOrder` ו-`total >= largeOrderThreshold` | דיאלוג `'אישור הזמנה גדולה'` עם הטקסט: `'סכום ההזמנה {total} חורג מהסף שהגדרת ({threshold}). להמשיך?'` + כפתורים `'ביטול'` / `'אשר והמשך'`. ביטול ⇐ עצירה. |
| **אחרי checkout** | אישור ב-`_CheckoutSheet` | סגירת ה-sheet + toast `'הזמנה #{DateTime.now().second} אושרה! 🎉'`. **אין** ניקוי סל / יצירת הזמנה אמיתית (mock). |

---

## 6. חוקים עסקיים ולוגיקה (מפורט)

כל הנוסחאות הן פונקציות טהורות (`store_screen.dart`, מצוינות כ-regression-tested ב-`test/gaps_test.dart`).

### 6.1 דמי משלוח — `deliveryFeeFor(CartDelivery d)`
```
express  → 120
standard → 45
pickup   → 0
```
(תואם ל-`_kDeliveryOptions`: ⚡ 4 שעות = 120, 📦 יום-יומיים = 45, 🏪 איסוף עצמי = 0.)

### 6.2 מע"מ — `cartVat(int subtotal, {required bool vatInclusive})`
שיעור המע"מ הוא **18%**.
- **`vatInclusive == true`** (המחיר כבר כולל מע"מ): `vat = subtotal - round(subtotal / 1.18)` — חלק המע"מ הגלום בסכום ברוטו.
- **`vatInclusive == false`** (מע"מ נוסף מעל): `vat = round(subtotal * 0.18)`.

### 6.3 סה"כ — `cartTotal(int subtotal, int deliveryFee, {required bool vatInclusive})`
- **inclusive**: `total = subtotal + deliveryFee` (המע"מ כבר בתוך subtotal; דמי המשלוח מתווספים).
- **exclusive**: `total = subtotal + cartVat(subtotal, false) + deliveryFee`.

### 6.4 מתחת מינימום — `cartBelowMinimum(int subtotal, StoreSettings s)`
```
return s.minOrderAmount > 0 && subtotal < s.minOrderAmount;
```
מתבסס על **subtotal** (לא total). אם `minOrderAmount == 0` (ברירת מחדל) — לעולם לא חוסם.

### 6.5 אישור הזמנה גדולה — `cartNeedsLargeConfirm(int total, StoreSettings s)`
```
return s.confirmLargeOrder && total >= s.largeOrderThreshold;
```
מתבסס על **total** (כולל מע"מ ומשלוח). השוואה `>=` (כולל את ערך הסף עצמו).

### 6.6 חישוב הסיכום ב-`_SummaryCard` (למה זה מסתכם)
- שורת "סכום ביניים": כש-inclusive מציגה `subtotal - vat` (= הסכום נטו, ללא מע"מ) ותחת label `'סכום ביניים (ללא מע"מ)'`; כש-exclusive מציגה `subtotal` תחת label `'סכום ביניים'`.
- שורת מע"מ: תמיד `vat`.
- שורת משלוח: `deliveryFee` (או `'חינם'`).
- שורת סה"כ: `total`.

**בדיקת סגירה (inclusive):** נטו + מע"מ + משלוח = `(subtotal − vat) + vat + deliveryFee = subtotal + deliveryFee = total` ✓.
**בדיקת סגירה (exclusive):** `subtotal + vat + deliveryFee = total` ✓.

### 6.7 מיפויי ברירת מחדל
- `cartDeliveryFor(selfPickupDefault)` → `pickup` אם true, אחרת `standard`.
- `cartPaymentFor(StorePayment)` → `bit`→bit, `supplierCredit`→supplierCredit, `card`/`applePay`→card.

### 6.8 חישוב subtotal (ב-`_CartView`)
```
subtotal = Σ (item.unitPrice × qtys[item.id]) על _kCItems  +  Σ line.total על smartLines
```
מחירי יחידה: blk=4, pls=42, blt=3, bm=45. `SmartCartLine.total = brandPrice×productQty + Σ(acc.price×acc.qty)`.

### 6.9 ערכי ברירת מחדל מספריים (מ-`StoreSettings.defaults`)
| הגדרה | ברירת מחדל |
|---|---|
| שיעור מע"מ | **18%** (קבוע בקוד, לא הגדרה) |
| `vatInclusive` | **true** |
| `minOrderAmount` | **0** (אין מינימום) |
| `confirmLargeOrder` | **true** |
| `largeOrderThreshold` | **5000** |
| `defaultPayment` | `StorePayment.card` |
| `selfPickupDefault` | **false** (⇒ משלוח התחלתי = standard) |
| `saveCartToProject` | **true** |
| דמי משלוח | express 120 · standard 45 · pickup 0 |

---

## 7. נתונים, מקורות ושמירה

- **Smart cart** — `smartCartProvider` (`SmartCartNotifier`), **in-memory בלבד**, ללא persist. שורות נוספות ממסך מוצר (`add`), נמחקות (`remove(index)`), מתאחדות לפי `setQtyForKey` (קו עם `productQty<=0` מסיר את המוצר), נמנות לפי `qtyForKey(productKey)`.
- **כמויות סל קבועות** — `cartQtysProvider` (Map in-memory). "נקה" מאפס ל-`{}`.
- **רשימות סל שמורות** — `cartListsProvider.saveCart(name, items)` (פעולת "שמור"); נשמרות עם שם, emoji, qty (מחולץ מ-`item.qty.split(' ')[0]`) ו-price.
- **`saveCartToProject`** — דגל הגדרה (persist) שמפעיל/מסתיר את שיוך הסל לפרויקט. השיוך נשמר ב-`cartProjectProvider` (in-memory).
- **הגדרות החנות** — `StoreSettings` עוברות JSON-serialize ונשמרות ב-`SharedPreferences` תחת `bs.store-settings.v1`; נטענות באתחול ה-notifier (best-effort, נופל ל-defaults אם פגום).
- **הזמנות / שירותים / פרטי-סל** — כולם **קבועים hard-coded** (`_kOrders`, `_kOrderDetails`, `_kServices`, `_kServiceSheets`, `_kCartItemDetails`); לא מגיעים מ-backend.

---

## 8. תלות בהגדרות (`StoreSettings`)

| הגדרה | השפעה במסך החנות |
|---|---|
| `defaultPayment` | קובע את ערך האתחול של `cartPaymentProvider` דרך `cartPaymentFor` (מיפוי applePay→card). |
| `selfPickupDefault` | קובע את ערך האתחול של `cartDeliveryProvider`: true⇒`pickup`, false⇒`standard` (דרך `cartDeliveryFor`). |
| `vatInclusive` | משנה את חישוב המע"מ והסה"כ (6.2/6.3) ואת תווית "סכום ביניים" ב-`_SummaryCard` (עם/בלי "(ללא מע"מ)"). |
| `minOrderAmount` | אם `>0` וה-subtotal נמוך ממנו ⇒ checkout חסום עם toast מינימום. |
| `confirmLargeOrder` + `largeOrderThreshold` | אם confirm פעיל ו-`total >= threshold` ⇒ דיאלוג אישור הזמנה גדולה לפני המעבר ל-sheet. |
| `saveCartToProject` | אם true ⇒ מוצג `_ProjectSelector` בראש תצוגת הסל; אם false ⇒ מוסתר. |

---

## 9. קריטריוני קבלה (Given/When/Then)

1. **מתחת מינימום חוסם checkout**
   Given `minOrderAmount = 500` ו-subtotal = 300
   When המשתמש לוחץ "הזמן עכשיו"
   Then מוצג toast `'מינימום להזמנה: ₪500'` ו-`_CheckoutSheet` **לא** נפתח.

2. **מינימום 0 לא חוסם**
   Given `minOrderAmount = 0` (ברירת מחדל)
   When checkout, בכל subtotal
   Then אין חסימת מינימום.

3. **הזמנה גדולה דורשת אישור**
   Given `confirmLargeOrder = true`, `largeOrderThreshold = 5000`, total = 5000
   When checkout
   Then מוצג דיאלוג `'אישור הזמנה גדולה'`; "ביטול"⇒עצירה; "אשר והמשך"⇒פתיחת `_CheckoutSheet`.

4. **סף לא הגיע — אין אישור**
   Given total = 4999, threshold = 5000
   When checkout
   Then אין דיאלוג, מעבר ישיר ל-sheet (בכפוף לגייט המינימום).

5. **confirmLargeOrder כבוי**
   Given `confirmLargeOrder = false`
   When total חורג מהסף
   Then אין דיאלוג אישור.

6. **מע"מ inclusive**
   Given `vatInclusive = true`, subtotal = 1180
   Then `vat = 1180 − round(1180/1.18) = 1180 − 1000 = 180`; "סכום ביניים (ללא מע"מ)" = ₪1,000; total = subtotal + deliveryFee.

7. **מע"מ exclusive**
   Given `vatInclusive = false`, subtotal = 1000, delivery = standard(45)
   Then `vat = round(1000×0.18) = 180`; total = 1000 + 180 + 45 = 1225.

8. **בורר משלוח מעדכן דמי משלוח וסה"כ**
   Given נבחר "איסוף עצמי"
   Then שורת "משלוח" = `'חינם'`, deliveryFee = 0, total מתעדכן.

9. **ניקוי סל**
   Given לחיצה על "נקה"
   Then `cartQtys = {}` + toast `'הסל נוקה'`.

10. **שיוך פרויקט תלוי הגדרה**
    Given `saveCartToProject = false`
    Then `_ProjectSelector` אינו מוצג בראש הסל.

---

## 10. פערים ידועים

- ~~**Summary chips קבועים**~~ ✅ **טופל**: הצ'יפים נגזרים כעת ממצב אמיתי — `cartItemCount` (סל), `isOrderOpen` (הזמנות פתוחות = 3, תוקן מהערך השגוי 2), והצעות הספקים ממקור-יחיד עם שורת "מכרז ספקים" (נתון mock סטטי, אך ללא כפילות).
- **`_CheckoutSheet` "אישור הזמנה"** — mock בלבד: מציג toast עם `DateTime.now().second` כמספר הזמנה, **אינו** מנקה את הסל ואינו יוצר רשומת הזמנה.
- **הזמנות ושירותים** — נתונים קבועים (`_kOrders`, `_kServiceSheets`); ה-sheets שלהם מובילים ברובם ל-toast `'… — בבנייה'`. "מעקב הזמנה 🚛" — בבנייה.
- **`_NotesField` (הערות לשליח)** — הטקסט אינו נשמר ואינו נשלח ל-checkout.
- **`_CartSheet` ו-`_showCartSheet`** — מבנה ישן עם total קבוע `'₪1,340'` וכפתור `'מעבר לתשלום →'` (toast "בבנייה"); נראה לא בשימוש בזרימה הראשית (תצוגת הסל מנותבת ל-`_CartView`).
- **"שתף" / "+ הוסף פרויקט" / Quick-actions sheets** — toasts "בבנייה".
- **pull-to-refresh** — `Future.delayed(800ms)` ריק, ללא טעינת נתונים אמיתית.
- **בורר תשלום/משלוח** — בחירת המשתמש אינה משנה את `defaultPayment`/`selfPickupDefault` בהגדרות (one-way: settings⇒cart בלבד).
