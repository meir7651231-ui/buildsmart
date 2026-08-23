# StudioComponentBuilder

- **screen:** `studio_component_builder`
- **role:** composer

## עצם · object (10)

> registry 0 · mapped 0/0 · **unregistered 10**

- **text** "🛠️ בונה ידני — ללא מודל" · — לא-רשום
- **text** "בחר רכיב לעריכה…" · — לא-רשום
- **text** "אין ערכי צבע מוגדרים לרכיב זה (fail-closed)." · — לא-רשום
- **text** "🙈 הסתר" · — לא-רשום
- **text** "👁️ הצג" · — לא-רשום
- **text** "בחר מסך-יעד (מסכי-פרמטר מאופרים — צריך פרמטרים):" · — לא-רשום
- **text** "צריך פרמטרים — לא זמין" · — לא-רשום
- **text** "👁️ תצוגה מקדימה (לפני החלה)" · — לא-רשום
- **text** "בחר עריכה כדי לראות תצוגה מקדימה." · — לא-רשום
- **text** "אשר והחל בטיוטה ✓" · — לא-רשום

## חיבורים · connections (2)

- **reads** · `read` → `configStoreProvider`
- **reads** · `watch` → `configStoreProvider`

## התנהגות · behaviour (0)

_(no flows)_

## floor · external functions (8)

- `bsOnAccent`
- `findDescriptor`
- `fn`
- `setState`
- `sort`
- `summarizeDiff`
- `validateAddComponent`
- `validateSafe`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 10 unregistered — "🛠️ בונה ידני — ללא מודל" · "בחר רכיב לעריכה…" · "אין ערכי צבע מוגדרים לרכיב זה (fail-closed)." · "🙈 הסתר" · "👁️ הצג" · "בחר מסך-יעד (מסכי-פרמטר מאופרים — צריך פרמטרים):" · "צריך פרמטרים — לא זמין" · "👁️ תצוגה מקדימה (לפני החלה)" · "בחר עריכה כדי לראות תצוגה מקדימה." · "אשר והחל בטיוטה ✓"
