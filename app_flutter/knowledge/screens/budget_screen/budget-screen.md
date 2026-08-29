# BudgetScreen

- **screen:** `budget_screen`
- **role:** composer

## עצם · object (13)

> registry 13 · mapped 13/13 · **unregistered 0**

- **cfgText** "תקציב הפרויקט" · `budget_screen.title` ✅
- **cfgText** "פירוט הוצאות לפי קטגוריה" · `budget_screen.cat_header` ✅
- **cfgText** "＋ הוסף" · `budget_screen.add` ✅
- **cfgText** "אין קטגוריות עדיין — הקש "＋ הוסף" כדי להוסיף קטגוריה" · `budget_screen.no_cats` ✅
- **cfgText** "הוצאות לפי אתר" · `budget_screen.site_header` ✅
- **cfgText** "אין אתרים פעילים — הוסיפו פרויקט במסך הפרויקטים" · `budget_screen.no_sites` ✅
- **cfgText** "✏️ עריכת התקציב" · `budget_screen.edit_budget_btn` ✅
- **cfgText** "עריכת תקציב" · `budget_screen.editor_title` ✅
- **cfgText** "שמירה" · `budget_screen.save` ✅
- **cfgText** "− הסר הוצאה" · `budget_screen.remove_expense` ✅
- **cfgText** "＋ הוסף הוצאה" · `budget_screen.add_expense` ✅
- **cfgText** "שמירה" · `budget_screen.save_cat` ✅
- **cfgText** "🗑️ מחיקת קטגוריה" · `budget_screen.delete_cat` ✅

## חיבורים · connections (6)

- **reads** · `watch` → `budgetProvider`
- **reads** · `watch` → `siteRepositoryProvider`
- **reads** · `watch` → `ordersEngineProvider`
- **reads** · `read` → `budgetProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (10)

- **onTap** → _verb_ `ref.read(budgetProvider.notifier).addCategory()` → write → budgetProvider
- **onPressed** → _verb_ `showToast(ctx, 'יש להזין מספרים תקינים')` → toast
- **onPressed** → _verb_ `ref.read(budgetProvider.notifier).setTotals(total, spent)` → write → budgetProvider
- **onPressed** → _verb_ `showToast(context, 'התקציב עודכן')` → toast
- **onPressed** → _verb_ `showToast(ctx, 'יש להזין שם קטגוריה')` → toast
- **onPressed** → _verb_ `showToast(ctx, 'יש להזין סכום תקין')` → toast
- **onPressed** → _verb_ `ref.read(budgetProvider.notifier).saveCategory(i, name, amt)` → write → budgetProvider
- **onPressed** → _verb_ `showToast(context, 'הקטגוריה נשמרה')` → toast
- **onPressed** → _verb_ `ref.read(budgetProvider.notifier).deleteCategory(i)` → write → budgetProvider
- **onPressed** → _verb_ `showToast(context, 'הקטגוריה נמחקה')` → toast

## floor · external functions (1)

- `confirmDestructive`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
