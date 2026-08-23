# _ContractorMaterialRequestsSheet

- **screen:** `contractor_material_requests_sheet`
- **role:** composer

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "📥 בקשות חומר" · `contractor_material_requests_sheet.t01` ✅
- **cfgText** · `contractor_material_requests_sheet.t02` ✅

## חיבורים · connections (2)

- **reads** · `watch` → `requestsForEmployer(kDemoContractorId)`
- **reads** · `read` → `materialRequestsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `requestsForEmployer`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
