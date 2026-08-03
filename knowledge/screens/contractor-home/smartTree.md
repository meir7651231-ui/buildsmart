# atom · smartTree · עץ חכם   [🔵 צריך-ניתוק]
`_SmartTreeRow` (:333) → `_SmartTreeCard` (:362) · ConsumerWidget · section→card

## 1 · עצם (node — מינימלי)
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| 🌳 עץ חכם — אינסטלציה (:345) | — לא רשום | text | static |
| **הוסף לסל** (:454) | `smart_home_screen.add_to_cart` ✓ | text | static |
| מחיר לפי ספק (:371) | — (fallback) | text | static |
| (כרטיסי-מוצר) | — | card | **דינמי** (`kSmartProducts`) |
| " נוסף לסל" (:445 toast) | — | text | static |

→ **registry 1 · mapped 1/1 ✓ · לא-רשום 3** · **state:** Stateless

## 2 · חיבורים (edges — קופסות)
```
smartTree —קרא→   catalogSettings (metrics) · kSmartProducts
smartTree —כתוב→  smartCart.add                      (ST-3)
smartTree —משתמש→ _Pad · _SectionTitle · _Metrics · _pal · groupThousands · productImage · showToast · CfgText · CfgVisible
smartTree —מגודר→ kSmartProducts.isEmpty (שורה) · CfgVisible('…add_to_cart') (כפתור)
```

## 3 · התנהגות (flows — trigger→steps→effect)
**ST-1 · build (שורה):**
`rule` `if kSmartProducts.isEmpty → SizedBox.shrink` · `formula` `height = m.rowH(192)` · `verb map` → `_SmartTreeCard(width = m.cardW(150))` → **effect:** רנדר/כלום

**ST-2 · build (כרטיס):**
`verb select` `rec = brands.firstWhere(b.rec, else first)` · `formula` `priceLabel = price==null ? 'מחיר לפי ספק' : '₪'+groupThousands(price)` · `rule` `imageAsset!=null ? productImage : Text(emoji)`

**ST-3 · onTap "הוסף לסל"** *(מגודר `CfgVisible`)*:
`verb build` `line = SmartCartLine(productKey: sku ?? 'smart:'+key, name, emoji, brand, price ?? 0, qty:1)` → `verb write` `smartCart.add(line)` → `verb notify` `showToast(name+' נוסף לסל')` → **effect:** עגלה מתעדכנת + טוסט
*primitives:* `firstWhere · groupThousands · SmartCartLine · smartCart.add · showToast · ??`

## חוזה-רכיב + gaps
`extractable: needs-untangle` · props:`[products, onAddToCart]` · **untangle:** products כ-prop · `onAddToCart(line)` במקום גישה-ישירה לעגלה
**gaps:** כותרת/fallback/toast לא-רשומים (רק הכפתור)
