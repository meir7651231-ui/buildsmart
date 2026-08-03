# InstallStudioScreen

- **screen:** `install_studio_screen`
- **role:** composer

## עצם · object (23)

> registry 0 · mapped 0/0 · **unregistered 23**

- **text** "תכנון חיבור" · — לא-רשום
- **text** "בחר מה לחבר · נכין רשימת קנייה" · — לא-רשום
- **text** "סוג הקו — מה טמפרטורת המים?" · — לא-רשום
- **text** "הטמפרטורה קובעת אילו פריטי בטיחות נדרשים" · — לא-רשום
- **text** "מה אתה רוצה לחבר?" · — לא-רשום
- **text** "בחר מה אתה מתקין:" · — לא-רשום
- **text** "— או כתוב במילים —" · — לא-רשום
- **text** "בנה" · — לא-רשום
- **text** "חיבור צינור צריך 2 נקודות — כניסה + יציאה.
הוסף את הנקודה השנייה (ברז, אסלה, דוד…)" · — לא-רשום
- **text** "מחזור מים חמים" · — לא-רשום
- **text** "מים חמים מיד, בלי להמתין שיתחממו" · — לא-רשום
- **text** "הפריטים הבאים חסרים וחשובים לבטיחות:" · — לא-רשום
- **text** "🔴" · — לא-רשום
- **text** "חזור לתכנון" · — לא-רשום
- **text** "הצג רשימה בכל זאת" · — לא-רשום
- **text** "שמור פרויקט" · — לא-רשום
- **text** "ביטול" · — לא-רשום
- **text** "שמור" · — לא-רשום
- **text** "הפרויקטים שלי" · — לא-רשום
- **text** "אין עדיין פרויקטים שמורים.
בנה קו ולחץ "💾 שמור פרויקט"." · — לא-רשום
- **text** "שנה שם" · — לא-רשום
- **text** "מחק" · — לא-רשום
- **text** "שנה שם לפרויקט" · — לא-רשום

## חיבורים · connections (17)

- **reads** · `read` → `catalogSettingsProvider`
- **writes** · `state=` → `installStudioActionsProvider`
- **reads** · `read` → `chainProvider`
- **reads** · `read` → `lineMaxTempProvider`
- **writes** · `state=` → `chainProvider`
- **reads** · `watch` → `chainProvider`
- **reads** · `watch` → `lineMaxTempProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **writes** · `state=` → `lineMaxTempProvider`
- **action** · `push` → `AuditScreen`
- **reads** · `read` → `lineAccessoriesProvider`
- **writes** · `state=` → `lineAccessoriesProvider`
- **action** · `showDialog` → `showDialog`
- **reads** · `read` → `savedProjectsProvider`
- **action** · `showToast` → `showToast`
- **reads** · `watch` → `savedProjectsProvider`
- **writes** · `remove` → `savedProjectsProvider`

## התנהגות · behaviour (2)

- **onTap** → _verb_ `ref.read(lineMaxTempProvider.notifier).state = val` → write → lineMaxTempProvider
- **onTap** → _verb_ `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const Audi…` → navigate → AuditScreen

## floor · external functions (11)

- `add`
- `autoFlowFix`
- `buildInstallation`
- `buildTreeInstallation`
- `canConnect`
- `confirmDestructive`
- `connectionMethodLabel`
- `manifoldOutlets`
- `productSuitableForTemp`
- `removeAt`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 23 unregistered — "תכנון חיבור" · "בחר מה לחבר · נכין רשימת קנייה" · "סוג הקו — מה טמפרטורת המים?" · "הטמפרטורה קובעת אילו פריטי בטיחות נדרשים" · "מה אתה רוצה לחבר?" · "בחר מה אתה מתקין:" · "— או כתוב במילים —" · "בנה" · "חיבור צינור צריך 2 נקודות — כניסה + יציאה.
הוסף את הנקודה השנייה (ברז, אסלה, דוד…)" · "מחזור מים חמים" · "מים חמים מיד, בלי להמתין שיתחממו" · "הפריטים הבאים חסרים וחשובים לבטיחות:" · "🔴" · "חזור לתכנון" · "הצג רשימה בכל זאת" · "שמור פרויקט" · "ביטול" · "שמור" · "הפרויקטים שלי" · "אין עדיין פרויקטים שמורים.
בנה קו ולחץ "💾 שמור פרויקט"." · "שנה שם" · "מחק" · "שנה שם לפרויקט"
