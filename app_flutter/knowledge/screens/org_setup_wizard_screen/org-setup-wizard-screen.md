# OrgSetupWizardScreen

- **screen:** `org_setup_wizard_screen`
- **role:** composer

## עצם · object (18)

> registry 0 · mapped 0/0 · **unregistered 18**

- **text** "🔒 ליבה — נעול" · — לא-רשום
- **text** "✎" · — לא-רשום
- **text** "אין רכיבים תואמים" · — לא-רשום
- **text** "כל מודול = סקציה. פתח סקציה כדי להדליק/לכבות רכיבים. חיפוש וצ׳יפים מסננים. ליבה (ניווט/כניסה) נעולה תמיד." · — לא-רשום
- **text** "הכל" · — לא-רשום
- **text** "🔌 אשף הקמת חברה" · — לא-רשום
- **text** "מצב לא-חמוש: השינויים פעילים מיד, אך לא ייטענו אחרי סגירה (נדרש build עם ORG_CONFIG=true)." · — לא-רשום
- **text** "החלת חבילה מחליפה מודולים+מונחים במלואם — שם וזהות נשמרים." · — לא-רשום
- **text** "🔎" · — לא-רשום
- **text** "מצא והחלף" · — לא-רשום
- **text** "🕘" · — לא-רשום
- **text** "גרסאות" · — לא-רשום
- **text** "🖥️" · — לא-רשום
- **text** "ניהול מסכים (סדר · הסתר)" · — לא-רשום
- **text** "שמור והפעל" · — לא-רשום
- **text** "ייצוא JSON" · — לא-רשום
- **text** "ייבוא JSON" · — לא-רשום
- **text** "איפוס טיוטה" · — לא-רשום

## חיבורים · connections (9)

- **reads** · `read` → `orgConfigProvider`
- **writes** · `state=` → `orgConfigProvider`
- **reads** · `read` → `downloadTextFileProvider`
- **reads** · `read` → `pickTextFileProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **action** · `push` → `_WizardFindReplaceScreen`
- **action** · `push` → `_WizardHistoryScreen`
- **action** · `push` → `_ScreenManagerScreen`
- **gated-by** · `guard` → `terms == null`

## התנהגות · behaviour (1)

- **build** → _rule_ `if (terms == null)` → hidden (SizedBox.shrink)

## floor · external functions (11)

- `applyVerticalPack`
- `bsOnAccent`
- `decodeOrgConfig`
- `elementShown`
- `encodeOrgConfig`
- `moduleOn`
- `persistOrgConfig`
- `screenLabelHe`
- `setState`
- `sort`
- `termOf`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onOrgConfig(…) callback instead of direct orgConfigProvider write
- **gaps:** 18 unregistered — "🔒 ליבה — נעול" · "✎" · "אין רכיבים תואמים" · "כל מודול = סקציה. פתח סקציה כדי להדליק/לכבות רכיבים. חיפוש וצ׳יפים מסננים. ליבה (ניווט/כניסה) נעולה תמיד." · "הכל" · "🔌 אשף הקמת חברה" · "מצב לא-חמוש: השינויים פעילים מיד, אך לא ייטענו אחרי סגירה (נדרש build עם ORG_CONFIG=true)." · "החלת חבילה מחליפה מודולים+מונחים במלואם — שם וזהות נשמרים." · "🔎" · "מצא והחלף" · "🕘" · "גרסאות" · "🖥️" · "ניהול מסכים (סדר · הסתר)" · "שמור והפעל" · "ייצוא JSON" · "ייבוא JSON" · "איפוס טיוטה"
