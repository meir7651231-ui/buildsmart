// ─────────────────────────────────────────────────────────────────────────────
// AdapterExplainScreen — "🔌 איך לגשר?" (#ai-adapter-explain): the AI explainer
// on top of the deterministic connection-warning engine. When `connectionWarningHe`
// flags that a spec'd part has NO direct mate in the catalog (it will need an
// adapter), Claude explains — over the part's REAL verified ends + material — why
// those ends don't mate to a standard connection and what TYPE of adapter bridges
// the gap, so the contractor knows what to look for.
//
// ANTI-HALLUCINATION (grounded, type-level): the prompt HANDS Claude the REAL
// connection ends (from `kVerifiedSpecs[sku].ends`, labelled in Hebrew) + the real
// material, and constrains it to reason at the ADAPTER-TYPE level only — FORBIDDEN
// to invent a product name, SKU, or price. The ends shown on screen are the spec's.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state; the demo/test build is unchanged.
// The caller only renders the entry button when the gateway is live.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/company_spec_bridge.dart'
    show kCompanySpecSkus;
import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show EndType, kVerifiedSpecs;
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/ai_result_states.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A plain-Hebrew label for a connection-end type — so the model (and the screen)
/// describe the REAL end, never an invented one.
String endTypeHe(EndType t) {
  switch (t) {
    case EndType.hdpeCompression:
      return 'מצמד קומפרסיה HDPE';
    case EndType.pexPress:
      return 'פרס PEX';
    case EndType.copperPress:
      return 'פרס נחושת';
    case EndType.bspMale:
      return 'תבריג חיצוני BSP';
    case EndType.bspFemale:
      return 'תבריג פנימי BSP';
    case EndType.drainOpening:
      return 'פתח ניקוז';
  }
}

/// True when [sku]'s spec was bridged from a company import (kCompanySpecSkus)
/// rather than hand-verified — the wording must then say so, not claim verified.
bool _isCompanySpec(String sku) => kCompanySpecSkus.contains(sku);

/// The grounded prompt — hands the model the REAL ends + material and asks ONLY
/// for a type-level "why + which adapter"; it may not invent a product.
/// [sku] routes the provenance wording (import-bridged vs hand-verified).
String adapterExplainPrompt({
  required String product,
  required List<String> ends,
  required String material,
  String sku = '',
}) {
  final endList = ends.join(', ');
  final source = _isCompanySpec(sku) ? 'מנתוני היבוא' : 'מנתוני-המפרט-המאומת';
  return 'החלק: "$product".\n'
      'הקצוות שלו ($source): $endList.\n'
      'חומר: $material.\n'
      'אין לו חיבור ישיר תואם בקטלוג — צריך מתאם.\n\n'
      'הסבר לאינסטלטור בקצרה: (1) למה הקצוות האלה לא מתחברים ישירות לחיבור-תקני '
      'נפוץ, (2) איזה סוג-מתאם מגשר. דבר ברמת סוג-המתאם בלבד — אל תמציא שם-מוצר, '
      'מק"ט או מחיר.';
}

const String _kSystem =
    'אתה אינסטלטור-מומחה לחיבורים. אתה מסביר ברמת סוג-המתאם בלבד למה קצוות-חיבור '
    'לא מתחברים ומה מגשר ביניהם. לעולם אל תמציא שם-מוצר, מק"ט או מחיר.';

class AdapterExplainScreen extends ConsumerStatefulWidget {
  const AdapterExplainScreen({
    super.key,
    required this.productName,
    required this.sku,
  });

  final String productName;
  final String sku;

  static Route<void> route({
    required String productName,
    required String sku,
  }) =>
      MaterialPageRoute<void>(
        builder: (_) =>
            AdapterExplainScreen(productName: productName, sku: sku),
      );

  @override
  ConsumerState<AdapterExplainScreen> createState() => _AdapterExplainState();
}

class _AdapterExplainState extends ConsumerState<AdapterExplainScreen> {
  bool _loading = false;
  bool _failed = false;
  String? _explanation;

  /// The REAL ends of this part, labelled (from the verified spec) — the data
  /// shown on screen AND fed to the model. Empty when the sku carries no spec.
  List<String> get _ends {
    final spec = kVerifiedSpecs[widget.sku];
    if (spec == null) return const [];
    return [for (final e in spec.ends) '${endTypeHe(e.type)} ${e.size}'];
  }

  String get _material => kVerifiedSpecs[widget.sku]?.material ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _explain());
  }

  Future<void> _explain() async {
    final gw = ref.read(claudeGatewayProvider);
    final ends = _ends;
    if (gw == null || ends.isEmpty) return;
    setState(() {
      _loading = true;
      _failed = false;
      _explanation = null;
    });
    try {
      final r = await gw.ask(
        prompt: adapterExplainPrompt(
            product: widget.productName,
            ends: ends,
            material: _material,
            sku: widget.sku),
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
    final ends = _ends;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          title: const CfgText('adapter_explain_screen.t01', '🔌 איך לגשר?',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            // ── The part + its REAL ends (data, never the model). ──
            Text(widget.productName,
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: BsTokens.space2),
            const CfgText('adapter_explain_screen.t02', 'הקצוות שלו:',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final e in ends)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(e,
                        style: const TextStyle(
                            color: BsTokens.dangerDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const Divider(height: BsTokens.space5, color: BsTokens.divider),

            // ── Claude's why + which-adapter. ──
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
            const CfgText('adapter_explain_screen.t03', '⚙️ הקצוות מנתוני-המפרט; ה-AI רק מסביר איזה סוג-מתאם מגשר.',
                style: TextStyle(fontSize: 11, color: BsTokens.mutedDark)),
          ],
        ),
      ),
    );
  }
}
