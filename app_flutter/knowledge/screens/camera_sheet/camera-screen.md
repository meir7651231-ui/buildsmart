# CameraScreen

- **screen:** `camera_sheet`
- **role:** composer

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (4)

- **action** · `showLipskeyProductSheet` → `showLipskeyProductSheet`
- **action** · `showToast` → `showToast`
- **reads** · `read` → `taskPhotoPickerProvider`
- **reads** · `read` → `catalogSettingsProvider`

## התנהגות · behaviour (1)

- **onPressed** → _verb_ `showToast(ctx, 'אין פלאש במכשיר')` → toast

## floor · external functions (5)

- `cameraPermissionErrorView`
- `catalogProductForSku`
- `catalogSiblingsFor`
- `picker`
- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** none (all registry-backed)
