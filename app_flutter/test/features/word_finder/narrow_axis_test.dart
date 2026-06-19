// Pure unit test for the lifted finder axis logic (STEP 0). No widgets — just
// the behaviour-preserving narrowAxis(): on a pool whose products carry
// DIFFERENT size tokens AND more than one colour, the SIZE axis ('גודל') must
// win over the COLOUR axis ('צבע') — size precedes colour in the axis order.
//
// The SECOND group ('narrowAxis — the non-size branches') closes the coverage
// gap the size-only test above left: every OTHER branch of narrowAxis — the
// curated-facet 'אפשרות' override, the 'זווית' angle branch, the 'צבע' colour
// branch, the 'דגם' word branch, and the empty no-split case — each reached by
// a pool shaped to land on exactly that branch. The 'אפשרות' branch uses REAL
// kDivePool products selected by their fields (categoryHe + the curated
// keyword substrings); the size-free branches use minimal synthetic products
// because no real catalog pool isolates an angle/colour/word split WITHOUT a
// size token also splitting (size precedes them all, so it would win first).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/narrow_axis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('narrowAxis', () {
    // Three products: half-inch / three-quarter-inch / one-inch taps, each a
    // different colour. The names carry parseable inch tokens (1/2" → ½",
    // 3/4" → ¾", 1") so the size axis splits the pool (>1 size); the colours
    // (≥2) would split too, but size is checked first.
    const half = LipskeyCatalogProduct(
      sku: 'A', nameHe: 'ברז כיור 1/2"', nameEn: 'tap half',
      color: 'לבן',
      categoryHe: 'ברזי כיור', categoryEn: 'sink taps',
      categoryEmoji: '🚰', page: 1,
    );
    const threeQuarter = LipskeyCatalogProduct(
      sku: 'B', nameHe: 'ברז כיור 3/4"', nameEn: 'tap three-quarter',
      color: 'כרום',
      categoryHe: 'ברזי כיור', categoryEn: 'sink taps',
      categoryEmoji: '🚰', page: 1,
    );
    const oneInch = LipskeyCatalogProduct(
      sku: 'C', nameHe: 'ברז כיור 1"', nameEn: 'tap one-inch',
      color: 'שחור',
      categoryHe: 'ברזי כיור', categoryEn: 'sink taps',
      categoryEmoji: '🚰', page: 1,
    );

    test('returns the size axis (גודל), not colour (צבע), on a multi-size pool',
        () {
      final pool = [half, threeQuarter, oneInch];
      final axis = narrowAxis(pool, null);
      expect(axis.label, 'גודל');
      // Sanity: the pool DOES carry >1 distinct colours, so the only reason
      // we didn't land on 'צבע' is that size legitimately precedes colour.
      expect(colorOptions(pool).length, greaterThan(1));
      // The size chips are the parsed, pretty-folded inch tokens.
      expect(axis.chips, containsAll(<String>['½"', '¾"', '1"']));
    });
  });

  group('narrowAxis — the non-size branches', () {
    // (1) CURATED-FACET 'אפשרות' override — REAL kDivePool products, selected by
    // their fields. The 'מחסומים גלויים' category carries the curated keyword
    // set ['אמריקאי','נסתר','לכיור','למדיח','כביסה','מטבח']; a pool whose names
    // hit MORE THAN ONE of those keywords takes the curated branch BEFORE any
    // auto axis, so it must win even though the same names also carry inch sizes
    // (1.25"/2") that would otherwise trigger 'גודל'.
    test('curated facet wins (אפשרות) for a >1-keyword מחסומים גלויים pool', () {
      const subtype = 'מחסומים גלויים';
      // The verbatim curated keys for this subtype — proof we feed real ones.
      final curated = kFinderFacets[subtype];
      expect(curated, isNotNull,
          reason: 'מחסומים גלויים must be a curated finder facet');

      // REAL products from the union pool whose names contain DIFFERENT curated
      // keywords: '213055' → "...אמריקאי...לכיור...", '218553' → "...נסתר...".
      final pool = kDivePool
          .where((p) =>
              p.categoryHe == subtype &&
              const ['213055', '218553'].contains(p.sku))
          .toList();
      expect(pool.length, 2,
          reason: 'both curated-keyword traps must exist in kDivePool');

      final axis = narrowAxis(pool, subtype);
      expect(axis.label, 'אפשרות',
          reason: 'a subtype in kFinderFacets with >1 matching key takes the '
              'curated branch, ahead of the auto size/angle/colour/word axes');
      // The chips are the SUBSET of curated keys actually present in the pool —
      // at least the two we picked the products for.
      expect(axis.chips.length, greaterThan(1));
      expect(axis.chips, containsAll(<String>['אמריקאי', 'נסתר']),
          reason: 'the offered options are the curated keys the pool matches');
      for (final c in axis.chips) {
        expect(curated!.contains(c), isTrue,
            reason: 'every curated chip must come from kFinderFacets[$subtype]');
      }
    });

    // (2) ANGLE branch ('זווית') — a pool with >1 angle token and NO size token
    // (size precedes angle, so the size axis must be empty for angle to win).
    // Minimal synthetics: elbow names carrying ONLY a degree token (45°/90°);
    // the size regex requires an explicit unit glyph, so a bare `45°` parses as
    // an angle, never a size.
    test('angle axis (זווית) wins when sizes do not split but angles do', () {
      const a45 = LipskeyCatalogProduct(
        sku: 'ANG-45', nameHe: 'ברך נחושת 45°', nameEn: 'elbow 45deg',
        categoryHe: 'ברכים', categoryEn: 'elbows', categoryEmoji: '🔧', page: 1,
      );
      const a90 = LipskeyCatalogProduct(
        sku: 'ANG-90', nameHe: 'ברך נחושת 90°', nameEn: 'elbow 90deg',
        categoryHe: 'ברכים', categoryEn: 'elbows', categoryEmoji: '🔧', page: 1,
      );
      final pool = [a45, a90];
      // Guard the branch precondition: the size axis is genuinely empty here.
      expect(sizeTokensIn(pool), isEmpty,
          reason: 'these names carry no unit-glyph size — size must not split');
      expect(angleTokensIn(pool).length, greaterThan(1),
          reason: 'two distinct angle tokens — the angle axis splits');

      final axis = narrowAxis(pool, null);
      expect(axis.label, 'זווית',
          reason: 'with no size split, the >1-angle pool takes the angle axis');
      expect(axis.chips, containsAll(<String>['45°', '90°']));
    });

    // (3) COLOUR branch ('צבע') — identical names (no distinguishing word), no
    // size, no angle, but TWO colours. Size→angle→colour: the first two axes are
    // empty, so colour wins.
    test('colour axis (צבע) wins on a same-name, two-colour pool', () {
      const white = LipskeyCatalogProduct(
        sku: 'COL-W', nameHe: 'מושב אסלה', nameEn: 'toilet seat',
        color: 'לבן',
        categoryHe: 'מושבי אסלה', categoryEn: 'seats', categoryEmoji: '🚽',
        page: 1,
      );
      const grey = LipskeyCatalogProduct(
        sku: 'COL-G', nameHe: 'מושב אסלה', nameEn: 'toilet seat',
        color: 'אפור',
        categoryHe: 'מושבי אסלה', categoryEn: 'seats', categoryEmoji: '🚽',
        page: 1,
      );
      final pool = [white, grey];
      expect(sizeTokensIn(pool), isEmpty);
      expect(angleTokensIn(pool), isEmpty);
      expect(colorOptions(pool).length, 2,
          reason: 'two distinct colours — the colour axis splits');
      // Identical names ⇒ no distinguishing word, so colour is the only split.
      expect(wordOptions(pool), isEmpty,
          reason: 'same name on both ⇒ no characterizing word to compete');

      final axis = narrowAxis(pool, null);
      expect(axis.label, 'צבע',
          reason: 'no size/angle split and >1 colour ⇒ the colour axis wins');
      expect(axis.chips, <String>['אפור', 'לבן'],
          reason: 'colours are returned sorted');
    });

    // (4) WORD branch ('דגם') — a shared head word plus a distinguishing word
    // each, no size, no angle, ≤1 colour. The first three axes are empty, so the
    // characterizing-word axis carries the split.
    test('word axis (דגם) wins on a distinguishing-word pool', () {
      const round = LipskeyCatalogProduct(
        sku: 'WRD-R', nameHe: 'מחבר עגול', nameEn: 'connector round',
        categoryHe: 'מחברים', categoryEn: 'connectors', categoryEmoji: '🔩',
        page: 1,
      );
      const square = LipskeyCatalogProduct(
        sku: 'WRD-S', nameHe: 'מחבר מרובע', nameEn: 'connector square',
        categoryHe: 'מחברים', categoryEn: 'connectors', categoryEmoji: '🔩',
        page: 1,
      );
      final pool = [round, square];
      expect(sizeTokensIn(pool), isEmpty);
      expect(angleTokensIn(pool), isEmpty);
      expect(colorOptions(pool), isEmpty,
          reason: 'no colours set ⇒ the colour axis is empty');
      expect(wordOptions(pool).length, greaterThan(1),
          reason: 'עגול vs מרובע distinguish — the word axis splits');

      final axis = narrowAxis(pool, null);
      expect(axis.label, 'דגם',
          reason: 'only the characterizing-word axis splits this pool');
      expect(axis.chips, containsAll(<String>['עגול', 'מרובע']));
    });

    // (5) EMPTY no-split case — a single product cannot be narrowed by ANY axis
    // (every axis needs >1 option), so narrowAxis returns the empty sentinel
    // (label:'', chips:[]). This is the branch the engine reads to drop the bar.
    test('returns the empty sentinel when nothing can split the pool', () {
      const lone = LipskeyCatalogProduct(
        sku: 'LONE', nameHe: 'מחבר עגול', nameEn: 'connector round',
        categoryHe: 'מחברים', categoryEn: 'connectors', categoryEmoji: '🔩',
        page: 1,
      );
      final axis = narrowAxis(const [lone], null);
      expect(axis.label, '',
          reason: 'a single-product pool has no axis with >1 option');
      expect(axis.chips, isEmpty,
          reason: 'the empty sentinel carries no chips');
    });
  });
}
