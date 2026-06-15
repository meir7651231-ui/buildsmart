# BuildSmart Functions — setRole (S1.9) + S8 server logic + S7.2 R2 bridge

Region **`me-west1`** (ת"א — כמו ה-Firestore) לכל הפונקציות; חייב להתאים
ל-`kAuthFunctionsRegion` באפליקציה. Node 20 · TypeScript strict ·
firebase-functions **v2** (חריג יחיד: `onUserDeleted` הוא trigger **v1** —
ל-Auth אין hook מחיקה ב-v2; v1 הוא חלק מאותה חבילה, ללא dependency חדש).

| function | סוג | תפקיד |
|---|---|---|
| `setRole` | callable | S1.9 — הקצאת תפקיד כ-custom-claim (admin בלבד). **ללא שינוי מה-skeleton.** |
| `advanceOrderStage` | callable | S8.1 — קידום הזמנה **צעד אחד** ב-`ORDER_FLOW`, עם אכיפת-תפקיד מה-claims. נתיב-הכתיבה המוסמך. |
| `revertIllegalOrderStageWrite` | trigger (orders/{id} updated) | S8.1 — defense-in-depth: כתיבה ישירה של stage שאינה צעד-קדימה-בודד **מוחזרת לאחור** + auditLog. |
| `computeCredit` | callable | S8.2 — אשראי-קבלן מחושב-שרת (port מדויק של `contractorCredit`) + used/balance/pct מההזמנות החיות. |
| `onOrderStageChanged` | trigger (orders/{id} updated) | S8.3/S6.3 — FCM בעברית על מעבר-stage חוקי, לפי `users/{uid}.fcmToken`. |
| `onChatMessageCreated` | trigger (chatMessages/{id} created) | S8.3/S6.3 — FCM בעברית על הודעת-צ׳אט חדשה למשתתפי-ה-thread. |
| `onUserDeleted` | trigger (auth user deleted) | S1.8 — ניקוי-צד-שרת במחיקת-חשבון: מוחק את המסמכים האישיים מפתח-ה-uid (`users/{uid}` + `diag/{uid}`) + auditLog. v1 (ל-Auth אין trigger מחיקה ב-v2). |
| `getUploadUrl` | callable | S7.2 — presigned-PUT URL ל-R2 (aws-sdk v3). creds ב-Secret Manager/env בלבד. |
| (`auditLog`) | collection | S8.4 — כל הנתיבים הרגישים לעיל כותבים רשומות append-only. |

---

## S8.1 — אכיפת מעברי-stage: שתי שכבות (שתיהן נדרשות)

**השרשרת** (`kManagerOrderFlow`, verbatim מהאפליקציה):
`new → preparing → ready → pickup → transit → delivered`

**מי מורשה למה** (מקור: ה-**קוד** של `app_flutter/lib/state/sys_orders.dart` —
`storeAdvance` יורה על new/preparing/ready, `courierAdvance` על pickup/transit):

| מעבר | תפקיד |
|---|---|
| `new→preparing`, `preparing→ready` | `store` |
| `ready→pickup` (המסירה לשליח — "מסור לשליח") | `store` |
| `pickup→transit`, `transit→delivered` | `courier` |
| כל צעד-בודד | `manager` / claim `admin` ("manager can nudge any single step") |

1. **Callable `advanceOrderStage({orderId})`** — ל-Firestore-triggers **אין
   auth context**, ולכן בדיקת-תפקיד אפשרית רק במקום שבו ה-ID-token קיים:
   callable. מקדם בדיוק צעד אחד, בטרנזקציה, חותם `stageBy`/`stageRole`/`stageAt`,
   וכותב auditLog גם על הצלחה וגם על **דחייה** (permission-denied /
   failed-precondition). `delivered` הוא סופי (mirror ל-no-op של ה-client).
2. **Trigger `revertIllegalOrderStageWrite`** — רשת-ביטחון לכתיבות ישירות:
   שינוי-stage שאינו צעד-קדימה-בודד מוחזר ל-stage הקודם (בטרנזקציה, רק אם לא
   נדרס בינתיים) ונרשם ב-auditLog. loop-guard: כתיבת-ה-revert חותמת
   `stageGuard{revertedAt,from,to}`; עדכון שבו `stageGuard` השתנה = revert →
   מדולג. אכיפת-תפקיד על כתיבות ישירות **חוקיות** נשארת אצל S5 rules (צי-אח).

**השלכות ידועות (מתועד, מקובל):** ה-"god-step" של המנהל ל-stage שרירותי
ו-`resetToSeed` (כלי-דמו) ככתיבות ישירות אחורה/בקפיצה — יוחזרו ע"י ה-trigger.
צעדים בודדים עוברים דרך ה-callable; איפוס-דמו = כלי-פיתוח מקומי.

## S8.2 — `computeCredit({name?})`

- **תקרה דטרמיניסטית** — port מדויק של `contractorCredit`
  (`app_flutter/lib/logic/manager_dashboard.dart`; שורת-ה-SSOT הפנתה ל-
  `orders_engine.dart` אך הפונקציה חיה ב-`manager_dashboard.dart`): hash של
  שם-הקבלן לרצועת 30,000–120,000 ₪, עיגול-מטה ל-₪100. ה-hash = אלגוריתם
  `String.hashCode` של **Dart VM** (iOS/Android), משוחזר bit-for-bit ואומת מול
  `dart run` (טבלת-probe ב-`src/creditCore.ts`, נאכפת ב-selftest).
  ⚠️ dart2js (web) מניב hash שונה — Dart לא מבטיח יציבות חוצת-פלטפורמות;
  **הערך השרתי הוא הקנוני.**
- **נגזרות חיות** (verbatim מ-`manager_dashboard_screen.dart`):
  `used` = Σ`sum` של הזמנות הקבלן (`orders.where(contractorId==name)`) ·
  `balance = (limit-used).clamp(0, limit)` ·
  `pct = limit==0?0:round(used/limit*100).clamp(0,100)`.
- **הרשאה** (mirror ל-S5.4): `manager`/`admin` — כל שם; כל תפקיד אחר — רק
  השם-העצמי (`users/{uid}.displayName`). מחזיר
  `{ok,name,creditLimit,used,balance,pct,orderCount}` + auditLog.

## S8.3 — FCM push (עברית)

- **stage:** רק מעבר **חוקי** (צעד-בודד; reverts/קפיצות לא שולחים push).
  נמענים: `contractorId`/`storeId`/`courierId` (uids לפי הסכמה; מזהי-לגאסי
  שאין להם doc ב-`users` מדולגים בשקט) **פחות המקדם** (`stageBy` כשה-callable
  חתם). payload: `עדכון הזמנה` / `הזמנה BS-1042 · מוכן לאיסוף` — תוויות-stage
  verbatim מ-`kOrderStageLabel` (`supplier_data.dart`).
- **chat:** משתתפי `chatThreads/{threadId}` פחות השולח. כותרת
  `הודעה חדשה מ־{displayName|תואר-פרסונה}` + preview (80 תווים).
- tokens מ-`users/{uid}.fcmToken` (S6.1); token מת
  (`registration-token-not-registered`) נמחק מה-doc.

## S8.4 — `auditLog` (append-only)

```
auditLog/{autoId} {
  at: serverTimestamp · action · source · actorUid · actorRole ·
  target ("orders/BS-1042" / "customers/<name>" / "r2://bucket/key") ·
  before · after · ok (false = נדחה/הוחזר) · reason?
}
```
נכתב מ: advance (גם דחיות) · revert · computeCredit · getUploadUrl.
ה-functions כותבים עם Admin SDK (עוקף rules); **S5 rules חייבים לחסום כל
read/write של clients על `auditLog`** (צי-rules — לא בקוד הזה).

## S7.2 — `getUploadUrl({kind, contentType, fileName?})`

- `kind` ∈ `pod` | `before-after` · `contentType` ∈ image/jpeg·png·webp·heic·heif.
- המפתח **בבעלות-השרת**: `{kind}/{uid}/{ts}-{sanitized}` — ה-client לעולם לא
  בוחר path (אין traversal/דריסה חוצת-משתמשים). תוקף 10 דקות. מחזיר
  `{url,key,method:"PUT",headers,expiresIn}`; ההעלאה: `PUT url` עם אותו
  `Content-Type`.
- aws-sdk v3 (`@aws-sdk/client-s3` + `s3-request-presigner`) מול
  `https://<account>.r2.cloudflarestorage.com` (region `auto`, path-style).

### קונפיגורציית R2 — אפס creds בקוד

> `firebase functions:config:set r2.*` היה מנגנון **v1** (Runtime Config —
> הוצא משירות). הקוד הזה הוא **v2** ומשתמש ב-params/Secret Manager:

```bash
# סודות (Secret Manager; נדרש Blaze):
firebase functions:secrets:set R2_ACCESS_KEY_ID
firebase functions:secrets:set R2_SECRET_ACCESS_KEY

# פרמטרים לא-סודיים — functions/.env.buildsmart-b0b78 (לא ב-git):
#   R2_ACCOUNT_ID=<cloudflare account id>
#   R2_BUCKET=<bucket>
```
ללא קונפיגורציה הפונקציה נכשלת ב-`failed-precondition` עם הודעה ברורה —
לעולם לא עם ברירת-מחדל מובנית.

---

## פיתוח ובדיקה

```bash
cd functions
npm install
npx tsc --noEmit     # typecheck (חובה ירוק)
npm run selftest     # build + node lib/selftest.js — 53/53 PASS
                     # (לוגיקה טהורה: hash/credit מול probe של Dart VM,
                     #  שרשרת-stages, מטריצת-תפקידים)
```

`src/` מודולרי: `index.ts` (entrypoint — setRole + re-exports) · `common.ts`
(REGION + lazy db + callerRoles) · `orderFlow.ts`/`creditCore.ts` (דומיין טהור,
ללא Firebase) · `orders.ts` · `credit.ts` · `push.ts` · `r2.ts` · `audit.ts` ·
`selftest.ts` (לא מיוצא — לא נפרס). מודולים לעולם לא פותרים שירותי-Admin
ב-module-scope (ה-imports נטענים לפני `initializeApp()` של index.ts).

## פריסה (console/CI — הסנדבוקס חסום ל-Firebase)

```bash
cd functions
npm install
npm run build                       # tsc → lib/
firebase deploy --only functions    # פרויקט: buildsmart-b0b78 · region me-west1
```
> `firebase.json` בשורש מכיל כרגע hosting בלבד. לפני ה-deploy הראשון הוסיפו:
> ```json
> "functions": { "source": "functions" }
> ```
> ⚠️ Cloud Functions דורש **Blaze plan** (הפרויקט כרגע Spark) — גם ל-Secret
> Manager וגם ל-FCM/Eventarc triggers.
> ⚠️ Firestore-triggers (v2/Eventarc) חייבים region תואם ל-database —
> `me-west1` (כבר כך בקוד).
> הערה: ה-root `.gitignore` מתעלם מכל `package.json` (כלל-לגאסי);
> `functions/.gitignore` מחזיר אותם (`!package.json`/`!package-lock.json`) כדי
> ש-CI/deploy יראו את המניפסט.

## bootstrap האדמין הראשון (ביצה-ותרנגולת)

`setRole` דורש שלקורא יש claim `admin: true` — שמוקצה פעם אחת מחוץ ל-callable,
בסקריפט Admin-SDK חד-פעמי (Cloud Shell / מכונה עם service-account):
```js
// node bootstrap-admin.js <uid>
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
initializeApp();
getAuth().setCustomUserClaims(process.argv[2], { admin: true })
  .then(() => console.log("admin claim set"));
```

## קריאה מהאפליקציה

- `AuthStateNotifier.assignRole({uid, role})` → `httpsCallable('setRole')`.
  המשתמש-היעד מקבל את ה-claim ברענון-token הבא (≤שעה) או בהתחברות הבאה;
  אפשר לכפות עם `getIdTokenResult(true)`.
- קידום-הזמנה צד-שרת: `httpsCallable('advanceOrderStage')({orderId})`
  (region me-west1) — ה-repo/engine ימשיכו לכתוב אופטימית ל-cache; ה-callable
  הוא נתיב-האמת כשה-rules ינעלו כתיבת-stage ישירה.
- אשראי: `httpsCallable('computeCredit')({name?})`.
- העלאת-תמונה: `httpsCallable('getUploadUrl')({kind, contentType, fileName?})`
  → `PUT` של ה-bytes ל-`url` עם ה-`Content-Type` שאושר.

## S1.8 — ניקוי-צד-שרת במחיקת-חשבון (`onUserDeleted`)

GDPR right-to-erasure + דרישת-Apple למחיקת-חשבון בתוך-האפליקציה. הקליינט
(`auth_state.dart`, `deleteAccount()`) קורא ל-`user.delete()` של Firebase Auth —
זה מוחק **רק** את רשומת-ה-Auth ומשאיר את עקבות-ה-Firestore יתומים. ה-trigger
הזה יורה על **כל** מחיקת-Auth (in-app / console / Admin-SDK) ומנקה את המסמכים
**ממופתחי-ה-uid** של המשתמש:

- `users/{uid}` — הפרופיל (displayName / טלפון / מייל / fcmToken)
- `diag/{uid}` — בדיקת ה-FS_DIAG

מחיקה best-effort לכל doc (מסמך חסר/כושל לא עוצר את השאר) + רשומת `auditLog`
(`action: "account.delete"`).

**טווח מכוון:** רק מסמכים ממופתחי-uid (אישיים, בעלים-יחיד) נמחקים. רשומות
רב-צדדיות (`orders`, `chatThreads`/`chatMessages`, `customers`, `projects`,
`tasks`) **נשמרות** — כל אחת שייכת לעסקה/שיחה שמשתמשים אחרים עדיין רואים, ומחיקתה
תשבש את נתוני-הצד-השני. אנונימיזציה של ה-uid ממסמכים משותפים = משימה נפרדת וכבדה
(follow-up — ראה `app_flutter/WIRING.md`), לא בגל הזה.

## TODO (לא בגל הזה)

- אכיפת App Check (`enforceAppCheck: true`) על ה-callables אחרי ש-S0.5 יציב.
- רישום אודיט גם ל-`setRole` (לא נגעתי — ה-skeleton קפוא בהוראה).
- אנונימיזציה של uid ממסמכים רב-צדדיים במחיקת-חשבון (מעבר ל-`users`/`diag`).
