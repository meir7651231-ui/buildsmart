// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · representative-image QUALITY (owner: never a black tile/header,
// always the clearest photo). Some catalog crops are near-black (a failed crop / a
// black background — e.g. sku 1053232 is a WHITE jacuzzi pipe whose image measures
// luma≈3). The color FIELD can't catch these (null, or 'לבן' for that black photo),
// so the only honest signal is the IMAGE's measured brightness.
//
// [kImageBrightness] is the MEASURED mean luminance (0-255) of the DARK-ISH crops
// (luma < 150) under assets/lipskey/products/ — a companion to the (already
// hardcoded) catalog, regenerated with it (bright crops omitted ⇒ treated as 255).
// The representative selectors ([browse_model]) pick the BRIGHTEST image of a
// type/family (relative — the clearest, most central photo) and, when even the best
// is below [kDarkFloor], fall back to the emoji so a tile/header is NEVER black.
//
// GATING (byte-identical-off): pure const + pure predicates; imported only by the
// gated browse layer ⇒ tree-shaken from a default (OFF) build.
// ─────────────────────────────────────────────────────────────────────────────

/// Measured mean luminance (0-255) of the DARK-ISH product crops (luma < 150) —
/// the bright majority is omitted (⇒ [imageBrightness] returns 255 for them). Used
/// to RANK a type's images (pick the brightest) and to floor genuinely-black ones.
/// OWNER-REVIEW: regenerate by scanning assets/lipskey/products/ (mean luma, 32×32)
/// when the catalog images change; a filename that leaves the catalog just never
/// matches. A cluster at 130 = normal mid-tone products (kept), NOT black.
const Map<String, int> kImageBrightness = {
  '777D0481.jpg': 0, '77901011.jpg': 1, '77777483.jpg': 1, '9899.jpg': 1,
  '77777481.jpg': 1, '1053232.jpg': 3, '77MK0001.jpg': 4, '77006036.jpg': 4,
  '77409440.jpg': 5, '7ISR0002.jpg': 6, '77004410.jpg': 9, '77400222.jpg': 11,
  '34-5017.jpg': 11, '77401622.jpg': 11, '77MK0002.jpg': 12, '77403622.jpg': 12,
  '4502A.jpg': 13, '77006080.jpg': 13, '77408222.jpg': 14, '77409561.jpg': 14,
  '77402222.jpg': 15, '77428333.jpg': 15, '77775283.jpg': 15, '77772011.jpg': 16,
  '77775284.jpg': 21, '77006030.jpg': 26, '77777557.jpg': 31, '77SK0002.jpg': 32,
  '77575328.jpg': 32, '77775282.jpg': 36, '77775252.jpg': 37, '77575305.jpg': 40,
  '77775285.jpg': 40, '77404222.jpg': 49, '77775150.jpg': 50, '77771010.jpg': 55,
  '77775288.jpg': 55, '77775287.jpg': 64, '76032202.jpg': 78, '77Z2079C.jpg': 79,
  '218569.jpeg': 88, '611051.jpeg': 89, '77Z2081C.jpg': 91, '77407622.jpg': 91,
  '77405222.jpg': 93, '218127.jpeg': 93, '116212.jpeg': 95, '120311.jpeg': 98,
  '77775280.jpg': 100, '77771008.jpg': 104, '506537.jpeg': 105, '77771006.jpg': 106,
  '116151.jpeg': 106, '77777335.jpeg': 107, '635737.jpeg': 107, '77000010.jpg': 110,
  '7609202B.jpg': 111, '777Z3069.jpg': 112, '116640.jpeg': 115, '77003025.jpg': 119,
  '124842.jpeg': 119, '77000013.jpg': 121, '7777708B.jpg': 126, '7777707B.jpg': 126,
  '77980000.jpg': 126, '777Z3068.jpg': 126, '77000012.jpg': 127, '116071.jpeg': 130,
  '220278.jpeg': 130, '273226.jpeg': 130, '116680.jpeg': 130, '196175.jpeg': 130,
  '221021.jpeg': 130, '221415.jpeg': 130, '221084.jpeg': 130, '116091.jpeg': 130,
  '221022.jpeg': 130, '273227.jpeg': 130, '116078.jpeg': 130, '221085.jpeg': 130,
  '220280.jpeg': 130, '110689.jpeg': 130, '217648.jpeg': 134, '119215.jpeg': 134,
  '218460.jpeg': 134, '116593.jpeg': 134, '116194.jpeg': 135, '77777777.jpg': 136,
  '10411001.jpg': 138, '77777010.jpg': 139, '77003023.jpg': 140, '77775260.jpg': 141,
  '116163.jpeg': 141, '196172.jpeg': 142, '116659.jpeg': 142, '116220.jpeg': 142,
  '218681.jpeg': 142, '116229.jpeg': 142, '110682.jpeg': 142, '187463.jpeg': 142,
  '116666.jpeg': 142, '116201.jpeg': 142, '213073.jpeg': 142, '116186.jpeg': 142,
  '116684.jpeg': 142, '77980001.jpg': 143, '9101601210.jpg': 144, '9101601232.jpg': 144,
  '77003223.jpg': 144, '506510.jpeg': 144, '194898.jpeg': 144, '116191.jpeg': 145,
  '116203.jpeg': 145, '997091.jpeg': 145, '116668.jpeg': 145, '77777011.jpg': 146,
  '116169.jpeg': 146, '194897.jpeg': 147, '116581.jpeg': 147, '194899.jpeg': 147,
  '164588.jpeg': 147, '170643.jpeg': 147, '198517.jpeg': 147, '805024.jpeg': 147,
  '116058.jpeg': 147, '116624.jpeg': 148, '116180.jpeg': 149,
};

/// Below this mean luma an image reads as BLACK — the tile/header shows its EMOJI
/// instead (owner: never black). Above it, a dark-ish product photo is kept (it is
/// the real product, not a broken crop).
const int kDarkFloor = 100;

/// The basename of [assetPath] (after the last '/'), or null.
String? _basename(String? assetPath) {
  if (assetPath == null) return null;
  final slash = assetPath.lastIndexOf('/');
  return slash < 0 ? assetPath : assetPath.substring(slash + 1);
}

/// Measured brightness (0-255) of [assetPath]'s image — the bright majority is
/// omitted from [kImageBrightness] and returns 255 (bright); a null path returns
/// -1 (no image). So a HIGHER value = a clearer photo, for ranking a type's images.
int imageBrightness(String? assetPath) {
  final file = _basename(assetPath);
  if (file == null) return -1;
  return kImageBrightness[file] ?? 255;
}

/// A USABLE (non-black) representative image — present and at/above [kDarkFloor].
/// Null / genuinely-black ⇒ false (skip it; the caller shows the emoji).
bool isBrightImage(String? assetPath) => imageBrightness(assetPath) >= kDarkFloor;

/// Category emojis that themselves read as BLACK (e.g. 'אטמים ופקקים' is '⚫') — so
/// even the EMOJI fallback (shown when a photo is absent) would be a black tile.
const Set<String> _kBlackEmojis = {
  '⚫', '⬛', '🖤', '◼️', '◼', '◾', '▪️', '▪', '🔲', '🔳', '🕳️', '🕳',
};

/// The tile/header icon for [categoryEmoji] — the category emoji UNLESS it is blank
/// or a black glyph ([_kBlackEmojis]), in which case the neutral '📦'. So an emoji
/// FALLBACK is never black either (owner: no tile/header is ever black).
String tileEmoji(String categoryEmoji) =>
    categoryEmoji.isEmpty || _kBlackEmojis.contains(categoryEmoji)
        ? '📦'
        : categoryEmoji;
