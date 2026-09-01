# חוזה · usableConnector

**מוצא:** `buildsmart/app_flutter/lib/logic/install_engine.dart:322-323` (‏`_usableConnector`, verbatim, חוק-4).
עוגן-שורה מאומת (28.8): ‏`:322` = `bool _usableConnector(LipskeyCatalogProduct p) =>` ·
‏`:323` = `flowRole(p) == FlowRole.connector && kVerifiedSpecs[p.sku] != null;`.
(הערת-מחצבה: כותרת-הטיוטה ציינה 495-497 — צילום ישן; העוגן החי הוא 322-323.)
דוק-מקור (‏:319-321): מוצר רשאי להיות מוכנס-אוטומטית כמחבר-אמצע-קו רק אם הוא
מחבר-זרימה אמיתי (לא קבוע/אביזר) **וגם** בעל גיאומטריה מאומתת (בלי התאמות
name-inference רופפות ב-BOM אוטומטי). שימוש במקור: שערי מסלול-החיפוש (‏:537, ‏:597).

## הכרעת-קידום (טיוטה-קשה, הכרעה 1 — שכן ⇒ שקע)
שני השכנים קרסו לשקעי-פרדיקט (בדפוס `can_connect.verifiedCompat`; אפס אטום-מייבא-אטום):
- `flowRole(p) == FlowRole.connector` ⇒ שקע `isFlowConnector(sku)` — כך אין הכפלת
  `enum FlowRole` (שחי באטום `flow_role.dart`); הקופסה מחווטת: `(sku) => flowRole(sku, cat) == FlowRole.connector`.
- `kVerifiedSpecs[p.sku] != null` ⇒ שקע `hasVerifiedSpec(sku)` — המפה הגלובלית
  (דאטה) נשארת מחוץ למנוע; הקופסה מחווטת: `(sku) => verifiedSpecs[sku] != null`.

## חתימה
```dart
bool usableConnector(
  String sku, {
  required bool Function(String sku) isFlowConnector,
  required bool Function(String sku) hasVerifiedSpec,
});
```

## קלט
- `sku` — SKU המוצר (‏`p.sku` במקור).
- `isFlowConnector` — שקע: האם תפקיד-הזרימה של המוצר הוא connector (מגלם `flowRole(p) == FlowRole.connector`, מקור:323).
- `hasVerifiedSpec` — שקע: האם ל-SKU ספק-גיאומטריה מאומת (מגלם `kVerifiedSpecs[p.sku] != null`, מקור:323).

## פלט
`bool` — true ⇔ שני השקעים true (AND קצר-חישוב: `isFlowConnector` false ⇒ `hasVerifiedSpec` לא נקרא — סמנטיקת `&&` של המקור).

## דוגמאות (עוגן install_engine.dart:322-323 · תפקידים מ-flowRole :310-317)
| # | sku | תפקיד-זרימה (קטגוריה) | ספק-מאומת | פלט |
|---|-----|------------------------|-----------|-----|
| 1 | 77PIPE01 | connector (‏'אביזרי נחושת') | כן | **true** |
| 2 | 77PIPE99 | connector (‏'ברכיים') | לא (name-inference) | false |
| 3 | 77TOILET1 | fixture (‏'אסלות וכיורים') | כן | false |
| 4 | 77701185 | accessory (מתלה, ‏_accessorySkus:304) | כן | false |
| 5 | UNKNOWN | accessory (‏'חבקי תליה') | לא | false |
| 6 | (קצר-חישוב) | לא-connector | — לא-נקרא | false |
