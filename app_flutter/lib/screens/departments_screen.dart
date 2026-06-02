import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which live department is open inside the departments home (null = show the
/// grid). It lives in the shell's first tab so the chrome (AppBar + bottom nav)
/// stays put; tapping the מחלקות tab resets it.
final homeDepartmentProvider = StateProvider<String?>((_) => null);

/// Departments home (Benzi #2/#3) — the app's landing: a grid of departments.
/// The two live departments ARE the clean-water/sewage division (Benzi #1,
/// option 2): each opens the catalog's **finder (בית)** scoped to its
/// `WaterSystem`, so every browse section (finder / categories / tree / search)
/// shows only that system's products. The rest are placeholders until their
/// catalog data exists (R8 — no data, no invention).
class DepartmentsScreen extends ConsumerWidget {
  const DepartmentsScreen({super.key});

  // Names verbatim from Benzi's spec (#2). `system` set on the two live ones.
  static const List<({String name, IconData icon, bool live, WaterSystem? system})>
      departments = [
    (name: 'אינסטלציה', icon: Icons.plumbing, live: true, system: WaterSystem.drainage),
    (name: 'ברזים וסניטריים', icon: Icons.water_drop, live: true, system: WaterSystem.supply),
    (name: 'חשמל', icon: Icons.electrical_services, live: false, system: null),
    (name: 'חומרי בניין', icon: Icons.foundation, live: false, system: null),
    (name: 'כלי עבודה ידני', icon: Icons.handyman, live: false, system: null),
    (name: 'כלי עבודה חשמלי', icon: Icons.construction, live: false, system: null),
    (name: 'צבע וכלים לצבע', icon: Icons.format_paint, live: false, system: null),
    (name: 'גבס ופרופילים', icon: Icons.view_column, live: false, system: null),
    (name: 'אספקה טכנית', icon: Icons.settings_input_component, live: false, system: null),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A live department selected → a scope bar (department · system + clear) over
    // the catalog finder, all scoped to its water system (shell chrome stays).
    final active = ref.watch(homeDepartmentProvider);
    if (active != null) {
      final dept = departments.firstWhere((d) => d.name == active,
          orElse: () => departments.first);
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _DeptScopeBar(name: dept.name, system: dept.system),
            const Expanded(child: CatalogScreen()),
          ],
        ),
      );
    }

    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(BsTokens.space4, BsTokens.space4,
                  BsTokens.space4, BsTokens.space2),
              child: Text(
                'מחלקות',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.fromLTRB(
                    BsTokens.space4, 0, BsTokens.space4, BsTokens.space5),
                mainAxisSpacing: BsTokens.space3,
                crossAxisSpacing: BsTokens.space3,
                childAspectRatio: 1.15,
                children: [for (final d in departments) _DeptTile(dept: d)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeptTile extends ConsumerWidget {
  const _DeptTile({required this.dept});

  final ({String name, IconData icon, bool live, WaterSystem? system}) dept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fg = dept.live ? BsTokens.brand : BsTokens.mutedLight;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: () {
          if (!dept.live) {
            showToast(context, 'בקרוב');
            return;
          }
          // Open the catalog's finder (בית) scoped to this department's water
          // system (Benzi #1, option 2 — the division flows through the finder,
          // not a forced tree). Every browse section reads the scope provider.
          ref.read(catalogSystemFilterProvider.notifier).state = dept.system;
          ref.read(catalogSectionProvider.notifier).state = 'בית';
          ref.read(catalogTreePathProvider.notifier).state = const [];
          ref.read(homeDepartmentProvider.notifier).state = dept.name;
        },
        child: Semantics(
          label: dept.live ? dept.name : '${dept.name} — בקרוב',
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(dept.icon, size: 40, color: fg),
                const SizedBox(height: BsTokens.space3),
                Text(
                  dept.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: dept.live ? theme.colorScheme.onSurface : fg,
                  ),
                ),
                if (!dept.live) ...[
                  const SizedBox(height: BsTokens.space1),
                  Text('בקרוב',
                      style: theme.textTheme.labelSmall?.copyWith(color: fg)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Context bar shown above the catalog while a department is open: names the
/// active department + water-system scope, and clears back to the grid. Makes
/// the clean-water/sewage division visible (Benzi #1) instead of silent.
class _DeptScopeBar extends ConsumerWidget {
  const _DeptScopeBar({required this.name, required this.system});

  final String name;
  final WaterSystem? system;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sysLabel = switch (system) {
      WaterSystem.supply => 'מים נקיים',
      WaterSystem.drainage => 'שפכים',
      null => null,
    };
    return Material(
      color: BsTokens.brand.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space4, vertical: BsTokens.space2),
        child: Row(
          children: [
            const Icon(Icons.tune, size: 18, color: BsTokens.brand),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: Text(
                sysLabel == null ? name : '$name · $sysLabel',
                style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700, color: BsTokens.brand),
              ),
            ),
            InkWell(
              onTap: () {
                ref.read(homeDepartmentProvider.notifier).state = null;
                ref.read(catalogSystemFilterProvider.notifier).state = null;
                ref.read(catalogTreePathProvider.notifier).state = const [];
              },
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              child: const Padding(
                padding: EdgeInsets.all(BsTokens.space1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('כל המחלקות',
                        style: TextStyle(
                            color: BsTokens.brand,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: 2),
                    Icon(Icons.close, size: 16, color: BsTokens.brand),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
