// The install/compatibility engine moved to packages/compat_engine (pure Dart).
// This file keeps the old import path working and holds the screen state, which
// belongs to the app, not to the engine.
import 'package:compat_engine/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:compat_engine/logic/install_engine.dart';

final compatGenderProvider  = StateProvider<String>((_) => 'הכל');
final compatSizeProvider    = StateProvider<String>((_) => 'הכל');
final compatMethodProvider  = StateProvider<String>((_) => 'הכל');
final compatSearchProvider  = StateProvider<String>((_) => '');

// ── plumbing chain state ──────────────────────────────────────────────────────

final chainProvider = StateProvider<List<LipskeyCatalogProduct>>((_) => []);

// Operating temperature of the line being built (°C). Drives the material
// suitability check — at 80°C, HDPE (capped ~40°C) is flagged unsuitable.
final lineMaxTempProvider = StateProvider<int>((_) => 20);

// Installation accessories confirmed for the line (insulation / clips / seal).
// Tracked separately from the series chain since they wrap/support, not flow.
final lineAccessoriesProvider = StateProvider<Set<String>>((_) => {});
