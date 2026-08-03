# _ContractorHrSheet

- **screen:** `contractor_hr_sheet`
- **role:** composer

## עצם · object (8)

> registry 8 · mapped 8/8 · **unregistered 0**

- **cfgText** "👷 חופשות עובדים" · `contractor_hr_sheet.t01` ✅
- **cfgText** "🌴 אין בקשות חופשה מהעובדים שלך כרגע" · `contractor_hr_sheet.t02` ✅
- **cfgText** "🎓 הדרכות עובדים" · `contractor_hr_sheet.t03` ✅
- **cfgText** "🎓 אין הדרכות מהעובדים שלך כרגע" · `contractor_hr_sheet.t04` ✅
- **cfgText** "📜 תעודות עובדים" · `contractor_hr_sheet.t05` ✅
- **cfgText** "התעודות המקצועיות של העובדים שלך (לצפייה בלבד)" · `contractor_hr_sheet.t06` ✅
- **cfgText** "📜 אין תעודות מהעובדים שלך כרגע" · `contractor_hr_sheet.t07` ✅
- **cfgText** "📋 מסמכים נדרשים מהעובדים" · `contractor_hr_sheet.t08` ✅

## חיבורים · connections (10)

- **reads** · `read` → `vacationRequestsProvider`
- **reads** · `read` → `workerNotifsProvider`
- **reads** · `read` → `chatEngineProvider`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `workerTrainingsProvider`
- **reads** · `watch` → `requestsForEmployer(kDemoContractorId)`
- **reads** · `watch` → `trainingsForEmployer(kDemoContractorId)`
- **reads** · `watch` → `certsForEmployer(kDemoContractorId)`
- **reads** · `watch` → `requiredDocsForEmployer(kDemoContractorId)`
- **reads** · `read` → `requiredDocsPolicyProvider`

## התנהגות · behaviour (5)

- **build** → _formula_ `reasonSuffix = (!approve && why != null && why.isNotEmpty) ? … : …` → text: ' · סיבה: ${why}' | ''
- **onPressed** → _verb_ `ref.read(requiredDocsPolicyProvider.notifier).removeRequirement(kDemoContract…` → write → requiredDocsPolicyProvider
- **onPressed** → _verb_ `showToast(context, '❌ הוסר מסמך נדרש: $name')` → toast
- **onTap** → _verb_ `ref.read(requiredDocsPolicyProvider.notifier).addRequirement(kDemoContractorI…` → write → requiredDocsPolicyProvider
- **onTap** → _verb_ `showToast(context, '📋 נוסף מסמך נדרש: $s')` → toast

## floor · external functions (5)

- `certsForEmployer`
- `promptRejectReason`
- `requestsForEmployer`
- `requiredDocsForEmployer`
- `trainingsForEmployer`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
