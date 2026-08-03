# 🧱 הרצפה — ספריית-הפרימיטיבים (smart_home_screen)
> העלים הבלתי-פריקים. כל `verb`/`formula`/`token` בשכבת-ההתנהגות מצביע לכאן. **נכתב פעם-אחת, חוזר בכל מקום.** מתחת לזה = הפלטפורמה (Dart/Flutter/מתמטיקה) = **נתון, לא מפרקים.**

## פרימיטיבי-widget מקומיים (מבנה) → `shared/primitives.md`
`_Pad` · `_SectionTitle` · `_MiniTile` · `_EmptyCard` · `_pal(c)` (Theme→פלטה) · `_Metrics(c,s)` (הגדרות→גדלים)

## פרימיטיבי-verb (פעלים — פונקציות)
| פרימיטיב | מה עושה | מקור |
|---|---|---|
| `groupThousands(n)` | פורמט אלפים | logic/money_format.dart |
| `showToast(c,msg)` | טוסט חולף | widgets/toast.dart |
| `showLipskeyProductSheet(c,p,siblings)` | גיליון-מוצר | lipskey_product_sheet.dart |
| `openScanPlanSheet(c)` · `openSiteHub(c)` | גיליונות | contractor_tools_sheets · site_hub |
| `productImage(asset,{fit,error})` | תמונת-asset + fallback | data/product_images.dart |
| `Navigator.push` · `MaterialPageRoute` · `StockScreen.route()` | ניווט | framework · stock_screen |
| `modOn(ref,mod)` · `featOn(ref,mod,feat)` | שערי-org → bool | state/org_gates.dart |
| `CfgText(id,text)` · `CfgVisible(id,child)` | טקסט/נראות מ-registry | widgets/studio/ |
| `cfgRadius(c)` | רדיוס מוגדר | theme/config_theme.dart |
| `kOrderStageLabel[stage]` · `SmartCartLine(...)` | map-lookup · value-object | supplier_data · state/smart_cart |

## פרימיטיבי-formula (נוסחאות `_Metrics`, :67-94)
```
cols = gridColumns.clamp(2,6)            ts = textScaler.scale(1.0).clamp(1.0,1.4)
_img = {small .85 · med 1.0 · large 1.18}   _base = compact ? .82 : 1.0
cardW(b) = b·_base·_img      rowH(b) = b·_base·_img·ts      tileH = (compact?86:104)·ts
```

## providers (state — קרא/כתוב)
`catalogSettings` · `screenSections` · `mainTab`(int) · `homeDepartment`(String?) · `catalogSection`/`keyboardDiveQuery`(String) · `productFavorites` · `catalogRepository` · `smartCart` · `sysOrders`

## דגלי-const (compile-gates → tree-shake)
`kProfileRawShell` · `kAxisDive` · `kSmartProducts` · `kHomeScreenKey`/`kHomeSectionIds`/`HomeSection`

## אופרטורי-Dart/Flutter (נתון — לא מפרקים)
`.where .take .map .toList .firstWhere .first .contains .isEmpty .clamp .byName` · `?? ?: switch` · `ListView.separated · GridView · InkWell · FilledButton · SizedBox.shrink`
