# _WorkPath

- **screen:** `contractor-home`
- **role:** section · section `workPath`

## עצם · object (4)

> registry 3 · mapped 3/3 · **unregistered 1**

- **text** "מסלול עבודה חכם" · — לא-רשום
- **cfgText** "🛁 חדש — מאפס עד גמר" · `smart_home_screen.workpath_badge` ✅
- **cfgText** "גמר אמבטיה — מלווה אותך שלב-שלב" · `smart_home_screen.workpath_title` ✅
- **cfgText** "4 שלבים בסדר הנכון. כל שלב: עץ מוצרים + חלון "סדר הרכבה"." · `smart_home_screen.workpath_sub` ✅

## חיבורים · connections (1)

- **gated-by** · `const-flag` → `kProfileRawShell`

## התנהגות · behaviour (1)

- **build** → _rule_ `if (kProfileRawShell)` → hidden (SizedBox.shrink)

## floor · external functions (1)

- `cfgRadius`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 1 unregistered — "מסלול עבודה חכם"
