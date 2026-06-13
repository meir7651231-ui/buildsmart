# SPEC — A4-A6 (מחודש): server-swap — BoardSession מ‑Firebase Auth

> **מסגור מחדש** אחרי סקירת‑הלוחות (576036c): הלוחות כבר **מסונכרנים לפי זהות** דרך `BoardSession`/`boardAuthProvider` — אך מול **5 חשבונות‑seed** (`data/board_accounts_local.dart`), לא מול Firebase Auth. הקוד עצמו מסומן: "SERVER-SWAP: Firebase Auth will replace the seed list".
> לכן A4‑A6 = **להחליף את מקור‑הזהות** + לחתום uid אמיתי + scoped reads. מנצל A7 (role→uid), A12 (setRole/claims), A2 (currentUid), A1 (scope), G2 (rules).

> ✅ **בוצע — הצי דחף 208f3a9 (13/6):** A4 (claim‑on‑first‑advance + `storeUid`/`courierUid` + orderParticipants) · A5 (scoped listener + שיתוף‑בריכה + indexes) · A6 (דשבורד חנות/שליח = בריכה ∪ שלי) · **A4' (50465b1 — `BoardSession` מ‑Firebase Auth: uid+role‑claim במקום seed; +255 בדיקות; SW1/SW2/SW3)** · rules +100 (claim/no‑steal + manager override) · 27/27 emulator + orders_uid_a4_a6_test 22 + suite +2176 · analyze 0 · build web. **מגודר ב‑`useFirebaseBackend`** (דורמנטי בברירת‑מחדל עד F1+דגל). **נותר ל‑uid‑core:** F1 (שלב 0 למטה) · צ׳אט (A8/A9 — seam+rules ✅ ב‑fec79e2, חסר אכלוס `participantUids` בשליחה דרך A7) · A13 קליינט · A14 seed.

## שלב 0 — F1 (תנאי‑סף! ראש‑סדר): חיבור Firebase לאפליקציית‑הטלפון
**תיקון‑דיוק (אומת 13/6 בקוד @208f3a9):** הטלפון **לא קורס** — `main.dart:51‑59` עוטף את האתחול ב‑try/catch+timeout, אז ה‑throw של `firebase_options` (web‑only) **נתפס בשקט** והאפליקציה נופלת ל‑repos מקומיים (דמו). כלומר גרסת‑הטלפון **רצה אך לא מדברת עם השרת** עד שמוסיפים קונפיג‑נייטיב. אותו שרת‑web קיים וחי (`firebase.json`: hosting+firestore+functions) — חסר רק "כרטיס‑הביקור" שלו לטלפון. חובה לפני שסדרת‑A רצה אמיתית על מכשיר.
- **[את] בקונסול:** לרשום iOS + Android ב‑Firebase (פרויקט `buildsmart-b0b78`) → להוריד `google-services.json` (אנדרואיד) + `GoogleService-Info.plist` (iOS).
- **[agent]:** `flutterfire configure` / להוסיף אופציות‑נייטיב ל‑`firebase_options.dart` (להסיר את ה‑throw) + App Check נייטיב.
- **DoD:** האפליקציה על מכשיר/אמולטור **מתחברת לשרת** (לא נופלת לדמו), Firebase מאותחל, הדגל ON עובד נייטיב.

## העיקרון
נרשם אמיתי (Firebase, B8) → מקבל role‑claim (A12) → `BoardSession` נבנה **מה‑Firebase user** (uid+role) במקום מ‑seed → כל הגידור והסינון הקיימים בלוחות עובדים מיד לכל נרשם.

## A4' — ✅ בוצע (50465b1, +255 בדיקות) · החלפת מקור‑הזהות · `state/board_auth.dart` / `boardAuthProvider`
- כש‑`useFirebaseBackend` ON: לבנות `BoardSession{uid, role, displayName, phone}` מ‑Firebase — `uid`=auth.uid · `role`=claims (`roleProvider`/A12) · פרטים מ‑`users/{uid}`.
- flag OFF / דמו: נתיב ה‑seed כמו שהוא — **אפס רגרסיה**.
- DoD: נרשם אמיתי עם role נכנס ללוח שלו.

## A4 — uid על הזמנות · `sys_orders.dart` + `orders_firebase.toDoc`
- במקום `session.username` (`stampCourier`/`storeAdvance` claim) → לחתום **uid** (flag ON): `storeUid`/`courierUid`. `contractorUid` כבר (A3).
- `orderParticipants=[contractorUid, storeUid?, courierUid?]`.

## A5 — scoped Firestore listener + pool · `orders_local.dart` + `firestore.indexes.json`
- non-manager: `arrayContains uid` (A1 scope) + listener‑בריכה (new/ready לא‑תפוסים). manager: full.
- אינדקסים: participants+ts · pool (stage+claimfield).
- (הסינון בצד‑לקוח כבר קיים — זה מבטיח שהשרת **שולח רק** את נתוני‑המשתמש: אבטחה+scale.)

## A6 — דשבורדים · store/courier
- כבר מסננים לפי `session` → לוודא הסתמכות על `session.uid` (הזהות המוחלפת). שינוי מינימלי.

## rules + pool + tests · `firestore.rules`
- בריכה (store→`new`/storeUid ריק · courier→`ready`/courierUid ריק) + ownership reads (G2) + עדכון emulator tests.

## ⚠️ יישור שמות
`contractorUid`/`storeUid`/`courierUid` **תואמים בדיוק** ל‑G2 (5de11d8).

## אומדן
A4' → A4 → A5 ; A6+rules במקביל. **~2‑3 ימים** — קטן מהמקור, כי הסינון כבר בנוי.
