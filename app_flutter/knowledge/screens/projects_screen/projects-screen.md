# ProjectsScreen

- **screen:** `projects_screen`
- **role:** composer

## עצם · object (10)

> registry 9 · mapped 9/9 · **unregistered 1**

- **cfgText** "🏗️ הפרויקטים שלי" · `projects_screen.title` ✅
- **cfgVisible** · `projects_screen.exit` ✅
- **cfgText** "‹ יציאה" · `projects_screen.exit` ✅
- **cfgVisible** · `projects_screen.new_project` ✅
- **cfgText** "פרויקט חדש" · `projects_screen.new_project` ✅
- **text** "🏗️" · — לא-רשום
- **cfgText** "אין פרויקטים עדיין" · `projects_screen.empty_title` ✅
- **cfgText** "צרו פרויקט חדש כדי לנהל סל, תקציב ומשימות לכל אתר" · `projects_screen.empty_sub` ✅
- **cfgVisible** · `projects_screen.empty_cta` ✅
- **cfgText** "פרויקט חדש" · `projects_screen.empty_cta` ✅

## חיבורים · connections (8)

- **reads** · `watch` → `projectsProvider`
- **action** · `push` → `BudgetScreen`
- **action** · `push` → `TasksScreen`
- **action** · `push` → `SmartProjectScreen`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `projectsProvider`
- **reads** · `read` → `smartCartProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`

## התנהגות · behaviour (3)

- **onTap** → _verb_ `Navigator.of(context).push(BudgetScreen.route())` → navigate → BudgetScreen
- **onTap** → _verb_ `Navigator.of(context).push(TasksScreen.route())` → navigate → TasksScreen
- **onTap** → _verb_ `Navigator.of(context).push(SmartProjectScreen.route())` → navigate → SmartProjectScreen

## floor · external functions (2)

- `bsOnAccent`
- `kbProjectsNodes`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
- **gaps:** 1 unregistered — "🏗️"
