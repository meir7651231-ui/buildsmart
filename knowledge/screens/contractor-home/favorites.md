# atom · favorites · מועדפים   [🔵 צריך-ניתוק]
**class:** `_Favorites` (:768) · `ConsumerWidget` · **kind:** section

## אלמנטים
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| מועדפים (:784) | — לא רשום | text | static |
| עדיין אין מועדפים — סמן ☆… (:787) | — לא רשום (empty) | text | static |
| (אריחי-מועדפים) | — | tile | **דינמי** (`productFavoritesProvider` × `catalogRepository`) |

→ **registry: 0 · mapped: 0 · לא-רשום: 2** ⚠️

- **state:** Stateless
- **reads:** `catalogSettingsProvider` (_metrics) · `productFavoritesProvider` (favSkus) · `catalogRepositoryProvider.allProducts()`
- **cross-effects:** אין
- **actions:** tile→`showLipskeyProductSheet(context, p, siblings)` (:807)
- **gate/empty:** `products.isEmpty` → `_EmptyCard('עדיין אין מועדפים…')` (:785)
- **layout:** `_Pad→Column[ _SectionTitle('מועדפים'), empty ? _EmptyCard : GridView(cross:m.cols)[ _MiniTile(star, p.nameHe, onTap:sheet) ] ]`
- **primitives:** _Pad · _SectionTitle · _MiniTile · _EmptyCard · _Metrics
- **חוזה-רכיב:** props:`[favorites:list, onOpen:cb]` · **untangle:** מקור-מועדפים כ-prop · `onOpen(product)` במקום פתיחת-sheet ישירה
- **gaps:** 'מועדפים' + empty לא-רשומים
