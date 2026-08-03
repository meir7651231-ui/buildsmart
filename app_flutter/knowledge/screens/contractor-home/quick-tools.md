# _QuickTools

- **screen:** `contractor-home`
- **role:** section · section `promise`

## עצם · object (1)

- **text** "כלים מהירים"

## חיבורים · connections (6)

- **gated-by** · `modOn` → `site`
- **gated-by** · `featOn` → `site.stock`
- **action** · `openScanPlanSheet` → `openScanPlanSheet`
- **action** · `push` → `StockScreen`
- **action** · `openSiteHub` → `openSiteHub`
- **gated-by** · `guard` → `rows.isEmpty`

## התנהגות · behaviour (1)

- **build** → _rule_ `if (rows.isEmpty)` → hidden (SizedBox.shrink)

## floor · external functions (1)

- `cfgRadius`
