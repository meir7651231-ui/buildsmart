import 'package:buildsmart/data/menu_trees.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/data/settings_tree.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/menu_state.dart';
import 'package:buildsmart/widgets/dial.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Menu FAB dial — 4 tabs (home · projects · cart · settings).
/// Each tab opens a section tree with arbitrary-depth drilling.
class MenuDialWidget extends ConsumerWidget {
  const MenuDialWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(menuTabProvider);
    if (tab == null) return const _TabsRoot();

    return switch (tab) {
      MenuTab.home     => const _SectionDrill(tab: MenuTab.home),
      MenuTab.projects => const _SectionDrill(tab: MenuTab.projects),
      MenuTab.cart     => const _SectionDrill(tab: MenuTab.cart),
      MenuTab.settings => const _SettingsDrill(),
    };
  }
}

class _TabsRoot extends ConsumerWidget {
  const _TabsRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const tabs = [
      (tab: MenuTab.home,     label: 'בית',         emoji: '🏠'),
      (tab: MenuTab.projects, label: 'הפרויקטים',   emoji: '🏗️'),
      (tab: MenuTab.cart,     label: 'רכש',         emoji: '🛒'),
      (tab: MenuTab.settings, label: 'הגדרות',      emoji: '⚙️'),
    ];
    return DialColumn(
      children: [
        for (final t in tabs)
          DialRow(
            label: t.label,
            emoji: t.emoji,
            icon: Icons.circle,
            onTap: () => ref.read(menuTabProvider.notifier).state = t.tab,
          ),
      ],
    );
  }
}

class _SectionDrill extends ConsumerWidget {
  const _SectionDrill({required this.tab});

  final MenuTab tab;

  StateProvider<List<String>> get _drillProvider => switch (tab) {
        MenuTab.home     => homeDrillProvider,
        MenuTab.projects => projectsDrillProvider,
        MenuTab.cart     => cartDrillProvider,
        MenuTab.settings => throw StateError('settings uses its own widget'),
      };

  List<Section> get _root => switch (tab) {
        MenuTab.home     => kHomeTree,
        MenuTab.projects => projectsTree(),
        MenuTab.cart     => kCartTree,
        MenuTab.settings => const [],
      };

  ({String label, String emoji}) get _tabAnchor => switch (tab) {
        MenuTab.home     => (label: 'בית',        emoji: '🏠'),
        MenuTab.projects => (label: 'הפרויקטים',  emoji: '🏗️'),
        MenuTab.cart     => (label: 'רכש',        emoji: '🛒'),
        MenuTab.settings => (label: 'הגדרות',     emoji: '⚙️'),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(_drillProvider);
    final walked = _walk(path);
    final anchor = _tabAnchor;

    return DialColumn(
      children: [
        DialRow(
          label: anchor.label,
          emoji: anchor.emoji,
          icon: Icons.circle,
          active: true,
          onTap: () {
            ref.read(menuTabProvider.notifier).state = null;
            ref.read(_drillProvider.notifier).state = const [];
          },
        ),
        for (var i = 0; i < walked.anchors.length; i++)
          DialRow(
            label: walked.anchors[i].title,
            emoji: walked.anchors[i].emoji,
            icon: Icons.circle,
            active: true,
            onTap: () => ref.read(_drillProvider.notifier).state =
                path.sublist(0, i),
          ),
        for (final s in walked.current)
          DialRow(
            label: s.title,
            emoji: s.emoji,
            icon: Icons.circle,
            onTap: () {
              if (s.hasChildren) {
                ref.read(_drillProvider.notifier).state = [...path, s.title];
              } else {
                showToast(context, '${s.title} — בבנייה');
              }
            },
          ),
      ],
    );
  }

  ({List<Section> anchors, List<Section> current}) _walk(List<String> path) {
    final anchors = <Section>[];
    var current = _root;
    for (final label in path) {
      final i = current.indexWhere((s) => s.title == label);
      if (i < 0) break;
      final node = current[i];
      if (!node.hasChildren) break;
      anchors.add(node);
      current = node.children;
    }
    return (anchors: anchors, current: current);
  }
}

class _SettingsDrill extends ConsumerWidget {
  const _SettingsDrill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(settingsGroupProvider);
    final tabAnchor = DialRow(
      label: 'הגדרות',
      emoji: '⚙️',
      icon: Icons.circle,
      active: true,
      onTap: () {
        ref.read(menuTabProvider.notifier).state = null;
        ref.read(settingsGroupProvider.notifier).state = null;
        ref.read(settingsDrillProvider.notifier).state = const [];
      },
    );

    // L2 — 10 groups.
    if (groupId == null) {
      return DialColumn(
        children: [
          tabAnchor,
          for (final g in kSettingsGroups)
            DialRow(
              label: g.label,
              emoji: g.emoji,
              icon: Icons.circle,
              onTap: () {
                if (g.isAction) {
                  showToast(context, '${g.label} — בבנייה');
                  return;
                }
                ref.read(settingsGroupProvider.notifier).state = g.id;
              },
            ),
        ],
      );
    }

    // L3+ — walk inside the chosen group.
    final group = kSettingsGroups.firstWhere((g) => g.id == groupId);
    final path = ref.watch(settingsDrillProvider);
    final walked = walkSettings(groupId, path);

    return DialColumn(
      children: [
        tabAnchor,
        DialRow(
          label: group.label,
          emoji: group.emoji,
          icon: Icons.circle,
          active: true,
          onTap: () {
            ref.read(settingsGroupProvider.notifier).state = null;
            ref.read(settingsDrillProvider.notifier).state = const [];
          },
        ),
        for (var i = 0; i < walked.anchors.length; i++)
          DialRow(
            label: walked.anchors[i].label,
            emoji: group.emoji,
            icon: Icons.circle,
            active: true,
            onTap: () => ref.read(settingsDrillProvider.notifier).state =
                path.sublist(0, i),
          ),
        for (final n in walked.current)
          DialRow(
            label: n.label,
            emoji: group.emoji,
            icon: Icons.circle,
            onTap: () {
              if (n.hasChildren) {
                ref.read(settingsDrillProvider.notifier).state = [
                  ...path,
                  n.label,
                ];
              } else {
                showToast(context, '${n.label} — בבנייה');
              }
            },
          ),
      ],
    );
  }
}
