# LoginSheet

- **screen:** `login_sheet`
- **role:** composer

## עצם · object (13)

> registry 12 · mapped 12/12 · **unregistered 1**

- **cfgText** "🔐 התחברות לחשבון" · `login_sheet.t01` ✅
- **text** "המשך עם Google" · — לא-רשום
- **cfgText** "או בקוד ל-SMS" · `login_sheet.t06` ✅
- **cfgVisible** · `login_sheet.t02` ✅
- **cfgText** "כניסה עם אימייל וסיסמה" · `login_sheet.t02` ✅
- **cfgVisible** · `login_sheet.t03` ✅
- **cfgText** "שליחת קוד חדש" · `login_sheet.t03` ✅
- **cfgVisible** · `login_sheet.t04` ✅
- **cfgText** "החלפת מספר" · `login_sheet.t04` ✅
- **cfgVisible** · `login_sheet.t05` ✅
- **cfgText** "שכחתי סיסמה" · `login_sheet.t05` ✅
- **cfgVisible** · `login_sheet.t06` ✅
- **cfgText** "חזרה לכניסה עם טלפון" · `login_sheet.t06` ✅

## חיבורים · connections (4)

- **action** · `showToast` → `showToast`
- **reads** · `read` → `authStateProvider`
- **reads** · `read` → `userProfileProvider`
- **reads** · `read` → `authGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (4)

- `onSubmitted`
- `setState`
- `unawaited`
- `validEmail`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
  - _codePane = shared component → separate atom
  - _emailPane = shared component → separate atom
  - _phonePane = shared component → separate atom
- **gaps:** 1 unregistered — "המשך עם Google"
