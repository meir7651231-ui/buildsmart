# QuotePolishScreen

- **screen:** `quote_polish_screen`
- **role:** composer

## עצם · object (5)

> registry 4 · mapped 4/4 · **unregistered 1**

- **cfgText** "ההצעה המנוסחת הועתקה" · `quote_polish_screen.copied_toast` ✅
- **cfgText** "✨ הצעה מקצועית" · `quote_polish_screen.title` ✅
- **text** "📋" · — לא-רשום
- **cfgText** "העתק לשליחה" · `quote_polish_screen.copy_btn` ✅
- **cfgText** "⚙️ המספרים מנתוני-המערכת; ה-AI רק מנסח — לא משנה מחירים." · `quote_polish_screen.footer_note` ✅

## חיבורים · connections (2)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `rawQuote` · `productName`
- **gaps:** 1 unregistered — "📋"
