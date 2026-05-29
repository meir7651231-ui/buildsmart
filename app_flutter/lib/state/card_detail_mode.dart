import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How much depth the SmartProduct card shows. `simple` keeps the card to the
/// essentials (summary · price · "connects to N"); `expert` adds the full
/// engineering detail (standards, tools, bore, brand-guide, variants, the
/// compliance "why" lines). Persisted so the choice survives a refresh.
/// Roadmap step 95.
enum CardDetailMode { simple, expert }

class CardDetailModeNotifier extends StateNotifier<CardDetailMode> {
  CardDetailModeNotifier() : super(CardDetailMode.expert) {
    _load();
  }

  static const _key = 'bs.card-detail-mode.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    if (v == 'simple') state = CardDetailMode.simple;
    if (v == 'expert') state = CardDetailMode.expert;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state.name);
  }

  void set(CardDetailMode mode) {
    if (state == mode) return;
    state = mode;
    _persist();
  }

  void toggle() => set(
      state == CardDetailMode.expert ? CardDetailMode.simple : CardDetailMode.expert);

  bool get isExpert => state == CardDetailMode.expert;
}

final cardDetailModeProvider =
    StateNotifierProvider<CardDetailModeNotifier, CardDetailMode>(
  (_) => CardDetailModeNotifier(),
);
