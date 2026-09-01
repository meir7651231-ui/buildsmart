# חוזה · `syntheticPipe`

מוצא: `buildsmart/app_flutter/lib/logic/install_engine.dart:1016-1041` (‏`_syntheticPipe`; חוק-4 — verbatim).

`LipskeyCatalogProduct syntheticPipe(String material, String dn, {required pipeCache, required verifiedSpecs})`
— צינור-סינתטי "לפי מטר" לחומרי-אספקה שאין להם SKU בקטלוג; המפרט נרשם ב-`verifiedSpecs`
כדי שעוזרי-התאימות/תוויות יראו אותו.

## שקעים (חוק-1/3 — הגלובליים-השכנים ⇒ פרמטרים)
- `pipeCache` ← השכן `_syntheticPipeCache` (‏install_engine.dart:1012) — `Map<String, LipskeyCatalogProduct>`.
- `verifiedSpecs` ← השכן `kVerifiedSpecs` — `Map<String, VerifiedSpec>`.

## טיפוסי-שכן מוטבעים (כלל-2)
- `EndType` (enum) · `ConnectorEnd(type, size)` — verbatim מ-`lipskey_verified_connections.dart:24,32`.
- `VerifiedSpec` — רק השדות שהפונקציה כותבת/ברירות-מחדל (sku · ends · material · maxTempC:double=40).
- `LipskeyCatalogProduct` — רק 8 השדות שהפונקציה מציבה (sku · nameHe · nameEn ·
  categoryHe · categoryEn · categoryEmoji · page · brand; ‏lipskey_catalog.dart:4).

## התנהגות (עוגני-שורה)
1. `sku = 'PIPE-$material-$dn'` (‏:1017).
2. `pipeCache.putIfAbsent(sku, builder)` (‏:1018) — **פגיעת-מטמון מחזירה את אותו מופע,
   ובלי לגעת ב-`verifiedSpecs` כלל** (ה-builder מדולג).
3. בתוך ה-builder: `verifiedSpecs.putIfAbsent(sku, …)` (‏:1019) — מפרט קיים **לא נדרס**.
4. המפרט: שני קצוות `hdpeCompression` בגודל `dn`; ‏`maxTempC = 40` ל-'HDPE', אחרת `95` (‏:1024-1028).
5. המוצר: `nameHe='צינור $material DN$dn (לפי מטר)'` · `nameEn='$material pipe DN$dn (cut to length)'` ·
   קטגוריה 'צינורות'/'Pipes'/'📏' · `page=0` · `brand='AQUATEC'` (‏:1030-1039).

## דוגמאות מספריות
- `syntheticPipe('HDPE','32', …ריקים)` ⇒ sku='PIPE-HDPE-32', nameHe='צינור HDPE DN32 (לפי מטר)',
  spec.maxTempC=40.0, ‏2 קצוות hdpeCompression '32'; המפות גדלו ל-1/1.
- `syntheticPipe('PEX','25', …)` ⇒ spec.maxTempC=95.0.
- קריאה-שנייה עם אותם ארגומנטים ⇒ `identical` למופע-הראשון; verifiedSpecs לא-שונה.

DoD: `dart run --enable-asserts new/dart/synthetic_pipe_test.dart` ⇒ exit 0.
