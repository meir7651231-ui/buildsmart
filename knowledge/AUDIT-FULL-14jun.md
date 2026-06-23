# AUDIT-FULL — חפירה מלאה על כל האפליקציה (14/6, c07da11)

> סריקת‑עומק משולשת על **כל** `app_flutter` (77 מסכים) — placeholders · פערי‑שרת/סנכרון · פוש/חומרה.
> מטרה: התמונה המלאה ל"100%". **~200 פערים** סה"כ.

## 🔄 עדכון‑סטטוס 23/6 (קרא ראשון — חלקים מהאודיט להלן כבר לא נכונים)
האודיט נכתב 14/6. מאז (v6.x, ~40+ קומיטים) נסגרו פערים מרכזיים — **אומת בקוד:**
- **E (AI hub "אפס LLM") — בוטל ✅:** Claude אמיתי נבנה+נפרס (`functions/src/claude.ts`, `askClaude`), ~15 פיצ'רי "✨ עם Claude" + agentic. **פעיל** (החלטת‑בעלים 23/6). דורש `ANTHROPIC_API_KEY` בקונסול. ראה `SPEC-ai-assistant.md`.
- **S (באג‑סנכרון) — נסגר ✅:** S2 (סנכרון הזמנות+צ׳אט) · S3 (✓✓ אמיתי per‑message) · S4 (מד‑חיבור חי 🟢/🔴).
- **B (קטלוג דק) — שופר משמעותית:** העשרת‑R8 ממסמכים רשמיים → dims ~96‑100%, real‑spec→87%, ציון‑כרטיס דו‑צירי. (עדיין vertical‑אינסטלציה לפי בחירת‑סקופ של הבעלים.)
- **D (seed מזויף) — נסגר ✅:** finance/stock/site/credit מגודרים ל‑ריק‑כן (P2).
- **F (הגדרות מתות) — חלקי ✅:** ירוקים מחווטים (P3: textSize/contrast/reduce‑motion/sessionTimeout).
- **מקלדת‑חכמה** נבנתה (`features/word_finder/` live‑DIVE) — ראה `KEYBOARD-MASTER-PLAN.md` + tracker.
- **מוכנות‑launch:** הצי סימן אבן‑דרך v6.72 (audit‑swarms סגרו MED+LOW).
> **השאר (פוש‑iOS · rewards‑backend · שכר/מסמכים · FX/SMS) — עדיין תקף כמתואר למטה.** המספר "~200" כבר לא מדויק כלפי מטה.

## ⚖️ חשבון‑הנפש (קרא קודם — הקשר 14/6)
האפליקציה היא **פרוטוטייפ ברמת‑דמו עם "מסגרת‑כנות" מצוינת**: דגל `kHideUnderConstruction=true` מסתיר מ‑UI כל placeholder, ו‑~25 מסכים אומרים ביושר "יחובר עם השרת". **שום דבר לא שבור‑בשקט או מזויף‑כאילו‑עובד** — אבל רוב הפיצ'רים מעבר לליבה הם **דמו/seed/inert**.

**מה אמיתי ועובד:** הזמנות (סנכרון) · צ׳אט (סנכרון) · הרשמה/auth (c07da11, מגודר) · קטלוג‑אינסטלציה · מצלמה/גלריה/GPS/שיתוף/ברקוד/קול/PDF/וואטסאפ · פוש‑קליינט + שרת‑שולח (order/chat triggers) · אנדרואיד‑manifest.

**⚠️ המלכודת הגדולה:** כמה `_firebase` repos מחזירים **const seed גם כשהדגל ON** — כלומר הדלקת הדגל **לא** הופכת אותם לחיים (תקציב, מלאי, פרויקטים, אשראי, FX). פירוט בקבוצה D.

---

## A. הרשמה / משפטי (חוסם השקה הכי גבוה)
- `welcome_screen.dart:205` · "אין שרת התחברות — אורח" = **טקסט ענף‑דמו (flag OFF)**; עם flag ON יש auth אמיתי (c07da11). לוודא שה‑UI מציג נכון בדמו.
- `legal_texts.dart:27,77,81,90,124` · **תקנון/פרטיות עם סוגריים ריקים**: [שם החברה]/[מספר רישום]/[כתובת]/[דוא"ל]/[מחוז]. למלא לפני השקה מסחרית.
- `legal_texts.dart:27` · "פועלת במתכונת פיתוח והדגמה" — להסיר בהשקה.
- `welcome_screen.dart:355` · אימות פורמט‑בלבד; ייחודיות → Firebase (server‑side check חסר).

## B. קטלוג‑דאטה — רק אינסטלציה קיים (ליבת‑המסחר חד‑ורטיקלית)
- `catalog_screen.dart:2511,3064` · כל קטגוריה בלי tree‑data → "בקרוב". **רק אינסטלציה/ניקוז מאוכלס.**
- `departments_screen.dart:107-113` · **5 מחלקות ריקות (live:false):** חשמל · חומרי‑בניין · צבע · גבס · אספקה‑טכנית.
- `profession_screen.dart:11` · **רק אינסטלטור בנוי**; חשמלאי + שיפוצים = "בקרוב".
- `suppliers_screen.dart` · **רק ספק אחד** (ליפסקי); פיצ'ר‑ספקים = placeholder.
- `brands.dart:24` · מותגים = placeholders. `lipskey_brand_screen.dart:237` · קטגוריות‑מותג ריקות. `huliot_smartlock_catalog.dart:56` · תמונות‑מוצר כבויות (העלאת‑R2 TODO).

## C. "יחובר עם חיבור השרת" — ~25 מסכים server‑pending (UI מוכן, backend חסר)
- **תלושי‑שכר:** `worker_payslips_sheet.dart:99,176` · `courier_profile_screen.dart:563` · `worker_profile_screen.dart:592` — אין שרת‑שכר.
- **מסמכי‑חנות:** `store_documents_sheet.dart:107,186` · `store_profile_screen.dart:594` — חשבוניות/דוחות 12‑חודש = placeholder.
- **HR/טפסים:** `worker_forms_screen.dart:212` · `courier_forms_screen.dart:161` (טופס 101) · `worker_safety_screen.dart:796` (הדרכות דמו) · `worker_equipment_checklist_sheet.dart:220`.
- **שליח:** `courier_portal_tab.dart:173,199,210,226,482` — זמינות‑צי · **מפה חיה** · ניווט · **טיימרי SLA** · `courier_delivery_detail_sheet.dart:290` (חותמות‑זמן) · `courier_attendance_screen.dart:202`.
- **persona portal:** `persona_portal.dart:251,301` — דירוגי‑ספק דמו · כלי barcode/nav/POD "יחובר בהמשך".

## D. ⚠️ דאטה מדומה **גם כשהדגל ON** (המלכודת — repos שמחזירים seed)
- **תקציב:** `finance_firebase.dart:284-303` — budgetTotal=15000/Spent=9840 + קטגוריות = const **גם ON**. כל קבלן רואה תקציב מזויף.
- **מלאי:** `stock_firebase.dart:209-233` — totalProducts/counts/stores = const **גם ON**. אריחי‑מלאי של המנהל מזויפים.
- **מלאי‑חנות:** `store_stock.dart:77,96` — OOS toggles + מוצרים‑שספק‑הוסיף = **SharedPreferences בלבד, אף פעם לא Firestore**. חנות שמסמנת "אזל" — אף אחד לא רואה.
- **אתר:** `site_firebase.dart:259-284` — projects/planTypes/safetyTips/archived = const **גם ON**.
- **אשראי‑לקוח:** `customers_firebase.dart:185` — creditLimit = hash‑קליינט, לא Firestore (אלא אם kServerCallables ON + computeCredit פרוס).
- **FX:** `phaseb_seeds.dart:117` (kFxRates) + `finance_hub_sheets.dart:1514` — "שערי דמו שמתעדכנים מהשרת" אבל אין API.
- **site_hub כולו:** `site_hub_screen.dart:1297,1060` — צילום‑לפני/אחרי **מדומה** (אין מצלמה, לא נשמר) · אישור‑בטיחות **מדומה** · גאנט/עץ‑אתר/תלויות/ארכיון = const. הכל בזיכרון, נעלם ב‑reload.

## E. AI hub — אפס קריאות LLM אמיתיות בכל הקוד
- `ai_hub_screen.dart:65` · 3 כלים deferred: `ai_hub_logic.dart:257` (התאמה‑משולשת kThreeWayDocs) · `:280` (מזג‑אוויר kWeather) · `:305` (זיהוי‑בלאי kGear) — כולם const.
- ✅ **6 כלים אמיתיים** (מחושבים מדאטה חי): חיזוי‑מלאי · חלופות‑זולות · אנליטיקה · תוכנית→BOM · ברקוד · קול. **אין שום `openai`/`anthropic`/`http` ב‑lib** — "AI" = כלים‑מחושבים, לא מודל.

## F. הגדרות מתות — ~50 toggles persisted‑בלי‑אפקט
- **notif_settings:** מייל/SMS/וואטסאפ (disabled) + ~24 toggles (`notif_settings_screen.dart:269-784`): הצעות‑ספק/חזר‑למלאי/תזכורות/שיחות/פרויקטים · שקט(שבת/פגישות/נהיגה) · צלילים/LED/דחייה/חסימה · persona‑feeds · סיכומים · פרטיות‑נעילה · כפתורי‑תגובה.
- **chat_settings:** `chat_settings_screen.dart:249-671` — ~9 toggles + 5 סקשנים (מדיה/גיבוי/שפה/עסקי/ארכיון) inert.
- **store_settings:** `store_settings_screen.dart:125-645` — תשלומים/עוסק/ח.פ./ייצוא‑רו"ח/קבלות/משלוח/ספקים‑מועדפים/ביומטרי/אשראי inert.
- **catalog_settings:** `catalog_settings_screen.dart:288-600` — רדיוס‑geo/ספק‑מועדף/השוואת‑מחיר/sync‑מועדפים deferred (למוצר אין geo/supplier‑id).
- **app_settings.dart:51-85** · 13 שדות מתים (textSize/units/currency/2FA/biometric...).

## G. פוש — קליינט+שרת אמיתי, אבל פערים
- ✅ FCM token lifecycle · ערוצי‑אנדרואיד · foreground · **שרת‑שולח** (`functions/push.ts`: order+chat triggers → sendEach). **שליחה למשתמש‑אחר אמיתית** (תלוי deploy+מכשיר).
- ❌ **iOS push מת:** חסר `aps-environment` entitlement · `UIBackgroundModes:remote-notification` · AppDelegate ריק. **F4 — חוסם iOS push.**
- ❌ tap→deep‑nav = log בלבד (`push_state.dart:633`). ❌ מייל/SMS/וואטסאפ — אין backend.
- `notifications_screen.dart:118` · פיד‑התראות‑קבלן = **seed קבוע** (`_kNotifs`), לא מקור‑חי.

## H. Rewards / מועדון — 100% מקומי (אף פעם לא Firestore)
- `rewards_state.dart:35-147` — coins(SharedPreferences) · streak/leaderboard/badges/coupons/VIP/referral = const. **אין repo‑Firebase ל‑rewards בכלל.**

## I. חומרה — רובו אמיתי, 3 stubs
- ✅ מצלמה/גלריה/חתימה/POD/GPS(native+web)/ברקוד/קול/PDF/tel/וואטסאפ/Waze — אמיתי.
- ❌ **ביומטרי** — `local_auth` **לא ב‑pubspec בכלל**; toggle = UI ריק.
- ❌ `doc_print_stub.dart` (הדפסת‑native → false) · `camera_sheet.dart:339` (thumbnails דמו בגריד‑גלריה) · `geo_stub.dart` (לא מחווט).

## S. סנכרון‑דאטה (הבאג שבדקת) — חשד ראשי
- אינדקסים: שלב‑deploy היה best‑effort. הזמנות scoped (arrayContains uid) — אם אינדקס חסר, רשימה ריקה בשקט. **לאמת + תג‑אבחון.**

---

## ספירה
**~200 פערים.** קוד‑fixable מיד (הצי): ~80 (לחווט repos לשרת · להסתיר/לסיים placeholders · iOS push · ביומטרי · אבחון). **דורש דאטה‑עסקית (אתה):** קטלוג‑5‑מחלקות · ספקים · מקצועות. **דורש backend‑חדש:** שכר/חשבוניות/מסמכים/rewards/notif‑channels. **דורש חיצוני:** FX/מזג‑אוויר/AI/תשלום/SMS/email.

## 🎯 ההכרעה: MVP ממוקד מול "הכל 100%"
- **MVP (שבועות):** ליבה שעובדת (אינסטלציה+הזמנות+צ׳אט+auth+חומרה), השאר מוסתר ביושר (kHideUnderConstruction). אפל‑safe. מוצר אמיתי אך **צר**.
- **"הכל 100%" (3‑6+ חודשים):** לבנות את כל ~200 — דאטת‑קטלוג מלאה · backend שכר/מסמכים/rewards · אינטגרציות FX/AI/תשלום/SMS · iOS push. עבודה ענקית + הרבה דאטה‑עסקית.
