# Firestore Schema — BuildSmart (S2.1)

> מסמך-הסכמה לפרויקט `server-connect` (Firebase + R2). הוא ה-SSOT למיפוי
> המודלים של ה-client ל-collections של Firestore, ומשמש כחוזה ש-6 מימושי
> ה-`_firebase` המקבילים (S3) יורשים. מקור: `SPEC-server-connect-MICRO.md`
> (בלוק "סכמת-Firestore") + `SPEC-server-connect.md` §S2.
>
> **פרויקט:** `buildsmart-b0b78` · Firestore Standard · region `me-west1`
> (תל-אביב) · Production mode (deny-by-default → דורש Rules ב-S5).

---

## עיקרון-על — sync interface מול async backend

ה-Repository interfaces **סינכרוניים** (`List<Order> all()` — לא `Future`),
ו-Firestore אסינכרוני. הגשר (S2.2 `FirestoreCachedRepo<T>`) = **offline-first
cache**: listener של `snapshots()` מעדכן cache בזיכרון · קריאות-sync מוגשות
מה-cache · כתיבות מעדכנות cache אופטימית **וגם** כותבות ל-Firestore.
**לעולם אין להפוך interface ל-`Future`; אין providers אסינכרוניים; אפס שינוי-UI.**
כשל-כתיבה/stream/decode נרשם (logged) ולעולם לא נזרק אל ה-UI.

---

## 9 ה-collections

```
users/{uid}        {phone, role, fcmToken, displayName}
orders/{id}        {projectId, lines[], sum, stage, siteAddress, contractorId, storeId, courierId, ts}
customers/{id}     {name, phone, creditLimit, used, balance, ownerId}
projects/{id}      {name, address, status, contractorId, members[]}
tasks/{id}         {projectId, title, status, assigneeUid, log[]}
stock/{id}         {sku, name, qty, location, projectId}
siteNodes/{id}     {projectId, floor, apt, room, ...}
chatThreads/{id}   {participants:[uid], names, lastMsg, ts}
chatMessages/{id}  {threadId, fromUid, fromRole, text, ts}
```

### `users/{uid}` — doc-id = Firebase Auth uid
| שדה | טיפוס | הערה |
|---|---|---|
| `phone` | string | מספר-טלפון (E.164) של ההתחברות (OTP). |
| `role` | string | `contractor`/`store`/`courier`/`worker`/`manager`/`admin`. **כתיבה = admin בלבד** (S5.1); מקור-האמת הוא custom-claim, המסמך הוא מראה קריא. |
| `fcmToken` | string | token ל-FCM push (S6.1). |
| `displayName` | string | שם-תצוגה. |

### `orders/{id}` — doc-id = order id (למשל `BS-1042`)
ה-collection-הפיילוט של S2.3. ראו "מיפוי-שדות orders" למטה למיפוי המלא
מ-`Order` (Dart) → doc (Firestore).
| שדה | טיפוס | הערה |
|---|---|---|
| `projectId` | string | מזהה-פרויקט (ריק אם לא-משויך). |
| `lines` | array&lt;map&gt; | `OrderLineItem{sku, nameHe, brand, qty, unitPrice, lineTotal, size?, note?}` — שורות-ההזמנה שנלכדו ב-checkout. |
| `sum` | int | סכום ההזמנה ב-₪. |
| `stage` | string | אחד מ-`kManagerOrderFlow`: `new`→`preparing`→`ready`→`pickup`→`transit`→`delivered`. |
| `siteAddress` | string | כתובת-האתר. |
| `contractorId` | string | הקבלן שהזמין. |
| `storeId` | string | החנות המטפלת (ריק עד שיבוץ). |
| `courierId` | string | השליח (ריק עד שיבוץ). |
| `ts` | string (ISO-8601) | חותם-זמן יצירת-ההזמנה. |

### `customers/{id}`
| שדה | טיפוס | הערה |
|---|---|---|
| `name` | string | שם-הלקוח/קבלן. |
| `phone` | string | טלפון. |
| `creditLimit` | int | תקרת-אשראי (₪). |
| `used` | int | נוצל (₪). |
| `balance` | int | יתרה (₪). |
| `ownerId` | string | בעל-הרשומה. **read credit:** `role==manager \|\| ownerId==uid` (S5.4). |

### `projects/{id}`
| שדה | טיפוס | הערה |
|---|---|---|
| `name` | string | שם-הפרויקט. |
| `address` | string | כתובת. |
| `status` | string | סטטוס. |
| `contractorId` | string | הקבלן-הבעלים. |
| `members` | array&lt;string&gt; | uids המשויכים (לבקרת-גישה S5.6). |

### `tasks/{id}`
| שדה | טיפוס | הערה |
|---|---|---|
| `projectId` | string | הפרויקט. |
| `title` | string | כותרת-המשימה. |
| `status` | string | סטטוס. |
| `assigneeUid` | string | מבצע. |
| `log` | array&lt;map&gt; | יומן-פעולות. |

### `stock/{id}`
| שדה | טיפוס | הערה |
|---|---|---|
| `sku` | string | מק"ט. |
| `name` | string | שם-הפריט. |
| `qty` | int | כמות. |
| `location` | string | מיקום. |
| `projectId` | string | הפרויקט. |

### `siteNodes/{id}`
| שדה | טיפוס | הערה |
|---|---|---|
| `projectId` | string | הפרויקט. |
| `floor` | string/int | קומה. |
| `apt` | string | דירה. |
| `room` | string | חדר. |
| `...` | — | gantt · snags · attendance · inspections (S3.S). |

### `chatThreads/{id}`
| שדה | טיפוס | הערה |
|---|---|---|
| `participants` | array&lt;string&gt; | uids בשיחה. **read/write:** `uid in participants` (S5.2). שאילתת-real-time: `where('participants', arrayContains: uid)` (S4.1). |
| `names` | map/array | שמות-המשתתפים לתצוגה. |
| `lastMsg` | string | תקציר ההודעה האחרונה. |
| `ts` | string/timestamp | זמן ההודעה האחרונה. |

### `chatMessages/{id}`
| שדה | טיפוס | הערה |
|---|---|---|
| `threadId` | string | השיחה. שאילתה: `where('threadId').orderBy('ts')` (S4.2). |
| `fromUid` | string | השולח. **create:** `fromUid==uid` (S5.3). |
| `fromRole` | string | תפקיד-השולח (לתצוגה). |
| `text` | string | גוף-ההודעה. |
| `ts` | string/timestamp | חותם-זמן. |

---

## ⛔ הקטלוג (1,877 מוצרים) — **לא** ב-Firestore

הקטלוג (1,877 מוצרים) **אינו** מאוחסן ב-Firestore. הוא נשאר **bundled / R2-CDN
(JSON סטטי)** וה-`catalog_firebase` (S3.K) קורא משם — **אפס עלות-DB**.
טעינת קטלוג שלם מ-Firestore בכל פתיחת-אפליקציה הייתה גוררת reads מיותרים
(עלות + latency) על data שמעולם לא משתנה בזמן-ריצה. זו אזהרה מפורשת ב-SSOT
(`SPEC-server-connect-MICRO.md` §אזהרות). creds של R2/admin = בשרת/Functions
בלבד, לעולם לא ב-client.

---

## מיפוי-שדות `orders` (Dart `Order` → Firestore doc)

מודל ה-`Order` ב-client (`lib/state/orders_engine.dart`) משתמש בשמות-שדה
מהלגאסי (`who`/`site`/`createdAt`). סכמת-Firestore משתמשת בשמות-הדומיין
שב-SSOT. ה-`FirebaseOrdersRepository` (S2.3) ממפה ביניהם דרך `toDoc`/`fromDoc`,
כך שמודל-ה-client לא משתנה (drop-in).

| `Order` (Dart) | doc (Firestore) | הערה |
|---|---|---|
| `id` | doc-id | מזהה-ההזמנה (`BS-####`) הוא ה-document-id; לא משוכפל כשדה. |
| `who` | `contractorId` | הקבלן שהזמין. |
| `site` | `siteAddress` | כתובת-האתר. |
| `items` | `items` | מספר-שורות (נשמר כדי ש-`all()` יחזיר `Order` מלא ללא קריאת `lines`). |
| `sum` | `sum` | סכום ב-₪. |
| `stage` | `stage` | שלב-ה-flow. |
| `createdAt` | `ts` | **ISO-8601** (`DateTime.toIso8601String()`); ה-seed ללא-timestamp נכתב בלי השדה. |
| `lines` | `lines` | מערך `OrderLineItem`; כל פריט ⇄ map (`name/emoji/qty/price` במודל-הנוכחי; הסכמה מרחיבה ל-`sku/nameHe/brand/unitPrice/lineTotal/size?/note?` ב-S3). |
| `shipTo` | `shipTo` | נכתב רק אם לא-ריק (round-trip backward-compatible). |
| `notes` | `notes` | נכתב רק אם לא-ריק. |

> שדות-העתיד `storeId`/`courierId` קיימים בסכמה ל-S5.5 (transition-מותר-לתפקיד)
> ול-S4.4 (סטטוס-חי). מודל-ה-`Order` הנוכחי לא נושא אותם; `fromDoc` מתעלם
> משדות-עודפים ו-`toDoc` לא מוסיף אותם — כך ה-round-trip נשאר נאמן עד שהמודל
> יורחב, בלי לשבור את ה-drop-in.

---

## דפוס-ה-cache (S2.2) בקצרה

`FirestoreCachedRepo<T>` (extends `ChangeNotifier`):
1. **seed** — ה-cache נולד מלא (האפליקציה לא-ריקה לפני ה-snapshot הראשון).
2. **`attach()`** — נרשם ל-`snapshots()`; כל snapshot ממופה דרך `fromDoc`/`idOf`,
   ממוין דרך `sortBy` (Firestore מחזיר סדר-doc-id), מחליף את ה-cache,
   ו-`notifyListeners`. מסמך-פגום מדולג (logged) — לעולם לא מאפס את הרשימה.
3. **`cached()`** — קריאה-סינכרונית מה-cache.
4. **כתיבה** (`upsert`/`replaceAll`) — עדכון-cache אופטימי + `set`/`delete` ברקע
   דרך `guardWrite` שתופס+רושם (כשל-כתיבה לעולם לא נזרק ל-UI).
5. **`onFirstSnapshotEmpty()`** — hook (ברירת-מחדל no-op); ה-orders-repo דוחף את
   ה-seed לשרת (`pushCacheToRemote()`) כשה-snapshot הראשון ריק.
6. **`dispose()`** — מבטל את ה-subscription.

ה-seam `RemoteCollectionSource` (abstract) מבודד את Firestore: המימוש-האמת
`FirestoreCollectionSource` פותר `FirebaseFirestore.instance` **בעצלתיים**
(lazily, לעולם לא ב-constructor) → הסוויטה (ללא Firebase) נשארת על המסלול-המקומי.
