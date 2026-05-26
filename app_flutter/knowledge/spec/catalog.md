# אפיון — מסך קטלוג (catalog_screen.dart)

## 1. מזהה ומיקום

- **קובץ:** `lib/screens/catalog_screen.dart` (≈5745 שורות). הווידג'ט הציבורי: `CatalogScreen` (`ConsumerStatefulWidget`).
- **מיקום בניווט:** ה-tab הראשון (אינדקס 0) ב-`IndexedStack` של `lib/screens/home_shell.dart` (שורה 36–39). זהו ה-tab שמוצג בעת פתיחת האפליקציה, ומגיעים אליו דרך ה-bottom nav.
- **כפתור הגדרות:** ב-app bar של ה-shell יש `_CatalogMenuButton` שפותח את `CatalogSettingsScreen.route()`.
- **providers מרכזיים שהמסך צורך (מוגדרים בראש הקובץ, ברובם `StateProvider` in-memory):**
  - `catalogSectionProvider` (`String`, ברירת מחדל `'הכל'`) — ה-section הפעיל.
  - `catalogSectionsListProvider` (`List<String>`, ברירת מחדל `['תאימות', 'חיפושים אחרונים', 'מועדפים', 'קטגוריות', 'עץ חכם']`) — רשימת ה-sections (לא כולל `'הכל'`).
  - `catalogListItemsProvider` (`Map<String, Set<String>>`) — אילו כותרות קטגוריה משויכות לכל רשימה מותאמת.
  - `searchPanelOpenProvider`, `searchQueryProvider`, `searchScopeProvider` (`'הכל'`), `recentSearchesProvider` (`List<String>`, מקס' 8) — מצב פאנל החיפוש.
  - `smartTreeCatProvider` / `smartTreeQueryProvider` — דריל בעץ החכם.
  - `catalogDrillCatProvider` — דריל ב"קטגוריות" (קומפוננטה `_CatalogDrillSection` קיימת אך לא מחווטת ל-body; ראו §10).
  - `catalogTreePathProvider` (`List<CatalogNode>`), `catalogTreeQueryProvider`, `catalogFacetProvider` (`List<String>`) — מחסנית הדריל בעץ הקטלוג בתוך ה-tab.
  - `catalogProductSortProvider` (`ProductSort`, ברירת מחדל `byOrder`) — מיון רשימת המוצרים.
  - `searchImageOnlyProvider` (`bool`) — דגל הסינון "עם תמונה" של כלי ⚙️ פילטרים בפאנל.
  - (הוסרו ה-enums/providers המתים `CatalogSort`/`CatalogFilter` — ראו §10.)
  - חיצוניים: `catalogSettingsProvider` (`lib/state/catalog_settings.dart`), `productFavoritesProvider` (`lib/state/product_favorites.dart`), `smartCartProvider` (`lib/state/smart_cart.dart`), `tabHeaderHiddenProvider` (`lib/state/dial_state.dart`).
- **מקורות דאטה:** `kCatalogCats` (`lib/data/catalog.dart`), `kLipskeyCatalog` (`lib/data/lipskey_catalog.dart`), `kCatalogTree` (`lib/data/catalog_tree.dart`), `kSmartProducts`/`kSmartTreeCats`/`smartProductsForCat` (`lib/data/smart_tree.dart`), `kSearchIndex` (`lib/data/search_index.dart`).

## 2. מטרה

מסך הקטלוג הוא נקודת הכניסה לגילוי ולעיון במוצרי בנייה: המשתמש מחפש מוצרים/קטגוריות/מסכים, מנווט (drill) בעץ קטגוריות ובעץ-חכם עד למוצר, מסנן לפי facets, ומוסיף לסל דרך גיליון מוצר. בנוסף הוא מארגן את התצוגה לרשימות section מותאמות אישית (כולל מועדפים, חיפושים אחרונים ותאימות).

## 3. מבנה ופריסה (מלמעלה למטה)

המסך RTL, light theme. ה-`build` בוחר בין כמה מצבי-על:

**מצב דריל בעץ קטלוג** (`catalogTreePathProvider` לא ריק) → `_TreeDrill`: שורת חיפוש ו-section chips נעלמות; במקומן **drill bar** קבוע (חץ חזרה + breadcrumb chips + שדה חיפוש צר ברוחב 92), ומתחתיו גוף הגלילה. ה-app bar וה-bottom nav נשארים קבועים.

**מצב רשימת מוצרים בעץ-חכם** (section = `'עץ חכם'` ו-`smartTreeCatProvider != null`) → `_SmartTreeProductList`: drill bar ירוק עם chip קטגוריה פעיל (🌳) + שדה חיפוש.

**מצב רגיל** (Column):
1. **שורת חיפוש** (`_SearchBar`) — נסתרת בגלילה למטה (מעל 50px), חוזרת בגלילה למעלה או בפתיחת פאנל. רקע `#E7E7EA`, רדיוס 24. אייקון חיפוש / חץ חזרה; chip scope (כשנבחר scope ≠ 'הכל') עם X; שדה טקסט; כפתור X לניקוי.
2. אם הפאנל פתוח → `_SearchPanel` (רקע **light** `BsTokens.cardLight` = לבן; תוקן מ-`#111111` הכהה שהיה רגרסיית light-mode) ממלא את הגוף: `_SearchToolsRow` (5 כלים), `_SearchScopeRow` (4 chips), Divider, ואז `_SearchResultsList` (אם יש query או scope) או `_RecentSearchesList`.
3. אחרת:
   - **שורת section chips** (`_SectionChipsRow`) — pill `'הכל'` קבוע + pills דינמיים מ-`catalogSectionsListProvider` + כפתור `[+]`. גם נסתרת בגלילה.
   - **גוף** (`_CatalogBody`) לפי ה-section הפעיל:
     - `'הכל'` → `_AllOverview`: בלוקי תצוגה מקדימה ("הצג הכל") עבור קטגוריות / חיפושים אחרונים / תאימות / מועדפים / עץ חכם.
     - `'עץ חכם'` → `_SmartTreeSection` (רשימת קטגוריות → רשימת מוצרים).
     - `'קטגוריות'` → `_CatalogList` (12 שורות `_CatalogRow`).
     - `'מועדפים'` → `_FavoritesSection`.
     - `'חיפושים אחרונים'` → `_RecentSearchesSection`.
     - `'תאימות'` → `InstallStudioScreen` (מוטמע).
     - section מותאם אחר → `_SectionHeader` (כותרת + ✏️) ומתחת `_FilteredCatalogList` או `_EmptySection`.

## 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור נתונים | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| שורת חיפוש | TextField | hint `'חיפוש מוצרים, קטגוריות, מסכים...'` (או `'חפש $scope...'`) | פוקוס ⇐ `searchPanelOpenProvider=true`; הקלדה ⇐ `searchQueryProvider`; submit ⇐ הוספה ל-recents (אם מאופשר) | ✅ |
| chip scope בשורת החיפוש | Chip+X | `searchScopeProvider` | X ⇐ scope חוזר ל-`'הכל'` | ✅ |
| כפתור X (ניקוי) | IconButton | — | ⇐ מנקה query | ✅ |
| חץ חזרה (פאנל פתוח) | IconButton | — | ⇐ `_closePanel` | ✅ |
| כלי 🎤 קולי | כפתור עגול | — | ⇐ `VoiceService.instance.listen`; כישלון ⇐ SnackBar `'הדפדפן לא תומך בחיפוש קולי'` | ✅ |
| כלי 📷 ברקוד | כפתור עגול | — | ⇐ `openBarcodeScanner` | ✅ |
| כלי ⚙️ פילטרים | כפתור עגול | — | ⇐ sheet "הכל / עם תמונה בלבד" → `searchImageOnlyProvider` (`filterByImage` על התוצאות החיות) | ✅ |
| כלי ↕️ מיון | כפתור עגול | — | ⇐ sheet ProductSort (ברירת מחדל/שם א-ת/שם ת-א/מק"ט) → `catalogProductSortProvider` (`_sortProducts` על התוצאות) | ✅ |
| כלי ▦ קטלוג | כפתור עגול | — | ⇐ סוגר את הפאנל + קופץ למקטע 'קטגוריות' | ✅ |
| chips scope | pills | `['הכל','מוצרים','קטגוריות','מסכים']` | ⇐ `searchScopeProvider` | ✅ |
| רשימת חיפושים אחרונים (פאנל) | ListView | `recentSearchesProvider` | tap/↖ ⇐ `searchQueryProvider`; `'נקה'` ⇐ מאפס | ✅ |
| ריק (פאנל recents) | Text | `'התחל להקליד כדי לחפש מוצרים, קטגוריות ומסכים.'` | — | ✅ |
| תוצאת index | ListTile | `kSearchIndex` (emoji/title/breadcrumb/typeLabel) | tap ⇐ ממלא query + מוסיף ל-recents | ✅ |
| תוצאת מוצר חי | ListTile + תג `'מוצר'` | `kLipskeyCatalog` (match בשם/SKU, take 40) | tap ⇐ `showLipskeyProductSheet` | ✅ |
| ריק (תוצאות) | Text | `'לא נמצאו תוצאות עבור "$query"'` / `'אין תוצאות ב$scope'` | — | ✅ |
| pill `'הכל'` (sections) | _SectionPill | קבוע | tap ⇐ section='הכל' | ✅ |
| pill section דינמי | _SectionPill | `catalogSectionsListProvider` | tap ⇐ הפעלה; long-press ⇐ תפריט (ניהול/שינוי שם/מחיקה) | ✅ |
| כפתור `[+]` | _AddPill | — | ⇐ `_openManageSheet` | ✅ |
| בלוק overview | _OverviewBlock | כותרת + badge ספירה + `'הצג הכל'` | `'הצג הכל'` ⇐ מעבר section / `_openStudio` | ✅ |
| שורת overview ריקה | Text | `'אין חיפושים אחרונים'` / `'אין מועדפים עדיין'` | — | ✅ |
| כרטיס ספק ליפסקי | Card | SKU 217861 `'סיפון אמריקאי 1¼" לבן'`; תגית `'ליפסקי ברקן'`/`'כל הקטגוריות'`/`'פרטים'` | tap מוצר ⇐ sheet; `'כל הקטגוריות'` ⇐ `LipskeyBrandScreen.route()` | ✅ (לא מוצג ב-body הנוכחי — ראו §10) |
| כרטיס "מוצר היום" | _FeaturedProductCard | `SmartProduct`; תגיות `'מומלץ'`/`'מוצר היום'`/`'ממותג מומלץ'` | stepper ± ; `'הוסף לסל · ₪…'` ⇐ `smartCartProvider.add` + toast | ✅ (לא מוצג ב-body הנוכחי — ראו §10) |
| `_CatalogRow` | InkWell | `kCatalogCats[i]` + `_kMeta[i]` (preview/time/badge) | tap ⇐ דריל (`catalogTreePathProvider`); קטגוריה ללא דאטה ⇐ node placeholder | ✅ |
| drill bar (עץ קטלוג) | Container | breadcrumb chips + שדה `'חיפוש'` | חץ ⇐ `goBack`; chip ⇐ קפיצה לרמה; X ⇐ `cancel` | ✅ |
| `_TreeCatRow` | כרטיס מסגרת כתומה | `node.title` + `_treeNodeDesc` + badge `_treeNodeCount` | tap ⇐ `openNode` (דריל / sheet smart) | ✅ |
| `_FacetRow` | כרטיס מסגרת כתומה | facet label + desc + count | tap ⇐ הוספת facet ל-`catalogFacetProvider` | ✅ |
| `_TreeComingSoon` | Center | `node.emoji` + תג `'בקרוב'` + `'הקטגוריה הזו בבנייה — תת-קטגוריות ומוצרים יתווספו בקרוב.'` | — | 🚧 |
| `_ProductsHeader` | Row | `'מוצרים'` + badge ספירה + כפתור `'מיון לפי'` | בחירה ⇐ `catalogProductSortProvider`; כפתור מותנה ב-`quickFilterBar` | ✅ |
| רשימת/רשת מוצרים | List/Grid | `LipskeyProductCard`/`LipskeyProductGridCard` | בהתאם ל-`viewMode`/`gridColumns` | ✅ |
| `_SmartTreeCatList` | ListView | `kSmartTreeCats` + emoji מ-`_catEmojis` + ספירה | tap ⇐ `smartTreeCatProvider` | ✅ |
| `_SmartTreeProductList` | ListView | `smartProductsForCat(cat)`, סינון לפי שם | drill bar ירוק; tap מוצר ⇐ `_SmartProductSheet` | ✅ |
| `_SmartProductSheet` | BottomSheet | מותג/סוג/מידה (collapsible) + פריטי חובה/אופציונליים + CTA | בחירת מותג, סינון `_filteredBrandIdx`, `'הוסף לסל · ₪$_total'` ⇐ סל + toast | ✅ |
| `_DiagramFlow`/`_StageCard` | דיאגרמה | `product.stages` | tap שלב ⇐ `_ExplodeChips` + הדגשת אביזרים | ✅ |
| `_AccRow` + ⓘ | שורת אביזר | `SmartAcc` (name/why/price) | checkbox, stepper ±, ⓘ ⇐ `_showAccInfo` (`'למה צריך:'` / `'מחיר ליחידה:'`) | ✅ |
| `_FavoritesSection` | ListView | `kLipskeyCatalog ∩ favSkus`; כותרת `'$n מועדפים'` | tap ⇐ `showLipskeyProductSheet` | ✅ |
| `_RecentSearchesSection` | ListView | `recentSearchesProvider`; `'$n חיפושים אחרונים'` + `'נקה הכל'` | tap ⇐ `LipskeyProductsScreen.openWordSearch`; X ⇐ הסרה | ✅ |
| `_ManageListsSheet` | BottomSheet | `catalogSectionsListProvider`; כותרת `'ניהול רשימות'`, subtitle `'הגדרה מראש'` | reorder, ✏️ ⇐ picker, 🗑 ⇐ מחיקה, `'יצירת רשימה מותאמת אישית'` | ✅ |
| `_ItemPickerSheet` | BottomSheet | `kCatalogCats` checkboxes; `'בחר אילו פריטים יופיעו ברשימה'` | סימון ⇐ `_selected`; `'שמירה'` ⇐ `catalogListItemsProvider` | ✅ |
| `_EmptySection` | Center | emoji + label + `'אין פריטים להצגה.\nפתחו את ניהול הרשימות והקישו ✏️ כדי לבחור פריטים.'` | — | ✅ |

## 5. מצבים (States)

- **ריק — recents בפאנל:** הודעה ממורכזת `'התחל להקליד כדי לחפש מוצרים, קטגוריות ומסכים.'`.
- **ריק — section מותאם ללא פריטים:** `_EmptySection` עם emoji `📋` והנחיה לפתוח ניהול רשימות.
- **ריק — מועדפים:** `_EmptySection` (emoji `⭐`, label `'מועדפים'`).
- **ריק — חיפושים אחרונים:** `_EmptySection` (emoji `🕐`).
- **טעינה:** אין מצב טעינה אסינכרוני במסך — כל הדאטה (`kLipskeyCatalog`, trees, index) קומפילטיבית/in-memory. `catalogSettings`/`productFavorites` נטענים מ-SharedPreferences עם defaults מיידיים, ללא spinner.
- **מלא:** רשימות/רשת מוצרים, חיפוש מחזיר index + עד 40 מוצרים חיים.
- **"לא נמצאו תוצאות":** `'לא נמצאו תוצאות עבור "$query"'` בחיפוש, בדריל עץ קטלוג ובעץ-חכם; `'אין תוצאות ב$scope'` כשיש scope אך אין query.
- **קצה — "בקרוב":**
  - קטגוריה ראשית ללא דאטת עץ → `_TreeComingSoon` (תג `'בקרוב'`).
  - ב-`_CatalogDrillCatGrid` (קומפוננטה לא-מחווטת): כרטיס מציג `'$count פריטים'` או `'בקרוב'` כש-`count==0`; וגוף ריק מציג `'בקרוב'`.
- **קצה — עץ-חכם ריק:** desc משתמש ב-fallback `'$count מוצרים בעץ'`.

## 6. חוקים עסקיים ולוגיקה

- **אינדקס מילים:** `kIndexMinWordLen = 2`; `indexableWord(w) => w.length >= 2` (`lib/data/lipskey_catalog.dart:304-305`). `lipskeyWordIndex()` בונה inverted index lazy ומדלג על טוקנים באורך 1.
- **טריגר תוצאות מוצר חיות:** מוצגות רק כש-`query.trim().length >= 2` וה-scope הוא `'הכל'`/`'מוצרים'`; match על `nameHe.contains(query)` או `sku` (case-insensitive); תקרה `take(40)`.
- **scope mapping ב-`_SearchResultsList`:** `'מוצרים'`→`category`; `'קטגוריות'`→`setting`/`menu`; `'מסכים'`→`screen`/`persona`/`action`; `'הכל'`→הכל. `SearchEntry.matches` עושה `contains` על title+breadcrumb (ללא סף אורך משלו).
- **recents:** מקס' 8 (`if (list.length > 8) list.removeRange(8, list.length)`), newest-first, dedup (remove+insert(0)). נשמר רק אם `searchHistoryEnabled`.
- **`_facetTokens`:** מסיר סוגריים/מרכאות/פיסוק, מפצל ב-whitespace, ומשאיר רק מילים `length >= 2` שאינן מכילות `"`/`″` ואינן מכילות ספרה — כדי לפצל facets לפי מילים מאפיינות בלבד.
- **`_autoFacetOptions`:** דורש `products.length > 1`; מחשב מילים משותפות לכל המוצרים (`shared`), ולכל מוצר סופר את **המילה המאפיינת הראשונה** שאינה משותפת ואינה כבר-נבחרה (break אחרי הראשונה); מחזיר אופציות רק אם `counts.length >= 2`, ממוין יורד לפי שכיחות.
- **facets מאוצרים:** `kProductFacets` מוגדר רק ל-`'מחסומי רצפה'` (3 קבוצות). `_matchesFacet`: keyword לא-null ⇐ `contains`; keyword null (`'כללי'`) ⇐ לא מכיל אף keyword אחר בקבוצה.
- **`_applyFacets`:** מחיל את `sel.length` הקבוצות הראשונות ברצף.
- **`_subtreeProducts`:** walk רקורסיבי על `lipskeyCategory` של עלי תת-העץ ⇐ כל מוצרי `kLipskeyCatalog` שב-categoryHe המתאים.
- **דריל עלה-מוצר:** עלה עם `lipskeyCategory` שיש לו מוצרים ⇐ דריל facets בתוך ה-tab; עלה עם `smartKey` ⇐ פתיחת `openSmartProductSheet`.
- **breadcrumb/ניווט:** `goBack` מסיר תחילה facet אחרון, אחרת רמת-עץ אחרונה. chips הם jump-to-level.
- **מיון מוצרים** (`_sortProducts`/`ProductSort`): `byOrder` (`'ברירת מחדל'`) / `nameAZ` (`'שם א-ת'`, `nameHe.compareTo`) / `nameZA` (`'שם ת-א'`) / `sku` (`'מק"ט'`, `sku.compareTo`).
- **`_treeNodeCount`:** branch→מס' ילדים; leaf lipskey→מס' מוצרים בקטגוריה; leaf smart→`brands.length`; אחרת→`brandIds.length`.
- **`_deriveBrandSizes`/`_deriveBrandTypes`:** מפרקים מידות (regex `[0-9][0-9.¼½¾/]*\s*["״]`) ו"סוגים" (מילה מאפיינת ראשונה) משמות מותגים; מציגים selector רק כשיש ערכים. `_deriveBrandTypes` דורש `brands.length >= 2`.
- **גרסת מחירים:** סכום sheet = מחיר מותג + Σ(מחיר אביזר נבחר × כמות) (`_total`). מחיר null ⇐ `'לפי ספק'`/`'מחיר לפי ספק'`.
- **גלילה/header:** הסתרת header בדלתא `> 6` ופיקסלים `> 50`; שחזור בדלתא `< -6` או פיקסלים `<= 2`; אנימציה 220ms.

## 7. נתונים ומקורות ושמירה

- **קטגוריות ראשיות:** `kCatalogCats` — **12 פריטים** (ה-comment בקוד אומר 11; ראו §10), כל אחד `Section{id,emoji,title}`. אותן 12 קטגוריות מופיעות גם ב-`kSearchIndex` (type `category`).
- **מוצרים אמיתיים:** `kLipskeyCatalog` (ספק ליפסקי ברקן) — שדות: `sku`, `nameHe`, `categoryHe`, `categoryEmoji`, `typeEmoji`, `brand`, `color?`, `qtyPack?`, `qtyPallet?`, `imageAsset?`.
- **עץ קטלוג:** `kCatalogTree` (`CatalogNode` עם `children`/`brandIds`/`lipskeyCategory`/`smartKey`; `isLeaf` = ללא ילדים).
- **עץ חכם:** `kSmartProducts`/`kSmartTreeCats`/`smartProductsForCat`/`smartProductByKey`; `SmartProduct` כולל `brands`, `acc`, `stages`, `mustCount`, `recBrand`.
- **אינדקס חיפוש:** `kSearchIndex` (`SearchEntry`: emoji/title/breadcrumb/type/typeLabel).
- **שמירה ל-SharedPreferences:**
  - `catalogSettingsProvider` ⇐ מפתח `'bs.catalog-settings.v1'` (JSON, persist בכל `update`).
  - `productFavoritesProvider` ⇐ מפתח `'bs.product-favorites.v1'` (StringList).
  - `recentSearchesProvider` ⇐ מפתח `'bs.recent-searches.v1'` (StringList; `RecentSearchesNotifier`, לוגיקת ה-add/cap בפונקציה טהורה `addRecentSearch`).
- **In-memory בלבד (לא נשמר, אובד ב-restart):** `catalogSectionsListProvider`, `catalogListItemsProvider`, `catalogSectionProvider`, מצבי הדריל (`catalogTreePathProvider`/`catalogFacetProvider`/`smartTreeCatProvider`/`catalogProductSortProvider`).

## 8. תלות בהגדרות (`catalogSettingsProvider`)

| הגדרה | השפעה במסך |
|---|---|
| `searchHistoryEnabled` | אם `false` — `_submit` ולחיצת תוצאת index **לא** מוסיפים ל-`recentSearchesProvider`. |
| `quickFilterBar` | אם `false` — כפתור `'מיון לפי'` ב-`_ProductsHeader` לא מוצג. |
| `viewMode` (`grid`/`list`) | קובע אם מוצרי הדריל מוצגים כ-`SliverGrid` (`LipskeyProductGridCard`) או `SliverList` (`LipskeyProductCard`). |
| `gridColumns` | מספר העמודות בתצוגת grid, עם `clamp(1,4)`. |
| `reducedMotion` | אם `true` — `_ExplodeChips` ו-`_DiagramFlow` קופצים מיד (`_ctrl.value = 1`) במקום אנימציה. |
| `imageSize` | ✅ נצרך בכרטיסי המוצר: שורת רשימה (`_ProductRow`, רוחב/גובה עמודת התמונה) ו-כרטיס רשת (`LipskeyProductGridCard` דרך `gridCardImageMetrics` — padding התמונה + גודל אמוji). |
| `compactMode` | ✅ נצרך: `_ProductRow` (margin/minHeight) ו-כרטיס רשת (גובה תיבת השם + paddings). |
| `highContrast`, `textSize` | אפקט **app-wide** (theme + `textScaler` ב-`main`), לא ספציפי למסך. |

## 9. קריטריוני קבלה (Acceptance)

- בהינתן `indexableWord` — מילה באורך `< 2` (1 תו) **אינה** נכנסת ל-`lipskeyWordIndex` (`kIndexMinWordLen == 2`).
- בהינתן חיפוש query באורך `< 2` — **אין** תוצאות מוצר חיות, גם ב-scope 'מוצרים'.
- בהינתן query שתואם שם/SKU וה-scope 'הכל'/'מוצרים' — מוצגות עד 40 תוצאות מוצר אחרי תוצאות ה-index.
- בהינתן 9 חיפושים — `recentSearchesProvider` שומר רק 8 (newest-first, ללא כפילויות).
- בהינתן `searchHistoryEnabled=false` — חיפוש/בחירה לא מוסיפים ל-recents.
- בהינתן section שאינו ברשימת המובנים וללא פריטים — מוצג `_EmptySection` עם ההנחיה הקבועה.
- בהינתן הקשה על קטגוריה ראשית ללא דאטת עץ — מוצג `_TreeComingSoon` (תג `'בקרוב'`).
- בהינתן `viewMode=grid` ו-`gridColumns=N` — רשת מוצרי הדריל עם `min(max(N,1),4)` עמודות.
- בהינתן `reducedMotion=true` — אין אנימציית explode/diagram.
- בהינתן `quickFilterBar=false` — אין כפתור 'מיון לפי'.
- בהינתן עלה lipskey עם מוצרים — `openNode` נכנס לדריל facets ולא פותח sheet ישירות.
- **רגרסיה קיימת:** `test/catalog_regression_test.dart` מריץ את `testCatalog()` (`lib/test_harness/tests/catalog.dart`) — בדיקות HARD על שלמות דאטה (אין שמות ריקים/פגומים, אין מספר תקוע, SKU ייחודי, מיפוי קטגוריה); `test/catalog_bfs_test.dart` בודק תאימות SKU. בדיקות אלו מגנות על הדאטה שהמסך צורך, לא על ה-UI ישירות.

## 10. פערים ידועים

- **קומפוננטות שאינן מחווטות ל-body הנוכחי:** `_LipskeySupplierCard`, `_FeaturedProductCard`, `_CatalogDrillSection`/`_CatalogDrillCatGrid`/`_CatalogDrillProductList` מוגדרות בקובץ אך אינן נקראות מ-`_CatalogBody`/`_AllOverview` (קוד שמור לתצוגות עתידיות / dead-ish). ⛔/🚧.
- ~~**state לא בשימוש**~~ ✅ **הוסר**: ה-enums/providers המתים `CatalogSort`/`CatalogFilter` + `_sortLabel`/`_filterLabel`/`_nextSort`/`_nextFilter` נמחקו (גם כדי לפתור את כפילות השם מול `catalog_settings.dart`). המיון/סינון של הפאנל משתמשים כעת ב-`ProductSort`/`_sortProducts` + `searchImageOnlyProvider`/`filterByImage`.
- ~~**כלי חיפוש placeholder**~~ ✅ **טופל**: ⚙️ פילטרים (סינון "עם תמונה" דרך `filterByImage`), ↕️ מיון (`_sortProducts` דרך `catalogProductSortProvider`), ▦ קטלוג (קפיצה למקטע קטגוריות) — מחווטים על תוצאות החיפוש החיות. (סינון/מיון לפי מחיר נותר ⛔ — אין דאטת מחיר.) הוסרו גם enums/providers מתים `CatalogSort`/`CatalogFilter` + `_sortLabel`/`_filterLabel`/`_nextSort`/`_nextFilter` (פתר גם את התנגשות השם עם `catalog_settings.dart`).
- ~~**הגדרות לא ממומשות במסך**~~ ✅ **טופל**: `imageSize`/`compactMode` נצרכים כעת גם בכרטיס הרשת (`gridCardImageMetrics` + paddings קומפקטיים), בנוסף לשורת הרשימה שכבר תמכה. `highContrast`/`textSize` הם אפקט app-wide (לא ספציפי למסך).
- **"בקרוב":** כל קטגוריה ראשית ללא דאטת עץ ⇐ `_TreeComingSoon`; ב-`_CatalogDrillCatGrid` קטגוריות ללא smart-products ⇐ תג `'בקרוב'`. 🚧.
- **אי-עקביות מספרית:** הערות הקוד מציינות "11 קטגוריות" בעוד `kCatalogCats` ו-`kSearchIndex` מכילים בפועל **12** (נוספו `אביזרים נלווים` + `גינון והשקיה`).
- **`_kMeta` סימולטיבי:** preview/time/badge ב-`_CatalogRow` הם דאטה מדומה קבועה (12 רשומות), לא חיה.
- ~~**חיפושים אחרונים — אובדן מצב**~~ ✅ **טופל (v3.78)**: `recentSearchesProvider` נשמר כעת ל-SharedPreferences (`bs.recent-searches.v1`) עם helper טהור `addRecentSearch` (dedup + cap 8). הגייט `searchHistoryEnabled` עדיין שולט בהקלטה.
