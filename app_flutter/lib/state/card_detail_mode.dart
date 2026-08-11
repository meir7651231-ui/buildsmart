import 'package:buildsmart/state/prefs_persisted.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How much depth the SmartProduct card shows. `simple` keeps the card to the
/// essentials (summary · price · "connects to N"); `expert` adds the full
/// engineering detail (standards, tools, bore, brand-guide, variants, the
/// compliance "why" lines). Persisted so the choice survives a refresh.
/// Roadmap step 95.
enum CardDetailMode { simple, expert }

class CardDetailModeNotifier extends StateNotifier<CardDetailMode>
    with EnumPrefsPersisted<CardDetailMode> {
  CardDetailModeNotifier() : super(CardDetailMode.expert) {
    _load();
  }

  @override
  String get persistKey => 'bs.card-detail-mode.v1';
  @override
  List<CardDetailMode> get persistValues => CardDetailMode.values;

  Future<void> _load() async {
    final v = await readPersistedEnum();
    if (v != null) state = v;
  }

  void set(CardDetailMode mode) => setPersisted(mode);

  void toggle() => set(
      state == CardDetailMode.expert ? CardDetailMode.simple : CardDetailMode.expert);

  bool get isExpert => state == CardDetailMode.expert;
}

final cardDetailModeProvider =
    StateNotifierProvider<CardDetailModeNotifier, CardDetailMode>(
  (_) => CardDetailModeNotifier(),
);
