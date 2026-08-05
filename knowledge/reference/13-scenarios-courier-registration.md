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
- **`courierAdvance(id)`:** parsing `'BS-001'`(whole) / `'BS-001#2'`(shipment-2); `next()`: ready/preparing/new→pickup→transit→delivered. shipment-advance → **`deriveOrderStageFromShipments`** (order-stage נגזר מה-shipments); whole-advance → מסנכרן shipments. side-effect: `saveSysOrders` + storage-event (מנהל/חנות).
- **detail-sheet** (`courierDetail`): tracker + לקוח/כתובת-מסירה/מועד/פריטים/פיצול + "תכולת המשלוח" + כפתור-שלב + **📄 תעודת-משלוח** (`showDeliveryNote`).
- **courier-portal — 6 tools verbatim:** 🧭 ניווט-למשלוח (Google Maps) · 🚛 צי-רכב (`FLEET`) · ⏱️ מעקב-SLA · 🗺️ אזורי-הפצה · 📸 אישור-מסירה POD+צילום · 💬 צ׳אט-עם-חנות.

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
⚠️ **07-06: שליח נבנה כמסך-מלא** (`courier_dashboard_screen` — בורר-רכב/משלוחים/tracker/פורטל; bs_dial הוסר). courier-tracking + POD **הומרו** (`ac3073d`). [היה: BS-dial toast-stubs.] ✅ **onboarding** (welcome/profession/3-slides, `OnboardingGate`) מחליף את ה-registration של הפרוטוטייפ (ראה דוח 09).
