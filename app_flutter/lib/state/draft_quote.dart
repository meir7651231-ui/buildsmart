
import 'package:buildsmart/state/prefs_persisted.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class DraftQuoteNotifier extends StateNotifier<List<DraftQuote>>
    with JsonListPrefsPersisted<DraftQuote> {
  DraftQuoteNotifier({this.maxEntries = 30}) : super(const []) {
    loadFromPrefs();
  }

  @override
  String get persistKey => _key;
  @override
  DraftQuote decodeElement(Map<String, dynamic> json) => DraftQuote.fromJson(json);
  @override
  Map<String, dynamic> encodeElement(DraftQuote element) => element.toJson();
  final int maxEntries;
  static const _key = 'bs.draft-quotes.v1';



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
    persistToPrefs();
    return q;
  }

  void remove(String id) {
    final next = state.where((d) => d.id != id).toList();
    if (next.length == state.length) return;
    state = next;
    persistToPrefs();
  }

  void clear() {
    if (state.isEmpty) return;
    state = const [];
    persistToPrefs();
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
