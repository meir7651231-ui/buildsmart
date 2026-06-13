# SPEC — A4-A6: בעלות הזמנה לחנות/שליח (ליבת multi-user · חוסם השקה)

> **ההוראה לצי** ל‑Phase A4‑A6. מבוסס על G2 rules (5de11d8), A1 (scope enabler), A2 (currentUidProvider), A3 (contractorUid), A7 (UsersLookup).
> **עיקרון: claim‑on‑first‑advance + בריכה משותפת (shared pool).**

## מודל השיוך (ההחלטה — זה מה שחסר היה)
- הזמנה ב‑stage `new` = **בריכה משותפת** לכל ה‑stores (רואים כדי לתפוס).
- store מקדם `new→preparing` (פעולה ראשונה) → **חותם `storeUid = currentUid`** (תפיסה). מכאן רק הוא הבעלים.
- הזמנה ב‑`ready` (ללא courier) = **בריכת שליחים**.
- courier מקדם `ready→pickup` → חותם `courierUid = currentUid`.

## A4 — חתימת uid בתפיסה  · `sys_orders.dart` + `orders_firebase.toDoc`
- להזריק `currentUid` (מ‑`currentUidProvider`) ל‑`storeAdvance`/`courierAdvance`.
- `storeAdvance` `new→preparing`: אם `storeUid` ריק → `storeUid = currentUid`.
- `courierAdvance` `ready→pickup`: אם `courierUid` ריק → `courierUid = currentUid`.
- `toDoc`: לתחזק `orderParticipants = [contractorUid, storeUid?, courierUid?]` (לא‑ריקים) — מתעדכן בכל חתימה.
- **DoD:** doc נושא storeUid/courierUid של הפועל + מערך `orderParticipants`.

## A5 — listener ממוקד + בריכה  · `orders_local.dart` provider + `firestore.indexes.json`
- non-manager: scope (דרך A1) ל‑`where('orderParticipants', arrayContains: uid)` (שלי).
- **+ בריכה:** store צריך גם `new` לא‑תפוסים · courier `ready` לא‑תפוסים → **listener שני** (`stage==X && claimField==''`) ממוזג ל‑cache. (ה‑`FirestoreCachedRepo` יורחב למיזוג שני streams.)
- manager/admin: full listen (ללא scope).
- אינדקסים: `orderParticipants arrayContains + ts desc` + לבריכה (`stage + storeUid/courierUid`).
- **DoD:** קבלן רואה שלו · store רואה שלו+בריכת‑new · courier שלו+בריכת‑ready · admin הכול.

## A6 — סינון דשבורד לפי זהות  · `store_dashboard_screen.dart` · `courier_dashboard_screen.dart`
- store: `storeUid==uid` (תפוסים) + `new` לא‑תפוסים (לתפיסה).
- courier: `courierUid==uid` + `ready` לא‑תפוסים.
- **DoD:** כל אחד רואה רק את שלו + הבריכה הרלוונטית — לא את של כולם.

## עדכון rules + tests  · `firestore.rules` + rules_test
- להתיר **בריכה**: `store` קורא orders ב‑`new` עם `storeUid` ריק · `courier` ב‑`ready` עם `courierUid` ריק.
- + reads לפי ownership (participants) כקיים מ‑G2.
- emulator tests: בריכה נראית · אחרי תפיסה רק הבעלים · store לא רואה הזמנות של store אחר.

## ⚠️ יישור שמות (קריטי)
לוודא ששמות השדות (`contractorUid`/`storeUid`/`courierUid`) **תואמים בדיוק** למה ש‑G2 rules (5de11d8) בודקים. אם הרולז משתמשים בשם אחר — ליישר את שני הצדדים.

## תלות ואומדן
A4 → A5 → A6 ; עדכון rules במקביל. **~2‑4 ימים.** אחרי זה: multi-user אמיתי עובד, וזה משחרר את חוסם‑ההשקה המרכזי.
