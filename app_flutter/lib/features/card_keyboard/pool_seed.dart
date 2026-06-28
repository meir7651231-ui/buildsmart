// pool_seed.dart — the ONE seed funnel (P7.62). Every mouth (word/material/job/
// category/text/voice/AI) ultimately yields a [CardSeed]; [seedStep] turns it into
// the SINGLE opening step ([kOpeningSeedAxis] — a non-signal sentinel, so no real
// axis is pre-answered), and [seedPool] applies it over the universe. ONE funnel,
// ONE axis: the screen wires every mouth through here (P7.68). PURE.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_seed.dart' show CardSeed;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep;

/// The SINGLE opening-seed axis label — public, non-signal, shared by EVERY mouth,
/// so a seed (whatever the mouth) keeps every real axis (size/material/colour/…)
/// offer-able and the dive still terminates. Replaces the per-mouth sentinels'
/// role once the screen migrates (P7.68).
const String kOpeningSeedAxis = '_seed.opening';

/// The seeded pool: the [universe] narrowed by [seed]'s predicate. Never invents —
/// every result is a real universe product.
List<LipskeyCatalogProduct> seedPool(
  CardSeed seed,
  List<LipskeyCatalogProduct> universe,
) =>
    universe.where(seed.seedPredicate).toList();

/// The opening step a [seed] pushes — the SAME shape for every mouth (one funnel).
NewbieStep seedStep(CardSeed seed) => NewbieStep(
      axisLabel: kOpeningSeedAxis,
      chipLabel: seed.displayLabel,
      crumbWord: seed.displayLabel,
      predicate: seed.seedPredicate,
    );
