# תרחישי פריט-חסר/אזל · שליח · רישום (17627–18422)

## ⭐ פריט-חסר (Scenario 1) (17628–17830)
טיפול בפריט שחסר במלאי בעת ליקוט: `openMissingDecision` → `resolveMissingLine` · `notifyStoreOfDecision` (מודיע לקבלן) · **`missingProceedWithout`** (המשך-בלי) / **`missingReplace`** (החלפה). `openReplacementChoice`/`confirmReplacement`/`replacementAsNewOrder` (תחליף כהזמנה-נפרדת). `storeAdvanceFromSheet`.

## אזל-מלאי בקופה (Scenario 2) (17831–17937)
`openOutOfStockGate` → `oosSkip`/`oosReplace`. מלאי-חנות: `renderStoreStock`/`storeStockDoSearch`/`storeStockSetFilter`/**`toggleStoreStock`** (מוצר-אזל לא מוצג לקבלן בקטלוג).

## ⭐ דשבורד-שליח (17938–18277)
- `VEHICLE_RANK` (17946) = `{small:0, van:1, truck:2}`. `haulInfo`/`vehicleCanCarry` (האם הרכב נושא את ההובלה) · **`pickCourierVehicle`** (בורר-רכב, `ch-veh`).
- `renderCourier`/`renderCourierHome` (🛵 + 3 סטטים) · `chStat` · `shipStage`/`deriveOrderStageFromShipments` · `renderCourierList` · `courierDetail`/**`courierAdvance`**.

**⭐ פירוט-עומק (מ-`COURIER_DASHBOARD.md`):**
- **job ≠ order:** הזמנה מפוצלת (`shipments.length>1`) יוצרת **N jobs** (אחד per-shipment; `shipStage(o,sh)` קובע שלב-לכל-גל); הרשימה מציגה **jobs**, לא orders.
- **vehicleCanCarry(v,need)** = `VEHICLE_RANK[need] ≤ VEHICLE_RANK[v]` (רכב-גדול נושא קטן); **default = 'truck'**.
- **stage-flow + תוויות verbatim:** `ready` →"📦 אספתי מהחנות"→ `pickup` →"🚚 יצאתי לדרך"→ `transit` →"✅ נמסר ללקוח"→ `delivered`. `ACTIVE=['ready','pickup','transit']` (delivered יורד מהרשימה).
- pill-colors: ready=צהוב · pickup=כחול · transit=ירוק; split-pill "🚚 משלוח 1/3" (`fresh` פועם בפעם-ראשונה).

## Cross-tab sync (18278–18316)
סנכרון בין-טאבים/חלונות — שינוי `SYS_ORDERS` בטאב אחד מתעדכן באחרים (localStorage `storage` event).

## רישום + כניסה (18317–18382)
`isValidContact`/`checkRegistration` (אימות שם+טלפון/אימייל → ✓ + `reg-confirm`) · **`finishRegistration`** · `enterAsExisting`/`enterAsDemo` (כניסה מהירה להדגמה) · `toggleRoleDrawer` (מגירת "מי אתה?").

## Coming-soon placeholders (18383–18422)
תבניות-placeholder ל-features עתידיים (`coming-soon`/`cs-*`).

---

## 🔄 Preact — דלתא מול אב-הטיפוס
⬆️ שליח → BS-dial placeholder (`views/courier.tsx`, 12 ש׳; ראה דוח 12).
➖ **לא הומר:** תרחישי **פריט-חסר/אזל** (missing-item/OOS) · **רישום** (`checkRegistration`/`finishRegistration` — אין onboarding) · `VEHICLE_RANK`/courier-tracking · cross-tab sync.

---

## 📱 Flutter — דלתא
`sections.dart` `kCourierSections` (סקשני-שליח כעץ-dial). ➖ תרחישי פריט-חסר/אזל · רישום/onboarding · courier-tracking מלא — לא הומרו.
