# atom · smartTree · עץ חכם   [🔵 צריך-ניתוק]
**class:** `_SmartTreeRow` (:333) → `_SmartTreeCard` (:362) · שניהם `ConsumerWidget` · **kind:** section→card

## אלמנטים
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| 🌳 עץ חכם — אינסטלציה (:345) | — לא רשום (plain Text) | text | static |
| **הוסף לסל** (:454) | `smart_home_screen.add_to_cart` ✓ | text | static |
| מחיר לפי ספק (:371) | — לא רשום (fallback) | text | static |
| (כרטיסי-מוצר) | — | card | **דינמי** (`kSmartProducts` · שם/קטגוריה/מחיר/אמוג'י) |
| " נוסף לסל" (:445, toast) | — לא רשום | text | static |

→ **registry: 1 · mapped: 1/1 ✓ · לא-רשום: 3** ⚠️

- **state:** Stateless
- **reads:** `catalogSettingsProvider` (_metrics) · `kSmartProducts`
- **cross-effects (writes):** `smartCartProvider.notifier.add(SmartCartLine…)` (:434) → מוסיף לסל · `showToast` (:445)
- **actions:** אין Navigator (הוספה-לסל בלבד)
- **gate:** `kSmartProducts.isEmpty` → shrink (:340) · הכפתור עטוף `CfgVisible('…add_to_cart')` (:430)
- **layout:** `Column[ _Pad(_SectionTitle('🌳 עץ חכם…')), ListView.separated(horizontal)[ _SmartTreeCard ×products ] ]` · card: `Column[ image/emoji, name, cat, priceLabel, FilledButton(CfgText 'הוסף לסל') ]`
- **primitives:** _Pad · _SectionTitle · _Metrics (row) · _pal (card)
- **חוזה-רכיב:** props:`[products:list, onAddToCart:cb]` · **untangle:** מקור-מוצרים כ-prop · `onAddToCart(line)` במקום גישה-ישירה לעגלה
- **gaps:** כותרת-הסקציה + fallback + toast לא-רשומים (רק הכפתור רשום)
