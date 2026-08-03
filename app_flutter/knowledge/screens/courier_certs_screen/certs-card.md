# _CertsCard

- **screen:** `courier_certs_screen`
- **role:** section

## עצם · object (4)

> registry 3 · mapped 3/3 · **unregistered 1**

- **cfgText** "אין תעודות בארנק עדיין — הוסף את הראשונה." · `courier.certs.empty` ✅
- **cfgVisible** · `courier.certs.add_button` ✅
- **cfgText** "➕ הוסף תעודה" · `courier.certs.add_button` ✅
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
