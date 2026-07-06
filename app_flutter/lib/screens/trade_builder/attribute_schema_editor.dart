// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 45 — the ATTRIBUTE-
// SCHEMA editor (wizard step 3 surface).
//
// The owner authors the trade's [AttributeDef]s: a list of the existing defs
// (name + kind + value chips, with the plan-addition-B EDIT-TIME validation —
// a variant axis with NO values renders the yellow warning chip
// 'ציר וריאנט ללא ערכים', BOTH on a saved def's tile and LIVE on the add-form
// while the switch is on with zero staged values), an add-form (שם מאפיין ·
// kind dropdown · a values builder with deletable chips · ציר וריאנט? switch
// · הוסף מאפיין) writing
// through `upsertAttribute` under a DETERMINISTIC slug id
// '<tradeId>.attr.<slug>' (the s44 idiom — NO DateTime/random; a collision
// appends '-2', '-3', …), and the LIVE decompose preview: typing a sample
// product name into 'בדיקת פירוק שם' surfaces every authored attribute VALUE
// contained in it as a 'שם: ערך' chip — simple `contains` matching over the
// SAME authored data (labelHe, plus the value's `canonical` form when set;
// `matchTokens` live per-DEF in the real schema, not per-value, so they name
// no single value and are not used here).
//
// Reached only via CategoryTreeEditorScreen's 🏷️ AppBar action (itself behind
// kTradeBuilderFlag, default OFF) ⇒ zero regression. LIGHT manager idiom +
// explicit RTL + Semantics on every tappable + the screen-local textScaler
// clamp (max 1.35) — the s44 family (trade_builder_home.dart) verbatim.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The emoji a new attribute definition is stamped with (the add-form keeps
/// the minimal s45 surface — no emoji field yet).
const String _kDefaultAttrEmoji = '🏷️';

/// The draft-amber of the family's warning chips (_StatusChip 'טיוטה' idiom).
const Color _kWarnColor = Color(0xFFB45309);

/// The ready-green of the family's success chips (_StatusChip 'פורסם' idiom).
const Color _kMatchColor = Color(0xFF1F8A4C);

/// The s44 deterministic slug: trimmed, lowercased, whitespace runs → '-'.
/// NO DateTime/random — the same text always yields the same slug.
String _slug(String text) =>
    text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

/// The Hebrew label of an [AttributeKind] (all user-facing strings are
/// Hebrew; the enum name itself is a persistence token, never UI).
String _kindHe(AttributeKind k) => switch (k) {
      AttributeKind.dimension => 'מידה',
      AttributeKind.choice => 'בחירה',
      AttributeKind.material => 'חומר',
      AttributeKind.color => 'צבע',
      AttributeKind.freeText => 'טקסט חופשי',
      AttributeKind.number => 'מספר',
    };

/// 🏷️ מאפיינים — the trade's attribute-schema editor (Pillar-2 · step 45).
class AttributeSchemaEditorScreen extends ConsumerStatefulWidget {
  const AttributeSchemaEditorScreen({required this.tradeId, super.key});

  final String tradeId;

  static Route<void> route(String tradeId) => MaterialPageRoute<void>(
        builder: (_) => AttributeSchemaEditorScreen(tradeId: tradeId),
      );

  @override
  ConsumerState<AttributeSchemaEditorScreen> createState() =>
      _AttributeSchemaEditorState();
}

class _AttributeSchemaEditorState
    extends ConsumerState<AttributeSchemaEditorScreen> {
  final _name = TextEditingController();
  final _value = TextEditingController();
  final _probe = TextEditingController();
  AttributeKind _kind = AttributeKind.values.first;
  bool _isAxis = false;
  final List<String> _pendingValues = [];

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    _probe.dispose();
    super.dispose();
  }

  /// The trade's defs, in authored order (defs carry no sortIndex).
  List<AttributeDef> _defs(TradesDoc doc) => [
        for (final a in doc.attributes)
          if (a.tradeId == widget.tradeId) a,
      ];

  /// '<tradeId>.attr.<slug>' — deterministic; an id collision appends '-2',
  /// then '-3', … (the s45 contract), so a same-named def never silently
  /// overwrites an existing one.
  String _newAttrId(List<AttributeDef> all, String name) {
    final base = '${widget.tradeId}.attr.${_slug(name)}';
    var id = base;
    var n = 2;
    while (all.any((a) => a.id == id)) {
      id = '$base-${n++}';
    }
    return id;
  }

  /// Stage one value chip. Empty input is a no-op; a duplicate (same slug —
  /// value ids must stay unique inside the def) is a no-op.
  void _addValue() {
    final v = _value.text.trim();
    if (v.isEmpty) return;
    final slug = _slug(v);
    if (_pendingValues.any((p) => _slug(p) == slug)) return;
    setState(() {
      _pendingValues.add(v);
      _value.clear();
    });
  }

  /// Author the def: guard the empty name (no-op), materialize the staged
  /// value chips as [AttributeValue]s (sortIndex = staged order), upsert, and
  /// reset the form for the next def.
  void _addAttribute() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final doc = ref.read(tradesStoreProvider);
    ref.read(tradesStoreProvider.notifier).upsertAttribute(
          AttributeDef(
            id: _newAttrId(doc.attributes, name),
            tradeId: widget.tradeId,
            nameHe: name,
            emoji: _kDefaultAttrEmoji,
            kind: _kind,
            values: [
              for (var i = 0; i < _pendingValues.length; i++)
                AttributeValue(
                  id: _slug(_pendingValues[i]),
                  labelHe: _pendingValues[i],
                  sortIndex: i,
                ),
            ],
            isVariantAxis: _isAxis,
          ),
        );
    setState(() {
      _name.clear();
      _value.clear();
      _pendingValues.clear();
      _isAxis = false;
      _kind = AttributeKind.values.first;
    });
  }

  /// The live decompose preview — every (def-name, value-label) pair whose
  /// value text (labelHe, or its `canonical` form when set) is contained in
  /// the typed sample name. Simple `contains` over the authored data; per-DEF
  /// `matchTokens` name no single value, so they don't participate.
  List<(String, String)> _decompose(List<AttributeDef> defs) {
    final probe = _probe.text.trim();
    if (probe.isEmpty) return const [];
    final out = <(String, String)>[];
    for (final d in defs) {
      for (final v in d.values) {
        final canonical = v.canonical;
        final hit = (v.labelHe.isNotEmpty && probe.contains(v.labelHe)) ||
            (canonical != null &&
                canonical.isNotEmpty &&
                probe.contains(canonical));
        if (hit) out.add((d.nameHe, v.labelHe));
      }
    }
    return out;
  }

  // NOTE deliberately NO hintText anywhere on this screen: a hint renders as
  // a real (transparent) Text widget, and the step-45 tests count VISIBLE
  // Text widgets containing authored names/values — a 'למשל: 16' hint echoing
  // a plausible value would poison those counts.
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
    final defs = _defs(ref.watch(tradesStoreProvider));
    final matches = _decompose(defs);
    final mq = MediaQuery.of(context);
    // The SAME a11y clamp as the s44 builder screens: cap the text scale at
    // 1.35× (never scales UP — min only caps).
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
            title: const Text(
              '🏷️ מאפיינים',
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
              // ── the authored defs ──────────────────────────────────────
              if (defs.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: BsTokens.space4),
                  child: Text(
                    'אין עדיין מאפיינים',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                for (final d in defs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: BsTokens.space3),
                    child: _AttributeTile(
                      def: d,
                      onDelete: () => ref
                          .read(tradesStoreProvider.notifier)
                          .removeAttribute(d.id),
                    ),
                  ),
              const SizedBox(height: BsTokens.space2),
              // ── the add-form ───────────────────────────────────────────
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('שם מאפיין'),
              ),
              const SizedBox(height: BsTokens.space4),
              DropdownButtonFormField<AttributeKind>(
                value: _kind,
                dropdownColor: BsTokens.cardLight,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('סוג'),
                items: [
                  for (final k in AttributeKind.values)
                    DropdownMenuItem(value: k, child: Text(_kindHe(k))),
                ],
                onChanged: (v) => setState(() => _kind = v ?? _kind),
              ),
              const SizedBox(height: BsTokens.space4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _value,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _addValue(),
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 14,
                      ),
                      decoration: _dec('ערך'),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  _PillButton(
                    label: 'הוסף ערך',
                    enabled: _value.text.trim().isNotEmpty,
                    onTap: _addValue,
                  ),
                ],
              ),
              if (_pendingValues.isNotEmpty) ...[
                const SizedBox(height: BsTokens.space3),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final v in _pendingValues)
                      Chip(
                        label: Text(
                          v,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 13,
                          ),
                        ),
                        backgroundColor: BsTokens.cardLight,
                        side: const BorderSide(color: Color(0xFFEDEDED)),
                        deleteButtonTooltipMessage: 'הסר',
                        onDeleted: () =>
                            setState(() => _pendingValues.remove(v)),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: BsTokens.space2),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: BsTokens.brand,
                title: const Text(
                  'ציר וריאנט?',
                  style: TextStyle(color: BsTokens.inkLight, fontSize: 14),
                ),
                value: _isAxis,
                onChanged: (v) => setState(() => _isAxis = v),
              ),
              // Plan addition-B, LIVE on the form too: an axis being authored
              // with ZERO staged values can never decompose a name — warn the
              // moment the switch flips, clear the moment a value lands.
              if (_isAxis && _pendingValues.isEmpty) ...[
                const SizedBox(height: BsTokens.space2),
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _WarnChip(text: 'ציר וריאנט ללא ערכים'),
                ),
              ],
              const SizedBox(height: BsTokens.space2),
              _PillButton(
                label: 'הוסף מאפיין',
                enabled: _name.text.trim().isNotEmpty,
                onTap: _addAttribute,
              ),
              const SizedBox(height: BsTokens.space5),
              // ── the live decompose preview ─────────────────────────────
              TextField(
                controller: _probe,
                onChanged: (_) => setState(() {}),
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('בדיקת פירוק שם'),
              ),
              if (matches.isNotEmpty) ...[
                const SizedBox(height: BsTokens.space3),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final m in matches)
                      _MatchChip(text: '${m.$1}: ${m.$2}'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One authored-def tile — the family's WHITE card: emoji square + nameHe +
/// the Hebrew kind line, a Semantics 'מחק' delete button, and the def's value
/// chips (or the plan-addition-B warning when a variant axis has none).
class _AttributeTile extends StatelessWidget {
  const _AttributeTile({required this.def, required this.onDelete});

  final AttributeDef def;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final warnAxisNoValues = def.isVariantAxis && def.values.isEmpty;
    return Semantics(
      label: '${def.emoji} ${def.nameHe} · ${_kindHe(def.kind)}',
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BsTokens.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    def.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: BsTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def.nameHe,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _kindHe(def.kind),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Semantics(
                  label: 'מחק',
                  button: true,
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: BsTokens.mutedLight,
                    ),
                  ),
                ),
              ],
            ),
            if (warnAxisNoValues || def.values.isNotEmpty) ...[
              const SizedBox(height: BsTokens.space3),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  // Plan addition-B (edit-time validation): a variant axis
                  // with NO values can never decompose a product name — warn
                  // right here, at authoring time.
                  if (warnAxisNoValues)
                    const _WarnChip(text: 'ציר וריאנט ללא ערכים')
                  else
                    for (final v in def.values) _ValueChip(text: v.labelHe),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One authored-value pill — neutral bordered white (read-only display).
class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The yellow edit-time warning pill (the _StatusChip 'טיוטה' amber idiom —
/// a 12% wash with full-colour AA text).
class _WarnChip extends StatelessWidget {
  const _WarnChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kWarnColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _kWarnColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// One decompose-preview hit ('קוטר: 16') — the success-green pill (the
/// _StatusChip 'פורסם' idiom).
class _MatchChip extends StatelessWidget {
  const _MatchChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kMatchColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _kMatchColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
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
