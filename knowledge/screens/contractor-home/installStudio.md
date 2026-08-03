# atom · installStudio · תכנון חיבור   [🟡 כמעט-נקי]
**class:** `_InstallStudioHero` (:621) · `ConsumerWidget` · **kind:** hero

## אלמנטים
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| תכנון חיבור (:648) | `smart_home_screen.install_title` ✓ | text | static |
| בחר מה לחבר — נכין רשימת קנייה… (:655) | `smart_home_screen.install_sub` ✓ | text | static |

→ **registry: 2 · mapped: 2/2 ✓ · לא-רשום: 0** ✅ **האטום היחיד עם כיסוי מלא**

- **state:** Stateless
- **reads:** `_pal` בלבד (אין provider)
- **cross-effects:** אין
- **actions:** `Navigator.push(InstallStudioScreen())` (:630)
- **gate:** אין בפנים — **המרכיב** מגדר על `compatOn` (:141)
- **layout:** `_Pad→InkWell→Container(#1AFF7A18, border)→Row[ Icon(account_tree), Expanded(Column[CfgText title, CfgText sub]), chevron ]`
- **primitives:** _Pad
- **חוזה-רכיב:** props:`[onOpen:cb]` · **untangle:** אין (נקי — רק callback-ניווט)
- **gaps:** אין ✅ — **התבנית לשאוף אליה** (2 טקסטים, שניהם רשומים, gate ברור, ניקוי מלא)
