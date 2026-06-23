// ─────────────────────────────────────────────────────────────────────────────
// PairedExplainScreen — "מה עוד צריך להתקנה?" (#ai-paired-explain): the AI nudge
// on top of the deterministic `frequentlyPairedTypesFor(p)` engine. That engine
// already derives — from the REAL compatibility graph — the product-TYPES most
// often installed alongside this product. Claude only explains, in plain Hebrew,
// why each type completes the job and what not to forget, so the contractor
// doesn't make a second trip to the store for a missing fitting.
//
// ANTI-HALLUCINATION (grounded, type-level): the prompt HANDS Claude the real
// product name + the real paired TYPE list, and constrains it to reason at the
// TYPE level only — it is FORBIDDEN to invent product names, SKUs, or prices.
// The types on screen are the engine's; Claude never adds to the list.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state; the demo/test build is unchanged.
// The caller only renders the entry button when the gateway is live.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/ai_result_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The grounded prompt — hands the model the REAL product + the REAL paired-type
/// list, and asks ONLY for a short why-each + don't-forget; type-level only.
String pairedExplainPrompt({
  required String product,
  required List<String> types,
}) {
  final list = types.map((t) => '• $t').join('\n');
  return 'המוצר: "$product".\n'
      'לפי נתוני-הקטלוג, הוא מותקן לרוב יחד עם סוגי-המוצרים האלה:\n$list\n\n'
      'הסבר לאינסטלטור, במשפט קצר לכל סוג, למה הוא נחוץ להתקנה של "$product", '
      'וסיים בשורת "אל תשכח" קצרה. דבר ברמת סוג-המוצר בלבד — אל תמציא שמות-מוצר, '
      'מק"טים או מחירים, ואל תוסיף סוגים שלא ברשימה.';
}

const String _kSystem =
    'אתה אינסטלטור-מנטור. אתה מסביר בקצרה למה אביזרים משלימים נחוצים להתקנה, '
    'ברמת סוג-המוצר בלבד. לעולם אל תמציא שם-מוצר, מק"ט או מחיר, ואל תוסיף פריטים '
    'מעבר לרשימה שניתנה לך.';

class PairedExplainScreen extends ConsumerStatefulWidget {
  const PairedExplainScreen({
    super.key,
    required this.product,
    required this.types,
  });

  final String product;
  final List<String> types;

  static Route<void> route({
    required String product,
    required List<String> types,
  }) =>
      MaterialPageRoute<void>(
        builder: (_) => PairedExplainScreen(product: product, types: types),
      );

  @override
  ConsumerState<PairedExplainScreen> createState() => _PairedExplainState();
}

class _PairedExplainState extends ConsumerState<PairedExplainScreen> {
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
    if (gw == null || widget.types.isEmpty) return;
    setState(() {
      _loading = true;
      _failed = false;
      _explanation = null;
    });
    try {
      final r = await gw.ask(
        prompt:
            pairedExplainPrompt(product: widget.product, types: widget.types),
        system: _kSystem,
        maxTokens: 320,
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
          title: const Text('🧩 מה עוד צריך?',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            // ── The product + the REAL paired types (data, never the model). ──
            Text(widget.product,
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: BsTokens.space2),
            const Text('מותקן לרוב יחד עם:',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in widget.types)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(t,
                        style: const TextStyle(
                            color: Color(0xFF6D28D9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const Divider(height: BsTokens.space5, color: BsTokens.divider),

            // ── Claude's why-each + don't-forget. ──
            if (!aiAvailable)
              const AiOffState('💡 ההסבר החכם דורש חיבור לשרת.')
            else if (_loading)
              const AiLoadingState()
            else if (_failed)
              AiFailedState(onRetry: _explain)
            else if (_explanation != null)
              Text(_explanation!,
                  style: const TextStyle(
                      color: BsTokens.inkLight, fontSize: 15, height: 1.5)),
            const SizedBox(height: BsTokens.space4),
            const Text('⚙️ הרשימה מנתוני-הקטלוג; ה-AI רק מסביר למה כל אביזר נחוץ.',
                style: TextStyle(fontSize: 11, color: BsTokens.mutedDark)),
          ],
        ),
      ),
    );
  }
}
