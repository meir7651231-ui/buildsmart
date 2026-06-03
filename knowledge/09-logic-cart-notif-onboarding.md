# סל-render · checkout-submit · התראות · onboarding/roles (11000–11907)

## סל + checkout-submit (11005–11481)
- `openCreditDetail`/`saveCreditLimit` (מסגרת-אשראי לקבלן).
- **`renderCart()`** (11044) → `view-cart`: קיבוץ ל-`store-group` (לפי ספק) + `computeCheckout` + ship-plan.
- **`syncOrderToSystem`** (11212) — דוחף הזמנה ל-`SYS_ORDERS` המשותף (קבלן→חנות/שליח/מנהל רואים).
- **`checkout()`** (11312) — אישור: יוצר `localOrder` → `syncOrderToSystem` → מנקה סל → `notifyOrderStatus`. `testCheckoutLayout` (QA).

## ⭐ התראות (11482–11618)
- `seedNotifications` (11482) — 3 seed: 📦 "הזמנה BS-1042 יצאה לדרך" · 🏷️ "מבצע 15% על אביזרי אינסטלציה" · 💰 "תזכורת תקציב מגדל הרצליה 66%". כל אחת `{id, text, time, read, icon, detail:{title, lines[], action:{label, fn}}}`.
- `renderNotifications`/`openNotifDetail` · **`pushNotification`** (11555, התראה חיה) · `toggleNotifications` (פאנל) · `clearNotifications` · `simulateIncomingNotification` · `notifyOrderStatus` (לפי סטטוס). `notifTimeLabel`.
- **`toast(msg)`** (11619) · `tick` (11627, שעון `clock`).

## ⭐ Onboarding + כניסת-תפקיד (11634–11907)
- `ONBOARD_SCREENS` (11634) — 10 מסכים (splash/welcome/login/profession/manager/store/store-login/courier/worker/delivery-note).
- **`showScreen(id)`** (11635). זרימה: splash → welcome → (login / profession → `buildPrep`(רשימת-העמסה) → `prepProceed` → **`enterApp`** (11756)).
- `pickProfession`/`backToProfession` · `currentStage`/`buildPrep`/`prepRow`/`prepChoice`.
- **persona entry**: `renderStoreLogin`/`storeLogin`/`storeLogout` · **`enterRole(role)`** (11806) — מ-role-drawer: contractor/manager/store/courier/worker → המסך המתאים. `loginExisting`.
- worker: `renderWorker`/`pickWorkerScreen`/`refreshTasks`. **`admTab`** (11890) — מעבר-טאב בדשבורד-admin (משותף ל-4 פרסונות).
