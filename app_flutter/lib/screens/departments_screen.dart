import 'package:buildsmart/data/lipskey_verified_connections.dart';
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
/// The two live departments ARE the clean-water/sewage division (Benzi #1):
/// each opens the catalog's category tree filtered to its `WaterSystem`, so a
/// fixture's sub-categories split (supply parts under מים נקיים = ברזים
/// וסניטריים, drainage parts under שפכים = אינסטלציה). The rest are placeholders
/// until their catalog data exists (R8 — no data, no invention).
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
    // A live department selected → its filtered catalog tree (shell chrome stays).
    if (ref.watch(homeDepartmentProvider) != null) return const CatalogScreen();

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
          // Open the catalog's category tree, filtered to this department's
          // water system (Benzi #1 division, at sub-category level).
          ref.read(catalogSystemFilterProvider.notifier).state = dept.system;
          ref.read(catalogTreePathProvider.notifier).state =
              const [kDepartmentTreeRoot];
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
