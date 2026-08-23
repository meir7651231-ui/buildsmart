# OrderNotifSheet

- **screen:** `order_notif_sheet`
- **role:** composer

## עצם · object (6)

> registry 6 · mapped 6/6 · **unregistered 0**

- **cfgText** "🔔 התראות הזמנות ומשלוחים" · `order_notif_sheet.t01` ✅
- **cfgText** "שאר ההתראות נשארו בהגדרות › התראות" · `order_notif_sheet.t02` ✅
- **cfgText** "עדכוני הזמנות" · `order_notif_sheet.t03` ✅
- **cfgText** "אישור · בהכנה · מוכן · שינוי סטטוס" · `order_notif_sheet.t04` ✅
- **cfgText** "עדכוני משלוחים" · `order_notif_sheet.t05` ✅
- **cfgText** "יצא לדרך · בדרך אליך · נמסר" · `order_notif_sheet.t06` ✅

## חיבורים · connections (2)

- **reads** · `watch` → `notifSettingsProvider`
- **reads** · `read` → `notifSettingsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
