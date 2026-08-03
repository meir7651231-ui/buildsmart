# _ManageTab

- **screen:** `manager-dashboard`
- **role:** section

## עצם · object (15)

> registry 13 · mapped 13/13 · **unregistered 2**

- **cfgText** "🛠️ שליטה מלאה על אפליקציית הקבלן — כל שינוי מתעדכן מיידית." · `manager.manage.intro` ✅
- **cfgText** "🎉 אין משימות הממתינות לאישור." · `manager_dashboard_screen.approvals_empty` ✅
- **cfgText** "אין בקשות חופשה." · `manager_dashboard_screen.vacations_empty` ✅
- **text** "שינוי שם קטגוריה מעדכן את כל המוצרים שבה." · — לא-רשום
- **cfgText** "עריכת האביזרים המשלימים של כל מוצר — בחירת מוצר חושפת את עץ האביזרים שלו." · `manager_dashboard_screen.producttree_intro` ✅
- **text** "כל מוצר נושא עץ אביזרים משלימים (חובה / אופציונלי)." · — לא-רשום
- **cfgText** · `manager_dashboard_screen.regression_intro` ✅
- **cfgVisible** · `manager.manage.regression.open` ✅
- **cfgText** "🔬 פתח מרכז בדיקות רגרסיה" · `manager.manage.regression.open` ✅
- **cfgText** · `manager_dashboard_screen.roleassign_intro` ✅
- **cfgVisible** · `manager.manage.roles.open` ✅
- **cfgText** "🔑 פתח שיוך תפקידים" · `manager.manage.roles.open` ✅
- **cfgText** · `manager_dashboard_screen.approvals_intro` ✅
- **cfgVisible** · `manager.manage.approvals.open` ✅
- **cfgText** "📋 פתח בקשות אישור" · `manager.manage.approvals.open` ✅

## חיבורים · connections (16)

- **reads** · `read` → `vacationRequestsProvider`
- **reads** · `read` → `workerNotifsProvider`
- **reads** · `read` → `chatEngineProvider`
- **action** · `showToast` → `showToast`
- **reads** · `watch` → `managerAnalyticsProvider.select((a) => a.catalogCategories)`
- **reads** · `watch` → `pendingApprovalTasksProvider`
- **reads** · `watch` → `vacationRequestsProvider`
- **reads** · `watch` → `featureFlagsProvider`
- **reads** · `read` → `tasksProvider`
- **action** · `push` → `RegressionPanelScreen`
- **action** · `showManagerRoleAssignSheet` → `showManagerRoleAssignSheet`
- **action** · `push` → `RoleRequestsInboxScreen`
- **action** · `push` → `TradeBuilderHomeScreen`
- **action** · `push` → `OrgSetupWizardScreen`
- **reads** · `watch` → `pendingRoleRequestsProvider`
- **reads** · `watch` → `tasksProvider`

## התנהגות · behaviour (2)

- **onTap** → _verb_ `Navigator.of(context).push(TradeBuilderHomeScreen.route())` → navigate → TradeBuilderHomeScreen
- **onTap** → _verb_ `Navigator.of(context).push(OrgSetupWizardScreen.route())` → navigate → OrgSetupWizardScreen

## floor · external functions (8)

- `bsOnAccent`
- `cfgRadius`
- `onApprove`
- `onReject`
- `promptRejectReason`
- `setState`
- `sort`
- `taskPhotoWidget`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 2 unregistered — "שינוי שם קטגוריה מעדכן את כל המוצרים שבה." · "כל מוצר נושא עץ אביזרים משלימים (חובה / אופציונלי)."
