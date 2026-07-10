// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 47 — the CONNECTION-
// RULE studio (wizard step 5 surface).
//
// The owner authors the trade's [ConnectorType]s and its [CompatibilityRule]
// matrix, then probes them on a test bench that runs the REAL
// [ConnectionResolver] — the exact evaluator the engine runs (single source
// of truth; the bench renders whatever the resolver returns, never a
// re-derived answer). THREE sections:
//   'מחברים' — the trade's types as tiles (Semantics-'מחק' delete) + the
//     add-row writing through `upsertConnectorType` under the DETERMINISTIC
//     slug id '<tradeId>.conn.<slug>' (the s44/s45 idiom — NO DateTime/random;
//     a collision appends '-2', '-3', …);
//   'מטריצת חיבורים' — the N×N grid over the trade's types SORTED BY ID
//     (rendered only when types exist): '✓' where a rule covers the UNORDERED
//     pair (either orientation), '·' where none. A ruleless cell opens the
//     'תווית שיטה' author dialog (empty label → no-op) and writes through
//     `upsertCompatRule` under the deterministic id
//     '<tradeId>.rule.<aTail>__<bTail>' (tails = the type-id slugs after the
//     last '.'), sizeMatch anyToAny + onMismatch critical; a ruled cell opens
//     the inspect dialog (the authored methodLabelHe + 'מחק כלל' / 'סגור');
//   'ספסל בדיקה' — two type picks ('מחבר א' / 'מחבר ב') + 'בדוק חיבור' build
//     TWO synthetic one-end specs (bench.a / bench.b, sizeValue '1') and call
//     `ConnectionResolver(rules: <the trade's compatRules>).canConnect` — a
//     FRESH resolver per probe (never a stale memo); mates → the authored
//     methodLabelHe in green, else the literal 'לא מתחבר' in red.
//
// Reached only via ProductAuthoringScreen's 🔌 AppBar action (itself behind
// kTradeBuilderFlag, default OFF) ⇒ zero regression; the live catalog keeps
// reading the baked seed unchanged (authored deltas only; the const files are
// untouched). LIGHT manager idiom + explicit RTL + Semantics on every
// tappable + the screen-local textScaler clamp (max 1.35) — the s44/s45
// family (trade_builder_home.dart) verbatim.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:buildsmart/domain/connection_resolver.dart';
import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The screen glyph (ConnectorType itself carries no emoji — the tiles and
/// the empty state reuse it).
const String _kConnectorEmoji = '🔌';

/// The s44 deterministic slug: trimmed, lowercased, whitespace runs → '-'.
/// NO DateTime/random — the same text always yields the same slug.
String _slug(String text) =>
    text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

/// The type-id tail — the slug after the LAST '.'
/// ('pipes.conn.male' → 'male'); an id with no '.' is its own tail.
String _tail(String id) => id.substring(id.lastIndexOf('.') + 1);

/// 🔌 כללי חיבור — the trade's connection-rule studio (Pillar-2 · step 47).
class ConnectionRuleStudioScreen extends ConsumerStatefulWidget {
  const ConnectionRuleStudioScreen({required this.tradeId, super.key});

  final String tradeId;

  static Route<void> route(String tradeId) => MaterialPageRoute<void>(
        builder: (_) => ConnectionRuleStudioScreen(tradeId: tradeId),
      );

  @override
  ConsumerState<ConnectionRuleStudioScreen> createState() =>
      _ConnectionRuleStudioState();
}

class _ConnectionRuleStudioState
    extends ConsumerState<ConnectionRuleStudioScreen> {
  final _name = TextEditingController();

  /// The bench picks (type ids; null until picked).
  String? _benchA;
  String? _benchB;

  /// The last bench probe — the REAL resolver's verdict (null = not run yet).
  ConnectResult? _benchResult;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// The trade's connector types, in authored order (the tiles + the bench
  /// dropdowns).
  List<ConnectorType> _types(TradesDoc doc) => [
        for (final t in doc.connectorTypes)
          if (t.tradeId == widget.tradeId) t,
      ];

  /// The matrix axes — the trade's types SORTED BY ID (deterministic; the
  /// grid never shuffles with authored order).
  List<ConnectorType> _sortedTypes(TradesDoc doc) =>
      _types(doc)..sort((a, b) => a.id.compareTo(b.id));

  /// The trade's compat rules, in authored order (the resolver's scan order).
  List<CompatibilityRule> _rules(TradesDoc doc) => [
        for (final r in doc.compatRules)
          if (r.tradeId == widget.tradeId) r,
      ];

  /// The FIRST rule covering the UNORDERED (a, b) pair — BOTH orientations
  /// checked; null when the pair is ruleless.
  static CompatibilityRule? _pairRule(
    List<CompatibilityRule> rules,
    String aId,
    String bId,
  ) {
    for (final r in rules) {
      final forward = r.aTypeId == aId && r.bTypeId == bId;
      final reverse = r.aTypeId == bId && r.bTypeId == aId;
      if (forward || reverse) return r;
    }
    return null;
  }

  /// '<tradeId>.conn.<slug>' — deterministic; an id collision appends '-2',
  /// then '-3', … (the s45 contract), so a same-named type never silently
  /// overwrites an existing one.
  String _newConnectorId(List<ConnectorType> all, String name) {
    final base = '${widget.tradeId}.conn.${_slug(name)}';
    var id = base;
    var n = 2;
    while (all.any((t) => t.id == id)) {
      id = '$base-${n++}';
    }
    return id;
  }

  /// Add a connector type from the add-row (empty name → no-op).
  void _addType() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final doc = ref.read(tradesStoreProvider);
    ref.read(tradesStoreProvider.notifier).upsertConnectorType(
          ConnectorType(
            id: _newConnectorId(doc.connectorTypes, name),
            tradeId: widget.tradeId,
            nameHe: name,
          ),
        );
    setState(_name.clear);
  }

  /// A matrix-cell tap: a ruleless pair opens the 'תווית שיטה' author dialog
  /// (empty label → no-op) and writes the rule under the deterministic id
  /// '<tradeId>.rule.<aTail>__<bTail>'; a ruled pair opens the inspect
  /// dialog — 'מחק כלל' pops true and the rule is removed, 'סגור' leaves it.
  Future<void> _tapCell(ConnectorType a, ConnectorType b) async {
    final rule =
        _pairRule(_rules(ref.read(tradesStoreProvider)), a.id, b.id);
    if (rule == null) {
      final label = await showDialog<String>(
        context: context,
        builder: (_) => const _MethodLabelDialog(),
      );
      if (!mounted) return;
      final method = label?.trim() ?? '';
      if (method.isEmpty) return; // empty label → no-op
      ref.read(tradesStoreProvider.notifier).upsertCompatRule(
            CompatibilityRule(
              id: '${widget.tradeId}.rule.${_tail(a.id)}__${_tail(b.id)}',
              tradeId: widget.tradeId,
              aTypeId: a.id,
              bTypeId: b.id,
              sizeMatch: SizeMatch.anyToAny,
              methodLabelHe: method,
              onMismatch: RuleSeverity.critical,
            ),
          );
    } else {
      final delete = await showDialog<bool>(
        context: context,
        builder: (_) => _RuleInspectDialog(rule: rule),
      );
      if (!mounted) return;
      if (delete ?? false) {
        ref.read(tradesStoreProvider.notifier).removeCompatRule(rule.id);
      }
    }
  }

  /// Probe the REAL resolver (single source of truth): TWO synthetic one-end
  /// specs over the picked types, evaluated against the trade's authored
  /// rules by a FRESH [ConnectionResolver] (never a stale memo). Missing
  /// picks → no-op.
  void _runBench() {
    final aId = _benchA;
    final bId = _benchB;
    if (aId == null || bId == null) return;
    final doc = ref.read(tradesStoreProvider);
    final types = _types(doc);
    if (!types.any((t) => t.id == aId) || !types.any((t) => t.id == bId)) {
      return;
    }
    final a = ProductConnectorSpec(
      productSku: 'bench.a',
      tradeId: widget.tradeId,
      ends: [ProductEnd(connectorTypeId: aId, sizeValue: '1')],
    );
    final b = ProductConnectorSpec(
      productSku: 'bench.b',
      tradeId: widget.tradeId,
      ends: [ProductEnd(connectorTypeId: bId, sizeValue: '1')],
    );
    final result = ConnectionResolver(rules: _rules(doc)).canConnect(a, b);
    setState(() => _benchResult = result);
  }

  // NOTE deliberately NO hintText anywhere on this screen: a hint renders as
  // a real (transparent) Text widget, and the step-47 tests count VISIBLE
  // Text widgets containing authored names — a 'למשל: …' hint echoing a
  // plausible name would poison those counts.
  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: BsTokens.cardLight,
        labelStyle:
            const TextStyle(color: BsTokens.mutedLight, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BsTokens.brand, width: 1.4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final doc = ref.watch(tradesStoreProvider);
    final types = _types(doc);
    final sorted = _sortedTypes(doc);
    final rules = _rules(doc);
    // Guard the kept picks against a type deleted meanwhile (a Dropdown
    // asserts its value is among its items).
    final benchA = types.any((t) => t.id == _benchA) ? _benchA : null;
    final benchB = types.any((t) => t.id == _benchB) ? _benchB : null;
    final result = _benchResult;
    final mq = MediaQuery.of(context);
    // The SAME a11y clamp as the s44/s45 builder screens: cap the text scale
    // at 1.35× (never scales UP — min only caps).
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(math.min(mq.textScaler.scale(1), 1.35)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: BsTokens.bgLight,
          appBar: AppBar(
            backgroundColor: BsTokens.cardLight,
            elevation: 0,
            iconTheme: const IconThemeData(color: BsTokens.inkLight),
            title: const CfgText(
              'connection_rule_studio.screen_title',
              '🔌 כללי חיבור',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              BsTokens.space4,
              BsTokens.space4,
              BsTokens.space4,
              BsTokens.space5,
            ),
            children: [
              // ── (1) the authored connector types ───────────────────────
              const _SectionHeader('מחברים'),
              const SizedBox(height: BsTokens.space3),
              if (types.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: BsTokens.space4),
                  child: _EmptyConnectors(),
                )
              else
                for (final t in types)
                  Padding(
                    padding: const EdgeInsets.only(bottom: BsTokens.space3),
                    child: _ConnectorTile(
                      type: t,
                      onDelete: () => ref
                          .read(tradesStoreProvider.notifier)
                          .removeConnectorType(t.id),
                    ),
                  ),
              const SizedBox(height: BsTokens.space2),
              // ── the add-row ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _name,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _addType(),
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 14,
                      ),
                      decoration: _dec('שם מחבר'),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  _PillButton(
                    label: 'הוסף מחבר',
                    enabled: _name.text.trim().isNotEmpty,
                    onTap: _addType,
                  ),
                ],
              ),
              // ── (2) the compatibility matrix (types exist only) ────────
              if (sorted.isNotEmpty) ...[
                const SizedBox(height: BsTokens.space5),
                const _SectionHeader('מטריצת חיבורים'),
                const SizedBox(height: BsTokens.space3),
                _Matrix(types: sorted, rules: rules, onCell: _tapCell),
              ],
              // ── (3) the test bench — the REAL resolver ─────────────────
              const SizedBox(height: BsTokens.space5),
              const _SectionHeader('ספסל בדיקה'),
              const SizedBox(height: BsTokens.space3),
              DropdownButtonFormField<String>(
                value: benchA,
                dropdownColor: BsTokens.cardLight,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('מחבר א'),
                items: [
                  for (final t in types)
                    DropdownMenuItem(value: t.id, child: Text(t.nameHe)),
                ],
                onChanged: (v) => setState(() => _benchA = v),
              ),
              const SizedBox(height: BsTokens.space4),
              DropdownButtonFormField<String>(
                value: benchB,
                dropdownColor: BsTokens.cardLight,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('מחבר ב'),
                items: [
                  for (final t in types)
                    DropdownMenuItem(value: t.id, child: Text(t.nameHe)),
                ],
                onChanged: (v) => setState(() => _benchB = v),
              ),
              const SizedBox(height: BsTokens.space4),
              _PillButton(
                label: 'בדוק חיבור',
                enabled: benchA != null && benchB != null,
                onTap: _runBench,
              ),
              if (result != null) ...[
                const SizedBox(height: BsTokens.space4),
                Text(
                  // The resolver's verdict VERBATIM: the matched rule's
                  // authored joint label on mates, the fixed miss literal
                  // otherwise (methodLabelHe is '' on a miss by contract).
                  result.mates ? result.methodLabelHe : 'לא מתחבר',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: result.mates
                        ? BsTokens.successDark
                        : BsTokens.dangerDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A section header — the family's bold ink line ('מחברים' /
/// 'מטריצת חיבורים' / 'ספסל בדיקה').
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: BsTokens.inkLight,
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
    );
  }
}

/// The calm empty-state — the s45 _EmptyCategories idiom with the s47
/// literal.
class _EmptyConnectors extends StatelessWidget {
  const _EmptyConnectors();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space5,
      ),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: const Column(
        children: [
          Text(_kConnectorEmoji, style: TextStyle(fontSize: 34)),
          SizedBox(height: BsTokens.space2),
          CfgText(
            'connection_rule_studio.empty_connectors',
            'אין עדיין מחברים',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BsTokens.mutedLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// One authored-type tile — the family's WHITE card: emoji square + nameHe
/// and a Semantics-'מחק' trailing delete.
class _ConnectorTile extends StatelessWidget {
  const _ConnectorTile({required this.type, required this.onDelete});

  final ConnectorType type;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$_kConnectorEmoji ${type.nameHe}',
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: BsTokens.brand.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                _kConnectorEmoji,
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: BsTokens.space3),
            Expanded(
              child: Text(
                type.nameHe,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Semantics(
              label: 'מחק',
              button: true,
              child: IconButton(
                onPressed: onDelete,
                // A real tooltip: a semantics label for screen-readers AND
                // a long-press hint — independent of semantics-tree timing.
                tooltip: 'מחק',
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: BsTokens.mutedLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The N×N unordered-pair grid — the sorted types on BOTH axes; '✓' where a
/// rule covers the (row, column) pair in EITHER orientation, '·' where none.
/// The cells are the ONLY content (each pair is named by its Semantics label
/// 'חיבור <a> אל <b>' — no header texts to poison the authored-name finder
/// counts); a wide matrix scrolls horizontally inside its card.
class _Matrix extends StatelessWidget {
  const _Matrix({
    required this.types,
    required this.rules,
    required this.onCell,
  });

  final List<ConnectorType> types;
  final List<CompatibilityRule> rules;
  final void Function(ConnectorType a, ConnectorType b) onCell;

  /// Does ANY rule cover the unordered (a, b) pair? Both orientations count.
  bool _ruled(String aId, String bId) => rules.any(
        (r) =>
            (r.aTypeId == aId && r.bTypeId == bId) ||
            (r.aTypeId == bId && r.bTypeId == aId),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final a in types)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final b in types)
                    _MatrixCell(
                      a: a,
                      b: b,
                      ruled: _ruled(a.id, b.id),
                      onTap: () => onCell(a, b),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// One matrix cell — the whole square tappable; '✓' = the pair has an
/// authored rule (either orientation), '·' = ruleless.
class _MatrixCell extends StatelessWidget {
  const _MatrixCell({
    required this.a,
    required this.b,
    required this.ruled,
    required this.onTap,
  });

  final ConnectorType a;
  final ConnectorType b;
  final bool ruled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'חיבור ${a.nameHe} אל ${b.nameHe}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.all(2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEDEDED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ruled ? '✓' : '·',
              style: TextStyle(
                color:
                    ruled ? BsTokens.successDark : BsTokens.mutedLight,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The author dialog for a ruleless pair — owns its controller (safe
/// dispose), brings its own RTL (dialogs mount on the app overlay, ABOVE the
/// screen's Directionality). 'שמור' pops the typed method label;
/// barrier-dismiss pops null (the caller no-ops on empty either way).
class _MethodLabelDialog extends StatefulWidget {
  const _MethodLabelDialog();

  @override
  State<_MethodLabelDialog> createState() => _MethodLabelDialogState();
}

class _MethodLabelDialogState extends State<_MethodLabelDialog> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: BsTokens.cardLight,
        title: const CfgText(
          'connection_rule_studio.new_rule',
          'כלל חדש',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: _ctl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(context, v),
          style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'תווית שיטה',
            filled: true,
            fillColor: BsTokens.cardLight,
            labelStyle:
                const TextStyle(color: BsTokens.mutedLight, fontSize: 13.5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEDEDED)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: BsTokens.brand, width: 1.4),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _ctl.text),
            style: TextButton.styleFrom(foregroundColor: BsTokens.brand),
            child: const CfgText(
              'connection_rule_studio.save',
              'שמור',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// The inspect dialog for a ruled pair — shows the authored methodLabelHe;
/// 'מחק כלל' pops true (the caller removes the rule), 'סגור' pops false.
/// Brings its own RTL like every dialog of the family.
class _RuleInspectDialog extends StatelessWidget {
  const _RuleInspectDialog({required this.rule});

  final CompatibilityRule rule;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: BsTokens.cardLight,
        title: const CfgText(
          'connection_rule_studio.rule_title',
          'כלל חיבור',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: Text(
          rule.methodLabelHe,
          style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const CfgText(
              'connection_rule_studio.delete_rule',
              'מחק כלל',
              style: TextStyle(
                color: BsTokens.dangerDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: BsTokens.brand),
            child: const CfgText(
              'connection_rule_studio.close',
              'סגור',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// The family's brand-pill action (the s44 _SaveDraftButton idiom): always
/// tappable (guards no-op), [enabled] drives the disabled-grey visual + the
/// Semantics enabled flag. Shrink-wraps in a Row, stretches in a ListView.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: enabled ? BsTokens.brand : const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: enabled ? bsOnAccent(context) : BsTokens.mutedLight,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
