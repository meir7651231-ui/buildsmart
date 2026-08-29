# _StatusSheet

- **screen:** `projects_screen`
- **role:** section

## עצם · object (3)

> registry 3 · mapped 3/3 · **unregistered 0**

- **cfgText** "✏️ הקש לעריכת הפרטים" · `projects_screen.edit_hint` ✅
- **cfgVisible** · `projects_screen.edit_site` ✅
- **cfgText** "✏️ עריכת פרטי האתר" · `projects_screen.edit_site` ✅

## חיבורים · connections (5)

- **reads** · `watch` → `projectsProvider`
- **reads** · `read` → `smartCartProvider`
- **reads** · `read` → `projectsProvider`
- **action** · `showToast` → `showToast`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`

## התנהגות · behaviour (4)

- **onTap** → _verb_ `ref.read(projectsProvider.notifier).switchProject(p.id, outgoingCart: outgoing)` → write → projectsProvider
- **onTap** → _verb_ `ref.read(smartCartProvider.notifier).loadSnapshot(incoming)` → write → smartCartProvider
- **onTap** → _verb_ `showToast(context, 'עברת לפרויקט: ${p.name}')` → toast
- **onTap** → _verb_ `showModalBottomSheet<void>(context: context, backgroundColor: Colors.transpar…` → open → showModalBottomSheet

## floor · external functions (1)

- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `projectId`
- **gaps:** none (all registry-backed)
