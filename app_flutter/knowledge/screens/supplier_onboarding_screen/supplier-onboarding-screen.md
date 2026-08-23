# SupplierOnboardingScreen

- **screen:** `supplier_onboarding_screen`
- **role:** composer

## עצם · object (2)

> registry 0 · mapped 0/0 · **unregistered 2**

- **text** "העלאת מוצר" · — לא-רשום
- **text** "מאפיינים מזוהים אוטומטית" · — לא-רשום

## חיבורים · connections (1)

- **reads** · `read` → `supplierSubmitProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (3)

- `setState`
- `suggestFacets`
- `validateDraft`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** `storeId`
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 2 unregistered — "העלאת מוצר" · "מאפיינים מזוהים אוטומטית"
