// ─────────────────────────────────────────────────────────────────────────────
// BusinessSummaryScreen — "✨ סיכום עסקי" (#ai-business-summary): turns the
// deterministic `computeAnalyticsInsights` rows (order count + spend, average,
// open/delivered, possible savings, budget utilization — every number folded from
// the live orders engine + budget + the real cheaper-alternatives scan) into a
// short, flowing Hebrew business check-in the owner reads in seconds. The numbers
// are the engine's; Claude only NARRATES them.
//
// ANTI-HALLUCINATION (grounded — narrate-only): the prompt HANDS Claude the
// computed insight lines and FORBIDS inventing, changing, or adding any number; it
// may only weave the given figures into prose. A business summary that invents a
// number is worse than useless, so the discipline is strict.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state; the demo/test build is unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/ai_result_states.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The grounded prompt — hands the model the REAL computed insight lines and asks
/// ONLY for a short narration; every number must be used as-is, none invented.
String businessSummaryPrompt(List<String> insightLines) {
  return 'תובנות-העסק שחושבו מהנתונים האמיתיים:\n${insightLines.join('\n')}\n\n'
      'נסח מהן סיכום-עסקי קצר וזורם בעברית (2–4 משפטים) — מצב ההזמנות, הכסף, '
      'החיסכון-האפשרי והתקציב, ומה כדאי לשים לב אליו. השתמש אך ורק במספרים '
      'שניתנו לך — אל תמציא, תשנה או תוסיף שום מספר.';
}

const String _kSystem =
    'אתה יועץ-עסקי מנוסה לאינסטלטור. אתה מנסח סיכום-עסקי קצר וברור מתובנות שכבר '
    'חושבו. השתמש אך ורק במספרים שניתנו לך; לעולם אל תמציא, תשנה או תוסיף מספר.';

class BusinessSummaryScreen extends ConsumerStatefulWidget {
  const BusinessSummaryScreen({super.key, required this.insightLines});

  /// Pre-formatted REAL insight lines (e.g. "📦 6 הזמנות · ₪48,000 סה״כ רכש").
  final List<String> insightLines;

  static Route<void> route({required List<String> insightLines}) =>
      MaterialPageRoute<void>(
        builder: (_) => BusinessSummaryScreen(insightLines: insightLines),
      );

  @override
  ConsumerState<BusinessSummaryScreen> createState() =>
      _BusinessSummaryState();
}

class _BusinessSummaryState extends ConsumerState<BusinessSummaryScreen> {
  bool _loading = false;
  bool _failed = false;
  String? _summary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _summarize());
  }

  Future<void> _summarize() async {
    final gw = ref.read(claudeGatewayProvider);
    if (gw == null || widget.insightLines.isEmpty) return;
    setState(() {
      _loading = true;
      _failed = false;
      _summary = null;
    });
    try {
      final r = await gw.ask(
        prompt: businessSummaryPrompt(widget.insightLines),
        system: _kSystem,
        maxTokens: 400,
      );
      if (mounted) {
        setState(() {
          final reply = r.text.trim();
          if (reply.isEmpty) {
            _failed = true; // 200-empty → honest retry, not a blank box
          } else {
            _summary = reply;
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiAvailable = ref.watch(claudeGatewayProvider) != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: const CfgText('business_summary_screen.t01', '✨ סיכום עסקי',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            // ── The REAL computed insights (data, never the model). ──
            const CfgText('business_summary_screen.t02', 'התובנות שחושבו:',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
            const SizedBox(height: 6),
            for (final line in widget.insightLines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $line',
                    style: const TextStyle(
                        color: BsTokens.inkLight, fontSize: 13)),
              ),
            const Divider(height: BsTokens.space5, color: BsTokens.divider),

            // ── Claude's narration. ──
            if (!aiAvailable)
              const AiOffState('💡 הסיכום החכם דורש חיבור לשרת.')
            else if (_loading)
              const AiLoadingState()
            else if (_failed)
              AiFailedState(onRetry: _summarize)
            else if (_summary != null)
              Text(_summary!,
                  style: const TextStyle(
                      color: BsTokens.inkLight, fontSize: 15, height: 1.6)),
            const SizedBox(height: BsTokens.space4),
            const CfgText('business_summary_screen.t03', '⚙️ המספרים מנתוני-המערכת; ה-AI רק מנסח אותם לסיכום.',
                style: TextStyle(fontSize: 11, color: BsTokens.mutedDark)),
          ],
        ),
      ),
    );
  }
}
