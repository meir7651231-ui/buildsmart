# SPEC — חיבור-שרת (Firebase + R2) · פירוק-משימות

> **מטרה:** להפוך את ה-client (server-ready, Repository 6/6) למוצר-חי. ביצוע: `claude/whats-happening-LyY9G` · תחת LAW #0 · push רק על "תדחוף".
> **סטאק (מומלץ):** **Firebase** (Auth · Firestore real-time · FCM push · Functions) + **Cloudflare R2** (תמונות, כבר מוקם).
> **עיקרון:** ה-Repository מתוכנן drop-in (`orders_local` וכו' — *"only THIS class swaps; providers+UI unchanged"*). מחליפים `_local` ב-`_firebase`. **אבטחה = Firestore Security Rules (RBAC צד-שרת — הפרדת-התפקידים האמיתית).**

## 0. נקודת-תכן קריטית — sync interface מול async backend
ה-interface הנוכחי **סינכרוני** (`List<Order> all()` — לא `Future`). Firestore = async + real-time. **הפתרון (שומר drop-in):** **offline-first cache** —
- Firestore **offline-persistence** ON · `snapshots()` listener מעדכן **cache מקומי** (Riverpod).
- `all()` סינכרוני קורא מה-cache (instant) · `place/advance` כותב ל-Firestore + optimistic-cache.
- → ה-providers/UI **לא משתנים**; ה-real-time זורם דרך ה-cache. **זה ה-drop-in.**

## ארכיטקטורה
```
   Firebase Auth (OTP) ──roles(custom claims)──┐
                                               ▼
   Firestore (offline-persist + listeners) ◄──► [Repository _firebase impls] ──► providers/UI (ללא-שינוי)
        │  collections: users/orders/customers/projects/tasks/stock/chatThreads/chatMessages
        │  real-time: chat + orders (snapshots → cache → UI חי)
        ▼
   🔒 Security Rules (RBAC per-domain · chat=participants-only · credit=manager+owner)
   + App Check · FCM (push) · Functions (server-logic) · R2 (תמונות)
```

## המשימות (S0–S9 · עם תלויות)

### S0 · הקמת-Firebase (חוסם-הכל) ⭐
🎯 פרויקט + Flutter wired.
- `flutterfire configure` · deps: `firebase_core/auth/cloud_firestore/messaging/functions` · init ב-`main.dart` · Firestore offline-persistence ON.
- ✅ DoD: האפליקציה עולה עם Firebase מאותחל · analyze 0.

### S1 · Authentication (חוסם S5) ⭐
🎯 זהות-אמת במקום role-picker-כ-זהות.
- Firebase Auth **OTP-טלפון** (ראשי) + מייל-fallback · מסך/sheet login · logout.
- **תפקיד מהשרת:** custom-claims (`role: contractor/store/courier/worker/manager`) — `role_picker` רק למשתמשי-רב-תפקיד; ברירת-מחדל מהזהות.
- ✅ DoD: משתמש מתחבר · התפקיד מגיע מ-auth (לא client-pick) · `_loaded`-guard.

### S2 · סכמת-Firestore + cache-pattern (חוסם S3/S4)
🎯 מיפוי המודלים ל-collections + דפוס-ה-cache.
- collections: `users` · `orders`(OrderLineItem) · `customers`(credit) · `projects` · `tasks` · `stock` · `chatThreads`(participants[]) · `chatMessages` · `siteNodes`.
- מימוש דפוס-ה-cache (S0§) כ-base-class ל-repos.
- ✅ DoD: סכמה מתועדת · base-cache עובד על domain-אחד (pilot: orders).

### S3 · Repository `_firebase` impls (מקבילי per-domain · drop-in)
🎯 להחליף כל `_local` במימוש-Firestore (אותו interface).
| תת | domain | interface (קיים) |
|---|---|---|
| S3.orders | `orders_firebase` | all/open/place/advance/setStage |
| S3.customers | `customers_firebase` | + credit |
| S3.catalog | `catalog_firebase` | (קריאה; אולי seed-only) |
| S3.site | `site_firebase` | — |
| S3.stock | `stock_firebase` | move |
| S3.finance | `finance_firebase` | — |
- ✅ DoD לכל-תת: provider קורא מ-Firestore (דרך cache) · UI ללא-שינוי · test.

### S4 · Real-time (הפיצ'רים-המנצחים · אחרי S3)
🎯 חי בין-מכשירים.
- **S4.chat:** `sys_chat` ← Firestore `chatMessages.snapshots()` (חנות שולחת → קבלן רואה **חי, בין-מכשירים**).
- **S4.orders:** `sys_orders` ← `orders.snapshots()` (סטטוס חי לכל הפרסונות).
- ✅ DoD: בדיקה דו-מכשירית — A שולח → B רואה תוך-שניות.

### S5 · 🔒 Security Rules — RBAC צד-שרת (קריטי · לפני-השקה · אחרי S1+S2)
🎯 **הפרדת-התפקידים שאומתה ב-client — נאכפת בשרת.**
- `chatThreads/Messages`: read/write רק אם `auth.uid ∈ participants` (ה-`threadsFor` כחוק-שרת).
- `customers.credit`: read רק manager + owner.
- `orders`: store כותב new→ready · courier כותב pickup→delivered · contractor קורא-שלו.
- `users/roles`: write רק admin · **App Check** ON.
- ✅ DoD: emulator-tests — חנות **לא** קוראת data-של-אחר · צ׳אט מבודד · credit חסום.

### S6 · FCM push
🎯 push-אמת (במקום honest-stub).
- ✅ DoD: התראה (הזמנה/צ׳אט) מגיעה למכשיר.

### S7 · R2 תמונות (app-side)
🎯 חיבור-קריאה/העלאה ל-R2 (סקריפט-העלאה כבר קיים).
- ✅ DoD: תמונות-מוצר נטענות מ-R2 · העלאה (POD/before-after) עובדת.

### S8 · Cloud Functions (לוגיקה-רגישה בשרת)
🎯 ולידציה שלא-סומכת-על-client.
- order-stage-transition validation · credit-calc · triggers (push on stage-change).
- ✅ DoD: פעולה-רגישה עוברת דרך Function.

### S9 · Offline/sync
🎯 עובד-אופליין + תור-batch-order.
- Firestore offline-persistence (מובנה) + offline-queue ל-batch-order.
- ✅ DoD: פעולה-אופליין → sync בחזרת-רשת.

## תלויות + סדר
```
S0 (חוסם-הכל) → S1 (auth) ┐
              → S2 (schema+cache) ┤→ S3 (repos, מקבילי ×6) → S4 (real-time chat+orders)
S1+S2 ──────────────────────┴→ S5 (Security Rules — לפני-השקה!) 
מקבילי-אחרי-S0: S6 (push) · S7 (R2) · S9 (offline)   ·   S8 (functions) לפי-צורך
```

## אבטחה — מתווה-rules per-domain (תמצית ל-S5)
- **chat:** `allow read,write: if request.auth.uid in resource.data.participants`.
- **credit/customers:** `if role==manager || resource.data.ownerId==uid`.
- **orders:** stage-transition מותר רק לתפקיד-הנכון (store vs courier).
- **users:** role-write = admin-only. **App Check** חוסם לקוחות-לא-אפליקציה.

## אומדן (גס)
S0+S1 ~2–3 ימים · S2 ~1 · S3 ~3–4 (מקבילי) · S4 ~2 · S5 ~2 (קריטי) · S6/S7/S8/S9 ~3. **סה"כ ~2–3 שבועות** לחיבור-שרת מלא+מאובטח.

## הערות
- **drop-in נשמר** דרך cache-pattern (S0§) — אל תהפוך את ה-interface ל-async (ישבור UI).
- **S5 לא-אופציונלי** — בלי Security Rules, ה-DB פתוח-לכולם (הפרדת-התפקידים מזויפת).
- R2-creds + Firebase-admin = **בשרת/Functions בלבד**, לעולם לא ב-client.
