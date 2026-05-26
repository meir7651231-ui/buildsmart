import 'package:buildsmart/screens/catalog_screen.dart'
    show recentSearchesProvider;
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen Catalog settings — 9 categories, ~40 leaves.
/// All 22 new fields persisted via [catalogSettingsProvider].
class CatalogSettingsScreen extends ConsumerWidget {
  const CatalogSettingsScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const CatalogSettingsScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text(
          'הגדרות קטלוג',
          style: TextStyle(
              color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          'איפוס הגדרות?',
          style: TextStyle(color: Color(0xFF1A1A1A)),
        ),
        content: const Text(
          'כל הגדרות הקטלוג יוחזרו לברירת המחדל.',
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
      if (context.mounted) showToast(context, 'הגדרות אופסו');
    }
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
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(searchHistoryEnabled: v)),
        ),
        _SwitchRow(
          label: 'סרגל מיון מהיר במוצרים',
          value: settings.quickFilterBar,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(quickFilterBar: v)),
        ),
        _NumberRow(
          label: 'רדיוס חיפוש',
          value: settings.searchRadius,
          min: 5,
          max: 500,
          suffix: 'ק"מ',
          step: 25,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(searchRadius: v)),
        ),
        _ActionRow(
          label: 'ניקוי היסטוריה',
          onTap: () {
            ref.read(recentSearchesProvider.notifier).state = const [];
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
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(viewMode: v)),
        ),
        _RadioGroupRow<CatalogSort>(
          label: 'מיון ברירת מחדל',
          value: settings.sortDefault,
          options: const [
            (value: CatalogSort.relevance, label: 'רלוונטיות'),
            (value: CatalogSort.priceAsc, label: 'מחיר: זול → יקר'),
            (value: CatalogSort.rating, label: 'דירוג גבוה'),
            (value: CatalogSort.newest, label: 'חדש ביותר'),
          ],
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(sortDefault: v)),
        ),
        _NumberRow(
          label: 'עמודות בתצוגת רשת',
          value: settings.gridColumns,
          min: 1,
          max: 4,
          suffix: '',
          onChanged: (v) => ref
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
          onChanged: (v) => ref
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
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionTile(
      emoji: '💰',
      title: 'מחירים ומטבע',
      children: [
        _SwitchRow(
          label: 'הצג מחירים כולל מע"מ',
          value: settings.showVat,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(showVat: v)),
        ),
        _RadioGroupRow<CatalogCurrency>(
          label: 'מטבע',
          value: settings.currency,
          options: const [
            (value: CatalogCurrency.ils, label: '₪ שקל'),
            (value: CatalogCurrency.usd, label: '\$ דולר'),
            (value: CatalogCurrency.eur, label: '€ יורו'),
          ],
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(currency: v)),
        ),
        _SwitchRow(
          label: 'הצגת מחיר ליחידה',
          value: settings.showUnitPrice,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(showUnitPrice: v)),
        ),
        _SwitchRow(
          label: 'השוואת מחירים בין ספקים',
          value: settings.priceComparison,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(priceComparison: v)),
        ),
      ],
    );
  }
}

// ─── 4. favorites & lists ────────────────────────────────────────────────────

class _FavoritesSection extends ConsumerWidget {
  const _FavoritesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionTile(
      emoji: '❤️',
      title: 'מועדפים ורשימות',
      children: [
        _SwitchRow(
          label: 'סנכרון מועדפים בין מכשירים',
          value: settings.syncFavorites,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(syncFavorites: v)),
        ),
        _SwitchRow(
          label: 'רשימות קנייה לפי פרויקט',
          value: settings.listsPerProject,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(listsPerProject: v)),
        ),
        const _PlaceholderRow(label: 'שיתוף רשימה עם צוות'),
        const _PlaceholderRow(label: 'יבוא / ייצוא רשימה'),
        _SwitchRow(
          label: 'התראה על שינוי מחיר במועדפים',
          value: settings.priceChangeAlert,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(priceChangeAlert: v)),
        ),
      ],
    );
  }
}

// ─── 5. catalog notifications ────────────────────────────────────────────────

class _CatalogNotifSection extends ConsumerWidget {
  const _CatalogNotifSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionTile(
      emoji: '🔔',
      title: 'התראות קטלוג',
      children: [
        _SwitchRow(
          label: 'ירידת מחיר במועדפים',
          value: settings.notifPriceDrop,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(notifPriceDrop: v)),
        ),
        _SwitchRow(
          label: 'חזר למלאי',
          value: settings.notifBackInStock,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(notifBackInStock: v)),
        ),
        _SwitchRow(
          label: 'מלאי נמוך',
          value: settings.notifLowStock,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(notifLowStock: v)),
        ),
        _SwitchRow(
          label: 'מוצרים חדשים בקטגוריה',
          value: settings.notifNewProducts,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(notifNewProducts: v)),
        ),
      ],
    );
  }
}

// ─── 6. units of measure ─────────────────────────────────────────────────────

class _UnitsSection extends ConsumerWidget {
  const _UnitsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionTile(
      emoji: '📏',
      title: 'יחידות מידה',
      children: [
        _RadioGroupRow<CatalogUnit>(
          label: 'מערכת מידה',
          value: settings.unit,
          options: const [
            (value: CatalogUnit.metric, label: 'מטרי (ס"מ / ק"ג)'),
            (value: CatalogUnit.imperial, label: "אימפריאלי (אינץ' / לב')"),
          ],
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(unit: v)),
        ),
        const _PlaceholderRow(label: 'פורמט מידות בכרטיס מוצר'),
        _RadioGroupRow<CatalogDecimalFormat>(
          label: 'פורמט הצגה',
          value: settings.decimalFormat,
          options: const [
            (value: CatalogDecimalFormat.decimal, label: 'עשרוני (1.5)'),
            (value: CatalogDecimalFormat.fraction, label: 'שברי (1½)'),
          ],
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(decimalFormat: v)),
        ),
      ],
    );
  }
}

// ─── 7. preferred suppliers ──────────────────────────────────────────────────

class _SuppliersSection extends ConsumerWidget {
  const _SuppliersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionTile(
      emoji: '🏪',
      title: 'ספקים מועדפים',
      children: [
        const _PlaceholderRow(label: 'ספקים מסומנים כמועדפים'),
        const _PlaceholderRow(label: 'ספקים חסומים'),
        _NumberRow(
          label: 'מרחק מקסימלי',
          value: settings.maxDistance,
          min: 5,
          max: 500,
          suffix: 'ק"מ',
          step: 25,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(maxDistance: v)),
        ),
        _RadioGroupRow<CatalogMinRating>(
          label: 'דירוג מינימלי',
          value: settings.minRating,
          options: const [
            (value: CatalogMinRating.any, label: 'ללא הגבלה'),
            (value: CatalogMinRating.three, label: '3+ כוכבים'),
            (value: CatalogMinRating.four, label: '4+ כוכבים'),
            (value: CatalogMinRating.five, label: '5 כוכבים'),
          ],
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(minRating: v)),
        ),
        _SwitchRow(
          label: 'ספקים מקומיים בלבד',
          value: settings.localSuppliersOnly,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(localSuppliersOnly: v)),
        ),
      ],
    );
  }
}

// ─── 8. AI & recommendations ─────────────────────────────────────────────────

class _AiSection extends ConsumerWidget {
  const _AiSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionTile(
      emoji: '🤖',
      title: 'AI והמלצות',
      children: [
        _SwitchRow(
          label: 'המלצות מבוססות AI',
          value: settings.aiRecommendations,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(aiRecommendations: v)),
        ),
        _SwitchRow(
          label: 'התאמה לפי היסטוריית הזמנות',
          value: settings.historyBased,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(historyBased: v)),
        ),
        _SwitchRow(
          label: 'סינון לפי פרויקט פעיל',
          value: settings.activeProjectFilter,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(activeProjectFilter: v)),
        ),
        _SwitchRow(
          label: 'חלופות זולות אוטומטיות',
          value: settings.cheapAlternatives,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(cheapAlternatives: v)),
        ),
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
          onChanged: (v) => ref
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
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(textSize: v)),
        ),
        _SwitchRow(
          label: 'ניגודיות גבוהה (כל האפליקציה)',
          value: settings.highContrast,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(highContrast: v)),
        ),
        _SwitchRow(
          label: 'הנפשות מופחתות (כל האפליקציה)',
          value: settings.reducedMotion,
          onChanged: (v) => ref
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
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
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              color: Color(0xFF1A1A1A),
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
      title: Text(label, style: const TextStyle(color: Color(0xFF1A1A1A))),
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
            title: Text(o.label,
                style: const TextStyle(color: Color(0xFF1A1A1A))),
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
      title: Text(label, style: const TextStyle(color: Color(0xFF1A1A1A))),
      trailing: const Text(
        'בבנייה',
        style: TextStyle(color: Color(0xFF666666), fontSize: 12),
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
      title: Text(label, style: const TextStyle(color: Color(0xFF1A1A1A))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.black54, size: 20),
            onPressed: value > min
                ? () => onChanged((value - step).clamp(min, max))
                : null,
          ),
          Text(
            suffix.isEmpty ? '$value' : '$value $suffix',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black54, size: 20),
            onPressed: value < max
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
