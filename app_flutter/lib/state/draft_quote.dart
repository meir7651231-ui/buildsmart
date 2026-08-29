import 'dart:convert';

import 'package:buildsmart/data/repositories/draft_quotes_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A quote text the user prepared but hasn't shared yet — saved under a label
/// so the user can come back to it. Roadmap step 48 adjacent (extends the
/// share-quote flow to drafts).
@immutable
class DraftQuote {
  const DraftQuote({
    required this.id,
    required this.label,
    required this.text,
    required this.savedAt,
  });
  final String id;
  final String label;
  final String text;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'text': text,
        'savedAt': savedAt.toIso8601String(),
      };

  factory DraftQuote.fromJson(Map<String, dynamic> j) => DraftQuote(
        id: j['id'] as String,
        label: j['label'] as String,
        text: j['text'] as String,
        savedAt:
            DateTime.tryParse(j['savedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class DraftQuoteNotifier extends StateNotifier<List<DraftQuote>> {
  DraftQuoteNotifier({this.maxEntries = 30, DraftQuotesRepository? repo})
      : _repo = repo,
        super(const []) {
    _load();
  }

  /// The server store for the drafts (`draftQuotes/{uid}`) when USER_DATA_SERVER
  /// is on for a real signed-in user; null (the default) ⇒ the SharedPreferences
  /// path below, byte-identical to before. Injected by [draftQuoteProvider].
  final DraftQuotesRepository? _repo;

  final int maxEntries;
  static const _key = 'bs.draft-quotes.v1';

  /// True once any mutation has been applied (or _load completes). Guards
  /// against _load clobbering a mutation that arrived before the store resolved
  /// (the carts/savedProjects load-clobber latch).
  bool _loaded = false;

  @override
  set state(List<DraftQuote> value) {
    _loaded = true; // mutation happened — block any pending _load
    super.state = value;
  }

  Future<void> _load() async {
    final repo = _repo;
    if (repo != null) {
      // Server path (USER_DATA_SERVER): the drafts live at `draftQuotes/{uid}`.
      // Seed via super.state (bypass the setter so load never re-persists); the
      // _loaded latch still blocks a load from clobbering an in-flight mutation.
      try {
        final list = List.of(await repo.load(repo.currentUid));
        if (!_loaded) {
          super.state = list;
          _loaded = true;
        }
      } on Object catch (_) {
        _loaded = true;
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      _loaded = true;
      return;
    }
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => DraftQuote.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!_loaded) {
        super.state = list; // bypass setter so we don't re-persist on load
        _loaded = true;
      }
    } on Object catch (_) {
      // Corrupt/old payload — keep the empty list.
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    final repo = _repo;
    if (repo != null) {
      // Server path: mirror the whole list to `draftQuotes/{uid}`.
      try {
        await repo.save(repo.currentUid, state);
      } on Object catch (_) {}
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(state.map((q) => q.toJson()).toList()));
    } on Object catch (_) {}
  }

  /// Save a draft. If a draft with the same [label] already exists, REPLACE
  /// its text (no duplicate). Otherwise append; trim to [maxEntries] keeping
  /// the newest. Returns the saved DraftQuote.
  DraftQuote save({required String label, required String text}) {
    final now = DateTime.now();
    final id = '${now.microsecondsSinceEpoch}_${label.hashCode}';
    final q = DraftQuote(id: id, label: label, text: text, savedAt: now);
    final filtered = state.where((d) => d.label != label).toList();
    final next = [...filtered, q];
    state = next.length > maxEntries
        ? next.sublist(next.length - maxEntries)
        : next;
    _persist();
    return q;
  }

  void remove(String id) {
    final next = state.where((d) => d.id != id).toList();
    if (next.length == state.length) return;
    state = next;
    _persist();
  }

  void clear() {
    if (state.isEmpty) return;
    state = const [];
    _persist();
  }

  DraftQuote? byLabel(String label) {
    for (final d in state) {
      if (d.label == label) return d;
    }
    return null;
  }
}

final draftQuoteProvider =
    StateNotifierProvider<DraftQuoteNotifier, List<DraftQuote>>(
  (ref) => DraftQuoteNotifier(repo: ref.watch(draftQuotesRepositoryProvider)),
);
