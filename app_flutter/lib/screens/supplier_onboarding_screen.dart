// C4.1 — the SUPPLIER SELF-ONBOARDING screen (SPEC-catalog-to-server).
//
// A store/supplier fills a product's fields + its price/stock and submits; the C4.2-4.4
// pipeline (supplier_onboarding.dart) validates the draft, auto-SUGGESTS facets from the
// name (C4.3, reusing the catalog's own getters), and — at go-live — writes the two docs
// a submit produces: the catalog product (`catalogProducts`) AND its store inventory row
// (`inventory`, where price/stock live — R1-6). This screen only COLLECTS a valid
// [SupplierDraft] and hands it to [supplierSubmitProvider]; the doc-building + Firestore
// write is that seam's job, wired at go-live and overridden by a fake in tests.
//
// GATING: reached ONLY from the manager screens sheet's tile, itself behind
// `featureFlagsProvider.isOn(kTradeImportFlag)` (default OFF — absent from prefs AND
// `_forcedOnFlags`). Flag off ⇒ the entry tile is absent ⇒ this screen is unreachable
// and the app is unchanged. Never seeds real data — that is the owner's go-live step.

import 'package:buildsmart/data/repositories/supplier_onboarding.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The submit seam — given a validated [SupplierDraft], writes the catalog product +
/// inventory row. Wired to the real (repo + Firestore) writer at go-live; until then it
/// throws (never reached — the entry tile is gated off) and tests override it to capture.
typedef SupplierSubmit = Future<void> Function(SupplierDraft draft);

final supplierSubmitProvider = Provider<SupplierSubmit>(
  (ref) =>
      (draft) =>
          throw UnimplementedError(
            'supplierSubmitProvider: wire the catalogProducts + inventory writer at '
            'go-live (draftToProductDoc + draftToInventory → Firestore)',
          ),
);

/// 🏪 העלאת מוצר — the supplier self-onboarding form (Pillar catalog-to-server · C4.1).
class SupplierOnboardingScreen extends ConsumerStatefulWidget {
  const SupplierOnboardingScreen({required this.storeId, super.key});

  /// The store this supplier submits for (stamped on every draft + inventory row).
  final String storeId;

  static Route<void> route(String storeId) => MaterialPageRoute<void>(
    builder: (_) => SupplierOnboardingScreen(storeId: storeId),
  );

  @override
  ConsumerState<SupplierOnboardingScreen> createState() =>
      _SupplierOnboardingState();
}

class _SupplierOnboardingState extends ConsumerState<SupplierOnboardingScreen> {
  final _sku = TextEditingController();
  final _nameHe = TextEditingController();
  final _nameEn = TextEditingController();
  final _categoryHe = TextEditingController();
  final _brand = TextEditingController();
  final _color = TextEditingController();
  final _barcode = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();

  List<String> _errors = const [];
  bool _submitting = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [
      _sku,
      _nameHe,
      _nameEn,
      _categoryHe,
      _brand,
      _color,
      _barcode,
      _price,
      _stock,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The current form as a draft (rebuilt each frame so the facet preview is live).
  SupplierDraft get _draft => SupplierDraft(
    storeId: widget.storeId,
    sku: _sku.text.trim(),
    nameHe: _nameHe.text.trim(),
    categoryHe: _categoryHe.text.trim(),
    nameEn: _nameEn.text.trim(),
    brand: _brand.text.trim(),
    color: _color.text.trim().isEmpty ? null : _color.text.trim(),
    barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
    price: num.tryParse(_price.text.trim()),
    stock: int.tryParse(_stock.text.trim()),
  );

  Future<void> _submit() async {
    final draft = _draft;
    final v = validateDraft(draft, const <String>{});
    if (!v.ok) {
      setState(() => _errors = v.errors);
      return;
    }
    setState(() {
      _errors = const [];
      _submitting = true;
    });
    try {
      await ref.read(supplierSubmitProvider)(draft);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _done = true;
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errors = const ['שליחה נכשלה — נסו שוב'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final facets = suggestFacets(_draft);
    final chips = <String>[
      if (facets.type != null) facets.type!,
      if (facets.gender != null) facets.gender!,
      if (facets.method != null) facets.method!,
      ...facets.sizes,
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: BsTokens.brandDark,
          foregroundColor: Colors.white,
          title: const Text('העלאת מוצר', style: TextStyle(fontSize: 16)),
        ),
        body: SafeArea(
          // A form scroller (NOT a lazy ListView) so every field + the submit
          // button are always in the tree — the whole form is short and testable.
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field('מק"ט', _sku),
                _field('שם (עברית)', _nameHe),
                _field('שם (אנגלית)', _nameEn),
                _field('קטגוריה', _categoryHe),
                _field('מותג', _brand),
                _field('צבע', _color),
                _field('ברקוד', _barcode, number: true),
                Row(
                  children: [
                    Expanded(child: _field('מחיר (₪)', _price, number: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('מלאי', _stock, number: true)),
                  ],
                ),

                // C4.3 — the auto-suggested facets from the name (live as you type).
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'מאפיינים מזוהים אוטומטית',
                    style: TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in chips)
                        Container(
                          key: Key('facetChip_$c'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: BsTokens.brand.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            c,
                            style: const TextStyle(
                              color: BsTokens.brandDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],

                // Validation errors (shown after a failed submit).
                for (final e in _errors) ...[
                  const SizedBox(height: 8),
                  Text(
                    e,
                    key: Key('supplierError_$e'),
                    style: const TextStyle(
                      color: BsTokens.dangerDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                Semantics(
                  button: true,
                  label: 'שלח מוצר',
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: BsTokens.brand,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(_submitting ? 'שולח…' : 'שלח מוצר'),
                  ),
                ),

                if (_done) ...[
                  const SizedBox(height: 16),
                  Text(
                    'המוצר נשלח · ${_sku.text.trim()}',
                    key: const Key('supplierDone'),
                    style: const TextStyle(
                      color: BsTokens.successDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        inputFormatters:
            number ? [FilteringTextInputFormatter.digitsOnly] : null,
        onChanged: (_) => setState(() {}), // keep the facet preview live
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
