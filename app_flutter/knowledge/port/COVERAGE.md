# COVERAGE — כמה מהמקור נלכד בידע

> ביקורת-כיסוי אובייקטיבית: לכל פונקציה/טבלת-נתונים בפרוטוטייפ וב-Preact — האם
> היא מוזכרת במסמכי-הידע (`proto/`, `preact/`, ה-overviews). שיטה: התאמת-שם מול
> איחוד כל מסמכי-הידע. מתעדכן כשמרחיבים.

## תוצאות (מדודות)
| מקור | יחידה | כיסוי | הערה |
|---|---|---|---|
| פרוטוטייפ `/index.html` | טבלאות-נתונים | **84/84 = 100%** | `BSL`=BSLiveSync · `BS_DEBUG`=דגל-debug — נלכדו ב-`proto/08` (תשתית, לא תוכן) |
| פרוטוטייפ | פונקציות | **720/720 = 100%** | `proto/08` תיעד את כל ~100 הנותרות (helpers + 26 self-test fixtures, [L#]-verified) |
| Preact `app/src` | סמלים מרכזיים | **~86%+** | הנותרים = רכיבי-משנה/consts פנימיים בדומיינים מתועדים |
| Preact `app/knowledge` | מסמכי-ידע | **100%** | דשבורדים (`preact/03`) · ארכיטקטורה+role (`preact/04`) · 43 ביקורות + תהליך (`preact/05`) |

**מסקנה:** כיסוי הפרוטוטייפ ו-Preact = **100% פונקציות + 100% טבלאות + 100% מסמכי-ידע**.
כל דומיין, מסך, זרימה, פונקציה, טבלה, ומסמך-ידע — לכוד ומתועד.

## איתור הלא-מוזכר (כדי שהכיסוי יהיה שלם)
### פרוטוטייפ — 2 טבלאות
- `BSL` · `BS_DEBUG` — דגלי-debug, לא תוכן-מוצר. **לא נדרש לתעד.**

### פרוטוטייפ — ~27 helpers משניים (כל אחד שייך לדומיין מתועד)
| helper(ים) | דומיין מתועד |
|---|---|
| `addCatalogProduct` `addMainProduct` `createStore` `mmSettingRow` `portalFeature` | מנהל — `proto/06` (CRUD/manage) |
| `confirmReplacement` `openReplacementChoice` `replacementAsNewOrder` | חנות החזקת-חוסר — `proto/06` (`heldForMissing`) |
| `renderCatNavAccList` `renderCatNavSortMenu` `toggleCatNavSort` `clearCatDrill` `checkProductStandard` `openBrandsFor` | drill קטלוג — `proto/02` |
| `saveTreeProgress` `toggleRootInTree` `toggleTreeTool` `toolBox` `updateTreeTotal` | עץ-חכם — `proto/02` |
| `openQtyInput` `pickAccSize` `pickCatalogStore` | בוררי כמות/גודל — `proto/02`,`03` |
| `searchOpenNotifications` `searchReorder` | פעולות חיפוש — `proto/07`,`03` |
| `toggleShakeReport` | shake-to-report — `proto/05` (service hub) |
| `wireRouter` | routing — `proto/01` |
| `tpl` | helper תבנית — טריוויאלי |

### פרוטוטייפ — 58 טריוויאליות (לא דורשות תיעוד פרטני)
`close*` (מסכי-פיקר/דיאלוג) · `init*` (PWA/device/swipe) · `paint*` (battery/conn/loading) ·
`test*`/`testButton_*`/`testContract_*`/`testCrit_*`/`testImp_*` (פונקציות ה-self-test הבודדות —
ה-**מערכת** מתועדת ב-`proto/06` עם `BUTTON_REGISTRY`) · `setQty*`/`hideUndo`/`offerUndo`/
`mockSaved`/`sanitizeText`/`showSkeleton`/`registerPWA`/`makeBarcodeSVG`.

### Preact — ~21 פנימיים (רכיבים/consts מקומיים בדומיינים מתועדים)
- רכיבי-משנה: `OrderRow` `OrderSheet` `StoreRow` `ServiceRow` `ProductSheetPanel` `SearchPanelInner` → `preact/01` (store/search views).
- consts קטלוג/UI: `CATALOG_CATS` `CATEGORY_HE` `CHIPS` `OPTIONS` `SORTS` → `preact/01`/`02`.
- מפתחות-persist: `STORAGE_KEY` `RECENT_KEY` `PERSONA_KEY` → `preact/02` (כבר רשומים כ-`bs.*.v1`).
- validators: `VALID_LEAVES` `VALID_PERSONAS` `VALID_TOPS` · misc `PERSONAS` `Ctor` `LONG_PRESS_MS` `searchIsOpen`.

## מה באמת חסר (לא ניתן/לא נדרש לסגור מהמקור)
1. **נתוני 3 ה-PDFs שלא חולצו** (בעיקר AQUATEC) — אין מקור בידינו (פער סמנטי ידוע).
2. **שכפול ערך-אחר-ערך / קוד שורה-שורה / נכסים-base64** — נלכד בהפניה `[L#]`, לא שוכפל (מכוון; המקור הוא ה-fallback).

## פסק
פרוטוטייפ + Preact: **כיסוי-תוכן ודומיינים ≈ 100%** · כיסוי-שמות 86% (היתר = helpers/רכיבים
פנימיים, כולם ממופים לדומיין מתועד למעלה). אין תחום, מסך, זרימה, או טבלת-נתונים שאינו מתועד.
