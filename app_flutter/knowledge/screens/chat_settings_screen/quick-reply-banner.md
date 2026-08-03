# _QuickReplyBanner

- **screen:** `chat_settings_screen`
- **role:** section

## עצם · object (7)

> registry 6 · mapped 6/6 · **unregistered 1**

- **cfgText** "תשובות מהירות" · `chat_settings_screen.t06` ✅
- **cfgVisible** · `chat_settings_screen.t07` ✅
- **cfgText** "הבנתי" · `chat_settings_screen.t07` ✅
- **text** "⚡" · — לא-רשום
- **cfgText** "תשובות מהירות" · `chat_settings_screen.t08` ✅
- **cfgVisible** · `chat_settings_screen.t09` ✅
- **cfgText** "ערוך" · `chat_settings_screen.t09` ✅

## חיבורים · connections (2)

- **action** · `showDialog` → `showDialog`
- **action** · `showToast` → `showToast`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `showToast(context, 'התבנית הועתקה')` → toast

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 1 unregistered — "⚡"
