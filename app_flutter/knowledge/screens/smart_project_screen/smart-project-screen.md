# SmartProjectScreen

- **screen:** `smart_project_screen`
- **role:** composer

## עצם · object (10)

> registry 9 · mapped 9/9 · **unregistered 1**

- **cfgText** "🏗️ פרויקט חכם" · `smart_project_screen.t01` ✅
- **cfgVisible** · `smart_project_screen.t02` ✅
- **cfgText** "📅 בחר יום" · `smart_project_screen.t02` ✅
- **cfgVisible** · `smart_project_screen.t03` ✅
- **cfgText** "‹ יציאה" · `smart_project_screen.t03` ✅
- **text** "🗓️" · — לא-רשום
- **cfgText** "אין ימי עבודה בתוכנית" · `smart_project_screen.t04` ✅
- **cfgText** "כשתוגדר תוכנית עבודה — ימי העבודה יופיעו כאן" · `smart_project_screen.t05` ✅
- **cfgText** "בחר יום" · `smart_project_screen.t06` ✅
- **cfgText** "✓ הושלם" · `smart_project_screen.t07` ✅

## חיבורים · connections (6)

- **reads** · `watch` → `smartProjectProvider`
- **reads** · `watch` → `smartProjectProgressProvider`
- **reads** · `watch` → `activeProjectProvider`
- **writes** · `toggle` → `smartProjectProvider`
- **action** · `showToast` → `showToast`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`

## התנהגות · behaviour (1)

- **build** → _formula_ `title = active.name.isEmpty ? … : …` → text: 'הפרויקט שלי — מאפס עד מסירה' | '${active.name} — מאפס עד מסירה'

## floor · external functions (5)

- `addAll`
- `buildDayStages`
- `cfgRadius`
- `clear`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onSmartProject(…) callback instead of direct smartProjectProvider write
- **gaps:** 1 unregistered — "🗓️"
