import 'package:buildsmart/test_harness/regression_state.dart';
import 'package:buildsmart/test_harness/runner.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegressionPanelScreen extends ConsumerWidget {
  const RegressionPanelScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const RegressionPanelScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(regressionStatusProvider);
    final summary = ref.watch(filteredSummaryProvider);
    final byCat = ref.watch(summaryByCategoryProvider);
    final filter = ref.watch(regressionFilterProvider);
    final results = ref.watch(filteredResultsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        title: const Text(
          '🔬 מרכז בדיקות רגרסיה',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'בודק את הקטלוג, ה-state, וה-views של המערכת',
            style: TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── The "Run" button ──
          _RunButton(status: status, ref: ref),

          if (status == RegressionStatus.done) ...[
            const SizedBox(height: 16),
            _SummaryCard(summary: summary, byCat: byCat),
            const SizedBox(height: 12),
            _FilterRow(active: filter),
            const SizedBox(height: 12),
            for (final r in results) _ResultCard(result: r),
          ],
        ],
      ),
    );
  }
}

class _RunButton extends StatelessWidget {
  const _RunButton({required this.status, required this.ref});
  final RegressionStatus status;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final running = status == RegressionStatus.running;
    final label = switch (status) {
      RegressionStatus.idle    => '▶ הרץ בדיקת רגרסיה מלאה',
      RegressionStatus.running => '⏳ מריץ את הבדיקות... רגע',
      RegressionStatus.done    => '↻ הרץ שוב',
    };
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: running ? const Color(0xFF5A7493) : BsTokens.brand,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: running ? null : () => runRegression(ref),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.byCat});
  final ({int total, int passed, int failed}) summary;
  final List<CategorySummary> byCat;

  @override
  Widget build(BuildContext context) {
    final ok = summary.failed == 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ok
              ? const Color(0xFF22C55E).withAlpha(120)
              : const Color(0xFFEF4444).withAlpha(120),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ok
                ? '✅ כל הבדיקות עברו (${summary.passed}/${summary.total})'
                : '❌ נמצאו ${summary.failed} כשלים',
            style: TextStyle(
              color: ok ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            byCat
                .where((c) => c.total > 0)
                .map((c) => '${c.category.he}: ${c.passed}/${c.total}')
                .join(' · '),
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.active});
  final String active;

  static const _filters = <({String id, String label})>[
    (id: 'all',      label: 'הכל'),
    (id: 'buttons',  label: 'כפתורים'),
    (id: 'tabs',     label: 'טאבים'),
    (id: 'products', label: 'מוצרים'),
    (id: 'behavior', label: 'התנהגות'),
    (id: 'dsync',    label: 'סנכרון'),
    (id: 'dupes',    label: 'זהויות'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in _filters) ...[
            _Pill(
              label: f.label,
              active: active == f.id,
              onTap: () =>
                  ref.read(regressionFilterProvider.notifier).state = f.id,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? BsTokens.brand : const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFFAAAAAA),
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final TestResult result;

  @override
  Widget build(BuildContext context) {
    final ok = result.allPass;
    final total = result.checks.length;
    final failed = result.failedCount;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ok
              ? const Color(0xFF22C55E).withAlpha(60)
              : const Color(0xFFEF4444).withAlpha(120),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          unselectedWidgetColor: Colors.white70,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white54,
          initiallyExpanded: !ok,
          title: Row(
            children: [
              Text(
                ok ? '✓' : '✗',
                style: TextStyle(
                  color: ok
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (result.area != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    result.area!,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 10,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                '${total - failed}/$total',
                style: TextStyle(
                  color: ok
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          children: [
            for (final c in result.checks) _CheckRow(check: c),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.check});
  final TestCheck check;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            check.pass ? '✓' : '✗',
            style: TextStyle(
              color: check.pass
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                if (check.detail != null && check.detail!.isNotEmpty)
                  Text(
                    check.detail!,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                    ),
                  ),
                if (!check.pass && check.expected != null)
                  Text(
                    'ציפיתי: ${check.expected} · קיבלתי: ${check.got ?? "—"}',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
