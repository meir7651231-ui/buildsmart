# BuildSmart Functions — `setRole` (S1.9)

callable יחיד שמקצה **תפקיד** למשתמש כ-custom-claim (`role` בודד או `roles[]` לרב-תפקיד).
זה המקור היחיד לכתיבת-תפקיד — לא Firestore, לא client. ה-client קורא דרך
`getIdTokenResult` (`lib/state/auth_state.dart` → `roleProvider`), ו-S5 Rules אוכפים בשרת.

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
> ⚠️ Cloud Functions דורש **Blaze plan** (הפרויקט כרגע Spark).
> ה-region (`me-west1`, ת"א — כמו ה-Firestore) חייב להתאים ל-`kAuthFunctionsRegion` באפליקציה.

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
`AuthStateNotifier.assignRole({uid, role})` → `httpsCallable('setRole')`
(משטח-מנהל עתידי: 👔 מנהל המערכת → ניהול). המשתמש-היעד מקבל את ה-claim
ברענון-token הבא (≤שעה) או בהתחברות הבאה; אפשר לכפות עם `getIdTokenResult(true)`.

## TODO (לא S1)
- מחיקת מסמכי-משתמש ב-Firestore עם מחיקת-חשבון (S1.8 מוחק את ה-Auth-user
  ומנקה data מקומי; wipe-צד-שרת = function/extension נפרד, לפני launch).
- S8: validateStageTransition · computeCredit · FCM triggers.
