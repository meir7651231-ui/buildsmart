// 🏠 תוכן-בית — the home-content section order (T3.I).
//
// Proto §1 (view-home, index.html:4416-4516) renders the home content as an
// ordered stack of sections. T3.I makes that order user-reorderable + persisted.
// The default order is VERBATIM from the prototype's section sequence:
//   categories(4443) → smart-install product row(4456) → smart work path(4466)
//   → promise cards(4478) → reorder history(4511).
//
// Persistence mirrors `smart_cart.dart` (SharedPreferences + JSON list of ids).

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The reorderable home content sections, in prototype order. The hero + search
/// are fixed chrome (not reorderable), matching the proto where only the content
/// blocks below the hero vary.
enum HomeSection {
  categories,
  products,
  workPath,
  promise,
  reorderHistory,
  // Previously-fixed trailing blocks, now manageable sections (screen-mgmt):
  installHero, // 'תכנון חיבור' — the compat module's home hero (org-gated)
  favorites, // 'מועדפים'
  superFinder, // 'מאתר-על' — the axis-dive super-wheel entry (kAxisDive-gated)
}

/// Display metadata for one home section (the drag-handle row label/emoji).
class HomeSectionMeta {
  const HomeSectionMeta(this.section, this.emoji, this.title);

  final HomeSection section;
  final String emoji;
  final String title;
}

/// Section labels — verbatim from the proto section titles.
const Map<HomeSection, HomeSectionMeta> kHomeSectionMeta = {
  HomeSection.categories:
      HomeSectionMeta(HomeSection.categories, '🗂️', 'מחלקות'),
  HomeSection.products: HomeSectionMeta(
      HomeSection.products, '🌳', 'עץ חכם — אינסטלציה'),
  HomeSection.workPath:
      HomeSectionMeta(HomeSection.workPath, '🛁', 'מסלול עבודה חכם'),
  HomeSection.promise:
      HomeSectionMeta(HomeSection.promise, '⚡', 'כלים מהירים'),
  HomeSection.reorderHistory: HomeSectionMeta(
      HomeSection.reorderHistory, '🔁', 'הזמנות אחרונות לאתר'),
  HomeSection.installHero:
      HomeSectionMeta(HomeSection.installHero, '🔌', 'תכנון חיבור'),
  HomeSection.favorites:
      HomeSectionMeta(HomeSection.favorites, '⭐', 'מועדפים'),
  HomeSection.superFinder:
      HomeSectionMeta(HomeSection.superFinder, '🕸️', 'מאתר-על'),
};

/// Default order — the prototype's top-to-bottom section sequence.
const List<HomeSection> kDefaultHomeOrder = [
  HomeSection.categories,
  HomeSection.products,
  HomeSection.workPath,
  HomeSection.promise,
  HomeSection.reorderHistory,
  HomeSection.installHero,
  HomeSection.favorites,
  HomeSection.superFinder,
];

/// The home screen's key + default section ids for the unified per-screen model
/// (`screen_sections.dart`) — ids == `HomeSection.name`, so the screen-mgmt
/// slice-3 migration maps cleanly both ways (`HomeSection.values.byName`).
const String kHomeScreenKey = 'home';
final List<String> kHomeSectionIds = [for (final s in kDefaultHomeOrder) s.name];

class HomeContentOrderNotifier extends StateNotifier<List<HomeSection>> {
  HomeContentOrderNotifier() : super(kDefaultHomeOrder) {
    _load();
  }

  static const String _prefsKey = 'bs_home_content_order_v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final names = (jsonDecode(raw) as List<dynamic>).cast<String>();
      final byName = {for (final s in HomeSection.values) s.name: s};
      final loaded = <HomeSection>[];
      for (final n in names) {
        final s = byName[n];
        if (s != null && !loaded.contains(s)) loaded.add(s);
      }
      // Append any section missing from the stored list (forward-compat).
      for (final s in kDefaultHomeOrder) {
        if (!loaded.contains(s)) loaded.add(s);
      }
      if (loaded.length == HomeSection.values.length) state = loaded;
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(state.map((s) => s.name).toList()),
      );
    } catch (_) {}
  }

  /// Move the section at [oldIndex] to [newIndex] (ReorderableListView contract).
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target < 0) target = 0;
    if (target > state.length - 1) target = state.length - 1;
    final next = [...state];
    final item = next.removeAt(oldIndex);
    next.insert(target, item);
    state = next;
    _persist();
  }

  /// Move a section up one slot (for the non-drag up/down affordance).
  void moveUp(HomeSection s) {
    final i = state.indexOf(s);
    if (i <= 0) return;
    reorder(i, i - 1);
  }

  /// Move a section down one slot.
  void moveDown(HomeSection s) {
    final i = state.indexOf(s);
    if (i < 0 || i >= state.length - 1) return;
    reorder(i, i + 2);
  }

  /// Restore the prototype default order.
  void reset() {
    state = kDefaultHomeOrder;
    _persist();
  }
}

final homeContentOrderProvider =
    StateNotifierProvider<HomeContentOrderNotifier, List<HomeSection>>(
  (_) => HomeContentOrderNotifier(),
);
