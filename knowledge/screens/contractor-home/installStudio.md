# atom · installStudio · תכנון חיבור   [🟡 כמעט-נקי]
`_InstallStudioHero` (:621) · ConsumerWidget · hero

## 1 · עצם (node)
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| תכנון חיבור (:648) | `smart_home_screen.install_title` ✓ | text | static |
| בחר מה לחבר — נכין רשימת קנייה… (:655) | `smart_home_screen.install_sub` ✓ | text | static |

→ **registry 2 · mapped 2/2 ✓ · לא-רשום 0** ✅ **כיסוי מלא** · **state:** Stateless

## 2 · חיבורים (edges)
```
installStudio —קרא→   _pal
installStudio —פעולה→ Navigator.push(InstallStudioScreen)   (IS-2)
installStudio —משתמש→ _Pad · CfgText
installStudio —מגודר→ compatOn  ← ב-SmartHomeBody (:141), לא בפנים
```

## 3 · התנהגות (flows)
**IS-1 · build:** רנדר-סטטי (CfgText title/sub). הנראות מוכרעת ב-**המרכיב** (compat gate), לא כאן.

**IS-2 · onTap hero:**
`verb navigate` `Navigator.push(MaterialPageRoute → InstallStudioScreen())` → **effect:** ניווט למנוע-החיבור
*primitives:* `Navigator.push · MaterialPageRoute · InstallStudioScreen`

## חוזה-רכיב + gaps
`extractable: clean` · props:`[onOpen]` · **untangle:** אין (רק callback-ניווט)
**gaps:** אין ✅ — **התבנית לשאוף אליה** (2 טקסטים רשומים, gate ברור במרכיב, ניקוי מלא)
