# _RequestCard

- **screen:** `role_requests_inbox_screen`
- **role:** section

## עצם · object (7)

> registry 6 · mapped 6/6 · **unregistered 1**

- **cfgVisible** · `role_requests_inbox_screen.t02` ✅
- **cfgText** "אישור" · `role_requests_inbox_screen.t02` ✅
- **cfgVisible** · `role_requests_inbox_screen.t03` ✅
- **cfgText** "דחייה" · `role_requests_inbox_screen.t03` ✅
- **cfgVisible** · `role_requests_inbox_screen.t04` ✅
- **text** "✨" · — לא-רשום
- **cfgText** "נסח סיבת-דחייה" · `role_requests_inbox_screen.t04` ✅

## חיבורים · connections (3)

- **gated-by** · `guard` → `ref.watch(claudeGatewayProvider) == null`
- **reads** · `watch` → `claudeGatewayProvider`
- **action** · `push` → `RejectReasonScreen`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (ref.watch(claudeGatewayProvider) == null)` → hidden (SizedBox.shrink)
- **onPressed** → _verb_ `Navigator.of(context).push(RejectReasonScreen.route(role: role, name: name ??…` → navigate → RejectReasonScreen

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `doc` · `busy` · `onApprove` · `onDeny`
- **gaps:** 1 unregistered — "✨"
