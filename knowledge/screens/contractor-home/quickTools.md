# atom · quickTools · כלים מהירים   [🔵 צריך-ניתוק קל]
**class:** `_QuickTools` (:534) · `ConsumerWidget` · **kind:** section

## אלמנטים
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| כלים מהירים (:576) | — לא רשום | text | static |
| 📐 סרוק תוכנית עבודה + כתובית (:550) | — לא רשום* | action | static |
| 📦 המלאי שלי + כתובית (:556) | — לא רשום* | action | static |
| 📋 משימות העבודה + כתובית (:562) | — לא רשום* | action | static |

→ **registry: 0 · mapped: 0 · לא-רשום: 4** ⚠️ (*היעדים רשומים במסכים אחרים: `contractor_tools_sheets.scan_*`, `stock_screen.t01/t02` — אבל התוויות-בבית לא)

- **state:** Stateless
- **reads:** `siteOn=modOn('site')` · `stockOn=featOn('site','stock')` · `kProfileRawShell`
- **cross-effects:** אין (ניווט בלבד)
- **actions:** scan→`openScanPlanSheet` (:551) · stock→`Navigator.push(StockScreen.route())` (:558) · site→`openSiteHub` (:565)
- **gate:** שורות מותנות (scan אם `!kProfileRawShell` · stock אם `stockOn` · site אם `siteOn`) · `rows.isEmpty`→shrink (:571)
- **layout:** `_Pad→Column[ _SectionTitle('כלים מהירים'), for r: InkWell→Container→Row[ Text(emoji), Expanded(Column[title, sub]), chevron ] ]` (**לא** _MiniTile — כרטיסי-Row ידניים)
- **primitives:** _Pad · _SectionTitle
- **חוזה-רכיב:** props:`[tools:list<{emoji,title,sub,onTap,enabled}>]` · **untangle:** בנה את `rows` מ-prop (עם דגלי-הזמינות) במקום מ-modOn/featOn ישירות
- **gaps:** כל 4 האלמנטים לא-רשומים ב-registry (רק היעדים במסכים אחרים)
