# atom · departments · מחלקות   [🔵 צריך-ניתוק]
`_Departments` (:271) · ConsumerWidget · section

## 1 · עצם (node)
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| מחלקות (:294) | — לא רשום | text | static |
| עוד (:321) | — לא רשום | text | static |
| (אריחי-מחלקות) | — | tile | **דינמי** (`DepartmentsScreen.departments.where(live)`) |
| בקרוב (:310) | — | text | static (**מת** — pre-filter live) |

→ **registry 0 · mapped 0 · לא-רשום 2** · **state:** Stateless

## 2 · חיבורים (edges)
```
departments —קרא→   catalogSettings (metrics) · DepartmentsScreen.departments
departments —כתוב→  homeDepartment = d.name   (D-2)
departments —כתוב→  mainTab = 1               (D-2, D-3) → מחליף לשונית-מחלקות
departments —משתמש→ _Pad · _SectionTitle · _MiniTile · _Metrics
departments —מגודר→ kProfileRawShell
```

## 3 · התנהגות (flows)
**D-1 · build:**
`rule` `if kProfileRawShell → shrink` · `verb filter+take` `depts = departments.where(d.live).take(3)` · `formula` `tileH = m.tileH`
*(הערה: `dim:!d.live` ו-`note:'בקרוב'` — ענפים **מתים**, כי depts כבר-מסונן ל-live)*

**D-2 · onTap אריח:**
`verb write` `homeDepartment = d.name` → `verb write` `mainTab = 1` → **effect:** מחלקה-נבחרת + מעבר-לשונית
*primitives:* `ref.read · .notifier · .state=`

**D-3 · onTap "עוד":**
`verb write` `mainTab = 1` → **effect:** מעבר-לשונית-מחלקות

## חוזה-רכיב + gaps
`extractable: needs-untangle` · props:`[departments, onSelect]` · **untangle:** departments כ-prop · `onSelect(name)` במקום כתיבה-ישירה ל-homeDepartment/mainTab
**gaps:** 'מחלקות'/'עוד' לא-רשומים · 'בקרוב' קוד-מת
