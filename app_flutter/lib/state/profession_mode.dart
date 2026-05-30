import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_detail_mode.dart';

/// Who's using the card — affects which detail level is the *sensible default*
/// and (in the future) which sections show by default. Orthogonal to
/// `cardDetailModeProvider`: profession picks the default mode; the user can
/// still toggle mode within that. Roadmap step 57 (state layer; UI affordance TBD).
enum ProfessionMode { diy, contractor, pro }

/// The recommended `CardDetailMode` for a given profession.
/// - diy → simple
/// - contractor / pro → expert
CardDetailMode defaultDetailFor(ProfessionMode p) =>
    p == ProfessionMode.diy ? CardDetailMode.simple : CardDetailMode.expert;

class ProfessionModeNotifier extends StateNotifier<ProfessionMode> {
  ProfessionModeNotifier() : super(ProfessionMode.contractor) {
    _load();
  }

  static const _key = 'bs.profession-mode.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null) return;
    for (final m in ProfessionMode.values) {
      if (m.name == s) {
        state = m;
        return;
      }
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state.name);
  }

  void set(ProfessionMode mode) {
    if (state == mode) return;
    state = mode;
    _persist();
  }
}

final professionModeProvider =
    StateNotifierProvider<ProfessionModeNotifier, ProfessionMode>(
  (_) => ProfessionModeNotifier(),
);
