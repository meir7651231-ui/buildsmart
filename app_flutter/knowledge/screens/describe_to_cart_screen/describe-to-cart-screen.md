# DescribeToCartScreen

- **screen:** `describe_to_cart_screen`
- **role:** composer

## עצם · object (9)

> registry 8 · mapped 8/8 · **unregistered 1**

- **cfgText** "🗣️ תאר עבודה → סל" · `describe_to_cart_screen.t01` ✅
- **cfgText** "💡 הפיצ'ר דורש חיבור לשרת." · `describe_to_cart_screen.t02` ✅
- **cfgText** "ספר במילים שלך מה אתה צריך:" · `describe_to_cart_screen.t03` ✅
- **cfgVisible** · `describe_to_cart_screen.t04` ✅
- **text** "🔎" · — לא-רשום
- **cfgText** "מצא לי את הסל" · `describe_to_cart_screen.t04` ✅
- **cfgText** "משהו השתבש — נסה שוב." · `describe_to_cart_screen.t05` ✅
- **cfgText** "זוהתה העבודה, אך לחלקיה עדיין אין מק"ט מקושר." · `describe_to_cart_screen.t06` ✅
- **cfgText** "לא זוהתה עבודה מתאימה — נסה לתאר אחרת." · `describe_to_cart_screen.t07` ✅

## חיבורים · connections (3)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `read` → `smartCartProvider`
- **reads** · `watch` → `claudeGatewayProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (1)

- `setState`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** —
- **gaps:** 1 unregistered — "🔎"
