# SPEC-A4-A6 — בעלות-הזמנה multi-user (claim-on-first-advance + בריכה משותפת)

> מקור: הוראת-בעלים (2026-06-13). מודל: **claim-on-first-advance + shared pool**. נכתב מהמודל שנמסר (קובץ זה לא היה קיים — נוצר כ-SSOT). ממשיך ישירות מ-A3 (`contractorUid`) + Phase-G (rules/indexes forward-ready).

## המודל
- **בריכה משותפת (pool):** הזמנה שטרם נתבעה (`storeUid==''` / `courierUid==''`) ובשלב הרלוונטי — **גלויה לכל** החנויות/השליחים בתפקיד. כל אחד יכול לתבוע.
- **claim-on-first-advance:** ה**ראשון** שחנות/שליח **מקדם** (advance/accept) הזמנה מהבריכה — **תובע** אותה: `storeUid`/`courierUid = ה-uid שלו`. מרגע זה היא יוצאת מהבריכה ונראית רק לו (+ מנהל).
- **no-steal:** אי-אפשר לתבוע הזמנה שכבר נתבעה ע"י אחר. מנהל יכול לשייך-מחדש (override).

## A4 — שדות + claim (כתיבה)
- `Order.storeUid` · `Order.courierUid` (אדיטיביים, default `''`, כמו `contractorUid`): ctor/copyWith/toJson/fromJson + `orders_firebase` toDoc(guarded)+fromDoc.
- ב-`sys_orders` storeAdvance/courierAdvance (ובנתיב engine/repo advance): **אם `storeUid==''`** → set `storeUid = actingUid` (claim). זהה לשליח. אם כבר מלא ושונה מ-actingUid → אסור (no-op/דחייה). actingUid = `currentUidProvider` של הצד הפועל.

## A5 — scope (ממוקד, מאחורי דגל)
- דגל `kUidScopedQueries` (`backend.dart`, default false). **OFF = התנהגות היום בדיוק (אפס רגרסיה).**
- כש-ON + uid + role:
  - contractor → `contractorUid==uid`
  - store → הבריכה (`storeUid=='' && stage∈store-stages`) ∪ שלי (`storeUid==uid`)
  - courier → אנלוגי עם `courierUid`
  - manager/admin → ללא scope (הכל)
- ממומש דרך scope של A1 (`FirestoreCollectionSource(scope:)`). הבריכה+שלי = או שתי-שאילתות או סינון-קליינט מעל listen רחב-יותר (פר-מימוש; לא לשבור OFF).

## A6 — סינון-דשבורד
- `store_dashboard_screen` / `courier_dashboard_screen`: כש-flag ON + uid — מציגים רק בריכה∪שלי (במקום/בנוסף לקיבוץ-לפי-שלב). OFF = היום.

## Rules (הרחבת Phase-G · אכיפת-claim) — עם emulator tests
- orders create/update: store יכול לקבוע `storeUid` **רק** כש-`resource.data.storeUid` ריק/לא-קיים **או** `== request.auth.uid` (no-steal); manager — כל ערך. אנלוגי ל-courier.
- emulator tests חדשים (`rules_test/orders.test.js`): (1) store תובע unclaimed → מותר · (2) store "גונב" claimed-של-אחר → נדחה · (3) הבעלים קורא/מעדכן שלו → מותר · (4) manager משייך-מחדש → מותר · (5) non-owner קורא claimed → נדחה.

## הפעלה (owner — לא הסוכן)
flip `UID_SCOPED_QUERIES=true` (build-define) · backfill ל-docs קיימים · `firebase deploy --only firestore:rules,firestore:indexes`. עד אז — OFF, אפס שינוי.

## אינווריאנט-בדיקה
flag-OFF ⇒ byte-identical להיום (נעילת-רגרסיה חובה). claim ⇒ mutation-verified. rules ⇒ emulator ירוק.

---

## גרסת server-swap — מקור-זהות BoardSession: seed → Firebase Auth (הוראת-בעלים 2026-06-13)

**הבעיה (ליבת multi-user):** היום הלוחות (עובד/שליח/חנות/מנהל) נכנסים דרך `boardAuthProvider` מול חשבונות-seed (`kBoardAccounts`, ran/1111…) — אבל ה-claim ב-`sys_orders` חותם `currentUidProvider` (= Firebase Auth uid). לכניסת-seed Firebase **מנותק** ⇒ uid=='' ⇒ הכל נשאר בבריכה ולא ממוקד. שתי מערכות-זהות מנותקות.

**הפתרון:** כש-`kUidScopedQueries` ON — מקור-הזהות של `boardAuthProvider` הוא **Firebase Auth (uid + role-claim)**, לא ה-seed. אותו משתמש מחובר מניע גם את הלוח (role) וגם את ה-uid לתביעה. OFF = seed/demo בדיוק כמו היום.

### SW1 — מודל
- `BoardSession.uid` (additive, default `''`): seed/demo ⇒ `''`; Firebase-derived ⇒ ה-uid האמיתי. ב-`toJson` **רק כשלא-ריק** (field economy ⇒ JSON של seed זהה byte-for-byte). `fromJson` defaulted.
- מיפוי role-claim→`BoardRole`: persona-ids = שמות BoardRole 1:1 (`worker/courier/store/manager`; `contractor` = האפליקציה הראשית, **לא לוח**).

### SW2 — helper טהור (testable ללא דגל-קומפילציה)
`BoardSession? boardSessionFromAuthSnapshot(AuthSnapshot snap)` — **תמיד מוגדר** (לא מגודר):
- `snap.user==null` ⇒ `null` (מנותק ⇒ אין לוח).
- אחרת ה-role הראשון מ-`snap.roles` שמתמפה ל-BoardRole (מדלג על `contractor`/לא-מוכר) ⇒ `BoardSession(role, username:uid, displayName: snap.user.displayName ?? kBoardDemoNames[role]!, uid, demo:false)`.
- אין role-לוח (claims ריק/contractor-בלבד/עדיין-נטען) ⇒ `null`.

### SW3 — קשירה מגודרת (notifier)
- `BoardAuthNotifier(this._ref, {bool? bindFirebase}) : _bind = bindFirebase ?? kUidScopedQueries` — **constructor-injectable** ⇒ נתיב-ON נבדק ב-unit מול ה-fake `AuthGateway` בלי dart-define; production מגודר ב-const.
- `_bind==false` ⇒ **בדיוק היום**: `_load()` seed, **אפס** קישור ל-authState (נעילת-רגרסיה — `board_auth_test.dart` הקיים נשאר ירוק).
- `_bind==true` ⇒ `ref.listen(authStateProvider, …, fireImmediately:true)` ⇒ `state = boardSessionFromAuthSnapshot(next)`. mounted-guard. (`login/enterDemo/logout` נשארים פונקציונליים; ניתוב-ה-gate ל-Firebase sign-in = follow-up מתועד, לא בטווח כאן — בלי fake.)
- `currentUidProvider` ללא שינוי: כשמשתמש-לוח מחובר ב-Firebase (ON) ה-uid זורם אוטומטית ל-`claimStore/claimCourier`. **אינווריאנט:** board store session `uid == currentUidProvider`.

### SW4 — rules
ה-uid-ownership + manager-override (role-claim) כבר נאכפים (A4-A6/Phase-G). server-swap = שינוי-קליינט. **לאמת** ש-manager-override נשען על `request.auth.token.role`/roles ושהבעלים נשען על uid; להוסיף emulator test אם יש פער (role:'store'+storeUid תואם ⇒ קורא שלי/בריכה בלבד; role:'manager' ⇒ משייך-מחדש). emulator נשאר ירוק.

### SW5 — בדיקות
`test/board_auth_server_test.dart`: helper טהור (store-claim⇒session+uid · contractor⇒null · signed-out⇒null · multi-role⇒board-role ראשון · displayName fallback) + notifier `bindFirebase:true` מול fake gateway (emit user+claim ⇒ session מופיע · emit null ⇒ נקי) + אינווריאנט uid==currentUid. `board_auth_test.dart` הקיים = נעילת flag-OFF.

### הפעלה (owner)
אותו דגל `UID_SCOPED_QUERIES=true` מפעיל את שתי החצאים יחד (scoped-queries + board-auth-from-Firebase) — מונע מצב-שבור (scope ON אבל board-users בלי uid). עד אז OFF, אפס שינוי.
