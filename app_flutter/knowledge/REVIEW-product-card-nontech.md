# Review — external product card, non-technical lens

Feedback on the chip system in `lib/screens/lipskey_products_screen.dart`
(`_ProductRow` · `_NameWords` · `_AttrChip` · `_attrPicker`), from the
"least-technical user" angle. The engineering is strong (in-place variant
editing, orange=editable/gray=fixed, variant collapse). The notes below are
about making it legible to a non-technical user — owner of the card decides.

Priority order (high → low):

1. **Chip colour code has no legend.** A name becomes 5–6 differently-styled
   pills (orange / teal-underlined / gray) with no explanation. Orange =
   "editable", teal = "search this word", gray = "fixed" is not self-evident.
   - *Done on my side (no conflict):* a dismissible one-time hint above the
     **finder** results — "צ׳יפ כתום על מוצר — הקש כדי להחליף גודל או צבע"
     (`finder_screen.dart` `_chipTip` + `finderChipTipDismissedProvider`).
   - *Suggested in the card:* the same first-time hint inside
     `LipskeyProductsList` so it also covers the catalog/store lists, or a
     tiny ▾ caret on orange chips (see #4).

2. **"tap to change" affordance is weak.** `_AttrChip` (line ~1558) renders
   just `word`; the `· N` count mentioned in the doc-comment is no longer
   shown, so "this chip is editable" is conveyed only by the orange border.
   Consider a trailing ▾ caret or restoring `word · N` on chips with siblings.

3. **Two pickers both say "בחר סוג".** `_attrPicker` labels both
   `AttrKind.type` and `AttrKind.subtype` as "סוג" (lines ~783/785). A product
   with both a type chip and a subtype chip opens two different "בחר סוג"
   pickers. Suggest: type → "בחר סוג", subtype → "בחר תת-סוג".

4. **Tiny chips.** `fontSize: 11`, vertical padding `1` (`_AttrChip` ~1549/1562).
   Hard to read/tap for older users. A bump to ~13 + a little vertical padding
   would match the accessibility direction taken in the finder rows.

5. **(minor) Green underlined words look like links but launch a search.**
   A 🔍 prefix or a one-word tooltip would set expectations.

None of 2–5 were touched by me — they live in the active card file. Only #1's
finder-side hint was added (additive, conflict-free).
