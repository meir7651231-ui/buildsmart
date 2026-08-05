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
- worker: `renderWorker`/`pickWorkerScreen`/`refreshTasks`. **`admTab`** (11890) — מעבר-טאב בדשבורד-admin (משותף ל-4 פרסונות). ⚠️ **זה הפרוטוטייפ בלבד** — ב-Flutter הפרסונות = **מסכים נפרדים ומבודדים** (`role_picker`→push לכל פרסונה; **אין** דשבורד-admin משותף, אין מעבר בין-לוחות). אל תממש shared-admin.

---

## 🔄 Preact (`app/src/`) — דלתא מול אב-הטיפוס
⬆️ **הסל** → signals (`app-store.ts`: `cart`/`setQty`/`cartCount`, ראה דוח 10).
➖ **הוחסר:**
- **onboarding הוסר לחלוטין** — אין splash/welcome/login/profession/prep; כניסה לפי-פרסונה ישירה (`ActiveView`).
- **התראות**: רק `notificationCount` signal (`app-store.ts`) — אין `seedNotifications`/`pushNotification`/פאנל-התראות.
- **checkout-submit** המלא (`checkout`/`syncOrderToSystem`/`generateMockOrder`) — לא הומר.

---

## 📱 Flutter — דלתא (התראות · שיחות · onboarding) ⭐ נכתב-מחדש מהמציאות
> ב-Flutter אלה **טאבים/מסכים native מלאים** — לא היו בפרוטוטייפ/Preact.
- **התראות** (`notifications_screen.dart` **1,081ש׳**, טאב-2): 9 התראות-דמו (orders/shipments/safety/budget/deals) · חיפוש + 6 צ'יפי-סינון · **קיבוץ-חכם** (run≥3 → "הצג עוד N"; date-groups היום/אתמול/מוקדם-יותר) · swipe-to-dismiss + undo · long-press · כפתורי-פעולה context (אשר-איסוף/טפל-כעת/עקוב — toast). persist `notifReadIds`/`notifDismissedIds`; badge נגזר (`notifUnreadCountProvider`).
- **שיחות** (`chats_screen.dart` **1,437ש׳**, טאב-1): 6 threads (הקבלן-הראשי · ספק-חומרי-בנייה · השליח · מנהל-המערכת · צ׳אטבוט · ספק-צבעים) · חיפוש + 4 צ'יפים · swipe-to-archive + undo · דף-שיחה (בועות me/them · read-receipts · typing · **auto-reply 900ms** מ-4 תגובות אם `botEnabled`) · persist `bs.chat-archived/muted.v1`.
- **onboarding** (`onboarding_screen` + `welcome_screen` + `profession_screen`): welcome (רישום/קיים/דמו) → profession (אינסטלטור/חשמלאי/קבלן-שיפוצים) → 3 שקופיות → home. gate `welcomeSeenProvider` (`bs.welcome-seen.v1`). שונה מ-role-drawer של הפרוטוטייפ — כאן onboarding ממוקד-קבלן.
🔧 מול המקורות הקודמים (אב-טיפוס=פאנל-bell + role-drawer · Preact=`notificationCount` signal בלבד): Flutter הוא **הכי-עשיר** — chats+notifications כמסכים מלאים שלא היו קיימים.
