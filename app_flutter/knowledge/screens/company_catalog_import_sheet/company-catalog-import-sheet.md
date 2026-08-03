# _CompanyCatalogImportSheet

- **screen:** `company_catalog_import_sheet`
- **role:** composer

## עצם · object (5)

> registry 0 · mapped 0/0 · **unregistered 5**

- **text** "📦 טעינת קטלוג החברה" · — לא-רשום
- **text** "המערכת עובדת על הקטלוג שתטענו — חיפוש, סל והזמנות. מחירים והשוואת-חנויות יתווספו בשלב חיבור-השרת." · — לא-רשום
- **text** "🔄 רענן להחלת הקטלוג בכל המסכים" · — לא-רשום
- **text** "⬇️ הורד תבנית לדוגמה" · — לא-רשום
- **text** "⬆️ העלה נתונים" · — לא-רשום

## חיבורים · connections (4)

- **reads** · `read` → `downloadTextFileProvider`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `pickTextFileProvider`
- **reads** · `read` → `reloadAppProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (9)

- `auditRows`
- `bsOnAccent`
- `companyCatalogTemplateCsv`
- `featEnabled`
- `parseCompanyCatalogCsv`
- `persistCompanyCatalog`
- `registerCompanySpecs`
- `setCompanyCatalog`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 5 unregistered — "📦 טעינת קטלוג החברה" · "המערכת עובדת על הקטלוג שתטענו — חיפוש, סל והזמנות. מחירים והשוואת-חנויות יתווספו בשלב חיבור-השרת." · "🔄 רענן להחלת הקטלוג בכל המסכים" · "⬇️ הורד תבנית לדוגמה" · "⬆️ העלה נתונים"
