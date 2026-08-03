# atom · departments · מחלקות   [🔵 צריך-ניתוק]
**class:** `_Departments` (:271) · `ConsumerWidget` · **kind:** section

## אלמנטים
| טקסט | registry-ID | kind | סטטי/דינמי |
|---|---|---|---|
| מחלקות (:294) | — לא רשום | text | static |
| עוד (:321) | — לא רשום | text | static |
| (אריחי-מחלקות) | — | tile | **דינמי** (`DepartmentsScreen.departments.where(live)`) |
| בקרוב (:310) | — | text | static (**מת** — רק live עוברות ה-filter) |

→ **registry: 0 · mapped: 0 · לא-רשום: 2** ⚠️

- **state:** Stateless (אין controllers)
- **reads:** `catalogSettingsProvider` (_metrics) · `DepartmentsScreen.departments`
- **cross-effects (writes):** `homeDepartmentProvider.state = d.name` (:313) · `mainTabProvider.state = 1` (:314,322) → מעביר ללשונית-מחלקות
- **actions:** אין Navigator (החלפת-לשונית בלבד)
- **gate:** `kProfileRawShell` → shrink (:281)
- **layout:** `_Pad→Column[ _SectionTitle('מחלקות'), GridView(cross:2, extent:m.tileH)[ _MiniTile ×depts, _MiniTile('עוד') ] ]`
- **primitives:** _Pad · _SectionTitle · _MiniTile · _Metrics
- **חוזה-רכיב:** props:`[departments:list, onSelect:cb]` · **untangle:** חשוף `departments` כ-prop · `onSelect(name)` במקום כתיבה-ישירה ל-homeDepartment/mainTab
- **gaps:** 'מחלקות'/'עוד' לא-רשומים · 'בקרוב' קוד-מת
