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
