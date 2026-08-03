# HomeShell

- **screen:** `home_shell`
- **role:** composer

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (16)

- **reads** · `watch` → `mainTabProvider`
- **reads** · `watch` → `helpModeProvider`
- **reads** · `read` → `shipToPromptedProvider`
- **writes** · `state=` → `shipToPromptedProvider`
- **action** · `openShipToSheet` → `openShipToSheet`
- **writes** · `state=` → `promptRoleRequestProvider`
- **action** · `showRoleRequestSheet` → `showRoleRequestSheet`
- **reads** · `read` → `promptRoleRequestProvider`
- **gated-by** · `modOn` → `search`
- **reads** · `watch` → `keyboardOverlayOpenProvider`
- **writes** · `state=` → `keyboardOverlayOpenProvider`
- **writes** · `state=` → `homeDepartmentProvider`
- **writes** · `state=` → `catalogSystemFilterProvider`
- **writes** · `state=` → `catalogTreePathProvider`
- **writes** · `state=` → `catalogSectionProvider`
- **writes** · `state=` → `mainTabProvider`

## התנהגות · behaviour (6)

- **onPressed** → _verb_ `ref.read(keyboardOverlayOpenProvider.notifier).state = true` → write → keyboardOverlayOpenProvider
- **onTap** → _verb_ `ref.read(homeDepartmentProvider.notifier).state = null` → write → homeDepartmentProvider
- **onTap** → _verb_ `ref.read(catalogSystemFilterProvider.notifier).state = null` → write → catalogSystemFilterProvider
- **onTap** → _verb_ `ref.read(catalogTreePathProvider.notifier).state = const []` → write → catalogTreePathProvider
- **onTap** → _verb_ `ref.read(catalogSectionProvider.notifier).state = 'בית'` → write → catalogSectionProvider
- **onTap** → _verb_ `ref.read(mainTabProvider.notifier).state = i` → write → mainTabProvider

## floor · external functions (4)

- `listenTabScreenView`
- `maybeShowConsentModal`
- `resetAllDials`
- `saveShipToPrompted`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - CatalogScreen = shared component → separate atom
  - DepartmentsScreen = shared component → separate atom
  - StoreScreen = shared component → separate atom
  - UpdatesScreen = shared component → separate atom
- **gaps:** none (all registry-backed)
