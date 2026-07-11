// CATALOG WHEEL — the owner's "pick which wheel to start from" finder.
//
// Ring flow (a constraint engine, not a fixed tree — every door open):
//   1) AXIS wheel  — "ממה נתחיל?" — every axis that still splits the pool
//      (סוג · קוטר · אורך · מעבר · חומר · חדר · …). Spin, pick one.
//   2) VALUE wheel — that axis's options (½" · DN40 · …). Spin, pick one → a
//      constraint is added and we return to the AXIS wheel for the next pick.
//   Repeat in ANY order; a "📋 הצג" option and the auto-collapse show the final
//   products. Behind [kAxisDive] ⇒ tree-shaken (byte-identical) when off.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/ring_dive/catalog_axes.dart';
import 'package:buildsmart/features/ring_dive/catalog_slang.dart'
    show catValueLabel;
import 'package:buildsmart/features/ring_dive/ring_dive_wheel.dart'
    show RingDiveWheel;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:flutter/material.dart';

class CatalogWheelScreen extends StatefulWidget {
  const CatalogWheelScreen({super.key});

  @override
  State<CatalogWheelScreen> createState() => _CatalogWheelScreenState();
}

class _CatalogWheelScreenState extends State<CatalogWheelScreen> {
  /// Chosen constraints: axisId → value.
  final Map<String, String> _cons = <String, String>{};

  /// Constraint order, so back removes the most-recent pick.
  final List<String> _order = <String>[];

  /// The axis we are currently picking a VALUE for; null = the axis selector.
  String? _axis;

  /// The user asked to see the remaining products (the "📋 הצג" option).
  bool _showList = false;

  /// The current wheel shows ALL options (the user tapped "עוד"); else it caps at
  /// [_cap] with a trailing "עוד…" that expands.
  bool _expanded = false;

  /// Max options on a ring before the rest fold behind "עוד…".
  static const int _cap = 12;

  CatAxis _ax(String id) => kCatAxes.firstWhere((a) => a.id == id);

  /// Step up one ring; false at the root (nothing to undo).
  bool _up() {
    if (_expanded) {
      setState(() => _expanded = false);
      return true;
    }
    if (_showList) {
      setState(() => _showList = false);
      return true;
    }
    if (_axis != null) {
      setState(() => _axis = null);
      return true;
    }
    if (_order.isNotEmpty) {
      setState(() => _cons.remove(_order.removeLast()));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final crumbs = <String>[
      'הכול',
      for (final id in _order) '${_ax(id).label}: ${catValueLabel(id, _cons[id]!)}',
      if (_axis != null) _ax(_axis!).label,
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: (_order.isEmpty && _axis == null && !_showList)
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'חזרה',
                  onPressed: () => _up(),
                ),
          title: Text(crumbs.join(' › '),
              style: const TextStyle(fontSize: 14), overflow: TextOverflow.fade),
        ),
        body: SafeArea(child: _body()),
      ),
    );
  }

  Widget _wheel(List<String> labels, List<String> subs, String hint,
          ValueChanged<int> onSelect) =>
      Center(
        child: RingDiveWheel(
          labels: labels,
          sublabels: subs,
          hubHint: hint,
          onSelect: onSelect,
        ),
      );

  Widget _body() {
    final matched = catMatching(_cons);

    // ── VALUE wheel — the options of the axis being chosen (capped at _cap) ────
    if (_axis != null) {
      final vals = catOptsFor(_axis!, _cons, matched, matched);
      final more = !_expanded && vals.length > _cap;
      final shown = more ? vals.take(_cap - 1).toList() : vals;
      final labels = <String>[
        for (final v in shown) catValueLabel(_axis!, v),
        if (more) 'עוד ${vals.length - shown.length}…',
      ];
      return _wheel(
        labels,
        const <String>[],
        'איזה ${_ax(_axis!).label}?',
        (i) {
          if (more && i == shown.length) {
            setState(() => _expanded = true);
            return;
          }
          setState(() {
            _cons[_axis!] = shown[i]; // raw value; label was the slang
            _order.add(_axis!);
            _axis = null;
            _expanded = false;
          });
        },
      );
    }

    final axes = catFindAxes(_cons);

    // Nothing left to split (or the user asked) → the final products.
    if (_showList || axes.isEmpty || matched.length <= 1) {
      return _finalList(matched);
    }

    // ── AXIS wheel — "which wheel do we start / continue from?" (capped) ────────
    // Slot 0 is always "הצג"; the remaining _cap-1 slots hold the top axes (easy-
    // path order), the rest fold behind a trailing "עוד…".
    final moreA = !_expanded && axes.length > _cap - 1;
    final shownAxes = moreA ? axes.take(_cap - 2).toList() : axes;
    final labels = <String>[
      '📋 הצג ${matched.length}',
      for (final id in shownAxes) '${_ax(id).emoji} ${_ax(id).label}',
      if (moreA) 'עוד ${axes.length - shownAxes.length} צירים…',
    ];
    final subs = <String>[
      'כל המוצרים',
      for (final id in shownAxes)
        '${catOptsFor(id, _cons, matched, matched).length} אפשרויות',
      if (moreA) 'צירים נוספים',
    ];
    return _wheel(
      labels,
      subs,
      _order.isEmpty ? 'ממה נתחיל?' : 'לפי מה עוד?',
      (i) {
        if (i == 0) {
          setState(() => _showList = true);
          return;
        }
        if (moreA && i == shownAxes.length + 1) {
          setState(() => _expanded = true);
          return;
        }
        setState(() {
          _axis = shownAxes[i - 1];
          _expanded = false;
        });
      },
    );
  }

  Widget _finalList(List<CatProduct> matched) {
    final products = <LipskeyCatalogProduct>[for (final p in matched) p.product];
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Text(
            products.length == 1
                ? 'המוצר שמצאנו:'
                : 'בחר את המדויק · ${products.length} מוצרים',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
