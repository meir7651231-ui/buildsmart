import 'package:buildsmart/data/menu_trees.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/data/settings_tree.dart';
import 'package:buildsmart/screens/store_screen.dart' show StoreSection, storeSectionProvider;
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/menu_state.dart';
import 'package:buildsmart/state/notif_settings.dart';
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
              } else if (s.id == 'cart-mine') {
                ref.read(storeSectionProvider.notifier).state = StoreSection.cart;
                ref.read(mainTabProvider.notifier).state = 3;
                ref.read(menuTabProvider.notifier).state = null;
                ref.read(_drillProvider.notifier).state = const [];
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

/// Returns true if the given leaf label is currently the active choice
/// (so the dial row paints in the brand colour).
bool _isOn(WidgetRef ref, String label) {
  final s = ref.watch(appSettingsProvider);
  final cs = ref.watch(catalogSettingsProvider);
  final ns = ref.watch(notifSettingsProvider);
  return switch (label) {
    'בהיר'              => s.theme == BsTheme.light,
    'כהה'               => s.theme == BsTheme.dark,
    // Fix 1 — textSize reads catalogSettingsProvider (main.dart textScaler)
    'קטן'               => cs.textSize == CatalogTextSize.small,
    'בינוני'           => cs.textSize == CatalogTextSize.medium,
    'גדול'             => cs.textSize == CatalogTextSize.large,
    // Fix 3 — reducedMotion reads catalogSettingsProvider (catalog_screen / home_shell)
    'הפחתת אנימציות'  => cs.reducedMotion,
    '₪ שקל'           => s.currency == BsCurrency.ils,
    r'$ דולר'         => s.currency == BsCurrency.usd,
    'עברית'            => s.lang == BsLang.he,
    'العربية'          => s.lang == BsLang.ar,
    'English'           => s.lang == BsLang.en,
    'מטרי (מ׳, ק״ג)'  => s.units == BsUnits.metric,
    'אימפריאלי'       => s.units == BsUnits.imperial,
    'משלוח קטן'       => s.haul == BsHaulSize.small,
    'טנדר'             => s.haul == BsHaulSize.van,
    'משאית'            => s.haul == BsHaulSize.truck,
    'ברירת מחדל — משלוח אקספרס' => s.express,
    // Fix 2 — highContrast reads catalogSettingsProvider (main.dart AppTheme)
    'מצב ניגודיות גבוהה (לשמש)' => cs.highContrast,
    'אימות דו-שלבי'   => s.twoFA,
    'כניסה ביומטרית'  => s.biometric,
    'הרשאת מיקום'     => s.locationPerm,
    '5 דק׳'   => s.sessionTimeout == BsSessionTimeout.m5,
    '15 דק׳'  => s.sessionTimeout == BsSessionTimeout.m15,
    '30 דק׳'  => s.sessionTimeout == BsSessionTimeout.m30,
    '60 דק׳'  => s.sessionTimeout == BsSessionTimeout.m60,
    // Fix 4 — notification toggles read notifSettingsProvider
    'עדכוני משלוחים'  => ns.typeShipments,
    'מבצעים והטבות'   => ns.typeDeals,
    'התראות תקציב'     => ns.typePriceDrops,
    'עדכוני הזמנות'   => ns.typeOrders,
    'שיתוף נתוני שימוש' => s.privAnalytics,
    'שירותי מיקום'    => s.privLocation,
    'התאמת תוכן שיווקי' => s.privMarketing,
    'שליחת דוחות תקלה' => s.privCrashReports,
    _ => false,
  };
}

/// Applies the side-effect for a tapped settings leaf. Unknown labels
/// fall through to the "X — בבנייה" toast.
void _applyLeaf(WidgetRef ref, BuildContext context, String label) {
  final n  = ref.read(appSettingsProvider.notifier);
  final cn = ref.read(catalogSettingsProvider.notifier);
  final nn = ref.read(notifSettingsProvider.notifier);
  switch (label) {
    case 'בהיר':              n.update((s) => s.copyWith(theme: BsTheme.light));
    case 'כהה':               n.update((s) => s.copyWith(theme: BsTheme.dark));
    // Fix 1 — write textSize to catalogSettingsProvider (main.dart textScaler)
    case 'קטן':               cn.update((s) => s.copyWith(textSize: CatalogTextSize.small));
    case 'בינוני':           cn.update((s) => s.copyWith(textSize: CatalogTextSize.medium));
    case 'גדול':             cn.update((s) => s.copyWith(textSize: CatalogTextSize.large));
    // Fix 3 — write reducedMotion to catalogSettingsProvider
    case 'הפחתת אנימציות':
      cn.update((s) => s.copyWith(reducedMotion: !s.reducedMotion));
    case '₪ שקל':            n.update((s) => s.copyWith(currency: BsCurrency.ils));
    case r'$ דולר':          n.update((s) => s.copyWith(currency: BsCurrency.usd));
    case 'עברית':             n.update((s) => s.copyWith(lang: BsLang.he));
    case 'العربية':           n.update((s) => s.copyWith(lang: BsLang.ar));
    case 'English':            n.update((s) => s.copyWith(lang: BsLang.en));
    case 'מטרי (מ׳, ק״ג)':  n.update((s) => s.copyWith(units: BsUnits.metric));
    case 'אימפריאלי':        n.update((s) => s.copyWith(units: BsUnits.imperial));
    case 'משלוח קטן':        n.update((s) => s.copyWith(haul: BsHaulSize.small));
    case 'טנדר':              n.update((s) => s.copyWith(haul: BsHaulSize.van));
    case 'משאית':             n.update((s) => s.copyWith(haul: BsHaulSize.truck));
    case 'ברירת מחדל — משלוח אקספרס':
      n.update((s) => s.copyWith(express: !s.express));
    // Fix 2 — write highContrast to catalogSettingsProvider (main.dart AppTheme)
    case 'מצב ניגודיות גבוהה (לשמש)':
      cn.update((s) => s.copyWith(highContrast: !s.highContrast));
    case 'אימות דו-שלבי':
      n.update((s) => s.copyWith(twoFA: !s.twoFA));
    case 'כניסה ביומטרית':
      n.update((s) => s.copyWith(biometric: !s.biometric));
    case 'הרשאת מיקום':
      n.update((s) => s.copyWith(locationPerm: !s.locationPerm));
    case '5 דק׳':   n.update((s) => s.copyWith(sessionTimeout: BsSessionTimeout.m5));
    case '15 דק׳':  n.update((s) => s.copyWith(sessionTimeout: BsSessionTimeout.m15));
    case '30 דק׳':  n.update((s) => s.copyWith(sessionTimeout: BsSessionTimeout.m30));
    case '60 דק׳':  n.update((s) => s.copyWith(sessionTimeout: BsSessionTimeout.m60));
    // Fix 4 — notification toggles write to notifSettingsProvider
    case 'עדכוני משלוחים':
      nn.update((s) => s.copyWith(typeShipments: !s.typeShipments));
    case 'מבצעים והטבות':
      nn.update((s) => s.copyWith(typeDeals: !s.typeDeals));
    case 'התראות תקציב':
      nn.update((s) => s.copyWith(typePriceDrops: !s.typePriceDrops));
    case 'עדכוני הזמנות':
      nn.update((s) => s.copyWith(typeOrders: !s.typeOrders));
    case 'שיתוף נתוני שימוש':
      n.update((s) => s.copyWith(privAnalytics: !s.privAnalytics));
    case 'שירותי מיקום':
      n.update((s) => s.copyWith(privLocation: !s.privLocation));
    case 'התאמת תוכן שיווקי':
      n.update((s) => s.copyWith(privMarketing: !s.privMarketing));
    case 'שליחת דוחות תקלה':
      n.update((s) => s.copyWith(privCrashReports: !s.privCrashReports));
    default:
      showToast(context, '$label — בבנייה');
      return;
  }
  showToast(context, '$label עודכן');
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
                if (g.id == 'reset') {
                  ref.read(appSettingsProvider.notifier).reset();
                  showToast(context, 'איפוס לברירת מחדל');
                  return;
                }
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
            active: _isOn(ref, n.label),
            onTap: () {
              if (n.hasChildren) {
                ref.read(settingsDrillProvider.notifier).state = [
                  ...path,
                  n.label,
                ];
                return;
              }
              _applyLeaf(ref, context, n.label);
            },
          ),
      ],
    );
  }
}
