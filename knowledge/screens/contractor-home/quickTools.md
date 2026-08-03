# atom · quickTools · כלים מהירים   [🔵 צריך-ניתוק קל]
`_QuickTools` (:534) · ConsumerWidget · section

## 1 · עצם (node)
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| כלים מהירים (:576) | — לא רשום | text | static |
| 📐 סרוק תוכנית עבודה + כתובית (:550) | — לא רשום* | action | static |
| 📦 המלאי שלי + כתובית (:556) | — לא רשום* | action | static |
| 📋 משימות העבודה + כתובית (:562) | — לא רשום* | action | static |

→ **registry 0 · mapped 0 · לא-רשום 4** (*היעדים רשומים במסכים אחרים) · **state:** Stateless

## 2 · חיבורים (edges)
```
quickTools —קרא→   siteOn=modOn('site') · stockOn=featOn('site','stock') · kProfileRawShell
quickTools —פעולה→ openScanPlanSheet · Navigator.push(StockScreen) · openSiteHub
quickTools —משתמש→ _Pad · _SectionTitle · _pal
quickTools —מגודר→ שורות-מותנות (פר-שער) · rows.isEmpty
```

## 3 · התנהגות (flows)
**QT-1 · build (הרכבת-רשימה מותנית):**
`verb read-gate` `siteOn=modOn('site')` · `stockOn=featOn('site','stock')` → `rule` `if !kProfileRawShell → +שורת-scan` · `rule` `if stockOn → +שורת-מלאי` · `rule` `if siteOn → +שורת-משימות` → `rule` `if rows.isEmpty → shrink`

**QT-2a · onTap scan:** `verb show-sheet` `openScanPlanSheet(c)` → **effect:** גיליון-סריקה
**QT-2b · onTap מלאי:** `verb navigate` `Navigator.push(StockScreen.route())` → **effect:** ניווט-מלאי
**QT-2c · onTap משימות:** `verb show-hub` `openSiteHub(c)` → **effect:** hub-אתר

## חוזה-רכיב + gaps
`extractable: needs-untangle קל` · props:`[tools:list<{emoji,title,sub,onTap,enabled}>]` · **untangle:** בנה `rows` מ-prop (עם דגלי-זמינות) במקום מ-modOn/featOn ישירות
**gaps:** כל 4 האלמנטים לא-רשומים (רק היעדים במסכים אחרים)
