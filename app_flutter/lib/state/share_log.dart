import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One share-action record. Persisted under `bs.share-log.v1` so the user (or
/// future analytics) can see what was shared and when. Domain mirrors the
/// in-memory bounded-list pattern of `state/crash_log.dart`, but — unlike
/// crash payloads — share metadata is benign and worth keeping across
/// restarts.
@immutable
class ShareEntry {
  const ShareEntry({
    required this.kind,
    required this.label,
    required this.at,
  });

  factory ShareEntry.fromJson(Map<String, dynamic> j) => ShareEntry(
        kind: (j['kind'] as String?) ?? '',
        label: (j['label'] as String?) ?? '',
        at: DateTime.tryParse((j['at'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// `'quote'` | `'deep-link'` | `'project-quote'` | any user-defined string.
  final String kind;

  /// Short human description ("ברז למטבח · AQUATEC").
  final String label;

  final DateTime at;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': kind,
        'label': label,
        'at': at.toIso8601String(),
      };
}

class ShareLogNotifier extends StateNotifier<List<ShareEntry>> {
  ShareLogNotifier({this.maxEntries = 100}) : super(const []) {
    _load();
  }

  final int maxEntries;

  static const _key = 'bs.share-log.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final parsed = list
          .map((e) => ShareEntry.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      // Defensive: also trim to maxEntries on load, in case the cap shrunk
      // between app versions.
      state = parsed.length > maxEntries
          ? parsed.sublist(0, maxEntries)
          : parsed;
    } on Object {
      // Corrupt payload — start clean rather than crash the notifier.
      state = const [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(state.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_key, encoded);
  }

  /// Add a new entry to the **front** (newest first) and trim to [maxEntries].
  void record({required String kind, required String label}) {
    final entry =
        ShareEntry(kind: kind, label: label, at: DateTime.now());
    final next = <ShareEntry>[entry, ...state];
    if (next.length > maxEntries) {
      state = next.sublist(0, maxEntries);
    } else {
      state = next;
    }
    _persist();
  }

  void clear() {
    state = const [];
    _persist();
  }

  /// Number of entries with [kind] (exact match).
  int countByKind(String kind) {
    return state.where((e) => e.kind == kind).length;
  }
}

final shareLogProvider =
    StateNotifierProvider<ShareLogNotifier, List<ShareEntry>>(
  (_) => ShareLogNotifier(),
);
