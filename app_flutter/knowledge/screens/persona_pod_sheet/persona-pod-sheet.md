# PersonaPodSheet

- **screen:** `persona_pod_sheet`
- **role:** composer

## עצם · object (8)

> registry 6 · mapped 6/6 · **unregistered 2**

- **text** "📦" · — לא-רשום
- **cfgText** "ההזמנה לא נמצאה" · `persona_pod_sheet.t01` ✅
- **cfgText** "ייתכן שההזמנה הוסרה או שהמשלוח כבר נסגר — חזרו לרשימת המשלוחים" · `persona_pod_sheet.t02` ✅
- **cfgText** "📸 אישור מסירה" · `persona_pod_sheet.t03` ✅
- **cfgText** "POD + צילום" · `persona_pod_sheet.t04` ✅
- **text** "📷" · — לא-רשום
- **cfgText** "אין צילום עדיין" · `persona_pod_sheet.t05` ✅
- **cfgText** "✅ נמסר ללקוח" · `persona_pod_sheet.t06` ✅

## חיבורים · connections (9)

- **reads** · `watch` → `sysOrdersProvider`
- **reads** · `watch` → `fulfillmentProvider`
- **reads** · `read` → `fulfillmentProvider`
- **reads** · `read` → `boardAuthProvider`
- **action** · `showToast` → `showToast`
- **action** · `openSignaturePad` → `openSignaturePad`
- **reads** · `read` → `sysOrdersProvider`
- **reads** · `read` → `rewardsProvider`
- **reads** · `read` → `workerNotifsProvider`

## התנהגות · behaviour (7)

- **onPressed** → _verb_ `showToast(context, ok ? 'צילום המסירה נשמר 📸 — מוצג לחנות ולמנהל' : 'התמונה …` → toast
- **onPressed** → _verb_ `openSignaturePad(context)` → open → openSignaturePad
- **onPressed** → _verb_ `showToast(context, ok ? 'החתימה נשמרה ✍️' : 'החתימה לא נשמרה — נסה שוב')` → toast
- **onPressed** → _verb_ `ref.read(sysOrdersProvider.notifier).courierAdvance(order.id)` → write → sysOrdersProvider
- **onPressed** → _verb_ `ref.read(rewardsProvider.notifier).awardCoins(kCourierDeliveryCoins)` → write → rewardsProvider
- **onPressed** → _verb_ `ref.read(workerNotifsProvider.notifier).addNotification(username: s.username,…` → write → workerNotifsProvider
- **onPressed** → _verb_ `showToast(context, 'המשלוח ${order.id} עודכן — מסונכרן עם החנות והמנהל ✓')` → toast

## floor · external functions (6)

- `bsOnAccent`
- `confirmDestructive`
- `pickTaskPhoto`
- `stampCourierClock`
- `taskPhotoWidget`
- `unawaited`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `orderId`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 2 unregistered — "📦" · "📷"
