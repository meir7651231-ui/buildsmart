# BuildSmart Functions — setRole (S1.9) + S8 server logic + S7.2 R2 bridge

Region **`me-west1`** (ת"א — כמו ה-Firestore) לכל הפונקציות; חייב להתאים
ל-`kAuthFunctionsRegion` באפליקציה. Node 20 · TypeScript strict ·
firebase-functions **v2/gen2** (כל הפונקציות — Cloud Run/Eventarc).

| function | סוג | תפקיד |
|---|---|---|
| `setRole` | callable | S1.9 — הקצאת תפקיד כ-custom-claim (admin בלבד) + `auditLog` (הצלחה + דחיית-לא-admin = עקבת privilege-escalation). |
| `reviewRoleRequest` | callable | #6 — אישור/דחיית בקשת-תפקיד לפי **מטריצה היררכית** (worker→contractor · courier→store · store/contractor→manager · admin=any). באישור כותב claim של התפקיד התפעולי (Admin SDK) ומסמן `roleRequests/{uid}` approved + auditLog. המטריצה (`mayReviewRoleRequest`) טהורה + נבדקת ב-selftest. |
| `advanceOrderStage` | callable | S8.1 — קידום הזמנה **צעד אחד** ב-`ORDER_FLOW`, עם אכיפת-תפקיד מה-claims. נתיב-הכתיבה המוסמך. |
| `revertIllegalOrderStageWrite` | trigger (orders/{id} updated) | S8.1 — defense-in-depth: כתיבה ישירה של stage שאינה צעד-קדימה-בודד **מוחזרת לאחור** + auditLog. |
| `computeCredit` | callable | S8.2 — אשראי-קבלן מחושב-שרת (port מדויק של `contractorCredit`) + used/balance/pct מההזמנות החיות. |
| `onOrderStageChanged` | trigger (orders/{id} updated) | S8.3/S6.3 — FCM בעברית על מעבר-stage חוקי, לפי `users/{uid}.fcmToken`. |
| `onChatMessageCreated` | trigger (chatMessages/{id} created) | S8.3/S6.3 — FCM בעברית על הודעת-צ׳אט חדשה למשתתפי-ה-thread. |
| `deleteAccount` | callable | S1.8 — מחיקת-חשבון: מוחק את המסמכים האישיים מפתח-ה-uid (`users/{uid}` + `diag/{uid}`) **וגם** את רשומת-ה-Auth (Admin SDK) + auditLog. callable (gen2) ולא trigger — ל-Auth אין trigger-מחיקה ב-gen2, ו-gen1 דורש App Engine שלא קיים (deploy 403). |
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
- **chat:** ה-uid-ים ב-`chatThreads/{threadId}.participantUids` (ה-auth-truth של
  A14 — לא `participants` שמחזיק שמות-תפקיד) פחות השולח. כותרת
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
npm run selftest     # build + node lib/selftest.js — 65/65 PASS
                     # (לוגיקה טהורה: hash/credit מול probe של Dart VM,
                     #  שרשרת-stages, מטריצת-תפקידים, מטריצת-אישור #6)
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

## bootstrap האדמין הראשון (ביצה-ותרנגולת) — ✅ **בוצע, והכלי נמחק**

`setRole` דורש שלקורא יש claim `admin: true`. ל-Firebase אין UI בקונסולה
ל-custom-claims, ולכן האדמין הראשון חייב להיות מוקצה פעם אחת מחוץ ל-callable,
בסקריפט Admin-SDK.

**זה כבר קרה (2026-07-19):** הבעלים (`meir7651231@gmail.com`) קיבל
`admin: true` + `role: 'manager'`, ומכאן כל תפקיד אחר מוקצה **מתוך האפליקציה**
דרך `setRole` — אין יותר צורך בכלי חיצוני.

⚠️ **הסקריפט וה-workflow שביצעו זאת נמחקו במכוון** (`scripts/bootstrap-admin.mjs`
+ `.github/workflows/bootstrap-admin.yml`). הם היו דלת שמייצרת אדמינים, וכל עוד
היו קיימים כל מי שיכול לדחוף לענף-החי יכול היה להעניק לעצמו שליטה מלאה. הכלי
עצמו תיעד את הדרישה הזו: *"it must not linger as a way to mint admins"*.

**אם אי-פעם יידרש אדמין נוסף** — עדיף להשתמש ב-`setRole` מתוך האפליקציה
(חשבון-אדמין קיים מעניק). רק אם **כל** חשבונות-האדמין אבדו, יש לשחזר את הסקריפט
מהיסטוריית-git לריצה חד-פעמית, **ולמחוק אותו שוב מיד אחרי**.

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

## S1.8 — מחיקת-חשבון צד-שרת (`deleteAccount` — callable)

GDPR right-to-erasure + דרישת-Apple למחיקת-חשבון בתוך-האפליקציה. הקליינט
(`auth_state.dart`, `FirebaseAuthGateway.deleteAccount()`) קורא ל-callable הזה
ואז מבצע `signOut` מקומי. ה-callable מאמת את הקורא (מוחק **רק** את
`request.auth.uid` — אין ארגומנט-uid), מנקה את המסמכים **ממופתחי-ה-uid**, ואז
מוחק את **רשומת-ה-Auth עצמה** דרך ה-Admin SDK (`getAuth().deleteUser` — ללא
דרישת recent-login, בניגוד ל-`user.delete()` של הקליינט):

- `users/{uid}` — הפרופיל (displayName / טלפון / מייל / fcmToken)
- `diag/{uid}` — בדיקת ה-FS_DIAG

מחיקה best-effort לכל doc (מסמך חסר/כושל לא עוצר את השאר) + רשומת `auditLog`
(`action: "account.delete"`).

> **למה callable ולא Auth-onDelete-trigger:** ל-Firebase Auth **אין** trigger-מחיקה
> ב-gen2, וכל ה-codebase כאן gen2. trigger v1/gen1 (`auth.user().onDelete`) דורש
> נתיב-deploy gen1 (App Engine + ה-API `v1/generateUploadUrl`) שלא קיים בפרויקט —
> הוא מחזיר 403 **ועוצר את כל** `firebase deploy --only functions` (כולל ה-gen2).
> callable נשאר gen2, נפרס נקי לצד השאר, ומחזיר תוצאה מאומתת לקליינט.

**טווח:** מסמכים ממופתחי-uid (אישיים, בעלים-יחיד) — `users/{uid}` + `diag/{uid}` —
**נמחקים**. רשומות רב-צדדיות (`orders`, `chatThreads`/`chatMessages`, `customers`)
**נשמרות אך מנוקות**: `purgeMultiPartyReferences` מנתק את ה-uid מהן (best-effort +
paginated) — `orders.contractorUid/storeUid/courierUid` נמחק, `chatMessages.fromUid`
נמחק, `chatThreads.participantUids` עובר `arrayRemove`, `customers.ownerId` נמחק —
כך שהרשומה נשארת לצד-השני אך הקישור האישי של המשתמש שנמחק נעלם. נכתב ל-`auditLog`
(`after.scrubbed` = ספירה per-target).

## TODO (לא בגל הזה)

- אכיפת App Check (`enforceAppCheck: true`) על ה-callables אחרי ש-S0.5 יציב.
