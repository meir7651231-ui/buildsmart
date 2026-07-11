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
import 'package:buildsmart/data/smart_tree.dart'
    show SmartProduct, kSmartProducts;
import 'package:buildsmart/features/ring_dive/catalog_axes.dart';
import 'package:buildsmart/features/ring_dive/catalog_slang.dart'
    show catValueLabel;
import 'package:buildsmart/features/ring_dive/ring_dive_wheel.dart'
    show RingDiveWheel;
import 'package:buildsmart/features/word_finder/recipe_kit.dart'
    show assembleKit;
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

  /// ENGINE 3 — jobs. When [_jobMode], the wheel walks the work-recipes instead of
  /// the axes: job-category → job → its assembled kit. A whole job in a few taps.
  bool _jobMode = false;
  String? _jobCat;
  SmartProduct? _job;

  CatAxis _ax(String id) => kCatAxes.firstWhere((a) => a.id == id);

  /// Step up one ring; false at the root (nothing to undo).
  bool _up() {
    if (_job != null) {
      setState(() => _job = null);
      return true;
    }
    if (_jobCat != null) {
      setState(() => _jobCat = null);
      return true;
    }
    if (_jobMode) {
      setState(() => _jobMode = false);
      return true;
    }
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

  /// A wheel over [items], capped at [_cap] with a trailing "עוד…" that expands.
  Widget _capped<T>(List<T> items, String Function(T) label, String hint,
      void Function(T) pick) {
    final more = !_expanded && items.length > _cap;
    final shown = more ? items.take(_cap - 1).toList() : items;
    final labels = <String>[
      for (final it in shown) label(it),
      if (more) 'עוד ${items.length - shown.length}…',
    ];
    return _wheel(labels, const <String>[], hint, (i) {
      if (more && i == shown.length) {
        setState(() => _expanded = true);
        return;
      }
      pick(shown[i]);
    });
  }

  Widget _body() {
    // ── ENGINE 3 — the JOB path (recipe kits) ──────────────────────────────────
    if (_jobMode) return _jobBody();

    final matched = catMatching(_cons);

    // ── VALUE wheel — the options of the axis being chosen (capped) ─────────────
    if (_axis != null) {
      final vals = catOptsFor(_axis!, _cons, matched, matched);
      return _capped(
        vals,
        (v) => catValueLabel(_axis!, v),
        'איזה ${_ax(_axis!).label}?',
        (v) => setState(() {
          _cons[_axis!] = v; // raw value; the label shown was the slang
          _order.add(_axis!);
          _axis = null;
          _expanded = false;
        }),
      );
    }

    final axes = catFindAxes(_cons);
    if (_showList || axes.isEmpty || matched.length <= 1) {
      return _finalList(matched);
    }

    // ── AXIS wheel — "הצג" + a "לפי עבודה" entry (opening only) + the top axes
    //    (easy-path order), the rest behind "עוד…", all within [_cap] slots. ─────
    final labels = <String>[];
    final subs = <String>[];
    final actions = <VoidCallback>[];
    void add(String label, String sub, VoidCallback act) {
      labels.add(label);
      subs.add(sub);
      actions.add(act);
    }

    add('📋 הצג ${matched.length}', 'כל המוצרים',
        () => setState(() => _showList = true));
    if (_cons.isEmpty) {
      add('🔧 לפי עבודה', '${kSmartProducts.length} מתכונים',
          () => setState(() => _jobMode = true));
    }
    final reserved = labels.length;
    final moreA = !_expanded && axes.length > _cap - reserved;
    final shownAxes = moreA ? axes.take(_cap - reserved - 1).toList() : axes;
    for (final id in shownAxes) {
      add(
        '${_ax(id).emoji} ${_ax(id).label}',
        '${catOptsFor(id, _cons, matched, matched).length} אפשרויות',
        () => setState(() {
          _axis = id;
          _expanded = false;
        }),
      );
    }
    if (moreA) {
      add('עוד ${axes.length - shownAxes.length} צירים…', 'צירים נוספים',
          () => setState(() => _expanded = true));
    }
    return _wheel(labels, subs,
        _order.isEmpty ? 'ממה נתחיל?' : 'לפי מה עוד?', (i) => actions[i]());
  }

  /// ENGINE 3 — the job flow: category → job → its assembled kit.
  Widget _jobBody() {
    if (_job != null) return _kitList(_job!);
    if (_jobCat != null) {
      final jobs = <SmartProduct>[
        for (final s in kSmartProducts)
          if (s.cat == _jobCat) s,
      ];
      return _capped(jobs, (j) => '${j.emoji} ${j.name}', 'איזו עבודה?',
          (j) => setState(() => _job = j));
    }
    final cats = <String>[];
    for (final s in kSmartProducts) {
      if (!cats.contains(s.cat)) cats.add(s.cat);
    }
    return _capped(cats, (c) => c, 'איזו עבודה תעשה?',
        (c) => setState(() => _jobCat = c));
  }

  /// The chosen job's kit — one line per accessory, resolved to a catalog product.
  Widget _kitList(SmartProduct job) {
    final lines = assembleKit(job);
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            children: <Widget>[
              Text('${job.emoji} ${job.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text('הערכה המלאה · ${lines.length} חלקים',
                  style: const TextStyle(fontSize: 12.5)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: lines.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final l = lines[i];
              final p = l.product;
              return ListTile(
                leading: Text(p?.typeEmoji ?? '•',
                    style: const TextStyle(fontSize: 20)),
                title: Text(l.acc.name, textDirection: TextDirection.rtl),
                subtitle: Text(p?.nameHe ?? 'לבחירה ידנית',
                    style: const TextStyle(fontSize: 11)),
                trailing: p == null ? null : const Icon(Icons.chevron_left),
                onTap:
                    p == null ? null : () => showLipskeyProductSheet(context, p, <LipskeyCatalogProduct>[p]),
              );
            },
          ),
        ),
      ],
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
