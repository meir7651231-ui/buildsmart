// ─────────────────────────────────────────────────────────────────────────────
// AiFinderScreen — "תאר → מצא" (#ai-finder): the AI upgrade of the "מאתר חכם".
// Instead of tapping words to narrow, the contractor describes what they need in
// free Hebrew ("ברז למטבח חם" / "חיבור לצינור ביוב") and Claude narrows the
// catalog to the right category, then shows those products.
//
// ANTI-HALLUCINATION (closed set): Claude is constrained to return ONE real
// catalog CATEGORY (`categoryHe`) — or NONE. It cannot name a product or invent a
// category. `matchCategory` validates the reply against the real category set and
// drops anything outside it; the products shown come straight from
// `kCatalogProducts.where(categoryHe == …)` — always real, never invented.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state; the demo/test build is unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The distinct catalog categories — the CLOSED set the model must pick from.
List<String> finderCategories() {
  final set = <String>{for (final p in kCatalogProducts) p.categoryHe};
  return set.toList()..sort();
}

/// The grounded prompt — hands the model the closed category set and the request,
/// and demands ONLY a category (or NONE). It can't name a product.
String aiFinderPrompt(String userText) {
  final cats = finderCategories().join('\n');
  return 'קטגוריות-המוצרים הזמינות:\n$cats\n\n'
      'הקבלן מחפש: "$userText".\n'
      'בחר את הקטגוריה האחת שהכי מתאימה לבקשה — מתוך הרשימה בלבד. '
      'החזר אך ורק את שם-הקטגוריה (שורה אחת, ללא טקסט נוסף). '
      'אם אף קטגוריה ברשימה לא מתאימה, החזר NONE.';
}

const String _kSystem =
    'אתה ממפה בקשת אינסטלטור לקטגוריית-מוצרים אחת מרשימה סגורה. החזר אך ורק '
    'שם-קטגוריה מהרשימה שניתנה, או NONE. לעולם אל תמציא קטגוריה ואל תכתוב שם-מוצר.';

/// Resolve Claude's reply to a real category — exact first, then contained.
/// Returns null when the reply names no real category (NONE / invented).
String? matchCategory(String aiReply) {
  final r = aiReply.trim();
  if (r.isEmpty) return null;
  final cats = finderCategories();
  for (final c in cats) {
    if (r == c) return c;
  }
  for (final c in cats) {
    if (r.contains(c)) return c;
  }
  return null;
}

/// The REAL products in [cat] (never invented).
List<LipskeyCatalogProduct> productsInCategory(String cat) =>
    kCatalogProducts.where((p) => p.categoryHe == cat).toList();

class AiFinderScreen extends ConsumerStatefulWidget {
  const AiFinderScreen({super.key, this.initialQuery});

  /// Pre-filled free-text (e.g. from a catalog search that found nothing) — the
  /// screen auto-runs the search on open so an empty catalog result flows
  /// straight into the AI finder.
  final String? initialQuery;

  static Route<void> route({String? initialQuery}) => MaterialPageRoute<void>(
      builder: (_) => AiFinderScreen(initialQuery: initialQuery));

  @override
  ConsumerState<AiFinderScreen> createState() => _AiFinderState();
}

class _AiFinderState extends ConsumerState<AiFinderScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  bool _failed = false;
  bool _searched = false;
  String? _category;
  List<LipskeyCatalogProduct> _products = const [];

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery?.trim() ?? '';
    if (q.isNotEmpty) {
      _controller.text = q;
      // Auto-search the pre-filled query once mounted (the gateway is read in
      // _search; a no-AI build just no-ops and shows the "requires connection").
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final gw = ref.read(claudeGatewayProvider);
    final text = _controller.text.trim();
    if (gw == null || text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _failed = false;
      _searched = true;
      _category = null;
      _products = const [];
    });
    try {
      final r = await gw.ask(
        prompt: aiFinderPrompt(text),
        system: _kSystem,
        maxTokens: 48,
      );
      final cat = matchCategory(r.text); // closed-set validation
      if (mounted) {
        setState(() {
          _category = cat;
          _products = cat == null ? const [] : productsInCategory(cat);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _failed = true;
        _loading = false;
      });
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
          title: const Text('🗣️ חיפוש חכם',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            if (!aiAvailable)
              const Text('💡 החיפוש החכם דורש חיבור לשרת.',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13))
            else ...[
              const Text('תאר במילים שלך מה אתה מחפש:',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'לדוגמה: ברז למטבח / חיבור לצינור ביוב',
                  filled: true,
                  fillColor: BsTokens.cardLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BsTokens.radiusCard)),
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _search,
                  icon: const Text('🔎'),
                  label: const Text('מצא לי'),
                ),
              ),
              const SizedBox(height: BsTokens.space4),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_failed)
                const Text('משהו השתבש — נסה שוב.',
                    style: TextStyle(color: BsTokens.danger, fontSize: 14))
              else if (_category != null) ...[
                Text('📂 ${_category!}  ·  ${_products.length} מוצרים',
                    style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: BsTokens.space2),
                for (final p in _products)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.nameHe,
                        style: const TextStyle(
                            color: BsTokens.inkLight, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_left, size: 18),
                    onTap: () => showLipskeyProductSheet(
                        context, p, productsInCategory(_category!)),
                  ),
              ] else if (_searched)
                const Text('לא זוהתה קטגוריה מתאימה — נסה לתאר אחרת.',
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }
}
