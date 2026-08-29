# _RequestingAs

- **screen:** `role_request_sheet`
- **role:** section

## עצם · object (1)

> registry 0 · mapped 0/0 · **unregistered 1**

- **text** "מבקש/ת בשם" · — לא-רשום

## חיבורים · connections (3)

- **reads** · `watch` → `authStateProvider`
- **gated-by** · `guard` → `user == null`
- **gated-by** · `guard` → `name.isEmpty && contact.isEmpty`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (user == null)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (name.isEmpty && contact.isEmpty)` → hidden (SizedBox.shrink)

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 1 unregistered — "מבקש/ת בשם"
