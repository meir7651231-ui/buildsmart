# _CoEditorPane

- **screen:** `studio_screen`
- **role:** section

## עצם · object (4)

> registry 4 · mapped 4/4 · **unregistered 0**

- **cfgText** "🤖 תאר בעברית מה לשנות. אכין תצוגה מקדימה — שום דבר לא ישתנה עד שתאשר." · `studio_screen_old.t03` ✅
- **cfgText** "נסח שינוי לתצוגה מקדימה" · `studio_screen_old.t04` ✅
- **cfgText** "אשר והחל בטיוטה ✓" · `studio_screen_old.t05` ✅
- **cfgText** "👁️ תצוגה מקדימה (לפני החלה)" · `studio_screen_old.t06` ✅

## חיבורים · connections (2)

- **reads** · `read` → `claudeGatewayProvider`
- **reads** · `read` → `configStoreProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (9)

- `bsOnAccent`
- `classifyScope`
- `parseConfigEdit`
- `scopeHe`
- `setState`
- `studioEditPrompt`
- `studioScopePrompt`
- `summarizeDiff`
- `validateSafe`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `ai`
- **gaps:** none (all registry-backed)
