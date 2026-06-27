// color_truth.dart — kTrueColors / isTrueColor / cardColorOptions (P1 step 42).
// The catalog encodes metal FINISHES (copper, nickel, chrome, brushed gold,
// stainless) in the SAME `color` field as real colours, so the live colour axis
// offers 'נחושת' as if it were a colour. kTrueColors is the allowlist of actual
// colours; the finish leaks are its COMPLEMENT. cardColorOptions strips them from
// the unified-finder colour axis. ADDITIVE: kLipskeyColors and the live
// colorOptions are untouched, so the live colour axis stays byte-identical.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show colorOptions;

/// The real product colours in the catalog. Metal finishes (זהב / כרום / נחושת /
/// ניקל / נירוסטה …) are deliberately ABSENT — a finish, or the material itself,
/// is never a colour and belongs on the material axis.
const Set<String> kTrueColors = {
  'אדום', 'אפור', "בז'", 'גרפיטי', 'ירוק', 'כחול', 'כתום',
  'לבן', 'מט שחור', 'פרגמון', 'שחור', 'שחור ירוק', 'שחור מט',
};

/// Whether [color] is a genuine colour (in [kTrueColors]) rather than a metal
/// finish miscoded into the catalog's colour field.
bool isTrueColor(String color) => kTrueColors.contains(color);

/// The unified-finder colour axis: the live [colorOptions] with the finish leaks
/// removed, so 'נחושת' / 'כרום' never appear as a "colour" chip. ADDITIVE —
/// nothing rewires onto this yet, so the live colour axis is byte-identical.
List<String> cardColorOptions(List<LipskeyCatalogProduct> pool) =>
    colorOptions(pool).where(isTrueColor).toList();
