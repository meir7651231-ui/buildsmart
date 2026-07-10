// PLAIN DIVE screen — the layman 4-ring drill, riding the SAME rotary wheel the
// pro RingDive uses (RingDiveWheel), fed by the dictionary tree ([plain_dive.dart]).
// Runs ALONGSIDE the pro RingDive; reached only behind [kPlainDive], so with the
// flag off this screen + its entry tree-shake and the app is byte-identical.
//
//   ring 1 קטגוריית-על → ring 2 סיווג → ring 3 שם-טכני\סלנג → ring 4 המוצרים
//
// The leaf reaches REAL products (plainProductsFor) and a tap opens the product
// sheet — the same path the finder uses — so the drill genuinely lands on a part.
library;

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
  String? _superCat; // ring 1 choice
  String? _classification; // ring 2 choice
  PlainNode? _type; // ring 3 choice → ring 4 shows its products

  /// Step UP one ring; false when already at the root (the caller pops the route).
  bool _up() {
    if (_type != null) {
      setState(() => _type = null);
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
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'חזרה',
            onPressed: () {
              if (!_up()) Navigator.of(context).maybePop();
            },
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
    // Ring 3 — type nodes, labelled in the layman's word (slang), the usage note
    // as the sub-line.
    if (_type == null) {
      final nodes = plainNodes(_superCat!, _classification!);
      return _wheel(
        [for (final n in nodes) n.slang],
        [for (final n in nodes) n.usage],
        _classification!,
        (i) => setState(() => _type = nodes[i]),
      );
    }
    // Ring 4 — the real products the leaf reaches; a tap opens the product sheet.
    final products = plainProductsFor(_type!);
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
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(_type!.usage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5)),
              const SizedBox(height: 2),
              Text('${products.length} מוצרים',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11.5)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final LipskeyCatalogProduct p = products[i];
              return ListTile(
                leading:
                    Text(p.typeEmoji, style: const TextStyle(fontSize: 22)),
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
