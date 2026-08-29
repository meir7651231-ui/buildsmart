# _ManagerScreensSheet

- **screen:** `manager_screens_sheet`
- **role:** composer

## עצם · object (4)

> registry 2 · mapped 2/2 · **unregistered 2**

- **cfgText** "מעבר בין מסכים" · `manager_screens_sheet.t01` ✅
- **cfgText** "צפייה בכל לוח של המערכת — חזרה לניהול בכל רגע." · `manager_screens_sheet.t02` ✅
- **text** "🏪" · — לא-רשום
- **text** "העלאת מוצר (ספק)" · — לא-רשום

## חיבורים · connections (4)

- **reads** · `read` → `boardAuthProvider`
- **action** · `push` → `MaterialPageRoute<void>(builder: (_) …`
- **reads** · `watch` → `featureFlagsProvider`
- **action** · `push` → `SupplierOnboardingScreen`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `Navigator.of(context).push(SupplierOnboardingScreen.route('ahim_cohen'))` → navigate → SupplierOnboardingScreen

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 2 unregistered — "🏪" · "העלאת מוצר (ספק)"
