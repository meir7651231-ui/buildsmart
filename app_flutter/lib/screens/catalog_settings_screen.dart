import 'package:buildsmart/screens/home_content_reorder.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/recent_searches.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen Catalog settings — 9 categories, ~40 leaves.
/// All 23 fields persisted via [catalogSettingsProvider].
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
          _PricesSection(),
          _FavoritesSection(),
          _UnitsSection(),
          _SuppliersSection(),
          _AiSection(),
          _AccessibilitySection(),
          _InfoSection(),
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
    final catalog = ref.watch(catalogSettingsProvider);
    final catalogN = ref.read(catalogSettingsProvider.notifier);
    // #50 — ONE 'תצוגה ומיון' section: theme + home-order (appSettings) folded
    // together with the catalog view/sort/grid/image controls (catalogSettings)
    // from the former separate 'תצוגה ומיון' section.
    return _SectionTile(
      emoji: '📊',
      title: 'תצוגה ומיון',
      children: [
        _RadioGroupRow<BsTheme>(
          label: 'ערכת נושא',
          value: settings.theme,
          options: const [
            _RadioOption(value: BsTheme.light, label: 'בהיר'),
            _RadioOption(value: BsTheme.dark, label: 'כהה'),
          ],
          onChanged:
              (v) => ref
                  .read(appSettingsProvider.notifier)
                  .update((s) => s.copyWith(theme: v)),
        ),
        _RadioGroupRow<CatalogViewMode>(
          label: 'סוג תצוגה',
          value: catalog.viewMode,
          options: const [
            _RadioOption(
              value: CatalogViewMode.grid,
              label: 'רשת (Grid)',
              icon: Icons.grid_view,
            ),
            _RadioOption(
              value: CatalogViewMode.list,
              label: 'רשימה (List)',
              icon: Icons.view_list_rounded,
            ),
          ],
          onChanged: (v) => catalogN.update((s) => s.copyWith(viewMode: v)),
        ),
        // 🟢 WIRED — persisted default catalog ordering (real ProductSort set).
        // Writing it persists the default AND updates the live catalog sort
        // (catalogProductSortProvider) so the change is visible immediately.
        _RadioGroupRow<ProductSort>(
          label: 'מיון ברירת מחדל',
          value: catalog.productSortDefault,
          options: const [
            _RadioOption(value: ProductSort.byOrder, label: 'ברירת מחדל'),
            _RadioOption(value: ProductSort.nameAZ, label: 'שם א-ת'),
            _RadioOption(value: ProductSort.nameZA, label: 'שם ת-א'),
            _RadioOption(value: ProductSort.sku, label: 'מק"ט'),
          ],
          onChanged: (v) {
            catalogN.update((s) => s.copyWith(productSortDefault: v));
            ref.read(catalogProductSortProvider.notifier).state = v;
          },
        ),
        _NumberRow(
          label: 'עמודות בתצוגת רשת',
          value: catalog.gridColumns,
          min: 1,
          max: 4,
          suffix: '',
          onChanged: (v) =>
              catalogN.update((s) => s.copyWith(gridColumns: v)),
        ),
        _RadioGroupRow<CatalogImageSize>(
          label: 'גודל תמונות',
          value: catalog.imageSize,
          // Each label renders at its own size so the difference is visible.
          options: const [
            _RadioOption(
              value: CatalogImageSize.small,
              label: 'קטן',
              labelFontSize: 13,
            ),
            _RadioOption(
              value: CatalogImageSize.medium,
              label: 'בינוני',
              labelFontSize: 15,
            ),
            _RadioOption(
              value: CatalogImageSize.large,
              label: 'גדול',
              labelFontSize: 18,
            ),
          ],
          onChanged: (v) =>
              catalogN.update((s) => s.copyWith(imageSize: v)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.swap_vert, color: BsTokens.brandDark),
          title: const Text('סידור מסך הבית'),
          subtitle: const Text('גרור לשנות את סדר המקטעים בבית'),
          trailing: const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
          onTap: () =>
              Navigator.of(context).push(HomeContentReorder.route()),
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
    final catalog = ref.watch(catalogSettingsProvider);
    final catalogN = ref.read(catalogSettingsProvider.notifier);
    // #50 — ONE 'התראות' section. The catalog-alert family folded in from the
    // former separate 'התראות קטלוג'; the duplicate price-drop collapsed to the
    // single canonical catalogSettings.notifPriceDrop ('ירידת מחיר במועדפים'),
    // so the old typePriceDrops 'התראות תקציב' toggle is gone. Order/shipment
    // updates moved to the orders world (#52) and are not shown here.
    return _SectionTile(
      emoji: '🔔',
      title: 'התראות',
      children: [
        _SwitchRow(
          label: 'מבצעים והטבות',
          value: notif.typeDeals,
          onChanged:
              (v) => ref
                  .read(notifSettingsProvider.notifier)
                  .update((s) => s.copyWith(typeDeals: v)),
        ),
        _SwitchRow(
          label: 'ירידת מחיר במועדפים',
          value: catalog.notifPriceDrop,
          onChanged: (v) =>
              catalogN.update((s) => s.copyWith(notifPriceDrop: v)),
        ),
        _SwitchRow(
          label: 'חזר למלאי',
          value: catalog.notifBackInStock,
          onChanged: (v) =>
              catalogN.update((s) => s.copyWith(notifBackInStock: v)),
        ),
        _SwitchRow(
          label: 'מלאי נמוך',
          value: catalog.notifLowStock,
          onChanged: (v) =>
              catalogN.update((s) => s.copyWith(notifLowStock: v)),
        ),
        _SwitchRow(
          label: 'מוצרים חדשים בקטגוריה',
          value: catalog.notifNewProducts,
          onChanged: (v) =>
              catalogN.update((s) => s.copyWith(notifNewProducts: v)),
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
          // Only Hebrew is actually implemented (no real l10n yet); Arabic +
          // English stay non-selectable and carry a "בקרוב" badge so the
          // picker never fakes a language switch.
          value: settings.lang,
          options: const [
            _RadioOption(value: BsLang.he, label: 'עברית'),
            _RadioOption(value: BsLang.ar, label: 'العربية', enabled: false),
            _RadioOption(value: BsLang.en, label: 'English', enabled: false),
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
        // 🔑 deferred — products carry no geo/location data and there is no
        // device-location source wired, so a search radius would filter nothing.
        // (searchRadius is persisted in CatalogSettings but kept unbound until a
        // location source + per-product geo exist.)
        const _PlaceholderRow(label: 'רדיוס חיפוש'),
        _ActionRow(
          label: 'ניקוי היסטוריה',
          onTap: () async {
            final ok = await confirmDestructive(
              context,
              title: 'ניקוי היסטוריית חיפוש?',
              message: 'היסטוריית החיפושים תימחק לצמיתות.',
              confirmLabel: 'נקה',
            );
            if (!ok || !context.mounted) return;
            ref.read(recentSearchesProvider.notifier).clear();
            showToast(context, 'ההיסטוריה נוקתה');
          },
        ),
      ],
    );
  }
}

// ─── 2. display & sort ───────────────────────────────────────────────────────

// (Former _DisplaySection merged into _ThemeSection · 'תצוגה ומיון' — #50.)

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
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(showVat: v)),
        ),
        _RadioGroupRow<CatalogCurrency>(
          label: 'מטבע',
          value: settings.currency,
          options: const [
            _RadioOption(value: CatalogCurrency.ils, label: '₪ שקל'),
            _RadioOption(value: CatalogCurrency.usd, label: r'$ דולר'),
            _RadioOption(value: CatalogCurrency.eur, label: '€ אירו'),
          ],
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(currency: v)),
        ),
        _SwitchRow(
          label: 'הצגת מחיר ליחידה',
          value: settings.showUnitPrice,
          onChanged:
              (v) => ref
                  .read(catalogSettingsProvider.notifier)
                  .update((s) => s.copyWith(showUnitPrice: v)),
        ),
        // השוואת מחירים בין ספקים — needs live per-supplier price feeds
        // (external service). Persisted via priceComparison but kept honest
        // until the feed exists, so it stays a placeholder for now.
        const _PlaceholderRow(label: 'השוואת מחירים בין ספקים'),
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
        // 🔑 cross-device sync needs a backend/account sync service — no local
        // effect possible, kept honest as a placeholder.
        const _PlaceholderRow(label: 'סנכרון מועדפים בין מכשירים'),
        // 🔑 per-project shopping lists need project-list infra not present in
        // the catalog layer.
        const _PlaceholderRow(label: 'רשימות קנייה לפי פרויקט'),
        // 🔑 sharing a list needs a team/backend channel.
        const _PlaceholderRow(label: 'שיתוף רשימה עם צוות'),
        // 🔑 import/export needs file-I/O plumbing — out of this batch's scope.
        const _PlaceholderRow(label: 'יבוא / ייצוא רשימה'),
        // 🟢 WIRED — persisted user preference. The toggle remembers state;
        // DELIVERY of the alert is gated on the notification system (not yet
        // pushing), so this stores intent only.
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

// ─── 6. units of measure ─────────────────────────────────────────────────────

class _UnitsSection extends ConsumerWidget {
  const _UnitsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    final notifier = ref.read(catalogSettingsProvider.notifier);
    return _SectionTile(
      emoji: '📏',
      title: 'יחידות מידה',
      children: [
        _RadioGroupRow<CatalogUnit>(
          label: 'מערכת מידה',
          value: settings.unit,
          options: const [
            _RadioOption(value: CatalogUnit.metric, label: 'מטרי (מ"מ / ס"מ)'),
            _RadioOption(value: CatalogUnit.imperial, label: 'אימפריאלי (אינץ\')'),
          ],
          onChanged: (v) => notifier.update((s) => s.copyWith(unit: v)),
        ),
        // Both rows control the SAME persisted dimension format
        // ([decimalFormat]): "פורמט מידות בכרטיס מוצר" is the on-card view of it
        // and "פורמט הצגה" the general display format. They share one source of
        // truth so they can never drift, and both genuinely re-render the card.
        _RadioGroupRow<CatalogDecimalFormat>(
          label: 'פורמט מידות בכרטיס מוצר',
          value: settings.decimalFormat,
          options: const [
            _RadioOption(value: CatalogDecimalFormat.decimal, label: 'עשרוני (1.5)'),
            _RadioOption(value: CatalogDecimalFormat.fraction, label: 'שבר (1½)'),
          ],
          onChanged: (v) => notifier.update((s) => s.copyWith(decimalFormat: v)),
        ),
        _RadioGroupRow<CatalogDecimalFormat>(
          label: 'פורמט הצגה',
          value: settings.decimalFormat,
          options: const [
            _RadioOption(value: CatalogDecimalFormat.decimal, label: 'עשרוני (1.5)'),
            _RadioOption(value: CatalogDecimalFormat.fraction, label: 'שבר (1½)'),
          ],
          onChanged: (v) => notifier.update((s) => s.copyWith(decimalFormat: v)),
        ),
      ],
    );
  }
}

// ─── 7. preferred suppliers ──────────────────────────────────────────────────

class _SuppliersSection extends StatelessWidget {
  const _SuppliersSection();

  // 🔑 ALL deferred — honestly. The catalog product model
  // (LipskeyCatalogProduct) carries NO supplier identity, rating, distance or
  // "local" flag, and the live ספקים list (SuppliersScreen) is a single brand
  // tile with no rating/distance data. So none of these can filter anything
  // in-app — every row would be a no-op. Persisting a number that filters
  // nothing would be faking the feature, so they stay placeholders until a
  // supplier↔product link (or a supplier feed) exists.
  //   • ספקים מסומנים כמועדפים / ספקים חסומים — no per-supplier product
  //     attribution to mark or filter against.
  //   • מרחק מקסימלי / דירוג מינימלי / ספקים מקומיים בלבד — backing fields
  //     (maxDistance/minRating/localSuppliersOnly) exist in CatalogSettings but
  //     have no supplier data on products to filter, so they are intentionally
  //     left unbound here.
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
            _RadioOption(value: CatalogTextSize.small, label: 'קטן'),
            _RadioOption(value: CatalogTextSize.medium, label: 'בינוני'),
            _RadioOption(value: CatalogTextSize.large, label: 'גדול'),
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

// ─── 10. info & legal (הגדרות › מידע — task #26) ─────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    return _SectionTile(
      emoji: 'ℹ️',
      title: 'מידע',
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text(
            'תנאי שימוש',
            style: TextStyle(color: BsTokens.inkLight),
          ),
          trailing: const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
          onTap: () => Navigator.of(context)
              .push(LegalScreen.route(initialTab: LegalTab.terms)),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text(
            'מדיניות פרטיות',
            style: TextStyle(color: BsTokens.inkLight),
          ),
          trailing: const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
          onTap: () => Navigator.of(context)
              .push(LegalScreen.route(initialTab: LegalTab.privacy)),
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

  // For Apple review (kHideUnderConstruction) we render only the functional
  // rows; the _PlaceholderRow tiles stay defined in code (reversible) but are
  // hidden from the visible list.
  List<Widget> get _visibleChildren => kHideUnderConstruction
      ? children.where((w) => w is! _PlaceholderRow).toList()
      : children;

  @override
  Widget build(BuildContext context) {
    // A section whose every row is a hidden placeholder disappears entirely.
    if (kHideUnderConstruction && _visibleChildren.isEmpty) {
      return const SizedBox.shrink();
    }
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
          children: _visibleChildren,
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
  final List<_RadioOption<T>> options;
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
        ...options.map((o) {
          final enabled = o.enabled;
          // Disabled options stay un-selectable and carry a "בקרוב" badge so
          // the picker is honest about what is actually implemented.
          return RadioListTile<T>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            // Optional leading icon (e.g. grid/list view glyph) — null = no icon.
            secondary: o.icon == null
                ? null
                : Icon(
                    o.icon,
                    color: enabled ? BsTokens.inkLight : BsTokens.mutedLight,
                  ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    o.label,
                    // Per-option font size lets size pickers render their own
                    // label at its own scale; defaults to the inherited size.
                    style: TextStyle(
                      color: enabled ? BsTokens.inkLight : BsTokens.mutedLight,
                      fontSize: o.labelFontSize,
                    ),
                  ),
                ),
                if (!enabled) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'בקרוב',
                    style: TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            value: o.value,
            groupValue: value,
            activeColor: BsTokens.brand,
            onChanged: enabled
                ? (v) {
                    if (v != null) onChanged(v);
                  }
                : null,
          );
        }),
      ],
    );
  }
}

/// One option in a [_RadioGroupRow]. [enabled] gates selection (a disabled
/// option shows a "בקרוב" badge); [icon] adds a leading glyph; [labelFontSize]
/// renders the label at its own scale.
class _RadioOption<T> {
  const _RadioOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.icon,
    this.labelFontSize,
  });

  final T value;
  final String label;
  final bool enabled;
  final IconData? icon;
  final double? labelFontSize;
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
