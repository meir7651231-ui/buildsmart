// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 44 — the FIRST
// authoring surface: the trade-builder HOME.
//
// The owner's authored-trade list + the 6-step wizard progress header + the
// 'הוסף ענף' action that opens step 1 (TradeDefineStepScreen). Reads the
// authored [tradesStoreProvider] (step 34) — an empty store renders the calm
// empty-state; each authored trade renders as a light tile with its emoji,
// nameHe, persona and a טיוטה/פורסם status chip.
//
// Reached ONLY from the manager 🛠️ ניהול entry that is gated on
// `featureFlagsProvider.isOn(kTradeBuilderFlag)` (default OFF — absent from
// prefs AND `_forcedOnFlags`), so a normal build never constructs this screen
// ⇒ zero regression. Visual language: the manager shell's LIGHT idiom
// (`bgLight` scaffold, WHITE `cardLight` cards + #EDEDED border, `brand`
// accents) — copied from manager_dashboard_screen.dart for plan-§6 visual
// consistency.
//
// a11y: explicit RTL INSIDE the screen, Semantics(button:) on every tappable,
// and the screen-local textScaler clamp (max 1.35) so huge OS type never
// shatters the RTL form layouts.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/category_tree_editor.dart';
import 'package:buildsmart/screens/trade_builder/trade_define_step.dart';
import 'package:buildsmart/screens/trade_builder/trade_publish_sheet.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The wizard step this home represents (define = step 1) and the total step
/// count of the trade-builder wizard (define → categories → attributes →
/// products → rules → publish). Steps 2-6 arrive in the next plan chunks; the
/// header renders 'שלב 1 מתוך 6' until then.
const int _kWizardStep = 1;
const int _kWizardTotal = 6;

/// 🏗️ בונה ענפים — the trade-builder home (Pillar-2 · step 44, wizard step 1).
class TradeBuilderHomeScreen extends ConsumerWidget {
  const TradeBuilderHomeScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const TradeBuilderHomeScreen(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trades = ref.watch(tradesStoreProvider).trades;
    final mq = MediaQuery.of(context);
    // a11y clamp: honor the OS/app text scale UP TO 1.35× — beyond that the
    // dense RTL tiles/forms break. Never scales UP (min), only caps.
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
              '🏗️ בונה ענפים',
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
              const _WizardHeader(),
              const SizedBox(height: BsTokens.space4),
              if (trades.isEmpty)
                const _EmptyTrades()
              else
                for (final t in trades)
                  Padding(
                    padding: const EdgeInsets.only(bottom: BsTokens.space3),
                    child: _TradeTile(trade: t),
                  ),
            ],
          ),
          // Pinned add-action (always reachable without scrolling): pushes the
          // wizard's step 1 — the define screen.
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                BsTokens.space4,
                BsTokens.space2,
                BsTokens.space4,
                BsTokens.space4,
              ),
              child: _AddTradeButton(
                onTap: () =>
                    Navigator.of(context).push(TradeDefineStepScreen.route()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The wizard-progress header — a WHITE card naming the current step
/// ('שלב 1 מתוך 6') over a 6-segment progress bar (the `_MiniTracker` idiom
/// from manager_dashboard_screen.dart: filled segments up to the current step,
/// light track for the rest).
class _WizardHeader extends StatelessWidget {
  const _WizardHeader();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'אשף בניית ענף — שלב $_kWizardStep מתוך $_kWizardTotal',
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
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'שלב 1 מתוך 6',
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  'הגדרת הענף',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space3),
            Row(
              children: [
                for (var i = 0; i < _kWizardTotal; i++) ...[
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: i < _kWizardStep
                            ? BsTokens.brand
                            : const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      ),
                    ),
                  ),
                  if (i < _kWizardTotal - 1) const SizedBox(width: 4),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The calm empty-state — the authored store starts EMPTY (plumbing is a baked
/// seed, not an authored row), so a fresh owner sees this invitation.
class _EmptyTrades extends StatelessWidget {
  const _EmptyTrades();

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
          Text('🧱', style: TextStyle(fontSize: 34)),
          SizedBox(height: BsTokens.space2),
          Text(
            'עדיין אין ענפים — הוסף את הראשון',
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

/// One authored-trade tile — a WHITE card (the manager `_MetricTile`/`_OrderRow`
/// card idiom) with the trade's emoji in a colour-washed square, its nameHe +
/// persona line, and the draft/published status chip.
class _TradeTile extends StatelessWidget {
  const _TradeTile({required this.trade});

  final Trade trade;

  @override
  Widget build(BuildContext context) {
    final status = trade.published ? 'פורסם' : 'טיוטה';
    return Semantics(
      button: true,
      label: '${trade.emoji} ${trade.nameHe} · $status',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        child: InkWell(
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          // s45 nav glue: the tile opens the trade's category-tree editor
          // (the next authoring surface) — insert-only wrapper, the card
          // inside is untouched.
          onTap: () => Navigator.of(context)
              .push(CategoryTreeEditorScreen.route(trade.id)),
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
                    color: Color(trade.color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Text(trade.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: BsTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trade.nameHe,
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
                        _personaTitle(trade.personaId),
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
                _StatusChip(published: trade.published),
                const SizedBox(width: BsTokens.space2),
                // s47 nav glue: the trade's publish sheet — an insert-only
                // trailing action; the tile's main onTap (→ the category
                // editor) stays intact.
                Semantics(
                  label: 'פרסם',
                  button: true,
                  child: IconButton(
                    onPressed: () => Navigator.of(context)
                        .push(TradePublishSheet.route(trade.id)),
                    icon: const Text('🚀', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The persona line under the trade name — `emoji title` from [kPersonas]
  /// (id/emoji/title), falling back to the raw id for an unknown persona.
  static String _personaTitle(String id) {
    for (final p in kPersonas) {
      if (p.id == id) return '${p.emoji} ${p.title}';
    }
    return id;
  }
}

/// The draft/published chip — the `_StagePill` idiom (a 12% colour wash with
/// full-colour text): טיוטה = dark amber, פורסם = the ready-green.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.published});

  final bool published;

  @override
  Widget build(BuildContext context) {
    final color =
        published ? const Color(0xFF1F8A4C) : const Color(0xFFB45309);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        published ? 'פורסם' : 'טיוטה',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// The pinned 'הוסף ענף' action — the manager `brand`-pill button idiom
/// (`_RegressionBody`'s open button), wrapped in Semantics(button:).
class _AddTradeButton extends StatelessWidget {
  const _AddTradeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'הוסף ענף',
      child: Material(
        color: BsTokens.brand,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'הוסף ענף',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: bsOnAccent(context),
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
