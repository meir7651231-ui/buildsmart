import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which live department's catalog is open inside the departments home
/// (null = show the departments grid). It lives in the shell's first tab so the
/// chrome (AppBar + bottom nav) stays put; tapping the מחלקות tab resets it.
final homeDepartmentProvider = StateProvider<String?>((_) => null);

/// Departments home (Benzi #2/#3) — the app's new landing: a grid of the
/// 9 departments. Plumbing departments (the existing catalog) are live; the rest
/// are placeholders until their catalog data exists (R8 — no data, no invention).
class DepartmentsScreen extends ConsumerWidget {
  const DepartmentsScreen({super.key});

  // Names verbatim from Benzi's spec (#2). `live` = has catalog data today.
  static const List<({String name, IconData icon, bool live})> departments = [
    (name: 'אינסטלציה', icon: Icons.plumbing, live: true),
    (name: 'ברזים וסניטריים', icon: Icons.water_drop, live: true),
    (name: 'חשמל', icon: Icons.electrical_services, live: false),
    (name: 'חומרי בניין', icon: Icons.foundation, live: false),
    (name: 'כלי עבודה ידני', icon: Icons.handyman, live: false),
    (name: 'כלי עבודה חשמלי', icon: Icons.construction, live: false),
    (name: 'צבע וכלים לצבע', icon: Icons.format_paint, live: false),
    (name: 'גבס ופרופילים', icon: Icons.view_column, live: false),
    (name: 'אספקה טכנית', icon: Icons.settings_input_component, live: false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A live department selected → show its catalog inline (shell chrome stays).
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

  final ({String name, IconData icon, bool live}) dept;

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
          if (dept.live) {
            ref.read(homeDepartmentProvider.notifier).state = dept.name;
          } else {
            showToast(context, 'בקרוב');
          }
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
