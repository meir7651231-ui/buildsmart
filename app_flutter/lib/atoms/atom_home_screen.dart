// Engine-driven contractor home. Holds the same drill state as `FinderScreen`,
// computes the same derived data (system filter + narrow/angle/letter/wall
// axes), and renders the same tree — but assembled by the atom engine from the
// contractor-home manifest instead of a hand-wired Column. Reached only when
// `kAtomEngine` is on; proven pixel-identical to `FinderScreen` by
// `test/atom_home_parity_test.dart`.
import 'package:buildsmart/atoms/atom_engine.dart';
import 'package:buildsmart/atoms/atom_schema.dart';
import 'package:buildsmart/atoms/finder_model.dart';
import 'package:buildsmart/atoms/home_atoms.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/_size_norm.dart';
import 'package:buildsmart/screens/finder_screen.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The parsed contractor-home schema (from the embedded, file-synced manifest).
final AtomSchema kContractorHomeSchema =
    AtomSchema.parse(kContractorHomeManifestJson);

class AtomHomeScreen extends ConsumerStatefulWidget {
  const AtomHomeScreen({super.key});
  @override
  ConsumerState<AtomHomeScreen> createState() => _AtomHomeScreenState();
}

class _AtomHomeScreenState extends ConsumerState<AtomHomeScreen> {
  FinderGroup? _group;
  String? _sub;
  String? _size;
  String? _angle;
  String? _letter;
  String? _wall;

  void _selectGroup(FinderGroup g) => setState(() {
        _group = g;
        _sub = null;
        _size = null;
        _angle = null;
        _letter = null;
        _wall = null;
      });

  void _back() => setState(() {
        if (_angle != null) {
          _angle = null;
          _letter = null;
          _wall = null;
        } else if (_size != null) {
          _size = null;
        } else if (_sub != null) {
          _sub = null;
        } else {
          _group = null;
        }
      });

  void _selectSub(String? label) => setState(() {
        _sub = label;
        _size = null;
        _angle = null;
        _letter = null;
        _wall = null;
      });

  @override
  Widget build(BuildContext context) {
    final systemFilter = ref.watch(catalogSystemFilterProvider);
    final group = _group;

    // ── landing groups (system-filtered, counted) — mirrors _typeList. ──────
    var landingGroups = const <(FinderGroup, int)>[];
    if (group == null) {
      final catCounts = categoryCounts(systemFilter);
      landingGroups = [
        for (final g in kFinderGroups)
          if (groupCount(g, catCounts) > 0) (g, groupCount(g, catCounts)),
      ];
    }

    // ── drill-mode derived data — mirrors the finder's build(). ─────────────
    var subs = const <FinderSub>[];
    var narrow = (label: '', chips: const <String>[]);
    var angleChips = const <String>[];
    var letterChips = const <String>[];
    var wallChips = const <String>[];
    var results = const <LipskeyCatalogProduct>[];
    var shown = 0;

    if (group != null) {
      final base = filterBySystem(productsForGroup(group), systemFilter);
      subs = subsFor(group, base);
      FinderSub? sel;
      for (final s in subs) {
        if (s.label == _sub) {
          sel = s;
          break;
        }
      }
      final pool = sel == null
          ? base
          : base.where((p) => sel!.cats.contains(p.categoryHe)).toList();
      narrow = narrowAxis(pool, _sub);
      angleChips = narrow.label == 'זווית'
          ? const <String>[]
          : angleTokensIn(pool).map((t) => t.label).toList();
      letterChips = letterOptions(pool);
      wallChips = wallOptions(pool);
      results = pool;
      if (_size != null) {
        results = results.where((p) => productHasChip(p, _size!)).toList();
      }
      if (_angle != null) {
        results = results.where((p) => productHasChip(p, _angle!)).toList();
      }
      if (_letter != null) {
        results = results
            .where((p) => letterSizeTokens(p.nameHe).contains(_letter))
            .toList();
      }
      if (_wall != null) {
        results =
            results.where((p) => wallTokens(p.nameHe).contains(_wall)).toList();
      }
      shown = results.map(productListDedupeKey).toSet().length;
    }

    final tipDismissed = ref.watch(finderChipTipDismissedProvider);

    bool visible(String when) {
      switch (when) {
        case 'landing':
          return group == null;
        case 'drilled':
          return group != null;
        case 'has_subs':
          return group != null && subs.length > 1;
        case 'has_narrow':
          return group != null && narrow.chips.isNotEmpty;
        case 'has_angles':
          return group != null && angleChips.length > 1;
        case 'has_letters':
          return group != null && letterChips.length > 1;
        case 'has_wall':
          return group != null && wallChips.length > 1;
        case 'has_results':
          return group != null && results.isNotEmpty;
        case 'has_results_and_tip':
          return group != null && results.isNotEmpty && !tipDismissed;
        default:
          return false;
      }
    }

    Widget buildAtom(AtomSpec spec) {
      switch (spec.id) {
        case 'type_grid':
          return AtomTypeGrid(groups: landingGroups, onSelect: _selectGroup);
        case 'breadcrumb':
          return AtomBreadcrumb(
            group: group!,
            sub: _sub,
            size: _size,
            onBack: _back,
          );
        case 'subtype_chips':
          return AtomChipBar(
            hint: 'סוג',
            options: [for (final s in subs) s.label],
            selected: _sub,
            onSelectAll: () => _selectSub(null),
            onSelect: _selectSub,
          );
        case 'narrow_chips':
          return AtomChipBar(
            hint: narrow.label.isEmpty ? 'גודל' : narrow.label,
            options: narrow.chips,
            selected: _size,
            onSelectAll: () => setState(() => _size = null),
            onSelect: (c) => setState(() => _size = c),
          );
        case 'angle_chips':
          return AtomChipBar(
            hint: 'זווית',
            options: angleChips,
            selected: _angle,
            onSelectAll: () => setState(() => _angle = null),
            onSelect: (c) => setState(() => _angle = c),
          );
        case 'letter_chips':
          return AtomChipBar(
            hint: 'מידה',
            options: letterChips,
            selected: _letter,
            onSelectAll: () => setState(() => _letter = null),
            onSelect: (c) => setState(() => _letter = c),
          );
        case 'wall_chips':
          return AtomChipBar(
            hint: 'עובי',
            options: wallChips,
            selected: _wall,
            labelFor: (c) => '$c מ"מ',
            onSelectAll: () => setState(() => _wall = null),
            onSelect: (c) => setState(() => _wall = c),
          );
        case 'result_count':
          return AtomResultCount(count: shown);
        case 'chip_tip':
          return AtomChipTip(
            onDismiss: () => ref
                .read(finderChipTipDismissedProvider.notifier)
                .state = true,
          );
        case 'results':
          return AtomProductList(products: results);
        default:
          return const SizedBox.shrink();
      }
    }

    return AtomEngine.render(
      kContractorHomeSchema,
      (spec) => visible(spec.when)
          ? AtomSlot(visible: true, child: buildAtom(spec))
          : const AtomSlot.hidden(),
    );
  }
}
