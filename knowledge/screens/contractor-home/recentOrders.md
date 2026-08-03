# atom · recentOrders · הזמנות אחרונות לאתר   [🔵 צריך-ניתוק]
`_RecentOrders` (:826) → `_OrderCard` (:864, Stateless) · `_EmptyCard` (:935) · section→card

## 1 · עצם (node)
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| הזמנות אחרונות לאתר (:838,847) | — לא רשום | text | static |
| עדיין אין הזמנות — … (:839) | — (empty) | text | static |
| 📦 (:892) · " פריטים" (:901) | — לא רשום | text | static |
| (כרטיסי-הזמנה) | — | card | **דינמי** (`sysOrders` · id/site/items/sum/stage) |

→ **registry 0 · mapped 0 · לא-רשום 3** · **state:** Stateless

## 2 · חיבורים (edges)
```
recentOrders —קרא→   catalogSettings (metrics) · sysOrders
recentOrders —כתוב→  —   (תצוגה בלבד)
recentOrders —משתמש→ _Pad · _SectionTitle · _EmptyCard · _Metrics · _pal · groupThousands · kOrderStageLabel
recentOrders —מגודר→ orders.isEmpty (ענף-empty)
```

## 3 · התנהגות (flows)
**RO-1 · build:**
`verb read` `orders = sysOrders` → `rule onEmpty` `if orders.isEmpty → _EmptyCard('עדיין אין הזמנות…')` → אחרת `formula` `height=m.rowH(150)` · `verb map` → `_OrderCard(width=m.cardW(160))`

**RO-2 · _OrderCard = רנדר-סטטי טהור** (display-only, **אין onTap/writes**):
`formula` `'${order.items} פריטים'` · `formula` `'₪'+groupThousands(order.sum)` · `formula` `kOrderStageLabel[order.stage] ?? ''`

→ **effect:** רשימת-כרטיסים או empty-card. **ללא אינטראקציה.**

## חוזה-רכיב + gaps
`extractable: needs-untangle` · props:`[orders]` · **untangle:** מקור-הזמנות כ-prop (`sysOrders` → קלט)
**gaps:** כותרת + empty + 📦 + " פריטים" לא-רשומים
