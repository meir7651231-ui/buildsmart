// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 44 — wizard step 1:
// DEFINE the trade.
//
// The minimal authoring form: שם הענף (required) · אימוג׳י (default 🛠️) ·
// פרסונה (from [kPersonas], default the first) · a fixed 6-swatch colour row
// (default the first) · 'שמור טיוטה'. Saving upserts a DRAFT [Trade]
// (published stays the ctor default `false`) into [tradesStoreProvider] under
// a DETERMINISTIC slug id — 'trade.' + the trimmed lowercased name with
// whitespace runs collapsed to '-' (NO DateTime/random), so re-saving the same
// name UPDATES the trade instead of duplicating it — then pops back to the
// builder home, whose list reflows off the same provider. An empty name is a
// no-op (the button renders disabled-grey and the save guard returns).
//
// Reached only via TradeBuilderHomeScreen (itself behind kTradeBuilderFlag,
// default OFF) ⇒ zero regression. LIGHT manager idiom + explicit RTL +
// Semantics on every tappable + the screen-local textScaler clamp (max 1.35).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The emoji a trade falls back to when the אימוג׳י field is left empty.
const String _kDefaultTradeEmoji = '🛠️';

/// The fixed colour palette for a new trade — 6 predefined ARGB ints (the
/// `Brand.color` format `Trade.color` matches): teal · blue · purple · green ·
/// amber · the BuildSmart brand orange. The FIRST is the default selection.
const List<int> _kTradeColors = [
  0xFF1F6F6B,
  0xFF2C7BE5,
  0xFF5A4A8C,
  0xFF1F8A4C,
  0xFFF2A516,
  0xFFFF7A18,
];

/// 🏗️ הגדרת ענף — the trade-builder wizard's step 1 (define name/emoji/
/// persona/colour, save as draft).
class TradeDefineStepScreen extends ConsumerStatefulWidget {
  const TradeDefineStepScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const TradeDefineStepScreen(),
      );

  @override
  ConsumerState<TradeDefineStepScreen> createState() =>
      _TradeDefineStepState();
}

class _TradeDefineStepState extends ConsumerState<TradeDefineStepScreen> {
  final _name = TextEditingController();
  final _emoji = TextEditingController(text: _kDefaultTradeEmoji);
  String _personaId = kPersonas.first.id;
  int _color = _kTradeColors.first;

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    super.dispose();
  }

  /// Deterministic slug id for an authored trade: `'trade.' + name` trimmed,
  /// lowercased, whitespace runs → '-'. NO DateTime/random — same name ⇒ same
  /// id ⇒ upsert updates instead of duplicating.
  static String _tradeSlug(String name) =>
      'trade.${name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-')}';

  /// Save the draft: guard the empty name (no-op), fall back to the default
  /// emoji, upsert into the authored store, and pop back to the builder home.
  void _saveDraft() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final emoji = _emoji.text.trim();
    ref.read(tradesStoreProvider.notifier).upsertTrade(
          Trade(
            id: _tradeSlug(name),
            nameHe: name,
            emoji: emoji.isEmpty ? _kDefaultTradeEmoji : emoji,
            color: _color,
            personaId: _personaId,
            // published stays the ctor default (false) — a DRAFT; publishing
            // is a later wizard step.
          ),
        );
    Navigator.of(context).pop();
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: BsTokens.cardLight,
        labelStyle:
            const TextStyle(color: BsTokens.mutedLight, fontSize: 13.5),
        hintStyle: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
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
    final mq = MediaQuery.of(context);
    final valid = _name.text.trim().isNotEmpty;
    // The SAME a11y clamp as the builder home: cap the text scale at 1.35×.
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
              'trade_define_step.title',
              '🏗️ הגדרת ענף',
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
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('שם הענף', hint: 'למשל: חשמל'),
              ),
              const SizedBox(height: BsTokens.space4),
              TextField(
                controller: _emoji,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('אימוג׳י', hint: _kDefaultTradeEmoji),
              ),
              const SizedBox(height: BsTokens.space4),
              DropdownButtonFormField<String>(
                value: _personaId,
                dropdownColor: BsTokens.cardLight,
                style:
                    const TextStyle(color: BsTokens.inkLight, fontSize: 14),
                decoration: _dec('פרסונה'),
                items: [
                  for (final p in kPersonas)
                    DropdownMenuItem(
                      value: p.id,
                      child: Text('${p.emoji} ${p.title}'),
                    ),
                ],
                onChanged: (v) =>
                    setState(() => _personaId = v ?? _personaId),
              ),
              const SizedBox(height: BsTokens.space4),
              const CfgText(
                'trade_define_step.color',
                'צבע',
                style: TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              Row(
                children: [
                  for (var i = 0; i < _kTradeColors.length; i++) ...[
                    _ColorSwatch(
                      color: _kTradeColors[i],
                      index: i,
                      selected: _color == _kTradeColors[i],
                      onTap: () =>
                          setState(() => _color = _kTradeColors[i]),
                    ),
                    if (i < _kTradeColors.length - 1)
                      const SizedBox(width: BsTokens.space2),
                  ],
                ],
              ),
              const SizedBox(height: BsTokens.space5),
              _SaveDraftButton(enabled: valid, onTap: _saveDraft),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tappable colour swatch — a circle of the colour itself, ink-ringed (+ a
/// check mark) when selected. Semantics(button:) with a per-swatch label.
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int color;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'צבע ${index + 1}',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(color),
            shape: BoxShape.circle,
            border: selected
                ? Border.all(color: BsTokens.inkLight, width: 3)
                : Border.all(color: const Color(0xFFEDEDED)),
          ),
          child: selected
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

/// The 'שמור טיוטה' action — the manager `brand`-pill button idiom. Always
/// tappable (the save guard no-ops on an empty name); [enabled] drives the
/// disabled-grey visual + the Semantics enabled flag.
class _SaveDraftButton extends StatelessWidget {
  const _SaveDraftButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'שמור טיוטה',
      child: Material(
        color: enabled ? BsTokens.brand : const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: CfgText(
              'trade_define_step.save_draft',
              'שמור טיוטה',
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
