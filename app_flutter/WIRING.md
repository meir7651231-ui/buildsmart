# WIRING CONTRACT — app_flutter

## #p2-w4a — Phase-2 גל-4א: עמודת-ח״פ אופציונלית בייבוא-הלקוחות (בית ל-validBusinessId) — 2026-07-27
**לולאת-סיום (W4a) — פיבוט מ"ייבוא-ספקים".** ממפה-הנחיתה הכריע (verdict b): אין ישות-רשימה של ספקים/עסקים עם ח״פ לייבא אליה — ח״פ חי רק על פרופילים-עצמיים (UserProfile/StoreProfile/EmployerProfile), ובניית "ייבוא-ספקים" תהיה המצאת-ישות (נגד "אין המצאות"). **הפיבוט הנקי:** הלקוחות עצמם *הם* עסקים (זרעי-הלקוחות: 'אלי בניין בע״מ' וכו') → נתתי ל-`validBusinessId` (גל-2א) שורת-ייבוא אמיתית בהרחבת ייבוא-הלקוחות שכבר-נשלח. `SavedCustomer` קיבל שדה `businessId` **אופציונלי** (default '', omit-when-empty ב-toJson ⇒ בדיקות-2ב-codec נשארות ירוקות; תוקן גם ה-reconstruction ב-upsertCustomer שאחרת היה מאבד ח״פ). `parseCustomerCsv` קיבל עמודת-ח״פ (aliases: ח.פ · ח"פ · עוסק מורשה · business_id · tax_id …) — מאומתת ב-validBusinessId כשקיימת (ח״פ-פסול → שגיאה חוסמת), נשמרת כשתקינה. התבנית קיבלה את העמודה + לגנדה. **reuse מלא של הפרוסה שנשלחה** — store (importAll), שער (manager.customers), משטח (גיליון-הייבוא), בלי שינוי-UI. בדיקות: הרחבת customer_import_test (ח״פ-תקין נשמר · ח״פ-פסול נדחה · נעדר→ריק) — 25 ירוקות בסוללה **כולל customers_store-2ב הנעול** · mutation ×2 (ולידציית-ח״פ כבויה→אדום · ח״פ-לא-נשמר→אדום) · analyze 0 · guards ×3. **ח״פ סוף-סוף נבדק בייבוא — בלי המצאת-ישות.**

## #p2-w4b — Phase-2 גל-4ב: מסמך תעודת-משלוח על רכבת printable_docs — 2026-07-27
**לולאת-סיום (W4b) — טיפוס-מסמך שני על רכבת-המסמכים.** אחרי חשבונית/קבלה (w3ה), תעודת-משלוח על אותה רכבת (`buildPrintableHtml`→`printDocument`). `lib/logic/delivery_note.dart` טהור: `buildDeliveryNoteRows(Order)` — פרטי-הזמנה + כתובת-אספקה + תאריך + פריטים כ**שם×כמות בלבד**; **בכוונה אפס כסף/מע"מ** (תעודת-משלוח היא סחורה, לא תשלום — זה תפקיד invoice.dart). `deliveryNoteTitle(Order)`. כפתור "📦 תעודת משלוח" בגיליון-פרטי-ההזמנה, ליד כפתור-החשבונית, מגודר **`orders.deliveryNote`** — **גייט נפרד** מ-`orders.invoicing` (חברה יכולה להדליק אחד בלי השני; independence מאומת בבדיקה). כבוי כברירת-מחדל ⇒ אין כפתור ⇒ הגיליון זהה-בייטים. בדיקות: kernel-4 (meta+shipTo+date+פריטים-ללא-מחיר · אפס-₪/total/VAT · שדות-רשות-נעדרים · title) + gate-3 (כבוי אין-כפתור · דלוק יש · שני-הגייטים-עצמאיים) = 7 · mutation ×2 (גייט תמיד-דלוק→אדום · דליפת-מחיר-לשורה→אדום) · analyze 0 · guards ×4.

## #p2-w3e — Phase-2 גל-3ה: מסמך חשבונית/קבלה על רכבת printable_docs — 2026-07-26
**גל-3 החצי-השני (מסמכים).** המפה אישרה: חשבונית/קבלה = טיפוס-מסמך **net-new על רכבת קיימת** (`buildPrintableHtml`→`printDocument`, idiom טופסי-העובד) — אין builder קיים. **מוקש-אמת שהמפה תפסה:** `order.sum` הוא ברוטו כולל-מע"מ(+משלוח) בעוד `OrderLineItem.price` לפני-מע"מ → Σprice×1.18 סוטה מ-order.sum. קרנל טהור `lib/logic/invoice.dart`: `invoiceVatOf(gross)=gross−round(gross/1.18)` — **חילוץ-מע"מ-לאחור** (מראה `cartVat(vatInclusive:true)`, `kVatRate` single-source), כך ש-(gross−vat)+vat≡gross — **מתשלב תמיד ל-order.sum, אפס-סטייה, בלי סכום-ביניים מפוברק**. `buildInvoiceRows(order)`→שורות label/value (מספר·לקוח·אתר·פריטים-מידעיים·סה"כ=order.sum·מזה-מע"מ) · `invoiceTitle(receipt:)` חשבונית/קבלה. כפתור "🧾 הפק חשבונית" ב-`_OrderDetailSheet` (אזור-הפעולה, אחרי advance) מגודר **`featEnabled(ref,'orders','invoicing')`** (orders=core → לא-נכבה; feature default-OFF) → buildPrintableHtml→printDocument (web-iframe/native-false→toast). ברירת-מחדל כבוי ⇒ אין כפתור ⇒ גיליון-ההזמנה זהה-בייטים. הרכבת עצמה (printable_docs/doc_print) **לא-נגעה** (additive). בדיקות: kernel-6 (חילוץ-מע"מ · reconcile ×7 · שורות · אתר-מושמט · כותרת) + gate-2 (כבוי אין-כפתור · דלוק יש) · mutation ×2 (שער תמיד-דלוק→אדום · **מע"מ-נאיבי→אדום** — המוקש) · analyze 0 · guards ×5 · 45 ירוקות בסוללה (כולל printable_docs+manager_dashboard הנעולים).

## #p2-w3d — Phase-2 גל-3ד: UI ייבוא-לקוחות — trigger מגודר + גיליון + importAll — 2026-07-26
**גל-3 (איכות) — סגירת ייבוא-הלקוחות (w3ב→w3ד).** ה-UI על מנוע-w3ג. (1) `CustomersStore.importAll(List)` — מקפל כל שורה דרך `upsertCustomer` (אותו dedup) ומשים state **פעם אחת** (persist יחיד; per-row upsert היה כותב prefs N פעמים). (2) `lib/screens/customer_import_sheet.dart` — clone מותאם של גיליון-הקטלוג: תבנית↓ · העלאה→`parseCustomerCsv`→שגיאות-אטומי (כל שגיאה ⇒ 0 commit) · הצלחה→`importAll(report.valid)` + "✅ נטענו N לקוחות" · אזהרות-איכות לא-חוסמות (reuse `auditRows` — key=טלפון · name=שם → מזהה "אותו טלפון, שם שונה"/"אותו שם, טלפון שונה" שה-hard-dedup מרשה). (3) trigger בטאב-הלקוחות (אחרי ה-chips) מגודר **`featEnabled(ref,'manager','customers')`** — אותו opt-in של בלוק-הלקוח-השמור שהוא מזין; **כבוי כברירת-מחדל ⇒ אין כפתור ⇒ הטאב זהה-בייטים** (demo/live לא מגיעים). בדיקות: gate-טאב ×2 (כבוי אין-כפתור · דלוק יש) + זרימת-גיליון (picker-override→upload→"נטענו 2"+אזהרה+store=2) + importAll ×2 (dedup-מקפל · ריק-no-op) = 5 · mutation ×2 (trigger תמיד-דלוק→אדום · importAll no-op→אדום) · analyze 0 · guards ×4 · 34 ירוקות בסוללה (כולל customers_store-2ב שלם). **גל ייבוא-הלקוחות שלם:** kernel משותף→פרסר→UI, הכל מגודר/זהה-בייטים-כבוי. **ח"פ עדיין מחוץ** (שדה-onboarding-עסקי) — פרוסה עתידית אם יידרש ייבוא-ספקים.

## #p2-w3c — Phase-2 גל-3ג: פרסר ייבוא-לקוחות המוני על ה-CSV-kernel — 2026-07-26
**גל-3 (איכות) — מנוע ייבוא-הלקוחות (נותן סוף-סוף שורה לוולידטורים phone/email של גל-2א).** ייבוא-לקוחות היה net-new (שלושת המייבאים הקיימים מייצרים מוצרים). `lib/data/customer_import.dart` טהור: `parseCustomerCsv(raw)→CustomerImportReport{valid:List<SavedCustomer>, errors}` על `csv_kernel` של w3ב (אותו tokenizer, autodetect `,`/`;`, שער-UTF8, מספרי-שורה פיזיים). חוזה זהה לפרסר-הקטלוג: **name** היחיד חובה; **phone/email** מאומתים כשקיימים (`validIsraeliMobile`/`validEmail`); notes חופשי; tags מפוצל ב-`|`. **gate אטומי `canCommit`** (0 שגיאות ו-≥1 שורה) — כל שגיאה ⇒ 0 commit. `customerCatalogTemplateCsv()` BOM-ראשון, כל שורות-הדוגמה מסומנות `#` ⇒ העלאה-מחדש של התבנית-הנקייה = 0 שורות. **id דטרמיניסטי** `imp:${normName|normalizePhone}` — **לא שעון-קיר** (לולאת-bulk ב-web טובעת ms זהה ⇒ id-שעון היה מתנגש ו-upsertCustomer היה מכווץ שורות-שונות בשקט; id-מ-dedupKey גם הופך re-import לאידמפוטנטי). כפילות-בקובץ (normName+phone זהה) = שגיאה-קשה (כמו מק"ט-כפול). **בלי שינוי-ישות** (ח"פ שדה-onboarding-עסקי, לא שדה-לקוח → מחוץ לייבוא-לקוחות) **ובלי UI עדיין** — זה המנוע; הגיליון-המגודר + trigger הוא w3ד. בדיקות: 9 פרסר (happy+tags · id-דטרמיניסטי/אידמפוטנטי · עמודת-שם-חסרה→שורה1 · תא-שם-חסר→שורה-פיזית · טלפון-לא-תקין · אימייל-לא-תקין · כפילות-בקובץ · אטומי-ללא-commit · `;`-autodetect · תבנית→0-שורות) + kernel-11 = 20 ירוקות · mutation ×2 (ולידציית-טלפון-כבויה→אדום · dedup-כבוי→אדום) · analyze 0 · guards ×4.

## #p2-w3b — Phase-2 גל-3ב: חילוץ CSV-kernel משותף מפרסר-הקטלוג — 2026-07-26
**גל-3 (איכות) — פרוסת-תשתית לקראת ייבוא-לקוחות.** הפרוטוקול מחייב "מצא → helper" (reuse, לא כפילות). כדי שפרסר-לקוחות עתידי יעמוד על אותו tokenizer חסין ולא ישכפל ~60 שורות, חילצתי את פרימיטיבי-ה-CSV מ-`company_catalog_import` למודול טהור-משותף `lib/data/csv_kernel.dart`: `CsvRecord` · `parseCsvRecords(text,sep)` (RFC-4180-ish, quoted/`""`/newline-in-quote/CRLF, אף-פעם לא-זורק) · `normHeader` · `csvIsBlank`/`csvIsComment`/`csvHeaderIndex` · `csvHeaderScore(records,knownHeaders)` · `tokenizeCsvAutodetect(text,knownHeaders)` (בחירת `,`/`;` לפי ניקוד-כותרת, תיקו→`,`). `company_catalog_import` עכשיו **צורך** אותם (מחק את ההעתקים המקומיים; `_headerScore` הפך ל-`csvHeaderScore` עם `_kKnownHeaders` = איחוד כל aliases-העמודות). **זהות-בייטים מוכחת:** הסוויטה הנעולה `company_catalog_import_test` (22) עוברת ללא-שינוי — כל סטייה-בהתנהגות הייתה מאדימה אותה. 4 מחרוזות-ה-guard בפרסר (canCommit · מק"ט כפול · לגנדת-התבנית) נשארו במקומן. בדיקות: kernel-11 ישיר (tokenize · header-helpers · autodetect) + פרסר-נעול-22 = 33 ירוקות · analyze 0 · guards ×3. **אפס-פיצ׳ר, אפס-שער — refactor טהור.** מכין את w3c (parseCustomerCsv על ה-kernel).

## #p2-w3a — Phase-2 גל-3א: ערוץ-אזהרות איכות-נתונים על ייבוא-הקטלוג — 2026-07-26
**גל-3 (איכות-נתונים) — פרוסה ראשונה.** המפה הכריעה: נתיב-הייבוא **כבר בעל ולידציה-אטומית חזקה** (שגיאות חוסמות commit) — לא זבל-נכנס; והוולידטורים phone/ח"פ **אין להם שורה** בייבוא-הקטלוג (מוצרים בלי טלפון). הפער-ה-additive האמיתי: dedup-ה-sku הוא **raw בלבד** → מפספס כפילויות-שם ו-sku שנבדל רק ברישיות/רווח, ואין ערוץ-אזהרות לא-חוסם. קרנל טהור חדש `lib/logic/data_quality.dart`: `auditRows(List<QualityRow>)→QualityReport` — **אזהרות לא-חוסמות** מעבר-לפרסור: `dup-name` (normName מתנגש, מק"ט שונה — "אותו מוצר, מק"ט אחר") · `near-key` (normName(מק"ט) מתנגש — נבדל רק ברישיות/רווח). גנרי (QualityRow דק) → ייבוא-לקוחות עתידי יעשה reuse. **חיווט מגודר `featEnabled(ref,'catalog','validation')`** בגיליון-הייבוא (`company_catalog_import_sheet` — `ref.read` ב-handler, `strict` bool): אחרי commit-מוצלח, מעבר-איכות על `report.valid` → סעיף "⚠️ N אזהרות איכות (לא חוסמות)". **הפרסור `parseCompanyCatalogCsv` לא-נגוע** (הסוויטה הקיימת נשארת ירוקה — byte-identical); ברירת-מחדל (opt-in כבוי) ⇒ `_quality` null ⇒ אין-סעיף ⇒ זהה-בייטים. שער `catalog.validation` (catalog=core → לא-נכבה בטעות; feature default-OFF). בדיקות: kernel-6 (dup-name·near-key·both·clean·empty·3-way) + gate-2 (OFF-מתחייב-בלי-אזהרות · ON-אזהרה-לא-חוסמת) · mutation ×2 (dup-name-כבוי→אדום · near-key-כבוי→אדום) · גארדים ×5 · analyze 0 · 30 ירוקות (כולל company_catalog_import הנעול — הפרסור לא-זז). **פרוסות-איכות אפשריות הבאות:** ייבוא-לקוחות/ספק (לתת ל-phone/ח"פ/email שורה) · טיפוסי-מסמך חדשים (חשבונית/קבלה על רכבת printable_docs הקיימת). **"מסמכים" אינו greenfield** — יש printable_docs.dart + finance_report_pdf + doc_print seam.

## #p2-w2d — Phase-2 גל-2ד: דירוג-לקוחות RFM (הפרוסה האחרונה של גל-CRM) — 2026-07-26
**בנייה-חדשה (מפה הכריעה: אין מנוע-דירוג; ה-intel/segments התנהגותי·כבוי·אורתוגונלי).** קרנל טהור חדש `lib/logic/customer_score.dart` בתבנית attention_engine: `scoreCustomer(RfmInput)→CustomerScore`. RFM בספים-מוחלטים (לא-אחוזונים → טהור פר-לקוח): Frequency=מספר-הזמנות · Monetary=סך-רכש (מ-ManagerCustomer) · Recency=ימים-מאז-האחרונה. כל ממד 0/1/2; דרגה (`champion`/`loyal`/`occasional`/`dormant`) מיחס-הנקודות; אות-פעולה `atRisk` (היה בעל-ערך F+M≥3 והתקרר). **recency מ-`Order.createdAt`** (יורד ב-toManagerOrder → מחושב בפרוביידר `lib/state/customer_score_source.dart`, השעון שם, הקרנל נקי-משעון); **זרעים חסרי-תאריך → FM-בלבד (maxPoints 4)** — כן, ולא crash. **badge מגודר `featEnabled(ref,'manager','scoring')`** על כרטיס-הלקוח (`_RfmPill` — pill טוקני-בהיר, **לא** progress-bar כי מספר-הברים-לכרטיס נעול; **לא** '👷' נוסף; מחרוזת-נבחנת ' p/maxP'), ברירת-מחדל כבוי ⇒ **זהה-בייטים**. **"finder"=חפיפת-שמות** (תיבת-2c היא מאתר-השמות; הערך-החדש הוא הדירוג עצמו — `ratio`/`atRisk` יכולים למיין/למקד). שער `manager.scoring` ולא `intel.rfm` (הימנעות מצימוד לטאב-המודיעין). בדיקות: kernel-8 (FM-בלבד·RFM-מלא·דרגות·atRisk·ספים) + gate-2 (OFF-אין-badge · ON-4-pills-‏/4) · mutation ×2 (atRisk-כבוי→אדום · שפלת-FM-מוסרת→אדום) · גארדים ×6 · analyze 0 · 42 ירוקות (רגרסיית-מנהל הנעולה עברה).

### ✅ גל-CRM (2א→2ד) הושלם — 4 פרוסות, כולן ירוקות ומגודרות
| פרוסה | מה | שער |
|---|---|---|
| 2א | ליבה: תיקון-ח"פ + נרמול + fuzzy | a59365dc |
| 2ב | ישות-לקוח שמורה + dedup | 5cd0ccd2 |
| 2ג | חיפוש-לקוחות סובל-שגיאות | 0b00621d |
| 2ד | דירוג RFM + badge | (זה) |
כולן additive · opt-in · זהה-בייטים-כשכבוי · האפליקציה החיה לא זזה. **הבא (אחרי דיווח-גל):** גל-3 (איכות-נתונים) או חיבור-מנוע-ה-workflow לצרכן-חי.

## #p2-w2c — Phase-2 גל-2ג: חיפוש-לקוחות סובל-שגיאות (search.fuzzy) — 2026-07-26
**הצרכן הראשון של מנוע-ה-fuzzy מ-2א.** תיבת-חיפוש בטאב-הלקוחות של המנהל, מגודרת opt-in `featEnabled(ref,'search','fuzzy')` — כבויה בברירת-מחדל ⇒ הטאב זהה-בייטים (אין תיבה, הרשימה לא-מסוננת). **נקודת-חיבור אחת** (`_CustomersTab` — הקיפול של הרשימה): הפרדיקט מרכיב **AND** את סינון-הצ׳יפ הקיים (status) עם התאמת-השם ה-fuzzy — שאילתה-ריקה = pass-through (סינון-הצ׳יפ לא-משתנה; רגל-המפתח "reflow מוסיף 5" שורדת). **`fuzzyNameMatch` חדש (additive ל-fuzzy_match):** מחרוזת-שלמה או **כל מילה** בשם (כך 'כוהן' פוגע ב'יוסי כהן' — מילה בתוך שם רב-מילים). idiom: setState מקומי + TextEditingController (שיבוט contractor_tools_sheets, בלי provider בלי debounce — סט-לקוחות זעיר). placeholder: `'חיפוש ${orgTerm(ref,'nav.customers','לקוחות')}'` (מונח-V3 `nav.customers` שנפתח). **החלטה (ממפה):** מחפשים את הרשימה-הנגזרת בלבד (ל-saved-בלי-הזמנות אין כרטיס לרנדר) · עצמאי מ-`manager.customers`. בדיקות: search-3 (OFF-אין-תיבה-4-כרטיסים · ON-מסנן-סובל-שגיאות · ריק=pass-through) + fuzzyNameMatch-leg ב-crm_core · mutation ×2 (סינון-מתאים-להכל→אדום · מודעות-מילים-כבויה→אדום) · גארדים ×4 · analyze 0 · 45 ירוקות (רגרסיית-מנהל הנעולה עברה). **לקח:** סף-fuzzy `floor(len/3)+1` רופף על שאילתה-קצרה (‏'לוי'≈'יוסי' במרחק 2) — נאמן-למאור אבל רועש; הבדיקה השתמשה בשאילתה-מובחנת. **פרוסת-CRM אחרונה:** finder + RFM/דירוג-אמינות.

## #p2-w2b — Phase-2 גל-2ב: ישות-הלקוח השמורה (dedup + AUGMENT) — 2026-07-26
**הפער האסטרטגי (מפת-מאור #3): היום "לקוח"=אגרגט-נגזר מהזמנות לפי שם — אין ישות שמורה.** קובץ חדש `lib/state/customers_store.dart`: `SavedCustomer{id·שם·טלפון·מייל·הערות·תגיות}` + `CustomersStore` (StateNotifier+persist, שיבוט orders_engine: guard-first·tolerant-per-entry·write-behind, מפתח `bs.saved-customers.v1`). **`upsertCustomer` טהור — dedup-על-קלט:** מפתח=`normName(שם)+normalizePhone(טלפון)` (ליבת-2א); התאמה=**עריכה-במקום** (שומר id+מיקום), אחרת append — לעולם לא כפילות. **`customerForName` — חיבור הזמנה→לקוח לפי-שם מנורמל (אפס-מיגרציה — אותו מפתח שהטאב כבר משתמש בו, בלי Order.customerId חדש).** **AUGMENT ולא replace:** `ManagerCustomer` + 17 קריאות-הבנאי + `managerCustomersProvider` הנגזר — **לא-נגועים**; בלוק חדש `_SavedCustomerSection` בגיליון-הפרטים הקיים (`_CustomerDetailSheet`) מגודר `featEnabled(ref,'manager','customers')` (opt-in), מציג טלפון/מייל/הערות/תגיות של הישות-המתאימה-בשם + עורך (`_SavedCustomerEditor`, upsert). **מונחי-V3 שנפתחו:** `entity.customer` (RESERVED) חובר סוף-סוף דרך orgTerm. בדיקות: store-9 (dedup/lookup/codec/persist טהור) + gate-3 (OFF-זהה·ON-מרנדר-בשם·ריק-מזמין) · mutation ×2 (dedup-כבוי→אדום +6−3 · fold-חיבור-מוסר→אדום +8−1) · גארדים ×6 · analyze 0 · 49 ירוקות (כולל רגרסיית-מנהל+repositories הנעולה — AUGMENT לא-שבר). **החלטות שהתקבלו (ממפה):** קישור-לפי-שם (לא id) · store-נפרד (לא הזרקה ל-managerCustomersProvider) · creditLimit לא-מפוברק (הנתיב-הנגזר שומר 0/"לא רשומה"). **פרוסות-CRM הבאות:** חיפוש-לקוחות סובל-שגיאות (`search.fuzzy`, על fuzzy_match מ-2א) → finder → RFM/אמינות.

## #p2-w2a — Phase-2 גל-2א: ליבת-CRM המשותפת (do-first) — 2026-07-26
**נצחון-מהיר · תיקון-באג טהור (בלי טוגל):** `validBusinessId` (input_validators.dart) היה 9-ספרות-בלבד — עכשיו + ספרת-ביקורת ישראלית 1-2-1-2 (חילוף>9=−9, סכום≡0 mod 10). ח"פ שגוי-מוקלד כבר לא עובר. **הפיקסצ'רים שהיו נעולים על 512345678 (סכום 39=פסול!) הוחלפו ל-512345679 (תקין)** — הבאג היה גם בבדיקה. **`normalizePhone` חדש** (צורת-`0…` קנונית לאחסון/dedup — נבדל מ-`waMeDigits` שמפיק `972…` יוצא). **ליבת-נרמול משותפת חדשה `lib/logic/text_normalize.dart`:** `normSearch`/`normName` — חולצו מ-`_normSearch` הפרטי של workflow_engine (**זהה-בייטים** — כל בדיקות ה-workflow עוברות), נקודת-אמת אחת לכל צרכני-החיפוש. **`lib/logic/fuzzy_match.dart` חדש — הפרימיטיב שהיה חסר:** Damerau-Levenshtein (כולל חילוף-שכנים) + סף `floor(len/3)+1` + `fuzzyMatch`/`fuzzyScore`, מעל הנרמול המשותף. **`data/fuzzy_search.dart` (contains-בלבד) לא-נגוע** — נעול ב-6 סוויטות; ה-fuzzy האמיתי הוא כלי-חדש לצרכן-מגודר בפרוסה הבאה. בדיקות core-16 + validators-מורחב · mutation ×2 (ספרת-ביקורת-מדולגת→אדום · חילוף-Damerau-כבוי→אדום) · גארדים ×7 · analyze 0 · 62 ירוקות. **פרוסות-CRM הבאות:** ישות-לקוח שמורה (dedup דרך normName/normalizePhone, מגודר `manager.customers`) → חיפוש-לקוחות סובל-שגיאות (`search.fuzzy`) → finder → RFM/אמינות.

## #p2-w1b — Phase-2 גל-1ב: קרנל-ה-workflow (מכונה-נתונה-לשם, טהור) — 2026-07-26
**דפוס מ-Maor `ayin.ts` — הדפוס עובר, הקוד לא.** קובץ-טהור חדש `lib/logic/workflow_engine.dart`: `WfStage{intake·prep·ready·dispatch·done}` (5-שלבים, מפתחות-סריאליזציה יציבים) · **כל תווית דרך termOf** (`nav.workflow`·`entity.wfItem/wfUnit`·`workflow.stage.*` — ורטיקל משנה-שם את כל הזרימה בלי קוד) · guards פר-שלב (intake צריך שם · ready צריך כמות · done סופי) · `planWfAdvance` מתכנן-מעבר טהור (patch+אירוע+toast) עם **מסירה 2-לחיצות** (לחיצה-1=dispatchPushed נשאר · לחיצה-2=done — סמנטיקת ayin) · `wfRevertPatch` (חזרה-לפני-מסירה מנקה pushed) · `planAddName` (dedup לפי שם-מנורמל-עברי: ניקוד/סופיות/רווחים · כמות=רשומת-log) · `wfDailyRows` ("טופל-היום") · `_normSearch` מקומי (port validate.ts — גל-3 יחלץ לליבה). **additive-נטו: אף מנוע/מסך לא נגוע** (3 המכונות נעולות ב-6 חוזי-בדיקה — ההנחיה אוסרת לגעת). **אין צרכן-חי בפרוסה** (מוצהר): הצינור-גבייה והתזמון שההנחיה הניחה לא-קיימים בקוד (מופו ודווחו), והמכונות off-limits — לכן נוחתים הקרנל-המוכח עכשיו, הצרכן-הראשון בעיצוב-עם-הבעלים. ברירת-מחדל זהה-בייטים (אף קובץ לא מייבא אותו). בדיקות 14 (חוזה ayin.test) · mutation ×2 (2-לחיצות-קורס→אדום · dedup-כבוי→אדום) · גארדים ×5 · analyze 0. **גל-1 (Phase-2) הושלם: מנוע-התראות + קרנל-workflow.**

## #p2-w1a — Phase-2 גל-1א: מנוע-ההתראות ("דורש-טיפול") — 2026-07-26
**דפוס מ-Maor `homeData.ts` (attentionItems/digestLines) — הדפוס עובר, הקוד לא; לבוש-מחדש לבנייה, לוח-עברי נוטרל.** קובץ-טהור חדש `lib/logic/attention_engine.dart`: fan-in DTO (`AttentionInput`) → פריטים מדורגים `AttentionItem{key·tag·title·sev·navTab}` + `DigestLine`. כללים: הזמנות-פתוחות ותיקות (≥3 י'=warn · ≥7=crit · עד-3 פרטני+צבירה) · אישורי-עובדים (≥8=crit — עומס-מצטבר · אחרת warn) · חופשות · בקשות-חשבון. **crit-לפני-warn בחלוקה-יציבה** (Dart sort לא-יציב — מפצלים; מוכח-חי: crit-מאוחר קופץ מעל warn-מוקדם). termOf לכל תג. שכבת-ספק `lib/state/attention_source.dart` (קוראת ordersEngine/approvals/vacations/roleRequests → DTO; ageDays מ-createdAt; role-reqs שרת=0-בדמו). **מוקש-סמנטיקה שנתפס:** `featureOn` הוא opt-OUT (חסר=דלוק) — פיצ'ר-חדש חייב default-OFF-לחי; הוספתי **`featureEnabled`/`featEnabled` (opt-IN: `==true`, מפל-מודול)** — הגדר `manager.attention` נכבה בברירת-מחדל ⇒ הקוקפיט זהה-בייטים; דלוק רק כשחברה מדליקה. הרכבה: כרטיס `_AttentionCard` מעל ה-KPIs (שורות → drill ל-managerTabProvider · ריק=SizedBox.shrink). בדיקות: engine-8 (טהור) + gate-3 (OFF-זהה/ON-מרנדר+drill/מפל-מודול) + featureEnabled-4 ב-org_config · mutation ×2 (חלוקה-הוסרה→אדום · opt-in↔opt-out→‎+12−2) · גארדים ×7 · 22 ירוקות + רגרסיית-מנהל-51. **נדחה-במוצהר:** deep-link לסקשן-אקורדיון ספציפי (managerTab בלבד — `_open` מקומי, הרמה=פרוסה-הבאה) · תור-פיננסים/מלאי כמקורות (לא-מחווטים לדשבורד היום). **גל-1ב הבא:** קרנל-ה-workflow (ayin — מכונה-נתונה-לשם + guards + next-touch + טופל-היום).

## #giant-v6 — V6: נתיב-החברה האפוי + ערוץ-plumbing (ההוכחה) — 2026-07-26
**הנתיב שנשמר ב-V1 נפתח:** `kOrgCompanyJson = String.fromEnvironment('ORG_CONFIG_JSON')` (מסווג **passthrough** בסריקת-הדגלים — ערך-פריסה, רדום-לחלוטין בלי ORG_CONFIG החמוש) → `hydrateOrgConfig({companyJson})` משחיל אותו לנתיב-ה-COMPANY של resolveOrgConfig; **מבנה-ההידרציה שוכתב לנפילה-דרך-נתיבים** (owner-קריא → company → default): blob-פגום כבר לא יוצא-מוקדם — הוא נופל לחברה (ההודעה שמרה את substring-הגארד 'corrupt cache (ignored'); owner-שמור מנצח **מסמך-שלם, לא-merge** (dive-החברה לא-מדמם פנימה). main מזין את הקבוע (ריק=null). **workflow:** clean-two-links קיבל שורת-מטריצה שלישית — ערוץ `plumbing` (clean + חמוש + JSON-אינסטלציה: dive+intel כבויים מהקופסה) — שני הערוצים הקיימים לא-נגועים; **שני מוקשי-shell נוטרלו:** brace-expansion על JSON-לא-מצוטט + פיצול-מילה על הרווח-העברי ⇒ ציטוט-יחיד מלא (אומת ב-yaml.safe_load). **לקח-גארד:** תבנית-conformance שמתחילה במקף נבלעת-כאופציה ע"י grep — נכתבה בלי המקפים המובילים. בדיקות: 3 רגלי-נתיבים ב-store (חברה-בלי-owner · owner-מנצח-מסמך-שלם · פגום-נופל-לחברה-בלי-מחיקה) · mutation ×2 (ניתוק-הנתיב → ‎+6 −2 · החזרת-היציאה-המוקדמת → ‎+7 −1 בדיוק) · גארדים ×8 · 34 ירוקות (כולל סיווג-הדגל בסריקה). **הוכחת-E2E בוצעה (אותו סשן):** שני builds מאותו קומיט (clean רגיל · clean+חמוש+JSON-אינסטלציה) נבנו-הוגשו-נצלמו בכרומיום אמיתי — הבסיס: "BuildSmart Clean"·טאב-"מחלקות"·סגמנט-שיחות; הערוץ: **"אינסטלציה דמו"·טאב-"צנרת"·סרגל-הסגמנטים נעלם** (chat-off מהנתיב-האפוי) — 4 צילומים נמסרו לבעלים. ה-JSON-בערוץ הועשר במזהים-נראים (home.topbar.brand·nav.catalog·chat:false) — dive/intel לבדם עיוורים-על-clean (רצפת-קומפילציה). **לקחי-סנדבוקס:** bootstrap מושך canvaskit מ-CDN ⇒ הטלאי האמיתי = `"useLocalCanvasKit":true` ב-buildConfig (רג׳קס-URL החטיא); ה-main מת לפני runApp על 7 import-דינמיים של firebasejs ⇒ keeper קיבל route-interception שממלא CDN מקאש-curl (TLS נשמר); הפרוקסי-לדפדפן הפכפך — קאש-דיסק דטרמיניסטי עדיף; pkill תואם-עצמית גם דרך נתיב-מלא/פקודת-אח באותה שורה — pkill לבדו בשורה. הזנת-שרת אמיתית לנתיב — פאזת-שרת.

## #giant-v5 — V5: אשף-ההקמה (ורטיקל→מודולים→מונחים→שמור) — 2026-07-26
**מסך חדש** `org_setup_wizard_screen.dart` (447ש׳, Text-רגיל בלבד — gate_118 נקי) + **עגינה** בטאב-ניהול של לוח-המנהל כסקשן-אחרון `if (kOrgConfigFlag)` (נעלם-בקומפילציה בברירת-מחדל ⇒ פיני-לוח-המנהל לא-נגועים; idiom-tradeBuilder המדויק: titleCfgId·emoji·title·sub·onTap-push). **מנגנון-הטיוטה:** `_draft` נזרע-ב-read (הכותב-לא-צופה — מתועד); `_rebuild` פרטי (אין copyWith ב-OrgConfig הסגור); מפת-מודולים **קנונית-מינימלית** (דלוק=מפתח-נמחק, לעולם-לא-true); מונחים בלי-מחרוזת-ריקה. **חבילות:** 6 ChoiceChips → applyVerticalPack על-הטיוטה + סנכרון-controllers. **נעילה-עצמית:** kWizardLockedModules={'manager'} (רישום-חדש `org_modules.dart`: 13 כרטיסי-תצוגה, סט-סגור=גל-1 בדיוק) — מתג-מושבת + תת-כותרת. **שמירה-מולחמת:** provider-חי קודם → persistOrgConfig → פתק-כן ('✅ נשמר ופעיל' / '⚠️ פעיל עכשיו — השמירה נכשלה'); **פתק-חימוש** כשלא-חמוש ('מצב לא-חמוש: … ORG_CONFIG=true'). **ייבוא/ייצוא JSON** דרך file_transfer (picked.content; אטומי — קובץ-פסול=טיוטה-לא-נגועה; IO=no-op-כן). בדיקות 8 · mutation ×2 (persist-מדולג → ‎+7 −1 · מנעול-מוסר → ‎+6 −2) · גארדים ×10 · 52 ירוקות (כולל לוח-מנהל+gate_118). **נדחה-במוצהר:** per-orgId slots (שרת) · זיהוי-super-admin-נוסף (הכניסה-למנהל כבר Google-מגודרת-מייל) · E2E-דפדפן חמוש (פרוסת-V6).

## #giant-v4 — V4: חבילות-ורטיקל (מנגנון + 6 נקודות-פתיחה) — 2026-07-26
**קובץ-טהור חדש** `lib/config/vertical_packs.dart` (אפס Flutter/Riverpod — משמעת org_config): `VerticalPack{id·emoji·label·terms·modules}` const-כולו · `kVerticalPacks` — **רשימת-הדוגמה של התוכנית כלשונה** (ספק-חומרי-בניין=ברירת-מחדל-זהות · אינסטלציה · חשמל · כלים · קרמיקה · קבלן-כללי; הסדר=סדר-האשף) · `verticalPackById` טוטאלי (null=לא-נמצא) · `applyVerticalPack` — **החלפה-מלאה** של terms+modules (V4.3: לא-merge — דטרמיניסטי, אפס-שאריות; הפעלה-כפולה≡אחת) עם שימור slug·orgName·theme·features. **תוכן=נקודות-פתיחה בלבד (V4.2 החלטת-בעלים):** כיבוי-מודול רק כעובדת-דומיין — compat (מנוע-הברגות-הצנרת) דלוק-לאינסטלציה/כבוי-לחשמל-כלים-קרמיקה; dive/intel כבויים-כפתיחה בורטיקלי-סחר-ממוקד; terms ריקים (מילון=כיוונון-באשף). בדיקות 7 (שלמות-רישום · closed-set מודולים+מונחים+core-לא-נגיע · יושר-דומיין · החלפה-מלאה+שימור · דטרמיניזם · הפיכוּת · lookup) · mutation ×2 (merge-במקום-replace → אדום-2 · השמטת-orgName → אדום-2) · גארדים ×7. **לקח חדש:** git-diff עיוור לקובץ-לא-נעקב — אימות-נוכחות-מוטציה בקובץ-חדש = grep ישיר על הקובץ. **צרכן:** האשף (V5) — אפס-חיווט-widget בגל-הזה.

## #giant-v3-w1 — V3 גל-1: מילון-המונחים (nav·brand·CfgText — סטודיו-מנצח) — 2026-07-26
**התפר:** תאומי-termOf ב-org_gates — `orgTerm` (watch-ב-build; live-swap) + `orgTermNow` (read; נתיבי-פתיחת-sheet בלבד — לא-מנוי, מתועד). **שכבת-CfgText:** `n.text ?? termOf(org,id,fallback)` — המונח **מתחת** לדריסת-סטודיו ומעל-ה-fallback; watch-לא-מותנה (מנוי-מהבהב-אסור); נתיב-חסר-scope נשאר-מילולי; editText נזרע-במונח (הבעלים-עורך-את-מה-שהוא-רואה, publish-מנצח). ⇒ **כל מזהה-CfgText = מפתח-מונח** בלי-נגיעה-ב-const (7 אתרי-המותג-הקפואים מכוסים-אוטומטית). **brand.*:** 11 המרות (name: כותרת-MaterialApp+שורת-הופק-פיננסים · club: פרסים×2+דוחות-עובד×3+שליח×2+פרופיל+drilldown-ב-Now) — AppBrand=ה-fallback-תמיד, לעולם-לא-מוטמע; const-יחיד-הוסר (_MdHead). **nav.*:** 4 תוויות-הטאבים (home/catalog/updates/store) — _kTabHelp נשאר-אינדקסי-קנוני (תפר-מוצהר). **רישום-מפתחות** מתועד ליד termOf (brand.name·brand.club·nav.×4·<CfgText-id>·RESERVED ל-V4: entity.×3+nav.customers). בדיקות org_terms-6 (DoD-זהות · nav · site-level · profile-club · **סטודיו-מנצח** · live-swap) · mutation ×2 כירורגי (−5/−1) · גארדים ×11 · 59 ירוקות. **נדחה-במוצהר:** אתרי-ייצוא/handlers (סל-שיתוף · שם-PDF · BOM · printable · quote/deeplink חסרי-ref ×7) · consts-עליונים (ערוצי-פוש-OS · onboarding · legal · זרעי-אינדקס/צ'אט · תווית/מילות-club-במקלדת-memo) · shareDomain · חיווט-entity.* (V4-packs).

## #giant-v2-w2 — V2 גל-2: המקלדת-כמכלול · פוש · בורדים — 2026-07-26
**מקלדת (בעלים-יחיד):** תיוג-מודול על-הרשומה (gate:'core' ברירת-מחדל, 21 תגים) — הרישום נשאר מלא+ref-less+ממומו (בדיקת-התוויות-הנדרשות = חוט-הביטחון); הסינון פר-קריאה: matchDestinations(cfg?) null=זהות · labelsByTab · דרייברים עם בוליאנים-טהורים שמסננים **לפני** השורש-הזורק (תקדים-זרוע-הגולמי) · tool-tree: cfg-ב-read (תקדים :645) · עלים-חסרי-ref: שומר-dispatch ('לא זמין') או דחייה-מתועדת. **search:** mount-האוברליי (const-ראשון) · אייקון-הסרגל · finder→נפילת-סעיף-ריק. **dive:** AND-שלישי אחרי const+flag. **פוש-צ'אט:** הזרוע-הכבויה של עדכונים צורכת+מטיסה 'שיחות אינן פעילות בחברה זו' (frame-deferred, אתר-צריכה-יחיד-כבוי). **בורדים:** ספק/עובד — הסתרת-תא+clamp (אפס-מספור-מחדש, מיפוי-ויזואלי-דו-כיווני בעובד); מנהל — intelOn מקונן ב-tabCount-הצרכני/stack/toggle/journey, ה-const לא-זז. מטריצה 8-רגליים · mutation ×2 · גארדים ×11 · 152 ירוקות.

## #giant-v2-w1 — V2 גל-1: המסכים מצייתים לקונפיג (9 משטחים + מטריצה) — 2026-07-26
**רישום-המפתחות אושרר-כברירת-מחדל** (core: catalog·orders תמיד · מודולים: chat·manager·supplier·courier·worker·finance·rewards·site·compat·ai·dive·search·intel · הכרעות: budget→finance · projects→site.projects · +ai · notifications-לא-כביה-בגל-1 ⇒ אף-טאב-תחתון-לא-נעלם). **תקן-חיווט אחד** (`org_gates.dart`): watch-ב-build בלבד; itemBuilder-נלכד; רצפת-הקומפילציה AND-ראשונה; memo-אסור (תקדים companyDeptDestinations). **9 משטחים:** בוחר (מיפוי persona→module, קבלן-מוגן-מבנית) · לוח (chat: כניסה+פריטים+dispatch-guard; ai: שורה+dispatch) · עדכונים (**clamp-בזמן-build** — כותבים-חיצוניים ל-subTab=1 קיימים) · חנות (finance-action · services-feature+**fallback-סעיף-תקוע**→all) · בית (site·site.stock·compat + rows-ריק⇒shrink) · פרופיל (rewards). **מטריצה** (`org_toggle_matrix_test`, 6): כל-מודול-לבד·נראות·הכל-כבוי·core-עוין·**live-swap**. **שתי מלכודות-בדיקה תועדו:** ProviderScope-לא-מחליף-overrides (UniqueKey-פר-boot) · ניווט=כתיבת-mainTabProvider. mutation ×2 (dead-true→-3 · watch→read→**רגל-האשף**) · 100 ירוקות · גארדים ×9. **גל-2 מוצהר:** המקלדת-כמכלול (בעלים-יחיד) · search · dive-AND · push-chat-degrade · טאבי-בורדים פנימיים.

## #giant-v1 — תוכנית-הענק Phase 1/V1: OrgConfig ריצתי (בעלים: PLAN-giant-system-master) — 2026-07-26
**הקפיצה:** שכבת-config בזמן-ריצה **מעל** הפרופיל-הקומפילציוני (לא במקומו). `lib/config/org_config.dart` (טהור): `OrgConfig{slug·orgName·theme·modules·features·terms}` · default-ריק=**הכל-דלוק** (חסר=דלוק ⇒ זהות-בייטים בלי-מניית-שמות) · codec-`{"v":1}` סובלני-פר-שדה · `resolveOrgConfig` טוטאלי (בעלים→חברה→default; שכבה-שבורה=מדולגת) · `moduleOn/featureOn` (רק-false מכבה · כיבוי-מודול משורשר · `kCoreModules={catalog,orders}` תמיד-דלוק · פיצ'ר-core כן-כביה) · `termOf` (fallback-בזהות — מתחת-ל-Studio: התוצאה נכנסת כ-fallback של CfgText, הדריסות ממשיכות-לנצח). `lib/state/org_config_store.dart`: שיבוט-משמעת-catalog-store (guard-first · getInstance-בתוך-try · corrupt-מתועד-לא-נמחק · persist-bool-quota) + `orgConfigProvider` (StateProvider — האשף-של-V5 יעדכן-חי). boot: הידרציה **לפני** hydrateCompanyCatalog + override. `ORG_CONFIG` סווג-במודע ל-**arming** (צורת-STUDIO/USER_SYSTEM; אטומי-באותו-commit עם הקבוע — אילוץ-סריקת-הסט). **התאמות-יושר מהמפה:** ערוץ-asset נדחה (pubspec-לא-נגוע; חריץ-`companyJson` שמור-לשרת) · orgId=מקור-שרת-עתידי · הסבת-38-אתרי-AppBrand=פרוסת-V3+ (רק-helper-קדימות הוקפא). בדיקות: pure(8, כולל **זרע-מטריצת-הטוגלים** של V2) + store(5) · mutation ×2 · גארדים ×6 · אפס-צרכנים=אפס-רגרסיה (תקדים trades_store:10).

## #completion-round — "למה לא הכל?": המנועים האחרונים נסגרים — 2026-07-26
**משלימים:** `companyComplementsFor` (טהור) + רצועת-🧩 בכרטיס (אותו mini-carousel; memo-פר-מוצר; שער `companyCatalogActive&&isNotEmpty`). **משחקים:** kDivePool/_pool overlay-first (זהות; else-בייט-זהה; lazy-final=hydrate-קודם). **סטודיו:** `_pickerCats()` — demo=const-זהה · raw+ייבוא=categoryHe-חי (סדר-הופעה, cap-7, ספירות-חיות) · raw-בלי=ריק-כן. **אינדקס:** מקטע-6 `_kContentProjectRows` (שער-זרעים; 383 איבר-זהה) + 3 שורות-שמות-כלים מגודרות-raw. **AI-hub:** `_rawHiddenToolIds={alt,plan,analytics}` בנקודת-הגזירה האחת (רשת+מקלדת+visibleToolIds יורשים); הנימוק: אין-שדה-מחיר-במודל — הצהרת-"3 חנויות שותפות" הייתה שקר-על-קונכייה; analytics מקפל אותם-מותגים-מומצאים. **מקלדת:** 4 עלים + 3 יעדים-מוקלדים מגודרים (memo-בטוח: קיפול-const לפני-cache; services-ריק=פני-אותיות, מאומת-שתי-רמות). **חנות:** svc-5 מגודר ב-`_kServiceItems` (נקודת-הרינדור האמיתית — תיקון-עוגן מול הממפה). **בדיקות:** `company_pools_overlay_test`(3, isolate-משלו ללטש-lazy) + הרחבות-רישום ×2. 151·14·3 · mutation ×2 · גארדים ×8. **מחוץ-מטבעו (הוצהר לבעלים):** קבצי-מסלולים/ערכות עתידיים · שרת (מחירים/מלאי/השוואה) · משפחת-kBudget (הדחוי-הגדול הבא) · typed-'שירותים' UC-gap.

## #raw-shell — הקונכייה הגולמית: אפס-כרום-BuildSmart על clean (בעלים: "זה לא גולמי") — 2026-07-26
**שער חדש** `kProfileRawShell = _clean` (+מראה; BuildMax=false — שומר את הוכחת-הקטלוג-שלו; פין-קוהרנטיות: גולמי⇒קטלוג-ריק). **9 בונים:** בית — רצועת-מחלקות/'גמר אמבטיה'-טיזר/שורת-'סרוק תוכנית' מוסתרים (השורה כי ה-sheet שלה = kPlanTypes מפוברק) · מקצוע — `1 => raw ? שקפים : Profession` (פרופסיה-ריקה בטוחה: mode-defaults) · סלוגן — טרנרי-const לנוסח-מנוע · **מחלקות** — ריק-כן ('אין מחלקות עדיין — יופיעו עם טעינת קטלוג החברה') → אחרי-ייבוא `companyDepartments` (dims['מחלקה'] סדר-הופעה; fallback-קטגוריות — הטאב-לעולם-לא-מת), כניסה-נגזרת ל-LipskeyProductsList (סינון-לפי-מצב-הגזירה), toggle-שטוח מוסתר-כן · **מקלדת** — 4 צ'יפי/יעדי-const מגודרים; `companyDeptDestinations()` (הגדרה-אחת לצ'יפ+הקלדה, מחוץ-לכל-memo — אפס-bake-in) · 4 ליטרלי-'BuildSmart' (כלים×2 · פיננסים×2) → `${AppBrand.name}` · **אינדקס-חיפוש** — פיצול-5-מקטעים שומר-סדר (383=366 מנוע+17 תוכן; demo איבר-זהה). **תפיסת-קריסה:** גוזר-מחלקות-המקלדת (root-שזורק-בכוונה) היה קורס על גולמי — זרוע-נגזרת (הקובץ הצטרף-במודע לרישום). באג-פרסור חי: `p.dims?['…']` בתוך `?:` = טרנרי-מקונן → סוגריים. **רישום חדש** `kRawShellGateConsumers` (9 קבצים) + מטריצת-F/F/T/F + עקביות-מראה. demo: widget/placeholder/onboarding/departments/keyboard×3 ללא-עדכון · clean 16 · company2 11 · mutation ×2 · גארדים ×10. **נדחה-במוצהר:** AI-hub-tools (kHomeProductBrands) · צ'יפי-סטודיו-להתקנה · 3 שמות-פרויקטי-דמו באינדקס (kProfileEmptySeeds-סבב-המשך) · derive-when-imported לאינדקס · kStores-בורדים · עזרה-'לבחירת המקצוע'.

## #connections-pour-in — סבב-ב׳: מוח-החיבורים נמזג מהקובץ (בעלים: "אני בניתי את המנועים... זה נטו מנוע") — 2026-07-26
**התגלית שהבעלים כפה (ואומתה במפה):** kVerifiedSpecs הוא `final` וכבר-נרשם-בריצה (תקדים polyroll_specs:138-144) — "שער-המזיגה" היה קיים; נותר לשכפל את המשמעת. **הגשר** `company_spec_bridge.dart` (חדש): dims['קצה 1/2/3']→ConnectorEnd לפי אוצר-המילים הקיים (תבריג±מגדר→bsp; פקס→pex; נחושת→copper; הדבקה/DN/מ"מ→push-fit-overload המתועד; פתח-ניקוז) עם **כלל-הצול הקריטי** — כל צורת-כתיבה ('1/2', ½, 0.5, '1 1/4') מקונ׳ ל-9 מפתחות-kBspInchToMm **עם `"` סופית** (directMatesWith=שוויון-מחרוזות); קצה-לא-פריק נשמט; אפס-קצוות⇒null (חוזה-polyroll). **שומר-פברוק:** חומר-ריק+קצה-לחיץ⇒אין-מפרט (אחרת ''=='' היה ממציא משפחת-חומר); טמפ׳-חסרה⇒ברירת-40 השמרנית (קו-חם-נדחה — מתועד בתבנית). **רישום:** putIfAbsent (static-wins) · kCompanySpecSkus רק-בהכנסה-בפועל · **בדיוק 2 call-sites** (hydrate טרום-runApp + commit-בגיליון) — פין-ה-890 שריר. **היקום:** chainUniverse ב-lipskey_hotwater (overlay⇒resolved, אחרת kCompatCatalog — אותו-אובייקט; blanket-swap היה מפיל את משפחת-HW מהדמו) → 6 נקודות-install_engine (אפס-בייטי-kCompatCatalog נותרו שם) + 5 סטודיו (מורכב-נכון עם תפר-s49b) + מפל-לחץ. **מגשרים:** isFitting += productType∈{מצמד,מחבר,מופה,ניפל,בושינג,רקורד,מתאם,ברך,זווית,מסעף,מעבר,אביזר} מגודר-overlay (שער-ה-BOM-המאומת :492 נשמר בכוונה). **כנות:** 'לפי נתוני היבוא' ב-3 מסכים (sheet-compat/engineering · copilot · adapter-explain) — נוסחי-'מאומת' בייט-זהים; adapterExplainPrompt קיבל sku-אופציונלי (ברירת-''=נוסח-ישן, קוראים-קיימים זהים). **בדיקות** `company_spec_bridge_test`(13): קנוניזציית-צול · שומרי-כנות · משמעת-רישום (עם ניקוי-tearDown — המפה גלובלית) · **שיא: זוג-מוצרי-אקסל מתחבר במסלול-המאומת + סיבת-כשל בעברית**. demo 69+13 · clean 13 · company2 13 · mutation ×2 (שתילה-מאומתת-בפייתון) · גארדים ×13. **נותר-בחוץ במוצהר:** צ'ק-ליסט-מים-חמים (HW-סקוסים) · dives-pool · תקן-כשדה (מוצג כשורת-מפרט בלבד).

## #template-v2 — כרטיס-מוצר 100% מקובץ אחד (בעלים: "אני רוצה 100 אחוז") — 2026-07-26
**הרקע:** הבעלים פתח כרטיס-מוצר אמיתי מול התבנית והראה את הפער (תמונות · טבלת-מפרט); דוח-הדרכון (per-engine, file:line) מיפה כל מנוע ותזונתו. **גל 6 בונים:** (F1) `_kCols`+4 עמודות-תמונה (| לרשימות, URL-או-שם AS-IS) · **עמודות-לא-מוכרות→dims** (סדר-קובץ, 'מידות' נשמר) · codec+4 מפתחות-תמונה · תבנית 15-עמודות עם legend חדש; (F2) `_isUrl`+passthrough בכל גטרי-התמונה (923 מוצרי-const ללא-שינוי בייט); (F3) resolver: URL-מוחלט→CachedNetworkImageProvider גם כש-base=''; (F4) שער-`page>0` + `_scanPool` (חיבורים-לפי-מידה :239/:288/:1144 + עמיתי-finder :2458 — שער-בטוח כי kLipskeyCatalog=תת-קבוצה, החלפה-ישירה הייתה משנה-demo); (F5) הצעות-חיפוש (:276) + `_wordHits` (נקודת-מפגש-אחת לשלושת מסלולי-לחיצת-מילה); (F6) alias-`dims['ברקוד']` ב-productBySku + באינדקס-הזהות (sku-גובר, אותם-אובייקטים — stage3 מחזיק). **בדיקות:** tier-g (עמודות-פתוחות · תמונות · roundtrip · passthrough · תבנית) + `barcode_alias_test` (קובץ-נפרד בכוונה — סדר-memo כמו-באפליקציה). demo 59+23 · clean 32 · company2 22 · mutation ×2 (עם שיעור-המוטציות-הכוזבות — ראה mutation_log) · גארדים ×10. **הצטרפו לרישום:** אין (הכול overlay-גייטד — אפס-churn בסריקות).

## #clean-100 — E2E-בדפדפן-אמיתי + שורות-נגזרות + כנות-מותג (בעלים: "תוצאה 100 לא 99") — 2026-07-25
**ה-E2E (חדש בסוג):** Chromium headless+Playwright על ה-build הנקי המקומי (canvaskit נותב-מקומית — סביבת-sandbox בלבד, artifact לא-בקוד): מסע-משתמש מלא צולם-ואומת-בעין — welcome→בחירת-תחום→קרוסלה→בית→sheet-הייבוא→**תבנית ירדה מלחיצה אמיתית** (BOM+כותרות אומתו-בבייטים)→**קובץ-שבור: 3 שגיאות-כנות מרונדרות** ('שורה 2 — חסר שם המוצר' · 'שורה 4 — מק"ט כפול: BB-2' · 'שורה 5 — חייב להיות מספר', סטטוס נשאר 'עדיין לא נטען'=אטומיות)→**קובץ-תקין: '✅ נטענו 3 מוצרים'**→**רענון: הידרציה חיה** (הכרטיס מציג 'נטענו 3 מוצרים' אחרי boot מלא). **3 תפיסות-עין→3 תיקונים:** (1) hero+terms של welcome היו 'BuildSmart' קשיח → `AppBrand.name` (CfgText-fallbacks, const-legal; demo זהה-בייטים); (2) שקופית-הפתיחה הבטיחה 'אלפי מוצרים' על קונכייה-ריקה → body מותנה-`kProfileEmptyCatalog` (הצטרפות-מודעת לרישום-הסריקה); (3) **שורות-הקטגוריות** היו טקסונומיית-אינסטלציה-const — עכשיו: `companyCatalogActive` (שער-פעילות-overlay ב-catalog_source — לא-פרופיל, כדי שהסוויטה define-less תוכיח) + `company_categories.dart` טהור (סדר-הופעה-ראשונה=הטקסונומיה-של-החברה · אימוג'י-מהמוצר-הראשון/'📦' · '$N מוצרים') + 4 נקודות-חיווט (שורות `_catsForSystem` — כולל ריק-כן-ללא-ייבוא · `categorySummaryProvider` · עלה-סינתטי `lipskeyCategory:כותרת` ב-onTap+openCatalogCategory — **הדריל הקיים משרת אותו ללא-שינוי**: isProductLeaf→auto-facets→רשימה). **בדיקות:** `company_categories_test` (טהור) + `company_catalog_rows_test` (widget, מעטפת-widget_test: BuildSmartApp+מחלקה+section) — demo-38 · clean-15 · company2-3 · mutation ×2 (נטרול-ענף→אדום-2 · השמטת-lipskeyCategory→'בקרוב'-חזר→אדום-1). גארדים ×8. **נדחה-במודע (ממופה):** עץ-מחלקות-const · רצועת-הצעות · dives-על-מיובא · '0 מוצרים · ליפסקי ברקן' בעלי-const (catalog_screen:2151).

## #company-catalog-import — משפך-הנתונים: תבנית⬇ + העלאה⬆ אל צינור-הקטלוג (בעלים "כן") — 2026-07-25
**החצי-השני של הקונכייה** (בעלים: "כפתור מוריד פירוט מה להכניס → מעלה קובץ → המערכת עובדת"): ב-clean בלבד. **Seam:** overlay רץ-זמן ב-`catalog_source.dart` — `setCompanyCatalog()` (נקודת-כתיבה-אחת) + הגטר בודק אותו **ראשון**; overlay כבוי (demo/buildsmart/לפני-ייבוא) ⇒ אותם אובייקטים **בזהות** (stage3 `identical()` מחזיק). הידרציה `hydrateCompanyCatalog()` ב-main **לפני runApp** — לפני כל ה-snapshots העצלים (`_skuIndex · _catalogByName · _kCatalogProductCats`); שער-ראשון `!kProfileEmptyCatalog → return` (הסוויטה define-less ⇒ no-op מוכח). **Domain טהור** `company_catalog_import.dart` (515 שורות, dart:convert+model בלבד): `companyCatalogTemplateCsv()` — **BOM-ראשון** (עברית-באקסל!), כותרות-עברית, שורות-`#` מתעדות-עצמן (חובה=מק"ט·שם·קטגוריה; "מחירים — בשלב חיבור-השרת"); `parseCompanyCatalogCsv` — RFC-4180-ish (מרכאות · פסיק/`;` אוטו · CRLF · מק"ט-לא-מצוטט שורד), שגיאות-עברית פר-שורה-פיזית ('שורה N — חסר…' · 'מק"ט כפול' · 'חייב להיות מספר' · 'חסרה עמודת חובה' · UTF-8 · תקרת-5,000), **שער-אטומי canCommit** (שגיאה-אחת=אפס-commit, חוזה-s48); **חוק-מותג-חברה:** תא-ריק ⇒ `brand:''` — לעולם-לא 'ליפסקי' שקט; codec v1 סובלני (מבני-שבור⇒null · פריט-שבור⇒skip). **Store** `company_catalog_store.dart`: `bs.company-catalog.v1`, corrupt⇒degrade-בשקט (חוק-ברזל-1), persist-quota⇒false-כן. **פלטפורמה** `services/file_transfer*` (טריו-מותנה כ-photo_downscale, אפס-deps — package:web קיים): הורדה Blob+anchor · בחירה input+FileReader · reload; seams-מוזרקים (share_seam) לבדיקות-widget. **UI** clean-בלבד: sheet ('📦 טעינת קטלוג החברה', שקוף-כן: "מחירים והשוואת-חנויות — בשלב חיבור-השרת"; רשימת-שגיאות in-sheet; '🔄 רענן להחלת…') + כרטיס בראש-הקטלוג + כפתור ב-empty-state-הספקים. **גבולות-v1 כנים (הוכרעו):** בלי-עמודת-מחיר (אין-לה-מסך ב-Phase-A) · חיפוש-תחילה (עץ-הקטגוריות הקבוע — פרוסת-המשך) · dives נשארים-ריקים · רענון-נדרש אחרי-ייבוא (6 snapshot-sites ממופים; invalidation=המשך). **בדיקה** `company_catalog_import_test`(17): תבנית·parser·codec·seam-identity·store-דו-עולמי (demo=no-op-מוכח; clean-מפרופל=**הייבוא-חי-מוכח**)·seams. **הוכחות:** analyze 0-errors · 17+20 define-less · **clean-מפרופל 26 · company2 17** · mutation ×2 (היפוך-תנאי-overlay→אדום-2 · נטרול-dup-sku→אדום-1, שחזור-sed) · רישום-סריקה +2-במודע · build-clean ✓ · גארדים ×10. **Phase-B=חיבור:** מחליפים loader (catalog_sync) — לא sink.

## #clean-empty-shell — הקונכייה-הריקה: קטלוג+זרעים ריקים ב-clean (הנחיית-בעלים) — 2026-07-25
**ההנחיה (בעלים, מתקנת את גבול-Clean-v1):** "לא — הקטלוג גם צריך להיות נקי" — clean = מנוע מלא עם **אפס תוכן BuildSmart**; company2/BuildMax שומר קטלוג (הוכחת-קטלוג-משלו) אבל **אפס רשומות**; demo/buildsmart זהי-בייטים (הסוויטה define-less = demo). **שני שערים נגזרים** ב-`app_profile.dart` (לא dart-define — אפס-churn בסריקת-הדגלים): `kProfileEmptyCatalog=_clean` · `kProfileEmptySeeds=_clean||_c2` + מראות-טהורות. **קטלוג:** נקודה-אחת — `resolvedCatalogProducts` (ענף-clean **ראשון**, CATALOG_SOURCE=v2 לא-דולף) + 4 מאגרי-fixture (`kDivePool` · plain-dive `_pool`-alias בתוך-הסנקציה · `kCompatCatalog` · `kSmartProducts`) + 2 הסתרות-כניסת-מותג (suppliers · keyboard_tool_tree) + empty-state כן חדש ('🏪 אין ספקים עדיין') + הסתרת שורת-עץ-חכם (היה פס-ריק-192px) + dsync-QA מודע-פרופיל. אפס-מיגון-חדש בקוד-החי — כל ~40 אתרי-הצריכה כבר מוגנים (מיפוי-מאמת מלא; חוק-ברזל-1 החזיק). **רשומות (10 משפחות):** `kManagerOrderSeed` (מרוקן בירושה את kOrdersEngineSeed+repos+sys_orders+לקוחות — backend-טרי של חברה לעולם לא יקבל את 4 הזמנות-הדמו) · `kPersonaTasks` · תגמולים-3 (coins→0; kVipTiers לא-נגוע) · phaseb-9 (כולל kStockDemo-Map; **kPaymentTerms דולג — options-לא-records**) · `kProjects` (sentinel-כן קיים) · `kChatThreads` · notifications+finance-3 (הרחבת שערי-`useFirebaseBackend` הקיימים) · store-`_kProjects` ('ללא פרויקט' הפונקציונלי שורד). **אל-תיגע (config, נעול-בבדיקה):** kVipTiers/kStores/kWorkers/kPaymentTerms — `.first`/בוחרים חיים. **תפיסת-NaN חיה:** `totPct` ב-_openSubs = 0/0 על-ריק → משמר `totAlloc > 0` (זהות-דמו מוכחת: 41000>0). **בדיקה חדשה `stage_clean_empty_test`** (17): מטריצת-4-פרופילים · קוהרנטיות-קונכייה (אין-קטלוג⇒אין-רשומות) · **live-pins דו-עולמיים** (demo=נועל-לא-ריק-היום; מפרופל=הוכחת-הריק) · סריקות-סט-סגור-צרכנים ×2. **הוכחות:** analyze 0 · 133 ממוקדות · **clean מפרופל: 20+דילוג-מכוון · company2: 9** · mutation ×2 · build-clean ✓ · גארדים ×19. הצעד-הבא (בעלים): re-run ל-`clean-two-links` → לינק-Clean ריק-באמת; ואז פרוסת-הייבוא (תבנית⬇+העלאה⬆ אל תוך ה-seam).

## #clean-finish — פיננסים-4 כן-מלא + שני-לינקים-קוד-אחד (DIRECTIVE-clean-finish) — 2026-07-25
**משימה-1 (פיננסים-4):** 4 הערות-השרת (מדד :482 · משנה :660 · ROI :1085 · חשבונית :1144) הפכו **מותנות-מצב**: דמו→'⚙️ בפרודקשן: נתוני X מהשרת — כאן נתוני דמו' (מצהיר-דמו, בלי הליטרל-האסור) · שרת→הנוסח-הקיים (סעיף-ריק-כן). 4 labelHe ברישום=גרסת-הדמו. תיקון-הכנות שהחליש-F7. **משימה-2 (שלב-5):** פרופיל-`company2` ב-`app_profile.dart` (_ux משותף · ערכי-חברה ריקים · עמודת-מראה+בדיקה) · `AppBrand.name` מודע-פרופיל (demo='BuildSmart' זהה-בייטים · clean='BuildSmart Clean' · company2=**'BuildMax'**) · wordmark ב-home_shell מנותב `AppBrand.name` (ברירת-מחדל זהה; Studio גובר) · **workflow חדש `clean-two-links.yml`** (workflow_dispatch בלבד — האתר-החי לא-נגוע): matrix של clean + company2(+CATALOG_SOURCE=v2, +789 מוצרים גלויים) → 2 ערוצי-preview נפרדים, לינק בכל Run-Summary. **ההבדל-הגלוי** (הפואנטה): שם-מותג + גודל-קטלוג. mutation ×2 (clause-הדמו · עמודת-c2 במראה) + 2 תיקוני-גארד חיים (workflow-matrix-literal · 3.2-name-guard→זרוע-ברירת-מחדל). מסירה: LAUNCH §שלב-5 — Run workflow → לתעד 2 לינקים.

## #stage4-clean-build — פרופיל-Clean: הוכחת-בנייה + סקריפט + מסירת-לינק — 2026-07-25
שלב-4 (החלק-המקודד). **הוכחה:** `flutter build web --release --dart-define=APP_PROFILE=clean` → ✓ ירוק (main.dart.js 9.3MB) — עמודת-ה-clean של `APP_PROFILE` (יכולות-ON · אפס-שרת/CDN-חברה · mirror-כבוי) היא אפליקציה בונה-אמיתית. **חדש:** `scripts/build_clean.sh` (פקודה-אחת, מתועד-פנים) + סעיף-שלב-4 ב-`LAUNCH_READINESS` (פריסת-ערוץ-נפרד `firebase hosting:channel:deploy clean` — הלינק-החי = צעד-בעלים; האתר-הראשי לא-נגוע) + גבול-כנות: Clean-v1 נושא את קטלוג-האינסטלציה כגנרי (המנועים צריכים מוצרים; החלפה-מלאה = seam-3.1(c), פירוק = שלב-6). שלב-5 = חזרה עם שם+קטלוג-דמו → שני-לינקים-קוד-אחד.

## #stage3-org-scope — St4+St5: דגל-scope ארגוני + ענפי-sameOrg בחוקים (כבוי, additive) — 2026-07-25
פרוסת-3.3 שלבים 4-5. **St4:** דגל חדש `ORG_SCOPED_QUERIES` (backend.dart, בכוונה לא-ממוחזר מ-UID_SCOPED_QUERIES שכבר-במסירה); `_ordersScopeFor`/`_customersScopeFor` +ענף-org-מועדף (claim לא-ריק ולא-manager/admin → `where('orgId'==claim)`; אחרת ענפי-uid מילה-במילה; manager/admin = god-view נעול-בבדיקות); stock קיבל scope-seam ראשון (בניית-source מותנית, else=היום-מילה-במילה). OFF=const-false ⇒ אפס-watches, זהות-בייטים. **St5:** `../firestore.rules` — helper `sameOrg()` עם משמר-`!= ''` **נושא-עומס** (בלעדיו token-ריק תואם כל דוק-ישן-''); `|| sameOrg()` על 6 קריאות (orders · customers · financeApprovals/Penalties/PaymentTerms/Budget) — הרחבה-בלבד, אפס-צמצום; אוספי-St6 לא-נגעו (isSignedIn כמו-שהיה — הצמצום צמוד-סדר-פריסה!). mutation: הסרת-המשמר → isolation-test אדום. שלילות-האמולטור הקיימות נשמרות (tokens בלי-claim + דוקים בלי-orgId = sameOrg false). גארדים ×3 (כולל תיקון-תחביר: תבנית-פותחת-`!` = absent-check — נוסחה מחדש). **3.3 הושלם עד-כמה-שניתן-כאן:** St6 (צמצום stock/tasks/material) + emulator-positive-case + פריסה = מסירת-בעלים (LAUNCH_READINESS).

## #stage3-org-stamp — St3: חותמות-orgId על רשומות (בריאה-בלבד, רדום) — 2026-07-25
פרוסת-3.3 שלב-3. **הזמנות** (המלכודת תוכננה-החוצה): `Order.orgId` (default '', A4-precedent — נכתב רק-כשלא-ריק, seed זהה-בייטים); threading בריאה-בלבד `placeOrder(orgId:)` engine→repo→checkout (`currentOrgIdProvider ?? ''`); **copyWith משמר-ולא-פרמטר** — קידומי-שלב מעבירים את החותמת, diff נשאר {stage,claim} (rules hasOnly); toDoc קורא מהמודל-בלבד (אפס session-stamp). **לקוחות/מלאי:** ctor `orgId` מוזרק-בבנייה (C2-discipline), חותמת-מגודרת ב-toDoc (בטוח — אין מסלול-diff-קפוא; כתיבות-מנהל בלבד). ללא-claim ⇒ מסמכים זהי-בייטים ⇒ אפס-השפעה על הסוויטה. בדיקה חדשה `stage3_org_stamp_test` (7: omit-ריק · round-trip · legacy-tolerant · stamp-בבריאה · **שימור-בקידום** · ריק-בלי-claim) + mutation (copyWith-drops→אדום). גארדים ×3. **נותר:** St4 דגל+scope · St5 sameOrg · St6 (צמוד-פריסה) — ממתינים למסירת-פריסה מסודרת.

## #stage3-setorg — תשתית-ארגונים St1+St2: callable אדמיני + פלמברת-claim בלקוח (רדום) — 2026-07-24
פרוסת-3.3 שלבים 1-2 (מתוך 6; המפרט-המדורג במלואו ב-scratchpad/_stage3_plan). **St1 (functions):** חדש `functions/src/setOrg.ts` — callable אדמיני-בלבד שמקצה/שולל `orgId`: מיזוג-claims שנוגע רק-ב-orgId (בכוונה לא-בתוך setRole — הוא מוחק את משטח-ה-claims שלו בכל קריאה; חברות-ארגון חייבת לשרוד re-role), מראת `users/{uid}.orgId` דרך Admin-SDK (עוקף את ה-freeze — נתיב-הכתיבה היחיד), ולידציית-charset, audit על הצלחה/דחייה (idioms: setRole:45-77 · reviewRoleRequest:136-153). re-export ב-index.ts. **tsc --noEmit strict: 0.** **St2 (client):** `auth_state.dart` — `orgIdFromClaims` (טהור, mirror rolesFromClaims/_nonEmptyString) · `AuthSnapshot.orgId` (nullable, default-null, 6 אתרי-בנייה לא-נגעו) · חילוץ בשני אתרי-ה-claims (`_onAuthEvent` + `reloadRole` — קוהרנטיות-רענון) · `currentOrgIdProvider` (mirror currentUid). **רדום לחלוטין:** אין claim עד שאדמין מריץ setOrg; אין צרכן-שאילתות עד ORG_SCOPED_QUERIES (St4). בדיקות: `org_claim_test` (8) + mutation (always-null→אדום). גארדים ×4 כולל `../functions/`. מסירה: שורת-פריסת-setOrg נוספה ל-LAUNCH_READINESS. **נותר ב-3.3:** St3 חותמות-דוקים · St4 דגל+scope · St5 חוקים sameOrg · St6 (צמוד-פריסה).

## #stage3-catalog-reroute — כל צרכני-הקטלוג הישירים → המקור-הפעיל + סריקת-סט-סגור — 2026-07-24
המשך-3.1 (אחרי ה-un-pin): **~35 אתרי-קוד ב-9 קבצים** הוחלפו `kCatalogProducts` → `resolvedCatalogProducts` (זהה-בייטים תחת v1): `catalog_screen` (13 — פתיחת-שורת-עגלה/dive-search/קיפולי-עץ) · `lipskey_product_sheet` (6) + `lipskey_products_screen` (7) — **בלי לגעת ב-`kLipskeyCatalog`** (סאבסט-מותג, פריט-זהיר נפרד) · `floating_card_keyboard` · `store_dashboard` · `ai_finder` · `assistant_intent` · `task_skus_local` (**נתיב-הברקוד**) · `variant_families`. imports יתומים נמחקו. **משמר חדש בבדיקת-העקביות (required):** סריקת-סט-סגור — קריאת-`kCatalogProducts` בקוד (לא-הערות) מותרת רק ל-18 קבצי-תשתית/מנוע מתועדים (הגדרות · שכבת-fallback · fixtures · brand-screen · harness); כל קורא-חדש מאדים. mutation: re-pin ב-ai_finder → הסריקה אדומה → שחזור ירוק. 49 בדיקות-צרכנים ירוקות.


## #stage3-app-brand — זהות-חברה במקור-אחד AppBrand (מיתוג→config) — 2026-07-24
פרוסת-3.2. **חדש:** `lib/config/app_brand.dart` — `AppBrand.name`/`club`/`shareDomain` (static const → אינטרפולציה-קבועה שומרת כל אתר const). **30 אתרים ב-19 קבצים** נותבו (כותרת-MaterialApp · onboarding · מועדון ×7 → `AppBrand.club` · שיתופים/ייצוא ×5 · PDF+שם-קובץ+footers ×5 · מסבירי-דוחות ×6 · ערוץ-push · שם-בוט · legal ×3 · דומיין-שיתוף). **זהות-בייטים מוכחת בזמן-ריצה** (41 אסרטי-מחרוזת קיימים עברו ללא-שינוי) + **מוטציה-התנהגותית**: name→'CleanCo' ⇒ keyboard_destinations אדום (-2) ⇒ שחזור ירוק — המיתוג באמת מחווט. **לא-נגעו (מכוון):** fallback-י CfgText (שכבת-Studio + registry-parity) · element_registry · LLM prompts · pubspec/applicationId/firebase_options/מעטפות. **חדש:** `knowledge/BRAND_SWAP_CHECKLIST.md` — מה מחליפים ידנית פר-חברה (מעטפות web/android/iOS · Firebase · פרופיל · store-listing) ומה כבר-בקוד. phase-2 מתועד: 79 ליטרלי-אלפא-hex ב-21 קבצים (tokens-לפי-מותג). גארדים: name-const · title-ניתוב · shareDomain.

## #stage3-app-profile — דגל-פרופיל אחד APP_PROFILE (demo · buildsmart · clean) — 2026-07-24
פרוסת-3.4 (מלאי-מלא: 34 דגלי-fromEnvironment + 2 קשיחים; **חבילת-ה-Play בונה היום בלי-דגלים = דמו**). **חדש:** `lib/state/app_profile.dart` — `kAppProfile` (`APP_PROFILE`, ברירת-מחדל `'demo'`) + 13 `kProfile*` consts + `kAppProfileKnown` + מראה-טהורה `profileDefaultsFor` לבדיקות. **13 הצהרות ב-8 קבצים** קיבלו `defaultValue: kProfile…` (feature_flags ×4 · keyboard_overlay · bs_keyboard_host · global_search · ring_dive_flag ×2 · store_comparison_line · backend ×2 בלבד · product_images) — התחיליות נשמרו רציפות עבור סוויטות-ה-grep (gate_123 · floating_card_keyboard — substring אחד הותאם). **עדיפות 3-שכבות = סמנטיקת-הפלטפורמה:** define-מפורש תמיד-גובר → כל ה-workflows וה-arming-variable ללא-שינוי, no-op מוכח; בלי-פרופיל = demo = כל ברירות-המחדל של היום (הסוויטה רצה כך — זהות-בייטים). **שכבת-החימוש (14 דגלי backend/Studio) הוחרגה בכוונה** (runbook STUDIO_GA §3 + studio_gating_test); ניסויים/חוגות/סוד — passthrough. **בדיקה חדשה (required):** `app_profile_flags_test.dart` — 4 מנעולים: demo≡היום · מטריצת-3-הפרופילים · עקביות-מראה↔const · **סריקת-סט-סגור** (כל define חדש חייב סיווג-מודע; עברה 1:1 מול המציאות). mutation ×3: default→buildsmart אדום · עמודת-מראה אדום · strip-rewire אדום-בייט. גארדים: `defaultValue: 'demo'` + 2 ה-VALUE rewires. **לא-בפרוסה (מתועד):** אימוץ-workflows (owner-gated; הפניית android-package = שינוי-חנות אמיתי) · kHide lift · firebase_options/חברה-#2 (שלב-4).

## #stage3-catalog-unpin — גשר-המק"טים + החיפוש עוקבים אחרי מקור-הקטלוג הפעיל (באג-רדום v2) — 2026-07-24
פרוסה ראשונה של שלב-3 (הפרדת מנוע↔דאטה). מיפוי-3.1 גילה **באג-רדום**: `related_info.dart` (`_skuIndex` :76 · `_canonKeyCountIndex` :101 · `variantSiblingsOf` :480) ו-`fuzzy_search.dart` (ברירת-מחדל :27) היו נעולים ל-`kCatalogProducts` (v1) בעוד המסכים קוראים `resolvedCatalogProducts` (CATALOG_SOURCE-aware) — תחת v2, 789 מוצרי-Huliot הופיעו ברשימות אך **לא נפתרו במק"ט** (ברקוד worker_app:288 · פתיחת-שורת-עגלה catalog_screen:314 · BOM card_projects:84) ולא עלו בחיפוש. 4 החלפות-שורה → `resolvedCatalogProducts` (+היגיינת-imports, +תיקוני-אמת בתיעוד-הפנימי). **זהה-בייטים תחת v1** (ה-getter מחזיר את אותו אובייקט). **בדיקה חדשה (required):** `stage3_catalog_source_consistency_test.dart` — כל מוצר-ברשימה נפתר-בגשר + זהות-אובייקט (list↔bridge מקור-אחד) — עוברת היום והופכת load-bearing ביום ש-v2/קטלוג-מוחלף פעיל. mutation-verify: re-pin → גארד-absent אדום → שחזור → ירוק. גארדים: `resolvedCatalogProducts` present + `!kCatalogProducts` בשני הקבצים. memo-בטיחות: CATALOG_SOURCE הוא compile-define → המקור קבוע לחיי-התהליך. **נותר בשלב-3:** APP_PROFILE · AppBrand · ניתובי-הקטלוג-המכניים · setOrg.

## #stage2-slice-C — בידוד-דייר: חוקים + חותמת-בעלים + הוכחת-A-לא-רואה-B (חוק-ברזל 2) — 2026-07-24
מיפוי קבע: יחידת-הדייר היום = **משתמש** (contractorUid/storeUid/participantUids) — הרשת-הבוגרת קיימת (חוקים 894ש' deny-by-default + rules_test אמולטור); orgId רדום (users בלבד) → org-מלא = שלב-3.3. הפרוסה מוכיחה ומחזקת את הקיים: **C1** `../firestore.rules` — 2 בלוקים לאוספים שנחסמו-בשקט ע"י ה-catch-all: `material_requests` (mirror-tasks; נואנס מתועד: הבוחן-בפועל=לוח-קבלן שאין-לו role-claim → הגייט manager/admin נכון-פונקציונלית, forward-ready לענף-קבלן) · `financeBudget` (mirror-financeApprovals + ענף-ownerId עתידי). **C2** customers (תקדים orders-A3): `customers_firebase.dart` — ctor `ownerUid` (מוזרק מ-`currentUidProvider` בבנייה — אין write-call-site אפליקטיבי), `toDoc` חותם `ownerId` רק-כשאין-למודל (round-trip-בטוח; fromDoc סובלני-לישן); `customers_local.dart` — `_customersScopeFor` (mirror `_ordersScopeFor`: אין-uid/manager/admin=null · אחרת `where('ownerId'==uid)`), מגודר `kUidScopedQueries` (OFF=בייט-זהה); ענף-החוקים :297-302 + אינדקס-#4 כבר-חיים. **בדיקה חדשה (required):** `stage2_tenant_isolation_test.dart` — 3 רמות: קונפורמנס-קובץ-החוקים (freeze-list · contractorUid · participantUids · ownerId · catch-all · public-read-יחיד=studioConfigLive · 2 הבלוקים) · תאומים-טהורים (A-לא-מקבל-B claimed) · מטמון-סקופי (רק-דוקי-הסקופ; ריק-סקופי=ריק-אמיתי). mutation-verify ×2 (freeze-list · חותמת). המשמר-הסקייל תפס את customers_local (RED-חי שלישי) → חריגה-מתועדת. **מסירת-בעלים** ב-`LAUNCH_READINESS` (פריסה · אמולטור+A-reads-B · ⚠️ `UID_SCOPED_QUERIES=true` · App Check). גארדים: `../firestore.rules` (×3, נתיבי-שורש בשער!) + `_ownerUid` + `_customersScopeFor`. **שלב-2 הושלם: 4 חוקי-ברזל × 4 בדיקות-required; חוק-5 = השער עצמו.**

## #stage2-slice-B — קנה-מידה: גבולות-מאזינים + רשימות-עצלות (חוק-ברזל 4) — 2026-07-24
מיפוי-הסקייל קבע: הקטלוג-הארוז = non-issue (מכוון, guard-tested); הסיכונים האמיתיים = מאזינים-ללא-גבול + 2 רשימות-eager. **B1** `data/repositories/firestore_cached_repo.dart` — `FirestoreCollectionSource` קיבל פרמטר `bound:` אופציונלי (transformer על-גבי scope; **בכוונה נפרד מ-`scope`** — גבול-גודל אינו tenant-scope ואסור שישפיע על `isScoped`/first-empty; null=התנהגות-היום, zero-regression). **B2** 3 המאזינים שהאודיט נקב: `chatMessages` = `orderBy('ts',desc).limit(500)` (המאזין-הצומח-ללא-גבול היחיד; ts נכתב-תמיד → אף-דוק-לא-מוחרג; 500-האחרונות) · `material_requests`/`tasks` = `limit(500)` נקי (בלי orderBy — שום דוק לא מוחרג). **orders מוחרג-בכוונה** — מלכודת-ts (toDoc כותב ts רק כש-createdAt≠null; orderBy היה מעלים את ה-seeds) → pagination-אמיתי = יוזמה נפרדת (`knowledge/studio-plan/05-scale-data-backend.md`). **B3** 2 רשימות-הזמנות eager→`ListView.builder` (manager `_OrdersTab` :1065 · store `_homeTab` — התגלה ששני "האתרים" הם scrollable אחד; השורות הועברו ל-builder החיצוני כי nested-shrinkWrap אינו עצל; `_pipeline` פוצל `_shownOrders`+`_pipelineHead`, שורות byte-identical). **בדיקה חדשה (required):** `stage2_scale_test.dart` — folds@10k · engine@10k · fuzzy@50k≤limit · **משמר-גבולות**: כל `FirestoreCollectionSource(` חייב `bound:` או חריגה-מתועדת-עם-סיבה (תפס 6 קבצים לא-מתועדים בריצה הראשונה — הוכחת-RED חיה). mutation-verify: היפוך `descending` → אדום → שחזור → ירוק. **נותר בשלב-2:** פרוסה-C (בידוד-דייר).

## #stage2-slice-A — חוסן: סבילות-דאטה + רשת-ביטחון (חוקי-ברזל 1+3) — 2026-07-24
שלב-2 של `PLAN-buildsmart-clean-master` (SSOT: `DIRECTIVE-buildsmart-clean.md §2`). מיפוי-4-מאמתים קבע: הבסיס כבר עמיד ברובו (per-doc-skip · last-good · C5.5 · emoji-fallbacks — הכל מוכח-בבדיקות); נסגרו 4 החורים שנמצאו: **F1** `state/orders_engine.dart` — פענוח `bs.orders.v1` הפך פר-רשומה (idiom של `OfflineOrderQueue._decode`): רשומה-פגומה-אחת מדולגת והשאר שורדות (היה: כל ההזמנות המקומיות נמחקות ל-seed); all-corrupt לא-ריק → seed. **F2** `data/repositories/catalog_sync.dart` — 2 קריאות `_decode(cached)` עטופות: מטמון-פגום = cache-MISS (נופל ל-resync/bundled, מרפא-עצמו) במקום קריסה שהפרה את הבטחת-C5.5 של הקובץ עצמו. **G3** `data/product_images.dart` — `errorBuilder` ברירת-מחדל `_productImageErrorFallback` (shrink) — call-site עתידי בלי fallback לא יקבל שלד-תקוע (כל 14 הקיימים עם משלהם — אפס-שינוי-חזותי). **F3** `state/share_log.dart` — `getInstance` לתוך ה-try (תקדים #99) + `_persist` מגודר. **בדיקות חדשות (required-tests):** `stage2_data_tolerance_test.dart` (חוק-1: ריק/חסר/מעוות/ענק — orders prefs+mapper · finance mapper · board/rewards/cart · 5k/1MB) + `stage2_safety_net_test.dart` (חוק-3: מטמון-פגום→bundled/resync · image-default). **mutation-verify: 3/3 אדום→ירוק** (כולל חיזוק בדיקת-G3 שנתפסה-חלשה ע"י המוטציה). G4 (ErrorWidget.builder) דולג בכוונה — סותר את invariant-אפס-הרגרסיה המתועד של מסלול-הדמו. S21 (~40 קבצי getInstance) = defer מתועד. **נותר בשלב-2:** פרוסה-B (קנה-מידה) · פרוסה-C (בידוד-דייר).

## #fake-sweep-site-hub — תווית "(דמו)" ל-4 מקטעי-האתר הזרועים — 2026-07-20
`screens/site_hub_screen.dart`: +ווידג'ט מקומי `_SiteServerNote` (העתק idiom-ה-`_ServerNote` של תגמולים; radius ליטרלי — site_hub בלי `cfgRadius`; `Text` רגיל, **אין CfgText/רישום**) + 4 שורות-תווית מתחת לראש כל מקטע — `kSiteTree` :591 (מבנה) · `kSiteDeps` :944 (תלויות) · `kSitePhotoPairs` :1024 (צילומים) · `kArchivedProjects` :1227 (ארכיון). כל 4 = דמו-בלבד (אין מקור-אמת; מלכודת `archive→kProjects` נמנעה — active≠archived + מזויף). תווית-בלבד; ערכי ה-const (verbatim proto) לא-נגעו (`phaseb_seeds_test`/`site_hub_state_test` נועלים values/lengths). מנומק ב-`legal_texts.dart:42`. **1 קובץ · 0 שינויי-בדיקה/רישום/גידור.** `/swarm`. גארד: `site_hub_screen.dart:::class _SiteServerNote`.

## #fake-sweep-finance-approval — חיווט תור-אישורים לריפו (server-אמיתי) + ניקוי 4 הערות (F7) — 2026-07-20
`data/repositories/finance_repository.dart`: +3 חברי-ממשק `approvals()/decide()/approvalsListenable` (+import FinanceApproval — מחזור finance_repository↔finance_hub_state, Dart-legal, analyze נקי). `finance_local.dart`: Local → זרע-דמו `kApprovalQueue` / no-op / null. `finance_firebase.dart`: +`@override` ל-approvals/decide הקיימים + `approvalsListenable=>_approvals` (ChangeNotifier, כמו budgetListenable). `state/finance_hub_state.dart`: `ApprovalQueueNotifier([FinanceRepository?])` ctor-אופציונלי — זורע+מתעדכן מ-`financeRepo().approvals()` (שרת=אמיתי · no-arg=seed), `decide` נכתב-כפול לריפו, `dispose` מסיר listener (mirror BudgetNotifier); provider `=> ApprovalQueueNotifier(financeRepo())`. `screens/finance_hub_sheets.dart`: נמחק ה-dual-write הידני (:788, הנוטיפייר מחזיק אותו); F7 — 4 הערות בלי "כאן מוצגים נתוני דמו". `state/studio/element_registry.dart`: 4 labelHe עודכנו לתואם. **על הבניה-החיה: אישורי-רכש אמיתיים מהשרת, לא demo AP-201/202.** Slice B (4 ערכי ROI/משנה/מדד/חשבונית) — דולג, אין מקור-אמת (החלטת-בעלים; ה-FX-gate נשאר). test: `budget_server_empty_test._FakeFinanceRepo` +3 stubs. הנחיה-2. גארדים: `finance_repository.dart:::approvals()` + `finance_hub_state.dart:::_repo?.decide` + `finance_hub_sheets.dart:::!כאן מוצגים נתוני דמו`.

## #fake-sweep-courier-supplier — גידור צי/דירוגים/זמינות + שורות "יתחבר עם השרת" — 2026-07-20
`screens/courier_portal_tab.dart`: זמינות-דמו מגודרת בתוך השורה (סוג-רכב+מחיר נשארים תמיד) · `kFleet` מגודר `if(!kHideUnderConstruction) ...[]` (הטירים שומרים על הגיליון לא-ריק) · הערת-מפה :219 נוסחה בלי "בדמו". `screens/persona_portal.dart`: `kSupplierRatings`+`kFleet` מגודרים **יחד-עם-התווית** + `else` שורת "…חי יתחבר עם חיבור השרת" (במקום גיליון-ריק). אין מקור-חי (kFleet=supplier_data.dart:225 · kSupplierRatings:274 · availability const) → גידור, לא חיווט. ב-review אפל: לא-מזויף ולא-ריק. הנחיה-2 (שליח+ספק). 0 שינויי-בדיקה (t9_supplier_personas + apple_readiness_hide_pass ירוקים). persona_portal.dart:257-269 (zones/sla/bulk = config סטטי) — לא בהיקף. גארדים: `persona_portal.dart:::דירוגי ספקים חיים יתווספו` + `:::ניהול צי חי יתחבר`.

## #fake-sweep-rewards — תווית "(דמו)" ללוח-מובילים · תגים · קוד-הזמנה — 2026-07-20
`screens/rewards_hub_screen.dart`: 3 שורות `_ServerNote` (Text רגיל — אין CfgText/רישום) מתחת לראש כל אחד — לוח-המובילים :209 (הדירוג חי אך המתחרים const-דמו) · תגים ירוקים :247 (earned קבועים, אין tracker) · קוד-הזמנה :346 (`BUILD-7K29` משותף מוצג כ"שלך"). תווית-בלבד; ערכי ה-const לא-נגעו (`t3_ghi` נועל values/lengths). מנומק ב-`legal_texts.dart:42` (מסכי-דמו מסומנים בכוונה). הנחיה-2 (פרוסת-תגמולים). `site_hub_screen.dart` (48KB, seed לא-מסומן) — נדחה לפרויקט-נפרד. גארד: `rewards_hub_screen.dart:::דירוג חי מהשרת`.

## #fake-sweep-M2 — אשראי-לקוח: hash-מהשם → אמת-מהשרת / "לא רשומה" (1א) — 2026-07-20
`logic/manager_dashboard.dart:282`: `creditLimit: contractorCredit(o.who)` → `0` (הפונקציה contractorCredit :256-264 **נשמרה** — נעולה כ"ערך-אסור" ע"י credit_never_invented_test; רק הקריאה הוסרה). `data/repositories/customers_local.dart`: `creditLimit()`→`0`, `_localCredit` מחזיר ceiling 0/balance 0/pct 0 עם `used`/`orderCount` אמיתיים (מראָה FirebaseCustomersRepository, שכבר-כן). `screens/manager_dashboard_screen.dart` (B4-B7): כרטיס `liveLimit<=0?'אשראי: לא רשומה'`, גיליון tile `'—'`, שורת מסגרת `'לא רשומה'`, שורת יתרה `'—'`. המקור-החי = `customerCreditProvider`→`computeCredit` (server-canonical). דליפת-קו-פיילוט נסגרה ע"י A1 (מקור=managerCustomersProvider). הנחיה `DIRECTIVE-fake-data-sweep.md` (M2·M3·1א). **תוצאה:** תג/פילטר "⚠️ אשראי גבוה" רדומים בדמו (fired רק על תקרת-שרת אמיתית). **טסטים שוכתבו:** orders_credit_a13 (expect 0) · manager_credit_computecredit_consumer (לא רשומה) · manager_dashboard_screen (לא רשומה + פילטר עם override-מוזרק + הסרת ÷0). גארד: `manager_dashboard.dart:::!contractorCredit(o.who)`.

## #fake-sweep-H1 — הסרת פס-התקדמות מזויף 38% (גמר אמבטיה) — 2026-07-20
`screens/smart_home_screen.dart`: הוסר `const LinearProgressIndicator(value: 0.38)` + ה-`ClipRRect`/`SizedBox(height:10)` העוטפים, מכרטיס "מסלול עבודה חכם / גמר אמבטיה" — פס קבוע-מזויף (38% לכל משתמש) בלי provider-התקדמות ובלי עץ-4-שלבים לחבר אליו (מאמת-D: היעד לא-נבנה). החלטת-בעלים "2א"=להסיר; הכרטיס נשאר טיזר-כן (badge+כותרת+תת-כותרת). הנחיה `DIRECTIVE-fake-data-sweep.md` (H1). גארד: `smart_home_screen.dart:::!value: 0.38`.

## #fake-sweep-store — חנות: הסרת 5 הזמנות-דמו · הסתרת צ'יפ-הצעות · אריח-הזמנות חי (S1·S2·S3) — 2026-07-20
`screens/store_screen.dart`: (S1) `storeOrdersProvider` — נמחק const `_kContractorDemoOrders` (5 שורות BS-1234…); הפרוביידר מחזיר `engineOrders.where(createdAt!=null)` בלבד → קבלן-חדש רואה רשימה-ריקה כנה, מונה "ההזמנות הפתוחות" (`_SummaryRow`) = 0 אמיתי במקום ~3 מזויף. (S2) צ'יפ `📨 הצעות ספקים` (const `_kSupplierOffersCount`) מגודר `if(!kHideUnderConstruction)` — מוסתר בבניה-החיה. (S3) אריח `📦 ההזמנות שלי` (`_AllList` `.map`) נגזר חי: `badge`=מספר-פתוחות (`openOrdersCount`), `preview`=הזמנה-אחרונה/"אין הזמנות פעילות" (`ordersPreview`), במקום const `#1234`/badge-1. הנחיה `DIRECTIVE-fake-data-sweep.md` (S1·S2·S3). **טסטים שוכתבו להתנהגות-אמת:** `state_deep_test` (fresh⇒empty⇒0 open) · `store_notif_widget_test` (מציב הזמנה-אמיתית BS-1234) · `global_search_sources_test` (מציב הזמנה-אמיתית BS-7777, `UncontrolledProviderScope`, שימור-כיסוי מקור-חיפוש). **נותר בשלב-1:** M2 credit (החלטת-בעלים) · H1 progress (החלטת-בעלים) · F5 approval-rewire (defer-large).

## #fake-sweep-batch-1 — honest-display fixes (S4 · H3 · F1-F4) — 2026-07-20
`screens/suppliers_screen.dart`: אריח-ליפסקי קורא `$kLipskeyProductCount` (const חדש ב-`data/lipskey_catalog.dart` = `kLipskeyCatalog.length` ≈923) במקום ליטרל "66"; screens לא קוראים `kLipskeyCatalog` ישירות (gate 114/לקח #69). `screens/rewards_hub_screen.dart`: כפתור "📤 שתף את הקוד" onTap → `Clipboard.setData(kReferralCode)` (+ import `flutter/services.dart`) — האישור "הועתק" עכשיו אמת. `screens/finance_hub_sheets.dart`: 4 גיליונות (מדד/קבלני-משנה/ROI/פיצול-חשבונית) מגודרים `useFirebaseBackend ? ריק : דמו` בתבנית `_openFx` + 4 `CfgText` server-note ids ב-`state/studio/element_registry.dart`. הנחיה `DIRECTIVE-fake-data-sweep.md` (S4·H3·F1-F4). **נותר:** store S1+S3 · M2 credit (החלטת-בעלים) · H1 progress (החלטת-בעלים) · F5 approval-rewire (defer-large).

## #manager-dashboard-drill — אריחי-KPI + שורות-pipeline לחיצים (drill) — 2026-07-20
`screens/manager_dashboard_screen.dart`: `_MetricTile`/`_PipelineRow` +`onTap?` (InkWell). `_MetricGrid`/`_OrderPipeline`→`ConsumerWidget`, מחווטים `managerTabProvider`: 🚚→הזמנות(1) · 📦/🧰/✅/🏪→ניהול(3) · pipeline→הזמנות(1). פריט 2 בהנחיית `DIRECTIVE-manager-console-live.md`. **נותר:** סינון-לפי-שלב ב-drill (deferred — filter מקומי) · אימות טאבים מול Firestore חי (דורש deploy).

---

## #manager-dashboard-live-pill — חיווי-חי אמיתי (סטטוס-קישוריות) — 2026-07-20
`screens/manager_dashboard_screen.dart` `_LivePill` → `ConsumerWidget` הקורא `connectionStatusProvider`: 🟢חי / 🔴מנותק / אפור-דמו, לא "חי" קבוע. פריט 3 בהנחיית `DIRECTIVE-manager-console-live.md`. נותר: onTap-drill לאריחים · קו-פיילוט (CLAUDE_AI) · אימות טאבים 1/2/3 מול Firestore חי.

---

## #manager-dashboard-live-kpi — 4 מדדי-לוח → קריאות חיות (לא קבועים) — 2026-07-20
`state/orders_engine.dart` `managerAnalyticsProvider`: 📦/🧰/✅ מ-`catalogRepositoryProvider` (ספירה חיה, 1,867 · accessory=קטגוריות-'אביזר'), 🏪 מ-`stockRepositoryProvider` (seed 3/3 מקומי · **ריק-כן על backend חי**, לא "3/3" מזויף). 🚚 הזמנות כבר-חי. `ManagerAnalytics` לא-נגוע. **נותר מההנחיה `DIRECTIVE-manager-console-live.md`:** onTap-drill לאריחים · `_LivePill` לסטטוס-קישוריות אמיתי · קו-פיילוט (CLAUDE_AI) · אימות טאבים 1/2/3 מול Firestore חי.

---

## #ultra-silent-images — 70 תמונות למוצרי Ultra Silent החדשים — 2026-07-19
`data/huliot_catalog.dart`: 70 מרשומות ה-Huliot החדשות שהיו אמוג׳י קיבלו `imageFile` (משחק-שיבוץ שני `ultra-silent-game.html`: 46 בחירות → 70 מק"טים; כל קובץ מאומת R2=200). 714→784 עם תמונה; 5 נשארו אמוג׳י (2 משפחות "אין"). brand='Huliot' ⇒ `assets/huliot/products/{file}`. מאחורי `CATALOG_SOURCE=v2` כמו שאר ה-789 החדשים.

---

## #fitting-images — 24 שיבוצי-תמונה למוצרי-פיטינג שהיו ללא-תמונה — 2026-07-19
`data/fitting_image_overrides.dart` (`kFittingImageOverrides`, 24 sku→`huliot/products/{img}.jpeg`) מוזג ב-`polyroll_catalog._withOwnerImage` בעדיפות-אחרונה (`huliot ?? lipski ?? fitting` — פיקים קיימים גוברים). מתוך 14 תמונות-פיטינג שהבעלים שייך ל-61 SKU: **24 net-new חוברו** (ברך 90° · צינור שחור · מסעף-מצרה · ברך 45°), **37 שכבר-נשאו-תמונה נשמרו** (לא-נדרסו). brand נשמר, ספירה 1,867.

---

## #activate-images — 760 שדרוגי-תמונה שבחר-הבעלים עלו לחי (v1) — 2026-07-19
שיבוץ-התמונות עבר מ-v2-בלבד ל-**מקור-הקטלוג** (`data/polyroll_catalog.dart`): `kCatalogProducts` ממופה דרך `_withOwnerImage` (מחיל `kHuliotImageOverrides` 512 + `kLipskiImageOverrides` 248 כ-`imageAssetOverride`, brand + כל שדה נשמרים). כל צרכן שקורא `kCatalogProducts` **ישירות** (כרטיסים · חיפוש · dashboards · dive) רואה עכשיו את התמונות הטובות — לא רק מאחורי `CATALOG_SOURCE=v2`. `catalog_source.dart` פושט: `kCatalogProductsV2 = [...kCatalogProducts, ...kHuliotProducts]` (יורש את השדרוגים) — הדגל מדרג עכשיו רק את **789 המוצרים החדשים**. ספירה 1,867 ללא-שינוי; `huliot_catalog_test`/`brand_profile_parity_test` עודכנו (v1 נושא את ה-760).

---

## #lipski-images — 248 מוצרי ליפסקי/AQUATEC → תמונת-אתר אמיתית (v2) — 2026-07-19
`data/lipski_image_overrides.dart` (`kLipskiImageOverrides`, מוזג ב-`catalog_source._withOwnerImage`, v2 בלבד, כל תמונה מאומתת-R2; fallback ל-extra כש-att-404). 20 fuzzy + 6 ללא-תמונה דחויים.

---


## #huliot — קטלוג-חוליות אדיטיבי + שדרוג-תמונות-בעלים (מאחורי CATALOG_SOURCE, default v1) — 2026-07-19
789 מוצרי-חוליות חדשים (`data/huliot_catalog.dart`, deduped מול 1,867 הקיימים; אפס-כפילות) · staging `kCatalogProductsV2` + דגל `CATALOG_SOURCE` (default v1 ⇒ live byte-identical, v1 ל-rollback) · שדרוג-תמונות שבחר הבעלים: **512 קיימים** (Polyroll/SmartLock) דרך `imageAssetOverride` (`data/huliot_image_overrides.dart`, brand-נשמר) + **714 חדשים** לתמונת-מוצר אמיתית (במקום ה-#0 שלרוב באנר/לוגו) · smart_tree 474/474 מגובות (0 שבורות; ה"167" היה ארטיפקט-grep) · `test/huliot_catalog_test.dart` 8 ירוקות. seam: `catalog_local.dart` קורא `resolvedCatalogProducts`.

---


What every interactive button / setting is expected to do, and its status.
**This contract is enforced by `test/wiring_test.dart`** (the wired-behavior rows
marked ✅ have an executable regression check). Keep this file and that test in
sync — if you change a behavior, update both.

Status legend: ✅ wired (real effect) · 🚧 בבנייה (placeholder toast) ·
⛔ blocked (needs price/rating/geo data, a server, or telephony that don't exist).

> **2026-07-09 — Studio coverage round 5 (v6.93): +17 owner-editable elements.** Wired `store_screen`
> (9 static checkout/cart chrome under the fresh `shop.*` namespace — cart empty-states, delivery/notes/
> payment/tracking headers, order-summary title + confirm CTA; dynamic product/price text left alone),
> `worker_today_strip` (3) and `courier_reports_tab` (5). `kElementRegistry` 152 → **169**. analyze 0 ·
> `gate_118` green · full suite green. Studio coverage this session: 23 → ~163 editable across 15 screens.

> **2026-07-09 — Studio coverage round 4 (v6.92): +13 owner-editable elements.** Wired `welcome_screen`
> (5 non-auth: hero title/tagline + first-run signup heading/subtitle/divider — ALL login/Google/code text
> left as plain `Text`) and `home_shell` (8: the smart-tree status label + 7 top-bar menu items via the
> `cfgId:` helper — catalog AI-hub, chats archive, notif read-all/clear-all/settings, store cart/orders).
> `kElementRegistry` 139 → **152**. analyze 0 · `gate_118` green · full suite green.

> **2026-07-09 — Studio coverage round 3 (v6.91): +28 owner-editable elements.** Wired `CfgText` into 4 more
> screens — `worker_profile_screen` (9), `courier_forms_screen` (8), `courier_attendance_screen` (6),
> `courier_certs_screen` (5). All BYTE-IDENTICAL (identity path). `kElementRegistry` 111 → **139** (`gate_118`
> green). Note: `every:worker` (32) and `every:courier` (52) now exceed the `kStudioMaxBatch = 25` broadcast
> ceiling — a per-utterance broadcast over those whole scopes is safely refused (no test asserts they build;
> `every:manager` stays 17). analyze 0 · full suite green.

> **2026-07-09 — Studio coverage round 2 (v6.90): +66 owner-editable elements.** Wired the canonical
> `CfgText` consumer into 6 more screens — `worker_app_screen` (12), `worker_reports_tab` (11),
> `courier_dashboard` (11), `courier_settings` (13), `courier_profile` (9), `manager_dashboard` (10 of 19).
> All BYTE-IDENTICAL with an empty doc (identity path — `flag OFF ⇒ Text(fallback)` verbatim): three private
> helpers gained an optional content-id (`_Card.titleId`, `_SwitchRow`/`_RadioGroupRow.cfgId`,
> `_ManageSection.titleCfgId`) that renders through `CfgText(id, label)` when set and plain `Text` otherwise.
> `kElementRegistry` 45 → **111** descriptors (`test/studio/gate_118` green — every referenced id registered).
> **Deferred (9):** the manager `_ManageSection` section-title headers (`manager.manage.*.title`) are wired in
> code but NOT yet registered — registering them would push the `every:manager` broadcast to 26 > the
> `kStudioMaxBatch = 25` per-utterance safety ceiling (see `studio_edit_intent_test`). They render fallback
> verbatim (fail-closed on the unregistered id) and light up once the manager-broadcast-ceiling call is made.
> No behavior-row change → `wiring_test` untouched. analyze 0 · full suite green.

> **2026-06-17 — owner-login dead-end fix (Google on the first screen):** on the LIVE backend the
> `OnboardingGate` traps a signed-OUT user in `_OpeningFlow` until `auth.user != null`, but the owner's
> manager Google login was only reachable from INSIDE `HomeShell` (unreachable while signed-out) — a
> circular dead-end (register blocked = email-already-in-use; email-login blocked = a Google account has no
> password). FIX: `welcome_screen.dart` now shows a **"כניסה עם Google (בעלים)"** FilledButton directly on
> the contractor welcome (gated to `useFirebaseBackend`; `isOwnerEmail` enforced server-side in
> `_managerGoogleLogin`), and `_managerGoogleLogin` flips `welcomeSeen` so a signed-in owner routes to
> `HomeShell`, not back into the loop. Demo build byte-identical (button hidden without Firebase). v6.23 / 1.4.6.

> **2026-06-16 — server-connect fix wave (real-fleet: 5 auditors → 2 validators → supervisor):**
> closed 6 validated gaps that kept the *connected* build serving demo/local data. **A1 (load-bearing):**
> `ordersEngineProvider`/`chatEngineProvider` now RE-BIND their repo on a uid-driven rebuild (the
> `ref.listen` is GATED to `useFirebaseBackend`, so the local/test path stays ACYCLIC —
> `LocalOrdersRepository.all` reads the engine — and byte-identical) → live orders/chat sync no longer
> freezes on the demo seed after the first sign-in. **C1+FS-1:** the live `FirebaseCustomersRepository`
> now receives `orderFunctionsGateway`, so the deployed `computeCredit` callable is actually reached;
> its no-callable fallback returns the honest 0, not the fabricated name-hash. **I1:** `profession`/
> `address`/`businessId` now mirror to `users/{uid}` at sign-in AND on profile edit (merge-write,
> rules-safe — no new rule/callable). **S2:** a connected build shows an honest-EMPTY in-app
> notifications feed (not the hardcoded `_kNotifs` list + fake unread badge). **X4:** contractor stock
> `move()` routes through the attached `FirebaseStockRepository` (reaches Firestore + the worker
> employer-stock view). **S1:** `pushCacheToRemote` never auto-seeds a REAL backend — the manager
> fresh-prod pollution path — gated on `useFirebaseBackend` (dev opts in with
> `--dart-define=SEED_FRESH_BACKEND`). DEFER-LARGE feature-waves (tasks / material-requests / POD /
> order-sum / attendance) intentionally NOT in this wave.

> **2026-06-15 — button-by-button fleet pass (4 surface traces) + fixes:** dispatched 4 read-only
> agents tracing EVERY control + flow across login / registration / accounts / mechanism. Verdict:
> every control wired correctly + every flow correct end-to-end; client↔server callable contracts
> (setRole / deleteAccount / reviewRoleRequest) + the approval matrix verified **3-way consistent**
> (client `approvableRolesForClaims` = server `APPROVER_FOR` inverse = rules `canReview`); flag-OFF
> zero-regression confirmed. Fixed: (MED) the welcome email-create `users/{uid}` mirror wrote the
> EMAIL into the `phone` field — now a phone→`phone`, an email→`email` (validIsraeliMobile/validEmail),
> keeping the field `users_lookup.uidByPhone` queries clean. (cosmetic) profile delete doc-comment
> updated (`user.delete` → `deleteAccount` callable); the OTP-expiry pre-check toast unified with the
> server-mapped string. ACCEPTED (noted): the admin-only role-request inbox is UI-unreachable
> (`rolesFromClaims` doesn't surface the `admin` bool) — but every requestable role already has an
> operational reviewer (worker→contractor · courier→store · store/contractor→manager) and admin has
> `setRole`, so no request is unreviewable; surfacing admin to the inbox is a deferred enhancement.

> **2026-06-15 — fleet VERIFICATION-scan fixes (3rd pass, final):** the 3rd fleet pass (over the
> final code) was clean on security (0) + most of lifecycle/gating; it caught 1 HIGH + 3 MEDIUM,
> now closed: (HIGH) `_registerViaAuth` no longer gates on the not-yet-propagated `signedIn`
> snapshot after `createUserWithEmailPassword` — it advances unconditionally on a non-throwing
> create, and `_finishAfterAuth` falls back to the gateway's `currentUser.uid` so the users/{uid}
> mirror still lands (a freshly-registered email user was getting stuck on welcome). (MED) the
> consent sentence's 3rd fragment darkened to `mutedLight` (the prior fix missed it). (MED) welcome
> `_register`/`_existingLogin` gained a `_busy` latch + CTA-disable (no double-submit). (MED)
> auth_state `signInWithSmsCode` now PEEKS the web ConfirmationResult and removes it only on a
> successful confirm (a wrong-code retry on web stays valid). 60/60 affected tests green.

> **2026-06-15 — fleet RE-SCAN fixes:** the re-scan (4 lenses) came back clean on security +
> lifecycle (0 findings) and confirmed the prior fixes hold; it surfaced one new MEDIUM + a LOW
> consistency gap, now closed: (1) `submitRoleRequest` no longer swallows the pre-write delete —
> a re-request after a denial starts from a fresh CREATE (no `merge:true` onto stale reviewer
> fields), bailing to false if the delete fails. (2) welcome `_field` gained `onSubmitted` wired
> to `_register` (the keyboard "done" submits, matching login_sheet). (3) consent-sentence text
> darkened to `mutedLight` (AA contrast). Accepted-LOW (noted): legal-link Semantics (minor),
> ltr-field textAlign (matches the login idiom), profession single-option (owner/UX call).

> **2026-06-15 — fleet-review MEDIUM+LOW batch (login/registration):** swept the rest of the
> review. login_sheet + welcome `_field` gained `autofillHints` + `textInputAction` (OS autofill
> + keyboard next/go; login_sheet's single-field panes also wire `onSubmitted` to their action)
> and a selective `ltr` (Hebrew NAME stays RTL — fixing login_sheet's name field too; digits/
> email/code/password go LTR); welcome's contact field got `keyboardType: emailAddress`.
> login_sheet: email-shape pre-validation on sign-in/create/reset; `_confirmCode` now requires
> EXACTLY 6 digits; a `_popped` latch + `_justCreated` reset in the auth listener (no stale
> "account created" toast / double-pop). auth_state: a 120s backstop timeout on the OTP completer
> (no infinite hang if no callback fires). role_request: clear busy before the pop; chevron
> `ExcludeSemantics`. Deferred w/ rationale: emoji-in-titles (app-wide style; canvaskit tofu is
> web-only, launch is mobile) + the web `_webConfirmations` micro-leak (web OTP-map risk > benefit).
> 59/59 affected tests green.

> **2026-06-15 — fleet-review HIGH fixes (login/registration, 2):** (1) `submitRoleRequest`
> (role_requests.dart) now wraps its Firestore write in try/catch → returns false on a
> network/permission failure instead of throwing past the sheet (which left it stuck
> "loading" with no error toast) — a regression from #6 inc.2; `role_request_test` +1.
> (2) welcome_screen's registration `_field` gained an `ltr` param: phone/email/code/password
> render LTR (`textDirection`) while the Hebrew NAME field stays RTL — matching login_sheet's
> twin (the registration screen previously had broken RTL caret/ordering on those inputs).
> MEDIUM polish (keyboardType/autofillHints/textInputAction/emoji-a11y) batched separately.

> **2026-06-15 — auth #6 inc.3 (approval inbox) — #6 COMPLETE:** the profile screen shows
> "📋 בקשות תפקיד" when the caller's CLAIM roles approve a tier (`approvableRolesForClaims`:
> contractor↞worker, store↞courier, manager↞store+contractor, admin=all). The inbox streams
> `roleRequests` SCOPED to that tier (`pendingRoleRequestsProvider` — matches the rules'
> `canReview`, so it never issues a query the rule would deny) and approve/deny calls the
> `reviewRoleRequest` callable via the `RoleReviewer` seam (a typedef'd function — testable, no
> AuthGateway churn). A decision flips the doc out of the pending query, self-emptying the list.
> Full #6 = inc.1 (server matrix) + inc.2 (request) + inc.3 (inbox).

> **2026-06-15 — auth #6 inc.2 (role-request UI):** the profile screen (signed-in) gains a
> "🪪 בקשת תפקיד" row → a bottom sheet listing the four requestable operational roles (each
> stating WHO approves it per the matrix). Picking one writes `roleRequests/{uid}`
> (status:pending, displayName/phone from the local profile) via the `roleRequestWriterProvider`
> seam (null Firebase-free → submit is a safe no-op). The server `reviewRoleRequest` (inc.1)
> approves/denies; the approver inbox is inc.3. `role_request_test` +2.

> **2026-06-15 — auth P2 (displayName on create):** the email "צור חשבון" pane now has an
> optional "שם מלא" field; on success it `register`s the name into the local profile, which the
> welcome flow's post-auth step (`_finishAfterAuth`) already mirrors to `users/{uid}.displayName`
> (read by `computeCredit` + the push sender name). Client-only — no gateway/interface change,
> no fake churn. `login_sheet_test` +1.

> **2026-06-15 — auth P2 (OTP resend cooldown + expiry):** the phone code step now
> enforces a 30s resend cooldown — re-tapping "שליחת קוד חדש" inside the window toasts the
> remaining seconds instead of re-hitting the rate-limited/billable send — and pre-checks the
> ~2-min code validity before the round-trip (the server session-expired stays the backstop);
> the code subtitle states the validity window. Timestamp-driven (no Timer) so the OTP widget
> tests' pumpAndSettle keep settling. `login_sheet_test` +1 (cooldown blocks the second send).

> **2026-06-15 — auth P2 (login polish):** account-enumeration closed on the
> sign-in path — `hebrewAuthError` folds `user-not-found` into the SAME generic
> "אימייל או סיסמה שגויים" as a wrong password (was a distinct "לא נמצא חשבון",
> which let the form probe which emails are registered; the full server-side fix
> is the Firebase console "Email Enumeration Protection" toggle — owner). Plus a
> show/hide-password eye toggle on the email pane and a client-side ≥6-char
> pre-check on "צור חשבון" (instant feedback; the server weak-password error is
> still mapped as a backstop). `login_sheet_test` +2 (enumeration unit + length).

> **2026-06-15 — auth #4 (account-deletion server cleanup, gen2 callable):** the
> client `deleteAccount()` used Firebase Auth `user.delete()` which removes ONLY the
> Auth record — the user's `users/{uid}` profile (name/phone/email/fcmToken) +
> `diag/{uid}` probe were left orphaned in Firestore (GDPR right-to-erasure / Apple
> gap). Now `FirebaseAuthGateway.deleteAccount` calls the server `deleteAccount`
> CALLABLE (functions/deleteAccount.ts), which purges those uid-keyed personal docs
> AND deletes the Auth record via the Admin SDK (no recent-login needed), writes an
> `auditLog` entry, then the client signs out locally. **Callable, not an Auth
> onDelete trigger:** Auth has no gen2 deletion hook and a v1/gen1 trigger needs an
> App Engine instance this project lacks — it 403s and ABORTS `firebase deploy
> --only functions`, blocking the (live) gen2 functions too; a callable stays gen2.
> SCOPE: only uid-keyed (single-owner) docs; multi-party records
> (orders/chat/customers/projects/tasks) are RETAINED — anonymizing the uid out of
> shared docs is a heavier follow-up (functions/README TODO).

> **2026-06-15 — auth #3 (email-verification notice):** the "צור חשבון" success path
> now toasts that a verification email was sent ("✓ החשבון נוצר — שלחנו מייל אימות…")
> instead of the generic sign-in toast — `sendEmailVerification` is no longer
> silent. (Hard `emailVerified` enforcement deferred — a backend-ON-only product
> decision; the store ships demo.)

> **2026-06-15 — auth #1 (auth-gate on the real backend):** `OnboardingGate` now
> routes a signed-OUT user to the welcome/login flow when `useFirebaseBackend` is
> ON (otherwise their writes are silently rules-denied — the orders/chat-sync
> class of bug); sign-in rebuilds to HomeShell, logout re-gates (the gate watches
> `authStateProvider`). DEMO build (flag OFF) + the whole test suite byte-identical.

> **2026-06-15 — auth #2 (forgot-password):** the login sheet gains a "שכחתי סיסמה"
> link (sign-in mode only) → `AuthStateNotifier.resetPassword` →
> `FirebaseAuth.sendPasswordResetEmail`. A neutral success toast shows regardless
> of whether the email is registered (no account enumeration) — the recovery path
> email users previously had none of.

> **2026-06-15 — chat-sync (A14 last-mile, orders analog):** `ensureParticipantUids`
> now ALWAYS stamps the sender's own uid (the `contractorUid==auth.uid` guarantee)
> even with no users-directory; the `chatThreads` listen is scoped
> `where('participantUids', arrayContains: uid)` (gated by `kUidScopedQueries`, like
> orders); the index + the update rule (empty→self bootstrap) align on
> `participantUids`. Chats now sync 2-way like orders. Flag OFF = byte-identical.

> **2026-06-15 — launch B1+#6:** data-safety/privacy declarations updated to honestly list
> Firebase Crashlytics/Analytics collection (B1, `LAUNCH_PACKAGE/`). The manager dashboard's
> "🔬 בדיקות רגרסיה" section is now `if(kDebugMode)`-gated — **DEV-ONLY**, not reachable by an
> end user in a shipped release (#6); the panel + `test_harness` stay in code (reversible).

> **v6.13 → v6.16 wiring audits:** see `knowledge/WIRING_AUDIT.md` — six rounds (three fix passes + a deep
> correctness/perf/a11y pass with adversarial validation). v6.16 corrected the manager express-fee display,
> aligned contractor stage labels to the canonical map, made the manager customer/order detail sheets read
> live engine data, fixed load-clobber races + incomplete resets + double-checkout, moved hot catalog/manager
> paths to derived providers, and fixed targeted RTL/overflow/reducedMotion issues — deferring the app-wide
> Semantics + highContrast-token initiatives and keeping verbatim-legacy strings.
>
> **v6.13 + v6.14 + v6.15 wiring audits:** see `knowledge/WIRING_AUDIT.md` — three passes swept the
> FAB/dial shortcut layer, deeper flows, and the full screens for stubs / mis-wired toggles and fixed
> them. v6.15 unified the contractor's order history on `ordersEngineProvider` (one id, live stage,
> real items, persisted), made supplier out-of-stock + project names persist, gated notification
> quiet-hours, seeded profession→catalog-mode, applied store sort/display, and made the
> service-sheet rows + account-edit leaves honest/editable.
>
> **v6.20 — חיווט קבלן↔עובד (server-ready):** גל 0 — שדרת `employerId` ב-`BoardSession`
> (`board_auth.dart`, מקושר עובד→קבלן, DEMO-SEED מתויג) + `employerProfileProvider`
> (`employer_link.dart` — חדש) שפותר את פרטי הקבלן-המעסיק. טופס 101 (`worker_forms_screen.dart`)
> קורא את בלוק-המעסיק דרך הקישור (`session.employerId`) במקום `userProfileProvider` הישיר —
> סוגר את חור-היושר ב-#106. SERVER-SWAP: `contractors/{employerId}`.
> **גל T1:** 2 מנועי-המשימות → מנוע אחד (`tasksProvider` מקור-יחיד; `workerTasksProvider` = shim מעביר). `TaskItem` += `employerId`/`assignedWorkerUid` (נחתמים מה-session בשליחה). נמחקו dual-write/mirror; fold של orderId→advance-on-approve; seam ריק `bindRemote` (T3 ימלא).
> **גל T2:** מסך-קבלן (`tasks_screen`) — ＋'משימה חדשה' (`createTask`, חותם `employerId`+`assignedWorkerUid`) · עריכה (`editTask`) · הקצאה (`assignTask`) · 'אישורי עובדים (קבלן)' (`approve`/`reject` מקבילי, מנהל לא-נגוע). הקבלן יוצר/מקצה/מאשר → העובד רואה חי דרך המנוע-המאוחד.
> **גל E1 (מלאי):** העובד קורא מלאי-קבלן READ-ONLY — `employerStockProvider(session.employerId)` (`employer_stock.dart`) → גיליון '📦 מלאי הקבלן' + כפתור בלוח-העובד. העובד רואה, לא משנה. SERVER-SWAP: stock scoped ל-employerId.
> **גל E2:** צ'יפ-זמינות ב-#112 — `availabilityFor` (`equipment_stock_join.dart`, token-aware, אין-המצאות) מצליב כל פריט-ציוד מול `employerStockProvider` → 🏬 מחסן / 🏗️ אתר / 'זמינות לא ידועה'. העובד רק רואה (read-only).
> **גל E3:** בקשת-חומר מובנית עובד→קבלן — `materialRequestsProvider` (`material_requests_engine.dart`): העובד שולח מ-'🧱 בקש חומרים' (גיליון-מלאי) ורואה סטטוס; הקבלן ב-'📥 בקשות חומר' (stock_screen) מקדם requested→ordered→supplied/declined. דו-כיווני-חי, ישות נפרדת מהמלאי (העובד לא משנה מלאי). firebase→Z.
> **גל H1 (HR):** אישור-חופשה עובד → **קבלן** (לא מנהל) — `requestsForEmployer` (`vacation_requests.dart`, employer-scoped) + מסך `contractor_hr_sheet` ('👷 חופשות עובדים' ב-tasks_screen): אשר/דחה → פעמון-עובד + צ'אט th-worker-contractor. מקבילי (מנהל נשאר). worker: 'לאישור הקבלן'.
> **גל H2 (HR):** תעודות + הדרכות עובד → **קבלן** — `certsForEmployer`/`trainingsForEmployer` (`worker_certs`/`worker_trainings`, employer-scoped). הדרכות: `approve`/`reject` אמיתי (pending→approved/rejected) + `contractor_hr_sheet` מורחב (🎓 אישור-הדרכות → פעמון+צ'אט · 📜 תעודות READ-ONLY + באנר-תוקף `statusAt`). `worker_safety` מטביע employerId. firebase→Z.
> **גל H3 (HR):** מדיניות מסמכים-נדרשים שהקבלן מגדיר → אוכפת בשער-מוכנות-העובד (#101) — `required_docs_policy.dart` (`requiredDocsForEmployer`, **normalized-exact** match) + `contractor_hr_sheet` עורך-מדיניות (📋). ADD-on (101+פג-תוקף נשארים חובה); מדיניות-ריקה=התנהגות-של-היום. שליחים לא-נגעו. firebase→Z.
> **גל S (אתר/נוכחות):** נוכחות-עובד → תצוגה-חיה אצל הקבלן — `attendanceForEmployer` (`worker_attendance.dart`, **חנות-עובד בלבד** → שליחים מודרים) + `contractor_attendance_sheet` ('🕒 נוכחות עובדים'): '🟢 נוכחים עכשיו' + 'היום' (שעות + מיקום-אמיתי דרך openNavSheet, אין-המצאה). read-only; העובד חותם כרגיל. firebase→Z.
> **גל G1 (משימות דו-כיווני):** העובד פותח משימה → `'proposed'` → הקבלן מאשר (`proposeTask`/`approveProposal`/`rejectProposal`, **מבודד** מ-review/completion). לוח-עובד: '➕ הוסף משימה' + מקטע 'ממתינות לאישור'; לוח-קבלן: מקטע-אישור-הצעות (`pendingProposalsProvider`) → פעמון+צ'אט th-worker-contractor. גאנט(G2)+ליקויים(G3) בהמשך. firebase→Z.
> **גל G2 (גאנט):** גאנט כתצוגה מעל `tasksProvider` (לא מערכת נפרדת) — `TaskItem.scheduledStart` + `buildTasksGantt` (`lib/logic/tasks_gantt.dart`, טהור) + `tasks_gantt_sheet` (read-only, נגיש מקבלן+עובד; **תאריכים אמיתיים**, 'ללא תאריך' בנפרד, אין-המצאה). הקבלן משבץ תאריך ב-author-sheet. ליקויים(G3) בהמשך. firebase→Z.
> **גל G3 (ליקויים):** ליקוי = `kind='defect'` של משימה (+location/severity) — מנצל את כל מנגנון הפתיחה/הצעה/אישור. הקבלן פותח (createTask→pending), העובד מדווח (proposeTask→proposed→אישור דרך זרם-G1). `defectsProvider` + `defects_sheet` (🔧, נגיש משני הלוחות). firebase→Z. **— חיווט קבלן↔עובד הושלם (T·E·H·S·G); נותר רק שרת (Z) + דחיפה.**
> **גל DEBUNDLE (פירוק via הצי הקנוני /swarm) — 2026-06-14:** `tasks_screen` = לוח-קבלן ממוקד בלבד (הוסרו טוגל מנהל↔עובד · `_workerView` · `_RolePicker` · 4 כפתורי-כלים כפולים). אריחי `site_hub` גאנט/ליקויים/נוכחות → מנועים **חיים** (`showTasksGanttSheet`/`showDefectsSheet`/`showContractorAttendanceSheet`) במקום seeds מתים + אריח `👷 חופשות עובדים` + מחיקת `_SiteGantt`/`_SiteSnagging`/`_SiteAttendance`. אישורי-קבלן scoped ל-`kDemoContractorId`; 6 אתרי-קריסה `kWorkers[]` חסומים (`_wk`). worker board לא-נגוע מבנית (+tap-target/RTL). אומת: analyze 0 · +2509 · build web · mutation RED→GREEN · supervisor 15/15.

---

## Opening flow — first run (`onboarding_screen.dart` · `welcome_screen.dart` · `profession_screen.dart` · `role_picker_sheet.dart`)

`OnboardingGate` (gated by `welcomeSeenProvider`, seeded in `main()` from prefs):
a genuine first run walks Welcome → Profession → onboarding slides → home; afterwards
home directly. Guarded by `onboarding_test`.

| Button | Behavior | Status |
|---|---|---|
| WelcomeScreen · אישור והמשך (רישום) | `register(name, contact)` → `userProfileProvider` (persisted) → profession step | ✅ |
| WelcomeScreen · כניסה ללקוח קיים | enters straight to home (skips the trade step; no auth backend) | ✅ |
| WelcomeScreen · המשך ללא רישום (דוגמה) | `continueAsDemo` → profession step | ✅ |
| ProfessionScreen · בחירת מקצוע / חזור | `setProfession` → slides · back → welcome | ✅ |
| OnboardingScreen · דלג / הבא / בואו נתחיל | finishes (`welcomeSeenProvider=true`, persisted) → home | ✅ |

## Home app-bar (`home_shell.dart` · `_HomeAppBar`)

| Button | Behavior | Status |
|---|---|---|
| logo "BuildSmart" | opens the "מי אתה?" persona picker (`showRolePicker`); contractor stays in the main app; **עובד / מנהל / חנות / שליח each open their full role-app** (`WorkerAppScreen` / `ManagerDashboardScreen` / `StoreDashboardScreen` / `CourierDashboardScreen`) | ✅ |
| role-app **עובד** (`WorkerAppScreen`) — T9 | same shell as the main app (white AppBar `🦺 עובד · ‹ יציאה` + card list, `BsTokens`); only the content differs. Faithful port of `renderWorker()` (proto 06 §4.2): worker picker (`kWorkers`) · summary (`שלום {name} 👷` + `{done}/{total}` + progress + פעילה/בתור/הוגשו) · 3 buckets (🔨 המשימה הנוכחית שלך = active\|rejected · ⏳ הבאות בתור = pending · 📋 שהגשת = review\|done) as task cards. **W3 — now LIVE:** `ConsumerStatefulWidget` reading the shared `workerTasksProvider` (not the static const); a current-bucket card carries a keyed "📸 שלח לאישור" button → `submitForReview` (active\|rejected → `review`), surfacing the task in the manager's approvals view. Data: `persona_data.dart` (5 verbatim tasks, R8). | ✅ |
| role-app **מנהל המערכת** (`ManagerDashboardScreen`) — unify | full LIGHT role-app, 4-tab toggle (📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול) reading the shared `ordersEngineProvider` live data (`managerAnalyticsProvider` / `managerCustomersProvider`). Replaces the old dial-manager panel for the manager persona. | ✅ |
| role-app **🏪 חנות ספק** (`StoreDashboardScreen`) — T9 | full role-app, 4 segmented tabs (בית/הזמנות/מלאי/פורטל), same shell as the main app. Faithful port of `screen-store` (proto 06 §2): action-first home (`שלום 👋` · primary `הזמנות ממתינות לאישור` · stats בהכנה/מוכן לאיסוף/מחזור פעיל · stock alert · demo `סימולציית הזמנה נכנסת`) · orders queue with the real **`new→preparing→ready`** advance (`✓ אשר וקבל להכנה` / `📦 סמן כמוכן — העבר לשליח`) · stock availability toggles (`✅ זמין במלאי` / `❌ אזל`) · 8-tile supplier portal. Orders are the shared `sysOrdersProvider`. Data verbatim `supplier_data.dart` (R8). Guarded by `t9_supplier_personas_test`. | ✅ |
| role-app **🛵 שליח** (`CourierDashboardScreen`) — T9 | full role-app: vehicle picker (`vehicleCanCarry`, משלוח קטן/טנדר/משאית) + delivery home (stats לאיסוף/בדרך/נמסרו) + job list (3-step tracker איסוף/בדרך/נמסר) + 6-tile portal. Faithful port of `screen-courier` (proto 06 §3): the real **`ready→pickup→transit→delivered`** advance (`📦 אספתי מהחנות` / `🚚 יצאתי לדרך` / `✅ נמסר ללקוח`). Shares `sysOrdersProvider` with the store — an order the store marks "מוכן" appears here live. Data verbatim (R8). Guarded by `t9_supplier_personas_test`. | ✅ |

> **T9 deferred** (proto "adds beyond"/heavier infra): per-store login routing, the picking sheet + missing-item hold loop, split-shipment jobs, POD capture, the printed delivery note, and localStorage persistence. The store/courier full screens + the shared 6-stage advance engine are done.
>
> **✅ unified (v6.12):** `sysOrdersProvider` is now a live view of the single `ordersEngineProvider`, so store/courier advances reach the manager live — all four roles (contractor checkout · store · courier · worker approval) share one engine. **v6.13:** the BS-dial manager order/customer panels also read the live engine (were a static seed). See `knowledge/WIRING_AUDIT.md`.
| 💡 (קצה שמאלי) | replays the intro tour (`showIntroTour` → the onboarding slides) | ✅ |
| שם-משתמש (צ'יפ ליד הלוגו) | registered user's first name (`userProfileProvider`); absent for guest/demo. **Tappable → `ProfileScreen.route()`** (48dp target · `Semantics(button,'הפרופיל שלי')`+Tooltip) — native profile surface: name/contact/profession edit via `userProfileProvider.update`, + 🔄 החלפת תפקיד (`showRolePicker`) + 🎮 מועדון BuildSmart (`RewardsHubScreen`). | ✅ |

## Version chrome (`home_shell.dart` AppBar → `version.g.dart`)

| Element | Behavior | Status |
|---|---|---|
| תווית-גרסה | מציגה `kVersionLabel` בלבד (אפור-secondary, `Key('version_chrome')`), מ-`version.g.dart` הנוצר אוטומטית מ-git+STATUS. אין נקודה-ירוקה (שמורה ל-`_PulsingStatus`), אין changelog ב-UI. לא מרונדרת במצב "עץ חכם". | ✅ wired (לקח #72) |

## 🔗 Shared orders engine — DATA LAYER (`state/orders_engine.dart` · `logic/manager_dashboard.dart`)

The legacy `SYS_ORDERS` (the localStorage array every role read & wrote, @index.html:11965-12039,
:16939-17035) ported to a Riverpod state engine. **DATA LAYER ONLY — no UI reads it yet** (wiring
the 4-tab UI / the dial to the engine is a LATER wave). `ordersEngineProvider`
(`StateNotifier<List<Order>>`) is **SEEDED with the SAME four seed orders** (from `kManagerOrderSeed`,
the retained seed source) so every existing manager number is preserved. `Order` =
`id/who/site/items/sum/stage` (+ optional `createdAt`); `isOpen` = `stage!=='delivered'`. Persists
to `SharedPreferences` key `bs.orders.v1` (cart/profile pattern; corrupt → seed).

| API / provider | Behavior | Status |
|---|---|---|
| `placeOrder({who, site, items, sum, id?, createdAt?, …, customerPhone})` | contractor creates an order at stage `new`; auto-id `BS-####` above current max; prepended + timestamped; returns it. `customerPhone` (additive, default `''`) stamps the placer's profile phone for the order card's 📞/💬 | ✅ |
| `advance(orderId)` | next stage in `kManagerOrderFlow`; no-op once `delivered` (verbatim `mgrAdvanceOrder` @17022-17032); unknown id = no-op | ✅ |
| `setStage(orderId, stage)` | manager "god-step" to ANY flow stage; ignores unknown id/stage | ✅ |
| `resetToSeed()` | restore the four seed orders | ✅ |
| `managerAnalyticsProvider` | `ManagerAnalytics` over the engine's LIVE orders (same fold as the static `managerAnalytics`) | ✅ |
| `managerCustomersProvider` | `mgrCustomerList` over the engine's LIVE orders | ✅ |

Guard: `orders_engine_test` (21 — seed correctness vs `kManagerOrderSeed`/`managerAnalytics`,
place/advance/setStage behavior, persistence round-trip, flow ordering). The static
`managerAnalytics` / `mgrCustomerList()` (seed-bound) are UNCHANGED and still feed the dashboard
widget below — the engine just adds the live path for the upcoming UI wave.

## 🔗 Shared worker-tasks engine — W3 cross-persona (`state/worker_tasks_engine.dart` · `data/persona_data.dart`)

The 🦺 worker's tasks lifted from the STATIC `kPersonaTasks` into a live Riverpod engine both the
worker and the manager read & write — so "the manager manages everyone live" now covers the worker.
`workerTasksProvider` (`StateNotifier<List<PersonaTask>>`) is **SEEDED from `kPersonaTasks`** (every
verbatim string/number preserved). The approval bridge is the task status (proto 06 `taskStatusInfo`):
`active`/`rejected` →(worker)→ `review` (📸 ממתין לאישור) →(manager)→ `done` (✅ אושר) or `rejected`
(↩️ נדחה — back to the worker). `PersonaTask` gained `copyWith(status:)` + an optional `orderId`.

| API / provider | Behavior | Status |
|---|---|---|
| `submitForReview(id)` | WORKER "שלח לאישור": `active`/`rejected` → `review`; no-op from any other status | ✅ |
| `approve(id)` | MANAGER: `review` → `done`; if the task has an `orderId`, also `advance`s that order on the SHARED `ordersEngineProvider` (a completed install moves its order live) | ✅ |
| `reject(id)` | MANAGER: `review` → `rejected` (bounces it back to the worker's current bucket) | ✅ |
| `resetToSeed()` | restore the verbatim seed | ✅ |
| `pendingApprovalTasksProvider` | the LIVE `review` queue (id-sorted) the manager's אישורי עובדים view reads | ✅ |

Seed task 3 (איטום רצפת מקלחת, `review`) is bound to order **BS-1040** (stage `ready`) so approving it
advances ready → pickup — the cross-engine link. Guard: `worker_approval_engine_test` (5 — pure
submit→pending→approve→done in one container · reject bounce-back · order-linked approval advancing
BS-1040 with the manager open-orders 4→3 chain · the worker "📸 שלח לאישור" widget submit · the manager
👷 אישורי עובדים widget approve, reflecting live). `worker_app_test` updated to pump in a `ProviderScope`.

## 👔 Manager dashboard — M1 SHELL + M2 📊 לוח בקרה + M3 🚚 הזמנות + M4 👥 לקוחות + M5 🛠️ ניהול (COMPLETE) (`screens/manager_dashboard_screen.dart` · `state/manager_dashboard_state.dart` · `state/orders_engine.dart` · `screens/role_picker_sheet.dart`)

The 👔 "מנהל המערכת" persona was rebuilt from the BS-dial drill (below) into a **full
role-app screen** — the same LIGHT shell/style as the 🦺 worker app. **M1 = the SHELL; M2 fills the
📊 לוח בקרה tab with a LIVE cockpit; M3 fills the 🚚 הזמנות tab with the live order list + the
manager's god-mode stage-advance; M4 fills the 👥 לקוחות tab with the live customer list + credit;
M5 fills the 🛠️ ניהול tab with the 5 management tools** (all derived from the same shared orders
engine where live). **The screen is now COMPLETE — every tab is real, ZERO "בקרוב" placeholder remains.**

| Element | Behavior | Status |
|---|---|---|
| `ManagerDashboardScreen` | `ConsumerWidget`; LIGHT `Scaffold(bgLight)` + white AppBar (`cardLight`) — title "מרכז השליטה" (`inkLight`) + subtitle "מנהל המערכת" (`mutedLight`) + green "חי" pill + "‹ יציאה" | ✅ |
| 4-tab segmented toggle | pill style (selected = `brand` fill + white text; unselected = `cardLight` + `inkLight` text; pill radius) — 📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול; replicates `updates_screen`'s `seg()`; tap sets `managerTabProvider` | ✅ |
| `IndexedStack` body | index-0 = the 📊 `_DashboardTab` cockpit (M2); index-1 = the 🚚 `_OrdersTab` (M3); index-2 = the 👥 `_CustomersTab` (M4); index-3 = the 🛠️ `_ManageTab` (M5); all 4 kept mounted. **No placeholder remains — `_TabPlaceholder` was removed** | ✅ |
| 📊 `_DashboardTab` (M2) | `ConsumerWidget`; a LIGHT `ListView` (`bgLight`) over the LIVE engine — watches `managerAnalyticsProvider` + `ordersEngineProvider` (a trimmed port of `renderMgrDashboard` @index.html:12133) | ✅ |
| 5 metric tiles (`_MetricGrid`/`_MetricTile`) | WHITE `cardLight` cards (2-up `Wrap`) — emoji + big `brand` number + `mutedLight` verbatim label: 🚚 הזמנות פתוחות · 📦 מוצרים בקטלוג · 🧰 אביזרים נלווים · ✅ זמינים כעת · 🏪 חנויות פעילות. Numbers from `managerAnalyticsProvider` over the engine's LIVE orders (`mdMetric` @12160-12164). Seed: 4 / 54 / 148 / 202 / 3/3 — and 🚚 reflows when an order is placed/advanced/delivered | ✅ |
| Order pipeline (`_OrderPipeline`/`_PipelineRow`) | WHITE `cardLight` card "צינור ההזמנות" — per-stage count + proportional bar across the **6** `kManagerOrderFlow` stages (group-by-stage over `ordersEngineProvider`); labels verbatim from the legacy `md-pipe` array + נאסף for pickup: התקבלה · בהכנה · מוכן · נאסף · בדרך · נמסר; bar colours = legacy hex (`md-pipe` @12177-12198). Seed: 1/1/1/0/0/0 | ✅ |
| 🚚 `_OrdersTab` (M3) | `ConsumerStatefulWidget`; a LIGHT `ListView` (`bgLight`) over the LIVE engine — `ref.watch(ordersEngineProvider)`. A faithful port of the legacy `renderMgrOrders` (@index.html:16939-17075). Local `_filter` = `'all'` or one `kManagerOrderFlow` stage (the legacy `mgrOrderFilter`); the free-text search is out of scope this wave | ✅ |
| `_OrderSummary` (M3) | WHITE `cardLight` strip — 3 stats (הזמנות = total / פתוחות = open / מחזור = ₪Σsum, grouped). Legacy `mo-summary` @index.html:16953-16962 | ✅ |
| `_OrderStageChips` (M3) | `הכל (N)` + one chip per **populated** stage — VERBATIM `ORDER_STAGE` labels + counts (@index.html:12041-12048, `md-chips` @16967-16973). Active chip = `brand` fill; tap sets `_filter`. A stage that empties out falls back to `הכל` | ✅ |
| `_OrderRow` (M3) | WHITE `cardLight` card (legacy `mo-card` @16998-17017): `📦 id` + a `_StagePill` (tinted stage colour) on top · `who · site` · a 6-step `_MiniTracker` · footer `items פריטים · ₪sum` + the advance control. Tapping the card opens the detail sheet | ✅ |
| 🔑 `_AdvanceButton` "קדם שלב ›" (M3) | per **open** order → `ref.read(ordersEngineProvider.notifier).advance(o.id)` (the legacy `mgrAdvanceOrder` @17022) → toasts `הזמנה id → next-label` (or "ההזמנה כבר הושלמה"). A `delivered` order shows "✓ הושלם" instead. **The first manager WRITE to the engine** — the shared `ordersEngineProvider` means the 📊 dashboard's 🚚 tile + pipeline + counts reflow LIVE | ✅ |
| `_OrderDetailSheet` (M3, optional) | `showModalBottomSheet` on row tap (legacy `mgrOrderDetail` @17037-17075): `📦` + id + `status · who` tag · full 6-step `_MiniTracker` · items/sum/step grid · קבלן/אתר/סטטוס rows · `קדם ל"…"` action (routes through the same `advance`) or a "✓ ההזמנה הושלמה ונמסרה" note | ✅ |
| 👥 `_CustomersTab` (M4) | `ConsumerStatefulWidget`; a LIGHT `ListView` (`bgLight`) over the LIVE engine — `ref.watch(managerCustomersProvider)` (orders grouped by buyer `who`) + `ref.watch(ordersEngineProvider)` (for distinct sites + live reflow). A faithful port of the legacy `renderMgrCustomers` (@index.html:16566-16607). Local `_filter` = `'all'` / `live` / `low` (the status filter, swapping the legacy free-text search) | ✅ |
| `_CustomerSummary` (M4) | WHITE `cardLight` strip — 3 stats (קבלנים = count / סך רכש = ₪Σspend / ניצול אשראי = Σused÷Σlimit %). Legacy `mo-summary` @index.html:16574-16578 | ✅ |
| `_CustomerStatusChips` (M4) | `הכל (N)` + a פעיל / אשראי גבוה chip per **populated** status (counts). Active chip = `brand` fill; tap sets `_filter`. A status that empties out falls back to `הכל`. Labels verbatim from the legacy `mc-pill` (@index.html:16592) | ✅ |
| `_CustomerCard` (M4) | WHITE `cardLight` card (legacy `mc-card` @16593-16604): `👷 name` + `N הזמנות · M אתרים` (M = distinct build-sites per buyer off the live orders) + a status `_StagePill` on top; then a `_CreditBar` + the line `ניצול אשראי: ₪used / ₪limit (pct%)`. `pct = min(100, round(spend÷credit×100))`; ceiling = `contractorCredit` (the deterministic hash in the analytics layer). Status (@16562): **פעיל** 0<pct<90 (green) / **⚠️ אשראי גבוה** pct≥90 (amber) / לא פעיל pct=0 (grey). Tapping opens the detail sheet | ✅ |
| 🔑 LIVE customers | the list is `managerCustomersProvider` over the engine's orders, so a **new contractor order placed on the engine (by ANY role) adds/updates a customer card here LIVE** — proven in `manager_dashboard_screen_test` (place an order → a 5th customer card appears; push a buyer >90% → "⚠️ אשראי גבוה") | ✅ |
| `_CustomerDetailSheet` (M4, optional) | `showModalBottomSheet` on card tap (legacy `mgrCustomerDetail` @16609-16643): `👷` + name + a status tag · orders/spend/pct grid · credit rows (מסגרת אשראי / נוצל / יתרה זמינה / אתרי בנייה) · the contractor's own orders (📦 id · ₪sum · stage pill), all off the same live engine. Read-only | ✅ |
| 🛠️ `_ManageTab` (M5) | `ConsumerStatefulWidget`; a LIGHT `ListView` (`bgLight`) — the intro banner + the W3 👷 אישורי עובדים section + a 5-section accordion (only one open at a time, local `_open` key, the legacy `mgrManageOpen`). A faithful port of `renderMgrManage` (@index.html:16645-16890) | ✅ |
| `_ManageIntro` (M5) | a soft `brand`-tinted banner: "🛠️ שליטה מלאה על אפליקציית הקבלן — כל שינוי מתעדכן מיידית." (legacy `mm-intro` @16650) | ✅ |
| `_ManageSection` (M5) | a WHITE `cardLight` accordion card — tappable header (emoji + title + sub + optional count badge + ▾/‹ chevron) revealing its body when open (legacy `mmSection` @16855). 6 of them now (👷 אישורי עובדים first, then the 5 verbatim tools) | ✅ |
| 👷 אישורי עובדים body (`_ApprovalsBody`/`_ApprovalRow`, W3) | the manager's LIVE worker-approval queue (the W3 cross-persona affordance) — `ref.watch(pendingApprovalTasksProvider)` (`review` tasks off the shared `workerTasksProvider`), with a count `_CountBadge` in the header. Each row: task name · `🦺 worker · 🕒 days · steps` · note · keyed **✅ אשר** (`approve-<id>` → `approve`, review→done; advances a bound order) / **↩️ דחה** (`reject-<id>` → `reject`, review→rejected). Empty → "🎉 אין משימות הממתינות לאישור." A worker "📸 שלח לאישור" surfaces a row here with no refresh; the decision reflects live on the worker screen. LIGHT only | ✅ |
| 🗂️ קטגוריות body (`_CategoriesBody`, M5) | the **LIVE** catalog category list — `ref.watch(managerAnalyticsProvider).catalogCategories` (sorted by count desc): header `קטגוריות פעילות (N)` + a `<cat> · <count> מוצרים` row per category + the verbatim hint "שינוי שם קטגוריה מעדכן את כל המוצרים שבה." (legacy SECTION 3 @16715-16729) | ✅ |
| ⚙️ הגדרות אפליקציה body (`_AppSettingsBody`, M5) | the 3 contractor-app config rows VERBATIM: תוספת משלוח אקספרס=₪80 (`EXPRESS_FEE` @11961) · מסגרת אשראי לקבלן=₪50,000 (`creditLimit` @11963) · שיעור מע״מ=18% (`VAT_RATE` @11941) + the verbatim hint (legacy SECTION 4 @16733). Display-only | ✅ |
| 🌳 עץ המוצרים body (`_ProductTreeBody`, M5) | an inline summary of the catalog product-tree (the legacy SECTION 1 prompt-edit has no backend here): the verbatim purpose + the live tree size (מוצרים בעץ / קטגוריות, from the same analytics map) | ✅ |
| 🏷️ מותגים ומחירים body (`_BrandsBody`, M5) | the brands list from `lib/data/brands.dart` (`kBrands`): header `מותגים (N)` + each brand's `emoji name` + tagline + product count (legacy SECTION 2 @16687) | ✅ |
| 🔬 בדיקות רגרסיה body (`_RegressionBody`, M5) | a `brand` action button "🔬 פתח מרכז בדיקות רגרסיה" → `Navigator.push(RegressionPanelScreen.route())` (the same target the old manager dial used) | ✅ |
| `managerCustomersProvider` | `Provider<List<ManagerCustomer>>` — `mgrCustomerList` over the engine's LIVE orders (`state/orders_engine.dart`) | ✅ |
| `managerTabProvider` | `StateProvider<int>` (0..3) — the active tab the `IndexedStack` reads | ✅ |
| `ManagerDashboardScreen.route()` | `MaterialPageRoute<void>` (the app's screen pattern) | ✅ |
| role picker → manager | `role_picker_sheet.dart` `_RoleRow.onTap` for `manager` now `Navigator.push`es `ManagerDashboardScreen.route()` (mirrors worker→`WorkerAppScreen`) **instead of** `activePersonaProvider='manager'`/`OpenDial.bs` (the old drill). Other personas unchanged. | ✅ |

Scope (M5): ONLY the 🛠️ tab body + the route call to `RegressionPanelScreen` — the orders engine
internals, the logic layer (read, not changed), the other 3 tabs (M2 = 📊 · M3 = 🚚 · M4 = 👥, all
done), the role picker, and the buyer/checkout flow are untouched. **The manager screen is now COMPLETE
— `_TabPlaceholder` was removed; no "בקרוב" remains anywhere.** The old BS-dial manager drill code below
remains (now unreachable via the picker) pending a later cleanup. Guard: `manager_dashboard_screen_test`
(30 — M1's six + M2's four + M3's six + M4's six + M5's seven [intro + 5 tool headers · 🗂️ LIVE category
counts · ⚙️ verbatim config rows · 🌳 inline tree summary · 🏷️ kBrands list · 🔬 routes to
`RegressionPanelScreen` · manage tab LIGHT/no-dark] + the COMPLETE/no-"בקרוב" + role-picker tests).

## 👔 Manager BS-dial → 📊 dashboard (`bs_dial_widget.dart` · `state/dial_state.dart` · `logic/manager_dashboard.dart`) — LEGACY drill (unreachable via picker as of M1)

The 👔 "מנהל המערכת" persona → לוח בקרה (`kManagerSections` → section `m-products`) has 5
`md-*` leaves. Tapping a leaf opens an INLINE `_ManagerMetricPanel` above the dial (R2 —
dial-drill, NO navigation) showing the REAL number derived in `manager_dashboard.dart`
(`managerAnalytics`, a verbatim port of `mgrAnalytics()` @index.html:12081-12126). State:
`bsMetricLeafProvider` (which `md-*` panel is open; tap toggles; any other dial action
clears it). The other dial leaves (children / `mm-regression` / etc.) are unchanged.

| Leaf (id) | Shows | Source getter | Status |
|---|---|---|---|
| 🚚 הזמנות פתוחות (`md-open-orders`) | `openOrders` (=4; orders not delivered, @12096) | `ManagerAnalytics.openOrders` | ✅ |
| 📦 מוצרים בקטלוג (`md-catalog`) | `catalogCount` (=54; non-accessory, @12110) | `ManagerAnalytics.catalogCount` | ✅ |
| 🧰 אביזרים נלווים (`md-accessories`) | `accessoryCount` (=148; `accessoryProduct:true`, @12107) | `ManagerAnalytics.accessoryCount` | ✅ |
| ✅ זמינים כעת (`md-available`) | `availableCount` (=202; STORE_STOCK all-true, @12122) | `ManagerAnalytics.availableCount` | ✅ |
| 🏪 חנויות פעילות (`md-stores`) | `storesLabel` (="3/3"; active/total, @12125) | `ManagerAnalytics.storesLabel` | ✅ |

The leaf row whose panel is open is rendered `active` (highlighted), so the user sees which
metric the panel belongs to; popping the persona/anchor or drilling into a child clears
`bsMetricLeafProvider`. Verified active in v5.93 (M1 — the 5 leaves no longer toast "בבנייה").

Guard: `bs_dial_manager_test` (5 leaves present · tap→inline panel with the real number ·
NO "בבנייה" · toggle closes) + `manager_dashboard_test` (the derivations, vs index.html).

### 👔 Manager BS-dial → 📦 הזמנות (M2)

The 👔 persona → 🚚 הזמנות (`kManagerSections` → section `m-orders`) has 6 `mo-*` leaves —
ONE per order-flow stage (`kManagerOrderFlow` @index.html:16943). Tapping a leaf opens an
INLINE `_ManagerOrderPanel` above the dial (R2 — dial-drill, NO navigation) listing the REAL
orders in that stage from `kManagerOrderSeed` (@index.html SYS_ORDERS_SEED) — each row is
`📦 id` / `who · site` / `items פריטים · ₪sum` (mirrors the legacy `mo-card` @17001-17014),
plus the stage's order count in the header. State: `bsOrderLeafProvider` (which `mo-*` panel
is open; tap toggles; opening a metric panel or any pop/drill clears it — order & metric
panels are mutually exclusive). `kManagerOrderLeafStage` maps each leaf id → stage;
`_kOrderStageLabel` is the verbatim Hebrew stage name (`ORDER_STAGE[st].label` @12041-12048).

| Leaf (id) | Stage | Shows | Status |
|---|---|---|---|
| 📥 התקבלה (`mo-new`) | `new` | order BS-1042 (יוסי כהן · מגדל הרצליה · 7 פריטים · ₪1240) | ✅ |
| 🔧 בהכנה (`mo-preparing`) | `preparing` | order BS-1041 (אבי מזרחי · דירה — רמת גן · 3 · ₪680) | ✅ |
| 📦 מוכן לאיסוף (`mo-ready`) | `ready` | order BS-1040 (משה אברהם · וילה — סביון · 12 · ₪3150) | ✅ |
| 🚛 נאסף (`mo-pickup`) | `pickup` | **empty** → "לא נמצאו הזמנות תואמות." (0 in seed) | ✅ |
| 🚚 בדרך לאתר (`mo-transit`) | `transit` | order BS-1039 (דוד לוי · משרדים — תל אביב · 4 · ₪420) | ✅ |
| ✅ נמסר ✓ (`mo-delivered`) | `delivered` | **empty** → "לא נמצאו הזמנות תואמות." (0 in seed) | ✅ |

The empty text "לא נמצאו הזמנות תואמות." is the legacy `md-empty` line (@index.html:16986).
Guard: `bs_dial_manager_orders_test` (6 leaves present · each populated stage → its real order
row · the 2 empty stages → empty text · metric/order mutual-exclusion · NO "בבנייה").

### 👔 Manager BS-dial → 👥 לקוחות (M3)

The 👔 persona → 👥 לקוחות (`kManagerSections` → section `m-customers`) has 2 `mc-*` leaves —
ONE per customer status filter (the legacy `status` @index.html:16562). Tapping a leaf opens an
INLINE `_ManagerCustomerPanel` above the dial (R2 — dial-drill, NO navigation) listing the REAL
customers in that status from `mgrCustomerList` (manager_dashboard.dart, grouping index.html
SYS_ORDERS_SEED by buyer) — each row is `👷 name` / `orders הזמנות · sites אתרים` / status pill /
`ניצול אשראי: ₪spent / ₪credit (pct%)` (mirrors the legacy `mc-card` @16593-16604), plus the
status's customer count in the header. State: `bsCustomerLeafProvider` (which `mc-*` panel is
open; tap toggles; any other dial action / pop / drill clears it; metric/order/customer panels
are mutually exclusive). `kManagerCustomerLeafStatus` maps each leaf id → status; `pct`/`status`
+ the distinct-site count `sites` are derived exactly as the legacy `mgrCustomerList`
(@16554,16559-16562).

| Leaf (id) | Status | Customers (verbatim from `mgrCustomerList`) | Status |
|---|---|---|---|
| 🟢 פעיל (`mc-live`) | `live` (0<pct<90) | all 4 seed buyers — e.g. משה אברהם (1 הזמנות · 1 אתרים · ניצול אשראי: ₪3,150 / ₪71,100 (4%)), יוסי כהן · אבי מזרחי · דוד לוי | ✅ |
| ⚠️ אשראי גבוה (`mc-low`) | `low` (pct≥90) | **empty** → "לא נמצאו קבלנים תואמים." (no buyer ≥90% with the Dart credit ceilings) | ✅ |

The empty text "לא נמצאו קבלנים תואמים." is the legacy customer `md-empty` line
(@index.html:16586). Guard: `bs_dial_manager_customers_test` (2 leaves present · mc-live → its
real customer rows · mc-low empty → empty text · metric/order/customer mutual-exclusion ·
NO "בבנייה").

### 👔 Manager BS-dial → 🛠️ ניהול (M4 — final wave; manager persona COMPLETE)

The 👔 persona → 🛠️ ניהול (`kManagerSections` → section `m-manage`) has 5 `mm-*` leaves, ALL
wired to their REAL target — a faithful port of the legacy `renderMgrManage`
(@index.html:16645-16743). After M4 the manager persona has **ZERO reachable "בבנייה"** in any of
its four sections (md/mo/mc/mm). Two leaves are DATA views → an INLINE `_ManagerManagePanel` above
the dial (R2 — NO navigation), state `bsManageLeafProvider` (tap toggles; any other dial action /
pop / drill clears it; metric/order/customer/**manage** panels are mutually exclusive). Two leaves
are server actions → a labelled toast (the legacy `prompt()` editors have no backend here). One
leaf routes. The partition `kManagerManageDataLeafIds` ∪ `kManagerManageActionLeafIds` ∪
`{mm-regression}` covers every leaf with no overlap, so none can fall through to the stub.

| Leaf (id) | Kind | Real target (verbatim, NO "בבנייה") | Status |
|---|---|---|---|
| 🌳 עץ המוצרים (`mm-trees`) | server action | toast "🌳 עריכת האביזרים המשלימים של כל מוצר" (legacy `mmSection` sub-title @16653) | ✅ |
| 🏷️ מותגים ומחירים (`mm-brands`) | server action | toast "🏷️ עריכת המותגים והמחירים של כל מוצר" (legacy sub-title @16687) | ✅ |
| 🗂️ קטגוריות (`mm-cats`) | data view | inline panel: `קטגוריות פעילות (14)` + every category + `N מוצרים` from `kManagerCatalogCategories` (legacy SECTION 3 @16716) + hint "שינוי שם קטגוריה מעדכן את כל המוצרים שבה." | ✅ |
| ⚙️ הגדרות אפליקציה (`mm-settings`) | data view | inline panel: תוספת משלוח אקספרס=₪80 (`EXPRESS_FEE`@11961) · מסגרת אשראי לקבלן=₪50,000 (`creditLimit`@11963) · שיעור מע״מ=18% (`VAT_RATE`@11941) + the legacy hint | ✅ |
| 🔬 בדיקות רגרסיה (`mm-regression`) | route | `RegressionPanelScreen.route()` — **UNCHANGED** (closes the dial; no panel/toast) | ✅ |

The settings values are the legacy editable globals (read-only here — the `prompt()` editors are
server actions, R8: no invented mutation); the credit line uses comma grouping to mirror the legacy
`creditLimit.toLocaleString()` (@16736). Guard: `bs_dial_manager_manage_test` (12 — 5 leaves
present · mm-cats → its real categories+counts · mm-settings → its 3 real rows · mm-trees/mm-brands
→ the verbatim action toast (not "בבנייה") · mm-regression → still routes · metric/order/customer
mutual-exclusion both directions · the leaf-set partition).

## Catalog settings (`catalog_settings_screen.dart` → `catalog_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| שמור היסטוריית חיפוש | gates recording recent searches; recents persist across launches via `recentSearchesProvider` (`addRecentSearch`, key `bs.recent-searches.v1`) | ✅ |
| סרגל מיון מהיר במוצרים | shows/hides the "מיון לפי" control | ✅ |
| גודל תמונות | product image size (small/med/large) — list rows (image column w/h) **and** grid cards (`gridCardImageMetrics`: image padding + emoji) | ✅ |
| מצב קומפקטי | product row height/margins (list) **and** grid card name-box/paddings | ✅ |
| הנפשות מופחתות | disables explode/diagram/pulse animations (app-wide) | ✅ |
| ניגודיות גבוהה | high-contrast theme (app-wide) | ✅ |
| גודל טקסט | global text scale (app-wide) | ✅ |
| סוג תצוגה (רשת/רשימה) | product grid ↔ list | ✅ |
| עמודות בתצוגת רשת | grid column count | ✅ |
| ניקוי היסטוריה / איפוס | clears recents / restores defaults | ✅ |
| מחירים/מע"מ/מטבע/מחיר-יחידה/השוואה | — | ⛔ no price data |
| דירוג/מרחק/ספקים מקומיים · AI×4 · יחידות/עשרוני · מיון-ברירת-מחדל · רדיוס | — | ⛔ no data/engine |

## Bottom nav (Benzi #3) — `home_shell._BottomNav`

4 tabs: **🏠 בית** (0, `CatalogScreen` on the "הכל" window) · **▦ מחלקות** (1,
`DepartmentsScreen`) · **🔔 עדכונים** (2, `UpdatesScreen` = התראות + שיחות merged
under a toggle `updatesSubTabProvider`) · **🛒 חנות** (3, `StoreScreen`). Cart =
floating FAB (hidden on חנות). Tapping בית resets the catalog to 'הכל' unscoped;
tapping מחלקות returns to the grid.

## Departments home (`departments_screen.dart` — Benzi #2/#3)

The **מחלקות** tab (bottom-nav index 1): a 2-col grid of 9 departments
(verbatim names). The two plumbing departments open a **fixtures-vs-pipes**
layout (Benzi #1 reframed, v5.96 — `category_division.dart` / `_DeptCatGroups`):
**small headings, each followed by its category rows** (no super-category to
drill into); a row tap drills into that category via `catalogTreePathProvider`.
- **ברזים וסניטריים** → 🚽 כלים לבנים (אסלות) · 🛁 כלים גמר (faucets · showers ·
  accessories) — `isCatalogDept` true.
- **אינסטלציה** → 💧 צינורות מים (PPR · copper · garden · transit valves ·
  manifolds · multilayer) · 🟤 צינורות שפכים (drainage · SmartLock · toilet
  branches).
A genuinely-mixed top-node splits per leaf (ברז-כיור→גמר but ברז-מעבר→מים); pure
families (PPR/SmartLock/אסלות) collapse to one drill-in row. **Dual-system
fittings** (אטמים ופקקים · חבקי תליה/צינור · עוגנים ובנדים · סטי הידוק, v5.97)
appear under **both** מים and שפכים headings — they fit either pipe. Supersedes
the old department-level `WaterSystem` filter. Guarded by `category_division_test`.
**v5.97 (בנצי #2):** `_CatGroupRow` dropped its trailing `Icon(Icons.chevron_left)`;
the orange product-count badge is now the row's END element (where the chevron was).
Row stays tappable (`InkWell` → `catalogTreePathProvider = [node]`).

**Tool departments (v5.83 — gather every real tool category):** a full audit (all
99 leaf categories) confirmed the catalog is 100% plumbing, so the only genuine
tool data backs two live tiles via `toolCats` (leaf `categoryHe`) →
`_toolDeptPath` (synthetic drill node, no system scope): **כלי עבודה ידני** →
`כלי עבודה` (2 wrenches) + `חותך צינורות` (2 cutters) · **כלי עבודה חשמלי** →
`כלי ריתוך PPR` (35 welding machines/drivers). Fitting-like cats stayed out
(מכשירי לחץ/מנגנונים/סטי-הידוק). The remaining **5** trades (חשמל · חומרי בניין ·
צבע · גבס · אספקה טכנית) → "בקרוב" toast (R8: no data) — guarded by
`departments_test`.

A `_DeptScopeBar` over the catalog names the active scope + a "כל המחלקות" clear.
Re-tapping the מחלקות tab (or the bar's clear) resets all three providers → grid.

**Flat "all products" per branch (Benzi #5, v5.86):** the scope bar also carries a
**"כל המוצרים" ↔ "קטלוג"** toggle (`deptFlatProductsProvider`) — "כל המוצרים"
swaps the catalog for ONE flat `LipskeyProductsList` of the whole branch
("ברצף, ללא קשר לקטלוג"). Scope = `departmentProducts`: water dept = all its
in-system products (`filterBySystem`), tool dept = all its `toolCats` products.
Resets on department open + clear. Guarded by `departments_test`.

## Catalog search panel tools (`catalog_screen.dart` · `_SearchToolsRow`)

> **חלוקת מערכת (Benzi #1) — option 2, דרך ה-finder:** מחלקה חיה קובעת
> `catalogSystemFilterProvider` ופותחת את ה-finder (בית) מסונן. הלוגיקה ב-
> `logic/system_division.dart` (משותף ל-catalog+finder, ללא back-import):
> `productDivisionSystems` (`VerifiedSpec.endSystems` supply=נקיים/drainage=שפכים
> → PPR=נקיים → שאר=שפכים), `filterBySystem`, `nodeHasSystem` (מתקנים בשני
> הצדדים; שאר לפי דומיננטיות). **פאזה 1:** finder (groups ריקים מוסתרים) +
> tree-drill + search. **פאזה 2 (v5.70):** קטגוריות + הכל + מועדפים —
> `_catsForSystem` (קטגוריות לפי `nodeHasSystem` הדומיננטי) · `filterBySystem`
> (מוצרים). **שורות הקטגוריה חיות (v5.79):** `_categorySummary` נותן לכל שורה
> ספירת-מוצרים אמיתית פר-מערכת (badge) + תיאור מתת-הקטגוריות שבמערכת — במקום
> ה-`_kMeta` הסטטי שהיה זהה בכל המחלקות. **פאזה 2b (v5.71):** עץ חכם — `filterSmartBySystem`/`smartProductSystems`
> ממפים את ה-SKU של מותגי ה-SmartProduct חזרה לקטלוג (לא-פתיר → נשאר בשני
> הצדדים, R8). **פאזה 3 (v5.71):** בורר המערכת הכפול (`sysOpt`) הוסר מגיליון ⚙️
> פילטרים — המערכת מגיעה רק מהמחלקות (source-of-truth אחד). **כל סקשני ה-browse מסוננים.**

| Tool | Behavior | Status |
|---|---|---|
| 🎤 קולי | `VoiceService.listen` (browser speech) | ✅ |
| 📷 ברקוד | `openBarcodeScanner` (כפתור: "הפעל מצלמה" — verbatim ← Preact `submenu-barcode`) | ✅ |
| ⚙️ פילטרים | sheet → `searchImageOnlyProvider`; live results filtered by `filterByImage` (הכל / עם תמונה בלבד) | ✅ |
| ↕️ מיון | sheet → `catalogProductSortProvider` (`_sortProducts`): ברירת מחדל / שם א-ת / שם ת-א / מק"ט, applied to live results | ✅ |
| ▦ קטלוג | closes the panel + jumps to the קטגוריות section | ✅ |
| filter "עם מחיר" / price sort | — | ⛔ no price data |

## Catalog search — product matching (`catalog_screen.dart` · `catalogProductMatchesQuery`)

| Behavior | Detail | Status |
|---|---|---|
| forgiving product search | matches across name + category + colour word-by-word (order-independent); folds Hebrew gershayim/geresh (״ ׳ → " ') so a Hebrew-keyboard size query matches; expands everyday words via `kSearchSynonyms` (kept precise — e.g. שירותים → toilet fixtures only, not branch connectors); AND-match with a graceful any-word fallback (`requireAll:false`) so a reasonable query never dead-ends. **SKU (v5.89):** matched separately, only for queries ≥5 chars — a short numeric size query (`20`/`200`/`3000`) no longer substring-matches an unrelated SKU (`200` inside `120011`), which used to make 55% of `"20"` results SKU-coincidence noise. Guarded by `search_sku_pollution_test`. | ✅ |
| relevance ranking | default order sorts results by `searchRelevance` (name match > category-only > synonym/colour), so the product the user meant surfaces first; an explicit ↕️ sort overrides it | ✅ |
| word-completion (Benzi #6) | `searchSuggestions` → `_SearchSuggestions` chip row above the results: **completes the word being typed from catalog PRODUCT-name words** ("השלמת מילים לפי מוצרים") — last whitespace-token is the fragment, suggestions are distinct product words it prefixes, ranked frequency → א-ת, capped at 6, keeping the already-typed words (`מח` → מחסום·מחבר·מחזיק); respects `catalogSystemFilterProvider`; ≥2-char fragment in a product scope. Tapping fills `searchQueryProvider` → results re-run. Guarded by `search_suggestions_test` | ✅ |

## Catalog בית — finder home (`finder_screen.dart`)

| Behavior | Detail | Status |
|---|---|---|
| default landing | `catalogSectionProvider` defaults to `'בית'` — the app opens straight on the finder home (`active=='בית' ⇒ FinderScreen`), the least-technical path to a product | ✅ |
| type groups | `kFinderGroups` — 8 plain-language groups + אחר catch-all; groups are pairwise disjoint and every catalog product is reachable. Each row shows `desc` (plain-Hebrew description) + a product-count badge, same idiom as the קטלוג category rows | ✅ |
| group glyph | `finderGroupGlyph(label)`: each home group circle (+ breadcrumb) renders a designer 3D product icon — `kFinderGroupImage` (label → `assets/lipskey/categories/{faucets,toilets,shower_bath,drainage,pipes,garden,connectors,clamps,ppr,other}.png`), with an `errorBuilder` fallback to a Material icon `kFinderGroupIcons`/`finderGroupIcon`. Replaces the empty-box emoji canvaskit's font can't draw. Guarded by `finder_group_icons_test` (every group mapped, images+icons unique). | ✅ |
| sub-types | curated `kFinderSubs` (ברזים · ניקוז) cover every group category that has products, with unique labels and no 1-item junk chips; other groups auto-derive sub-types from `categoryHe`, merged by cleaned label | ✅ |
| narrow chips | `_narrowOptions`: curated facets (`kFinderFacets` — incl. floor-drain open/closed/shower words instead of opaque DN codes) → sizes (`_sizeRe`; confusing inch forms folded to clean fractions, e.g. 11/4"·1.25" → 1¼") → colours → distinguishing words | ✅ |
| results | render through the shared `LipskeyProductsList` (variant dedup + quantity wheel) | ✅ |
| chip-row scroll hint | `_ChipScroll` wraps every narrow chip row (סוג/גודל/זווית): when chips overflow, a soft edge-fade + ‹ chevron (`Key('chip-scroll-more')`) appears on the END edge (left in RTL) and hides once scrolled to the end / when nothing overflows — so clipped chips are discoverable | ✅ |
| letter-size axis | `_letterBar`/`_letterOptions` + `letterSizeTokens` (`_size_norm.dart`): a secondary `'מידה'` chip row (S/M/L…) appears when a pool has >1 letter sizes (e.g. clamp collars `אוגן כפול M`/`S`), co-filtering with גודל + זווית. Excludes the `L=` length prefix (gray pipe `L=50 ס"מ` is not a size). State `_letter`, reset on group/sub/back nav. | ✅ |
| wall-thickness axis | `_wallBar`/`_wallOptions` + `wallTokens` (`_size_norm.dart`): a secondary `'עובי'` chip row appears when a cross-dim pool has >1 distinct wall (`20×2.8` vs `40×5.5`). PPR/multilayer pipes ship the SAME OD at different walls (PN ratings — verified: 9/13 ODs have ≥2 walls), so wall narrows beyond the גודל (OD) axis. Co-filters with size/angle/letter. State `_wall`, reset on nav. | ✅ |
| chip display contract | one shared path keeps the filter chip and the product-card chip identical: `displaySizeLabel` (label text — P9/P12/P13) + `chipLabelDirection` (LTR for digit labels so `40×60` doesn't RTL-flip — P16). Drift is guarded by `finder_card_consistency_test` (finder chip set ⊆ card chip set over the whole catalog). | ✅ |
| secondary-axis orphan guard | `finder_card_consistency_test` extended: the three secondary axes (זווית/מידה/עובי) are derived only from the name, so every chip they surface must be literally visible on the card. Audit 2026-06-02: 0 violations; three guards lock it in. | ✅ |
| size-chip substring false-match (v5.86) | `_productHasChip` matches a chip by structural size/angle token, then falls back to `nameHe.contains(chipLabel)` for curated-facet PLAIN-WORD chips. That fallback is now gated to digit-free labels — it used to fire for digit chips too, so `5"` matched `1.25"`, `50 מ"מ` matched `250 מ"מ`, `2"` matched `1/2"` (a size filter surfacing larger sizes it isn't). Global false-positive upper bound 350→0. Guarded by `finder_filter_falsematch_test`. | ✅ |
| mm-token dedup reachability (v5.87) | `dedupLengthByMm` collapses equivalent LENGTH chips (cm≡meters, P11), but it also merged the `mm` family — which is usually a DIAMETER (`250 מ"מ` head) or cross-dim OD (`16×20`), not a length. `250 מ"מ` collapsed into `25 ס"מ` and `16×20` into `16×16`; since `_productHasChip` matches by exact label, every product carrying the collapsed-away label became unreachable by the surviving chip (328 catalog-wide). Fix: `mm` dropped from the length-dedup rank — mm tokens each stay their own chip. dedup-missed 328→0. Guarded by `finder_dedup_reachability_test`. | ✅ |
| tokenizer agreement — leading fraction (v5.88) | `isSizeToken` (card word-classifier) required a leading digit, rejecting a bare `½"` that `parseSizeTokens` (finder) accepts — so on the Lipskey `_NameWords` path `½"` would render as a plain link not a size chip, and `productListDedupeKey` wouldn't strip it. No product triggers it today (the lone `½"` is a חוליות hierarchy card), but the asymmetry was latent. Fix: `isSizeToken` accepts a leading fraction glyph; the two tokenizers now agree. Full suite 1061/1061. Guarded by `finder_tokenizer_agreement_test`. | ✅ |
| dims-DN chip on card (v5.84) | the finder surfaces a גודל chip from `tokensFromDims(dims)` (DN/length) even when the name has no size — but `_NameWords` (Lipskey card) previously showed only name words + length, so fittings (ברכיים/אטמים/מכסים) filtered by DN landed on a card with no visible size, and the collapsed DN variants (cycled via the "N/M" family badge) looked identical. Fix: `_NameWords` adds a gray informational DN chip from `tokensFromDims` for each `dnDiameter` whose label isn't already a name size-chip — mirrors the finder exactly (incl. showing BOTH `4"` from name AND `DN110` from dims). `_grayInfoChip` helper shared by the DN + length chips (adds `chipLabelDirection` LTR). | ✅ |
| dims-DN chip on hierarchy card (v5.85) | the חוליות/PPR card path (`_HierarchyChips`) shows a name-derived breadcrumb, so covers/risers/grates whose bore lives ONLY in dims (e.g. `הגבהה`/`מכסה`/`רשת` → DN98/DN104/DN111) had no visible size while the finder filtered them by DN. Fix: `_HierarchyChips` appends a gray stacked "מידה" DN pill from `tokensFromDims` **only when the breadcrumb carries no size of its own** — so a PPR valve (name states the OD, e.g. `20`) never gets a second, possibly-inconsistent dims-DN (PPR dims DN is unreliable: a `50` valve carries DN63). Cards with no visible size: 18→1. The lone remainder (`סט פקקים…½"`) is a `parseChips` gap — it doesn't surface a leading-fraction `½"` the way `parseSizeTokens` does (tokenizer asymmetry, 1 accessory). Guarded by `card_dims_dn_chip_test` (4: Lipskey DN · חוליות hierarchy DN · PPR no-dup · name-size no-dup). | ✅ |
| Lipski → `_HierarchyChips` (gate 117 follow-up, v6.09) | post PDF-data sync (9/9), Lipski cards route to the same hierarchy breadcrumb as Polyroll/חוליות (`lipskey_products_screen.dart:1176`). `parseChips` got compound-type lookahead (`מיכל הדחה` / `מושב אסלה`) + Lipski model vocab (ספיר/ברקת/טופז/יהלום/טיטאן/כנרת/חרמון/אדיר/תבור/כרמל/הגייני) + `87°` shape + `סגירה רכה` / `אנטי ונדליזם` / `ציר ניירוסטה` compound features + `(מס. 1)..(מס. 9)` kitchen-sink variants + `DN\d+` size prefix for pipes. AQUATEC stays on `_NameWords` (no structure). Guarded by `lipskey_hierarchy_parity_test` (18 SKUs · type+path) + `card_dims_dn_chip_test` (updated for v6.01 names). | ✅ |
| group-emoji glyph fallback | sites that showed a finder group emoji (🚰🚽🕳️ — empty box in canvaskit) now render an icon instead: product-sheet "נמצא ב" strip uses `Icons.travel_explore` (`_StripDef.icon`), and the catalog overview "מאתר" row drops the emoji (label only). Home circles already use `finderGroupGlyph` (I1). | ✅ |
| code hygiene (I10-partial) | `dart fix` sweep on `finder_screen.dart` + `_size_norm.dart` (44 mechanical fixes: trailing commas, redundant args, combinators ordering, unnecessary raw strings, omitted local types). Both files lint-clean. No user-visible behavior change. | ✅ |

## Chat settings (`chat_settings_screen.dart` → `chat_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| בוט (botEnabled) | enables the canned auto-reply | ✅ |
| חיווי הקלדה | shows "מקליד..." before a bot reply | ✅ |
| אישורי קריאה | sent ticks blue ✓✓ vs grey ✓ | ✅ |
| רטט (chatVibration) | haptic on send | ✅ |
| ברכת פתיחה | seeds a greeting in a fresh chat | ✅ |
| זמן מקוון אחרון (lastSeenPrivacy) | nobody → hides "פעיל כעת" + online dot (`showOnlinePresence`) | ✅ |
| מדיה/גיבוי/שפה/שעות-עסקיות/פרטיות/lock-preview/auto-archive/spam | — | ⛔ media/server |

## Chats screen (`chats_screen.dart`)

| Button | Behavior | Status |
|---|---|---|
| חיפוש / פילטר צ'יפים | filter thread list | ✅ |
| לחיצה על שיחה | opens conversation | ✅ |
| החלקה לארכוב + ביטול | archive/restore (persistent) | ✅ |
| תפריט ⋮ → שיחה חדשה | opens an empty conversation with the contact | ✅ |
| תפריט ⋮ → ארכיון שיחות | opens the archive screen (restore per row) | ✅ |
| תפריט ⋮ → השתק הכל / בטל | mutes/unmutes all threads (persistent, toggles label) | ✅ |
| תפריט ⋮ → הגדרות | **REMOVED** — opened the dead ChatSettingsScreen (call-settings tree: read-receipts/typing/video-compression/call-ringtone/cloud-backup — none real). The screen file is kept but is no longer reachable from any menu/search. | ⛔ removed |
| chat header 📞 / 💬 (calls/video) | **was** dead in-app voice+video buttons → now REAL `ContactActions`: 📞 launches `tel:`, 💬 launches `https://wa.me/…` (via `url_launcher`, seam `urlLauncherProvider`). Phone = `userProfileProvider.contact` (the only number the app holds; threads carry none). Hidden when no phone. | ✅ |
| שליחת הודעה | adds bubble (+ auto-reply if bot on) | ✅ |
| עוד · מצלמה/צירוף/אמוג'י/מיקרופון | — | 🚧 |

## Notifications (`notifications_screen.dart` → `notif_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| סוגי התראות: הזמנות/משלוחים/מבצעים/ירידות-מחיר | hide that category from the list (`notifMutedSections`) | ✅ |
| חשיבות (importanceFilter) | important/critical → only high-priority rows (`passesImportance`) | ✅ |
| snooze banner | mutes notifications temporarily | ✅ |
| push/email/sms/whatsapp · שעות-שקט · סיכומים · צליל/רטט · lock-screen · לפי-תפקיד | — | ⛔ no notif engine |
| 🦺/💰 פעולת-התראה (טפל כעת/פרטים) | **T6:** sheet inline (R9, `showNotifActionSheet`) — safety→`kSafetyTips`×5+אישור · budget→ספי 80/90/100% + סטטוס. מחליף toast 'בבנייה' | ✅ |

## Store (`store_screen.dart` → `store_settings.dart`)

| Setting / button | Behavior | Status |
|---|---|---|
| defaultPayment | seeds the cart payment method | ✅ |
| selfPickupDefault | seeds delivery = pickup | ✅ |
| vatInclusive | VAT shown embedded vs added; total adjusts | ✅ |
| minOrderAmount | blocks checkout below the minimum | ✅ |
| confirmLargeOrder + largeOrderThreshold | confirm dialog at checkout | ✅ |
| cart stepper (+ / − / לעגלה) | `qtyForKey` / `setQtyForKey` | ✅ |
| saveCartToProject | show/hide the cart project selector | ✅ |
| summary chips (פריטים בסל / הזמנות פתוחות / הצעות ספקים) | derived live: `cartItemCount` (cart+smart lines), `isOrderOpen` over `_kOrders`, offers single-sourced from the מכרז ספקים row badge | ✅ |
| לאן לשלוח (Benzi #4) | **one-time** non-binding popup `openShipToSheet` (TextField + דלג/שמירה), auto-opened by `home_shell`'s `smartCartProvider` listener on the **first product add** (cart 0→1) — NOT at checkout. Guard `shipToPromptedProvider` (default true for tests; seeded in `main()` via `loadShipToPrompted`, persisted via `saveShipToPrompted`). Address → `shipToProvider`. Guarded by `shipto_prompt_test` | ✅ |
| כתובות/חשבוניות/ספקים/השכרה/אחריות/ביומטרי/אשראי-יומי | — | ⛔ server/data |
| ההזמנות שלי → גיליון-הזמנה (T5) | מעקב-סטטוס חי (`_OrderTimeline` · 4 stages) + כפתור "📄 סרוק תעודת-משלוח" → toast (OCR=stub, §9d). Sheet `isScrollControlled` (QA — הכפתור היה חתוך) + תוכן ב-`SingleChildScrollView` (gate 32 — לא גולש במסכים נמוכים). | ✅ |

## Install Studio (`install_studio_screen.dart` → `logic/install_engine.dart`)

Entry: the catalog section chip **`'תכנון חיבור'`** (renamed from "תאימות" — a
self-explanatory name for non-technical users). Safety-checklist labels carry a
plain-Hebrew gloss with the technical term in parens (e.g. "ברז ערבוב נגד כוויה (TMTV)").

| Button | Behavior | Status |
|---|---|---|
| הוסף מוצר | append a chain anchor from the dark catalog picker | ✅ |
| **השלם התקנה** | linear `buildInstallation`, or `buildTreeInstallation` when a manifold is mid-chain (trunk → branches); dark BOM sheet with quantities, ⑂ branch count + outlet warning, gaps; "החל על הקו" applies it | ✅ |
| מטראז׳ צינור (− / +) | per-pipe length in metres; header totals "X מ׳ צנרת" | ✅ |
| טמפ׳ הקו | cycles 20/60/80°C (material suitability) | ✅ |

**Engine hardening (B1):** the bore engine (`_minBoreMmOf` · install_engine), the
pressure-drop estimator (`_boreMeters` · pressure_drop) and the spec sheet
(`engineeringSpecFor` · related_info) now share ONE BSP inch→mm const
`kBspInchToMm` (in `lipskey_verified_connections`) instead of three hand-copied
tables that could silently drift. `_autoAddCompliance.insertAt` guards
`items.length < 2`, so `buildInstallation([oneSupplyProduct], autoCompliance: true)`
no longer throws a `clamp(1, 0)` ArgumentError. Both locked by
`install_engine_hardening_test`.

**Engine safety (B2):** (P2.4) `_findBridge` (the name-inference fallback used
when the verified BFS finds no path) now refuses to bridge across plumbing
systems — `productSystems(from) ∩ productSystems(to)` must be non-empty, matching
the BFS's own isolation. A probe found 0/3600 reachable cross-system bridges
today, so this is defence-in-depth; `install_engine_safety_test` enforces the
invariant going forward. (P2.5) `manifoldOutlets` classifies a manifold by the
catalog taxonomy (`'מחלקים'` / `productType 'מחלק'`), not by raw end-count — a
tee/מסעף with 3 same-size ends (e.g. `116565`) is no longer mis-read as a
3-outlet manifold (now 0). Real manifolds keep their outlet counts (4/2/4).

**Drainage slope (P3.9):** the BOM sheet showed the supply-only "עלייה אנכית /
ירידת לחץ" block for EVERY line. Now it's gated on `lineIsSupply(plan.items)`:
a supply line keeps the pressure-drop check; a **drainage** line instead shows a
slope block — "אורך אופקי" + "מפל אנכי" sliders feeding the existing
`checkDrainageSlope` (pressure_drop) → "שיפוע ניקוז X%" with the ת"י-1205 verdict
(green ≥ 2%, amber below). No invented values — the function and the 2% standard
already existed (covered by `pressure_drop_advanced_test`); P3.9 only wires them
into the drainage UI.

**Connection validity — terminal devices (B4):** the engine validated geometry +
material + cross-system isolation, but treated almost every non-ceramic device as
a pass-through connector — so it accepted physically-invalid chains a plumber
rejects. Now TERMINAL devices are `FlowRole.fixture` (endpoint-only, never
auto-inserted): traps (`סיפונים`/`מחסומים גלויים`), floor/roof drains
(`מחסומי רצפה`/`מאספי רצפה`/`תעלות ניקוז`/`ניקוז גג`/`מאספים וקולטים`), and supply
draw-off taps (`ברזי מטבח`/`כיור`/`קיר`/`אמבטיה`/`גן`/`דלי`). A line carries at
most ONE terminal: two-on-one (double-trap, two taps in series, two floor drains)
is rejected in `findShortestPath`/`_findShortestPathExcluding`/`_findBridge`, and a
pair separated by connectors (`trap→pipe→trap`) is caught at the line level in
`buildInstallation` (records a gap → `isComplete=false`, so "התקנה שלמה" no longer
overclaims). In-line valves (`ברזי מעבר`) stay connectors; shower components
(`מערבל→זרוע→ראש`) are deliberately left for a later finer model; flow-direction
for check/backflow valves is the next step (B5). Locked by
`install_engine_safety_test`; `audit40` cases 3/15/23/35/39 — which had encoded the
two-terminal bug as *valid* — were flipped to expect no-path.

**Engine round-2 fixes (B5):** (E1) the galvanic dielectric requirement now fires
between dissimilar metal GROUPS — copper-group (נחושת/פליז) joined to iron-group
(פלדה/נירוסטה) — via `_galvanicallyDissimilar`, used by both `lineComplianceChecklist`
and `_autoAddCompliance`. The old predicate required copper specifically (missed
brass↔steel) and omitted stainless; benign copper↔brass is no longer over-flagged.
(E8) shower spray OUTLETS — `ראשי מקלחת` (heads) + `מזלפי יד` (hand-sprayers) — are
now `_terminalCats` (endpoint-only), while `זרועות דוש` (arms) + `ברזי מקלחת`
(mixers) stay connectors so the real mixer→arm→head chain still builds. Locked by
`install_engine_b5_test`.

**Spec-data fixes (B6):** (E6) `224156` (PP-MD-ML DN110 drainage pipe) maxTempC
80→70 to match its identical family (224345/224169/… all 70) — was an outlier that
made the engine accept it but reject its identical siblings on a ~71-80°C line.
(E3) reducing branch tees had their larger DN erased (ends flattened to all-DN50):
`116558` (מסעף 110/50) → [110,110,50], `217533` (75/50) → [75,50], `218564` (מסעף
כפול 110/50/50) → [110,50,50] — so the real DN110/DN75 joints connect and a DN50
pipe no longer mates a physically large socket. DNs taken from the product names.
Locked by `install_engine_b6_test`. (A broader flattened-DN sweep — מצרה 50/40,
40/32, 110/100, 50/32 — is tracked for B8.)

**Manifold over-capacity cap (B7/E5):** `buildTreeInstallation` used to route EVERY
branch target even past the manifold's physical outlet count — emitting phantom
branches (each with its own TMTV/balancing valve) off ports that don't exist, and
miscounting over-capacity from the raw target list. Now branches are CAPPED at
`manifoldOutlets`: the overflow targets become gaps (so `isComplete` is false) plus
an explicit over-capacity warning, and TMTV/balance are added only per actually-
routed branch. Within capacity, behaviour is unchanged. Locked by `manifold_test`
case 10 (now builds a 4-branch-on-2-outlet tree). The studio UI banner is fixed too
(B12, #5): `_assemble` counts only real branch targets (≠ the manifold), and the
over-capacity banner now reads "$branches ענפים על מחלק $outlets-יציאות — N לא חוברו
(חסר במחלק)" — the accurate requested / capacity / overflow. Verified live (build
web + browser: a 3-branch line on a 2-outlet manifold showed "1 לא חוברו"). visual_log.

**Flattened-DN data sweep (B8):** a class of reducers/couplers/caps had their
verified-spec ends lazily defaulted to a single DN (mostly [50,50]) regardless of
the product name, so the engine accepted wrong-size joints and rejected the real
ones. Restored from the names: reducers `218568`(50/40)/`220316`(40/32)/
`116680`(50/32), `194897`(110/100), coupler `218567`(160/160), and single-ended
caps `218569`(110)/`218460`(50)/`218560`(160)/`220315`(40). Full suite (1569) stayed
green — no test had encoded these wrong joints. Two ambiguous items (`116203`
"40/49", thread-side elbow `116207` "32/32") were left for human confirmation.
Locked by `install_engine_b8_test`.

**Backflow / vacuum-breaker (B10/E7):** a garden tap / hose outlet (`ברזי גן`) on a
supply line can back-siphon dirty water into the potable supply; code requires a
vacuum-breaker. `lineComplianceChecklist` now surfaces this as a WARNING-severity
check ("שובר-ואקום למניעת זרימה-חוזרת") instead of silently passing. It is
intentionally UNSATISFIABLE — no vacuum-breaker SKU exists in the catalog, so it
cannot be auto-inserted and stays a warning (no `criticalOpen` impact). Adding a
real VB product is flagged for the user. Locked by `install_engine_b10_test`.
(E4 note: the high-value auto-compliance fix — auto-adding the dielectric union for
the steel expansion tank — already shipped in B5; TMTV line-sizing was evaluated
and dropped as a practical no-op since every fixture line carries a ½″≈DN15 outlet,
and the PRV has no DN variants to size.)

**Directional-valve orientation warning (B11/D4):** check valves (אל-חזור/אלחוזר)
and sewage backflow preventers (category `אל חזור`) are one-way devices, but the
model stores their two ends identically — so the undirected engine cannot reject a
backwards mount (`deep_audit` even asserts path symmetry). The checklist now WARNS
("כיוון התקנה — שסתום חד-כיווני", warning severity) when a line contains such a
device, surfacing the orientation hazard for manual verification. This is the safe
increment; full orientation ENFORCEMENT (a per-end inlet/outlet `port` on
ConnectorEnd + a direction-aware search + relaxing the symmetry invariant) is a
larger architectural change deferred for design review. Locked by
`install_engine_b11_test`.

**Per-device directionality guidance (B13/#1):** the single generic warning is now
ONE check PER directional valve — `lineComplianceChecklist` emits
"כיוון התקנה: <valve name>" with `_directionalContext` stating where it sits
("בין <upstream> ל-<downstream>"), so the installer knows exactly which valve, and
between which two parts, to orient for flow. (True rejection of a backwards mount
remains impossible — a check valve's two ends are physically identical, so
orientation is an install choice the parts list can't encode; the engine pinpoints
and guides rather than enforces.) Locked by `install_engine_b13_test`.

---

## Verified by regression (`test/wiring_test.dart`)
- cart `qtyForKey` / `setQtyForKey` (sum, collapse, remove-at-0)
- store `cartPaymentProvider` / `cartDeliveryProvider` defaults from store settings
- `notifMutedSections` mapping (all-on → none; per-type off → matching section)
- chat mute notifier (`setAll`) and archive notifier (`archive`/`restore`)
- finder grouping: groups disjoint, אחר catch-all + no blank category, curated
  `kFinderSubs` cover every group category w/ products, unique labels, cats ⊆ group
- `catalogProductMatchesQuery`: category-word match, synonym expansion,
  `requireAll:false` graceful superset, colour searchable, שירותים precision
  (no connector match), `searchRelevance` ranks name-match above synonym-match

UI-only effects (theme/contrast/text-scale, grid layout, VAT display, image size)
are documented above but exercised through their underlying providers/helpers

---

## Dead code removed (step 9)

Symbols removed from `catalog_screen.dart` — never had callers, no visual impact:

| Symbol | Lines removed | Phase |
|--------|--------------|-------|
| `_MiniSearchPill` | ~22 | B ✅ |
| `_Chip` | ~37 | C ✅ |
| `_diameterSubGroups` + `_diameterCounts` + `_diameterBucket` + `scrollCtrl`/`subGroups` params + `_SectionBanner` | ~54 | D ✅ |
| `_CatalogDrillSection` cluster (P4+P5+P6+P7) | ~353 | E ✅ |

Total removed: ~466 lines. Kept: `catalogDrillCatProvider` (line 237) — used in smoke test `tabs.dart`.
rather than pixel rendering.

## Polyroll catalog spec routing (§22)
- `lib/data/polyroll_catalog.dart` `_pprSpecFor(categoryHe, nameHe, page)` returns
  the correct per-page or per-sub-type spec for each product. See
  `knowledge/CATALOG-CARD-PROTOCOL.md` §22.C/D/E/F for the full ruleset.
- p80 AQUATHERM AC blue pipes: kPprPipesAC → `spec_pprct_pipe.jpg` (was
  routing to `spec_faser_20.jpg` green by mistake; fixed in §22.F sweep).
- **§22.I — internal-card dims completeness:** `_acPipe` builder now injects
  `'מק"ט חוליות': sku` into its dims map (was missing for all 16 AC pipes,
  thinning the internal card vs. the catalog). Guard: spec_assets_test
  "§22.I every Polyroll product carries יצרן + at least one מק"ט" — sweeps
  the whole catalog, fails on any builder that skips the standard dim fields.
  mutation-verified by `scripts/mutation_verify.sh` (the protocolist's tool).
- §14 detection: `test/spec_assets_test.dart` enforces 36 routing rules
  including "every page lands on its own per-page crop or a legit shared one".
- All 74 catalog pages audited per §22.F mandatory audit checklist.

## External-card chip hierarchy (§21)
- `chip_hierarchy.dart` `parseChips(nameHe)` → breadcrumb [shape ‹ thread ‹ size];
  the title is the type noun. Angles (45°/90°) are shape, the diameter is the
  size — a digit-leading angle no longer steals the size slot.
- `lipskey_products_screen.dart` `_HierarchyChips`: display-only cleanup —
  `_chipDisplayLabel` strips wrapping parens, `_isNoiseChip` hides bare units
  (מ"מ). nameHe stays verbatim (R8); tap index maps back to the raw path level.
- §14: `spec_assets_test` · "§21 angle fittings keep the diameter as size".

## §21.A chip fixes (2026-06-01)
- Angle elbows keep diameter as size (sizeRe skips shape tokens); bare 45/90
  removed from shape set. Display: parens stripped, units (מ"מ) hidden.
- Multi-word phrase "למיקום נקודת מים" kept as one ordered chip (_l3Compounds).
- Guards: spec_assets_test "§21 angle fittings keep the diameter as size" +
  "§21 multi-word phrase stays one ordered chip".

## §21.B unit-fold — lossless recoverability (2026-06-01)
- `chip_hierarchy.dart` `_kChipUnits {מ"מ, mm}` + a parseChips branch fold the
  unit INTO the size chip (`l5 = '$l5 $t'`), so the size reads "20-63 מ"מ" and
  the full Polyroll name is recoverable from [type]+breadcrumb+material badge.
  'מ"מ' removed from kChipLevel3Feature (was being hidden as noise → dropped).
- Guard: spec_assets_test "§21.B every Polyroll name is fully recoverable from
  the chips" — behavioral, scoped to kPolyrollCatalog (no grep antipattern: מ"מ
  is a legit standalone token in lipskey_catalog, so a source grep can't tell
  the wrong placement from the right one). E2E result: 774/774 full recon.

## §21 chip picker (בורר) — works for Huliot (v5.95 — 2026-06-03)
- The faceted chip picker (tap a breadcrumb chip → swap that attribute for a
  sibling product) was dead for every Huliot product. Two bugs, lesson T4:
  - `lipskey_products_screen.dart` `_cycleHierarchy` drew siblings from
    `kPolyrollCatalog` → now `kCatalogProducts` (unified).
  - `chip_hierarchy.dart` `findHierarchySiblings` gated on a fixed
    `polyrollBrand` (returned `[]` for Huliot) → now gates on the product's
    **own** brand (same-brand siblings); the `polyrollBrand` param is removed.
- Behavior: tap a חוליות `ברך 45°` shape chip → picker offers `45°`+`90°`; size
  chip → `32/40/50/63`. Polyroll/PPR picker unaffected (same-brand still holds).
- Guard: `huliot_picker_test` (4) + mutation_verify on the brand gate.

## §21.C chip + picker level labels — primary/secondary/final clarity (2026-06-01)
- User: "אני נכנס לבורר בציפ אני לא יודע מה הוא בורר ראשי ומה משני ומה אחרון
  זה בבלגן." Chips were identical-looking pills, picker said "בחר ערך" generic.
- `chip_hierarchy.dart` `ChipPath.levelLabelOf(int) → String` maps a path index
  to one of {חיבור, צורה, תכונה, תבריג, מידה}. Two consumers:
  - `lipskey_products_screen.dart` `_HierarchyChips` — stacks each chip in a
    Column: 9pt grey level label on top + value pill below. RTL → "חיבור" reads
    first (primary), "מידה" last (final).
  - `lipskey_products_screen.dart` `_hierarchyPickerTitle` — picker header now
    reads "בחר חיבור:" / "בחר צורה:" / "בחר תכונה:" / "בחר תבריג:" / "בחר מידה:".
- Guard: spec_assets_test "§21.C every visible chip carries a semantic level
  label" — sweeps kPolyrollCatalog, asserts every non-noise chip gets one of
  the 5 allowed labels and the size chip always reads "מידה".
## Catalog lens selector (v5.44 — data layer)
- `lib/data/catalog_lens.dart` — `CatalogLens {category,variant,smartTree}`,
  `availableLensesForSet(products)` (which lenses are meaningful for a set;
  smart-tree hidden below 25% mapped — approach א), `groupByLens(products,lens)`
  (titled `LensGroup` buckets per axis), `setSupportsLens`.
- `lib/state/catalog_lens_state.dart` — `catalogLensProvider` (transient
  StateProvider, default category) + `resolveActiveLens(selected, available)`
  (falls back to first-available; never strands on an unavailable lens).
- Wiring status: data layer ONLY. The selector chips + list router (which read
  `catalogLensProvider` and render `groupByLens` output beside the existing
  grid/list + sort controls) are the NEXT step — not yet wired into
  `catalog_screen.dart`. Guard: `catalog_lens_test` (18 tests).

## Lens selector UI — step 3a (v5.46)
- `lib/screens/lens_selector_row.dart` — `LensSelectorRow(products:)` ConsumerWidget:
  a list-level chip row ("סדר לפי: 📂/🎚/🌳") that reads/writes `catalogLensProvider`
  and shows only the lenses `availableLensesForSet(products)` deems meaningful.
  Renders nothing when <2 lenses apply (category-only sets unchanged).
- Wiring status: widget BUILT + tested (`lens_selector_row_test`, 3 widget tests),
  NOT yet placed in a product-list screen. Placement into the product browse view
  (where `groupByLens` output renders) is step 3b.

## Lens selector — step 3b WIRED (v5.47)
- `LipskeyProductsList` (lib/screens/lipskey_products_screen.dart) now renders
  `LensSelectorRow` ABOVE the product list. Default lens = category → the
  original flat grid/list, unchanged. variant/smartTree → `_groupedList` renders
  `groupByLens` output: a `_LensGroupHeader` (title + count) per group, products
  as standard rows. The selector hides itself when <2 lenses apply.
- This is the user-visible activation of the lens feature (steps 1+2+3a).

## Lens selector — option א: smart-tree group = gateway (v5.48)
- Under the 🌳 smart-tree lens, each `_LensGroupHeader` in `lipskey_products_screen.dart`
  is now TAPPABLE → `openSmartProductSheet(context, smartProductForSku(first.sku))`,
  opening the rich SmartProduct card (install/compat/brands/BOM). Header shows a
  🌳 prefix + "פתח כרטיס ›" hint + Semantics(button). Category/variant headers
  stay non-tappable. Imports via `show` (openSmartProductSheet, smartProductForSku)
  to avoid circular-import symbol pollution.

## Lens selector — option א refined: per-row "כרטיס חכם" (v5.49)
- Under 🌳 smart-tree lens, each `_ProductRow` shows "כרטיס חכם" (was "פרטים")
  → `_openSheet` opens the rich SmartProduct card via openSmartProductSheet/
  smartProductForSku for THAT product's fixture (not a group-level gateway).
  Falls back to the standard Lipskey sheet when unmapped. `_LensGroupHeader`
  reverted to a plain label (🌳 prefix cue only, not tappable).

## cardReadinessScore — raised bar (v5.53)
- `related_info.dart::cardReadinessScore` expanded 5→9 dimensions so 100 reflects
  FULL smart-card readiness (spec+25 · connectivity+20 · ת"י+12 · install+13 ·
  acceptance+5 · compliance+5 · finder+5 · price+5 · variants+10). A spec'd
  connectable PPR fitting now reaches ~95 (was 90); fixture endpoints stay low.
  Guards: card_score_test (raised-bar group) + mutation_log.

## Score badge on internal card (v5.56)
- `lipskey_product_sheet.dart` header now renders the `cardReadinessScore` badge
  ("📊 ציון נתונים N · label", `scoreBandColors`) — same metric the smart card
  shows. Closes the gap: PPR/Lipskey products that open the INTERNAL card (not
  the smart card) now display their data-readiness score (PPR ~95).

## cardReadinessScore — quantity-aware (v5.57)
- `related_info.dart::cardReadinessScore` now grades by AMOUNT of knowledge, not
  binary presence (user: "לא תתסתכל על הכמות ידע שיש לו"). New/regraded terms:
  data-depth `p.dims.length` (≥8→15 · 4-7→10 · 1-3→5); connectivity (≥20→18 ·
  ≥5→12 · >0→6); install-tips / acceptance / compliance graded by item count;
  spec 25→20, finder 5→3, price 5→2. Effect: the PPR faser pipe (dims=11, richest
  but 0 mates) rises ~75→80 מצוין instead of being pinned by connectivity.
  Verified live-equivalent: PPR supply 98 · faser 80 · toilet seat 16 · trap 63.
  Guards: card_score_test (spec-weight 25→20) + mutation_log (dims `:0`→`:50`
  turns the seat "stays low" + "no single dim=100" guards red).

## cardReadinessScore — composite breadth+depth (v5.58)
- `related_info.dart::cardReadinessScore` now returns a COMPOSITE of two axes
  (user: "ציון משוכלל משני הצירים"), each ≤50, and exposes both sub-scores in
  the return record `({score, label, breadth, depth})`:
  • BREADTH — weighted presence of distinct knowledge KINDS (variety).
  • DEPTH — graded QUANTITY within the measurable kinds (dims/mates/tips/…).
  composite = breadth + depth (cap 100). Broad-but-shallow or deep-but-narrow
  products land mid-band; only broad AND deep reach מצוין. Callers
  (`lipskey_product_sheet.dart`, `catalog_screen.dart`) keep using `.score`/
  `.label` (named access — extra record fields are non-breaking).
  Verified: PPR supply 99 (b49/d50) · faser 75 (b41/d34) · seat 15 (b11/d4).
  Guards: card_score_test (spec→breadth≥10; composite==breadth+depth) +
  polyroll_score_test (pre-spec baseline ≤50) + mutation_log.

## Huliot SmartLock — P11 installKit parity (v5.83 — 2026-06-02)
- **`recommendedKitForProduct` קיבל ענף `if (p.brand == 'חוליות')`** ב-
  `lib/logic/install_kit.dart`: חותך-צינורות (רק ל-`kSmlPipes`) + מפתח-לאום
  SmartLock לפי DN bracket (≤40 → 61040360, >40 → 61060560). ענף תואם ב-
  `installKitFor` (`related_info.dart`) סופר tools.
- **תוצאה ב-UI:** product sheet של כל מוצר חוליות מציג עכשיו strip "ערכת
  התקנה" (📦) — צינור = tools≥2, fitting/nut = tools=1.
- 4 בדיקות P11 חדשות ב-`polyroll_e2e_test.dart` (קבוצה אחרי P6) +
  mutation_verify על ענף ה-Huliot. 1041 tests pass.

## Huliot SmartLock — hotfix R2-fallback (v5.80 — 2026-06-02)
- **באג שאובחן ע"י בנצי:** כרטיסי Huliot ב-web/release התרוקנו. שורש:
  89 photo crops + 83 spec crops לא הועלו ל-R2 bucket → CDN 404 →
  `CachedNetworkImage` זרק חריגה → build failed → כרטיס ריק.
- **תיקון זמני:** `_huliotImageFor` ו-`_huliotSpecFor` קיבלו flags
  `_routeCropDisabled` + `_specCropDisabled = true`. הכרטיס מציג עכשיו
  את עמוד-הקטלוג המלא (`page_NN.jpg` — כבר ב-R2) במקום crop. הרוטינג
  הקנוני נשמר ב-`_huliotImageForCrop` — flip של flag אחד מחזיר את
  ההתנהגות המקורית ברגע שה-crops יעלו.
- **§17.1 הוקל זמנית** ל"exists" בלבד (במקום "is a real crop"). **§17.1.b**
  עודכן לעבוד מול ה-routing table הקנוני, לא מול imageAsset הדינמי, כך
  שה-crops הקיימים על דיסק נחשבים legitimate (הם ה-deliverable ל-upload).
- **P10 בHULIOT_TODO** — הוראות upload + reversal steps.

## Huliot SmartLock — P3 spec crops פר-משפחה (v5.77 — 2026-06-02)
- `scripts/crop_huliot.py` הורחב: לכל band ש-`SPEC_PAGES` (31 עמודי-טבלה),
  מתחת לתצלום נחתכת **דיאגרמת חתך** (L/DN/W/t/H verbatim) → 83 קבצי
  `spec_sml_p{NN}_{tag}.jpg`. פטור: עמ' 24 (אביזרים), עמ' 27 (AQUA SLIM —
  hand-tuned).
- `_huliotSpecFor` עבר מ-`return null` ל-routing: מקבל את ה-tag
  מ-`_huliotImageFor` וממפה `spec_$img`. נופל ל-null עבור page-fallback +
  עמודי 24/27.
- **2 שערים חדשים/מורחבים:**
  - **§17.2-Huliot** (חדש) — every product with specImageFile → קובץ קיים פיזית.
  - **§17.1.b** הורחב לכלול גם `spec_sml_p*.jpg` ב-orphan scanning.
- 39 lint-infos `avoid_escaping_inner_quotes` נוקו ב-`dart fix --apply`
  (single→double quotes ל-strings עם `'` בתוכן).
- mutation_verify ✓ · 1031 tests · flutter analyze: 0 Huliot warnings.
- **HULIOT_TODO סגור 9/9 ✅ 100%** (P3 הומר מ-🔵 ל-✅).

## Huliot SmartLock — P8 לוגו brand ייעודי (v5.75 — 2026-06-02)
- `assets/lipskey/categories/smartlock.png` — היה עותק של `drainage.png`
  (placeholder). הוחלף ב-crop של ה-Y-tee האייקוני מעמ' 1 של הקטלוג
  (x=10-510, y=150-650), resize ל-512×512 RGBA. דומיננטי בצבע ה-Huliot הירוק
  הכהה, מציג את חתימת SmartLock visual signature (3 השקעים + הטבעות הירוקות).
- `finder_group_icons_test` "no two groups share the same product image"
  עובר (md5 שונה מ-drainage.png). 1015 tests pass.
- **HULIOT_TODO סגור 9/9** — כל הפריטים בוצעו או הוכרעו כ-cosmetic.

## Huliot SmartLock — P4 AQUA SLIM crops עמ' 27 (v5.74 — 2026-06-02)
- עמ' 27 = layout ייחודי (2 renders + strip schematic) שלא מתאים ל-band-loop
  הגנרי. `scripts/crop_huliot.py` הורחב ב-`CROPS_27` עם hand-tuned boxes:
  - `sml_p27_a.jpg` — Aqua Slim 330 render (470,195→825,315)
  - `sml_p27_b.jpg` — Aqua Slim 700 render (420,440→825,540)
  - `sml_p27_c.jpg` — פס ניקוז ללא סט (strip-only schematic, 150,870→670,920)
- `_huliotImageFor` case 27: `has('פס') → c` · `has('700') → b` · default 330(a).
- 10 מוצרי AQUA SLIM (סטים + פסים) יצאו מ-page-27 fallback ל-crops ייעודיים.
- mutation_verify על default routing (page_27 → red §17.1, restore → green).

## Huliot SmartLock — P5 orphan-crop cleanup + 2 routing fixes (v5.73 — 2026-06-02)
- **P5 בוצע:** נמחקו `sml_p24_b.jpg` + `sml_p25_b.jpg` (table-only rows שלא
  היו ב-routing). `scripts/crop_huliot.py` SECTIONS עודכן (24:`['a','c','d']`,
  25:`['a','c']`). 88→86 crops.
- **Guard חדש §17.1.b-Huliot:** "no orphan crops" — סורק
  `assets/huliot_smartlock/products/sml_p*.jpg`, וכל קובץ חייב להיות referenced
  ע"י לפחות מוצר Huliot אחד דרך `_huliotImageFor`. **גילה 2 בגי-routing נוספים:**
  - **עמ' 30:** "רשת מוגבהת עגולה בז'/אפור" נפלה ל-`_p(30,'c')` (עגולה) במקום
    `_p(30,'a')` (raised). תוקן: `מוגבהת` נבדק לפני `עגולה`.
  - **עמ' 40:** "מאריך למבוא זחיח" נפלה ל-`_p(40,'b')` (slip pipe) במקום
    `_p(40,'c')` (extension). תוקן: `מאריך` נבדק לפני `זחיח`.
- mutation_verify על תיקון עמ' 30 (red→green). 1015 tests pass.

## Huliot SmartLock — P9 תיעוד PARITY+COVERAGE (v5.72 — 2026-06-02)
- `knowledge/PARITY.md` סעיף H · קטלוג: השורה הישנה "קטלוג 935" → "קטלוג
  3-brand (1,879 מוצרים)"; נוסף sub-table "Brand catalogs" עם 3 השורות
  (ליפסקי 935·21 cats · פולירול 774·14 cats · חוליות 170·17 cats).
- `knowledge/port/COVERAGE.md` "תוצאות מדודות" — שורה חדשה:
  **קטלוגי-מותג ב-Flutter · 1,879/1,879 = 100%** (כולל הקרדיט ל-brand #3).
- אין שינוי קוד; תיעוד-בלבד (סוגר את החוזה הפורמלי של ה-brand).

## Huliot SmartLock — P7 full dims למוצר-ייחוס פר-משפחה (v5.71 — 2026-06-02)
- CATALOG §13 — מוצר-ייחוס פר-משפחה = שורת-טבלה מלאה verbatim. נוספו
  `יח׳/ארגז` (per-box) + `יח׳/משטח` (per-pallet) ל-13 מוצרי-ייחוס:
  pipes(40·L3000), cutters, joker, elbow oneside 15°/40, elbow 45°/32,
  elbow reducing 90°/32-40, telescopic 40, tee 45°/32, double coupling 32,
  reducer 32/40, gutter 70/40, drain 80/50 סגור, nut 32, raised cover 28, basin
  siphon 1¼". ערכים נשלפו ישירות מ-PDF (smartlock_raw.txt) לכל reference SKU.
- Guard: `§22.J-Huliot reference product per family carries יח׳/ארגז + יח׳/משטח`
  ב-`spec_assets_test.dart` — סורק את ה-product הראשון בכל categoryHe,
  פטור: kSmlAccessories (umbrella, varied) + kSmlAquaSlim (layout שונה).
- mutation_verify על §22.J (מחיקת זוג ערכים → red→green). 1014 tests pass.

## Huliot SmartLock — P6 חיווט מותג לפונקציות משותפות (v5.70 — 2026-06-02)
- CATALOG שלב ה' — Huliot נפל ל-default ב-4 פונקציות משותפות. נוסף ענף 'חוליות':
  - `related_info.dart::finderGroupFor` → (🟢, 'דלוחין SmartLock') — "נמצא ב" עכשיו מאוכלס.
  - `related_info.dart::engineeringSpecFor` → snapshot מ-עמ' 4/6: PP רב-שכבתי
    (PPMD) · ללא PN (כבידה) · 95°C · דלוחין · נעילת ראטצ'ט+TPE · bore=DN.
  - `related_info.dart::complianceTriggersFor` → 5 תקני Huliot verbatim
    (ת"י 958-1/71253-1+2/5694/14020 + EN-1451·DIN 8078), בלי לדלוף תקני PPR.
  - `related_info.dart::complianceWhyHe` → 5 הסברי-why ל-labels החדשים
    (smart_card_data_test דורש why לכל label, כי Huliot smart-wired ע"י בנצי).
- Guards: `test/polyroll_e2e_test.dart` group `P6 · Huliot brand-wiring` (4
  בדיקות: finderGroup=דלוחין · engineeringSpec PP/no-PN/95°C · 5 תקנים נוכחים
  + לא דולף 15874 · 0 orphans). mutation_verify על finderGroupFor (red→green).
- 1013 tests pass.

## Huliot SmartLock — P1+P2 תצלומי-מוצר נקיים (v5.69 — 2026-06-02)
- מענה לפידבק "חלק מה-crops כוללים דיאגרמת L/DN + שאריות-טבלה":
- `scripts/crop_huliot.py`: `TOP_FRAC` (חלק יחסי מהבנד) → `PHOTO_H=170` קבוע
  מראש-הבנד. התצלום בגובה ~קבוע בכל הבנדים (2/3/4 סקשנים) כי ה-render בגודל
  אחיד; דיאגרמת L/DN+הטבלה יושבות מתחת ונחתכות. `min(PHOTO_H, band*0.92)`
  שומר על בנדים קטנים בתוך-הבנד.
- P2: `X1` 250→238 — מסיר את פס אייקוני יח'/ארגז/משטח האפור מימין.
- 88/88 crops נחתכו מחדש; שמות-קבצים ו-`_huliotImageFor` routing **ללא שינוי**
  (אותו contract, רק תוכן-תמונה נקי יותר). אומת ויזואלית ב-contact-sheet.
- Guards ללא שינוי: §17.1-Huliot (קיום + לא page-fallback) עדיין ירוק.

## Huliot SmartLock — 88 תמונות מוצר חתוכות פר-משפחה (v5.63 — 2026-06-01)
- מענה לפידבק "איפה תמונות לפי פרוטוקול?": עמוד-מוקטן הוחלף ב-crops אמיתיים.
- `scripts/crop_huliot.py` (one-off): חותך את עמודת-התצלום השמאלית (x=12-250)
  של כל עמוד-מוצר ל-N בנדים (לפי מספר הסקשנים), `sml_p{NN}_{a|b|c|d}.jpg`.
  88 קבצים ב-`assets/huliot_smartlock/products/`.
- `lib/data/huliot_smartlock_catalog.dart::_huliotImageFor` — switch פר-עמוד
  (11-43) שמנתב כל מוצר ל-crop שלו לפי keyword ב-nameHe (זווית/מידה/קטגוריה),
  בדיוק כמו polyroll `_pprPagePhoto`. שורות table-only (אטם מעביר p24, מצרה
  p25) ממחזרות crop של אח או מצמד. עמ' 27 (AQUA SLIM, render-on-table) =
  page image לגיטימי.
- Guard: `§17.1-Huliot every product front image exists + is a real crop` —
  מאמת שכל imageAsset קיים על דיסק ו**אינו** page-fallback (פרט לעמ' 27).
  זו ההגנה שמוודאת שלא נחזור לעמוד-מוקטן.

## Huliot SmartLock — chips היררכיים + תמונות (v5.62 — 2026-06-01)
- `lib/screens/lipskey_products_screen.dart:1175` — Huliot מצטרף ל-Polyroll
  במסלול `_HierarchyChips` (היה `_NameWords` Lipskey-style). כל קלף Huliot
  עכשיו מציג pills עם labels (חיבור/צורה/תכונה/תבריג/מידה) ו-breadcrumb '‹'.
- `lib/data/chip_hierarchy.dart`:
  - `kChipTypes` += 23 Huliot types (סיפון, מחסום, מאסף, אום, אטם, ...).
  - `kChipLevel2Shape` += 15°/30°/87.5° + חלק/טלסקופית/כפול/נפילה/קומקום/...
  - `kChipLevel3Feature` += 60+ Huliot tokens (לג'וקר, מטבח, רחצה, אמריקאי, ...)
  - `_l3Compounds` += 40+ multi-word compounds (צד אחד חלק, AQUA SLIM, ...)
  - Parser: skip cosmetic separators ('-', '—', '/'); strip surrounding parens
    on token before vocab lookup; multi-numeric tokens fold INTO `level5`.
  - Existing `_l3Compounds` של Polyroll עודכנו (הסרת '-' פנימי) כדי לתאום
    ל-skip-dash בtokenizer החדש.
- `lib/data/lipskey_catalog.dart`: image-asset path resolver — שם קובץ
  שמתחיל ב-`page_` הולך ל-`pages/` (לא `products/`). מאפשר ל-Huliot להציג
  את עמוד הקטלוג כתמונת מוצר כברירת-מחדל עד שתחתכו crops פר-משפחה.
- `lib/data/huliot_smartlock_catalog.dart`: `_huliotImageFor(page, …)`
  מחזיר `'page_NN.jpg'` (היה null → emoji-fallback). 170/170 cards עם תמונה.
- Guards: `§21.B-Huliot` strong recoverability עבר (parseChips); `§21.C-Huliot`
  מאמת שכל chip נושא label סמנטי. שני tests של Polyroll עודכנו במקביל
  (skip '-/—//' מ-orig set כדי שלא יסומנו כ-lossy אחרי שהפרסר מדלג עליהם).

## Huliot SmartLock — קבוצת בית ייעודית (v5.61 — 2026-06-01)
- `lib/screens/finder_screen.dart`:
  - `kFinderGroups` += `FinderGroup('🟢', 'דלוחין SmartLock', {kSml* ×17})` —
    מוצב בין "צנרת PPR" (פולירול) ל-"אחר" (catch-all).
  - `kFinderGroupIcons` += `'דלוחין SmartLock': Icons.water_damage` (Material).
  - `kFinderGroupImage` += `'דלוחין SmartLock': 'smartlock'` — תמונה
    `assets/lipskey/categories/smartlock.png`.
- `lib/data/huliot_smartlock_catalog.dart`:
  - `kSmlSiphons = 'סיפונים SmartLock'` (היה 'סיפונים' — התנגש עם קבוצת
    'ניקוז' שכבר כוללת את 'סיפונים' של Lipskey/Aquatec). הקבוצות עכשיו
    pairwise-disjoint (wiring_test).
- `lib/data/catalog_tree.dart`: `sml.siphons.lipskeyCategory` עודכן בהתאם.
- אפקט: ניקוז יצא 168→150 (18 סיפוני Huliot עברו לקבוצה החדשה).

## Huliot SmartLock catalog ingestion (v5.59-60 — 2026-06-01)

### Catalog tree leaves (sml.*)
| Leaf id | Title | Category (kSml*) | Products | Pages |
|---|---|---|---|---|
| `sml.pipes` | צינור חלק | `kSmlPipes` | 7 | 11 |
| `sml.cutters` | חותך צינורות | `kSmlCutters` | 2 | 11 |
| `sml.joker` | מתאם זווית - ג'וקר | `kSmlJoker` | 3 | 11 |
| `sml.elbow_oneside` | ברכיים צד אחד חלק | `kSmlElbowOneSide` | 8 | 12 |
| `sml.elbow` | ברכיים | `kSmlElbow` | 7 | 13 |
| `sml.elbow_reducing` | ברך מצרה | `kSmlElbowReducing` | 5 | 13-14 |
| `sml.elbow_telescopic` | ברך טלסקופית | `kSmlElbowTelescopic` | 4 | 15 |
| `sml.tees` | מסעפים | `kSmlTee` | 11 | 16-17 |
| `sml.double_coupling` | מצמד כפול | `kSmlDoubleCoupling` | 4 | 18 |
| `sml.reducer` | מצרה | `kSmlReducer` | 5 | 18, 25 |
| `sml.gutters` | מאספים | `kSmlGutters` | 8 | 19-20 |
| `sml.drains` | מחסומים | `kSmlFloorDrains` | 7 | 21-23 |
| `sml.accessories` | אביזרים משלימים | `kSmlAccessories` | 46 | 24, 39-43 |
| `sml.nuts` | אום SmartLock | `kSmlNuts` | 5 | 25 |
| `sml.aquaslim` | מאסף קווי AQUA SLIM | `kSmlAquaSlim` | 10 | 27 |
| `sml.covers` | מכסים, הגבהות ורשתות | `kSmlCovers` | 20 | 28-30 |
| `sml.siphons` | סיפונים | `kSmlSiphons` | 18 | 31-38 |
| **TOTAL** | | | **170** | **11-43 (excl. 26)** |

### Guards
- `test/spec_assets_test.dart`:
  - `§22.I-Huliot every product carries יצרן + מק"ט` (170 SKUs)
  - `§22-Huliot every product asset resolves to assets/huliot_smartlock/`
  - `§22-Huliot every Huliot page asset exists on disk` (170 × N pages)
  - `§21.B-Huliot every product name renders verbatim (no empty words)`
  - `§22-Huliot every numeric token in name is grounded in dims`
  - `§22-Huliot paranoid 12-check audit — cross-product consistency`
- `test/ppr_infra_test.dart`: `kCatalogProducts.length == Lipskey + Polyroll + Huliot`
- `knowledge/mutation_log.md`: `_sl` (factory) + `_brandDir` (path mapping) verified.

### File map
- **Data:** `lib/data/huliot_smartlock_catalog.dart` (170 products, factory `_sl`).
- **Brand:** `lib/data/brands.dart` Brand(id='huliot', name='חוליות', emoji='🟢').
- **Tree:** `lib/data/catalog_tree.dart` root `sml` + 17 leaves.
- **Path mapping:** `lib/data/lipskey_catalog.dart` `_brandDir(brand)` static.
- **Unified registry:** `lib/data/polyroll_catalog.dart` `kCatalogProducts +=
  kHuliotCatalog`.
- **Sheet content:** `lib/screens/lipskey_product_sheet.dart` `_buildInfoHuliot()`
  — page 5-6 advantages + page 4 standards + page 8-9 install verbatim.
- **Brand emoji:** `lib/screens/lipskey_products_screen.dart:1187-1192` —
  '🟢 חוליות' (was '🏭 ${brand}' fallback).
- **Assets:** `assets/huliot_smartlock/pages/page_01-44.jpg` (3.5MB).

### Detail

- New file: `lib/data/huliot_smartlock_catalog.dart` — 170 products from the
  Huliot SmartLock™ HE catalog PDF (44 pages, REV 001 / 02.2026). PP drainage
  system, 32-63mm, ratchet-tooth locking, TPE elastomer pressure seal.
  Standards: ת"י 958-1, 71253-1, 71253-2, 5694, 14020.
- 17 verbatim TOC families: `kSmlPipes`/`kSmlCutters`/`kSmlJoker`/
  `kSmlElbowOneSide`/`kSmlElbow`/`kSmlElbowReducing`/`kSmlElbowTelescopic`/
  `kSmlTee`/`kSmlDoubleCoupling`/`kSmlReducer`/`kSmlGutters`/`kSmlFloorDrains`/
  `kSmlAccessories`/`kSmlNuts`/`kSmlAquaSlim`/`kSmlCovers`/`kSmlSiphons`.
- Factory `_sl` auto-injects `יצרן='חוליות'` + `מק"ט חוליות'=sku` into every
  product's dims — §22.I (internal card completeness) is satisfied by
  construction (guarded by a new spec_assets_test §22.I-Huliot test).
- Wired into `kCatalogProducts` (polyroll_catalog.dart) — now Lipskey 935 +
  Polyroll 774 + Huliot 170 = **1,879 products**.
- Brand `'חוליות'` added to `lib/data/brands.dart` (id `huliot`, green 🟢).
- Catalog tree: `lib/data/catalog_tree.dart` `'sml'` root + 17 leaf nodes
  (`sml.pipes` → `sml.siphons`), each `brandIds: ['huliot']` +
  `lipskeyCategory: <kSml*>`. Reachable from the catalog drill-down.
- `lib/data/lipskey_catalog.dart` `_brandDir(brand)` helper now resolves
  Huliot to `assets/huliot_smartlock/` (was hardcoded `polyroll|lipskey`).
- Image fallback: `_huliotImageFor` returns null → flip side lands on the
  full catalog page (`assets/huliot_smartlock/pages/page_NN.jpg`). Per-family
  crops will go here as they're cut from the PDF (protocol §17).
- 44 pages extracted via `pdftoppm` to `assets/huliot_smartlock/pages/` +
  `pubspec.yaml` asset entry added.

## cardReadinessScore — row-level chip in search results (v5.59)
- `catalog_screen.dart::_SearchResultsList` product `ListTile` now shows the
  composite `cardReadinessScore` as a band-coloured `📊 N` chip in `trailing`
  (above the "מוצר" tag), via `cardReadinessScore`/`scoreBandColors` (already
  imported). Makes the score visible at a glance in the catalog search list —
  no need to open the card overlay. Verified live: PPR אספקה → 📊 99 (🟢);
  מושב אסלה → 📊 15 (🔴). Pure display; the score engine (v5.58) is unchanged.

## Huliot SmartLock → smart-tree wiring, batch 1: drainage fixtures (v5.62)
- `smart_tree.dart`: added 17 Huliot SmartLock SKUs as `SmartBrand` options to 4
  existing drainage-fixture cards (so they become mapped via `smartProductForSku`
  and reachable under the 🌳 smart-tree lens / "כרטיס חכם" button):
  - `floorDrain` (מחסום רצפה) +7 — 70124599 · 70124590 · 70114500 · 70114590 ·
    70145960 · 70117500 · 70117560
  - `basinTrap` (סיפון לכיור רחצה) +3 — 61230060 · 63466055 · 61233360
  - `kitchenDrain` (סיפון לכיור מטבח) +4 — 61450060 · 61550060 · 61350060 · 61650060
  - `washingMachineDrain` (סיפון למכונת כביסה) +3 — 61480100 · 61230065 · 62850060
- Effect: smart-tree mapped coverage 293 → **310** SKUs. Huliot floor-drains &
  siphons now show a כרטיס-חכם instead of falling back to the plain sheet.
- Guards: `smartproduct_contract_test` — new "Huliot … wired into the smart-tree"
  test (4 cards carry a Huliot brand; spot-check sku→card; ≥17 mapped) + the
  existing "every SmartBrand.sku is a real catalog SKU" + bridge round-trip.
  Mutation-verified (a broken Huliot sku fails both). Pure data; no engine change.
- REMAINING (next batches): American-sink siphons (62230060/62450060/62550060/
  62650060/62750060 + 61233172/63350060/61100062) → visibleTrap/otherTraps;
  pipes/elbows/tees/couplings → pvcPipe/drainageElbow/drainageFittings;
  gutters/covers/aquaslim → floorCollector/drainageManifold/floorCover.

## Huliot SmartLock → smart-tree wiring, batch 2: PP piping + remaining siphons (v5.63)
- `smart_tree.dart`: +62 Huliot SmartLock SKUs as `SmartBrand` options on 4 more
  drainage cards:
  - `pvcPipe` (צינור ניקוז) +7 — צינור חלק 32/40/50/63 (3-4 מ')
  - `drainageElbow` (ברכיים) +27 — ג'וקר ×3 · צד-אחד ×8 · 45°/90° ×7 · מצרה ×5 · טלסקופית ×4
  - `drainageFittings` (מחברים/מצמדים) +20 — מסעפים ×11 · מצמד כפול ×4 · מצרה ×5
  - `visibleTrap` (מחסום גלוי) +8 — סיפוני כיור-אמריקאי ×5 · ללא-סיפון · הורקה · אמבט
- Effect: smart-tree mapped coverage 310 → **372** SKUs; Huliot **79/170** mapped.
  Together with batch 1, all of Huliot's drainage *fixtures* + *piping* now open a
  כרטיס-חכם as a brand option.
- Guards: `smartproduct_contract_test` Huliot test extended to all 8 cards + sku→card
  spot-checks + ≥79 mapped. Mutation-verified (broken sku fails it + the catalog-SKU
  contract). Pure data; no engine change.
- REMAINING (batch 3): מאספים/AQUA SLIM → floorCollector/drainageManifold; מכסים
  → floorCover; אום/חותך/אביזרים משלימים (mostly SmartAcc, not brands).

## Huliot SmartLock → smart-tree wiring, batch 3: collectors/channels/covers (v5.64)
- `smart_tree.dart`: +38 Huliot SKUs as `SmartBrand` options on 3 more cards:
  - `roofCollector` (מאספים וקולטי גג) +8 — מאסף 70/40·130·230 + מאסף נפילה 50/100/110
  - `drainChannel` (תעלת ניקוז) +10 — AQUA SLIM 330/700 נירוסטה (סטים + פסים)
  - `floorCover` (מכסים ורשתות) +20 — הגבהות + מכסים עגול/ריבועי + רשתות
- Effect: smart-tree mapped coverage 372 → **410** SKUs; Huliot **117/170** mapped.
  All of Huliot's installable units (fixtures · piping · collectors · channels ·
  covers) now open a כרטיס-חכם. The unmapped ~53 are nuts/cutters/complementary
  accessories — SmartAcc-style, not standalone brand cards.
- Guards: `smartproduct_contract_test` Huliot test now spans 11 cards + sku→card
  spot-checks + ≥117 mapped. Mutation-verified. Pure data; no engine change.

## CI Gate-5 false-positive fix — BsTokens.chatText token (v5.68)
- `lib/theme/tokens.dart`: הוספת `BsTokens.chatText = Color(0xFF111111)` +
  `BsTokens.chatTimestamp = Color(0xFF777777)` כטוקנים ייעודיים לצ'אט.
- `lib/screens/chats_screen.dart`: החלפת שני שימושים בצבע גולמי `0xFF111111`
  (צבע טקסט, לא משטח כהה) בטוקן `BsTokens.chatText`.
- Effect: Gate-5 ב-CI (`grep ... lib/screens/`) מחזיר 0 תוצאות — false-positive נפתר.
  הטוקן עצמו נמצא ב-`lib/theme/` שלא נסרק ע"י Gate-5.

## Product/page images → CDN + bounded on-device cache (#3 weight)
- `lib/data/product_images.dart`: `productImageUrl` (pure asset-path → CDN-URL map,
  strips `assets/`) + `resolveProductImage`/`productImage` (drop-in for `Image.asset`).
  Full-quality images load from Cloudflare R2; cached on-device in a hard-capped LRU
  (`productImageCache`, ≤700 objects) so the device never fills, even at 60k+ images.
- Call-sites migrated `Image.asset(` → `productImage(`: `catalog_screen.dart` (2),
  `lipskey_products_screen.dart` (5), `lipskey_product_sheet.dart` (7),
  `install_studio_screen.dart` (1). Category icons + fonts stay bundled.
- Effect: release AAB 141.6 MB → 68.2 MB (−52%), image quality unchanged. Product/page
  assets de-bundled from pubspec; `IMAGE_BASE_URL` empty → bundled-asset fallback.
- Guards: `product_images_test.dart` (URL mapping, mutation-verified: strip + base).

## Huliot SmartLock → smart-tree wiring, batch 4: tools + connection nuts (v5.72)
- `smart_tree.dart`: +9 Huliot SKUs as `SmartBrand` options on 2 existing cards:
  - `tools` (כלי עבודה) +4 — חותך צינורות 40/50 + מפתח לאום 32-40/50-69
  - `drainageFittings` (מחברים/מצמדים) +5 — אום SmartLock 32/40/50/63 + אום מעבר מברזל
- Effect: smart-tree mapped coverage → Huliot **126/170** mapped.
- The remaining ~44 Huliot SKUs are kSmlAccessories (אטמים/פקקים/משפכים/מבואים/
  רוזטות — siphon spare-parts/seals). These are accessory-tier (SmartAcc), not
  standalone brand-cards; left as plain catalog products by design (a 44-brand
  catch-all card would be a dumping ground, not a usable smart-card).
- Guards: `smartproduct_contract_test` Huliot test extended to 12 cards (+tools)
  + sku→card spot-checks + ≥126 mapped. Mutation-verified. Pure data.

## Huliot SmartLock → smart-tree wiring, batch 5: spare-parts card (v5.78) — COMPLETE 170/170
- `smart_tree.dart`: new SmartProduct `smlSpareParts` ("חלקי חילוף לסיפון/מחסום
  SmartLock") — a parts-picker card listing the 44 remaining kSmlAccessories as
  SmartBrand options: אטמים (6) · אומי-ג'וקר (3) · פקקים (9) · אגנית/רוזטות (4) ·
  מבואים (5) · מכלולים/זחיחים/מאריכים/מתאם (7) · סטי-חיבור (3) · משפכים (3) ·
  אביקים/ונטיל/מצחיה (4).
- Effect: **Huliot smart-tree coverage = 170/170 (100%)**. Every Huliot SmartLock
  product now opens a כרטיס-חכם.
- Guard: `smartproduct_contract_test` Huliot test → 13 cards (+smlSpareParts) +
  sku→card spot-check + ≥170 mapped. Mutation-verified. Pure data.

## Unified-catalog reads — Huliot/PPR card, search & favorites/cart (v5.90)
Consolidates three fixes onto origin (the v5.85–v5.87 work, re-applied after
origin advanced to v5.89):
- **Blank card:** the search-result onTap built the sheet's sibling list from
  kLipskeyCatalog (empty for Huliot/PPR) → the variant pager threw
  "Invalid argument(s): 0" → blank card. Fix: build from kCatalogProducts +
  guard `categoryProducts.isEmpty ? [product]` in showLipskeyProductSheet.
- **SKU search:** matchProducts (results) iterated kLipskeyCatalog → a Huliot
  SKU (64032300) returned nothing. Fix: matchProducts runs over kCatalogProducts
  (catalogProductMatchesQuery already matches sku for >=5-char queries).
- **Favorites & cart:** favorites (×2), openCartLineProductSheet + cartLineDisplay,
  and the favorites-tile sibling call-site → kCatalogProducts.
Intentionally Lipskey-scoped: searchSuggestions (autocomplete, pinned by
search_suggestions_test) + the connection-planner count (install_engine Lipskey).
Rule in CONVENTIONS.md. Guards: huliot_card_render_test (2) + huliot_search_test (2).

## Contractor seeds foundation — T0 partial (לוח-קבלן)
- New `lib/data/contractor_seeds.dart` — verbatim const seeds (proto/04, T0.1/T0.3):
  PLAN_TYPES (4 · 13 zones · 3-store offers) · SAFETY_TIPS×5 · budget thresholds +
  `budgetLevel` · budgetCategories(4)+projectBudget · DEPT tiles(8) · helpers
  `bestStore`/`fMoney`/`caToday`.
- Guard: `test/contractor_seeds_test` (8 tests; fMoney/bestStore mutation-verified).
- Deferred (per PLAN): T0.2 StateNotifiers (mute→T7 · orders→T5; favorites exists) +
  ORDER_STATUS/STORE-services seeds (proto/04 lacks the verbatim labels → T4/T5).
  No `kLipskeyCatalog` introduced (gate 114 clean).

## Contractor T1 — catalog ⋮ "חלופות זולות" → cheaper same-product alternatives
- `home_shell.dart`: catalog ⋮ `case 'alternatives'` → `showModalBottomSheet(_CheaperAlternativesSheet)`
  (replaced the "בבנייה" toast). New `CheaperAlt` model + `cheaperAlternativesAcrossCatalog()`
  scanning `kHomeProductBrands` (lib/data/contractor_seeds.dart — proto §1b HOME_PRODUCTS, verbatim).
- For each product returns the cheapest tier below its recommended brand, sorted by savings desc
  (אסלה ₪740→560 · מקלחת ₪520→380 · ברז ₪189→139). Footer notes live supplier pricing in prod.
- Guard: `test/cheaper_alternatives_test` (≥3 alts · each altPrice<recPrice · sorted; filter
  mutation-verified). No `kLipskeyCatalog` (gate 114 clean).

## Contractor T2 — catalog ⋮ "השוואת מחירים" → per-product store price comparison
- `home_shell.dart`: catalog ⋮ `case 'price_compare'` → `showModalBottomSheet(_StorePriceComparisonSheet)`
  (replaced the "בבנייה" toast). New `StoreCompareRow` model + `storePriceComparisonAcrossCatalog()`
  flattening `kPlanTypes` zone items (lib/data/contractor_seeds.dart — proto §9b store offers, verbatim).
- Each product shows its 3 partner-store prices (בנייני העיר/אבן קיסר/טמבור הום…) as `_StoreChip`s;
  the cheapest (`bestStore`) is brand-highlighted with ✓. Footer = proto §9b verbatim note.
- Guard: `test/store_price_comparison_test` (≥3 products · each ≥3 stores · best==cheapest · §9b verbatim).
  No `kLipskeyCatalog` (gate 114 clean).

## Contractor T3 — catalog ⋮ "סרוק תוכנית" → scan flow (picker → scan → results → cart)
- `home_shell.dart`: `_ScanPlanSheet` now a `ConsumerStatefulWidget` (was a `showToast('בבנייה')` stub).
  3 phases: **picker** (4 `kPlanTypes` — proto §9) → **scan** (per-type `steps`, Timer animation) →
  **results** (per zone: header + ודאות%, items with `_StoreChip` store comparison, cheapest tagged).
- "אשר הכל — הוסף N פריטים לסל" → `scanPlanCartLines(plan)` adds each zone item at its cheapest store
  (`bestStore`) as a `SmartCartLine` → `smartCartProvider`, switches to חנות/הסל tab, toasts. Modal `isScrollControlled`.
- All strings verbatim proto §9. Guard: `test/scan_plan_test` (4 types active · each line cheapest · qty 1).
  No `kLipskeyCatalog` (gate 114 clean).

## Polish — token-binding (ליטוש · אין שינוי-wiring)
- **P-1 wave-1** (`catalog/notif/chat/store_settings_screen`): 44× צבעי-טקסט קשיחים →
  `BsTokens.inkLight/mutedLight` (token-equal · אפס שינוי-render/wiring). ראה `POLISH_LOG.md` #7.
- **P-3** (`toast`/`chain_diagram`): font-literals → `BsTokens.fontXs/Sm/Md/Lg` (token-equal).
- **P-4**: הוסר `go_router` (dependency מת, 0 שימושים).

## Dedup consolidation — scan/alternatives unified to canonical R9 sheets
- **Why:** Phase-1 added duplicate full-screens (`ScanMenuScreen`, AI-hub `_Alternatives`/`_PlanScan`)
  for features already implemented as catalog ⋮ modal sheets (T2/T3 above). Audit flagged it; fixed by
  upgrading the EXISTING sheets and deleting the duplicates (R9 = modal sheet is canonical).
- **New shared file `contractor_tools_sheets.dart`** (moved verbatim from `home_shell.dart`, no string/number change):
  `CheaperAlt`/`cheaperAlternativesAcrossCatalog`/`_CheaperAlternativesSheet`,
  `StoreCompareRow`/`storePriceComparisonAcrossCatalog`/`_StorePriceComparisonSheet`/`_StoreChip`,
  `scanPlanCartLines`/`_ScanPlanSheet`. Public openers: `openScanPlanSheet(ctx,{planKey})` ·
  `openCheaperAlternativesSheet(ctx)` · `openPriceCompareSheet(ctx)` (avoids home_shell↔leaf import cycle).
- **`_ScanPlanSheet` upgraded** with `initialPlanKey` deep-link (auto-starts the matching `kPlanTypes` plan) —
  ports the only extra the deleted `ScanMenuScreen` had. Guard: `budget_stock_scan_test` widget test.
- **Rewiring:** `menu_dial_widget` plan-* → `openScanPlanSheet(planKey)`; `ai_hub_screen` alt/plan tiles →
  the canonical sheets; `home_shell` catalog ⋮ → openers; `ai_hub_logic` repointed to the new file.
- **Deleted:** `lib/screens/scan_menu_screen.dart`. Net −1,144/+57. Gate: analyze 0 · 1642 tests · build web ✓.
- **Open TODO:** `knowledge/TODO-dedup-gate.md` — protocol has NO anti-dup gate (structural overlaps רכש≈Store,
  הגדרות≈dedicated screens still pending decision).

## Dial-distribution Wave 2 — 9×9 fleet (audit→validate→fix→gate, per Law #0)
Distributes the menu-dial 🏠 home branch into the catalog ⋮ (the dial itself is removed in Wave 3).
The 3 tools below were already in the ⋮ `itemBuilder` but had **NO `_onSelected` case** = silent no-op;
caught by 2 independent audit lenses (navigation + edge-crash), byte-verified against the architect agent's
mis-narration (it claimed "wired"). Now actually wired:

| ⋮ item | Behavior | Status |
|---|---|---|
| 🤖 בינה מלאכותית ואוטומציה | `case 'ai_hub'` → `AIHubScreen.route()` (label also un-truncated for text-parity) | ✅ |
| 📦 המלאי שלי | `case 'stock'` → `StockScreen.route()` | ✅ |
| 📋 משימות העבודה | `case 'site_tasks'` → `openSiteHub()` (10-tool site-hub landing) | ✅ |

- **`profile_screen.dart`** — native profile surface (name/contact/profession edit via `userProfileProvider.update`)
  reached from the name-chip; a11y pass (accessibility-rtl lens): 48dp target, button Semantics, chevron contrast,
  ExcludeSemantics on emoji/avatar, RTL/LTR input direction, ChoiceChip checkmark.
- **Conformance:** verbatim rule `הסל שלי` re-pointed `menu_trees.dart` → `store_screen.dart` (cart moved to the
  Store in the dedup; string preserved ×3). Gate: central-verify green — analyze 0 · 1645 tests · build · conformance 7/7.
- **Wave 3 (pending product-owner decisions):** delete `menu_dial_widget.dart` + hamburger + dial state; build a
  unified `SettingsScreen`; reconcile the projects dataset. Escalations in `_findings.md`.

## Dial-distribution Wave 3a — native settings + per-persona access (9×9 fleet · product-owner decisions)
Per product-owner: settings = extend the EXISTING `CatalogSettingsScreen` (not a new screen); profile+settings
reachable from EACH persona dashboard (separately); guest reaches profile via an always-visible account row.

| Surface | Wiring | Status |
|---|---|---|
| CatalogSettingsScreen · 👤 הפרופיל שלי (top, always visible) | → `ProfileScreen.route()` — guest-visible (register path) | ✅ |
| CatalogSettingsScreen · ערכת נושא / התראות (×4) / שפה | ported from the dial; provider-split kept (theme·lang→`appSettings` · notif→`notifSettings` · text/motion/contrast→`catalogSettings`) — verbatim strings from `settings_tree.dart` | ✅ |
| מנהל / חנות / שליח / עובד dashboards · AppBar | 👤 פרופיל→`ProfileScreen.route()` · ⚙️ הגדרות→`CatalogSettingsScreen.route()` (each persona, separately) | ✅ |
| כרטיס-זהות פרופיל ספק/עובד/שליח · 📞 / 💬 | `ContactActions(phone: profile.phone)` under the identity card (`store_profile_screen` / `worker_profile_screen` / `courier_profile_screen`) — 📞→`tel:<phone>`, 💬→`https://wa.me/<intl digits>` (`waMeDigits`) via the `urlLauncherProvider` seam. Hidden when the profile has no phone. No in-app calling. | ✅ |
| כרטיס/דף-הזמנה (store · courier · manager) · 📞 / 💬 | `ContactActions(phone: order.customerPhone)` reaches the CONTRACTOR who placed the order (product decision — the supplier/courier calling the placer). Field flow: `Order.customerPhone` (additive, default `''`, guarded write like `contractorUid`/`storeUid`) ← stamped at checkout (`store_screen` place-order, `= userProfileProvider.contact`) → projected onto `SysOrder.customerPhone` (`sys_orders._toSysOrder`). Surfaces: `_StoreOrderCard`/`_DeliveredCard` (`store_dashboard_screen`) · `_CourierJobCard` (`courier_dashboard_screen`) · `CourierDeliveryDetailSheet` · manager `_OrderRow`/`_OrderDetailSheet` (`manager_dashboard_screen`). Seed/legacy orders carry no phone → no buttons (ContactActions' empty-guard) = zero-regression. | ✅ |

- Gate: central-verify green — analyze 0 · 1645 tests · build · conformance 7/7 · required-tests present.
- **Known follow-up (Wave 3b):** `CatalogSettingsScreen._confirmReset` resets only `catalogSettings` — extend to also reset `appSettings`+`notifSettings` so the ported controls reset too.
- **Wave 3b (next, atomic):** delete `menu_dial_widget.dart` + the hamburger + dial state, now that the native surfaces are in place.

## Dial-distribution Wave 3b — menu-dial REMOVED (cutover · 9×9 fleet)
The menu-dial FAB is **gone** — all its content lives natively (catalog ⋮ · ProfileScreen via name-chip ·
extended CatalogSettingsScreen · store project-picker · per-persona dashboard access).
- **Deleted:** `lib/screens/menu_dial_widget.dart`, `lib/state/menu_state.dart` (drill providers).
- `home_shell.dart`: removed the hamburger leading button + the `OpenDial.menu` render block + the import.
- `dial_state.dart`: removed `OpenDial.menu`, `menuTabProvider`, `MenuTab`, and their `resetAllDials` lines (BS/search dials untouched).
- harness: removed `tabs:menu` + the `menuTabProvider`/`MenuTab` lines from `button:resetAllDials`.
- `CatalogSettingsScreen._confirmReset` now resets catalog+app+notif (covers the Wave-3a ported controls); copy → 'כל ההגדרות…'.
- **0 dangling code references** (byte-verified for all 8 dial symbols). Gate: central-verify green — analyze 0 · 1645 tests · build · conformance 7/7 · required-tests.
- Note: the search-dial (`OpenDial.search`) remains; the BS-dial was removed in Wave 4 (below).

## Dial-distribution Wave 4 — BS-dial REMOVED + cleanups (9×9 fleet)
The BS-dial (the old 5-persona radial FAB drill) is **gone**. A 4-persona parity audit (manager/store/courier/worker) confirmed every dial leaf is covered by the full dashboards — often as a SUPERSET (several dial leaves were placeholder 'בבנייה' toasts), all on the SAME engines.
- **Deleted:** `lib/screens/bs_dial_widget.dart` (~1670 lines) + 4 `test/bs_dial_manager_*` tests (their target was the deleted widget; manager logic/UI stays covered by `orders_engine_test` · `manager_dashboard_test` · `manager_dashboard_screen_test`).
- `dial_state.dart`: removed `OpenDial.bs` (+ dead `bsMode`), `bsDrillPathProvider`, the 7 `bs*LeafProvider`s + their `resetAllDials` lines (kept `activePersonaProvider`, `OpenDial.search`).
- `home_shell.dart`: removed the `OpenDial.bs` render block + the `bs_dial_widget` import. `role_picker_sheet.dart`: removed the dead `OpenDial.bs` fallback (kept terminal pop + `activePersonaProvider`).
- `store_/courier_stage_advance_engine_test.dart`: rewritten to drive the shared engine DIRECTLY (`storeAdvance`/`courierAdvance` → `ordersEngineProvider`) — order-flow coverage preserved without the widget. harness `buttons.dart`: dropped the BS test blocks.
- Cleanups: stale `menu_dial_widget` comments (site_hub/app_settings) reworded; `CatalogSettingsScreen` title `הגדרות קטלוג` → `הגדרות`.
- **0 BS-dial code references** remain (byte-verified). The legacy "👔 Manager BS-dial M1–M4" wiring docs below are now **historical** — the widget + its `bs_dial_manager_*` guards no longer exist.
- Gate: central-verify green — analyze 0 · tests green · build · conformance 7/7 · required-tests.

## Wave 5 — audit-driven dead-code + wiring (9×9 fleet)
Full-app completeness audit (6 area-auditors) → fix-fleet. The app proved largely well-wired; gaps were few.
- **Dead-code removed:** unused `_MiniPill` (notifications_screen + chats_screen); orphan seeds `kVoiceSamples` / `PlanItem`+`kPlanResult` from `ai_hub_logic.dart` (+ their assertions in `t3_ghi_rewards_ai_home_test`).
- **Wired:** Store **saved-cart-lists** — `cartListsProvider` was write-only; added a "רשימות" sheet (load a saved cart into the smart-cart + delete). Courier **split-shipment indicator** — `🚚×N` tag from `fulfillmentProvider.splitInto`, mirroring `_StoreOrderCard`.
- **Validation caught (kept honest):** `aiAlternatives()` is NOT dead (a live test exercises it) → KEPT. The store price-comparison row was ALREADY routed to `openPriceCompareSheet` (audit false-positive).
- **Deferred — need a refactor / new infra (R8: not forced, not invented):** autoStock portal tile → live OOS list (needs `storeOosProvider` moved to `lib/state/` to avoid a circular import); chat history-clear (needs a persisted `chatHistoryProvider` — history is local widget state today). See `_gaps.md`.
- Gate: central-verify green — analyze 0 · tests · build · conformance 7/7 · required-tests.

## Wave 6 — deferred items resolved + dead-data removed (9×9 fleet)
Closes the Wave-5 "deferred" list + D3.
- **autoStock → live OOS:** moved `storeOosProvider` (+ its notifier + key) to a shared `lib/state/store_stock.dart` (screens→state, no cycle); the `autoStock` portal tile now renders the live out-of-stock products from it (was the "יחובר בהמשך" stub).
- **chat history-clear:** added a persisted `chatHistoryClearedProvider` (mirrors the archive notifier); `_ChatPage` seeds empty once cleared; the 'מחיקת היסטוריה' row → confirm dialog → `clearAll()` (a light cleared-flag, NOT a full message store — R8).
- **D3:** deleted the dead `lib/data/settings_tree.dart` (~70-leaf `kSettingsGroups`/`walkSettings`, 0 consumers — superseded by the screen-based settings); detached its 2 harness sections in `test_harness/tests/settings.dart`. (Stale `knowledge/` doc refs → separate scrub.)
- Gate: central-verify green — analyze 0 · tests · build · conformance 7/7 · required-tests.

## Wave 7 — search-dial removed (the LAST FAB dial · 9×9 fleet)
The search-dial was the last FAB dial (menu + BS already gone). A reachability audit confirmed `OpenDial.search` was never set by any user action (no search FAB; only the dial's own close + the harness), and every tool it offered is live in the in-catalog `_SearchToolsRow` (better-wired). So the entire `OpenDial`/dial machinery is gone:
- **Deleted:** `lib/screens/search_dial_widget.dart`.
- `dial_state.dart`: removed `enum OpenDial`, `openDialProvider`, `enum SearchTool`, `searchToolProvider` + their `resetAllDials` lines (kept `activePersonaProvider`, `mainTabProvider`, `tabHeaderHiddenProvider`). **No FAB-dial state remains in the app.**
- `home_shell.dart`: removed the search-dial render + scrim + import; the cart FAB guard is now just `tabIndex != 3`. The real in-catalog search (`_SearchToolsRow`) + the `Icons.search` header button are untouched.
- harness `buttons.dart`: dropped the search-dial/OpenDial test blocks. `lib/widgets/dial.dart` kept (test-only, via `dial_test_helper`).
- **0 dial-symbol references remain** (byte-verified). Gate: central-verify green — analyze 0 · tests · build · conformance 7/7 · required-tests.

## Wave 8 — inert-switch honesty pass (D2 · 9×9 fleet)
A 3-auditor sweep (store/notif/chat settings) byte-verified (grep-proven) which persisted toggles have **no consumer** anywhere in `lib/` — written by the settings screen, read by nothing. 13 sections proved **fully inert** (every persisted field dead); they previously rendered as live switches with an active-count badge, misleading users.
- `_SectionTile` (in each of the 3 settings screens) gained an optional `underConstruction` flag → renders an honest ExpansionTile `subtitle:` **"בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות"** and **suppresses the count badge** (a dead section no longer claims N active settings). Additive only — `_activeCount`/`children` untouched.
- **Marked (13):** store — התראות חנות · ספקים מועדפים · שירות ולוגיסטיקה. notif — ערוצי קבלה · צליל ורטט · לפי תפקיד · סיכומים תקופתיים · פרטיות במסך נעול. chat — מדיה ושמע · גיבוי וייצוא · שפה ותרגום · שיחות עסקיות · ארכיון וניקיון.
- **NOT section-marked — MIXED/LIVE sections** (some toggles ARE genuinely wired; a section-level note would mislabel a working toggle): store תשלום/חשבוניות/סל/תצוגה/משלוחים/פרטיות; notif סוגי-התראות (4 live via `notifMutedSections`) + שעות-שקט (core quiet-hours IS consumed at `notifications_screen.dart`) + חשיבות; chat שיחות-וחיווי/התראות-שיחה/פרטיות(live delete)/בוט.
- **Full D2 pass (per-row honesty inside the MIXED sections):** a 3-auditor re-sweep re-proved the **29 dead toggles** inside them (store 17 · notif 8 · chat 4); each now carries an honest per-row marker **"בבנייה — עדיין לא משפיע"** (subtitle on `_SwitchRow`; a note under the label on `_RadioGroupRow`/`_InlineTextRow`/`_NumberRow`) and stays functional (still persists). A shared `_Inert` interface lets `_SectionTile._activeCount` exclude them, so each MIXED section's badge now shows only the **LIVE** count (e.g. סוגי-התראות 9→4). Live toggles untouched.
- Guard: `test/settings_honesty_test.dart` (6 tests) — asserts the section-level subtitle on all 3 screens, and expands a MIXED section per screen to assert the per-row marker renders.
- Gate: central-verify green — analyze 0 · tests · build · conformance · required-tests.

## Wave 9 — T7 cross-persona chat + server-ready (orders/customers) + P1 colors (9×9 fleet)
The three remaining tracks, built/wired in parallel (disjoint files), one verified gate.

### T7 — cross-persona chat (the one missing feature)
The chat is now a shared, persisted, cross-persona engine (was a contractor-only `const _kThreads` + bot). A store message is seen by the contractor and vice-versa; each persona sees ONLY its own threads.
- `state/sys_chat.dart` (NEW): `ChatEngineNotifier` over `ChatThread`/`ChatMessage`, persist `bs.sys-chat.v1` (worker_tasks H2 pattern: `_loaded`-guard + persist-flag). `send(threadId, fromRole, text)` (visible to both participants), `threadsFor(role)` (data isolation). `chatEngineProvider`.
- `data/chat_seeds.dart` (NEW): cross threads (contractor↔store/courier/manager · store↔courier) + a bot thread (auto-reply kept).
- `chats_screen.dart`: `ChatsScreen({persona = contractor})` — the thread list + `_ChatPage` read the engine via `threadsFor(persona)`; sending calls `send(.., persona, ..)`. UI reused verbatim (emoji/camera/archive/honest-stubs/bot). Backward-compatible: `const ChatsScreen()` still serves the contractor home-shell tab.
- 🔒 Isolation (SPEC §2.5): a non-contractor persona opens a STANDALONE Scaffold (own "שיחות" AppBar + back→pop) — no home_shell, no role_picker, no cross-board nav.
- Wiring (CH-4): store/courier → `persona_portal` (`_ChatEntryRow`); worker → `worker_app_screen`; manager → `manager_dashboard_screen` — each pushes `ChatsScreen(persona:)` standalone. Contractor via `updates_screen`.
- Guard: `test/sys_chat_test.dart` — cross-persona visibility · restart persistence · isolation.

### server-ready (Repository seam) — orders + customers wired (T6.2/T6.3)
- `data/repositories/orders_local.dart` + `customers_local.dart` (NEW): local impls of the existing interfaces, delegating to the live engine; `seed()` exposes the const genesis acyclically.
- `orders_engine.dart`: `ordersEngineProvider` sources its seed via `ordersRepositoryProvider.seed()`; `managerCustomersProvider` derives via `customersRepositoryProvider.aggregate(orders)` (still watches the engine). Behavior byte-identical.
- Guard: `test/repositories_test.dart`. The other 4 domains (finance/site/stock/catalog) read their seeds directly across many screens (no single owning provider) → T6.3 deferred (R8 — not forced); their T6.1 interfaces remain.

### P1 polish — colors → BsTokens
- 20 raw `Color(0x)` literals → `BsTokens` (19 in `widgets/chain_diagram.dart` + 1 in `theme/app_theme.dart`); 14 new exact-hex tokens in `theme/tokens.dart` (chain* palette + `bgLightAlt`). Screenshot-identical.

Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

## Wave 10 — server-ready extension: route catalog/site/stock through their repositories (T6.3 · 9×9 fleet)
Extends the server-ready seam to the cleanest of the remaining domains (Wave 9 did orders/customers), all behavior **byte-identical** (the verified 29/29 hubs read the same consts, now via the repos).
- **catalog** — `data/repositories/catalog_local.dart` (LocalCatalogRepository — returns `kCatalogProducts`/`kSmartProducts`/`kCatalogCats` verbatim). Routed **21 ref-scoped reads** via `catalogRepositoryProvider` in `catalog_screen.dart` (19) + `lipskey_products_screen.dart` (2).
- **site** — `site_local.dart` (LocalSiteRepository). Routed `kProjects` via `siteRepositoryProvider` in `budget_screen.dart` (site rows) + `projects_engine.dart` (seed — orders-idiom, acyclic).
- **stock** — `stock_local.dart` (LocalStockRepository). `stock_screen.dart` sources `kStockDemo` via `stockRepositoryProvider` (11 items unchanged).
- **Architectural ceiling (reported — R8, NOT forced):** the finance/site **hub screens** + the catalog **pure-logic** (`category_division`/`pressure_drop`/`system_division`) + `finder`/`departments` read their consts in non-Consumer contexts (StatelessWidget / top-level functions, no `ref`). Routing them would require converting the verified 10/10 hub screens to ConsumerWidgets (structural change → regression risk). Their T6.1 interfaces + T6.2 local impls stand; that provider-rewire needs a dedicated screen-restructure pass. (`finance_local` removed — it had no safe consumer.)
- **Net server-ready:** orders · customers · catalog · site · stock routed through repos; finance + the pure-logic catalog paths remain const-bound by architecture.
- Guard: mutation-verified; gate green.

Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

## Wave 11 — server-ready 6/6: close finance + catalog pure-logic via a global repo accessor (T6.3 · 9×9 fleet)
Closes the architectural ceiling Wave 10 flagged. The remaining const reads sat in non-Consumer contexts (top-level functions / StatelessWidgets, no `ref`), so a Ref-free **global repo accessor** routes them — no signature changes, no verified hub restructured.
- `finance_local.dart`: added a const `LocalFinanceRepository.constData()` + global `financeRepo()` (Ref-free) for the budget consts; `activeRevenue()` stays Ref-based via the provider. `finance_hub_sheets.dart`'s `_open*` functions + `_FinReportView` now read budget data via `financeRepo()` — the 10 verified finance values byte-identical (15000/9840/66 · ₪12,800 · ×1.42 · 80/90/100 · …).
- `catalog_local.dart`: const `_kCatalogRepo` + global `catalogRepo()`; the provider returns the same instance. The pure-logic readers — `category_division` · `system_division` · `pressure_drop` (colleague's file — only the catalog read touched, their flow logic intact) · `finder_screen` · `departments_screen` · `card_projects` — now read via `catalogRepo().allProducts()`/`allSmartProducts()` (byte-identical; dead `polyroll_catalog` imports dropped).
- **R8 exception (honest):** `pressure_drop.dart`'s `kLipskeyCatalog` read (a Lipskey-only const, not the unified catalog — no matching interface method) left as-is.
- **Net server-ready now 6/6:** orders · customers · catalog · site · stock · finance all route through their repositories. A backend swap is a drop-in repo replacement.
- Guard: mutation-verified; gate green.

Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

## W1 — ליטוש-באגים (workbook `POLISH.md` §5)
### #1 בועות-צ׳אט RTL — `chats_screen.dart` — 2026-06-08
- helper חדש `chatBubbleAlignment({required isMe})` (top-level) — מנתב צד-בועה: own→start (ימין ב-RTL), other→end. `_Bubble` (הודעה) + `_TypingBubble` (הקלדה=incoming) שניהם דרכו. רדיוסי-הזנב → `BorderRadiusDirectional` (start/end) כך שהזנב עוקב אחר הצד.
- מתקן היפוך מול spec `sys_chat.dart §1`. guard: `chat_bubble_side_test` (4) + mutation-verified. אין שינוי state/ניווט.
### teal→כתום (W0) — `site_hub_screen.dart` · `finance_hub_sheets.dart` — 2026-06-08
- 3 consts מקומיים שהחזיקו teal **בטעות** (`_kBrand`/`_kBrandDark` ב-site · `_kBrandTeal` ב-finance — ההערה ב-site אף אמרה "orange brand") → `BsTokens.brand`/`brandDark`. ~12 שימושים flipped לכתום. status-teals אחרים (manager 'new' · lipskey accents) מחוץ-לסקופ.
### microcopy (W0) — `search_index` · `notif_settings_screen` · `catalog_settings_screen` — 2026-06-08
- `מנהל מערכת`→`מנהל המערכת` (search_index ×2 · notif_settings — האחדה ל-canonical `personas.dart`) · `AI`→`בינה מלאכותית` (catalog_settings ×2). אפס שינוי-לוגיקה. tests של 'מנהל המערכת' (manager_dashboard/widget) כבר על ה-canonical — לא נשברו. `mm`→`מ"מ` נדחה לפס נפרד.
### #+-עגלה — `lipskey_products_screen` — 2026-06-08
- `_ProductRow._addToCart` השתמש ב-`.add()` (append) → על ListView-recycle (כש-`_open` טרי אך המוצר כבר בעגלה) tap על `+` יצר **שורה כפולה**. → `setQtyForKey` (אידמפוטנטי לפי productKey), כמו add-path של grid-card (507) ו-`_setQty`. guard: `lipskey_plus_no_dup_test` (2). אין שינוי-API.
### #perf — install_studio blueprint rebuild-per-frame — 2026-06-08
- `AnimatedBuilder` בנה את כל ה-Column (header/canvas/dock) **בתוך ה-builder** → כל הצומת נבנה-מחדש בכל tick (60fps). → התוכן ל-`AnimatedBuilder.child` (נבנה פעם-אחת) + `RepaintBoundary` סביב ה-CustomPaint. אותו עץ-ויזואלי, רק ה-painter מצוייר מחדש. אין שינוי state/לוגיקה.
### #weld-key — תזמון-ריתוך PPR נעלם — `lipskey_product_sheet` — 2026-06-08
- חיפוש תוכנית-הריתוך (`_kPprWeldPlan[dn]`) קרא רק `dims['dn נומינלי']`, אך רוב צינורות ה-PPR של פולירול (supply+faser) נושאים את הקוטר תחת `'קוטר חיצוני'` → null → התזמון נעלם. → helper `pprWeldDn` עם fallback ל-`'קוטר חיצוני'`. guard: `ppr_weld_dn_test` (4) + mutation-verified. אין שינוי API/state.

## Wave 12 — deep bug-hunt fixes + protocol hardening (9×9 fleet)
A deep audit (5 semantic/integration lenses — business-logic/RBAC · e2e-flow · edge-cases · dead-interactions/isolation · races) found bugs the surface/regression gates structurally couldn't (features never wired right · cross-feature seams · races). Fixed:
- **HIGH — cart-per-project (now works):** `projects_screen._switch` called `switchProject` without `outgoingCart` and discarded the returned snapshot → the cart never swapped (every project showed 0 items). Now passes `outgoingCart: ref.read(smartCartProvider)` + applies the snapshot via new `SmartCartNotifier.loadSnapshot`.
- **HIGH — §2.5 isolation hole:** the shared `ProfileScreen` exposed "🔄 החלפת תפקיד" → role-picker from inside every non-contractor persona. Gated the link on `activePersonaProvider == null` (contractor only).
- **MED — plumbing safety:** the vacuum-breaker/backflow check missed `'ציוד גן'` (garden hose-connectors — supply parts needing a hose-bibb vacuum-breaker). Widened the trigger to `'ברזי גן' || 'ציוד גן'` (`install_engine.dart`).
- **MED — data-loss:** `saved_projects._persist` had no try/catch (awaited from an `async void` rename) → silent loss; wrapped it.
- **MED — cross-engine load-clobber (WON'T-FIX, documented):** the theoretical "approve on seed before `_load` resolves → double-advance" is a sub-microtask, low-reachability window. An `if(!_loaded) return;` guard on `approve`/`advance` was TRIED but **reverted** — it no-ops a legitimate SYNCHRONOUS mutation (construct-then-act), which the persistence regression test correctly caught. The existing per-notifier `_loaded` guard (on `_load`/`set state`) + the persisted-status check (`status != 'review'`) already prevent the double-advance after a real restart. Cure was worse than the disease.
- **MED — load-clobber (4 notifiers):** `store_stock` · `smart_project_engine` · `saved_projects` · `card_projects` lacked the `_loaded` guard (WIRING earlier claimed the load-clobber race "fixed" — it wasn't, for these); added the guard mirroring `cart_lists_state`. Closes that spec-divergence.
- **Guards:** `test/deep_fix_regression_test.dart` (cart round-trip · 'ציוד גן' vacuum-breaker · profile isolation). **Protocol hardening:** `test/state_loaded_guard_test.dart` — a source-scan gate asserting every persisting notifier that overrides `set state` carries `bool _loaded` (12 guarded / 0 offenders) → a future un-guarded persisting notifier now fails `flutter test`. (The behavioral/invariant gate class the build was missing.)
- **HIGH — order-site decoupled (RESOLVED):** product decision = **the projects engine is canonical**. Checkout's `cartProjectProvider` now defaults from `activeProjectProvider` (watches it); the site-picker lists `projectsProvider` projects + `'ללא פרויקט'`; the "+ הוסף" add-flow routes to the engine's `addProject`; both post-order/clear resets follow the active project. `storeProjectsProvider` retired (vestigial — 0 live readers). An order's `site` now follows the active project. Guard: `test/order_site_canonical_test.dart` (5 cases); `contractor_checkout_engine_test` updated to the canonical site name.
Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

### #₪-truncation — `store_screen` saved-cart reload (W1) — 2026-06-08
- `_loadItem` שיחזר שורה-שמורה כ-`brandPrice: total ~/ qty` → איבד עד (qty-1) ₪ כשה-total לא מתחלק ב-qty (₪340@3→339). → helper top-level `savedLineReconstruct` ששומר total מדויק (מתחלק→per-unit; אחרת qty=1 ב-total מלא). guard: `saved_line_reconstruct_test` (4) + mutation-verified.
### #camera — מסך-שחור בהרשאה-נדחית (W1) — 2026-06-08
- 2 ה-MobileScanner (`camera_sheet` · `barcode_scanner`) היו בלי `errorBuilder` → מסך-שחור כשהמצלמה לא עולה (הרשאה נדחית/אין מצלמה). → `errorBuilder` → widget משותף `cameraPermissionErrorView` (`lib/widgets/`, מקור-אחד לקופי המאושר). guard: `camera_error_view_test`.

## Round 3 — deeper bug-hunt fixes (data integrity / RTL / UX · 9×9 fleet)
A 3rd, DEEPER audit (data-integrity · RTL/BiDi · error/empty-path lenses) caught bugs the prior rounds missed:
- **HIGH×2 — lipskey category-key mismatch (52 products):** `lipskey_smart_data.dart` taxonomy keys `'אטמים אומים ופקקים'` / `'מחסומים (סיפונים) גלויים'` didn't match the real products' `categoryHe` (`'אטמים ופקקים'` / `'מחסומים גלויים'`), so `lipskeyAccFor`/`lipskeyStagesFor` returned `[]` → 17+35 products silently lost their curated accessories + install-stages + showed dead tiles. Renamed all 3 occurrences each. Guard: `test/lipskey_category_keys_test.dart` (non-empty + negative-guard on the old keys; mutation-verified).
- **MED×2 — vanishing catalog leaves:** `catalog_tree.dart` leaves `קולטי גג` + `אביק לאמבט ואגנית` set a `lipskeyCategory` matching 0 products → "0 מוצרים" + the leaf vanished under a water-system filter. Dropped the bogus `lipskeyCategory` (each has a working `smartKey` that drives it).
- **MED — CDN image placeholder:** `product_images.dart` `productImage` now has a default `frameBuilder` (faint grey skeleton + fade-in) so slow CDN loads don't show blank boxes (one-point fix, covers all 15 call-sites).
- **Convergence (already fixed via rebase):** the FX-equation RTL reorder (`finance_hub_sheets`, wrapped LTR) + the wrong-direction `Icons.arrow_back` (→ `arrow_forward`, 11 sites) were independently fixed in the parallel agent's RTL-polish pass.
- **Deferred (low-value / not cleanly fixable):** lipskey spec-string Latin-reorder (a `_StripDef.value` data field rendered through a shared mixed-direction `Text` — per-value bidi-isolation needed; cosmetic); voice "listening" indicator (a real STT-feedback feature, not a one-liner); 7 LOWs (emoji/SKU order, `₪-` sign, breadcrumb arrow, badge side, zoom-error, partial-load notice).
Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

### #bind-color — W3 batch 1: inkLight ×150 — 2026-06-08
- `Color(0xFF1A1A1A)` → `BsTokens.inkLight` ב-17 קבצי-screens (token-equal · אפס שינוי-עין · imports נוספו). guard: `color_token_ratchet_test` (down-only). batch-1 של בינדינג-הצבע (#3); re-based על tip-הצי `d8b1089` אחרי collision.

### #a11y-contrast — "ניגודיות גבוהה" מכסה foregrounds-של-מותג — 2026-06-08
- ה-toggle `catalogSettings.highContrast` היה **חלקי**: `app_theme` נגע רק בטקסט-התמה (`ink`/bodyMedium), אך לא ב-literals ברמת-widget — FAB לבן-על-כתום (2.61:1), מחיר/online ירוק-על-לבן (2.28:1), ו-~40 chip/CTA/badge פעילים (לבן-על-כתום). נשארו לא-קריאים גם כש-HC דלוק.
- **היסוד:** `BsSemanticColors` ThemeExtension ב-`app_theme.dart` נושא 2 צבעים תלויי-HC, נקראים דרך top-level `bsOnAccent(context)` (foreground על מילוי-מבטא) ו-`bsSuccess(context)` (ירוק-טקסט על בהיר). רגיל → `white` / `#22C55E` ; HC → `BsTokens.inkLight` (6.7:1 על כתום) / `BsTokens.successDark`=`#15803D` (5.0:1 על לבן). + `floatingActionButtonTheme.foregroundColor` תלוי-HC. token חדש: `BsTokens.successDark`.
- **רולאאוט:** ~32 foregrounds ב-22 קבצים → helpers (FAB · lens-chip · מחיר · online-badge · dial · וכל ה-active pill/chip/CTA/badge ב-catalog/store/manager/store_dashboard/worker/tasks/chats/stock/projects/profile/rewards/departments/finance/persona/regression). **המצב הרגיל מוכח שלא משתנה** (helper מחזיר white/#22C55E כש-HC כבוי) → אפס סיכון לברירת-המחדל של הקולגה. ratchet-clean (משתמש ב-`inkLight`, לא raw literal).
- **נדחה לקומיט נפרד:** `_RunButton` (regression · dev) · `_ApprovalButton` textColor-param (manager_dashboard) · a11y לא-צבעוני (tooltips/semanticLabels/Dynamic-Type).
- guard: `test/a11y_contrast_theme_test.dart` (5 · normal=white/#22C55E · HC=inkLight/successDark · helpers resolve via Theme).
Gate: analyze 0 · a11y_contrast(5) + color_token_ratchet green · מוזג נקי (0 conflicts) על tip-הקולגה `5269b37`.

### #a11y-noncolor — Dynamic-Type + tooltips + image-semantics — 2026-06-08
- **Dynamic-Type:** `main.dart` קודם דרס את scaler-ה-OS (`TextScaler.linear(textScale)` קבוע · cap 1.15×) → התעלם לגמרי מהגדרת גודל-הטקסט של iOS/Android. עכשיו מקפל את ה-OS scaler עם העדפת-האפליקציה ו-clamp ל-`[0.85, 1.35]` (תקרת-בטיחות-layout, ניתנת להעלאה אחרי QA-ויזואלי). משתמשי low-vision מקבלים הגדלה אמיתית במקום ננעלים על 1.15.
- **Tooltips:** 13 `IconButton` icon-only קיבלו `tooltip:` עברי (גם = semantic label) — `camera_sheet` (סגור/פלאש ×3) + `chats_screen` (חזרה/אפשרויות/וידאו/שיחה/מצלמה/צירוף/אימוג׳י/נקה ×10).
- **Image semantics:** `product_images.productImage` → `excludeFromSemantics: semanticLabel == null` (תיקון נקודה-אחת, כל 15+ call-sites): תמונת-מוצר לא-מתויגת (שם-המוצר מוצג כטקסט לידה) הופכת דקורטיבית → screen-reader לא מקריא "תמונה" חסר-משמעות; caller שמעביר `semanticLabel` (hero) מקבל הקראה.
- **HC straggler:** `regression_panel._RunButton` (dev) → `bsOnAccent`.
- **לא שונה במכוון (false-positive):** `_ApprovalButton` "אשר" = לבן-על-ירוק-כהה `#1F8A4C` (כבר ~4.5:1) — bsOnAccent היה שובר אותו ב-HC (כהה-על-כהה).
Gate: analyze 0 · a11y_contrast(5) green · tooltips/semantics additive.
### #smart-home — מחיקת סקשן 'הכל' + מסך-בית חכם + מצב-היכרות — `catalog_screen`/`smart_home_screen`/`home_content_reorder`/`help_target` — 2026-06-09
- **מחיקת 'הכל' (per deletion protocol — MASTER_PROTOCOL חלק כ):** סקשן הקטלוג 'הכל' הוסר — הפיל-הקבוע, הניתוב, ברירת-המחדל, וה-classes היתומים `_AllOverview`/`_OverviewBlock`/`_OverviewRow`/`_OverviewEmpty`/`_openStudio` (256 שורות; grep אישר שאין callers אחרים). `catalogSectionProvider` ברירת-מחדל עכשיו `'בית'` (הפיל-הקבוע הראשון = הבית-החכם). ה-finder עבר ל-`'מאתר'` (`if(active=='מאתר') return FinderScreen()`). כל ה-fallbacks (`activate`/hide/delete) → 'בית'; home_shell טאב-בית → 'בית'. `_findCatalogTreeNodeByTitle`/`_CatalogRow` נשמרו (בשימוש).
- **`SmartHomeBody`** (smart_home_screen.dart) = נחיתת 'בית': מקטעים ניתנים-לסידור דרך `smartHomeSectionFor(HomeSection)` הקורא `homeContentOrderProvider` — מחלקות (`DepartmentsScreen.departments`, 2 שורות + "עוד") · 🌳 עץ-חכם (`kSmartProducts` + תמונות `productImage`) · מסלול-עבודה · כלים-מהירים (`openScanPlanSheet`/`StockScreen.route`/`openSiteHub`) · תכנון-חיבור (`InstallStudioScreen`) · מועדפים (`productFavoritesProvider`) · הזמנות-אחרונות (`sysOrdersProvider`). אין מחירים מומצאים (עץ-חכם → "מחיר לפי ספק").
- **`home_content_reorder`** ("סידור מסך הבית", נגיש מהגדרות→תצוגה דרך `HomeContentReorder.route()`) מציג עכשיו את אותם מקטעים דרך `smartHomeSectionFor`; ה-preview-widgets הישנים הוסרו (449 שורות) + imports יתומים. `kHomeSectionMeta` כותרות עודכנו (מחלקות/עץ-חכם/הזמנות-אחרונות).
- **מצב-היכרות (#30):** `helpModeProvider` (help_mode.dart) + `HelpTarget`/`HelpToggleButton`/`HelpModeBanner`/`HelpModeScaffold` (help_target.dart). 💡 ב-home app-bar = toggle; לחיצה-ארוכה = `showIntroTour`. במצב פעיל: `HelpModeScaffold` דוחף באנר מעל התוכן + `HelpTarget` עוטף אלמנט → לחיצה פותחת בועת-הסבר (Overlay, זנב מעל/מתחת אוטומטי). מחובר: בית (📷, סל-FAB), מסך-פתיחה (5 אלמנטים), מקצוע, שקופיות.

### #a11y-round3 — Semantics labels + round-3 deferred cosmetics — 2026-06-08
- **Semantics** (screen-reader) ל-7 אלמנטים אינטראקטיביים icon-only שלא הוקראו: catalog (נקה-סינון · בטל-breadcrumb · מידע-אביזר · `_MiniQtyBtn` הוסף/הפחת-כמות) · lipskey_product_sheet (סגור-תמונה-מלאה) · install_studio (`_stepBtn` הוסף/הפחת · הסר-מוצר). אדיטיבי (`Semantics(button,label)`), בלי שינוי-גודל (נמנע מסיכון-layout).
- **סימן ₪-** (budget `_fmt`): סכום שלילי הוצג `₪-3,150` → עכשיו `-₪3,150` (הסימן לפני הסמל).
- **חץ-breadcrumb** (finder): מפריד `›` (הצביע לכיוון הלא-נכון ב-RTL) → `‹`, תואם catalog/lipskey.
- **zoom errorBuilder** (lipskey_products `_openImage`): תמונת-zoom שנכשלת הציגה קופסת-שבר → `errorBuilder` עם emoji-fallback (×2).
- **התראת טעינה-חלקית** (catalog `_SearchResultsList`): כשתוצאות-החיפוש נחתכות ל-40 → footer "מציג 40 תוצאות ראשונות — צמצמו את החיפוש".
- **נדחה:** bidi-spec/brand (FSI מזהם מחרוזות + שובר `find.text` → צריך impl נקי דרך `textDirection`); ניגודיות-טקסט-משני (`888888`/`AAAAAA` ~120 אתרים — שינוי-עין בתחום-הצבע של הקולגה, דורש תיאום).
Gate: analyze 0 · full suite 1737/1737 green.
### #smart-home-settings — סנכרון מסך-הבית עם הגדרות-התצוגה + תיקון גלילה — `smart_home_screen` — 2026-06-09
- **גלילה הפוכה (RTL):** הוסר `reverse: true` מ-2 ה-ListView האופקיים (עץ-חכם + הזמנות) — ב-RTL ה-Directionality כבר מסדר ימין-לשמאל, ה-reverse הפך פעמיים. עכשיו גלילה טבעית.
- **סנכרון-מלא להגדרות-התצוגה** (`catalogSettingsProvider` + `Theme` + `MediaQuery`): הבית כבר לא קבוע-מראה.
  - ערכת-נושא (light/dark) + ניגודיות-גבוהה → `_pal(context)` קורא `Theme.of(context).colorScheme` (במקום `BsTokens.cardLight/inkLight` קבועים).
  - `gridColumns` → `crossAxisCount` במחלקות/מועדפים (GridView עם `SliverGridDelegateWithFixedCrossAxisCount` + `mainAxisExtent` קבוע → עמודות משתנות, גובה-אריח קבוע).
  - `imageSize` (small/med/large) + `compactMode` → `_Metrics.cardW/rowH` (גודל כרטיסים/תמונות).
  - גודל-טקסט → `MediaQuery.textScalerOf` מכפיל גבהים (`rowH`/`tileH`) → טקסט גדל בלי לקצץ.
  - הנפשות-מופחתות → הבית חסר אנימציות (אין מה להפחית).
- אומת חי: gridColumns=2 → 2 עמודות בגובה תקין. אין שינוי API/לוגיקה אחר.
### #sheet-close-x — כפתור X (סגור) ל-3 sheets ה-AI + מירכוז אריחי AI-Hub — `contractor_tools_sheets`/`ai_hub_screen` — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #38/#40/#48)
- **כפתור סגירה מפורש** ל-3 ה-modal-sheets (`openCheaperAlternativesSheet`/`openScanPlanSheet`/`openPriceCompareSheet`): נוסף widget משותף `_SheetHandle` (Stack: ידית-הגרירה במרכז + `Align(centerLeft)` עם `IconButton(tooltip:'סגור', Icons.close)` → `Navigator.of(context).pop()`). מוקם פעם-אחת בכל sheet, ובמסך-הסריקה רץ מעל ענפי-הפאזות → ה-X = "סגור הכל" בכל הפאזות, נפרד מ-"סרוק תוכנית אחרת" (back-step פנימי). RTL: visual-top-left; 48dp; `Semantics(button,label:'סגור')`. אידיום זהה ל-`camera_sheet.dart:324`.
- **מירכוז AI-Hub:** `AiFinTile` Column → `CrossAxisAlignment.center` (אימוגי+שם+תיאור ממורכזים).
- Gate: analyze 0 · `test/sheet_close_test.dart` 3/3 (פתח→find.byTooltip('סגור')→tap→sheet נעלם, התנהגות מוכחת).
### #c2-declutter-honesty — declutter תפריט ⋮ + הגדרות-הוגנות + מסך-בקרוב — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #34/#53/#51/#29)
- **declutter תפריט ⋮ הבית** (`home_shell` `_CatalogMenuButton`): 9→2 פריטים. הוסרו 7 (כל אחד אומת נגיש ממקום חי אחר): scan_plan/alternatives (אריחי AI-Hub) · price_compare (Store→services grid `_kServices[5]`) · stock/site_tasks/favorites (בית→"כלים מהירים"/מקטע-מועדפים) · home_content (הגדרות→"סידור מסך הבית"). נשארו `ai_hub`→`AIHubScreen.route()` · `settings`→`CatalogSettingsScreen.route()`. הוסרו 4 imports שהפכו לא-בשימוש (contractor_tools_sheets·site_hub_screen·stock_screen·home_content_reorder). תפריטי chats/notifications/store לא נגעו.
- **הגדרות הוגנות** (`catalog_settings_screen`): `_RadioOption<T>` חדש (icon/labelFontSize/enabled+badge 'בקרוב'). שפה: العربية+English → `enabled:false` + 'בקרוב' (עברית פעילה; אין זיוף החלפת-שפה). סוג-תצוגה: רשת→`Icons.grid_view`, רשימה→`Icons.view_list_rounded`. גודל-תמונות: תוויות בגדלים 13/15/18. "מיון ברירת מחדל": נשאר HONEST (placeholder) — `CatalogSettings.sortDefault` נשמר אך אין consumer (הקטלוג ממיין דרך Prod-sort נפרד) → לא חוּוט-בזיוף.
- **מסך "בקרוב"** (NEW `coming_soon_screen.dart` · `ComingSoonScreen.route(profession)`): RTL, 🚧+'בקרוב'+'התוכן עבור <מקצוע> בהכנה'+כפתור '‹ חזור לבחירת מקצוע'. `profession_screen` `pick()`: `kComingSoonTrades={'חשמלאי','קבלן שיפוצים'}` → push ל-ComingSoon; 'אינסטלטור' (plumber) ללא שינוי.
- Gate: analyze 0 errors (8 infos/warnings non-blocking) · `test/coming_soon_screen_test.dart` 1/1 + onboarding/profile ירוקים.
### #c3-dept-grid+alts-search+plan-select — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #33/#37/#41)
- **מחלקות = רשת קבועה** (`smart_home_screen` `_Departments`): נותק מ-gridColumns. `static const _deptCols=2`; `take(_deptCols*2-1)` (3 מחלקות + "עוד"); `crossAxisCount:_deptCols`. `_Favorites`/מוצרים עדיין `m.cols` (הגדרת-התצוגה משפיעה רק עליהם).
- **חיפוש-מוצר בחלופות זולות** (`_CheaperAlternativesSheet`→StatefulWidget): `_searchCtl`+`_query`; build סורק את כל ה-cross-catalog (לא top-5 חתוך) ומסנן case-insensitive לפי product/recName/altName; ריק→רשימה אוטומטית; אין-התאמה→'לא נמצאו חלופות תואמות.' (ריק→'אין חלופות זולות כרגע.' verbatim).
- **בחירה-ידנית בסריקה** (`_ScanPlanSheetState`): `Set<String>? _selected` (key 'scan:<plan>:<name>', seed all-selected בתוצאות, reset ב-re-scan). Checkbox לכל ScanItem עם stores. כפתור-חכם: allSelected→'אשר הכל — הוסף N'; אחרת→'אשר את הבחירה — הוסף M'; disabled ב-0. `_addToCart` מסנן `scanPlanCartLines` ל-_selected (null→הכל); שלב 'לאן לשלוח?'+smartCartProvider נשמרו.
- Gate: analyze 0 errors · `test/plan_select_alt_search_test.dart` 2/2 + scan_plan/cheaper_alternatives/sheet_close ירוקים.
### #c4-profile-card — הרחבת פרופיל + כרטיסייה בצ'יפ-השם — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #55)
- **שדות פרופיל** (`state/user_profile.dart`): נוספו `address`(כתובת/אזור) + `businessId`(ח.פ./עוסק) — דרך copyWith/toJson/fromJson(default '')/update(). registered-flip (`registrationValid` על name+contact) ללא שינוי. אין שדה לוגו (נדחה — דורש image-picker).
- **עורך** (`profile_screen.dart`): 2 שדות `_Field` חדשים (כתובת · ח.פ./עוסק מורשה) מתחת לטלפון/אימייל, נשמרים ב"שמור" הקיים (`_save` הורחב).
- **כרטיסיית-פרופיל** (`home_shell.dart`): צ'יפ-השם בכותרת → `showProfileCard()` (showModalBottomSheet · `_ProfileCard` ConsumerWidget · RTL · BsTokens): avatar+שם + X(סגור) + שורות-פרטים לא-ריקות (מקצוע/כתובת/ח.פ./contact — ריקות מושמטות) + FilledButton 'ערוך פרופיל' → ProfileScreen.route(). העורך נגיש רק דרך הצ'יפ; שאר נתיבי-הכניסה ל-ProfileScreen ללא שינוי.
- Gate: analyze 0 errors · `test/user_profile_fields_test.dart` 4/4 + profile/deep_fix/onboarding ירוקים.
### #c5-cart-fab — כפתור-סל צף + משוב מיידי, בלי קפיצה-לטאב — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #47)
- **CartFab ציבורי** (`home_shell.dart`): `_CartFab`→`CartFab` + פרמטר `popFirst=false`; `openCart()` עושה `maybePop()` קודם רק כש-popFirst (בית = default ללא-pop). מראה/אנימציה/ספירה ללא שינוי.
- **AI-Hub** (`ai_hub_screen.dart`): `floatingActionButton: cartHasItems ? const CartFab(popFirst:true) : null` ב-AIHubScreen וב-_AIFeatureScreen (route דחוף → pop ואז cart-tab). מוצג רק כשהסל לא-ריק (`smartCartProvider`).
- **בלי קפיצה כפויה** (`contractor_tools_sheets._addToCart`): הוסרו `mainTabProvider=3`+`storeSectionProvider=cart` — המשתמש נשאר בהקשר, ה-CartFab החי מציג את הספירה החדשה = משוב מיידי. הוספה-לסל+pop+toast+"לאן לשלוח?" נשמרו. הוסרו imports שהתייתמו (store_screen/dial_state).
- Gate: analyze 0 errors · widget_test (shell boots) + scan/budget/sheets/plan-select ירוקים (28/28).
### #c6-loadrace — תיקון load-race ברישום-חוזר — `state/user_profile` — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #24)
- **הבאג:** ה-provider עצל → `UserProfileNotifier` נבנה בדיוק כש-`register()` נקרא; ה-`_load()` האסינכרוני (SharedPreferences) נפתר *אחרי* `register()` → אם קיים פרופיל ישן (רישום-חוזר), `_load` דרס את הקלט הטרי בערכים הישנים.
- **התיקון (ממוקד):** שדה `bool _userTouched=false`; `_load()` עושה `if (_userTouched) return;` (אחרי `if (raw==null) return;`) → לא דורס אחרי כתיבת-משתמש. כל מתודה מוטטת (register/continueAsDemo/setProfession/update) מסמנת `_userTouched=true` בראשה. אין שינוי API/סמנטיקה; registered-flip ללא שינוי.
- Gate: analyze 0 errors · `test/profile_loadrace_test.dart` (משחזר: prefs ישן + register טרי → הטרי שורד) + onboarding/profile/user_profile_fields ירוקים.
### #async-race-guards — guard load-race ל-6 notifiers (נחיל 9×9 קנוני, ריצה אוטונומית) — 2026-06-09
- **מקור:** האודיט-הקנוני (עדשת async-race) אימת 6 StateNotifiers עם אותו load-race כמו #24 — provider עצל, `_load()` אסינכרוני נפתר אחרי מוטציית-משתמש ודורס אותה.
- **התיקון (אותה תבנית #24):** שדה `bool _userTouched=false` + `if (_userTouched) return;` ב-`_load()` (אחרי קריאת-prefs, לפני השמת-state) + סימון `_userTouched=true` בראש כל מתודה מוטטת:
  - `card_filter_state` (setType/setSize/clear · med) · `card_acc_state` (setSelected/setQty · med) · `product_favorites` (toggle · med)
  - `recent_searches` · `recently_viewed` · `offline_cache` (low).
- אין שינוי פורמט-persist/provider/חתימות.
- Gate: analyze 0 errors · `test/state_loadrace_guards_test.dart` 3/3 (משחזר race לכל med-notifier → המוטציה שורדת) + `profile_loadrace_test` ירוק.
### #a11y-fleet — Semantics/Tooltip לכפתורי-אייקון ב-10 מסכים (נחיל 9×9 קנוני, ריצה אוטונומית) — 2026-06-09
- **מקור:** האודיט-הממצה (עדשת a11y) — כפתורי-אייקון/glyph בלבד (InkWell/GestureDetector עם Icon קטן) בלי Semantics/Tooltip. תוקנו ע"י נחיל-fix (14 מסכים, 10 עם תיקון אמיתי), **25 תיקונים**.
- **דפוס (תואם #a11y-round3):** עטיפה אדּיטיבית `Semantics(button:true,label:HE)` + `Tooltip(message:HE)` — **בלי שינוי-גודל/layout** (round-3 נמנע מ-resize של פקדים צפופים → סיכון-overflow). תוויות-עברית מדויקות (הוסף לסל/הסר מהסל/הוסף כמות/סגור/חזרה/בטל/נהל קטגוריות...).
- מסכים: lipskey_products(4)·catalog(4)·lipskey_product_sheet·store·install_studio·camera_sheet·home_shell·lipskey_brand·notifications·smart_home. fixers דילגו על Material-defaults (IconButton/TextButton כבר ≥48dp) ועל טקסט-נושא-עצמו.
- Gate: analyze 0 errors. 48dp-enlarge נדחה מכוון (סיכון-layout) — תוסף Semantics הוא הריפוי המאושר. אימות-פיקסל-חי בתור.
### #a11y-rtl-finish — השלמת a11y/rtl על שאר המסכים (נחיל 9×9) — 2026-06-09
- נחיל של 44 fixers על כל המסכים שנותרו → **רק 9 תיקונים אמיתיים ב-6 קבצים** (38 כבר תקינים מ-round3 — אישוש ש-876-האודיט היה over-report).
- תוקנו (Semantics+Tooltip additive): `finder` (× סגור chip-tip) · `audit_screen` (חזרה) · `home_content_reorder` · `chats_screen` · `install_studio` · `lipskey_products`. תוויות-עברית מדויקות. בלי שינוי-layout.
- Gate: analyze 0 errors.

### #server-S0 — Firebase SDK מחווט (web) · Phase A — 2026-06-09
- ה-foundation החי (console: Auth Phone+Email · Firestore me-west1 Production) חובר ל-client דרך drop-in cache-pattern. SSOT: `SERVER-KICKOFF` + `SPEC-server-connect-MICRO` (ענף-ידע `nice-volta-BSbVm`).
- **S0.2** `lib/firebase_options.dart` — נכתב ידנית מה-Web SDK config (flutterfire CLI חסום בסנדבוקס: אין CLI/auth + ה-network חוסם דומייני-Firebase). web בלבד; android/ios זורקים שגיאה ברורה עד שירשמו. client-config פומבי (אבטחה = Rules S5).
- **S0.3** deps: `firebase_core ^4.10` · `firebase_auth` · `cloud_firestore ^6.5` · `firebase_messaging` · `cloud_functions` · `firebase_app_check` (pub get ירוק).
- **S0.4** `main.dart`: `Firebase.initializeApp(…web)` + `Settings(persistenceEnabled:true)` — רץ רק ב-`main()` (לא בטסטים) → הסוויטה נשארת Firebase-free.
- **S0.5** App Check guarded (debug ל-mobile · web reCAPTCHA + prod-attestation בהמשך · non-enforcing עד S5.7).
- ה-interface נשאר **sync** (drop-in); ה-repos עדיין `_local` עד S3. catalog לא ב-Firestore.
Gate: analyze 0 · suite 1772/1772 · build web ✓. Next: S2 (base cache-pattern + orders pilot) → S3 ×6 (הנחיל).

### #server-S2 — סכמה + base cache-pattern + orders pilot · Phase B — 2026-06-10
- ה-foundation של server-connect ש-6 מימושי-ה-`_firebase` (S3) יורשים. ה-drop-in נשמר דרך **offline-first cache**: ה-interface נשאר **sync**, ה-UI ללא-שינוי, ה-real-time זורם דרך ה-cache. SSOT: `SPEC-server-connect-MICRO` §S2/S3 + בלוק-הסכמה.
- **S2.1** `knowledge/firestore-schema.md` — 9 ה-collections (users/orders/customers/projects/tasks/stock/siteNodes/chatThreads/chatMessages) + שדות/טיפוסים, מיפוי-שדות orders (who→contractorId · site→siteAddress · createdAt→ts ISO-8601 · id=doc-id), ואזהרה מפורשת: **הקטלוג (1,877) לא ב-Firestore** — bundled/R2-CDN, אפס עלות-DB.
- **S2.2** `lib/data/repositories/firestore_cached_repo.dart` — `FirestoreCachedRepo<T>` (extends `ChangeNotifier`): seam `RemoteCollectionSource` (abstract: `snapshots()`/`set`/`delete` בשפת-`RemoteDoc` נייטרלי), שהמימוש-האמת `FirestoreCollectionSource` פותר `FirebaseFirestore.instance` **בעצלתיים** (לעולם לא ב-constructor → הסוויטה נשארת Firebase-free). cache-בזיכרון נולד-מ-seed · `attach()` ממפה snapshots דרך `fromDoc`/`idOf`+`sortBy` ומחליף cache → `notifyListeners` (doc-פגום מדולג+logged, לעולם לא מאפס) · `cached()` sync · `upsert`/`replaceAll`/`removeById` = עדכון-cache אופטימי + כתיבת-רקע דרך `guardWrite` (תופס+רושם — כשל-כתיבה/stream לעולם לא נזרק ל-UI) · `onFirstSnapshotEmpty()` hook + `pushCacheToRemote()` · `dispose()` מבטל subscription.
- **S2.3** `lib/data/repositories/orders_firebase.dart` — `FirebaseOrdersRepository extends FirestoreCachedRepo<Order> implements OrdersRepository` (collection `orders`, doc-id = order id). כל מתודות-ה-interface (all/byId/open/placeOrder/advance/setStage/resetToSeed) = **ports verbatim של `OrdersEngineNotifier`** (`_nextId` BS-#### · `advance` מעל `kManagerOrderFlow` · `setStage` guards · placeOrder ב-stage `new` prepended). seed: cache נולד עם `kOrdersEngineSeed` · snapshot-ראשון-ריק → `pushCacheToRemote()` · `resetToSeed` → `replaceAll(seed)`. `sortBy` משחזר סדר-newest-first (Firestore מחזיר סדר-doc-id) → ה-seed (BS-1042…BS-1039) ומיקום-ההזמנות-החדשות נשמרים byte-identical.
- **provider switch** (תחתית `orders_local.dart`): `Firebase.apps.isNotEmpty` → `FirebaseOrdersRepository()..attach()` (+`ref.onDispose`); אחרת `LocalOrdersRepository(ref)` — כל הסוויטה (ללא `Firebase.initializeApp`) נשארת על המסלול-המקומי, לעולם לא נוגעת ב-Firestore.
- Gate: `flutter analyze lib/ test/` 0 errors (ה-infos/warnings קדמו · 0 נוספו על קבצי-S2) · `test/firestore_cached_repo_test.dart` 20/20 (fake-source ידני, ללא package חדש) · הסוויטה המלאה ירוקה. Next: S3 ×6 (הנחיל יורש את ה-base).

## גל S3 — הנחיל ×5 (server-connect · Phase C, rebuild) — 2026-06-09

### #server-S3.C — customers_firebase (Firestore-backed לקוחות) · Phase B — 2026-06-10
- מימוש-ה-`_firebase` של דומיין-הלקוחות, יורש את ה-base של S2.2 (`FirestoreCachedRepo<T>`) ומחקה את ה-pilot S2.3 (`orders_firebase`). ה-drop-in נשמר דרך **offline-first cache**: ה-interface נשאר **sync**, ה-UI ללא-שינוי, ה-real-time זורם דרך ה-cache. SSOT: `SPEC-server-connect-MICRO` §S3 (שורה S3.C) + בלוק-הסכמה (`customers`).
- **מהות-הדומיין (השוני מ-orders):** מסך 👥 לקוחות אינו seed סטטי — הוא ה-**aggregates** הנגזרים מההזמנות החיות (`ManagerCustomer{name, orderCount, totalSpend, creditLimit}`), קיפול `mgrCustomerList` (`logic/manager_dashboard.dart`) + תקרת-האשראי הדטרמיניסטית `contractorCredit`. לכן ה-interface הקיים `CustomersRepository` הוא משטח-**קריאה** נגזר (`all`/`byName`/`creditLimit`) — **ללא מתודות-כתיבה**, וה-repo לא ממציא כאלה. הכתיבות-האופטימיות של ה-base משמשות ל-seeding-של-backend-טרי (`onFirstSnapshotEmpty`) ולשמירת `upsert` מושפע-אשראי sync-visible (כפי שדורש חוזה-S3).
- **S3.C** `lib/data/repositories/customers_firebase.dart` — `FirebaseCustomersRepository extends FirestoreCachedRepo<ManagerCustomer> implements CustomersRepository` (collection `customers`, doc-id = שם-הלקוח). מתודות-ה-interface (all/byName/creditLimit) = **ports verbatim של `LocalCustomersRepository`**: `all()`→`cached()` · `byName()` סורק את ה-cache · `creditLimit()` delegates ל-`contractorCredit(name)` הטהור (לא קריאת-Firestore — תקרה דטרמיניסטית, זהה בכל מסלול). seed: cache נולד עם `mgrCustomerList()` (קיפול-ה-seed של `kManagerOrderSeed` → אותם 4 לקוחות שה-local מחזיר) · snapshot-ראשון-ריק → `pushCacheToRemote()`.
- **מיפוי-שדות** (`ManagerCustomer` ⇄ doc per סכמה `customers/{id} {name, phone, creditLimit, used, balance, ownerId}`): `name`→`name` (doc-id) · `totalSpend`→`used` (₪ שנוצל — בדיוק מה שה-dashboard מציג) · `creditLimit`→`creditLimit` · `balance` = `creditLimit-totalSpend` (נגזר, שדה-SSOT) · `orderCount` נישא כשדה-עודף (כך ש-`all()` מחזיר aggregate-מלא ללא join — בדיוק כמו ש-`orders` נושא `items`). `phone`/`ownerId` חסרי-ערך-במודל → `toDoc` משמיט, `fromDoc` מתעלם (round-trip סובלני — בדיוק טיפול-ה-pilot ב-`storeId`/`courierId`). `sortBy` משחזר סדר-spend-desc (Firestore מחזיר סדר-doc-id) → סדר-ה-`mgrCustomerList` נשמר.
- **provider switch** (תחתית `customers_local.dart`): `Firebase.apps.isNotEmpty` → `FirebaseCustomersRepository()..attach()` (+`ref.onDispose`); אחרת `LocalCustomersRepository(ref)` — כל הסוויטה (ללא `Firebase.initializeApp`) נשארת על המסלול-המקומי, לעולם לא נוגעת ב-Firestore. `managerCustomersProvider` כבר מסתעף על `is LocalCustomersRepository`: ה-local מקפל את ההזמנות-החיות שהוא `watch` דרך `aggregate(orders)`, ומימוש-ה-Firestore מגיש את ה-aggregates מה-cache דרך `all()` — ללא שינוי-קוד נוסף שם.
- Gate: `flutter analyze lib/data/repositories/customers_firebase.dart lib/data/repositories/customers_local.dart test/customers_firebase_repo_test.dart` → 0 errors (No issues found) · `test/customers_firebase_repo_test.dart` 9/9 (fake-source ידני, ללא package חדש: seed-first · snapshot מחליף cache · מיפוי-אשראי round-trip · doc-פגום מדולג · `upsert` מושפע-אשראי sync-visible + writes-through · כשל-כתיבה לא-משחית/לא-נזרק · first-empty seeds-remote · provider→LOCAL ללא Firebase). הסוויטה המלאה — gate מרכזי (orchestrator).

### #server-S3-stock — מלאי `_firebase` (S3.T) · drop-in · Phase B — 2026-06-10
- מימוש-ה-Firestore של המלאי, יורש את ה-base מ-S2.2 (`FirestoreCachedRepo<T>`). drop-in מלא ל-`LocalStockRepository`: ה-interface נשאר **sync**, ה-UI ללא-שינוי. SSOT: `SPEC-server-connect-MICRO` §S3.T + בלוק-הסכמה (`stock/{id} {sku, name, qty, location, projectId}`).
- **שני משטחים, מחלקה אחת** — למלאי טבע מפוצל וה-repo שומר עליו נאמן byte-for-byte:
  1. **קריאות-אנליטיקה const** (`totalProducts`/`catalogCount`/`accessoryCount`/`availableCount`/`categoryCounts`/`stores`/`activeStores`/`supplierStores`/`haulTypes`) — data **סטטי שלא משתנה בזמן-ריצה**, ולכן (בדיוק כמו הקטלוג S3.K) **לא ב-Firestore**: נשארות **byte-identical** ל-`LocalStockRepository`, מאצילות לאותם consts בדיוק (`managerAnalytics`, `kManagerCatalogCategories`, `kManagerStores`, `kStores`, `kHaulTypes`). טעינתן מ-Firestore רק הייתה מוסיפה reads+latency על data bundled וקבוע (אזהרת-SSOT §אזהרות).
  2. **המלאי המשתנה** (מסך 📦 "המלאי שלי", שני-tabs: `name → 'warehouse'|'site'`, נהפך ב-`move`) **הוא** החלק ששייך לשרת — זו ה-collection `stock`. רוכב על ה-cache-pattern: listener של `snapshots()` מזין cache-בזיכרון · קריאת-sync `stockDemo()` מוגשת ממנו · `move` מעדכן cache אופטימית + כותב ל-Firestore ברקע (כשל-כתיבה נרשם, לעולם לא נזרק).
- **`lib/data/repositories/stock_firebase.dart`** — `FirebaseStockRepository extends FirestoreCachedRepo<StockItem> implements StockRepository` (collection `stock`). מודל-cache פנימי `StockItem{id(=sku), name, location, qty, projectId}`.
  - **אסטרטגיית doc-id (ה-gotcha המרכזי):** המלאי ממופתח לפי **שם-פריט עברי**, וכמה שמות מכילים `/` (למשל `ברז ניל זוויתי 1/2"`) — **אסור** ב-document-id של Firestore. לכן השם **לא** יכול להיות doc-id. במקום זה מוקצה surrogate יציב `STK-##` ב-**סדר-ה-seed** (doc-id order = seed order): `STK-00`…`STK-10`, אחד לכל ערך ב-`kStockDemo`. `fromDoc` קובע `sku == id` (שדה-ה-`sku` בסכמה **הוא** ה-surrogate); השם-העברי וה-location הם שדות רגילים, כך ש-ה-`/` חי בבטחה ב-data ולעולם לא ב-id.
  - **`move` = port verbatim של `StockNotifier.move`** (`screens/stock_screen.dart`): חיפוש לפי **שם**; שם-לא-מוכר → **no-op**; אחרת היפוך `'warehouse'`⇄`'site'` (`cur == 'warehouse' ? 'site' : 'warehouse'`). ההיפוך = `upsert` אופטימי (replace-by-id → השורה שומרת מיקום-seed) + `set` ברקע.
  - seed: ה-cache נולד עם `kStockDemo` ממופה ל-`STK-##` · snapshot-ראשון-ריק → `pushCacheToRemote()` (11 שורות-מלאי בשרת) · `sortBy` ממיין לפי id עולה → סדר-seed משוחזר אחרי כל snapshot (Firestore מחזיר סדר-doc-id = `STK-00…STK-10`) · doc-פגום מדולג+logged (לעולם לא מאפס את המלאי).
- **provider switch** (תחתית `stock_local.dart`): `Firebase.apps.isNotEmpty` → `FirebaseStockRepository()..attach()` (+`ref.onDispose(repo.dispose)`); אחרת `const LocalStockRepository()` — כל הסוויטה (ללא `Firebase.initializeApp`) נשארת על המסלול-המקומי, לעולם לא נוגעת ב-Firestore.
- **הערת-interface:** `move` ו-`stockDemo()` חיים על ה-**impl** (`FirebaseStockRepository`/`LocalStockRepository`), **לא** על ה-abstract `StockRepository` — בדיוק כמו `StockNotifier.move` ו-`LocalStockRepository.stockDemo()` בלגאסי. ה-abstract נשאר ללא-שינוי (קריאות-האנליטיקה בלבד). מסך-המלאי (`stock_screen.dart`, של צי-אחר) עדיין זורע את ה-`StockNotifier` שלו דרך `repo.stockDemo()` רק כשה-repo הוא `LocalStockRepository`, אחרת fallback ל-`kStockDemo` — אותו מפת-11-שורות בשני המקרים, ה-drop-in נשמר; חיווט-המסך-ל-repo-החי הוא S4 (real-time), לא בהיקף S3.T.
- Gate: `flutter analyze` על 3 הקבצים (stock_firebase · stock_local · test) **0 issues**. `test/stock_firebase_repo_test.dart` **10/10** (fake-source ידני, ללא package חדש): seed-first · doc-id STK-## (sku==id, שם-`/` בשדה) · snapshot מחליף-cache בסדר-seed · doc-פגום מדולג · `move` אופטימי sync-visible + כתיבה · `move` שם-לא-מוכר no-op · כשל-כתיבה עמיד · snapshot-ראשון-ריק זורע שרת · אנליטיקה byte-identical ל-local · provider=LOCAL ללא-Firebase.

### #server-S3.S — site repository `_firebase` (drop-in, composed) · Phase C — 2026-06-10
- S3.S: המימוש ה-Firestore-backed של `SiteRepository` (workspace-האתר: פרויקטים · כלי-אתר · plan-scan · התראות-תקציב + טיפי-בטיחות · התקדמות-שלבי-התקנה · זרימת-משימות-עובד). drop-in מלא ל-`LocalSiteRepository` — `siteRepositoryProvider` + כל מסכי-האתר ללא-שינוי; רק המחלקה שה-provider מחזיר מתחלפת. SSOT: `SPEC-server-connect-MICRO` §S3.S. יורש את base-ה-cache (`FirestoreCachedRepo<T>`, S2.2) דרך אותו דפוס בדיוק כמו ה-orders pilot (S2.3) → ה-interface נשאר **sync**, ה-real-time זורם דרך ה-cache, כשל-כתיבה נרשם ולעולם לא נזרק.

- **`lib/data/repositories/site_firebase.dart` (חדש)** — `FirebaseSiteRepository implements SiteRepository`, **מורכב (COMPOSED)** משני repos של ה-base כי ה-interface מחזיק שתי רשימות-חיות עצמאיות + משטחים-סטטיים:
  - **`tasks`** (`_TasksRepo extends FirestoreCachedRepo<PersonaTask>`, collection `tasks`, doc-id = `'${task.id}'`) — זרימת worker↔manager. seed = `kPersonaTasks` (cache נולד-מלא). `toDoc`/`fromDoc` ממפים `name⇄title` + `status` (השדה היחיד שמשתנה ב-runtime) ושומרים `worker/days/steps/note/orderId` בלי-אובדן. `sortBy` ממיין לפי id-מספרי (Firestore מחזיר סדר-doc-id-string → '10' לפני '2').
  - **`siteStageProgress`** (`_StageRepo extends FirestoreCachedRepo<_StageFlag>`, collection site-prefixed) — התקדמות-שלבי-התקנה. ה-`StageProgressNotifier` הוא `Set<String>` של מפתחות `"<productKey>#<idx>"`; כאן **כל מפתח-נוכח = doc-אחד** (doc-id = המפתח; קיום-ה-doc = "done"). cache נולד **ריק** (ה-set המקומי מתחיל `const {}` — משתמש-טרי לא סימן כלום) → אין מה ל-seed (`onFirstSnapshotEmpty` no-op מובנה). `toggle` = upsert/removeById אופטימי.
  - **`_SeedingRepo<T>` (subclass פרטי)** — מפעל את ה-hook של seed-fresh-backend **פעם-אחת** (`onFirstSnapshotEmpty() => pushCacheToRemote()`); `_TasksRepo` יורש ממנו, `_StageRepo` לא (נולד-ריק).
  - **משטחים-סטטיים = const pass-through, *לא* Firestore:** `projects`/`projectById`/`activeProjectId`/`siteToolsTree`/`planTypes`/`safetyTips`/`budgetLevel` (`kProjects`/`kActiveProjectId`/`kSiteToolsTree`/`kPlanTypes`/`kSafetyTips`/`budgetLevelFor`). data-לוח/דמו שלא משתנה ב-runtime → כלל-הקטלוג (data-סטטי לא שייך ל-Firestore, אפס עלות-DB). לכן `projects` **אינו** repo-מורכב-שלישי.

- **כל מתודות-ה-interface = ports verbatim:**
  - `workerTasks`/`pendingApprovals` — מ-`_tasks.cached()` (pending = `status=='review'` ממוין-id, port של `pendingApprovalTasksProvider`).
  - `submitForReview` — port של `WorkerTasksNotifier.submitForReview` (`active`/`rejected`→`review`, אחרת no-op).
  - `approve` — port של `.approve` (`review`→`done`; אם יש `orderId` → מקדם את ההזמנה). **גשר-ההזמנות מנותב דרך ה-seam `ordersRepositoryProvider`** (`_orders.advance(orderId)`) ולא דרך `ordersEngineProvider` הישיר — כך ההזמנה מתקדמת **גם מרחוק** (Firestore), בדיוק כפי שהמקומי מקדם על ה-engine המשותף.
  - `reject` — port של `.reject` (`review`→`rejected`, אחרת no-op).
  - `stageIsDone`/`stageDoneCount`/`toggleStage` — ports של `StageProgressNotifier.isDone`/`doneCount`/`toggle` (אותה סכמת-מפתח `"<productKey>#<idx>"`).

- **provider switch** (תחתית `lib/data/repositories/site_local.dart` — שונה):
```dart
final siteRepositoryProvider = Provider<SiteRepository>((ref) {
  if (Firebase.apps.isNotEmpty) {
    final repo = FirebaseSiteRepository(
      orders: ref.read(ordersRepositoryProvider),
    )..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return LocalSiteRepository(ref);
});
```
  `attach()` רושם את **שני** ה-caches המורכבים ל-`snapshots()` שלהם; `dispose()` מבטל את **שניהם** (דרך `ref.onDispose`). ה-seam של ההזמנות נמשך פעם-אחת מ-`ordersRepositoryProvider` והוזרק. כל הסוויטה (ללא `Firebase.initializeApp`) → `Firebase.apps` ריק → `LocalSiteRepository`, לעולם לא נוגעת ב-Firestore.

- **`test/site_firebase_repo_test.dart` (חדש)** — 13 בדיקות, fake ידני **לכל collection** (`_FakeSource` ×2) + spy-`OrdersRepository` (`_SpyOrders` שמתעד `advance`), **ללא package חדש**: tasks נולד-מ-seed · stage נולד-ריק (ולא דוחף seed) · snapshot מחליף cache (ממוין-id) · submit/approve/reject/toggle אופטימיים sync-visible + כותבים דרך · **approve מנתב advance דרך ה-orders seam** (bound) ולא מקדם (unbound/non-review) · כשל-כתיבה לא משבית cache ולא נזרק · משטחים-סטטיים = seeds · `siteRepositoryProvider`=LOCAL ללא-Firebase.

- Gate: `flutter analyze` על 3 הקבצים = **0 errors** (info יחיד שנותר — `directives_ordering` ב-`site_local.dart`, **קדם** ל-S3.S ב-baseline; 0 issues חדשים על קבצי-S3.S). `flutter test test/site_firebase_repo_test.dart` = **13/13 PASS**. אין commit/push (scoped). Next: שאר ה-S3 (customers/stock/finance), אז S4 real-time.

### #server-S3.F — finance repo `_firebase` (drop-in דרך cache-pattern) · Phase C · S3.F — 2026-06-10

- ה-repo ה-Firestore-backed של 📊 מרכז פיננסים, יורש את base ה-cache (S2.2 `FirestoreCachedRepo<T>`) — **drop-in** ל-`LocalFinanceRepository`: ה-accessor `financeRepo()` + ה-provider `financeRepositoryProvider` + ה-UI ללא-שינוי, רק המחלקה שהם מחזירים מתחלפת. SSOT: `SPEC-server-connect-MICRO` שורה S3.F + בלוק-הסכמה.
- **מה נשמר (persist) vs מה נגזר (derived):** ה-SSOT מפורש — finance שומר **רק** את 3 חלקי-ה-state החי, וכל השאר **נגזר client-side ולעולם לא נדחף ל-Firestore** (אחרת reads מיותרים על data קבוע + שכפול ה-const seeds):
  - `financeApprovals` — תור אישורי-הרכש (doc-id = id האישור, למשל `AP-201`).
  - `financePenalties` — ספר-הקנסות (doc-id = id הקנס, למשל `PEN-301`).
  - `financePaymentTerms/active` — תנאי-התשלום הפעיל היחיד (collection חד-מסמכי · doc-id קבוע `active` · שדה `{termId}`).
  - **derived (לא persist):** `budgetTotal`/`budgetSpent`/`budgetCategories`/`budgetPct`/`budgetLevel`/`financeHub` (const seeds) + `activeRevenue` (Σ הזמנות-פתוחות מ-orders engine) — מחושבים **בדיוק כמו ב-local** (forward ל-`LocalFinanceRepository` פנימי), אפס כתיבה ל-Firestore.
- **S3.F** `lib/data/repositories/finance_firebase.dart` — `FirebaseFinanceRepository implements FinanceRepository`. אינו `FirestoreCachedRepo` בעצמו (שומר 3 רשימות נפרדות, לא אחת) — אלא **מרכיב 3 sub-repos** של ה-base (`_ApprovalsCacheRepo`/`_PenaltiesCacheRepo`/`_PaymentTermCacheRepo`), כל אחד מעל ה-collection שלו, ומפזר `attach()`/`dispose()` לשלושתם (בדיוק כמו ה-orders pilot מחווט בprovider). ה-const reads + `activeRevenue` מ-delegate ל-`LocalFinanceRepository` (Ref-bearing כשהprovider מספק Ref).
  - **seed:** approvals נולד מ-`kApprovalQueue` (status 'ממתין', זהה ל-`ApprovalQueueNotifier`) · penalties נולד **ריק** (זהה ל-`PenaltyLedgerNotifier`, אין מה לדחוף → `onFirstSnapshotEmpty` default no-op) · payment-term נולד מ-`kActivePaymentTerm` ('net30'). approvals + payment-term: `onFirstSnapshotEmpty() => pushCacheToRemote()` (זריעת backend טרי).
  - **כתיבות = ports verbatim של ה-notifiers** (optimistic upsert + `guardWrite` ברקע — כשל נרשם, לעולם לא נזרק): `decide(id,ok)` → flip ל-'אושר'/'נדחה' (`ApprovalQueueNotifier.decide`, no-op על id לא-מוכר) · `addPenalty(days)` → `PEN-${300+len+1}` × `kPenaltyPerDay` (500), days clamped ל-≥1, newest-first (`PenaltyLedgerNotifier.add`; ה-`sortBy` של sub-repo שומר PEN-#### גבוה בקדמה) · `setPaymentTerm(termId)` → upsert מסמך `active` (כמו `activePaymentTermProvider.notifier.state = id`).
  - **חברים concrete נוספים** (תקדים `LocalOrdersRepository.seed()`): מכיוון ש-`FinanceRepository` הוא interface **read-only/derived** ללא מתודות ל-state הזה, הרשימות-הנשמרות + ה-writes נחשפים כחברים concrete מעבר ל-interface (`approvals()`/`penalties()`/`activePaymentTerm()` + `decide`/`addPenalty`/`setPaymentTerm`) — ה-interface האבסטרקטי לא נגע, ה-drop-in נשמר.
- **provider switch — 2 entry points** (תחתית `finance_local.dart`, מועתק מ-orders ומותאם לכל צורה):
  - **accessor גלובלי Ref-free `financeRepo()`** — singleton לכל חיי-האפליקציה (ל-accessor אין lifecycle של provider לdispose מולו → חי כל זמן ה-process, בדיוק כמו ה-const שהוא מחליף). Ref=`null` → `activeRevenue` לא-זמין דרכו (זורק — זהה לחוזה ה-accessor const היום; אף sheet לא קורא revenue דרכו):
    ```dart
    FirebaseFinanceRepository? _firebaseFinanceSingleton;
    FinanceRepository financeRepo() {
      if (Firebase.apps.isNotEmpty) {
        return _firebaseFinanceSingleton ??=
            (FirebaseFinanceRepository(null)..attach());
      }
      return _kFinanceConst;
    }
    ```
  - **provider Ref-bearing `financeRepositoryProvider`** — `ref.onDispose` כמו orders:
    ```dart
    final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
      if (Firebase.apps.isNotEmpty) {
        final repo = FirebaseFinanceRepository(ref)..attach();
        ref.onDispose(repo.dispose);
        return repo;
      }
      return LocalFinanceRepository(ref);
    });
    ```
  - כל הסוויטה (ללא `Firebase.initializeApp` → `Firebase.apps` ריק) נשארת על המסלול-המקומי, לעולם לא נוגעת ב-Firestore.
- **⚠️ follow-up (לא בוצע — מכוון):** sheets של finance-hub (`screens/finance_hub_sheets.dart`) עדיין מ-mutate-ים את ה-StateNotifiers ישירות (`ref.read(approvalQueueProvider.notifier).decide(...)` · `penaltyLedgerProvider.notifier.add(...)` · `activePaymentTermProvider.notifier.state = ...`). ה-re-pointing שלהם ל-ports של ה-repo (`financeRepositoryProvider`) הוא משימת-המשך — ה-StateNotifiers נשארים המסלול-החי ל-UI עד שה-re-wiring נוחת. ה-`_firebase` מספק את התשתית; הצריכה לא משתנה עדיין.
- **collections שנבחרו:** `financeApprovals` · `financePenalties` · `financePaymentTerms` (חד-מסמכי, doc `active`). שמות מתועדים כאן ובראש הקובץ. (טרם נוספו ל-`knowledge/firestore-schema.md` — collections של finance הם state נשמר חדש; ה-schema doc הוא קובץ-base בבעלות S2, לא נגעתי בו.)
- Gate: `flutter analyze` על 3 הקבצים (`finance_firebase.dart` · `finance_local.dart` · `finance_firebase_repo_test.dart`) — **0 errors** (info יחיד: `avoid_positional_boolean_parameters` על `decide(String,bool)` — port verbatim של `ApprovalQueueNotifier.decide`, אותו info מדויק קיים ב-`finance_hub_state.dart:71` → parity מכוון). `test/finance_firebase_repo_test.dart` **11/11 PASS** (fake-source ידני per-collection, ללא package חדש: seed-first · snapshot מחליף · decide/addPenalty/setPaymentTerm optimistic+sync-visible+write-through · write-failure resilient · derived byte-identical+לא-נדחף · accessor+provider פותרים LOCAL ללא Firebase).

#server-S3.K — קטלוג STATIC (אפס עלות-DB) · אימות + שומר-קבע

## ההחלטה (SSOT S3.K)
הקטלוג (1,877 מוצרים) **לא ב-Firestore** — נשאר const-Dart bundled + תמונות מ-R2 CDN.
DoD: "catalog from bundle/CDN · 0 DB cost". 1,877 reads בכל פתיחת-קטלוג = עלות-DB מתמשכת על data שלא משתנה → אסור.

## נתיב-הנתונים שאומת (file:line)
- **המקור (const, לא-Firestore):**
  - `lib/data/polyroll_catalog.dart` → `kCatalogProducts` (1,877 — Lipskey+Polyroll+Huliot).
  - `lib/data/smart_tree.dart` → `kSmartProducts` (82 קלפים) + `kSmartTreeCats` + helpers.
  - `lib/data/catalog.dart` → `kCatalogCats` (11 קטגוריות ▦).
  - `lib/data/related_info.dart` → גשר `catalogProductForSku/Brand/Smart`.
  - כל ששת קבצי-הנתונים: **0 התאמות** ל-`cloud_firestore`/`firebase` (grep נקי).
- **ה-repo (טהור, const):** `lib/data/repositories/catalog_local.dart:44` `LocalCatalogRepository implements CatalogRepository` — כל method מחזיר const verbatim. אין `Ref`, אין import של firestore.
  - `catalog_local.dart:92` `const _kCatalogRepo` → `catalog_local.dart:98` global `catalogRepo()` + `catalog_local.dart:103` `catalogRepositoryProvider` — שניהם מחזירים את **אותו** instance (מקור-יחיד; remote-impl עתידי מחליף את שניהם).
- **הצרכנים (כולם דרך ה-seam, לא-Firestore):**
  - provider (ref-scoped): `screens/catalog_screen.dart` (×13) · `screens/lipskey_products_screen.dart:119,778,896` · `screens/smart_home_screen.dart:605`.
  - global `catalogRepo()` (לוגיקה-טהורה): `screens/departments_screen.dart:50,74,79` · `screens/finder_screen.dart:253,258` · `logic/system_division.dart:52,79` · `logic/pressure_drop.dart:285` · `logic/category_division.dart:102,124` · `state/card_projects.dart:125`.
- **תמונות (R2 CDN בלבד):** `lib/data/product_images.dart:8` `kImageBaseUrl` (`pub-…r2.dev`, dart-define override) → `resolveProductImage` (CDN+cache LRU 700, או asset-fallback). תמונות לא-bundled; metadata-מוצר כן const.

## הדליפה שנבדקה
grep `cloud_firestore|FirebaseFirestore|FirestoreCachedRepo|FirestoreCollectionSource` על `catalog_*.dart` תחת `lib/data/repositories/` → **0 התאמות**. אין דליפת-Firestore. (סימני-ה-Firestore חיים רק ב-`firestore_cached_repo.dart` + ה-drop-in של צי-אחר `orders_firebase.dart`.)

## השומר (נעילת-קבע)
`test/catalog_static_guard_test.dart` — source-scan (קריאות-File אמיתיות, לא reflection) על כל `catalog_*.dart` תחת `lib/data/repositories/`:
- **אסור** import של `cloud_firestore` (regex על directive ב-raw-source).
- **אסור** `FirestoreCachedRepo` / `FirestoreCollectionSource` ב-live-code (סריקת-identifier אחרי הסרת-הערות — סובלני להערות; הזכרת "NOT Firestore" בהערה לא מפילה).
- anti-vacuous: (1) הקבצים נבחרים בפועל (לא-ריק); (2) ה-detectors יורים על ה-base הסיבלינג שבאמת מצמיד-Firestore; (3) ה-comment-stripper לא no-op (sentinel בהערה בלבד).
- **תוצאה:** `flutter analyze` 0 · `flutter test` 3/3 ירוק. הוכח: `catalog_firebase.dart` זמני שמייבא firestore → RED (3 offenders); הסרה → GREEN.
- מנעול: כל `catalog_firebase.dart` עתידי שמצמיד-Firestore מפיל את ה-suite.

### #swarm-9 — נחיל 9-משימות: ניווט·RTL·48dp·אישורים·ריק·חיווט·ביצועים·ולידציה·משפטי — 2026-06-10 (נחיל מקבילי, 48 סוכנים, 36 קבצים)
- **#60 חזור בזרם-רישום** (`onboarding_screen.dart`): `_OpeningFlow` עטוף `PopScope` — step>0 חוסם pop ומחזיר שלב-אחורה (`startupStepProvider--`); step==0 pop רגיל (יציאה). `onPopInvokedWithResult` (Flutter≥3.22).
- **#62 RTL**: 5 חצי-חזרה `arrow_forward`→`arrow_back` (chats×3·catalog·audit — תחת RTL גלובלי `matchTextDirection` הופך אותם, הם הצביעו שמאלה=הפוך); ריפודים א-סימטריים `EdgeInsets.only(left/right)`/`fromLTRB`→`EdgeInsetsDirectional` (camera·finder·install·lipskey·catalog·notifications·audit). 6 חצים נוספים מחוץ-לסקופ תועדו ב-spec.
- **#63 48dp** (~44 תיקונים, 3 פרוסות): GestureDetector/InkWell על אייקונים 16-28px → קופסת-מגע ≥48dp (`SizedBox 48×48`+`Center`+`HitTestBehavior.opaque` / `ConstrainedBox minW/H:48`) בלי שינוי-מראה — store(5)·catalog(13)·chats·chat_settings·departments(2)·contractor·finder·audit·install(4+)·lipskey-sheet(5)·lipskey-products(5)·help_target(2). steppers צפופים 100dp-עמודה דווחו unfixable-בלי-רידיזיין.
- **#57 אישורי-הרס** (`widgets/confirm_dialog.dart` חדש — תבנית `_confirmReset`): `confirmDestructive()` נוסף ל-19 פעולות בלתי-הפיכות ב-13 קבצים (מחיקות רשימה/קטגוריה/פרויקט/התראות/חיפושים · נקה-סל · השתק-הכל · approve/reject משימה · מסירה-לשליח · נמסר-ללקוח · מימוש-פרס). +1 קיים (chat clearAll) = 20.
- **#58 מצבי-ריק** (16 עריכות, 11 מסכים): empty-state עברי (אימוג'י+כותרת+משנה, תבנית chats/notifications) — lipskey-products·departments·projects(+CTA פרויקט-חדש)·site-inspect(_CaEmpty)·budget(×2)·worker(queue/submitted)·persona-pod(order-not-found)·audit·smart-project·tasks-manager·catalog-brands. loading/error נדחה ל-Firebase.
- **#59 חיווט אמת**: שתף-סל → `share_plus` אמיתי (+clipboard-fallback; pubspec) · עקוב → `notifFollowedIdsProvider` persist `bs.notif-followed.v1` + צ'יפ-toggle עוקב✓ · רענון-התראות → `reload()` אמיתי מ-prefs (היו 4×`delayed(800ms)` פייק) · unread-צ'אט אמיתי → `bs.chat-lastread.v1`, נגזר מ-ts>lastReadAt, mark-on-open · ערוצי-קבלה: in-app אמיתי (badge=0 כשכבוי), אימייל/SMS/WhatsApp מסומנים 'דורש חיבור שרת' מושבתים-בכנות.
- **#61 ביצועים**: 19× `ref.watch(p)`→`p.select(field)` (ai_hub·chats·catalog·lipskey·notifications·departments·store_dashboard·manager·rewards) · `stock_screen` ListView→builder. סריקה מלאה אישרה: שאר הרשימות כבר lazy.
- **#64 ולידציה** (`logic/input_validators.dart` חדש, 5 פונקציות טהורות): נייד 05+10ספרות · email · ח.פ. 9ספרות · סכום>0 · טווח-תאריכים. חיווט inline-errorText: welcome(רישום, חוסם אישור)·profile(שמור מושבת על שגוי)·store_settings(ח.פ.)·budget(3 שדות)·finance(המרה). uniqueness נדחה ל-Firebase. `validDateRange` unwired בכנות — אין date-range UI באפליקציה.
- **#26 משפטי** (`data/legal_texts.dart`+`screens/legal_screen.dart` חדשים): תנאי-שימוש+מדיניות-פרטיות עברית מדויקים לחוק הגנת הפרטיות+תיקון-13 (בתוקף 8.2025, מחקר-רשת מתועד) — כנים ל-on-device-only, placeholders-בסוגריים לפרטי-חברה (אין המצאות). מסך RTL עם טאבים+SelectableText. חיווט: הגדרות→'מידע' חדש · חיפוש-אינדקס (2 ערכים קיימים) · קישורים מתחת לרישום.
- Gate: analyze 0 errors · בדיקות חדשות `input_validators_test` 27/27 + `notif_follow_toggle_test` 4/4 (תוקן lazy-provider בבדיקה) · מוטציה נתפסה ושוחזרה (mutation_log) · full-suite בריצה.

## גל S1+S4 — Auth + Real-time (server-connect · Phase B+C) — 2026-06-10

### #server-S1 — Authentication: זהות-אמת במקום role-picker-כ-זהות · Phase B — 2026-06-10
- שכבת-ה-auth של server-connect (S1.1–S1.9): login טלפון-OTP + מייל-fallback · `authStateProvider`/`roleProvider` · role-מ-custom-claims · נעילת role_picker למשתמש חד-תפקיד · logout+מחיקת-חשבון · `setRole` callable. SSOT: `SPEC-server-connect-MICRO` §S1 + §S1 במפרט-האב. **auth הוא additive**: בלי Firebase (כל הסוויטה / הסנדבוקס) האפליקציה מתנהגת byte-for-byte כהיום — user=null, role=בחירת-הפרסונה-הקליינטית.
- **THE SEAM** `lib/state/auth_state.dart` — `AuthGateway` (abstract): כל מגע-FirebaseAuth עובר דרך port מוזרק שמדבר ב-`AuthUser` נייטרלי + מפות-claims (לא `firebase_auth.User`), והמימוש-האמת `FirebaseAuthGateway` פותר `FirebaseAuth.instance`/`FirebaseFunctions` **בעצלתיים** (לעולם לא ב-constructor — חוק-ה-`FirestoreCollectionSource` מ-S2.2). חוזה-stream מתועד: emit של המצב-הנוכחי לכל subscriber חדש (סמנטיקת-FirebaseAuth — ה-fakes מחויבים לה). שגיאות מתורגמות ל-`AuthGatewayException(code)` נייטרלי ב-choke-point יחיד (`_guard`). web: `signInWithPhoneNumber`+`ConfirmationResult` (ל-`verifyPhoneNumber` אין מימוש-web); mobile: `verifyPhoneNumber` עם auto-verification (Android) שמתנקז לאותו מסלול-stream.
- **S1.4/S1.5 providers** (`auth_state.dart`) — `authGatewayProvider` (null כש-`Firebase.apps.isEmpty` — אותו switch של orders_local) · `authStateProvider` = `AuthSnapshot{user, roles, loaded}`: נולד-seeded מ-session-משוחזר (`currentUser` sync), claims נטענים async דרך `getIdTokenResult`; משמעת-`_loaded` של orders_engine מותאמת ל-stream+fetch — מונה-דורות `_gen` שכל אירוע/sign-out מקדם, ו-claims-איטיים שהדור-שלהם עבר **נזרקים** (לעולם לא מחיים user שהתנתק). `rolesFromClaims` (pure): claim-`roles` רשימה (רב-תפקיד) גובר על `role` בודד; ערכים מסוננים ל-5 ה-persona-ids — claim זר (`admin`) לעולם לא נועל UI. `roleProvider` בניב-`activePersonaProvider` (null=קבלן): חד-תפקיד → ה-role מהשרת (הבחירה-הקליינטית נדרסת); אחרת fallback לבחירה של היום.
- **S1.1–S1.3 login sheet** `lib/screens/login_sheet.dart` — bottom-sheet RTL באידיום persona_pod_sheet (ידית, rounded-top, FilledButton brand): שלב-טלפון (`normalizeIlPhone` pure: 05X→+972) → "שלח קוד אימות" → שלב-קוד (6 ספרות, "אימות וכניסה", שליחה-חוזרת/החלפת-מספר) → fallback "כניסה עם אימייל וסיסמה". **סגירה stream-driven בלבד**: `ref.listen(authStateProvider)` — user נחת (קוד ידני / מייל / auto-verification) → toast `התחברת בהצלחה ✓` + pop, בלי double-pop. כשלים = toast עברי דרך `hebrewAuthError(code)` (pure, ~12 קודים ממופים), לעולם לא exception ל-UI. loading: כפתור disabled + spinner.
- **S1.6 נעילת-הבורר** — diff מינימלי ב-`role_picker_sheet.dart`: `showRolePicker` קורא `roleSwitchLockedProvider` דרך `ProviderScope.containerOf` → נעול = no-op (כל call-sites מכוסים: לוגו-app-bar + שורת-הפרופיל). `roleSwitchLockedProvider` = `singleRole || (signedIn && !loaded)` — session משוחזר ש-claims-שלו עוד נפתרים נחסם שמרנית (ms); signed-out תמיד מוכרע → ההתנהגות של היום שלמה. **התנהגות:** signed-out / Firebase-free → הבורר של היום · חד-תפקיד → אין בורר (פרסונה=זהות; השורה `🔄 החלפת תפקיד` גם נסתרת בפרופיל) · רב-תפקיד → הבורר נשאר.
- **S1.7/S1.8 פרופיל** (`profile_screen.dart`) — מתחת ל"עוד": gateway+מנותק → `🔐 התחברות לחשבון` (פותח את ה-sheet; **בלי gateway השורה לא קיימת** → רנדור זהה-להיום בסוויטה); מחובר → section `חשבון` עם `🚪 התנתקות` (sign-out אופטימי-מקומי תמיד-נקי, כשל-רשת נרשם) + `🗑️ מחיקת חשבון` (דרישת-Apple): AlertDialog עברי "מחק לצמיתות"/"ביטול" → `user.delete()` + wipe. **ניקוי-identity** (משותף): `UserProfileNotifier.reset()` חדש (מנקה state + מוחק `bs.profile.v1`, `_userTouched` חוסם `_load` תלוי) + איפוס `activePersonaProvider`; העדפות-מכשיר (theme/welcome-seen) אינן account-data ושורדות. מחיקה שנכשלה (`requires-recent-login`) **לא מוחקת כלום** — toast עברי, החשבון והנתונים נשארים. wipe-צד-שרת של מסמכי-Firestore = TODO מתועד (functions/README, לפני launch).
- **S1.9 setRole** — `functions/` חדש בשורש-הריפו (Node 20 · firebase-functions v2 · TS strict, `tsc --noEmit` נקי): callable `setRole` ב-region **me-west1** (תואם `kAuthFunctionsRegion` בקליינט) — unauthenticated→חסום · ללא claim-`admin`→`permission-denied` · `{uid, role}` (או `roles[]` לרב-תפקיד) מאומת מול 5 ה-roles · merge מעל claims-קיימים (admin נשמר, `role`/`roles` בלעדיים-הדדית). README: deploy (דורש Blaze + בלוק `"functions"` ב-`firebase.json` — לא נגעתי בקובץ ה-CI), bootstrap-האדמין-הראשון (סקריפט Admin-SDK חד-פעמי), והערת-רענון-token. צד-קליינט: `AuthStateNotifier.assignRole({uid, role})` → `httpsCallable('setRole')` — נקודת-החיווט העתידית: 👔 מנהל המערכת → ניהול.
- **אילוץ-סביבה:** רשת-הסנדבוקס חוסמת Firebase — OTP/sign-in חיים לא נבדקים כאן (מכשיר אמיתי בהמשך). הקוד CODE-COMPLETE מאחורי ה-seam, וכל לוגיקת-providers/flows מכוסה ב-fake ידני (אפס packages חדשים).
- Gate: `flutter analyze` על 7 הקבצים (auth_state · user_profile · login_sheet · role_picker_sheet · profile_screen · 2 tests) → **0 errors** (2 infos קדמו ל-S1, אומתו על HEAD) · `test/auth_state_test.dart` + `test/login_sheet_test.dart` **41/41** (fake-gateway ידני: parsing claims · zero-regression בלי-Firebase · `_loaded`/gen-guard · OTP/קוד-שגוי/מייל · נעילת-בורר ב-3 המצבים · logout/מחיקה wipes + מחיקה-כושלת-לא-מוחקת · setRole) · קבצי-השכנים שנגעתי בהם (profile/deep_fix/manager_dashboard/user_profile_fields/onboarding/settings_honesty) **54/54** · `functions` `npx tsc --noEmit` נקי. הסוויטה המלאה — gate מרכזי (orchestrator).

### #server-S4 — real-time דרך ה-caches: chat `_firebase` + חיווט המנועים (S4.1–S4.4) · Phase C — 2026-06-10
- שכבת ה-real-time של server-connect: ה-snapshots זורמים **לתוך המנועים הקיימים דרך ה-caches** — אף provider לא הופך async, אפס שינויי-UI (אף מסך לא נגעו בו), ה-API הציבורי של המנועים ללא-שינוי. SSOT: `SPEC-server-connect-MICRO` §S4 (שורות S4.1–S4.5) + בלוק-הסכמה (`chatThreads`/`chatMessages`).
- **S4.1/S4.2 `lib/data/repositories/chat_firebase.dart` (חדש)** — `FirebaseChatRepository extends ChangeNotifier implements ChatRepository`, **מורכב (COMPOSED, התקדים של S3.S)** משני repos של ה-base (S2.2): `chatThreads` (heads: `_ChatThreadHead{id, participants, names, avatar, isBot, lastMsg, ts}`) + `chatMessages` (המודל = `ChatMessage` של המנוע, ללא-שינוי). `threads()` מרכיב חזרה את צורת-ה-`ChatThread` של המנוע (head + הודעותיו) משני ה-caches; שינוי בכל-אחד מהם → `notifyListeners` אחד שהמנוע מאזין לו. `sortBy`: heads בסדר-ה-seed (Firestore מחזיר doc-id order) · הודעות `orderBy(ts)` client-side (tie-break id; ה-bot reply חתום +1ms). seed: שני ה-caches נולדים מ-`kChatThreads` verbatim (heads + הודעות שטוחות) · snapshot-ראשון-ריק → `pushCacheToRemote()` לאותה collection · doc-פגום מדולג+logged (לעולם לא מרוקן את הצ׳אט).
- **⚠️ uid-join נדחה ל-S1 (מתועד בקובץ):** עד שצי-ה-auth מנחית `auth.uid` אמיתיים, הזהות מבוססת-ה-`BsRole` ממופה verbatim — `participants` נושא את **שמות-התפקידים** (`'contractor'`,`'store'`,…) במקום uids, `fromRole` נכתב ו-`fromUid` **מושמט**. אחרי S1 הקובץ הזה הוא נקודת-ההחלפה היחידה (fromDoc/toDoc); `fromDoc` כבר סובלני ל-entry לא-מזוהה (uid עתידי ליד role-name מדולג, לא פאטאלי), ו-head שדבר בו לא נפתר → skip per-doc.
- **S4.3 `send(threadId, fromRole, text)`** — port verbatim של `ChatEngineNotifier.send` דרך upsert: trim · no-op על ריק/thread-לא-מוכר · id `m-<micros>-<role>` · הודעה ל-cache אופטימית + `set` ברקע · עדכון-head `lastMsg`/`ts` (הדה-נורמליזציה שהסכמה דורשת) באותו מהלך · ה-BOT thread שומר את ה-auto-reply (רוטציה לפי ספירת הודעות-bot, +1ms) — threads אמיתיים לא עונים-אוטומטית (הפרסונה השנייה עונה חי: זו כל הפואנטה של S4). כשל-כתיבה נרשם, לעולם לא נזרק (`guardWrite`).
- **seam `lib/data/repositories/chat_repository.dart` (חדש, מינימלי, בתבנית-S3):** abstract `ChatRepository implements Listenable` (`threads`/`send`/`resetToSeed`) — ה-Listenable על ה-seam מאפשר למנוע להירשם דרך ה-interface בלבד. `chatRepositoryProvider`: `Firebase.apps.isNotEmpty` → `FirebaseChatRepository()..attach()` (+`ref.onDispose`); אחרת **null** — אין `LocalChatRepository` כי המימוש-המקומי **הוא** המנוע עצמו (עטיפה הייתה שכבת-האצלה מתה); כל הסוויטה נשארת על המסלול-המקומי.
- **חיווט המנועים (הלולאה לשני הכיוונים, diffs מינימליים):**
  - `lib/state/sys_chat.dart` — `ChatEngineNotifier.bindRemote(ChatRepository)` (נקרא מ-`chatEngineProvider` רק כש-Firebase מאותחל): **DOWN** — כל שינוי-cache (snapshot או optimistic) → `addListener` → `state = remote.threads()` (sync); **UP** — `send`/`resetToSeed` מאצילים ל-ports-ה-verbatim של ה-repo, שה-upsert-האופטימי שלהם מודיע חזרה **באותו call סינכרוני** → המנוע (וה-UI) רואים את השינוי באותו frame, וכתיבת-Firestore יוצאת ברקע. `markRead`/`threadsFor` ללא-שינוי (🔒 isolation נשאר במנוע).
  - `lib/state/orders_engine.dart` — `OrdersEngineNotifier.bindRemote(FirebaseOrdersRepository)` (נקשר ב-`ordersEngineProvider` ל-repo שה-switch של S2.3 כבר בנה+attach): **S4.4** `orders.snapshots()` → cache → המנוע → `sysOrdersProvider` (ההשלכה store/courier נגזרת מהמנוע — אפס שינוי ב-`sys_orders.dart`) + manager analytics — קידום-חנות נראה אצל שליח/קבלן חי. `placeOrder`/`advance`/`setStage`/`resetToSeed` מאצילים ל-ports-ה-verbatim של ה-repo — **ההאצלה היא מה ששומר cache⇄engine ב-lockstep**: כל מוטציה מקומית חיה בתוך ה-cache, ולכן snapshot מאוחר לעולם לא דורס אותה.
  - **prefs תחת Firebase:** ה-refresh רץ דרך ה-setter הציבורי → `_loaded=true`, כך ש-overlay-ה-SharedPreferences לא דורס מצב-שרת; תחת Firebase מקור-ההמשכיות הוא ה-offline-persistence של Firestore עצמו (S0.4), ו-prefs נשאר עותק write-behind. בלי Firebase (כל הסוויטה) — שום bind, התנהגות **byte-identical** להיום.
- **S4.5 (בדיקה דו-מכשירית) לא ניתן להריץ כאן** — אין רשת/Firebase בסביבה; ה-tests מקבעים בדיוק את הלולאה שהמכשירים ירכבו עליה (fake-source snapshot → cache → engine → getters sync; mutation → optimistic cache + כתיבה רשומה), והאימות-החי A→B רץ על מכשירים אמיתיים אחרי deploy.
- Gate: `flutter analyze` על 4 קבצי-lib + 2 קבצי-test → **0 errors** (בקבצים-החדשים 0 issues; ב-`orders_engine`/`sys_chat` נותרו רק ה-infos/warning שקדמו — 0 נוספו) · חדש `test/chat_firebase_repo_test.dart` **10/10** + `test/realtime_wiring_test.dart` **8/8** (fakes ידניים, ללא package חדש, ללא Firebase-init) · רגרסיה: 14 סוויטות chat/orders קיימות (sys_chat · chat_bubble_side · orders_engine · firestore_cached_repo · store/courier_stage_advance · t9_supplier_personas · persistence_roundtrip · manager_dashboard ×2 · worker_approval · worker_tasks_persistence · contractor_checkout · bs_dial_manager_orders) **134/134**. Next: S4.5 על מכשירים + S5 Rules (`chatThreads`/`chatMessages` per S5.2/S5.3) אחרי uid-join של S1.


## גל S5+S6+S8+S9 — Rules · FCM · Functions · Offline (server-connect · סגירת SSOT) — 2026-06-10

### #server-S5 — 🔒 Security Rules — RBAC צד-שרת (לפני-השקה) · Phase B — 2026-06-10
- שער-ההשקה הקריטי: Firestore ב-Production mode (deny-by-default) והאפליקציה קוראת/כותבת 10+ collections — קובץ-rules אחד הופך את הפרדת-התפקידים של ה-client לחוק-שרת. SSOT: `SPEC-server-connect-MICRO` שורות S5.1–S5.8 + בלוק-הסכמה, `SPEC-server-connect` §S5 + §"אבטחה — מתווה-rules". מקור-התפקידים: **custom-claims בלבד** (`role`/`roles[]` + `admin` — נכתבים רק דרך ה-callable `setRole`, `functions/src/index.ts`); ה-rules קוראים `request.auth.token`, ושדה-ה-`role` ב-`users/{uid}` הוא **מראה-קריאה** בלבד.
- **`firestore.rules` (חדש, repo root)** — helpers: `isSignedIn()` · `isAdmin()` (claim `admin:true`) · `hasRole(r)` (תומך **בשתי** צורות-ה-claim: `role` בודד **וגם** `roles:[…]` רב-תפקידי, דרך `token.get(…, default)` — בטוח-מ-error על claim חסר) · `isManager()` (manager∪admin — תפקיד-העל של האפליקציה). חוקים per-collection:
  - **S5.1 `users/{uid}`** — read: self/admin · self מתחזק את ה-mirror שלו (fcmToken S6.1 / displayName / phone) אבל **`role`/`roles` = admin-בלבד** (create: `keys().hasAny` · update: `diff().affectedKeys().hasAny`) · delete: self (S1.8 מחיקת-חשבון in-app, דרישת-Apple) או admin.
  - **S5.2 `chatThreads`** — read/delete: `auth.uid in resource.data.participants` · create: היוצר חייב להיות ב-participants של ה-doc-החדש · update: משתתף בלבד **ו-participants קפוא** (`request.resource.data.get('participants',[]) == resource.data.participants` — מותר לרענן lastMsg/ts denorm, אי-אפשר להעיף את ה-peer או לגייס זרים; ה-upsert-המלא של ה-repo כותב את אותו מערך → עובר). **manager אינו מעל פרטיות-צ׳אט** (לא-משתתף → denied).
  - **S5.3 `chatMessages`** — read: uid∈participants של ה-thread (lookup `get()` — עלות read-אחד) · create: רק כעצמך (`fromUid == auth.uid`, אין spoof) **וגם** משתתף-ב-thread · update/delete: `false` (הודעות immutable; moderation = עניין-Functions S8).
  - **S5.4 `customers`** — read: `isManager() || resource.data.get('ownerId','') == uid` (doc בלי ownerId — כמו ה-aggregates הנוכחיים — נקרא manager-בלבד) · write: manager בלבד (גם ה-owner לא מעלה לעצמו תקרת-אשראי).
  - **S5.5 `orders`** — create: contractor **רק** ב-`stage=='new'` (ראש `kManagerOrderFlow`) **וכבול-לעצמו** (`contractorId == uid` — אין הזמנה בשם-אחר); manager/admin יוצרים בכל stage חוקי (כלי-לוח/seed/reset). update **transition-מותר-לתפקיד**: store = שרשרת-החנות `new→preparing→ready` · courier = שרשרת-השליח `ready→pickup→transit→delivered` (הופ-אחד-בכל-פעם, מראה של `advance`) · שניהם **stage-only diff** (`affectedKeys().hasOnly(['stage'])` — שום שדה אחר לא זז) **וכבילת-שיבוץ**: `storeId`/`courierId` מאויש → רק אותו uid עובד על ההזמנה (ריק/חסר = pre-assignment → שער-התפקיד בלבד) · manager = god-step (`setStage`) לכל stage **בתוך** ה-vocabulary (stage מומצא נדחה). read: משתתף (`contractorId`/`storeId`/`courierId` == uid) או manager · delete: manager בלבד.
  - **S5.6 `stock`/`siteNodes`/`projects`/`tasks`/`siteStageProgress`** — פרגמטי-ומתועד (ה-docs החיים עדיין בלי joins של בעלות — projectId:'' / `projects` עצמו const pass-through שהאפליקציה לא כותבת): read: כל-מחובר · write לפי בעל-הזרימה: stock=store/manager · siteNodes=contractor/manager · projects=manager או contractor-כבול-לעצמו (`contractorId==uid`) · tasks=worker/manager (זרימת submit→approve/reject) · siteStageProgress=contractor/worker/manager. הידוק ל-membership-פר-פרויקט (`projects.members[]`/joins) = שלב-ההקשחה שאחרי uid-migration, לצד S8.
  - **S3.F `financeApprovals`/`financePenalties`/`financePaymentTerms`** — write: manager בלבד (decide/addPenalty/setPaymentTerm = פעולות-לוח-manager) · read: manager (+owner היכן ש-`ownerId` קיים — future-proof; ה-docs הנוכחיים בלי → manager-only).
  - **default deny** — `match /{document=**} { allow read, write: if false; }` — כל collection לא-ממופה (כולל עתידי-בלי-rule) חסום לכולם. הקטלוג (1,877) בכוונה **לא** ב-rules — הוא bundled/R2-CDN, לא Firestore.
- **3 אזהרות-תפעול בכותרת-הקובץ (חוזה-ההשקה):**
  1. **S5.7 App Check = פעולת-console, לא rules:** console → App Check → APIs → Cloud Firestore → Enforce — רק אחרי שה-clients מריצים provider (S0.5). צעד מתועד גם ב-`rules_test/README.md`.
  2. **uid-migration לפני production:** ה-rules ממשים את חוזה-ה-uid שאחרי-S1 (כמתועד ב-`chat_firebase.dart`) — אבל ה-client הנוכחי עוד כותב **שמות-role** ב-`chatThreads.participants`, **משמיט** `fromUid`, וכותב display-name ב-`orders.contractorId` → כתיבות/קריאות pre-migration נדחות by-design עד ריצת-המיגרציה (rewrite ל-uids + החלפת נקודת-המיפוי היחידה ב-`chat_firebase.dart`).
  3. **rules הם לא פילטרים:** `FirestoreCollectionSource` מאזין היום ל-collections **שלמים** (בלי `where`) — האזנה כזו של לא-manager על collection ממוסך-משתתפים (orders/chat/customers/finance) נדחית **כמכלול**; ה-listeners השמורים של ה-base רושמים את הכשל וממשיכים להגיש seed-cache (לעולם לא נזרק ל-UI), אבל data חי מחייב שאילתות-ממוסכות (חוזה-S4.1 `arrayContains`). מאותה סיבה seed-push של backend-טרי מצליח רק מסשן admin/manager.
- **`firebase.json`** — נוסף בלוק `"firestore": {"rules": "firestore.rules"}` (hosting נשמר byte-intact; deploy: `firebase deploy --only firestore:rules`).
- **`rules_test/` (חדש, repo root) — S5.8 suite:** `@firebase/rules-unit-testing` v4 על `node --test` (בלי mocha/jest), `firestore.rules.test.mjs` — 6 suites: users-mirror (12) · chat-isolation (16, כולל שאילתת-S4.1 מותרת מול full-listen נדחה, spoof-שולח, participants-קפוא) · credit (8) · store-foreign-isolation (7) · orders-transitions (26, כולל multi-role `roles:[store,courier]` דרך `hasRole`) · S5.6+finance+default-deny (16). זהויות = בדיוק צורות-ה-claims ש-`setRole` כותב; seed עם `withSecurityRulesDisabled` + `clearFirestore` לפני **כל** טסט. `package.json` + `README.md` (פקודות-הרצה local/CI + צעד-App-Check + 3 האזהרות) + `.gitignore`.
- Gate: `firebase emulators:exec --only firestore --project demo-buildsmart "npm test"` (emulator v1.19.8 אמיתי, ה-rules קומפלו ונאכפו — ה-denials מצטטים מספרי-שורות-rule) → **85/85 PASS · 0 fail** ב-~8.2s. אפס נגיעה ב-`app_flutter/lib`/`functions/src`/`pubspec*` (rules = צד-שרת בלבד). Next: deploy rules ל-`buildsmart-b0b78` (console/CLI) · uid-migration · scoped-queries (S4) · App Check enforce (S5.7).

### #server-S8 — Cloud Functions: לוגיקה-רגישה בשרת (S8.1–S8.4 + S7.2/S6.3) · Phase C — 2026-06-10
- שכבת-השרת שלא-סומכת-על-client: אכיפת מעברי-stage, אשראי-קבלן קנוני, FCM-push, audit append-only, ו-presigned-uploads ל-R2 — הכל ב-`functions/` (Node 20 · TS strict · firebase-functions **v2** · region **`me-west1`** בכל פונקציה, תואם `kAuthFunctionsRegion`). ה-skeleton של S1 (`setRole`) **לא שונה** — המודולים החדשים נוספו סביבו (`src/index.ts` re-exports בלבד; שירותי-Admin נפתרים lazily בתוך handlers — לעולם לא ב-module-scope, כי ה-imports נטענים לפני `initializeApp()`). SSOT: `SPEC-server-connect-MICRO` §S8 + S7.2 + S6.3.
- **S8.1** `src/orders.ts` + `src/orderFlow.ts` — אכיפה בשתי שכבות (שתיהן נדרשות, כי ל-Firestore-triggers אין auth-context): **(א)** callable `advanceOrderStage({orderId})` — קידום **צעד-בודד** ב-`ORDER_FLOW` (`new→preparing→ready→pickup→transit→delivered`, verbatim `kManagerOrderFlow`) בטרנזקציה, עם אכיפת-תפקיד מה-claims לפי ה-**קוד** של `sys_orders.dart`: store = new→preparing→ready→pickup (כולל המסירה "מסור לשליח") · courier = pickup→transit→delivered · manager/admin = כל צעד-בודד ("can nudge any single step"); חותם `stageBy/stageRole/stageAt`; `delivered` סופי (mirror ל-no-op של ה-client); **(ב)** trigger `revertIllegalOrderStageWrite` (onDocumentUpdated `orders/{id}`) — defense-in-depth: שינוי-stage ישיר שאינו צעד-קדימה-בודד **מוחזר** ל-stage הקודם (בטרנזקציה, רק אם לא נדרס) + auditLog; loop-guard בחותם `stageGuard{revertedAt,from,to}`. אכיפת-תפקיד על כתיבות ישירות חוקיות = S5 rules (צי-אח). מתועד: god-step/resetToSeed ככתיבות ישירות לא-ליניאריות יוחזרו — הנתיב המוסמך הוא ה-callable.
- **S8.2** `src/credit.ts` + `src/creditCore.ts` — callable `computeCredit({name?})`: port **מדויק** של `contractorCredit` (הפונקציה חיה ב-`logic/manager_dashboard.dart` — שורת-ה-SSOT הפנתה ל-`orders_engine.dart`, סטייה מתועדת): hash-שם → רצועת 30,000–120,000 ₪ → עיגול-מטה ל-₪100. ה-hash = `String.hashCode` של **Dart VM** משוחזר bit-for-bit ואומת אמפירית מול `dart run` (Dart 3.7.2) על 9 שמות כולל עברית+emoji (טבלת-probe ב-`creditCore.ts`; dart2js-web מניב hash שונה — מתועד; **הערך השרתי קנוני**). נגזרות חיות verbatim מהמסך: `used`=Σ`sum` מ-`orders.where(contractorId==name)` · `balance=(limit-used).clamp(0,limit)` · `pct=round(used/limit*100).clamp(0,100)`. הרשאה mirror ל-S5.4: manager/admin כל שם; אחרת רק `users/{uid}.displayName` העצמי.
- **S8.3 (+S6.3)** `src/push.ts` — שני FCM-triggers בעברית: `onOrderStageChanged` (onDocumentUpdated `orders/{id}`) שולח רק על מעבר **חוקי** (reverts/קפיצות מדולגים) ל-`contractorId/storeId/courierId` פחות-המקדם (`stageBy` כשנחתם), גוף `הזמנה {id} · {label}` עם תוויות verbatim מ-`kOrderStageLabel` (התקבלה/בהכנה/מוכן לאיסוף/נאסף/בדרך לאתר/נמסר ✓); `onChatMessageCreated` (onDocumentCreated `chatMessages/{id}`) → משתתפי-thread פחות-השולח, כותרת `הודעה חדשה מ־{displayName|תואר-פרסונה}` + preview-80. tokens מ-`users/{uid}.fcmToken` (S6.1); מזהי-לגאסי בלי users-doc מדולגים בשקט; token מת נמחק (`registration-token-not-registered`).
- **S8.4** `src/audit.ts` — collection `auditLog` append-only: `{at,action,source,actorUid,actorRole,target,before,after,ok,reason?}` נכתב מכל הנתיבים הרגישים — advance (כולל **דחיות** ok:false), revert, computeCredit, getUploadUrl. best-effort (כשל-אודיט נרשם ב-Cloud Logging, לא מפיל עסקה). דרישה ל-S5: rules חוסמים כל client read/write על `auditLog`.
- **S7.2** `src/r2.ts` — callable `getUploadUrl({kind,contentType,fileName?})`: presigned-**PUT** (10 דק׳) דרך aws-sdk v3 (`@aws-sdk/client-s3`+`s3-request-presigner`) מול `https://<account>.r2.cloudflarestorage.com`. `kind` ∈ pod|before-after · contentType ∈ image/* whitelist · המפתח **בבעלות-שרת** `{kind}/{uid}/{ts}-{sanitized}` (אין traversal/דריסה). **אפס creds בקוד**: `R2_ACCESS_KEY_ID`/`R2_SECRET_ACCESS_KEY` ב-Secret Manager (`firebase functions:secrets:set`) · `R2_ACCOUNT_ID`/`R2_BUCKET` ב-`.env` params (v2 — מחליף את `functions:config:set r2.*` ה-v1 שהוצא-משירות; README). חסר-קונפיג → `failed-precondition` ברור.
- **תיקון-תשתית אגבי:** ה-root `.gitignore` מתעלם מכל `package.json`/`package-lock.json` (כלל-לגאסי) — `functions/.gitignore` מחזיר אותם (`!package.json`/`!package-lock.json`) כדי ש-CI/deploy יראו את מניפסט-התלויות; נוסף גם ignore ל-`.env*` (param-values מקומיים).
- Gate: `npm install` ירוק (רשת זמינה; aws-sdk v3 הותקן) · `npx tsc --noEmit` **0 errors** · `npm run selftest` — **53/53 PASS** offline (hash/credit מול probe-אמת של Dart VM · שרשרת-stages · מטריצת-תפקידים מלאה) · `node lib/index.js` נטען ומייצא את כל 7 הפונקציות (setRole + 6 חדשות). פריסה: console/CI בלבד (Blaze + `"functions":{"source":"functions"}` ב-`firebase.json` — README).

### #server-S6 — FCM push (צד-client): token עוקב-זהות + handlers + toast · Phase C — 2026-06-10
- שכבת-ה-push של server-connect (S6.1–S6.2 + ה-hook ל-S6.3): רישום-token ל-`users/{uid}.fcmToken` שעוקב אחרי ה-auth · handlers ל-foreground/background/tap · payload עברי (שה-Functions של S8.3 מלחינים) עולה כ-toast. SSOT: `SPEC-server-connect-MICRO` §S6 + `knowledge/firestore-schema.md` (`users/{uid}.fcmToken`). **push הוא additive**: בלי Firebase (כל הסוויטה / הסנדבוקס) השכבה אינרטית לחלוטין — אפס prompt, אפס fetch, אפס writes.
- **THE SEAM** `lib/state/push_state.dart` — `PushGateway` (abstract): כל מגע-FirebaseMessaging עובר דרך port מוזרק שמדבר ב-`PushMessage{title, body, data}` נייטרלי (לא `RemoteMessage`): requestPermission (authorized/provisional→true) · getToken/deleteToken · onTokenRefresh · onForegroundMessage · initialMessage (tap שהקים מ-terminated, נצרך-פעם-אחת) · onMessageOpenedApp (tap מ-background). המימוש-האמת `FirebaseMessagingGateway` פותר `FirebaseMessaging.instance` **בעצלתיים** (לעולם לא ב-constructor — חוק `FirebaseAuthGateway`/`FirestoreCollectionSource`); ה-streams הסטטיים (onMessage/onMessageOpenedApp) ממופים אך אינם נרשמים עד שה-controller חי (= רק כש-Firebase מאותחל). הערת-web מתועדת: `getToken` דורש VAPID key (console → Web Push certificates) — עד שיוקצה הוא נכשל ב-web ונבלע-נרשם; mobile לא מושפע.
- **S6.1 `PushController`** — ה-token עוקב-זהות: sign-in (uid מ-`authStateProvider`) → requestPermission → getToken → `users/{uid}.fcmToken` (כתיבה דרך writer מוזרק = **אותו seam `RemoteCollectionSource` של S2.2** מכוון ל-`users`; merge-set → לעולם לא דורס `role`/`displayName` של ה-admin) · onTokenRefresh → כתיבה-מחדש תחת ה-uid **הנוכחי** (מנותק → נזרק) · sign-out → ניקוי השדה (`''` — עוצר את שולחי-S8.3) + `deleteToken()` (עותק-שרת-עבש לא ישיג את המכשיר) · החלפת-חשבון A→B → ניקוי-A **לפני** רישום-B. **משמעת-עבודה:** תור-FIFO מסודר (`_chain`) — clear לעולם לא עוקף/נעקף ע"י register; re-check של `_uid` אחרי כל await (משמעת ה-`_gen` של auth_state בתרגום-לתור); re-emissions של claims לאותו uid אידמפוטנטיים (אין re-prompt/re-write). permission-נדחה / token-חסר / write-נדחה → logged+נבלע, **לעולם לא נזרק ל-UI**, וה-chain ממשיך (refresh מאוחר משלים רישום).
- **S6.2 surfaces** — foreground: `pushToastText` (pure: `title · body` / חלק-בודד / data-only→null=skip) → `showGlobalToast` — וריאנט context-free חדש ב-`lib/widgets/toast.dart` (אותו pill, אותו styling — ה-SnackBar מוצה ל-builder יחיד `_toastBar`) המוגש דרך `bsMessengerKey` (GlobalKey שמחווט ל-`MaterialApp.scaffoldMessengerKey`). tap (initial+opened): **seam-ניווט מתועד** — callback `onOpened` מוזרק; ברירת-מחדל רושמת את ה-`data` payload (deep-nav למסך-הזמנה/שיחה מ-`data['type']/['id']` = follow-up מתועד, דורש navigator של ה-shell). background/terminated: `firebaseMessagingBackgroundHandler` top-level ב-`main.dart` (`@pragma('vm:entry-point')`, guard-wrapped — throw היה מפיל את ה-isolate; אין עבודת-data עדיין — pushes של S6.3 הם notification-payload שה-tray מצייר לבד), נרשם רק כש-`Firebase.apps.isNotEmpty` ולעולם לא ב-web (שם זה תפקיד ה-service worker).
- **providers** (`push_state.dart`) — `pushGatewayProvider` + `pushTokenWriterProvider` (null כש-`Firebase.apps.isEmpty` — אותו switch של authGatewayProvider/S2-S3) · `pushControllerProvider`: בנייה + `ref.listen(authStateProvider, fireImmediately: true)` — session משוחזר (notifier נולד-seeded מ-`currentUser`) נרשם בלי לחכות לאירוע-auth חדש; dispose מבטל subscriptions. **חיווט-הערה ב-`main.dart`** (הקובץ של S6 בגל הזה): `ref.watch(pushControllerProvider)` יחיד ב-`BuildSmartApp.build` (providers עצלים — בלעדיו S6.1 לא רץ באפליקציה האמיתית) + `scaffoldMessengerKey: bsMessengerKey` (משטח-ה-toast ה-context-free) — שתי שורות מעבר ל-handler, אפס שינוי-UI אחר.
- **אילוץ-סביבה:** רשת-הסנדבוקס חוסמת Firebase — delivery חי לא נבדק כאן; ה-fakes מקבעים את הלוגיקה ואימות-מכשיר (prompt+push אמיתיים, iOS APNS) = שלב on-device בהמשך. S6.3 (ה-trigger בשינוי-stage/הודעת-צ׳אט) = צד-שרת — S8.3.
- Gate: `flutter analyze lib/state/push_state.dart lib/widgets/toast.dart lib/main.dart test/push_state_test.dart` → **0 errors** (4 ה-infos היחידים = קודמי-S6 ב-main.dart, אומתו על HEAD; toast.dart אף ירד מ-1 ל-0) · `test/push_state_test.dart` **15/15** (fake gateway+writer ידניים: formatting · אינרטי-בלי-Firebase · רישום-once · session-משוחזר · refresh · refresh-מנותק-נזרק · sign-out-clear+deleteToken · A→B בסדר-קפדני · permission-denied · token-null · getToken-זורק · write-נדחה · foreground-hook · initial+opened taps · widget: ברירת-המחדל עולה ב-pill האמיתי דרך `bsMessengerKey`) · שכנים שנגעתי בנתיבם (widget/robustness/product_journey/knowledge_protocol/wiring) **63/63**. הסוויטה המלאה — gate מרכזי (orchestrator).

### #server-S9 — Offline/sync: אימות-persistence + תור-batch-order מפורש + מדיניות-קונפליקטים (S9.1–S9.3) · Phase C — 2026-06-10
- שכבת-ה-offline של server-connect. עיקרון-היושר: ה-offline-persistence של Firestore (S0.4) **כבר מכסה** כל כתיבה-מנוהלת בדפוס-ה-cache — S9 לא ממציא אופליין מחדש אלא (1) מאמת ומתעד את הכיסוי, (2) מוסיף את התור-המפורש המנדטורי-SSOT ל-batch-order, (3) מקבע מדיניות-קונפליקטים. SSOT: `SPEC-server-connect-MICRO` §S9 (שורות S9.1–S9.3). אפס שינויי-מסכים, אפס deps חדשים, ה-API הציבורי של המנוע ללא-שינוי.
- **S9.1 `knowledge/offline-sync.md` (חדש)** — אימות-קוד מלא של שרשרת-ה-persistence: `main.dart` (S0.4) קובע `Settings(persistenceEnabled: true)` מיד אחרי `initializeApp` ולפני כל שימוש (מובטח — `FirestoreCollectionSource` פותר את ה-instance בעצלתיים, לעולם לא ב-constructor); אומת במקור-החבילות (cloud_firestore 6.5.0): native = persistence דיסקית (תור-כתיבות שורד restart), **web = השורה הזו בדיוק מה שממפה ל-`persistentLocalCache` (IndexedDB)** — בלעדיה web היה memory-only. מנייה מלאה של הכתיבות-המכוסות: **כל** כתיבה עוברת `guardWrite` → `set(merge:true)`/`delete` → התור-הנטיבי (orders: place/advance/setStage/reset/seed · chat: send+head · stock: move · site: tasks+stages · finance: decide/penalty/term · customers: זריעה). קריאות = cache-בזיכרון נולד-מ-seed + snapshots מה-cache-המקומי → קריא-במלואו אופליין. אימות-מכשיר חי לא אפשרי כאן (אין רשת — הסתייגות-S4.5); הקוד מקבע את המנגנון.
- **S9.2 `lib/logic/offline_order_queue.dart` (חדש)** — התור-המפורש ל-batch-order (belt-and-braces מעל הנטיבי, וכך מתועד בקובץ): `connectivityProbeProvider` (seam `bool Function()`, ברירת-מחדל **assume-online** → אינרטי בפרודקשן עד probe אמיתי; אין connectivity_plus) · `OfflineOrderIntent` = סט-הפרמטרים המלא של `placeOrder` + `queuedAt`, **בלי id** — ה-`BS-####` מוקצה ב-replay מעל ה-cache שאחרי-החיבור (התור-הנטיבי משחזר doc-id שנבחר-אופליין → שני מכשירים יכולים לדרוס `BS-1043` זה-של-זה; התור-המפורש סוגר את הנתיב) · `maybeEnqueue` סינכרוני (ה-checkout סינכרוני; persist-רקע מנוהל) · מפתח מגורסם `bs.offline-orders.v1` · `drainQueue()` משחזר FIFO דרך ה-seam `ordersRepositoryProvider` (מסלול-הזמנה-חיה, כולל ולידציית-S8 עתידית), no-op כשעדיין offline-suspect ("נשלח בחזרת-רשת") · **שרשרת-serialization אחת לכל פעולות-התור** — בלעדיה שני enqueues מהירים מתהפכים סביב ה-`getInstance` הקר (resume-order הפוך על ה-completer; נתפס בבדיקות) ו-enqueue מול drain יכול להחיות state-שנוקז · crash-safe: השארית נשמרת אחרי כל replay → אין double-place · payload/entry פגום נזרק+נרשם per-entry, לעולם לא מפיל (קול-ה-repos).
- **חיווט מינימלי `lib/state/orders_engine.dart`** (היה-S4, committed) — diff של import×2 + שורה-אחת ב-`ordersEngineProvider`: `unawaited(ref.read(offlineOrderQueueProvider).drainQueue())` אחרי ה-bind — ה-drain רץ ב-init של המנוע (app start), fire-and-forget, ריק-במסלול-הנפוץ; ה-await-prefs דוחה את ה-replay אל-אחרי-ה-build → ה-seam לא נכנס-מחדש mid-build (אין circular read). API ציבורי ללא-שינוי; הקובץ שומר בדיוק את 4 ה-infos שקדמו (אומת מול ה-committed) — 0 נוספו.
- **S9.3 מדיניות-קונפליקטים** (ב-`offline-sync.md`): Firestore = LWW פר-שדה; בצד-לקוח snapshot **מחליף** את ה-cache כולו (אין merge) → התכנסות-דטרמיניסטית לאמת-השרת. טבלת-דומיינים: orders-stage = LWW + ולידציית-S8.1 בשרת · orders-יצירה = נתיב-התנגשות-ה-id המתועד + המיטיגציה (S9.2 / id-שרת ב-S8) · chat = append-only (ids ייחודיים — אין-קונפליקטים מבנייה; head = LWW מתרפא) · stock-move = LWW (המזיז-האחרון) · customers/finance = manager-only. רגרסיה-מקבעת **אחת** נוספה ל-`test/firestore_cached_repo_test.dart` (הורחב, לא שוכפל): "S9.3 — post-write snapshot RECONCILES the optimistic cache" — echo-שרת קנוני, כתיבה-שהפסידה מתכנסת ולא קמה-לתחייה.
- **`test/offline_order_queue_test.dart` (חדש)** — 9 בדיקות, fakes ידניים (`_RecordingOrdersRepo` + override של שני ה-seams), ללא Firebase/package חדש: אינרטי-כשאונליין (ברירת-המחדל — כלום לא נכתב) · offline-suspect → intercept+persist של ה-intent המלא תחת המפתח-המגורסם · drain משחזר FIFO דרך ה-seam (createdAt=queuedAt, id מה-repo) ומרוקן · התור שורד-restart (container טרי, אותו prefs) · אין-double-place (drain מקבילי/עוקב) · drain-באופליין שומר את התור · payload פגום נזרק / entry פגום מדולג והשאר שורד · round-trip JSON (כלכלת-שדות של `Order.toJson`) · **חיווט-ה-init**: intent בתור לפני-המנוע → קריאת `ordersEngineProvider` על הגרף-האמיתי (מסלול-local) מנקזת אותו לתוך המנוע.
- Gate (scoped): `flutter analyze` על 4 הקבצים — **0 errors; 0 issues על הקבצים-החדשים** (ב-`orders_engine` רק 4 ה-infos שקדמו, אומת מול ה-HEAD) · `offline_order_queue_test` **9/9** + `firestore_cached_repo_test` **21/21** (כולל פין-S9.3 החדש) · רגרסיית orders/realtime: 14 סוויטות (orders_engine · realtime_wiring · contractor_checkout · store/courier_stage_advance · persistence_roundtrip · manager_dashboard ×2 · worker_approval · bs_dial_manager_orders · t9_supplier_personas · sys_chat · order_site_canonical · cart_bulk_order) **122/122**. אין commit/push. Next: probe-קישוריות אמיתי + קריאת `maybeEnqueue` ב-checkout (מסך) + trigger-drain בחזרת-רשת; אימות airplane-mode על מכשיר אחרי deploy.

## גידור-Switch (server) + CI-deploy — 2026-06-10

### #server-gate — דגל-בקאנד default-OFF (`backend.dart`)
- **הבעיה ה-live:** S0 מאתחל Firebase ב-web → `Firebase.apps.isNotEmpty` היה TRUE → כל ה-providers נתבו ל-`_firebase` → Firestore ריק+deny-all → אפליקציה ריקה.
- **התיקון:** `lib/data/repositories/backend.dart` — `useFirebaseBackend = bool.fromEnvironment('USE_FIREBASE_BACKEND') && Firebase.apps.isNotEmpty`. ברירת-מחדל **OFF** → ה-live מגיש דמו (`_local`) למרות ש-Firebase מאותחל, עד הדלקה מפורשת (`--dart-define=USE_FIREBASE_BACKEND=true`) אחרי deploy+seed.
- **11 אתרי-switch ב-9 קבצים** הוחלפו ל-`useFirebaseBackend` (6 repos · authGateway · pushGateway+writer · FCM-bg ב-main · chat_repository ההפוך `!useFirebaseBackend`). imports של firebase_core מיותרים הוסרו מ-8 קבצים. UI ללא-שינוי.
- guard: `test/backend_flag_test.dart` (default=false ללא-define / ללא-Firebase) · mutation-verified (default→true תפס RED). analyze 0 · סוויטה 1954/1954.

### #ci-deploy — CI לפריסת Firestore rules + Cloud Functions (repo-root) · 2026-06-10
- workflow חדש בשורש-הריפו: `.github/workflows/firebase-deploy.yml` — אח ל-`firebase-hosting.yml` (אותו ענף, אותו secret). פורס את שכבת-ה-backend (rules + functions) ל-`buildsmart-b0b78` ב-push, בנפרד מ-deploy-ה-hosting. SSOT-ההסכמה: `functions/README.md` (region `me-west1`, דרישת-Blaze) + `firebase.json` (בלוק `firestore`). לא נגעתי באף קובץ מחוץ ל-`.github/workflows/` — `firebase.json`/`firestore.rules`/`functions/**`/`app_flutter` נקראו בלבד.
- **trigger** (מראה את ה-hosting CI verbatim): `on: push` לענף `claude/whats-happening-LyY9G` + `workflow_dispatch`. **concurrency** `firebase-deploy-${{ github.ref }}` עם `cancel-in-progress: true` — push חדש על אותו ref מבטל deploy שרץ.
- **GATE לפני כל פריסה** (שום deploy לא רץ אם אחד נכשל): (1) Flutter `analyze`+`test` — אותו setup של ה-hosting/pages CI: `subosito/flutter-action@v2` channel stable `3.44.0` cache, `flutter pub get` ב-`app_flutter`, `bash scripts/gen_version.sh` (version.g.dart ה-gitignored), `flutter analyze --no-fatal-infos --no-fatal-warnings` (lint-infos/warnings קיימים לא חוסמים — בדיוק כמו `deploy.yml`), `flutter test --reporter=compact`. (2) functions `tsc` — `npm ci` + `npm run build` ב-`functions/`.
- **auth = service-account (לא token אינטראקטיבי):** ה-secret הקיים `FIREBASE_SERVICE_ACCOUNT` נכתב לקובץ-temp (`$RUNNER_TEMP/gcp-sa.json`), `GOOGLE_APPLICATION_CREDENTIALS` מצביע עליו; `npm i -g firebase-tools`; כל `firebase deploy` רץ עם `--project buildsmart-b0b78 --non-interactive`. שום `firebase login`/CI-token.
- **firebase.json read-only — הגישור:** הקובץ ה-committed מכיל `firestore`+`hosting` בלבד, ללא בלוק `functions.source` (ה-README דורש להוסיף אותו לפני deploy ראשון). במקום לערוך אותו, ה-CI מסנתז config-temp ב-`jq` (`. + {functions:{source:"functions"}}` → `$RUNNER_TEMP/firebase.ci.json`) ומריץ את הפריסות עם `--config` עליו → `--only functions` פותר את `functions/` בלי לגעת בקובץ ה-committed.
- **rules — תמיד:** `firebase deploy --only firestore:rules` (עובד על Spark החינמי) — צעד ללא `if`, רץ בכל push שעבר את ה-GATE.
- **functions — מותנה + לא-חוסם:** מזוהה שינוי ב-`functions/` דרך `dorny/paths-filter@v3` (filter `functions: ['functions/**']`; `fetch-depth: 0` ב-checkout כדי שיהיה היסטוריה ל-diff מול ה-base — עמיד ל-`github.event.before` של push-ראשון). הצעד רץ רק עם `if: steps.changes.outputs.functions == 'true'`, בונה תחילה (`npm ci && npm run build` כבר רצו ב-GATE), ועטוף ב-**`continue-on-error: true`** עם echo לפני ואחרי: "⚠️ functions deploy requires the Blaze plan — skipping (non-blocking). Enable Blaze on buildsmart-b0b78 to activate." → ה-workflow לעולם לא נחסם על פער-ה-Blaze הידוע (הפרויקט כרגע Spark). כש-`functions/` לא השתנה — צעד-note מדלג מפורשות (rules כבר נפרסו).
- **דגל-ה-backend לא נוגע:** ה-CI **לא** מעביר `USE_FIREBASE_BACKEND` ולא שום `--dart-define` לאף build — ה-web החי נשאר demo (ה-backend מאחורי דגל default-off של צי-האפליקציה). ה-workflow הזה פורס rules+functions בלבד, לא בונה/פורס web ולא מסיט את הדגל.
- Validate (ללא deploy חי): `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/firebase-deploy.yml'))"` → OK · אומת תכנותית: rules-always (ללא `if`), functions conditional+`continue-on-error`, paths-filter על `functions/**`, אפס `--dart-define`, jq-merge מוסיף את בלוק-ה-functions נכון. **לא** בוצע `git commit`/`push`.

### #server-gate-auth — חיווט welcome→login (סגירת ה-gap של ה-preview) — 2026-06-10
- **ה-gap (preview-test):** `welcome_screen` עשה onboarding מקומי (`continueAsDemo`) ולא קרא ל-Firebase auth; `login_sheet` (S1) היה יתום. עם `useFirebaseBackend=true` → ה-repos של `_firebase` פעילים אך אין auth → S5 Rules חוסמים → אפס persist.
- **התיקון:** כש-`useFirebaseBackend` → "כניסה ללקוח קיים"/"רישום" מנתבים ל-`showLoginSheet` (phone-OTP/מייל). `_enterViaAuth` ממתין לסגירת-ה-sheet, ואחרי `authStateProvider.signedIn` → mirror של `{displayName, phone}` ל-`users/{uid}` (merge דרך `usersProfileWriterProvider`, rules-safe — role נשאר admin-only) + `welcomeSeen=true` (כניסה). sheet שבוטל (עדיין signed-out) → נשאר ב-welcome לניסיון חוזר. `continueAsDemo` נשאר ל-flag-OFF + לקישור "המשך ללא רישום (דוגמה)".
- `usersProfileWriterProvider` (`auth_state`) — seam של collection `users`, null בלי backend (אותו `useFirebaseBackend` gate). UI ללא-שינוי (רק לוגיקת-onPressed).
- guard: `test/welcome_auth_gate_test.dart` (3 · flag-OFF=דמו · writer=null בלי Firebase · welcome מרנדר). נתיב flag-ON (OTP חי) נבדק ב-preview-channel האמיתי (מכשיר — הסנדבוקס חוסם Firebase).
Gate: analyze 0 · `welcome_auth_gate` 3/3 + סוויטה מלאה ירוקה.

### #boot-guard — Firebase init לא חוסם עלייה (web white-screen fix) — 2026-06-10
- **הבאג:** S0 הוסיף `await Firebase.initializeApp` לא-מוגן ב-`main.dart` — על web (localhost) האתחול נתקע ~60ש' וזרק חריגה לפני `runApp` → מסך לבן קבוע (אומת לייב :5556 + console exception).
- **התיקון:** עטיפת init+Firestore-settings ב-`try/catch` + `.timeout(8s)` — נאמן לאינווריאנט S0 המוצהר ("a failure here must never block app start"): בכשל `Firebase.apps` נשאר ריק → כל ה-swap של S2/S3 (`Firebase.apps.isNotEmpty`) נשאר על הנתיב הלוקאלי וה-UI עולה רגיל.
- Gate: build web עבר · אומת לייב — הבית עולה מלא (v6.16).
### #boards-65-76 — רישום/זהות + לוח-עובד שלם + לוח-שליח שלם (נחיל 16 סוכנים) — 2026-06-10
- **#65 זהות** (`state/board_auth.dart`+`data/board_accounts_local.dart` חדשים): BoardRole{worker·courier·store·manager} · BoardSession persist `bs.board-auth.v1` (_userTouched guard) · login/enterDemo/logout · חשבונות-דמו ran/1111·omer/2222·dudi/3333·lipskey/4444·admin/5555 + kRoleSwitchCode='1234' (SERVER-SWAP). מסך-הרישום הקיים במצב-תפקיד — **אפס שינוי ויזואלי/טקסט** (boardRole param; השדה השני=קוד/מזהה; 'המשך ללא רישום'=דמו; validBoardCode חדש ב-input_validators). חוק-השער: בלי session — הלוח בונה רק את שער-הרישום (role_picker _BoardGateRoute + שומרים ב-store/manager/worker dashboards). in-place swap: login הופך gate→board בלי ניווט.
- **#66-71 לוח עובד** (`worker_app_screen` + 4 קבצים חדשים): זהות מה-session (ran→רן·omer→עומר·דמו→רן+צ'יפ'דמו'), מתג רן/עומר הוסר — עובד רואה רק את שלו · 4 טאבים תחתונים (משימות·שיחות·דוחות·אזור-אישי, סגנון home_shell) · `worker_task_detail_sheet` — צ'ק-ליסט שלבים+תמונה+שלח-לאישור (dual-write tasksProvider+workerTasksProvider, mirror החלטות-מנהל) · `worker_profile_screen` — סטטיסטיקה+החלפת-תפקיד בקוד-1234+יציאה · `worker_settings_screen` — פרופיל/התראות/אזור-ושפה/נגישות/מידע בלבד.
- **#70/#75 צ'אט-audience** (`chats_screen`+`sys_chat`+`data/chat_seeds.dart` חדש): ChatThread.audience ('contractor' default — התנהגות-קבלן byte-identical) · ChatsScreen(audience:, embedded:) · עובד: קבלן·מנהל·בוט · שליח: חנות·לקוח·שליחים·בוט — threads-דמו כנים שמפנים למשימות/משלוחים האמיתיים.
- **#72-76 לוח שליח** (`courier_dashboard` + 5 קבצים חדשים): שער-session · בחירת-רכב→בית · 4 טאבים (משלוחים·פורטל·דוחות·אזור-אישי) · `courier_delivery_detail_sheet` — "הקש לפרטים" אמיתי (פריטים/לקוח/tracker/POD) + סינון-רכב כן ("דורש רכב אחר" מקובץ) · `courier_portal_tab` — POD/צ'אט/צי/אזורים מחווטים לוקאלית, ניווט/SLA מוכני-שרת ('יחובר עם חיבור השרת') · `courier_reports_tab` — היסטוריית-מסירות מהמנוע · profile+settings ייעודיים (1234).
- תיקון-אוריינטציה שלי: 4 קריאות `WelcomeScreen(role:)`→`boardRole:` (אי-התאמת חוזה W↔A) · עדכון `worker_app_test` לזריעת session (השער החדש) — analyze 0 errors.
- Gate: בדיקות חדשות `board_auth_test` 8/8 + `worker_task_scope_test` · מוטציה (קוד ran) נתפסה-שוחזרה · full-suite בריצה.
### #worker-v2 — לוח עובד v2 מלא·יעיל·מקדם (#85) + תיקון 23 ממצאי-אודיט — 2026-06-10
- **#85א כניסה:** role-mode עבר ל"כניסה ללקוח קיים" (שם-משתמש+קוד inline, שגיאה 'שם משתמש או קוד לא נכונים'); רישום-ראשוני נשאר לקבלן; גילוי-אורח כן בקבלן.
- **#85ב צילום-חובה:** `services/task_photo.dart` + `screens/webcam_capture_sheet.dart` חדשים — בדסקטופ-web מצלמת getUserMedia אמיתית (camera+camera_web, תצוגה-חיה+צלם+X), fallback הוגן לקובץ; שלח-לאישור חוסם בלי תמונה, preview, התמונה ל-TaskItem.photo (data-URL) ומוצגת למנהל באישור (+ הערת-העובד דרך richMatch). תוקן באג זריקת-תמונה בשלח-מהיר (worker_app _submit→submitWithProofPhoto).
- **#85ג/ה לוח:** X לכל ה-sheets · `worker_today_strip` (DayStage לפי worker) · "מה להביא" (`data/task_skus_local` + recommendedKitForProduct) · ברקוד (+מק"ט ידני ב-barcode_scanner) · 💡 HelpTarget · הערה-קולית (voice onError+מצב-מקליט).
- **#85ו מנועים:** `state/worker_notifs.dart` (פעמון+badge, per-username, bs.worker-notifs.v1) — אירועי אושרה/נדחתה/חופשה · מטבעות awardCoins בזמן-החלטת-מנהל (rich approve במקביל ל-lean, guard מונע כפל) · rewards persist bs.rewards.v1 · שעון startedAt/completedAt + התחל-עבודה · שלבי-משימה doneSteps+toggleStep persisted.
- **#85ז דוחות:** `screens/worker_reports_tab.dart` — גרף-שבועי, אישור-ראשון %, זמן-למשימה, מטבעות+רצף-אמיתי-משעון, פירוט-אתר, היסטוריה עם תמונות-לחיצות (InteractiveViewer), דחיות+סיבת-מנהל (דיאלוג-סיבה בשני זרמי-הדחייה), שלח-דוח-יומי→צ'אט.
- **#85ח HR:** `worker_attendance` (כניסה/יציאה+דוח-חודשי+שלח-לקבלן) · `worker_forms` (טופס-101 ממולא-מהפרופיל, בקשת-חופשה→תור-מנהל בניהול+החלטה→פעמון, אישור-מחלה עם צפיין) · `worker_safety` (הדרכות+ארנק-תעודות+תוקף+צילום) · `worker_payslips` (מוכן-לשרת) · פרופיל-עריכה מלא (worker_profile_store, save→bool+טוסט-קוטה).
- **רוחבי:** chats _visibleToAudience — קבלן/מנהל רואים threads-עובד שהם משתתפים בהם (דוח-יומי/נוכחות/101 כבר לא write-only) · `manager_profile_screen` חדש + התנתקות אמיתית למנהל ולחנות.
- Gate: analyze 0 · בדיקות 21/21 (vacation-id-collision נתפס ותוקן ב-_seq מונוטוני) · אודיט-עומק 114 ממצאים: 88 עובדים, 23 שבורים→תוקנו כולם, 3 server-stubs כנים.
### #merge-fix — יישוב rebase מול server-track (S5/S6) — 2026-06-10
- `welcome_screen._existingLogin`: סדר-עדיפויות ממוזג — שער-לוח (קוד #65) → Firebase-OTP (useFirebaseBackend) → גילוי-אורח (#19). שני ייבואי-auth (auth_state+board_auth) דרים יחד גם ב-role_picker.
- `sys_chat.resetToSeed`: reset-מרוחק של ה-server-track + ה-seed המקומי המלא (כולל threads-audience #70/#75).
- `BackendDebugBadge`: topRight→topCenter — ב-RTL ישב על לוגו BuildSmart ובלע את הקליק לבוחר-התפקידים (נתפס ע"י widget_test 'BS dial opens 5 personas').
- Gate: analyze 0 · בדיקות-רגישות 30/30 (board_auth/onboarding/sys_chat/widget).
### #build-fix — DropdownButtonFormField value: (Flutter 3.29) — 2026-06-11
- **הבאג:** מיזוג e8ae1dd השאיר `initialValue:` (API של Flutter מאוחר) על `DropdownButtonFormField` ב-`worker_forms_screen.dart:172` (טופס-101, שדה מצב-משפחתי) — בטולצ'יין 3.29 הפרמטר הוא `value:`, ולכן `undefined_named_parameter` ו-build web נכשל (חסם push).
- **התיקון:** `initialValue:` → `value:` (טוקן יחיד, אפס שינוי התנהגותי). זה היה ה-error היחיד; כל השאר info/lint.
- Gate: analyze 0 errors · build web --release ירוק (46s).
### #A2-uid-seam — currentUidProvider (חשיפת auth.uid לשכבת-הנתונים · נחיל Phase A) — 2026-06-11
- **A2 (חוסם-השקה):** נוצר `currentUidProvider` ב-`auth_state.dart` — נגזר מ-`authStateProvider`, מחזיר `user?.uid` (null בלי-Firebase/signed-out, עוקב login/logout חי). זה הקיסטון ש-A3–A6 קוראים כדי למקד reads/writes ל-uid המחובר. מיפוי-נחיל אישר: שדות היעד כבר קיימים (orders=`contractorId` · customers=`ownerId` · chat=`participants`) ו-A1 הוסיף `scope` אופציונלי ל-`FirestoreCollectionSource`.
- **בטיחות — אפס רגרסיה:** A2 רק **חושף** את ה-uid; **לא הדליק scoping**. הדלקת scope עכשיו הייתה שוברת הכל (אף doc עוד לא נושא uid → כל query חוזר ריק). לכן A3–A6 (כתיבת השדות + backfill + הדלקת scope) באים יחד אחר-כך, מאחורי דגל.
- guard: `auth_state_test` קבוצת 'currentUidProvider — A2' (signed-out→null · signed-in→uid · logout→null). מוטציה (`return null`) הזריקה → signed-in האדים (שורה 422) → שוחזר → ירוק.
- Gate: analyze 0 · auth_state_test 26/26.
### #A3-uid-write — orders נושאות contractorUid (auth.uid · נחיל Phase A) — 2026-06-11
- **A3 (חוסם-השקה · בנאי+supervisor):** הוסף `Order.contractorUid` (אופציונלי, default '') — מוטבע על הזמנה חדשה מ-`currentUidProvider` ב-checkout. מחווט מקצה-לקצה: model (ctor · copyWith שמשמר · toJson · fromJson) · `placeOrder` (engine · firebase · repository · local) · orders_firebase toDoc/fromDoc · store_screen checkout. **אדיטיבי ונייטרלי-תצוגה:** `who` עדיין מניע כל UI; נכתב רק כשלא-ריק (seed/legacy round-trip ללא שינוי). A4 ימקד את ה-listen על השדה הזה.
- guard: `orders_uid_a3_test` (8 · toJson/fromJson · toDoc/fromDoc · copyWith-preservation; ריק מושמט = אפס רגרסיה). מוטציה: שבירת copyWith → preservation האדים (Expected 'u-9'/Actual '') → שוחזר → ירוק.
- Gate (supervisor-verified): analyze 0 · full-suite +2008 · build web ✅. (`pubspec.lock` re-resolution מ-pub get לא נכלל — ארטיפקט-סביבה.)
### #fleet-9x9 — שליח-v2 + ספק #77-83 (נחיל קנוני PLAYBOOK, worktree) — 2026-06-11
- **צינור מלא:** 10 אודיטורים-לפי-עדשה (registry) → 49 ממצאים · ולידציה-אדברסרית פסלה 23 FP · 26 CONFIRMED → 10 fixers על מפת-קבצים זרה · supervisor אימת בייטים · central-verify ירוק (analyze 0 · בדיקות · build).
- **שליח v2:** POD אמיתי — pickTaskPhoto (webcam) ב-persona_pod_sheet, `podCaptured bool`→`podPhoto String?` (data-URL, persona_fulfillment + back-compat getter) — מוצג לחנות ולמנהל · מטבעות+פעמון ב-courierAdvance→delivered (guard מונע-כפל) · `courier_reports_tab` נכתב-מחדש: גרף-מסירות, זמן-ממוצע, KPI מטבעות+רצף-אמיתי, תמונות-POD לחיצות, שלח-דוח-יומי→חנות (נראה לחנות).
- **ספק:** #77/#78 טאבים-תחתונים (בית=צינור-ההזמנות + צי/עדכון-מלאי בבית, שיחות-טאב) · #79 StoreProduct overlay (bs.store-products.v1, תג 'נוסף ע״י הספק') + זמינות↔קטלוג · #80 חיפוש-מלאי name+sku+category · #81 חוסר דו-צדדי — ההחלטה ירדה מצד-הספק; ממתין-לקבלן persist + sheet-החלטה לקבלן · #82 SupplierSettingsScreen (פרופיל-עסק) · #83 4 threads-ספק (קבלנים·שליח-איסופים·מנהל·קבוצת-ספקים)+בוט, נראות דו-צדדית.
- עדכוני-בדיקות (orchestrator): podPhoto migration · t9 לטאבים-החדשים (scrollable מפורש) · sys_chat — בוט-בחנות (spec #83) + seed-lock ל-audience (סגירת mutation-survival).
- Gate: central-verify PASS · מוטציה audience הוזרקה→נתפסה(אחרי הנעילה)→שוחזרה.
### #wave1-hide — הסתרת 5 מחלקות + 2 מקצועות לא-בנויים + תיקון activeThumbColor (נחיל-placeholders גל-1) — 2026-06-11
- **הסתרה (החלטת-בעלים · אדיטיבי-הפיך · סינון-render בלבד):** `departments_screen` → `where((d)=>d.live)` (מסתיר חשמל·חומרי בניין·צבע·גבס·אספקה טכנית) · `smart_home_screen` `_Departments` → `.where(live).take(3)` · `profession_screen` picker → `where(!kComingSoonTrades)` (מסתיר חשמלאי·שיפוצים). הנתונים נשמרו (re-enable = flip live:true / הסר מ-kComingSoonTrades). אין יותר "בקרוב" גלוי — חוסם-אפל.
- **תיקון-build נלווה:** `store_dashboard_screen.dart:2371` `activeThumbColor`→`activeColor` — שריד מ-fd1b9d9 (API של Flutter מאוחר שלא קיים ב-3.29; היה ה-error היחיד וחסם build לכל האפליקציה). זהה-במחלקה ל-#build-fix (worker_forms initialValue).
- guard: `placeholder_hide_test` (3 · המחלקות/מקצועות המוסתרים `findsNothing`, החיים present). מוטציה: הסרת `where(live)` → 'חשמל' חזר → אדום → שוחזר → ירוק.
- מצאי-placeholders מלא נשמר: `knowledge/PLACEHOLDER-INVENTORY.md` (תוכנית 6-גלים · 8 פריטי-🔑 לבעלים).
- Gate: analyze 0 · full-suite +2012 · build web ✅.
### #personal-v2 — אזור אישי שליח+ספק #86/#87 (נחיל קנוני PLAYBOOK, worktree fleet/personal-areas) — 2026-06-11
- **צינור מלא:** 10 אודיטורים-לפי-עדשה → 57 ממצאים · ולידציה-אדברסרית: 54 CONFIRMED + 3 ADJUST + 0 FP · 10 fixers על מפת-קבצים זרה (חוזים חוצי-קבצים נחתמו מראש ב-_confirmed.md) · supervisor אימת 110 markers בייט-בייט: CLEAN, אפס שקרים · בדיקות-אורקסטרטור: 51 נוספו.
- **שליח (#86):** פרופיל בעריכה — שם/טלפון/רכב-מועדף(kHaulTypes)/תמונה (`bs.courier-profile.v1`, ‎#24 idiom) · נוכחות — שעון+יומן-חודשי+שלח-דוח-**לחנות** (th-store-courier-pickups, guard-thread, `bs.courier-attendance.v1`) · טפסים — 101 לחנות · חופשה בתור-המנהל המשותף (שדה `role` חדש ב-VacationRequest, back-compat) · אישורי-מחלה בצילום (`bs.courier-forms.v1`) · תעודות-נהג — presets רישיון-נהיגה/ביטוח-רכב/רישיון-רכב + רמזור-תפוגה (`bs.courier-certs.v1`) · תלושים — reuse `showWorkerPayslipsSheet` כמו-שהוא · כרטיס אזור-אישי 4 כניסות.
- **תיקון הבאג הגלובלי:** `Fulfillment.courierUser` (json 'cu', legacy→null) נחתם ב-capturePod+מסירה בכל 3 נקודות-advance (dashboard·detail-sheet·pod-sheet); סטטיסטיקת הפרופיל/הדוח-היומי מסוננת "על-ידי" עם תוויות כנות; `bs.courier-clock.v1` קיבל writers (היה מפתח-מת — אפס מדדים לנצח); capturePod הפך `Future<bool>` עם rollback וטוסט-כן (אין יותר "נשמר" שקרי על quota-fail).
- **ספק (#87):** `bs.store-profile.v1` per-username (מיגרציה כנה מהרשומה הגלובלית `bs.supplier-settings.v1` — לא נמחקת) · זהות הלוח חיה (כותרת+ברכה מ-override, fallback מתועד ל-seed) · אייקון-פרופיל לא דולף יותר ל-ProfileScreen של הקבלן · טאב חמישי "אזור אישי" — StoreProfileBody: פרופיל-עסק·תעודות-עסק (presets רישיון/ביטוח-עסק, `bs.store-certs.v1`)·מסמכים SERVER-READY (12 חודשים נעולים, אפס סכומים)·סטטיסטיקה עם `deliveredRevenue` חדש (by-design כלל-חנותי, מתועד) · SupplierSettings gated+commit-מפורש (לא עוד persist-לכל-הקשה ולא טוסט-הצלחה-שקרי על לוגו).
- **רוחבי:** גשר-audience שיחות שליח↔חנות (הדוחות נראים בשני הצדדים) · החלטות-חופשה מנותבות לפי תפקיד (🛵/🦺 אצל המנהל) · ארכיון/השתקה/lastRead/ניקוי-צ'אט קוננו per-username עם מיגרציה (3 צורות payload) · `BsTokens.dangerDark` + ניגודיות AA על מילויי-מותג · mounted-guards ב-8 stores · sys_chat merge-on-write + תקרת-persist 200 · מופעי-עובד של אותם דפקטים → `_backlog.md` (מחוץ-למנדט).
- Gate: analyze 0 errors · supervisor CLEAN (110 markers) · central-verify על ה-worktree · בדיקות חדשות: courier_profile_store/hr/clock · store_profile_store · fulfillment courierUser+back-compat · vacation role · sys_chat cap+merge · t9 טאב-ספק-חמישי.
### #wave2-b1 — חיבור הגדרות-תצוגה בקטלוג (נחיל-placeholders גל-2 מנה-1) — 2026-06-11
- **חובר (היה `_PlaceholderRow` "בבנייה"):** 5 הגדרות-תצוגה → `catalogSettings` (השדות showVat/currency/showUnitPrice/unit/decimalFormat כבר היו, פשוט לא חוברו ולא נצרכו): מע"מ (×1.17) · מטבע (₪/$/€ סמל) · מחיר-ליחידה · מטרי/אימפריאלי · פורמט-מידות. הוספו helpers טהורים ב-`catalog_settings.dart` (`priceWithVat`/`currencySymbol`/`formatCatalogPrice`/`formatDimValue`).
- **הקטלוג מכבד:** `lipskey_product_sheet` — 3 אתרי-מחיר דרך `formatCatalogPrice` (מע"מ+סמל+"ליחידה"), טבלת-מידות דרך `formatDimValue` (mm→inch). פקדים אמיתיים ב-`catalog_settings_screen` (Switch/RadioGroup).
- 🔑 deferral יחיד: "השוואת מחירים בין ספקים" (דורש feed-ספקים חי) — נשאר placeholder, מתועד (אין זיוף).
- guard: `catalog_price_units_settings_test` (16 · persist round-trip ×5 · VAT math · symbols · dim format · 3 widget). מוטציה: שבירת `priceWithVat` → 2 assertions אדום → שוחזר.
- Gate: analyze 0 · full-suite +2028 · build web ✅.
### #wave2-b2 — שאר מתגי-הקטלוג: מיון + התראות-מועדפים (נחיל גל-2 מנה-2) — 2026-06-11
- **חובר:** `מיון ברירת מחדל` → `productSortDefault` + `catalogProductSortProvider` — הקטלוג מתמיין מיד (`sortCatalogProducts` הוזז ל-state, 4 call-sites עודכנו). 5 toggles-התראות (ירידת-מחיר/חזר-למלאי/מלאי-נמוך/מוצרים-חדשים/שינוי-מחיר-במועדפים) → העדפה נשמרת (delivery מגודר על מערכת-ההתראות, מתועד בקוד).
- **🔑 נדחו ביושר (~10, אפס זיוף):** 5 סינוני-ספקים + רדיוס-חיפוש (למוצרי-lipskey אין שדות זהות-ספק/דירוג/מרחק/geo — פער-דאטה, לא רק מפתח) · סנכרון-מועדפים/שיתוף-רשימה/יבוא-יצוא (backend). השדות קיימים ב-state, לא-מחוברים, מתועד.
- guard: `catalog_sort_alerts_settings_test` (16 · סדר-מיון AZ/ZA/SKU+טוהר · persist ×6 + bogus-fallback · 3 widget). מוטציה: היפוך comparator → nameAZ אדום → שוחזר.
- Gate: analyze 0 · full-suite 2096 · build web ✅.
### #wave2-b3 — חיבור הגדרות-התראות in-app (נחיל גל-2 מנה-3) — 2026-06-11
- **חובר:** toggle עובד/שליח (`personaWorker/Courier`) → שער `boardFeedEnabled` על feed-הפעמון החי (worker_notifs/courier_dashboard) · `pushEnabled` הורחב לגדר את שני ה-feeds (היה badge בלבד) · sound/vibration → haptic+SystemSound כשה-unread **עולה** (מושתק ב-snooze/quiet-hours).
- **🔑 נדחו ביושר:** persona קבלן/חנות/admin (אין feed-פעמון ייעודי) · type-toggles (אין שורות-feed מהסוגים) · quiet-shabbat/meetings/driving + sound-per-type + LED + lock-screen + quick-actions + summaries (דורש ערוצי-push נייטיב/חיישנים/scheduler) · email/SMS/WhatsApp (requiresServer). markers-יושר נשמרו על הנדחים.
- guard: `notif_settings_wiring_test` (14 · gating · provider empty/restore · feedback-predicate כולל snooze/quiet · persist). מוטציה: שבירת זרוע-`boardFeedEnabled` → 3 אדום → שוחזר.
- Gate: analyze 0 · full-suite 2110 · build web ✅.
### #wave4-ai — כלי-AI על דאטה אמיתי (נחיל גל-4 · supervisor-verified) — 2026-06-11
- **🟢 מחושב באמת (6):** חיזוי-מלאי (`computeStockForecast` מ-ordersEngine+smartCart — צריכה/קצב/ימים) · analytics (`computeAnalyticsInsights` מ-orders — count/sum/avg/open-delivered/חיסכון/תקציב) · חלופות-זולות (`aiAlternatives` מעל price-tiers) · סריקת-תוכנית/ברקוד/דיבור (מחוברים לחיפוש/cart החיים). כל מחושב נושא תג `🧮 מחושב`.
- **🔑 נדחו ביושר (3, לא מזויף):** התאמה-משולשת (דורש תעודות-משלוח+חשבוניות) · מזג-אוויר (API) · בלאי (חיישני-IoT) — כל אחד עם הערת `⚙️ בפרודקשן: דורש X`.
- guard: `ai_hub_compute_test` (14 · forecast/analytics/alternatives על דאטה+קצוות). מוטציה: שבירת fold-הצריכה (`+`→`-`) → 5 assertions אדום → שוחזר.
- Gate (supervisor-verified): analyze 0 · full-suite +2124 · build web ✅.
### #B1-B4 — ניקוי-אפל: תג-בדיקה debug-only + קטגוריות-ריקות מוסתרות (נחיל) — 2026-06-11
- **B1:** `BackendDebugBadge` → debug-only — `main.dart` `debugOverlayChildren(isDebug: kDebugMode)`; ב-release/web-release (kDebugMode=false) לא מרונדר כלום (הווידג'ט נשמר ל-dev).
- **B4:** 5 קטגוריות-קטלוג חסרות-תוכן (חימום מים·מטבח·גופי תברואה·בנייה ומחיצות·גמר) מסוננות (`_categoryHasContent`+`where`, הפיך — הנתונים נשמרו); 8 נשארות, אפס "בקרוב" גלוי. `_TreeComingSoon` נשאר fallback בלתי-נגיש.
- guard: `debug_badge_gate_test` (3) + `catalog_coming_soon_hide_test` (2) + עדכון `widget_test` (8 קטגוריות, אפס "בקרוב"). מוטציה: הסרת gate-ה-debug → release-test אדום → שוחזר.
- Gate: analyze 0 · full-suite +2129 · build web ✅.
### #wave3-camera — מצלמה אמיתית ב-camera_sheet (נחיל גל-3) — 2026-06-11
- **חובר:** `camera_sheet` — לכידת-מצלמה+גלריה (היה 🚧 "בבנייה" מדומה) → seam בר-הזרקה `taskPhotoPickerProvider` (ברירת-מחדל = `pickTaskPhoto` הקיים: web getUserMedia→file-input · mobile camera→gallery, מחזיר data-URL). `_ShutterButton` אמיתי + דיאלוג-אישור (preview); `openCameraSheet` מחזיר את ה-data-URL; ביטול/כשל = no-op חינני. flash/ברקוד ללא-שינוי. לא נגעתי ב-persona_pod (churn מקביל). אפס plugin חדש.
- guard: `camera_sheet_capture_test` (3 · capture→deliver · cancel→no-op · gallery — דרך fake-seam). מוטציה: `Navigator.pop(dataUrl)`→`pop()` → 2 אדום → שוחזר.
- **caveat (owner device-test):** לכידת-חומרה אמיתית (מצלמה/גלריה פיזית) מאומתת רק על מכשיר; ה-fake מוכיח חיווט+build בלבד.
- Gate: analyze 0 · full-suite +2132 · build web ✅.
### #phaseG — חוקי-שרת ownership + אינדקסים + בדיקות-emulator (נחיל) — 2026-06-12
- **תיקון-אבטחה אמת:** ה-rules גידרו בעלות-הזמנה על `contractorId` — אבל זה מחזיק את ה**שם** (`Order.who`), לא uid → היו **דוחים מקבלן את ההזמנה שלו**. תוקן ל-`contractorUid` (השדה האמיתי מ-A3, helper `ownsOrder()`): קריאה=בעלים/assignee/manager/admin · יצירה=קבלן ב-stage 'new' עם `contractorUid==uid` או manager. backward-tolerant (seed בלי uid עדיין manager-readable).
- **G1 אינדקסים** (`firestore.indexes.json` חדש · 6): orders `contractorUid+ts` (פעיל) · storeId/courierId/customers `ownerId`/chat `participants` (forward-ready) · chatMessages `threadId+ts` (פעיל).
- **G2/G3:** customers `ownerId`-or-manager · chat `participants` (forward-ready) · `rules_test/orders.test.js` 17 בדיקות + harness (`package.json`).
- **אימות:** אמולטור-Firestore **רץ** (firebase-tools 14.27 + rules-unit-testing v4) → **17/17 pass**. analyze 0. (לא קוד-אפליקציה.)
- **owner-deploy:** `firebase deploy --only firestore:rules,firestore:indexes --project buildsmart-b0b78`.
### #A8-A11 — הכנת-זהות: צ׳אט fromUid + לקוחות ownerId (נחיל) — 2026-06-12
- **A8 צ׳אט:** הודעה נושאת `fromUid` (ליד `fromRole`) — `sys_chat` (model+toJson guard+send-param) · `chat_firebase` toDoc/fromDoc · `chat_repository` interface · `chats_screen` מטביע מ-`currentUidProvider`. participants של threads נשארים role-based (forward, post-S1).
- **A11 לקוחות:** `customers_firebase` toDoc(guard)/fromDoc נושא `ownerId` · `ManagerCustomer.ownerId` (manager_dashboard). forward-ready — אין כיום write-path ציבורי ללקוחות (נגזרים מהזמנות) → unset עד שיהיה; מתועד, אפס זיוף.
- אדיטיבי · display-neutral · אפס-רגרסיה (נכתב רק כשקיים; seed/legacy round-trip). scoping + ה-rules (Phase-G, forward-ready) מופעלים ע"י קונסול.
- guard: `chat_uid_a8_test` + `customers_uid_a11_test`. מוטציה: שבירת fromUid → אדום (Expected 'u-7'/null) → שוחזר.
- Gate: analyze 0 · full-suite ירוק · build web ✅.
### #A7 — מדריך users role/phone→uid (נחיל) — 2026-06-12
- **A7 (infra ל-A4/A8):** `UsersLookup` חדש (`lib/data/repositories/users_lookup.dart`) מעל אוסף `users` (doc-id=uid, נכתב ע"י usersProfileWriterProvider · {displayName, phone, role?}): `uidByPhone(phone,{role})` · `uidsByRole(role)` · `usersLookupProvider` (gated על useFirebaseBackend, null בלי-backend). seam בר-הזרקה (RemoteCollectionSource) — בר-בדיקה בלי Firebase. **לא חובר עדיין ל-A4/A8** (אדיטיבי, אפס שינוי-התנהגות).
- guard: `users_lookup_a7_test` (10 · hit/miss/empty · role-narrow/exclude · uidsByRole · snapshot-error→null · provider-null-בלי-backend). מוטציה: היפוך predicate-הטלפון → 4 אדום → שוחזר.
- Gate: analyze 0 · full-suite +2155 · build web ✅.
### #A12 — מסך הקצאת-תפקיד למנהל (נחיל) — 2026-06-12
- **A12:** `manager_role_assign_sheet.dart` חדש — מנהל מזין משתמש (טלפון→uid דרך `UsersLookup.uidByPhone`, או uid ישיר) + בוחר תפקיד (store/courier/worker/manager) → קורא ל-`assignRole({uid,role})` הקיים (S1.9). mount מינימלי ב-manager_dashboard ניהול-tab (סקשן 🔑 שיוך תפקידים). **gated בלי-backend** (banner אמבר, אפס שיוך מזויף); כשל-שרת=טוסט-נכשל; הצלחה רק על setRole שלא זרק.
- guard: `manager_role_assign_sheet_a12_test` (5 · phone→uid forwards {uid,role} · uid-ישיר · phone-לא-נמצא→אין-call · דחיית-שרת→נכשל · בלי-backend→disabled+banner). מוטציה: uid→'MUTANT' → 2 אדום → שוחזר.
- **owner/backend:** השיוך בפועל רץ מול `setRole` Cloud Function (me-west1, מאמת admin-claim שרת-צד). UI מושבת נקי בלי-backend.
- Gate: analyze 0 · full-suite +2160 · build web ✅.
### #B8 — הרשמה אמיתית: אומת (כבר מחווט) + בדיקת-שמירה (נחיל) — 2026-06-12
- **B8 = כבר מחווט (S1), אפס פער-קוד:** משתמש-חדש → חשבון אמיתי. welcome `_register` → (flag ON) `_enterViaAuth` → `showLoginSheet` (phone-OTP יוצר חשבון Firebase על אימות-ראשון) → mirror `{displayName, phone}` ל-`users/{uid}`. flag-OFF=דמו (gateway+writer=null). אימייל=login-fallback (אין signup מזויף).
- guard: הורחב `welcome_auth_gate_test` (+2): flag-OFF `_register` כותב 0 ל-users (נעילה מול רגרסיה שתמציא חשבון בדמו) · צורת-mirror `users/{uid}` ({displayName,phone}, uid-keyed, ריקים מושמטים). flag-ON routing = device-only (מתועד).
- מוטציות: הסרת flag-gate ב-`_register` → אדום · key `displayName`→`name` → אדום · שניהם שוחזרו.
- Gate: analyze 0 · full-suite +2162 · build web ✅.
### #A4-A6 — בעלות-הזמנה multi-user: claim-on-first-advance + pool (נחיל · לפי SPEC) — 2026-06-13
- **A4 (claim/no-steal):** `Order.storeUid`/`courierUid` (אדיטיביים, default '') · `claimStore`/`claimCourier` (מנוע+repo+firebase) — תובע רק כשריק (no-steal), uid-ריק no-op · `sys_orders` storeAdvance/courierAdvance תובעים מ-`currentUidProvider` לפני קידום.
- **A5 (scope · gated):** דגל `kUidScopedQueries` (`backend.dart`, default false). ON → contractor=`contractorUid==uid` · store=pool(`storeUid==''`∧store-stage)∪own(`storeUid==uid`) · courier=אנלוגי · manager=ללא. **OFF=אפס-רגרסיה** (short-circuit לפני watch של role/uid; נעול בבדיקה).
- **A6 (דשבורד):** store/courier dashboards מסננים pool∪own כש-flag ON (`visibleOrderIdsProvider`/`orderVisibleToRole`); OFF=ללא-שינוי.
- **rules+emulator:** `firestore.rules` אוכף claim/no-steal (`claimOnlySelf`/`unassignedOrMine`/pool) + manager-override · `rules_test/orders.test.js` +10.
- guard: `orders_uid_a4_a6_test` (22 · flag-OFF lock · claim+no-steal · round-trip · scope-per-role · dashboard). מוטציות: rules (2 steal→אדום, 25/2) + Dart (no-steal→אדום) שוחזרו.
- **אימות:** analyze 0 · full-suite +2176 · build web ✅ · **emulator 27/0** (17→+10). SPEC: `knowledge/SPEC-A4-A6-order-ownership.md`.
- **owner-activation:** `UID_SCOPED_QUERIES=true` + backfill + `firebase deploy --only firestore:rules,firestore:indexes`.
### #A4-A6 server-swap — מקור-זהות BoardSession: seed → Firebase Auth (אני, לא נחיל) — 2026-06-13
- **הבעיה (ליבת multi-user):** חנות/שליח נכנסו דרך חשבונות-seed (`boardAuthProvider`) אבל ה-claim חותם `currentUidProvider` (Firebase) — שמנותק → uid ריק → הכל בבריכה, לא ממוקד. שתי מערכות-זהות מנותקות.
- **SW1 (model):** `BoardSession.uid` (אדיטיבי, default '') · `toJson` כותב uid רק כשלא-ריק (JSON של seed זהה byte-for-byte) · `fromJson` defaulted.
- **SW2 (helper טהור):** `boardSessionFromAuthSnapshot(AuthSnapshot)` — signed-out→null · role-claim ראשון שמתמפה ל-BoardRole (contractor/לא-מוכר מדולגים)→session הנושא uid · displayName נופל לכותרת-התפקיד. בר-בדיקה ישירות ללא דגל-קומפילציה.
- **SW3 (קשירה gated):** `BoardAuthNotifier(ref, {bindFirebase})` (default `kUidScopedQueries`) · ON→`ref.listen(authStateProvider, fireImmediately)` ממראה זהות-Firebase חיה (sign-out→null, השער נסגר) · OFF→seed `_load()`, אפס-קישור (נעילת-רגרסיה). `currentUidProvider` ללא שינוי — **אינווריאנט: board.uid == currentUidProvider** (אותו uid שה-claim של A4-A6 חותם ב-sys_orders).
- **SW4 (rules):** ללא שינוי — `firestore.rules` כבר ממוקדות-uid (`isManager()` override + `storeUid/courierUid == request.auth.uid` owner/no-steal/pool); 27 בדיקות-ה-emulator מכסות את הזהות-המוחלפת.
- guard: `board_auth_server_test` (12 · helper טהור · נתיב-ON חי מול fake AuthGateway · אינווריאנט uid==currentUid) + `board_auth_test` הקיים = נעילת flag-OFF (seed). מוטציה: helper→`return null` קבוע → `+5 -7` אדום → שוחזר (cp byte-מדויק) → 12/12.
- gate-UI sign-in routing (ניתוב השער ל-Firebase) = follow-up מתועד, מחוץ-לטווח (בלי fake). SPEC: §server-swap (SW1-SW5).
### #A9 — צ׳אט scoped (participantUids) — 2026-06-13
- **model (`sys_chat`):** `ChatThread.participantUids: List<String>` (אדיטיבי, default `const []`) — ה-uids של חברי-ה-thread, auth-truth שה-rules ממקדות עליו. `participants` (role-based) נשאר לתצוגה + לבידוד `threadsFor`. `copyWith` משמר את ה-uids.
- **helper טהור (`sys_chat`):** `chatThreadVisibleToUid(participantUids, uid)` = `participantUids.isEmpty || participantUids.contains(uid)` — רשימה ריקה → גלוי-לכולם (legacy/לא-מהוגר, אפס-רגרסיה); מאוכלסת → חברים-בלבד. ממראה את `uid in participantUids` של ה-rules; gated ב-`kUidScopedQueries` באתר-הקריאה.
- **repo (`chat_firebase`):** `_ChatThreadHead.participantUids` (ctor/field/copyWith) · `_threadHeadSeed`/`threads()` נושאים אותו · **toDoc economy** — `participantUids` נכתב **רק כשלא-ריק** → doc של seed/role-based זהה byte-for-byte ל-pre-A9 · fromDoc קורא סובלני (לא-רשימה/לא-string → `[]`).
- **rules (`firestore.rules`):** `chatThreads` (read/create/update/delete) + `threadParticipants()` הוחלפו מ-`participants` (שם-תפקיד, תצוגה) ל-`participantUids` הייעודי (auth-truth) עם `.get('participantUids', [])` להגנה · update **מקפיא** את participantUids (רענון lastMsg/ts עובר; גיוס/פליטה נדחים) · `participants` נשאר לתצוגה. docs לפני-מיגרציה (participantUids ריק) לא תואמים שום uid — forward-ready inert.
- **emulator (כיסוי chat ראשון אי-פעם):** `rules_test/chat.test.js` חדש — 15 בדיקות (8 chatThreads: member-read/non-member/role-לא-מגדר/legacy/create-self/create-not-self/update-lastMsg/update-freeze · 7 chatMessages: member-read/non-member/create-self/spoof-denied/not-in-thread/immutable/signed-out). project-id ייעודי `demo-buildsmart-chat` מבודד מ-`orders.test.js` (ריצה מקבילית של `node --test` + `clearFirestore` משותף → race; ראה מטה).
- guard: `chat_uid_a9_test` (6 · helper empty-visible/members-only · model default-[]/copyWith · toDoc OMIT-כשריק/WRITE-כשמאוכלס · fromDoc round-trip/default-[]) + `chat.test.js` (15 · emulator). מוטציות: helper — הסרת `participantUids.isEmpty ||` → empty-visible **אדום** (Expected true/Actual false) → שוחזר (cp) → +6 ירוק · rules — `chatThreads` read→`if isSignedIn();` → 3 **אדום** (non-member/role-only/legacy: "Expected request to fail, but it succeeded") → שוחזר (cp) → 42/42.
- **אימות:** analyze (3 קבצי-A9) 0 errors (test נקי לגמרי; legacy-infos = baseline) · full-suite +2194 ירוק · **emulator 42/42/0** (orders 27 + chat 15, דטרמיניסטי 3/3 ריצות) · build web (לא נדרש כאן).
- **owner-activation:** אכלוס `participantUids` (יצירת-thread per-user במיגרציה) הוא שלב-הבעלים/ההפעלה; עד אז inert (role threads נשארים משותפים) + `firebase deploy --only firestore:rules`.

### #A14 — צ׳אט last-mile: אכלוס participantUids אמיתי (נחיל) — 2026-06-13
- **הפער ש-A14 סוגר (ביקורת בעל-המוצר):** A9 הוסיף את שדה `participantUids` + round-trip + rules שממקדות עליו — אבל **השדה מעולם לא אוכלס** → תמיד ריק → "ריק = גלוי-לכולם" → **אין בידוד פר-משתמש אמיתי**. A14 מאכלס אותו **באמת**.
- **מנוע (`sys_chat`):** `ChatEngineNotifier.ensureParticipantUids(threadId)` חדש — gated ב-`uidScoped` (שדה חדש, default = `kUidScopedQueries` ⇒ production ממוקד בדיוק על הדגל, OFF היום). ON + `lookup` קיים + ה-uids עוד ריקים ⇒ פותר את **האיחוד** (⋃) מעל **כל role** של ה-thread דרך A7 `UsersLookup.uidsByRole` (מדלג `bot`), מקפל פנימה את uid-השולח (`currentUid`), וחותם על ה-head. כך `[contractor,store]` נושא **כל** uid-קבלן + **כל** uid-חנות (ריבוי-משתמשים-לתפקיד מטופל — דוגמת שני-העובדים ran/omer). אסינכרוני **ולא-חוסם** את ה-send האופטימי (in-flight guard מונע resolve כפול). `ChatThread.copyWith` קיבל `participantUids`.
- **קישור (`sys_chat`):** `send()` קורא `ensureParticipantUids` בכניסה (gated, non-blocking) · `chatEngineProvider` מזריק `usersLookupProvider` (A7) + `currentUidProvider` (A2); `uidScoped` יורש את הדגל ⇒ OFF=no-op=אפס-רגרסיה (`usersLookupProvider` גם null בלי-backend → inert כפול).
- **repo (`chat_firebase` · `chat_repository`):** `ChatRepository.setParticipantUids(threadId, uids)` חדש — `FirebaseChatRepository` עושה upsert ל-head (ה-toDoc של A9 כבר כותב participantUids כשלא-ריק → persist + ה-mirror מחזיר ל-state) · `_ChatThreadHead.copyWith` קיבל `participantUids`. הנתיב-המקומי חותם ישירות על ה-state.
- **גזירת-הזרקה (testability בלי recompile):** הדגל הקומפילציוני `kUidScopedQueries` עוטף את `uidScoped` (כברירת-מחדל); בדיקה מזריקה `uidScoped: true` להוכיח את ענף-ה-ON בסוויטה רגילה — אותה תבנית שכל switch קומפילציוני כאן משתמש בה.
- guard: `chat_uid_a14_populate_test` (6) — **ההוכחה ש-NOT inert:** flag-ON + fake directory (contractor→[uid-c], store→[uid-s1,uid-s2]) + currentUid=uid-c → אחרי send/open על thread `[contractor,store]` ה-`participantUids` **לא-ריק ושווה לאיחוד** {uid-c,uid-s1,uid-s2} · flag-OFF → נשאר **ריק** (נעילת אפס-רגרסיה) · ה-thread המאוכלס **גלוי לחבר ולא לזר** דרך `chatThreadVisibleToUid` · resolve-once (אין re-resolve ב-send שני) · `kUidScopedQueries==false` בבדיקות ⇒ default-gate OFF. מוטציה: שבירת האיחוד (`union.addAll(uidsByRole)` → drop) → 3 **אדום** (Expected {uid-c,uid-s1,uid-s2}/Actual {uid-c} · member-visible Expected true/Actual false) → שוחזר (cp מ-`/tmp/A14_sys_chat.dart.bak`, **לא** git checkout) → +6 ירוק.
- **אימות:** analyze (3 קבצים שנגעתי) 0 errors (test נקי; legacy-infos = baseline) · full-suite +2200 ירוק · **emulator 42/42/0** (ללא שינוי-rules — לא נדרש). 
- **owner-activation:** `UID_SCOPED_QUERIES=true` build → האכלוס פעיל; ה-uids נחתמים בכניסה/send ראשון ל-thread, מתמשכים דרך toDoc, וה-rules ממקדות. דורש backend חי (`usersLookupProvider`) + users-docs עם role.

### #LAUNCH-4FIX — 4 כפתורים-מתים/מזויפים → התנהגות-אמת (נחיל · ביקורת-launch) — 2026-06-14
ארבעה defects "wire a dead/fake button to real behavior" — אפס החלטת-מוצר, כל אחד מחווט ל-effect-אמת + seam בר-בדיקה.
- **FIX#1 · שיתוף-סל אמיתי** (`store_screen.dart:~3118` `_CartActionsRow`): כפתור 'שתף' רק `showToast('סל שותף:…')` ⇒ עכשיו בונה את סיכום-הסל (אותו `items` שכבר נבנה + שורת סה״כ) ומוסר אותו ל-**share-sheet הנייטיב/Web** דרך seam מוזרק חדש `lib/state/share_seam.dart` (`shareTextProvider`, ברירת-מחדל `Share.share` מ-`share_plus` 10.x שכבר ב-pubspec, לא-בשימוש-עד-עכשיו ב-lib). מראה את תבנית `url_launcher_seam.dart`. בדיקה לוכדת את הטקסט המשותף בלי share-sheet חי.
- **FIX#2 · אריח-מועדף מת** (`smart_home_screen.dart:~637` `_Favorites`): `_MiniTile` של מוצר-מועדף עם `onTap: () {}` (מת) ⇒ עכשיו פותח את גיליון-המוצר **בדיוק כמו אח-המוצר הלא-מועדף** של הקטלוג (`_FavProductRow`): `showLipskeyProductSheet(context, p, <אחים לפי categoryHe>)`.
- **FIX#3 · "הזמן עכשיו" מזויף** (`ai_hub_screen.dart:~251` `_PredictStock.AiCardBtn`): רק `showToast('נוסף לרשימת רכש מומלצת')` בלי effect ⇒ עכשיו **מוסיף פריט-אמת לעגלה החיה** (`smartCartProvider.add(SmartCartLine(...))`). **בדיקת-יכולת-קבלה (לא זייפתי):** ל-`StockPred` לא היו `price`/`emoji`/`key` (רק name/stock/rate/days) — אבל כל תחזית נגזרת **משורת-הזמנה אמיתית** (`OrderLineItem` נושא `emoji`+`price`=סך-שורה). לכן הרחבתי את `StockPred` ב-`emoji`+`unitPrice` (אופציונליים, default `📦`/`0` → seed `kStockPreds` נשאר תקף, guard `t3_ghi` לא נשבר), ו-`computeStockForecast` קוטף אותם מה-line האחרון (`unitPrice = round(price/qty)`). **נתונים אמיתיים שנלכדו, לא מומצאים** ⇒ לא נדרש STOP. `productKey: 'ai-restock:<name>'` (תקדים `scan:`/`smart:`).
- **FIX#4 · ייצוא-PDF אמיתי** (`finance_hub_sheets.dart:~1314` `_FinReportView` print): פתח view-על-מסך ואז רק `showToast('בחר "שמור כ-PDF"…')` ⇒ עכשיו בונה **`pw.Document` אמיתי** (`printing: ^5.13.0` + `pdf: ^3.11.0` נוספו ל-pubspec.yaml) מ**אותם נתונים** שה-view מציג (תקציב total/spent/pct/יתרה + קטגוריות) ומוסרו ל-print/save dialog דרך seam מוזרק `lib/state/pdf_print_seam.dart` (`pdfPrintProvider`, ברירת-מחדל `Printing.layoutPdf`). הבונה `lib/logic/finance_report_pdf.dart` טוען את גופן-Heebo המצורף (PDF-default Helvetica חסר עברית) ומסנן emoji-קטגוריה (`_pdfSafe` — מונע missing-glyph crash; השם+₪ נשמרים). `_FinReportView` → `ConsumerWidget`. **printing נפתר ובנה web** (✓ Built build/web — אין חומת web-compat).
- **בדיקות (per-fix · +8):** share — `cart_share_test` 2/2 (טאפ 'שתף' לוכד את טקסט-הסל דרך seam · סל-ריק=אפס-שיתוף) · favorite — `favorite_tile_opens_sheet_test` 1/1 (טאפ אריח-כוכב פותח `LipskeyProductSheet`) · order-now — `ai_hub_compute_test` +2 (יחידה: emoji+unitPrice נקטפים מה-line האחרון · widget: טאפ 'הזמן עכשיו' מוסיף line-אמת לעגלה `ai-restock:PEX`) · PDF — `finance_pdf_export_test` 3/3 (בונה-טהור מפיק bytes לא-ריקים עם magic `%PDF` · טאפ 'הדפסה' מזריק את ה-doc ל-seam · financeRepo מגבה).
- **מוטציה (FIX#1):** טקסט-השיתוף `'סל BuildSmart:…'` → `'MUTANT'` (Edit) → `cart_share_test` **אדום** (`Expected: contains 'מלט' / Actual: 'MUTANT'`) ✅ נתפס → שוחזר `cp /tmp/store_screen.bak.dart` (**לא** git checkout) → **2/2 ירוק**.
- **gate:** `flutter analyze` (כל הקבצים הנגועים) — **0 errors/warnings** (רק info קיימים-מראש; 4 הקבצים החדשים נקיים לגמרי) · `flutter test` מלא — **+2241 All tests passed** (היה +2233; +8) · `flutter build web --release` — **✓ Built build/web** (7.7MB main.dart.js; מוכיח ש-printing נפתר web-side). **pubspec.lock לא staged** (מוסכמת-ריפו). לא-נגעתי בלוגיקת בעלות-הזמנה/uid/chat.

### #B5 — settings "בבנייה" → effect-אמת או backend-blocked מדויק (store settings) — 2026-06-14
חוק-הבעלים: כל setting מת ('בבנייה — עדיין לא משפיע') הופך ל-**(א)** מחווט ל-effect-לקוח אמיתי, **או (ב)** מדווח backend-blocked. אסור להסתיר/למחוק/לזייף.

**🟢 WIRED (3 · store_settings — client surface קיים, marker הוסר + behavior-test):**
- **`shareCartWithTeam`** (`store_settings_screen.dart` §סל · `store_screen.dart:~3130` `_CartActionsRow`): מגדיר כעת אם כפתור הסל 'שתף' מוצג. OFF (ברירת-מחדל) ⇒ הכפתור **מוסתר** (אי-אפשר למסור את סיכום-הסל ל-share-sheet); ON ⇒ הכפתור מופיע ומשתף (ה-LAUNCH-FIX#1 seam). `ref.watch(...select(shareCartWithTeam))`.
- **`supplierCreditEnabled`** (§אמצעי תשלום · `store_screen.dart:~2487` `_PaymentSelector`): מגדיר כעת אם chip-התשלום 'אשראי ספק' מוצע ב-checkout. OFF (ברירת-מחדל) ⇒ ה-chip **מסונן החוצה** מה-selector (כרטיס/ביט נשארים); ON ⇒ מופיע. סינון על `_kPaymentOptions`.
- **`defaultAddress`** (§משלוחים · `store_screen.dart:2176` `openShipToSheet`): מקדים-ממלא כעת את שדה 'לאן לשלוח?' — כש-`shipToProvider` ריק (מקרה ה-popup-החד-פעמי), השדה נטען עם הכתובת-השמורה במקום ריק. `shipTo` בתהליך גובר על ה-default.

**⛔ BACKEND-BLOCKED — נשארים 'בבנייה', לא הוסתרו/זויפו (אין client surface · דורש שרת/feed/geo):**
- `store_settings` · `defaultInstallments` (§תשלום): אין selector-תשלומים ב-checkout (אין UI לפצל מספר-תשלומים); דורש מסך-תשלום + סליקה.
- `store_settings` · `showStock` (§תצוגה): מסך-המוצר/קטלוג אינו מציג מלאי-לקוח לסנן (אין שדה stock לכל מוצר ב-data).
- `store_settings` · `localSuppliersOnly`/`minSupplierRating`/`maxSupplierDistance` (§ספקים): מסך-הספקים = tiles קשיחים, אין geo/rating per-supplier לסנן.
- `store_settings` · `repeatOrders` (§סל): דורש backend-הזמנות-חוזרות מתמשך (אין engine מקומי לתזמן הזמנה חוזרת). [`purchaseHistory` **חווט ב-B5-cont** — ראה מטה.]
- `store_settings` · `businessName`/`businessId`/`exportToAccountant`/`autoReceipts`/`preferredDeliveryWindow`/`deliveryAreas`/`courierInstructions`/`biometricConfirm`/`dailyCreditLimit`/`unitSystem`: חשבוניות = server-only (מתויג ביושר), שאר = דורשים שרת/חומרה (ביומטריה)/יחידות-מוצר.
- **`notif_settings`** · `typeSupplierOffers`/`typeBackInStock`/`typeReminders`/`typeNewChats`/`typeProjectUpdates`: אין `NotifSection` ב-feed (`{all,shipments,orders,safety,budget,deals}`) ל-5 הסוגים האלה — 4 ה-types הפעילים (`typeOrders/Shipments/Deals/PriceDrops`) **כן** מחווטים ב-`notifMutedSections` (`notifications_screen.dart:248`). לחווט את ה-5 ידרוש להמציא notifications-דמו (=זיוף) או push-server אמיתי. כן: `personaContractor/Store/Admin` (אין bell-feed ייעודי · קבלן קורא feed משותף) · `soundPerType`/LED (Android channels) · `quietOnShabbat/InMeetings/WhileDriving` (אין מקור-לוח/קלנדר/נהיגה) · כל §סיכומים/§מסך-נעול (push/OS).
- **`chat_settings`** · `readReceipts`/`typingIndicator`/`botEnabled`/`greetingEnabled`/`messageAlertEnabled`/`lastSeenPrivacy` **כבר מחווטים** (`chats_screen.dart:1029/1291/1343/1380/1665`). הנשארים 'בבנייה': `lockScreenPreview` (OS-lock-screen) · `initialResponseEnabled`/`callRingEnabled` (telephony/presence) · `mediaDownload`/`imageQuality`/`compressVideo` (אין pipeline-מדיה) · `backupEnabled/Freq` (cloud) · `lang`/`autoTranslate` (i18n-engine) · §עסקי/§ארכיון (שרת) · `chatPrivacy` ("מי יכול לפתוח שיחה" — presence/server).
- **`catalog_settings`** · `_PlaceholderRow` (רדיוס-חיפוש · ספקים-מועדפים/חסומים/מרחק/דירוג/מקומי · 4×AI): אין geo per-product / supplier↔product attribution / AI-engine — מתועד inline ב-`catalog_settings_screen.dart:287,600`. אלה inert placeholders (לא toggles-מתמשכים), נשארים 'בבנייה' ביושר.

**בדיקות (+8 · `store_settings_wiring_test.dart`):** share OFF→אין-'שתף'/ON→מופיע/ON→משתף-דרך-seam · credit OFF→אין-'אשראי ספק'(כרטיס-כן)/ON→מופיע · address ריק→שדה-ריק/default→מקדים-ממלא/shipTo-בתהליך-גובר. `cart_share_test` עודכן (+`shareCartWithTeam:true` precondition — ה-share עבר מאחורי gate).
**מוטציה:** ראה `knowledge/mutation_log.md` (§B5). **gate:** analyze 0-errors · full-suite ירוק · build web ✅.

### #B5-cont — `purchaseHistory` → טוגל-פרטיות אמיתי על רשימת-ההיסטוריה — 2026-06-14
- **`purchaseHistory`** (`store_settings_screen.dart` §פרטיות · `store_screen.dart` רשימת order-history): היה 'בבנייה'. כעת **מגטה את רשימת היסטוריית-ההזמנות** — ON (ברירת-מחדל) ⇒ שורות-ההזמנה מוצגות; OFF ⇒ הרשימה מוסתרת מאחורי הודעת-פרטיות + כפתור "הצג היסטוריה" שמחזיר את ה-setting ל-ON ואת הרשימה. effect-לקוח אמיתי, marker הוסר.
- **בדיקה (+3 · `store_purchase_history_settings_test.dart`):** ON→שורות-מוצגות/אין-הודעה · OFF→מוסתר-מאחורי-הודעה · tap-"הצג היסטוריה"→מחזיר. **gate:** analyze 0-errors · ירוק.
- **סיכום B5:** 4 הגדרות-store חוּוטו ל-effect אמיתי (share/credit/address/purchaseHistory). יתר ה-settings (notif/chat/catalog + שאר store) = **backend-blocked מתועד** (לא הוסתרו/זויפו — נשארים 'בבנייה' ביושר עד שהבעלים יספק שרת/אחסון/push/geo/AI/דאטה).

### #A13 — order-stage advance + credit → Cloud Functions callables (gated, forward-ready) — 2026-06-14
**הפער:** הפונקציות `advanceOrderStage` + `computeCredit` **קיימות** בשרת (`functions/src/orders.ts`/`credit.ts`, region `me-west1`, re-export ב-`index.ts`), וטריגר `revertIllegalOrderStageWrite` **מחזיר** כתיבת-stage ישירה שאינה צעד-קדימה-יחיד — כלומר הנתיב הקנוני לקידום-שלב הוא ה-callable. אבל ה-client **לא** קרא להן: הוא עשה direct optimistic Firestore writes (`orders_firebase.advance`→`upsert`) + hash-אשראי מקומי, שעוקף את לוגיקת-השרת + חוקי-S5.
**הפתרון (gated, אפס-רגרסיה):** flag קומפילציה `kServerCallables = bool.fromEnvironment('SERVER_CALLABLES')` (ברירת-מחדל **OFF**, דפוס `kUidScopedQueries`), עם שדה-injectable `serverCallables` על ה-notifier/repo (ברירת-מחדל = ה-flag) לבדיקות. seam חדש `OrderFunctionsGateway` (mirror ל-`AuthGateway`): `FirebaseOrderFunctionsGateway` פותר `FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion)` עצלן, מתרגם `FirebaseFunctionsException` ל-`OrderFunctionsException` ניטרלי; provider `orderFunctionsGatewayProvider` = null מחוץ ל-live-backend (=flag inert).
- **קידום-שלב** (`orders_engine.advance` כש-bound): **ON** ⇒ `advanceOrderStage({orderId})` עושה את הכתיבה הקנונית בשרת; ה-client מחיל **optimistic LOCAL** בלבד (`FirebaseOrdersRepository.applyServerStage`→`upsertLocalOnly` — cache+notify, **בלי `set`**) מתוך ה-`{to}` שהשרת החזיר — **לא** קורא `r.advance` (כתיבה-ישירה הייתה מתבטלת ע"י הטריגר). **OFF** ⇒ ה-direct optimistic write הקיים, byte-identical.
- **אשראי** (`CustomersRepository.computeCredit(name)` — מתודה אדיטיבית חדשה ב-interface): **ON** ⇒ callable `computeCredit({name})` למספרים הקנוניים; **OFF** ⇒ גזירה מקומית זהה לדשבורד (`contractorCredit` ceiling + spend-fold + `pct`/`balance`) — `creditLimit(name)` הסינכרוני **לא נגעתי**.
- **כשל graceful:** `OrderFunctionsException` (לא-deployed / permission) → קידום: no-op כן (הכרטיס נשאר), אשראי: נפילה-חזרה לגזירה-המקומית — **בלי לזייף הצלחה**, בלי crash.
- **args לפי החוזה:** advance ← `{'orderId': orderId}` (השרת מחזיר `{ok,orderId,from,to}`); credit ← `{'name': name}` (השרת מחזיר `{ok,name,creditLimit,used,balance,pct,orderCount}`).
- **OFF = byte-identical:** ה-flag OFF + provider-gateway null מחוץ ל-live-backend ⇒ אפס-נגיעה בנתיב-היום. הבעלים deploy-פונקציות + `--dart-define=SERVER_CALLABLES=true` מאוחר יותר.
- **בדיקות (+8 · `orders_credit_a13_callable_test.dart`, fake `OrderFunctionsGateway`+`RemoteCollectionSource`):** ON-advance מזמן את ה-callable+מחיל `{to}`+**אפס direct set** (נעול על הבייטים) · OFF-advance = direct set (נעילת אפס-רגרסיה)+callable לא-נקרא · FunctionsException→no-advance · ON-credit מזמן+מחזיר server figures · OFF-credit = local זהה+callable לא-נקרא · FunctionsException→fallback מקומי · compile-time-default OFF. **gate:** analyze 0-errors/warnings (כל הנגועים) · full-suite **+2260** (היה +2252; +8) · build web ✅. מוטציה: `result.to→result.from` ⇒ ON-test אדום (Expected 'preparing'/Actual 'new') → שוחזר → ירוק; וגם "ON גם יורה direct set" ⇒ `sets isEmpty` אדום → שוחזר.

### #A14 — צילומי-תמונה → העלאה ל-Cloudflare R2 דרך `getUploadUrl` (gated, forward-ready) — 2026-06-14
**הפער:** כל תמונה שנקלטת (POD / before-after / פרופיל / לוגו-חנות / תעודת-שליח) נשמרת כ-`data:image/...;base64,...` data-URL ב-SharedPreferences/localStorage (`services/task_photo.dart`, `state/persona_fulfillment.dart`) — חסום ~1.5MB, ללא sync בין-מכשירים. ה-callable `getUploadUrl` **קיים** בשרת (`functions/src/r2.ts`, region `me-west1`, presigned-PUT מול R2) אבל ה-client **מעולם לא** קרא לו.
**הפתרון (gated, אפס-רגרסיה):** flag קומפילציה `kCloudPhotos = bool.fromEnvironment('CLOUD_PHOTOS')` (ברירת-מחדל **OFF**, נפרד מ-`kServerCallables` כדי שתמונות יופעלו עצמאית), עם seam-gate מודולרי `photoUploadEnabled` (ברירת-מחדל = ה-flag) לבדיקות define-less. seam חדש `UploadFunctionsGateway` (mirror ל-`OrderFunctionsGateway`): `FirebaseUploadFunctionsGateway` פותר `FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion)` עצלן, מתרגם `FirebaseFunctionsException` ל-`UploadFunctionsException` ניטרלי. seam שני להזרקה — `PhotoHttpPut` (`Future<int> Function(Uri, Uint8List, String)`, ברירת-מחדל `http.put` אמיתי cross-platform) — כך שבדיקות לעולם לא נוגעות ברשת.
- **חוזה השרת (`r2.ts`):** input `{kind:'pod'|'before-after', contentType, fileName?}` — **המפתח בבעלות-השרת** (`{kind}/{uid}/{ts}-{fileName}`), ה-client בוחר רק kind+contentType. השרת מחזיר `{ok, url, key, method:'PUT', headers, expiresIn}` — **אין שדה public-URL בחוזה**; ה-URL הציבורי מורכב צד-לקוח כ-`{kImageBaseUrl}/{key}` (אותו base ציבורי `https://pub-…r2.dev` שתמונות-הקטלוג כבר מוגשות ממנו, `data/product_images.dart`). השדות בשימוש: `url` (presigned PUT) + `key` (→ publicUrl).
- **נתיב-הקליטה** (`task_photo.dart` `_guardAndDeliver` → `deliverGuardedPhoto`, אחרי ה-size-guard): **ON** ⇒ `getUploadUrl('pod', contentType)` → `PUT` של ה-bytes ל-`url` עם ה-Content-Type → על 2xx **מאחסן את ה-publicUrl** (`https://…`) במקום ה-base64. **OFF** ⇒ ה-data-URL המדויק (byte-identical), ה-gateway **לא נגע** כלל. ה-guard של ~1.5MB (`kMaxPhotoDataUrlChars`) ב-OFF לא נגעתי.
- **תצוגה דו-צורתית** (`widgets/photo_viewer.dart` `imageProviderForRef`): כל אתר-רינדור מנתב דרך helper שמזהה `http(s)`→`NetworkImage` · `data:image`→`MemoryImage(decoded)` · אחר→null. + `showFullPhotoRefDialog(ref)` (full-screen לשתי הצורות) + `isHttpPhotoRef`. אתרי-הרינדור שנותבו: POD (`taskPhotoWidget` — נצרך ע"י persona_pod/manager/store_dashboard) · אווטאר-פרופיל עובד/שליח · לוגו-חנות (`_StoreLogoAvatar` + edit-preview) · תעודות שליח/עובד/עסק (`courier_certs`/`worker_safety`/store-cert-row) · sick-notes (`courier_forms`) · POD-thumb (`courier_reports_tab`) · proof-thumb+דיאלוג (`worker_reports_tab`). (`camera_sheet` preview = data-URL-ביד לפני-העלאה, ללא שינוי.)
- **כשל graceful, ישר:** `getUploadUrl` זורק (לא-deployed / R2 לא-מוגדר → `failed-precondition`) **או** PUT non-2xx **או** PUT זורק → **נפילה-חזרה ל-data-URL** (התמונה **לא** אובדת — נשמרת מקומית כמו היום) + log ישר (`debugPrint`). MIME לא-נתמך (gif) → נשמר base64, לא נשלח. **לעולם לא מזייף הצלחה, לעולם לא מאבד תמונה.**
- **OFF = byte-identical:** `kCloudPhotos` ברירת-מחדל OFF ⇒ הבילד בפרודקשן שומר על נתיב-ה-base64 המדויק. אדיטיבי + forward-ready: הבעלים provision R2 + deploy + `--dart-define=CLOUD_PHOTOS=true`.
- **חבילה:** `http: ^1.6.0` קודם ל-direct-dep ב-pubspec.yaml (כבר transitive — אותה גרסה 1.6.0; pubspec.lock **לא** staged/שונה).
- **בדיקות (+12 · `cloud_photos_a14_upload_test.dart`, fake `UploadFunctionsGateway`+fake PUT):** ON ⇒ קליטה מזמנת `getUploadUrl('pod',contentType)`+**PUT של ה-bytes המדויקים**+מאחסן את ה-**publicUrl** (לא ה-uploadUrl, לא base64; round-trip בייט-לבייט) · OFF ⇒ ה-data-URL verbatim+gateway **לא-נקרא** (נעילת אפס-רגרסיה) · compile-default OFF · getUploadUrl-throw→fallback-base64 · PUT-403→fallback · PUT-throw→fallback · gif→base64-לא-נשלח · display: http→NetworkImage / data→MemoryImage / null+demo→null. **gate:** analyze 0-errors (כל הנגועים) · full-suite **+2272 All tests passed** (היה +2260; +12) · build web ✅. מוטציה: `return target.publicUrl`→`target.uploadUrl` ⇒ 2 ON-tests אדום (Expected publicUrl/Actual `…sig=AAA`) → שוחזר `cp /tmp/task_photo.dart.bak` (**לא** git checkout) → +12 ירוק.
### #boards-polish — גל D עובד/שליח/חנות (נחיל אמיתי /swarm: donning + שער-מאניפסטים) — 2026-06-14
- **צינור מלא עם donning:** 10 אודיטורים-לפי-עדשה → 57 ממצאים · ולידציה אדברסרית: 32 CONFIRMED + 3 ADJUST + **0 FP** + 2 DEFER-LARGE · 7 fixers על מפת-קבצים זרה (כל סוכן עטה את ממד-הסוכן-המושלם שלו) · supervisor byte-verify · central-verify **עם המאניפסטים** (--assert conformance + --required-tests) — GATE PASS · mutation-verify (vacation_requests.dart:132 back-compat 'worker'→'courier' → אדום → שוחזר → ירוק).
- **לוח-עובד (התאום הלא-מתוקן של שליח/חנות מ-#86/#87):** מגני in-flight save (worker_profile/_safety add-cert/_forms sick-note — בלי double-pop, בלי הצלחה-מזויפת על quota); ניגודיות AA (Colors.redAccent→BsTokens.dangerDark ב-יציאה/הסר-תמונה; Colors.white→bsOnAccent על כפתור-השעון success-green ~1.9:1, _PillButton, שמור/הוסף-תעודה, שלח-דוח); excludeSemantics ב-_PillButton/_DateField/_SendReportButton/_ClockCard/_SubmitButton/הוסף-תעודה; cacheWidth/cacheHeight (_ProfileAvatar, _CertRow, _ProofThumb, taskPhotoWidget עם BuildContext? אופציונלי, sick-note double-decode→Image.memory ישיר); הסרת לולאת-ניווט הגדרות⇄פרופיל (_ProfileRow ירד; ההגדרות leaf); displayName בהודעת טופס-101; סינון-חופשה r.username==username && r.role=='worker' (סגירת דליפת-demo חוצת-תפקידים); guard thread-exists לטוסט-101.
- **residuals חנות/שליח:** store_settings reset/_ActionRow redAccent→dangerDark · store_dashboard _logout נוסח-יציאה אחיד (F-53) + הסרת toast · store_dashboard POD-thumb + courier_profile avatar cacheWidth.
- **נדחה (#99):** rewardsProvider device-global → per-username + workerNotifs role-scope (refactor מעבר לחלון-פוליש); בינתיים תווית כנה 'BuildCoins (מועדון משותף)' בלוח-העובד.
- **כיסוי-בדיקות:** +3 בדיקות (P-12 בידוד-role בחופשה · P-5 אין שורת-פרופיל בהגדרות · P-15 sent-guard נוכחות) — כותב-הבדיקות עטה ממד-3. הערת-כיסוי כנה: ה-P-12 unit-test משכפל את ביטוי-הסינון של המסך (מאמת את מודל-ה-role+back-compat), לא קורא מה-widget — סינון-המסך עצמו מכוסה רק עקיף.
- Gate: analyze 0 · GATE PASS (conformance 7/7 · required-tests 6/6 · build web) · mutation red→green. v6.17→v6.18.

### #POD-signature — pad-חתימה אמיתי (החלפת ה-(הדגמה)) — 2026-06-14
- **`lib/widgets/signature_pad.dart` (חדש):** pad-ציור client אמיתי — אצבע (מובייל)/עכבר (web) → strokes → `ui.PictureRecorder`→`Picture.toImage`→PNG→`data:image/png;base64,…` (headless-safe ב-flutter test, בלי backend/package). pad-ריק → null; השמור מושבת עד דיו — **אין חתימה מזויפת**.
- **`persona_fulfillment.dart`:** שדה `podSignature` (String? — additive: ctor/copyWith/toJson-guarded/fromJson-default כמו podPhoto). `podSigned` אמיתי רק כשקיימת `podSignature`.
- **`persona_pod_sheet.dart`:** ✍️ פותח את ה-pad → שומר → `podSignature`+`podSigned=true` + toast כן ("החתימה נשמרה ✍️" — **הוסר ה-"(הדגמה)"**). תצוגה דרך helper-התמונות. server-swap: כש-`kCloudPhotos` ON החתימה (PNG אמיתי) זורמת דרך אותו נתיב R2 (kind `pod`).
- **אימות (orchestrator fast-verify — ממוקד, לא הסוויטה המלאה):** analyze **0 errors** · `signature_pad_test` (8) + `persona_fulfillment_test` ירוקים (ציור→PNG-לא-ריק/dot/pad-ריק→null/round-trip/preview). **מוטציה:** encode-success `return 'data:…base64,${base64Encode(bytes)}'`→`return null` ⇒ 4 אדום ('Expected: not null') → `cp /tmp/sig.bak` (לא git checkout) → +8 ירוק. הסוויטה המלאה מאומתת ב-pre-push build-gate.

### #C10 — הרשאות-מכשיר מלאות ל-Apple/Play readiness (config-only, אפס permission-crash) — 2026-06-14
**הפער:** ה-`AndroidManifest.xml` הצהיר `INTERNET`+`CAMERA`+`RECORD_AUDIO` אבל **חסרה הרשאת-הגלריה** ל-`image_picker` (בחירת תמונה קיימת ל-POD/פרופיל/תעודות) — באנדרואיד מודרני בחירה מהגלריה דורשת `READ_MEDIA_IMAGES`. ה-`Info.plist` כבר נשא את 4 ה-`NS…UsageDescription` אך הניסוח לא היה מיושר verbatim עם `lib/data/legal_texts.dart` (~שורה 102: "מצלמה — לסריקת ברקוד… בלבד; מיקרופון — לחיפוש קולי בלבד").
- **Android (`android/app/src/main/AndroidManifest.xml`)** — נוסף: `READ_MEDIA_IMAGES` (API 33+, גלריה ל-image_picker) · `READ_EXTERNAL_STORAGE` עם `android:maxSdkVersion="32"` (מכשירים ישנים בלבד; לא נדרש מ-API 33) · `<uses-feature android:name="android.hardware.microphone" android:required="false"/>` (speech_to_text). כל `uses-feature` החומרה (camera+microphone) ב-`required="false"` → האפליקציה מתקינה גם על מכשיר חסר-חומרה (תאימות-Play). **לא** נוספו GPS/location (out-of-scope — נחיל אחר) ולא הרשאות לתוספים שאינם בשימוש.
- **iOS (`ios/Runner/Info.plist`)** — 4 ה-strings יושרו לניסוח-עברי ספציפי תואם-`legal_texts` (Apple דוחה ניסוח כללי): `NSCameraUsageDescription` (סריקת-ברקוד + צילום POD/פרופיל/תעודות, "אין צילום ברקע") · `NSMicrophoneUsageDescription` ("לחיפוש קולי… בלבד. אין הקלטה ברקע") · `NSSpeechRecognitionUsageDescription` (המרת חיפוש-קולי לטקסט) · `NSPhotoLibraryUsageDescription` (צירוף תמונות קיימות — POD/פרופיל/תעודות). **`NSPhotoLibraryAddUsageDescription` לא נוסף** — `task_photo.dart` קורא רק `pickImage` (READ), אף פעם לא כותב/שומר לגלריה; הצהרת-add הייתה שקרית.
- **אימות:** `flutter analyze` **0 errors** (config-only, Dart לא-מושפע; 4998 ה-info/warning = לינטים קיימים בקבצי-test) · `flutter build web --release` ✅ (sanity) · שני הקבצים well-formed XML (אומת ב-`xml.dom.minidom`). **caveat:** בילד נייטיב iOS/Android **לא** ניתן להרצה בסביבת-Linux הזו — נכונות-ההרשאות אומתה בבדיקת-manifest/plist מול רשימת-התוספים, לא בהרצת-מכשיר.

### #C11 — Apple-readiness HIDE-pass: כל placeholder "בבנייה"/"בקרוב"/"(הדגמה)"/"לא זמין" מוסתר (הפיך) — 2026-06-14
**החלטת-בעלים חדשה (גוברת על §B5):** ל-App Store review **כל** פיצ׳ר backend-blocked שמציג placeholder גלוי מוסתר מה-UI. ה-§B5 הקודם השאיר אותם 'בבנייה ביושר' — ההחלטה הזו הופכת זאת ל-**HIDE** עבור כל הלא-ניתנים-למילוי. ה-hide **הפיך לחלוטין**: דגל-קומפילציה יחיד `kHideUnderConstruction` (`lib/state/under_construction.dart`, default `true`) — כל ה-widgets/providers/seeds/const נשארים בקוד; flip ל-`false` מחזיר הכל בדיוק כמו היום. דפוס זהה ל-`kServerCallables`/`kCloudPhotos`.

**C7 — סריקת תוכניות (`ai-plan`): נשאר גלוי (REAL).** הברז `ai-plan` ב-AI-hub פותח `openScanPlanSheet` — flow אמיתי: picker→אנימציית-סריקה→זיהוי-zones עם מחירי-חנות אמיתיים מ-`kPlanTypes`→multi-select→הוספת-lines-אמת לעגלה. אין "(הדגמה)"/"בקרוב" גלוי; האנימציה קוסמטית, ה-BOM+עגלה אמיתיים. מכוסה ב-`scan_plan_test`. **לא הוסתר.**

**C9 — biometricConfirm: הוסתר.** `local_auth` אינו dependency ואי-אפשר לאמת חומרת-ביומטריה בסביבה זו → לא הוספנו dep לא-ניתן-לאימות. הטוגל `store_settings.biometricConfirm` (`store_settings_screen.dart:630`, `underConstruction:true`) מסונן ע"י פילטר-ה-`_SectionTile` (ראה מטה). גם `notif.biometricToOpen` (בתוך `_LockScreenSection` שכולה `underConstruction`) ו-`app_settings.biometric` (search-entry בלבד, אין מסך security נייטיב) מוסתרים בפועל. השדות נשמרים — הפיך.

**B6 — פילטרים/מיון: כבר ממומש ואמיתי (לא placeholder).** `↕️ מיון` (`catalog_screen.dart:1683` `_openSortSheet`) → `ProductSort` אמיתי דרך `catalogProductSortProvider`+`sortCatalogProducts` (nameAZ/ZA/sku). `⚙️ פילטרים` (`:1715` `_openFilterSheet`) → `searchImageOnlyProvider`+`catalogSystemFilterProvider` ב-pipeline-החי `searchResultsProvider`. מכוסה: מיון ב-`catalog_sort_alerts_settings_test`, filterByImage ב-`gaps_test`, + behavior-test חדש ב-`apple_readiness_hide_pass_test`.

**מנגנון ה-HIDE (הפיך) לפי משטח:**
- **מסכי-הגדרות (store/notif/chat/catalog):** ה-`_SectionTile` בכל קובץ מסנן כעת מ-`children` כל שורת-placeholder (`_PlaceholderRow` · `_Inert.underConstruction` · `_SwitchRow.requiresServer`) כש-`kHideUnderConstruction`, ומרנדר `SizedBox.shrink()` אם הסקשן עצמו `underConstruction` או שכל שורותיו סוננו. courier_settings — ללא placeholders (רק אופציות-שפה ar/en sanctioned). ~79 שורות/סקשנים מוסתרים.
- **AI-hub deferred tools (3way/weather/wear · "⚙️ בפרודקשן"):** 3 ה-tiles מסוננים מ-`_visibleTiles` (`ai_hub_screen.dart`); `_AIFeatureScreen` שלהם נשאר בקוד אך בלתי-נגיש. `AIHubScreen.visibleToolIds`/`deferredToolIds` נחשפו ל-tests.
- **חיפוש חי:** `kVisibleSearchIndex` (חדש, `search_index.dart`) משמיט את `kHiddenSearchTitles` (3 ה-deferred) כש-הדגל; `kSearchIndex` ה-const נשאר verbatim. הצרכן (`catalog_screen.dart:2063`) עבר ל-`kVisibleSearchIndex`. "סריקת תוכניות" + יתר הכלים האמיתיים **נשמרים**.
- **צ׳אט — sheet-צירוף:** שורות "מסמך"/"מיקום" (`chats_screen.dart:1917,1923` · "לא זמין בדמו") עטופות `if (!kHideUnderConstruction)` — נשאר "מצלמה" (אמיתי). מפה/ניווט courier = C6 location-fleet, **לא נגעתי**.
- **portal demo-notes:** `_note('נתוני הדגמה…')` (`persona_portal.dart` ⭐ratings) · `_note('זמינות להדגמה…')` (`courier_portal_tab.dart` 🚛fleet) עטופים בדגל — שורות-הנתונים עצמן נשארות. הערת-מפה (`:199`) = C6, **לא נגעתי**.
- **persona_picking:** כפתור 'ביטול ההזמנה כולה — בקרוב' (placeholder כש-`onCancelOrder==null`) מוסתר בדגל; כשמחווט הוא מופיע כפתור-אמת.
- **משימות-צוות:** ה-clause "(בהדגמה…)" ב-`_Intro` (`tasks_screen.dart:125`) + suffix "(הדגמה)" ב-toast-צירוף-תמונה (`:498`) מותנים בדגל — האפשרויות עצמן עדיין פועלות.

**מה לא הוסתר (מכוון):** מחלקות-ריקות (החלטת-בעלים תלויה) · electrician/renovation professions + קטגוריות-קטלוג חסרות-תוכן (sanctioned כבר) · אופציות-שפה ar/en (task #53) · "מצב הדגמה" badge ב-manager_profile (אינדיקטור-session אמיתי, לא feature-placeholder) · GPS/location + map/nav (C6 fleet) · worker-board.

**בדיקות (חדש · `apple_readiness_hide_pass_test.dart`):** kVisibleSearchIndex משמיט deferred / kSearchIndex שומר (הפיך) / real+C7 נשמרים · `AIHubScreen.visibleToolIds` ללא 3 deferred + 6 נשארים · B6 sort/filter behavior · source-guard ש-5 הקבצים שומרים את ה-literal מאחורי הדגל. `settings_honesty_test.dart` **עודכן** (היה: 'בבנייה subtitle findsWidgets' → כעת: placeholders findsNothing + שורה-פונקציונלית findsOneWidget לכל מסך). שאר ה-honesty-tests (`store_notif_widget`/`t9_supplier_personas`/`worker_app`) הם findsNothing — מתחזקים.
**מוטציה:** `kVisibleSearchIndex` שונה ל-לא-מסנן (placeholder דולף) → `apple_readiness_hide_pass_test` 'kHiddenSearchTitles absent' **אדום `+0 -1`** ✅ → שוחזר `cp /tmp/search_index.dart.bak` → ירוק (ראה `knowledge/mutation_log.md`).
**gate:** `flutter analyze` (כל הנגועים+tests) — **0 errors** · `flutter test` מלא — **+2300 All tests passed** (היה +2284; אפס regression — הוחלפו 6 honesty-cases ב-3, נוסף `apple_readiness_hide_pass_test`, +1 stuck-regression) · `flutter build web --release` — ✓ Built. uid/chat/orders-callable/cloud-photos/POD-gating **לא נגעתי**.

**מסכי-store נוספים שהוסתרו (סבב-2, אחרי הסקירה הראשונה):** טאב `🔧 שירותים` (`store_screen.dart:672` + פריט-תפריט `home_shell.dart:920` — כל הסקשן "🚧 בבנייה") · quick-actions מועדים/תזמון/שיחה (`store_screen.dart:762-781` — פותחים גיליונות שכל אריח בהם toast "בבנייה"; מועדפים+כספים אמיתיים נשארים) · אריחי-hub שה-tap שלהם placeholder (`_StoreList` מסנן פריטים ללא handler-אמיתי-שאינו-שירות; השכרת-כלים/פקדונות/החזרה/מכרז/בטיחות/השוואת-מחירים מוסתרים, הסל/הזמנות נשארים) · כפתור OCR 'סרוק תעודת-משלוח' (`store_screen.dart:4025`). **lipskey_brand_screen:350** ('בקרוב' לקטגוריות-מותג ריקות) = זמינות-תוכן (כמו קטגוריות-קטלוג חסרות-תוכן ה-sanctioned), **נשאר**.

### #C11 — Apple-readiness HIDE-pass: סבב-3 (דליפות נוספות מסקירה read-only) — 2026-06-14
סקירת-audit מצאה שש דליפות **נגישות** של "(הדגמה)"/הצלחה-מזויפת/"בקרוב" שסבב-1/2 פספסו. כל אחת נסגרה ב-FILL (flow אמיתי) או HIDE (אותו דגל `kHideUnderConstruction`, הפיך). **שתי החלטות-"נשאר" קודמות בוטלו** (סומנו מטה): lipskey:350 ו-"מצב הדגמה" badge — שתיהן אכן נגישות ל-reviewer ונסגרו.

- **#1 (APPLE-BLOCKER · FILL) `tasks_screen.dart:~503`:** כפתור-העובד "דווח על הביצוע" קרא `attachPhoto(t.id)` **בלי תמונה** (המנוע שמר `photo:'demo'`) ואז toast "תמונה צורפה" — שקר-הצלחה (סבב-1 הוריד את ה-suffix "(הדגמה)" הכן והפך אותו לשקט). **FILL:** מנותב כעת דרך `pickTaskPhoto(context)` האמיתי (webcam/מצלמה, כמו `worker_task_detail_sheet`) — null=ביטול-כן (toast 'לא צולמה תמונה'), אחרת `attachPhoto(t.id, dataUrl)` + toast '📷 תמונת ההוכחה צורפה'. **אף פעם** לא toast "תמונה צורפה" בלי תמונה אמיתית.
- **#2 (FILL) `tasks_screen.dart:~478`:** קופסת "📷 תמונה מהשטח" סטטית-אפורה שלא רינדרה תמונה אמיתית (גם כשקיימת). הוחלפה ב-`taskPhotoWidget(t.photo, context:…)` המשותף (dual-render).
- **#3 (HIDE · helper-תצוגה משותף) `worker_task_detail_sheet.dart:48,74` (`taskPhotoWidget`/`_photoPlaceholder`):** ⚠️ ה-helper יושב ב-`screens/worker_task_detail_sheet.dart`, **לא** ב-`widgets/photo_viewer.dart`. כש-`kHideUnderConstruction` והרפרנס הוא ה-marker הלגאסי `'demo'` — מחזיר `SizedBox.shrink()` במקום ה-placeholder "📷 תמונה מהשטח (הדגמה)". display-only — מתקן את מחלקת "(הדגמה)" **בכל** ה-call-sites (worker sheet · manager approvals row · POD preview). תמונה אמיתית (data-URL/https) לא מושפעת. לוגיקת worker-board לא נגעה.
- **#4 (HIDE) `lipskey_brand_screen.dart:350` — ביטול "נשאר" של סבב-2:** 2 קטגוריות-מותג ריקות ("אמבט ואגנית", "מאספים וקולטים") רינדרו badge "בקרוב" מעומעם. נוסף `visibleSectionEntries(section)` שמסנן `products.isNotEmpty` כש-הדגל (מראה דפוס `_categoryHasContent` של הקטלוג). הרשת ב-`LipskeySectionScreen` + ספירת-הכותרת עברו ל-הרשימה-המסוננת. `kLipskeySections` const נשאר — הפיך.
- **#5 (HIDE) `store_dashboard_screen.dart:467`:** כפתור "➕ סימולציית הזמנה נכנסת (כלי הדגמה)" עטוף `if (!kHideUnderConstruction) [...]`. ה-seam `simulateIncomingOrder` נשאר בקוד.
- **#6 (HIDE/soften) `manager_profile_screen.dart:132` + `welcome_screen.dart:142` — ביטול "נשאר" של ה-badge:** pill "מצב הדגמה" מותנה `session.demo && !kHideUnderConstruction` (Apple דוחה אפליקציה שמציגה עצמה כ-demo). דיאלוג "עדיין אין שרת התחברות — נכנסים כאורח (דוגמה)." רוכך כש-הדגל ל"נכנסים כאורח כדי לעיין באפליקציה." (flow-האורח זהה; הניסוח-הכן נשאר ל-flag-off, הפיך).

**מה לא נגעתי (owner/נחיל-אחר):** `docs_readiness_gate.dart` ("כלל-הדגמה זמני" · worker-board-v3) · לוגיקת worker-board-v3 + `worker_reports_drilldown_test` (כשל-קיים מראש, **לא שלי**) · GPS/location (C6) · 4 המחלקות-הריקות · backend-gating (uid/chat/callables/cloud-photos/POD).

**בדיקות (חדש · `apple_readiness_missed_leaks_test.dart`, 12 cases):** taskPhotoWidget — 'demo'→shrink כש-הדגל / null→shrink / data-URL-אמיתי לא-מוסתר · lipskey — `visibleSectionEntries` מסנן את 2 הריקות + const-שומר (הפיך) · source-guards ל-6 הקבצים (FILL: `pickTaskPhoto` קיים + `attachPhoto(t.id)`/`'תמונה צורפה'` הוסרו; HIDE: literal נשמר מאחורי הדגל). `apple_readiness_hide_pass_test.dart` **עודכן**: case-ה-source-guard ל-`tasks_screen` עבר מ-'תמונה צורפה (הדגמה)' (FILLED—נעלם) ל-'(בהדגמה —' (ה-disclaimer הנותר).
**מוטציה:** `visibleSectionEntries` שונה ל-`return section.entries` (פילטר מנוטרל) → `apple_readiness_missed_leaks_test` 'drops the empty categories' **אדום `+4 -1`** (`"אמבט ואגנית" leaked past the content filter`) ✅ → שוחזר `cp /tmp/lipskey_brand_screen.dart.bak` → **ירוק +12**.
**gate:** `flutter analyze` (6 הנגועים+tests) — **0 errors / 0 warnings** (רק info-לינטים קיימים) · `color_token_ratchet_test` ירוק (אפס `Color(0xFF1A1A1A)` גולמי חדש) · `flutter test` מלא — **+2397, -1** (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש, לא שלי; אפס regressions חדשות) · `flutter build web --release` — ✓ Built (58.7s, main.dart.js).

### #G4 — Crashlytics + Analytics (telemetry seam · Firebase-gated · אפס-רגרסיה) — 2026-06-14
**הפער:** ה-roadmap-primitives `state/crash_log.dart` (step 90) + `state/analytics_log.dart` (step 91) הם in-memory-only והעירו במפורש ש"telemetry חיצוני (Sentry/Crashlytics, GA/Mixpanel) הוא wall-step נפרד". ה-`pubspec` כבר נשא `firebase_messaging`+`firebase_app_check` אבל **חסרו** `firebase_crashlytics`+`firebase_analytics`, ושום error/event לא זרם ל-backend אמיתי.
**הפתרון (additive, Firebase-gated · אפס-define חדש):** seam-injectable `TelemetrySink` (mirror ל-`AuthGateway`/`OrderFunctionsGateway`) — `lib/state/telemetry.dart`:
- **`NoopTelemetrySink`** (ברירת-מחדל) — no-op טהור (`enabled=false`); זה מה שכל ריצה ללא-Firebase (כל הסוויטה + ה-demo) מקבלת ⇒ כל call-site **byte-identical** לפני-טלמטריה.
- **`FirebaseTelemetrySink`** — פותר `FirebaseAnalytics.instance`/`FirebaseCrashlytics.instance` **עצלן** (לעולם ב-ctor — אותו כלל כמו `FirebaseAuthGateway`); `logEvent`→`logEvent(name,parameters)`, `recordError`→`recordError(...)`, כשל-forward נבלע (טלמטריה לעולם לא מפילה את האפליקציה שהיא צופה בה).
- **`telemetryProvider`** = `FirebaseTelemetrySink` **רק** כש-`useFirebaseBackend` (אותו gate `kUseFirebaseBackendFlag && Firebase.apps.isNotEmpty`), אחרת `NoopTelemetrySink`. בדיקות overriding עם recording-fake.
- **Crashlytics global handlers** (`main.dart`): גוש חדש מגודר `if (Firebase.apps.isNotEmpty)` (runtime, **לא** define) **בתוך** ה-Firebase-init — מתקין `FlutterError.onError`→`presentError`+`recordFlutterFatalError`, `PlatformDispatcher.instance.onError`→`recordError(...,fatal:true)` ומחזיר `true`; collection מופעל רק ב-`!kDebugMode` (debug שומר את ה-overlay). הלוגיקה ב-`installCrashlyticsHandlers` (`@visibleForTesting`, closures מוזרקות) → נבדקת **בלי Firebase אמיתי**. עם Firebase **נעדר** הגוש מדולג כליל ⇒ `main()` byte-identical.
- **אירועי-משפך (key events)** דרך ה-seam: `order_placed` (`store_screen` checkout, אחרי `placeOrder` מוצלח — params `{order_id,items,sum}`) · `role_assigned` (`manager_role_assign_sheet`, אחרי `assignRole` לא-זורק — param `{role}`, **בלי uid/PII**) · `app_error` (generic, דרך `logError(e,st,where:)` ב-catch של role-assign — `recordError`+breadcrump). שמות canonical ב-`TelemetryEvents`.
- **קבצים:** `lib/state/telemetry.dart` (חדש — ה-seam+events+`logError` extension) · `lib/main.dart` (handlers+gate) · `lib/screens/store_screen.dart` (אירוע order_placed) · `lib/screens/manager_role_assign_sheet.dart` (role_assigned+app_error) · `pubspec.yaml` (`firebase_crashlytics:^5.0.0`→נפתר 5.2.3, `firebase_analytics:^12.0.0`→נפתר 12.4.2; **pubspec.lock לא staged**).
- **סטטוס:** Crashlytics/Analytics **CODE-COMPLETE**; פעיל ב-web-עם-Firebase עכשיו, נייד **ממתין-לבעלים (F1)** (`firebase_options` web-only — Firebase לא יאותחל בנייד עד תיקון F1) · dashboard-Crashlytics דורש console-enable = **ממתין-לבעלים**.
- **בדיקות (+8 · `telemetry_test.dart`, recording-fake — בלי Firebase):** ללא-Firebase ה-provider = `NoopTelemetrySink`/`enabled=false`+כל מתודה no-op (אפס-רגרסיה) · enabled ⇒ logEvent/recordError/logError מעבירים verbatim · `installCrashlyticsHandlers`: שגיאת-framework→`recordFlutterError` (release: collection ON) · שגיאת-async→`recordError`+מחזיר `true` · debug→collection OFF. **gate:** analyze (כל הנגועים) **0-errors** (אפס `Color(0xFF1A1A1A)` חדש) · full-suite ירוק (+8; ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש) · build web ✅. **מוטציה:** ב-`main.dart` הוסר `recordFlutterError(details);` מ-`FlutterError.onError` → 'Flutter framework error→recordFlutterError' **אדום `+7 -1`** ✅ → שוחזר `cp /tmp/main.dart.bak` (**לא** git checkout) → **+8 ירוק**.
**מה לא נגעתי:** F1/`firebase_options` · worker-board · 4 המחלקות-הריקות · ה-primitives in-memory (נשארו — ה-seam הוא forward נוסף, לא החלפה).

### #F2+#G3 — App Check native (prod providers מאחורי flag) + token-enforcement client-side — 2026-06-14
**הפער:** `main.dart` קרא `FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.debug, appleProvider: AppleProvider.debug)` (web מדולג) — attestation-**debug** קשיח, ללא נתיב production. אין flag לבחירת ה-providers האמיתיים (Play Integrity / App Attest), ולא תועד שה-token כבר מצורף אוטומטית לכל קריאה.
**הפתרון (additive, flag-gated · אפס-רגרסיה — אותו invariant כמו `kCloudPhotos`/`kServerCallables`):**
- **`kAppCheckProd = bool.fromEnvironment('APP_CHECK_PROD')`** (default **false**) ב-`lib/data/repositories/backend.dart`, ליד שאר ה-flags. בנוסף **`kAppCheckRecaptchaSiteKey = String.fromEnvironment('APP_CHECK_RECAPTCHA_SITE_KEY')`** (default ריק) ל-web reCAPTCHA.
- **`appCheckProvidersFor({required bool prod})`** (`lib/main.dart`, `@visibleForTesting`, **טהור** — מחזיר record `({AndroidProvider android, AppleProvider apple})`): OFF→`AndroidProvider.debug`/`AppleProvider.debug` (**byte-identical** לדמו/dev של היום) · ON→`AndroidProvider.playIntegrity`/`AppleProvider.appAttestWithDeviceCheckFallback` (App Attest ב-iOS 14+/macOS 14+, fallback ל-DeviceCheck). נבדק לשני ערכי-הדגל **בלי לאתחל Firebase / בלי לקרוא `activate`**.
- **`main.dart`** — גוש ה-App Check הוזז **לתוך** `if (Firebase.apps.isNotEmpty)` (כמו ה-G4 Crashlytics): נייד→`activate(androidProvider: providers.android, appleProvider: providers.apple)` עם `providers = appCheckProvidersFor(prod: kAppCheckProd)` (OFF ⇒ אותם ערכים בדיוק כמו קודם). web→מדולג כברירת-מחדל; activate **רק** אם `kAppCheckRecaptchaSiteKey.isNotEmpty` (`providerWeb: ReCaptchaV3Provider(...)`). הכל ב-try non-fatal — App Check לא חוסם את עליית-האפליקציה.
- **G3 (token-attach):** `FirebaseAppCheck.instance.activate(...)` לבדו גורם ל-SDKs (Firestore/Functions/Storage) **לצרף את ה-App-Check-token אוטומטית לכל בקשה** — **אין עבודה per-call** (אומת מול ה-API: `getToken`/`getLimitedUseToken` קיימים אך אינם נדרשים בנתיב הרגיל — ה-callable-gateways לא צריכים אותם, ה-SDK מצרף לבד). כש-prod פעיל הופעל `setTokenAutoRefreshEnabled(true)` (שמירת הטוקן רענן).
- **סטטוס:** **F2 ready, ממתין ל-F1 (`firebase_options` נייד) + רישום-קונסול** (מפתחות-attestation: Play Integrity / App Attest/DeviceCheck) — ה-flag לא משנה דבר עד שהבעלים ידליק. **G3 enforcement (דחיית בקשות ללא-token) = ממתין-לבעלים (Firebase console toggle על Firestore + כל callable)** — צד-לקוח רק מצרף; האכיפה היא console.
- **בדיקות (+5 · `app_check_providers_test.dart`, בלי Firebase):** `kAppCheckProd==false` (live default) · `kAppCheckRecaptchaSiteKey` ריק (web מדולג) · `appCheckProvidersFor(prod:false)`→debug (byte-identical) · `prod:true`→playIntegrity/appAttestWithDeviceCheckFallback · ה-flag החי דרך ה-helper (pinned OFF). **gate:** analyze (`main.dart`+`backend.dart`+test) **0-errors** (6 info קיימים-מראש בלבד — אפס חדש; אפס raw-color) · full-suite **+2424 -1** (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline) · build web ✅. **מוטציה:** ב-`appCheckProvidersFor` ענף-ה-OFF שונה ל-playIntegrity/appAttestWithDeviceCheckFallback → 'OFF→debug (byte-identical)' + 'live flag→dev providers' **אדום `+3 -2`** (Expected debug / Actual playIntegrity) ✅ נתפס; ה-ON נשאר ירוק → שוחזר `cp /tmp/main.dart.f2 lib/main.dart` (**לא** git checkout — לשמר את קוד-ה-F2) → **+5 ירוק**.
**מה לא נגעתי:** F1/`firebase_options` · AndroidManifest · `push_state` (סוכן מקביל) · worker-board / 4 המחלקות · לוגיקת uid/orders-callable. נגעתי **רק** ב-`main.dart`+`backend.dart` (+טסט חדש). OFF byte-identical.

### #F5 — Android notifications hardening (channels + foreground display + POST_NOTIFICATIONS · Firebase-gated · אפס-רגרסיה) — 2026-06-14
**הפער:** `push_state.dart` (S6) רשם FCM-token + טיפל ב-foreground/tap, אבל **חסרו** ב-Android: ערוצי-התראה (channels), הרשאת `POST_NOTIFICATIONS` (אנדרואיד 13+), אייקון-התראה, ותצוגת-OS להודעות-foreground (אנדרואיד **לא** מצייר tray-notification להודעה ב-foreground — היא מגיעה שקטה ל-`onMessage`). בלי channel, אנדרואיד 8+ **מפיל** כל התראה.

**הפתרון (additive, Firebase-gated · אותו invariant כמו G4/F2):** seam-injectable `LocalNotificationsGateway` (mirror ל-`PushGateway`) ב-`lib/state/push_state.dart`:
- **`pubspec.yaml`** — נוסף `flutter_local_notifications: ^18.0.1` (קו תואם-3.29/Dart-3.7). **pubspec.lock לא staged.**
- **`AndroidManifest.xml`** — `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` (אנדרואיד 13+, ישנים auto-grant) + שני `<meta-data>` של FCM: `default_notification_icon`→`@drawable/ic_notification`, `default_notification_channel_id`→`@string/default_notification_channel_id`.
- **`res/values/strings.xml`** (חדש) — `default_notification_channel_id` = `bs_general`, **byte-identical** ל-`kDefaultPushChannelId` (source-of-truth יחיד; אנדרואיד-8+ מפיל התראה עם channel לא-קיים).
- **`res/drawable/ic_notification.xml`** (חדש) — vector-drawable, צללית **לבנה/שקופה** (`android:fillColor="#FFFFFFFF"`, פעמון). אנדרואיד מרנדר small-icon כ-mono-mask (alpha בלבד) → אייקון צבעוני היה ריבוע-לבן. אסט brand-accurate (קסדה/"BS") = **follow-up** (אותו שם → אותו חיווט).
- **`kPushChannels`** (3 channels, importance-high): `bs_general`/`bs_orders`/`bs_chat` — PURE-data (`PushChannel`, בלי טיפוס-plugin → unit-testable). `pushChannelIdFor(msg)` ממפה `data['type']` (`order`→orders, `chat`→chat, else→general) — טהור, מקום-יחיד.
- **`FlutterLocalNotificationsGateway`** — פותר את ה-plugin **עצלן** (לעולם ב-ctor — אותו כלל כמו `FirebaseMessagingGateway`); `ensureInitialised()` (init + יצירת ה-channels דרך `AndroidFlutterLocalNotificationsPlugin.createNotificationChannel`), `requestAndroid13Permission()` (`requestNotificationsPermission()`), `show(msg, channelId)`.
- **`PushController`** (param חדש `localNotifications`): ב-`_register` — `ensureInitialised()` לפני ה-token (channels מוכנים) + `requestAndroid13Permission()` belt-and-braces אחרי ש-`firebase_messaging.requestPermission()` הצליח (זה כבר מפעיל את prompt-13; ה-local הוא no-op כשכבר ניתן). ב-`_handleForeground` — בנוסף ל-toast הקיים (web/iOS), `show(...)` על ה-channel הממופה (אנדרואיד). הכל **guarded** (rule #3 — כשל נבלע, לא נזרק) ו-**gated** (gateway null → אינרטי).
- **`localNotificationsGatewayProvider`** = `FlutterLocalNotificationsGateway` **רק** כש-`useFirebaseBackend && !kIsWeb` (אותו gate; web אין channels/runtime-perm ו-FCM-web בעל-משטח-משלו), אחרת **null** → כל הסוויטה הללא-Firebase + ה-demo **לא בונים את ה-plugin** ⇒ ה-F5 **byte-identical inert** שם. בדיקות overriding עם fake.
- **VAPID web push** עדיין **ממתין-לבעלים** (`getToken(vapidKey:…)` — מפתח Web Push בקונסול); נייד **ממתין-ל-F1** (`firebase_options` web-only). **caveat נייד:** יצירת-channel/permission/tray-notification אמיתיים = on-device — לא ניתן לאמת headless כאן; ה-fakes נועלים את הלוגיקה+הגייטינג + source-guard נועל manifest/res.
- **קבצים נגועים:** `pubspec.yaml` · `android/app/src/main/AndroidManifest.xml` · `android/app/src/main/res/values/strings.xml` (חדש) · `android/app/src/main/res/drawable/ic_notification.xml` (חדש) · `lib/state/push_state.dart` · `test/push_state_test.dart`. **לא נגעתי:** `main.dart`/`backend.dart` (סוכן מקביל F1/F2) · worker-board / 4 המחלקות · uid/chat/orders-callable/cloud-photos.
- **בדיקות (+13 cases · `push_state_test.dart`, fake `_FakeLocalNotifications` — בלי plugin/Firebase):** channel-config טהור (3 ids ייחודיים · `kPushChannels.first==kDefaultPushChannelId=='bs_general'`) · `pushChannelIdFor` (order/chat/unknown/missing) · **gating** (gateway null → אפס init/prompt/show, ה-token נרשם בכל-זאת; controller אינרטי-לגמרי) · wired (sign-in → `ensureInitialised`+`requestAndroid13Permission`; denied-messaging → אפס android-13/token; foreground → `show` על ה-channel הממופה; data-only → אפס show; throwing-show נבלע + השרשרת ממשיכה) · source-guard (manifest: POST_NOTIFICATIONS + 2 meta + `@drawable/ic_notification` · strings.xml channel-id==`kDefaultPushChannelId` · אייקון קיים+`<vector>`+`#FFFFFFFF`).
- **gate:** `flutter analyze` (`push_state.dart`+test) — **0 errors / 0 issues** · XML well-formed (xmllint: manifest/strings/icon OK) · `flutter test` מלא — **+2424 -1** (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline; אפס regression) · `flutter build web --release` — ✓ Built (web לא-מושפע; fln מתקמפל ל-web כ-no-op). **מוטציה:** ב-`pushChannelIdFor` ענף-`order` שונה ל-`kDefaultPushChannelId` → 'routes by data.type' + 'foreground RE-SHOWN on its channel' **אדום `+26 -2`** (Expected `bs_orders` / Actual `bs_general`) ✅ נתפס → שוחזר `cp /tmp/push_state.dart.bak` (**לא** git checkout) → **+28 ירוק**.

### #C6 — GPS אמיתי נטיב (geolocator) ל-seam המשותף + site-hub נוכחות — 2026-06-14
**הפער:** `services/geo.dart` (seam #100) החזיר fix אמיתי רק ב-**web** (`geo_web.dart` → `navigator.geolocation`); הנתיב הנטיב (`geo_stub.dart`) היה **stub-null ביושר** הממתין ל-"SERVER-SWAP platform geolocator". בנוסף נוכחות-ה-GPS של ה-site-hub (T2.4) הטביעה **קואורדינטת-דמו קשיחה** `'32.07°N, 34.79°E (±12מ׳)'` (לא חיישן חי). ה-seam **משותף** עם clock-in של נחיל-העובדים (ה-C6 שלהם) — הם **לא** מימשו geo נטיב (`geo_stub.dart` עדיין null; WIRING רשם GPS כ-"נחיל אחר / C6 fleet"), אז **אין conflict**.
**הפתרון (additive — מימוש ה-seam המשותף; אפס נגיעה במסכי worker-board):**
- **`pubspec.yaml`** — נוסף `geolocator: ^14.0.0` (קו תואם-Dart-3.7/Flutter-3.29, `sdk: ^3.5.0`). יש לו תמיכת-web (`geolocator_web` → `web: ^1.0.0`, תואם ה-pin `web: ^1.1.0`), אז `flutter build web` נשאר ירוק. **pubspec.lock לא staged.**
- **`services/geo_gate.dart`** (חדש · **טהור, platform-free**) — לוגיקת-ה-gating שאפשר ליחידה-בדיקה ב-VM **בלי** לייבא `geo.dart` (→ package:web/js_interop שלא מתקמפל ב-test-VM, אותו מגבלת-toolchain ש-`worker_attendance_geo_test` נאלץ לדלג בגללה). `resolveGeoFix(...)` מקבל 4 callbacks (isServiceEnabled/checkPermission/requestPermission/getReading) ומחיל את ה-gate הכן: שירות-כבוי→null (בלי prompt) · permission לא-granted (וגם אחרי בקשה)→null · `deniedForever`→null (לא נשאל-שוב) · granted→ה-reading של הפלטפורמה (או null) · כל-throw→null. **לעולם לא קואורדינטה מומצאת.** `GeoReading`/`GeoPermissionState` = מראָה platform-free.
- **`services/geo_native.dart`** (חדש · נטיב/VM) — adapter דק שכובל את `Geolocator` האמיתי ל-`resolveGeoFix`: `isLocationServiceEnabled` + `checkPermission`/`requestPermission` (ממופים: whileInUse/always→granted, אחרת denied/deniedForever/unableToDetermine) → `getCurrentPosition(LocationAccuracy.medium)` → `GeoFix`. ב-VM headless (אין platform-channel) הקריאה זורקת בתוך הצעד ונבלעת ל-null.
- **`services/geo.dart`** — ה-conditional-import שונה מ-`geo_stub.dart` ל-`geo_native.dart` בנתיב הלא-web (`if (dart.library.js_interop) geo_web.dart`). **חוזה byte-identical** (`Future<GeoFix?>`, null=לא-זמין) → ה-callers (site-hub + worker clock-in/out) **לא משתנים**. `geo_stub.dart` נשאר כ-legacy לא-מחובר (הערה עודכנה).
- **`AndroidManifest.xml`** — נוספו `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` (foreground בלבד — **אין** `ACCESS_BACKGROUND_LOCATION`) + שני `<uses-feature android:name="android.hardware.location[.gps]" android:required="false"/>` (התקנה גם על מכשיר חסר-location, תאימות-Play).
- **`ios/Runner/Info.plist`** — נוסף `NSLocationWhenInUseUsageDescription` (עברית, ספציפי: מיקום בזמן-שהאפליקציה-פתוחה לתיוג נוכחות-ה-GPS באתר + החתמת כניסה/יציאה, "אין איסוף מיקום ברקע"). **אין** `NSLocationAlways…` (foreground בלבד).
- **`site_hub_state.dart`** — `SiteAttendanceNotifier.clockIn(now, {geo})` מקבל את הקואורדינטה האמיתית (ברירת-מחדל = `kGeoUnavailable`='מיקום לא זמין'). נוסף `formatGeo(lat,lng,{accuracyMeters})` (טהור — `32.0728°N, 34.7912°E (±12מ׳)`, hemisphere מהסימן, ±מטר רק כשדוּוח). אין נתיב-null בפורמטר (ה-caller מעביר `kGeoUnavailable` כשאין fix) → קואורדינטה מומצאת לא יכולה לדלוף.
- **`site_hub_screen.dart`** — `_clock(...isIn:true)` עכשיו `async`: `await currentGeoFix()`; fix→`formatGeo(...)`, null→`kGeoUnavailable` + טוסט כן 'מיקום לא זמין — כניסה נרשמה ב-$hhmm בלי מיקום' (אותו idiom כמו ה-worker clock-in). **`value:`/`activeColor:` — לא נוגעו; אפס Color חדש.**
- **caveat נטיב:** ה-fetch האמיתי על מכשיר (geolocator דרך platform-channel) **לא ניתן לאמת headless** — ה-gate נעול ביחידה (`geo_gate_test`), ה-permissions נעולים ב-source-guard (`geo_permissions_source_test`).
- **קבצים נגועים:** `pubspec.yaml` · `lib/services/geo.dart`·`geo_native.dart`(חדש)·`geo_gate.dart`(חדש)·`geo_stub.dart`(הערה) · `lib/state/site_hub_state.dart` · `lib/screens/site_hub_screen.dart` · `android/app/src/main/AndroidManifest.xml` · `ios/Runner/Info.plist` · `test/geo_gate_test.dart`(חדש)·`geo_permissions_source_test.dart`(חדש)·`site_hub_state_test.dart`(עודכן). **לא נגעתי:** מסכי worker-board / worker clock-in UI (נחיל-העובדים) · manager-credit (סוכן מקביל) · 4 המחלקות · `firebase_options`(F1) · `nav_launch.dart` (deep-link מפות — נשאר).
- **בדיקות (+24 · בלי package:web):** `geo_gate_test` (+13) — granted→position · denied-ואז-prompt-granted→position · service-off→null+אפס-fetch+אפס-prompt · denied-נשאר-denied→null · `deniedForever`→null+לא-נשאל · granted+fetch-זורק→null · granted+platform-מחזיר-null→null · service-check-זורק→null. `geo_permissions_source_test` (+6) — manifest: FINE+COARSE · location uses-feature `required="false"` · אין background-permission · plist: `NSLocationWhenInUseUsageDescription` עברית-ספציפי+"ברקע" · אין `Always`. `site_hub_state_test` (net +5) — clockIn-בלי-fix→`kGeoUnavailable` (לא '°N') · clockIn עם-geo→הקואורדינטה verbatim · `formatGeo` N/E·S/W·בלי-accuracy·עיגול-מטר·`kGeoUnavailable`-לא-קואורדינטה. (ה-T2.4 הישן שאישר את הדמו-הקשיח **עודכן** לחוזה-הכן.)
- **gate:** `flutter analyze` (כל הנגועים) — **0 errors** (geo_native/geo_gate + שני הטסטים החדשים = **0 issues**; ה-info היחידים שנותרו ב-`geo.dart:21`/`geo_stub.dart:7` (relative-import בתוך directive ה-conditional) + 3 ב-`site_hub_screen` = **קיימים-מראש**, אומתו ב-`git stash`; אפס raw-color חדש) · `flutter test` מלא — **+2448 -1** (baseline היה +2424 -1; +24 חדשים עוברים; ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline) · `flutter build web --release` — ✓ Built (geolocator_web מתקמפל; ה-conditional-import שומר את `geo_web.dart` שלנו ל-web → `grep geolocator main.dart.js`=**0**, אפס payload-web). **מוטציה:** ב-`geo_gate.dart` הוסר `if (perm != GeoPermissionState.granted) return null;` (ה-gate-הכן עוקף — fetch ללא-הרשאה) → 'permission denied…→null' + 'deniedForever→null' **אדום `+7 -2`** ✅ נתפס → שוחזר `cp /tmp/geo_gate.dart.bak` (**לא** git checkout; sha1 `1dff8495…` תואם) → **+9 ירוק**.
**מה לא נגעתי:** מסכי/UI worker-board (clock-in הוא נחיל-העובדים — נהנה אגב מה-seam בלי שינוי-מסך) · manager-credit · 4 המחלקות · F1 · `nav_launch`. ה-seam additive: web byte-identical (`geo_web.dart` עדיין נבחר), נטיב עבר מ-null-stub ל-geolocator חי.

### #F1 — Firebase נטיב מחווט (android+ios `firebase_options` + gradle + pbxproj) · launch blocker #1 — 2026-06-14
**הפער:** `lib/firebase_options.dart` החזיק **רק** `web`; `currentPlatform` **זרק `UnsupportedError`** לכל android/iOS → על מכשיר אמיתי `Firebase.initializeApp` נכשל (נבלע ב-`main.dart:127-135`) → האפליקציה רצה **כולה על local/demo** בנייד (וגם G4 telemetry + App Check נשארו ישנים כי `Firebase.apps` ריק). הבעלים כבר העלה ואימת את שני קבצי-הקונפיג (project `buildsmart-b0b78`, bundle/package `com.buildsmart.buildsmart`): `android/app/google-services.json` + `ios/Runner/GoogleService-Info.plist`.
**הפתרון (additive · web byte-identical · הנתונים עדיין מגודרים):**
- **`lib/firebase_options.dart`** — נוספו `static const FirebaseOptions android` ו-`ios`, עם הערכים **שנקראו verbatim** משני קבצי-הקונפיג:
  - **android** ← `google-services.json`: `apiKey`=`AIza…mrslg` (`client[0].api_key[0].current_key`) · `appId`=`1:483064122180:android:e9d240f3251e7a33ca6511` (`mobilesdk_app_id`) · `messagingSenderId`=`483064122180` (`project_number`) · `projectId`=`buildsmart-b0b78` · `storageBucket`=`buildsmart-b0b78.firebasestorage.app`.
  - **ios** ← `GoogleService-Info.plist`: `apiKey`=`AIza…VUow` (`API_KEY`) · `appId`=`1:483064122180:ios:89ac1613e3b695cfca6511` (`GOOGLE_APP_ID`) · `messagingSenderId`=`483064122180` (`GCM_SENDER_ID`) · `projectId`=`buildsmart-b0b78` · `storageBucket`=…`firebasestorage.app` · `iosBundleId`=`com.buildsmart.buildsmart` (`BUNDLE_ID`). **אין `CLIENT_ID` בקבצים** → אין `iosClientId`/`androidClientId` (Google-Sign-In לא רשום).
  - **`currentPlatform`** — הוסר ה-`throw UnsupportedError` ל-android/ios: `kIsWeb`→`web` (כמו קודם, byte-identical) · `TargetPlatform.android`→`android` · `iOS`/`macOS`→`ios` · linux/windows/fuchsia עדיין `throw UnsupportedError` ברור (פלטפורמות לא-רשומות).
- **Android Gradle (Kotlin DSL — הפרויקט `.kts`):** ב-`android/settings.gradle.kts` נוסף ל-`plugins{}` את `id("com.google.gms.google-services") version "4.4.2" apply false` (קו 4.4.x — דפוס README של firebase_core). ב-`android/app/build.gradle.kts` נוסף `id("com.google.gms.google-services")` (אחרי android/kotlin, לפני flutter-gradle-plugin) → ה-plugin **קורא בפועל** את `google-services.json` ומזריק את הקונפיג. אומת ש-`applicationId`+`namespace` = `com.buildsmart.buildsmart` = ה-`package_name` ב-json (תאימות חובה).
- **iOS pbxproj:** `GoogleService-Info.plist` **לא** היה רשום ב-`ios/Runner.xcodeproj/project.pbxproj` (לא היה נשלח ב-bundle). נוספו 4 רשומות מאוזנות (IDs ייחודיים 24-hex `F1B5…A1/A2`): `PBXFileReference` · `PBXBuildFile` · חבר ב-`Runner` `PBXGroup` · רשומה ב-**Runner** `Resources` build-phase (`97C146EC`, לא RunnerTests `331C807F`) → ה-plist נשלח ב-bundle לאתחול נטיב.
- **App Check (F2):** ללא-שינוי — מתקמפל (`app_check_providers_test` **5/5** ירוק); providers-debug נשארים default (`kAppCheckProd` OFF).
- **⚠️ מסגור-הגייטינג (חשוב):** אחרי F1, בנייד `Firebase.initializeApp` **מצליח** → Firebase **מאותחל** → מה שמפעיל (בכוונה) את ה-telemetry-המגודר-Firebase (G4) + App Check debug-providers — זו תוצאת-F1 הרצויה. **אבל** ה-DATA-backend נשאר מגודר ע"י `kUseFirebaseBackendFlag` (`USE_FIREBASE_BACKEND`, default OFF; `useFirebaseBackend => flag && Firebase.apps.isNotEmpty`) → orders/customers/וכו' **עדיין מגישים local/demo** עד שהבעלים ידליק. כלומר ברירת-המחדל של התנהגות-הנתונים **לא משתנה** — רק יסוד-ה-Firebase קם לחיים. **web: byte-identical** (ה-const `web` + ענף `kIsWeb` לא נגעו).
- **caveat android:** אין Android-SDK/toolchain בסביבה הזו (`flutter doctor` → "Unable to locate Android SDK"; `flutter build apk --debug` → "No Android SDK found") — לא ניתן להריץ את ה-gradle/google-services כאן. הסתמכתי על **analyze + נכונות-קבצי-gradle + התאמת-ערכים JSON/plist** (בדיקה קוראת את שני הקבצים). **boot על-מכשיר נטיב = צעד-ה-DoD של הבעלים.**
- **בדיקות (+18 · `test/firebase_options_test.dart`, בלי Firebase — `debugDefaultTargetPlatformOverride`):** `currentPlatform` android→`android`/iOS→`ios`/macOS→`ios` (`same(...)`, **בלי throw**) · linux/windows/fuchsia→`throwsA(UnsupportedError)` · android-options==`google-services.json` (קורא את הקובץ: apiKey/appId/senderId/projectId/storageBucket + `package_name`) · ios-options==`GoogleService-Info.plist` (קורא: API_KEY/GOOGLE_APP_ID/GCM_SENDER_ID/PROJECT_ID/STORAGE_BUCKET/BUNDLE_ID) · web UNCHANGED (כל 7 השדות S0.2) · שלוש הפלטפורמות חולקות `projectId` אחד אבל 3 `appId` נבדלים.
- **gate:** `flutter analyze` (`firebase_options.dart`+`main.dart`+הטסט) — **0 errors** (`firebase_options.dart`=**0 issues**; ה-info ב-`main.dart` קיימים-מראש בלבד; אפס raw-color) · `flutter test` מלא — **+2466 -1** (baseline היה +2448 -1; +18 חדשים עוברים; ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline, אומת בבידוד `+1 -1`) · `flutter build web --release` — ✓ Built (web לא-מושפע). **מוטציה:** ב-`firebase_options.dart` ה-`android.projectId` שונה ל-`WRONG-PROJECT-MUTANT` → 3 בדיקות **אדום `+15 -3`** (Expected `buildsmart-b0b78` / Actual `WRONG-PROJECT-MUTANT`) ✅ נתפס → שוחזר `cp /tmp/firebase_options.dart.GOOD` (**לא** git checkout; diff=זהה) → **+18 ירוק**.
**קבצים נגועים:** `lib/firebase_options.dart` · `android/settings.gradle.kts` · `android/app/build.gradle.kts` · `ios/Runner.xcodeproj/project.pbxproj` · `test/firebase_options_test.dart`(חדש). **לא נגעתי:** קבצי-הקונפיג (`google-services.json`/`GoogleService-Info.plist` — של הבעלים) · `main.dart`/App-Check · worker-board / 4 המחלקות · manager-credit · geo. **pubspec.lock לא staged.**

### #auth-gate — הרשמה/כניסה אמיתית מגודרת (flag ON) — 2026-06-14
- **`auth_state.dart`:** הוסף `createUserWithEmailPassword` ל-AuthGateway+FirebaseAuthGateway+notifier (דרך `_guard`/`_required`) — חשבון-Firebase אמיתי, לא register-מקומי. בלי gateway (Firebase-free) → `unavailable` נייטרלי.
- **`login_sheet.dart`:** ל-email pane נוסף מצב **"צור חשבון"** (שדה-סיסמה + createUser) לצד sign-in; מיפוי-שגיאות עברי כן (`email-already-in-use`→"האימייל כבר רשום — התחברו במקום" · `weak-password`→"סיסמה חלשה (6+)" · invalid-email). phone→code + reCAPTCHA-fallback ללא שינוי.
- **`welcome_screen.dart`:** "אישור והמשך" כש-flag ON → שדה-סיסמה + createUser (חשבון אמיתי). שער: בלי חשבון אפשר רק הרשמה/כניסה **או** "דמו" מסומן-בבירור; כש-OFF — register-מקומי verbatim (אפס-רגרסיה).
- **`profile_screen`:** שורת-כניסה (showLoginSheet) + 🚪 התנתקות פעילות תחת הדגל (signOut→חוזר לשער).
- **אימות (orchestrator — הסוכן נעצר בשלב-האימות; השלמתי):** analyze 0-errors · ratchet נקי · 6 קבצי-טסט עודכנו (269 הוספות / 5 מחיקות — **אפס skip/הסרת-expect**; ה-+3 בטסטי-הריפל = override-interface ל-createUser ב-test-doubles) · full-suite **+2475 -1** (ה-`-1` היחיד = `worker_reports_drilldown` baseline, אומת בבידוד) · build web ✅ · mutation §mutation_log. flag OFF byte-identical. **לא נגעתי:** worker-board / 4 מחלקות / firebase_options / CI / geo / manager-credit.

### #order-sync-fix — סנכרון-הזמנות בין-מכשירים: rules create-gate + index field-names + דיאגנוסטיקה — 2026-06-14
- **הבאג (real-device, flag ON, קבלן אמיתי `meir7651231@gmail.com`):** הזמנה שנוצרה בטלפון **לא הופיעה בדפדפן** של אותו חשבון.
- **שורש (root cause, ביטחון גבוה):** כלל ה-`create` ב-`firestore.rules` על `orders` (`allow create: if hasRole('contractor') && stage=='new' && contractorUid==auth.uid`) דרש את ה-**claim** `contractor`. אבל זהות-ה-`contractor` היא **ברירת-המחדל ללא-claim** — ה-callable `setRole` + `manager_role_assign_sheet` מקצים אך-ורק תפקידים-מיוחדים (manager/store/courier/worker) ו**מסרבים במכוון** להקצות 'contractor' (ראה `RoleOption` doc ב-`manager_role_assign_sheet.dart`). לכן קבלן-אמיתי מחובר נושא **0 role-claim** ⇒ `hasRole('contractor')`==false ⇒ **כל** יצירת-הזמנה נדחתה (`permission-denied`). ה-`set` ברקע עובר דרך `guardWrite` (`firestore_cached_repo.dart:302`) ש**בולע** את הדחייה (`debugPrint`, אף-פעם לא נזרק) ⇒ ההזמנה מופיעה אופטימית במכשיר-המניח (cache) אבל **לא מגיעה ל-Firestore** ⇒ אין סנכרון. **הקריאה תקינה:** `_ordersScopeFor` של הקבלן (`orders_local.dart:191`) = `where('contractorUid'==uid)` (= `ownsOrder` ב-rules + index #1), בלי `orderBy` (המיון client-side ב-`sortBy`) — מסכים לחלוטין. **השדה הנכתב תקין:** `toDoc` כותב `contractorUid` (קו 81). הבאג כולו = שער-היצירה גידר על claim שלקבלן אין.
- **תיקון 1 (root cause · `firestore.rules`):** ה-create gate שונה מ-`hasRole('contractor')` ל-**`isSignedIn()`** (`stage=='new' && contractorUid==auth.uid` נשמרו). הבעלות עדיין קשורה ל-uid-המניח (אי-אפשר לזייף uid אחר; עדיין נעוץ ל-'new') — זו בדיוק אותה רמת-הקשחה, רק על המפתח-הנכון (ה-uid ש-ההזמנה קשורה אליו, לא claim שלא קיים). מנהל/admin create ללא-שינוי.
- **תיקון 2 (`firestore.indexes.json`):** index #2/#3 שונו `storeId`/`courierId` → **`storeUid`/`courierUid`** (להתאים ל-`toDoc` קווים 86-87 + ל-store/courier branch ב-`_ordersScopeFor`). השדות-הישנים אף-פעם לא נכתבו ⇒ ה-store/courier scoped query (`where('storeUid'==uid).orderBy('ts')`) רץ **בלי index** ⇒ `failed-precondition`. עודכנו גם הערות-ה-`//` הישנות (שאמרו storeId/courierId "טרם נכתבים").
- **תיקון 3 (`firestore_cached_repo.dart:99`):** doc-comment example `contractorId`→`contractorUid` (היה מטעה — `contractorId` הוא שם-התצוגה, לא uid).
- **דיאגנוסטיקה (בקשת-הבעלים · זמני · `backend_debug_badge.dart`):** ה-self-test של ה-badge הקיים הורחב ל-**4 צעדים** (`fsDiagStepResult` טהור ממפה כל צעד ל-✅/❌+קוד): (1) כתיבה/קריאה `diag/{uid}` · (2) כתיבת `users/{uid}` · (3) **שאילתת-ההזמנות-שלי** `where('contractorUid'==uid).orderBy('ts' desc).limit(1)` (index-חסר → `failed-precondition`+URL) · (4) **יצירת-הזמנה אמיתית** (ואז ניקוי) — דחיית-rules → `permission-denied` (=ה-smoking-gun). ה-badge מגודר `kDebugMode || FS_DIAG` (`debugOverlayChildren` ב-`main.dart` קיבל `fsDiag=kFsDiag`; הקבוע ב-`backend.dart`). הפעלה ב-APK חתום: `--dart-define=FS_DIAG=true --dart-define=USE_FIREBASE_BACKEND=true`.
- **seam ניתן-לבדיקה (`orders_local.dart`):** נוספו קבועי-שם-שדה (`kOrdersContractorScopeField='contractorUid'` · `kOrdersStoreScopeField='storeUid'` · `kOrdersCourierScopeField='courierUid'`) ש-`_ordersScopeFor` בונה מהם את ה-`where(...==uid)`, + `debugOrdersScopeField(role)` (`@visibleForTesting`, טהור) — תיאור-נאמן של החיווט-החי (אותם קבועים) לבדיקה בלי-Firestore.
- **OFF byte-identical:** `kFsDiag` + `kUidScopedQueries` שניהם compile-time OFF ⇒ ה-badge נשאר debug-only (release לא-מראה כלום), ה-scope נשאר whole-collection — כהיום. ה-rules+index הם **server-side** (לא חלק מבייטי-האפליקציה). אפס `Color`/`value:`/`activeColor:` חדש (קבועי-צבע קיימים בלבד).
- **caveat נייד:** אישור-הסנכרון-האמיתי = on-device בלבד (לא headless) — הדיאגנוסטיקה (FS_DIAG=true) תַראֶה את ה-`permission-denied`/`failed-precondition`+URL המדויק. **deploy של rules+index = פעולת-בעלים:** `firebase deploy --only firestore:rules,firestore:indexes --project buildsmart-b0b78` (ה-rules מתוקנים נכנסים לתוקף רק אחרי deploy).
- **בדיקות (+13 · `test/orders_sync_scope_index_diag_test.dart`, Firebase-free):** scope: contractor(null)→`contractorUid` (ולא `contractorId`) · worker→`contractorUid` · store→`storeUid`/courier→`courierUid` (ולא ...Id) · manager/admin→null · הקבועים נכונים. index↔toDoc: כל שדות-ה-orders-index נכתבים ב-`toDoc` (אין `storeId`/`courierId`) + index(`contractorUid`,`ts`) קיים (קורא את `firestore.indexes.json` בפועל דרך `File('../...')`). דיאגנוסטיקה: `fsDiagStepResult` null→✅+code-ריק · `permission-denied`→❌+הקוד+ההודעה · `failed-precondition`→ה-URL verbatim · שגיאה-לא-Firebase→❌+הטקסט.
- **gate:** `flutter analyze` (כל הנגועים + הטסט) — **0 errors** (כל ה-issues `info`-בלבד · אפס raw-color/`value:`/`activeColor:`) · `flutter test` מלא — **+2488 -1** (baseline היה +2475 -1; +13 חדשים עוברים; ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline) · `flutter build web --release` — ✓ Built. **מוטציה:** ב-`firestore.indexes.json` שדה-ה-index `storeUid`→`storeId` → 'every orders index field is a field toDoc writes' **אדום `+5 -1`** (`Expected: not contains 'storeId'` / `Actual: Set:[...,'storeId',...]`) ✅ נתפס → שוחזר `cp /tmp/firestore.indexes.json.good` (גיבוי byte-for-byte) → **+11 ירוק**.
- **קבצים נגועים:** `firestore.rules` · `firestore.indexes.json` · `lib/data/repositories/backend.dart`·`orders_local.dart`·`firestore_cached_repo.dart` · `lib/main.dart` · `lib/widgets/backend_debug_badge.dart` · `test/orders_sync_scope_index_diag_test.dart`(חדש). **לא נגעתי:** worker-board / 4 המחלקות / auth-gate / `firebase_options` / manager-credit / geo. **pubspec.lock לא staged.**

### #manager-owner — מנהל = חשבון בעלים: בלי logout, בלי demo (שלב 1/4) — 2026-06-15
- **רקע (דרישת מוצר):** המנהל = חשבון-הבעלים: "לא מתנתק", "אין לו דמו", כניסה הכי-מאובטחת, וגישה לכל-המסכים. תוכנית 4 שלבים — שלב 1 (כאן): בלי-logout + בלי-demo · שלב 2: סיסמה אישית (salted-hash) במקום קוד `5555` · שלב 3: גישה-לכל-המסכים (override מרוכז בשערי-הלוחות) · שלב 4: תפר-Firebase אמיתי למנהל (forward-ready, כבוי בדמו).
- **`manager_dashboard_screen.dart`:** הוסר כפתור logout (`Icons.logout`→`boardAuthProvider.logout`) מ-AppBar actions + המתודה `_logout`. '‹ יציאה' (`Navigator.maybePop` — ניווט-בלבד, לא מנקה session) נשמרה. הוסר import לא-בשימוש `confirm_dialog` (`showToast` עדיין בשימוש בטאבים אחרים).
- **`manager_profile_screen.dart`:** הוסרה שורת '🚪 יציאה מהחשבון' (+ ה-Divider שלפניה) + המתודה `_logout`; הוסרו imports לא-בשימוש (`confirm_dialog`+`toast`); כותרת-הקובץ עודכנה (2 פעולות + הערת "המנהל לא מתנתק").
- **`welcome_screen.dart` (שער role-mode):** כפתור "מצב דמו" ב-`_boardLoginChildren` מגודר `if (role != BoardRole.manager)`; `_demo()` קיבל הגנה `if (role == BoardRole.manager) return`. עובד/שליח/ספק — דמו verbatim.
- **OFF byte-identical:** הסרת-UI בלבד למסלול-המנהל; מודל `boardAuthProvider` (`enterDemo`/`logout`) לא נגע (עדיין callable ⇒ `board_auth_test` ללא-שינוי). שאר הפרסונות ללא-שינוי.
- **gate:** `flutter analyze` (3 הנגועים) — **0 errors** (info קיימים-מראש; הוסרה אזהרת unused_import שלי) · `flutter test` מלא — **+2626 -1** (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline, אומת בבידוד עם-ובלי-השינוי `+1 -1` ⇒ 0 כשלים חדשים) · isolation manager_dashboard/board_auth/apple_readiness/widget — ירוקים.
- **קבצים נגועים:** `lib/screens/manager_dashboard_screen.dart` · `lib/screens/manager_profile_screen.dart` · `lib/screens/welcome_screen.dart`. **לא נגעתי:** board_auth model / עובד·שליח·ספק / auth-gate / firebase_options / manager-credit / geo.

### #manager-owner — כניסת מנהל = "כניסה עם Google" (שלב 2/4) — 2026-06-15
- **רקע (החלטת בעלים):** המנהל = חשבון-הבעלים; הכניסה הכי-מאובטחת = Google (firebase_auth Google provider) — גוגל מנהלת סיסמה/2FA/שחזור, אפס סיסמה במכשיר. הבעלים = `meir7651231@gmail.com`. כנות: אבטחה-אמיתית-מלאה = שלב 4 (claim+rules server-side); שלב 2 = הסרת הסיסמה-המקומית-הידועה והעברה ל-OAuth של גוגל.
- **`pubspec.yaml`:** נוסף `google_sign_in: ^6.2.1` (נייד: token-flow→GoogleAuthProvider; web: signInWithPopup). pub get נקי.
- **`auth_state.dart`:** (1) `AuthGateway.signInWithGoogle()` חדש (interface) + impl ב-`FirebaseAuthGateway` (web `signInWithPopup(GoogleAuthProvider())` · נייד `gsi.GoogleSignIn().signIn()`→credential→`signInWithCredential`; null=cancel) דרך `_guard`; (2) flow `AuthStateNotifier.signInWithGoogle()` דרך `_required`; (3) **`authGatewayProvider` נותק מ-`useFirebaseBackend` ל-`Firebase.apps.isNotEmpty`** — auth זמין כש-Firebase אותחל (main מאתחל web+נייד) גם כשה-DATA-backend דמו; Firebase-free (כל הסוויטה) → null → byte-identical signed-out.
- **`board_accounts_local.dart` (lib/data):** `kOwnerEmails` + `isOwnerEmail(email)` (trim+lowercase) — שער-הבעלים.
- **`board_auth.dart` (lib/state):** `loginManagerViaGoogle({uid, displayName})` — קובע session-מנהל אמיתי (לא-demo) עם ה-uid; נשמר (הבעלים נשאר מחובר).
- **`welcome_screen.dart` (lib/screens):** שער-המנהל (`role==manager`) קוצר ל-`_managerGoogleChildren()` — כפתור "המשך עם Google" בלבד (בלי seed code, בלי demo); `_managerGoogleLogin()` → signInWithGoogle → `isOwnerEmail` → `loginManagerViaGoogle`, וזר → signOut+טוסט. בלי Firebase → הודעת "דורשת חיבור" כנה. עובד/שליח/ספק — seed login verbatim.
- **6 fakes (test):** stub `signInWithGoogle async => null` (ה-interface חייב impl).
- **OFF byte-identical:** משתמש לא-מחובר ⇒ authGatewayProvider live אבל currentUser=null ⇒ signed-out כמו היום; ה-DATA נשאר demo (`useFirebaseBackend` נפרד). ה-seed `admin/5555` עדיין בקוד אך **לא נגיש מה-UI** (שער-המנהל Google-בלבד) — יוסר בשלב-המשך עם ה-claim.
- **gate:** analyze **0 errors** · full-suite **+2632 -1** (ה-`-1` = `worker_reports_drilldown` baseline; +6 חדשים ירוקים) · mutation §mutation_log (`isOwnerEmail`→true ⇒ `+3 -2` ✅). **caveat בעלים (חובה לפני שעובד):** הפעלת ספק Google ב-Console + SHA-1 אנדרואיד + דומיין web — `knowledge/owner/google-signin-setup.md`.
- **קבצים נגועים:** `pubspec.yaml` · `lib/state/auth_state.dart` · `lib/state/board_auth.dart` · `lib/data/board_accounts_local.dart` · `lib/screens/welcome_screen.dart` · 6 fakes · `test/manager_google_login_test.dart`(חדש) · `knowledge/owner/google-signin-setup.md`(חדש). **לא נגעתי:** worker-board / 4 מחלקות / firebase_options / CI / geo.
### #E3-leak-fix — בקשות-חומר: scope-עובד per-username במקום session.uid (דליפה חוצת-משתמשים) — 2026-06-15
- **הבאג (ביקורת-תקינות אדוורסרית של הצי · high):** `requestsForWorker` מיקד את "הבקשות שלי" של העובד על `workerUid` = `session.uid`, אבל uid מאוכלס רק בנתיב Firebase-Auth (`kUidScopedQueries` כבוי כברירת-מחדל ב-backend.dart) — בנתיב seed/demo החי (login/enterDemo) כל עובד נושא uid ריק. לכן `workerUid==''` לכולם ו-`requestsForWorker('')` החזיר את בקשות-החומר הפרטיות של כל עובד לכל עובד אחר (הפרת #66 "כל עובד רואה רק את שלו").
- **התיקון (תבנית-האחים VacationRequest/AttendanceDay/WorkerCert שכבר מסננים לפי username):** `MaterialRequest` קיבל שדה-scope `username` (submit חותם אותו, requestsForWorker מסנן לפיו); `workerUid` נשמר כ-id additive מוכן-לשרת (username==uid בנתיב Firebase → אפס רגרסיה). `worker_employer_stock_sheet` מעביר `session.username` בקריאה ובהגשה.
- **gate:** analyze 0 · caller יחיד (הגיליון) עודכן · mutation §mutation_log (RED `+7 -1` בהחזרת הפילטר→workerUid · GREEN `+8` משוחזר) · ANTIPATTERN+RULE §stuck_log · stuck_regression מסונכרן.
- **קבצים נגועים:** `lib/state/material_requests_engine.dart` · `lib/screens/worker_employer_stock_sheet.dart` · `test/material_requests_test.dart` (+טסט-בידוד seed-session). **לא נגעתי:** orders / auth / firebase / manager-board / worker-board. נמצא ע"י ביקורת-הלילה האוטונומית של הצי.

### #R2-seq-guard — מגן _seq ל-id מבוסס-timestamp ב-4 stores (דליפת-מחיקה) — 2026-06-15
- **הבאג (ביקורת-לילה סבב-2 · medium/low):** WorkerCert/SickNote/CartList/SavedProject מינטו id מ-timestamp בלבד; על web (~1ms) שתי יצירות באותה מילישנייה → id זהה → remove/delete/rename מחקו או שינו את שתיהן.
- **התיקון:** `int _seq = 0;` + סיומת `-${_seq++}` ל-id בכל 4 ה-notifiers (תבנית worker_trainings/worker_notifs). id נשאר String אטום → אפס שינוי-persist.
- **gate:** analyze 0 · טסט `id_seq_collision_test` (4 חנויות) · mutation §mutation_log (RED `+3 -1` הסרת _seq מ-worker_certs · GREEN `+4`) · ANTIPATTERN+RULE §stuck_log · stuck_regression מסונכרן.
- **קבצים:** `lib/state/worker_certs.dart` · `worker_forms.dart` · `cart_lists_state.dart` · `saved_projects.dart` · `test/id_seq_collision_test.dart`. **לא נגעתי** ב-UI / orders / auth / manager-board.

### #A1-tasks-persistence — משימות-ריצה (קבלן/עובד) שורדות restart + server-ready — 2026-06-15
- **הבאג (החלטת-בעלים A1 · high):** ה-_load של tasks_engine בנה state רק מ-seeds קבועים plus overlay → משימה שקבלן יצר (createTask) או עובד הציע (proposeTask) נמחקה ב-restart (ה-overlay גם לא שמר את ה-name/steps/worker שלה).
- **התיקון:** TaskItem += toJson/tryFromJson; _persist שומר משימות-ריצה (non-seed ids) כרשומות-מלאות תחת kTasksRuntimeKey; _load משחזר אחרי seed plus overlay. **server-ready:** bindRemote (T1) יסנכרן חי כשה-Firebase ינחת. back-compat: מפתח-prefs נפרד.
- **gate:** analyze 0 · טסט `tasks_runtime_persistence_test` (+2) · 3 טסטי-overlay הקיימים ירוקים (לא נשבר) · mutation §mutation_log (RED +0 -2 ביטול-השחזור · GREEN +2).
- **קבצים:** `lib/state/tasks_engine.dart` · `test/tasks_runtime_persistence_test.dart`. **לא נגעתי** ב-UI / מסכים / orders / auth.

### #A2-hr-decide-once — אישור HR יורה פעם-אחת (לא double-fire) — 2026-06-15
- **הבאג (החלטת-בעלים A2 · medium):** _decide/_decideTraining ב-contractor_hr_sheet ירו פעמון plus צ'אט plus toast ללא-תנאי → double-tap (או שני-משטחים) שלח לעובד התראה כפולה.
- **התיקון:** approve/reject/_decide ב-vacation_requests plus worker_trainings מחזירים bool (מעבר-אמיתי); הווידג'ט יורה רק אם true. הקבלן מחזיק את ההתראה (פעמון plus צ'אט ב-th-worker-contractor, פעם-אחת). ה-double-fire בלוח-המנהל נפתר כש-#84g יוציא HR מהמנהל.
- **gate:** analyze 0 · טסט `hr_decide_once_test` (+2) · 17 טסטי-אישור הקיימים ירוקים (void→bool additive) · mutation §mutation_log (RED +1 -1 · GREEN +2).
- **קבצים:** `lib/state/vacation_requests.dart` · `worker_trainings.dart` · `lib/screens/contractor_hr_sheet.dart` · `test/hr_decide_once_test.dart`. **לא נגעתי** בלוח-המנהל.

### #A3-pod-signature — חתימת POD נשמרת-באמת או אומרת-אמת — 2026-06-15
- **הבאג (החלטת-בעלים A3):** persona_pod_sheet הריע "נשמרה" גם כשה-persist נכשל (captureSignature היה void/fire-and-forget) → ב-restart החתימה נעלמה.
- **התיקון:** captureSignature → Future<bool> (await _persist plus rollback, חיקוי capturePod); הכפתור מריע "נשמרה ✍️" רק על true, אחרת "לא נשמרה — נסה שוב". server-ready: החתימה רוכבת על ה-side-car הראשי podSig ושורדת restart (bindRemote יזרים חי).
- **gate:** analyze 0 · persona_fulfillment_test +23 · mutation §mutation_log (return ok→false → A3 reload-test RED +22 -1 · GREEN +23).
- **קבצים:** `lib/state/persona_fulfillment.dart` · `lib/screens/persona_pod_sheet.dart` · `test/persona_fulfillment_test.dart`.

### #A4-dst-day-idiom — offset-יום DST-safe אחיד (גאנט + 2 דוחות) — 2026-06-15
- **הבאג (החלטת-בעלים A4):** offset-יום ב-local-midnight difference inDays (גאנט startDay · worker/courier reports dayIdx) מתקצר ביום על גבול spring-forward; weekStart ב-subtract Duration נסחף גם.
- **התיקון:** עוזר טהור משותף `lib/logic/calendar_days.dart` — `daysBetweenDst` (DateTime.utc, ימי-24h) plus `startOfWeekSunday` (DateTime y m d-k חשבון-לוח). 3 אתרי-offset plus 2 weekStart עוברים דרכו. idiom אחיד.
- **gate:** analyze 0 · calendar_days_test +6 (TZ=Israel, spring-forward 27/3/2026) · contractor_task_gantt_test +21 ירוק · mutation §mutation_log (DateTime.utc→DateTime → 3 טסטי-DST RED +3 -3 · GREEN +6).
- **קבצים:** `lib/logic/calendar_days.dart` (חדש) · `lib/logic/tasks_gantt.dart` · `lib/screens/worker_reports_tab.dart` · `lib/screens/courier_reports_tab.dart` · `test/calendar_days_test.dart` (חדש).

### #A5-board-proposed-fold — משימה מוצעת מקופלת ל-בתור בלוח-המשימות — 2026-06-15
- **הבאג (החלטת-בעלים A5):** worker_task_board_screen קיבץ לפי status אבל לא כיסה proposed → משימה שעובד הציע (ממתינה לאישור קבלן) הייתה בלתי-נראית בלוח.
- **התיקון:** כל קבוצה = Set-של-statuses; proposed קופל ל-⏳ בתור (לא קבוצה נפרדת). חולצה `groupByStatus` טהורה. כל status ממופה לקבוצה אחת → counts sum to total.
- **gate:** analyze 0 · worker_task_board_group_test +1 · mutation §mutation_log (הסרת proposed מסט-בתור → RED +0 -1 · GREEN).
- **קבצים:** `lib/screens/worker_task_board_screen.dart` · `test/worker_task_board_group_test.dart`.

### #52-order-notif-to-orders-world — התראות הזמנה/משלוח בעולם-ההזמנות — 2026-06-15
- **המהלך (החלטת-בעלים #52, מאושר):** 2 ההתראות הקשורות-הזמנה typeOrders/typeShipments עברו ממסך-ההגדרות אל עולם-ההזמנות — 🔔 בכותרת טאב 📦 הזמנות (store_screen) → גיליון OrderNotifSheet. שאר ההתראות נשארו בהגדרות › התראות.
- **חיווט:** הגיליון קושר את אותו `notifSettingsProvider` — מקור-אמת יחיד, אין עותק. שורות-ה-UI ב-notif_settings_screen הוסרו (השדות/copyWith במודל נשארו — engine-tests לא הושפעו).
- **gate:** analyze 0 · order_notif_sheet_test +1 (widget: tap → provider flips) · mutation §mutation_log (RED +0 -1 · GREEN) · de-risk: notif_settings_wiring/edge_cases/robustness/settings_honesty ירוקים.
- **קבצים:** `lib/screens/order_notif_sheet.dart` (חדש) · `lib/screens/store_screen.dart` · `lib/screens/notif_settings_screen.dart` · `test/order_notif_sheet_test.dart`.

### #50-settings-merge-dup-categories — מיזוג קטגוריות כפולות בהגדרות — 2026-06-15
- **המהלך (החלטת-בעלים #50):** במסך 'הגדרות' (catalog_settings) — 2 מקטעי-🔔 → 'התראות' יחיד · 2 מקטעי-תצוגה → 'תצוגה ומיון' יחיד · price-drop קנוני יחיד = `notifPriceDrop` (הוסר ה-toggle הכפול typePriceDrops 'התראות תקציב'). order/shipment הושמטו (עולם-ההזמנות, #52). 13→11 מקטעים.
- **gate:** analyze 0 · 4 טסטי-מסך ירוקים (catalog_sort_alerts/catalog_price_units/robustness/settings_honesty) · mutation §mutation_log ('מלאי נמוך'→mut → RED +14 -1 · GREEN +16).
- **שארית (תועדה):** typePriceDrops עדיין ב-notif_settings_screen (מסך-נפרד, לא קטגוריה כפולה בהגדרות) · priceChangeAlert במועדפים → ל-#54.
- **קבצים:** `lib/screens/catalog_settings_screen.dart` · `test/catalog_sort_alerts_settings_test.dart`.

### #54-remove-favorites-category — 'מועדפים ורשימות' הוסרה מההגדרות — 2026-06-15
- **המהלך (החלטת-בעלים #54):** הוסר המקטע ❤️ 'מועדפים ורשימות' מ-catalog_settings (11→10 מקטעים). priceChangeAlert → מכוסה ע"י ה-price-drop הקנוני ב-'התראות' (#50); השדה נשאר במודל. 4 ה-placeholders (סנכרון/שיתוף/יבוא-ייצוא/רשימות-פרויקט) → server-ready seams במשטחי-המועדפים, נדחה עד שקע-הגדרות שם.
- **gate:** analyze 0 · 4 טסטי-מסך ירוקים · RED→GREEN §mutation_log (טסט-findsNothing אדום בעוד המקטע קיים +0 -1, ירוק אחרי הסרה).
- **קבצים:** `lib/screens/catalog_settings_screen.dart` · `test/catalog_sort_alerts_settings_test.dart`.

### #49-wire-supplier-prefs — ספקים מועדפים: 3 העדפות מחווטות server-ready — 2026-06-15
- **המהלך (החלטת-בעלים #49):** `_SuppliersSection` ב-catalog_settings — חיווט 3 השדות המגובים לפקדים נשמרים: maxDistance (_NumberRow), minRating (_RadioGroupRow), localSuppliersOnly (_SwitchRow). שמירה מקומית עכשיו · server-ready (הסינון מופעל כשצד-הספק יזין מרחק/דירוג/מקומיות). preferred/blocked = seams (דורשים זהות-ספק). שאר ה-placeholders (AI/השוואת-מחירים) חסומי-דאטה-חיצונית → seams כנים (#56).
- **gate:** analyze 0 · catalog_sort_alerts +1 (toggle→persist) · robustness/settings_honesty ירוקים · mutation §mutation_log (localSuppliersOnly no-op → RED +0 -1 · GREEN).
- **קבצים:** `lib/screens/catalog_settings_screen.dart` · `test/catalog_sort_alerts_settings_test.dart`.

### #99-rewards-private-per-user — BuildCoins פרטי per board user — 2026-06-15
- **הבאג (החלטת-בעלים #99 · P-6/F-33):** BuildCoins/התקדמות נשמרו תחת מפתח גלובלי יחיד → דלפו בין משתמשי-לוח.
- **התיקון:** `RewardsNotifier._storageKey` = `'$kRewardsKey.$username'` (ריק→גלובלי back-compat); ה-provider קורא boardAuthProvider.username ובונה notifier scoped (re-build על login/switch). leaderboard נשאר seed משותף (רק 'אתה' פרטי). workerNotifs כבר היה per-username (P-13).
- **gate:** analyze 0 · rewards_per_user_test +1 (שני usernames מבודדים) · t3_ghi_rewards ירוק אחרי תיקון-binding · mutation §mutation_log (key→גלובלי-תמיד → RED +0 -1 · GREEN).
- **שארית:** אין מיגרציה ממפתח-גלובלי קודם (מטבעות דמו מקומיים).
- **קבצים:** `lib/state/rewards_state.dart` · `test/rewards_per_user_test.dart` · `test/t3_ghi_rewards_ai_home_test.dart` (setup).

### #99-addendum — board_auth._load resilience (root-cause of the gate-32 baseline) — 2026-06-16
- כש-`rewardsProvider` התחיל `ref.watch(boardAuthProvider)` (#99), כל טסט שמרנדר מסך-קורא-rewards (worker/courier reports · rewards hub · drilldowns) בנה את `BoardAuthNotifier`. ב-`_load` ה-`await SharedPreferences.getInstance()` **לא** היה ב-try/catch (רק ה-jsonDecode) — וב-context בלי `setMockInitialValues`/binding זה זורק "Binding not initialized" (StateError) כשגיאה אסינכרונית **לא-מטופלת** → הטסט נכשל.
- **התיקון:** עטיפת כל ה-`_load` ב-try/catch (כמו rewards_state ומנועים אחרים) → כשל-prefs נבלע, נשאר logged-out. תיקון-robustness אמיתי.
- **בונוס:** זה היה גם שורש ה-baseline הקדם-קיים `worker_reports_drilldown` (קורא דרך drilldown→boardAuth). אחרי התיקון הסוויטה המלאה = **+2658 ALL PASS, 0 כשלים**. baseline עודכן 1→0 (STATUS.md + known_failing.txt).
- **קבצים נוספים ל-#99:** `lib/state/board_auth.dart` · `knowledge/STATUS.md` · `knowledge/known_failing.txt`.

### #36-voice-dictate-worker-board — כפתור קול↔הקלדה (לוח עובד) — 2026-06-16
- **המהלך (החלטת-בעלים #36):** widget חדש `VoiceDictateButton` (מיקרופון per-field, מכתיב דרך VoiceService ל-controller, append cursor-safe). מחווט כ-suffixIcon ל-3 שדות גיליון-הצעת-המשימה בלוח-העובד (שם/תיאור/שלבים). לוח-עובד בלבד, לא app-wide. ה-STT מוזרק (seam) לבדיקה.
- **gate:** analyze 0 · voice_dictate_button_test +2 (fake-listen → השדה מתמלא) · mutation §mutation_log (_append early-return → RED +0 -2 · GREEN +2).
- **קבצים:** `lib/widgets/voice_dictate_button.dart` (חדש) · `lib/screens/worker_app_screen.dart` · `test/voice_dictate_button_test.dart`.

### #45-weather-open-meteo — תחזית מזג-אוויר אמיתית (Open-Meteo + GPS) — 2026-06-16
- **המהלך (החלטת-בעלים #45):** `lib/services/weather.dart` — Open-Meteo (חינמי ללא-מפתח) דרך currentGeoFix (#100 GPS); mapper טהור WMO→אמוji/הערה/טמפ; `weatherForecastProvider` עם fallback ל-kWeather. `_Weather` ב-ai_hub צורך את ה-provider (דאטה אמיתית במקום seed קשיח).
- **gate:** analyze 0 · weather_service_test +3 (mapper · thresholds · malformed-tolerant) · ai_hub_compute/robustness ירוקים · mutation §mutation_log (rain ⚠️ הוסר → RED +1 -2 · GREEN +3).
- **שארית:** הכלי נשאר deferred/hidden ל-Apple (un-hide = flip בשחרור) · schedule-automation מהתחזית = micro-confirm עתידי.
- **קבצים:** `lib/services/weather.dart` (חדש) · `lib/screens/ai_hub_screen.dart` · `test/weather_service_test.dart`.

### #manager-owner — מנהל ניגש לכל המסכים (התחזות · שלב 3/4) — 2026-06-16
- **רקע:** המנהל = מנהל-הצי; צריך לפתוח כל לוח (עובד/שליח/ספק/קבלן) ולחזור. גישת הצי (b): session-swap מתוחם (impersonation), לא override פר-שער.
- **`board_auth.dart` (lib/state):** `impersonate(BoardRole)` — מחליף את ה-session לחשבון-ה-seed של התפקיד (worker→ran עם employerId, courier→dudi, store→lipskey), שומר את session-המנהל ב-`_impersonationReturn` (מחסנית-חזרה חד-עומק). **לא נשמר** (restart חוזר ל-session-המנהל הזכור). `returnFromImpersonation()` משחזר. `isImpersonating` getter + `_seedFor(role)` עוזר. no-op אם ה-session הנוכחי אינו מנהל / אין seed.
- **`manager_screens_sheet.dart` (lib/screens, חדש):** `showManagerScreensSheet` — grid עם 4 יעדים (🦺 עובד/🛵 שליח/🏪 חנות ספק/👷 קבלן). הקשה → impersonate + push דרך `_ImpersonationFrame` (PopScope→returnFromImpersonation בחזרה) + באנר כן "👔 צפייה כ-X · מצב מנהל" עם "חזרה לניהול". קבלן = HomeShell (לא לוח-מגודר, בלי impersonation).
- **`manager_profile_screen.dart` (lib/screens):** הפעולה "🔁 החלפת תפקיד" (קוד-מעבר→showRolePicker) הוחלפה ב-"🖥️ מעבר בין מסכים" → showManagerScreensSheet (בלי קוד — המנהל הוא admin). הוסרו `_askRoleSwitch` + `_RoleSwitchCodeDialog` + imports לא-בשימוש (role_picker_sheet + board_accounts_local).
- **gate:** analyze **0 errors** · full-suite **+2675 -1** (ה-`-1` = `worker_reports_drilldown` baseline; +3 חדשים = manager_impersonate_test) · manager_dashboard/board_auth ירוקים.
- **קבצים נגועים:** `lib/state/board_auth.dart` · `lib/screens/manager_screens_sheet.dart`(חדש) · `lib/screens/manager_profile_screen.dart` · `test/manager_impersonate_test.dart`(חדש). **לא נגעתי:** שערי-הלוחות (worker/courier/store) — עוברים בלי שינוי (ה-session הוא seed תקין).
### #31-help-coverage-wave1 — מצב-היכרות כיסוי גל 1 (chrome ראשי של הקבלן) — 2026-06-16
- **המהלך:** הרחבת כיסוי "מצב היכרות" (#30→#31) לפי לוח, גל 1 = home_shell. נוסף helper `showHelpInfo` ל-help_target. ב-home_shell: לוגו/חיוג-תפקיד, שבב-שם/פרופיל, חיפוש, ו-4 וריאנטי ⋮ עטופים ב-HelpTarget; 4 טאבי-הניווט מוסברים במצב-היכרות דרך showHelpInfo במקום ניווט.
- **עיקרון:** ה-💡 וה-✕ לא נעטפים (אחרת לוכדים את המשתמש במצב); אלמנטים מחוץ לשכבת-ההקפאה מוסברים דרך showHelpInfo במקום בועת-זנב.
- **gate:** analyze 0 · help_coverage_test +2 (chrome מכוסה · tap-טאב מסביר) · mutation §mutation_log.
- **שארית (גלים הבאים):** שליח→חנות→מנהל→מסכים-עמוקים. מפת-דרכים מלאה ב-help-coverage-roadmap workflow.
- **קבצים:** `lib/widgets/help_target.dart` · `lib/screens/home_shell.dart` · `test/help_coverage_test.dart`.

### #31-help-coverage-wave2 — מצב-היכרות לוח השליח — 2026-06-16
- **המהלך:** גל 2 בכיסוי מצב-היכרות (לפי לוח). נוסף `HelpToggleButton` ל-AppBar של courier_dashboard (נקודת-כניסה למצב — היה חסר לכל לוח לא-קבלן). עטיפת פעמון/פרופיל/הגדרות/יציאה + בורר-הרכב ב-HelpTarget; 4 טאבים מוסברים דרך showHelpInfo.
- **עיקרון חדש:** לוח ללא HelpToggleButton = הסברים מתים → כל לוח חייב toggle משלו (stuck_log).
- **gate:** analyze 0 · help_coverage_courier_test +2 (toggle+chrome קיימים · tap-פעמון מסביר) · mutation §mutation_log (הסרת toggle → RED +0 -2 · GREEN +2).
- **שארית (courier-deep):** כפתורי קידום-המשלוח+POD בכרטיסים · בורר-הרכב בטאב המשלוחים. גלים הבאים: חנות→מנהל→קבלן-עמוק→עובד→כניסה.
- **קבצים:** `lib/screens/courier_dashboard_screen.dart` · `test/help_coverage_courier_test.dart`.

### #31-helpfix-bottomnav — טאבים תחתונים כ-HelpTarget (קבלן+שליח) — 2026-06-16
- **המהלך:** תיקון עקביות במצב-היכרות. ה-BottomNavigationBar בקבלן (home_shell) ובשליח (courier_dashboard) הוחלף ב-Material+Row של `BottomNavCell` (widget משותף חדש ב-help_target), כל טאב עטוף ב-HelpTarget → טבעת + בועה-מעוגנת. הוסר ה-showHelpInfo/helpMode מהטאבים.
- **למה:** הקיצור הקודם (showHelpInfo כרטיס-מרכזי) השאיר את הטאבים בלי הדגשה ובלי בועה-יוצאת-מהם — חוסר-עקביות (stuck_log).
- **gate:** analyze 0 · help_coverage_test +2 (טאב=HelpTarget + בועה) · 4 טסטי-עזרה ירוקים · mutation §mutation_log · אומת חי בדפדפן.
- **קבצים:** `lib/widgets/help_target.dart` (BottomNavCell) · `lib/screens/home_shell.dart` · `lib/screens/courier_dashboard_screen.dart` · `test/help_coverage_test.dart`.

### #31-helpcov-wave3 — מצב-היכרות לוח החנות — 2026-06-16
- **המהלך:** גל 3 (כיסוי-לפי-לוח). נוסף HelpToggleButton ל-store_dashboard AppBar; chrome עטוף ב-HelpTarget; 5 טאבים → BottomNavCell+HelpTarget (Material+Row, לא BottomNavigationBar).
- **gate:** analyze 0 · help_coverage_store_test +2 · mutation §mutation_log.
- **קבצים:** `lib/screens/store_dashboard_screen.dart` · `test/help_coverage_store_test.dart`.

### #31-swarm-wave — נחיל קנוני: מנהל+עובד+שליח (89 עטיפות) — 2026-06-16
- **המהלך:** הופעל הנחיל הקנוני (/swarm, DONNING + central-verify gate) על #31. audit→validate→fix → 89 HelpTarget ב-14 קבצים (מנהל/עובד-עמוק/שליח-עמוק), + 💡 toggle ללוחות-שליח שחסרו, + per-seg למנהל (toggle עליון, לא bottom-nav).
- **gate:** central-verify GATE PASS (analyze 0 · +2682 · build · conformance 7/7 · required-tests 6/6) · byte-verify · supervisor (6+7).
- **שארית (לגלי-נחיל הבאים):** תתי-מסכי-מנהל (profile/role-assign/inbox) · courier_delivery_detail · קבלן-עמוק (catalog/tools/ai-settings ~508) · login/shared.
- **קבצים:** 14 — manager_dashboard · worker_app/profile/reports/today_strip/notifs · courier_dashboard/portal/profile/settings/reports/forms/attendance/certs.

### #chat-delivery-status — HONEST per-message delivery status (🕐/✓/✓✓/❌) — 2026-06-16
- **המהלך:** ה-✓✓ הקוסמטי (שהודלק ע״י toggle ה-`readReceipts` הגלובלי לכל הודעה) הוחלף בסטטוס-מסירה אמיתי **לכל הודעה**: `enum MsgStatus { pending, sent, delivered, failed }`.
- **הסמנטיקה (reconciliation-aware):** `pending` 🕐 = כתיבה אופטימית בתעופה (מסלול Firebase, התחלתי) · `sent` ✓ = ב-outbox המקומי / demo-local (אין אישור-שרת — ברירת-המחדל, כך כל seed/legacy/demo נקרא ✓) · `delivered` ✓✓ = ההודעה נבנתה-מחדש מ-**snapshot של השרת** (באמת הגיעה) · `failed` ❌ = הכתיבה ברקע זרקה (+ "נסה שוב").
- **ה-HONEST INVARIANT:** ✓✓ מופיע **רק** על הודעה שפוענחה מ-snapshot של השרת. זה נאכף **מבנית** — `delivered` נקבע אך ורק ב-`FirebaseChatRepository` message `fromDoc` (`return decoded.copyWith(status: MsgStatus.delivered)`). הודעה שלא הגיעה לשרת לעולם לא תציג ✓✓. הסטטוס הוא **sender-local** — `toDoc` מסיר אותו, כך שהוא לא נכתב לדוק-השרת (ה-delivered-ness משתמע מחזרה דרך `fromDoc`).
- **ה-onWrite plumbing:** `FirestoreCachedRepo.guardWrite` קיבל `{void Function(bool ok)? onResult}` (try→`onResult(true)`, catch→debugPrint+`onResult(false)`); `upsert` קיבל `{void Function(bool ok)? onWrite}` המועבר ל-guardWrite. **תוסף בלבד** — כל קורא קיים מעביר כלום → התנהגות ללא-שינוי. ב-`send`, שורת-המשתמש נשלחת `pending` עם onWrite שמטליא ל-`sent` (ok) / `failed` (כשל) דרך `upsertLocalOnly` (ללא כתיבת-רשת נוספת); auto-reply של הבוט נשאר `sent` רגיל. `retry(threadId, msgId)` נוסף ל-repo (re-fire `pending` + אותו onWrite), ל-`ChatRepository` interface, ולמנוע (`retry` → `_remote?.retry(...)`; local = no-op כי demo לא נכשל).
- **קבצים שנגעו:** `lib/state/sys_chat.dart` (enum + שדה/copyWith/toJson/fromJson + engine `retry`) · `lib/data/repositories/firestore_cached_repo.dart` (onWrite/onResult) · `lib/data/repositories/chat_firebase.dart` (send pending+onWrite · fromDoc delivered · toDoc מסיר status · retry) · `lib/data/repositories/chat_repository.dart` (retry ב-interface) · `lib/screens/chats_screen.dart` (`_Message` += status,id · 5 בניות-tuple · `_Bubble` onRetry · widget `_DeliveryStatus`).
- **gate:** analyze **0 errors** · `flutter test` **+2699 -1** (ה-`-1` היחיד = baseline ידוע `worker_reports_drilldown_test.dart`, לא קשור לצ׳אט, נכשל בבידוד). אין כשל חדש. טסטים חדשים: `test/chat_msg_status_test.dart` (9) + הרחבת `test/chat_firebase_repo_test.dart` (+6: fromDoc→delivered · toDoc משמיט status · pending→sent · pending→failed · retry · bot נשאר sent).

### #connection-indicator — חיווי-חיבור חי ALWAYS-ON (🟢 מחובר / 🔴 מנותק / מצב דמו) — 2026-06-16
- **המהלך:** גלולת-חיווי (pill) קבועה בראש כל מסך שמשקפת **אמיתית וחיה** האם פעולות יישמרו. נוסף `connectivity_plus: ^6.1.0` (נפתר **6.1.5**). שני קבצים חדשים: state (`lib/state/connection_status.dart`) + widget (`lib/widgets/connection_indicator.dart`), הורכבו פעם-אחת ב-`main.dart`.
- **הקומביין (החלטי-ביותר ראשון; כל סעיף מאוחר רק מעדן):**
  1. `!useFirebaseBackend` → **demo** (אין שרת בכלל — כנה, "מצב דמו")
  2. `!networkOnline` → **disconnected** (wifi כבוי — מקרה ה-DoD ~2s)
  3. `!signedIn` → **disconnected** (אין uid — אי-אפשר לשמר)
  4. `firestoreCacheOnly` → **disconnected** (רשת למעלה אבל השרת לא נגיש)
  5. אחרת → **connected** 🟢
- **האותות (signals):**
  - **networkOnline** — `connectivity_plus`: seed ב-`checkConnectivity()` ואז חי דרך `onConnectivityChanged`. 6.x מחזיר `List<ConnectivityResult>`; **offline == הרשימה ריקה או רק `ConnectivityResult.none`**. זה האות המהיר שמגשים "wifi כבוי → 🔴 תוך ~2s".
  - **signedIn / uid** — נקרא מ-`authStateProvider` דרך `ref.listen` (re-bind ל-probe כש-uid משתנה).
  - **firestoreCacheOnly** — `diag/{uid}.snapshots(includeMetadataChanges:true)` → `snap.metadata.isFromCache`. **מאזין בלבד, לא כותב** (ה-BackendDebugBadge הוא הכותב). ברירת-מחדל **FALSE** (מניחים live עד שמוכח cache-only) — מונע ריצוד 🔴 בהתחלה.
- **התנהגות demo / Firebase-free (HARD RULE #1):** במסלול `!useFirebaseBackend` ה-notifier **אינרטי לחלוטין** — `connectionStatusProvider` הוא קבוע `demo`, **לא נפתח שום listener** (לא connectivity ולא Firestore), `FirebaseFirestore.instance` לא נגעת. לכן כל ה-suite ה-Firebase-free + ה-sandbox בונים את האפליקציה בלי לגעת בערוץ-פלטפורמה — zero regression, וזו הסיבה שטסטי-widget שבונים MaterialApp לא קורסים.
- **בטיחות (HARD RULE #2/#3):** כל מגע ב-connectivity/Firestore עטוף try/catch + `onError`; שגיאה מורידה את החיווי, לעולם לא זורקת לתוך מסך.
- **mount point:** `main.dart` — בתוך ה-`Stack` של `MaterialApp.builder` (אחרי `...debugOverlayChildren(isDebug: kDebugMode)`) נוסף `const ConnectionIndicator()`. ב-debug החיווי מוסט מטה (`kConnectionIndicatorDebugDrop=44`) שלא יתנגש ב-BackendDebugBadge; ב-release (kDebugMode false) הוא לבדו בראש. עטוף ב-`IgnorePointer` — לא בולע tap.
- **gate:** analyze **0 errors** · `flutter test` **+2699 -1** (ה-`-1` היחיד = baseline ידוע `worker_reports_drilldown_test.dart`, לא קשור — נכשל בבידוד). **אין כשל חדש.** (אין טסט חדש — המסלול שטסטים בונים הוא ה-demo האינרטי, שמוגן ע״י ה-gate הקיים.)
- **קבצים:** `lib/state/connection_status.dart` (חדש) · `lib/widgets/connection_indicator.dart` (חדש) · `lib/main.dart` (import + Stack child) · `pubspec.yaml` (`connectivity_plus`).

### #quality-wave1 — ליטוש איכות: memo-perf · a11y (tooltips/LTR/tap-target) · ניווט — 2026-06-16
- **המהלך:** גל-איכות (לא פיצ׳ר חדש) על בסיס אודיט-עדשות (performance · accessibility-rtl · navigation). שלוש קבוצות:
  - **perf (memoization — byte-equivalent, אפס שינוי-נראה):** `compatibleProductsFor` קיבל `_compatCache` per-SKU (טהור מעל קטלוג-`const` → ה-O(catalog) sweep+sort רץ פעם אחת לכל SKU); `system_division.nodeHasSystem` קיבל `_catSystemTallyIndex` (categoryHe→(sup,dr), נבנה פעם) + `_nodeHasSystemCache`; `catalog_screen` קיבל `_treeNodeSummary` (memo) + `_CardCatalogData` bundle (6 חישובי-O(catalog) מאוגדים, cached per sku); `finder_screen` קיבל `_categoryCountsFor`/`_baseFor` (badge-counts + pool cached); `lipskey_product_sheet` קיבל `_ensureFacts` (facts per-SKU memo). כולם **byte-identical** — 75/75 טסטי compat/system_division/adapter/line_fit ירוקים.
  - **a11y:** tooltips עבריים על כפתורי-אייקון (`ערוך`/`מחק` ב-catalog_screen · `הפחת`/`הוסף` ב-catalog_settings · `מחק` ב-store_screen); שדות numeric/ת.ז/ח.פ/טלפון → `TextDirection.ltr` (store_dashboard · worker/courier/store profile · worker/courier forms · welcome board-login username) בעוד שדות-שם עבריים נשארים RTL; כפתורי-stepper ב-install_studio עטופים ל-48dp tap-target (`SizedBox(48,48)`+`Center`+`HitTestBehavior.opaque`); `Color(0xFFAAAAAA)`→`BsTokens.mutedLight` ב-store_screen (×3).
  - **ניווט:** `docs_readiness_gate` קיבל AppBar עם `‹ יציאה` (`maybePop`) — מילוט ממסך-מלכודת; `onboarding_screen._finish` (מסלול לא-tour) מאפס `startupStepProvider=0` שלא ייתקע אחרי סיום.
- **gate:** analyze **0 errors** · `flutter test` **+2700 -1** (ה-`-1` היחיד = baseline ידוע `worker_reports_drilldown_test.dart`, לא קשור). טסט חדש: `test/compat_memo_test.dart` (2 — memo-live `identical` + empty-path), mutation-verified (§mutation_log). אין כשל חדש.
- **קבצים שנגעו:** `lib/data/related_info.dart` · `lib/logic/system_division.dart` · `lib/screens/{catalog_screen,catalog_settings_screen,finder_screen,lipskey_product_sheet,install_studio_screen,docs_readiness_gate,onboarding_screen,welcome_screen,store_screen,store_dashboard_screen,store_profile_screen,worker_profile_screen,courier_profile_screen,worker_forms_screen,courier_forms_screen}.dart`.

### #wave2a-connect — חיבור-לשרת: פיננסים נשמרים + יושרת order.sum ב-computeCredit — 2026-06-17
- **המהלך:** גל 2א של "צריך-שרת-ולא-מחובר". שני חיבורים אמיתיים, שניהם **byte-identical** במצב-דמו/טסטים (מאחורי `useFirebaseBackend` / `Array.isArray(lines)`), אומתו ע״י הצי (auditor→validate).
- **(1) finance-hub write-ports** (`lib/screens/finance_hub_sheets.dart`): שלוש מוטציות שנכתבו רק ל-`StateNotifier` בזיכרון ונאבדו על הבילד-המחובר עכשיו מנותבות גם דרך `financeRepo()` כשמחוברים:
  - בחירת תנאי-תשלום (`onTap` ב-`_PayOpt`, ~:521) → `r.setPaymentTerm(t.id)`
  - אישור/דחיית בקשת-רכש (`_decide`, ~:742) → `r.decide(a.id, ok)`
  - רישום קנס-איחור (`_PenaltyInput.onAdd`, ~:1098) → `r.addPenalty(days)`
  הדפוס בכולם: אחרי הכתיבה-לנוטיפייר הקיימת (מסלול-דמו), `if (useFirebaseBackend) { final r = financeRepo(); if (r is FirebaseFinanceRepository) r.<port>(...); }`. הפורטים `decide`/`addPenalty`/`setPaymentTerm` כבר היו בנויים ב-`finance_firebase.dart:329-362` ובדוקים ב-`finance_firebase_repo_test.dart` — היו **dead code (אפס קוראים)** עד עכשיו (ה-FOLLOW-UP שתועד מפורשות ב-finance_firebase.dart:28-32). import חדש: `finance_firebase.dart show FirebaseFinanceRepository`.
- **(2) order.sum integrity** (`functions/src/`): `computeCredit` קיפל `used` מתוך `doc.get("sum")` שהלקוח כותב (ניתן-לזיוף). תוקן: helper טהור חדש `orderSum(lines)` ב-`creditCore.ts` שמחזיר `Σ Math.round(line.price)` — **price הוא כבר סך-השורה המלא** (הלקוח מטמיע `OrderLineItem.price = l.total` ב-`store_screen.dart:2873`; `qty` אינפורמטיבי, **לא** מכפיל — auditor הציע בטעות `qty×price`, ה-validation תפס שזה היה מנפח-כפול). `credit.ts` עכשיו: `used += Array.isArray(lines) ? orderSum(lines) : (typeof s==="number" && Number.isFinite(s) ? s : 0)` — נפילה-חזרה ל-`sum` רק להזמנות ללא שורות (seed ישן). byte-identical להזמנות תקינות (Σ price == sum), מתקן רק זיופים.
- **gate:** `flutter analyze` 0 errors (ה-info על bool-param ב-:776 pre-existing) · functions `npm run selftest` **70/70** (כולל 5 assertions ל-orderSum: `[{price:600},{price:300}]→900`, `[]→0`, `undefined→0`, `"x"→0`, `qty מתעלם: [{qty:5,price:100}]→100`) · `flutter test` (גייט). אין logic/data חדש ב-app_flutter → אין helper-test/mutation. הפורטים מכוסים ב-finance_firebase_repo_test.
- **נדחה (גל 2ב, מתועד למשתמש):** customer-LIST credit (view-model recompute), projects empty-state (crash-guard ב-`ProjectsState.active` + UX רב-משטחי), budget sub-repo חדש (collection חדש). שלושתם אומתו ע״י הצי עם fix מדויק; דורשים פס עבודה ממוקד משלהם.

### #wave2b-projects — פרויקטים: לוח-ריק כן מהשרת במקום 3 דמו מזויפים — 2026-06-17
- **הבעיה (אומת ע״י הצי):** `projectsProvider` (`projects_engine.dart`) שאב seed דרך הריפו **רק** כש-`repo is LocalSiteRepository`; אחרת נפל ל-`ProjectsNotifier()` עם ה-const `kProjects` (3 פרויקטי-דמו). על הבילד-המחובר `siteRepositoryProvider` מחזיר `FirebaseSiteRepository` (לא Local) → המשתמש ראה 3 אתרים **מזויפים**, ו-`persist=true` אף כתב אותם ל-`bs.projects.v1`. סתירה: `budget_screen` כבר קרא `siteRepositoryProvider.projects()` והראה ריק.
- **התיקון (2 שינויים, byte-identical בדמו):**
  1. `projectsProvider` שואב מ-`repo.projects()`/`repo.activeProjectId()` (מתודות-הממשק, על **שני** ה-impls) במקום `seed()`/`seedActiveId()` הלוקאליים. Local → `kProjects`/`kActiveProjectId` (זהה). Firebase → `const []`/`''` (החוזה-הריק-הכן ב-`site_firebase.dart:266`). `persist: repo is LocalSiteRepository` → כבוי על המסלול-המחובר (לא משחזר דמו מ-prefs).
  2. `ProjectsState.active` קיבל guard: `projects.isEmpty ? const LiveProject(id:'',name:'',addr:'',manager:'') : firstWhere(...)` — מנע קריסה על `projects.first` ברשימה-ריקה. ה-UI כבר ערוך לזה: `smart_project_screen:50` נופל לכותרת גנרית כש-`active.name.isEmpty`, ו-`projects_screen:94` כבר מציג מסך "אין פרויקטים עדיין" + כפתור יצירה.
- **gate:** analyze 0 errors · `flutter test` (גייט) · טסט חדש `test/projects_server_empty_test.dart` (+2: empty→sentinel ללא-קריסה · local seed byte-identical). projects_engine ב-`lib/state` → גייט 24 (WIRING) חל; אין logic/data → אין helper-test/mutation; אין screen → אין visual_log חובה (הוספתי בכל-זאת רשומה — שינוי-התנהגות נראה על המחובר).
- **נדחה (אותו class):** יצירת-פרויקט שתישמר לשרת (write-port ל-Firestore) — כרגע פרויקט שנוצר על המחובר הוא in-session; אותו דפוס כמו budget sub-repo. נשאר ב-2ב: customer-LIST credit + budget.

### #wave2b-customerlist — רשימת-לקוחות: מסגרת-אשראי חיה (computeCredit) במקום ה-seed המזויף — 2026-06-17
- **הבעיה (אומת ע״י הצי):** ב-`manager_dashboard_screen.dart`, `_CustomerCard` הציג `c.creditLimit` (ה-seed של `contractorCredit` — hash דטרמיניסטי) ו-`view.pct` שנגזר ממנו. רק **גיליון-הפירוט** חובר ל-`computeCredit` (C1/A13, `customerCreditProvider`). הרשימה — הדבר הראשון שהמנהל רואה — הציגה תקרה מפוברקת שלא מתעדכנת מהשרת. בדיוק הערך ש-`FirebaseCustomersRepository.creditLimit()=>0` נועד למנוע.
- **התיקון (קובץ יחיד, byte-identical כבוי):** `_CustomerCard` `StatelessWidget`→`ConsumerWidget`; `build(context)`→`build(context, ref)`; שולף `liveLimit = ref.watch(customerCreditProvider(c.name)).valueOrNull?.creditLimit ?? c.creditLimit` (אותו דפוס מוכח של הגיליון @~1926), ומחשב-מחדש `pct`/`status` ממנו (אותה נוסחה כמו `_CustomerView.pct`@1472/`status`@1443). ה-`_CreditBar` ושורת "ניצול אשראי" משתמשים ב-`liveLimit`/`pct` המקומיים. כבוי → `computeCredit` מחזיר `contractorCredit(name)==c.creditLimit` בלי רשת → זהה; מחובר → ערך-שרת קנוני.
- **gate:** analyze 0 errors (2 ה-info על :68/:1204 pre-existing) · 80 טסטי manager/customer ירוקים · טסט חדש ב-`manager_credit_computecredit_consumer_test.dart` (+1: ה-LIST מגיעה ל-`computeCredit` בעת-רינדור **בלי tap** — נועל שלא יחזרו ל-seed). manager_dashboard הוא screen → גייט 24 (WIRING) + 116 (visual_log); אין logic/data → אין helper-test/mutation.
- **לא נכלל (אותו class, נותר):** רצועת-הסיכום `fleetPct` (1542/1680) עדיין סוכמת `creditLimit` מהאגרגט — אגרגט גס שדורש watch של N providers; budget sub-repo (collection חדש) — המשימה האחרונה בגל 2ב.

### #wave2b-budget — תקציב: אין כסף-דמו מזויף על המחובר (read-honesty) — 2026-06-17
- **הבעיה (אומת ע״י הצי):** `budgetProvider` (`budget_screen.dart`) היה `((_) => BudgetNotifier())` — in-memory טהור שנזרע **תמיד** מה-const (`kBudgetTotal` 15000 / `kBudgetSpent` 9840 / 4 קטגוריות), גם על המחובר. בעוד תיבת-התקציב של מרכז-הפיננסים כבר מציגה ריק-כן (`FirebaseFinanceRepository.budgetTotal()=>0` וכו', finance_firebase:281-298 "honest empty state, not invented money") — מסך-התקציב היה **לא-עקבי** והציג כסף מזויף לקבלן אמיתי. (גילוי-לוואי: התקציב לא נשמר **אף פעם** — גם בדמו הוא in-memory בלי persist.)
- **התיקון (read-honesty, byte-identical בדמו):** `BudgetNotifier` קיבל פרמטרי-seed אופציונליים (`{int? total, int? spent, List<BudgetCat>? categories}`, ברירת-מחדל ל-const → `BudgetNotifier()` נשאר byte-identical); `budgetProvider` זורע אותם דרך `financeRepo()` (אותו global accessor של finance-hub, מתחלף על `useFirebaseBackend`): לוקאלי → const demo זהה, מחובר → `repo.budgetTotal()/budgetSpent()/budgetCategories()` הכנים (0/0/[]). מסך-התקציב כבר מרנדר ריק בחן (ענף `b.categories.isEmpty` @~259). אידיום ה-repo-seam של `projects_engine`. import חדש: `finance_local.dart show financeRepo`.
- **gate:** analyze 0 errors (45 ה-info trailing-comma pre-existing) · `flutter test` (גייט) · טסט חדש `test/budget_server_empty_test.dart` (+2: empty seed → 0/0/[]/pct0 ללא-קריסה · bare → const demo byte-identical) · budget_stock_scan_test +14 ירוק. budget_screen הוא screen → גייט 24 (WIRING) + 116 (visual_log); אין logic/data → אין helper-test/mutation.
- **נדחה במפורש (פיצ'ר חדש, לא disconnect):** **שמירת עריכות-תקציב לשרת** — דורשת collection חדש (`financeBudget/active`) + `_BudgetCacheRepo` + write-port + binding ריאקטיבי של `BudgetNotifier` ל-repo. תת-מערכת חדשה (התקציב לא נשמר מעולם, גם לא בדמו) — לא נכלל; התיקון הזה רק עוצר הצגת כסף-דמו מזויף. גם רצועת-סיכום fleet-% במנהל נותרה.

### #wave2b-budget-persist — תקציב נשמר לשרת (collection + repo + binding ריאקטיבי) — 2026-06-17
- **המהלך:** השלמת התקציב מ-read-honesty (v6.28) ל-**persistence מלא**. הפיצ'ר לא היה קיים מעולם (התקציב היה in-memory אפמרי גם בדמו).
- **repo layer:** `_BudgetCacheRepo extends FirestoreCachedRepo<_BudgetRow>` — מסמך-יחיד `financeBudget/active` (`{total, spent, cats:[{name,icon,amount}]}`), על בסיס תקדים `_PaymentTermCacheRepo`. seed **ריק** (0/0/[]); `onFirstSnapshotEmpty` = base no-op → backend טרי לא נזרע בכסף-דמו. `FinanceRepository` (interface) קיבל `void setBudget(int,int,List<BudgetCategory>)` + `Listenable? get budgetListenable`. `FirebaseFinanceRepository`: סב-repo רביעי (`_budget`), attach/dispose fan-out, `budgetTotal/Spent/Categories/Pct` מחזירים מ-`_budget.active()` (היה 0/[] קשיח), `setBudget`→`upsert`, `budgetListenable`→`_budget`. `LocalFinanceRepository`: `setBudget` no-op + `budgetListenable`→null (דמו אפמרי כתמיד).
- **UI binding:** `BudgetNotifier(this._repo)` — נזרע מ-`_seedFrom(repo)`, מאזין ל-`repo.budgetListenable` (`addListener(_syncFromRepo)` → re-seed כש-snapshot נוחת), כל mutator קורא `_persist()` (=`repo.setBudget(total,spent,cats)`), `dispose` מסיר את ה-listener. `budgetProvider` → `BudgetNotifier(financeRepo())`. round-trip `BudgetCat.ic`↔`BudgetCategory.icon` נשמר. אין feedback-loop (write→notify→re-seed לאותו ערך, ה-setState לא כותב).
- **byte-identical בדמו/טסטים:** `financeRepo()` OFF = `LocalFinanceRepository` → `budgetListenable` null (אין re-seed), `setBudget` no-op, reads = const demo → התנהגות זהה לחלוטין (אומת: budget_stock_scan_test +14 ירוק אחרי עדכון ל-`BudgetNotifier(const LocalFinanceRepository.constData())`).
- **gate:** analyze 0 errors · `flutter test` **+2999 -2** (שני baselines ידועים בלבד) · טסט חדש `test/budget_server_empty_test.dart` (4, fake `FinanceRepository`) + עדכון `finance_firebase_repo_test` (budgetSource fake ב-`_build`) + `budget_stock_scan_test` (constructor). data/repositories נגע → גייט 42 (helper-test ✓) + 44 (mutation ✓ §mutation_log) + 24 (WIRING) + 116 (visual_log, budget_screen).
- **זה משלים את גל 2** — כל פערי "צריך-שרת" שזוהו (פיננסים · order-sum · פרויקטים · לקוחות · תקציב read+write) חוברו. נותר: רצועת-סיכום fleet-% (אגרגט קטן) + deferred-class (Auth עובד/שליח · seed cleanup · App Check).

### #wave2b-fleetpct — רצועת-סיכום fleet-% מאשראי חי (סגירת גל 2) — 2026-06-17
- **הבעיה:** רצועת-הסיכום בלוח-המנהל (`manager_dashboard_screen.dart` ~:1540) חישבה `totalCredit = Σ v.customer.creditLimit` — ה-seed המזויף (`contractorCredit`). אחרי שכרטיס-הלקוח חובר (v6.27), הרצועה-המצרפית נשארה הפער האחרון.
- **התיקון (קובץ יחיד, byte-identical כבוי):** `fleetCreditProvider` (`FutureProvider<int>`) — `ref.watch(managerCustomersProvider)` ואז `await ref.watch(customerCreditProvider(c.name).future)` לכל לקוח, מסכם `creditLimit`. הרצועה: `final totalCredit = ref.watch(fleetCreditProvider).valueOrNull ?? views.fold(Σ c.creditLimit)` (נפילה-חזרה לסכום-ה-seed בזמן טעינה → אפס ריצוד). כבוי: `computeCredit` מחזיר `contractorCredit(name)==c.creditLimit` → הסכום זהה לחלוטין (אותה invariant שאומתה בכרטיס).
- **gate:** analyze 0 errors · 46 טסטי manager (consumer/screen/dashboard) ירוקים — byte-identical כבוי. manager_dashboard הוא screen → גייט 24 (WIRING) + 116 (visual_log); אין logic/data → אין helper-test/mutation; ה-seam עצמו (`computeCredit`) כבר מכוסה ע״י `manager_credit_computecredit_consumer_test` (כולל "list reaches computeCredit on render", שעכשיו כולל גם את ה-fleet provider).
- **סגירה:** עם זה **כל פערי "צריך-שרת" שזוהו ע״י הצי חוברו** — finance ports · order-sum · projects · customer-card · customer-fleet-% · budget (read+write). נותר רק deferred-class (Auth עובד/שליח · seed cleanup · App Check · kb_golden של צי-המקלדת).

### #twin-spend-by-site — תקציב: "הוצאות לפי אתר" מהזמנות אמיתיות (out-of-box גל ①) — 2026-06-22
- **הבעיה:** `budget_screen.dart` הציג הוצאות-לפי-אתר עם משקל מומצא (`b.spent*(n-i)/(n*(n+1)/2)`, דיסקליימר "להמחשה").
- **התיקון (byte-identical בדמו):** ב-`BudgetScreen.build`, כש-`useFirebaseBackend` — קיפול `ordersEngineProvider` לפי `o.site`→Σ`o.sum` (`spendBySite`), וה-`_SiteRow` מציג `spendBySite[project.name] ?? 0`. הזמנות מטביעות `site = cartProjectProvider = שם-הפרויקט הפעיל` ב-checkout, אז הן תואמות את שורות-הפרויקטים. כבוי → המשקל-הממחיש נשאר (אין backend לקפל → זהה). imports: `backend(useFirebaseBackend)` + `orders_engine(ordersEngineProvider)`.
- **למה גייטינג ולא תמיד-אמיתי:** הזמנות-ה-seed (supplier_data) משתמשות ב-site מקוצר ('מגדל הרצליה') שלא תואם שמות-פרויקטים מלאים ('מגדל הרצליה — קומה 4') → fold-אמיתי בדמו היה מראה ₪0. לכן דמו=המחשה, מחובר=אמיתי (הזמנות-אמת תואמות-שם).
- **gate:** analyze 0 errors · budget tests +18 ירוק (byte-identical כבוי). screen → גייט 24/116; אין logic/data.

### #guarantee-seal — אחריות-סל-שלם "אין נסיעה שנייה" (out-of-box גל ②) — 2026-06-22
- **המהלך:** ב-`install_studio_screen.dart`, לפני `if (plan.gaps.isNotEmpty)` (אזור ה-add-to-cart), נוסף חותם ירוק "🛡️ אחריות: הסל משלים את העבודה — אין נסיעה שנייה" שמוצג רק כש-`ok && checkCritical == 0` — שני אותות שכבר מחושבים ב-build (`ok=plan.isComplete` @1808 · `checkCritical` @1815 = unsatisfied-critical מ-`lineComplianceChecklist`). צבע `_ok` (0xFF16A34A). המשלים החיובי לאזהרת "⚠️ חסרים חיבורים" הקיימת.
- **למה זה ה-moat:** מנוע-התאימות (`install_engine`) כבר יודע אם הקו שלם+בטוח; החותם רק *ממתג* את האות הזה ברגע-הקנייה — בלתי-ניתן-להעתקה בלי גרף-תאימות מאומת.
- **gate:** analyze 0 errors · `robustness_test` +19 ירוק (כולל "install studio renders"). additive בלבד (widget מותנה). screen → גייט 24/116; אין logic/data.

### #autobom-saved-job — BOM-אוטומטי: פתיחת עבודה-שמורה = רשימת-חומרים בלחיצה (out-of-box גל ③) — 2026-06-22
- **המהלך:** `_loadProject(p)` ב-`install_studio_screen.dart` טען רק את הקנבס (chain/temp/accessories). נוסף: אם `found.length >= 2` → `_assemble(found, p.tempC)` מיד — בונה את ה-BOM המלא (`buildInstallation`/`buildTreeInstallation` עם autoCompliance) ופותח את גיליון-ה-BOM/האזהרה-הקריטית. לחיצה אחת מ"עבודה שמורה" ל-רשימת-חומרים מוכנה-לסל.
- **סדר ה-pop:** ה-tap-handler של פריט-העבודה שונה ל-`Navigator.pop(ctx)` (סגירת גיליון-הרשימה) **לפני** `_loadProject` — אחרת ה-pop היה סוגר את גיליון-ה-BOM החדש.
- **מנצל קיים:** כל הצינור (auto-flow-fix → buildInstallation → BOM sheet → add-to-cart) כבר היה; רק החיווט מ"טען עבודה" ל"בנה מיד".
- **gate:** analyze 0 errors · robustness + install-engine/gaps tests +77 ירוק. additive. screen → גייט 24/116; אין logic/data.

### #barcode-plus-wiring — ברקוד: סריקה → כרטיס-מוצר (out-of-box גל ④) — 2026-06-22
- **המהלך:** `camera_sheet._onDetect` הציג רק `showToast('נקלט: code')` (מבוי-סתום). עכשיו: `catalogProductForSku(code)` → אם נמצא, `showLipskeyProductSheet(context, product, const [])` (הכרטיס נושא add-to-cart/הזמנה-חוזרת + רצועת-תאימות שמחושבת ע"י הכרטיס עצמו); אם לא-נמצא, ה-toast הכן נשאר. imports חדשים: `related_info(catalogProductForSku)` + `lipskey_product_sheet(showLipskeyProductSheet)` (אין import-cycle — analyze 0).
- **נדחה לבעלים (דאטה, לא קוד):** טבלת EAN→SKU או הדפסת תוויות-SKU. מק"טי-הקטלוג הם הקודים הפנימיים, אז סריקת תווית-SKU עצמית עובדת היום; EAN מסחרי אמיתי דורש מיפוי שאתה מספק. עד אז ה-fallback מדווח את הקוד.
- **gate:** analyze 0 errors (כולל בדיקת import-cycle camera_sheet↔product_sheet) · camera/scan tests +24 ירוק (כולל camera_sheet_capture). screen → גייט 24/116; אין logic/data.

### #barcode-harden — הקשחת-ברקוד (use-after-pop) + טסט (לולאה, סבב-3-בדיקות) — 2026-06-22
- **באג שתוקן (Check 3 #1, MED):** `camera_sheet._onDetect` עשה `Navigator.pop(context)` ואז `showLipskeyProductSheet(context,…)`/`showToast(context,…)` על אותו context — אחרי ה-pop האלמנט defunct (toast no-op, sheet לא-מעוגן). תוקן: `final rootCtx = Navigator.of(context, rootNavigator:true).context;` **לפני** `Navigator.of(context).pop()`, ושימוש ב-`rootCtx` לשניהם.
- **ניסוח כן (Check 3 #4, LOW):** קוד לא-מוכר → `'הקוד $code לא נמצא במק"ט'` (במקום "נקלט: code" שנשמע כהצלחה).
- **טסט (Check 2 #4):** `test/barcode_resolve_test.dart` נועץ את ה-found/not-found split: SKU אמיתי→מוצר (round-trip) · `'NOPE-12345'`/`''`/`null`→null.
- **gate:** analyze 0 errors · barcode_resolve +camera_sheet_capture +5 ירוק. screen → גייט 24/116.

### #twin-harden — הקשחת-Twin: disclaimer + שארית + נעיצה (לולאה, סבב-3-בדיקות) — 2026-06-22
- **disclaimer (Check3 #2, MED):** ב-`budget_screen` הערת "* הנתונים להמחשה…" הייתה שקרית על המחובר (הנתונים כבר אמיתיים) → `useFirebaseBackend ? 'מבוסס על ההזמנות בפועל לפי אתר.' : '* הנתונים להמחשה…'`.
- **שארית (Check3 #3, LOW):** הזמנות עם `site` שאינו שם-פרויקט (למשל 'ללא פרויקט') נכנסו ל-`spendBySite` אך לא הוצגו → השורות הסתכמו לפחות מהסך. נוסף `residualSpend` (Σ-orders − Σ-projects) + שורת `_SiteRow('אחר / ללא פרויקט')` כשהוא >0.
- **נעיצה (Check2 #1):** חולצו `budgetSpendBySite(List<Order>)` (הקיפול) + `illustrativeSiteSpend(spent,n,i)` (נוסחת-ההמחשה) כ-top-level pure; `test/budget_twin_test.dart` נועץ את שניהם (קיפול לפי site · המחשה verbatim 3/6,2/6,1/6 · n=0→0). import הורחב ל-`Order`.
- **נדחה (החלטת-בעלים):** Check1 #2 — כותרת-התקציב (הוצא/%נוצל/bar/אזהרת-חריגה) עדיין `b.spent` (הנערך/persisted מ-v6.29), בעוד השורות אמיתיות → סתירה-פנימית על המחובר. תיקון דורש החלטה: spent-מחובר = Σ-הזמנות (דורס עריכה) או נשאר נערך? לא ננגע עד החלטה.
- **gate:** analyze 0 errors · budget_twin + budget_server_empty + budget_stock_scan +20 ירוק. screen → גייט 24/116.

### #barcode-allscanners — ברקוד פותח כרטיס בכל שלושת הסורקים (לולאה) — 2026-06-22
- **Check1 #1:** שני ה-callers האחרים של `openBarcodeScanner` רק זרקו ל-search: `catalog_screen` (הכלי 📷) ו-`ai_hub_screen._runBarcode`. הרצפה `q.length>=5` בחיפוש-מק"ט החטיאה מק"טים קצרים → 0 תוצאות גם כש-`catalogProductForSku` היה מוצא.
- **התיקון:** שניהם → `catalogProductForSku(code)` → `showLipskeyProductSheet(context, product, siblings)` (siblings = `kCatalogProducts.where(categoryHe==)` inline); fallback ל-search רק כשלא-נמצא. catalog_screen: 0 imports חדשים (כבר מייבא הכל). ai_hub: +3 imports (`polyroll_catalog.kCatalogProducts` (שם מוגדר ה-unified), `related_info.catalogProductForSku`, `lipskey_product_sheet.showLipskeyProductSheet`).
- **תפס באג-build תוך-כדי:** ייבאתי תחילה `kCatalogProducts` מ-`lipskey_catalog` (שם יש `kLipskeyCatalog`, לא `kCatalogProducts`) → analyze error → תוקן ל-`polyroll_catalog`.
- **gate:** analyze 0 errors · robustness + catalog + ai_hub tests +141 ירוק. screens → גייט 24/116. ה-resolve split כבר נעוץ ב-barcode_resolve_test (אותה לוגיקה).

### #autobom-pin — טסט-נעיצה ל-auto-BOM glue (לולאה, Check2 #3) — 2026-06-22
- **Check2 #3:** ה-engine half של auto-BOM נעוץ ב-install_plan_coverage_test, אבל ה-**glue** (`_loadProject`: SavedProject.anchorSkus → `kLipskeyCatalog.where` → `found.length>=2` gate) לא היה נעוץ.
- **הטסט:** `test/saved_project_autobom_test.dart` (טסט-בלבד, אפס שינוי-lib): SavedProject עם זוג מוכח-מתחבר → resolve → length==2 (gate עובר) → `buildInstallation` items לא-ריק + מכיל את שני העוגנים · עוגן-בודד → length==1 (gate false, נשאר על קנבס) · SKU חסר-מקטלוג → נושר בשקט (glue בטוח).
- **gate:** analyze 0 errors · +3 ירוק. אין lib staged → אין גייט 24/42/44/116; אין bump-גרסה (טסט-בלבד).

### #twin-residual-pin + barcode-siblings-DRY (לולאה סבב-2) — 2026-06-22
- **residual pin (Check unverified):** חולץ `budgetResidualSpend(spendBySite, projectNames)` כ-top-level pure (היה inline) + 3 asserts ב-`budget_twin_test` (אורפן צף · 0→שורה מוסתרת · ריבוי-אורפנים מצטבר). אפס שינוי-התנהגות.
- **siblings DRY (Check improve):** שני סורקי-הברקוד החדשים (catalog_screen, ai_hub) הוחלפו מ-inline `kCatalogProducts.where(categoryHe==)` ל-`catalogSiblingsFor(product)` (כמו camera_sheet) — 3 הסורקים עקביים. byte-identical (catalogSiblingsFor = אותו ביטוי). ai_hub: import הוחלף polyroll_catalog→task_skus_local.
- **gate:** analyze 0 errors · budget_twin + robustness +22 ירוק. refactor+test, אפס שינוי-נראה → אין bump-גרסה.

### #autobom-hotwater-fix — תיקון-באג: עוגני מים-חמים נושרים מעבודה-שמורה (לולאה סבב-2) — 2026-06-22
- **הבאג (Check missing סבב-2, MED):** `install_studio._loadProject:1305` פתר `anchorSkus` מול `kLipskeyCatalog` בלבד, אבל עוגנים מתווספים מ-`kCompatCatalog` (=`[...kLipskeyCatalog, ...kHotWaterCatalog]`, הפיקרים ב-271/3070). עוגן מים-חם (HW-*) שמור → `where` ב-kLipskeyCatalog מחזיר ריק → נושר. ה-auto-BOM של גל ③ (`found.length>=2`) הפך "קנבס-חלקי" ל**no-BOM שקט**. סיבלינג: :1797 ("הוסף מוצר מומלץ") דיווח שקרית "אינו במאגר" על HW.
- **התיקון:** `kLipskeyCatalog`→`kCompatCatalog` בשני המקומות (one-line swap; kCompatCatalog כבר מיובא+בשימוש ב-install_studio). byte-equivalent לעוגנים שאינם-HW (kCompatCatalog⊇kLipskeyCatalog), מוסיף רק את ה-HW. אותו class כמו תיקון-הברקוד (129c5f4).
- **תיקון-טסט (קריטי):** `saved_project_autobom_test._resolve` שיקף את ה-baggy `kLipskeyCatalog` → **נעץ את הבאג**. עודכן ל-`kCompatCatalog` + case חדש: עוגן ב-`kCompatCatalog`-שאינו-`kLipskeyCatalog` (מים-חם) פותר ל-length 1 (ה-kLipskeyCatalog הישן היה מחזיר 0).
- **gate:** analyze 0 errors · saved_project_autobom + robustness + install_plan_coverage +27 ירוק.

### #autoflowfix-pump — תיקון-באג: משאבת-הגברה אוטומטית הייתה מתה (לולאה סבב-3) — 2026-06-22
- **הבאג (Check missing סבב-3, HIGH):** `pressure_drop.autoFlowFix:237` פתר `HW-PUMP-40` (מים-חם-בלבד, lipskey_hotwater:39) מול `kLipskeyCatalog` → `.where` תמיד ריק → המשאבה לעולם לא נוספה בקווי ΔP>1bar. ה-auto-fix נקרא בפועל (install_studio:965) אך עשה no-op שקט. המופע האחרון של מחלקת-הבאג (סיבלינג של 129c5f4/15fa473).
- **התיקון:** `kLipskeyCatalog`→`kCompatCatalog` (import חדש `lipskey_hotwater show kCompatCatalog`). byte-equivalent לכל SKU שאינו-HW.
- **gate (lib/logic → 24+42+44):** analyze 0 · טסט חדש `pressure_pump_test` (+3: autoFlowFix מוסיף משאבה ב-ΔP גבוה · estimatePressureDrop מציע HW-PUMP-40 · HW-PUMP-40 רק ב-kCompatCatalog) · mutation-verified (§mutation_log) · WIRING. הטסט ה-3 (membership) שומר גם את swaps של install_studio (15fa473) מ-regression.

### #ai-backbone — תשתית-Claude מאובטחת (out-of-box גל ⑤, השלד) — 2026-06-22
- **הקשר:** הבעלים סיפק `ANTHROPIC_API_KEY` (Secret Manager, פרויקט buildsmart-b0b78). בניתי את השלד שכל פיצ'רי-ה-AI יושבים עליו.
- **שרת (`functions/src/claude.ts`):** callable `askClaude` — `defineSecret('ANTHROPIC_API_KEY')` + `secrets:[…]` + auth-gate + `enforceAppCheck:true` + lazy-client cached (דפוס `r2.ts` ה verbatim). מקבל `{prompt, system?, model?, maxTokens?}` (חסמי-קלט), מחזיר `{text, model}`. default model `claude-haiku-4-5-20251001` (זול לנימוק כן/לא). מיפוי-שגיאות נייטרלי. נוסף ל-`index.ts` exports + `@anthropic-ai/sdk@^0.32.1` ל-package.json. **המפתח רק בשרת — לעולם לא בקליינט.**
- **קליינט (`lib/data/repositories/claude_functions.dart`):** seam `ClaudeGateway` (abstract) + `FirebaseClaudeGateway` (lazy `FirebaseFunctions.instanceFor(me-west1)`, מתרגם `FirebaseFunctionsException`→`ClaudeException` נייטרלי) + `ClaudeResult` — מראה את `order_functions.dart`. `claudeGatewayProvider` מחזיר gateway אמיתי **רק** כש-`useFirebaseBackend && kClaudeAi`, אחרת null.
- **דגל (`backend.dart`):** `kClaudeAi = bool.fromEnvironment('CLAUDE_AI')`, default OFF → null gateway → "דורש חיבור" כן + demo/test byte-identical (אותו zero-regression כמו kServerCallables). הפעלה: `--dart-define=CLAUDE_AI=true` אחרי פריסת-הפונקציה.
- **grounding:** ה-callable גנרי+טיפש בכוונה; כל פיצ'ר מעביר דאטה מאומתת ב-prompt/system → המודל מנמק מעל אמת, לא ממציא מק"טים.
- **gate:** functions `tsc --noEmit` 0 + `npm run selftest` 70/70 · flutter analyze 0 · `test/claude_gateway_test.dart` (null-when-OFF + fake-seam + neutral-exception), mutation-verified (§mutation_log). data/ → גייט 42(test ✓)+44(mutation ✓). הדחיפה מפעילה `firebase-deploy` (functions/** trigger) → `askClaude` נפרס מול הסוד שקיים עכשיו.
- **הבא:** הפיצ'ר הראשון — קופיילוט-מפרט ("60°C ו-6 בר?") מעל `VerifiedSpec` (התשובה ב-Dart, Claude מסביר → אפס הזיות).

### #ai-spec-copilot — קופיילוט-מפרט (out-of-box גל ⑤, הפיצ'ר הראשון) — 2026-06-22
- **המהלך:** הפיצ'ר-AI הראשון על שלד-Claude (v6.40). `lib/screens/spec_copilot_screen.dart` (חדש) + כפתור-כניסה ב-`lipskey_product_sheet.dart` ("🌡️ מתאים לתנאים שלי?", מופיע רק כש-`kVerifiedSpecs.containsKey(p.sku)`).
- **zero-hallucination:** ה-verdict כן/לא מחושב ב-Dart ב-`specTempVerdict` (=`VerifiedSpec.suitableForTemp`, `tempC ≤ maxTempC`) — תמיד נכון, offline. Claude **רק מנסח**: `specCopilotPrompt` מוסר לו את התשובה-שכבר-חושבה + המספרים + "אל תמציא/אל תסתור". המודל לא מחליט ולא ממציא מספר.
- **gating:** `claudeGatewayProvider` (null אם דגל כבוי/לא-מחובר) → ה-verdict הדטרמיניסטי עדיין מוצג + "הסבר-AI דורש חיבור" (כן). demo/test byte-identical. מצבי loading/failed("נסה שוב") מטופלים.
- **gate:** analyze 0 errors · `spec_copilot_test` +3 (verdict ≤/null-on-no-spec · ה-prompt מכיל את ה-verdict+המספרים) · `huliot_card_render_test` +2 (כרטיס עדיין מרונדר). screens → גייט 24/116. ה-verdict עצמו מבוסס `suitableForTemp` (כבר מכוסה במנוע).

### #ai-describe-to-cart — "תאר תקלה → סל" (out-of-box גל ⑤, AI-native אמיתי) — 2026-06-22
- **המהלך:** `describe_to_cart_screen.dart` (חדש) + אריח-ראשון ב-`ai_hub_screen.dart` ("🗣️ תאר עבודה → סל") + dispatch case. הקבלן מתאר חופשי → Claude ממפה למתכון → `assembleKit` בונה סל.
- **anti-hallucination (closed-set):** ה-prompt (`describeToCartPrompt`) מוסר את כל ה-`key=name` מ-`kSmartProducts` ודורש **רק key** (או NONE) — Claude לא יכול לנקוב שם-מוצר. `matchRecipe` מאמת את התשובה מול הסט-האמיתי (exact→contained) וזורק NONE/מומצא. `resolvedKitProducts` מחזיר רק שורות עם `product != null && match != none` → **כל פריט-סל הוא מק"ט אמיתי**. ה-cart-add מראה את דפוס `_addKitToCart` של product_sheet.
- **gating:** `claudeGatewayProvider` null → "הפיצ'ר דורש חיבור". maxTokens=32 (מחזיר key קצר → זול). demo/test byte-identical.
- **AI-hub tile:** הרשימה גדלה מ-9 (proto-verbatim) ל-10; `apple_readiness_hide_pass_test` עודכן 6→7 visible (10−3 deferred).
- **gate:** analyze 0 errors · `describe_to_cart_test` (matchRecipe דוחה key מומצא · prompt grounding · resolvedKitProducts=מוצרים-אמיתיים) + apple_readiness + ai_hub tests +39 ירוק. recipe_kit נוצל **בקריאה-בלבד** (לא נגעתי בקוד-המאתר). screens → גייט 24/116.

### #ai-finder — שדרוג-המאתר: "תאר → מצא" (out-of-box גל ⑥, נגיעה מאושרת במאתר) — 2026-06-22
- **המהלך:** `ai_finder_screen.dart` (חדש) + נגיעה מינימלית ב-`word_finder_screen.dart`: בפתיחה `if (showJobsEntry) _buildAiFinderEntry()` (אותו opening-gate) + מתודה `_buildAiFinderEntry` (OutlinedButton → `AiFinderScreen.route()`) + import. **באישור המשתמש** (הצי לא עובד על מסך-המאתר).
- **הזרימה:** טקסט-חופשי → `aiFinderPrompt` מוסר את הסט-הסגור של הקטגוריות (`finderCategories()` = distinct `categoryHe`, ~68) → Claude מחזיר **קטגוריה אחת או NONE** → `matchCategory` מאמת (exact→contained, זורק מומצא/NONE) → `productsInCategory(cat)` = `kCatalogProducts.where(categoryHe==)` → רשימה (לחיצה → `showLipskeyProductSheet`).
- **anti-hallucination:** Claude לא יכול לנקוב שם-מוצר — רק קטגוריה מהרשימה; המוצרים אמיתיים-בלבד.
- **gating:** `claudeGatewayProvider` null → "החיפוש החכם דורש חיבור". maxTokens=48. demo/test byte-identical.
- **gate:** analyze 0 errors · `ai_finder_test` (matchCategory closed-set + prompt grounding + products-real + **DEMO מודפס**) + 18 טסטי finder ירוקים. word_finder_screen ב-features/ (לא screens|state|logic) → לא מפעיל גייט-lib; ai_finder_screen ב-screens → גייט 24/116.

### #lipskey-pdf-enrich — העשרת קטלוג-הבית מ-PDF הרשמי (R8) + תיקון render — 2026-06-23
- **דאטה (`lib/data/lipskey_catalog.dart`):** נחיל-חילוץ ויזואלי קרא את 58 עמודי קטלוג-ליפסקי הרשמי (תמונתי, דו-לשוני). הוחל R8-verbatim: **93 dims (מידות/תיאור/הערה) · 44 qtyPallet · 2 color** על מוצרים קיימים (התאמה לפי SKU, 287/287). `scripts/match_lipskey_pdf.py` ממפה qty→qtyPack/qtyPallet ו-**מחריג color ל-SKUs מוצמדי-gate-117** (`lipskey_pdf_parity_test`, שמצמיד color=null לאביזרים) — מונע התנגשות. `scripts/apply_lipskey_enrich.py` idempotent (לא דורס).
- **render (`lib/screens/lipskey_product_sheet.dart`):** `_SpecRow` — הערך היה `Text(value)` אחרי `Spacer()` (לא נגלל → ערך-מפרט ארוך גלש). תוקן: `Flexible(label)` + `Expanded(Text(value, textAlign:end))` — ערכים ארוכים נגללים, קצרים נראים זהה. תיקון-שורש לכל מוצר עם dims עשיר.
- **gate:** analyze 0 errors · `lipskey_enrichment_test` (מידות+qtyPallet, mutation-verified) · `lipskey_pdf_parity_test` (gate-117) + `product_journey` (935 sheets) **ירוקים**. screens → גייט 24/116. כלים+תוכנית: `knowledge/LIPSKEY-INGESTION-PLAN.md`. push רק ב"תתדחוף".
### #ai-search-fallback — קטלוג: כשהחיפוש-הדטרמיניסטי לא מצא → גשר ל-AI finder (out-of-box גל ⑥, המשך) — 2026-06-22
- **המהלך:** ב-`catalog_screen.dart` מצב ה-no-results (`filtered.isEmpty && products.isEmpty`) הוחלף מ-`Text` בודד ל-`Column`: אותה הודעת "לא נמצאו תוצאות" + כפתור **"🗣️ נסה חיפוש חכם"** (`OutlinedButton.icon`) → `AiFinderScreen.route(initialQuery: query)`. שני imports נוספו (`claude_functions show claudeGatewayProvider`, `ai_finder_screen show AiFinderScreen`).
- **הזרימה:** החיפוש-הדטרמיניסטי (AND→OR→fuzzy ב-`searchResultsProvider`) מחזיר 0 → הקבלן מקבל גשר במקום מבוי-סתום: לחיצה פותחת את ה-AI finder **עם השאילתה כבר ממולאת**, ו-`AiFinderScreen.initState` מריץ `_search()` ב-`addPostFrameCallback` → Claude → קטגוריה → מוצרים אמיתיים. אפס הקלדה-חוזרת.
- **gating:** הכפתור עטוף ב-`if (query.isNotEmpty && ref.watch(claudeGatewayProvider) != null)` → ב-demo/no-AI הוא **לא קיים בעץ** → ה-no-results נשאר ה-`Text` המקורי (byte-identical). `initialQuery` ריק/null → `initState` לא מריץ כלום (המסך הידני ללא-שינוי).
- **anti-hallucination:** ללא חדש — חוזר על #ai-finder (closed-set `matchCategory`, מוצרים מ-`kCatalogProducts.where`).
- **gate:** analyze 0 errors/warnings (405 infos pre-existing) · `ai_finder_test`/`claude_gateway_test`/`describe_to_cart_test`/`search_fallback_test` ירוקים. catalog_screen + ai_finder_screen ב-screens → גייט 24/116.

### #ai-alt-explain — "למה החלופה הזולה שווה?" על sheet החלופות (out-of-box גל ⑥, המשך) — 2026-06-22
- **המהלך:** `alt_explain_screen.dart` (חדש) + נגיעה מינימלית ב-`contractor_tools_sheets.dart`: בכל שורת-חלופה ב-`_CheaperAlternativesSheet` נוסף `Consumer` שמרנדר כפתור **"🤔 למה כדאי?"** (`TextButton.icon`) → `AltExplainScreen.route(product/recName/recPrice/altName/altPrice)`. +2 imports (`claudeGatewayProvider`, `AltExplainScreen`).
- **הזרימה:** ההחלפה (מותג-מומלץ↔מותג-זול) + כל המספרים (מחיר-המלצה, מחיר-חלופה, חיסכון) מגיעים מ-`cheaperAlternativesAcrossCatalog()` האמיתי. המסך מציג אותם (data), קורא ל-Claude ב-`initState`, ו-Claude **רק מנסח** את ה-tradeoff ב-2–3 משפטים + הדבר-האחד-לבדוק.
- **anti-hallucination (grounded, לא closed-set):** ה-prompt (`altExplainPrompt`) **מוסר** את שני המותגים + שני המחירים + החיסכון, ו**אוסר** להמציא מפרט/מספר/שם-מוצר שלא ניתן + אוסר להבטיח ש"הזול תמיד עדיף". המספרים על המסך = של ה-data, לעולם לא של המודל.
- **gating:** הכפתור עטוף ב-`Consumer` שבודק `claudeGatewayProvider == null → SizedBox.shrink()` → ב-demo/no-AI **לא קיים בעץ**, ה-sheet byte-identical. המסך עצמו ב-null → "ההסבר החכם דורש חיבור".
- **gate:** analyze 0 errors/warnings · `alt_explain_test` (prompt-grounding: שני מותגים+מחירים+חיסכון · anti-hallucination guard) ירוק. alt_explain_screen + contractor_tools_sheets ב-screens → גייט 24/116.

### #ai-paired-explain — "מה עוד צריך להתקנה?" בכרטיס-המוצר (out-of-box גל ⑥, המשך) — 2026-06-22
- **המהלך:** `paired_explain_screen.dart` (חדש) + נגיעה מינימלית ב-`lipskey_product_sheet.dart`: ליד כפתור spec-copilot ("מתאים לתנאים שלי?") נוסף `Builder`+`Consumer` שמרנדר כפתור **"🧩 מה עוד צריך להתקנה?"** (`OutlinedButton.icon`) → `PairedExplainScreen.route(product: p.nameHe, types: frequentlyPairedTypesFor(p))`. +2 imports (`claudeGatewayProvider`, `PairedExplainScreen`; `frequentlyPairedTypesFor` כבר זמין מ-related_info).
- **הזרימה:** `frequentlyPairedTypesFor(p)` (מנוע קיים — גוזר מגרף-התאימות האמיתי את עד-4 סוגי-המוצרים שמותקנים לרוב יחד) נותן את הרשימה. המסך מציג את הסוגים (chips, data), קורא ל-Claude ב-`initState`, ו-Claude **רק מסביר** למה כל סוג נחוץ + שורת "אל תשכח".
- **anti-hallucination (grounded, type-level):** ה-prompt (`pairedExplainPrompt`) מוסר את המוצר + רשימת-הסוגים האמיתית ומגביל לדבר **ברמת סוג-המוצר בלבד** — אוסר להמציא שם-מוצר/מק"ט/מחיר ואוסר להוסיף סוגים מעבר לרשימה. ה-chips על המסך = של המנוע, לא של המודל.
- **gating:** `Builder` בודק `pairedTypes.isEmpty → shrink`; `Consumer` בודק `claudeGatewayProvider == null → shrink` → ב-demo/no-AI **לא קיים בעץ**, ה-sheet byte-identical. המסך ב-null → "ההסבר החכם דורש חיבור".
- **gate:** analyze 0 errors (4 warnings pre-existing dead-code ב-product_sheet, לא שלי) · `paired_explain_test` (grounding: מוצר+כל סוג · anti-hallucination guard) ירוק. paired_explain_screen + lipskey_product_sheet ב-screens → גייט 24/116.

### #ai-assistant — "🤖 העוזר החכם" עוזר-Claude מעוגן ב-AI hub (out-of-box #1) — 2026-06-22
- **המהלך:** `ai_assistant_screen.dart` (חדש) — מסך-צ'אט עצמאי עם state מקומי (`List<AssistantTurn>`), קלט+בועות+typing. ב-`ai_hub_screen.dart` נוסף tile `(id:'assistant', 🤖, "עוזר חכם")` **בסוף** רשימת ה-tiles + `case 'assistant'` → `AiAssistantScreen.route()` + import. **למה בסוף ולא בראש:** טסטי-widget (`ai_hub_compute`/`dedup`) מקישים על tiles לפי מיקום-על-המסך; הוספה בראש מזיזה את `חיזוי מלאי` לשורה הבאה → ה-tap מחטיא. tail שומר על כל ה-index הקיימים → אפס שינוי-טסט.
- **למה לא retrofit ל-sys_chat:** ב-`ChatEngineNotifier.send()` הנתיב החי (Firebase מחובר → `_remote != null`) **delegate ל-repo ו-return ב-560** — תגובת-הבוט קורית ב-`ChatRepository` (Firestore). שינוי שם = ניתוח dual-path + persistence + uid-scoping = סיכון-רגרסיה למנוע-הצ'אט בפרודקשן. עוזר-עצמאי = אותו ערך, **אפס נגיעה** במנוע.
- **grounding (כן, domain-bounded — לא closed-set):** עוזר-שיחה פתוח מטבעו, אז ה-`assistantSystem` הוא העיגון: (1) תוחם דומיין לאינסטלציה/בנייה/רכש, (2) **אוסר** להמציא שם-מוצר/מק"ט/מחיר/מלאי (אין לו גישה לקטלוג), (3) **מפנה** כל פעולת-קטלוג לכלים האמיתיים (תאר→סל · חיפוש-חכם · כרטיס-מוצר). `assistantTurnPrompt` מקפל היסטוריה **חסומה** (`kAssistantHistoryWindow=12`) לתוך prompt אחד (ה-callable מקבל user-message יחיד).
- **gating:** `claudeGatewayProvider == null` (demo/web/בדיקות) → המסך מציג "דורש חיבור" וקלט מושבת; tile תמיד גלוי (כמו describe), המסך מטפל ב-off-state. byte-identical בדמו.
- **gate:** analyze 0 errors/warnings · `ai_assistant_test` (system-grounding: domain/anti-hallucination/routes-to-tools · turn-prompt: history-fold + bounded-window) + `apple_readiness_hide_pass_test` (11−3=8 visible) ירוקים. ai_assistant_screen + ai_hub_screen ב-screens → גייט 24/116.

### #ai-adapter-explain — "🔌 איך לגשר?" על אזהרת-החיבור בקטלוג (out-of-box #4) — 2026-06-22
- **המהלך:** `adapter_explain_screen.dart` (חדש) + נגיעה ב-`catalog_screen.dart`: ה-`Builder` של אזהרת-החיבור (`connectionWarningHe(prod)`, step 29) הורחב — מתחת לאזהרה "נדרש מתאם" נוסף לינק-טקסט **"🔌 איך לגשר?"** (gated על `ref.watch(claudeGatewayProvider) != null`) → `AdapterExplainScreen.route(productName, sku)`. +1 import.
- **הזרימה:** המנוע (`connectionWarningHe`) מזהה שלחלק spec'd אין מצמד-ישיר בקטלוג. המסך קורא `kVerifiedSpecs[sku]`, מציג את הקצוות האמיתיים (`ends` → label עברי דרך `endTypeHe` + size) + החומר, וקורא ל-Claude שמסביר **למה** הם לא מתחברים + **איזה סוג-מתאם** מגשר.
- **anti-hallucination (grounded, type-level):** ה-prompt (`adapterExplainPrompt`) מוסר את הקצוות האמיתיים + החומר ומגביל **לרמת סוג-המתאם בלבד** — אוסר להמציא שם-מוצר/מק"ט/מחיר. ה-chips על המסך = של ה-spec, לא של המודל. `endTypeHe` מכסה את כל 6 ערכי `EndType` (אף קצה לא חסר-תווית).
- **gating:** הלינק עטוף ב-`if (aiOn)` בתוך ה-Builder → ב-demo/no-AI **לא קיים בעץ**, הכרטיס byte-identical (האזהרה עצמה ללא-שינוי). המסך ב-null → "דורש חיבור".
- **gate:** analyze 0 errors/warnings · `adapter_explain_test` (grounding: ends+material · anti-hallucination · endTypeHe-לכל-EndType) ירוק. adapter_explain_screen + catalog_screen ב-screens → גייט 24/116.

### #ai-quote-polish — "✨ נסח הצעה מקצועית" בכרטיס-המוצר (out-of-box batch-2 · הצעת-מחיר) — 2026-06-22
- **המהלך:** `quote_polish_screen.dart` (חדש) + נגיעה ב-`catalog_screen.dart`: ליד כפתור "📋 הצעה" (שמעתיק את `quoteTextFor(p, _selectedBrand)` הגולמי ל-clipboard) נוסף `Builder` gated שמרנדר **"✨ נסח"** → `QuotePolishScreen.route(rawQuote, productName)`. +1 import.
- **הזרימה:** `quoteTextFor` (פונקציה קיימת) בונה הצעת-מחיר גולמית מ-`lineCostEstimateFor` (מוצר/אביזרים/עבודה/סה"כ — מספרים אמיתיים). המסך מציג את הגולמי, קורא ל-Claude שמנסח אותו להודעה מקצועית ללקוח, ומאפשר **העתקה לשליחה**.
- **anti-hallucination (grounded, rewrite-only):** ה-prompt (`quotePolishPrompt`) מוסר את ההצעה הגולמית ו**אוסר** לשנות/להוסיף/למחוק מספר/מחיר/מק"ט — רק לנסח. הצעה שממציאה מחיר = אסון עסקי, אז המשמעת כאן קשיחה. המספרים על המסך = של ה-data.
- **gating:** הכפתור עטוף ב-`Builder` שבודק `claudeGatewayProvider == null → shrink` → ב-demo/no-AI **לא קיים בעץ**, הכרטיס byte-identical (כפתור "📋 הצעה" הגולמי ללא-שינוי). המסך ב-null → "דורש חיבור".
- **gate:** analyze 0 errors/warnings · `quote_polish_test` (raw-quote verbatim · forbids-changing-numbers guard) ירוק · full-suite baseline. quote_polish_screen + catalog_screen ב-screens → גייט 24/116.

### #ai-business-summary — "✨ סיכום עסקי" ב-Analytics (out-of-box batch-2 · סיכום-עסקי) — 2026-06-22
- **המהלך:** `business_summary_screen.dart` (חדש) + נגיעה ב-`ai_hub_screen.dart` (תוך ה-`_Analytics` בלבד — **לא** ברשימת-ה-tiles, כך ש-tile-position-tests בטוחים): אחרי ה-`AiServerNote` נוסף `if (gateway != null && insights.isNotEmpty) ...[` עם `OutlinedButton.icon` **"✨ סיכום בעברית"** → `BusinessSummaryScreen.route(insightLines)`. +2 imports (`claudeGatewayProvider`, `BusinessSummaryScreen`).
- **הזרימה:** `computeAnalyticsInsights(orders)` (מנוע קיים) מקפל את מנוע-ההזמנות + התקציב + סריקת-החלופות למספרים אמיתיים (הזמנות·ממוצע·פתוח/סופק·חיסכון·תקציב). הכפתור בונה `insightLines` מ-`'${it.ic} ${it.title} — ${it.sub}'` ומעביר למסך; Claude **רק מנסח** סיכום זורם.
- **anti-hallucination (grounded, narrate-only):** ה-prompt (`businessSummaryPrompt`) מוסר את שורות-התובנה ו**אוסר** להמציא/לשנות/להוסיף מספר — רק לשזור. ה-bullets על המסך = של המנוע.
- **gating:** ה-`if (claudeGatewayProvider != null …)` → ב-demo/no-AI הכפתור **לא קיים בעץ**, מסך-ה-Analytics byte-identical (כרטיסי-התובנה ללא-שינוי). המסך ב-null → "דורש חיבור".
- **gate:** analyze 0 errors/warnings · `business_summary_test` (insight-lines verbatim · forbids-inventing-numbers guard) ירוק · full-suite baseline. business_summary_screen + ai_hub_screen ב-screens → גייט 24/116.

### #ai-assistant-agentic — העוזר לוקח פעולות (closed action set · Phase 1 read-only) — 2026-06-22
- **המהלך:** `assistant_intent.dart` (חדש, logic/ — pure, data-only) + שכתוב `_send` ב-`ai_assistant_screen.dart`. במקום reply-טקסט-בלבד, המודל מחזיר **JSON של פעולה** מרשימה-סגורה (`answer`/`findProduct`/`summarizeOrders`/`checkBudget`), `parseAssistantIntent` מאמת, ו-`_dispatchIntent` מריץ מעל המנועים האמיתיים. +4 imports (assistant_intent · computeAnalyticsInsights · productsInCategory · ordersEngineProvider).
- **anti-hallucination (closed action + closed key, total parse):** ה-parse הוא **total** — JSON-שבור / action-לא-מוכר / קטגוריה-מחוץ-לקטלוג → `answer` (אף פעם לא זורק, אף פעם לא מבצע פעולה לא-מאומתת). `findProduct.key` עובר `matchAssistantCategory` (אותו closed-set כמו המאתר). כל מוצר/מספר במסך מגיע מ-`productsInCategory`/`computeAnalyticsInsights` — לעולם לא מהמודל (שמספק רק key מאומת + prose `say`).
- **Phase 1 = read-only:** אף ענף לא ממטט state (אין `addToCart` עדיין). `summarizeOrders`/`checkBudget` הם קריאות-טהורות של `computeAnalyticsInsights(ordersEngineProvider)`. Phase 2 (addToCart עם אישור) יבוא בנפרד.
- **gating + תאימות:** `claudeGatewayProvider == null` → ה-off-state הקיים (ללא-שינוי). הפונקציות הישנות (`assistantSystem`/`assistantTurnPrompt`/`kAssistantHistoryWindow`) **נשמרו** → `ai_assistant_test` הקיים ירוק. ה-tile ב-AI hub **לא זז** (position-pinned).
- **gate:** analyze 0 errors/warnings · `assistant_intent_test` (G1 unknown-action · G2 invented-category-downgrade · G3 malformed→answer-never-throw · prompt-grounding) + `ai_assistant_test` ירוקים · mutation-verify ב-mutation_log (#ai-assistant-agentic, +9→+8-1→+9) · full-suite baseline. assistant_intent ב-logic → גייט 42/44; ai_assistant_screen ב-screens → גייט 24/116.

### #ai-assistant-agentic Phase 2 — addToCart עם אישור-משתמש (v6.56) — 2026-06-23
- **המהלך:** הוסף `addToCart` ל-closed action set. ב-`assistant_intent.dart`: `matchAssistantRecipeKey` (closed-set מעל `kSmartProducts`) + ענף addToCart ב-`parseAssistantIntent` (מפתח-ערכה לא-תקין → `answer`) + הערכות ב-`assistantIntentPrompt`. ב-`ai_assistant_screen.dart`: `_dispatchIntent` מחזיר עכשיו `AssistantTurn` (לא String); addToCart מרכיב את הערכה (`matchRecipe`→`resolvedKitProducts`) ו**מציע** אותה ב-turn עם `kit`.
- **G5 — mutation מאחורי tap בלבד:** ה-`smartCartProvider.add` היחיד יושב ב-`_confirmAdd`, שמופעל **רק** מלחיצת המשתמש על "🛒 הוסף N לסל" בבועה. עד האישור הערכה היא **הצעה בלבד** (`_confirmedKitTurns` עוקב לפי index). שום נתיב-מודל לא מגיע ל-add — ה-AI מציע, המשתמש מאשר, הקוד מבצע. הכתיבה = ה-`SmartCartLine` הוורבטים מ-describe→cart.
- **anti-hallucination:** addToCart עם מפתח מחוץ ל-`kSmartProducts` → `answer` (אין הוספה שגויה); אם ה-recipe לא מרכיב פריטים → הודעת-שיחה, לא כפתור.
- **gate:** analyze 0 errors/warnings · `assistant_intent_test` (+addToCart: real-key-stays · invented-key→answer · matchAssistantRecipeKey) + `ai_assistant_test` ירוקים · mutation-verify (#ai-assistant-agentic-p2, +12→+11-1→+12) · full-suite baseline. assistant_intent ב-logic → גייט 42/44; ai_assistant_screen ב-screens → גייט 24/116.

## #honest-score — ציון-כן דו-צירי (v6.59)
- **`dataCompletenessScore(p)` (חדש, `lib/data/related_info.dart` → גייט 24/42):** ציון שלמות-listing 0..100 **spec-FREE** — dims-depth(40/30/18) · תמונה(15) · מחיר(12) · כמות pack/pallet(12) · וריאנטים(11) · מאתר(10). **לא קורא `kVerifiedSpecs`** → אביזר שלא-מתחבר עם listing מלא מקבל ציון גבוה (מזוכה). band-fences 80/55/30 כמו `cardReadinessScore`.
- **`cardReadinessScore`** ללא שינוי-נוסחה — נשאר "מוכנות חיבור/התקנה" (נשען על spec). השם בכרטיס שונה מ-"📊 ציון נתונים" ל-"🔧 מוכנות התקנה" (`lipskey_product_sheet.dart:~522` → גייט 116). שני שבבים ב-`Wrap` (📋 שלמות נתונים % · 🔧 מוכנות התקנה).
- **`kMountAuxCats` (חבקי תליה/חבקי צינור/ידיות אחיזה):** `installToolsFor`/`installTipsFor` מחזירים כלי+שלבי-הרכבה לפי קטגוריה כש-spec=null. **קוראי-installTools = ציון+תצוגת-כרטיס בלבד (אומת), אפס ניתוב-מנוע** → אין mate-שגוי. מעלה מוכנות-חבק 25→37.
- **R8:** לא הומצא חיבור. נחיל הציע spec-חיבור לחבקים → נדחה (חבק=מחבק צינור, ה-1/2" קוטר לא תבריג). low-is-correct ננעל ב-`honest_score_test` (`compatibleProductsCount('77006080')==0`).
- **גייט:** analyze 0 · `honest_score_test` (mutation-verified: dataCompletenessScore→0 שובר "listing NOT slandered") · card_score+polyroll_score+lipskey_score+external_card_score+line_score ירוקים (שינוי-חבק לא שבר הצמדה) · product_journey(935) ירוק (2-שבבים ב-Wrap בלי overflow).
### #ai-credit-explain — "💳 הסבר אשראי" ב-sheet הלקוח (מנהל · solo-wave) — 2026-06-23
- **המהלך:** `credit_explain_screen.dart` (חדש) + נגיעה ב-`manager_dashboard_screen.dart`: ב-`_CustomerDetailSheet` (ConsumerWidget), מתחת לשורות-האשראי (מסגרת/נוצל/יתרה/אתרים), נוסף `if (claudeGatewayProvider != null) ...[` עם `OutlinedButton.icon` **"💳 הסבר אשראי"** → `CreditExplainScreen.route(name, creditLimit, used, balance, pct)`. +2 imports.
- **הזרימה:** המספרים (מסגרת/נוצל/יתרה/ניצול%) דטרמיניסטיים — `mgrCustomerList`/`contractorCredit`/`computeCredit` מעל מנוע-ההזמנות החי. המסך מציג אותם, ו-Claude **רק מסביר** מה משמעות הניצול לפני אישור הזמנה נוספת.
- **anti-hallucination (grounded, explain-only):** ה-prompt (`creditExplainPrompt`) מוסר את 4 המספרים ו**אוסר** להמציא/לשנות/להוסיף מספר — החלטת-אשראי = החלטת-כסף. המספרים על המסך = של המנוע.
- **gating:** ה-`if (claudeGatewayProvider != null)` → ב-demo/no-AI הכפתור **לא קיים בעץ**, ה-sheet byte-identical (שורות-האשראי ללא-שינוי). המסך ב-null → "דורש חיבור".
- **gate:** analyze 0 errors/warnings · `credit_explain_test` (4-figures verbatim · forbids-inventing guard) ירוק · full-suite baseline. credit_explain_screen + manager_dashboard_screen ב-screens → גייט 24/116.

### #ai-daily-report — "✨ נסח דוח-יום" משותף (עובד + שליח · solo-wave) — 2026-06-23
- **המהלך:** `daily_report_screen.dart` (חדש, **משותף**) + נגיעה ב-`worker_reports_tab.dart` ו-`courier_reports_tab.dart`: ליד כפתור "💬 שלח דוח יומי" הקיים נוסף `if (gateway != null)` עם **"✨ נסח דוח עם AI"** → `DailyReportScreen.route(title, reportLines)`. כל טאב בונה את ה-reportLines מאותם מספרים-חיים שה-chat-report משתמש בהם (`_openAiDailyReport`/`_openAiCourierReport`). +2 imports בכל טאב.
- **הזרימה:** עובד — `tasksProvider` (אושרו/הוגשו/נדחו/בביצוע/בתור); שליח — `sysOrders`/`fulfillment`/`courierClock` (נמסרו-היום/סה"כ/פעילים/POD/ערך). המסך מציג את השורות, Claude **רק מנסח** דוח-יום זורם, כפתור "העתק לשליחה".
- **anti-hallucination (grounded, narrate-only):** ה-prompt (`dailyReportPrompt`) מוסר את שורות-הדוח ו**אוסר** להמציא/לשנות/להוסיף מספר. המספרים = של המנועים.
- **gating:** `if (claudeGatewayProvider != null)` בכל טאב → ב-demo הכפתור **לא בעץ**, שני הטאבים byte-identical (כפתור-השליחה הקיים ללא-שינוי). המסך ב-null → "דורש חיבור".
- **gate:** analyze 0 errors (4 warnings pre-existing ב-courier_reports_tab, לא שלי) · `daily_report_test` (title+lines verbatim · forbids-inventing) ירוק · full-suite baseline. daily_report_screen + worker/courier_reports_tab ב-screens → גייט 24/116.

### #ai-site-summary — "✨ סכם התקדמות" ב-יומן-האתר (קבלן · solo-wave) — 2026-06-23
- **המהלך:** נגיעה ב-`site_hub_screen.dart` (`_SiteDiary`, ConsumerWidget) + הכללת ה-AppBar של `daily_report_screen.dart` ("✨ דוח-יום"→"✨ ניסוח חכם", reuse). ב-`_SiteDiary` נוסף `if (gateway != null)` עם `_CaPrimary` **"✨ סכם התקדמות עם AI"** → `_openSiteSummary` שקורא את 3 המנועים (`siteDiaryProvider`/`siteSnagsProvider`/`siteInspectionsProvider`) ובונה reportLines → `DailyReportScreen.route('סיכום אתר', lines)`. +2 imports.
- **הזרימה:** המספרים (רישומי-יומן · ליקויים פתוחים/טופלו · ביקורות מתוכננות/בוצעו) דטרמיניסטיים מ-3 ה-providers החיים. המסך מציג אותם, Claude **רק מנסח** סיכום-התקדמות (reuse של DailyReportScreen).
- **anti-hallucination (grounded, narrate-only):** אותו `dailyReportPrompt` — מוסר את שורות-האתר ו**אוסר** להמציא/לשנות מספר. כיסוי-טסט דרך `daily_report_test` (ה-prompt משותף).
- **gating:** `if (claudeGatewayProvider != null)` → ב-demo הכפתור **לא בעץ**, ה-יומן byte-identical.
- **gate:** analyze 0 errors (4 warnings pre-existing dead-code ב-site_hub, לא שלי) · `daily_report_test` ירוק · full-suite baseline. site_hub_screen + daily_report_screen ב-screens → גייט 24/116.

### #ai-reject-reason — "✨ נסח סיבת-דחייה" בבקשות-תפקיד (מנהל · solo-wave, אחרון) — 2026-06-23
- **המהלך:** `reject_reason_screen.dart` (חדש) + נגיעה ב-`role_requests_inbox_screen.dart` (`_RequestCard`, Stateless): מתחת לשורת אישור/דחייה נוסף `Consumer` (inline) שמרנדר **"✨ נסח סיבת-דחייה"** → `RejectReasonScreen.route(role, name)`. +2 imports.
- **שונה מהשאר — generative, לא narrate:** כאן ה-AI **מייצר טקסט** ולא מנסח נתון אמיתי, אז העיגון הוא **closed-set של קטגוריות-סיבה** (מסמכים/הדרכה/בדיקת-רקע/אין-מקום) שה-prompt מוסר, + **איסור להמציא עובדות ספציפיות** על האדם. ה-system מגביל לנוסח כללי-מכובד; המנהל עורך/מעתיק לפני שליחה (לא מחווט אוטומטית לדחייה).
- **gating:** ה-`Consumer` בודק `claudeGatewayProvider == null → shrink` → ב-demo/no-AI **לא קיים בעץ**, הכרטיס byte-identical (אישור/דחייה בלבד).
- **gate:** analyze 0 errors/warnings · `reject_reason_test` (role+person+closed-set · anti-invention guard) ירוק · full-suite baseline. reject_reason_screen + role_requests_inbox_screen ב-screens → גייט 24/116.

### #swarm-fixes-w1 — תיקוני אודיט-הנחיל גל-1 (HIGH test-hygiene + a11y + spec_copilot) — 2026-06-23
- **רקע:** אודיט-נחיל-מלא (9 עדשות) על כל פיצ'רי-ה-AI — הארכיטקטורה תקינה (0 HIGH בקוד-הרץ). גל-1 סוגר את ה-ROI-הגבוה.
- **HIGH (test-hygiene):** `ai_assistant_screen` — הוסרו `assistantSystem`/`assistantTurnPrompt`/`kAssistantHistoryWindow` (מתים מאז ה-agentic upgrade; הנתיב-החי `_send` קורא ל-`assistantIntentSystem`/`assistantIntentPrompt`). `ai_assistant_test` כּוון-מחדש לבדוק את ה-grounding **החי** (היה בודק את המת → ביטחון-שווא). ספירת-טסטים נשמרה (6).
- **MED (a11y):** `contractor_tools_sheets` כפתור "🤔 למה כדאי?" → ≥48dp (היה `Size(0,32)`+shrinkWrap).
- **MED (spec_copilot):** טקסט-וורדיקט → `successDark`/`dangerDark` (WCAG AA) · מירוץ-טמפרטורה: `_temp` snapshot + drop-late-reply + ניקוי-spinner ב-onSelected.
- **gate:** analyze 0 errors/warnings · `ai_assistant_test` (live grounding) + `spec_copilot_test` + `alt_explain_test` ירוקים · full-suite baseline. 3 screens ב-screens → גייט 24/116.

### #swarm-fixes-w2 — model-allowlist (שרת) + a11y button-role בקטלוג — 2026-06-23
- **(LOW · שרת)** `functions/src/claude.ts` — `model` עבר מ-passthrough-חופשי ל-`kAllowedModels` allowlist (haiku-default + sonnet); id לא-מוכר → default. חוסם נעיצת-מודל-יקר / זבל (cost-safety). tsc נקי.
- **(LOW · a11y)** `catalog_screen.dart` — כפתורי "✨ נסח" + "🔌 איך לגשר?" עטופים ב-`Semantics(button: true, label)` → תפקיד-כפתור לקורא-מסך. ויזואלית byte-identical. גודל-היעד נשאר מוגבל ע"י עיצוב-השורה (משותף עם צ'יפים קיימים — דחוי).
- **gate:** analyze 0 errors/warnings · full-suite baseline. catalog_screen ב-screens → גייט 24/116.

### #swarm-fixes-w3 — narrate-bridge test (סיכום-אתר) — 2026-06-23
- **(MED · coverage)** הגשר caller→prompt של סיכום-האתר היה לא-בדוק. חולץ בונה-השורות מ-`_openSiteSummary` ל-`siteSummaryReportLines(diary, snags, inspections)` ב-`site_hub_state.dart` (state/ → לא גייט-42/44). `_openSiteSummary` קורא ל-helper (ויזואלית זהה).
- **טסט (`narrate_bridge_test`):** 4 בדיקות נועלות את הגשר-הקריטי — ספירות-הליקויים לפי `'פתוח'`/`'טופל'`, ביקורות לפי `'מתוכננת'`/`'בוצעה'`, ספירת-יומן + רישום-אחרון, ו-empty→אפסים-ללא-המצאה. typo במחרוזת-סטטוס היה מאפס ספירה בשקט — עכשיו נתפס.
- **gate:** analyze 0 errors (4 warnings pre-existing ב-site_hub, לא שלי) · `narrate_bridge_test` ירוק · full-suite baseline. site_hub_screen ב-screens → גייט 24/116.

### #swarm-fixes-w4 — de-dup סולם-התוצאה ב-8 מסכי-נרטיב + תשובה-ריקה + token-drift — 2026-06-23
- **(tech-debt · de-dup)** סולם-התוצאה (`if (!aiAvailable) … else if (_loading) … else if (_failed) …`) היה משוכפל **מילולית** ב-8 מסכי-AI. חולץ ל-3 widgets ב-`lib/widgets/ai_result_states.dart`: `AiOffState(text)` · `AiLoadingState()` · `AiFailedState(onRetry:)`. 8 המסכים: `alt/paired/adapter/credit_explain_screen` · `business_summary_screen` · `quote_polish_screen` · `daily_report_screen` · `reject_reason_screen`.
- **שלב-התוצאה נשאר per-screen** (`else if (_explanation/_summary/_polished/_report/_draft != null)` — 4 פשוטים `Text`, 3 spread עם כפתור-העתקה) → **אפס שינוי-פריסה** (לא נכנס ל-widget המשותף בכוונה, כדי לא לשנות `mainAxisSize`).
- **(LOW · תשובה-ריקה)** הצלחת-fetch עם `r.text.trim()` ריק ציירה `Text("")` ריק (200-empty). עכשיו בכל 8 ה-handler מנתב reply-ריק ל-`_failed = true` → שורה כנה + נסה-שוב (משתמש-חוזר ב-`AiFailedState`).
- **(LOW · WCAG)** שורת-הכשל "משהו השתבש — נסה שוב." עברה `BsTokens.danger`(0xFFEF4444)→`dangerDark`(0xFFB91C1C) — ניגודיות AA על הכרטיס-הבהיר, **פעם-אחת** ב-widget המשותף (חל על כל 8).
- **(LOW · token-drift)** `Color(0xFFEEEEEE)`/`0xFF9AA3B2`/`0xFFB91C1C` → `BsTokens.divider`/`mutedDark`/`dangerDark` (ערכים זהים-לפיקסל → rename טהור).
- **טסט (`ai_result_states_test`):** 4 בדיקות — `AiOffState` (mutedLight/13) · `AiLoadingState` (spinner) · `AiFailedState` (dangerDark + נסה-שוב, ו-onRetry נורה פעם-אחת בלחיצה).
- **gate:** analyze 0 errors · full-suite `+3333 -1` (רק `kb_golden` הידוע) · `lib/widgets`+`lib/screens` → גייט 24/116 (לא 42/44). **כל ממצאי-הנחיל גל-1→4 סגורים.**

### #swarm-fixes-w5 — אודיט-עדשות-שונות: grounding · races · server cost-safety · injection — 2026-06-23
נחיל-שני (8 עדשות חדשות: concurrency · failure-modes · grounding · prompt-injection · Riverpod/lifecycle · perf · RTL · backend-security). 0 HIGH · 6 MED · 2 LOW — כולם תוקנו. (Riverpod/disposal + RTL/i18n חזרו נקי.)
- **(MED grounding ×2)** ה-closed-set substring-fallback ב-`matchRecipe` (`describe_to_cart_screen`), `matchCategory` (`ai_finder_screen`), ו-`matchAssistantRecipeKey`/`matchAssistantCategory` (`logic/assistant_intent`) החזיר את המפתח ה**ראשון** המוכל. מפתחות מתנגשים בתחילית (`faucet`⊂`kitchenFaucet`, `basin`⊂`basinTrap`), אז תשובה עטופה (`"kitchenFaucet"`) תפסה את ה-prefix הקצר → ערכה שגויה-אך-אמיתית. **תוקן ל-longest-match** בכל 4 ה-matchers (pass-1 exact עדיין קודם). mutation-verified.
- **(MED race ×2)** `_search` (`ai_finder`) + `_find` (`describe_to_cart`): ה-`onSubmitted` של המקלדת עקף את חסימת-הכפתור בזמן `_loading` → submit-חוזר שיגר ask שני במקביל, ותשובה-מאחרת דרסה תוצאת-שאילתה-חדשה. נסגר ע"י `|| _loading` ב-early-return (חוסם את שני המסלולים — כפתור ו-Enter).
- **(MED injection)** `rejectReasonPrompt` (`reject_reason_screen`): `name`=`displayName` (טקסט-חופשי בשליטת-מבקש, בלי cap ב-rules) הוזרק ל-prompt שתשובתו **פרוזה** (אין closed-set אחריו) — וקטור-הזרקה חי. עכשיו `promptSafeText(name, maxLen:60, collapseWhitespace:true)` מקפל newlines וחותך. (`role` נשאר closed-set ע"י rules — לא וקטור.)
- **(LOW injection/cost)** `promptSafeText` (`logic/prompt_sanitize` — חדש) חל גם כ-cap-אורך על free-text ב-`describeToCartPrompt`/`aiFinderPrompt`/`assistantIntentPrompt` (closed-set מכיל הזרקה, אז כאן רק גבול-אורך נגד >8000→hard-fail).
- **(MED server ×2 + LOW)** `functions/src/claude.ts`: `enforceRateLimit(uid)` — Firestore fixed-window (`_claudeRate/{uid}`, 40/דקה, fail-open על infra-blip) → `resource-exhausted`; `maxInstances:10` (תקרת-קונקרנסי); Anthropic `timeout:25s`+`maxRetries:1` + onCall `timeoutSeconds:30` (היה SDK-default 600s → ספינר-מת). **דורש `firebase deploy --only functions:askClaude`.**
- **(LOW perf)** `ai_finder` body → `CustomScrollView`: התוצאות (~120 מוצרים בקטגוריה הגדולה) עברו מ-`for`-eager ל-`SliverList.builder` עצל. padding מפוצל לשקילות-layout (top/sides space4 + space2 קיים + trailing space4).
- **טסט:** `prompt_sanitize_test` (5: cap/collapse/trim) · `assistant_intent_test`+`describe_to_cart_test` collision-guards (ordered-pair finder → first-match מובטח-שגוי). mutation-verify: `assistant_intent_test` +13→first-match→`+12 -1`→שחזור→+13.
- **gate:** analyze 0 errors · full-suite baseline · `logic/` → גייט 42/44 (helper-test + mutation_log) · `screens/` → 24/116. **כל ממצאי שני-הנחילים (גל-1→5) סגורים.**

### #swarm-fixes-w6 — אודיט-נחיל #3 (8 עדשות-ליבה): 5 MED + 8 LOW — launch-readiness — 2026-06-23
נחיל-שלישי (8 עדשות חדשות: פיננסי · null-safety · סריאליזציה · הרשאות · מכונת-מצבים · offline/sync · layout · שלמות-טסטים). **null-safety + סריאליזציה חזרו נקי.** 0 HIGH · 5 MED · 8 LOW — כולם תוקנו.
- **(MED · שרת atomicity)** `functions/src/reviewRoleRequest.ts` — load-check-update עבר ל-`db().runTransaction` (re-read `status` ב-tx, flip אטומי). ה-claim מוענק רק אחרי-הניצחון ו**מחוץ** ל-tx (`setCustomUserClaims` הוא Auth-op, retry-unsafe). סוגר את ה-race "אישור מתחרה דחייה → `denied` עם תפקיד-מוענק".
- **(MED · שרת money)** `functions/src/credit.ts` — `used` חזר ל-Σ `sum` (grand-total מחויב, כולל מע״מ/משלוח/פריטים-קבועים) במקום `orderSum(lines)` (שורות-חשופות שמחסירות ~18%). תואם את ה-header המתועד + תצוגת-המנהל (Σ o.sum); לא יזוז כש-`SERVER_CALLABLES` נדלק. `orderSum` נשאר fallback ל-docs ללא-`sum`.
- **(MED · rules isolation)** `firestore.rules` chatThreads update ענף-(b) — חתימת-thread-ריק דורשת כעת שתפקיד-הקורא ∈ `participants` (`hasAny` על `token.role`/`token.roles`). worker/courier כבר לא יכול לחתום thread קבלן↔ספק ריק ולקרוא אותו (הבידוד הוא ברמת-תפקיד, וזה בדיוק מה שה-union-stamp מכניס). **3 בדיקות `rules_test/chat.test.js`** (role תקין מותר · worker נדחה · ללא-self נדחה).
- **(MED · client cache)** `firestore_cached_repo.dart` — `RemoteCollectionSource.isScoped` חדש; snapshot-ריק-ראשון תחת source-scoped מרוקן ל-honest-empty (לא seed-דמו). 16 fakes ב-test קיבלו `isScoped => false`. בדיקה ב-`firestore_cached_repo_test`. (גייט 42/44 → mutation_log.)
- **(MED · test-infra)** `kb_golden_test` — resolver פונט cross-platform (FLUTTER_ROOT/resolvedExecutable) במקום ה-`C:/flutter/...` הקשיח, + skip-by-default (`RUN_GOLDENS=1` להרצה מכוונת; הגולדנים host-specific). **known-failing 1→0** (`known_failing.txt` ריק, STATUS עודכן).
- **(LOW ×8)** `order_functions` advance/credit עטופים ב-`.timeout(30s)` · 5 טסטים assert-nothing קיבלו expect אמיתי (coverage_scan/find_all_four/long_chain/system_examples/dn_pipe_gaps) · 4 תיקוני-overflow (`persona_portal` title/sub maxLines · `departments` dept.name maxLines · `store_screen` _GridHubCard mainAxisSize.min · `store_screen` הסרת double-scroll מיותר).
- **gate:** analyze 0 errors · full-suite (kb_golden skipped) · functions tsc 0 · `lib/data` → גייט 42/44 · `screens` → 24/116. שרת+rules נפרסים אוטומטית (firebase-deploy.yml). **כל ממצאי שלושת-הנחילים (גל-1→6) סגורים.**

### #search-hybrid — חיפוש-AI literal-first (מתקן ברז→1 · שחור→נחושת) — 2026-06-23
תלונת-משתמש (QA אמיתי): בחיפוש-החכם/העוזר — `ברז` החזיר מוצר אחד, `שחור` החזיר "נחושת". **אבחון (תועד):** שני הפיצ'רים מיפו כל שאילתה ל**קטגוריה אחת** (`finderCategories`≡`assistantCategories`), והם **עיוורים** ל: צבע (אין קטגוריית-צבע → force-pick שגוי), מידה (54 מוצרים `1"` לא-נגישים), מילה-גנרית (`ברז`→הקטגוריה-הגנרית `'ברזים'` עם מוצר-1 — stray `34-5017` ברז-גן מסווג-בטעות). שורש: category-only · single-pick · weak-NONE.
- **התיקון — literal-first hybrid:** `_search` (ai_finder) ו-`_dispatchIntent`/`findProduct` (assistant) קוראים קודם `fuzzySearchProducts(query)` מ-`data/fuzzy_search.dart` (חיפוש דטרמיניסטי על `nameHe`, שנושא צבע/מידה/חומר/סוג). אם יש תוצאות → מציג אותן (label `🔎 "query"`). אם ריק → נופל ל-AI-מיפוי-הסמנטי הקיים (`aiFinderPrompt`/`matchCategory`/`productsInCategory`) לשפה-טבעית.
- **grounded:** `fuzzySearchProducts` מחזיר רק שורות-`kCatalogProducts` אמיתיות; עקבי עם שרשרת-החיפוש של הקטלוג (`search_fallback_test`: AND→OR→fuzzy). אפס הזיה.
- **assistant:** `_dispatchIntent(intent, userText)` — userText מועבר כדי לאפשר fuzzy על הטקסט-הגולמי; שאר ה-cases (answer/summarizeOrders/checkBudget/addToCart) ללא-שינוי.
- **טסט (`ai_finder_test` +4):** COLOR `שחור`→מוצרים-שחורים ולא `'אביזרי נחושת'` · GENERIC `ברז`→>1 · SIZE `1"`→לא-ריק · חוזה-חיווט (המסך מפנה ל-`fuzzySearchProducts`). הטסטים הקיימים (`matchCategory`/`productsInCategory`) עדיין ירוקים (ה-AI-fallback נשמר).
- **gate:** analyze 0 errors · `ai_finder`+`ai_assistant`+`assistant_intent` tests ירוקים · full-suite baseline · `lib/screens` → גייט 24/116 (לא 42/44; `fuzzy_search.dart` לא-נגע). **נדחה:** ניקוי ה-stray `34-5017`/`'ברזים'` (דאטה — מיותר כעת כי fuzzy-first עוקף את המלכודת).

### #manager-copilot — 🤖 קו-פיילוט למנהל "שאל את העסק שלך" (M2) — 2026-06-23
הפיצ'ר-הדגל הראשון מ-`MANAGER-BUILD-PLAN.md`. הבעלים שואל בעברית → Claude עונה מהדאטה-החיה. **grounded** מלא.
- **`lib/logic/manager_copilot.dart` (חדש · גייט 42/44):** `buildManagerContext({analytics, customers, stageCounts})` מקפל snapshot-עברית מקורקע (הזמנות/מחזור/צינור/קטלוג/אשראי/לקוחות-מובילים) · `managerCopilotSystem` (אנליסט, אסור-להמציא, ענה-מהקונטקסט-בלבד) · `managerCopilotPrompt(ctx,q)` (שאלה capped ב-`promptSafeText`) · `managerMorningBriefPrompt(ctx)` · `kManagerCopilotSuggestions`.
- **`lib/screens/manager_copilot_screen.dart` (חדש):** `ManagerCopilotScreen` — צ'אט RTL (בועות user-brand/assistant-card · `_Welcome` עם צ'יפי-שאלות + "☀️ תדריך-בוקר" · `_InputBar`). קורא `managerAnalyticsProvider`/`managerCustomersProvider`/`ordersEngineProvider` ב-ask-time → `buildManagerContext` → `gw.ask(prompt, system: managerCopilotSystem, maxTokens:420)`. גדור `claudeGatewayProvider` (null → `AiOffState`). race-guard `_loading`.
- **`manager_dashboard_screen.dart`:** `_CopilotHero` (כרטיס brand-gradient בראש `_DashboardTab`) → `ManagerCopilotScreen.route()`. **לא** AppBar-action (6th action גרם RenderFlex-overflow 18px — נבדק; ה-hero בולט יותר ממילא).
- **ממשל:** מודיעין/פיקוח = תחום-המנהל · אפס-HR · additive · אפס-רגרסיה (מנהל-בלבד · off-state בלי-שרת).
- **gate:** analyze 0 · `manager_copilot_test` (7: context-folding · grounding-system · prompt · cap · brief · suggestions) + `manager_copilot_screen_test` (off-state render) · 49 טסטי-מנהל ירוקים · full-suite. screens → 24/116.

### #manager-copilot-r1 — אודיט-נחיל סיבוב-1 (7 תיקונים) — 2026-06-23
נחיל-4-עדשות על הקו-פיילוט. **(HIGH)** הזרקת-`c.name` → `promptSafeText` ב-`buildManagerContext`. **(MED)** clamp ניצול-אשראי(0,100) · הסרת-"מגמת-מחזור" מהתדריך · `tooltip:'שלח'` · ניגודיות-בועה (טקסט-כהה). **(LOW)** `money()` שלילי · hero-subtitle full-white. concurrency נקי. `manager_copilot_test` 12 ירוק · analyze 0.

### #manager-copilot-r2 — אודיט-נחיל סיבוב-2: gateway-timeout + maxTokens-per-call — 2026-06-23
נחיל-עדשות-שונות (error-handling · concurrency · governance · a11y) על הקו-פיילוט. concurrency/ממשל/Riverpod **נקיים**. תוקנו:
- **(MED · error-handling)** `claude_functions.dart` — `ClaudeGateway.ask` בלי `.timeout()` בצד-לקוח → `.timeout(const Duration(seconds:30))` סביב ה-`.call(...)`; `on Object catch` הקיים ממפה timeout→`ClaudeException('unavailable')`. תאם ל-`order_functions.dart`. (lib/data → 42/44; נעוץ ב-`claude_gateway_test` חוזה-maxTokens.)
- **(LOW · truncation)** `manager_copilot_screen.dart` — `_run` קיבל `{int maxTokens=420}`; `_morningBrief` מעביר `600` (תדריך-עברי ארוך, עדיין ≪ cap-שרת 2048). Q&A=420. (screens → 24/116.)
- **נדחה (מתועד):** prompt-cache (`functions/src/claude.ts` `cache_control` — server-wide לכל-הקוראים, LOW) · fake-gateway screen-test למסלולי success/empty/catch (פער-כיסוי, אופציונלי).
- **gate:** analyze 0 errors · `claude_gateway_test` (+maxTokens-forwarding) · `manager_copilot_test` 12 · 49 מנהל · full-suite.

### #manager-copilot-r3 — אודיט-נחיל סיבוב-3: a11y/RTL + S0 ממשל (כפתור-הגדרות) — 2026-06-23
נחיל-עדשות-שונות (RTL/overflow/a11y · numeric · Riverpod-lifecycle · wiring/governance). **Riverpod — LENS CLEAN** (disposal/mounted/read-vs-watch מלאים). **Numeric — נקי** (כל חלוקה גדורה · `revenue==Σspend` מחזיק · clamps נכונים; `money()` שלילי = אי-התאמה-קוסמטית בלתי-נגישה, תועד כלא-תקלה). תוקנו:
- **(MED · a11y/overflow)** `manager_copilot_screen.dart` — כותרת-AppBar (Column דו-שורתי) בלי `maxLines/overflow` → גלישה-אנכית ב-textScaler גדול → `maxLines:1, overflow:ellipsis` לשתי השורות.
- **(LOW · RTL)** `manager_copilot_screen.dart` — `_Typing` השתמש ב-`EdgeInsets.only(right:)` פיזי → `EdgeInsetsDirectional.only(start:)` (אותו מראה ב-RTL, מתהפך נכון ב-LTR).
- **(LOW · a11y)** `manager_dashboard_screen.dart` — כותרת-AppBar בלי ellipsis → `maxLines:1, overflow:ellipsis`.
- **(HIGH · governance S0)** `catalog_settings_screen.dart` — כפתור-ההגדרות של המנהל פתח את ה-`CatalogSettingsScreen` המשותף **כולל** שורת-הפרופיל-של-הקבלן (→ `ProfileScreen`) = דליפת-persona. תוקן: param `showProfileRow` (ברירת-מחדל `true`). 3 קוראי-קבלן (home_shell · keyboard×2) ללא-שינוי; 2 קוראי-מנהל (dashboard:194 · profile:208) מעבירים `false` → המנהל מקבל את אותו No-Code admin (תצוגה/אזור/מחירים/ספקים/AI — תחומו לפי-ממשל) **בלי** שורת-הפרופיל. זה ה-S0-step מ-`MANAGER-BUILD-PLAN.md` (שורה 18) / ממשל #84.
- טסט: `catalog_price_units_settings_test` +2 (קבלן→מציג · מנהל→מסתיר+שומר admin) = 18 ירוק. `manager_dashboard_screen_test` 30 · `manager_copilot_screen_test` · analyze 0. screens → 24/116.
- **נדחה ל-Phase-0 build (תועד, לא תקלת-קו-פיילוט):** עדשת-ה-wiring אישרה שעדיין-חיים — `manager_dashboard_screen.dart:2346-2375` (👷 אישורי-עובדים approve/reject) + `:2382-2395` (🏖️ חופשות worker+courier) + `vacation_requests.dart:20,282` (ניתוב-החלטה למנהל). אלה ניוד-HR רב-personas (worker→קבלן · courier→חנות) = Phase-0 בתוכנית-הבנייה (שורה 43), refactor-גדול שדורש בניית משטחי-קליטה — לא in-round patch.

### #manager-copilot-r4 — אודיט-נחיל סיבוב-4: קשיחות-בדיקות (regression-armor) — 2026-06-23
נחיל-4-עדשות-טריות: **security/PII · degraded-state/flag-matrix · prompt-grounding — שלושתן LENS CLEAN** (סוד רק ב-Secret-Manager · אפס log-leak · auth+rate-limit+caps בשרת · off-state בכל צירוף-דגלים · empty-state כן · 5 ההצעות כולן answerable מהקונטקסט · top-5 בלבד · client maxTokens≤cap-שרת). העדשה ה-4 (**test-quality**) מצאה ש**שכבת-המסך + מיפוי-ה-gateway-האמיתי נשלחים בלי כיסוי** — נסגר (test-only, אפס שינוי-קוד-מוצר):
- **`manager_copilot_screen_behavior_test.dart` (חדש, 7):** מסלולי-המסך החיים דרך fake-gateway ב-override — success-בועה · empty→fallback כן · throw→בועת-retry · race-guard (input נעול בזמן-טיסה · call יחיד) · תדריך maxTokens 600 · Q&A 420 · צ'יפ מקפל שאלה+context('מצב-העסק')+system.
- **`claude_gateway_test.dart` (+3):** ה-`FirebaseClaudeGateway` האמיתי (fake `FirebaseFunctions` מוזרק) — `FirebaseFunctionsException`→code verbatim · שגיאה-אחרת→`unavailable` · transport-תקוע→`.timeout(30s)` (ב-`fakeAsync`) →`unavailable`. החוזה: cloud_functions לא דולף, ה-UI לא נתלה.
- **`manager_copilot_test.dart` (+4, חוזק):** money() **שלילי** באמת-מורץ (`-₪1,200`) · empty-state ('אין הזמנות'+'(אין לקוחות עדיין)') · zero-limit→בלי 'ניצול-אשראי' (אפס-div) · revenue==**5490** מוחלט (שובר את ה-recompute-mirror) · cap מאשר 400-הראשונים שורדים.
- **gate:** analyze 0 · 3 קבצי-בדיקה ירוקים (7+10+7) · full-suite · אין lib נגוע → אין 24/42/44/116 (test-only).

### #manager-copilot-r5 — אודיט-נחיל סיבוב-5: סריקת-AI-רוחבית (injection · grounding · RTL · manager-tabs) — 2026-06-23
נחיל מורחב על **כל משטח-ה-AI** (13 קוראי-`gw.ask`) + הטאבים הלא-קו-פיילוט. **grounding — LENS CLEAN** (כל 13 הפיצ'רים אוסרים-להמציא + closed-set longest-match) · **AI-screens RTL/overflow — LENS CLEAN** (מחלקת-overflow-הכותרת של הקו-פיילוט לא חוזרת באחים) · **manager-tabs — 2 LOW בלבד** (אפס wrong-number/dead-control). תוקנו:
- **(HIGH · injection)** `credit_explain_screen.dart:33` — שם-הלקוח (`c.name` = `Order.who`, חופשי בשליטת-קבלן) הוזרק **גולמי** ל-prompt בעוד התאום (`manager_copilot.dart:83`) כבר מנקה אותו → `promptSafeText(name, 40, collapseWhitespace)`. אותו וקטור-הזרקה בדיוק (sanitized-here/raw-there). reply = פרוזה חופשית בלי closed-set → מסוכן. test +1.
- **(MED · a11y/contrast)** `ai_assistant_screen.dart:324` — בועת-משתמש לבן-על-brand (~2.7:1, נכשל WCAG AA) → טקסט-כהה `inkLight` (אותו תיקון כמו הקו-פיילוט ב-r1).
- **(LOW · injection-defense)** `daily_report_screen.dart:30` — `title` (נושא `displayName` של שליח) נחתך ב-`promptSafeText(80, collapseWhitespace)` בבּילדר → מגן על כל הקוראים. test +1.
- **(LOW · honesty)** `manager_dashboard_screen.dart:386` — docstring טען "כל 5 ה-tiles live" בעוד 4/5 const-by-design → תוקן לדייק (רק 🚚 open-orders engine-live; קטלוג/אביזרים/זמין/חנויות = ports סטטיים).
- **מאומת-תקין (11 קוראי-gw.ask):** reject_reason (name wrapped 60) · ai_finder/describe_to_cart/assistant (query wrapped 600 + closed-set) · quote_polish/business_summary/adapter/paired/alt/spec (catalog/system-data בלבד). **נדחה (LOW · inert):** toast בנתיב server-callable מציג שלב-ישן (kServerCallables כבוי בשילוח).
- **gate:** analyze 0 · credit_explain(3)/daily_report(3)/ai_assistant(11) ירוקים · full-suite · screens → 24/116.

### #manager-copilot-r6 — אודיט-נחיל סיבוב-6: אחי-ה-AI + impersonation (async · honesty · isolation · coverage) — 2026-06-23
4 עדשות על האחים (לא-קו-פיילוט). **async-lifecycle (12 מסכים) — LENS CLEAN** (mounted-guards/dispose/double-submit מלאים בכולם). תוקנו:
- **(LOW · honesty)** `spec_copilot_screen.dart:96` — reply ריק רינדר "🤖 " stub בלי retry (כל האחים מנתבים empty→failed) → `if(reply.isEmpty) _failed=true`. מחזיר retry.
- **(LOW · contrast)** `ai_finder_screen.dart:250` + `describe_to_cart_screen.dart:208` — שורת-כשל `danger`→`dangerDark` (WCAG AA, parity עם AiFailedState המשותף).
- **(MED · impersonation residue)** `board_auth.dart:356` — `logout()` מתוך board-מתחזה השאיר `_impersonationReturn` ואיפס את session-המנהל (לא-מתמיד) → ב-restart המנהל מנותק לגמרי. תוקן: logout בזמן impersonation **חוזר** לסשן-המנהל (impersonation אפמרי); logout רגיל ללא-שינוי. `manager_impersonate_test` +2.
- **מאומת-תקין:** entry-gating של impersonation (רק מנהל), באנר "צופה כ", return-path, restart-safety — כולם תקינים.
- **נדחה ל-build-ממוקד (תועד, HIGH/MED):**
  - **(HIGH)** boards-מתחזים **interactive ולא read-only** (`manager_screens_sheet.dart:60` + `board_auth.dart:319`) — מנהל יכול לכתוב כ-seed (clockIn/submitTask/store-save/courier-deliver). תיקון = readOnly דרך 3 boards (worker/store/courier) — refactor רב-personas, אין choke-point יחיד ששומר scroll-לצפייה. בשילוח-הדמו הכתיבות מקומיות-בלבד (דגלים כבויים) → לא דליפת-backend, אבל ממשל-שגוי. = build-ממוקד אחרי הנחיל.
  - **(MED)** role-switch/logout נגישים ב-worker-profile בזמן impersonation (חלק מה-readOnly לעיל).
  - **(12×MED · test-coverage)** כל 12 אחי-ה-AI הם LOGIC-ONLY (prompt-builder נבדק; מסלולי-מסך success/empty/error/off לא) — אותו פער שנסגר לקו-פיילוט. כל אחד צריך `*_screen_behavior_test`. = סבב-בדיקות ייעודי.
- **gate:** analyze 0 · spec_copilot/ai_finder/describe_to_cart + manager_impersonate(5)/board_auth(20) ירוקים · full-suite · screens→24/116 · state (לא 42/44).

### #vat-single-source — אודיט-נחיל סיבוב-7: מע״מ 17%↔18% מאוחד למקור-אמת-יחיד — 2026-06-23
נחיל-4-עדשות (backend-authz · pricing/VAT · persistence · boards). **backend-authz · boards — CLEAN.** תוקנו:
- **(HIGH · money)** הקטלוג הציג מע״מ 17% (`kVatRate=0.17`) בעוד העגלה/קופה חייבה 18% (`/1.18`) וה-מנהל פרסם 18% — **מחיר-עיון ≠ חיוב-בקופה** לאותו מוצר. ישראל = 18% חוקי מ-2025-01-01 (גם הלגאסי: `VAT_RATE=0.18`). תוקן: `kVatRate=0.18` (מקור-אמת-יחיד) · `cartVat` ב-`store_screen.dart` נגזר מ-`kVatRate` (זהה-מספרית, אך לא יוכל לסטות שוב) · `_vatPercent` ב-`manager_dashboard_screen.dart` נגזר מ-`kVatRate`. עכשיו עיון==קופה==מנהל, לנצח.
- **(LOW · persistence)** `smart_input_usage.dart:44` — ה-`jsonDecode` היחיד בלי try/catch בכל הקוד-בסיס → עטוף ב-`try/on Object catch` כמו כל אח (ערך-תדירות פגום לא יזרוק מ-`_load` הלא-מומתן; self-heal בבחירה הבאה).
- **טסט:** `catalog_price_units_settings_test` עודכן ל-18% (118/330/496 · `kVatRate==0.18` · `~₪118`). טסטי-העגלה (`gaps`/`state_deep`/`hard`/`cart_stress`/`cart_bulk`) **נשארו ירוקים** (כבר ציפו 18%). 122 ירוקים · analyze 0. screens → 24/116; `kVatRate`/`cartVat` נבדקים. אין lib/logic|data → אין 42/44.

### #r8-a11y-statemachine — אודיט-נחיל סיבוב-8: a11y + מנעול-double-tap בחנות — 2026-06-23
נחיל-4-עדשות (order-state-machine · deep-a11y · offline-sync · i18n). תוקנו:
- **(MED · state-machine)** `store_dashboard_screen.dart` — ה-`_advance` של החנות חסר את מנעול-ה-staleness שיש לשליח (F-12) → double-tap מהיר על כפתורי `new→preparing→ready` הלא-מאושרים קידם 2 שלבים במחווה אחת. תוקן: מראה-בראי את courier F-12 (קריאת `sysOrdersProvider` חי, no-op אם `current.stage != o.stage`).
- **(MED · a11y/contrast)** 3 כפתורי-_Pill לא-פעילים (`store_screen.dart` 730/1821/2609) צבע `#AAAAAA` על `#F5F5F5` ≈2.3:1 (נכשל AA) → `#595959`. + `catalog_screen.dart` כותרת-מותג `#9AA3B2`→`mutedLight` · טקסט-תאימות `#999999`→`#595959`.
- **(MED · a11y/labels)** כפתורי-IconButton בלי tooltip → נוספו: catalog (אישור/סגירה/חזרה/נקה/השתמש-בחיפוש/הסר) · store (נקה/הסר-מהסל). unread-notif (`store_dashboard:2069`) צבע-בלבד → `Semantics(label:'לא נקרא')`.
- **gate:** analyze 0 · product_journey (935-sheet HARD) + persona_fulfillment + store_notif ירוקים · screens→24/116. מנעול-החנות = ראי-נאמן ל-courier F-12 (אותו דפוס מוכח). אין lib/logic|data→אין 42/44.
- **נדחה (תועד):** offline-queue MED (`offline_order_queue.dart:283` מוחק intent על-replay-כושל — **inert בפרודקשן**: probe מקובע `()=>true`, אפס callers; Firestore-SDK-persistence הוא הנשא בפועל) · i18n currency-grouping MED → סיבוב הבא · pluralization "1 פריטים" LOW = verbatim-מהלגאסי (parity).

### #currency-single-source — אודיט-נחיל סיבוב-8 (i18n): ₪ מקובץ אחיד — 2026-06-23
תיקון ה-MED מעדשת-ה-i18n (סיבוב-8): קיבוץ-אלפים של ₪ היה **לא-עקבי** — קטלוג/בית/קבלן הציגו "₪4200" בעוד עגלה/מנהל/תקציב/פיננסים הציגו "₪4,200" (אותו מוצר, שתי תצוגות).
- **`lib/logic/money_format.dart` (חדש · 42/44):** `groupThousands(int)` פרימיטיב-יחיד + `formatNis`. 
- **נותבו דרכו (15 אתרי-גולמי):** `formatCatalogPrice` (catalog_settings — כרטיס-המוצר הראשי) · catalog_screen (8: b.price/price/alt.price/c.total+product+accessories+labour/_total/acc.price×2) · smart_home (rec.price/order.sum) · contractor_tools (recPrice/altPrice/savings/offer.price/total). nullable → `!` היכן שגדור (analyze 0).
- **gate:** `money_format_test` (5) + catalog_price_units (18%) + product_journey (935 HARD) ירוקים · analyze 0. screens→24/116 · money_format→42/44.
- **נשאר (תועד · LOW):** 4 ה-helpers הפרטיים (`_price`/`_grouped`/`_thousands`/`_group`) מקבצים-נכון (פלט זהה ל-`groupThousands`); האצלתם ל-`groupThousands` = ניקוי-פנימי אפס-ערך-משתמש, נדחה (לא נוגעים בקוד-נכון-חי לפני launch).

### #r9-catalog-perf — אודיט-נחיל סיבוב-9 (perf): hoist-RegExp + PERF-H2 suggestions-provider — 2026-06-23
נחיל-4-עדשות (memory/disposal · performance · navigation · input). **בדיקת-אמת:** 2 מ-3 ה-HIGH של עדשת-הביצועים היו **stale** — הם כבר תוקנו: `searchResultsProvider` (PERF-H1, ההתאמה מחושבת ב-provider לא ב-build) + `categorySummaryProvider` (PERF-H3, סיכומי-קטגוריה ממומואזים פעם-אחת/system; `_CatalogRow` עושה map-lookup). תוקן הנותר:
- **(perf · multiplier)** `catalog_screen.dart` — `RegExp(r'\s+')` נוצר-מחדש per-product per-keystroke ב-`_tokenHitHe`/match/relevance (O(catalog) loops) → hoisted ל-top-level `final _wsSplit`. אפס שינוי-התנהגות.
- **(perf · PERF-H2)** `searchSuggestions(...)` רץ **בתוך `_SearchSuggestions.build()`** (סריקת-מילים O(catalog) per-keystroke) → חולץ ל-`searchSuggestionsProvider` (אחות ל-H1), מחושב פעם-אחת/query·scope·system. אותם guards (ריק עד ≥2 תווים בסקופ-מוצרים), אותו פלט.
- **נדחה (תועד · רציונל):** debounce-חיפוש (ההתאמה כבר provider-ized + guard ≥2 + 935 צנוע; debounce נוגע ב-controller-sync/submit-flush בליבת-החיפוש החיה — סיכון>תועלת ללא device-profiling) · ResizeImage thumbnails (cache כבר חסום 700/~MB; resize per-slot צריך הקשר-תצוגה — סיכון-רגרסיה ויזואלית בליבה).
- **gate:** 19 בדיקות-חיפוש (search_suggestions/match_boundary/fallback/sku_pollution/huliot) ירוקות · analyze 0. screens→24/116; אין lib/logic|data→אין 42/44.

### #r9-hygiene — אודיט-נחיל סיבוב-9 (hygiene): disposal-idiom + trim + camera-toast — 2026-06-23
שאר ממצאי R9 (אחרי v6.86 perf). תוקנו:
- **(9× MED · disposal)** idiom אחיד: `TextEditingController`/`FixedExtentScrollController` מקומי-לפונקציה שמועבר ל-`showDialog`/`showModalBottomSheet` ולא-נזרק. תוקן ב-`store_screen` (×3) · `catalog_screen` (×3) · `install_studio_screen` (×3) · `lipskey_products_screen` (×1) — `.whenComplete(()=>ctrl.dispose())` ל-statement, dispose-אחרי-await ל-awaited (catalog `_rename` שוכתב dispose-after-await כדי לא-לשבור null-promotion). State-field controllers (כבר עם dispose) לא-נגעו.
- **(LOW · input)** `welcome_screen._register` — שם/קשר נשמרו לא-trimmed → `.trim()`.
- **(LOW · nav)** `camera_sheet._capture` — toast אחרי pop על context-מת (נשמט שקט) → `rootCtx` שנלכד-לפני-pop (אותו דפוס כמו `_onDetect`).
- **נדחה (תועד · רציונל):** qty upper-clamp — **נבדק ונדחה**: עגלת-B2B-בנייה מזמינה לגיטימית >999 יח' (`cart_stress` מאשר qty=100000); Dart int לא-עולה-על-גדותיו בערכי price×qty ריאליים → ה"runaway" תיאורטי. נשאר ללא-חסם-עליון (חסם-תחתון qty<=0→הסרה נשמר). · checkout double-submit (LOW · synchronous+immediate-pop ממתן · תיקון=המרה-ל-stateful = churn).
- **gate:** analyze 0 · cart_stress + product_journey (935 HARD) + cart_safety/bulk ירוקים · screens→24/116. אין lib/logic|data→אין 42/44.

### #r10-finish — אודיט-נחיל סיבוב-10 (הסיבוב העשירי): crash-paths CLEAN + date-fix — 2026-06-23
הסיבוב ה-10 (משלים ≥10). 4 עדשות-טריות (crash-paths · date/time · engine-concurrency · dead-code). **crash-paths — LENS CLEAN** (סריקה ממצה: כל `.first`/`.firstWhere`/`.reduce`/`[i]`/`map[k]!`/parse גדור). תוקן:
- **(MED · date)** `install_studio_screen._formatDate` — timestamp-עתידי (שעון-מכשיר אחורה) הציג "לפני -3 דקות" → clamp ל-"עכשיו"; + צורות-יחיד עבריות (לפני דקה/שעה · אתמול · עכשיו ל-<דקה).
- **gate:** analyze 0 · install_builder + full-suite. screens→24/116.
- **נדחה (תועד · רציונל — כולם LOW/narrow/feature-wiring, אפס launch-blocker):**
  - **dead-code (feature-wiring):** תוצאות-חיפוש מסוג `SearchType.screen` ('ספקים ומותגים'/'התראות'/'חנות') ב-`catalog_screen` רק-כותבות-query במקום לנווט → `SuppliersScreen`+`LipskeyBrandScreen` יתומים. זה **גַּף-בנייה** (צריך מיפוי entry→screen, כמו ניוד-HR Phase-0) — מתועד, לא patch.
  - **engine-concurrency (2× LOW · failure-only):** `tasks_engine._saveRejectNote` partial-write לא-מסודר (side-map) · `persona_fulfillment.capturePod/captureSignature` rollback מוחק-כל-המפה ב-3 אתרים (דורש כשל-quota + כתיבה-מקבילה לעוד-הזמנה — נדיר-קיצוני, מסונכרן ב-load הבא).
  - **dead-helpers (MED-cruft):** `install_engine.connectionMethodLabel`/`pipeConnectionDn` · `brand_history.countsFor/totalPicks` — אפס-callers (אולי-roadmap; הסרה נדחית כדי לא-למחוק WIP אפשרי).
  - **10 providers אפס-ref** = roadmap-infra מתועד (לא-dead).

### #studio-s1 — סטודיו No-Code · value-objects של מנוע-הקונפיג (עמוד-1 · שלב-1) — 2026-06-23
תחילת בניית הסטודיו (`STUDIO-100-STEPS` שלב-1). **`lib/state/studio/config_node.dart` (חדש):** `CfgNode`/`CfgStyle`/`CfgAction` — value-objects אימutable + JSON-סלחני (toJson sparse משמיט-nulls · fromJson שומר מפתח-לא-מוכר ב-`extra` · enum-fallback בלי-throw · fontScale clamp 0.8–1.6 · int→double · ==/hashCode ידני, בלי equatable/uuid — גייט 60). טהור, **אפס-wiring, אפס-צרכן → inert** (`kStudioFlag` ייווצר בשלב-4; עד אז אין מי שקורא → answer-equivalent ביבילד). canonical: `studio-plan/01` §2.1–2.3 + R1/R2.
- **gate:** `config_node_test` 15 ירוקים · analyze 0 · lib/state → גייט 24 (לא 42/44). שלב-הבא: `ConfigDoc` (שלב-2).

### #studio-s2 — סטודיו · מסמך-הקונפיג השכבתי (עמוד-1 · שלב-2) — 2026-06-23
**`lib/state/studio/config_doc.dart` (חדש):** `ConfigLayer` (global · persona[roleKey] · structure-שמור-ל-Pillar-2) · `ConfigVersion` (snapshot מלא, rollback-מדויק) · `ConfigDoc` (published⊕draft⊕history-ring-cap-30⊕schemaVersion). `ConfigDoc.empty`=inert · `migrate()` forward-compat (חוסר-schema⇒v1) · cast-סלחני ל-persona map-of-maps · `draftNodeCount` ל-badge. consts: `kHistoryCap=30`/`kSchemaVersion=1`. אפס-צרכן→inert. `config_doc_test` 8 ירוקים · analyze 0.

### #studio-s3 — סטודיו · ליבת-המיזוג `mergeNode` (עמוד-1 · שלב-3) — 2026-06-23
**`lib/state/studio/config_merge.dart` (חדש, טהור — אפס Flutter):** `mergeNode(id, doc, roleKey, {includeDraft, criticalIds})` ממזג `identity ⊕ published.global ⊕ published.persona[roleKey] ⊕ draft` (draft רק ב-includeDraft), most-specific-wins per-axis. `CfgStyle`/`CfgAction` ממוזגים **שדה-אחר-שדה** (טיוטת-fontScale שומרת colorToken — R1/R2-#5). `roleKeyOf(null)=='contractor'` קנוני (R1-A2, אסור null-key). critical-id ⇒ hidden מתעלם (criticalIds מוזרק, לא-import → טהור). **doc-ריק⇒identity = הוכחת אפס-הרגרסיה לכל wrapper ב-OFF.** `config_merge_test` 8 ירוקים (טבלה) · analyze 0.

### #studio-s4 — סטודיו · הדגל-הראשי `kStudioFlag` (עמוד-1 · שלב-4) — 2026-06-23
**`lib/state/studio/studio_flags.dart` (חדש):** `const kStudioFlag = bool.fromEnvironment('STUDIO')` **default-OFF** (משכפל invariant של `backend.dart:12` — flip=השינוי-היחיד, OFF=answer-equivalent) + `const kStudioFlagName='kStudio'` ל-runtime-set. אפס-צרכן עדיין. `studio_flags_test` 2 ירוקים (נועץ default-OFF) · analyze 0.

### #studio-s5 — סטודיו · הכרה ב-`kStudio` כדגל-runtime (עמוד-1 · שלב-5) — 2026-06-23
**EDIT `lib/state/feature_flags.dart`:** doc-comment-מדיניות ליד `kKbLiveMirrorFlag` — `kStudio` מוכר כדגל-runtime אך **בכוונה לא** ב-`_forcedOnFlags` (הסט נשאר כפי-שהיה) → OFF-לכולם, בילד-רגיל answer-equivalent; הנתיב היחיד = owner-staged `enable('kStudio')`. `studio_flags_test` +1 (FeatureFlagsNotifier טרי לא מכיל kStudio) = 3 ירוקים · analyze 0 · DoD-grep: kStudio∉_forcedOnFlags.

### #studio-s6 — סטודיו · `ConfigStore` + `ConfigOp` + applyOps/undo + sink + publish (עמוד-1 · שלב-6) — 2026-06-23
**`lib/state/studio/config_store.dart` (חדש):** `ConfigOp` sealed (SetText/Emoji/Hidden/Order/Style/Action — apply בונה node חדש, null=clear) · `ConfigSink` seam (Pillar-5) + `LocalPrefsSink` (`bs.studio-config.v1`, decode off-thread `compute` — R2-#8, empty⇒remove) · `ConfigStore extends StateNotifier<ConfigDoc>`: **API ציבורי מבוסס-op** `applyOps`(+undo/redo, draft-snapshots דלילים)·`resetDraftNode`·`discardDraft`·`publish`(field-merge→prune→snapshot-history-cap→clear-draft, byEmail ל-audit-#84)·`rollback`(forward-only). `editDraft`=primitive פנימי (R1-A3 — Pillar-4 קורא applyOps, לא editDraft). immutable מלא (copyWith). providers `configSinkProvider`/`configStoreProvider`. אפס-reader עדיין→inert. `config_store_test` 9 ירוקים (fake-sink · undo/redo round-trip · batch-as-one · publish/rollback/JSON) · analyze 0.
- **פאזה-A (data+store, שלבים 1–6) — הושלמה.** הבא: read-path (resolvedNodeProvider, שלב-7) + edit-mode (8).

### #studio-s8 — סטודיו · שער-הממשל edit-mode (#84) (עמוד-1 · שלב-8) — 2026-06-29
**`lib/state/studio/edit_mode.dart` (חדש):** `EditModeController extends StateNotifier<EditModeState>` (`isEditing`/`previewDraft`/`selectedId`). `enterEdit()` נדלק **רק** כששלושת התנאים יחד: (1) `studioActiveProvider` (compile `kStudioFlag` **או** runtime `kStudio`) ∧ (2) `isOwnerEmail` על המייל-האמיתי ∧ (3) הקשר-מנהל; אחרת no-op **לצמיתות** (#84) ⇒ OFF=answer-equivalent. `previewDraft` נדלק עם `isEditing` (ה-seam שש לב-7 קורא). `exitEdit`/`toggleEdit`/`select`/`revalidate`/`canEdit`.
- **תיקון-ספק (read-don't-guess, מול detail/001-015.md:154):** (א) ה-spec כתב `session.email` — אבל ל-`BoardSession` אין שדה email; המקור-האמיתי `authStateProvider.user?.email` (`auth_state.dart:77`, כמו `welcome_screen.dart:362`). (ב) ה-spec בדק `roleProvider=='manager'` בלבד — אבל מצב-מנהל-אמיתי הוא `boardAuthProvider.role==BoardRole.manager` (`loginManagerViaGoogle`, `board_auth.dart:291`); בדיקת-roleProvider-בלבד **לעולם לא תיפתח** בזרימת-הבעלים האמיתית. לכן הקשר-מנהל = **board-manager OR persona-manager**, מאחורי שומר-המייל-הבעלים (superset בטוח — לא-ניתן-לזיוף).
- **3 providers-נגזרים דקים** כ-seams ל-test+שלב-20: `studioActiveProvider`/`studioOwnerEmailProvider`/`studioInManagerContextProvider` (override ישיר בטסט — בלי fake-AuthGateway). `editModeProvider` מאזין ל-3-הקלטים ו-`revalidate()` מפיל edit-mode ברגע logout/החלפת-role/כיבוי-דגל (#84). תוספות: לוג-audit in-memory (#84) + `kEditModeAutoExitMinutes` (seam footgun).
- **gate:** `test/studio/zero_regression_test.dart` 12 ירוקים (flip רק owner+manager+active · inert לכל פרסונה/זר · reset על-שינוי-הקשר · audit) · analyze **0** (כולל package-imports נקי) · lib/state → גייט 24 (לא 42/44). הבא: `resolvedNodeProvider` (שלב-7).

### #studio-s7 — סטודיו · `resolvedNodeProvider` (read-path) (עמוד-1 · שלב-7) — 2026-06-29
*(נבנה אחרי s8 — תלוי ב-`editModeProvider`/`previewDraft`.)* **`lib/state/studio/config_store.dart` (תוספת):** `resolvedNodeProvider = Provider.autoDispose.family<CfgNode,String>` — ה-CfgNode האפקטיבי ל-id לפי פרסונת-הצופה, כולל draft-הבעלים **רק** ב-previewDraft. **R2-#1 (הליבה):** צופה אך-ורק ב-4 פרוסות per-id דרך `.select` (`published.global[id]` · `published.persona[roleKey][id]` · `draft.global[id]` · `draft.persona[roleKey][id]`) — **לא** ב-doc השלם → עריכה/פרסום של id אחר לא מבטל את ה-provider הזה. `roleKey=roleKeyOf(roleProvider)` · `includeDraft=editModeProvider.previewDraft`. `autoDispose` משחרר ids לא-נצפים (זיכרון ב-100k+).
- **`lib/state/studio/config_merge.dart` (תוספת):** `mergeNodeSlices(id, {publishedGlobal, publishedPersona, draftGlobal, draftPersona, includeDraft, criticalIds})` — אותו fold כמו `mergeNode`, אבל על פרוסות-מוכנות (ה-seam ש-resolvedNodeProvider קורא). `mergeNode` עכשיו **מאציל** ל-`mergeNodeSlices` (התנהגות זהה → 8 בדיקות `mergeNode` נשארות ירוקות).
- **doc-ריק + ללא-preview ⇒ `CfgNode.identity`** ⇒ כל wrapper יראֶה את ה-literal מילולית (שורש אפס-הרגרסיה לשלב-15). אין circular-import (config_store→edit_mode→config_merge; edit_mode לא מייבא config_store).
- **gate:** `test/studio/resolved_node_test.dart` 7 ירוקים (identity · global-לכולם · persona-לפי-roleKey-בלי-דליפה · draft-רק-ב-preview · **R2-#1 targeted-invalidation** עם positive-control) · analyze **0** בקבצים החדשים · lib/state → גייט 24. **פאזה-B החלה.** הבא: `EditHandle` (שלב-9) + עוטפני `CfgText`/`CfgVisible` (10–11).

### #studio-s9 — סטודיו · `EditHandle` (אפשר-עריכה-במקום) (עמוד-1 · שלב-9) — 2026-06-29
**`lib/widgets/studio/edit_handle.dart` (חדש):** `EditHandle.maybe(WidgetRef ref, String id, {required Widget child})` — factory סטטי שצופה **אך-ורק** ב-`editModeProvider.select((s)=>s.isEditing)`. **מחוץ ל-edit-mode ⇒ `return child` (אפס widgets נוספים)** — חוזה אפס-הרגרסיה הנושא (kStudioFlag כבוי ⇒ isEditing לעולם לא true ⇒ כל call-site הוא child גולמי). ב-edit-mode: `RepaintBoundary` + `Stack[MetaData(StudioEditTarget(id)) , Positioned.fill→IgnorePointer→DecoratedBox מתאר-brand 1.5px]` — המתאר **לא-מ-sizing** (לא משנה layout של ה-child).
- **R2-#3:** ה-tap **לא** מטופל פר-wrapper (אין GestureDetector → אין gesture-arena-storm). במקום: `MetaData(StudioEditTarget(id))` מתייג את תת-העץ, וה-StudioOverlay (שלב-13) ימפה נקודת-מגע ל-id דרך hit-test יחיד. ה-tap/popover מחווט בשלב-13.
- **gate:** `test/studio/cfg_wrappers_test.dart` 2 ירוקים (OFF=child verbatim + `MetaData` findsNothing · ON=tag StudioEditTarget('cart.cta')+outline) · analyze **0** · lib/widgets → **גייט 116 (visual_log)** + גייט 24. `visual_log`: שינוי-נראה אפס (מגודר). הבא: `CfgText` (שלב-10).

### #studio-s10 — סטודיו · `CfgText` (עוטפן-תוכן) (עמוד-1 · שלב-10) — 2026-06-29
**`lib/widgets/studio/cfg_text.dart` (חדש):** `CfgText(id, fallback, {style, textAlign, maxLines, overflow, softWrap})` — `ConsumerWidget`, drop-in ל-`Text`. `n=resolvedNodeProvider(id)`; `txt=n.text??fallback`; emoji-prepend אם `n.emoji`; `applyCfgTextStyle(context, style, n.style)`; עטוף ב-`EditHandle.maybe`. **doc-ריק/ללא-override ⇒ `Text(fallback, style: style)` מילולי** — חוזה אפס-הרגרסיה (gates 61/64).
- **`applyCfgTextStyle`:** override==null ⇒ מחזיר `callSite` **בדיוק** (identity מוכח בטסט). עם override: ממזג tokens מעל `DefaultTextStyle`+callSite — `cfgColorFromToken`/`cfgWeightFromToken`/`cfgSizeFromToken` (vocab תואם-עורך-נושא שלב-24) + `fontScale` כופל. token לא-מוכר ⇒ מתעלם (שומר base).
- **gate:** `cfg_wrappers_test` +4 (empty⇒verbatim+RTL+style-null · text-override · emoji-prepend · token-color=brand) = 6 ירוקים · analyze **0** · lib/widgets → גייט 116 (visual_log) + 24. הבא: `CfgVisible`/`CfgList`/`CfgBox`/`CfgAction` (שלב-11).

### #studio-s11 — סטודיו · CfgVisible/CfgBox/CfgList/CfgAction (עמוד-1 · שלב-11) — 2026-06-29
**4 קבצים חדשים ב-`lib/widgets/studio/`** — כולם drop-in, **ללא override ⇒ child מילולית** (אפס-רגרסיה):
- `cfg_visible.dart` — `CfgVisible(id, {child, critical})`: `hidden=!critical&&(n.hidden??false)`. לא-מוסתר⇒child · מוסתר+לא-עורך⇒`SizedBox.shrink` · מוסתר+edit⇒ghost(`Opacity .35`)+badge "מוסתר" (כדי לשחזר — pitfall a).
- `cfg_box.dart` — `CfgBox(id, {child})`: `bgToken`→`ColoredBox`, `pad`(`EdgeKey`)→`Padding` (`cfgEdgeFromKey` none/sm/md/lg → BsTokens spaces). ללא style⇒child. עטוף ב-`EditHandle`.
- `cfg_list.dart` — `CfgList({items:[CfgListItem(id,child)], builder})`: מיון **יציב** לפי `n.order` (חסר⇒index ⇒ ללא override=סדר-הצהרה). ה-`builder` מחזיק את ה-container (layout של הקורא נשמר). drag-reorder ידחה ל-write-path של ה-inspector.
- `cfg_action.dart` — `cfgAction(ref, id, fallback)→VoidCallback?`: v1 תמיד `fallback` (registry-הפעולות = Pillar-4); seam לאימוץ call-sites כבר עכשיו, fallthrough בטוח (kind לא-מוכר לא בולע tap — pitfall d).
- **gate:** `cfg_wrappers_test` 16 ירוקים (no-override⇒verbatim לכל ה-4 · ghost · resort · fallthrough) · analyze **0** · lib/widgets → 116+24. **פאזה-B — עוטפנים (9–11) הושלמו.** הבא: `ElementRegistry` (12) + `StudioOverlay` (13).

### #studio-s12 — סטודיו · ElementRegistry (חוזה-האלמנט) (עמוד-1 · שלב-12) — 2026-06-29
**`lib/state/studio/element_registry.dart` (חדש):** `ElementDescriptor` עם זהות (id/screen/area/labelHe) + **6 שדות-ממשל (R1-A1):** `kind`(ElementKind) · `editableProps`(Set<EditAxis>) · `allowedActions` · `allowedValues` · `kImmutable` · `kRoleFloor`(roleKey קנוני) + `wired`(נדלק באימוץ, שלב-14). enums `EditAxis{text,emoji,hidden,order,style,action}` · `ElementKind{text,container,list,action,theme}`. `const kElementRegistry` (2 seeds: cart.cta · home.kpi.title, wired:false) ⇒ אפס עלות-runtime.
- **fail-closed:** `findDescriptor(all, id)` ⇒ null ל-id לא-קיים (ה-inspector לא עורך · validateSafe דוחה — אין vacuous-green, R1-A1/R2-#15). `elementRegistryProvider` = built-ins ⊕ `domainElementsProvider` (seam ל-Pillar-2, ריק כברירת-מחדל). `descriptorProvider(id)` family. `kElementRegistryVersion=1`.
- **gate:** `registry_contract_test` 6 ירוקים (ids-unique · identity-non-empty · fail-closed · found · provider-merge · domain-append) · analyze **0** · lib/state → גייט 24 (לא 116/42/44). הבא: `StudioOverlay` (13) — ה-hit-test המרכזי שצורך את ה-MetaData tags + ה-registry.

### #studio-s13 — סטודיו · StudioOverlay (overlay תמיד-mounted) (עמוד-1 · שלב-13) — 2026-06-29
**`lib/widgets/studio/studio_overlay.dart` (חדש) + EDIT `lib/main.dart`:** שורה **additive** יחידה `const StudioOverlay()` ב-builder Stack ליד `ConnectionIndicator`. `StudioOverlay extends ConsumerWidget`: `!studioActive || !isEditing` ⇒ `SizedBox.shrink()` (inert · אפס pointer-area · answer-equivalent — דפוס `ConnectionIndicator`; const-OFF ⇒ tree-shake מלא). on-gate ⇒ `Positioned` באנר "✏️ מצב עריכה" + "צא" (`exitEdit`). `.select((s)=>s.isEditing)`.
- **נדחה (צעד ממוקד):** ה-hit-test המרכזי (tap על `MetaData(StudioEditTarget)` → `select(id)`) — מנגנון hit-test על ה-render-tree רגיש-לגרסה, מוזרק בנפרד כדי לא לסכן את `main.dart`. שלב-13 = ה-shell + אפס-רגרסיה.
- **gate:** `zero_regression_test` +2 (off⇒SizedBox+ללא-באנר · on⇒באנר) = 14 ירוקים · analyze **0** (ב-main.dart 6 infos קיימים-מראש בלבד) · lib/widgets+main → גייט 116 (visual_log) + 24. **Phase-B כמעט-שלם.** הבא: s12.5 (הקפאת-חוזה, test-only) → s14 (פיילוט — אימוץ ~10 ids) → s15 (סיכום zero-regression).

### #studio-s12.5 — סטודיו · הקפאת-חוזה ElementDescriptor (Phase-0) (עמוד-1) — 2026-06-29
**EDIT `element_registry.dart` + NEW `test/studio/descriptor_contract_test.dart`:** הקפאת חוזה-6-השדות **לפני** seam-freeze (שלב-30) — Pillars 2/4/5 מקרקעים את `validateSafe` עליו. תגית `⚠️ FROZEN` על `ElementDescriptor`. הטסט מאמת: (א) כל descriptor אמיתי עומד בחוזה; (ב) 6 השדות נוכחים+מטופסים (signature-freeze); (ג) **fake↔real parity** — `findDescriptor` fail-closed זהה על registry מזויף ואמיתי (fake לא יכול self-certify, R2-#15).
- **gate:** `descriptor_contract_test` 3 ירוקים · analyze **0** · test-only (אין production) · lib/state → גייט 24. הבא: **s14 — אימוץ פיילוט (~10 ids: Text→CfgText במסך-המנהל + שורות registry).**

### #studio-s14 — סטודיו · אימוץ פיילוט (5 כותרות KPI בקוקפיט) (עמוד-1 · שלב-14) — 2026-06-29
**EDIT `manager_dashboard_screen.dart` + `element_registry.dart`:** האימוץ-הראשון — 5 כותרות ה-KPI בלוח-הבקרה (`_MetricGrid`) עברו `Text(label,…)`→`CfgText(cfgId, label,…)` (style/maxLines/overflow **זהים בדיוק**; `_MetricTile` קיבל `required cfgId`). ids: `manager.cockpit.kpi.{openOrders,products,accessories,available,stores}`. 5 descriptors (wired:true) נוספו ל-`kElementRegistry` (במקום seed 'home.kpi.title'; 'cart.cta' נשאר forward-target).
- **OFF = answer-equivalent + golden** (doc-ריק ⇒ `n.text??fallback`=label, אותו style) — revert = `CfgText→Text` טהור. **זהו ה-end-to-end הראשון: אלמנט אמיתי במסך אמיתי הפך config-driven** (עדיין לא גלוי לבעלים עד המפקח, s16–19).
- **gate:** `registry_contract_test` +1 (pilot⊆registry) = 7 · `descriptor_contract` 3 · analyze **0** (5 infos קיימים-מראש ב-mega-file בלבד) · lib/screens → גייט 116 (visual_log diff ריק) + 24. הבא: s15 (סיכום zero-regression) → s16 (קונכיית-הסטודיו).

### #studio-s15 — סטודיו · סיכום zero-regression (Pillar-1 gate) (עמוד-1 · שלב-15) — 2026-06-29
**EDIT `test/studio/zero_regression_test.dart`:** הוכחת אפס-הרגרסיה הקנונית של Pillar-1 — לולאה **פרמטרית** על כל roleKey ([null/contractor/store/courier/worker/manager]): doc-ריק + Studio כבוי ⇒ `resolvedNodeProvider('any.id')` == `CfgNode.identity` ⇒ כל wrapper מרנדר fallback מילולי. מצטרף ל-overlay==SizedBox (s13) + cannot-flip-#84 (s8) באותו קובץ.
- **`zero_regression_test` = ה-gate של Pillar-1** (frozen-seam): כל תוספת ב-Pillars 2–5 חייבת לעבור אותו. 20 ירוקים · analyze 0 · test-only. **✅ Phase A+B (שלבים 1–15) הושלמו.** הבא: **Phase C — s16: קונכיית-הסטודיו (`studio_screen` shell — IndexedStack panes + chrome RTL, גדור kStudioFlag).**

### #studio-s16 — סטודיו · שלד קונכיית-הסטודיו (Phase C) (עמוד-2 · שלב-16) — 2026-06-29
**`lib/screens/studio/studio_screen.dart` (חדש):** `StudioScreen` (ConsumerStatefulWidget) — RTL + `Scaffold(bgLight)` + `AppBar(cardLight, elevation:0, no-leading)` + 4 panes ב-`IndexedStack` (עץ/מפקח/עיצוב/גרסאות — placeholders) + ChoiceChips למעבר-pane. `static route(WidgetRef)→Route?` **גדור ב-`studioActiveProvider`** (null כש-OFF ⇒ אין deep-link). chrome מועתק מ-manager_dashboard.
- **בלתי-נגיש עד s20** (אין כניסה מחווטת) ⇒ אפס-התנהגות. panes אמיתיים: s18 (tree) · s19 (inspector) · s21 (history) · s24 (theme).
- **gate:** `studio_screen_test` 2 ירוקים (RTL+AppBar לבן · route-guard) · analyze **0** · lib/screens → גייט 116 (visual_log, שינוי-נראה אפס) + 24. **Phase C החלה.** הבא: s17 (top-bar: badge-טיוטה · פרסם לכולם · בטל · toggle-עריכה).

### #studio-s17 — סטודיו · top-bar (פרסם-לכולם / בטל / מצב-עריכה) (עמוד-2 · שלב-17) — 2026-06-29
**`lib/screens/studio/studio_top_bar.dart` (חדש) + EDIT `studio_screen.dart`:** `StudioTopBar` (ConsumerWidget) — badge "טיוטה · N" (`draftNodeCount` via `.select`) · מתג "מצב עריכה" (`editModeProvider.toggleEdit`) · "בטל טיוטה" · "פרסם לכולם" (כבוי כש-N=0).
- **publish flow (R2-#13):** bottom-sheet אישור-היקף — "ישפיע על כל המשתמשים — N שינויים" + note inline (R9) + dropdown view-as-persona (מספר-שינויים-לפי-roleKey: `draft.global + draft.persona[roleKey]`) + פרסם/ביטול → `publish(note, byEmail=studioOwnerEmailProvider, nowMs)`. discard → אישור → `discardDraft`. `_publishing` guard מונע double-publish. הכל דרך `applyOps`/`publish` (לא store ישיר).
- **gate:** `studio_screen_test` +1 (publish-disabled-empty → enabled-with-draft + badge) = 3 ירוקים · analyze **0** · lib/screens → גייט 116 (visual_log, עדיין לא-נגיש) + 24. הבא: s18 (tree pane) → s19 (inspector) → **s20 (כניסת-מנהל — הופך הכל נגיש!).**

### #studio-audit-r1 — נחיל-ביקורת היסוד (s1–s17, 8 עדשות) + תיקונים — 2026-06-29
נחיל אדוורסרי, 8 auditors (עדשה לכל): zero-regression · #84 · store-races · merge · RTL/a11y · perf · JSON · idioms. **הארכיטקטורה החזיקה** — identity-anchor un-spoofable · merge math · R2-#1/#3 · JSON-tolerance · idioms=0-defects. ממצאים אמיתיים מתוקנים (גדורים, מבוקרי-suite):
- **A (#84 defence, HIGH — לפני s20):** `studioCanEditProvider` חדש (active∧owner∧manager, reactive) = **מקור-אמת יחיד** לשער. `publish`/`discard`/`route()` עכשיו גדורים בו (לא רק draft-count/active) ⇒ שער-#84 לא ניתן לאיבוד מ-control ששוכח לבדוק. `EditModeController._gateOpen`+listener מאוחדים סביבו (listener יחיד במקום 3). + תיקון `EdgeInsetsDirectional` ב-`_PublishSheet`. **gate:** studio suite 100 ירוקים · analyze 0.
- **B (store/JSON hardening) ✅:** `_clampScale` `is`-guard (fontScale לא-מספרי → null, לא מפיל את כל ה-doc) · `publish` empty-draft guard + `_nextVersionId` מונוטוני (id ייחודי גם ב-same-ms, גם ל-rollback) · `_load` pristine-guard (לא דורס edit באמצע load) · applyOps/editDraft no-op short-circuit. **gate:** config_node_test +1 · config_store_test +3 = 28 ירוקים · analyze (infos קיימים-מראש בלבד בקבצים).
- **C (perf/scale) — נדחה ל-Phase-4 (scale+server):** debounce + off-thread `_save`. **החלטה מודעת:** ב-doc הזעיר הנוכחי אין בעיית-perf, ו-`compute` off-thread היה **מאט** save קטן (isolate-overhead > encode); שייך ל-server-sink של Pillar-5 ושם הוא מדיד. (auditor: "MED עכשיו, HIGH at-scale".)
- **deferred (מתועד, לא סיכון חי):** criticalIds→s26 · reactive canUndo→שלב-undo-UI · hashCode-note · agent-1 #1 (published-survives-flag = product-model, end-users מרנדרים published בלי הדגל — תיקון תיעוד בלבד) · **C/perf→Phase-4.** **✅ נחיל-ביקורת r1 הושלם (A+B מתוקנים-ומבוקרים, C/deferred מתועד).**

### #studio-s18 — סטודיו · Pane A: עץ-הרכיבים (registry-driven, virtualised) (עמוד-2 · שלב-18) — 2026-06-29
**`lib/state/studio/studio_nav.dart` (חדש):** `studioScopePersonaProvider` (StateProvider<String>='contractor') + `studioSelectedIdProvider` (StateProvider<String?>) + `kStudioPersonas`/`kStudioPersonaHe`. **`lib/screens/studio/panes/tree_pane.dart` (חדש):** `TreePane` — עץ screen→area→element מ-`elementRegistryProvider`, **וירטואלי** (`ListView.builder` על flattened-rows · sealed `_Row` · לא nested ExpansionTile — §11 scale). חיפוש (labelHe/id) + dropdown persona (→scope) + tap-leaf→`studioSelectedIdProvider`; badge "טרם חובר" ל-`!wired`. read-only. מחובר ל-pane 0 ב-studio_screen.
- **gate:** `tree_pane_test` 4 ירוקים (lists · search · tap-selects · persona-scope) · `studio_screen_test` 4 (לא נשבר) · analyze **0** · lib/screens → 116+24. הבא: s19 (inspector — עורך את הנבחר דרך applyOps + live preview) → **s20 (כניסת-מנהל — הופך הכל נגיש!).**

### #studio-s19 — סטודיו · Pane B: המפקח (עריכה→draft) (עמוד-2 · שלב-19) — 2026-06-29
**`lib/screens/studio/panes/inspector_pane.dart` (חדש):** `InspectorPane` (ConsumerStatefulWidget) — עורך את `studioSelectedIdProvider`→`descriptorProvider(id)`. ללא בחירה→placeholder · id-לא-מוכר→**fail-closed**. לפי `editableProps`: **תוכן** (TextField טקסט+אמוג'י, controller מקומי seeded פעם-אחת/בחירה — R2-#2 decouple) · **נראות** (SwitchListTile, נעול+הסבר אם `kImmutable`). כל עריכה → `applyOps([Set*(id,…)])` ל-**draft global** (v1 "לכולם"; per-persona=seam מאוחר), **לא חי עד publish**. תצוגה-חיה (draft⊕published slices) + 'אפס רכיב'→`resetDraftNode`. מחובר pane 1.
- **gate:** `inspector_pane_test` 4 ירוקים (no-selection · fail-closed · text→draft · reset-clears) · analyze **0** · lib/screens → 116+24. **הבא: s20 — שורת "🎨 סטודיו" אצל המנהל → `StudioScreen.route` (owner-gated). ⭐ זה השלב שהופך הכל נגיש: הבעלים פותח · בוחר · מקליד · מפרסם — ורואה חי.**

### #studio-s20 — סטודיו · הכניסה ⭐ (שורת "🎨 סטודיו" אצל המנהל) (עמוד-2 · שלב-20) — 2026-06-29
**`edit_mode.dart`:** `studioOwnerManagerProvider` חדש (owner∧manager, **בלי** הדגל) + רפקטור `studioCanEditProvider = studioActive && studioOwnerManager`. **`lib/screens/studio/studio_entry.dart` (חדש):** `StudioEntryCard` — `!studioOwnerManager ⇒ SizedBox.shrink` (אפס-שינוי לכולם); לבעלים-מנהל: כרטיס "🎨 סטודיו (בטא)" → tap מפעיל `kStudio` (`enable`, no-rebuild) + `StudioScreen.route` (owner-gated) → push. **EDIT `manager_dashboard_screen.dart`:** import + `const StudioEntryCard()` בקוקפיט (`_DashboardTab`, אחרי הקו-פיילוט).
- **⭐ הסטודיו נגיש end-to-end לבעלים:** פתח → עץ (s18) → בחר → מפקח (s19) → הקלד → top-bar "פרסם לכולם" (s17) → חי. **אפס-שינוי לכל non-owner** (gated, SizedBox.shrink).
- **gate:** `studio_entry_test` 3 ירוקים (hidden/visible/tap-opens) · **כל חבילת studio 115 ירוקים** (refactor של הגייט לא שבר) · analyze **0** (5 infos קיימים-מראש ב-mega-file) · lib/screens → 116+24. הבא: s21 (היסטוריית גרסאות) → s22 (סיום Phase C: שלד-הסטודיו).

### #studio-s21 — סטודיו · Pane D: היסטוריית-גרסאות (עמוד-2 · שלב-21) — 2026-06-29
**`lib/screens/studio/panes/history_pane.dart` (חדש):** `HistoryPane` — `configStoreProvider.select((d)=>d.history)`, רשימת `ConfigVersion` חדש-לישן (note · byEmail · זמן מ-`_fmt`); "שחזר" → AlertDialog אישור → `rollback(v.id, byEmail, nowMs)` (**forward-only** — re-publish snapshot כגרסה חדשה, ההיסטוריה לא נהרסת). ריק → placeholder. מחובר pane 3 (גרסאות).
- **gate:** `history_pane_test` 3 ירוקים (empty-placeholder · shows-version-note · restore-forward+history-grows) · `studio_screen_test` 4 (לא נשבר) · analyze **0** · lib/screens → 116+24. **Phase C: 3/4 panes חיים** (עץ/מפקח/גרסאות; עיצוב→s24 placeholder). הבא: s22 (סיום Phase C — gate-118 על pilot-ids + finalize knowledge).

### #studio-s22 — סטודיו · gate-118 + סיום Phase C (עמוד-2 · שלב-22) — 2026-06-29
**NEW `test/studio/gate_118_test.dart`:** gate-118 (GATE_REGISTRY) — סורק `lib/` (dart:io) לכל id של הסטודיו ב-UI (`cfgId: '…'` + `Cfg*('…'`) ומאמת ⊆ `kElementRegistry` ("אין id-יתום"; fail-closed גם בזמן-טסט). non-vacuous (חייב למצוא ≥ 5 ה-pilot). **GATE_REGISTRY:118 מיושם.**
- **✅ Phase C (16–22) הושלם — שלד-הסטודיו חי:** shell+chrome (16) · top-bar publish/discard/toggle (17) · tree (18) · inspector (19) · owner-entry (20) · history (21) · gate-118 (22). 4 panes: tree/inspector/history live · theme→s24. **הסטודיו נגיש end-to-end לבעלים** (פתח→בחר→הקלד→פרסם→חי→שחזר). הבא: **Phase D — s23 (CfgTheme + ThemeExtension) → s24 (Pane C עורך ערכת-נושא live+AA) → s25-28 (find&replace · critical+validator · reset-scopes · safety-bundle).**

### #studio-s23 — סטודיו · CfgTheme (override-עיצוב + ThemeExtension glue) (עמוד-2 · שלב-23) — 2026-06-29
**NEW `lib/theme/config_theme.dart`:** `CfgTheme extends ThemeExtension<CfgTheme>` (brand/surface/ink/radius/fontScale) + copyWith/lerp + `CfgTheme.fallback` (**defaults = BsTokens בדיוק** ⇒ אפס-רגרסיה). accessors `cfgBrand/cfgSurface/cfgInk/cfgRadius/cfgFontScale(context)` עם fallback ל-BsTokens. **EDIT `lib/theme/app_theme.dart`:** הוספת `CfgTheme.fallback` ל-`extensions:` (ליד BsSemanticColors). inert: אין override + אין צרכן ⇒ פיקסל-זהה.
- **הערה (סטייה מהספק):** הונח ב-`lib/theme/` (לא state/studio) — אובייקט-theme טהור, נמנע theme→state import. החיבור config→CfgTheme + העורך החי = s24.
- **gate:** `config_theme_test` 5 ירוקים (defaults=BsTokens · copyWith · lerp · live-theme-exposes · accessor-fallback) · `a11y_contrast_theme_test` עובר (לא-נשבר) · analyze **0** · lib/theme → גייט 24. הבא: s24 (Pane C עורך ערכת-נושא — live whole-app + AA-contrast block; כאן config→CfgTheme מחווט).

### #studio-s24a — סטודיו · חיווט config→theme (Phase D) (עמוד-2 · שלב-24a) — 2026-06-29
**CfgTheme JSON** (toJson ARGB / fromJson סובלני) · **`configThemeProvider`** (Provider<CfgTheme>: `draft.structure['theme']` ⊕ published → CfgTheme, fallback=defaults) · **store `setThemeDraft`** (כותב `draft.structure['theme']`, undoable) · **`_promote` ממזג structure** (theme מתקדם ב-publish) · **`draftNodeCount += structure.length`** (theme-draft נספר ⇒ publish enabled + badge) · **`AppTheme.light/dark({cfg})`** (seed/primary/FAB = `cfg.brand`) · **main.dart מזריק `configThemeProvider`** (`ref.watch` ב-MaterialApp).
- **doc-ריק ⇒ cfg=fallback=BsTokens ⇒ פיקסל-זהה** (אפס-רגרסיה; `a11y_contrast_theme_test` עובר). override brand ⇒ **כל-האפליקציה משתקפת חי**.
- **gate:** `config_theme_wiring_test` 4 (empty⇒fallback · setThemeDraft⇒live · theme-publishable+promotes · AppTheme.primary=cfg.brand) + `config_theme_test` 6 (+JSON round-trip) · **כל חבילת studio + a11y ירוקים** · analyze **0** (infos קיימים-מראש) · lib/theme+state+main → גייט 24. הבא: s24b (Pane C עורך — color/radius/fontScale + live + AA-block).

### #studio-s24b — סטודיו · Pane C: עורך ערכת-נושא (עמוד-2 · שלב-24b) — 2026-06-29
**NEW `lib/screens/studio/panes/theme_pane.dart`:** `ThemePane` ConsumerWidget קורא `configThemeProvider` (single-source) → **בורר-צבע-מותג** (Wrap של 8 swatches מוגדרים-מראש, ללא dep חיצוני; הראשון = BsTokens.brand) · **Slider radius 0–28** · **Slider fontScale 0.8–1.6** · **תצוגה-חיה** (כרטיס+כותרת+גוף+כפתור-מותג, קורא cfg ישירות) · **כפתור אפס** (`setThemeDraft(CfgTheme.fallback)`). כל שינוי → `setThemeDraft` ל-draft (**לא חי עד "פרסם לכולם"**). **בדיקת-AA:** `_contrastVsWhite(brand)=1.05/(L+0.05)`; <4.5 ⇒ אזהרה (מיידעת, לא חוסמת publish). **EDIT `studio_screen.dart`:** pane 2 placeholder → `ThemePane()` (הוסר `_PanePlaceholder`).
- **שינוי-נראה: אפס** (בתוך הסטודיו המגודר; non-owner לא מגיע). העורך כותב draft בלבד.
- **gate:** `theme_pane_test` 4 ירוקים (2-sliders+swatches · tap⇒draft-live+publishable · warning toggles sub-AA↔high-contrast · reset⇒fallback) · `studio_screen_test` (לא נשבר) · `zero_regression` ירוק · analyze **0**. lib/screens → גייט 24+116. הבא: s25 (find&replace) → s26 (critical-ids+validator) → s27 (reset-scopes) → s28 (safety-bundle). נחיל round-2 ב-s30.

### #studio-s25 — סטודיו · מצא-והחלף גלובלי על תוכן → טיוטה (עמוד-2 · שלב-25) — 2026-06-29
**NEW `lib/screens/studio/panes/find_replace_pane.dart`:** `FindReplacePane` ConsumerStatefulWidget — חיפוש-substring registry-driven על **שכבת-ה-overrides** (`draft.global[id].text ?? published.global[id].text` לכל id עם `editableProps∋text`; **לא** labelHe = שם-הרכיב). כל hit: checkbox (ברירת-מחדל נבחר, מעקב `_deselected`) + preview `labelHe` + "לפני ← אחרי". **"החלף בנבחרים (N)"** → `applyOps(List<ConfigOp>)` **batch יחיד = undo יחיד** (R1-A3 · R2-#18), ל-**draft בלבד** (לעולם לא publish). `kImmutable` = קריאה-בלבד (checkbox נעול, מחוץ ל-batch). אזהרת >50 hits. SnackBar-אישור. **EDIT `studio_screen.dart`:** segment 5 חדש ('🔎 מצא והחלף') + ילד-5 ב-IndexedStack `FindReplacePane()`.
- **שינוי-נראה: אפס** (בתוך הסטודיו המגודר; non-owner לא מגיע). published-לא-נגע מאומת.
- **gate:** `find_replace_test` 3 ירוקים (preview-by-labelHe + replace→draft-only/published-untouched · single-undo-frame · kImmutable read-only/excluded) · `studio_screen_test` (5 panes, לא נשבר) · `zero_regression` ירוק · analyze **0**. lib/screens → גייט 24+116. הבא: s26 (critical-ids + publish-validator — חבר criticalIds ל-resolvedNodeProvider) → s27 (reset-3-scopes) → s28 (safety-bundle) = סיום Phase D. נחיל round-2 ב-s30.

### #studio-s26 — סטודיו · critical-id set + publish-validator (Phase D) (עמוד-2 · שלב-26) — 2026-06-29
**ההגנה התלת-שכבתית על ניווט/auth (§8.1) — חוברה (זה ה-item שנדחה מסבב-1):**
- **EDIT `element_registry.dart`:** +5 seeds `kImmutable:true` (`auth.login.cta`/`auth.logout`/`nav.bottombar`/`manager.entry`/`studio.exit`, wired:false — מוצהרים-מוגנים גם לפני אימוץ-widget) · **NEW `criticalIdsProvider`** (`Set<String>` = כל id עם `kImmutable` ב-`elementRegistryProvider`) — **מקור-יחיד** ל-merge+validator ⇒ אפס-drift (תוספת-א).
- **EDIT `config_merge.dart` (model):** הבלוק-הקריטי מנקה כעת גם `action` (לא רק `hidden`) — reroute על critical מתעלם ב-resolve (תוספת-ב).
- **EDIT `config_store.dart`:** `resolvedNodeProvider` מעביר `criticalIds: ref.watch(criticalIdsProvider)` (הפעלת הגנת-המודל בפרודקשן) · **publish-validator:** `publish` קיבל `Set<String> criticalIds`, מחזיר `bool`, ו-`_sanitizeCritical` מפשיט hide/reroute של critical **לפני** promote (published נשאר נקי; חוקי-נשאר-חוקי) · **`criticalViolations(criticalIds)`** מדווח (ל-אזהרה-inline עתידית).
- **ללא wiring-production** (model+validator בלבד, לפי הספק נק' 8) — ה-top-bar עדיין קורא `publish()` ללא criticalIds; ה-sanitize ייקרא מ-UI ב-s28.
- **gate:** `safety_test` 4 ירוקים (criticalIds=seeds · publish-strips-hide-keeps-legal · publish=false-כשרק-critical · resolve-מנטרל-hide-בpublished) + `config_merge_test` (+action-clear) · **כל חבילת studio 141 ירוקים** (registry→11, publish→bool — אף בדיקה לא נשברה) · analyze **0** (infos קיימים-מראש ב-config_store). lib/state → גייט 24 (לא 116). הבא: s27 (reset-3-scopes + behavior-whitelist) → s28 (safety-bundle) = סיום Phase D. נחיל round-2 ב-s30.

### #studio-s27 — סטודיו · reset 3-scopes + behavior-whitelist + write-validator (עמוד-2 · שלב-27) — 2026-06-29
**EDIT `config_store.dart`:**
- **write-validator** — `cfgOpError(op, {criticalIds, allowedKinds})` (pure, מחזיר שגיאת-R9-עברית או null): תקרת-אורך `kCfgMaxTextLen=80` · דחיית תווי-בידי/LTR (`_hasBidiControl`: LRM/RLM, LRE…RLO, LRI…PDI — gate 65) · hide-על-critical · action-kind לא-מורשה. **`applyOps`** מסנן ops לא-תקינים (criticalIds default `{}` ⇒ s26-flow נשמר; אורך/בידי/kind תמיד נאכפים).
- **behavior-whitelist** — `kCfgAllowedActionKinds={'noop','navigate'}` + `cfgActionRegistryProvider`. (cfg_action כבר נופל-בחזרה ל-onTap המקורי לכל kind ⇒ override inert; הוולידטור חוסם kind זר כבר ב-write.)
- **reset 3-scopes** — רכיב (`resetDraftNode` קיים) · טיוטה (`discardDraft` קיים) · **הכל (`resetAll` NEW)** = publish של layer-ריק כגרסה-חדשה ⇒ **הפיך דרך rollback** (ההיסטוריה לא נהרסת).
- **deferred:** legacy-emoji-whitelist המלא (gate 64) — כרגע רק length-guard · per-target route-whitelist ל-`navigate` (אין route-registry עדיין; ה-kind-whitelist + fallthrough כבר חוסמים ביצוע) · אין UI-wiring (R9-inline ב-inspector/find-replace = s28).
- **gate:** `safety_test` 9 ירוקים (s26 4 + s27 5: length-cap · bidi-refused · unauthorized-kind · whitelist=={noop,navigate} · resetAll-recoverable) · **כל חבילת studio 146 ירוקים** · analyze **0** (אין warnings; infos קיימים-מראש ב-config_store). lib/state → גייט 24. הבא: **s28 (safety-bundle) = סיום Phase D** → נחיל round-2 ב-s30.

### #studio-s28 — סטודיו · safety test-suite (סיום Phase D) (עמוד-2 · שלב-28) — 2026-06-29
**בדיקות-בלבד (אין שינוי lib/ · אין production-wiring — לפי הספק).** `safety_test.dart` הורחב לחוזה-הבטיחות המאוחד (26+27+28):
- **style-tokens חסומים-ל-BsTokens:** `cfgColorFromToken`/`cfgWeightFromToken`/`cfgSizeFromToken` — token מוכר ⇒ ערך-BsTokens; token שרירותי (`#ff0000`/`rgb()`/`javascript:`/`''`/`BRAND`) ⇒ `null` (מתעלם). **חסום-מעצם-הבנייה:** SetStyle לא-יכול-להזריק צבע/גודל/משקל שרירותי — רק BsTokens או no-op (מכסה את וקטור ה-find-replace/AI/Pillar-2).
- **theme-קריא:** ניגודיות `CfgTheme.fallback.ink` על `surface` ≥ 4.5 (AA). (brand-על-לבן ~2.6 < 4.5 בכוונה — ה-theme-pane מזהיר; הגוף תמיד-קריא.)
- **deferred:** golden/pixel-test (תוספת-ב) — שביר ב-headless (fonts); אפס-רגרסיה כבר מוכח ב-`config_theme_test` (defaults==BsTokens) + `config_theme_wiring_test` (primary==brand) · safety-contract ב-`knowledge_protocol_test` (תוספת-א) — דילוג למניעת-coupling · דחיית style-token לא-מוכר ב-write — לא-נדרש (resolve כבר inert=בטוח; היה כופה layering state→widgets).
- **gate:** `safety_test` 13 ירוקים (9 + 4: color/weight/size-bounded + ink-on-surface-AA) · `a11y_contrast_theme_test` עדיין-עובר (5) · **כל חבילת studio 150 ירוקים** · analyze **0**. **🎉 Phase C+D הושלמו** (s16–28). הבא: s29-30 (Phase E — content-adoption + finalize/seam-freeze) + **נחיל-ביקורת round-2** (מכסה C+D). דחוף רק על 'תדחוף'.

### #studio-round2 — נחיל-ביקורת round-2 (גבול Phase C+D) + תיקונים — 2026-06-29
**8 auditor-agents במקביל (lens אחד כל אחד) על כל משטח C+D.** verdict: **אין bypass חי · אין רגרסיה · #84 אטום · persistence/merge/contrast תקינים.** הפערים = defence-in-depth + correctness + a11y. תיקונים ב-batches:
- **r2-fix-1 (lib/state + lib/theme — store/theme hardening):**
  - `resetDraftNode` קיבל no-op guard (היה דוחף undo-פנטום + מוחק redo + notify מיותר על רכיב-pristine — כפתור "אפס רכיב" תמיד-פעיל) [auditor-store M3].
  - `applyOps` מחזיר כעת `int` = מס' ה-ops שבאמת שינו את הטיוטה (validated ∧ לא no-op) — כדי ש-find-replace ידווח ספירה כנה במקום `ops.length` (ops שנדחו/no-op לא נספרים) [auditor-find-replace H3 · auditor-store H2].
  - `CfgTheme` clamp ל-`radius` (fromJson 0–64 + copyWith) ו-`fontScale` (copyWith 0.8–1.6) — radius היה לא-חסום (1e9/שלילי משחית BorderRadius כלל-אפליקציה דרך doc מושחת/Pillar-5) [auditor-safety L1 · auditor-theme].
  - **gate:** `safety_test` 16 (+3) · config_store/config_theme/find_replace לא נשברו · analyze 0. lib/state+theme → גייט 24.
- **r2-fix-2 ✅ (panes):** `studio_top_bar._doPublish` מעביר `criticalIds: ref.read(criticalIdsProvider)` (sanitize רץ בפרודקשן — published נשאר נקי) [M1] · find-replace `_apply` pre-check `cfgOpError` (מדלג נדחים) + מדווח `applied` count כנה + "(N נדחו)" + `Semantics('מ־…ל־…')`+`ExcludeSemantics` לשורת ה-hit [H3/M6] · theme_pane sliders `semanticFormatterCallback` עברי + מספרי-ניגודיות LTR-isolate (`⁦…⁩` escapes) [M5/L2] · studio_screen ChoiceChips `tooltip: .$3` [M4]. **gate:** `find_replace_test` 4 (+over-length-dropped) · `theme_pane`/`studio_screen` לא נשברו · analyze 0. lib/screens → גייט 24+116.
- **r2-fix-3 ✅ (theme apply-side — fontScale):** NEW `combinedTextScale(inApp, os, ownerFontScale)` ב-config_theme.dart (clamp 0.85–1.35; ×1.0 = identity ⇒ אפס-רגרסיה) · main.dart מקפל `cfgTheme.fontScale` ל-MediaQuery scaler. **ה-slider של גודל-גופן עכשיו משפיע חי על כל האפליקציה** [auditor-theme HIGH]. **gate:** `config_theme_test` 11 (+combinedTextScale: identity·1.2>1·1.6→1.35·0.8→0.85) · analyze 0. lib/main+theme → גייט 24.
  - **DEFERRED (נימוק):** **radius live** — אין `cardTheme` (כרטיסים = literals פר-widget) → חיווט דרך ThemeData יחמיץ Container-cards + יחזיר Material-Card מ-12→20. צריך **אימוץ call-site ב-Phase E** (כל card יקרא `cfgRadius(context)`). ה-radius-slider נשאר preview-only עד אז. **ink live** — `cfg.ink` default (inkLight 0xFF1A1A1A) ≠ טקסט-בהיר נוכחי (black87) → היה משנה מראה-ברירת-מחדל; גם לא חשוף בעורך. **surface live** — בטוח (default=white=נוכחי) אך לא חשוף בעורך.
- **DEFERRED (מתועד):** "ניקוי published-override" ברמת-רכיב (צריך tombstone-model — מעבר ל-ops/merge/promote/json; revert היום דרך rollback/resetAll) · `criticalViolations` wiring ל-publish-sheet (אזהרת-בעלים inline) · surface/ink live (לא חשופים בעורך) · auto-exit Timer (#84 כבר נופל על שינוי-הקשר).

### #studio-s29 — סטודיו · Phase E: אימוץ-תוכן section-by-section (עמוד-2 · שלב-29) — 2026-06-29
**גלגול-adoption (`Text('ליטרל')`→`CfgText`) על מסכים-בעלי-ערך, batch נפרד לכל section; הליטרל נשאר fallback ⇒ OFF=answer-equivalent. היקף-הציר ~532 ליטרלים סטטיים (R1-B6) — עבודה מתמשכת רב-commits.**
- **batch-1 (קוקפיט · copilot hero · תוכן):** `manager_dashboard_screen.dart` — `const Text('שאל את העסק שלך')` → `const CfgText('manager.cockpit.copilot.title', …)` (const נשמר). +שורת registry (append-only, wired, לא-kImmutable). רק `Text('ליטרל')` סטטי; conditional/interpolated/`Text.rich` = out-of-v1.
- **batch-2 (קוקפיט · copilot hero · עיצוב):** 2× `BorderRadius.circular(BsTokens.radiusCard)` בכרטיס `_CopilotHero` → `cfgRadius(context)` (non-const, context זמין). default=radiusCard=20 ⇒ אפס-רגרסיה; override-בעלים ⇒ פינות חיות. **מתחיל להפעיל את ה-radius-slider** (deferred מ-r2-fix-3). ללא registry (theme גלובלי). gate: `config_theme_test` 12 (+cfgRadius override/fallback) · `zero_regression` 16 · analyze 0.
- **batch-3 (כל קוקפיט-המנהל · עיצוב):** replace_all של 14 אתרי-radius שנותרו ב-`manager_dashboard_screen.dart` → `cfgRadius(context)` (16 בסה"כ בקובץ). **כל כרטיסי לוח-המנהל מגיבים ל-radius-slider חי.** אומת ע"י `flutter analyze` נקי (תופס const/missing-context). `Radius.circular` ב-2 const-RoundedRectangleBorder (גליונות-תחתית) נשארו במכוון. **ה-radius-slider עכשיו פעיל-מהותית במסך-המנהל** (סוגר את רוב ה-deferred של r2-fix-3 ל-radius). gate: `zero_regression`/`config_theme`/`gate_118`/`a11y` ירוקים · analyze 0.
- **batch-4 (לוח-ספק · עיצוב):** replace_all של 24 אתרי-radius ב-`store_dashboard_screen.dart` → `cfgRadius(context)` (+import). אומת analyze נקי. **כל כרטיסי לוח-הספק מגיבים ל-radius-slider.** gate: analyze 0 · config_theme/a11y ירוקים.
- **batch-5 (4 מסכים · עיצוב):** cfgRadius adoption ב-`finance_hub_sheets`(13)·`worker_app_screen`(11)·`smart_home_screen`(11)·`rewards_hub_screen`(11) = **46 אתרים, commit אחד**. כל אחד import+replace_all, אומת analyze נקי. **radius-slider פעיל כעת על 6 מסכים** (מנהל·ספק·פיננסים·עובד·בית-חכם·מועדון). gate: analyze 0 · config_theme/a11y ירוקים.
- **batch-6 (5 מסכים · עיצוב):** cfgRadius ב-`tasks`(8)·`profile`(9)·`smart_project`(6)·`projects`(6)·`courier_dashboard`(7) = 36 אתרים. **לקח:** 2 אתרים ב-helpers חסרי-context (`_kvTile`/`_logDay`) — analyze תפס, הושארו ב-radiusCard (יאומצו עם context-threading). +הוסר import מת. **11 מסכים מאומצים-radius.**
- **batch-7 (5 מסכים · עיצוב):** cfgRadius ב-`store_profile`(6)·`departments`(6)·`worker_attendance`(5)·`courier_profile`(5)·`ai_hub`(5) = 27 אתרים. `courier_portal_tab`+`persona_portal` הוחזרו (3 אתרים ב-helpers חסרי-context — נדחים). **16 מסכים מאומצים-radius.** lib/widgets = רק 2 אתרים (signature_pad) — radius כיסה את המשטח העיקרי.
- **batch-8 (קטלוג · תוכן — ציר-CfgText, לב s29):** 5 כותרות-סקשן בעמוד פרטי-המוצר ב-`catalog_screen.dart` → CfgText (`catalog.detail.*`) + 5 registry rows. **פנייה מ-radius לציר-התוכן** (החשוב לבעלים). catalog mega-file (~7K שורות) — section-by-section. רק static `Text('ליטרל')`. gate: `gate_118` (ids⊆registry) · `registry_contract`/`zero_regression` · analyze 0.
- **batch-9 (קטלוג · תוכן):** עוד 5 ליטרלים → CfgText (`catalog.card.productBadge`·`catalog.templates.label`·`catalog.detail.brandGuide`·`catalog.detail.recentlyViewed`·`catalog.search.clearAll`) + 5 registry rows. **10 תוויות-קטלוג ניתנות-לעריכה.** gate: gate_118/registry/zero_regression · analyze 0.
- **batch-10 (קטלוג · כפתורי-פעולה):** 4 ליטרלים עם emoji-לגאסי → CfgText (`catalog.detail.dataHeader`·`catalog.action.{buildBom/addToProject/saveVersion}`) + 4 registry rows. **14 תוויות-קטלוג ניתנות-לעריכה.** emoji-לגאסי (אין emoji חדש → gate-64).
- **batch-11 (קטלוג · כפתורי-צ'יפ):** 3 כפתורים → CfgText (`catalog.action.{proposal/draft/howToBridge}`) + 3 registry rows. **17 תוויות-קטלוג — אימוץ-טקסט-סטטי בקטלוג הושלם מהותית** (הנותר = interpolated/Text.rich, out-of-v1). gate: gate_118/zero_regression · analyze 0.
- **סטטוס s29 (אימוץ):** **radius** = 16 מסכים (~140 אתרים) · **text** = 17 תוויות-קטלוג (המסך הלקוחי הראשי). זו כיסוי-partial מייצג (s29 = ongoing/partial לפי הספק). **נקודת-החלטה:** המשך אימוץ-sparse במסכים נוספים · radius-tail (context-threading) · או התקדמות ל-s30 (finalize/freeze Pillar-1). 45 commits מקומיים, 0 נדחפו.
- **שיטה (radius adoption per-screen):** הוסף `import config_theme show cfgRadius` → `replace_all 'BorderRadius.circular(BsTokens.radiusCard)'→'…(cfgRadius(context))'` → `flutter analyze` (תופס מיידית כל const/missing-context — נקי=כל-האתרים-חוקיים) → test → commit. מטרות-עשירות נותרו: finance_hub_sheets(13)·worker_app(11)·smart_home(11)·rewards_hub(11)·tasks/profile(9)·...
- **gate:** `gate_118_test` (סורק lib/ ל-`CfgText('id'` → ⊆ registry — מאמת אוטומטית כל אימוץ) · `registry_contract`/`descriptor_contract`/`zero_regression` ירוקים · analyze 0 · `visual_log` אפס-diff. lib/screens → גייט 24+116.

### #studio-s30 — סטודיו · Finalize + הקפאת 4(+1) pillar-seams (§13) — סיום עמוד-1 — 2026-06-29
**docs + seam-freeze (אין שינוי-התנהגות). זה סוגר את Pillar-1 — המנוע מוקפא לקראת עמודים 2-5.**

**§13 — ה-seams המוקפאים (FROZEN · Pillars 2-5 בונים עליהם · נעולים ב-`test/studio/seam_contract_test.dart` = compile-guard):**

| # | Seam | חתימה (קפואה) | file:line | מי תלוי |
|---|------|----------------|-----------|---------|
| 1 | `ConfigSink` | `save(ConfigDoc)→Future<void>` · `load()→Future<ConfigDoc?>` · `watch()→Stream<ConfigDoc>?` | `config_store.dart:232` | Pillar-5 (server/sync) |
| 2 | `applyOps` + `undo`/`redo` | `int applyOps(List<ConfigOp>, {String? persona, Set<String> criticalIds})` | `config_store.dart:316` | Pillar-4 (מייצר ops). **`editDraft`=primitive פרטי, לא-seam** |
| 3 | `publish` | `bool publish({String note, String byEmail, int nowMs, Set<String> criticalIds})` | `config_store.dart:412` | promote-to-live |
| 4 | `elementRegistryProvider` + 6-field `ElementDescriptor` (קפא ב-12.5) + `criticalIdsProvider` | `Provider<List<ElementDescriptor>>` | `element_registry.dart:354` | Pillar-2 (מוסיף דרך `domainElementsProvider`) |
| 5 | `cfgActionRegistryProvider` | `Provider<Set<String>>` | `config_store.dart:178` | Pillar-4 (whitelist התנהגות) |

**owner-sign-off checklist — תנאים מפורשים ל-flip `kStudioFlag` ON ל-GA (תוספת-ב):**
- [ ] full 100-gate ירוק (analyze 0 · suite · build web · knowledge_protocol 94)
- [ ] `zero_regression`/`config_theme`/a11y ירוקים · OFF=answer-equivalent מאומת
- [x] נחיל-ביקורת round-2 (8 עדשות) — אפס-bypass/רגרסיה, #84 אטום, פערים תוקנו
- [ ] perf 10K-id (virtualised tree משלב 18 — resolvedNode autoDispose.family O(1)/id)
- [ ] אישור-בעלים מפורש (`MANAGER-BUILD-PLAN.md:17`) — default OFF עד אז
- [x] seam_contract_test ירוק (5 seams קפואים)

- **gate:** `seam_contract_test` ירוק (compile-guard ל-5 החתימות) · FROZEN markers ב-5 ה-seams בקוד · `config_store`/`zero_regression`/כל החבילה ירוקים · analyze 0. lib/state → גייט 24. **🎉 עמוד-1 (מנוע-העריכה + הסטודיו, שלבים 1-30) הושלם — seams קפואים.** הבא: עמודים 2-5 (בונה-תחומים · מודיעין-לקוחות · עורך-AI · ענן/scale) — או המשך אימוץ-תוכן ב-s29 לפי בחירת-הבעלים.
- **codemod `tool/studio_extract_ids.dart`** — נדחה: `tool/` תחת very_good_analysis (avoid_print וכו') ⇒ חיכוך; אימוץ ידני per-section עובד. ייבנה כש-batch גדול יצדיק.

---

## עמוד-2 — בונה-התחומים (Domain/Vertical Builder · שלבים 31-50) — התחיל 2026-06-29
**מטרה:** "תוסיף חשמלאי מחר, בעצמי" — לקדם את מודל-נתוני-האינסטלציה הקשיח (Trade→Category→Attribute/Variant→Product→Accessory→CompatibilityRule) ל-document מחובר-בעלים, persisted, server-ready. **אינסטלציה לא-נגעת (zero-regression); תחומים-חדשים בלבד.** חלק א׳ (31-34) = schema+flags+store, **additive טהור, read-path לא-נגוע.**

### #pillar2-s31 — 3 דגלי trade default-OFF — 2026-06-29
**NEW `lib/state/trade_builder_flags.dart`:** 3 string-consts (idiom של `kKbLiveMirrorFlag`):
- `kTradeBuilderFlag = 'kTradeBuilder'` — UX יצירת-תחום (entry ~step 44+)
- `kTradeStudioFlag = 'kTradeStudio'` — עריכה-חיה inline של תחום מחובר (~step 46+)
- `kTradeImportFlag = 'kTradeImport'` — pipeline ייבוא-בכמות (~step 48+)

כולם נצרכים דרך `featureFlagsProvider.isOn(<flag>)`, **default-OFF** (נעדרים מ-prefs ומ-`_forcedOnFlags`). **אף branch חי לא קורא אותם עדיין** (אומת ב-grep: 0 refs ב-lib/ מחוץ לקובץ-consts) ⇒ build רגיל byte-identical.
- **gate:** `trade_builder_flags_test` 2 ירוקים (3 default-OFF + לא-force-enabled golden · owner-stage `enable` מדליק אחד) · `feature_flags_test` 6 (לא-נשבר) · analyze 0 · grep 0-refs. lib/state → גייט 24. הבא: Step 32 (`lib/domain/trade_schema.dart`).

### #pillar2-s32 — schema הליבה trade-agnostic — 2026-06-29
**NEW `lib/domain/trade_schema.dart`:** 9 טיפוסים `@immutable` + toJson/fromJson (server-seam, סובלני) + ==/hashCode (listEquals/mapEquals · ללא dep חדש) + stable-string-ids: `AttributeKind` (מכליל `AttrKind`) · `Trade` (+schemaVersion `kTradeSchemaVersion=1`) · `TradeCategory` (tree דרך parentId) · `AttributeDef` (+`matchTokens` R1-4 · `values:List<AttributeValue>`) · `AttributeValue` · `TradeProduct` (superset של `LipskeyCatalogProduct`; `dims:Map` נשמר 1:1 ל-parity) · `AccessoryRule` · `SmartFixture`+`SmartBrandRef`+`InstallStage` (== SmartProduct/SmartBrand/SmartStage). **לא מיובא ע"י שום lib/screens|logic** (grep 0) ⇒ additive, אפס-רגרסיה.
- **NEW `test/variant_families_snapshot_test.dart` (CAPTURE+FREEZE):** מקבע את חלוקת-הוריאנטים שה-regex (`variant_families.dart:25/77`) מייצר היום — **398 משפחות · 1608 מוצרים · {size:243, color:44, subtype:105, model:6}** + endpoint-sigs. **baseline ל-Step 45** (כשמוחקים את ה-regex ל-authored `matchTokens` — חייב לשחזר חלוקה זהה).
- **gate:** `trade_schema_test` 7 (roundtrip לכל טיפוס · unknown-kind→freeText · tolerant-empty) + `variant_families_snapshot_test` (frozen) ירוקים · analyze 0 · grep 0-imports. lib/domain → גייט 24. הבא: Step 33 (`connection_schema.dart`).

### #pillar2-s33 — schema חיבורים (מטריצה מחליפה enum סגור) — 2026-06-29
**NEW `lib/domain/connection_schema.dart`:** הכללה של ה-enum הסגור `EndType` למטריצה-מחוברת authored: `SizeMatch`/`RuleSeverity` enums · `ConnectorType` · `SystemDef` (supply/drainage גנרי) · `ProductEnd` · `ProductConnectorSpec` (+`envelope:Map<String,num>` trade-defined keys + `materialGroupId` R1-3) · `CompatibilityRule` (aTypeId/bTypeId סדר-מתועד · `sizeTable:List<List<String>>?` [a,b] · **+`materialGroup`+`incompatibleMaterialGroups` R1-3** ⇒ ניתן-לבטא HDPE↔PVC/galvanic) · `CompletionRule` (+`incompatibleMaterialGroups`+`requiredInterposerWhyHe` R1-3). כולם @immutable+JSON+==/hashCode (deep ל-sizeTable). **`RuleSeverity` שקול-בשם ל-`CheckSeverity` (install_engine:77)** — האדפטר מתרגם ב-step 39. `EndType`/`WaterSystem` **נוגעים-לא** (git no-diff; הופכים seed-types ב-37).
- **gate:** `connection_schema_test` 6 (roundtrip · enum-by-name · material-group R1-3 שורד · sizeTable nested · **RuleSeverity≡CheckSeverity דו-כיווני**) ירוקים · analyze 0 · `lipskey_verified_connections` ללא-diff · grep 0-imports. lib/domain → גייט 24. הבא: Step 34 (`trades_store.dart` — deltas-only).

### #pillar2-s34 — authored-trade store (deltas-only) — **סיום chunk א׳** — 2026-06-29
**NEW `lib/state/trades_store.dart`:** `TradesDoc` (@immutable container של כל ה-deltas: 11 List<> מכל טיפוסי s32+s33 + schemaVersion · toJson/fromJson/copyWith/==/hashCode · `TradesDoc.empty`) + `TradesStoreNotifier extends StateNotifier<TradesDoc>` (key `bs.trades.v1`, idiom של `catalog_settings.dart` — async `_load`/`_persist`, mutators idempotent: `upsertTrade`/`removeTrade`/`replaceAll`/`clear` עם no-op short-circuit) + `tradesStoreProvider`. **מתחיל ריק ⇒ אין trade מפורסם ⇒ אפליקציה חיה byte-identical.** **`migrate(json)` ממשי (R1 #18):** doc לא-מ-versioned (v0) → נחתם ל-v1 בטעינה, data נשמר (לא no-op סמלי). **אף consumer חי** (grep 0).
- **gate:** `trades_store_test` 4 (empty-start · upsert-idempotent · remove/clear · persist→reload roundtrip) + `trades_migration_test` 2 (v0→v1 שומר-data · identity ל-current) ירוקים · analyze 0 · grep 0-consumers. lib/state → גייט 24.
- **🎉 chunk א׳ (31-34) הושלם:** flags + schema (trade+connection) + store — **ה-read-path של האפליקציה החיה לא נגוע בכלל, אפס-רגרסיה מוכחת.** הבא: chunk ב׳ (35+: persona-link · plumbing SEED + answer-equivalence keystone @38 · adapter).

### #pillar2-s35 — adapter `TradeProduct↔LipskeyCatalogProduct` (linchpin אפס-רגרסיה §1.4) — 2026-06-29
**NEW `lib/domain/trade_product_adapter.dart`:** `tradeProductFromLegacy(LipskeyCatalogProduct)`→`TradeProduct` + extension `.toLegacy()` — **זוג-הופכי נאמן** כך שהמסכים ממשיכים לראות `LipskeyCatalogProduct` בלבד (אפס שינוי-טיפוס). `dims` נשמר 1:1 (render parity); שדות legacy-only (color/category-strings/brand/imageFile+specImageFile singular) → stash ב-`attributes` תחת מפתחות-שמורים `__` (trade-חדש לא משתמש בהם; legacy-render מתעלם מ-attributes). `brand` default 'ליפסקי' נשמר.
- **gate:** `trade_product_adapter_test` 2 ירוקים — **כל קטלוג-האינסטלציה (`kCatalogProducts`) עושה round-trip byte-for-byte ללא drift** (sku/dims/brand/`connectionSizes`) + curated-set (dims/images/color/3 brands) שדה-שדה. analyze 0 · grep 0 live-consumers · המסכים ללא-שינוי. lib/domain → גייט 24. הבא: Step 36 (גנרטור consts→plumbing doc).

### #pillar2-s36 — plumbing seed (trade+categories+products+fixtures+accessories) — 2026-06-29
**⚠️ סטייה מתועדת מהספק:** הספק רצה `scripts/gen_plumbing_seed.dart` (codegen). **חסום** — הקבועים (brands/catalog_tree/smart_tree) מייבאים `package:flutter/foundation.dart` שמושך `dart:ui` (`ui.Image`/`ui.Picture`), ו-`dart run` נכשל בקומפילציה (אומת אמפירית: `'Image' isn't a type`). **Pivot ל-runtime-builder:** `buildPlumbingSeed()→TradesDoc` בונה מהקבועים החיים, דטרמיניסטי (מיון יציב לפי id/sku) ⇒ idempotent-by-construction (אין byte-drift לשמור) · ה-keystone (38) בודק תשובה-זהות ישירות.
- **NEW `lib/domain/seeds/plumbing_trade_seed.dart`:** `plumbingTrade()` (brandIds מ-kBrands) · `plumbingCategories()` (שיטוח kCatalogTree → parentId-linked) · `plumbingProducts()` (כל kCatalogProducts דרך ה-adapter, byte-faithful) · `plumbingAccessories()` (sp.acc) · `plumbingFixtures()` (kSmartProducts → SmartFixture: brandRefs+stages+accessory-links) · `buildPlumbingSeed()` מרכיב TradesDoc. connectorTypes/specs/CompatibilityRules מ-891 = step 37.
- **gate:** `plumbing_seed_test` 4 ירוקים (determinism: 2 builds == · counts==consts: products/fixtures/brands · SKU-set מדויק · fixture→accessory links resolve) · analyze 0 · grep 0 live-consumers (store ריק, read-path לא-נגוע). lib/domain → גייט 24. הבא: Step 37 (CompatibilityRules מ-891 specs) → 38 KEYSTONE.
- הבא: batches נוספים (קוקפיט→home_shell→catalog) + **אימוץ `cfgRadius(context)` בכרטיסים** שיפעיל את ה-radius-slider החי (סוגר את ה-deferred של r2-fix-3). דחוף רק על 'תדחוף'.

### #pillar2-fix — תיקוני-יסוד (ביקורת-נחיל 4-עדשות) לפני Step 37 — 2026-06-29
**מצא הנחיל (4 עדשות read-only), בנה הנחיל (2 בנאים + בודק), המנצח byte-verify + גידר.** 3 תיקונים additive על יסוד-עמוד-2 (read-path עדיין לא-נגוע):
- **Fix C (HIGH) — איחוד מרחב-הקטגוריות** ב-`plumbing_trade_seed.dart`: היו 3 מרחבי-id מנותקים (categories=`plumbing.cat.<node.id>` · products=`plumbing.<categoryHe>` · fixtures/acc=`plumbing.cat.<sp.cat>`) ⇒ FK תלוי-באוויר. עכשיו resolver משותף מ-kCatalogTree (`lipskeyCategory→_categoryId(node.id)` · `smartKey→_categoryId(node.id)`) + קטגוריית-נפילה `kUncategorizedCategoryId='plumbing.cat._uncategorized'`. products↔lipskeyMap · fixtures/accessories↔smartKeyMap (לפי `sp.key`, לא `sp.cat`) · כולם `?? fallback`. החוזה by-construction: כל `categoryId`/`appliesToCategoryId` ∈ categories.
- **adapter** `tradeProductFromLegacy` — param אופציונלי `String? categoryId` (null → התנהגות-קודמת `'$tradeId.${p.categoryHe}'`); `toLegacy()` לא-נגע ⇒ `trade_product_adapter_test` (קורא בלי categoryId) byte-identical.
- **Fix B** — `trades_store.dart` `_schemaVer()` סובלני: `schemaVersion` כ-String ("1"→1 · לא-מספרי→fallback) לא זורק יותר (guard-ה-prefs-המושחת שב לעבוד).
- **Fix A** — `connection_schema.dart` `_numMap` guard `if (e.value is num)` (envelope עם ערך לא-num לא מפיל decode).
- **gate:** הבדיקות המושפעות +23 ירוקים (plumbing_seed +3: no-dangling-FKs · _uncategorized · non-vacuous · trades_migration +2: String-tolerance · adapter round-trip byte-for-byte) · analyze 0 errors · grep 0 live-consumers. הבא: Step 37.

### #pillar2-s37 — connections seed (connectorTypes·systems·specs·rules מ-890 VerifiedSpecs) — 2026-06-29
**הרחיב הנחיל (בנאי+בודק), המנצח אימת byte+gate.** `buildPlumbingSeed()` ממלא עכשיו גם 5 רשימות-חיבור מ-`kVerifiedSpecs` (**890** byte-מאומת — לא 891 כפי שתועד בהנחיה; הבנאי נקשר ל-`.length` אז ה-seed תקין, והבדיקה תוקנה ל-890):
- **6 ConnectorTypes** (לכל EndType: id `plumbing.conn.<e.name>` · sizeValues distinct-sorted · systemId נגזר מ-`ConnectorEnd.system`) · **2 SystemDefs** (`plumbing.sys.supply`='אספקה' כחול · `.drainage`='ניקוז' אפור).
- **890 ProductConnectorSpecs** (לכל VerifiedSpec: ends→ProductEnd(connTypeId,size) · materialId · ratingHe=pressureRating · envelope{maxTempC} · materialGroupId=`_galvanicGroup(material)`; pexType נדחה — envelope הוא `Map<String,num>`).
- **5 CompatibilityRules** — methodLabelHe **בייט-זהה ל-`install_engine.connectionMethodLabel`:90** (קריטי לקיסטון): bspMale↔bspFemale 'תבריג + PTFE' · pexPress 'Press / טבעת כיווץ' · copperPress 'Press / O-ring' · drainOpening 'כיסוי ניקוז' · hdpe 'אום הידוק (compression)' (התווית של pipeSharedWith:105, לא ה-direct-mate המת). sizeMatch=exactSame · onMismatch=critical.
- **1 CompletionRule גלווני** — incompatibleMaterialGroups=['copper-group','iron-group'] + dielectric whyHe + critical (type-fields ריקים בכוונה: גלווני מבוסס-חומר, לא-type; resolver@40 יקרא material).
- **gate:** `plumbing_seed_test` +5 = **12 ירוקים** (890 specs · 6+2 · sample-rule לפי תווית · גלווני · determinism) · analyze 0 errors · grep 0 live-consumers (store ריק, read-path לא-נגוע). הבא: **Step 38 — KEYSTONE** (trade_seed_equivalence_test).

### #pillar2-s38 — KEYSTONE: seed answer-equivalent ל-מנוע החי — **חלק ב׳ נסגר** — 2026-06-29
**הפיבוט.** `test/trade_seed_equivalence_test.dart` מוכיח שה-seed (s36/s37) מייצר **בדיוק אותן תשובות** כמו מנוע-האינסטלציה הקשיח — resolver-דק שנבנה *רק* מ-`seed.productSpecs`+`seed.compatRules` משחזר את `install_engine.connectionMethodLabel` בייט-בבייט על כל הקטלוג המאומת:
- **TEST 1 (הקיסטון):** לכל sku ב-(kVerifiedSpecs ∩ kCatalogProducts) × probe-לכל-EndType — `seedMethod(s,p) == connectionMethodLabel(prod[s],prod[p])`. שומרי-לא-ריקנות: skus≠∅ · ≥5/6 EndTypes · ראה ≥1 תווית-מלאה *ו*≥1 ריקה (מימוש מול non-mate). HW-* (מים-חמים, ב-`kCompatCatalog`) מדולגים נכון (לא ב-kCatalogProducts), ומכוסים ב-TEST 2/3 דרך הזרע.
- **TEST 2 (אפס אובדן-מידע):** כל 890 ה-VerifiedSpecs מוקרנים נאמנה — material · maxTempC · ends (`connectorTypeId='plumbing.conn.<EndType.name>'` + size).
- **TEST 3 (גלווני):** materialGroupId לכל spec (נחושת/פליז→copper-group · פלדה/נירוסטה→iron-group · benign→null) + ה-CompletionRule מזווג copper↔iron · שומרי sawCopper/sawIron.
- **gate:** 3 ירוקים · analyze 0 (קומפל+רץ) · הבנאי כתב נאמן (אפס assertions מוחלשים), המנצח קרא+הריץ. **🎉 חלק ב׳ (35-38) נסגר: "אינסטלציה = עוד תחום-נתונים", answers-wise מוכח.** הבא: Step 39 (resolver wiring מאחורי flag).

### #merge — איחוד קו Studio/עמוד-2 עם workstream המקלדת/חיפוש (origin) — 2026-06-29
מיזוג נקי (אפס קונפליקטים) של 95 commits מ-`origin/whats-happening` (card-keyboard/finder/line-convergence) עם קו Studio+עמוד-2 (56 commits) — שני קווים שהתפצלו מ-`decc48b`, קבצים מנותקים. **`card_soft.dart` + הבדיקה שלו שומרו** (הצוות-האחר מחקם כ-dead-code; שומרתי כדי לא להפעיל שער 89 — ינוקה ב-PR מאוחר). **אפס-עקיפה** — כל 100 השערים רצים על commit-המיזוג. הזרע של עמוד-2 עדיין רדום (grep 0 live-consumers).

### #pillar2-s39 — connection_resolver: מנוע-חוקים טהור, trade-agnostic (ללא UI) — 2026-07-06
**חלק ג׳ נפתח (39-41): המנוע מפסיק "לדעת פיזיקה" ומתחיל להעריך חוקים מחוברים.** NEW `lib/domain/connection_resolver.dart` (בנאי-נחיל) + `test/connection_resolver_unit_test.dart` (בודק-נחיל, 8 בדיקות) — **התכנסו על החוזה בניסיון ראשון** (אפס תיקוני-יישוב):
- **`normalizeSize`** — strip `"` + trim, כך ש-`'1/2'`≡`'1/2"'` (מלכודת-הצפי של התוכנית §3) — בכל השוואת-size.
- **`ConnectionResolver(rules, connectorTypes, systems, completionRules)`** + memo `(aType|aSize|bType|bSize)` (§6). **`canConnect(a,b)`→`ConnectResult{mates, methodLabelHe, severity, rule}`** — סדר דטרמיניסטי (a.ends חיצוני · b.ends פנימי · חוקים בסדר-רשימה · first-match-wins, מכליל את `connectionMethodLabel`:90); rule = ה-back-ref של `explain()` (תוספת-א). טבלת-הכרעה: matched→(true,label,null,rule) · size-miss→(false,'',onMismatch,rule) · no-rule→(false,'',null,null) — "לא מתחבר" שקט, לא exception (§4).
- **SizeMatch מלא:** exactSame (מנורמל) · anyToAny · tableLookup (שורות `[aSize,bSize]` באוריינטציית-הכלל; התאמה-הפוכה בודקת `[y,x]` — מתועד).
- **`completion(line)`→`List<CompletionIssue>`** — שתי צורות: MATERIAL (גלווני: ≥2 קבוצות-מהרשימה בקו → whyHe=requiredInterposerWhyHe??whyHe, offendingSkus) + TYPE (trigger-type בלי require-type). **`systemCoherence(line)`→`SystemCoherence{coherent, offendingSystem, offendingSku}`** — מצביע על האלמנט החורג (תוספת-ב).
- **DoD:** analyze 0 errors · 8/8 ירוקים · **grep 0 call-sites חיים** (שום קוד חי לא מייבא — החיווט המגודר הוא s41) · דטרמיניסטי. הבא: **Step 40 — G-resolver parity** (resolver על המטריצה המוזרעת ≡ תשובות kVerifiedSpecs).

### #pillar2-s40 — G-resolver parity: ה-resolver האמיתי ≡ המנוע החי — שער-הכניסה ל-41 — 2026-07-06
**NEW `test/connection_resolver_parity_test.dart` (בנאי-נחיל) — 4/4 ירוק בריצה ראשונה.** ההבדל מהקיסטון (s38): שם resolver-דק *בתוך הבדיקה*; כאן **ה-`ConnectionResolver` האמיתי מ-s39**, מוזן `seed.compatRules/connectorTypes/systems/completionRules` — ההוכחה שקוד-הייצור עצמו משחזר את המנוע:
- **TEST 1 (G-resolver):** סוויפ-הקיסטון המלא — (kVerifiedSpecs ∩ kCatalogProducts ≈ 812 skus) × probe-לכל-EndType (~4.9K זוגות): `r.methodLabelHe == connectionMethodLabel(...)` **וגם** `r.mates == engineLabel.isNotEmpty`. שומרי-לא-ריקנות כמו בקיסטון.
- **TEST 2 (זוגיות-פיזיקה גולמית):** ≤3 skus לכל EndType מכלל kVerifiedSpecs (גם HW-*, לא רק הקטלוג) — כל זוג-מסודר: `resolver.mates == (directMatesWith || pipeSharedWith)`. שומרים: >20 זוגות · גם true וגם false.
- **TEST 3 (גלווני):** copper+iron → issue critical עם whyHe (המתאם הדיאלקטרי) + offendingSkus; copper+benign / copper+copper → ריק (tripwire להוספות-seed עתידיות).
- **TEST 4 (קוהרנטיות):** supply+drainage → לא-קוהרנטי, offendingSku=הניקוז, offendingSystem=`plumbing.sys.drainage`.
- **ערוץ-סטייה שתועד ולא רוכך:** ה-resolver מנרמל sizes (`normalizeSize`) והמנוע משווה גולמי — הזוגיות מוכיחה שאין אי-עקביות-size בנתונים בפועל. **gate:** analyze 0 · 4/4 · הפינים הישנים (compat_50_samples · full_compliance_audit) לא-נגועים. **G-resolver ירוק = מותר לחווט (s41).**

### #pillar2-s41 — תפר-ההאצלה במנוע החי: אינסטלציה קשיחה לנצח (R1-2) — **חלק ג׳ (39-41) נסגר** — 2026-07-06
**לראשונה המנוע החי יודע להעריך תחומים-חדשים מחוקים-מחוברים — בלי לגעת באינסטלציה.** `install_engine.dart` (בנאי-נחיל; בודק-נחיל כתב חוזה במקביל — 6/6):
- **`TradeResolution{tradeId, resolver, specOf}`** — תפר-ההאצלה. `connectionMethodLabel(a,b,{trade})` + `lineComplianceChecklist(chain,tempC,acc,{trade})` — פרמטר אופציונלי; **אף קורא חי לא מעביר אותו עדיין** (שער-הדגל `kTradeStudioFlag` יגיע בשכבת-ה-provider, s43) ⇒ אפס-רגרסיה, הגופים הישנים בייט-לא-נגועים (הוזרקו רק שורות מעל).
- **R1-2 (חוזה-קיסטון):** guard רץ **ללא-תנאי** — `trade.tradeId!='plumbing'` — אינסטלציה **לעולם** לא נכנסת ל-resolver, גם אם הועבר לה tradeResolution (בכוונה אין assert — פלמבינג-מוזרם חייב להיבלע בשקט בכל build-mode; הבדיקה מוכיחה עם specOf-זורק + דגל-consulted שהוא **מעולם לא נקרא**).
- **תחום-מחובר:** method דרך `resolver.canConnect(specOf(a),specOf(b)).methodLabelHe`; spec-חסר → `''` שקט. checklist v1: **"הצ׳קליסט של תחום-מחובר = הפרות-החוקים שלו"** — CompletionIssues כ-LineChecks לא-מסופקים (RuleSeverity→CheckSeverity שם-לשם, info קיים) + check-קריטי על ערבוב-מערכות ('ערבוב מערכות (אספקה/ניקוז)' + ה-sku החורג).
- **Kill-switch (תוספת-ב):** האצלה שזורקת → fallback שקט ל-legacy (try/catch, בלי print).
- **gate:** analyze 0 · `install_engine_delegation_test` 6/6 (כולל R1-2-מוכח + העדפת requiredInterposerWhyHe) · **כל בדיקות-המנוע הקיימות ירוקות ללא-שינוי** (safety/hardening/polyroll/b5-b13, 41 ירוקים בריצת-האימות). הבא: **s42** (tradeId ל-repo, default 'plumbing') → **s43** (activeTradeProvider + שער-הדגל).

### #pillar2-s42 — תפר-tradeId ב-CatalogRepository (default 'plumbing' = בייט-זהה) — 2026-07-06
**חלק ד׳ נפתח (42-43).** `catalog_repository.dart` + `catalog_local.dart` (בנאי-נחיל; בודק-נחיל במקביל — 6/6):
- **`{String tradeId = 'plumbing'}`** על `allProducts`/`smartTreeCats`/`catalogCategories` — כל הקוראים הקיימים (אפס-ארגומנטים) בייט-זהים; ה-guard המוביל `if (tradeId != 'plumbing') return const [];` הוזרק **מעל** הגופים הקיימים (לא-נגועים). tradeId זר → קריאה ריקה (v1 מתועד — read-path של תחומים-מחוברים יגיע עם חיווט-ה-store, s43+).
- **`categoryTree({tradeId})` חדש** — גוף-דיפולט על ה-abstract (מגן על מימושי-extends עתידיים) + **override מפורש ב-LocalCatalogRepository** (הבנאי תפס לבד ש-`implements` לא יורש גוף-דיפולט — אותה מלכודת שהבודק דיגל במקביל; שני הסוכנים התכנסו).
- **gate:** analyze 0 · `catalog_repository_tradeid_test` 6/6 (כולל חוזה-תאימות-לאחור פורמלי לכל מתודה + non-electric-special-case) · `repositories_test` + `catalog_regression_test` ירוקים ללא-שינוי (48 ירוקים בריצת-האימות). הבא: **s43 — activeTradeProvider** (ברירת-מחדל 'plumbing'; switcher מוסתר כש-count==1).

### #pillar2-s43 — activeTrade providers: הכרעת-התחום-הפעיל — **חלק ד׳ (42-43) נסגר** — 2026-07-06
**append-only ל-`lib/state/trades_store.dart` (259→311; אפס נגיעה בקיים; אפס consumers חיים עדיין):**
- **`publishedTradeIdsProvider`** — `{'plumbing'} ∪ published` — אינסטלציה **שמורה-לנצח** (guard תוספת-ב: אי-אפשר להישאר עם קטלוג ריק).
- **`activeTradeProvider`** (raw, default 'plumbing') + **`resolvedActiveTradeIdProvider`** — הבחירה אם-פורסמה, אחרת fallback ל-'plumbing'; **read-paths צורכים רק את ה-resolved**.
- **`activeTradeObjProvider`** (תוספת-א: ה-Trade המלא; null לאינסטלציה-השמורה) + **`tradeSwitcherVisibleProvider`** (מוצג רק כש->1 מפורסם ⇒ תחום-יחיד = UI בייט-זהה).
- **gate:** analyze 0 · `active_trade_provider_test` 6/6 (default · reserved · hidden-at-1/visible-at-2 · set+resolve · unpublish-fallback · unknown-id) + `trades_store_test` 4/4 ללא-שינוי. **חלק ד׳ סגור — כל התשתית מוכנה; הבא: חלק ה׳ (44-47) — מסכי-הבנייה העבריים.**

### #pillar2-s44 — ה-UI הראשון: כניסה מגודרת + בית-בונה-הענפים + define-step — 2026-07-06
**חלק ה׳ נפתח (44-47).** בנאי+בודק-נחיל במקביל, הבנאי הצליב כל assertion מול הבדיקה לפני מסירה:
- **NEW `lib/screens/trade_builder/trade_builder_home.dart`** — `TradeBuilderHomeScreen`: RTL פנימי, clamp-1.35 (min(ambient,1.35) — clamps לא resets), '🏗️ בונה ענפים', wizard 'שלב 1 מתוך 6' (6-segment), רשימת-ענפים מ-tradesStoreProvider (ריק → 'עדיין אין ענפים — הוסף את הראשון'; מלא → tile עם emoji/color-wash/צ׳יפ טיוטה/פורסם), 'הוסף ענף' (Semantics-button, brand-pill) → define-step.
- **NEW `trade_define_step.dart`** — טופס: 'שם הענף' · 'אימוג׳י' (default 🛠️) · 'פרסונה' dropdown מ-kPersonas (Persona{id,emoji,title}) · 6-swatches · 'שמור טיוטה' → `upsertTrade(Trade(id:'trade.<slug-דטרמיניסטי>', published:false))` + pop. שם-ריק = no-op.
- **`manager_dashboard_screen.dart`** — insert-only (26+/0-): כרטיס `_ManageSection` '🏗️ בונה ענפים' בסוף `_ManageTab`, **collection-if על `kTradeBuilderFlag`** → OFF = עץ בייט-זהה.
- **gate:** analyze 0 · `trade_builder_home_test` 6/6 (flag-OFF-absent גם-offstage · RTL · semantics · clamp+anti-vacuity · ניווט · draft-write) · `manager_dashboard_screen_test` **36/36 ללא-שינוי** · visual_log מעודכן. הבא: **s45 — עורכי עץ-קטגוריות + סכמת-מאפיינים** (⚠️ תנאי-קדם: variant_families_snapshot לפני מחיקת-regex).

### #pillar2-s45 — 🗂️ עורך עץ-קטגוריות + 🏷️ עורך מאפיינים — 2026-07-06
**בנאי+בודק-נחיל במקביל; תיקון-יישוב יחיד (tooltip 'מחק'):**
- **NEW `category_tree_editor.dart`** — `CategoryTreeEditorScreen{tradeId}`: קטגוריות-הענף לפי sortIndex ב-ReorderableListView (גרירה משכתבת 0..n-1 idempotent), הוסף ('שם קטגוריה'+'הוסף קטגוריה' → `upsertCategory` id `<tradeId>.cat.<slug>`, התנגשות → '-2'), שנה-שם (dialog, **id יציב**), מחק (Semantics+tooltip). AppBar-action '🏷️' → עורך-המאפיינים.
- **NEW `attribute_schema_editor.dart`** — `AttributeSchemaEditorScreen{tradeId}`: רשימת AttributeDefs + טופס (שם/kind/ערכים-chips/'ציר וריאנט?') → `upsertAttribute`. **ולידציה edit-time:** 'ציר וריאנט ללא ערכים' (צהוב, חי על הטופס + על tile). **פירוק-שם חי:** 'בדיקת פירוק שם' — contains על labelHe/canonical → chips '<שם>: <ערך>'.
- **`trades_store.dart`** — +4 mutators idempotent במראה-upsertTrade: `upsertCategory/removeCategory/upsertAttribute/removeAttribute` (+49 שורות).
- **`trade_builder_home.dart`** — nav: tile-ענף tappable → עורך-הקטגוריות.
- **gate:** analyze 0 · 10/10 (שני הקבצים) · const files (variant_families/catalog_tree) לא-נגועים (git diff ריק) · ⚠️ מחיקת-ה-regex נשארת חסומה עד ש-variant_families_snapshot עובר עם axes-מחוברים (s45-DoD, טרם). הבא: **s46 — עורך-מוצרים + עורך-אביזרים**.

### #pillar2-s46 — 📦 עורך-מוצרים + 🧩 עורך-אביזרים — 2026-07-06
**בנאי+בודק-נחיל; שרשרת-ה-authoring הושלמה (בית→הגדרה→קטגוריות→מאפיינים→מוצרים→אביזרים):**
- **NEW `product_authoring_screen.dart`** — `ProductAuthoringScreen{tradeId}`: מוצרי-הענף + טופס: 'שם מוצר' · 'מק"ט' (=id verbatim; כפילות → no-op + 'מק"ט כבר קיים', הראשון שורד) · 'קטגוריה' (חובה; אין → 'צור קטגוריה קודם') · **קלטים דינמיים per-AttributeDef** (עם-values → dropdown labelHe = out-of-schema בלתי-אפשרי; number → digits) → `upsertProduct` (attributes: `Map<String,String>` defId→valueId/freeText; brandId/nameEn='' — לא בבעלות-הטופס).
- **NEW `accessory_rule_editor.dart`** — `AccessoryRuleEditorScreen{tradeId}`: חוקי-האביזר + טופס: שם/למה-חשוב/'חובה?'/'מחיר' (non-digit → 'מחיר לא תקין' + no-op; ולידציה על הטקסט הגולמי, בכוונה בלי formatter) / 'קטגוריה' / **'מוצר מקושר' חסין-יתומים** (רק מוצרי-הענף; 'ללא'=null; נשמר id) → `upsertAccessory` (id `<tradeId>.acc.<slug>`, emoji default '🧩').
- **`trades_store.dart`** — +4 mutators (upsertProduct/removeProduct/upsertAccessory/removeAccessory, מראה-s45). **`category_tree_editor.dart`** — פעולת '📦' (insert-only).
- **gate:** analyze 0 · s46 9/9 + רגרסיית-s45 10/10 · const seeds לא-נגועים. הבא: **s47** (לפי התוכנית — קרא detail/031-050.md).

### #pillar2-s47 — 🔌 סטודיו כללי-חיבור + 🚀 שער-פרסום FK — **חלק ה׳ (44-47) נסגר** — 2026-07-06
**הוויזרד "תוסיף חשמלאי" קיים מקצה-לקצה: בית → הגדרה → קטגוריות → מאפיינים → מוצרים → אביזרים → כללי-חיבור → פרסום.**
- **NEW `connection_rule_studio.dart`** — `ConnectionRuleStudioScreen{tradeId}`: 'מחברים' (upsert/removeConnectorType, id `<tradeId>.conn.<slug>`) · **מטריצת N×N** (זוג-לא-מסודר; dialog 'תווית שיטה' → upsertCompatRule `<tradeId>.rule.<a>__<b>` anyToAny/critical; 'מחק כלל') · **ספסל-בדיקה חי** — specs סינתטיים חד-קצה דרך **ה-ConnectionResolver האמיתי (s39)** → methodLabelHe/'לא מתחבר'. מקור-אמת יחיד = אפס-drift מול install-studio.
- **NEW `trade_publish_sheet.dart`** — `TradePublishSheet{tradeId}`: r1 'לכל קטגוריה יש מוצר' · r2 'לכל ציר וריאנט יש ערכים' · r3 'אין כלל-חיבור יתום' · **r4 FK 'כל המוצרים משויכים לקטגוריה קיימת' (R2-7)** + dry-run counts + 'פרסם' (all-pass → published:true+pop; אחרת no-op). **ענף פגום לא יכול לעלות לאוויר.**
- **`trades_store.dart`** — +4 mutators (connectorType/compatRule). חיווט: 🚀 בבית · 🔌 במוצרים (insert-only).
- **gate:** analyze 0 · s47 10/10 · **רגרסיית-משפחה מלאה 35/35** · const seeds לא-נגועים. הבא: **חלק ו׳ — s48** (חוזה-ייבוא: template→map→dry-run→commit אטומי, מאחורי kTradeImportFlag).

### #pillar2-s48 — 📥 חוזה-הייבוא (G-import): template→dry-run→commit אטומי — 2026-07-06
- **NEW `lib/domain/trade_import.dart`** (Dart טהור): `kImportFixedColumns` [sku,name,category] · `generateCsvTemplate(defs)` (כותרת + שורת-דוגמה ריקה) · `parseAndValidateCsv(...)→ImportReport{valid, errors, canCommit}`. חוקים: כותרת-רעה → שגיאת-row-0 יחידה 'כותרות לא תקינות' · 'שדה חובה חסר' · 'מק"ט כפול' (בקובץ + מול ה-store) · **'קטגוריה לא קיימת' (R2-7, titleHe או id → נפתר ל-ID)** · **'ערך לא בסכמה'** (תא תחת def-עם-values חייב labelHe/id → נשמר value-ID) · freeText=raw · תא-ריק-תחת-def = תקין.
- **`product_authoring_screen.dart`** — סקציית-ייבוא collection-if על `kTradeImportFlag` (OFF=בייט-זהה): הדבק→dry-run→'ייבא' רק על canCommit; **אטומי** (שגיאה אחת=אפס כתיבה; commit=לולאת upsertProduct על valid בלבד; עריכה מבטלת דוח).
- **gate:** analyze 0 · `bulk_import_test` 8/8 (כולל אטומיות-store וקידוד value-id≠label) · רגרסיה 11/11. הבא: **s49-50** (סוגרים את קשת 31-50).

### #pillar2-s50 — 🏆 G-newtrade: "תוסיף חשמלאי בעצמך" מוכח מקצה-לקצה — 2026-07-06
**⚠️ סטיית-סדר מתועדת: s50 נבנה לפני s49** — מבחן-הקבלה משמש רשת-ביטחון לפני ה-refactor הכבד של s49 (מסך 3,485 שורות). בנאי+בודק-נחיל:
- **(A) נתיב-הקריאה של ענפים-מחוברים:** `LocalCatalogRepository({TradesDoc Function()? authoredDoc})` — מוזרק מ-`catalogRepositoryProvider` (`ref.read(tradesStoreProvider)`; reactivity-חי יגיע עם ה-cutover). tradeId שאינו-plumbing: `allProducts` מגיש מוצרים-מחוברים דרך אדפטר-s35 `toLegacy()` (sorted-by-sku) · `categoryTree` מגיש קטגוריות-מחוברות כ-CatalogNodes (sorted-by-sortIndex). source-null → התנהגות-s42 (ריק). plumbing בייט-זהה.
- **(B) הרחבת-r3 בשער-הפרסום:** גם CompletionRules עם type-fields לא-ריקים חייבים להיפתר ל-connectorTypes של הענף (חומר-בלבד = תקין) — כלל-רפאים חוסם פרסום.
- **NEW `test/trade_newtrade_acceptance_test.dart` (G-newtrade, 6):** authoring מלא דרך ה-mutators → publish → **הקטלוג מגיש** (products+tree, adapter-converted, sorted) → ה-resolver עונה (connect 'חיבור בורג' + completion 'מאמ"ת דורש מפסק-פחת' יורה-רק-בהפרה) → **CompletionRule-יתום חוסם פרסום** → **default-OFF** (store-ריק = plumbing-בלבד, governance #84) → **הקיסטון לא-נגוע** (allProducts()==kCatalogProducts אחרי הכל).
- **gate:** analyze 0 · **26/26** (acceptance 6 + publish-sheet 5 + repo-contracts 12 + keystone 3). **נשאר בקשת: s49 בלבד** (install-studio seams + BrandProfile parity — הכבד, במכוון אחרון).

### #pillar2-s49a — BrandProfile: 5 קבוצות-הסולמות × 3 מותגים + שער-שקילות (R1-5) — 2026-07-06
**חצי-המותגים של s49 (אדיטיבי; אף סולם לא נמחק — מחיקה מותרת רק כשהשקילות ירוקה):**
- **NEW `lib/domain/brand_profile.dart`** — `BrandProfile{specEnvelope(maxTempC 90/95/null·waterSystem·ends·material·pressure) · parseBore(diRangeMax "13.6–14.7"→14.7 / dnDirect / none) · imageDir(polyroll/huliot_smartlock/lipskey+page_→pages) · finderEmoji/Label(🚰 אספקת מים / 🟢 דלוחין SmartLock / null) · systemHint({supply}/{drainage}) · kitStrategy(pprSocketFusion/smartLockSnapFit/endsDerived) · specStrips}` + `kBrandProfiles` + `profileForBrand` (else=ליפסקי). האתרים האמיתיים (נדדו מהתוכנית): `data/related_info.dart` :487-539/:52-54/:415-458 · `lipskey_catalog.dart` :49-53 · `system_division.dart` :22-27 · `install_kit.dart` :42-149 · sheet :2198-2221.
- **NEW `test/brand_profile_parity_test.dart`** — 6 בדיקות, **מוצמד מהקוד החי** (אפס-מעגליות): G1-G5 דרך פונקציות-חיות ציבוריות על מוצרים אמיתיים + literals-בייט; fall-through על AQUATEC (מותג-אמיתי בלי-arm). לא-ניתן-להרמה (מוצהר): גופי-פאנלים ווידג׳טיים; OR-חומר ב-install_kit:48 נשאר באתר.
- **נמצאו 2 סולמות מחוץ-לתוכנית** (complianceTriggersFor :624-668 · products-screen chips :1322-1340) — לצעד-המחיקה העתידי.
- **gate:** analyze 0 · parity 6/6 בריצה-ראשונה. הבא: **s49b** — 8 התפרים המגודרים במסך-ההתקנות.

### #pillar2-s49b — 7 תפרים מגודרים במסך-ההתקנות + TradePhysicsConfig — **🏁 קשת 31-50 סגורה** — 2026-07-06
**החצי הכבד של s49 (מסך 3,485 שורות): insert-only, 366+/18− (כל מחיקה=בליעה-משמרת-טוקנים):**
- **guard יחיד** `_authoredConfigOf(ref)` — **null כש-resolved=='plumbing' (R1-2) לפני כל מגע ב-slices**; אחרת `_ActiveTradeConfig` (systems/specs/mustHave-rules + **TradeResolution של s41 — אפס תפר-מקביל**; physics=null v1).
- **7 התפרים** (אתרים אמיתיים, נדדו מהתוכנית): (a) `_systemColor`+3 call-sites → SystemDef.color · (b) picker → `allProducts(tradeId:)` (נתיב-s50, מוצרים-לא-fixtures — סטייה-מנומקת) · (c) checklist ×2 + `_checkRow` verbatim-whyHe → התפר-s41 · (d) חום → envelope-banner · (e) canConnect → `connectionMethodLabel(trade:)` · (f) שיפוע → מוסתר כש-physics-null; **ת"י-1205 של אינסטלציה לא-נגוע** · (g) kit → mustHave-AccessoryRules. NEW `lib/domain/trade_physics_config.dart` (אינסטלציה לעולם לא קוראת — קבועיה קבועים).
- **הושארו-legacy במוצהר:** kit/pressure-text ב-copyBom · free-text match · scenario-tiles · צנרת-assemble (פיזיקת-מנוע, צעדים עתידיים).
- **NEW `test/install_studio_flag_off_test.dart` (G-flag-off) 5/5** — resolution-default · עוגני-shell · **פאנל-שיפוע נוכח לאינסטלציה** · תווית-חיבור positional-בלבד · צבעי-מערכת דרך ווידג׳טים מרונדרים. תיקוני-יישוב: משטח 440×950 + פילטר-onError ל-overflow-ישן בשורת-שרשרת :1139 (חוב-layout קיים-מראש בקוד לא-נגוע; ורק overflow — כל שגיאה אחרת מפילה).
- **gate:** analyze 0 · flag-off 5/5 · parity 6/6 · delegation+safety ירוקים. **🏁 הקשת 31-50 הושלמה: schema→store→adapter→seed→keystone→resolver→parity→תפר-מנוע→תפר-repo→activeTrade→7 מסכי-authoring→import→acceptance→brand-parity→תפרי-studio.**

## עמוד-5 — Scale/Data/Backend & Publish-to-All (שלבים 51-68)

### #pillar5-s68 — Phase-3 flip + חבילת-gate zero-regression + **deploy-ordering gate (R2-10)** — **🏁 קשת 51-68 סגורה** — 2026-07-07
**השלב האחרון של Pillar-5. אפס-`lib/` — הפליפ הוא `--dart-define` בלבד (הצי `_firebase` של 51-67 כבר קיים), כך שה-shipped-default נשאר flags-OFF byte-identical עד אישור owner. השינוי כולו CI + harness + docs:**
- **`--dart-define` flip (dev-build, ללא-קוד):** `USE_FIREBASE_BACKEND=true CATALOG_BASE_URL=… CATALOG_SERVER_SEARCH=true STUDIO_LIVE=true` — provider-switch בתבנית `orders_firebase.dart:44`. **אין נגיעה ב-`backend.dart`** (3 הדגלים נוספו ב-step 51; `backend_flag_test.dart` כבר מוכיח default-OFF/'' — זו ה-"flags-OFF parity", gate 122).
- **`.github/workflows/firebase-deploy.yml` — deploy-ordering קשיח (R2-10):** (a) **bootstrap `studioConfig/published` לפני rules-lock** (`scripts/bootstrap-studio-pointer.mjs`, idempotent create-if-absent — לעולם לא דורס publish חי); (b) **indexes = GATE** (`id: indexes`, הוסר `continue-on-error` — ה-IAM ניתן 2026-06-14); (c) **functions מגודר `if: steps.indexes.outcome == 'success'`** + הוסר `continue-on-error`; (d) **READY-poll** (Firestore Admin REST, ≤10min, fail-loud) לפני ה-functions — token-indexer/rollup לא רצים לפני ה-composite index → אין `FAILED_PRECONDITION`.
- **CI-assertion offline (`functions/src/selftest.ts`, `npm run selftest`):** 11 checks חדשים שקוראים את ה-YAML ומוודאים את השרשרת bootstrap→rules→indexes→READY→functions + `!continue-on-error: true`. gate חדש בזרימת-הפריסה (`Functions self-test (GATE)`) — reorder או החזרת continue-on-error נכשל **לפני** שמשהו נפרס. אפס-Firebase/emulator/network (אותו חוזה כמו ה-selftest של S8).
- **NEW `scripts/compare_local_vs_flip.sh`** (📈 §8 Phase-3) — dev-helper שמריץ שני builds (local vs flip) ומדפיס diff; אדיטיבי, אפס build-impact.
- **docs:** `GATE_REGISTRY.md` (gates **121** deploy-ordering-R2-10 + **122** flags-OFF-parity, הבא-הפנוי→123) · `firestore-schema.md` (bootstrap-seed + deploy-ordering) · WIRING זה.
- **gate:** ה-`lib/` byte-identical (אין קובץ-dart שהשתנה → `flutter analyze`/`flutter test` ללא-רגרסיה by-construction) · tsc-strict (selftest) · CI-ordering 11/11. **🏁 Pillar-5 (51-68) הושלם: flags→schema→PagedQuery→config-seam→sink→publishConfig-CAS→revert-trigger→listener→snapshot→catalog-SKU→seed→search-seam→token-indexer→catalog-paged→rules→cost-guardrails→analytics/presence→deploy-ordering-flip.**

---

## עמוד-4 — עורך-AI (AI Co-Editor · שלבים 69-85) — התחיל 2026-07-07 · ✅ **הושלם 2026-07-07 (69–85 · שער #119 חי · anti-hallucination + governance #84 חתומים)**
**מטרה:** "תגיד לאפליקציה מה לשנות, בעברית" — עורך-config מעוגן-מודל מעל ה-seams הקפואים של Pillar-1 (`applyOps`/`ConfigOp`/`ElementDescriptor`). המודל **נוקב בלבד** מתוך closed-sets; Dart דטרמיניסטי בונה+מאמת את ה-diff (anti-hallucination · idiom של `manager_copilot`/`assistant_intent`). דגל `kStudioCoEditor` default-OFF ⇒ demo byte-identical. שער שמור **#119** (grounding). כל הצעדים DORMANT עד חיווט ה-cockpit (81+). (step 69 הנחית את `logic/studio/config_op.dart` — round-trip JSON מעל משפחת ה-`ConfigOp` הקפואה של P1.)

### #pillar4-s70 — עורך-AI · תפר-השאילתה הקפוא `RegistryView` + fake + מתאם-P1 אמיתי — 2026-07-07
**NEW `lib/logic/studio/registry_view.dart`:** ה-seam היחיד שדרכו כל ה-pillar מקרקע את ה-closed-sets. `abstract RegistryView` עם 5 שאילתות: `elementIds()` · `propKeysFor(id)` · `allowedValues(id, propKey)` · `actionIdsFor(id)` · `componentTypes()` (כולן `Set<String>`, **fail-closed** — id/prop לא-מוכר → סט ריק, לעולם לא throw, לעולם לא pass-all) + `frozen()` (תוספת-א §9 — snapshot immutable כדי ש-race בין prompt-build ל-parse יראה תמונת-registry אחת).
- **שני מימושים** (משמעת ה-fake-gateway של `ClaudeGateway`, `claude_functions.dart:56-67`): `FakeRegistryView.of({ids, propKeys, allowedValues, actionIds, componentTypes})` — fake in-memory מהסטים המוזרקים בדיוק (§6; סטים unmodifiable ⇒ closed-set לא ניתן להרחבה) · **`ElementRegistryView`** — המתאם ה**אמיתי** מעל `kElementRegistry` הקפוא של Pillar-1 (R1-2): `propKeysFor`=שמות `editableProps` · `allowedValues`/`actionIdsFor`=שדות ה-descriptor · `componentTypes`=ריק עד ה-palette (step 73). **זה הקובץ היחיד שמייבא טיפוס-registry קונקרטי של Pillar-1** — כל שאר קבצי-הסטודיו תלויים ב-`RegistryView` בלבד (DoD §8 — "אם הצורה זזה, רק המתאם משתנה").
- **NEW `test/studio_registry_view_test.dart`:** `registryViewContract(label, RegistryView Function())` — **חוזה משותף חובה (R2-#15)** של אינווריאנטים מבניים (סטים לא-null אידמפוטנטיים · never-throws · **fail-closed** על id/prop לא-קיים · frozen שומר את כל משטח-השאילתה), **רץ מול ה-fake וגם מול המתאם-האמיתי-הקפוא** ⇒ fake לא יכול self-certify (fake "נדיב מדי" נכשל באינווריאנט ה-fail-closed). + קבוצה: fake מחזיר-בדיוק-המוזרק · קבוצה: adapter ממפה את ה-descriptor הקפוא נאמנה.
- **DORMANT + adaptation:** data טהור, אפס widget/gateway/provider; אף קובץ ב-`lib/` לא מייבא אותו עדיין ⇒ tree-shaken ⇒ byte-identical תחת כל דגל. ה-detail (pre-S3.K) דמיין את הקובץ נוחת **לפני** Pillar-1; מאחר ש-P1 כבר נחת, ה-`ElementDescriptor` הקפוא הוא מקור-ה-grounding האמיתי — ולכן ה"מתאם האמיתי" המובטח נשלח **כאן** בקובץ-הפרודקשן (לא רק fake), וזה מה שמאפשר ל-`registryViewContract` לרוץ מול הרישום-האמיתי.
- **gate:** `studio_registry_view_test` ירוק (חוזה × {fake, real} + 2 קבוצות ממוקדות) · `flutter analyze` 0 · `git grep` מאשר `registry_view.dart` = המייבא היחיד של `ElementDescriptor` בשכבת `logic/studio`. הבא: s71 (matchers closed-set `matchElementId`/`matchPropKey`/… exact→longest-contained, null-on-miss).

### #pillar4-s71..s79 — עורך-AI · שרשרת ה-grounding (מתומצת) — 2026-07-07
7 קבצי-לוגיקה טהורים, כולם DORMANT (אף קובץ ב-`lib/` לא צורך אותם ⇒ tree-shaken ⇒ byte-identical):
- **s71** `registry_view.dart` +matchers `matchElementId`/`matchPropKey`/`matchValue`/`matchActionId`/`matchComponentType` (exact→longest-contained→null; fuzz 4000× מול fake+real).
- **s72** NEW `action_catalog.dart`: 7 ActionIds מעוגנים ל-effect אמיתי; `matchScreenId` מול 38 מסכי no-arg (17 typed-arg מואפרים); closed-by-omission (אין auth/nav-structure, שער #84).
- **s73** NEW `component_palette.dart`: 6 תבניות (button/textBlock/badge/divider/infoCard/linkRow), `allowedContainers` מול `ElementKind`, `requiredProps`, `optionalAction` מול קטלוג-72.
- **s74** NEW `edit_prompt.dart`: `studioEditSystem` + scope דו-שלבי <8000 תווים (`claude.ts:40`); דקדוק-ops = 6 התגיות האמיתיות (setText/setEmoji/setHidden/setOrder/setStyle/setAction).
- **s75** NEW `edit_intent.dart`: `parseConfigEdit` — total, never-throws, truncation-guard (finishReason + brace-balance), כל שדה→matcher→drop; fuzz 6000× (fake+real) אפס-זריקות. שער שמור **#119**.
- **s76** `edit_intent.dart` +`expandScope`/`kStudioMaxBatch=25`/`buildScopeEdit`: המודל נוקב token, Dart מרחיב ל-ids אמיתיים (no-kind seam → `every:ns` + `scope:actionable` proxy); תקרת-batch מוקדמת.
- **s77** NEW `edit_safety.dart`: `validateSafe`/`SafetyVerdict{applied,blocked}` — kImmutable דוחה-הכל · רצפת עסק-קריטי (אי-הסתרת מחיר/"אשר הזמנה") · WCAG-AA contrast · color-subset (R1-9) · action legality · fail-closed. צבעים מ-`BsTokens` SSOT (אפס hex גולמי). advisory — נאכף-שוב בשרת (R1-1).
- **s78** `edit_safety.dart` +רצפת-נראות-לפי-פרסונה (`roleProvider` String?, null=קבלן, לא BsRole enum) + `kStudioSessionBudget=60` + `kStudioMaxRegistryFraction=0.25` + `kStudioSoftBatchWarn=15`; `kStudioMaxBatch=25` מיובא לא-מוגדר-מחדש.
- **s79** NEW `diff_preview.dart`: `summarizeDiff → List<DiffLine>` — שורות עברית טהורות, broadcast→"N שינויים", group-by-`ConfigOp.kind`, blocked-count "נחסמו K", RTL בלי hard-LTR; כל DiffLine נושא את ה-op המקורי.
- **gate כללי:** כל צעד — `flutter analyze` 0 + הטסט שלו + guard-set + color-ratchet (נכשל רק על `ring_dive_screen.dart` הקיים-מראש) ירוקים; studio suite +392.

### #pillar4-s80 — עורך-AI · דגל `kStudioCoEditor` + `studioCoEditorProvider` (3 צירים) — 2026-07-07
**`backend.dart` +`const kStudioCoEditor = bool.fromEnvironment('STUDIO_CO_EDITOR')`** (default-OFF, idiom של `kClaudeAi`/`kStudioLive`; דורש גם `useFirebaseBackend`). **NEW `lib/logic/studio/co_editor_gate.dart`:** `studioCoEditorProvider` מחזיר record 3-צירים **בלתי-תלויים** — `enabled`=`kStudioCoEditor && useFirebaseBackend` · `ai`=`claudeGatewayProvider != null` · `manager`=`boardAuthProvider?.role == BoardRole.manager` (§9 — guard ה-manager-only מרוכז כאן ל-step 81). pillar-on/gateway-off = מצב חוקי-מובחן (§4). **NEW `test/studio_gating_test.dart`:** default-OFF byte-identical (`kStudioCoEditor==false`, `enabled==false`) + 3 הצירים false בברירת-מחדל · **שער-רגרסיה §10** — `STUDIO_CO_EDITOR` בשום workflow ב-`.github/`. **DORMANT:** אף מסך לא צורך את ה-provider ⇒ tree-shaken (byte-identical). `flutter analyze` 0 · gating + `backend_flag` ירוקים. הבא: s81 (StudioScreen cockpit + route + off-states — תחילת החיווט הגלוי).

### #pillar4-s81 — עורך-AI · Studio cockpit hero + `StudioScreen` shell + off-states (הצעד הגלוי הראשון) — 2026-07-07
**`manager_dashboard_screen.dart` +hero מגודר-קומפילציה:** `if (kStudioCoEditor) const _StudioHero()` ליד `_CopilotHero` (§4). `kStudioCoEditor` הוא `const bool.fromEnvironment` false, כך שהתנאי const-false **ו-`_StudioHero`** (מופנה רק שם) עוברים tree-shake → הקוקפיט החי **byte-identical** להיום. ציר ה-`manager` (runtime) נבדק **בתוך** ה-hero (`studioCoEditorProvider.manager`), לא כשער חיצוני (אחרת ה-hero היה מתקמפל לכל בילד). **NEW `lib/screens/studio_screen.dart`:** `StudioScreen` (ConsumerStatefulWidget) + `static Route<void> route()` (idiom `manager_copilot_screen.dart:32`); **route-guard §10 fail-closed** — role≠manager → `WelcomeScreen(boardRole: manager)` (mirror `manager_dashboard_screen.dart:87`, לא דף-שגיאה); shell 3 טאבים (🤖 עורך-שפה / 🛠️ בונה ידני / 🔒 כללים), panes placeholder ("בקרוב" + מטרה) — s82 ממלא בונה-ידני · s83 עורך-NL. **off-state §4:** טאב co-editor מציג `AiOffState` כש-`studioCoEditorProvider.ai`=false (gateway null); הבונה-הידני **תמיד שמיש** בלי gateway (§8). **§9:** badge "ניסיוני" על ה-hero + deep-link שפותח את הבונה-הידני כטאב ברירת-מחדל (הנתיב שתמיד עובד). כל הצבעים מ-`BsTokens` (color-ratchet — אפס `Color(0x` גולמי ב-`studio_screen.dart`). **`test/studio_gating_test.dart` +2:** flag-OFF→אין hero (`Key('studio-hero')` findsNothing גם עם session מנהל — הקומפייל-גייט מנצח את בדיקת-התפקיד) · compile-gate מתועד; 3 הבדיקות הישנות ירוקות. `manager_dashboard_screen_test` נשאר ירוק (hero מגודר-OFF → dashboard ללא שינוי). `flutter analyze` 0 · guard-set + color-ratchet ירוקים. הבא: s82 (בונה ידני no-model — pick→prop/נראות/רכיב/פעולה→preview→confirm→undo דרך `P1.applyOps`).

### #pillar4-s82 — עורך-AI · בונה ידני no-model (pick→prop/נראות/רכיב/פעולה→preview→confirm→undo) — ה-MVP של ה-pillar — 2026-07-07
**NEW `lib/screens/studio_component_builder.dart`:** `StudioComponentBuilder` (ConsumerStatefulWidget) — עריכת no-code שעובדת עם `kClaudeAi` **OFF** (הבונה **לעולם** לא קורא ל-`claudeGatewayProvider`; §8). **הזרימה (§2):** בחר אלמנט (מעל `ElementRegistryView.builtIn()` מעל `kElementRegistry`) → בחר עריכה — prop (טקסט `SetText` · אמוג׳י `SetEmoji` · צבע-סגנון `SetStyle` מ-`allowedValues(id,'color')`) · נראות `SetHidden` · פעולה (`kActionCatalog`; מסכי-typed-arg **מאופרים** "צריך פרמטרים — לא זמין", R1-5 — לא נעלמים) · רכיב (`kComponentPalette`, `validateAddComponent` — תצוגה מקדימה בלבד) → **preview** (`validateSafe`→`summarizeDiff` מחושב **חינם** בכל שינוי, §6) → **confirm** (tap יחיד tracked → **P1 `applyOps` פעם אחת**, R1-4) → **undo/redo** (`configStoreProvider.notifier.undo()/redo()` — ה-undo-stack של P1, ה-SSOT; §9). **האינווריאנט (R1-4 · DoD §8):** כתיבה **רק** דרך `applyOps` — **אין** `apply` P4-מקומי (מאומת ב-`git grep`); ה-op-stack של ה-UI (`_mirror`) הוא **mirror לתצוגה בלבד**, לא מקור-אמת מקביל. **confirm-gate** במראה של `_confirmedKitTurns` (`ai_assistant_screen.dart:71,223`): `_turn`+`Set<int> _confirmedTurns` → double-tap לא כותב פעמיים; מועברים **רק** `verdict.applied` (חסומים לעולם לא מגיעים ל-`applyOps`). **פיוס-משפחה-קפואה (מתועד):** משפחת `ConfigOp` של P1 היא 6 ה-Set-ops בלבד — **אין** `AddComponent`, לכן קטגוריית "רכיב" היא preview מאומת (תופעל עם שער ה-AddComponent של P1); צבע/פעולה על ה-seed-registry (ש-`allowedValues`/`allowedActions` שלו ריקים) נחסמים כראוי ע"י `validateSafe` (fail-closed) ומוצגים כ-"נחסמו K" — ה-backstop עובד. **§10 draft badge:** תג "טיוטה" קבוע (Studio נוגע ב-DRAFT בלבד; publish = שער P1 נפרד). כל הצבעים מ-`BsTokens` (color-ratchet — אפס `Color(0x` גולמי). **mount:** `studio_screen.dart` — הטאב הידני (`_manualTab`=1 ב-`IndexedStack`) מציג `const StudioComponentBuilder()` (במקום ה-placeholder); שאר ה-shell ללא שינוי. **NEW `test/studio_screen_behavior_test.dart` (§5):** preview-לפני-apply · `applyOps` פעם-אחת + double-tap-לא-כופל (spy מונה קריאות מעל `configStoreProvider.overrideWith`) · undo-דרך-P1-stack · typed-arg-GREYED-not-selectable (`ListTile.enabled==false`, `onTap==null`) · usable-בלי-gateway. `studio_gating_test` + `manager_dashboard_screen_test` נשארים ירוקים. `flutter analyze` 0 · guard-set + color-ratchet ירוקים. הבא: s83 (חיווט פאנל ה-NL — ask→parse→safe→preview→confirm, off-state כן).

### #pillar4-s83 — עורך-AI · חיווט פאנל ה-NL (ask→parse→safe→preview→confirm) + off-state כן — 2026-07-07
**`lib/screens/studio_screen.dart` — הטאב 🤖 (index 0) מולא:** `_CoEditorPane` הפך ל-`ConsumerStatefulWidget`. **off-state §4:** `ai==false` (gateway null) → `AiOffState` המפנה לבונה-הידני (שעדיין **שמיש תמיד**, §8); `ai==true` → פאנל ה-NL החי. **הזרימה (§2):** utterance → **Stage-A** `gw.ask(studioScopePrompt)` → `classifyScope` מקרקע ל-token סגור, **ambiguous→null→"צריך הבהרה"** (R1-7, לעולם לא ניחוש) → **Stage-B** `gw.ask(system: studioEditSystem, prompt: studioEditPrompt(scope), maxTokens: kStudioEditMaxTokens)` → `parseConfigEdit(reply, registry, finishReason: null)` (ל-`ClaudeResult` **אין** finishReason → הישענות על brace-balance guard) → **truncated→"לא הצלחתי"** (R1-10, לא preview חלקי) · **ops ריק→"מה התכוונת?" + droppedCount** (§9, לא תיבה אילמת) → `validateSafe`→`summarizeDiff(verdict.applied, registry, verdict:)` → preview עברית עם **ה-scope בראש** ("מתוך: …" דרך `scopeHe`, R1-7) + חסימות עם נימוק. **האינווריאנט (R1-4 · DoD §8):** **המודל לעולם לא מפעיל כתיבה** — ה-gateway מחזיר ops, הפאנל מציג אותם כ-PREVIEW בלבד; `ref.read(configStoreProvider.notifier).applyOps(verdict.applied)` נקרא **רק** מ-confirm-tap מפורש (אותו נתיב-כתיבה של s82), עם confirm-gate `_turn`+`Set<int> _confirmedTurns` → double-tap לא כותב פעמיים. **guards §4:** `if (gw==null || text.isEmpty || _loading) return;` (חוסם submit כפול mid-flight; `onSubmitted` עוקף את disable-הכפתור → ה-guard הוא ה-backstop) · `if (!mounted) return;` אחרי **כל** await · 200-empty→retry כן (לא תיבה ריקה) · debounce 400ms client-side (§10, מתחת ל-40/min). utterance מקופל+capped ע"י `promptSafeText` **בתוך** `studioScopePrompt`/`studioEditPrompt` (injection-lever §7.9). כל הצבעים מ-`BsTokens` (color-ratchet — אפס `Color(0x` גולמי ב-`studio_screen.dart`). **`test/studio_screen_behavior_test.dart` +6 (§5):** gateway-null→`AiOffState`+manual-usable · **המודל לעולם לא מפעיל `applyOps`** (fake gateway מחזיר ops → preview; spy: 0 applies אחרי ask, 1 אחרי confirm; double-tap לא כופל) · scope בראש ה-preview (dy) · truncated→"לא הצלחתי" (אין preview) · empty→retry כן · ambiguous→"צריך הבהרה" (Stage-B לא נשאל) · `||_loading` חוסם double-submit (fake עם `Completer` gate). 4 בדיקות s82 + `studio_gating_test` + `manager_dashboard_screen_test` נשארים ירוקים. `flutter analyze` 0 · guard-set + color-ratchet ירוקים. הבא: s84 (מודל rules/automation סגור + `parseRule` + מסך rules ידני/NL).

### #pillar4-s84 — עורך-AI · מודל rules/automation סגור + `parseRule` + מסך rules ידני (advisory read-only) — 2026-07-07
**NEW `lib/logic/studio/rules_model.dart`** (Dart טהור · אפס Widget/gateway/provider/Firebase-symbol — מייבא רק את טיפוסי-הדאטה `Order`/`ManagerAnalytics`): מודל `Rule{trigger, RuleCondition{field,op,value}, action}` כש**כל slot הוא closed-set** (§6) — `kRuleTriggerIds` (`order.stuck`/`order.new`/`order.open`/`order.delivered`) · `kRuleConditionFields` (`ageDays`/`sum`/`items`) · `kRuleOps` (`>` `>=` `<` `<=` `=`) · `kRuleActionIds` (`notify.manager`/`notify.contractor` read-only + `flag.order`/`suggest.reorder` `mutating:true`). כל id נושא label עברי (`RuleTrigger`/`RuleField`/`RuleAction`).
- **`parseRule(String) → Rule?` — עוד מופע של ה-TOTAL parser (§6, מראה של `parseConfigEdit`):** brace-extract (`indexOf('{')`/`lastIndexOf('}')`) → `jsonDecode` בתוך `try` → כל token מאומת מול ה-closed-set שלו דרך matcher (`_matchClosed` — **העתק 1:1 של idiom step-71** exact→longest-contained→null) → **trigger/field/op/action מומצא → drop כל ה-rule (null)** · value לא-מספרי → drop · terminal `catch (_) → null` — **לעולם לא throw, לעולם לא rule לא-מעוגן**. mutating-action **מנתח** (לא נזרק ב-parse — נדחה ב-execution מאחורי אותו confirm-gate של `ai_assistant_screen.dart:208-229`).
- **`toJson`/`fromJson` ל-`Rule`+`RuleCondition` (§10)** — round-trip identity; **הפיוס:** ל-`ConfigDoc` הקפוא של P1 **אין slot rules** (grep מאשר config_node/doc/store), ומאחר שהכללים read-only advisory הם **לא** round-trip-ים דרך ה-draft הקפוא — המודל מחזיק toJson/fromJson **משלו** (ל-P1-integration עתידי), וה-working rules יושבים ב-local state במסך.
- **`evalRuleAdvisory(Rule, {orders, analytics, now}) → int` — טהור + READ-ONLY (§9 · האינווריאנט §4/§8):** סופר כמה `Order` תואמים כרגע (trigger ∧ condition) מעל `List<Order>` **בלתי-משתנה** — לא מחזיק notifier, לא קורא setter, לא ממיר מצב. `order.stuck`=`isOpen`, `ageDays`=`now-createdAt` (seed עם `createdAt==null`→0). ה-action **לא רלוונטי** לספירה (גם mutating רק **סופר** ב-Phase-1).
**NEW `lib/screens/studio_rules_screen.dart`** (`ConsumerStatefulWidget`): בונה ידני — trigger → condition (field/op/value) → action, **הכל מ-closed-sets** (pills בסגנון manager-toggle); **פעולות mutating מוצגות אך GREYED/deferred** (`onTap:null` + הערה "מוקפאות — ידרשו אישור", מראה R1-5 — לא נעלמות). **advisory preview §9:** "כרגע N הזמנות תואמות" ע"י `evalRuleAdvisory` מעל `ref.watch(ordersEngineProvider)`/`ref.watch(managerAnalyticsProvider)` (idiom הקריאה `manager_copilot_screen.dart:53-64`). **האינווריאנט (DoD §8):** אפס mutation על הזמנות — `ref.watch` בלבד, **אף פעם** ה-notifier; `git grep` מאשר ריק. כל הצבעים מ-`BsTokens` (אפס hex גולמי). **הפיוס-tab:** ה-tab 🔒 כללים (index 2) היה placeholder ("רצפת-בטיחות / מה ה-Studio רשאי לשנות") — **הוחלף** ב-`const StudioRulesScreen()`; מסגרת רצפת-הבטיחות שורדת כ-sub-note בראש. `_RulesPane`+`_Placeholder` המתים הוסרו (אין tab-placeholder יותר).
**NEW `test/studio_rules_test.dart` (§5):** round-trip "תקועה >2 ימים→התרע למנהל"→`Rule(order.stuck, ageDays>2, notify.manager)` + `toJson`→`fromJson` identity · **invented trigger/field/op/action/value → drop (null), never throws** (מראה ל-parseConfigEdit invented-drop) · **read-only advisory** — count נכון + `identical(engine.state, before)` (מצב מנוע-ההזמנות ללא-שינוי אחרי eval) · closed-set governance (2 mutating בדיוק). `studio_screen_behavior`/`studio_gating`/`manager_dashboard_screen` נשארים ירוקים. **gate:** `flutter analyze` 0 · guards (studio/ + catalog_static + state_loaded) ירוקים · color-ratchet **−1 = ONLY `ring_dive_screen.dart`** (הקיים-מראש; הקבצים החדשים אפס hex). הבא: s85 (רישום שער #119 + injection-sanitize assertions + governance #84 audit + protocol docs).

### #pillar4-s85 — עורך-AI · CAPSTONE · רישום שער #119 + governance #84 audit + injection-sanitize + docs — 2026-07-07
**NEW `test/studio/gate_119_test.dart`** (מראה של `gate_118_test` — סריקת-מקור/דאטה בזמן-טסט, לא רק fake): **רושם 3 אינווריאנטים** שחותמים את Pillar-4, כולם מול המקורות **האמיתיים-הקפואים** של P1:
- **(א) governance #84 — closed BY OMISSION:** שום capability של auth / role-grant / HR / permission / claim ב-**אף closed VOCABULARY set** של הסטודיו — מה שהמודל/הבונה **רשאי לנקוב** ולכן לבצע: `actionCatalogIds()` · `kNavScreenIds` · `componentTypeNames()` · `kRuleTriggerIds` · `kRuleActionIds` (+`kRuleConditionFields`). detector `_isCapabilityForbidden` (idiom של `_isForbidden` ב-`studio_action_catalog_test`) עם **anti-vacuous** — יורה על `auth.login` השתול (חובה §4) + `grantRole`/`hr.hire`/`permission.set`/`claim.add`/`role.grant`, ו**לא** יורה על vocab לגיטימי. **הפיוס (אמת-הקוד):** (1) ה-**registry** של P1 נושא `auth.login.cta`/`auth.logout` — זו **תשתית-UI קפואה** (`kImmutable`, `element_registry.dart:298`) שה-safety-layer **מסרב לערוך**, לא capability; לכן ה-#84-property שלו = "כל identity-UI קפוא + אפס privilege-GRANT" (נבדק ב-`_isIdentityMutation` שאינו יורה על ה-UI הקפוא), ו**נסרק בנפרד** מ-vocabulary (סריקת `auth` גולמית הייתה מסמנת בטעות את מנגנון-ההגנה עצמו). (2) `RoleRequestsInboxScreen` הוא **יעד-ניווט לגיטימי** (מעבר למסך-מנהל קיים לא מעניק כלום · למסך יש auth-gate משלו) — לכן `role` גולמי **מכוון לא-נמצא** ברשימת-האסורים.
- **(ב) injection-sanitize:** utterance/label עוין (newlines · tabs · bidi · "התעלם מההוראות") **מקופל (whitespace collapse) + capped** ע"י `promptSafeText` (`prompt_sanitize.dart:19`) לפני שיגיע ל-prompt — שני הידיות שמגיעות ל-prompt: **שורת-הוראה חדשה** ו**length context-stuffing** (מראה של cap-test של `manager_copilot`/`prompt_sanitize`). anti-vacuous: label תמים עובר as-is.
- **(ג) grounding:** `parseConfigEdit` **מפיל כל id/prop/value/action מומצא** מעל `ElementRegistryView.builtIn()` האמיתי, **לעולם לא throws**, בעוד עריכה מעוגנת (`cart.cta`) **שורדת** (anti-vacuous). ה-**FUZZ הממצה** (אלפי תשובות, ∀op כל שדה∈registry או ריק) של gate-119 חי בקבוצה "parseConfigEdit — property-invariant fuzz (§10, gate-119 REQUIRED)" ב-`studio_edit_intent_test.dart`, רץ מול ה-fake **וגם** מול `ElementRegistryView.builtIn()` (R2-15) — הקובץ הזה re-invokes מעבר-אינווריאנט קטן כדי להיות self-contained.
**`knowledge/GATE_REGISTRY.md`:** **#119 מסומן ✅ מיושם** (שורה 13, מראה של #118) עם מצביע-הטסט. **#119 שמור-מראש ל-P4 → אין bump ל"הבא הפנוי" (נשאר 123; 121/122 נלקחו ב-Pillar-5 s68).** `knowledge/STATUS.md`/`ROADMAP.md` — שורת "עמוד-4 הושלם · שער #119 חי" + governance-snapshot (§10 — סופר את ה-closed-sets + ה-capabilities הנעדרות, עקבות-ביקורת ל-#84 בין sessions).
**`.githooks/pre-commit` לא-נגוע במכוון** (57KB · no-op בענף · סיכון-מיותר ל-capstone) — **שער-119 נאכף דרך חבילת-הטסטים** (`flutter test test/studio/`), לא דרך ה-hook. **אפס שינוי ב-`lib/`** (זה capstone של test+registry+docs). **gate:** `flutter analyze` 0 · `gate_119` + grounding + `studio_rules`/`studio_registry_view` ירוקים · `knowledge_protocol_test` (#94) ירוק · guards (studio/ + catalog_static + state_loaded) ירוקים · color-ratchet **−1 = ONLY `ring_dive_screen.dart`** (קיים-מראש; הקובץ החדש אפס hex). **עמוד-4 (69–85) הושלם — עורך-ה-AI המעוגן חתום end-to-end: closed-sets → matchers → parse → validateSafe → preview → confirm, עם anti-hallucination + governance #84 נאכפים ב-commit-time.**

## עמוד-3 — מודיעין-לקוח חי (Live Customer Intelligence · שלבים 86-100) — התחיל 2026-07-07
**מטרה:** שכבת-אנליטיקה **מגודרת-הסכמה, ברירת-מחדל כבויה, פרטיות-תחילה** — טקסונומיה → bus → sink batched → actorKey אנונימי → instrumentation → funnel/segments לפי uid → presence → טאב-מנהל 5 + journey + שער-פרטיות #120 + erasure-sweep. שער #120 שמור-מראש (analytics-PII). **החלטה (2026-07-07):** כל החלקים הגלויים-למשתמש מגודרים ב-compile-const `kIntelLive` (default OFF) → הדמו byte-identical, כמו כל שאר הסטודיו; ההדלקה ב-100 מאחורי אישור-בעלים.

### #pillar3-s86 — פרטיות: הסכמה-מדעת + ברירת-מחדל-DENY + version-gate — 2026-07-07
**`lib/state/app_settings.dart`:** ברירת-מחדל **`privAnalytics: false`** (:119, היה `true` — תיקון-הבאג של forward-on-לכל-משתמש-ישן) + read `priv['analytics'] == true` (:259, absent/null⇒false); שדה חדש **`consentedPolicyVersion`** (int, default 0) + **`privPresence`** (bool, default false) — שניהם ב-ctor/copyWith/toJson/fromJson (5 אתרים). **`lib/data/legal_texts.dart`:** ניסוח-אמת (אנליטיקה מגודרת · ברירת-מחדל כבויה · רק אחרי הסכמה) + **`const kCurrentPolicyVersion = 1`** + `kLegalLastUpdated` מעודכן. **`lib/data/repositories/backend.dart`:** **`const kIntelLive = bool.fromEnvironment('INTEL_LIVE')`** (:253, default OFF, idiom של `kStudioLive`). **NEW `lib/screens/consent_modal.dart`:** מודאל חד-פעמי version-gated; על "אני מסכים" → כתיבה **אטומית** של `privAnalytics=true` + `consentedPolicyVersion=kCurrentPolicyVersion` (copyWith יחיד). **NEW `lib/state/intel/consent_gate.dart`:** `analyticsForwardEnabled` = `consentedPolicyVersion>=kCurrentPolicyVersion && privAnalytics && useFirebaseBackend && kIntelLive` (bump-גרסה מאפס הסכמה — תיקון-13). **`lib/screens/home_shell.dart`:** ה-trigger `if (kIntelLive) maybeShowConsentModal(...)` — **COMPILE-GATED** (const-false → הענף + כל ה-consent surface tree-shaken → shell byte-identical, דפוס `_StudioHero` של s81). **tests:** `test/intel/consent_flow_test.dart` (לפני-הסכמה→inert · אחרי→enabled · אחרי-bump→inert-שוב) + `test/legal_screen_test.dart`. **gate:** analyze 0 · full-suite `+4374 ~5 -13` (13-בסיס בדיוק, אפס-רגרסיה מהתיקון-ברירת-מחדל) · knowledge_protocol ירוק · אפס raw Color.

### #pillar3-s87..s99 — ROLL-UP · שכבת-המודיעין המלאה + שער-פרטיות #120 + erasure-sweep שלם — 2026-07-08
**ROLL-UP מרוכז (s87–99, נדחה ל-s99):** שכבת מודיעין-לקוח **מגודרת-הסכמה · uid-keyed · erasable**, כולה **INERT off-backend/pre-consent** (הדמו byte-identical — `NoopIntelSink`/`NoopPresenceWriter`/`NoopActorStitchWriter` + `kIntelLive` const-false).
- **טקסונומיה + buffer + bus (s87–89):** `lib/state/intel/intel_event.dart` (`IntelEvent` immutable · **`toWire()` משמיט `displayName` by-construction**, R1-4 — רק `actor_key`/`uid`/`session_id`/`screen`/`props`/`at` על-החוט) · `intel_events.dart` (`IntelEvents` taxonomy + `allowedProps` — מפתחות scalar בלבד, `q_len`/`q_hash` לעולם-לא raw-query) · `intel_log.dart` (ring buffer מקומי, always-on) · `intel_bus.dart` (`IntelBus.track`/`identify` — fan-out 3-כיווני, READ-only, never-re-raise).
- **sink + actor-key + stitch (s90–91):** `intel_sink.dart` (`FirestoreIntelSink` batched N/T/paused + requeue + cap · **cloud_firestore מבודד לקובץ היחיד הזה**) · `actor_key.dart` (`actorKeyProvider` = uid-או-anon-uuid · `ActorStitch` → `identify` bridge + persist **`actorStitch/{uid}`** מאחורי consent+backend gate — R1-3, מזין את ה-erasure).
- **instrumentation + פונקציות טהורות (s92–96):** `screen_view.dart` (RouteObserver) · catalog/store funnel events (שורות additive) · `logic/intel/funnels.dart` (`analyzeIntel` + stuck/abandon/dead-end) · `segments.dart` (`segmentsByActor`/`retentionCohorts` — keyed by **uid/actorKey לא-שם**, R2-#12).
- **session + presence + מסך-מנהל + journey (s97–99A):** `session_tracker.dart` (clone של `ConnectionStatusNotifier` · always-on local session · presence heartbeat מאחורי double-gate customer-only) · `presence.dart` (`Presence` heartbeat · `presenceLive` freshness · `PresenceWriter` port ללא-`displayName` param) · `intel_read.dart` (4 providers manager-gated · **שמות resolved owner-side, לא מ-`displayName` של האירוע**) · `intel_tab.dart` (טאב-מנהל 5) · `manager_dashboard_screen.dart` `JourneyTimeline` (ציר-מסע join-by-**uid/actorKey**, same-name-separate).
- **🔒 שער-פרטיות #120 (analytics-PII) — NEW `test/studio/gate_120_test.dart`** (מראה `gate_118`/`gate_119` — סריקת-מקור בזמן-טסט): (א) surface-הסריאליזציה (`toWire`+writers) = **closed-set פסאודונימי** (allowlist 10 מפתחות: `name`/`actor_key`/`uid`/`session_id`/`screen`/`props`/`at`/`anonKeys`/`last_beat`/`expire_at`) · (ב) `_looksLikePii` denylist על כל map-key ב-`lib/state/intel/`+`lib/logic/intel/` (email/phone/full_name/address/raw-query/credential) · (ג) `'displayName'` **נעדר** כ-wire-key מכל השכבה (R1-4) · (ד) anti-vacuous (`email`/`full_name`/`user_query`/`displayName` שתולים → יורים; `name`/`q_hash`/`actor_key` → לא). **`knowledge/GATE_REGISTRY.md:13` #120 ✅ מיושם** · **`.githooks/pre-commit` לא-נגוע במכוון** (57KB · no-op בענף) — **#120 נאכף דרך הטסט** (בדיוק כמו #119 ב-s85). **אין bump ל"הבא הפנוי" (נשאר 123 — #120 היה שמור-מראש).**
- **🧹 erasure-sweep שלם (זכות-מחיקה תיקון-13 §14):** **NEW `lib/state/intel/erasure.dart`** — executor Dart **טהור** (`eraseSubject(uid, {reader, deleter})` + `ErasurePlan`/`ErasureReader`/`ErasureDeleter` ports, Firebase-free/testable) שמוחק על **key-set רב-מפתחי `{uid, ...anonKeys}`** (anonKeys מ-`actorStitch/{uid}`, R1-3): **events** `actor_key∈{uid,...}` · **presence/{uid} וגם presence/{actorKey}** · **sessions** (אם קיים) · **displayName→''** · **actorStitch/{uid}** עצמו. **`functions/src/deleteAccount.ts`** — הרחבת ה-GDPR callable ב-`purgeIntelForSubject(uid)` שמריץ את **אותו key-set בדיוק** מול Firestore חי (best-effort + paginated כמו `purgeMultiPartyReferences`; אודיט `intelPurged`). **NEW `test/intel/erasure_completeness_test.dart`** (חובה §5): seed anon-pre-stitch + uid events + presence×2 + displayName-row + `actorStitch/{uid}` → sweep → **אפס שאריות בכל קולקציה** (כולל ה-anon-pre-stitch, מגיע דרך actorStitch) + anti-vacuous (נושא-אחר שורד).
- **gate:** `flutter analyze` **0** · `erasure_completeness_test`(3) + `gate_120_test`(6) + `journey_timeline_test` + `knowledge_protocol_test`(#94) ירוקים · `functions` **`tsc --noEmit` 0** + harness `studio.test.ts` 74/74 + `selftest.ts` 82/82. **🏁 עמוד-3 (86–99) חתום: הסכמה→taxonomy→bus→sink→actor-key/stitch→instrumentation→funnel/segments→session/presence→טאב-מנהל+journey→#120→erasure. הכל consent-gated · uid-keyed · erasable; ההדלקה ב-100 מאחורי אישור-בעלים.**

### #studio-s100 — 🏁 GA-lock · safe-by-default capstone (Studio 100%) — 2026-07-08
**הצעד האחרון של הסטודיו. אפס-`lib/` — capstone של test+docs בלבד (byte-identical by-construction).**
**NEW `test/studio/gate_123_ga_safety_test.dart`** (שער #123): מוכיח מכנית שהסטודיו נשלח **רדום**.
(A) כל 6 דגלי-ה-Pillar (`kStudioFlag`/`kStudioLive`/`kCatalogServerSearch`/`kCatalogBaseUrl`/
`kStudioCoEditor`/`kIntelLive`) נטענים לברירת-מחדל בטוחה (false/'') בבנייה ללא `--dart-define` —
כלומר האסרשן על ה-const **הוא** האסרשן על ערך-הבנייה-הנשלחת · ה-guard המורכב `useCatalogServerSearch`
(=`kCatalogServerSearch && useFirebaseBackend`) = false ללא backend חי (טסטים לא מאתחלים Firebase ⇒
`Firebase.apps` ריק ⇒ שום עמוד לא נדלק). (B) **closed-set self-maintaining** — סריקת-מקור של
`backend.dart`+`studio_flags.dart` ל-`const … k(Studio|Intel|Catalog)… = …fromEnvironment(...)`;
**כל** דגל-Pillar חייב להופיע בסט-המאושר, כך שדגל-Pillar חדש שיתווסף ללא assertion בטוחה **יפיל** את
השער — רשת-הבטיחות לא מתיישנת. (C) anti-vacuous (הסריקה מוכחת לא-ריקה).
**NEW `knowledge/STUDIO_GA.md`** — מקור-האמת ל"בנוי מול חי": מטריצת-שלמות 5-עמודים · אינווריאנט-הכיבוי
(איזה דגל מדליק מה) · רצף-ההדלקה **בשליטת-בעלים** (merge→main → Flutter cutover → backend deploy →
staged flag-flip → אישור-בעלים פר-שלב) · מה **לא** נכלל ב-100% במכוון. נרשם ב-`README.md` (אנטי-יתום D-015).
**`knowledge/GATE_REGISTRY.md`:** #123 ✅ + **"הבא הפנוי" → 124** (הפעם bump אמיתי — #123 לא היה שמור-מראש).
**`knowledge/DECISIONS.md` D-017:** "built 100%, dormant, one owner-gated flip from live". **`.githooks/pre-commit`
לא-נגוע** (capstone של test+docs; #123 נאכף דרך חבילת-הטסטים כמו #119/#120). **gate:** `flutter analyze` **0** ·
`gate_123`(3/3) + `knowledge_protocol_test`(#94) ירוקים · אפס raw Color · אפס שינוי `lib/` ⇒ אפס-רגרסיה by-construction.
**🏁🏁 הסטודיו (No-Code) הושלם 100% end-to-end — 5 עמודים בנויים, מוכחים-רדומים, byte-identical, צעד-אישור-בעלים אחד מהחיים.**
