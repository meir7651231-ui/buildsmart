import 'package:buildsmart/data/menu_trees.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/data/settings_tree.dart';
import 'package:buildsmart/screens/store_screen.dart' show StoreSection, storeSectionProvider;
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/chat_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/menu_state.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:buildsmart/state/user_profile.dart';
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
                showToast(context, '🚧 ${s.title} — בבנייה');
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
    // placeholder — currency stored but not consumed anywhere (v6.14)
    '₪ שקל'           => false,
    r'$ דולר'         => false,
    'עברית'            => s.lang == BsLang.he,
    'العربية'          => s.lang == BsLang.ar,
    'English'           => s.lang == BsLang.en,
    // placeholder — units/haul/express stored but not consumed anywhere (v6.14)
    'מטרי (מ׳, ק״ג)'  => false,
    'אימפריאלי'       => false,
    'משלוח קטן'       => false,
    'טנדר'             => false,
    'משאית'            => false,
    'ברירת מחדל — משלוח אקספרס' => false,
    // Fix 2 — highContrast reads catalogSettingsProvider (main.dart AppTheme)
    'מצב ניגודיות גבוהה (לשמש)' => cs.highContrast,
    // placeholder — security toggles stored but not consumed anywhere (v6.14)
    'אימות דו-שלבי'   => false,
    'כניסה ביומטרית'  => false,
    'הרשאת מיקום'     => false,
    '5 דק׳'   => false,
    '15 דק׳'  => false,
    '30 דק׳'  => false,
    '60 דק׳'  => false,
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
    // placeholder — currency not consumed; show honest stub (v6.14)
    case '₪ שקל':
    case r'$ דולר':
      showToast(context, '🚧 $label — בבנייה');
      return;
    case 'עברית':             n.update((s) => s.copyWith(lang: BsLang.he));
    case 'العربية':           n.update((s) => s.copyWith(lang: BsLang.ar));
    case 'English':            n.update((s) => s.copyWith(lang: BsLang.en));
    // placeholder — units/haul/express not consumed; show honest stub (v6.14)
    case 'מטרי (מ׳, ק״ג)':
    case 'אימפריאלי':
    case 'משלוח קטן':
    case 'טנדר':
    case 'משאית':
    case 'ברירת מחדל — משלוח אקספרס':
      showToast(context, '🚧 $label — בבנייה');
      return;
    // Fix 2 — write highContrast to catalogSettingsProvider (main.dart AppTheme)
    case 'מצב ניגודיות גבוהה (לשמש)':
      cn.update((s) => s.copyWith(highContrast: !s.highContrast));
    // placeholder — security toggles not consumed; show honest stub (v6.14)
    case 'אימות דו-שלבי':
    case 'כניסה ביומטרית':
    case 'הרשאת מיקום':
    case '5 דק׳':
    case '15 דק׳':
    case '30 דק׳':
    case '60 דק׳':
      showToast(context, '🚧 $label — בבנייה');
      return;
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
                  ref.read(catalogSettingsProvider.notifier).reset();
                  ref.read(notifSettingsProvider.notifier).reset();
                  ref.read(chatSettingsProvider.notifier).reset();
                  ref.read(storeSettingsProvider.notifier).reset();
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
    // Profile values shown in the 👤 חשבון group leaves.
    final profile = groupId == 'account'
        ? ref.watch(userProfileProvider)
        : null;

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
            label: _accountLabel(n.label, profile),
            emoji: group.emoji,
            icon: Icons.circle,
            active: _isOn(ref, n.label) || _accountActive(n.label, profile),
            onTap: () {
              if (n.hasChildren) {
                ref.read(settingsDrillProvider.notifier).state = [
                  ...path,
                  n.label,
                ];
                return;
              }
              // Account leaves with real edit affordances (uses profile != null
              // as guard — only reachable when groupId == 'account').
              if (profile != null) {
                switch (n.label) {
                  case 'שם הקבלן':
                    _showNameContactDialog(context, ref, profile, editName: true);
                    return;
                  case 'טלפון':
                    _showNameContactDialog(context, ref, profile, editName: false);
                    return;
                  case 'תחום מקצועי':
                    _showProfessionDialog(context, ref, profile);
                    return;
                  case 'סוג עוסק':
                    showToast(context, '🚧 סוג עוסק — בבנייה');
                    return;
                }
              }
              _applyLeaf(ref, context, n.label);
            },
          ),
      ],
    );
  }
}

/// Returns the display label for a settings leaf, appending the live
/// profile value for the 👤 חשבון group leaves that surface stored data.
String _accountLabel(String label, UserProfile? profile) {
  if (profile == null) return label;
  final value = switch (label) {
    'שם הקבלן'       => profile.name.trim(),
    'טלפון'          => profile.contact.trim(),
    'תחום מקצועי'    => profile.profession.trim(),
    _                => '',
  };
  return value.isEmpty ? label : '$label: $value';
}

/// Returns true (active/filled highlight) when the account leaf has a
/// stored value so the user can see at a glance that the field is set.
bool _accountActive(String label, UserProfile? profile) {
  if (profile == null) return false;
  return switch (label) {
    'שם הקבלן'       => profile.name.trim().isNotEmpty,
    'טלפון'          => profile.contact.trim().isNotEmpty,
    'תחום מקצועי'    => profile.profession.trim().isNotEmpty,
    _                => false,
  };
}

// ─── account-leaf edit dialogs ────────────────────────────────────────────────

/// Opens an edit dialog for 'שם הקבלן' and 'טלפון'.
/// Prefills from [profile]; on save calls [register(name:contact:)],
/// keeping the unchanged field intact.
void _showNameContactDialog(
  BuildContext context,
  WidgetRef ref,
  UserProfile profile, {
  required bool editName, // true → focus name field; false → focus contact
}) {
  final nameCtrl    = TextEditingController(text: profile.name);
  final contactCtrl = TextEditingController(text: profile.contact);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFFFFFFFF),
      title: Text(
        editName ? 'עריכת שם הקבלן' : 'עריכת טלפון',
        style: const TextStyle(color: Color(0xFF1A1A1A)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            autofocus: editName,
            style: const TextStyle(color: Color(0xFF1A1A1A)),
            decoration: const InputDecoration(hintText: 'שם הקבלן'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: contactCtrl,
            autofocus: !editName,
            style: const TextStyle(color: Color(0xFF1A1A1A)),
            decoration: const InputDecoration(hintText: 'טלפון'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ביטול', style: TextStyle(color: Colors.black38)),
        ),
        TextButton(
          onPressed: () {
            final name    = nameCtrl.text.trim();
            final contact = contactCtrl.text.trim();
            if (name.isEmpty && contact.isEmpty) return;
            ref.read(userProfileProvider.notifier).register(
                  name: name.isNotEmpty ? name : profile.name,
                  contact: contact.isNotEmpty ? contact : profile.contact,
                );
            Navigator.pop(ctx);
            showToast(context, 'הפרטים עודכנו');
          },
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF7A18)),
          child: const Text('שמור'),
        ),
      ],
    ),
  );
}

/// Opens a picker dialog for 'תחום מקצועי'; calls [setProfession(...)].
void _showProfessionDialog(
  BuildContext context,
  WidgetRef ref,
  UserProfile profile,
) {
  const options = ['אינסטלטור', 'חשמלאי', 'קבלן שיפוצים'];
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFFFFFFFF),
      title: const Text(
        'תחום מקצועי',
        style: TextStyle(color: Color(0xFF1A1A1A)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final opt in options)
            ListTile(
              title: Text(opt, style: const TextStyle(color: Color(0xFF1A1A1A))),
              trailing: profile.profession == opt
                  ? const Icon(Icons.check_circle, color: Color(0xFFFF7A18))
                  : null,
              onTap: () {
                ref.read(userProfileProvider.notifier).setProfession(opt);
                Navigator.pop(ctx);
                showToast(context, 'תחום מקצועי עודכן');
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ביטול', style: TextStyle(color: Colors.black38)),
        ),
      ],
    ),
  );
}
