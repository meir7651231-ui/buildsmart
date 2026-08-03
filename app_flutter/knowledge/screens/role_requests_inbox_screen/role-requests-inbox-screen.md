# RoleRequestsInboxScreen

- **screen:** `role_requests_inbox_screen`
- **role:** composer

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "בקשות תפקיד" · `role_requests_inbox_screen.t01` ✅

## חיבורים · connections (4)

- **reads** · `read` → `roleReviewerProvider`
- **action** · `showToast` → `showToast`
- **reads** · `watch` → `pendingRoleRequestsProvider`
- **reads** · `watch` → `authStateProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (5)

- `clearAllRoleRequests`
- `confirmDestructive`
- `isOwnerEmail`
- `reviewer`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
