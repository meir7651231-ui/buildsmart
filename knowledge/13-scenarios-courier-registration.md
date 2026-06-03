# תרחישי פריט-חסר/אזל · שליח · רישום (17627–18422)

## ⭐ פריט-חסר (Scenario 1) (17628–17830)
טיפול בפריט שחסר במלאי בעת ליקוט: `openMissingDecision` → `resolveMissingLine` · `notifyStoreOfDecision` (מודיע לקבלן) · **`missingProceedWithout`** (המשך-בלי) / **`missingReplace`** (החלפה). `openReplacementChoice`/`confirmReplacement`/`replacementAsNewOrder` (תחליף כהזמנה-נפרדת). `storeAdvanceFromSheet`.

## אזל-מלאי בקופה (Scenario 2) (17831–17937)
`openOutOfStockGate` → `oosSkip`/`oosReplace`. מלאי-חנות: `renderStoreStock`/`storeStockDoSearch`/`storeStockSetFilter`/**`toggleStoreStock`** (מוצר-אזל לא מוצג לקבלן בקטלוג).

## ⭐ דשבורד-שליח (17938–18277)
- `VEHICLE_RANK` (17946) = `{small:0, van:1, truck:2}`. `haulInfo`/`vehicleCanCarry` (האם הרכב נושא את ההובלה) · **`pickCourierVehicle`** (בורר-רכב, `ch-veh`).
- `renderCourier`/`renderCourierHome` (🛵 + 3 סטטים) · `chStat` · `shipStage`/`deriveOrderStageFromShipments` · `renderCourierList` (משלוחים: ready/pickup/transit) · `courierDetail`/**`courierAdvance`** (קדם: נאסף→בדרך→נמסר).

## Cross-tab sync (18278–18316)
סנכרון בין-טאבים/חלונות — שינוי `SYS_ORDERS` בטאב אחד מתעדכן באחרים (localStorage `storage` event).

## רישום + כניסה (18317–18382)
`isValidContact`/`checkRegistration` (אימות שם+טלפון/אימייל → ✓ + `reg-confirm`) · **`finishRegistration`** · `enterAsExisting`/`enterAsDemo` (כניסה מהירה להדגמה) · `toggleRoleDrawer` (מגירת "מי אתה?").

## Coming-soon placeholders (18383–18422)
תבניות-placeholder ל-features עתידיים (`coming-soon`/`cs-*`).
