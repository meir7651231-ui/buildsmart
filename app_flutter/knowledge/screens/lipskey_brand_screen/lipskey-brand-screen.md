# LipskeyBrandScreen

- **screen:** `lipskey_brand_screen`
- **role:** composer

## עצם · object (2)

> registry 2 · mapped 2/2 · **unregistered 0**

- **cfgText** "ליפסקי ברקן" · `lipskey_brand_screen.appbar_title` ✅
- **cfgText** "אינסטלציה · סניטציה" · `lipskey_brand_screen.appbar_sub` ✅

## חיבורים · connections (1)

- **action** · `push` → `context`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `Navigator.push(context, LipskeySectionScreen.route(section: section))` → navigate → context

## floor · external functions (0)

_(none)_

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - CustomScrollView = shared component → separate atom
- **gaps:** none (all registry-backed)
