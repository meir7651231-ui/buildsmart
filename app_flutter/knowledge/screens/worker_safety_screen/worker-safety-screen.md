# WorkerSafetyScreen

- **screen:** `worker_safety_screen`
- **role:** composer

## עצם · object (12)

> registry 11 · mapped 11/11 · **unregistered 1**

- **cfgText** "🛡️ תיק בטיחות" · `worker_safety_screen.appbar_title` ✅
- **cfgText** "🎓 הוספת הדרכה" · `worker_safety_screen.add_training_title` ✅
- **text** "📅" · — לא-רשום
- **cfgText** "📄 צרף מסמך הדרכה (לא חובה)" · `worker_safety_screen.attach_doc` ✅
- **cfgText** "📄 מסמך צורף ✓" · `worker_safety_screen.doc_attached` ✅
- **cfgVisible** · `worker_safety_screen.save_training` ✅
- **cfgText** "💾 שמור הדרכה" · `worker_safety_screen.save_training` ✅
- **cfgText** "🪪 הוספת תעודה" · `worker_safety_screen.add_cert_title` ✅
- **cfgText** "📷 צרף צילום תעודה (לא חובה)" · `worker_safety_screen.attach_photo` ✅
- **cfgText** "📷 צילום צורף ✓" · `worker_safety_screen.photo_attached` ✅
- **cfgVisible** · `worker_safety_screen.save_cert` ✅
- **cfgText** "💾 שמור תעודה" · `worker_safety_screen.save_cert` ✅

## חיבורים · connections (13)

- **reads** · `watch` → `boardAuthProvider`
- **reads** · `watch` → `workerTrainingsProvider`
- **reads** · `watch` → `workerCertsProvider`
- **reads** · `read` → `workerTrainingsProvider`
- **action** · `showFullPhotoDialog` → `showFullPhotoDialog`
- **writes** · `remove` → `workerCertsProvider`
- **action** · `showToast` → `showToast`
- **writes** · `remove` → `workerTrainingsProvider`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`
- **action** · `showDatePicker` → `showDatePicker`
- **writes** · `add` → `workerTrainingsProvider`
- **reads** · `read` → `boardAuthProvider`
- **writes** · `add` → `workerCertsProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (6)

- `bsOnAccent`
- `confirmDestructive`
- `decodeDataUrlPhoto`
- `pickTaskPhoto`
- `setSheetState`
- `sort`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - WelcomeScreen = shared component → separate atom
- **gaps:** 1 unregistered — "📅"
