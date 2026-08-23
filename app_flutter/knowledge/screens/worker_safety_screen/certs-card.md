# _CertsCard

- **screen:** `worker_safety_screen`
- **role:** section

## עצם · object (4)

> registry 3 · mapped 3/3 · **unregistered 1**

- **cfgText** "אין תעודות בארנק עדיין — הוסף את הראשונה." · `worker_safety_screen.no_certs` ✅
- **cfgVisible** · `worker_safety_screen.add_cert_btn` ✅
- **cfgText** "➕ הוסף תעודה" · `worker_safety_screen.add_cert_btn` ✅
- **text** "📷" · — לא-רשום

## חיבורים · connections (1)

- **action** · `showFullPhotoRefDialog` → `showFullPhotoRefDialog`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `showFullPhotoRefDialog(context, cert.photo, label: cert.name)` → open → showFullPhotoRefDialog

## floor · external functions (3)

- `bsOnAccent`
- `imageProviderForRef`
- `onRemove`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `certs` · `onAdd` · `onRemove`
- **gaps:** 1 unregistered — "📷"
