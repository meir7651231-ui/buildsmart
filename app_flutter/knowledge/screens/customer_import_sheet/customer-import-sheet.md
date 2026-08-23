# _CustomerImportSheet

- **screen:** `customer_import_sheet`
- **role:** composer

## עצם · object (5)

> registry 0 · mapped 0/0 · **unregistered 5**

- **text** "👥 ייבוא לקוחות" · — לא-רשום
- **text** "טענו רשימת לקוחות מקובץ CSV — שם חובה, טלפון ואימייל נבדקים, כפילויות מסוננות אוטומטית." · — לא-רשום
- **text** "סגור" · — לא-רשום
- **text** "⬇️ הורד תבנית לדוגמה" · — לא-רשום
- **text** "⬆️ העלה נתונים" · — לא-רשום

## חיבורים · connections (4)

- **reads** · `read` → `downloadTextFileProvider`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `pickTextFileProvider`
- **reads** · `read` → `savedCustomersProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (5)

- `auditRows`
- `bsOnAccent`
- `customerCatalogTemplateCsv`
- `parseCustomerCsv`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 5 unregistered — "👥 ייבוא לקוחות" · "טענו רשימת לקוחות מקובץ CSV — שם חובה, טלפון ואימייל נבדקים, כפילויות מסוננות אוטומטית." · "סגור" · "⬇️ הורד תבנית לדוגמה" · "⬆️ העלה נתונים"
