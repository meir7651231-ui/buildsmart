import 'package:buildsmart/state/store_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen Store settings — 9 categories, ~40 leaves.
/// 8 active leaves are persisted via [storeSettingsProvider];
/// the rest show a "בבנייה" toast on tap.
class StoreSettingsScreen extends ConsumerWidget {
  const StoreSettingsScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const StoreSettingsScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'הגדרות חנות',
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
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'איפוס הגדרות?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'כל הגדרות החנות יוחזרו לברירת המחדל.',
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
        const _PlaceholderRow(label: 'חלון זמן מועדף'),
        const _PlaceholderRow(label: 'אזורי משלוח'),
        const _PlaceholderRow(label: 'הוראות לשליח'),
        const _PlaceholderRow(label: 'איסוף עצמי כברירת מחדל'),
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
        const _PlaceholderRow(label: 'תשלומים (1/3/6/12)'),
        const _PlaceholderRow(label: 'הסדר אשראי ספק'),
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
        const _PlaceholderRow(label: 'פרטי עוסק/חברה'),
        const _PlaceholderRow(label: 'ח.פ. / ע.מ.'),
        const _PlaceholderRow(label: 'ייצוא לרו"ח'),
        const _PlaceholderRow(label: 'קבלות אוטומטיות'),
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
        const _PlaceholderRow(label: 'ירידת מחיר במועדפים'),
        const _PlaceholderRow(label: 'סטטוס הזמנה'),
        const _PlaceholderRow(label: 'משלוח בדרך'),
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
        const _PlaceholderRow(label: 'הזמנות חוזרות'),
        const _PlaceholderRow(label: 'שיתוף סל עם צוות'),
        const _PlaceholderRow(label: 'שמירת סל לפרויקט'),
      ],
    );
  }
}

// ─── 6. suppliers ────────────────────────────────────────────────────────────

class _SuppliersSection extends StatelessWidget {
  const _SuppliersSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '🏪',
      title: 'ספקים מועדפים',
      children: [
        _PlaceholderRow(label: 'חנויות מסומנות'),
        _PlaceholderRow(label: 'ספקים חסומים'),
        _PlaceholderRow(label: 'מרחק מקסימלי'),
        _PlaceholderRow(label: 'דירוג מינימלי'),
        _PlaceholderRow(label: 'ספקים מקומיים בלבד'),
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
        const _PlaceholderRow(label: 'תצוגה (רשת / רשימה)'),
        const _PlaceholderRow(label: "יחידות (מטר / אינץ')"),
        const _PlaceholderRow(label: 'הצגת מלאי'),
      ],
    );
  }
}

// ─── 8. logistics ────────────────────────────────────────────────────────────

class _LogisticsSection extends StatelessWidget {
  const _LogisticsSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '⚡',
      title: 'שירות ולוגיסטיקה',
      children: [
        _PlaceholderRow(label: 'משלוח מהיר (תוך 4 שעות)'),
        _PlaceholderRow(label: 'משלוח רגיל (יום-יומיים)'),
        _PlaceholderRow(label: 'ייעוץ טכני'),
        _PlaceholderRow(label: 'מדיניות החזרות'),
        _PlaceholderRow(label: 'אחריות מורחבת'),
      ],
    );
  }
}

// ─── 9. privacy & purchases ──────────────────────────────────────────────────

class _PrivacySection extends StatelessWidget {
  const _PrivacySection();

  @override
  Widget build(BuildContext context) {
    return const _SectionTile(
      emoji: '🔐',
      title: 'פרטיות ורכישות',
      children: [
        _PlaceholderRow(label: 'היסטוריית רכישות'),
        _PlaceholderRow(label: 'מחיקת חיפושים'),
        _PlaceholderRow(label: 'אישור ביומטרי לרכישה'),
        _PlaceholderRow(label: 'מגבלת אשראי יומית'),
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
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctrl,
            style: const TextStyle(color: Colors.white),
            cursorColor: BsTokens.brand,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Color(0xFF666666)),
              filled: true,
              fillColor: const Color(0xFF222222),
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
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white),
              cursorColor: BsTokens.brand,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF222222),
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
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Text(
        'בבנייה',
        style: TextStyle(color: Color(0xFF666666), fontSize: 12),
      ),
      onTap: () => showToast(context, '$label — בבנייה'),
    );
  }
}
