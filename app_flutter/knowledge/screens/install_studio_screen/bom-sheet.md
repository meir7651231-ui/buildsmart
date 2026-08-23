# _BomSheet

- **screen:** `install_studio_screen`
- **role:** section

## עצם · object (18)

> registry 0 · mapped 0/0 · **unregistered 18**

- **text** "שנה שם לאזור" · — לא-רשום
- **text** "ביטול" · — לא-רשום
- **text** "שמור" · — לא-רשום
- **text** "המערכת תיקנה אוטומטית:" · — לא-רשום
- **text** "✅" · — לא-רשום
- **text** "עלייה אנכית:" · — לא-רשום
- **text** "החלף לחומר עמיד-חום: PEX / נחושת / פליז." · — לא-רשום
- **text** "מינ׳ 2% · ת"י 1205" · — לא-רשום
- **text** "אורך אופקי:" · — לא-רשום
- **text** "מפל אנכי:" · — לא-רשום
- **text** "🛡️" · — לא-רשום
- **text** "אחריות: הסל משלים את העבודה — אין נסיעה שנייה" · — לא-רשום
- **text** "⚠️ חסרים חיבורים — הקו לא שלם" · — לא-רשום
- **text** "בטיחות ותקינות" · — לא-רשום
- **text** "💡" · — לא-רשום
- **text** "מה הצעד הבא?" · — לא-רשום
- **text** "לחץ "📋 שלח לאינסטלטור" כדי להעתיק ולשלוח ב-WhatsApp,
או "הוסף לסל" להזמנה ישירה." · — לא-רשום
- **text** "📋 שלח לאינסטלטור" · — לא-רשום

## חיבורים · connections (17)

- **action** · `showDialog` → `showDialog`
- **reads** · `read` → `chainProvider`
- **action** · `showToast` → `showToast`
- **writes** · `state=` → `chainProvider`
- **reads** · `read` → `lineMaxTempProvider`
- **reads** · `read` → `lineAccessoriesProvider`
- **gated-by** · `guard` → `anchorSkus.length != 2 || branches > 0`
- **gated-by** · `guard` → `anchors.length != 2`
- **gated-by** · `guard` → `alts.length < 2`
- **gated-by** · `guard` → `autoAdded == 0`
- **gated-by** · `guard` → `s49bTempCfg != null`
- **gated-by** · `guard` → `unfit.isEmpty`
- **gated-by** · `guard` → `s49bCfg != null && s49bCfg.physics?.minSlopePercent == null`
- **gated-by** · `const-flag` → `kit.isEmpty`
- **gated-by** · `guard` → `rules.isEmpty`
- **reads** · `read` → `smartCartProvider`
- **gated-by** · `guard` → `count == 0`

## התנהגות · behaviour (10)

- **build** → _rule_ `if (anchorSkus.length != 2 || branches > 0)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (anchors.length != 2)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (alts.length < 2)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (autoAdded == 0)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (s49bTempCfg != null)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (unfit.isEmpty)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (s49bCfg != null && s49bCfg.physics?.minSlopePercent == null)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (kit.isEmpty)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (rules.isEmpty)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (count == 0)` → hidden (SizedBox.shrink)

## floor · external functions (15)

- `buildInstallation`
- `checkDrainageSlope`
- `estimatePressureDrop`
- `estimatePrice`
- `findAlternativePaths`
- `isPipe`
- `lineComplianceChecklist`
- `lineIsSupply`
- `lineStructureText`
- `materializeChain`
- `productMaxTempC`
- `productSuitableForTemp`
- `recommendedKitFor`
- `setState`
- `widerSiblingOf`

## חוזה-רכיב · contract + gaps

- **extractable:** `needs-untangle`
- **props:** `plan` · `anchorSkus` · `branches` · `outlets` · `autoFixes`
- **untangle:**
  - onChain(…) callback instead of direct chainProvider write
- **gaps:** 18 unregistered — "שנה שם לאזור" · "ביטול" · "שמור" · "המערכת תיקנה אוטומטית:" · "✅" · "עלייה אנכית:" · "החלף לחומר עמיד-חום: PEX / נחושת / פליז." · "מינ׳ 2% · ת"י 1205" · "אורך אופקי:" · "מפל אנכי:" · "🛡️" · "אחריות: הסל משלים את העבודה — אין נסיעה שנייה" · "⚠️ חסרים חיבורים — הקו לא שלם" · "בטיחות ותקינות" · "💡" · "מה הצעד הבא?" · "לחץ "📋 שלח לאינסטלטור" כדי להעתיק ולשלוח ב-WhatsApp,
או "הוסף לסל" להזמנה ישירה." · "📋 שלח לאינסטלטור"
