# _InteractiveChips

- **screen:** `lipskey_product_sheet`
- **role:** section

## עצם · object (0)

> registry 0 · mapped 0/0 · **unregistered 0**

_(no text nodes)_

## חיבורים · connections (2)

- **gated-by** · `guard` → `entries.isEmpty`
- **gated-by** · `guard` → `options.isEmpty`

## התנהגות · behaviour (2)

- **build** → _rule_ `if (entries.isEmpty)` → hidden (SizedBox.shrink)
- **build** → _rule_ `if (options.isEmpty)` → hidden (SizedBox.shrink)

## floor · external functions (5)

- `kindOf`
- `onChipTap`
- `onSelect`
- `sort`
- `variantValue`

## חוזה-רכיב · contract + gaps

- **extractable:** `clean`
- **props:** `product` · `openPickerKey` · `onChipTap` · `onVariantSelect`
- **gaps:** none (all registry-backed)
