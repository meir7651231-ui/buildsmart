import 'package:buildsmart/state/prefs_persisted.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active project type — which "world" the user is shopping for. Persisted
/// so the card can later hide irrelevant content (e.g. hide hot-water-only
/// items when the project is `cold`, or show only commercial-grade items in
/// `commercial`). Roadmap step 52 (state layer; UI filter wiring TBD).
enum ProjectMode { any, cold, hot, commercial }

class ProjectModeNotifier extends StateNotifier<ProjectMode>
    with EnumPrefsPersisted<ProjectMode> {
  ProjectModeNotifier() : super(ProjectMode.any) {
    _load();
  }

  @override
  String get persistKey => 'bs.project-mode.v1';
  @override
  List<ProjectMode> get persistValues => ProjectMode.values;

  Future<void> _load() async {
    final v = await readPersistedEnum();
    if (v != null) state = v;
  }

  void set(ProjectMode mode) => setPersisted(mode);

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
