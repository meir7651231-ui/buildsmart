import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_detail_mode.dart';
import 'user_profile.dart';

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

/// Cycle order for the UI chip: diy → contractor → pro → diy …
/// Pure (no provider read); the UI calls this on tap.
ProfessionMode nextProfessionMode(ProfessionMode current) {
  switch (current) {
    case ProfessionMode.diy:
      return ProfessionMode.contractor;
    case ProfessionMode.contractor:
      return ProfessionMode.pro;
    case ProfessionMode.pro:
      return ProfessionMode.diy;
  }
}

/// One-emoji + Hebrew label for the UI chip.
({String emoji, String label}) labelForProfession(ProfessionMode p) {
  switch (p) {
    case ProfessionMode.diy:
      return (emoji: '🔨', label: 'DIY');
    case ProfessionMode.contractor:
      return (emoji: '💼', label: 'קבלן');
    case ProfessionMode.pro:
      return (emoji: '🛠', label: 'מקצועי');
  }
}

/// Derive an initial [ProfessionMode] from the onboarding trade string stored
/// in [UserProfile.profession].  Used only when the user has not yet made an
/// explicit manual choice (i.e. [ProfessionModeNotifier._key] is absent).
///
/// Mapping:
///   'אינסטלטור' | 'חשמלאי'  → [ProfessionMode.pro]   (specialist trades)
///   'קבלן שיפוצים'           → [ProfessionMode.contractor]
///   empty / unknown           → [ProfessionMode.contractor]  (safe default)
ProfessionMode professionModeFromTrade(String trade) {
  switch (trade.trim()) {
    case 'אינסטלטור':
    case 'חשמלאי':
      return ProfessionMode.pro;
    case 'קבלן שיפוצים':
      return ProfessionMode.contractor;
    default:
      return ProfessionMode.contractor;
  }
}

class ProfessionModeNotifier extends StateNotifier<ProfessionMode> {
  ProfessionModeNotifier() : super(ProfessionMode.contractor) {
    _load();
  }

  static const _key = 'bs.profession-mode.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s != null) {
      // Explicit manual choice — always wins.
      for (final m in ProfessionMode.values) {
        if (m.name == s) {
          state = m;
          return;
        }
      }
    }
    // No explicit choice yet: derive from the onboarding trade selection.
    final profileRaw = prefs.getString(kUserProfileKey);
    if (profileRaw == null) return;
    try {
      final profile = UserProfile.fromJson(
        jsonDecode(profileRaw) as Map<String, dynamic>,
      );
      if (profile.profession.isNotEmpty) {
        final derived = professionModeFromTrade(profile.profession);
        state = derived;
        // Seed cardDetailModeProvider if the user hasn't explicitly set it.
        const detailKey = 'bs.card-detail-mode.v1';
        if (prefs.getString(detailKey) == null) {
          await prefs.setString(detailKey, defaultDetailFor(derived).name);
        }
      }
    } on Object catch (_) {
      // Corrupt profile — keep default.
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
