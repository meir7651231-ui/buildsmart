# RegressionPanelScreen

- **screen:** `regression_panel_screen`
- **role:** composer

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "🔬 מרכז בדיקות רגרסיה" · `regression_panel_screen.t01` ✅
- **cfgText** "בודק קטלוג · chips · מאתר · מנוע תאימות/התקנה · state · ניווט · wiring" · `regression_panel_screen.t02` ✅

## חיבורים · connections (5)

- **reads** · `watch` → `regressionStatusProvider`
- **reads** · `watch` → `filteredSummaryProvider`
- **reads** · `watch` → `summaryByCategoryProvider`
- **reads** · `watch` → `regressionFilterProvider`
- **reads** · `watch` → `filteredResultsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
