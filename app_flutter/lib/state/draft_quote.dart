import 'dart:convert';

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
  DraftQuoteNotifier({this.maxEntries = 30}) : super(const []) {
    _load();
  }
  final int maxEntries;
  static const _key = 'bs.draft-quotes.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      state = (jsonDecode(raw) as List)
          .map((e) => DraftQuote.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(state.map((e) => e.toJson()).toList()));
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
  (_) => DraftQuoteNotifier(),
);
