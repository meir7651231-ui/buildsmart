import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/screens/regression_panel_screen.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/dial.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// BS dial — port of app/src/components/bs/bs-dial.tsx.
/// L1 = 5 personas. L2+ = walk active persona's section tree along
/// the drill path. Tapping a leaf with no children → toast, EXCEPT the
/// manager 📊 dashboard `md-*` leaves, which open a real metric panel inline
/// (R2 — dial-drill, no new screen; numbers derived in manager_dashboard.dart).
class BsDialWidget extends ConsumerWidget {
  const BsDialWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaId = ref.watch(activePersonaProvider);

    // L1 — 5 personas.
    if (personaId == null) {
      return DialColumn(
        children: [
          for (final p in kPersonas)
            DialRow(
              label: p.title,
              emoji: p.emoji,
              icon: Icons.circle,
              onTap: () =>
                  ref.read(activePersonaProvider.notifier).state = p.id,
            ),
        ],
      );
    }

    final persona = kPersonas.firstWhere((p) => p.id == personaId);
    final path = ref.watch(bsDrillPathProvider);
    final walked = walkBsDrill(personaId, path);
    final openMetric = ref.watch(bsMetricLeafProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inline metric panel for the open `md-*` leaf — rises above the dial,
        // stays within the dial overlay (no navigation).
        if (openMetric != null) ...[
          _ManagerMetricPanel(
            leafId: openMetric,
            onClose: () =>
                ref.read(bsMetricLeafProvider.notifier).state = null,
          ),
          const SizedBox(height: BsTokens.space3),
        ],
        DialColumn(
          children: [
            // Persona anchor — tap to pop back to L1.
            DialRow(
              label: persona.title,
              emoji: persona.emoji,
              icon: Icons.circle,
              active: true,
              onTap: () {
                ref.read(activePersonaProvider.notifier).state = null;
                ref.read(bsDrillPathProvider.notifier).state = const [];
                ref.read(bsMetricLeafProvider.notifier).state = null;
              },
            ),
            // One anchor per drill step — tap pops to that depth.
            for (var i = 0; i < walked.anchors.length; i++)
              DialRow(
                label: walked.anchors[i].title,
                emoji: walked.anchors[i].emoji,
                icon: Icons.circle,
                active: true,
                onTap: () {
                  ref.read(bsDrillPathProvider.notifier).state =
                      path.sublist(0, i);
                  ref.read(bsMetricLeafProvider.notifier).state = null;
                },
              ),
            // Current items at this depth.
            for (final s in walked.current)
              DialRow(
                label: s.title,
                emoji: s.emoji,
                icon: Icons.circle,
                // Highlight the leaf whose metric panel is currently open.
                active: s.id == openMetric,
                onTap: () => _onLeafTap(context, ref, s, path),
              ),
          ],
        ),
      ],
    );
  }

  void _onLeafTap(
    BuildContext context,
    WidgetRef ref,
    Section s,
    List<String> path,
  ) {
    if (s.hasChildren) {
      ref.read(bsMetricLeafProvider.notifier).state = null;
      ref.read(bsDrillPathProvider.notifier).state = [...path, s.title];
    } else if (kManagerMetricLeafIds.contains(s.id)) {
      // M1 — toggle the inline metric panel for this dashboard leaf.
      final cur = ref.read(bsMetricLeafProvider);
      ref.read(bsMetricLeafProvider.notifier).state = cur == s.id ? null : s.id;
    } else if (s.id == 'mm-regression') {
      ref.read(openDialProvider.notifier).state = OpenDial.none;
      Navigator.of(context).push(RegressionPanelScreen.route());
    } else {
      showToast(context, '${s.title} — בבנייה');
    }
  }
}

/// The five 📊 dashboard leaves wired to real derived numbers (M1).
const Set<String> kManagerMetricLeafIds = {
  'md-open-orders',
  'md-catalog',
  'md-accessories',
  'md-available',
  'md-stores',
};

/// Inline panel that shows a manager dashboard leaf's REAL derived number plus
/// a one-line note of what it counts. Pure presentation over [managerAnalytics]
/// (manager_dashboard.dart) — every figure is verbatim-derived from index.html.
class _ManagerMetricPanel extends StatelessWidget {
  const _ManagerMetricPanel({required this.leafId, required this.onClose});

  final String leafId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final m = _metricFor(leafId);
    final theme = Theme.of(context);

    return Semantics(
      label: '${m.emoji} ${m.title}: ${m.value}',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space4,
          vertical: BsTokens.space3,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: BsTokens.circleShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(m.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Text(
                    m.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(BsTokens.radiusCircle),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.close, size: 18, color: BsTokens.mutedLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space2),
            Text(
              m.value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: BsTokens.brand,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              m.note,
              style: theme.textTheme.bodySmall?.copyWith(
                color: BsTokens.mutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _Metric _metricFor(String id) {
    const a = managerAnalytics;
    switch (id) {
      case 'md-open-orders':
        return _Metric(
          emoji: '🚚',
          title: 'הזמנות פתוחות',
          value: '${a.openOrders}',
          note: 'הזמנות שטרם נמסרו (מתוך ${a.orders.length})',
        );
      case 'md-catalog':
        return _Metric(
          emoji: '📦',
          title: 'מוצרים בקטלוג',
          value: '${a.catalogCount}',
          note: 'מוצרים שאינם אביזרים נלווים',
        );
      case 'md-accessories':
        return _Metric(
          emoji: '🧰',
          title: 'אביזרים נלווים',
          value: '${a.accessoryCount}',
          note: 'מוצרי אביזרים נלווים בקטלוג',
        );
      case 'md-available':
        return _Metric(
          emoji: '✅',
          title: 'זמינים כעת',
          value: '${a.availableCount}',
          note: 'מוצרים זמינים במלאי מתוך ${a.totalProducts}',
        );
      case 'md-stores':
        return _Metric(
          emoji: '🏪',
          title: 'חנויות פעילות',
          value: a.storesLabel,
          note: 'חנויות פעילות מתוך סך החנויות',
        );
      default:
        return const _Metric(emoji: '📊', title: '', value: '', note: '');
    }
  }
}

class _Metric {
  const _Metric({
    required this.emoji,
    required this.title,
    required this.value,
    required this.note,
  });
  final String emoji;
  final String title;
  final String value;
  final String note;
}
