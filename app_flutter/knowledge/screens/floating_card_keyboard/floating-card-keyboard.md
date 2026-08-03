# FloatingCardKeyboard

- **screen:** `floating_card_keyboard`
- **role:** composer

## עצם · object (2)

> registry 1 · mapped 1/1 · **unregistered 1**

- **cfgText** "קולי — בקרוב" · `floating_card_keyboard.voice_soon` ✅
- **text** "החלקים לעבודה" · — לא-רשום

## חיבורים · connections (28)

- **reads** · `watch` → `screenSectionsProvider`
- **reads** · `read` → `screenSectionsProvider`
- **reads** · `read` → `keyboardSearchModeProvider`
- **writes** · `state=` → `keyboardSearchModeProvider`
- **reads** · `read` → `mainTabProvider`
- **writes** · `state=` → `keyboardDiveQueryProvider`
- **reads** · `read` → `updatesSubTabProvider`
- **writes** · `state=` → `updatesChatSearchProvider`
- **writes** · `state=` → `notifSearchQueryProvider`
- **writes** · `state=` → `storeSearchQueryProvider`
- **writes** · `state=` → `keyboardOverlayOpenProvider`
- **reads** · `read` → `catalogLocationProvider`
- **reads** · `read` → `keyboardScreenToolsProvider`
- **action** · `showSnackBar` → `showSnackBar`
- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **reads** · `watch` → `mainTabProvider`
- **reads** · `watch` → `orgConfigProvider`
- **reads** · `watch` → `featureFlagsProvider`
- **reads** · `watch` → `deptLocationProvider`
- **reads** · `watch` → `updatesLocationProvider`
- **reads** · `watch` → `visibleThreadsProvider`
- **reads** · `watch` → `storeLocationProvider`
- **reads** · `watch` → `smartCartProvider`
- **reads** · `watch` → `ordersEngineProvider`
- **reads** · `watch` → `catalogLocationProvider`
- **reads** · `watch` → `keyboardJobSkusProvider`
- **reads** · `watch` → `keyboardScreenToolsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (31)

- `add`
- `buildEntitySearchIndex`
- `buildWordLexicon`
- `cardKeyboardPredictions`
- `catalogLeadsWithFinder`
- `clear`
- `crossDomainNextTokens`
- `currentScreenTools`
- `deriveCatalogContext`
- `deriveDeptContext`
- `deriveStoreContext`
- `deriveUpdatesContext`
- `dispose`
- `featureOn`
- `hideCurrentSnackBar`
- `insertAtCaret`
- `kbHomeNodes`
- `kbKbdNodes`
- `kbScreenMenuNodes`
- `kbTabToolNodes`
- `kbTilesFor`
- `keyboardLayoutKey`
- `listEquals`
- `matchDestinations`
- `mergeNarrowers`
- `moduleOn`
- `productBySku`
- `removeListener`
- `run`
- `setState`
- `tabNodes`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onKeyboardDiveQuery(…) callback instead of direct keyboardDiveQueryProvider write
  - onKeyboardOverlayOpen(…) callback instead of direct keyboardOverlayOpenProvider write
  - onKeyboardSearchMode(…) callback instead of direct keyboardSearchModeProvider write
  - onNotifSearchQuery(…) callback instead of direct notifSearchQueryProvider write
  - onStoreSearchQuery(…) callback instead of direct storeSearchQueryProvider write
  - onUpdatesChatSearch(…) callback instead of direct updatesChatSearchProvider write
- **gaps:** 1 unregistered — "החלקים לעבודה"
