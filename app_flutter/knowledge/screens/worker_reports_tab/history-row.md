# _HistoryRow

- **screen:** `worker_reports_tab`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "📷 לא ניתן להציג את התמונה" · `worker_reports_tab.photo_error` ✅

## חיבורים · connections (2)

- **action** · `showDialog` → `showDialog`
- **action** · `showFullPhotoRefDialog` → `showFullPhotoRefDialog`

## התנהגות · behaviour (2)

- **onTap** → _verb_ `showDialog<void>(context: context, builder: (_) => Dialog(backgroundColor: Co…` → open → showDialog
- **onTap** → _verb_ `showFullPhotoRefDialog(context, p)` → open → showFullPhotoRefDialog

## floor · external functions (1)

- `imageProviderForRef`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `task` · `duration` · `onTap`
- **gaps:** none (all registry-backed)
