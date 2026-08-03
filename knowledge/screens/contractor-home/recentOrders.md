# atom · recentOrders · הזמנות אחרונות לאתר   [🔵 צריך-ניתוק]
**class:** `_RecentOrders` (:826, ConsumerWidget) → `_OrderCard` (:864, **Stateless**) · `_EmptyCard` (:935) · **kind:** section→card

## אלמנטים
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| הזמנות אחרונות לאתר (:838,847) | — לא רשום | text | static |
| עדיין אין הזמנות — … (:839) | — לא רשום (empty) | text | static |
| 📦 (:892) · " פריטים" (:901) | — לא רשום | text | static |
| (כרטיסי-הזמנה) | — | card | **דינמי** (`sysOrdersProvider` · id/site/items/sum/stage) |

→ **registry: 0 · mapped: 0 · לא-רשום: 3** ⚠️

- **state:** Stateless (card = display-only, אין onTap)
- **reads:** `catalogSettingsProvider` (_metrics) · `sysOrdersProvider`
- **cross-effects:** אין · **actions:** אין (תצוגה בלבד)
- **gate/empty:** `orders.isEmpty` → `_SectionTitle` + `_EmptyCard('עדיין אין הזמנות…')` (:833)
- **layout:** `Column[ _Pad(_SectionTitle('הזמנות אחרונות לאתר')), ListView.separated(horizontal)[ _OrderCard ×orders ] ]` · card: `Column[ Row[id, 📦], site, 'N פריטים', ₪sum, pill(stageLabel) ]`
- **primitives:** _Pad · _SectionTitle · _EmptyCard · _Metrics
- **חוזה-רכיב:** props:`[orders:list]` · **untangle:** מקור-הזמנות כ-prop (`sysOrdersProvider` → קלט)
- **gaps:** כותרת + empty + 📦 + " פריטים" לא-רשומים
