# SuppliersScreen

- **screen:** `suppliers_screen`
- **role:** composer

## עצם · object (5)

> registry 1 · mapped 1/1 · **unregistered 4**

- **cfgText** "ספקים ומותגים" · `suppliers_screen.title` ✅
- **text** "🏪" · — לא-רשום
- **text** "אין ספקים עדיין" · — לא-רשום
- **text** "ספקים ומותגים יופיעו כשקטלוג החברה ייטען" · — לא-רשום
- **text** "📦 טעינת קטלוג החברה" · — לא-רשום

## חיבורים · connections (2)

- **action** · `showCompanyCatalogImportSheet` → `showCompanyCatalogImportSheet`
- **action** · `push` → `context`

## התנהגות · behaviour (2)

- **onPressed** → _verb_ `showCompanyCatalogImportSheet(context)` → open → showCompanyCatalogImportSheet
- **onTap** → _verb_ `Navigator.push(context, LipskeyBrandScreen.route())` → navigate → context

## floor · external functions (1)

- `kbSuppliersNodes`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - KbScreen = shared component → separate atom
- **gaps:** 4 unregistered — "🏪" · "אין ספקים עדיין" · "ספקים ומותגים יופיעו כשקטלוג החברה ייטען" · "📦 טעינת קטלוג החברה"
