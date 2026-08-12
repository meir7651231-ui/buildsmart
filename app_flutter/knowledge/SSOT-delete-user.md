# SSOT — מחיקת-משתמש מכל-מקום (🗑️ delete-user)

> יעד-הבעלים: כפתור-מחיקה במרכז שמוחק משתמש **מכל המערכות** (Auth + Firestore),
> + מונע רשומות-יתומות בעתיד. **בניין רגיש: refactor של קוד-GDPR + פעולה הרסנית
> על פרודקשן-חי.** בטיחות מעל-הכל.

## נכסים קיימים — למחזר, לא לבנות מחדש
- `functions/src/deleteAccount.ts` — callable GDPR (gen2, self-delete): `purgeMultiPartyReferences` (מנתק uid מ-orders/chatMessages/customers/chatThreads — שומר לצדדים) + `purgeIntelForSubject` (intelEvents/presence/actorStitch) + מחיקת `users`/`diag` + `getAuth().deleteUser(uid)` + audit. **directory מתנקה דרך cascade** של `onUserDocWritten` (directory.ts) על מחיקת users-doc.
- `functions/src/approveUsers.ts` — `mayApproveUsers` (בדיקת-הרשאת-מנהל טהורה) + תבנית onCall gen2.
- `functions/src/common.ts` — `callerRoles`, `isOwnerEmail`, `db`, `REGION`.
- לקוח: `userApproverProvider`/`UserApprover` (role_requests.dart:151-161) — תבנית-provider · `_CustomerActionRow` (manager_dashboard_screen.dart:3469) — מיקום-הכפתור · `confirm_dialog.dart` — דיאלוג-אישור.
- **למה לא טריגר auth.onDelete:** deleteAccount.ts:5-11 מסביר — טריגר gen1 שובר את deploy-ה-gen2. לכן ה-**callable** מוחק-מכל-מקום (וזה משיג את מטרת ג׳: אין יתומים כי המחיקה עוברת דרך הכפתור, לא הקונסולה).

## קבלה

### שרת (functions/)
1. **Refactor `deleteAccount.ts` — אפס-רגרסיה:** לחלץ את גוף-המחיקה ל-`export async function eraseUserCompletely(uid, {actorUid, actorRole}): Promise<{existed, scrubbed, intelPurged}>` (purgeMultiParty + purgeIntel + מחיקת users/diag + `getAuth().deleteUser` + audit). `deleteAccount` הקיים קורא לו עם `request.auth.uid` — **התנהגותו זהה-בייטים** (`erasure_completeness_test` + כל טסט-deleteAccount נשארים ירוקים).
2. **`deleteUser` callable חדש** (gen2 onCall, `region: REGION`): קלט `{uid: string}`.
   - **הרשאה:** `request.auth` קיים + הקורא מנהל/admin (`mayApproveUsers(callerRoles(token))` או `mayDeleteUsers` מקביל). אחרת `HttpsError('permission-denied')` + audit-denial.
   - **שומרים (airtight):** `uid` ריק → `invalid-argument`; היעד הוא הבעלים (`getAuth().getUser(uid)` → `isOwnerEmail(email)`) → `permission-denied` ("אי-אפשר למחוק את הבעלים"); `uid === request.auth.uid` → `failed-precondition` ("השתמש ב-deleteAccount לעצמך").
   - קורא `eraseUserCompletely(uid, …)` + audit (`action:'user.delete'`, actorUid=caller, target=`users/{uid}`). מחזיר `{ok:true}`.
3. לייצא `deleteUser` ב-`functions/src/index.ts`.

### לקוח (app_flutter/)
4. **`role_requests.dart`:** `typedef UserDeleter = Future<void> Function(String uid);` + `userDeleterProvider` (מראה `userApproverProvider`): null כשאין backend/gateway; אחרת עוטף את ה-callable `deleteUser` דרך ה-gateway.
5. **`manager_dashboard_screen.dart` — `_CustomerActionRow`:** כפתור **🗑️ מחק** (סגנון הרסני/אדום), **רק כש-`view.uid.isNotEmpty` וגם השורה אינה הבעלים** (`!isOwnerEmail(view.customer.email)`). לחיצה → `showConfirmDialog` ("למחוק לצמיתות את {שם} מכל המערכות (חשבון + נתונים)? בלתי-הפיך.", כפתור אדום "מחק") → אישור → `ref.read(userDeleterProvider)?.call(view.uid)` → toast "המשתמש נמחק" / toast-שגיאה כן; `_busy` guard. השורה נעלמת דרך הזרם-החי.

## בטיחות (בלתי-ניתן-למשא-ומתן)
- השרת **אוכף** מנהל/admin + שומר-בעלים + no-self (לעולם לא לסמוך על הלקוח).
- הלקוח: דיאלוג-אישור + הסתרת-הכפתור-לבעלים (הגנה-בעומק).
- בלתי-הפיך — הדיאלוג אומר זאת מפורשות.
- **אסור לשבור את deleteAccount** (GDPR) — הטסטים שלו נשארים ירוקים.

## אימות (השער)
- `app_flutter`: `flutter analyze` 0 · `flutter test` (חדש+קיים ירוק — predicate ל-`mayDeleteUsers` + שומר-בעלים · כפתור מוסתר-לבעלים/מוצג-לאחר · `userDeleterProvider` OFF-null) · `central-verify.sh`.
- `functions`: `cd functions && npm run build` (tsc נקי) + טסטי-functions אם יש. **חובה** — ה-callable חייב להתקמפל.
- לעדכן WIRING.md + visual_log.md + mutation_log.md.

## 🔴 דחיפה + פריסה
functions נפרסים אוטומטית (firebase-deploy.yml על push לענף, אם `functions/**` ב-paths) + web נפרס אוטומטית. **לא לדחוף עד "תדחוף"** — לאמת gate + functions-build קודם.
