import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/recent_searches.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen Catalog settings — 9 categories, ~40 leaves.
/// All 22 new fields persisted via [catalogSettingsProvider].
class CatalogSettingsScreen extends ConsumerWidget {
  const CatalogSettingsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CatalogSettingsScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text(
          'הגדרות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          IconButton(
            tooltip: 'איפוס לברירת מחדל',
            icon: const Icon(Icons.restart_alt, color: Colors.black54),
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          _ProfileRow(),
          _ThemeSection(),
          _NotificationsSection(),
          _RegionSection(),
          _SearchSection(),
          _DisplaySection(),
          _PricesSection(),
          _FavoritesSection(),
          _CatalogNotifSection(),
          _UnitsSection(),
          _SuppliersSection(),
          _AiSection(),
          _AccessibilitySection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF),
            title: const Text(
              'איפוס הגדרות?',
              style: TextStyle(color: BsTokens.inkLight),
            ),
            content: const Text(
              'כל ההגדרות יוחזרו לברירת המחדל.',
              style: TextStyle(color: Colors.black54),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('ביטול'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('אפס'),
              ),
            ],
          ),
    );
    if ((ok ?? false) && context.mounted) {
      await ref.read(catalogSettingsProvider.notifier).reset();
      await ref.read(appSettingsProvider.notifier).reset();
      await ref.read(notifSettingsProvider.notifier).reset();
      if (context.mounted) showToast(context, 'הגדרות אופסו');
    }
  }
}

// ─── 0. profile (account home — always visible, guest path) ──────────────────

/// Tappable account row at the very top — opens [ProfileScreen] for everyone,
/// including guests (so a guest can open the profile and register). Ported from
/// the menu-dial ⚙️ → 👤 חשבון group, now surfaced as the settings home header.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const Text('👤', style: TextStyle(fontSize: 22)),
        title: const Text(
          'הפרופיל שלי',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_left, color: Colors.black54),
        onTap: () => Navigator.of(context).push(ProfileScreen.route()),
      ),
    );
  }
}

// ─── 0a. theme (ported from menu-dial — display → ערכת נושא) ──────────────────

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return _SectionTile(
      emoji: '🖥️',
      title: 'תצוגה',
      children: [
        _RadioGroupRow<BsTheme>(
          label: 'ערכת נושא',
          value: settings.theme,
          options: const [
            (value: BsTheme.light, label: 'בהיר'),
            (value: BsTheme.dark, label: 'כהה'),
          ],
          onChanged:
              (v) => ref
                  .read(appSettingsProvider.notifier)
                  .update((s) => s.copyWith(theme: v)),
        ),
      ],
    );
  }
}

// ─── 0b. notifications (ported from menu-dial — 🔔 התראות) ────────────────────

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notif = ref.watch(notifSettingsProvider);
    return _SectionTile(
      emoji: '🔔',
      title: 'התראות',
      children: [
        _SwitchRow(
          label: 'עדכוני משלוחים',
          value: notif.typeShipments,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typeShipments: v)),
        ),
        _SwitchRow(
          label: 'מבצעים והטבות',
          value: notif.typeDeals,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typeDeals: v)),
        ),
        _SwitchRow(
          label: 'התראות תקציב',
          value: notif.typePriceDrops,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typePriceDrops: v)),
        ),
        _SwitchRow(
          label: 'עדכוני הזמנות',
          value: notif.typeOrders,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typeOrders: v)),
        ),
      ],
    );
  }
}

// ─── 0c. region & language (ported from menu-dial — 🌐 אזור ושפה) ─────────────

class _RegionSection extends ConsumerWidget {
  const _RegionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return _SectionTile(
      emoji: '🌐',
      title: 'אזור ושפה',
      children: [
        _RadioGroupRow<BsLang>(
          label: 'שפה',
          value: settings.lang,
          options: const [
            (value: BsLang.he, label: 'עברית'),
            (value: BsLang.ar, label: 'العربية'),
            (value: BsLang.en, label: 'English'),
          ],
          onChanged:
              (v) => ref
                  .read(appSettingsProvider.notifier)
                  .update((s) => s.copyWith(lang: v)),
        ),
      ],
    );
  }
}

// ─── 1. search & filters ─────────────────────────────────────────────────────

class _SearchSection extends ConsumerWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionTile(
      emoji: '🔍',
      title: 'חיפוש וסינון',
      children: [
        _SwitchRow(
          label: 'שמור היסטוריית חיפוש',
          value: settings.searchHistoryEnabled,
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(searchHistoryEnabled: v)),
        ),
        _SwitchRow(
          label: 'סרגל מיון מהיר במוצרים',
          value: settings.quickFilterBar,
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(quickFilterBar: v)),
        ),
        const _PlaceholderRow(label: 'רדיוס חיפוש'),
        _ActionRow(
          label: 'ניקוי היסטוריה',
          onTap: () {
            ref.read(recentSearchesProvider.notifier).clear();
            showToast(context, 'ההיסטוריה נוקתה');
          },
        ),
      ],
    );
  }
}

// ─── 2. display & sort ───────────────────────────────────────────────────────

class _DisplaySection extends ConsumerWidget {
  const _DisplaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionTile(
      emoji: '📊',
      title: 'תצוגה ומיון',
      children: [
        _RadioGroupRow<CatalogViewMode>(
          label: 'סוג תצוגה',
          value: settings.viewMode,
          options: const [
            (value: CatalogViewMode.grid, label: 'רשת (Grid)'),
            (value: CatalogViewMode.list, label: 'רשימה (List)'),
          ],
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(viewMode: v)),
        ),
        const _PlaceholderRow(label: 'מיון ברירת מחדל'),
        _NumberRow(
          label: 'עמודות בתצוגת רשת',
          value: settings.gridColumns,
          min: 1,
          max: 4,
          suffix: '',
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(gridColumns: v)),
        ),
        _RadioGroupRow<CatalogImageSize>(
          label: 'גודל תמונות',
          value: settings.imageSize,
          options: const [
            (value: CatalogImageSize.small, label: 'קטן'),
            (value: CatalogImageSize.medium, label: 'בינוני'),
            (value: CatalogImageSize.large, label: 'גדול'),
          ],
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(imageSize: v)),
        ),
      ],
    );
  }
}

// ─── 3. prices & currency ────────────────────────────────────────────────────

class _PricesSection extends ConsumerWidget {
  const _PricesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _SectionTile(
      emoji: '💰',
      title: 'מחירים ומטבע',
      children: [
        _PlaceholderRow(label: 'הצג מחירים כולל מע"מ'),
        _PlaceholderRow(label: 'מטבע'),
        _PlaceholderRow(label: 'הצגת מחיר ליחידה'),
        _PlaceholderRow(label: 'השוואת מחירים בין ספקים'),
      ],
    );
  }
}

// ─── 4. favorites & lists ────────────────────────────────────────────────────

class _FavoritesSection extends StatelessWidget {
  const _FavoritesSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '❤️',
      title: 'מועדפים ורשימות',
      children: [
        _PlaceholderRow(label: 'סנכרון מועדפים בין מכשירים'),
        _PlaceholderRow(label: 'רשימות קנייה לפי פרויקט'),
        _PlaceholderRow(label: 'שיתוף רשימה עם צוות'),
        _PlaceholderRow(label: 'יבוא / ייצוא רשימה'),
        _PlaceholderRow(label: 'התראה על שינוי מחיר במועדפים'),
      ],
    );
  }
}

// ─── 5. catalog notifications ────────────────────────────────────────────────

class _CatalogNotifSection extends StatelessWidget {
  const _CatalogNotifSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '🔔',
      title: 'התראות קטלוג',
      children: [
        _PlaceholderRow(label: 'ירידת מחיר במועדפים'),
        _PlaceholderRow(label: 'חזר למלאי'),
        _PlaceholderRow(label: 'מלאי נמוך'),
        _PlaceholderRow(label: 'מוצרים חדשים בקטגוריה'),
      ],
    );
  }
}

// ─── 6. units of measure ─────────────────────────────────────────────────────

class _UnitsSection extends StatelessWidget {
  const _UnitsSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '📏',
      title: 'יחידות מידה',
      children: [
        _PlaceholderRow(label: 'מערכת מידה'),
        _PlaceholderRow(label: 'פורמט מידות בכרטיס מוצר'),
        _PlaceholderRow(label: 'פורמט הצגה'),
      ],
    );
  }
}

// ─── 7. preferred suppliers ──────────────────────────────────────────────────

class _SuppliersSection extends StatelessWidget {
  const _SuppliersSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '🏪',
      title: 'ספקים מועדפים',
      children: [
        _PlaceholderRow(label: 'ספקים מסומנים כמועדפים'),
        _PlaceholderRow(label: 'ספקים חסומים'),
        _PlaceholderRow(label: 'מרחק מקסימלי'),
        _PlaceholderRow(label: 'דירוג מינימלי'),
        _PlaceholderRow(label: 'ספקים מקומיים בלבד'),
      ],
    );
  }
}

// ─── 8. AI & recommendations ─────────────────────────────────────────────────

class _AiSection extends StatelessWidget {
  const _AiSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '🤖',
      title: 'בינה מלאכותית והמלצות',
      children: [
        _PlaceholderRow(label: 'המלצות מבוססות בינה מלאכותית'),
        _PlaceholderRow(label: 'התאמה לפי היסטוריית הזמנות'),
        _PlaceholderRow(label: 'סינון לפי פרויקט פעיל'),
        _PlaceholderRow(label: 'חלופות זולות אוטומטיות'),
      ],
    );
  }
}

// ─── 9. interface & accessibility ────────────────────────────────────────────

class _AccessibilitySection extends ConsumerWidget {
  const _AccessibilitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionTile(
      emoji: '📱',
      title: 'ממשק ונגישות',
      children: [
        _SwitchRow(
          label: 'מצב קומפקטי (כרטיסים קטנים)',
          value: settings.compactMode,
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(compactMode: v)),
        ),
        _RadioGroupRow<CatalogTextSize>(
          label: 'גודל טקסט (כל האפליקציה)',
          value: settings.textSize,
          options: const [
            (value: CatalogTextSize.small, label: 'קטן'),
            (value: CatalogTextSize.medium, label: 'בינוני'),
            (value: CatalogTextSize.large, label: 'גדול'),
          ],
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(textSize: v)),
        ),
        _SwitchRow(
          label: 'ניגודיות גבוהה (כל האפליקציה)',
          value: settings.highContrast,
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(highContrast: v)),
        ),
        _SwitchRow(
          label: 'הנפשות מופחתות (כל האפליקציה)',
          value: settings.reducedMotion,
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(reducedMotion: v)),
        ),
      ],
    );
  }
}

// ─── shared widgets ──────────────────────────────────────────────────────────

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.emoji,
    required this.title,
    required this.children,
  });

  final String emoji;
  final String title;
  final List<Widget> children;

  // Count only functional rows — exclude "בבנייה" placeholders.
  int get _activeCount => children.where((w) => w is! _PlaceholderRow).length;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          iconColor: Colors.black54,
          collapsedIconColor: Colors.black54,
          leading: Text(emoji, style: const TextStyle(fontSize: 22)),
          // Count badge replaces the default expand chevron.
          trailing:
              _activeCount == 0
                  ? null
                  : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: BsTokens.brand,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      '$_activeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          title: Text(
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      value: value,
      activeColor: BsTokens.brand,
      onChanged: onChanged,
    );
  }
}

class _RadioGroupRow<T> extends StatelessWidget {
  const _RadioGroupRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<({T value, String label})> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
        ...options.map(
          (o) => RadioListTile<T>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              o.label,
              style: const TextStyle(color: BsTokens.inkLight),
            ),
            value: o.value,
            groupValue: value,
            activeColor: BsTokens.brand,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: const Text(
        'בבנייה',
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
      ),
      onTap: () => showToast(context, '$label — בבנייה'),
    );
  }
}

class _NumberRow extends StatelessWidget {
  const _NumberRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
    this.step = 1,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.black54, size: 20),
            onPressed:
                value > min
                    ? () => onChanged((value - step).clamp(min, max))
                    : null,
          ),
          Text(
            suffix.isEmpty ? '$value' : '$value $suffix',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black54, size: 20),
            onPressed:
                value < max
                    ? () => onChanged((value + step).clamp(min, max))
                    : null,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.brand)),
      onTap: onTap,
    );
  }
}
