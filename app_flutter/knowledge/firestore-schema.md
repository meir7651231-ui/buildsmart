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

> **עדכון Pillar 5 (Step 52) — התפתחות, לא סתירה.** ה-stance לעיל נשאר תקף
> ל-**מסלול-ברירת-המחדל (flags OFF)** ול-**bundled starter subset** (Phase 4):
> הקטלוג-המצומצם נשאר const/CDN, offline byte-identical, אפס עלות-DB. Pillar 5
> **מוסיף** collection-מחובר `catalogProducts/{sku}` ל-**superset ה-authored ב-scale**
> (10Ks) — **מאחורי דגלים** (`CATALOG_BASE_URL`/`CATALOG_SERVER_SEARCH`, default OFF),
> נקרא ב-**paged query** (לא listen על כל-הקטלוג — בדיוק האזהרה לעיל נשמרת),
> ומחיר ב-sub-doc role-scoped. פירוט: הסעיף "Pillar 5 — 4 משפחות-collections" למטה.

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

---

## Pillar 5 (Scale · Data · Backend) — 4 משפחות-collections חדשות + 8 composite indexes (Step 52)

> **doc-only · dormant.** ארבע משפחות-הנתונים של Pillar 5 הן **greenfield** — אף
> client לא כותב אליהן היום; הן חבויות מאחורי דגלי-ברירת-מחדל-OFF ב-`backend.dart`
> (`USE_FIREBASE_BACKEND` · `STUDIO_LIVE` · `CATALOG_SERVER_SEARCH` · `CATALOG_BASE_URL`).
> עם כל הדגלים כבויים ה-build **byte-identical** להיום; ה-indexes עולים אפס עד ה-seed
> (Phase 1, Step 61). מקור-אמת: `knowledge/studio-plan/05-scale-data-backend.md`
> §1 + §1.5, וה-**appendix R1 גובר** (price-sub-doc R1-6 · tombstone R1-9 ·
> tokens-מ-`nameHe`-בלבד R1-7 · presenceSummary R1-3).
>
> **קונבנציות מורשות (ללא סטייה):** doc-id = natural key (לא משוכפל כשדה) · כל
> timestamp = ISO-8601 string (מיון לקסיקוגרפי == כרונולוגי) · Local persist keys
> מנוקדי-גרסה `bs.<feature>.v1` · לכל collection חדש **חייב** rule מפורש
> (deny-by-default, §5/Step 65).

### משפחה 1 · Pillar 1 — עץ-הקונפיג ה-no-code (draft + published)

שני-ייצוגים, כי דפוסי-הגישה הפוכים: **מצביע** זעיר-חם שכולם קוראים, ו-**blobs
immutable** מגובבים-לפי-גודל. פרסום = **flip של המצביע** מעל snapshot-immutable חדש (§3).

#### `studioConfig/{channel}` — מצביע-הפרסום (זעיר · ~200B · doc-id = שם-ערוץ קבוע `published`/`draft`)
| שדה | טיפוס | הערה |
|---|---|---|
| `version` | int | מונה-גרסה; client משווה נכנס↔cached כדי להחליט אם למשוך snapshot (אות ה-cache-bust, §3). |
| `ref` | string | מצביע ל-snapshot immutable (`studioConfigSnapshots/v1287` / `draft-<uid>`). |
| `checksum` | string | sha256 של ה-snapshot; אימות לפני swap אטומי (§3.1). |
| `schema` | int | גרסת-סכמה; `> maxKnownSchema` → keep-last-good + "עדכן אפליקציה", **לא לנתח** (R2-7). |
| `publishedAt` / `updatedAt` | string (ISO-8601) | זמן פרסום / עדכון-draft. |
| `publishedBy` / `updatedBy` | string (uid) | מי פרסם / עדכן. |
| `draftOwnerUid` / `lockedAt` | string / iso | advisory-lock רך על ה-draft ("מנהל אחר עורך כעת", TTL) — R1-4. |

- **read:** `published` = world (כל signed-in) · `draft` = `isManager()` בלבד. **write:** `if false` — הכותב היחיד הוא ה-callable `publishConfig` (Admin-SDK, §3.2/Step 56), מגובה ב-trigger `revertIllegalConfigWrite`.
- **bootstrap-baseline (Step 68 / R2-10):** ה-`published` נזרע פעם-אחת ב-CI **לפני נעילת-ה-rules** ל-`{version:0, ref:null, …}` (`scripts/bootstrap-studio-pointer.mjs`, idempotent create-if-absent → לעולם לא דורס publish חי). כך cold-start-client קורא מצביע תקין-ריק (→ born-seed bundled, byte-identical) במקום doc-חסר; ה-Admin-SDK עוקף rules, אז זו הגנה-בעומק, וה-workflow ממקם אותה ראשונה בכל-מקרה (נתיב-seed לא-Admin היה נחסם ע"י ה-lock).

#### `studioConfigSnapshots/{snapshotId}` — blobs immutable מגובבים (sharded)
- כל publish כותב **`vN` חדש** (`v1`,`v2`,…; draft = `draft-<uid>`), לעולם לא מוטציה — rollback חינם + אין torn-read.
- parent-doc: `{ version, nodeCount, shardCount, shards:["…/0","…/1"] }` + subcollection `studioConfigSnapshots/{id}/shards/{n}`, כל shard ≤~500KB serialized nodes (תקרת 1MiB עם headroom). ≤ אלפי-nodes = shard-אחד = read-אחד; 10Ks = כמה shards במקביל, cached-by-id, re-pull רק על version-bump.

> **אין composite index** ל-`studioConfig*` — get/listen לפי doc-id קבוע בלבד (§1.5, Step-52 addition-b). העץ נקרא-לפי-version כ-blob, לעולם לא נשאל ב-query.

### משפחה 2 · Pillar 2 — catalog מחובר ב-10Ks (בעיית-ה-scale היחידה)

ה-domain היחיד שדורש query+pagination+search ב-scale → collection per-doc אמיתי
(המימוש שהובטח ב-`catalog_repository.dart`). מודל ה-Dart `LipskeyCatalogProduct`
**ללא שינוי**; ה-`_firebase` mapper מוסיף שדות רק כשלא-ריקים (round-trip תואם-לאחור,
כמו `orders_firebase toDoc`).

#### `catalogProducts/{sku}` — doc-id = SKU (natural key → upsert idempotent, `productForSku` = get-יחיד)
| שדה | טיפוס | הערה |
|---|---|---|
| `sku, nameHe, nameEn, brand, color` | string | שדות-בסיס (זהים ל-`LipskeyCatalogProduct`). |
| `categoryHe, categoryEn, categoryEmoji` | string | קטגוריה. |
| `tradeId` | string | מקצוע Pillar-2 (חשמלאי/אינסטלטור…). ← index #8. |
| `qtyPack, qtyPallet, page` | int | כמות-אריזה / משטח · עמוד-קטלוג. |
| `dims` | map | מידות. |
| `imageFile(s), specImageFile(s)` | string / array | תמונות (מסלול R2 הקיים, `product_images.dart`). |
| `active` | bool | `true` = חי; **מחיקה = tombstone** `active:false` (paged-query מסנן `active==true`). ← index #10. |
| `tombstone, tombstonedAt, replacedBy` | bool / iso / sku? | soft-delete + הפניה-לחלופה (R1-9); ה-fan-out `onCatalogProductWrite` מנקה `nameTokens`+`catalogTokenFreq` של ה-SKU-המת. |
| `version` | int | per-product; delta-sync (§7). |
| `updatedAt` | string (ISO-8601) | עדכון-אחרון (`updatedBy` uid). ← index #10. |
| `nameTokens` | array&lt;string&gt; | tokens lowercased מ-**`nameHe` בלבד** (server indexer, parity עם ה-fuzzy החי — R1-7); token-search ב-scale (§2, index #11). |
| `catalogShard` | int | bucket ל-shard-fanout listen (נדיר; ברירת-המחדל = paged-query, לא listen). |

> **⚠️ `price` אינו כאן.** המחיר יושב ב-**sub-doc role-scoped** `catalogProducts/{sku}/pricing/{audience}` (R1-6) — read `isManager() || hasRole(audience)`, write `isManager()`. ה-doc-הציבורי world-readable ללא-מחיר, כך שחנות-מתחרה/לקוח-לא-מורשה **לא** קורא מחיר-קבלן. ה-mapper לא ממפה price ל-doc-הראשי; ה-token-index לא כולל price.

#### `catalogTrades/{tradeId}` · `catalogCategories/{catId}` · `catalogTokenFreq/{token}` — metadata + search-support
| collection | שדות | הערה |
|---|---|---|
| `catalogTrades/{tradeId}` | `nameHe, nameEn, emoji, order, active, productCount` | `productCount` aggregate incremental — מונה ללא `count()` יקר. |
| `catalogCategories/{catId}` | `nameHe, emoji, tradeId, order` | metadata ל-browse-לפי-קטגוריה. |
| `catalogTokenFreq/{token}` | `count:int` | token-frequency-map לבחירת "rarest token" ל-`arrayContains` (R1-7); מתוחזק ב-`onCatalogProductWrite` (increment/decrement פר-token). |

### משפחה 3 · Pillar 3 — analytics event-stream + presence

append-only · write-amplification-aware · **owner-read-only**.

#### `analyticsEvents/{autoId}` — doc-id = auto (scatter · בלי hotspot)
| שדה | טיפוס | הערה |
|---|---|---|
| `name` | string | שם-האירוע. ← index #12. |
| `props` | map | payload (יתכן context רגיש — owner-read בלבד). |
| `uid` | string | השחקן. **create חייב `uid == auth.uid`** (בלי spoofing). ← index #13. |
| `role, sessionId` | string | תפקיד + סשן. |
| `at` | string (ISO-8601) | חותם-שרת. ← index #13. |
| `day` | string `"YYYY-MM-DD"` | מפתח-drill-down יומי. ← index #12. |
| `clientTs` | string (ISO-8601) | חותם-client. |

- **rule:** `create` = signed-in + `uid==auth.uid` · `read` = `isManager()` · `update/delete` = `if false` (append-only, כמו `auditLog`).

#### `presence/{uid}` — doc-אחד/משתמש · self-write
| שדה | טיפוס | הערה |
|---|---|---|
| `online` | bool | מחובר. ← index #14. |
| `lastSeen` | string (ISO-8601) | heartbeat אחרון (debounced ≥30s); TTL-sweep מהפך stale `online→false`. ← index #14. |
| `screen, role, sessionId` | string | מסך-נוכחי · תפקיד · סשן. |

- **read:** `isManager()` (או self) — אבל ה-owner קורא **`presenceSummary/current`** (doc-מגולגל-שרת: `{count, byRole, sample:[≤50 uids], updatedAt}`, `read: if isManager(); write: if false`), **לא** listener על כל ה-`presence/*` (R1-3). index #14 משרת את ה-rollup-fn (server-side) ואת ה-drill-down ה-paged של ה-owner. **write:** self בלבד.

#### `analyticsDaily/{day}` · `analyticsCounters/{metric}/shards/{n}` — rollups (Admin-SDK)
| collection | שדות | הערה |
|---|---|---|
| `analyticsDaily/{day}` | `counts:{order_placed:N,…}, uniques:int` | scheduled-fn rollup; owner קורא **doc-אחד/יום** (לא 100K events). read `isManager()`, write `if false`. |
| `analyticsCounters/{metric}/shards/{0..9}` | `count:int` | distributed-counter למטריקות-חמות (increment ל-shard אקראי, סכום ב-rollup). read `isManager()`, write `if false`. |

### תוכנית ה-8 composite indexes (תוספת ל-`firestore.indexes.json`)

נוספו ל-array `"indexes"` (entries 8–15); `"fieldOverrides": []` נשאר ריק (כל
collection שומר את ה-single-field indexes האוטומטיים). שני ה-`ARRAY_CONTAINS`
מעתיקים את הצורה המאומתת של `chatThreads participantUids` (`arrayConfig:"CONTAINS"`
+ שדה-order trailing) — אחרת deploy נכשל ב-`failed-precondition`.

| # | collection | fields | משרת |
|---|---|---|---|
| 8 | `catalogProducts` | `tradeId` ASC, `nameHe` ASC | רשימת-catalog לפי-מקצוע, paginated |
| 9 | `catalogProducts` | `categoryHe` ASC, `nameHe` ASC | browse לפי-קטגוריה, paginated |
| 10 | `catalogProducts` | `active` ASC, `updatedAt` DESC | delta-sync (§7) + "נערך לאחרונה" של ה-owner (addition-a) |
| 11 | `catalogProducts` | `nameTokens` ARRAY_CONTAINS, `nameHe` ASC | token-search ב-scale (§2) → fuzzy re-rank client-side |
| 12 | `analyticsEvents` | `day` ASC, `name` ASC | drill-down יומי לבעלים |
| 13 | `analyticsEvents` | `uid` ASC, `at` DESC | trail per-user (support) |
| 14 | `presence` | `online` ASC, `lastSeen` DESC | "מי מחובר עכשיו" (rollup server-side + drill-down paged) |
| 15 | `customers` | `searchTokens` ARRAY_CONTAINS, `used` DESC | חיפוש-לקוחות ב-scale (**optional**, forward-ready) |

> **`studioConfig*` — אין composite index** (get/listen לפי doc-id קבוע בלבד; העץ blob-נקרא-לפי-version, לא נשאל ב-query). Step-52 addition-b. ולידציה: `firebase deploy --only firestore:indexes --project buildsmart-b0b78 --dry-run`.

## סדר-הפריסה (Step 68 / R2-10 קנוני) — `.github/workflows/firebase-deploy.yml`

ה-indexes האלה הם **תלות-קשיחה** של ה-functions: `onCatalogProductWrite` (token-indexer) ו-server-search שואלים את index #11 (`nameTokens` ARRAY_CONTAINS + `nameHe`), וה-rollups את #12–14. לכן הפריסה **מסודרת** ולא מקבילה:

1. **bootstrap `studioConfig/published`** (`scripts/bootstrap-studio-pointer.mjs`) — **לפני** נעילת-rules.
2. **`--only firestore:rules`**.
3. **`--only firestore:indexes`** = **GATE** (`id: indexes`, ללא `continue-on-error` — ה-IAM "Cloud Datastore Index Admin" ניתן 2026-06-14). כשל כאן **עוצר** את ה-job → functions לא נפרסים.
4. **READY-poll** (Firestore Admin REST `collectionGroups/-/indexes`, ≤10min, fail-loud) — ממתין שכל index יגיע ל-`READY` (לא `CREATING`).
5. **`--only functions`** — מגודר `if: steps.indexes.outcome == 'success'`, ללא `continue-on-error` (fail-loud, Blaze חי).

בלי הסדר הזה: functions חיים **לפני** ה-composite index → ה-query הראשון זורק `FAILED_PRECONDITION`; או rules-lock לפני ה-seed → ה-bootstrap נחסם. הסדר נאכף offline ב-`functions/src/selftest.ts` (`npm run selftest` — 11 checks על ה-YAML) שרץ כ-GATE בזרימת-הפריסה עצמה.
