// PLAIN DIVE screen — the layman drill, riding the SAME rotary wheel the pro
// RingDive uses (RingDiveWheel), fed by the dictionary tree ([plain_dive.dart]).
// Runs ALONGSIDE the pro RingDive; reached only behind [kPlainDive], so with the
// flag off this screen + its entry tree-shake and the app is byte-identical.
//
//   ring 1 קטגוריית-על → ring 2 סיווג → ring 3 סלנג → rings 4+ narrow the variants
//   by size/material/… (in plain words) → the final short list → open the product.
//
// Every ring keeps SPINNING toward one product instead of dumping a long list.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/ring_dive/plain_dive.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_wheel.dart'
    show RingDiveWheel;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:flutter/material.dart';

class PlainDiveScreen extends StatefulWidget {
  const PlainDiveScreen({super.key});

  @override
  State<PlainDiveScreen> createState() => _PlainDiveScreenState();
}

class _PlainDiveScreenState extends State<PlainDiveScreen> {
  String? _superCat; // ring 1
  String? _classification; // ring 2
  PlainNode? _type; // ring 3 → then the narrow phase begins

  // Narrow phase (rings 4+): the current product set + the plain choices made.
  List<LipskeyCatalogProduct> _products = const <LipskeyCatalogProduct>[];
  final List<({String axis, String value})> _picks =
      <({String axis, String value})>[];

  Set<String> get _usedAxes => {for (final p in _picks) p.axis};

  void _rebuildProducts() {
    var ps = plainProductsFor(_type!);
    for (final p in _picks) {
      ps = plainFilterBy(ps, p.axis, p.value);
    }
    _products = ps;
  }

  /// Step UP one ring. Returns false only at the drill root — where the back arrow
  /// is hidden (the user leaves via the tabs), so that case isn't reached in the UI.
  bool _up() {
    if (_picks.isNotEmpty) {
      setState(() {
        _picks.removeLast();
        _rebuildProducts();
      });
      return true;
    }
    if (_type != null) {
      setState(() {
        _type = null;
        _products = const <LipskeyCatalogProduct>[];
      });
      return true;
    }
    if (_classification != null) {
      setState(() => _classification = null);
      return true;
    }
    if (_superCat != null) {
      setState(() => _superCat = null);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final crumbs = <String>[
      'הכול',
      if (_superCat != null) _superCat!,
      if (_classification != null) _classification!,
      if (_type != null) _type!.slang,
      for (final p in _picks) plainAxisLabel(p.axis, p.value),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          // At the drill ROOT there is nowhere up — this screen is embedded in the
          // tab body (not a pushed route), so a back arrow there is dead (or, under
          // the pushed manager frame, ejects the whole shell). Show it only once the
          // user has drilled at least one ring; at the root they leave via the tabs.
          automaticallyImplyLeading: false,
          leading: _superCat == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'חזרה',
                  onPressed: () => _up(),
                ),
          title: Text(crumbs.join(' › '),
              style: const TextStyle(fontSize: 15), overflow: TextOverflow.fade),
        ),
        body: SafeArea(child: _body()),
      ),
    );
  }

  Widget _wheel(
    List<String> labels,
    List<String> subs,
    String hint,
    ValueChanged<int> onSelect,
  ) =>
      Center(
        child: RingDiveWheel(
          labels: labels,
          sublabels: subs,
          hubHint: hint,
          onSelect: onSelect,
        ),
      );

  Widget _body() {
    // Ring 1 — super-categories.
    if (_superCat == null) {
      final scs = plainSuperCats();
      return _wheel(scs, const <String>[], 'סובב · הקש לבחור',
          (i) => setState(() => _superCat = scs[i]));
    }
    // Ring 2 — classifications.
    if (_classification == null) {
      final cls = plainClassifications(_superCat!);
      return _wheel(cls, const <String>[], _superCat!,
          (i) => setState(() => _classification = cls[i]));
    }
    // Ring 3 — the type, in the layman's word.
    if (_type == null) {
      final nodes = plainNodes(_superCat!, _classification!);
      return _wheel(
        [for (final n in nodes) n.slang],
        [for (final n in nodes) n.usage],
        _classification!,
        (i) => setState(() {
          _type = nodes[i];
          _picks.clear();
          _rebuildProducts();
        }),
      );
    }

    // Rings 4+ — keep narrowing the variants by size/material/… in plain words,
    // until no axis splits them; then show the short final list.
    if (_products.length > 1) {
      final next = plainNextAxis(_products, usedAxes: _usedAxes);
      if (next != null) {
        return _wheel(
          [for (final v in next.values) plainAxisLabel(next.axis, v)],
          const <String>[],
          plainAxisTitle(next.axis),
          (i) => setState(() {
            _picks.add((axis: next.axis, value: next.values[i]));
            _rebuildProducts();
          }),
        );
      }
    }

    // Final ring — the remaining product(s); a tap opens the product sheet.
    return _finalList();
  }

  Widget _finalList() {
    final products = _products;
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('${_type!.slang}  ·  ${_type!.english}',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                  products.length == 1
                      ? 'המוצר שמצאנו:'
                      : 'בחר את המדויק · ${products.length} אפשרויות',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: products.isEmpty
              ? const Center(child: Text('לא נמצאו מוצרים'))
              : ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return ListTile(
                      leading: Text(p.typeEmoji,
                          style: const TextStyle(fontSize: 22)),
                      title: Text(p.nameHe, textDirection: TextDirection.rtl),
                      subtitle: p.nameEn.isEmpty
                          ? null
                          : Text(p.nameEn, style: const TextStyle(fontSize: 11)),
                      onTap: () => showLipskeyProductSheet(context, p, products),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
