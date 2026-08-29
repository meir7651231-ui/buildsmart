# _InstallStudioHero

- **screen:** `contractor-home`
- **role:** section · section `installHero`

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "תכנון חיבור" · `smart_home_screen.install_title` ✅
- **cfgText** "בחר מה לחבר — נכין רשימת קנייה תקנית ונבדוק את החיבור" · `smart_home_screen.install_sub` ✅

## חיבורים · connections (1)

- **action** · `push` → `InstallStudioScreen`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const Inst…` → navigate → InstallStudioScreen

## floor · external functions (1)

- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** none (all registry-backed)
