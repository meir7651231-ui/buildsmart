// ─────────────────────────────────────────────────────────────────────────────
// StudioRulesScreen — BuildSmart Studio · Pillar 4 · Step 84. The manager-only
// AUTOMATION RULES pane (the 🔒 כללים tab, index 2 of the StudioScreen shell). A
// rule is `trigger → condition → action`, every slot picked from a CLOSED SET
// (`rules_model.dart` §6). Phase-1 rules are READ-ONLY ADVISORY (§4/§8/§9):
// composing a rule computes + SURFACES "כרגע N הזמנות תואמות" over the LIVE engines
// — it NEVER mutates orders/tasks/anything.
//
// THE INVARIANT (§4/§8 · DoD §8 greps this file): NO orders mutation. This screen
// only `ref.watch`es the orders-engine + manager-analytics providers (the read
// idiom of `manager_copilot_screen.dart:53-64`) and passes the immutable list to
// the PURE `evalRuleAdvisory`. It NEVER reads the orders-engine notifier, never
// places / advances / sets a stage — it only READS. The MUTATING actions
// (`flag.order` / `suggest.reorder`) are shown in the picker (never dropped —
// governance transparency, R1-5) but GREYED / DEFERRED behind a confirm-gate note;
// they are not selectable and not wired to any write in Phase-1.
//
// RECONCILIATION #1 — this REPLACES the `_RulesPane` placeholder (the "safety floor
// / what the Studio may change" framing). The safety-floor framing survives as a
// sub-note at the top; the tab now hosts these automation rules.
//
// RECONCILIATION #2 — P1's frozen `ConfigDoc` has NO `rules` slot, and Phase-1
// rules are read-only advisory, so the working rules are held in SIMPLE LOCAL
// STATE here (a `List<Rule>`), NOT round-tripped through P1's frozen draft. The
// model's own `Rule.toJson`/`fromJson` (§10) is ready for a FUTURE P1 integration.
//
// Colors from [BsTokens] only (the color-ratchet — zero raw color literals).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/manager_dashboard.dart' show ManagerAnalytics;
import 'package:buildsmart/logic/studio/rules_model.dart';
import 'package:buildsmart/state/orders_engine.dart'
    show Order, managerAnalyticsProvider, ordersEngineProvider;
import 'package:buildsmart/theme/app_theme.dart' show bsOnAccent;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The 🔒 כללים tab pane — manual automation-rule builder + read-only advisory.
class StudioRulesScreen extends ConsumerStatefulWidget {
  const StudioRulesScreen({super.key});

  @override
  ConsumerState<StudioRulesScreen> createState() => _StudioRulesScreenState();
}

class _StudioRulesScreenState extends ConsumerState<StudioRulesScreen> {
  // The composed rule's slots — every one a CLOSED-SET member. Defaults spell the
  // canonical §5 example ("הזמנה תקועה · ימים פתוחה > 2 · התרע למנהל") so the
  // advisory count shows immediately.
  String _trigger = kTriggerOrderStuck;
  String _field = kFieldAgeDays;
  String _op = '>';
  String _action = kActionNotifyManager;
  final TextEditingController _valueController =
      TextEditingController(text: '2');

  // The working rules — SIMPLE LOCAL STATE (reconciliation #2): NOT P1's ConfigDoc.
  // `Rule.toJson` (§10) is ready for a future P1 integration; nothing is persisted
  // through P1's frozen draft in Phase-1.
  final List<Rule> _rules = <Rule>[];

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  /// The rule the pickers currently compose, or null when the value is not numeric
  /// (then the advisory shows a hint instead of a count). The selected action is
  /// always a READ-ONLY one (mutating actions are not selectable — see the picker).
  Rule? _composed() {
    final value = num.tryParse(_valueController.text.trim());
    if (value == null) return null;
    return Rule(
      trigger: _trigger,
      condition: RuleCondition(field: _field, op: _op, value: value),
      action: _action,
    );
  }

  void _addRule() {
    final rule = _composed();
    if (rule == null || rule.isMutating) return; // Phase-1 adds read-only rules only.
    setState(() => _rules.add(rule));
  }

  @override
  Widget build(BuildContext context) {
    // READ-ONLY sources (the manager_copilot_screen.dart:53-64 read idiom). We
    // WATCH the live list + analytics; we NEVER touch `.notifier`.
    final orders = ref.watch(ordersEngineProvider);
    final analytics = ref.watch(managerAnalyticsProvider);

    final composed = _composed();
    final matches = composed == null
        ? null
        : evalRuleAdvisory(composed, orders: orders, analytics: analytics);

    return ListView(
      padding: const EdgeInsets.all(BsTokens.space4),
      children: [
        _introNote(),
        const SizedBox(height: BsTokens.space4),

        // ── מתי (trigger) ──
        _sectionTitle('🔔 מתי'),
        const SizedBox(height: BsTokens.space2),
        Wrap(
          spacing: BsTokens.space2,
          runSpacing: BsTokens.space2,
          children: [
            for (final t in kRuleTriggers)
              _pill(
                label: t.labelHe,
                selected: _trigger == t.id,
                onTap: () => setState(() => _trigger = t.id),
              ),
          ],
        ),
        const SizedBox(height: BsTokens.space4),

        // ── תנאי (condition: field · op · value) ──
        _sectionTitle('📐 תנאי'),
        const SizedBox(height: BsTokens.space2),
        Wrap(
          spacing: BsTokens.space2,
          runSpacing: BsTokens.space2,
          children: [
            for (final f in kRuleFields)
              _pill(
                label: f.labelHe,
                selected: _field == f.id,
                onTap: () => setState(() => _field = f.id),
              ),
          ],
        ),
        const SizedBox(height: BsTokens.space2),
        Row(
          children: [
            Wrap(
              spacing: BsTokens.space2,
              children: [
                for (final op in kRuleOpsList)
                  _pill(
                    label: op,
                    selected: _op == op,
                    onTap: () => setState(() => _op = op),
                  ),
              ],
            ),
            const SizedBox(width: BsTokens.space3),
            SizedBox(
              width: 84,
              child: TextField(
                key: const Key('studio-rule-value'),
                controller: _valueController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: BsTokens.cardLight,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: BsTokens.space4),

        // ── פעולה (action — read-only selectable; mutating GREYED/deferred) ──
        _sectionTitle('⚡ פעולה'),
        const SizedBox(height: BsTokens.space2),
        Wrap(
          spacing: BsTokens.space2,
          runSpacing: BsTokens.space2,
          children: [
            for (final a in kRuleActions)
              _pill(
                label: a.mutating ? '${a.labelHe} 🔒' : a.labelHe,
                selected: !a.mutating && _action == a.id,
                // Mutating actions are DEFERRED — shown (never dropped) but not
                // selectable (onTap null → greyed), mirroring the typed-arg R1-5.
                onTap: a.mutating ? null : () => setState(() => _action = a.id),
                disabled: a.mutating,
              ),
          ],
        ),
        const SizedBox(height: BsTokens.space2),
        const CfgText(
          'studio_rules_screen.t01',
          'פעולות משנות (סמן הזמנה · הצע הזמנה חוזרת) מוקפאות — ידרשו אישור מפורש. '
          'הכללים כאן קוראים בלבד ומתריעים; אינם משנים הזמנות.',
          style: TextStyle(
            color: BsTokens.mutedLight,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: BsTokens.space4),

        // ── advisory preview (§9) — "כרגע N הזמנות תואמות" ──
        _advisoryCard(matches),
        const SizedBox(height: BsTokens.space3),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: const Key('studio-rule-add'),
            onPressed: composed == null ? null : _addRule,
            style: ElevatedButton.styleFrom(
              backgroundColor: BsTokens.brand,
              disabledBackgroundColor: BsTokens.divider,
              foregroundColor: bsOnAccent(context),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const CfgText(
              'studio_rules_screen.t02',
              'הוסף כלל',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),

        if (_rules.isNotEmpty) ...[
          const SizedBox(height: BsTokens.space4),
          _sectionTitle('📋 כללים פעילים'),
          const SizedBox(height: BsTokens.space2),
          for (var i = 0; i < _rules.length; i++)
            _ruleRow(_rules[i], i, orders: orders, analytics: analytics),
        ],
      ],
    );
  }

  // ── pieces ──

  Widget _introNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.surfaceMid,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: const CfgText(
        'studio_rules_screen.t03',
        '🔒 כללי אוטומציה — מתי → תנאי → פעולה. בשלב זה הכללים קוראים בלבד: הם '
        'סופרים כמה פריטים תואמים כרגע ומתריעים. מחירים ופעולות-ליבה תמיד מוגנים; '
        'פעולות שמשנות הזמנות מוקפאות עד אישור מפורש.',
        style: TextStyle(
          color: BsTokens.mutedLight,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      );

  Widget _advisoryCard(int? matches) {
    return Container(
      key: const Key('studio-rule-advisory'),
      width: double.infinity,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.surfaceMid,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Text(
        matches == null
            ? 'הזן ערך מספרי לתנאי כדי לראות תצוגה מקדימה.'
            : '👁️ ${advisoryHe(matches)} — תצוגה מקדימה, לפני שמירה (קריאה בלבד).',
        style: TextStyle(
          color: matches == null ? BsTokens.mutedLight : BsTokens.inkLight,
          fontSize: 13,
          height: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _ruleRow(
    Rule rule,
    int index, {
    required List<Order> orders,
    required ManagerAnalytics analytics,
  }) {
    // READ-ONLY per-rule advisory — same pure eval over the live (watched) orders.
    final matches = evalRuleAdvisory(rule, orders: orders, analytics: analytics);
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: BsTokens.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ruleSummaryHe(rule),
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: BsTokens.space1),
                Text(
                  advisoryHe(matches),
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: BsTokens.mutedLight),
            onPressed: () => setState(() => _rules.removeAt(index)),
            tooltip: 'הסר כלל',
          ),
        ],
      ),
    );
  }

  /// A closed-set choice pill (the manager-toggle style). [disabled] → greyed +
  /// non-tappable (the deferred mutating actions).
  Widget _pill({
    required String label,
    required bool selected,
    required VoidCallback? onTap,
    bool disabled = false,
  }) {
    final bg = disabled
        ? BsTokens.surfaceMid
        : (selected ? BsTokens.brand : BsTokens.cardLight);
    final fg = disabled
        ? BsTokens.mutedLight
        : (selected ? bsOnAccent(context) : BsTokens.inkLight);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space3,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            border: Border.all(
              color: selected && !disabled ? BsTokens.brand : BsTokens.divider,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
