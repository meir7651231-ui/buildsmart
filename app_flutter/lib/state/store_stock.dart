// 🏪 store out-of-stock set — the supplier's per-product "אזל מהמלאי" toggles.
//
// Lives in `lib/state/` (not on the store dashboard screen) so it can be read
// from the shared persona portal (`screens/persona_portal.dart` — the autoStock
// tile renders this live list) WITHOUT the portal having to import the store
// dashboard, which would create a circular import (the dashboard imports the
// portal for its 8 tiles).
//
// Persists best-effort to its own SharedPreferences key (`bs.store-oos.v1`) —
// the same pattern the orders engine + fulfillment side-car use — so the
// availability toggles survive an app restart.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kOosKey = 'bs.store-oos.v1';

class StoreOosNotifier extends StateNotifier<Set<String>> {
  StoreOosNotifier() : super(const {}) {
    unawaited(_load());
  }

  /// True once any mutation has been applied (or _load completes).
  /// Guards against _load clobbering a mutation that arrived before prefs.
  bool _loaded = false;

  // Setter does NOT persist — the mutators (markOos/markAvailable) persist
  // explicitly (the cart_lists shape), so we only flag the load-guard here.
  @override
  set state(Set<String> value) {
    _loaded = true; // mutation happened — block any pending _load
    super.state = value;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kOosKey);
      if (list != null && !_loaded) {
        super.state = list.toSet(); // bypass setter so we don't re-persist on load
        _loaded = true;
      } else {
        _loaded = true;
      }
    } on Object catch (_) {
      _loaded = true; // keep empty
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kOosKey, state.toList());
    } on Object catch (_) {/* best-effort */}
  }

  void markOos(String name) {
    state = {...state, name};
    unawaited(_persist());
  }

  void markAvailable(String name) {
    state = {...state}..remove(name);
    unawaited(_persist());
  }
}

final storeOosProvider =
    StateNotifierProvider<StoreOosNotifier, Set<String>>(
  (_) => StoreOosNotifier(),
);
