// ─────────────────────────────────────────────────────────────────────────────
// ManagerCopilotScreen — "שאל את העסק שלך" (M2 · the owner's AI analyst).
//
// The owner types (or taps a suggestion / "תדריך-בוקר") → we fold the LIVE engine
// state (`managerAnalyticsProvider`/`managerCustomersProvider`/`ordersEngineProvider`)
// into a GROUNDED snapshot (`buildManagerContext`) and hand it to Claude with a
// "reason over truth, never invent" system prompt. Every number Claude sees is the
// real business data; it only PHRASES the answer. Gated on a live gateway
// (`claudeGatewayProvider`) — OFF → an honest "requires connection" state.
//
// Manager-only intelligence/oversight surface → governance-clean (no HR), additive,
// zero-regression. Reached from the 📊 cockpit hero-card + the AppBar.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/logic/manager_copilot.dart';
import 'package:buildsmart/logic/manager_dashboard.dart' show kManagerOrderFlow;
import 'package:buildsmart/state/orders_engine.dart'
    show managerAnalyticsProvider, managerCustomersProvider, ordersEngineProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/ai_result_states.dart' show AiOffState;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One chat turn — the owner's question or the co-pilot's answer.
typedef _CopTurn = ({bool user, String text});

class ManagerCopilotScreen extends ConsumerStatefulWidget {
  const ManagerCopilotScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ManagerCopilotScreen());

  @override
  ConsumerState<ManagerCopilotScreen> createState() => _ManagerCopilotState();
}

class _ManagerCopilotState extends ConsumerState<ManagerCopilotScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_CopTurn> _turns = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Fold the LIVE engine state into the grounded snapshot (read at ask-time).
  String _liveContext() {
    final orders = ref.read(ordersEngineProvider);
    final stageCounts = <String, int>{
      for (final s in kManagerOrderFlow)
        s: orders.where((o) => o.stage == s).length,
    };
    return buildManagerContext(
      analytics: ref.read(managerAnalyticsProvider),
      customers: ref.read(managerCustomersProvider),
      stageCounts: stageCounts,
    );
  }

  Future<void> _run(String userLabel, String prompt, {int maxTokens = 420}) async {
    final gw = ref.read(claudeGatewayProvider);
    if (gw == null || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _turns.add((user: true, text: userLabel));
      _loading = true;
    });
    _scrollToEnd();
    try {
      final r = await gw.ask(
        prompt: prompt,
        system: managerCopilotSystem,
        maxTokens: maxTokens,
      );
      if (!mounted) return;
      final text = r.text.trim();
      setState(() {
        _turns.add((
          user: false,
          text: text.isEmpty ? 'לא הצלחתי לנסח תשובה — נסה לשאול אחרת.' : text,
        ));
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _turns.add((user: false, text: 'משהו השתבש בחיבור — נסה שוב עוד רגע.'));
        _loading = false;
      });
    }
    _scrollToEnd();
  }

  void _ask(String question) {
    final q = question.trim();
    if (q.isEmpty) return;
    _controller.clear();
    _run(q, managerCopilotPrompt(_liveContext(), q));
  }

  // Brief = 3-4 Hebrew bullets; Hebrew tokenizes ~2-4× worse, so give it more room
  // than a Q&A answer to avoid mid-sentence truncation (still ≪ the 2048 server cap).
  void _morningBrief() => _run(
      '☀️ תדריך-בוקר', managerMorningBriefPrompt(_liveContext()),
      maxTokens: 600);

  void _scrollToEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut);
        }
      });

  @override
  Widget build(BuildContext context) {
    final aiAvailable = ref.watch(claudeGatewayProvider) != null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🤖 קו-פיילוט',
                  style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
              Text('שאל את העסק שלך',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
            ],
          ),
        ),
        body: !aiAvailable
            ? const Padding(
                padding: EdgeInsets.all(BsTokens.space5),
                child: Center(
                    child: AiOffState(
                        '💡 הקו-פיילוט החכם דורש חיבור לשרת.')),
              )
            : Column(
                children: [
                  Expanded(
                    child: _turns.isEmpty
                        ? _Welcome(onAsk: _ask, onBrief: _morningBrief)
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.all(BsTokens.space4),
                            itemCount: _turns.length + (_loading ? 1 : 0),
                            itemBuilder: (_, i) {
                              if (i >= _turns.length) return const _Typing();
                              return _Bubble(turn: _turns[i]);
                            },
                          ),
                  ),
                  _InputBar(
                    controller: _controller,
                    enabled: !_loading,
                    onSend: () => _ask(_controller.text),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Empty-state: greeting + the one-tap morning brief + suggestion chips.
class _Welcome extends StatelessWidget {
  const _Welcome({required this.onAsk, required this.onBrief});
  final void Function(String) onAsk;
  final VoidCallback onBrief;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(BsTokens.space4),
      children: [
        const SizedBox(height: BsTokens.space4),
        const Text('🤖', style: TextStyle(fontSize: 44), textAlign: TextAlign.center),
        const SizedBox(height: BsTokens.space3),
        const Text('שאל אותי כל דבר על העסק שלך.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('אני קורא את ההזמנות, הלקוחות והאשראי החיים שלך ועונה מהמספרים האמיתיים.',
            textAlign: TextAlign.center,
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
        const SizedBox(height: BsTokens.space4),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onBrief,
            icon: const Text('☀️'),
            label: const Text('תדריך-בוקר'),
          ),
        ),
        const SizedBox(height: BsTokens.space4),
        const Text('או שאל:',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
        const SizedBox(height: BsTokens.space2),
        Wrap(
          spacing: BsTokens.space2,
          runSpacing: BsTokens.space2,
          children: [
            for (final q in kManagerCopilotSuggestions)
              ActionChip(
                label: Text(q),
                onPressed: () => onAsk(q),
                backgroundColor: BsTokens.cardLight,
                labelStyle: const TextStyle(
                    color: BsTokens.inkLight, fontSize: 13),
              ),
          ],
        ),
      ],
    );
  }
}

/// A single chat bubble — owner (brand, right) vs co-pilot (card, left).
class _Bubble extends StatelessWidget {
  const _Bubble({required this.turn});
  final _CopTurn turn;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: turn.user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: BsTokens.space3),
        padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space4, vertical: BsTokens.space3),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: turn.user ? BsTokens.brand : BsTokens.cardLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        ),
        // Dark ink on BOTH bubbles — white-on-brand was ~2.7:1 (fails WCAG AA);
        // dark-on-brand is ~6:1 and keeps the brand-colored owner bubble.
        child: Text(turn.text,
            style: const TextStyle(
                color: BsTokens.inkLight, fontSize: 14, height: 1.5)),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();
  @override
  Widget build(BuildContext context) => const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(bottom: BsTokens.space3, right: BsTokens.space3),
          child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4)),
        ),
      );
}

class _InputBar extends StatelessWidget {
  const _InputBar(
      {required this.controller, required this.enabled, required this.onSend});
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space3),
        decoration: const BoxDecoration(
          color: BsTokens.cardLight,
          border: Border(top: BorderSide(color: BsTokens.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'שאל את העסק שלך…',
                  filled: true,
                  fillColor: BsTokens.bgLight,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: BsTokens.space4, vertical: BsTokens.space3),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            IconButton.filled(
              tooltip: 'שלח', // a11y: screen-reader label for the send button
              onPressed: enabled ? onSend : null,
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
