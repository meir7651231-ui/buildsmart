# CourierDeliveryDetailSheet

- **screen:** `courier_delivery_detail_sheet`
- **role:** composer

## עצם · object (8)

> registry 7 · mapped 7/7 · **unregistered 1**

- **text** "📦" · — לא-רשום
- **cfgText** "ההזמנה לא נמצאה" · `courier_delivery_detail_sheet.t01` ✅
- **cfgText** "ייתכן שההזמנה הוסרה או שהמשלוח כבר נסגר — חזרו לרשימת המשלוחים" · `courier_delivery_detail_sheet.t02` ✅
- **cfgText** "פריטי המשלוח" · `courier_delivery_detail_sheet.t03` ✅
- **cfgText** "מסלול ההזמנה" · `courier_delivery_detail_sheet.t04` ✅
- **cfgText** "חותמות זמן לשלבים יחוברו עם חיבור השרת" · `courier_delivery_detail_sheet.t05` ✅
- **cfgText** "📸 אישור מסירה (POD)" · `courier_delivery_detail_sheet.t06` ✅
- **cfgText** "POD זמין משלב האיסוף (כשההזמנה בידי השליח)" · `courier_delivery_detail_sheet.t07` ✅

## חיבורים · connections (8)

- **reads** · `watch` → `sysOrdersProvider`
- **action** · `showPodSheet` → `showPodSheet`
- **reads** · `read` → `boardAuthProvider`
- **reads** · `read` → `fulfillmentProvider`
- **reads** · `read` → `sysOrdersProvider`
- **reads** · `read` → `rewardsProvider`
- **reads** · `read` → `workerNotifsProvider`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `showPodSheet(context, order.id)` → open → showPodSheet

## floor · external functions (5)

- `bsOnAccent`
- `confirmDestructive`
- `fMoney`
- `haulInfo`
- `stampCourierClock`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `orderId`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 1 unregistered — "📦"
