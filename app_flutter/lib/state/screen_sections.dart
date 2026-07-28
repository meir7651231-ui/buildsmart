// 🖥️ ניהול-מסכים — per-screen section layout: ORDER + HIDE, persisted (screen-
// management directive · slice-1). The GENERALIZATION of the two live section
// models into one:
//   • home_content_order.dart      — section ORDER (List<HomeSection>, home-only)
//   • hidden_catalog_sections.dart — section HIDE  (Set<String>, by label)
// → for each screen id, an ordered list of section ids + a hidden set. The
// wizard's "ניהול מסכים" (slice-2) edits this; real screens migrate onto it
// GRADUALLY (slice-5) — the two source models stay live until then (extend, don't
// touch). Default = EMPTY ⇒ every screen keeps its own canonical default order
// with nothing hidden ⇒ BYTE-IDENTICAL until a screen is actually customized.
// Non-destructive (hide, never delete) and canonical-minimal (an un-customized /
// reset screen leaves no trace in prefs), mirroring both sources.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One screen's section layout: an explicit display [order] of section ids (empty
/// ⇒ "use the screen's canonical default") + the [hidden] section ids (non-
/// destructive). Immutable; round-trips through JSON.
class ScreenLayout {
  const ScreenLayout(
      {this.order = const [], this.hidden = const {}, this.labels = const {}});

  factory ScreenLayout.fromJson(Map<String, dynamic> j) => ScreenLayout(
        order: (j['order'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>(),
        hidden: (j['hidden'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>()
            .toSet(),
        labels: (j['labels'] as Map<String, dynamic>? ?? const {})
            .map((k, v) => MapEntry(k, v as String)),
      );

  final List<String> order;
  final Set<String> hidden;

  /// Per-id label OVERRIDE (rename). Absent id ⇒ the caller's default label.
  final Map<String, String> labels;

  bool get isEmpty => order.isEmpty && hidden.isEmpty && labels.isEmpty;

  ScreenLayout copyWith(
          {List<String>? order,
          Set<String>? hidden,
          Map<String, String>? labels}) =>
      ScreenLayout(
        order: order ?? this.order,
        hidden: hidden ?? this.hidden,
        labels: labels ?? this.labels,
      );

  Map<String, dynamic> toJson() => {
        if (order.isNotEmpty) 'order': order,
        if (hidden.isNotEmpty) 'hidden': hidden.toList(),
        if (labels.isNotEmpty) 'labels': labels,
      };
}

/// Per-screen section layouts, keyed by screen id. Canonical-minimal: a screen
/// with no customization is ABSENT from the map (⇒ default order, nothing hidden).
class ScreenSectionsNotifier extends StateNotifier<Map<String, ScreenLayout>> {
  ScreenSectionsNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.screen-sections.v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = {
        for (final e in map.entries)
          e.key: ScreenLayout.fromJson(e.value as Map<String, dynamic>),
      };
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // canonical-minimal: drop empty layouts so a reset screen leaves no trace.
      final map = <String, dynamic>{
        for (final e in state.entries)
          if (!e.value.isEmpty) e.key: e.value.toJson(),
      };
      if (map.isEmpty) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, jsonEncode(map));
      }
    } catch (_) {}
  }

  ScreenLayout _of(String screen) => state[screen] ?? const ScreenLayout();

  void _set(String screen, ScreenLayout layout) {
    final next = {...state};
    if (layout.isEmpty) {
      next.remove(screen);
    } else {
      next[screen] = layout;
    }
    state = next;
    _persist();
  }

  /// The section ids for [screen] in effective display order: the stored order
  /// (only ids still present in [defaults], de-duped) then any [defaults] not yet
  /// listed (forward-compat) — the home_content_order reconcile algorithm, made
  /// generic. With no stored order this is just [defaults] ⇒ byte-identical.
  List<String> orderedIds(String screen, List<String> defaults) {
    final stored = _of(screen).order;
    final valid = defaults.toSet();
    final out = <String>[];
    for (final id in stored) {
      if (valid.contains(id) && !out.contains(id)) out.add(id);
    }
    for (final id in defaults) {
      if (!out.contains(id)) out.add(id);
    }
    return out;
  }

  /// [orderedIds] minus the hidden ids — what the screen actually renders.
  List<String> visibleIds(String screen, List<String> defaults) {
    final hidden = _of(screen).hidden;
    return orderedIds(screen, defaults)
        .where((id) => !hidden.contains(id))
        .toList();
  }

  bool isHidden(String screen, String id) => _of(screen).hidden.contains(id);

  void hide(String screen, String id) {
    final l = _of(screen);
    if (l.hidden.contains(id)) return;
    _set(screen, l.copyWith(hidden: {...l.hidden, id}));
  }

  void show(String screen, String id) {
    final l = _of(screen);
    if (!l.hidden.contains(id)) return;
    _set(screen, l.copyWith(hidden: {...l.hidden}..remove(id)));
  }

  void toggle(String screen, String id) =>
      isHidden(screen, id) ? show(screen, id) : hide(screen, id);

  /// The effective label for [id] on [screen]: the rename override, or [fallback].
  String labelOf(String screen, String id, String fallback) =>
      _of(screen).labels[id] ?? fallback;

  /// Set (or clear, when [value] is empty) the rename override for [id].
  void setLabel(String screen, String id, String value) {
    final l = _of(screen);
    final next = {...l.labels};
    final v = value.trim();
    if (v.isEmpty) {
      next.remove(id); // back to the default label
    } else {
      next[id] = v;
    }
    _set(screen, l.copyWith(labels: next));
  }

  /// Reorder [screen]'s sections (ReorderableListView contract), reconciled
  /// against [defaults] so a first-time reorder persists the full explicit order.
  void reorder(
      String screen, List<String> defaults, int oldIndex, int newIndex) {
    final ids = orderedIds(screen, defaults);
    if (oldIndex < 0 || oldIndex >= ids.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target > ids.length - 1) target = ids.length - 1;
    final next = [...ids];
    final item = next.removeAt(oldIndex);
    next.insert(target, item);
    _set(screen, _of(screen).copyWith(order: next));
  }

  /// Move one section up a slot (the non-drag up/down affordance).
  void moveUp(String screen, List<String> defaults, String id) {
    final ids = orderedIds(screen, defaults);
    final i = ids.indexOf(id);
    if (i <= 0) return;
    reorder(screen, defaults, i, i - 1);
  }

  /// Move one section down a slot.
  void moveDown(String screen, List<String> defaults, String id) {
    final ids = orderedIds(screen, defaults);
    final i = ids.indexOf(id);
    if (i < 0 || i >= ids.length - 1) return;
    reorder(screen, defaults, i, i + 2);
  }

  /// Drop all customization for [screen] (back to default order, nothing hidden).
  void resetScreen(String screen) => _set(screen, const ScreenLayout());
}

final screenSectionsProvider =
    StateNotifierProvider<ScreenSectionsNotifier, Map<String, ScreenLayout>>(
  (_) => ScreenSectionsNotifier(),
);
