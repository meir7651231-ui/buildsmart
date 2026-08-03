# AuditScreen

- **screen:** `audit_screen`
- **role:** composer

## עצם · object (4)

> registry 3 · mapped 3/3 · **unregistered 1**

- **cfgText** "אודיט תרחישים" · `audit_screen.t01` ✅
- **text** "🧪" · — לא-רשום
- **cfgText** "עדיין לא הורצו בדיקות" · `audit_screen.t02` ✅
- **cfgText** "הקש "⚡ הרץ 20 תרחישי בדיקה" כדי להתחיל" · `audit_screen.t03` ✅

## חיבורים · connections (0)

_(no edges)_

## התנהגות · behaviour (2)

- **build** → _formula_ `tempTag = tempC >= 60 ? … : …` → text: '🔥 חם' | '❄ קר'
- **build** → _formula_ `loopTag = loop ? … : …` → text: ' (ריזרקולציה)' | ''

## floor · external functions (6)

- `buildInstallation`
- `estimatePressureDrop`
- `lineComplianceChecklist`
- `name`
- `productSystems`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 1 unregistered — "🧪"
