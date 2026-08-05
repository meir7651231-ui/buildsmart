# SPEC-catalog-to-server — פירוק‑מיקרו מלא (קטלוג + חנויות → שרת)

> נגזר מ‑סקירת‑3‑חוקרים על שדות‑המנועים (12/7) + רשימת‑המשימות. כל שורה = unit‑אחד · DoD‑בודד · [agent]/[אתה=console]. ביצוע `claude/whats-happening-LyY9G` · push רק על "תדחוף".
> **מה זה:** מהפך של `SPEC-server-connect.md` S3.K (ששם הקטלוג נשאר bundled בכוונה). עכשיו הקטלוג הדינמי + **שכבת‑חנויות חדשה** (מחיר/מלאי) עוברים לשרת, והמנועים קוראים משם — **בלי לשכתב מנוע אחד**.
> **עיקרון:** drop‑in דרך ה‑Repository (`bundled`→`server`) + **cache‑pattern** (הורדה‑פעם‑אחת · sync‑reads מ‑cache · re‑sync‑בשינוי) → UI ומנועים ללא‑שינוי · אופליין נשמר · עלות‑DB נמוכה.
> **גידור:** `useServerCatalog` (= `kCatalogBaseUrl` set + `useFirebaseBackend`) + `kSeedFreshBackend` — **שניהם כבר קיימים רדומים** · default OFF = byte‑identical.
> **שימוש‑חוזר (לא לבנות מאפס):** `TradeProduct`/`trade_schema.dart` · `authored_products_firebase.dart` (`toDoc`, collection `catalogProducts`) · `catalog_paged.dart` (`CatalogPagedBrowse.bundled()`/server) · `FirestoreCachedRepo<T>` (base מ‑S2.2) · `kTradeImport` (trade_builder_flags) · `registerPolyrollSpecs()`.

---

## מפת‑המקור (מאומת מהקוד — מה עובר)
- **מוצר = 16 שדות** — `LipskeyCatalogProduct` (`lib/data/lipskey_catalog.dart:4`). כל 1,879 ב‑`kCatalogProducts` (`polyroll_catalog.dart:1513`).
- **מפרט‑חיבורים = טבלה נפרדת** — `VerifiedSpec` ×890 (`lipskey_verified_connections.dart`) + PPR ב‑runtime.
- **עבודות/ערכות = עץ נפרד** — `SmartProduct/SmartBrand/SmartAcc/SmartStage` (`smart_tree.dart`), מקושר לפי `sku`.
- **facets נגזרים‑מהשם** — `productType/connectionGender/connectionMethod/connectionSizes...` (getters ב‑lipskey_catalog). "חינם" אם השם טוב.
- **מסחרי = חדש** — אין מחיר‑אמת (מנוחש מ‑`categoryHe` ב‑`price_estimate.dart`/`priceFor`) · אין מלאי · חנויות‑דמו (`contractor_seeds.dart` `ScanItem/StoreOffer`).

---

## C0 · תשתית וגידור (חוסם‑הכל)
| ID | משימה | מי | DoD |
|---|---|---|---|
| C0.1 | מיפוי `TradeProduct` (`trade_schema.dart`) + `authored_products_firebase.toDoc` מול 16 השדות + dims + 4 השכבות | agent | `catalog-schema.md` |
| C0.2 | הגדרת 5 collections: `products`·`verified_specs`·`recipes`·`stores`·`inventory` | agent | schema doc + מבנה‑שדות לכל doc |
| C0.3 | לאמת שהדגלים `useServerCatalog`/`kSeedFreshBackend` קיימים ו‑OFF; להוסיף `kCatalogBaseUrl` בקונפיג | agent | דגלים OFF · analyze 0 |
| C0.4 | Security Rules: `products`/`verified_specs`/`recipes` קריאה‑ציבורית‑write‑מוגן · `inventory` write רק ל‑owner‑store | agent | rules deployed · deny‑by‑default נשמר |
| C0.5 | **test:** דגל OFF → `CatalogPagedBrowse.bundled()` · byte‑identical · regression ירוק | agent | golden/regression PASS |

## C1 · הפרוסה הדקה (Thin Vertical Slice)  ⭐ שער‑ההוכחה
*20 מוצרים end‑to‑end. אם C1.7–C1.10 עוברים → הארכיטקטורה מוכחת. אם לא → עוצרים לפני C2.*
| ID | משימה | מי | DoD |
|---|---|---|---|
| C1.1 | לבחור ~20 SKUs מגוונים (כולל 118220 המורכב, מ‑5 קטגוריות, כולל צנרת + לא‑צנרת) | אתה+agent | רשימת‑SKUs |
| C1.2 | סקריפט‑מיגרציה: 20 מוצרים `kCatalogProducts`→`products/{sku}` (16 שדות · dims כמספרים) | agent | 20 docs ב‑Firestore · תואמי‑`toDoc` |
| C1.3 | `verified_specs` של אותם 20 (רק צנרת) → `verified_specs/{sku}` | agent | specs עלו · ends/material/temp |
| C1.4 | 2 חנויות‑דמו `stores/{id}` + `inventory/{store}_{sku}` (מחיר·מלאי) | agent | 2×20 inventory docs |
| C1.5 | לחווט Repository למשוך את הפרוסה מהשרת (הדלקת `catalog_paged` server‑mode דרך base‑cache) | agent | האפליקציה מציגה 20 מהשרת |
| C1.6 | שכבת‑cache: הורדה‑פעם‑אחת → מקומי (Hive/persist) · re‑sync רק ב‑`updatedAt` חדש | agent | פתיחה‑2 = 0 קריאות‑DB |
| C1.7 | **test:** חיפוש + צלילה (ring/plain/axis) על דאטת‑השרת == אפוי | agent | תוצאות זהות |
| C1.8 | **test:** השוואת‑חנויות "זמין ב‑2 · הזול 38₪" מ‑`inventory` | agent | נרנדר נכון |
| C1.9 | **test:** שינוי מחיר ב‑Firestore → מתעדכן באפליקציה בלי‑גרסה | agent | live‑update < re‑sync |
| C1.10 | **test:** אופליין — עובד מה‑cache בלי רשת | agent | טיסה‑מטוס PASS |

## C2 · מיגרציה מלאה של הקטלוג
| ID | משימה | מי | DoD |
|---|---|---|---|
| C2.1 | סקריפט‑מיגרציה כל 1,879 → `products` (ליפסקי 935·פולירול 774·חוליות 170·חמים) | agent | 1,879 docs · count‑verify |
| C2.2 | כל 890 `verified_specs` → `verified_specs` (כולל `registerPolyrollSpecs` שנרשם ב‑runtime) | agent | 890+ docs |
| C2.3 | `smart_tree` recipes → `recipes/{key}`, אביזרים/מותגים מקושרים לפי `sku` | agent | recipes עלו · sku‑join עובד |
| C2.4 | **test‑זהות:** diff מלא דאטת‑שרת מול אפוי (16 שדות · specs · recipes) | agent | 0 diffs (regression) |
| C2.5 | **perf:** פתיחת‑קטלוג‑מלא מהשרת+cache < יעד‑זמן; קריאות‑DB חד‑פעמיות | agent | benchmark PASS |
| C2.6 | **test:** כל המנועים עוברים על דאטת‑שרת (finder/dive/compat/standards/tools/global‑search) | agent | חבילת‑טסטים ירוקה |

## C3 · שכבת החנויות האמיתית (הליבה‑החדשה — מה שהמתכנת הצביע עליו)
| ID | משימה | מי | DoD |
|---|---|---|---|
| C3.1 | מודל `Store{id,name,area,logo,contact}` + repo (base‑cache) | agent | stores נטענות |
| C3.2 | מודל `Inventory{storeId,sku,price,stock,updatedAt}` + repo — לב הרב‑חנותיות | agent | inventory‑by‑sku query |
| C3.3 | מנוע השוואת‑חנויות אמיתי — **להחליף** `contractor_seeds` `ScanItem/StoreOffer` + `storePriceComparisonAcrossCatalog` (`contractor_tools_sheets.dart:388`) | agent | ההשוואה מ‑`inventory` |
| C3.4 | תצוגת "זמין ב‑N חנויות · הזול ב‑X · מלאי" בגיליון‑המוצר (`lipskey_product_sheet.dart`) | agent | נרנדר · owner‑locked |
| C3.5 | **להסיר** מחיר‑הניחוש: `price_estimate.dart estimatePrice` + `priceFor` (`related_info.dart:779`) → מחיר‑אמת מ‑`inventory` | agent | אין‑יותר ניחוש‑מקטגוריה |
| C3.6 | שדה `barcode` למוצר (לא קיים — `_runBarcode` מחפש לפי `sku`); סריקה→barcode→sku | agent | ברקוד‑אמיתי (אופציונלי) |

## C4 · טופס העלאה לספק (Onboarding — חולגה מזינה לבד)
| ID | משימה | מי | DoD |
|---|---|---|---|
| C4.1 | טופס‑העלאה: 16 שדות + מפרט‑חיבורים + מחיר/מלאי (reuse `product_authoring_screen.dart`) | agent | טופס עובד |
| C4.2 | ולידציה: `sku` ייחודי · dims מספריים · שדות‑חובה · אזהרת‑כפילות | agent | ולידציה חוסמת‑שגיאות |
| C4.3 | עזרה‑אוטומטית: פירוק‑שם→הצעת facets (type/gender/method) — reuse getters קיימים | agent | הצעות‑אוטומטיות |
| C4.4 | Pipeline: טופס → `products`+`inventory` (reuse `FirebaseAuthoredProductsRepository`) | agent | העלאה→חי |
| C4.5 | ייבוא‑המוני CSV/Excel — **להדליק `kTradeImport`** (Trade Builder, כבר בנוי רדום) | agent | ייבוא‑שורות עובד |

## C5 · הפעלה, ניטור והקשחה (Go‑Live)
| ID | משימה | מי | DoD |
|---|---|---|---|
| C5.1 | הדלקת הדגל בהדרגה: stage→אחוז→כולם (דרך `STUDIO_DART_DEFINES` / דגל‑ריצה) | אתה+agent | הדלקה‑הדרגתית |
| C5.2 | ניטור: עלות‑DB · latency · error‑rate · read‑count/session | agent | dashboard/alerts |
| C5.3 | Security Rules לפי‑חנות: כל חנות כותבת רק את `inventory` שלה | agent | rules‑test PASS |
| C5.4 | גיבוי‑Firestore + שחזור‑לנקודת‑זמן | אתה=console | scheduled backup |
| C5.5 | **Fallback:** שרת‑נופל → cache→bundled (האפליקציה לא נשברת) | agent | kill‑server test PASS |

---

## סדר‑הבנייה + הבשורה
`C0 תשתית → C1 פרוסה‑דקה (השער!) → C2 מיגרציה‑מלאה → C3 חנויות‑אמיתיות → C4 טופס‑ספק → C5 הפעלה.`

- **הבשורה:** הרבה מ‑C0/C1/C4 הוא **הדלקה/חיווט** של בנוי‑ורדום (הסכמה · `catalog_paged` server‑mode · `authored_products_firebase` · `kTradeImport`). ה‑**חדש‑האמיתי** = שכבת‑החנויות (C3) + ה‑cache (C1.6) + `barcode` (C3.6).
- **אף unit לא נוגע במנוע** — המנועים קוראים דרך אותו ממשק; מתחלף רק המקור (`bundled`→`server`).
- **שער‑בטיחות קבוע:** בכל שלב, דגל‑OFF = byte‑identical (C0.5).
- **חוק‑ברזל:** "אומתו" = `flutter test` **מלא** (ולא רק טסט‑הפיצ'ר) — שתי נפילות‑Play קודמות היו על זה.

## פתוח‑לבעלים (החלטות לפני C1)
1. **20 ה‑SKUs לפרוסה** — לבחור יחד.
2. **יעד‑הזמן ל‑perf (C2.5)** — מה נחשב "מהיר מספיק" לפתיחת‑קטלוג.
3. **מודל‑חנות (C3)** — האם החנויות נכנסות ידנית‑על‑ידך, או כל חנות מזינה את עצמה (onboarding נפרד).
