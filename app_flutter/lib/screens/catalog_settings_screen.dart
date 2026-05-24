import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen Catalog settings — 9 categories, ~40 leaves.
/// 9 active leaves persisted via [catalogSettingsProvider];
/// the rest show "בבנייה" toast on tap.
class CatalogSettingsScreen extends ConsumerWidget {
  const CatalogSettingsScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const CatalogSettingsScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'הגדרות קטלוג',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
        actions: [
          IconButton(
            tooltip: 'איפוס לברירת מחדל',
            icon: const Icon(Icons.restart_alt, color: Colors.white70),
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
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'איפוס הגדרות?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'כל הגדרות הקטלוג יוחזרו לברירת המחדל.',
          style: TextStyle(color: Colors.white70),
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
        const _PlaceholderRow(label: 'סינון מהיר בשורת חיפוש'),
        const _PlaceholderRow(label: 'רדיוס חיפוש גיאוגרפי'),
        const _PlaceholderRow(label: 'ניקוי היסטוריה'),
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
        const _PlaceholderRow(label: 'מספר עמודות בתצוגת רשת'),
        const _PlaceholderRow(label: 'גודל תמונות'),
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
        const _PlaceholderRow(label: 'הצגת מחיר ליחידה'),
        const _PlaceholderRow(label: 'השוואת מחירים בין ספקים'),
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
        const _PlaceholderRow(label: 'מלאי נמוך'),
        const _PlaceholderRow(label: 'מוצרים חדשים בקטגוריה'),
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
        const _PlaceholderRow(label: 'הצגה עשרונית / שברי'),
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
        _PlaceholderRow(label: 'מרחק מקסימלי מהאתר'),
        _PlaceholderRow(label: 'דירוג מינימלי לתצוגה'),
        _PlaceholderRow(label: 'ספקים מקומיים בלבד'),
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
        const _PlaceholderRow(label: 'התאמה לפי היסטוריית הזמנות'),
        const _PlaceholderRow(label: 'סינון לפי פרויקט פעיל'),
        const _PlaceholderRow(label: 'חלופות זולות אוטומטיות'),
      ],
    );
  }
}

// ─── 9. interface & accessibility ────────────────────────────────────────────

class _AccessibilitySection extends StatelessWidget {
  const _AccessibilitySection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '📱',
      title: 'ממשק ונגישות',
      children: [
        _PlaceholderRow(label: 'מצב קומפקטי (כרטיסים קטנים)'),
        _PlaceholderRow(label: 'גודל טקסט'),
        _PlaceholderRow(label: 'ניגודיות גבוהה'),
        _PlaceholderRow(label: 'הנפשות מופחתות'),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white70,
          leading: Text(emoji, style: const TextStyle(fontSize: 22)),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
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
      title: Text(label, style: const TextStyle(color: Colors.white)),
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
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        ...options.map(
          (o) => RadioListTile<T>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(o.label, style: const TextStyle(color: Colors.white)),
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
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Text(
        'בבנייה',
        style: TextStyle(color: Color(0xFF666666), fontSize: 12),
      ),
      onTap: () => showToast(context, '$label — בבנייה'),
    );
  }
}
