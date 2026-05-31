import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single entry in the offline cache: an opaque string value + when it was
/// saved + how long it stays fresh. Roadmap step 83 (cache primitive; concrete
/// consumers like image-cache / network-cache are separate steps).
@immutable
class CacheEntry {
  const CacheEntry({
    required this.value,
    required this.savedAt,
    required this.ttl,
  });
  final String value;
  final DateTime savedAt;
  final Duration ttl;

  bool isFresh(DateTime now) => now.difference(savedAt) < ttl;

  Map<String, dynamic> toJson() => {
        'v': value,
        'at': savedAt.toIso8601String(),
        'ttlMs': ttl.inMilliseconds,
      };

  factory CacheEntry.fromJson(Map<String, dynamic> j) => CacheEntry(
        value: j['v'] as String,
        savedAt: DateTime.parse(j['at'] as String),
        ttl: Duration(milliseconds: (j['ttlMs'] as num).toInt()),
      );
}

class OfflineCacheNotifier extends StateNotifier<Map<String, CacheEntry>> {
  OfflineCacheNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.offline-cache.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      state = m.map((k, v) =>
          MapEntry(k, CacheEntry.fromJson(v as Map<String, dynamic>)));
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(state.map((k, v) => MapEntry(k, v.toJson()))));
  }

  /// Returns the cached value for [key] when fresh; null when absent or expired.
  /// [now] is overridable for tests.
  String? get(String key, {DateTime? now}) {
    final entry = state[key];
    if (entry == null) return null;
    return entry.isFresh(now ?? DateTime.now()) ? entry.value : null;
  }

  /// Store [value] under [key] with a freshness window.
  void put(String key, String value,
      {Duration ttl = const Duration(hours: 24)}) {
    final next = Map<String, CacheEntry>.from(state);
    next[key] = CacheEntry(value: value, savedAt: DateTime.now(), ttl: ttl);
    state = next;
    _persist();
  }

  /// Drop entries that are no longer fresh. Returns the number dropped.
  int sweep({DateTime? now}) {
    final at = now ?? DateTime.now();
    final survivors = <String, CacheEntry>{};
    var dropped = 0;
    state.forEach((k, v) {
      if (v.isFresh(at)) {
        survivors[k] = v;
      } else {
        dropped++;
      }
    });
    if (dropped > 0) {
      state = survivors;
      _persist();
    }
    return dropped;
  }

  void clearAll() {
    if (state.isEmpty) return;
    state = const {};
    _persist();
  }
}

final offlineCacheProvider =
    StateNotifierProvider<OfflineCacheNotifier, Map<String, CacheEntry>>(
  (_) => OfflineCacheNotifier(),
);
