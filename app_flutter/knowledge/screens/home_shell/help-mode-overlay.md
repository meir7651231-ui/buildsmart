# _HelpModeOverlay

- **screen:** `home_shell`
- **role:** section

## עצם · object (1)

> registry 1 · mapped 1/1 · **unregistered 0**

- **cfgText** "מצב היכרות — לחצו על אלמנט מודגש כדי ללמוד מה הוא עושה" · `home.helpmode.banner` ✅

## חיבורים · connections (2)

- **writes** · `state=` → `helpModeProvider`
- **action** · `showSnackBar` → `showSnackBar`

## התנהגות · behaviour (2)

- **onTap** → _verb_ `ref.read(helpModeProvider.notifier).state = false` → write → helpModeProvider
- **onTap** → _verb_ `..showSnackBar(const SnackBar(duration: Duration(seconds: 2), content: Text('…` → open → showSnackBar

## floor · external functions (1)

- `hideCurrentSnackBar`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** —
- **untangle:**
  - onHelpMode(…) callback instead of direct helpModeProvider write
- **gaps:** none (all registry-backed)
