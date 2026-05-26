import 'package:buildsmart/state/store_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen Store settings — 9 categories, ~40 leaves.
/// All leaves are persisted via [storeSettingsProvider].
class StoreSettingsScreen extends ConsumerWidget {
  const StoreSettingsScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const StoreSettingsScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text(
          'הגדרות חנות',
          style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700),
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
          _ShippingSection(),
          _PaymentSection(),
          _InvoicesSection(),
          _NotificationsSection(),
          _CartSection(),
          _SuppliersSection(),
          _DisplaySection(),
          _LogisticsSection(),
          _PrivacySection(),
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
          'כל הגדרות החנות יוחזרו לברירת המחדל.',
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
      await ref.read(storeSettingsProvider.notifier).reset();
      if (context.mounted) showToast(context, 'הגדרות אופסו');
    }
  }
}

// ─── 1. shipping & addresses ─────────────────────────────────────────────────

class _ShippingSection extends ConsumerWidget {
  const _ShippingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    return _SectionTile(
      emoji: '📍',
      title: 'משלוחים וכתובות',
      children: [
        _InlineTextRow(
          label: 'כתובת ברירת מחדל',
          hint: 'רחוב, מספר, עיר',
          value: settings.defaultAddress,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(defaultAddress: v)),
        ),
        _RadioGroupRow<StoreDeliveryWindow>(
          label: 'חלון זמן מועדף',
          value: settings.preferredDeliveryWindow,
          options: const [
            (value: StoreDeliveryWindow.morning, label: 'בוקר'),
            (value: StoreDeliveryWindow.noon, label: 'צהריים'),
            (value: StoreDeliveryWindow.evening, label: 'ערב'),
            (value: StoreDeliveryWindow.flexible, label: 'גמיש'),
          ],
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(preferredDeliveryWindow: v)),
        ),
        _InlineTextRow(
          label: 'אזורי משלוח',
          hint: 'ת"א, רמת גן, הרצליה...',
          value: settings.deliveryAreas,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(deliveryAreas: v)),
        ),
        _InlineTextRow(
          label: 'הוראות לשליח',
          hint: 'הערות למשלוח...',
          value: settings.courierInstructions,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(courierInstructions: v)),
        ),
        _SwitchRow(
          label: 'איסוף עצמי כברירת מחדל',
          value: settings.selfPickupDefault,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(selfPickupDefault: v)),
        ),
      ],
    );
  }
}

// ─── 2. payment ──────────────────────────────────────────────────────────────

class _PaymentSection extends ConsumerWidget {
  const _PaymentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    return _SectionTile(
      emoji: '💳',
      title: 'אמצעי תשלום',
      children: [
        _RadioGroupRow<StorePayment>(
          label: 'ברירת מחדל',
          value: settings.defaultPayment,
          options: const [
            (value: StorePayment.card, label: 'כרטיס אשראי'),
            (value: StorePayment.bit, label: 'ביט'),
            (value: StorePayment.applePay, label: 'Apple/Google Pay'),
            (value: StorePayment.supplierCredit, label: 'אשראי ספק'),
          ],
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(defaultPayment: v)),
        ),
        const _PlaceholderRow(label: 'כרטיסים שמורים'),
        _RadioGroupRow<StoreInstallments>(
          label: 'תשלומים (1/3/6/12)',
          value: settings.defaultInstallments,
          options: const [
            (value: StoreInstallments.one, label: 'תשלום אחד'),
            (value: StoreInstallments.three, label: '3 תשלומים'),
            (value: StoreInstallments.six, label: '6 תשלומים'),
            (value: StoreInstallments.twelve, label: '12 תשלומים'),
          ],
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(defaultInstallments: v)),
        ),
        _SwitchRow(
          label: 'הסדר אשראי ספק',
          value: settings.supplierCreditEnabled,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(supplierCreditEnabled: v)),
        ),
      ],
    );
  }
}

// ─── 3. invoices & tax ───────────────────────────────────────────────────────

class _InvoicesSection extends ConsumerWidget {
  const _InvoicesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    return _SectionTile(
      emoji: '🧾',
      title: 'חשבוניות ומס',
      children: [
        _SwitchRow(
          label: 'הצג מחירים כולל מע"מ',
          value: settings.vatInclusive,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(vatInclusive: v)),
        ),
        _InlineTextRow(
          label: 'פרטי עוסק/חברה',
          hint: 'שם עסק...',
          value: settings.businessName,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(businessName: v)),
        ),
        _InlineTextRow(
          label: 'ח.פ. / ע.מ.',
          hint: 'מספר...',
          value: settings.businessId,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(businessId: v)),
        ),
        _SwitchRow(
          label: 'ייצוא לרו"ח',
          value: settings.exportToAccountant,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(exportToAccountant: v)),
        ),
        _SwitchRow(
          label: 'קבלות אוטומטיות',
          value: settings.autoReceipts,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(autoReceipts: v)),
        ),
      ],
    );
  }
}

// ─── 4. notifications ────────────────────────────────────────────────────────

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    return _SectionTile(
      emoji: '🔔',
      title: 'התראות חנות',
      children: [
        _SwitchRow(
          label: 'התראות מבצעים',
          value: settings.notifDeals,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(notifDeals: v)),
        ),
        _SwitchRow(
          label: 'חזר למלאי במועדפים',
          value: settings.notifBackInStock,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(notifBackInStock: v)),
        ),
        _SwitchRow(
          label: 'ירידת מחיר במועדפים',
          value: settings.notifPriceDrop,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(notifPriceDrop: v)),
        ),
        _SwitchRow(
          label: 'סטטוס הזמנה',
          value: settings.notifOrderStatus,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(notifOrderStatus: v)),
        ),
        _SwitchRow(
          label: 'משלוח בדרך',
          value: settings.notifShipmentEnRoute,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(notifShipmentEnRoute: v)),
        ),
      ],
    );
  }
}

// ─── 5. cart & orders ────────────────────────────────────────────────────────

class _CartSection extends ConsumerWidget {
  const _CartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    return _SectionTile(
      emoji: '🛒',
      title: 'סל והזמנות',
      children: [
        _NumberRow(
          label: 'מינימום הזמנה (₪)',
          value: settings.minOrderAmount,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(minOrderAmount: v)),
        ),
        _SwitchRow(
          label: 'אישור כפול לרכישה גדולה',
          value: settings.confirmLargeOrder,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(confirmLargeOrder: v)),
        ),
        if (settings.confirmLargeOrder)
          _NumberRow(
            label: 'סף לאישור כפול (₪)',
            value: settings.largeOrderThreshold,
            onChanged: (v) => ref
                .read(storeSettingsProvider.notifier)
                .update((s) => s.copyWith(largeOrderThreshold: v)),
          ),
        _SwitchRow(
          label: 'הזמנות חוזרות',
          value: settings.repeatOrders,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(repeatOrders: v)),
        ),
        _SwitchRow(
          label: 'שיתוף סל עם צוות',
          value: settings.shareCartWithTeam,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(shareCartWithTeam: v)),
        ),
        _SwitchRow(
          label: 'שמירת סל לפרויקט',
          value: settings.saveCartToProject,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(saveCartToProject: v)),
        ),
      ],
    );
  }
}

// ─── 6. suppliers ────────────────────────────────────────────────────────────

class _SuppliersSection extends ConsumerWidget {
  const _SuppliersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    return _SectionTile(
      emoji: '🏪',
      title: 'ספקים מועדפים',
      children: [
        const _PlaceholderRow(label: 'חנויות מסומנות'),
        const _PlaceholderRow(label: 'ספקים חסומים'),
        _NumberRow(
          label: 'מרחק מקסימלי (ק"מ, 0=ללא)',
          value: settings.maxSupplierDistance,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(maxSupplierDistance: v)),
        ),
        _RadioGroupRow<StoreMinRating>(
          label: 'דירוג מינימלי',
          value: settings.minSupplierRating,
          options: const [
            (value: StoreMinRating.any, label: 'ללא סינון'),
            (value: StoreMinRating.two, label: '★★+'),
            (value: StoreMinRating.three, label: '★★★+'),
            (value: StoreMinRating.four, label: '★★★★+'),
            (value: StoreMinRating.five, label: '★★★★★'),
          ],
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(minSupplierRating: v)),
        ),
        _SwitchRow(
          label: 'ספקים מקומיים בלבד',
          value: settings.localSuppliersOnly,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(localSuppliersOnly: v)),
        ),
      ],
    );
  }
}

// ─── 7. display & sort ───────────────────────────────────────────────────────

class _DisplaySection extends ConsumerWidget {
  const _DisplaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    return _SectionTile(
      emoji: '📊',
      title: 'תצוגה ומיון',
      children: [
        _RadioGroupRow<StoreSortDefault>(
          label: 'מיון ברירת מחדל',
          value: settings.sortDefault,
          options: const [
            (value: StoreSortDefault.priceAsc, label: 'מחיר: זול → יקר'),
            (value: StoreSortDefault.rating, label: 'דירוג גבוה'),
            (value: StoreSortDefault.distance, label: 'מרחק קרוב'),
          ],
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(sortDefault: v)),
        ),
        _RadioGroupRow<StoreDisplayMode>(
          label: 'תצוגה (רשת / רשימה)',
          value: settings.displayMode,
          options: const [
            (value: StoreDisplayMode.list, label: 'רשימה'),
            (value: StoreDisplayMode.grid, label: 'רשת'),
          ],
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(displayMode: v)),
        ),
        _RadioGroupRow<StoreUnitSystem>(
          label: "יחידות (מטר / אינץ')",
          value: settings.unitSystem,
          options: const [
            (value: StoreUnitSystem.metric, label: 'מטרי'),
            (value: StoreUnitSystem.imperial, label: 'אינגלי'),
          ],
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(unitSystem: v)),
        ),
        _SwitchRow(
          label: 'הצגת מלאי',
          value: settings.showStock,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(showStock: v)),
        ),
      ],
    );
  }
}

// ─── 8. logistics ────────────────────────────────────────────────────────────

class _LogisticsSection extends ConsumerWidget {
  const _LogisticsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    return _SectionTile(
      emoji: '⚡',
      title: 'שירות ולוגיסטיקה',
      children: [
        _SwitchRow(
          label: 'משלוח מהיר (תוך 4 שעות)',
          value: settings.fastDelivery,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(fastDelivery: v)),
        ),
        _SwitchRow(
          label: 'משלוח רגיל (יום-יומיים)',
          value: settings.regularDelivery,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(regularDelivery: v)),
        ),
        const _PlaceholderRow(label: 'ייעוץ טכני'),
        _RadioGroupRow<StoreReturnPolicy>(
          label: 'מדיניות החזרות',
          value: settings.returnPolicy,
          options: const [
            (value: StoreReturnPolicy.days7, label: '7 ימים'),
            (value: StoreReturnPolicy.days14, label: '14 יום'),
            (value: StoreReturnPolicy.days30, label: '30 יום'),
          ],
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(returnPolicy: v)),
        ),
        _SwitchRow(
          label: 'אחריות מורחבת',
          value: settings.extendedWarranty,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(extendedWarranty: v)),
        ),
      ],
    );
  }
}

// ─── 9. privacy & purchases ──────────────────────────────────────────────────

class _PrivacySection extends ConsumerWidget {
  const _PrivacySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    return _SectionTile(
      emoji: '🔐',
      title: 'פרטיות ורכישות',
      children: [
        _SwitchRow(
          label: 'היסטוריית רכישות',
          value: settings.purchaseHistory,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(purchaseHistory: v)),
        ),
        _ActionRow(
          label: 'מחיקת חיפושים',
          buttonLabel: 'מחק',
          onTap: () => showToast(context, 'החיפושים נמחקו'),
        ),
        _SwitchRow(
          label: 'אישור ביומטרי לרכישה',
          value: settings.biometricConfirm,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(biometricConfirm: v)),
        ),
        _NumberRow(
          label: 'מגבלת אשראי יומית (₪, 0=ללא)',
          value: settings.dailyCreditLimit,
          onChanged: (v) => ref
              .read(storeSettingsProvider.notifier)
              .update((s) => s.copyWith(dailyCreditLimit: v)),
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
            title: Text(o.label, style: const TextStyle(color: Color(0xFF1A1A1A))),
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

class _InlineTextRow extends StatefulWidget {
  const _InlineTextRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_InlineTextRow> createState() => _InlineTextRowState();
}

class _InlineTextRowState extends State<_InlineTextRow> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant _InlineTextRow old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctrl,
            style: const TextStyle(color: Color(0xFF1A1A1A)),
            cursorColor: BsTokens.brand,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Color(0xFF666666)),
              filled: true,
              fillColor: const Color(0xFFF2F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}

class _NumberRow extends StatefulWidget {
  const _NumberRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_NumberRow> createState() => _NumberRowState();
}

class _NumberRowState extends State<_NumberRow> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.value.toString());

  @override
  void didUpdateWidget(covariant _NumberRow old) {
    super.didUpdateWidget(old);
    final current = int.tryParse(_ctrl.text) ?? 0;
    if (widget.value != current) {
      _ctrl.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Color(0xFF1A1A1A)),
              cursorColor: BsTokens.brand,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF2F3F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
              onChanged: (v) => widget.onChanged(int.tryParse(v) ?? 0),
            ),
          ),
        ],
      ),
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.buttonLabel,
    required this.onTap,
  });

  final String label;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: Color(0xFF1A1A1A))),
      trailing: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
        child: Text(buttonLabel),
      ),
    );
  }
}
