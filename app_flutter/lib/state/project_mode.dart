import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Active project type — which "world" the user is shopping for. Persisted
/// so the card can later hide irrelevant content (e.g. hide hot-water-only
/// items when the project is `cold`, or show only commercial-grade items in
/// `commercial`). Roadmap step 52 (state layer; UI filter wiring TBD).
enum ProjectMode { any, cold, hot, commercial }

class ProjectModeNotifier extends StateNotifier<ProjectMode> {
  ProjectModeNotifier() : super(ProjectMode.any) {
    _load();
  }

  static const _key = 'bs.project-mode.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null) return;
    for (final m in ProjectMode.values) {
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

  void set(ProjectMode mode) {
    if (state == mode) return;
    state = mode;
    _persist();
  }

  bool get isFiltering => state != ProjectMode.any;
}

/// Cycle order for the UI chip: any → cold → hot → commercial → any.
/// Pure — caller passes the current; UI taps to advance.
ProjectMode nextProjectMode(ProjectMode current) {
  switch (current) {
    case ProjectMode.any:
      return ProjectMode.cold;
    case ProjectMode.cold:
      return ProjectMode.hot;
    case ProjectMode.hot:
      return ProjectMode.commercial;
    case ProjectMode.commercial:
      return ProjectMode.any;
  }
}

/// One-emoji + Hebrew label for the UI chip.
({String emoji, String label}) labelForProjectMode(ProjectMode m) {
  switch (m) {
    case ProjectMode.any:
      return (emoji: '◯', label: 'הכל');
    case ProjectMode.cold:
      return (emoji: '❄️', label: 'קר');
    case ProjectMode.hot:
      return (emoji: '🔥', label: 'חם');
    case ProjectMode.commercial:
      return (emoji: '🏢', label: 'מסחרי');
  }
}

final projectModeProvider =
    StateNotifierProvider<ProjectModeNotifier, ProjectMode>(
  (_) => ProjectModeNotifier(),
);
