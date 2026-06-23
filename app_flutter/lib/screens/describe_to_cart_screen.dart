// ─────────────────────────────────────────────────────────────────────────────
// DescribeToCartScreen — "תאר תקלה → סל" (#ai-describe-to-cart). The first truly
// AI-NATIVE feature: the contractor describes a job/problem in free Hebrew
// ("יש לי נזילה מתחת לכיור" / "מתקין דוד שמש") and gets a ready parts kit.
//
// ANTI-HALLUCINATION DESIGN (the load-bearing choice): Claude is constrained to a
// CLOSED SET — it must return the `key` of ONE recipe from `kSmartProducts`, or
// NONE. It can NOT emit a product name. The cart is then assembled DETERMINISTICALLY
// by `assembleKit(recipe)` (recipe_kit.dart) — every line is bound to a REAL catalog
// product (or honestly flagged unresolved). So the model only CLASSIFIES the
// request into a known job; it never invents a part. `matchRecipe` validates the
// reply against the real key set and drops anything outside it.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state; the demo/test build is unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/data/smart_tree.dart' show SmartProduct, kSmartProducts;
import 'package:buildsmart/features/word_finder/recipe_kit.dart'
    show KitMatch, assembleKit;
import 'package:buildsmart/logic/prompt_sanitize.dart';
import 'package:buildsmart/state/smart_cart.dart'
    show SmartCartLine, smartCartProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The grounded prompt — hands the model the CLOSED recipe set (`key = name`) and
/// demands it return ONLY a key (or NONE). It can't name a product.
String describeToCartPrompt(String userText) {
  final list = kSmartProducts.map((r) => '${r.key} = ${r.name}').join('\n');
  final safe = promptSafeText(userText, maxLen: 600); // cap free-text (cost/DoS)
  return 'רשימת-העבודות הזמינות (key = שם):\n$list\n\n'
      'בקשת הקבלן: "$safe".\n'
      'בחר את ה-key של העבודה האחת שהכי מתאימה לבקשה — מתוך הרשימה בלבד. '
      'החזר אך ורק את ה-key (שורה אחת, ללא טקסט נוסף). '
      'אם שום עבודה ברשימה לא מתאימה, החזר NONE.';
}

const String _kSystem =
    'אתה ממפה בקשת אינסטלטור לעבודה אחת מרשימה סגורה. החזר אך ורק key מהרשימה '
    'שניתנה, או NONE. לעולם אל תמציא key ואל תכתוב שם-מוצר.';

/// Resolve Claude's reply to a real recipe — exact-key first, then a contained
/// key (the model may wrap it). Returns null when the reply names no real key
/// (NONE / hallucinated) — the closed-set guard.
SmartProduct? matchRecipe(String aiReply) {
  final resp = aiReply.trim();
  if (resp.isEmpty) return null;
  for (final r in kSmartProducts) {
    if (resp == r.key) return r;
  }
  // Contained-key fallback (the model may wrap the key in quotes/prose). Pick the
  // LONGEST containing key — many keys are prefixes of others (faucet⊂kitchenFaucet,
  // basin⊂basinTrap), and first-match would grab the short prefix → the wrong kit.
  SmartProduct? best;
  for (final r in kSmartProducts) {
    if (resp.contains(r.key) &&
        (best == null || r.key.length > best.key.length)) {
      best = r;
    }
  }
  return best;
}

/// The REAL products the recipe resolves to (bound lines only — never invented).
List<LipskeyCatalogProduct> resolvedKitProducts(SmartProduct recipe) => [
      for (final line in assembleKit(recipe))
        if (line.product != null && line.match != KitMatch.none) line.product!,
    ];

class DescribeToCartScreen extends ConsumerStatefulWidget {
  const DescribeToCartScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const DescribeToCartScreen());

  @override
  ConsumerState<DescribeToCartScreen> createState() => _DescribeToCartState();
}

class _DescribeToCartState extends ConsumerState<DescribeToCartScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  bool _failed = false;
  SmartProduct? _recipe;
  List<LipskeyCatalogProduct> _products = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    final gw = ref.read(claudeGatewayProvider);
    final text = _controller.text.trim();
    // `|| _loading` closes a stale-response race: onSubmitted bypasses the button's
    // loading-disable, so a re-submit mid-flight would fire a 2nd concurrent ask
    // whose late reply could overwrite the newer query's result.
    if (gw == null || text.isEmpty || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _failed = false;
      _recipe = null;
      _products = const [];
    });
    try {
      final r = await gw.ask(
        prompt: describeToCartPrompt(text),
        system: _kSystem,
        maxTokens: 32,
      );
      final recipe = matchRecipe(r.text); // closed-set validation
      if (mounted) {
        setState(() {
          _recipe = recipe;
          _products = recipe == null ? const [] : resolvedKitProducts(recipe);
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

  void _addToCart() {
    final notifier = ref.read(smartCartProvider.notifier);
    for (final p in _products) {
      notifier.add(SmartCartLine(
        productKey: 'lip:${p.sku}',
        productName: p.nameHe,
        productEmoji: p.typeEmoji,
        brandName: p.brand,
        brandPrice: 0,
        productQty: 1,
        accessories: const [],
      ));
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('נוספו ${_products.length} פריטים לסל ✓'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
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
          title: const Text('🗣️ תאר עבודה → סל',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            if (!aiAvailable)
              const Text('💡 הפיצ\'ר דורש חיבור לשרת.',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13))
            else ...[
              const Text('ספר במילים שלך מה אתה צריך:',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                maxLines: 2,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _find(),
                decoration: InputDecoration(
                  hintText: 'לדוגמה: יש לי נזילה מתחת לכיור במטבח',
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
                  onPressed: _loading ? null : _find,
                  icon: const Text('🔎'),
                  label: const Text('מצא לי את הסל'),
                ),
              ),
              const SizedBox(height: BsTokens.space4),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_failed)
                const Text('משהו השתבש — נסה שוב.',
                    style: TextStyle(color: BsTokens.danger, fontSize: 14))
              else if (_recipe != null) ...[
                Text('✓ ${_recipe!.name}',
                    style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: BsTokens.space2),
                if (_products.isEmpty)
                  const Text('זוהתה העבודה, אך לחלקיה עדיין אין מק"ט מקושר.',
                      style:
                          TextStyle(color: BsTokens.mutedLight, fontSize: 13))
                else ...[
                  for (final p in _products)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• ${p.nameHe}',
                          style: const TextStyle(
                              color: BsTokens.inkLight, fontSize: 14)),
                    ),
                  const SizedBox(height: BsTokens.space3),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: BsTokens.brand),
                      onPressed: _addToCart,
                      icon: const Icon(Icons.shopping_cart, size: 19),
                      label: Text('הוסף ${_products.length} לסל'),
                    ),
                  ),
                ],
              ] else if (_controller.text.trim().isNotEmpty)
                const Text('לא זוהתה עבודה מתאימה — נסה לתאר אחרת.',
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }
}
