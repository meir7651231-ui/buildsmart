// ─────────────────────────────────────────────────────────────────────────────
// CreditExplainScreen — "💳 הסבר אשראי" (#ai-credit-explain): the AI explainer on
// the manager's customer credit. The figures — credit limit, used, balance,
// utilisation % — are all deterministic (mgrCustomerList / contractorCredit /
// computeCredit over the live orders engine); Claude only EXPLAINS what the
// utilisation means for approving the next order. The numbers are the engine's;
// the model never invents one.
//
// ANTI-HALLUCINATION (grounded — explain-only): the prompt HANDS Claude the real
// limit/used/balance/% and FORBIDS inventing or changing any number. A credit
// call is a money decision, so the discipline is strict.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state; the demo/test build is unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/logic/prompt_sanitize.dart' show promptSafeText;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/ai_result_states.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The grounded prompt — hands the model the REAL credit figures and asks ONLY
/// for a short read on the utilisation; every number must be used as-is.
///
/// A ZERO LIMIT MEANS "NOT ON RECORD", AND THE PROMPT MUST SAY SO. The instruction
/// below is "use only the numbers you were given — invent nothing", and it works:
/// the model faithfully explains whatever ceiling it is handed. That is precisely
/// why handing it a placeholder was dangerous — the ceiling used to fall back to a
/// hash of the customer's name, and the model would then reason confidently about
/// whether that contractor was "close to the ceiling" and advise on approving the
/// next order. An honest model grounded on a fabricated number produces a
/// fabricated recommendation, stated with all the authority of a real one. So when
/// there is no ceiling, the utilisation question is not asked at all.
String creditExplainPrompt({
  required String name,
  required int creditLimit,
  required int used,
  required int balance,
  required int pct,
}) {
  // Sanitize the customer name: it derives from `Order.who` — contractor-typed
  // free-text with no newline/length guard at the source — so collapse newlines
  // + cap to defang an "ignore the above / new system:" injection. Same lever
  // already guarded for the SAME field in manager_copilot.dart (was raw here).
  final who = promptSafeText(name, maxLen: 40, collapseWhitespace: true);
  if (creditLimit <= 0) {
    return 'לקוח: "$who".\n'
        'לא רשומה עבורו מסגרת-אשראי במערכת. הסכום שנוצל בפועל: ₪$used.\n\n'
        'כתוב למנהל 2–3 משפטים בעברית. פתח בכך שאין מסגרת-אשראי רשומה ולכן '
        'אי-אפשר לומר כמה מהמסגרת נוצל. אל תעריך, אל תשער ואל תרמוז מהי המסגרת, '
        'ואל תמליץ אם לאשר הזמנה. השתמש אך ורק במספר שניתן לך.';
  }
  return 'לקוח: "$who".\n'
      'מסגרת-אשראי: ₪$creditLimit · נוצל: ₪$used · יתרה: ₪$balance · '
      'ניצול: $pct%.\n\n'
      'הסבר למנהל ב-2–3 משפטים בעברית מה המשמעות של ניצול-האשראי הזה — האם הלקוח '
      'קרוב לתקרה או פנוי, ומה כדאי לשקול לפני אישור הזמנה נוספת. השתמש אך ורק '
      'במספרים שניתנו לך — אל תמציא, תשנה או תוסיף שום מספר.';
}

const String _kSystem =
    'אתה יועץ-אשראי מנוסה למנהל-רכש. אתה מסביר בקצרה ובכנות מה משמעות ניצול-האשראי '
    'של לקוח. השתמש אך ורק במספרים שניתנו לך; לעולם אל תמציא, תשנה או תוסיף מספר.';

class CreditExplainScreen extends ConsumerStatefulWidget {
  const CreditExplainScreen({
    super.key,
    required this.name,
    required this.creditLimit,
    required this.used,
    required this.balance,
    required this.pct,
  });

  final String name;
  final int creditLimit;
  final int used;
  final int balance;
  final int pct;

  static Route<void> route({
    required String name,
    required int creditLimit,
    required int used,
    required int balance,
    required int pct,
  }) =>
      MaterialPageRoute<void>(
        builder: (_) => CreditExplainScreen(
          name: name,
          creditLimit: creditLimit,
          used: used,
          balance: balance,
          pct: pct,
        ),
      );

  @override
  ConsumerState<CreditExplainScreen> createState() => _CreditExplainState();
}

class _CreditExplainState extends ConsumerState<CreditExplainScreen> {
  bool _loading = false;
  bool _failed = false;
  String? _explanation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _explain());
  }

  Future<void> _explain() async {
    final gw = ref.read(claudeGatewayProvider);
    if (gw == null) return;
    setState(() {
      _loading = true;
      _failed = false;
      _explanation = null;
    });
    try {
      final r = await gw.ask(
        prompt: creditExplainPrompt(
          name: widget.name,
          creditLimit: widget.creditLimit,
          used: widget.used,
          balance: widget.balance,
          pct: widget.pct,
        ),
        system: _kSystem,
        maxTokens: 300,
      );
      if (mounted) {
        setState(() {
          final reply = r.text.trim();
          if (reply.isEmpty) {
            _failed = true; // 200-empty → honest retry, not a blank box
          } else {
            _explanation = reply;
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
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          title: const CfgText('credit_explain_screen.title', '💳 הסבר אשראי',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            // ── The REAL credit figures (data, never the model). ──
            Text(widget.name,
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: BsTokens.space2),
            // No ceiling on record → say that, rather than print "₪0". A zero
            // shekel figure reads as an approved limit of nothing, which is a
            // different (and equally wrong) claim from "we do not know it". The
            // spend stays: it is folded from this contractor's own orders and is
            // the one figure here that was never in doubt.
            if (widget.creditLimit <= 0) ...[
              _row('מסגרת', 'לא רשומה'),
              _row('נוצל', '₪${widget.used}'),
              _row('יתרה', '—'),
              _row('ניצול', '—'),
            ] else ...[
              _row('מסגרת', '₪${widget.creditLimit}'),
              _row('נוצל', '₪${widget.used}'),
              _row('יתרה', '₪${widget.balance}'),
              _row('ניצול', '${widget.pct}%'),
            ],
            const Divider(height: BsTokens.space5, color: BsTokens.divider),

            if (!aiAvailable)
              const AiOffState('💡 ההסבר החכם דורש חיבור לשרת.')
            else if (_loading)
              const AiLoadingState()
            else if (_failed)
              AiFailedState(onRetry: _explain)
            else if (_explanation != null)
              Text(_explanation!,
                  style: const TextStyle(
                      color: BsTokens.inkLight, fontSize: 15, height: 1.6)),
            const SizedBox(height: BsTokens.space4),
            const CfgText('credit_explain_screen.note',
                '⚙️ המספרים מנתוני-המערכת; ה-AI רק מסביר אותם.',
                style: TextStyle(fontSize: 11, color: BsTokens.mutedDark)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: BsTokens.mutedLight, fontSize: 13)),
            ),
            Text(value,
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
