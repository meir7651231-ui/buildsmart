# B2B שרשרת-אספקה (Category A) (18423–19451)

## ⭐ מתכנן-משלוחים מרובה-גלים (18447–18935)
פיצול הזמנה ל-"גלי-משלוח" נפרדים. state: `plannerShipments`/`setPlannerShipments`/`ensurePlannerShipments` · **`cartHasSplit`** · `shipLines`/`plannerLineQty`/`qtyTakenAcross`/`qtyInShip`/`setShipLineQty` (כמות-לכל-גל) · `unassignedInPlanner`.
- entry: `openCartShipPlanner`/`openOrderShipPlanner`. render: `renderShipPlanner`/`renderShipCard`.
- mutations: `setShipSlot`/`setShipSite`/`setShipHaul` · `addShipment`/`removeShipment`/`assignRemainingTo`/`resetToSingleShipment` · **`finalizeShipPlanner`**.
- item-picker: `openShipItems`/`renderShipItems`/`shipCategoryOf` · `toggleShipItem`/`setShipQty`/`bumpShipQty` · `shipBulkSelectVisible`/`shipBulkClearHere`. `renderCartShipPlan` (רצועת-סל = SSOT לאופן-המשלוח).
> מתחבר ל-`computeCheckout` (10): כל גל = שיגור-רכב נפרד, מחויב בנפרד.

## החזרות / השכרה / פקדונות (18978–19159)
- **RMA**: `openRMA`/`toggleRMAItem`/`submitRMA`/`renderRMAList`.
- **השכרת-כלים**: `RENTAL_TOOLS` (18428) · `openToolRental`/`startRental`/`returnRental`/`renderRentalList`.
- **פקדונות**: `DEPOSIT_ITEMS` (18436) · `openDeposits`/`addDeposit`/`refundDeposit`/`renderDepositList`. helpers `caMoney`/`caToday`/`caEsc`.

## חתימה דיגיטלית (19160–19219)
`openSignature`/**`initSignaturePad`** (canvas `sigCanvas`)/`clearSignature`/`saveSignature`.

## מרכז-שרשרת + MSDS + מסמכים + מכרז (19220–19451)
- `renderSupplyHub` (19220).
- **`MSDS_SHEETS`** (19230) — גיליונות-בטיחות: `{id, name, ic, hazard, risk, handling, firstAid}` (מלט-פורטלנד risk:גבוה · ממס-אקרילי דליק/רעיל). `openMSDS`/`showMSDSDetail`.
- doc-scan: `openDocScan`/**`runDocOCR`** (OCR). **gov-XML**: `openGovExport`/`buildGovXML`/`downloadGovXML` (ייצוא-ממשלתי).
- `openPriceCompare` (השוואת-מחירים בין-ספקים). **RFQ**: `openRFQ`/`submitRFQ`/`renderRFQList` (מכרז-ספקים).

---
**תובנה:** Category-A הוא שכבת-ה-B2B המלאה (שש שירותי-שרשרת ב-`view-orders` של 02: השכרה/פקדונות/RMA/RFQ/MSDS/השוואה) + המתכנן-משלוחים שמשנה את ה-checkout. הכל חי-מקומית (state בזיכרון/localStorage), חוץ מ-OCR/gov-XML שהם הדמיה.

---

## 🔄 Preact — דלתא מול אב-הטיפוס
🔧 **תיקון (grep):** שירותי-B2B **כן מופיעים ב-Preact כ-dial-leaves verbatim** — מכרז ספקים · השכרת כלים · גיליונות בטיחות (×3 כ"א). → התוכן **ported כ-leaves**; אבל הפונקציונליות (planner/RMA/RFQ/MSDS flows) = drill/toast placeholder, **לא רצה** (אין קומפוננטות-flow ב-`app/src`).

---

## 📱 Flutter — דלתא
🔧 **תיקון:** חלק מ-Category-A **כן מופיע** כ-**פריטים ב-`store_screen`** (מתוך 8 הפריטים: השכרת-כלים · פקדונות · החזרה(RMA) · מכרז-ספקים(RFQ) · גיליונות-בטיחות(MSDS)) — אך **demo-stubs** (sheet/toast בסיסי), לא ה-flows המלאים. ➖ planner/חתימה/gov-XML — לא הומרו.
