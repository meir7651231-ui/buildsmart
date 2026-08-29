# Offline/Sync — BuildSmart (S9)

> מסמך-העדות של S9 (`SPEC-server-connect-MICRO` §S9): אימות-קוד של
> ה-offline-persistence (S9.1), התור-המפורש ל-batch-order (S9.2), ומדיניות
> ה-conflict-resolution (S9.3). משלים את `firestore-schema.md` (S2.1).
> ⚠️ אימות-מכשיר חי (airplane-mode) אינו אפשרי בסביבה הזו (אין רשת/Firebase) —
> אותה הסתייגות כמו S4.5; הקוד מקבע את המנגנון, האימות-החי רץ אחרי deploy.

---

## S9.1 — אימות Firestore offline-persistence (שרשרת-הקוד המלאה)

**הטענה:** כל כתיבה-מנוהלת (guarded) בדפוס-ה-cache נכנסת לתור-האופליין
ה-מובנה של Firestore, וכל קריאה עובדת אופליין. אומתה חוליה-חוליה:

1. **ההפעלה (S0.4, `lib/main.dart`):** מיד אחרי `Firebase.initializeApp` —
   `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);`
   חוזה-ה-`Settings` דורש שזה יקרה **לפני כל שימוש אחר** — מתקיים, כי:
2. **אף נגיעה מוקדמת ב-Firestore אינה אפשרית:** `FirestoreCollectionSource`
   (S2.2) פותר `FirebaseFirestore.instance` **בעצלתיים** (`get _db`) — לעולם לא
   ב-constructor; ה-repos נבנים ע"י providers שנקראים רק אחרי `runApp`.
3. **סמנטיקת-פלטפורמה** (אומת במקור-החבילות — cloud_firestore 6.5.0 /
   cloud_firestore_web 5.5.0):
   - **Android/iOS:** persistence דיסקית של ה-SDK — cache + תור-כתיבות-ממתינות
     שורדים restart של האפליקציה.
   - **Web:** ה-setter של `settings` ממפה `persistenceEnabled: true` ל-
     `persistentLocalCache` (IndexedDB, single-tab manager כברירת-מחדל). בלי
     השורה הזו web היה `memoryLocalCache` — **אפס אופליין**. כלומר שורת-S0.4
     היא בדיוק מה שמדליק אופליין ב-web.
4. **אילו כתיבות מכוסות — כולן.** כל כתיבה-מרוחקת באפליקציה עוברת דרך
   `FirestoreCachedRepo.guardWrite` → `RemoteCollectionSource.set/delete` →
   `doc(id).set(data, merge:true)` / `delete()` — שה-SDK מתייק אופליין ומסנכרן
   בחזרת-רשת. המנייה לפי repo:
   | repo | הכתיבות המנוהלות |
   |---|---|
   | `orders_firebase` | `placeOrder`/`advance`/`setStage` (upsert) · `resetToSeed` (replaceAll) · זריעת-backend (pushCacheToRemote) |
   | `chat_firebase` | `send` (message + עדכון-head lastMsg/ts) · זריעה |
   | `customers_firebase` | upserts/זריעה |
   | `stock_firebase` | `move` (upsert) · זריעה |
   | `site_firebase` | `submitForReview`/`approve`/`reject` (tasks) · `toggleStage` (upsert/removeById) · זריעה |
   | `finance_firebase` | `decide`/`addPenalty`/`setPaymentTerm` · זריעה |
5. **קריאות אופליין:** הקריאות-הסינכרוניות מוגשות מה-cache-בזיכרון (נולד-מ-seed,
   לעולם לא ריק), וה-`snapshots()` ניזון מה-cache-המקומי של ה-SDK גם בלי רשת —
   האפליקציה קריאה-במלואה אופליין.
6. **ה-UI לעולם לא נחסם/נשבר אופליין:** `guardWrite` בולע+רושם; מה שהמשתמש
   רואה הוא ה-cache האופטימי, וה-sync משלים ברקע.

**מסקנה (DoD S9.1):** "עובד-אופליין" מובטח-בקוד לכל המסלולים המנוהלים;
prefs (`bs.orders.v1` וכו') נשאר עותק write-behind בלבד — מקור-ההמשכיות תחת
Firebase הוא ה-persistence של Firestore עצמו (כפי שתועד ב-#server-S4).

---

## S9.2 — התור המפורש ל-batch-order (`lib/logic/offline_order_queue.dart`)

**זרימת-ה-batch-order:** checkout (`store_screen.dart` `_CheckoutButton`) →
`ordersEngineProvider.notifier.placeOrder(...)` → (bound) ports-ה-verbatim של
`FirebaseOrdersRepository` → upsert אופטימי + כתיבת-רקע — שכבר מכוסה נטיבית
(S9.1). **השכבה המפורשת היא belt-and-braces מנדטורית-SSOT**, ומוסיפה מה
שהתור-הנטיבי לא יכול:

- **הקצאת-id בזמן-replay:** intent בתור **לא נושא id**; ה-`BS-####` מוקצה ע"י
  ה-repository בעת-ה-replay, מעל ה-cache שאחרי-החיבור-מחדש. התור-הנטיבי משחזר
  doc-id שנבחר אופליין — שני מכשירים אופליין יכולים לבחור `BS-1043` ולדרוס זה
  את זה בשקט (LWW ברמת-doc). התור-המפורש סוגר את נתיב-ההתנגשות הזה.
- **שקיפות:** `pending()` חושף את הממתינים (badge "ממתין לסנכרון" עתידי).
- **replay דרך ה-seam:** `drainQueue()` משחזר דרך `ordersRepositoryProvider` —
  הזמנה-משוחזרת עוברת בדיוק את מסלול-הזמנה-חיה (ports verbatim, ולידציית-S8
  עתידית כלולה).

**מנגנון:** `connectivityProbeProvider` (seam של `bool Function()`, ברירת-מחדל
**"assume online"** → השכבה אינרטית בפרודקשן עד שיחווט probe אמיתי; אין
connectivity_plus — אילוץ אפס-deps) · `maybeEnqueue` סינכרוני (ה-checkout
סינכרוני) עם persist-רקע מנוהל · מפתח-persist מגורסם `bs.offline-orders.v1` ·
`drainQueue` משוחזר FIFO ונקרא מ-init של `ordersEngineProvider` (app start) —
ה-diff היחיד ב-`orders_engine.dart`. **כל פעולות-התור מסודרות בשרשרת-futures
אחת** (שני enqueues מהירים סביב ה-`getInstance` הקר מתהפכים בלעדיה; enqueue
מול drain היה יכול להחיות state-שנוקז) · crash-safe: השארית-המתכווצת נשמרת
אחרי **כל** replay → אין double-place · payload פגום נזרק+נרשם, לעולם לא מפיל.

**לגל-המשך (מחוץ להיקף S9):** חיווט probe אמיתי (metadata `isFromCache` /
listener פלטפורמה) + קריאת `maybeEnqueue` בכפתור-ה-checkout (מסך — לא בהיקף) +
טריגר-drain בחזרת-רשת.

---

## S9.3 — מדיניות conflict-resolution

**המנגנון:** Firestore = **last-write-wins פר-שדה** בשרת; בצד-הלקוח, snapshot
**מחליף את ה-cache כולו** (אין merge) → כל המכשירים מתכנסים לאמת-השרת,
וכתיבה-שהפסידה לעולם לא קמה-לתחייה. מקובע ברגרסיה החדשה
(`firestore_cached_repo_test.dart` — "S9.3 — a post-write snapshot RECONCILES
the optimistic cache").

| דומיין | מדיניות | למה זה בסדר |
|---|---|---|
| orders — stage | LWW | המעבר מוולד-שרת ב-S8.1 (`validateStageTransition`) — מעבר-אופליין-לא-חוקי נדחה, וה-snapshot מחזיר את הלקוח לאמת. ה-doc עצמו לעולם לא נמחק ממרוץ-stages → אין-אובדן. |
| orders — יצירה | LWW על doc-id | נתיב-ההתנגשות היחיד שתועד (BS-#### שנבחר אופליין ×2 מכשירים). מיטיגציה: התור-המפורש (S9.2) מקצה id ב-replay; הקצאת-id-שרת היא הסגירה הסופית (S8). |
| chat — הודעות | append-only | ids ייחודיים (`m-<micros>-<role>`) → אין-קונפליקטים מבנייה. |
| chat — thread head | LWW | דה-נורמליזציית `lastMsg`/`ts`; הגרוע-ביותר = preview רגעית-מיושנת, מתרפא בהודעה הבאה. |
| stock — `move` | LWW | היפוך-מיקום — המזיז-האחרון צודק; `qty` לא משתנה ב-move. |
| customers / finance | LWW | כתיבות-manager בלבד, concurrency נמוכה; `computeCredit` עובר לשרת ב-S8.2. |

**DoD S9.3 "אין-אובדן":** אף כתיבה לא נזרקת-בשקט בצד-לקוח (נכנסת לתור-נטיבי או
נרשמת ב-log); קונפליקטים מתכנסים דטרמיניסטית לאמת-השרת; דומיינים append-only
לא מאבדים דבר; נתיב-התנגשות-ה-id הוא הסיכון-השיורי המתועד + המיטיגציה שלו.
