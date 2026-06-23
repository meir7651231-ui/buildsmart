import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Max number of recent picks retained (newest first).
const int kMaxSmartInputRecent = 20;

/// Persisted usage signal that feeds `rankSuggestions` — a recent-first list of
/// picked texts plus a per-text frequency tally. Mirrors the
/// `FeatureFlagsNotifier` / `RecentSearchesNotifier` persistence pattern: an
/// async `_load()` in the ctor, a `_persist()` after each mutation, and a
/// one-shot `_userTouched` guard so a late-resolving `_load()` cannot clobber a
/// synchronous user write (the provider is lazy).
@immutable
class SmartInputUsage {
  final List<String> recent;
  final Map<String, int> frequencies;
  const SmartInputUsage({this.recent = const [], this.frequencies = const {}});
}

class SmartInputUsageNotifier extends StateNotifier<SmartInputUsage> {
  SmartInputUsageNotifier() : super(const SmartInputUsage()) {
    _load();
  }

  static const _key = 'bs.smart-input-usage.v1';
  static const _recentKey = '$_key.recent';
  static const _freqKey = '$_key.frequencies';

  /// Late-load guard: once the user has recorded anything, a slow `_load()`
  /// must not overwrite the synchronous write (lazy provider ordering).
  bool _userTouched = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(_recentKey);
    final freqRaw = prefs.getString(_freqKey);
    if (_userTouched) return;

    final freqs = <String, int>{};
    if (freqRaw != null) {
      // Guard the decode like every sibling store — a corrupt/truncated value
      // must not throw out of this unawaited load (it would be swallowed by the
      // global onError, but the usage signal would silently stay empty).
      try {
        final decoded = jsonDecode(freqRaw);
        if (decoded is Map) {
          decoded.forEach((k, v) {
            if (v is num) freqs['$k'] = v.toInt();
          });
        }
      } on Object catch (_) {
        // corrupt frequencies → ignore; self-heals on the next pick
      }
    }

    if (recent == null && freqRaw == null) return; // nothing persisted yet
    state = SmartInputUsage(recent: recent ?? const [], frequencies: freqs);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, state.recent);
    await prefs.setString(_freqKey, jsonEncode(state.frequencies));
  }

  /// Record a pick: prepend [text] to `recent` (de-duplicated, newest first,
  /// capped to [kMaxSmartInputRecent]) and increment its frequency. Blank
  /// inputs are ignored. Then persist.
  void record(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    _userTouched = true;

    final recent = [t, ...state.recent.where((e) => e != t)];
    if (recent.length > kMaxSmartInputRecent) {
      recent.removeRange(kMaxSmartInputRecent, recent.length);
    }

    final frequencies = {...state.frequencies};
    frequencies[t] = (frequencies[t] ?? 0) + 1;

    state = SmartInputUsage(recent: recent, frequencies: frequencies);
    _persist();
  }
}

final smartInputUsageProvider =
    StateNotifierProvider<SmartInputUsageNotifier, SmartInputUsage>(
  (_) => SmartInputUsageNotifier(),
);
