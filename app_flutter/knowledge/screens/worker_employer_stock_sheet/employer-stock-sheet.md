# _EmployerStockSheet

- **screen:** `worker_employer_stock_sheet`
- **role:** composer

## עצם · object (6)

> registry 6 · mapped 6/6 · **unregistered 0**

- **cfgText** "📦 מלאי הקבלן" · `worker_employer_stock_sheet.t01` ✅
- **cfgText** "הקבלן טרם שיתף מלאי" · `worker_employer_stock_sheet.t02` ✅
- **cfgText** "רשימת המלאי תוצג כאן כשתחובר עם השרת." · `worker_employer_stock_sheet.t03` ✅
- **cfgText** "הבקשות שלי" · `worker_employer_stock_sheet.t04` ✅
- **cfgVisible** · `worker_employer_stock_sheet.t05` ✅
- **cfgText** "סגור" · `worker_employer_stock_sheet.t05` ✅

## חיבורים · connections (4)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `employerStockProvider(session?.employerId ?? '')`
- **reads** · `watch` → `requestsForWorker(session?.username ?? '')`
- **reads** · `read` → `materialRequestsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (3)

- `employerStockProvider`
- `requestsForWorker`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
