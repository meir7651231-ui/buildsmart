# atom · favorites · מועדפים   [🔵 צריך-ניתוק]
`_Favorites` (:768) · ConsumerWidget · section

## 1 · עצם (node)
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| מועדפים (:784) | — לא רשום | text | static |
| עדיין אין מועדפים — סמן ☆… (:787) | — (empty) | text | static |
| (אריחי-מועדפים) | — | tile | **דינמי** (`productFavorites` × `catalogRepository`) |

→ **registry 0 · mapped 0 · לא-רשום 2** · **state:** Stateless

## 2 · חיבורים (edges)
```
favorites —קרא→   catalogSettings (metrics) · productFavorites · catalogRepository.allProducts
favorites —פעולה→ showLipskeyProductSheet   (FV-2)
favorites —משתמש→ _Pad · _SectionTitle · _MiniTile · _EmptyCard · _Metrics
favorites —מגודר→ products.isEmpty (ענף-empty)
```

## 3 · התנהגות (flows)
**FV-1 · build:**
`verb read` `favSkus = productFavorites` → `verb read+filter` `products = catalogRepository.allProducts().where(favSkus.contains(p.sku))` → `rule onEmpty` `if products.isEmpty → _EmptyCard('עדיין אין מועדפים…')` → אחרת `verb map-grid` (`cols=m.cols` · `tileH=m.tileH`) → `_MiniTile(star, p.nameHe)`

**FV-2 · onTap אריח:**
`verb read+filter siblings` `siblings = allProducts().where(q.categoryHe==p.categoryHe)` → `verb show-sheet` `showLipskeyProductSheet(c, p, siblings)` → **effect:** גיליון-מוצר (אחים = אותה קטגוריה)
*primitives:* `catalogRepository.allProducts · where · showLipskeyProductSheet`

## חוזה-רכיב + gaps
`extractable: needs-untangle` · props:`[favorites, onOpen]` · **untangle:** מקור-מועדפים כ-prop · `onOpen(product)` במקום פתיחת-sheet ישירה
**gaps:** 'מועדפים' + empty לא-רשומים
