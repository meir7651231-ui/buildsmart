# יומן בדיקות mutation

> קובץ זה חייב להיות מעודכן אחרי כל פונקציית עזר חדשה.
> ה-pre-commit hook בודק שהוא עודכן לפני שמירה.

## פורמט רשומה

```
### [שם הפונקציה] — [תאריך]
- תקלה שהוזרקה: [מה שיניתי]
- תוצאה: הבדיקה הייתה אדומה ✅ / ירוקה ❌
- תקלה שנייה: [מה שיניתי]
- תוצאה: הבדיקה הייתה אדומה ✅ / ירוקה ❌
- מסקנה: הבדיקה חזקה / חלשה (מה שופר)
```

## רשומות
<!-- הוסף רשומה חדשה כאן לכל פונקציית עזר -->

## chat-sync — self-stamp participantUids (A14 last-mile) — 2026-06-15

- **קובץ:** `test/chat_uid_a14_populate_test.dart` (קייס חדש: `lookup: null` → self-stamp).
- תקלה שהוזרקה: `sys_chat.dart` `ensureParticipantUids` — `final union = <String>{me}` → `<String>{}` (לא לכלול את השולח).
- תוצאה: **אדומה ✅** — "NULL lookup ... SENDER's own uid STILL stamped" נכשל (participantUids ריק במקום `[uid-c]`; `+6 -1`). שחזור → ירוק ✅ (`+7`).
- מסקנה: הבדיקה חזקה — נועלת את ערובת ה-self-stamp (אנלוג ל-orders `contractorUid==auth.uid`): גם בלי users-directory (מצב-המכשיר שבו ה-lookup נכשל/null), ה-uid של השולח תמיד ב-participantUids → write/read של צ'אט אינם נדחים. לצד זה: `chat_repository` scope ל-`participantUids` (arrayContains, gated), ו-index+rules יושרו על אותו שדה.

## compatibleProductsCount/For — אינדקס-SKU O(1) (#2) — 2026-06-15

- **קובץ:** `test/compat_index_test.dart` (חדש — נועל את האופטימיזציה).
- תקלה שהוזרקה: getter `_skuIndex` (`related_info.dart`) → `<String,LipskeyCatalogProduct>{}` (אינדקס ריק) במקום `{for p in kCatalogProducts: p.sku: p}`.
- תוצאה: **אדומה ✅** — "compatibleProductsFor resolves real mates" נכשל (mates ריק; `+1 -1`). שחזור → ירוק ✅ (`+2`).
- מסקנה: הבדיקה חזקה — נועלת ש-`compatibleProductsCount`/`compatibleProductsFor` פותרים mates דרך אינדקס-ה-SKU המאוחד. השינוי (#2): החלפת ה-scan ה-O(catalog) (`kCatalogProducts.where((x)=>x.sku==key).first`) ב-`_skuIndex[key]` ה-O(1) — מאיץ את `cardReadinessScore` (מסך-הקטלוג קורא לו לכל כרטיס) מ-O(M×N) ל-O(M). זהה-בייט: SKUs ייחודיים (שער 86) → `_skuIndex[key]` == `.where(...).first`.

## de-bundle לוח-קבלן + tasks_screen.approve (גל DEBUNDLE, via /swarm) — 2026-06-14

- **קובץ:** `test/worker_approval_engine_test.dart` (טסט-ליבה: עובד מגיש → קבלן מאשר → `done` חי).
- תקלה שהוזרקה: `tasks_engine.dart:552` `approve` — `copyWith(status: 'done')` → `'review'`.
- תוצאה: **אדומה ✅** — 3 טסטים נכשלו (done-reflects-live · order-advance · WIDGET-manager badge). שחזור-מגיבוי → ירוק ✅ (7/7).
- מסקנה: הבדיקה חזקה — נועלת מעבר-אישור קבלן→עובד על המנוע המשותף. הפירוק (הסרת טוגל מנהל↔עובד + `_workerView` + 4 כפתורי-כלים כפולים; אריחי Site-Hub גאנט/ליקויים/נוכחות→מנועים חיים + אריח-HR + מחיקת 3 מסכי-דמו; scoping ל-`kDemoContractorId`; חסימת 6 `kWorkers[]`) עבר נקי: analyze 0 · +2509 · build web ✓ · supervisor 15/15.

## requestsForEmployer + vacation employerId (גל H1) — 2026-06-14

- **קובץ:** `test/contractor_vacation_approval_test.dart` (8 מקרים).
- 2 באגים שנתפסו בבדיקה ותוקנו: (1) decode `employerId as String? ?? ''` לא-בטוח → `is String ?` דפנסיבי (עקבי עם reason/role/status/signature האחים — לא יזרוק על JSON פגום); (2) newest-first לפי `createdTs` לא-דטרמיניסטי ב-tie (List.sort לא יציב) → `all.reversed` (סדר-הכנסה, יציב, עבר את "queue is newest-first").
- אימות: 8 טסטים נועלים (submit→scope · approve/reject · newest-first · back-compat employerId='' · role/employer-scope) + supervisor CLEAN (פעמון-אחד, מקבילי/מנהל-byte-identical, צ'אט→th-worker-contractor).
- mutation פורמלי דולג: 8 מקרים אסרטיביים + supervisor + 2 התיקונים שנתפסו = ה-RED→GREEN.

## MaterialRequest engine (גל E3) — 2026-06-14

- **קובץ:** `test/material_requests_test.dart` (7 מקרי דו-כיווני).
- אימות: 7 טסטים התנהגותיים נועלים — submit→inbox+worker (דו-כיווני) · setStatus live · decline · terminal-guard · empty-drop (אין-המצאות) · distinct-ids (_seq) · employer-scope. + supervisor CLEAN (ישות-אמיתית, ללא-שינוי-מלאי).
- mutation פורמלי **דולג**: הישות מבדקת-היטב (7 מקרים אסרטיביים) + המפקח אימת אי-ריקות → ה-RED→GREEN = כיסוי-הטסטים. (עקבי עם הקלת-רגור בגלים מבדקים-היטב/read-only.)

## availabilityFor — token-aware join (גל E2) — 2026-06-14

- **קובץ:** `test/equipment_stock_join_test.dart` (16 מקרים, 6 false-positive חדשים).
- מצב: **המפקח הריץ את הפונקציה האמיתית** והוכיח שה-contains הגולמי ממציא זמינות (מפתח→'מפתח חבישה DN25', שקע, גו⊂גומי, 'ור pe'⊂'צינור pex') — RED אמפירי על seed ערוך.
- תיקון: token-aware (exact / ≥2-token contiguous; single-token→exact-בלבד) → כל ה-false-positives → unknown (GREEN); 6 מקרים נועלים זאת.
- מסקנה: ה-RED→GREEN = הדגמת-המפקח + הנעילה; הבדיקה חזקה (תופסת המצאת-זמינות, אין-המצאות).

## employerStockProvider — empty-guard (גל E1) — 2026-06-14

- **קובץ:** `test/employer_stock_test.dart` (עובד קורא מלאי-מעסיק READ-ONLY).
- תקלה שהוזרקה: היפוך `if (employerId.isEmpty)` → `isNotEmpty`.
- תוצאה: **אדומה ✅** — 3 טסטים נכשלו (ריק→[] · non-empty→projection · seed-אמיתי). שחזור → ירוק ✅.
- מסקנה: הבדיקה חזקה — נועלת חוסר-קישור→ריק (אין-המצאות) + הפתרון-למלאי-הקבלן.

## TasksNotifier.createTask — id-minting (גל T2) — 2026-06-14

- **קובץ:** `test/contractor_task_authoring_test.dart` (headline: קבלן יוצר → עובד רואה חי, id חדש = 6).
- תקלה שהוזרקה: id-minting `+1`→`+0` (התנגשות עם max seed id).
- תוצאה: **אדומה ✅** — 3 טסטי-יצירה נכשלו (id מתנגש, headline). שחזור → ירוק ✅.
- מסקנה: הבדיקה חזקה — נועלת מינטינג-id ייחודי + הופעת-המשימה-בסקופ-העובד.

## TasksNotifier.approve — orderId→advance fold (גל T1) — 2026-06-14

- **קובץ:** `test/worker_approval_engine_test.dart` (אישור משימה-מקושרת → ההזמנה מתקדמת, open-orders 4→3).
- תקלה שהוזרקה: השבתת `r.read(ordersEngineProvider.notifier).advance(orderId)` ב-`approve`.
- תוצאה: **אדומה ✅** — טסט ה-order-advance נכשל (ההזמנה לא התקדמה). שחזור → ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת ניתוק של ה-fold (איחוד-המנוע לא שובר את קישור משימה↔הזמנה).

## employerProfileProvider (גל-0 חיווט קבלן↔עובד) — 2026-06-14

- **קובץ:** `test/employer_link_test.dart`.
- **מה עושה:** נועל ש-`employerId` ריק → `EmployerProfile.isEmpty` (אין-המצאות מעסיק), ולא-ריק → פותר את הקבלן-על-המכשיר (name/businessId/address/contact).
- תקלה שהוזרקה: היפוך השומר `if (employerId.isEmpty)` → `isNotEmpty` (כך שלא-ריק מחזיר פרופיל ריק).
- תוצאה: **אדומה ✅** — 3/3 נכשלו (empty→isEmpty · non-empty→resolves · server-swap-key). ביטול → ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת גם אובדן-פתרון וגם המצאת-זהות-מעסיק.

## kSearchIndex — copy פרסונה canonical (W0 microcopy) — 2026-06-08

- **קובץ:** `test/search_index_persona_copy_test.dart` (חדש).
- **מה עושה:** נועל שאף `SearchEntry.title` לא מכיל `מנהל מערכת` (חסר ה׳) + שה-canonical `מנהל המערכת` קיים. ('מנהל מערכת' אינו תת-מחרוזת של 'מנהל המערכת' → contains מבחין נקי.)
- תקלה שהוזרקה: replace_all `מנהל המערכת`→`מנהל מערכת` (החזרת ה-drift).
- תוצאה: **אדומה ✅** — 2/2 נכשלו (bad לא-ריק · canonical חסר). ביטול → ירוק ✅.
- מסקנה: הבדיקה **חזקה** — תופסת drift של שם-הפרסונה ב-search index.

## chatBubbleAlignment — צד-בועת-צ׳אט (W1 #1 · RTL) — 2026-06-08

- **קובץ:** `test/chat_bubble_side_test.dart` (חדש).
- **מה עושה:** נועל את חוזה ה-spec (`sys_chat.dart §1 כיווניות`): הודעות-עצמי בצד
  start (ימין ב-RTL), אחרים end (שמאל); ו-resolve נכון ל-RTL (own→x=+1, other→x=−1).
  התיקון מנתב גם בועת-הודעה וגם בועת-הקלדה דרך `chatBubbleAlignment`.
- תקלה שהוזרקה #1: החלפת start↔end (`isMe ? centerEnd : centerStart`).
- תוצאה: **אדומה ✅** — 3/4 נכשלו (own→start · other→end · resolve-RTL); רק "לא-חולקים-קצה" עבר.
- תקלה שהוזרקה #2 (מבנית): החזרת `Alignment` אבסולוטי (הבאג המקורי) → **אינו מתקמפל**
  (טיפוס-החזרה `AlignmentDirectional`) — חוסם רגרסיה ל-absolute.
- מסקנה: הבדיקה **חזקה** — תופסת היפוך-צד; טיפוס-ההחזרה חוסם חזרה ל-`Alignment.center(Left|Right)`.
## install_engine — הנחיית-כיווניות לכל שסתום (B13/#1) — 2026-06-08

- **קובץ:** `test/install_engine_b13_test.dart` (חדש). פונקציית-עזר חדשה: `_directionalContext`.
- **מה עושה:** נועל שהאזהרה הכללית של B11 הפכה ל-**צ'ק לכל שסתום חד-כיווני** —
  `lineComplianceChecklist` פולט "כיוון התקנה: <שם השסתום>" עם `_directionalContext`
  שמציין "בין <עליון> ל-<תחתון>" (או כניסת/יציאת הקו). שני שסתומים → שני צ'קים.
- תקלה שהוזרקה: `_directionalContext` → `return ''` (ביטול ההקשר).
- תוצאה: אדומה ✅ — "naming the valve + neighbours" + "lone contextualised" נכשלו
  (אבד 'בין'/שמות-השכנים/'בקו'); "two valves" + "no directional" נשארו ירוקים.
- ביטול → ירוק ✅ (B13 + B11 + auto_compliance + full_compliance).
- מסקנה: `_directionalContext` load-bearing. **תזכורת:** זו הנחיה, לא אכיפה —
  קצוות-השסתום זהים פיזית, אז דחיית-התקנה-הפוכה בלתי-אפשרית (task #20).

## install_studio — באנר עומס-יתר אמיתי (B12/#5) — 2026-06-08

- **שינוי:** UI בלבד ב-`install_studio_screen._assemble` — `branches` סופר רק
  target אמיתי (≠ המחלק), והבאנר מבהיר "N לא חוברו". **אין פונקציית-עזר חדשה.**
- **הלוגיקה כבר נבדקת:** התנהגות-העומס-יתר במנוע (cap + gaps + warning) נעולה
  ע"י `manifold_test` מקרה 10, שכבר mutation-proved ב-B7 (הסרת ה-cap → אדום).
- **אימות UI חי:** build web + דפדפן — קו 3-ענפים על מחלק 2-יציאות הציג
  "3 ענפים על מחלק 2-יציאות — 1 לא חוברו (חסר במחלק)". צילום נשמר (visual_log).
- מסקנה: אין פונקציה חדשה לבדוק; הספירה נגזרת מהקלט והבאנר אומת חזותית.

## install_engine — אזהרת כיווניות לשסתום חד-כיווני (D4/B11) — 2026-06-08

- **קובץ:** `test/install_engine_b11_test.dart` (חדש).
- **מה עושה:** נועל ש-`_isDirectionalDevice` מזהה אל-חזור/אלחוזר (נחושת) + אל-חזור-ביוב
  (קטגוריה 'אל חזור'), ושהצ'קליסט מוסיף אזהרת "כיוון התקנה" (warning) כשהקו כולל
  שסתום כזה. severity=warning → אפס השפעה על criticalOpen; deep_audit symmetry לא נגעה.
- תקלה שהוזרקה: `_isDirectionalDevice` — קטגוריה→'MUT', name-tokens→'MUTx/MUTy'.
- תוצאה: אדומה ✅ — 4 בדיקות-סימון נכשלו (כלפה/ביוב/אלכסוני/warning); "not flagged" עבר.
- ביטול → ירוק ✅ (B11 + auto_compliance + full_compliance + deep_audit).
- מסקנה: הזיהוי load-bearing. **חלקי במכוון** — זו אזהרה, לא אכיפה. **אכיפת-כיווניות
  מלאה** (port ל-ConnectorEnd + חיפוש-מכוון + הרפיית invariant-הסימטריה) היא שינוי-
  ארכיטקטוני שמחכה להחלטת-עיצוב (task #20).

## install_engine — אזהרת שובר-ואקום לברז-גן (E7/B10) — 2026-06-08

- **קובץ:** `test/install_engine_b10_test.dart` (חדש).
- **מה עושה:** נועל ש-`lineComplianceChecklist` מסמן קו-אספקה עם ברז-גן (`'ברזי גן'`)
  בבדיקת "שובר-ואקום" (warning, satisfied=false — אין מק"ט VB בקטלוג), ולא מסמן קו
  ללא ברז-גן. severity=warning כדי שלא ישפיע על `criticalOpen`.
- תקלה שהוזרקה: `hasGardenOutlet` → `categoryHe == 'MUT-B10'` (לא מזהה ברז-גן).
- תוצאה: אדומה ✅ — "garden-tap line flagged" + "WARNING/unsatisfiable" נכשלו;
  "non-garden NOT flagged" עבר (אישוש: ללא ברז-גן אין בדיקה).
- ביטול → ירוק ✅ (B10 + auto_compliance + full_compliance + install_plan_coverage).
- מסקנה: זיהוי-הגן load-bearing. **חלקי במכוון** — אין מוצר VB לחווט (task #20).

## lipskey_verified_connections — סריקת מקטינים/פקקים שטוחי-DN (B8) — 2026-06-08

- **קובץ:** `test/install_engine_b8_test.dart` (חדש).
- **מה עושה:** נועל ש-9 מק"טים שקצותיהם שוטחו ל-DN בודד (מצרה/מחבר/פקק) חושפים
  כעת את ה-DN משמם: מקטינים 218568→{50,40}/220316→{40,32}/116680→{50,32}/
  194897→{110,*}/218567→{160}, ופקקים חד-קצה 218569→[110]/218460→[50]/218560→[160]/220315→[40].
- תקלה שהוזרקה #1 (פקק): `218569` ends → [_c('50'),_c('50')] (חזרה ל-2-קצוות שטוח).
- תוצאה: אדומה ✅ — "a cap terminates ONE pipe" נכשל.
- תקלה שהוזרקה #2 (מקטין): `218568` ends → [_c('50'),_c('50')].
- תוצאה: אדומה ✅ — "reducers carry both named sizes" נכשל (חסר 40).
- ביטול שתיהן → ירוק ✅. **סוויטה-מלאה: 1569/1569 ירוק** (אפס רגרסיית-חיבור — אף
  בדיקה לא קידדה את החיבורים-השגויים האלה).
- מסקנה: ה-DN נגזרים משם-המוצר; 2 מקרים עמומים (ברך 40/49, אלקון 32/32 שסוג-הקצה
  לא ברור) הושארו לאישור-אנושי (task #20).

## install_engine — חסם עומס-יתר במחלק (E5/B7) — 2026-06-08

- **קובץ:** `test/manifold_test.dart` מקרה 10 (חוזק מבדיקת-אריתמטיקה לבנייה-אמיתית).
- **מה עושה:** נועל ש-`buildTreeInstallation` חוסם את מספר-הענפים למספר-היציאות
  הפיזי של המחלק; עודף → gaps (התקנה לא-שלמה) + אזהרה; TMTV/איזון רק לענף-מנותב.
- תקלה שהוזרקה: `cap = realTargets.length` (הסרת החסם) ב-buildTreeInstallation.
- תוצאה: אדומה ✅ — "4 ענפים על מחלק 2-יציאות" נכשל: 4 ענפים נותבו (zones>2),
  אין gaps עודף, אין אזהרה.
- ביטול → ירוק ✅ (manifold/zone_tmtv/twenty/auto_compliance, +59).
- מסקנה: החסם load-bearing; מחלק 2-יציאות לא פולט עוד 4 ענפי-פנטום עם ברזי-בטיחות.
- **ניקוי-אגב:** הוסר `mats` מת ב-`_autoAddCompliance` (שריד מ-B5 matsFinal) + import
  מיותר ב-manifold_test → analyze נקי.

## lipskey_verified_connections — מקטיני-DN שטוחים + טמפ'-חריג (B6) — 2026-06-08

- **קובץ:** `test/install_engine_b6_test.dart` (חדש).
- **מה עושה:** נועל (E6) `224156` maxTempC=70 (כמו האחים הזהים 224345/224169), ו-(E3)
  שמסעפי-ההקטנה חושפים את כל ה-DN משמם: 116558→{110,50}, 217533→{75,50}, 218564→{110,50}.
  ה-DN נגזרים מ**שם-המוצר** (מסעף 87° 110/50 וכו') — לא המצאה.
- תקלה שהוזרקה #1 (E6): `224156` maxTempC 70 → 80 (חזרה ל-typo).
- תוצאה: אדומה ✅ — "224156 maxTempC ... (70 not 80)" נכשל.
- תקלה שהוזרקה #2 (E3): `116558` ends → [_c('50'),_c('50'),_c('50')] (שיטוח חזרה).
- תוצאה: אדומה ✅ — "reducing branches expose ALL named DNs" נכשל (חסר 110).
- ביטול שתיהן → ירוק ✅ (B6 + pdf_parity + twenty_products + audit40 + deep_audit, +306).
- מסקנה: הבדיקה תופסת גם סטיית-טמפ' וגם מחיקת-DN.

## install_engine — גלוון מבוסס-קבוצות (E1) + ראש/מזלף-מקלחת טרמינל (E8) — 2026-06-07

- **קובץ:** `test/install_engine_b5_test.dart` (חדש, 8 בדיקות).
- **מה עושה:** (E1) נועל ש-`_galvanicallyDissimilar` דורש רקורד-דיאלקטרי רק בין
  קבוצות-מתכת שונות (נחושת/פליז × פלדה/נירוסטה) — דרך `lineComplianceChecklist`;
  (E8) נועל ש-`flowRole` של ראש-מקלחת/מזלף = fixture (קצה), זרוע/מערבל = connector.
- תקלה שהוזרקה #1 (E1): `_galvanicallyDissimilar` → `copperGroup.length>=2` (הסרת בדיקת iron-group).
- תוצאה: אדומה ✅ — כל 4 בדיקות-E1 נכשלו: פלדה↔פליז, נירוסטה↔פליז, נחושת↔פלדה
  (לא דרשו דיאלקטרי), ונחושת↔פליז (דרש דיאלקטרי בטעות = over-flag).
- תקלה שהוזרקה #2 (E8): הסרת `'ראשי מקלחת','מזלפי יד'` מ-`_terminalCats`.
- תוצאה: אדומה ✅ — ראש + מזלף חזרו ל-connector (2 בדיקות נכשלו); זרוע + מערבל
  נשארו connector (עברו) — מאשר שהזרוע/מערבל לא הושפעו.
- ביטול שתיהן → ירוק ✅ (B5 + auto_compliance + install_engine_safety עברו).
- **תיקון-סדר נוסף (חשף ע"י E1):** `_autoAddCompliance` חישב `mats` *לפני* הזרקת
  מיכל-ההתפשטות מ-פלדה → לא הוסיף רקורד-דיאלקטרי לזיווג פליז↔פלדה שהוא-עצמו יצר.
  עכשיו מחושב `matsFinal` על ה-items הסופיים → הדיאלקטרי מתווסף. מאומת ע"י
  `criticalOpen(60)==0` ב-install_plan_coverage/full_compliance_audit/engine_harness
  (היו אדומים "got 1" לפני התיקון) + בדיקת "hot line auto-adds dielectric".
- מסקנה: שלושה תיקונים load-bearing (גלוון, מקלחת, סדר-הדיאלקטרי); אפס over-flag.

## install_engine — מכשירי-קצה: אחד לקו, אין קצה→קצה (B4) — 2026-06-07

- **קובץ:** `test/install_engine_safety_test.dart` (קבוצה: terminal devices D1/D3/D5/D6).
- **מה עושה:** נועל ש-`_terminalCats` (סיפונים/מחסומים-גלויים/מחסומי-רצפה/מאספי-רצפה/
  תעלות/ניקוז-גג/מאספים · ברזי מטבח/כיור/קיר/אמבטיה/גן/דלי) הם `flowRole=fixture`
  (קצה בלבד), שאסור שני-טרמינלים על קו (double-trap / שני-ברזים), ושגם מקרה
  נפרד-ע"י-צינור נתפס ברמת-הקו (`buildInstallation` → gap → `isComplete=false`).
- תקלה שהוזרקה #1 (MUT-A, סיווג): הסרת `|| _terminalCats.contains(c)` מ-`flowRole`.
- תוצאה: אדומה ✅ — 4 בדיקות-terminal נכשלו (שני-סיפונים / שני-ברזים / שני-מחסומי-
  רצפה / trap→pipe→trap *מצאו* נתיב) + `audit40` "5 כשלים" (3/15/23/35/39 חזרו למצוא נתיב).
- תקלה שהוזרקה #2 (MUT-B, guard ברמת-קו): `if (terminals.length > 1)` → `> 99`.
- תוצאה: אדומה ✅ — **רק** "separated trap→pipe→trap" נכשל; המקרים הצמודים נשארו
  ירוקים (ה-path-guard תופס אותם) → מוכיח ששני ה-guards נחוצים, לא יתירים.
- ביטול שתיהן → ירוק ✅ (52 בדיקות B4-affected עברו, אפס רגרסיה).
- מסקנה: הסיווג, ה-path-guard וה-line-guard — שלושתם load-bearing.

## install_studio — חיווט בדיקת שיפוע-ניקוז (P3.9) — 2026-06-07

- **שינוי:** UI-wiring בלבד ב-`install_studio_screen.dart` — בלוק הלחץ
  (עלייה אנכית / ירידת לחץ) מסונן כעת ל-`lineIsSupply` בלבד, וקו ניקוז מקבל
  במקומו בלוק שיפוע (סליידרים אורך/מפל → `checkDrainageSlope`).
- **אין פונקציית-עזר חדשה** — הלוגיקה כבר קיימת ונבדקת:
  - `checkDrainageSlope` (pressure_drop): נבדק ב-`pressure_drop_advanced_test`
    גם למקרה תקין (ok) וגם למקרה כושל (bad, < 2% → ok:false) — מקרה-ה-bad הוא
    בעצם "הזרקת התקלה" שמוכיחה שספי ת"י 1205 (2%) נאכף ולא ואקום.
  - `lineIsSupply` (install_engine): קובע אספקה↔ניקוז, מכוסה בעקיפין בשערי
    audit40 / install_engine_safety (חוצה-מערכת).
- **אימות UI:** הודגם חי (build web + דפדפן) — קו ניקוז מציג "שיפוע ניקוז 2.0% —
  תקין (≥2% ת"י 1205)", ריאקטיבי לסליידרים (2.0%→4.6%). צילומי-מסך נשמרו.
- מסקנה: אין פונקציה חדשה לבדוק-מוטציה; ספי ה-2% כבר נעול בבדיקת-המנוע הקיימת.

## install_engine safety — _findBridge חוצה-מערכת (P2.4) + manifoldOutlets טקסונומיה (P2.5) — 2026-06-07

- **קובץ:** `test/install_engine_safety_test.dart` (חדש, 4 בדיקות).
- **מה עושה:** נועל (P2.4) ש-`buildInstallation` לעולם לא מגשר supply↔drainage —
  זוג חוצה-מערכת חייב לצאת כ-gap, לא כגשר; ו-(P2.5) ש-`manifoldOutlets` מסווג
  מחלק לפי טקסונומיית-הקטלוג (`'מחלקים'`), לא לפי ספירת-קצוות.
- תקלה שהוזרקה #1 (P2.5, שער-טקסונומיה): ניטרול
  `if (p.productType != 'מחלק' && p.categoryHe != 'מחלקים') return 0;` ב-`manifoldOutlets`.
- תוצאה: אדומה ✅ — "tee 116565 NOT a manifold" נכשל (החזיר 3 במקום 0).
  מחלקים אמיתיים (4/2/4) + צינור (0) נשארו ירוקים — הניטרול לא נוגע בהם.
- תקלה שהוזרקה #2 (P2.4, שתי שכבות-ההגנה): ניטרול גם ה-guard
  `if (shared.isEmpty) return null;` וגם פילטר ה-`canConnect` ב-`_findBridge`.
- תוצאה: אדומה ✅ — "never bridges supply↔drainage" נכשל עם **1600 גשרים
  חוצי-מערכת**. החזרת שכבה אחת בלבד → ירוק.
- ביטול שתיהן → ירוק ✅ — `+4 All tests passed`.
- מסקנה: P2.5 — שער אמיתי שתופס היפוך-סיווג (tee↔מחלק). P2.4 — הבדיקה אוכפת
  end-to-end את אי-חציית-המערכת; ה-guard הוא שכבת-בטיחות יתירה התואמת את ה-BFS
  (probe: 0/3600 ניתנים-להגעה היום, אז הגנה-בעומק ולא תיקון-דליפה-חי).

## install_engine hardening — kBspInchToMm + insertAt guard (B1) — 2026-06-07

- **קובץ:** `test/install_engine_hardening_test.dart` (חדש, 3 בדיקות).
- **מה עושה:** נועל (1) את `kBspInchToMm` — מקור-האמת היחיד לטבלת BSP אינץ׳→מ"מ
  שאוחד מ-3 עותקים מועתקים-ביד (install_engine `_minBoreMmOf` · pressure_drop
  `_boreMeters` · related_info `engineeringSpecFor`); ו-(2) את ה-guard ב-
  `_autoAddCompliance.insertAt` שמונע קריסת `clamp(1,0)` על קו חד-פריטי.
- תקלה שהוזרקה #1 (ערך-קוטר): `kBspInchToMm` `'1/2': 15` → `'1/2': 14`.
- תוצאה: אדומה ✅ — `at location ['1/2'] is <14> instead of <15>` (בדיקת הטבלה-המדויקת).
- תקלה שהוזרקה #2 (השבתת guard): `if (items.length < 2) return;` → `if (items.length < 0) return;`.
- תוצאה: אדומה ✅ — `buildInstallation([oneSupplyProduct], autoCompliance)` זרק
  `ArgumentError:<Invalid argument(s): 1>` (בדיוק קריסת ה-clamp שה-guard מונע);
  הבדיקה ציפתה `return normally`.
- ביטול שתיהן → ירוק ✅ — `+3: All tests passed!`.
- מסקנה: הבדיקה חזקה — תופסת גם סטיית ערך-בודד בטבלת-הקוטר המאוחדת וגם הסרה של
  ה-guard (רגרסיית-קריסה אמיתית), לא רק happy-path.

## cheaperAlternativesAcrossCatalog (T1) — 2026-06-04

- **קובץ:** `test/cheaper_alternatives_test.dart`
- **מה עושה:** סורק את `kHomeProductBrands` (proto §1b HOME_PRODUCTS) ומחזיר לכל מוצר את החלופה הזולה ביותר שמתחת למחיר ההמלצה; אוכף ≥3 חלופות, כל `altPrice<recPrice`, `savings>0`, וסדר-חיסכון יורד.
- תקלה שהוזרקה: `t.price < rec.price` → `t.price > rec.price` (בורר את הטיר היקר במקום הזול).
- תוצאה: אדומה ✅ — `Expected: a value less than <189> · Actual: <329>` (ברז לכיור בחר פרימיום).
- ביטול → ירוק ✅ — All tests passed.
- מסקנה: הבדיקה חזקה — תופסת היפוך של לוגיקת-הסינון המרכזית (זול↔יקר), לא רק קיום פלט.

## gate 117 closeout (v6.11) — full-snapshot parity לפולירול + חוליות — 2026-06-04

- **קבצים:** `test/_polyroll_snapshot.g.dart` (774) · `test/_huliot_snapshot.g.dart` (170).
- **מה עושים:** snapshot lock על כל nameHe+page של כל מק"טי הקטלוג.
- תקלה שהוזרקה (פולירול): `'צינור PPR אספקת מים 20'` → `'…אספקתX…'` (95016002).
  תוצאה: `Polyroll snapshot drift (1)` אדום ✅; ביטול → ירוק ✅.
- תקלה שהוזרקה (חוליות): `'ברך 15° צד אחד חלק 40'` → `'ברך 15X…'` (70041150).
  תוצאה: `Huliot snapshot drift (1)` אדום ✅; ביטול → ירוק ✅.
- מסקנה: ה-snapshots תופסים שינוי-תו-אחד בכל מ-944 המק"טים.

## gate 117 closeout — polyroll_pdf_parity_test — 2026-06-04

- **קובץ:** `test/polyroll_pdf_parity_test.dart` (חדש) — 20 SKUs מ-`kPolyrollCatalog`.
- **מה עושה:** snapshot lock על nameHe+page+brand של 20 פיפסים/אביזרים מייצגים.
- תקלה שהוזרקה: `'צינור PPR אספקת מים 20'` → `'…אספקתX…'` (95016002).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 closeout — huliot_pdf_parity_test — 2026-06-04

- **קובץ:** `test/huliot_pdf_parity_test.dart` (חדש) — 13 SKUs מ-`kHuliotCatalog`.
- **מה עושה:** snapshot lock על nameHe+page+brand של 13 ברכים/הגבהות/מכסים.
- תקלה שהוזרקה: `'ברך 15° צד אחד חלק 40'` → `'ברך 15X…'` (70041150).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 follow-up — lipskey_hierarchy_parity_test — 2026-06-04

- **קובץ:** `test/lipskey_hierarchy_parity_test.dart` (חדש) + `lib/data/chip_hierarchy.dart`.
- **מה עושה:** אוכף ש-parseChips מחזיר type+path תקינים ל-18 SKUs מייצגים של ליפסקי
  (תנאי-קדם להפעלת `_HierarchyChips` במקום `_NameWords`).
- תקלה שהוזרקה: `'מיכל הדחה'` → `'מיכלX הדחה'` ב-`_kCompoundTypes`.
- תוצאה: אדום ✅ — SKU 152785 (`מיכל הדחה טיטאן לבן`) נכשל ב-`type expected "מיכל הדחה"`.
- ביטול → ירוק ✅ — 18/18.
- מסקנה: הטסט אוכף את ה-compound-type lookup; שינוי שובר את שיוך-ה-type הגורף.

## gate 117 — lipskey_pdf_parity_test (מחסומי רצפה תיקניים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runFloorTrapGroup` (8 SKUs, עמ' 26–27).
- תקלה שהוזרקה: `'מחסום תיקני 140/50 פתוח'` → `'מחסום תיקניX 140/50 פתוח'` (218681).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (צינורות) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runPipeGroup` (57 SKUs, עמ' 47–48).
- תקלה שהוזרקה: ב-fixture 116101 color `'אפור'` → `'אפורX'`.
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (אביזרי תבריג) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runScrewOnGroup` (43 SKUs, עמ' 20–23).
- תקלה שהוזרקה: `'מחבר כפול תבריג 32/32'` → `'מחבר כפולX תבריג 32/32'` (116209).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (אטמים/פקקים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runGasketPlugGroup` (17 SKUs, עמ' 36–37).
- תקלה שהוזרקה: שינוי `'אטם לכוס 2"'` ל-`'אטם לכוסX 2qq'` (506525).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מאספים/כיסויים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runCollectorGroup` (19 SKUs, עמ' 30–33).
- תקלה שהוזרקה: `'רשת פנימית עגולה אפור'` → `'…אפורX'` (661360).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מצמדים/מצרות/פקקים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runConnectorGroup` (21 SKUs, עמ' 44–45).
- תקלה שהוזרקה: `'כובע אויר 110'` → `'כובע אוירX 110'` (120311).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מסעפים שקע-תקע) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runInsertionBranchGroup` (13 SKUs, עמ' 42).
- תקלה שהוזרקה: `'מסעף 45° 40/40'` → `'מסעף 45X 40/40'` (220305).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (ברכיים שקע-תקע) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה רביעית (`_runInsertionBendGroup`)
- **מה עושה:** fixture של 15 SKUs של ברכיים שקע-תקע (עמ' 40–41).
- תקלה שהוזרקה: `'ברך 87° 75'` → `'ברך 87X 75'` (116033).
- תוצאה: הבדיקה אדומה ✅.
- ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מחסומים גלויים) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה שלישית (`_runVisibleTrapGroup`)
- **מה עושה:** fixture של 32 SKUs מקטלוג ה-PDF (עמ' 8–15) — אגן 1.25", מטבח 2", אמריקאי 1.5"/2", צד, מאריכים+אביזרים.
- תקלה שהוזרקה: שינוי `'מחסום אמריקאי 1.5"'` → `'מחסום אמריקאיX 1.5"'` (218495).
- תוצאה: הבדיקה אדומה ✅ — `SKU 218495 · מחסום אמריקאי 1.5"`.
- ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מושבי אסלה) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה שנייה (`group('… מושבי אסלה')`)
- **מה עושה:** fixture של 26 SKUs מקטלוג ה-PDF (עמ' 53–55) + טסט פנטומים. אוכף `nameHe / color / qtyPack / qtyPallet / categoryHe / page` לכל מושב אסלה.
- תקלה שהוזרקה: `sed 's/מושב אסלה כרמל סגירה רכה לבן/מושב אסלה כרמלX סגירה רכה לבן/'` — שינוי שם דגם כרמל.
- תוצאה: הבדיקה אדומה ✅ — נכשלה ב-`SKU 195505 · מושב אסלה כרמל סגירה רכה לבן`.
- ביטול → ירוק ✅ — 51/51.
- מסקנה: הטסט תופס שינויי-שם גם בקטגוריה השנייה, באותה רמת דיוק.

## gate 117 — lipskey_pdf_parity_test (מיכלי הדחה) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` (חדש)
- **מה עושה:** fixture של 23 SKUs מקטלוג ה-PDF (עמ' 50–52) + טסט פנטומים. אוכף `nameHe / color / qtyPack / categoryHe / page / dims` של כל מיכל הדחה.
- תקלה שהוזרקה #1: `sed 's/מיכל הדחה ספיר לבן/מיכל הדחה ספירX לבן/' lib/data/lipskey_catalog.dart` — שינוי שם דגם של ספיר.
- תוצאה: הבדיקה אדומה ✅ — נכשלה ב-`SKU 124848 · מיכל הדחה ספיר לבן`.
- ביטול → ירוק ✅ — 24/24.
- מסקנה: הטסט תופס שינויי-שם ב-nameHe מקצה-לקצה, גם תווים בודדים.



- **קובץ:** `lib/data/polyroll_catalog.dart:609`
- **מה עושה:** factory function — יוצר `LipskeyCatalogProduct` לצינור PPR מיזוג אוויר (Aquatherm blue pipe). עוטף `_ppr()` עם קבועים ספציפיים ל-AC.
- **בדיקה:** `test/polyroll_catalog_test.dart` — ודא שמוצר AC Blue Pipe מופיע ב-`kPolyrollCatalog` עם SKU תקין.
- מסקנה: factory בלי לוגיקה — בדיקה מינימלית מספיקה (SKU קיים, קטגוריה נכונה)

## §22.H photo-only routing (_pprSpecFor: kPprElectrofusion + kPprTools) — 2026-05-31
- תקלה שהוזרקה #1: p72 routing `90→45` (כל ברך 90° מקבל spec של 45°).
- תוצאה: §22.H אדום ✅ (תפס את ה-swap, לא רק "לא page").
- תקלה שהוזרקה #2: p91 routing `תותב die→driver`.
- תוצאה: §22.H אדום ✅.
- מסקנה: הבדיקה חזקה — אחרי שחיזקתי מ-"not page + exists" ל-מיפוי-ספציפי
  פר-תת-סוג. הגרסה החלשה הראשונה הייתה עוברת את שני ה-swaps.

## §21 chip parser — angle vs size (parseChips/kChipLevel2Shape) — 2026-05-31
- תקלה שהוזרקה: החזרת bare '45','90' ל-kChipLevel2Shape (המצב הקודם).
- תוצאה: §21 angle test אדום ✅ — הקוטר 90mm נגנב לתא ה-shape, size=null.
- מסקנה: הבדיקה חזקה — תופסת גם את ה-collision של זווית-מול-קוטר וגם את
  הבליעה של sizeRe. הוזרק וחזר ירוק אחרי שחזור.

## §21 multi-word chip compound (_l3Compounds) — 2026-06-01
- תקלה שהוזרקה: מחיקת 'למיקום נקודת מים' מ-_l3Compounds.
- תוצאה: §21 multi-word test אדום ✅ — הביטוי התפזר ל-[מים, למיקום, נקודת].
- מסקנה: הבדיקה חזקה — מאמתת גם נוכחות הביטוי כ-chip אחד וגם היעדר פיזור.

## §21.B unit-fold — recoverability E2E (parseChips / _kChipUnits) — 2026-06-01
- תקלה שהוזרקה: הסרת ענף ה-unit-fold (`if (_kChipUnits.contains(t))`) מ-parseChips.
- תוצאה: §21.B test אדום ✅ — `מזוודת ריתוך קטנה 20-63 מ"מ` איבד את "מ"מ"
  (lost: מ"מ), השחזור מ-set-המילים נכשל.
- מסקנה: הבדיקה חזקה — תופסת כל נפילת token (לא רק מ"מ): משווה את כל set-המילים
  מקור↔שחזור על כל kPolyrollCatalog. הוזרק וחזר ירוק אחרי שחזור הענף.

## §21.C chip level labels (levelLabelOf / מידה anchor) — 2026-06-01
- תקלה שהוזרקה: שינוי `if (i == 0 && level5 != null) return 'מידה';` → return ''.
- תוצאה: §21.C test אדום ✅ — ציפי-הגודל בכל הקטלוג קיבלו label ריק, הבדיקה
  פלטה רשימה ארוכה של "size chip 'X' → '' (expected מידה)".
- מסקנה: הבדיקה חזקה — לא רק מאמתת קיום של אחת מ-5 תוויות אלא מצמידה את ציפ
  הגודל ספציפית ל-"מידה" (העוגן ל-leaf, כך שמשתמש תמיד יודע מה ה-bottom-of-chain).
  הוזרק, חזר ירוק אחרי שחזור.

### lib/data/polyroll_catalog.dart — 2026-06-01T15:00:31+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'מק"ט חוליות': sku,/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

## _sl — Huliot SmartLock factory (lib/data/huliot_smartlock_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart:61`
- **מה עושה:** factory — בונה `LipskeyCatalogProduct` עם brand='חוליות' ומזריק
  `יצרן='חוליות'` + `מק"ט חוליות'=sku` ל-dims אוטומטית (§22.I by-construction).
- תקלה שהוזרקה: הסרת `'יצרן': 'חוליות'` משדה ה-fullDims.
- תוצאה: הבדיקה הייתה אדומה ✅ — `§22.I every Huliot product carries יצרן`
  נכשל עם 170 קוויי "[no יצרן]".
- שחזור: byte-exact (החזרת השורה). הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת §22.I פר-מוצר. ה-factory pattern מבטיח שאי-אפשר
  לשכוח יצרן/מק"ט גם כשמוסיפים 170 מוצרים ב-batch.

## _brandDir — brand→dir mapping (lib/data/lipskey_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/lipskey_catalog.dart:49`
- **מה עושה:** static helper — ממפה brand string לתיקיית assets:
  פולירול→polyroll, חוליות→huliot_smartlock, אחר→lipskey.
- **בדיקה חיזק (2026-06-01 — סשן 100%):** נוסף `§22-Huliot every product
  asset resolves to assets/huliot_smartlock/` ב-spec_assets_test.dart שסורק
  כל imageAssets/specImageAssets של 170 מוצרי Huliot. בנוסף `§22-Huliot
  every Huliot page asset exists on disk` מוודא קיום פיזי.
- mutation_verify.sh ראשוני (תיעד את החולשה) → אחרי הוספת ה-test, mutation_verify
  שני (`s|if (brand == 'חוליות') return 'huliot_smartlock';|// removed|`) → אדום ✅.

### availableLensesForSet — 2026-05-31
- תקלה שהוזרקה: `>= smartTreeMinFraction` → `> smartTreeMinFraction` (סף עץ-חכם)
- תוצאה: הבדיקה הייתה אדומה ✅ ("exactly at the fraction → smart-tree included" נפל — 0.25 > 0.25 = false)
- תקלה שנייה: `if (products.any((p) => famSkus.contains(p.sku)))` → `if (true)` (variant תמיד)
- תוצאה: הבדיקה הייתה אדומה ✅ ("variant lens follows injected family membership" נפל — without-family ציפה לא-variant)
- מסקנה: הבדיקה חזקה — תופסת גם את גבול הסף (>=/>) וגם את תלות ה-variant במשפחה.

### groupByLens — 2026-05-31
- תקלה שהוזרקה: ב-smartTree case, `smartProductForSku(p.sku)` → `?? smartProductForSku(kLipskeyCatalog.first.sku)` (unmapped לא נזרק)
- תוצאה: הבדיקה הייתה אדומה ✅ ("smart-tree keeps ONLY mapped" — kept != mapped)
- תקלה שנייה: ב-variant case, `singletons.add(...)` → הוסר (singletons נזרקים)
- תוצאה: הבדיקה הייתה אדומה ✅ ("variant nothing dropped" — total != copper.length)
- מסקנה: הבדיקה חזקה — תופסת גם drop של unmapped ב-smartTree וגם drop של singletons ב-variant.

### cardReadinessScore (raised bar, 9 dims) — 2026-06-01
- שינוי: הנוסחה הורחבה מ-5 ל-9 ממדים (spec25/compat20/תקן12/התקנה13/קבלה5/תאימות5/מאתר5/מחיר5/וריאנט10), max 100.
- תקלה שהוזרקה: `score += 25` (spec) → `score += 0`.
- תוצאה: הבדיקה הייתה אדומה ✅ ("rich spec+connectable PPR hits top band" נפל — PPR ירד מ-95 ל-70 < 80).
- מסקנה: הבדיקה החדשה ("raised bar") חזקה — תופסת ירידת משקל ליבה. בנוסף: endpoint נשאר נמוך, ואין ממד יחיד שמגיע ל-100 (דורש רוחב).

### cardReadinessScore (quantity-aware) — 2026-06-01
- שינוי: הציון מודד עכשיו *כמות-ידע*, לא רק נוכחות בינארית. ממדים מדורגים: עומק-נתונים `p.dims.length` (≥8→15/4-7→10/1-3→5), חיבורים (≥20→18/≥5→12/>0→6), טיפים/קבלה/תאימות מדורגים לפי כמות. spec ירד 25→20, מחיר/מאתר ירדו.
- מניע (משוב משתמש): "לא תתסתכל על הכמות ידע שיש לו" — צינור PPR פייזר (dims=11, העשיר ביותר) קיבל ~75 בגלל compat=0; עכשיו 80 מצוין.
- תקלה שהוזרקה: ענף ה-dims `: 0` (אפס dims) → `: 50` (בונוס שמן ל-0 ידע).
- תוצאה: 2 בדיקות אדומות ✅ — "fixture endpoint (toilet seat) stays low" (אסלה קפצה 16→66 > 45) וגם "no single dimension reaches 100".
- מסקנה: הבדיקות תופסות ניפוח שגוי של מוצרים חסרי-ידע. אומת: PPR אספקה 98 · PPR פייזר 80 · אסלה 16 · סיפון כיור 63.

### cardReadinessScore (composite breadth+depth) — 2026-06-01
- מניע (משוב משתמש): "שישקף גם וגם משולב … ויתן ציון משוכלל משניהם" — ציון אחד שמשלב שני צירים.
- שינוי: הנוסחה פוצלה לשני תת-ציונים (כל אחד ≤50) ומוחזרים ב-record:
  • רוחב (breadth) — נוכחות משוקללת של *סוגי* ידע שונים (spec10/חיבור8/dims6/תקן6/התקנה5/וריאנט4/טיפים4/קבלה3/תאימות2/מאתר1/מחיר1).
  • עומק (depth) — *כמות* בתוך הסוגים המדידים (dims ≥8→18/4-7→12/1-3→6 · חיבורים ≥20→16/≥5→10/>0→5 · טיפים/קבלה/תאימות מדורגים).
  composite = breadth + depth (cap 100). מוצר רחב-ושטחי או עמוק-וצר נופל לאמצע; רק רחב+עמוק מגיע ל-מצוין.
- תוצאות מאומתות: PPR אספקה 99 (b49/d50) · PPR פייזר 75 (b41/d34, נענש על 0 חיבורים בשני הצירים אך מקבל קרדיט מלא על 11 dims) · אסלה 15 (b11/d4) · סיפון 55 (b40/d15). Lipskey top: 29 מוצרים ≥80, max 85 (צינורות גמישים b50/d35).
- תקלה שהוזרקה: `var score = breadth + depth` → `var score = breadth` (התעלמות מעומק).
- תוצאה: 2 בדיקות אדומות ✅ — "composite == breadth + depth" וגם "raised bar PPR hits top band" (PPR צנח ל-49<80).
- מסקנה: הבדיקות נועלות גם את הזהות composite=breadth+depth וגם את שילוב שני הצירים בפועל.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-01T19:21:42+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'יצרן': 'חוליות',/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/lipskey_catalog.dart — 2026-06-01T19:22:05+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (brand == 'חוליות') return 'huliot_smartlock';|// removed for mutation test|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Huliot smart-tree wiring (v5.62) — 2026-06-02
- שינוי: 17 מק"טי חוליות נוספו כ-SmartBrand ל-4 כרטיסי-ניקוז (floorDrain+7,
  basinTrap+3, kitchenDrain+4, washingMachineDrain+3). כיסוי עץ-חכם 293→310.
- תקלה שהוזרקה: מק"ט חוליות מחובר '70124599' → '00000000' (לא קיים בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — smartproduct_contract "Huliot … wired into the
  smart-tree" (spot-check sku→card + card-has-Huliot-brand) וגם "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: הקישור מוגן דו-שכבתית — test/smartproduct_contract_test + harness
  lib/test_harness/tests/catalog.dart (צעד 77).

### Huliot smart-tree wiring batch 2 (v5.63) — 2026-06-02
- שינוי: +62 מק"טי חוליות (צנרת PP) כ-SmartBrand ל-4 כרטיסים: pvcPipe+7,
  drainageElbow+27, drainageFittings+20, visibleTrap+8. כיסוי 310→372, חוליות 79/170.
- תקלה שהוזרקה: מק"ט ברך מחובר '70033960' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: הכיסוי המורחב מוגן; כל 8 הכרטיסים נבדקים שיש בהם מותג חוליות + spot-check.

### Huliot smart-tree wiring batch 3 (v5.64) — 2026-06-02
- שינוי: +38 מק"טי חוליות כ-SmartBrand: roofCollector+8 (מאספים), drainChannel+10
  (AQUA SLIM), floorCover+20 (מכסים/רשתות). כיסוי 372→410, חוליות 117/170.
- תקלה שהוזרקה: מק"ט AQUA SLIM מחובר '60150331' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 11 הכרטיסים מוגן (spot-check + ≥117 ממופים).

## _huliotImageFor — per-family crop routing (lib/data/huliot_smartlock_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart:46`
- **מה עושה:** switch פר-עמוד (11-43) שמנתב כל מוצר Huliot ל-crop פר-משפחה
  `sml_p{NN}_{a|b|c|d}.jpg` לפי keyword ב-nameHe. החליף את ה-fallback של
  עמוד-מוקטן (`page_NN.jpg`) ב-88 תמונות מוצר חתוכות (§17.1).
- **בדיקה:** `test/spec_assets_test.dart §17.1-Huliot every product front
  image exists + is a real crop` — מאמת (א) imageAsset קיים על דיסק; (ב) אינו
  `/pages/page_` (פרט לעמ' 27 AQUA SLIM). סורק 170/170.
- תקלה שהוזרקה: שינוי `case 11:` להחזיר `'page_11.jpg'` במקום `_p(11,'a')`.
- תוצאה: §17.1-Huliot אדום ✅ — "still on whole-page fallback" עם 7 מוצרי
  צינור (עמ' 11) שחזרו ל-page image.
- שחזור: החזרת `_p(11,'a')`. הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת כל regression לעמוד-מוקטן (הפרת §17.1). זו
  בדיוק התלונה של המשתמש ("איפה תמונות לפי פרוטוקול") — עכשיו test-guarded.

## parseChips — Huliot vocab + parser-skip cosmetics (lib/data/chip_hierarchy.dart) — 2026-06-01
- **קובץ:** `lib/data/chip_hierarchy.dart`
- **מה השתנה:** (א) tokenizer מדלג על '-', '—', '/' (separators קוסמטיים).
  (ב) ב-loop, raw token עם parens עוטפות → strip לפני vocab lookup.
  (ג) מספר נומרי אחרי `l5` נצמד אליו ב-space (היה ?? = pin to first only).
  (ד) kChipTypes/Level2/Level3 + _l3Compounds הורחבו ב-100+ tokens של Huliot.
- **בדיקות:**
  - `test/spec_assets_test.dart §21.B-Huliot every product fully recoverable
    via parseChips` — סורק 170/170; recon = type + path + leftover; כל מילה
    בשם (אחרי norm + skip '-/—//') חייבת להופיע ב-recon; leftover חייב להיות
    ריק. עבר 170/170.
  - `test/spec_assets_test.dart §21.C-Huliot every visible chip carries
    semantic level label` — כל chip ב-path מקבל אחת מ-{חיבור/צורה/תכונה/
    תבריג/מידה}; size chip תמיד 'מידה'. עבר.
- **תקלות שהוזרקו:**
  - הסרת ענף ה-`(raw.startsWith('(') && raw.endsWith(')'))` (paren-strip) →
    §21.B-Huliot אדום ✅ עם 12 מקרים `leftover: סיפון` (כש-(סיפון) לא matchen).
  - שינוי `l5 == null ? t : '$l5 $t'` → `l5 ??= t` (multi-numeric drop) →
    §21.B-Huliot אדום ✅ עם `missing: 3000/4000` ב-7 מוצרי צינור.
- שני המוטציות שוחזרו → ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת כל regression בפרסר שמשפיעה על תכולת ה-card
  (משאיר מילה מאחור = מילה מתאדה מה-UI = הפרת §14.E).

## FinderGroup 'דלוחין SmartLock' — finder_screen.dart — 2026-06-01
- **קובץ:** `lib/screens/finder_screen.dart:71` (אחרי 'צנרת PPR')
- **מה עושה:** קבוצת home שמאחדת 17 קטגוריות kSml* תחת label אחד
  ("🟢 דלוחין SmartLock"); 170 מוצרי Huliot נספרים תחתיה במסך הבית.
- **בדיקה:**
  - `test/wiring_test.dart` "named groups are pairwise disjoint" — מאמת
    שאין קטגוריה משותפת לשתי קבוצות. תפס שה-'סיפונים' הופיע גם בניקוז וגם
    ב-SmartLock; כשעדכנתי `kSmlSiphons = 'סיפונים SmartLock'`, הבדיקה עברה ירוק.
  - `test/finder_group_icons_test.dart` "every group has dedicated icon/image" —
    מאמת שלכל קבוצה יש Material icon ייעודי + תמונה ייעודית.
- תקלה שהוזרקה: החזרת `kSmlSiphons = 'סיפונים'` (הערך הקודם).
- תוצאה: שני בדיקות אדומות ✅ — `pairwise disjoint` שיכפל את 'סיפונים'
  בין ניקוז ו-SmartLock; `paranoid 12-check` לא נפגע (catRoot mapping של
  הבדיקה מסתמך על categoryHe).
- שחזור: החזרת `'סיפונים SmartLock'`. הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת collision של category-set בין שתי קבוצות
  finder. זו ההגנה היחידה שמבטיחה ש-finder.home לא מציג מוצר באותו פעם
  באף one of two distinct groups (UX duplicate).

### lib/data/related_info.dart — 2026-06-02T13:07:53+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#if (p.brand == 'חוליות') return (emoji: '🟢', label: 'דלוחין SmartLock');#// mutated#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/polyroll_e2e_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T13:42:06+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'יח׳\/ארגז': '90', 'יח׳\/משטח': '3,780'}/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T14:17:05+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#if (has('מוגבהת')) return _p(30, 'a');#// mutated#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T14:37:52+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#return _p(27, 'a');#return 'page_27.jpg';#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### system_division (productDivisionSystems · filterBySystem · nodeHasSystem) — 2026-06-02
- **קובץ:** `lib/logic/system_division.dart` · בדיקה: `test/system_division_test.dart`
- **מה עושה:** ליבת חלוקת מים/שפכים (בנצי #1) — סיווג מוצר/צומת-עץ ל-WaterSystem.
- תקלה שהוזרקה #1: ב-`productDivisionSystems` הפכתי את fallback ה-PPR מ-`supply` ל-`drainage`.
- תוצאה: אדום ✅ — `'PPR ... → supply'` נתפס (הכלל שהמשתמש קבע: PPR=מים נקיים).
- תקלה שהוזרקה #2: ב-`nodeHasSystem` הסרתי את שורת ה-`_fixtureTitles` (מתקנים
  לא יופיעו בשני הצדדים).
- תוצאה: אדום ✅ — `'fixture (אסלות) shows under BOTH systems'` נתפס (כלל option 2).
- תקלה שהוזרקה #3: ב-`filterBySystem` החזרתי `list` גם כש-system≠null (ביטול הסינון).
- תוצאה: אדום ✅ — `'supply filter keeps only supply'` נתפס.
- שחזור: שלושתן הוחזרו → הרצה ירוקה (9/9) ✅.
- מסקנה: הבדיקה חזקה — מכסה את שלושת הכללים (PPR=נקיים, מתקנים בשני צדדים, סינון ממשי).

### system_division — פאזה 2b (smartProductSystems · filterSmartBySystem) — 2026-06-02
- **קובץ:** `lib/logic/system_division.dart` · בדיקה: `test/system_division_test.dart`
- **מה עושה:** סינון עץ-חכם — ממפה את ה-SKU של מותגי ה-SmartProduct חזרה לקטלוג
  כדי לסווג כל מוצר-חכם למערכת (לא-פתיר → נשאר בשני הצדדים).
- תקלה שהוזרקה A: ב-`smartProductSystems` שיניתי `p.sku == sku` ל-SKU שלעולם
  אינו קיים (אף התאמה → כל מוצר "לא-פתיר").
- תוצאה: אדום ✅ — `'brand-SKU mapping resolves'` **וגם** `'filter discriminates'`
  נתפסו (הכול הפך ל"בשני הצדדים" → sup==dr==all).
- תקלה שהוזרקה B: ב-`filterSmartBySystem` החזרתי `list` תמיד (no-op, ביטול הסינון).
- תוצאה: אדום ✅ — `'filter discriminates — supply/drainage pools differ'` נתפס.
- שחזור: שתיהן הוחזרו → 14/14 ירוק ✅.
- מסקנה: הבדיקה חזקה — מכסה מיפוי-לא-no-op, אי-היעלמות (supply∪drainage מכסה הכול),
  והבחנה ממשית (48 נקיים · 58 שפכים מתוך 81; 23 supply-only · 33 drainage-only).

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T18:16:15+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|return 'spec_$img';|return 'spec_sml_p99_z.jpg';|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Huliot smart-tree wiring batch 4 (v5.72) — 2026-06-02
- שינוי: +9 מק"טי חוליות כ-SmartBrand: tools+4 (חותכים+מפתחות), drainageFittings+5
  (אומי-חיבור). חוליות 117→126/170. הנותרים (~44) = אביזרי-סיפון (SmartAcc), לא כרטיסים.
- תקלה שהוזרקה: מק"ט חותך מחובר '79904070' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 12 הכרטיסים מוגן (spot-check + ≥126 ממופים).

### _huliotImageForCrop — R2-fallback helper extraction (v5.80) — 2026-06-02
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart`
- **מה עושה:** ה-routing הקנוני (per-page tag mapping) חולץ ל-`_huliotImageForCrop`.
  `_huliotImageFor` עכשיו מחזיר `page_NN.jpg` כברירת-מחדל (R2-fallback)
  כל עוד `_routeCropDisabled = true`. כשהדגל יוסר → חוזר לקרוא ל-helper הקנוני.
- תקלה שהוזרקה: `s|return 'page_\${page.toString().padLeft(2, '0')}.jpg';|return null;|`
  (לדמות מצב שבו ה-fallback בעצמו נכשל).
- תוצאה: §17.1-Huliot אדום ✅ — `${p.sku} → null imageAsset`.
- מסקנה: ה-guard המוקל ("exists") עדיין תופס נפילה מוחלטת, ולא רק crop-vs-page.

### Huliot smart-tree wiring batch 5 — spare-parts card (v5.78) — 2026-06-02
- שינוי: כרטיס חדש `smlSpareParts` עם 44 מק"טי אביזרי-סיפון/מחסום כ-SmartBrand.
  כיסוי חוליות 126→**170/170 (100%)**.
- תקלה שהוזרקה: מק"ט אטם מחובר '67750440' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 13 הכרטיסים מוגן (spot-check + ≥170 ממופים).

### lib/logic/install_kit.dart — 2026-06-02T20:25:13+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (p.brand == 'חוליות')|if (p.brand == 'מותג-שלא-קיים')|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/polyroll_e2e_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Unified-catalog reads (v5.90) — 2026-06-03
- איחוד שלושה תיקונים על origin (עבודת v5.85–87, יושמה-מחדש אחרי ש-origin התקדם ל-v5.89):
  כרטיס-ריק (אחים מ-kCatalogProducts + guard), חיפוש-מק"ט (matchProducts על המאוחד),
  מועדפים/שורת-עגלה (kCatalogProducts).
- אימות: cartLineDisplay('lip:64032300') → שם-קטלוג ולא fallback;
  catalogProductMatchesQuery על kCatalogProducts מוצא 64032300, על kLipskeyCatalog ריק.
- נשאר Lipskey בכוונה: searchSuggestions (autocomplete) + ספירת-מתכנן.

### lib/data/chip_hierarchy.dart — 2026-06-03T17:46:43+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (brandOf(q) != brand) continue;|if (brandOf(q) == brand) continue;|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/huliot_picker_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

## resolveCatTitle / catNodeProductCount (category_division.dart) — 2026-06-03
- **קובץ:** `lib/logic/category_division.dart`
- **מה עושה:** ממפה כותרת-מחלקה (`kDeptCatHeadings.titles`) לצומת-עץ (top-node /
  leaf / synthetic) + סופר מוצרים תחתיו — הבסיס לתצוגת כלים-מול-צנרת (בנצי #1).
- תקלה שהוזרקה: `return null;` בראש `resolveCatTitle` (כל כותרת → לא-נפתרת).
- תוצאה: `category_division_test` אדום ✅ (3 בדיקות נפלו — "does not resolve" +
  flat-products ריקים למים/שפכים/אסלות).
- שחזור: byte-exact מ-backup; הרצה חוזרת 5/5 ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת מיפוי שבור (כל ערך חייב להיפתר לצומת עם >0 מוצרים, R8).

## דו-מערכתיים בשתי הכותרות (category_division.dart) — 2026-06-03 (v5.97)
- **קובץ:** `lib/logic/category_division.dart` (`kDeptCatHeadings['אינסטלציה']`)
- **מה עושה:** דו-מערכתיים (אטמים/חבקים/עוגנים/סטי-הידוק) רשומים תחת **שתי**
  הכותרות 💧 צינורות מים + 🟤 צינורות שפכים — נגישים מכל כותרת (בנצי #1).
- תקלה שהוזרקה: הסרת בלוק 5 הדו-מערכתיים מכותרת **שפכים**.
- תוצאה: `category_division_test` אדום ✅ (`+5 -1`) — נתפס ע"י הבדיקה החדשה
  "dual-system fittings appear under BOTH מים and שפכים headings (#1)"
  ("אטמים ופקקים missing from צינורות שפכים").
- שחזור: הבלוק הוחזר; הרצה חוזרת 6/6 ירוק ✅.
- מסקנה: הבדיקה חזקה — דורשת שכל דו-מערכתי יופיע בשתי הכותרות (ולא רק באחת).

### contractor_seeds helpers (T0) — 2026-06-04
- helpers: bestStore/fMoney/caToday/budgetLevel.
- אימות: שברתי מפריד-אלפים של fMoney (`% 3 == 0`→`% 3 == 9`) → contractor_seeds_test
  אדום ("Expected ₪9,840 · Actual ₪9840") ✅. שחזור → 8/8 ירוק.
- מסקנה: הבדיקה תופסת רגרסיה ב-helper.

### lib/data/persona_data.dart — 2026-06-03T23:58:26+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|t.worker == worker && statuses.contains|t.worker != worker \&\& statuses.contains|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/worker_app_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### ManagerAnalytics — 👔 dashboard derivations (lib/logic/manager_dashboard.dart) — 2026-06-03
- **קובץ:** `lib/logic/manager_dashboard.dart` · בדיקה: `test/manager_dashboard_test.dart`
- **מה עושה:** פורט PURE של `mgrAnalytics()` (@index.html:12081-12126) — `ManagerAnalytics`
  גוזר את 5 ה-mdMetric tiles (openOrders/catalogCount/accessoryCount/availableCount/
  storesLabel) ע"י fold על seed שפורט verbatim (STORES · SYS_ORDERS_SEED · התפלגות
  TREES · STORE_STOCK). כל מספר אומת מול הלולאה החיה ב-index.html (node-replay).
- תקלה שהוזרקה #1: ב-`catalogCount` הפכתי `totalProducts - accessoryCount` →
  `totalProducts + accessoryCount`.
- תוצאה: אדום ✅ — `'📦 catalogCount = non-accessory products = 54'` נפל (350≠54) וגם
  `'catalog + accessory == total'` (ה-split כבר לא ממצה).
- תקלה שהוזרקה #2: ב-`openOrders` הפכתי `o.isOpen` (`stage != 'delivered'`) ל-`!o.isOpen`.
- תוצאה: אדום ✅ — `'🚚 openOrders … = 4'` נפל (0≠4; אף הזמנה לא 'delivered').
- תקלה שהוזרקה #3: ב-`activeStores` הפכתי `where((s) => s.on)` ל-`where((s) => !s.on)`.
- תוצאה: אדום ✅ — `'🏪 stores = … 3/3'` נפל (`storesLabel`="0/3").
- שחזור: שלושתן הוחזרו → 12/12 ירוק ✅.
- מסקנה: הבדיקה חזקה — נועלת כל אחד מ-5 ה-tiles למספר ה-verbatim, וגם את אקסיומת
  ה-split (catalog+acc==total) ואת ה-flow (כל seed stage ∈ ORDER_FLOW). מוטציה בכל
  getter נתפסת. (`contractorCredit`/`mgrCustomerList` = foundation ל-M3, נבדקים גם הם:
  band 30k-120k · דטרמיניסטיות · group-by-buyer aggregation.)

### lib/screens/contractor_tools_sheets.dart — 2026-06-07T05:23:07+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/b.savings.compareTo(a.savings)/a.savings.compareTo(b.savings)/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/cheaper_alternatives_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/logic/ai_hub_logic.dart — 2026-06-07T18:44:40+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/int get save => fromPrice - toPrice/int get save => toPrice - fromPrice/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/t3_ghi_rewards_ai_home_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/settings_tree.dart (Wave 6 — מחיקה) — 2026-06-07
- שינוי ה-lib/(logic|data) ב-commit זה = **מחיקת data מת בלבד**: `kSettingsGroups`/`walkSettings`
  (~70 עלים const, 0 צרכנים, הוחלף ע"י מסכי-ההגדרות). אין logic/התנהגות למוטציה — נתון const שהוסר.
- שאר Wave 6 (autoStock→OOS · chat-history cleared-flag · העברת `storeOosProvider` ל-lib/state) ב-
  lib/screens|state; ל-`markOos` המועבר אין בדיקה ייעודית (ההתנהגות נשמרה verbatim בהעברה).
  מכוסה ב-suite הירוק של השער (analyze 0 · tests · build · conformance 7/7 · required-tests).

### lib/state/store_stock.dart — 2026-06-07T19:16:48+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/{...state, name}/{...state}/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/store_stock_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/state/sys_chat.dart — 2026-06-07T23:13:55+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/t.participants.contains(role)/true/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/sys_chat_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/repositories/stock_local.dart — 2026-06-08T00:12:00+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/stockDemo() => kStockDemo;/stockDemo() => const <String, String>{};/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/repositories_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/repositories/finance_local.dart — 2026-06-08T00:53:36+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/int budgetTotal() => kBudgetTotal;/int budgetTotal() => 0;/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/repositories_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/screens/profile_screen.dart — 2026-06-08T17:27:45+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/activePersona == null/activePersona != null/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/deep_fix_regression_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/lipskey_smart_data.dart — 2026-06-08T18:59:32+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/אטמים ופקקים/אטמים אומים ופקקים/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/lipskey_category_keys_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-08 (manual)
- שינוי: `_routeCropDisabled = true` → `false`, `_specCropDisabled = true` → `false`
- מטרה: הפעלת תמונות-מוצר חתוכות (159 crops כבר ב-assets, WIP v45-v52)
- תוצאה: האפליקציה מציגה sml_pXX_X.jpg במקום page_XX.jpg לכל 170 מוצרי חוליות
- תיקוני gate-32 (spec_assets_test 0→53 PASS):
  - `_huliotImageFor` כעת מחזיר page-fallback (לא null) כשאין crop ספציפי
  - p24 אטם (seal): routing מוחזר null → page_24.jpg (sml_p24_a.jpg לא נוצר ב-crop_huliot.py)
  - `_missingSpecs` set: 11 קבצי spec שלא נוצרו (p11_b, p30_d, p32_a, p36_b, p38_a, p39_b/c, p40_a/c/41_c, p42_a/b/c/d)

### lib/data/product_images.dart — 2026-06-08T21:04:22+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/semanticLabel == null/false/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/product_image_a11y_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.
### 2026-06-09 — מסך-בית חכם / מחיקת 'הכל' (UI-wiring)
- מוטציה 1: שינוי `catalogSectionProvider` ברירת-מחדל `'בית'`→`'מאתר'` → `hard_tests "default catalog landing"` אדום (Expected 'בית', Actual 'מאתר') ✅ נתפס; שוחזר.
- מוטציה 2: הסרת תיקון ה-overflow (`Flexible`/`Expanded` ב-_MiniTile/_SmartTreeCard) → robustness 1/12 RenderFlex overflowed אדום ✅; שוחזר.
- כיסוי: widget_test "בית" smart-home shows wired section blocks · robustness 1/12/18 render · hard_tests default-landing.

### 2026-06-09 — מסך-הבית מסונכרן-הגדרות (UI-wiring)
- מוטציה 1: קיבוע `crossAxisCount: 4` (התעלמות מ-`gridColumns`) → הבית לא מגיב לעמדות-רשת בהגדרות (אומת ויזואלית: gridColumns=2 צריך 2 עמודות) ✅; שוחזר.
- מוטציה 2: `childAspectRatio` במקום `mainAxisExtent` → ב-2 עמודות אריחים ענקיים (חצי-מסך-ריבועי) ✅ נתפס ויזואלית; שוחזר ל-`mainAxisExtent` קבוע.
- מוטציה 3: החזרת `reverse: true` → גלילה הפוכה ב-RTL ✅; שוחזר.
- כיסוי: אימות ויזואלי חי (אין טסט-יחידה ל-layout-metrics; נבדק בעין על :5556).

### 2026-06-09 — server-S2 (rebuild): cache-pattern base (`firestore_cached_repo`)
- מוטציה (ידנית — הסקריפט flaky על restore): נטרול עדכון-ה-cache האופטימי ב-`upsert` (`_cache = _sorted(next)` → `_sorted(_cache)`) → `firestore_cached_repo_test` **-5 אדום** ✅ נתפס; שוחזר byte-clean (0 markers) → **+20 ירוק**.
- כיסוי: 20 טסטים על fake-source — seed-ראשוני · snapshot מחליף+notify · doc פגום מדולג · optimistic מיידי (assert סינכרוני) · כשל-כתיבה לא משחית/זורק · replaceAll/resetToSeed/removeById · empty-ראשון≠מאוחר · roundtrip מיפוי+סדר · provider=local בלי Firebase. (נבנה-מחדש אחרי שה-restart גלגל את הקומיט הלא-דחוף.)

### 2026-06-09 — server-S3 (rebuild): גל הנחיל ×5 (`stock_firebase` כנציג)
- מוטציה (ידנית): נטרול flip-המיקום ב-`move` (`'site' : 'warehouse'` → `'warehouse' : 'warehouse'`) → `stock_firebase_repo_test` **-2 אדום** ✅ נתפס; שוחזר byte-clean (0 markers) → **+10 ירוק**.
- כיסוי-גל: 46 טסטים חדשים (customers 9 · stock 10 · site 13 · finance 11 · catalog-guard 3) — fake-sources, אפס deps; provider=local בלי Firebase בכל דומיין; ה-base עצמו mutation-verified ב-S2.
### 2026-06-10 — lib/logic/input_validators.dart (חדש · #64 נחיל)
- מוטציה: `^05\d{8}$` → `^05\d{7,8}$` (קבלת נייד בן 9 ספרות) → `test/input_validators_test.dart` אדום ("mobile — 9 digits (too short) is invalid": Expected false, Actual true) ✅ נתפס.
- שחזור: regex הוחזר byte-exact; הרצה חוזרת 27/27 ירוקה ✅.
- מסקנה: הבדיקה חזקה — מכסה אורך/קידומת/תווים לכל 5 הוולידטורים (27 cases).
- `lib/data/legal_texts.dart` (חדש · #26): const-strings בלבד (תנאי-שימוש/פרטיות) — אין לוגיקה למוטט; מכוסה עקיף ע"י analyze + legal_screen רנדור.

### 2026-06-10 — server-S1+S4: Auth + Real-time (`auth_state` כנציג)
- מוטציה (ידנית): הסרת אימות-תפקיד-מוכר ב-`rolesFromClaims` (`single is String && known.contains(single)` → `single is String`) → `auth_state_test` **-1 אדום** ✅ נתפס; שוחזר byte-clean → **+24 ירוק**.
- כיסוי-גל: 59 טסטים חדשים (auth_state+login_sheet 41 · chat_firebase 10 · realtime_wiring 8) — fake gateway/sources, אפס deps; ללא-Firebase = byte-identical להיום (signed-out picker · מנועים local).

### 2026-06-10 — server-S5/S6/S8/S9: גל-הסגירה (`offline_order_queue` כנציג)
- מוטציה (ידנית): שבירת FIFO ב-`drainQueue` (`pending.first` → `pending.last` = LIFO) → `offline_order_queue_test` **-2 אדום** ✅ נתפס; שוחזר byte-clean → **+9 ירוק**.
- כיסוי-גל: 25 טסטי-flutter חדשים (queue 9 · push_state 15 · S9.3-pin ב-cache-repo 1) + **85/85 rules-emulator** (S5, רץ אמת מול ה-emulator) + **53/53 functions selftest** (S8, כולל אימות bit-for-bit של dartStringHashCode מול dart run).

### 2026-06-10 — server-gate: דגל-בקאנד default-OFF (`backend.dart`)
- מוטציה (ידנית): הפיכת ברירת-המחדל של הדגל ל-true (`bool.fromEnvironment('USE_FIREBASE_BACKEND', defaultValue: true)`) → `backend_flag_test` **-1 אדום** ✅ נתפס; שוחזר byte-clean → **+1 ירוק**.
- כיסוי: `backend_flag_test` נועל את ברירת-המחדל (demo/_local ללא-define, ללא-Firebase) — ה-live נשאר דמו עד הדלקה מפורשת. 11 אתרי-switch דרך `useFirebaseBackend`.
### 2026-06-10 — lib/data/board_accounts_local.dart + lib/state/board_auth.dart (חדשים · #65 נחיל-לוחות)
- מוטציה: קוד-הכניסה של ran שונה '1111'→'9999' → `test/board_auth_test.dart` אדום (4 בדיקות: login-success/persist/case-insensitive/race-guard — Expected session, Actual null) ✅ נתפס.
- שחזור: byte-exact; הרצה חוזרת 8/8 ירוקה ✅.
- מסקנה: בדיקות-הזהות חזקות — מכסות הצלחה/כישלון/persist/דמו/logout/קוד-החלפה.
- `lib/data/chat_seeds.dart` (חדש · #70/#75): seed-בלבד (שיחות audience) — מכוסה עקיף ע"י בדיקות ה-chat הקיימות + analyze.

### 2026-06-10 — worker-v2 (לוגיקה חדשה ב-lib/state + lib/data/task_skus_local)
- באג-אמיתי שנתפס ע"י בדיקת-שמירה (לא מוטציה מלאכותית): vacation_requests — שתי בקשות באותה אלפית-שנייה קיבלו אותו id (web=דיוק-ms) → החלטה אחת אישרה את שתיהן; הבדיקה 'decision touches ONLY the given id' אדומה → תוקן `_seq` מונוטוני → ירוקה. תיעוד כ-mutation-equivalent (fault אמיתי→red→fix→green).
- task_skus_local.dart: seed-בלבד (מיפוי משימה→מק"טים, DEMO-SEED) — מכוסה ע"י רנדור 'מה להביא' + analyze.

### 2026-06-11 — uid-migration A2+A3 (נחיל Phase A · builder+supervisor)
- **A2 — `currentUidProvider` (`lib/state/auth_state.dart`):** מוטציה — `return ref.watch(authStateProvider).user?.uid` → `return null` → `auth_state_test` קבוצת 'currentUidProvider — A2' **אדום** (signed-in: Expected 'u-42' / Actual null, שורה 422) ✅ נתפס; שוחזר byte-clean → ירוק.
- **A3 — `Order.contractorUid` (`lib/state/orders_engine.dart`):** מוטציה (supervisor) — שבירת ה-preservation ב-copyWith `contractorUid: contractorUid,` → `contractorUid: ''` → `orders_uid_a3_test` 'a stage advance (copyWith) keeps the contractor uid' **אדום** (Expected 'u-9' / Actual '') ✅ נתפס; שוחזר byte-clean (grep-count חזר ל-3) → +8 ירוק.
### 2026-06-11 — lib/data/chat_seeds.dart (#83 threads-ספק · נחיל-קנוני)
- מוטציה: audience 'store'→'worker' על thread-ספק → **שרדה** (חור-כיסוי!) → נוספה בדיקת-נעילה (sys_chat_test: 4 ids חייבים audience 'store') → מוטציה חוזרת **נתפסה** (אדום) → שוחזר → ירוק. לקח: seed-fields שמשפיעים-על-נראות חייבים נעילת-בדיקה.
### 2026-06-11 — personal-v2 #86/#87 (נחיל קנוני · orchestrator)
- **`lib/data/supplier_data.dart` — `deliveredRevenue`:** חור-כיסוי נמצא (אפס בדיקות לשדה) → נוספה בדיקה ל-t9 ('deliveredRevenue counts ONLY delivered orders'). מוטציה — הוספת `|| transit` לסינון → **אדום** (seed: BS-1039 ב-transit, ציפייה 0) ✅ נתפס; שוחזר → 12/12 ירוק.
- **`lib/state/persona_fulfillment.dart` — `courierUser` fromJson:** מוטציה — `j['cu']…` → `null` קבוע → `persona_fulfillment_test` **אדום** (Expected 'noam'/Actual null, round-trip+stamp) ✅ נתפס; שוחזר → 20/20 ירוק.
- **`lib/state/vacation_requests.dart` — back-compat `role`:** מוטציה — ברירת-מחדל decode `'worker'`→`'courier'` → `vacation_requests_test` **אדום** (Expected 'worker'/Actual 'courier' — legacy חייב עובד) ✅ נתפס; שוחזר → 11/11 ירוק.

### 2026-06-11 — חיבור הגדרות-תצוגה בקטלוג (נחיל גל-2 מנה-1)
- **`lib/state/catalog_settings.dart` — `priceWithVat`:** מוטציה — `base*(1+kVatRate)` → `base` קבוע → `catalog_price_units_settings_test` **אדום** (2 assertions: Expected 117/'~₪117', Actual 100/'~₪100') ✅ נתפס; שוחזר byte-clean (cp) → 16/16 ירוק.

### 2026-06-11 — מיון-קטלוג (נחיל גל-2 מנה-2)
- **`catalog_screen.dart`/`catalog_settings.dart` — `sortCatalogProducts` nameAZ:** מוטציה — היפוך ה-comparator (descending) → `catalog_sort_alerts_settings_test` nameAZ **אדום** (['B-200','C-300','A-100'] ≠ ['A-100','C-300','B-200']) ✅ נתפס; שוחזר (cp) → 16/16 ירוק.

### 2026-06-11 — חיבור התראות in-app (נחיל גל-2 מנה-3)
- **`lib/state/worker_notifs.dart` — `boardFeedEnabled`:** מוטציה — זרוע-העובד `=> true` קבוע → `notif_settings_wiring_test` **אדום** (3: personaWorker/master/restore gating) ✅ נתפס; שוחזר (backup) → 14/14 ירוק.

### 2026-06-11 — כלי-AI על דאטה אמיתי (נחיל גל-4 · supervisor)
- **`lib/logic/ai_hub_logic.dart` — `computeStockForecast`:** מוטציה — fold-הצריכה `+ li.qty` → `- li.qty` → `ai_hub_compute_test` **אדום** (5 assertions: rate/urgent/span/on-hand/aggregate) ✅ נתפס; שוחזר (cp, md5 חזר) → 14/14 ירוק.

### 2026-06-12 — הכנת-זהות A8 (נחיל)
- **`lib/state/sys_chat.dart`/`chat_firebase.dart` — `fromUid`:** מוטציה — שבירת כתיבת/round-trip של fromUid → `chat_uid_a8_test` **אדום** (Expected 'u-7'/Actual null) ✅ נתפס; שוחזר → ירוק.

### 2026-06-12 — מדריך users lookup A7 (נחיל)
- **`lib/data/repositories/users_lookup.dart` — predicate-הטלפון:** מוטציה — `== phone` → `!= phone` → `users_lookup_a7_test` **אדום** (4: hit→uid-שגוי · miss→החזיר-uid · role-narrow→null) ✅ נתפס; שוחזר (cp) → 10/10 ירוק.

### 2026-06-13 — בעלות-הזמנה A4-A6 (נחיל)
- **`firestore.rules` — no-steal (`claimOnlySelf`/`unassignedOrMine`):** מוטציה (emulator) — נטרול ל-true → 2 steal-tests **אדום** (25/2) → שוחזר → 27/0.
- **`lib/state/orders_engine.dart` — `claimStore` no-steal:** מוטציה — הסרת ה-guard → 'store אחר לא יכול לגנוב' **אדום** (Expected store-a/Actual store-b) → שוחזר.

### 2026-06-13 — server-swap זהות-לוח seed→Firebase (אני, לא נחיל)
- **`lib/state/board_auth.dart` — `boardSessionFromAuthSnapshot` (helper טהור):** מוטציה — `return null` קבוע בראש ה-helper (מנטרל את כל הגזירה) → `board_auth_server_test` **אדום** `+5 -7` (7 בדיקות שמצפות session: store-claim/each-role/multi-role/no-displayName/sign-in/אינווריאנט/sign-out נפלו; 5 שמצפות null נשארו ירוקות) ✅ נתפס; שוחזר byte-מדויק (cp מגיבוי, **לא** git checkout — שלא לאבד את SW2/SW3) → 12/12 ירוק.

### 2026-06-13 — A9 צ׳אט participantUids (נחיל)
- **`lib/state/sys_chat.dart` — `chatThreadVisibleToUid` (helper טהור):** מוטציה — הסרת סעיף empty-is-visible (`participantUids.isEmpty || participantUids.contains(uid)` → `participantUids.contains(uid)`) → `chat_uid_a9_test` 'an EMPTY participantUids is VISIBLE to anyone (legacy/un-migrated)' **אדום** (Expected: true / Actual: \<false\>, `+5 -1`) ✅ נתפס; שוחזר (cp מגיבוי `/tmp/A9_sys_chat.dart.bak`, **לא** git checkout — שלא לאבד את שדה ה-A9 הלא-מקומט) → `+6` ירוק.
- **`firestore.rules` — `chatThreads` read (membership על participantUids):** מוטציה (emulator) — החלשת ה-read ל-`if isSignedIn();` (הסרת `request.auth.uid in resource.data.get('participantUids', [])`) → 3 בדיקות-chat **אדום** (`a NON-member is DENIED` · `a display ROLE in participants never gates` · `a LEGACY thread matches no uid` — כולן 'Expected request to fail, but it succeeded', chat.test.js:95) → 39/3 fail · שוחזר (cp מגיבוי `/tmp/A9_firestore.rules.bak`) → **42/42/0** ירוק.
- **defect שתוקן (לא מוטציה — באג-אמת):** `rules_test/chat.test.js` החדש חלק `PROJECT_ID = 'demo-buildsmart'` עם `orders.test.js`; `node --test` מריץ את שני הקבצים **במקביל** מול emulator יחיד, ו-`clearFirestore` של קובץ אחד מחק את ה-docs שזרע השני באמצע-בדיקה → ה-`get()` החוצה-מסמך של חוקי chatMessages על thread-האב נכשל ("Service call error") → כשל פלאקי (1-2) בחיוביים תלויי-seed. תיקון: project-id ייעודי `demo-buildsmart-chat` (מבודד namespace, אפס-נגיעה ב-orders). chat-לבד 7/7 דטרמיניסטי; combined 42/42/0 ב-3/3 ריצות.

### 2026-06-13 — A14 צ׳אט last-mile: אכלוס participantUids אמיתי (נחיל)
- **הפער שנסגר:** A9 הוסיף את `participantUids` כשדה inert (מעולם לא אוכלס → תמיד ריק → "ריק=גלוי-לכולם" → אפס בידוד-אמיתי). A14 מאכלס אותו באמת: `ChatEngineNotifier.ensureParticipantUids` פותר את **האיחוד** של uids-התפקידים (A7 `uidsByRole`) + uid-השולח וחותם על ה-thread, gated ב-`uidScoped` (default `kUidScopedQueries`).
- **`lib/state/sys_chat.dart` — `ensureParticipantUids` (אכלוס-האיחוד):** מוטציה — שבירת לולאת-האיחוד (`union.addAll(await lk.uidsByRole(role.name))` → `await lk.uidsByRole(role.name);` בלי addAll, כלומר זריקת ה-uids של התפקידים) → `chat_uid_a14_populate_test` **`+3 -3` אדום**: 'flag ON: a send STAMPS the union' (Expected Set{uid-c,uid-s1,uid-s2} / Actual Set{uid-c} — רק השולח שרד) · 'ensureParticipantUids on thread OPEN' (אותו {uid-c}) · 'VISIBLE to a member, NOT to a non-member' (Expected true/Actual false — חבר-החנות uid-s1 נשמט → ה-rules-twin מבודד אותו, מוכיח שהאכלוס הוא מה שמניע את הבידוד האמיתי) ✅ נתפס. נעילות אפס-הרגרסיה (flag-OFF stays empty) + resolve-once + compile-time-OFF נשארו ירוקות (המוטציה נגעה רק באיחוד).
- שחזור: `cp /tmp/A14_sys_chat.dart.bak lib/state/sys_chat.dart` (**לא** git checkout — שלא לאבד את קוד-ה-A14 הלא-מקומט); md5 חזר ל-`efc72d1dff51673d130252879fe8c5b4` → הרצה חוזרת **+6 ירוק**.
- **`lib/data/repositories/chat_firebase.dart` / `chat_repository.dart` — `setParticipantUids`:** seam-נתיב-השרת לחתימת ה-head (toDoc של A9 כבר persist את participantUids כשלא-ריק). מכוסה עקיף ע"י ההוכחה הנ"ל (הנתיב-המקומי) + בדיקות-ה-chat הקיימות (`chat_uid_a9_test` toDoc/fromDoc) + analyze. הנתיב-המקומי (engine IS the store) הוא מה שהבדיקות מריצות (Firebase-free).
- **emulator:** ללא שינוי-rules → 42/42/0 (אומת מחדש; לא נדרשו בדיקות-rules חדשות).

### 2026-06-13 — שיחות/וידאו V1+V2 (calls/video): כפתורי 📞/💬 + הסתרת עץ-הגדרות-מת (אני)
- **`lib/logic/input_validators.dart` — `waMeDigits` (helper טהור, נרמול טלפון→wa.me):** מוטציה — הפלת המרת ה-0→972 (`digits = '972${digits.substring(1)}';` הוערה החוצה) → `input_validators_test` **`+31 -3` אדום**: 'waMe — Israeli local 0501234567 → 972501234567' (Expected '972501234567' / Actual '0501234567') · 'waMe — separators…' (אותו) · 'waMe — does NOT double-prefix…' (אותו) ✅ נתפס. נעילות אפס-הרגרסיה (empty→'' · already-972 untouched · 00-prefix) נשארו ירוקות (המוטציה נגעה רק בענף-ה-0-המקומי). שחזור: `cp /tmp/input_validators.dart.bak lib/logic/input_validators.dart` (**לא** git checkout); md5 חזר ל-`1d2bd4145ffe5ad25876a31904d90de6` → הרצה חוזרת **+34 ירוק**.
- **`lib/data/search_index.dart` — הסרת עץ 'הגדרות שיחות' המת (V2):** הוסר ה-entry העליון (`title: 'הגדרות שיחות'`) + כל תת-העץ (~40 leaves: שיחות-וחיווי/אישורי-קריאה/חיווי-הקלדה/התראות-שיחה/צלצול-שיחה-נכנסת/מדיה-ושמע/דחיסת-וידאו/פרטיות/גיבוי-וייצוא/שפה/עסקיות/בוט/ארכיון). נעול ע"י `call_settings_hidden_test` (8 כותרות-מת נעדרות + אפס breadcrumb תחת 'הגדרות שיחות' + ה-entry 'שיחות' של הצ׳אט-האמיתי **נשמר** + 3 עצי-הגדרות-שכנים נשמרים). אין helper חדש בקובץ זה → לא נדרשה מוטציה ייעודית (זו data-list); הבדיקה היא ה-guard הביצועי לבייטים.

### 2026-06-13 — order-card 📞/💬: customerPhone על ההזמנה (V1 last-mile · נחיל)
- **הפער שנסגר:** V1 (8709129) נתן `ContactActions` על chat + כרטיסי-פרופיל, אבל ל**כרטיס-ההזמנה** לא היו כפתורים — אף order-model לא נשא טלפון (Order/SysOrder חשפו רק `who`=שם-תצוגה). הוחלט (בעל-המוצר): על כרטיס-הזמנה ה-📞/💬 מגיעים ל**מי שהזמין** (הקבלן). שדה additive `Order.customerPhone` (default `''`, כתיבה-מוגנת כמו `contractorUid`/`storeUid`) ← נחתם ב-checkout (`store_screen` = `userProfileProvider.contact`) → מוקרן ל-`SysOrder.customerPhone` (`sys_orders._toSysOrder`). **לא flag-gated** — ה-default-הריק + empty-guard של ContactActions הם אפס-הרגרסיה (seed/legacy → אין כפתורים).
- **`lib/state/orders_engine.dart` — `Order.fromJson` קריאת `customerPhone`:** מוטציה — `customerPhone: (j['customerPhone'] as String?) ?? ''` → `customerPhone: ''` קבוע (זריקת הקריאה) → `orders_engine_test` 'Order.customerPhone … a phone is WRITTEN and round-trips losslessly when non-empty' **אדום `+26 -1`** (Expected '050-123 4567' / Actual ''); נעילות אפס-הרגרסיה (EMPTY omitted · fromJson defaults '' · copyWith preserves · placeOrder stamps/defaults) נשארו ירוקות (המוטציה נגעה רק בקריאה-כשקיים) ✅ נתפס. שחזור: `cp /tmp/orders_engine.dart.bak lib/state/orders_engine.dart` (**לא** git checkout); md5 חזר ל-`3bf5bdaa4f54e16ffa87a44e84f9fb6e` → הרצה חוזרת **+27 ירוק**.
- **`lib/data/repositories/orders_firebase.dart` / `orders_local.dart` / `orders_repository.dart` — חתימת `placeOrder` + toDoc/fromDoc:** השדה עבר דרך כל ה-impls (guarded-write `if (o.customerPhone.isNotEmpty)` ב-toDoc · default-read ב-fromDoc) מירור מדויק ל-`contractorUid`/`storeUid`. מכוסה ע"י `orders_uid_a3_test` קבוצת customerPhone (Firestore shape: WRITTEN+round-trip · EMPTY omitted · fromDoc defaults '') + analyze.
- **test-doubles שתוקנו לשינוי-החתימה (האנטי-דפוס החוזר):** `_RecordingOrdersRepo` (`offline_order_queue_test.dart`) + `_SpyOrders` (`site_firebase_repo_test.dart`) — שניהם `implements OrdersRepository`, הוסף להם הפרמטר `String customerPhone = ''` (ל-recording גם `customerPhone: customerPhone` ב-Order שהוא בונה). analyze 0-errors תפס שהם חייבים עדכון; שניהם ירוקים.
- **gate:** `flutter analyze` (כל הקבצים הנגועים) — 0 errors/warnings (רק info קיימים-מראש; אפס info חדש). `flutter test` מלא — **+2233 All tests passed** (היה +2222; +11: order_card_contact_actions +2 · engine customerPhone +6 · a3 customerPhone +3). `flutter build web --release` — ✓ Built. לוגיקת בעלות-הזמנה (A4-A6/A14 claim/scope/uid) **לא נגעתי** — customerPhone שדה עצמאי.

### 2026-06-14 — 4 כפתורים-מתים/מזויפים → התנהגות-אמת (ביקורת-launch · נחיל)
4 fixes; מוטציה מלאה הורצה על FIX#1 (share), שאר ה-3 מכוסים ע"י בדיקות-effect ייעודיות.
- **FIX#1 (share) · `lib/screens/store_screen.dart` — טקסט-השיתוף ב-`_CartActionsRow`:** מוטציה — `final text = 'סל BuildSmart:\n$items\n\nסה״כ: ₪$total';` → `final text = 'MUTANT';` (Edit) → `cart_share_test` 'tapping שתף hands the cart summary to the share seam' **אדום** (`Expected: contains 'מלט' / Actual: 'MUTANT'`) ✅ נתפס — הבדיקה מוכיחה שטקסט-הסל-האמיתי זורם ל-seam, לא no-op. שחזור: `cp /tmp/store_screen.bak.dart lib/screens/store_screen.dart` (**לא** git checkout) → הרצה חוזרת **2/2 ירוק**.
- **FIX#3 (order-now) · `lib/logic/ai_hub_logic.dart` — `computeStockForecast` קטיף emoji+unitPrice:** מכוסה ע"י `ai_hub_compute_test` 'carries REAL emoji + unit price from the latest order line' (יחידה: line אחרון 🪨/200÷4 → `emoji='🪨'`, `unitPrice=50`) + widget 'הזמן עכשיו adds the recommended item to the live cart' (טאפ → `smartCartProvider` גדל ב-1, line `ai-restock:PEX` עם emoji-אמת). שבירת הקטיף (החזרת `📦`/`0`) הייתה מפילה את היחידה — הבדיקה היא ה-guard הביצועי.
- **FIX#2 (favorite) · `lib/screens/smart_home_screen.dart` — onTap של אריח-מועדף:** אין helper טהור (UI-wiring) → מכוסה ע"י `favorite_tile_opens_sheet_test` (טאפ אריח-כוכב → `LipskeyProductSheet` נפתח; `onTap: () {}` המקורי היה מפיל את ה-`findsOneWidget`).
- **FIX#4 (PDF) · `lib/logic/finance_report_pdf.dart` — `buildFinanceReportPdf`:** מכוסה ע"י `finance_pdf_export_test` — הבונה-הטהור חייב להפיק bytes לא-ריקים שמתחילים ב-magic `%PDF` (שבירת ה-`addPage` הייתה מפילה את `isNotEmpty`/`'%PDF'`); ה-widget-test מוכיח שטאפ 'הדפסה' מזריק את אותו doc ל-`pdfPrintProvider` (seam). 
- **gate:** analyze (כל הקבצים הנגועים) 0 errors/warnings (4 קבצים-חדשים נקיים) · full-suite **+2241 All tests passed** (היה +2233; +8) · build web ✅ Built (printing נפתר web). pubspec.lock לא staged.

### 2026-06-14 — A13 קידום-שלב + אשראי → Cloud Functions callables (gated, אני)
- **הפער שנסגר:** `advanceOrderStage`+`computeCredit` קיימות בשרת (+טריגר `revertIllegalOrderStageWrite` שמחזיר כתיבת-stage ישירה לא-חוקית), אבל ה-client עשה direct optimistic Firestore writes + hash-אשראי מקומי שעוקפים את השרת+S5. A13 מחווט נתיב-callable **gated** מאחורי `kServerCallables` (default OFF, דפוס `kUidScopedQueries`/`uidScoped`), forward-ready ל-deploy+flip של הבעלים. seam חדש `OrderFunctionsGateway` (mirror ל-`AuthGateway`; `FirebaseOrderFunctionsGateway` פותר `FirebaseFunctions.instanceFor(region: me-west1)` עצלן, מתרגם `FirebaseFunctionsException`→ניטרלי). OFF + provider-gateway null מחוץ ל-live-backend = byte-identical.
- **`lib/state/orders_engine.dart` — `_advanceViaCallable` (החלת ה-`{to}` הקנוני של השרת):** מוטציה — `remote.applyServerStage(orderId, result.to)` → `result.from` (החלת השלב-הישן במקום החדש) → `orders_credit_a13_callable_test` 'flag ON: advance INVOKES advanceOrderStage … applies the server's {to} LOCALLY' **אדום `+0 -1`** (Expected: 'preparing' / Actual: 'new' — השלב לא התקדם). נעילות OFF (direct set) + FunctionsException + credit נשארו ירוקות (המוטציה נגעה רק בהחלה-המקומית של ה-advance). ✅ נתפס. שחזור: `cp /tmp/A13_oe_final.bak lib/state/orders_engine.dart` (**לא** git checkout — שלא לאבד את קוד-ה-A13); md5 חזר ל-`7ab77ca974d951979977414a200e55b4` → הרצה חוזרת **+8 ירוק**.
- **מוטציה שנייה (נעילת ה-tension optimistic↔callable) · `advance`:** הוספת `r.advance(orderId)` בענף-ON (כלומר גם יורה את ה-direct write שהטריגר היה מחזיר) → אותו test **אדום** (`Expected: empty / Actual: [BS-1042…]` על `src.sets` — הוכחה בייט-לבייט ש-ON אסור שיירה `set` ישיר). שוחזר → ירוק. זו ההוכחה שה-test נועל באמת את "ה-callable הוא הכתיבה הקנונית; ה-client לא יורה direct set".
- **`lib/data/repositories/customers_local.dart`/`customers_firebase.dart` — `computeCredit` (נתיב-אשראי):** gated זהה; ON→callable `computeCredit({name})`, OFF→גזירה-מקומית זהה לדשבורד (`contractorCredit`+spend-fold+`pct`/`balance`), FunctionsException→fallback מקומי (בלי לזייף). מכוסה ע"י אותו test (ON-credit מזמן+מחזיר server figures · OFF-credit local זהה+callable-לא-נקרא · FunctionsException→fallback · default-OFF). ה-`creditLimit(name)` הסינכרוני (נתיב-הדשבורד) **לא נגעתי** — אפס-רגרסיה.
- **`lib/data/repositories/firestore_cached_repo.dart` — `upsertLocalOnly`:** תאום LOCAL-only ל-`upsert` (cache+notify, **בלי `set`**) — הנתיב שבו הכתיבה-הקנונית נעשית במקום-אחר (ה-callable). `lib/data/repositories/orders_firebase.dart` — `applyServerStage` (stage-only מעליו). `lib/data/repositories/backend.dart` — ה-flag. `lib/data/repositories/customers_repository.dart` — מתודת-interface `computeCredit` אדיטיבית.
- **gate:** `flutter analyze` (כל ~8 הקבצים הנגועים + ה-test) — **0 errors/warnings**; אפס info-lints חדשים (אומת מול HEAD: `firestore_cached_repo` 82/103 + `orders_engine` 27/57/219/243 קיימים-מראש). `flutter test` מלא — **+2260 All tests passed** (היה +2252; +8). `flutter build web --release` — ✓ Built. לוגיקת uid/chat-message **לא נגעתי**. (הערה: ה-codebase בסגנון-formatter ישן; `dart format` היה מעצב-מחדש קוד-קיים → שוחזר ל-HEAD ושוכתב בסגנון-המקור, diff = additions בלבד.)

## A14 — צילומי-תמונה → R2 upload דרך `getUploadUrl` (gated, אני) — 2026-06-14

- **הפער שנסגר:** כל תמונה (POD/before-after/פרופיל/לוגו/תעודה) = `data:…;base64` data-URL ב-localStorage (~1.5MB, ללא sync); ה-callable `getUploadUrl` (`functions/src/r2.ts`, presigned-PUT ל-R2) קיים אבל ה-client לא קרא לו. A14 מחווט נתיב-העלאה **gated** מאחורי `kCloudPhotos` (default OFF, נפרד מ-`kServerCallables`), forward-ready ל-provision+deploy+flip של הבעלים. seam חדש `UploadFunctionsGateway` (mirror ל-`OrderFunctionsGateway`; `FirebaseUploadFunctionsGateway` פותר Functions עצלן, מתרגם `FirebaseFunctionsException`→ניטרלי) + seam שני `PhotoHttpPut` (ברירת-מחדל `http.put`). חוזה: השרת מחזיר `{url,key,…}` (אין public-URL בחוזה); ה-publicUrl מורכב `{kImageBaseUrl}/{key}`.
- **`lib/services/task_photo.dart` — `uploadCapturedPhoto` (החזרת ה-URL הציבורי על 2xx):** מוטציה — `return target.publicUrl;` → `return target.uploadUrl;` (אחסון ה-presigned-PUT URL במקום הציבורי) → `cloud_photos_a14_upload_test` **`+10 -2` אדום**: 'ON: a capture INVOKES getUploadUrl … stores the PUBLIC url' (Expected `https://pub-test.r2.dev/pod/u/9-photo.jpg` / Actual `https://r2.example/put/k1?sig=AAA`) + 'uploadCapturedPhoto … publicUrl on a 2xx' (Expected publicUrl / Actual upload-url) ✅ נתפס. נעילות OFF (byte-identical) + 3 ה-fallbacks (getUploadUrl-throw/PUT-403/PUT-throw) + gif + display נשארו ירוקות (המוטציה נגעה רק באחסון-ה-URL בנתיב-ה-2xx). שחזור: `cp /tmp/task_photo.dart.bak lib/services/task_photo.dart` (**לא** git checkout — שלא לאבד את קוד-ה-A14) → הרצה חוזרת **+12 ירוק**.
- **קבצים נגועים (lib/services|lib/state|lib/data):** `lib/services/task_photo.dart` (נתיב-העלאה + seams + gate) · `lib/data/repositories/upload_functions.dart` (חדש — ה-seam) · `lib/data/repositories/backend.dart` (ה-flag `kCloudPhotos`) · `lib/widgets/photo_viewer.dart` (`imageProviderForRef`/`showFullPhotoRefDialog`/`isHttpPhotoRef`) + ~12 אתרי-רינדור (screens). `lib/state/persona_fulfillment.dart` — **לא** נגעתי (ה-side-map שומר את ה-String כמו-שהוא; ON מאחסן https, OFF מאחסן base64 — אותו mechanism).
- **gate:** `flutter analyze` (כל הנגועים) — **0 errors** (info/warning קיימים-מראש בלבד). `flutter test` מלא — **+2272 All tests passed** (היה +2260; +12). `flutter build web --release` — ✓ Built. pubspec.lock **לא** staged. לוגיקת uid/chat/orders-callable **לא נגעתי**.
### 2026-06-14 — גל-D פוליש (#98 · נחיל אמיתי)
- **`lib/state/vacation_requests.dart:132` — back-compat decode של role:** מוטציה — `: 'worker'` → `: 'courier'` (ברירת-מחדל ל-payload ישן בלי 'role'). הבדיקה החדשה 'P-12 worker filter — an OLD payload without role is counted as the worker's (back-compat)' **אדומה** (Expected ['vac-legacy-demo'] / Actual []) + #86.3 back-compat האדים גם → ✅ נתפס; שוחזר byte-clean → 13/13 ירוק.
- **כיסוי כן:** סינון-המסך של P-12 (worker_forms_screen.dart, r.role=='worker') מכוסה רק עקיפות — ה-unit-test משכפל את ביטוי-הסינון ומאמת את מודל-ה-role/back-compat שעליו הוא נשען, לא קורא מה-widget. דפקט-המודל (back-compat) כן נתפס במוטציה; רגרסיה בשורת-המסך עצמה תיתפס רק ב-widget-test ייעודי (לא נכתב — פוליש).

## podSignature / strokesToPngDataUrl — pad-חתימת-POD אמיתי — 2026-06-14
- **קובץ:** `test/signature_pad_test.dart` (חדש) · helper חדש `strokesToPngDataUrl` (`lib/widgets/signature_pad.dart`).
- **מה עושה:** נועל ש-strokes אמיתיים → PNG data-URL לא-ריק (PNG-magic), dot→חתימה, pad-ריק→**null** (אין זיוף), ושה-save פולט data-URL לא-ריק / מושבת כשריק.
- תקלה שהוזרקה: encode-success `return 'data:image/png;base64,${base64Encode(bytes)}'` → `return null`.
- תוצאה: **אדומה ✅** — 4 נכשלו ('Expected: not null' · preview/save/dot). שוחזר `cp /tmp/sig.bak` (**לא** git checkout) → **+8 ירוק**.
- מסקנה: ה-encode load-bearing; pad-ריק→null אמיתי. אימות-orchestrator **fast-mode** (ממוקד + מוטציה-ממוקדת; הסוויטה המלאה ב-pre-push build-gate).

## גל H2 — approve-back הדרכות (guard pending) — 2026-06-14
- **קובץ:** `lib/state/worker_trainings.dart:340` (ה-guard ב-`_decide`) · בדיקה `test/contractor_training_approval_test.dart`.
- **מוטציה:** הסרת שמירת-ה-guard — `if (t.id == id && t.status == kTrainingPending)` → `if (t.id == id)` (approve היה מאשר **כל** סטטוס, כולל recorded/rejected — דריסת ה-no-op).
- **תוצאה:** **אדומה ✅** — 'approve on a non-pending (recorded) training is a no-op' נכשל ('recorded stays recorded' · Differ at offset 0). שוחזר ה-guard ב-Edit (**לא** git checkout) → **+15 ירוק** (שני קבצי-H2: contractor_training_approval + contractor_certs).
- **מסקנה:** ה-guard `status == kTrainingPending` load-bearing — בלעדיו approve/reject היו מחיים החלטה סופית/דורסים סטטוס. ה-lifecycle הדו-כיווני (pending→approved/rejected, no-op אחרת) אמיתי ונעול.

## גל H3 — מדיניות מסמכים-נדרשים (normalized-exact, לא substring) — 2026-06-14
- **קובץ:** `lib/state/docs_readiness.dart:104` (ההצלבה ב-block-3 של `workerDocsReadiness`) · בדיקה `test/contractor_required_docs_test.dart`.
- **מוטציה:** `normalizeDocName(c.name) == key` → `key.contains(normalizeDocName(c.name))` (req מכיל cert — מלכודת-substring שממציאה סיפוק: דרישה 'בטיחות בגובה' היתה 'מסופקת' ע"י תעודת 'בטיחות' חלקית).
- **תוצאה:** **אדומה ✅** — 'a substring-only cert does NOT satisfy a longer requirement' נכשל (Actual: <true>). שוחזר ל-`==` ב-Edit (**לא** git checkout) → **+23 ירוק** (8 gate + 15 policy).
- **מסקנה:** ההצלבה normalized-exact load-bearing — לקח E2 (אין-המצאות) נעול גם בשער-הבטיחות; substring היה חוסם/משחרר עובדים על סמך התאמה-חלקית מזויפת.

## גל S — נוכחות employer-scope (בידוד קבלן↔עובד) — 2026-06-14
- **קובץ:** `lib/state/worker_attendance.dart:308` (פילטר `attendanceForEmployer`) · בדיקה `test/contractor_attendance_test.dart`.
- **מוטציה:** `if (d.employerId == employerId)` → `if (d.employerId != employerId)` (היפוך — הקבלן היה רואה את נוכחות כל-מי-שאינו-שלו).
- **תוצאה:** **אדומה ✅** — 4 טסטי-scope נכשלו (lands-in-roster · unstamped-excluded · clockOut-preserves · deterministic-order). שוחזר ל-`==` ב-Edit (**לא** git checkout) → **+7 ירוק**.
- **מסקנה:** בידוד-המעסיק load-bearing — הוא לב חיווט-קבלן↔עובד; היפוך-הפילטר דלף נוכחות חוצת-מעסיקים. שליחים מודרים-במבנה (חנות-נוכחות נפרדת), לא תלוי בפילטר הזה.

## גל G1 — בידוד מחזור-חיים: הצעת-עובד מול השלמה — 2026-06-14
- **קובץ:** `lib/state/tasks_engine.dart:636` (ה-guard ב-`approveProposal`) · בדיקה `test/contractor_task_proposal_test.dart`.
- **מוטציה:** הסרת ה-guard — `if (t == null || t.status != 'proposed')` → `if (t == null)` (approveProposal היה מאשר **כל** סטטוס, כולל review/pending → התנגשות עם מחזור-ההשלמה).
- **תוצאה:** **אדומה ✅** — 'GUARD: the proposal lifecycle and the completion lifecycle do NOT collide' נכשל. שוחזר ה-guard ב-Edit (**לא** git checkout) → **+5 ירוק**.
- **מסקנה:** ה-guard `status=='proposed'` load-bearing — מפריד את `approveProposal`(proposed→active) מ-`approve`(review→done); בלעדיו הצעת-עובד הייתה מאושרת במסלול-ההשלמה (כולל הענקת-מטבעות/קידום-הזמנה שגויים).

## גל G2 — גאנט: len floored at 1 (פריסה טהורה) — 2026-06-14
- **קובץ:** `lib/logic/tasks_gantt.dart:163` (`lenDays`) · בדיקה `test/contractor_task_gantt_test.dart`.
- **מוטציה:** `lenDays: t.days < 1 ? 1 : t.days` → `lenDays: t.days` (משימת days==0 קיבלה bar באורך 0 — נעלמת מהציר).
- **תוצאה:** **אדומה ✅** — 'a days==0 task still occupies one cell (lenDays floored at 1)' נכשל. שוחזר ב-Edit → **+15 ירוק**.
- **מסקנה:** ה-floor load-bearing — כל משימה משובצת תופסת לפחות תא אחד (אחרת בלתי-נראית בגאנט). הפריסה טהורה+דטרמיניסטית, **אין-המצאת-תאריך** (scheduledStart==null → unscheduled, לא bar).

## גל G3 — ליקויים: מסנן ה-kind (פריסה טהורה) — 2026-06-14
- **קובץ:** `lib/state/tasks_engine.dart:909` (`defectsProvider` kind filter) · בדיקה `test/contractor_defects_test.dart`.
- **מוטציה:** `if (t.kind == 'defect')` → `if (t.kind != 'defect')` (היפוך — defectsProvider החזיר משימות-רגילות במקום ליקויים).
- **תוצאה:** **אדומה ✅** — 4 טסטי-ליקויים נכשלו (createTask-defect · editTask · round-trip · proposeTask-defect). שוחזר ל-`==` → **+5 ירוק**.
- **מסקנה:** מסנן-ה-kind load-bearing. **+ תיקון-מפקח:** `_openDefect` חתם employerId מ-session ריק (תפקיד-מנהל) → ליקוי-קבלן נעלם מרשימתו; תוקן ל-`kDemoContractorId` (כמו `_TaskAuthorSheet`). [פער-מבחן ידוע: render-test של הגיליון תחת session-מנהל — parked עם שאר ה-widget-tests.]
## #C11 — Apple-readiness HIDE-pass (kHideUnderConstruction · kVisibleSearchIndex) — 2026-06-14
- **קבצים (lib/state|lib/data):** `lib/state/under_construction.dart` (חדש — הדגל `kHideUnderConstruction` + `kHiddenSearchTitles`) · `lib/data/search_index.dart` (getter חדש `kVisibleSearchIndex` שמסנן placeholder-titles · ה-const `kSearchIndex` נשאר verbatim). (UI: `_SectionTile` ב-4 מסכי-הגדרות · `ai_hub_screen` `_visibleTiles`/`visibleToolIds` · chats/persona_portal/courier_portal_tab/persona_picking_sheet/tasks_screen guards.)
- **תקלה שהוזרקה:** `kVisibleSearchIndex => kHideUnderConstruction ? […filtered] : kSearchIndex` שונה ל-`=> false // MUTATION` (כלומר תמיד מחזיר את הרשימה המלאה → 3 ה-titles ה-deferred דולפים לחיפוש החי).
- **תוצאה:** `apple_readiness_hide_pass_test` 'kHiddenSearchTitles are absent from kVisibleSearchIndex' **אדומה `+0 -1`** ✅ נתפס (Expected isEmpty / Actual contains 'התאמה משולשת'…). שוחזר `cp /tmp/search_index.dart.bak lib/data/search_index.dart` (**לא** git checkout — לשמר את קוד-ה-C11) → **`+1` ירוק**.
- **מסקנה:** ה-getter המסנן load-bearing; ה-hide הפיך (ה-const נשאר). gate: analyze 0-errors · full-suite +2300 · build web ✅.

## G4 — telemetry seam + installCrashlyticsHandlers (Crashlytics+Analytics, Firebase-gated) — 2026-06-14
- **קבצים (lib/state + lib/main):** `lib/state/telemetry.dart` (חדש — ה-seam `TelemetrySink`: `NoopTelemetrySink` no-op default + `FirebaseTelemetrySink` עצלן; `telemetryProvider` מגודר `useFirebaseBackend`; `TelemetryEvents`; extension `logError`) · `lib/main.dart` (`installCrashlyticsHandlers` `@visibleForTesting` — closures מוזרקות; הגוש המגודר `if (Firebase.apps.isNotEmpty)` מתקין `FlutterError.onError`/`PlatformDispatcher.onError` ומפעיל collection ב-`!kDebugMode`). אירועי-משפך ב-`store_screen.dart` (order_placed) + `manager_role_assign_sheet.dart` (role_assigned + app_error).
- **`lib/main.dart` — `installCrashlyticsHandlers` (חיווט handler-השגיאות):** מוטציה — הוסר `recordFlutterError(details);` מתוך `FlutterError.onError` (כלומר שגיאת-framework מוצגת ב-`presentError` אבל **לא** מדווחת ל-Crashlytics).
- תוצאה: `telemetry_test` 'installCrashlyticsHandlers — Flutter framework error → recordFlutterError' **אדומה `+7 -1`** ✅ (Expected: a single recorded FlutterErrorDetails / Actual: []). שאר 7 (no-op-gate, forward-when-enabled, logError-compose, platform-async→recordError+true, debug-gate) נשארו ירוקים — המוטציה נגעה רק בנתיב-ה-framework.
- שחזור: `cp /tmp/main.dart.bak lib/main.dart` (**לא** git checkout — לשמר את קוד-ה-G4) → הרצה חוזרת **+8 ירוק**.
- מסקנה: ה-`recordFlutterError(details)` load-bearing — בלעדיו שגיאות-framework לא היו מגיעות ל-dashboard. ה-no-op gate נעול (provider=`NoopTelemetrySink` ללא-Firebase ⇒ demo byte-identical). gate: analyze 0-errors (כל הנגועים, אפס `Color(0xFF1A1A1A)` חדש) · full-suite +8 (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש) · build web ✅. pubspec.lock **לא** staged.

## F2 + G3 — App Check native (prod providers behind flag) + token-enforcement client — 2026-06-14
- **קבצים (lib/main + lib/data):** `lib/data/repositories/backend.dart` (flags חדשים `kAppCheckProd` default OFF + `kAppCheckRecaptchaSiteKey` default ריק) · `lib/main.dart` (helper טהור `appCheckProvidersFor({required bool prod})` `@visibleForTesting` המחזיר record `({AndroidProvider android, AppleProvider apple})` + גוש ה-App-Check הוזז לתוך `if (Firebase.apps.isNotEmpty)`, נייד בוחר providers דרך ה-helper, web מדולג אלא אם site-key, `setTokenAutoRefreshEnabled(true)` כש-prod). טסט חדש `test/app_check_providers_test.dart`.
- **`lib/main.dart` — `appCheckProvidersFor` (בחירת-providers):** מוטציה — ענף-ה-OFF `: (android: AndroidProvider.debug, apple: AppleProvider.debug)` שונה ל-`: (android: AndroidProvider.playIntegrity, apple: AppleProvider.appAttestWithDeviceCheckFallback)` (כלומר OFF מחזיר את ה-providers של prod → שובר byte-identical לדמו/dev).
- תוצאה: `app_check_providers_test` **אדום `+3 -2`** — 'OFF (default) → debug providers (BYTE-IDENTICAL to today)' + 'the live flag value selects the dev providers (pinned OFF)' (Expected `AndroidProvider.debug` / Actual `AndroidProvider.playIntegrity`) ✅ נתפס. ה-ON-test ('ON → playIntegrity + appAttestWithDeviceCheckFallback') נשאר ירוק — המוטציה נגעה רק בענף-ה-OFF.
- שחזור: `cp /tmp/main.dart.f2 lib/main.dart` (**לא** git checkout — לשמר את קוד-ה-F2) → הרצה חוזרת **+5 ירוק**.
- מסקנה: ענף-ה-OFF load-bearing — הוא ה-byte-identical-guard לדמו/dev (OFF חייב לבחור debug). ON=playIntegrity/appAttest נעול גם הוא. **G3 finding:** `activate(...)` לבדו מצרף את ה-App-Check-token אוטומטית לכל קריאת Firestore/Functions/Storage — אין עבודה per-call (`getToken`/`getLimitedUseToken` קיימים אך לא נדרשים בנתיב הרגיל). אכיפה (דחיית בקשות ללא-token) = Firebase console toggle = ממתין-לבעלים. **F2 ready, ממתין ל-F1 + רישום-קונסול.** gate: analyze 0-errors (6 info קיימים-מראש בלבד · אפס raw-color) · full-suite +2424 (ה-`-1` היחיד = `worker_reports_drilldown_test` baseline קיים-מראש) · build web ✅. pubspec.lock **לא** staged · נגעתי רק ב-main.dart+backend.dart.

## F5 — Android notifications hardening (channels + foreground display · `push_state.dart` · Firebase-gated) — 2026-06-14
- **קבצים (lib/state + android):** `lib/state/push_state.dart` (seam `LocalNotificationsGateway`: `FlutterLocalNotificationsGateway` עצלן default-null + `kPushChannels`/`pushChannelIdFor` טהורים; `localNotificationsGatewayProvider` מגודר `useFirebaseBackend && !kIsWeb`; `PushController._register` יוצר channels + מבקש הרשאת-13, `_handleForeground` מוסיף `show` על ה-channel הממופה — guarded+gated) · `android/app/src/main/AndroidManifest.xml` (POST_NOTIFICATIONS + 2 meta-data של FCM) · `res/values/strings.xml` (חדש — `default_notification_channel_id`=`bs_general`) · `res/drawable/ic_notification.xml` (חדש — vector צללית-לבנה `#FFFFFFFF`) · `pubspec.yaml` (`flutter_local_notifications: ^18.0.1`; **pubspec.lock לא staged**) · `test/push_state_test.dart` (+13 cases · fake `_FakeLocalNotifications`).
- **`lib/state/push_state.dart` — `pushChannelIdFor` (מיפוי type→channel, ה-load-bearing של תצוגת-ה-foreground):** מוטציה — ענף-`case 'order': return kOrdersPushChannelId;` שונה ל-`return kDefaultPushChannelId;` (כלומר הזמנה מנותבת ל-channel הכללי במקום ל-`bs_orders`).
- תוצאה: `push_state_test` **אדום `+26 -2`** — 'F5 — channel config (pure) pushChannelIdFor routes by data.type' + 'F5 — wired behaviour … a foreground push is RE-SHOWN as an OS notification on its channel' (שניהם Expected `'bs_orders'` / Actual `'bs_general'`) ✅ נתפס. כל שאר ה-F5 (channel-config, gating, denied/data-only/throwing, source-guard) + כל ה-S6 הקיים נשארו ירוקים — המוטציה נגעה רק במיפוי-ה-order.
- שחזור: `cp /tmp/push_state.dart.bak lib/state/push_state.dart` (**לא** git checkout — לשמר את קוד-ה-F5) → הרצה חוזרת **+28 ירוק**.
- מסקנה: `pushChannelIdFor` load-bearing — הוא ה-מקום-היחיד שממפה `data['type']` ל-channel; בלעדיו התראת-הזמנה היתה נוחתת על ה-channel הלא-נכון (המשתמש לא יכול היה למצקה ערוץ-הזמנות בנפרד). ה-gating נעול (provider=null ללא-Firebase/web ⇒ demo byte-identical — אפס init/prompt/show, ה-token נרשם בכל-זאת). **caveat נייד:** יצירת-channel/permission/tray-notification אמיתיים = on-device בלבד (לא headless); ה-fakes נועלים את הלוגיקה+הגייטינג, source-guard נועל את ה-manifest/res. **VAPID web push = ממתין-לבעלים; נייד = ממתין-ל-F1.** gate: analyze 0-errors (push_state+test) · XML well-formed · full-suite +2424 (ה-`-1` היחיד = `worker_reports_drilldown_test` baseline) · build web ✅. pubspec.lock **לא** staged · נגעתי רק ב-pubspec.yaml+AndroidManifest+res/**+push_state.dart (+טסט).

## A13-consumer — חיווט CONSUMER ל-computeCredit (תצוגת-אשראי-מנהל, gated) — 2026-06-14
- **קבצים (lib/screens + test):** `lib/screens/manager_dashboard_screen.dart` (provider חדש `customerCreditProvider` = `FutureProvider.family<CreditResult,String>` הקורא `customersRepositoryProvider.computeCredit(name)` + ה-wiring ב-`_CustomerDetailSheet`: `creditLimit = ref.watch(customerCreditProvider(c.name)).valueOrNull?.creditLimit ?? c.creditLimit`, המזין את row `מסגרת אשראי`, `livePct` ו-`balance`). טסט חדש `test/manager_credit_computecredit_consumer_test.dart` (+3, spy-repo + fake gateway). ה-`computeCredit` עצמו (repo/gateway/function) כבר היה — רק חובר ל-consumer.
- **`lib/screens/manager_dashboard_screen.dart` — row `מסגרת אשראי` (ה-load-bearing של חיווט-ה-consumer):** מוטציה — `row('מסגרת אשראי', '₪${_grouped(creditLimit)}')` שונה ל-`'₪${_grouped(c.creditLimit)}'` (כלומר ה-row מתעלם מהערך-הנפתר של `computeCredit` ומציג את ה-aggregate ה-SYNC במקום).
- תוצאה: `manager_credit_computecredit_consumer_test` **אדום `+2 -1`** — רק 'ON + a bound gateway: the rendered ceiling UPGRADES to the server-canonical figure' נכשל (Expected `₪88,000` / Actual ה-hash המקומי). שני ה-OFF-tests (seam-reached דרך spy-repo + no-flicker) נשארו ירוקים — המוטציה נגעה רק בנתיב ה-ON (הערך-הנפתר); OFF ממילא מציג את ה-מקומי.
- שחזור: `cp /tmp/manager_dashboard_screen.CURRENT.bak lib/screens/manager_dashboard_screen.dart` (**לא** git checkout — לשמר את קוד-החיווט) → הרצה חוזרת **+3 ירוק**.
- מסקנה: ה-`creditLimit` הנפתר (`valueOrNull?.creditLimit`) load-bearing — בלעדיו תצוגת-האשראי לעולם לא הייתה מציגה את הערך ה-server-canonical (ה-seam היה נשאר מת אף-על-פי שהוא בנוי). ה-gate ה-OFF נעול (repo `computeCredit` מחזיר את ה-derivation המקומית בלי רשת ⇒ demo byte-identical, אין flicker — ה-fallback ה-SYNC שווה לערך-הנפתר). gate: analyze 0-חדש (screen: 7 info קיימים-מראש בלבד · test: 0 issues · אפס raw-color) · full-suite (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline) · build web ✅. נגעתי רק ב-manager_dashboard_screen.dart (+טסט).

## C6 — resolveGeoFix — ה-gate הכן ל-GPS נטיב (geolocator · seam משותף `lib/services`) — 2026-06-14
- **קבצים (lib/services + state + test):** `lib/services/geo_gate.dart` (חדש · טהור platform-free — `resolveGeoFix(...)` עם 4 callbacks: isServiceEnabled/checkPermission/requestPermission/getReading, מחיל את ה-gate הכן; `GeoReading`/`GeoPermissionState` מראָה platform-free כדי **לא** לייבא `geo.dart`→package:web שלא מתקמפל ב-test-VM) · `lib/services/geo_native.dart` (חדש · adapter דק שכובל את `Geolocator` האמיתי ל-`resolveGeoFix`) · `lib/services/geo.dart` (conditional-import שונה `geo_stub.dart`→`geo_native.dart` בנתיב הלא-web; חוזה `Future<GeoFix?>` byte-identical) · `lib/state/site_hub_state.dart` (`clockIn(now,{geo})` + `formatGeo(...)` + `kGeoUnavailable`) · `lib/screens/site_hub_screen.dart` (`_clock` async → `currentGeoFix()`). טסטים חדשים `test/geo_gate_test.dart` (+13) · `test/geo_permissions_source_test.dart` (+6); `test/site_hub_state_test.dart` עודכן (net +5, ה-T2.4 הישן שאישר את הדמו-הקשיח הומר לחוזה-הכן).
- **`lib/services/geo_gate.dart` — `resolveGeoFix` (ה-permission-gate, load-bearing של החוזה-הכן):** מוטציה — `if (perm != GeoPermissionState.granted) return null;` הוסר (הוערה החוצה) → ה-gate עוקף ו-fetch מתבצע גם ללא הרשאה (יזיף קואורדינטה ל-denied/disabled).
- תוצאה: `geo_gate_test` **אדום `+7 -2`** — 'resolveGeoFix — honest null paths (NEVER a fabricated coordinate) permission denied and still denied after the prompt → null' + '… deniedForever → null and NOT re-prompted' (שניהם החזירו את ה-`GeoReading` במקום null) ✅ נתפס. הנתיבים-granted + service-off (שלא תלויים בשורה שהוסרה) נשארו ירוקים.
- שחזור: `cp /tmp/geo_gate.dart.bak lib/services/geo_gate.dart` (**לא** git checkout — לשמר את קוד-ה-C6; sha1 `1dff8495…` תואם את ה-pre-mutation byte-for-byte) → הרצה חוזרת **+9 ירוק**.
- מסקנה: שורת-ה-`if (perm != granted) return null` load-bearing — היא ה-יחידה שמונעת fetch (=קואורדינטה) כשההרשאה denied/deniedForever/unableToDetermine; בלעדיה ה-seam היה מזייף מיקום על מכשיר-מסורב — בדיוק ה-anti-pattern שה-#100 אסר ("אין קואורדינטה מומצאת"). ה-gate מבודד ב-`geo_gate.dart` (בלי package:web) כדי שיהיה ניתן-לבדיקה-headless למרות ש-`worker_attendance_geo_test` נאלץ לדלג את ה-seam דרך `geo.dart`. **caveat נטיב:** ה-fetch האמיתי על מכשיר (geolocator/platform-channel) לא ניתן-לאימות headless — ה-gate נעול ביחידה + ה-permissions ב-source-guard (`geo_permissions_source_test`: manifest FINE+COARSE+אין-background+location-feature-`required=false`; plist `NSLocationWhenInUseUsageDescription` עברית-ספציפי+אין-`Always`). gate: analyze 0-errors (geo_native/geo_gate + 2 טסטים חדשים = 0 issues; info שנותרו = relative-import ב-`geo.dart:21`/`geo_stub.dart:7` בתוך directive ה-conditional + 3 ב-site_hub_screen = **קיימים-מראש**, אומת ב-`git stash`; אפס raw-color) · full-suite **+2448 -1** (baseline +2424 -1; +24 חדשים; ה-`-1` = `worker_reports_drilldown_test` baseline) · build web ✅ (geolocator_web מתקמפל; `geo_web.dart` עדיין נבחר ל-web → 0 התייחסויות-geolocator ב-main.dart.js). pubspec.lock **לא** staged · נגעתי רק ב-geo*.dart + site_hub(_screen/_state) + pubspec + AndroidManifest + Info.plist (+טסטים). **לא נגעתי במסכי worker-board / clock-in UI / manager-credit / firebase_options / nav_launch.**

## F1 — Firebase נטיב (android+ios firebase_options + currentPlatform mapping) — 2026-06-14
- **קבצים (lib + native):** `lib/firebase_options.dart` (נוספו `static const FirebaseOptions android`/`ios`, ערכים verbatim מ-`android/app/google-services.json` + `ios/Runner/GoogleService-Info.plist` — project `buildsmart-b0b78`, appId-android `…:android:e9d240f3251e7a33ca6511`, appId-ios `…:ios:89ac1613e3b695cfca6511`; `currentPlatform` הוסר ה-`UnsupportedError` ל-android/ios, ממפה android→android·iOS/macOS→ios·web→web·linux/windows/fuchsia→throw). gradle: `android/settings.gradle.kts` (`com.google.gms.google-services` v4.4.2 apply false) + `android/app/build.gradle.kts` (apply ה-plugin). `ios/Runner.xcodeproj/project.pbxproj` (4 רשומות → `GoogleService-Info.plist` חבר ב-Runner Resources). טסט חדש `test/firebase_options_test.dart`.
- **`lib/firebase_options.dart` — `android.projectId` (ה-load-bearing של אתחול-Firebase הנכון):** מוטציה — `projectId: 'buildsmart-b0b78'` בבלוק ה-android שונה ל-`projectId: 'WRONG-PROJECT-MUTANT'` (כלומר נייד-android היה מאתחל מול פרויקט לא-קיים → init נכשל בשקט → חזרה ל-local/demo, בדיוק הבאג ש-F1 מתקן).
- תוצאה: `firebase_options_test` **אדום `+15 -3`** — 'android options match … projectId ← project_info.project_id' + 'currentPlatform … android → the android FirebaseOptions' (assertion `projectId`) + 'all three platforms share one project' (Expected `'buildsmart-b0b78'` / Actual `'WRONG-PROJECT-MUTANT'`) ✅ נתפס. ה-ios/web/mapping-no-throw נשארו ירוקים — המוטציה נגעה רק ב-android.projectId.
- שחזור: `cp /tmp/firebase_options.dart.GOOD lib/firebase_options.dart` (**לא** git checkout — לשמר את קוד-ה-F1; `diff`=זהה byte-for-byte) → הרצה חוזרת **+18 ירוק**.
- מסקנה: ה-`projectId` בבלוק-android load-bearing — הוא הקושר את ה-init לפרויקט הנכון; הבדיקה קוראת את `google-services.json` בפועל אז היא נשברת ברגע ש-firebase_options.dart נסחף מהקובץ-של-הבעלים (או להפך). **מסגור-גייטינג:** F1 מביא לחיים את אתחול-ה-Firebase בנייד (→ G4 telemetry + App Check debug קמים), אבל ה-DATA-backend עדיין מגודר `kUseFirebaseBackendFlag` (default OFF) → demo/local byte-identical עד שהבעלים ידליק; **web byte-identical** (const `web` + ענף `kIsWeb` לא נגעו). **caveat android:** אין Android-SDK בסביבה (`flutter build apk` → "No Android SDK found") → נכונות-ה-gradle + התאמת-JSON/plist בלבד; boot-נטיב = DoD של הבעלים. gate: analyze 0-errors (`firebase_options.dart`=0 issues; info ב-main.dart קיימים-מראש; אפס raw-color) · full-suite **+2466 -1** (baseline +2448 -1; +18 חדשים; ה-`-1` היחיד = `worker_reports_drilldown_test` baseline, אומת בבידוד `+1 -1`) · build web ✅. pubspec.lock **לא** staged · נגעתי רק ב-firebase_options.dart + 2 gradle + pbxproj (+טסט). **לא נגעתי בקבצי-הקונפיג של הבעלים / main.dart / App-Check / worker-board / 4 מחלקות / manager-credit / geo.**

## auth-gate — createUser + מיפוי-שגיאות (server-gate-auth) — 2026-06-14
- **קבצים:** `test/login_sheet_test.dart` + `test/auth_state_test.dart` (createUser group · create-account/error-map · welcome-gate · role-picker · profile login/logout/delete).
- **מוטציה (נתפסה ✅):** שיבוש מיפוי-השגיאה `'email-already-in-use' => 'האימייל כבר רשום — התחברו במקום'` → `'MUT_BROKEN'` ב-`login_sheet.dart` → `login_sheet_test` **`+10 -2` אדום** (הטסט "צור חשבון — email-כבר-רשום" חיפש את הטקסט-העברי, מצא 0 widgets) → שוחזר `cp /tmp/ls.bak` → **+20 ירוק**.
- **הערת-יושר (חולשת-מוטציה מתועדת):** מוטציה `createUserWithEmailAndPassword`→`signInWithEmailAndPassword` ב-**FirebaseAuthGateway** (impl ה-SDK, שורה 292) **שרדה** — כי הטסטים מזייפים את ה-`AuthGateway` (`_FakeAuthGateway`), לא את ה-SDK; ה-impl העוטף את ה-SDK אינו unit-testable (כמו `signInWithEmailAndPassword`). ה-notifier + ה-UI (מה שחשוב למשתמש) כן נעולים (login_sheet_test +20).
- **gate:** analyze 0-errors · ratchet נקי · full-suite **+2475 -1** (`-1` = `worker_reports_drilldown` baseline, אומת בבידוד). נגעתי: `auth_state.dart`(lib/state) + `login_sheet`/`welcome_screen`(lib/screens) + 6 טסטים. **לא נגעתי:** worker-board / 4 מחלקות / firebase_options / CI / geo / manager-credit.

## seed-employer-link — חיתום חשבונות-seed של עובדים ב-employerId (תיקון seed-login scoping) — 2026-06-15
- **קבצים (lib/data + test):** `lib/data/board_accounts_local.dart` (חיתום `employerId: kDemoContractorId` על חשבונות-ה-seed של העובדים `ran`/`omer` — ה-Wave-0 worker→contractor link שהשדה נבנה עבורו; courier/store/manager נשארו `''`). טסט חדש `test/seed_worker_employer_link_test.dart` (+3). רקע: עובד ב-seed-LOGIN נשא employerId `''` → נשמט שקט מכל view ממוקד-מעסיק (חופשה/תעודות/הדרכות/חומרים/נוכחות) ושער-המסמכים הקשיח (#101) נכשל-פתוח. נבחר חיתום-במקור על-פני רפרוף הפילטרים ל-`|| isEmpty` כי ה-scoping הקשיח `== employerId` הוא תכן מכוון+מבוטסט (`contractor_certs_test`/`contractor_vacation_approval_test`/`contractor_attendance_test` מאשרים ש-`''`/legacy מורחק).
- **`lib/data/board_accounts_local.dart` — `employerId: kDemoContractorId` על 'ran' (ה-load-bearing של חיווט seed-login→קבלן):** מוטציה — שורת `employerId: kDemoContractorId,` תחת חשבון 'ran' הוסרה (→ ran חוזר ל-default `''` — בדיוק הבאג).
- תוצאה: `seed_worker_employer_link_test` **אדום `+1 -2`** — 'worker seeds (ran/omer) are employed by the demo contractor' (Expected `'contractor-demo'` / Actual `''`) + 'every worker seed has a non-empty employer (no silent drop)' ✅ נתפס. ה-test השלישי ('non-worker seeds keep no contractor employer link') נשאר ירוק — המוטציה נגעה רק ב-ran.
- שחזור: `cp /tmp/bal.GOOD lib/data/board_accounts_local.dart` (**לא** git checkout — לשמר את קוד-החיתום; diff מול ה-GOOD = RESTORED-IDENTICAL) → הרצה חוזרת **+3 ירוק**.
- מסקנה: ה-`employerId: kDemoContractorId` על חשבונות-העובדים load-bearing — בלעדיו ה-session של עובד-seed-login נושא `''` וכל ה-channels ממוקדי-המעסיק (שעושים `== employerId` קשיח) משמיטים אותו, ושער-ה-#101 נכשל-פתוח; החיתום מיישר את עובד-ה-login לעובד-ההדגמה (`board_auth.dart:274` כבר נותן kDemoContractorId ל-enterDemo). gate: analyze 0-errors (board_accounts_local + הטסט = 0 issues) · 5 קבצי-ה-state חזרו byte-identical (revert של גישת-הפילטר) · הטסטים המושפעים ירוקים (contractor_certs/vacation/attendance + docs_readiness + auth = 159 ירוק). נגעתי רק ב-board_accounts_local.dart (+טסט). **לא נגעתי** בפילטרי-ה-scoping (vacation/material/certs/trainings/docs_readiness) — נשמרו קשיחים בכוונה.
## order-sync-fix — ההזמנה של הקבלן לא מסתנכרנת בין מכשירים (rules create-gate + index) — 2026-06-14
- **שורש הבאג:** כלל ה-`create` ב-`firestore.rules` על `orders` דרש `hasRole('contractor')`, אבל זהות-ה-`contractor` היא ברירת-המחדל **ללא claim** — ה-callable `setRole` + `manager_role_assign_sheet` מקצים אך-ורק את התפקידים-המיוחדים (manager/store/courier/worker) ולעולם **לא** 'contractor' (ראה ה-RoleOption doc). לכן קבלן-אמיתי מחובר (כמו `meir7651231@gmail.com`) נושא 0 role-claim ⇒ `hasRole('contractor')`==false ⇒ כל יצירת-הזמנה **נדחתה** (`permission-denied`), ה-`guardWrite` בלע אותה בשקט, ההזמנה הופיעה אופטימית במכשיר-המניח אבל **לא הגיעה ל-Firestore** ⇒ לא סונכרנה לדפדפן-של-אותו-חשבון. הקריאה (`ownsOrder`=`contractorUid==uid`) והשדה הנכתב (`contractorUid`) היו **תקינים** — רק שער-היצירה גידר על claim שלקבלן אין.
- **תיקונים:** (1) `firestore.rules` create → `isSignedIn() && stage=='new' && contractorUid==auth.uid` (קושר ל-uid-הבעלות, לא ל-claim; עדיין אי-אפשר לזייף uid אחר, עדיין נעוץ ל-'new'). (2) `firestore.indexes.json` #2/#3: `storeId`/`courierId` → `storeUid`/`courierUid` (להתאים ל-toDoc + ל-`_ordersScopeFor` של store/courier; שאילתת-scoped עם שדה-ללא-index זורקת `failed-precondition`). (3) `firestore_cached_repo.dart:99` doc-comment `contractorId`→`contractorUid`. (4) דיאגנוסטיקה ב-`backend_debug_badge.dart` (4 צעדים: diag/{uid} · users/{uid} · שאילתת-הזמנות-שלי · יצירת-הזמנה) מאחורי `kDebugMode||FS_DIAG`.
- **קובץ-מוטציה (ה-load-bearing של התאמת-index↔toDoc):** `firestore.indexes.json` — שדה-ה-index `storeUid` → `storeId` (החזרת-הבאג: index על שדה שאף-פעם לא נכתב ⇒ ה-store scoped query לעולם בלי-index).
- תוצאה: `orders_sync_scope_index_diag_test` **אדום `+5 -1`** — 'every orders index field is a field toDoc writes (no storeId/courierId)' → `Expected: not contains 'storeId'` / `Actual: Set:['contractorUid','ts','storeId','courierUid']` ✅ נתפס. כל שאר הצעדים (scope-fields · contractor-index-קיים · 4 ה-fsDiagStepResult mappings) נשארו ירוקים — המוטציה נגעה רק בהתאמת-ה-index.
- שחזור: `cp /tmp/firestore.indexes.json.good firestore.indexes.json` (גיבוי לפני-מוטציה, byte-for-byte) → הרצה חוזרת **+11 ירוק**.
- מסקנה: התאמת שמות-ה-index לשדות ש-`toDoc` כותב load-bearing — index על `storeId` בזמן ש-toDoc כותב `storeUid` משאיר את ה-store/courier scoped listen בלי-index ⇒ `failed-precondition` בכל live-read שלהם. ה-guard קורא את `firestore.indexes.json` בפועל (`File('../...')`) אז הוא נשבר ברגע שקובץ-ה-index נסחף מ-שמות-ה-toDoc. **מסגור-גייטינג:** ה-scope + הדיאגנוסטיקה מגודרים (`kUidScopedQueries` / `kDebugMode||FS_DIAG`, שניהם compile-time OFF) ⇒ flag-OFF byte-identical; ה-rules+index הם server-side (לא חלק מ-בינארי-האפליקציה). **caveat נייד:** אישור-הסנכרון-האמיתי = on-device — הדיאגנוסטיקה (FS_DIAG=true ב-APK חתום) תַראֶה את ה-`permission-denied`/`failed-precondition`+URL המדויק; ה-deploy של rules/indexes = פעולת-בעלים (`firebase deploy --only firestore:rules,firestore:indexes`). gate: analyze 0-errors (כל הקבצים-הנגועים + הטסט החדש; כל ה-issues `info`-בלבד · אפס raw-color/`value:`/`activeColor:`) · full-suite (ה-`-1` היחיד = `worker_reports_drilldown_test` baseline) · build web ✅. נגעתי רק ב-rules/indexes + backend/orders_local/firestore_cached_repo/main/backend_debug_badge (+טסט). **לא נגעתי:** worker-board / 4 מחלקות / auth-gate / firebase_options.

## E3-leak-fix — requestsForWorker scope על session.uid דלף בין עובדי-seed — 2026-06-15
- **קבצים (lib/state + lib/screens + test):** `lib/state/material_requests_engine.dart` (MaterialRequest += שדה-scope `username`; submit מקבל `username` וחותם אותו; requestsForWorker מסנן `r.username == username` במקום workerUid; workerUid נשמר כ-id מוכן-לשרת) · `lib/screens/worker_employer_stock_sheet.dart` (read+submit מעבירים `session.username`) · `test/material_requests_test.dart` (+טסט-בידוד seed-session, +username בכל submit).
- **`lib/state/material_requests_engine.dart` — requestsForWorker filter (ה-load-bearing של בידוד-העובד):** מוטציה — `if (r.username == username) r,` הוחזר ל-`if (r.workerUid == username) r,` (הבאג המקורי — keying על workerUid שהוא '' לכל עובד seed/demo).
- תוצאה: `material_requests_test` **אדום `+7 -1`** — רק 'requestsForWorker scopes per-USERNAME even when workerUid is empty' נכשל (Expected length 1 / Actual 0 — query 'ran' מול רשומות שכולן workerUid '' → 0 התאמות) ✅ נתפס. 7 הטסטים האחרים (שמעבירים workerUid==username) נשארו ירוקים.
- שחזור: `cp /tmp/mre.GOOD lib/state/material_requests_engine.dart` → RESTORED-IDENTICAL → **+8 ירוק**.
- מסקנה: ה-scope-key של requestsForWorker load-bearing — session.uid='' לכל עובד seed/demo (רק נתיב Firebase-bind ממלא אותו, kUidScopedQueries default OFF ב-backend.dart), אז keying עליו התנגש ב-'' ו-requestsForWorker('') החזיר את בקשות-החומר הפרטיות של כל העובדים זה לזה (הפרת #66). המעבר ל-username (תבנית-האחים VacationRequest/AttendanceDay/WorkerCert) מבודד נכון; workerUid נשמר additive ל-SERVER-SWAP (username==uid בנתיב Firebase → אפס רגרסיה). נמצא ע"י ביקורת-התקינות האדוורסרית של הצי. gate: analyze 0 · caller יחיד (worker_employer_stock_sheet) עודכן. נגעתי רק ב-material_requests_engine + worker_employer_stock_sheet (+טסט). **לא נגעתי** ב-orders/auth/firebase.

## R2-seq-guard — id מבוסס-timestamp בלי _seq → דליפת-מחיקה ב-4 stores — 2026-06-15
- **קבצים (lib/state + test):** `worker_certs.dart` (cert id) · `worker_forms.dart` (sick-note id) · `cart_lists_state.dart` (cart id) · `saved_projects.dart` (project id) — לכל אחד נוסף `int _seq = 0;` והסיומת `-${_seq++}` ל-id. טסט חדש `test/id_seq_collision_test.dart` (4 חנויות).
- **`lib/state/worker_certs.dart` — id mint (load-bearing):** מוטציה — הוסר `-${_seq++}` מה-id (חזרה ל-`'cert-${micros}'` — הבאג המקורי).
- תוצאה: `id_seq_collision_test` **אדום `+3 -1`** — רק 'worker_certs cert id' נכשל (הסגמנט-האחרון של ה-id הוא ה-micros ולא 0,1) ✅ נתפס. 3 החנויות האחרות נשארו ירוקות.
- שחזור: `cp /tmp/wc.GOOD lib/state/worker_certs.dart` → RESTORED-IDENTICAL → **+4 ירוק**.
- מסקנה: web DateTime ~1ms-precise; שני adds באותה מילישנייה התנגשו על id זהה, ו-remove(id)/deleteList(id)/rename(id) (שמורידים/משנים כל שורה עם אותו id) פגעו בשתיהן. ה-`_seq` המונוטוני (תבנית vacation/material/trainings/notifs/stock) מבטיח ייחודיות. id נשאר String אטום (toJson/fromJson ללא-שינוי) → אפס back-compat. נמצא ע"י ביקורת-הלילה סבב-2 של הצי. gate: analyze 0 · 4 stores ירוקים. נגעתי רק ב-4 ה-state-stores (+טסט). **לא נגעתי** ב-UI/orders/auth.

## A1-tasks-persistence — משימות-ריצה (createTask/proposeTask) לא שרדו restart — 2026-06-15
- **קבצים (lib/state + test):** `tasks_engine.dart` — TaskItem += toJson/tryFromJson (רשומה-מלאה); `_persist` כותב משימות-ריצה (non-seed ids) כרשומות-מלאות תחת `kTasksRuntimeKey='bs.tasks-runtime.v1'`; `_load` משחזר אותן אחרי seed+overlay. טסט חדש `test/tasks_runtime_persistence_test.dart` (+2).
- **`tasks_engine.dart` _load — restore-runtime (load-bearing):** מוטציה — `if (runtime.isNotEmpty) super.state = [...state, ...runtime];` הוחלף ב-`{}` (משימות-הריצה מחושבות אך לא מוחלות — הבאג המקורי).
- תוצאה: `tasks_runtime_persistence_test` **אדום `+0 -2`** — שני המקרים נכשלו (המשימה שנוצרה ב-session 1 לא קיימת ב-session 2) ✅ נתפס. 3 טסטי-ה-overlay הקיימים (worker_tasks_persistence) נשארו ירוקים.
- שחזור: `cp /tmp/te.GOOD lib/state/tasks_engine.dart` → RESTORED-IDENTICAL → **+2 ירוק**.
- מסקנה: ה-_load בנה state רק מ-_seedTasks (const ids 1-5) plus overlay; משימות-ריצה (id=max+1) נזרקו ב-restart וה-overlay גם לא שמר name/steps/worker שלהן. עכשיו הרשומה-המלאה נשמרת תחת מפתח-prefs נפרד ומשוחזרת. back-compat: payload פרה-A1 ללא-שינוי; ה-overlay של ה-seeds לא נגע (3 טסטיו ירוקים). SERVER-READY: bindRemote (T1) יסנכרן חי כשה-Firebase ינחת. החלטת-בעלים A1. gate: analyze 0. נגעתי רק ב-tasks_engine (+טסט).

## A2-hr-decide-once — אישור חופשה/הדרכה ירה פעמון+צ'אט פעמיים (double-tap) — 2026-06-15
- **קבצים (lib/state + lib/screens + test):** `vacation_requests.dart` + `worker_trainings.dart` — `approve`/`reject`/`_decide` שונו מ-void ל-`bool` (true רק על מעבר אמיתי pending→decided). `contractor_hr_sheet.dart` — `_decide`/`_decideTraining` יורים bell+chat+toast רק אם ה-bool true. טסט חדש `test/hr_decide_once_test.dart` (+2).
- **`vacation_requests.dart` _decide guard (load-bearing):** מוטציה — ה-`return false;` (כשהשורה כבר-לא-pending) → `return true;`.
- תוצאה: `hr_decide_once_test` **אדום `+1 -1`** — מקרה-ה-vacation נכשל (approve שני החזיר true במקום false) ✅ נתפס. מקרה-ה-training (מנוע אחר) נשאר ירוק.
- שחזור: `cp /tmp/vr.GOOD lib/state/vacation_requests.dart` → RESTORED-IDENTICAL → **+2 ירוק**.
- מסקנה: ה-side-effects היו ללא-תנאי אחרי קריאת-המנוע; ה-r/t הלכוד מתיישן ב-double-tap (השורה לא נבנתה-מחדש בין הקשות) → שתי-ההקשות ירו. עכשיו המנוע מחזיר אם באמת עבר, והווידג'ט יורה פעם-אחת — מתקן double-tap plus שני-משטחים (השני רואה false). הקבלן מחזיק את ההתראה; ה-double-fire בלוח-המנהל נפתר ב-#84g (הוצאת HR מהמנהל). void→bool additive (17 טסטי-אישור קיימים ירוקים). gate: analyze 0. נגעתי ב-vacation plus trainings(state) plus contractor_hr_sheet(לוגיקה, ללא-פיקסל).

## A3-pod-signature-await-rollback — חתימת POD "נשמרה" גם כשה-persist נכשל — 2026-06-15
- **קבצים:** `persona_fulfillment.dart` — `captureSignature` שונה מ-`void` (→`_put` fire-and-forget) ל-`Future<bool>` עם await+rollback (חיקוי `capturePod`). `persona_pod_sheet.dart` — הכפתור ממתין ל-bool ומציג toast-הצלחה רק אם נשמר ("החתימה לא נשמרה — נסה שוב" אחרת). טסט חדש ב-`persona_fulfillment_test.dart` (+1, סה"כ +23).
- **load-bearing:** `captureSignature` `return ok;` (ה-bool של ה-persist) — ייחודי בקובץ (grep=1).
- מוטציה: `return ok;` → `return false;`. תוצאה: הטסט "captureSignature awaits persist (true) and survives a reload (A3)" **אדום `+22 -1`** ✅ (ה-isTrue על n1 נכשל). שאר 22 ירוקים.
- שחזור → **+23 ירוק** · RESTORED-IDENTICAL.
- מסקנה: החתימה רוכבת על ה-side-car הראשי (`'podSig'` ב-toJson), אז await יחיד של `_persist` הוא כל הכתיבה (בלי `_mirrorPodPhoto` שהוא לתמונה בלבד). הקוד הישן עשה `_put`→`set state`→`_persist()` fire-and-forget — כשל-quota השאיר state בזיכרון אבל לא בדיסק, וה-UI הריע "נשמרה" שקרית; ב-reload החתימה נעלמה. עכשיו: rollback ל-state הקודם plus `false`, וה-UI כן. analyze 0. server-ready (החתימה שורדת restart; bindRemote יזרים חי).

## A4-dst-day-idiom — off-by-one ב-offset יום חוצה גבול-DST (גאנט + 2 דוחות) — 2026-06-15
- **קבצים:** חדש `lib/logic/calendar_days.dart` (`daysBetweenDst` מבוסס-`DateTime.utc` plus `startOfWeekSunday` חשבון-לוח). `tasks_gantt.dart` (startDay offset), `worker_reports_tab.dart` plus `courier_reports_tab.dart` (weekStart plus dayIdx של היסטוגרמת-השבוע) עוברים דרכם. טסט חדש `calendar_days_test.dart` (+6).
- **load-bearing:** `daysBetweenDst` — `DateTime.utc(...)` (×2). מוטציה: `DateTime.utc(` → `DateTime(` (local).
- תוצאה (TZ=Israel Standard Time, ה-spring-forward 2026 ב-27/3): 3 הטסטים התלויי-DST של daysBetweenDst **אדומים `+3 -3`** ✅ (adjacent dates, multi-day span, time-of-day ignored). טסטי startOfWeekSunday נשארו ירוקים (לא משתמשים ב-.utc).
- שחזור → **+6 ירוק** · RESTORED-IDENTICAL.
- מסקנה: `DateTime(y,m,d)` מקומי הוא midnight מקומי; הפרש בין שני midnight-ים מקומיים חוצה spring-forward = 23h → `.inDays` מתקצר ל-0 (יום פחות) → בָּר נופל ביום שגוי / משלוח בדלי-שבוע שגוי. UTC (ימי-24h, בלי DST) נותן את הפער הלוחי המדויק בכל TZ. בנוסף: `weekStart` חושב ב-subtract Duration days (חיסור-שעות שנסחף ב-DST) → הוחלף ב-DateTime y m d-k (חשבון-לוח). הגאנט הוא pure (VM-safe) וכך גם calendar_days. ה-streak כבר היה חשבון-לוח — לא נגעתי. analyze 0.

## A5-board-proposed-fold — משימה מוצעת (proposed) בלתי-נראית בלוח-המשימות — 2026-06-15
- **קובץ:** `worker_task_board_screen.dart` — `_groups` שונה מ-status-יחיד ל-Set-של-statuses, ו-`'proposed'` קופל לקבוצת ⏳ בתור (יחד עם pending). חולצה `groupByStatus` טהורה (@visibleForTesting). build משתמש בה. טסט חדש `worker_task_board_group_test.dart` (+1).
- **load-bearing:** סט-ה-בתור `{'pending', 'proposed'}`. מוטציה: הסרת `'proposed'` → `{'pending'}`.
- תוצאה: `worker_task_board_group_test` **אדום `+0 -1`** ✅ — המשימה המוצעת (id 1) לא נכנסה לאף קבוצה → containsAll[1,2] נכשל plus הסכום 3≠4.
- שחזור → **ירוק** · RESTORED-IDENTICAL.
- מסקנה: המנוע מחזיק status `'proposed'` (worker proposeTask → ממתין ל-approveProposal של הקבלן), אבל `_groups` כיסה רק active/rejected/pending/review/done → משימה מוצעת נפלה בין-הכיסאות (לא הוצגה כלל, וה-invariant counts-sum-to-total נשבר בשקט). A5 (החלטת-בעלים): לא קבוצה חדשה — לקפל proposed לתוך בתור. עכשיו כל status ממופה לקבוצה אחת בדיוק. analyze 0.

## #52-order-notif-to-orders-world — התראות הזמנה/משלוח מההגדרות → עולם-ההזמנות — 2026-06-15
- **קבצים:** חדש `order_notif_sheet.dart` (OrderNotifSheet plus showOrderNotifSheet — 2 toggles הקשורים ל-notifSettingsProvider: typeOrders/typeShipments). `store_screen.dart` — 🔔 ב-_SectionChipsRow כשהמקטע=📦 הזמנות → פותח את הגיליון. `notif_settings_screen.dart` — הוסרו 2 השורות הזמנות/משלוחים ממקטע 🔔 (שאר ה-types נשארו). טסט חדש `order_notif_sheet_test.dart` (+1).
- **load-bearing:** ה-toggle `onChanged: v => n.update(x => x.copyWith(typeOrders: v))` — כותב את ה-provider המשותף. מוטציה: `copyWith(typeOrders: v)` → `copyWith(typeOrders: x.typeOrders)` (מתעלם מ-v).
- תוצאה: `order_notif_sheet_test` **אדום `+0 -1`** ✅ — אחרי tap, typeOrders נשאר true (הציפייה false נכשלה) → ה-tap לא כתב את ה-provider.
- שחזור → **ירוק** · RESTORED-IDENTICAL.
- מסקנה: ההתראות הקשורות-הזמנה הועברו למקום שבו הקונה עוקב אחרי הזמנות (🔔 בטאב 📦 הזמנות), כשהן קושרות את אותו notifSettingsProvider (מקור-אמת יחיד, לא עותק) — שאר ההתראות נשארו בהגדרות › התראות. שני הטסטים שנוגעים ב-typeOrders/typeShipments הם engine-level (notifMutedSections/copyWith) → לא הושפעו. שני טסטים שמרנדרים NotifSettingsScreen (robustness, settings_honesty) ירוקים. analyze 0. אין שער-format.

## #50-settings-merge-dup-categories — מיזוג קטגוריות-הגדרות כפולות + price-drop קנוני — 2026-06-15
- **קובץ:** `catalog_settings_screen.dart` (מסך 'הגדרות' הראשי). מוזגו 2 מקטעי-🔔 (`_NotificationsSection` plus `_CatalogNotifSection`) ל-🔔 'התראות' יחיד, ו-2 מקטעי-תצוגה (`_ThemeSection` plus `_DisplaySection`) ל-'תצוגה ומיון' יחיד. price-drop כפול קופל לשדה-קנוני יחיד `catalogSettings.notifPriceDrop` ('ירידת מחיר במועדפים'); ה-toggle הכפול `typePriceDrops` ('התראות תקציב') הוסר מהמסך. order/shipment הושמטו (עברו לעולם-ההזמנות, #52). הרשימה ב-build ירדה מ-13 ל-11 מקטעים. עדכון `catalog_sort_alerts_settings_test` ('התראות קטלוג'→'התראות').
- **load-bearing:** השורה המקופלת `notifLowStock` ('מלאי נמוך') תחת המקטע-הממוזג 'התראות' — מוכיחה שמשפחת-קטלוג קופלה לתוך 'התראות'. ייחודי בקובץ (grep=1).
- מוטציה: תווית `'מלאי נמוך'` → `'XX_MUT'`. תוצאה: טסט "מלאי נמוך flips notifLowStock" **אדום `+14 -1`** ✅. שחזור → **+16 ירוק** · RESTORED-IDENTICAL.
- מסקנה: היו שני מקטעי-התראה ושני מקטעי-תצוגה במסך-הגדרות אחד, plus 3 toggles ל-price-drop על-פני 2 שדות plus שדה-שלישי priceChangeAlert במועדפים. #50 מיזג את הכפילויות בתוך catalog_settings plus קיבע price-drop ל-notifPriceDrop. 4 טסטי-מסך ירוקים. analyze 0. שארית: typePriceDrops ב-notif_settings_screen (מסך-נפרד) plus priceChangeAlert (→#54).

## #54-remove-favorites-category — הסרת קטגוריית 'מועדפים ורשימות' מההגדרות — 2026-06-15
- **קובץ:** `catalog_settings_screen.dart` — מחיקת `_FavoritesSection` (❤️ 'מועדפים ורשימות') plus רשומתה ב-build (11→10 מקטעים). היה: 4 placeholders (סנכרון/רשימות-פרויקט/שיתוף/יבוא-ייצוא — כולם coming-soon backend-blocked) plus toggle אחד מחווט `priceChangeAlert`. priceChangeAlert מכוסה ע"י ה-price-drop הקנוני ב-'התראות' (notifPriceDrop, #50); השדה נשאר במודל back-compat בלי toggle. עדכון `catalog_sort_alerts_settings_test`: טסט-priceChangeAlert → טסט "הקטגוריה הוסרה" (findsNothing).
- **load-bearing:** קיום המקטע ❤️ 'מועדפים ורשימות' במסך.
- אימות RED→GREEN בלי perl: הטסט החדש רץ **בעוד `_FavoritesSection` קיים** → **אדום `+0 -1`** (מצא את הכותרת). אחרי מחיקת המקטע → **ירוק** (4 טסטי-מסך +54). מוכיח שהטסט תופס רגרסיה של חזרת-הקטגוריה.
- מסקנה: קטגוריה שכולה placeholders backend-blocked plus toggle כפול שכבר-קנוני (#50) = קטגוריה מתה. הוסרה; ה-placeholders יחוברו כ-seams במשטחי-המועדפים/רשימות כשייחשף שם שקע-הגדרות (נדחה — הצבה עכשיו = ניחוש). analyze 0.

## #49-wire-supplier-prefs — ספקים-מועדפים: חיווט 3 העדפות מגובות (server-ready) — 2026-06-15
- **קובץ:** `catalog_settings_screen.dart` — `_SuppliersSection` שונה מ-StatelessWidget (5 placeholders) ל-ConsumerWidget: 3 השדות המגובים ב-CatalogSettings חוּוטו לפקדים נשמרים — `maxDistance` (_NumberRow 5-300 ק"מ), `minRating` (_RadioGroupRow any/3+/4+/5), `localSuppliersOnly` (_SwitchRow). 2 הרשימות (ספקים-מועדפים/חסומים) נשארו _PlaceholderRow כ-server-ready seams (דורשות זהות-ספק). טסט חדש ב-catalog_sort_alerts_settings_test (+1).
- **load-bearing:** `_SwitchRow` 'ספקים מקומיים בלבד' `onChanged: copyWith(localSuppliersOnly: v)`. מוטציה: `copyWith(localSuppliersOnly: v)` → `copyWith(localSuppliersOnly: s.localSuppliersOnly)` (מתעלם מ-v).
- תוצאה: טסט "ספקים מקומיים בלבד flips localSuppliersOnly (#49)" **אדום `+0 -1`** (אחרי tap נשאר false). שחזור → **ירוק** · RESTORED-IDENTICAL.
- מסקנה: הקוד הקודם השאיר את 3 השדות לא-מחווטים בכוונה כי אין דאטת-ספק על מוצרים לסנן. אך שמירת ההעדפה אינה זיוף — היא ה-intent שהסינון העתידי יכבד (server-ready). החיווט שומר מקומית עכשיו ומופעל אוטומטית כשהספק יזין מרחק/דירוג/מקומיות. preferred/blocked דורשים זהות-ספק → seams כנים. analyze 0 · robustness/settings_honesty ירוקים.

## #99-rewards-private-per-user — BuildCoins נשמרו תחת מפתח גלובלי → דליפה בין משתמשים — 2026-06-15
- **קובץ:** `rewards_state.dart` — `RewardsNotifier` קיבל `username` plus getter `_storageKey` (`'$kRewardsKey.$username'`, ריק→מפתח-גלובלי back-compat). `_load`/`_persist` משתמשים ב-`_storageKey`. ה-provider קורא `ref.watch(boardAuthProvider)?.username` ובונה notifier scoped (re-build על login/switch). leaderboard נשאר seed משותף (רק שורת 'אתה' מסונכרנת למאזן הפרטי). טסט חדש `rewards_per_user_test.dart` (+1). תיקון-setup ב-`t3_ghi_rewards_ai_home_test.dart` (binding plus mock — ה-coupling החדש ל-boardAuth נוגע ב-prefs).
- **load-bearing:** `_storageKey` getter `username.isEmpty ? kRewardsKey : '$kRewardsKey.$username'`. מוטציה: `username.isEmpty ?` → `true ?` (מפתח-גלובלי תמיד, מתעלם מ-username).
- תוצאה: טסט "#99" **אדום `+0 -1`** — omer ירש את 440 של ran (440≠340 seed). שחזור → **ירוק** · RESTORED-IDENTICAL.
- מסקנה: כל המשתמשים חלקו `bs.rewards.v1` יחיד → P-6/F-33 leak. עכשיו המפתח כולל username → פרטי per-user; ה-provider מ-re-build על שינוי-session. leaderboard משותף (החלטת-בעלים). אין מיגרציה ממפתח-גלובלי (מטבעות דמו מקומיים) — נרשם. analyze 0 · t3 מלא ירוק אחרי תיקון-binding.

### #99-addendum — board_auth._load resilience (root-cause of the gate-32 baseline) — 2026-06-16
- כש-`rewardsProvider` התחיל `ref.watch(boardAuthProvider)` (#99), כל טסט שמרנדר מסך-קורא-rewards (worker/courier reports · rewards hub · drilldowns) בנה את `BoardAuthNotifier`. ב-`_load` ה-`await SharedPreferences.getInstance()` **לא** היה ב-try/catch (רק ה-jsonDecode) — וב-context בלי `setMockInitialValues`/binding זה זורק "Binding not initialized" (StateError) כשגיאה אסינכרונית **לא-מטופלת** → הטסט נכשל.
- **התיקון:** עטיפת כל ה-`_load` ב-try/catch (כמו rewards_state ומנועים אחרים) → כשל-prefs נבלע, נשאר logged-out. תיקון-robustness אמיתי.
- **בונוס:** זה היה גם שורש ה-baseline הקדם-קיים `worker_reports_drilldown` (קורא דרך drilldown→boardAuth). אחרי התיקון הסוויטה המלאה = **+2658 ALL PASS, 0 כשלים**. baseline עודכן 1→0 (STATUS.md + known_failing.txt).
- **קבצים נוספים ל-#99:** `lib/state/board_auth.dart` · `knowledge/STATUS.md` · `knowledge/known_failing.txt`.

## #36-voice-dictate-worker-board — כפתור קול↔הקלדה בלוח-העובד — 2026-06-16
- **קבצים:** חדש `lib/widgets/voice_dictate_button.dart` (VoiceDictateButton — IconButton-מיקרופון שמכתיב דרך VoiceService.listen ומצרף את הטקסט ל-controller; seams listenFn/stopFn לבדיקה). `worker_app_screen.dart` — מחווט כ-suffixIcon ל-3 שדות-הטקסט בגיליון-הצעת-המשימה (שם/תיאור/שלבים). טסט חדש `voice_dictate_button_test.dart` (+2). לוח-עובד בלבד (החלטת-בעלים #36), לא app-wide.
- **load-bearing:** `_append` — `if (t.isEmpty) return;` ואז כתיבת ה-controller. מוטציה: `if (t.isEmpty) return;` → `return;` (תמיד early-return, אף פעם לא מצרף).
- תוצאה: שני טסטי-#36 **אדומים `+0 -2`** — אחרי tap השדה לא השתנה. שחזור → **+2 ירוק** · RESTORED-IDENTICAL.
- מסקנה: ההכתבה ממלאת את השדה שבו המשתמש (append, cursor בסוף — לא דורסת הקלדה), במקום הבאג המקורי שבו קול הפעיל חיפוש-קטלוג. ה-STT מוזרק (seam) לבדיקה בלי מיקרופון. analyze 0.

## #45-weather-open-meteo — תחזית מזג-אוויר אמיתית (Open-Meteo + GPS) — 2026-06-16
- **קבצים:** חדש `lib/services/weather.dart` — `fetchOpenMeteoDaily` (Open-Meteo, חינמי ללא-מפתח, http-seam מוזרק) plus `weatherDaysFromOpenMeteo` (mapper טהור: WMO weather_code → אמוji/הערה/טמפ) plus `weatherIconFor`/`weatherNoteFor` plus `weatherForecastProvider` (FutureProvider: currentGeoFix→fetch→map, fallback ל-kWeather ב-no-GPS/רשת/parse). `ai_hub_screen.dart` — `_Weather` הפך ל-ConsumerWidget שצורך את ה-provider במקום ה-seed הקשיח; ההערה "⚙️ בפרודקשן API חיצוני" → "🌦️ Open-Meteo · לפי מיקום". טסט חדש `weather_service_test.dart` (+3).
- **load-bearing:** `weatherNoteFor` ענף-הגשם (51-67) `'⚠️ גשם — לדחות יציקות בטון'`. מוטציה: `⚠️ גשם` → `גשם`.
- תוצאה: טסטי-#45 **אדומים `+1 -2`** — days[2].warn (code 61) הפך false, ו-thresholds-test נכשל. שחזור → **+3 ירוק** · RESTORED-IDENTICAL.
- מסקנה: הכלי היה deferred כי "צריך API חיצוני" — Open-Meteo חינמי ללא-מפתח פותר זאת. ה-fetch מוזרק (seam) אז ה-mapper נבדק בלי רשת/GPS; ה-provider נופל ל-seed בחן (ב-VM אין GPS → seed מיידי, מסך לא נשבר). analyze 0 · ai_hub_compute/robustness ירוקים. נשאר deferred/hidden ל-Apple — un-hide הוא flip של הבעלים בשחרור; schedule-automation = micro-confirm עתידי.

## #31-help-coverage-wave1 — מצב-היכרות: chrome ראשי של הקבלן (home_shell) — 2026-06-16
- **קבצים:** `lib/widgets/help_target.dart` — נוסף `showHelpInfo` (כרטיס-הסבר מרכזי לאלמנטים שאי-אפשר לעגן להם בועת-זנב, כמו טאבים תחתונים). `lib/screens/home_shell.dart` — לוגו→חיוג-תפקיד, שבב-השם→פרופיל, חיפוש, ו-4 וריאנטי תפריט-⋮ נעטפו ב-HelpTarget; 4 טאבי-הניווט מקבלים הסבר במצב-היכרות דרך showHelpInfo במקום ניווט. טסט חדש `help_coverage_test.dart` (+2).
- **load-bearing:** ב-onTap של הניווט התחתון `body: _kTabHelp[i].$2` (ההסבר של הטאב הנלחץ). מוטציה: `.$2` → `.$1` (מציג את שם-הטאב במקום ההסבר).
- תוצאה: טסט-הטאב **אדום `+1 -1`** — אחרי tap על "עדכונים" לא הופיע ההסבר "ההתראות והשיחות". שחזור → **+2 ירוק** · RESTORED-IDENTICAL.
- מסקנה: ה-💡 וה-✕ נשארים ללא-עטיפה כדי שתמיד אפשר לצאת מהמצב; אלמנטים מחוץ לשכבת-ההקפאה מוסברים דרך showHelpInfo. גל 1 מתוך כיסוי-לפי-לוח (קבלן→שליח→חנות→מנהל→עמוק). analyze 0.

## #31-help-coverage-wave2 — מצב-היכרות: לוח השליח (courier_dashboard) — 2026-06-16
- **קבצים:** `lib/screens/courier_dashboard_screen.dart` — נוסף `const HelpToggleButton()` ל-AppBar (קריטי — בלעדיו אי-אפשר להיכנס למצב-היכרות בלוח השליח); עטיפת פעמון/פרופיל/הגדרות/יציאה + בורר-הרכב ב-HelpTarget; 4 טאבי-הניווט מקבלים הסבר דרך showHelpInfo במצב-היכרות במקום החלפת-טאב. טסט חדש `help_coverage_courier_test.dart` (+2). כפתורי קידום-המשלוח+POD שבתוך כרטיסי-הרשימה + בורר-הרכב בטאב המשלוחים נדחו לתת-גל courier-deep.
- **load-bearing:** `const HelpToggleButton()` ב-AppBar של השליח (נקודת-הכניסה היחידה למצב-היכרות בלוח). מוטציה: `const HelpToggleButton(),` → `const SizedBox.shrink(),`.
- תוצאה: שני טסטי-השליח **אדומים `+0 -2`** — אין toggle אז find.byType(HelpToggleButton) ריק, ולא ניתן להיכנס למצב כדי שהפעמון יסביר. שחזור → **+2 ירוק** · RESTORED-IDENTICAL.
- מסקנה: עטיפת אלמנטים בלוח חסרת-ערך בלי toggle להפעלת המצב — כל לוח (שליח/חנות/מנהל) חייב HelpToggleButton משלו. analyze 0 (info יחיד comment_references קדם-קיים). גל 2/7 בכיסוי-לפי-לוח.

## #31-helpfix-bottomnav — טאבים תחתונים: HelpTarget אמיתי במקום כרטיס-מרכזי — 2026-06-16
- **קבצים:** `lib/widgets/help_target.dart` — widget משותף חדש `BottomNavCell` (תא-ניווט icon+label שאפשר לעטוף ב-HelpTarget). `lib/screens/home_shell.dart` + `lib/screens/courier_dashboard_screen.dart` — ה-BottomNavigationBar הוחלף ב-Material+Row של BottomNavCell, כל טאב עטוף ב-HelpTarget (קבלן: בית/מחלקות/עדכונים/חנות · שליח: משלוחים/פורטל/דוחות/אזור אישי). הוסר ענף showHelpInfo (+ משתנה helpMode הלא-נחוץ בשליח). טסט `help_coverage_test` עודכן.
- **הבאג שתוקן:** הטאבים השתמשו ב-showHelpInfo (כרטיס מרכזי) + בלי טבעת → לא מודגשים והבועה לא יצאה מהם, בניגוד למצלמה/⋮. עכשיו עקבי: טבעת כתומה + בועה מעוגנת מכל טאב.
- **load-bearing:** `body: _kTabHelp[i].$2` ב-HelpTarget של הטאב. מוטציה: `.$2` → `.$1` (הבועה תציג את שם-הטאב במקום ההסבר).
- תוצאה: טסט-הטאב **אדום `+1 -1`** — אחרי tap על "עדכונים" לא הופיע "ההתראות והשיחות". שחזור → **+2 ירוק** · RESTORED-IDENTICAL. אומת חי בדפדפן (Chrome extension): טבעת על כל 4 הטאבים + בועה יוצאת מ"עדכונים".
