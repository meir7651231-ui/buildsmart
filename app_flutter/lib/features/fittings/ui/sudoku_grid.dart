// 🧩 D11/D13 · גריד-הסודוקו — ה-UI הדק מעל מנוע-הכיוונים (P6·1–5). מניחים אביזר
// בתא; הקשה על משבצת-ריקה שכנה מציגה **רק מה שמתחבר לשכן** (`gridSuggestionsAt`),
// והקשה על הצעה מניחה אותה. שלושת הכפתורים (קו/בדיקה/השלם) פועלים על התאים
// המונחים דרך `freeEndsOf`. מגודר `kFittingEngine` (ברירת-מחדל OFF) — אינו מחווט
// לפרודקשן, נטרף ב-off-build.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show ConnectorEnd, kBspInchToMm, kVerifiedSpecs;
import 'package:buildsmart/data/related_info.dart' show compatibleProductsFor;
import 'package:buildsmart/features/fittings/engine/catalog_map.dart'
    show familyOf, od2Of, odOf;
import 'package:buildsmart/features/fittings/engine/grid_cell.dart';
import 'package:buildsmart/features/fittings/engine/grid_topology.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/ui/line_3d.dart';
import 'package:flutter/material.dart';

const Color _cInk = Color(0xFF232A33);
const Color _cDim = Color(0xFF7A828D);
const Color _cLine = Color(0xFFE9ECF1);
const Color _cAccent = Color(0xFFEE6A2A);
const Color _cImgBg = Color(0xFFF4F6F9);
const Color _cHotBg = Color(0xFFFFF2EA);
const Color _cGreen = Color(0xFF1F9D57);

/// The candidate palette the grid offers (od 50 for the demo hero size).
const List<RunElement> _kCandidates = [
  RunElement(Family.coupler, 50),
  RunElement(Family.elbow90, 50),
  RunElement(Family.elbow90, 50, dir: Dir.up),
  RunElement(Family.tee, 50, dir: Dir.up),
  RunElement(Family.reducer, 50, od2: 40),
  RunElement(Family.plug, 50),
];

/// Parse a connector end's `size` string → nominal OD in mm. Handles the two
/// forms the verified specs use: plain metric ("50", "32") and BSP inch marks
/// ("1/2\"", "3/4\"", "4\""). BSP sizes resolve through [kBspInchToMm]; whole-
/// inch sizes past that table (3"/4"/6"/8") fall back to a nominal inch×25.
int? _endOdMm(String rawSize) {
  final hadInch = rawSize.contains('"');
  final s = rawSize.replaceAll('"', '').trim();
  final bsp = kBspInchToMm[s];
  if (bsp != null) return bsp;
  final m = RegExp(r'^(\d+)').firstMatch(s);
  if (m == null) return null;
  final n = int.tryParse(m.group(1)!);
  if (n == null) return null;
  return hadInch ? n * 25 : n; // inch-marked & off-table ⇒ nominal mm
}

/// Type a product from its VERIFIED connector spec (the lipskey path): family by
/// port-count (1 = plug · 2 same-size = coupler · 2 diff-size = reducer · 3+ =
/// tee/manifold), OD from the first end's size. Lets every spec'd product seed
/// the grid with its REAL shape even though it isn't a PPR pipe fitting.
RunElement? _runElementFromEnds(List<ConnectorEnd> ends) {
  if (ends.isEmpty) return null;
  final od0 = _endOdMm(ends.first.size);
  if (od0 == null) return null;
  if (ends.length == 1) return RunElement(Family.plug, od0);
  if (ends.length == 2) {
    final od1 = _endOdMm(ends[1].size);
    if (od1 != null && od1 != od0) {
      final big = od0 >= od1 ? od0 : od1;
      final small = od0 >= od1 ? od1 : od0;
      return RunElement(Family.reducer, big, od2: small);
    }
    return RunElement(Family.coupler, od0);
  }
  return RunElement(Family.tee, od0); // 3+ ends: tee / manifold
}

/// Map a catalog product to an engine [RunElement] (family + od + od2) so the
/// grid can be SEEDED from a real product. Tries the PPR/polyroll engine typing
/// first (`familyOf`/`odOf`), then falls back to the verified connector spec
/// (the lipskey catalog the internal card actually runs on). `null` only when
/// neither path can type the product.
RunElement? runElementFor(LipskeyCatalogProduct p) {
  final famLabel = familyOf(p);
  final od = odOf(p);
  if (famLabel != null && od != null) {
    final fam = Family.fromLabel(famLabel);
    if (fam != null) return RunElement(fam, od, od2: od2Of(p));
  }
  final spec = kVerifiedSpecs[p.sku];
  if (spec != null) {
    final el = _runElementFromEnds(spec.ends);
    if (el != null) return el;
  }
  return null;
}

String famEmoji(Family f) => switch (f) {
      Family.coupler => '🧷',
      Family.elbow90 || Family.elbow45 || Family.miteredElbow => '🦵',
      Family.tee || Family.saddle => '🔱',
      Family.reducer => '🔻',
      Family.plug => '⬛',
      Family.valve => '🚰',
      Family.adapter => '🔩',
      Family.collar => '⭕',
    };

/// The D11/D13 sudoku grid: place fittings on a lattice; the engine filters
/// suggestions to only those that mate a placed neighbour.
class SudokuGrid extends StatefulWidget {
  const SudokuGrid({
    this.rows = 3,
    this.cols = 3,
    this.initialActive,
    this.seedProduct,
    this.initial3D = false,
    super.key,
  });

  final int rows;
  final int cols;

  /// Optional (row,col) pre-selected on first build (used by previews/tests to
  /// show the suggestion row without a tap).
  final (int, int)? initialActive;

  /// The real product the grid is opened FROM — seeds the centre cell and the
  /// suggestion candidates from its actual mates (null ⇒ generic od-50 demo).
  final LipskeyCatalogProduct? seedProduct;

  /// Start in the 3D-cubes view (previews/tests).
  final bool initial3D;

  @override
  State<SudokuGrid> createState() => _SudokuGridState();
}

class _SudokuGridState extends State<SudokuGrid> {
  /// (row, col) → fitting. Seeded from [SudokuGrid.seedProduct] (the real
  /// product the card was opened from) when it types cleanly, else a demo coupler.
  late final Map<(int, int), RunElement> _placed = {
    (widget.rows ~/ 2, widget.cols ~/ 2):
        (widget.seedProduct != null ? runElementFor(widget.seedProduct!) : null) ??
            const RunElement(Family.coupler, 50),
  };

  /// The empty cell the user is filling (null = none active).
  late (int, int)? _active = widget.initialActive;

  /// D12 — 2D grid vs the isometric 3D-cubes view of the same line.
  late bool _is3D = widget.initial3D;

  /// Suggestion candidates: the seed product's REAL mates (mapped to engine
  /// elements) when seeded, else the generic od-50 demo palette.
  late final List<RunElement> _candidates = _resolveCandidates();

  List<RunElement> _resolveCandidates() {
    final sp = widget.seedProduct;
    if (sp != null) {
      final mates = [
        for (final m in compatibleProductsFor(sp)) runElementFor(m),
      ].whereType<RunElement>().toList();
      if (mates.isNotEmpty) return mates;
    }
    return _kCandidates;
  }

  List<GridCell> get _cells => [
        for (final e in _placed.entries)
          GridCell(e.key.$2, -e.key.$1, 0, e.value),
      ];

  List<RunElement> get _suggestions {
    final a = _active;
    if (a == null) return const [];
    return gridSuggestionsAt(_cells, (a.$2, -a.$1, 0), _candidates);
  }

  void _tapEmpty(int r, int c) => setState(() => _active = (r, c));

  void _place(RunElement el) {
    final a = _active;
    if (a == null) return;
    setState(() {
      _placed[a] = el;
      _active = null;
    });
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        key: const Key('sudokuGrid'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 4, 0, 10),
            child: Text(
              '🧵 בניית הגריד — הקש משבצת ריקה שכנה',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _cInk,
              ),
            ),
          ),
          _viewToggle(),
          const SizedBox(height: 8),
          if (_is3D)
            Line3DView(cells: _cells, height: 280)
          else ...[
            for (var r = 0; r < widget.rows; r++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [for (var c = 0; c < widget.cols; c++) _cell(r, c)],
              ),
            const SizedBox(height: 12),
            _suggestionArea(),
          ],
          const SizedBox(height: 12),
          _actions(),
        ],
      ),
    );
  }

  Widget _viewToggle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        key: const Key('gridToggle3D'),
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _is3D = !_is3D),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _is3D ? _cAccent : _cImgBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _is3D ? _cAccent : _cLine),
          ),
          child: Text(
            _is3D ? '▦ 2D' : '📦 3D',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _is3D ? Colors.white : _cInk,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell(int r, int c) {
    final el = _placed[(r, c)];
    final active = _active == (r, c);
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: el != null
            ? _cHotBg
            : active
                ? _cHotBg
                : _cImgBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: el != null || active ? _cAccent : _cLine,
          width: el != null || active ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: el != null
          ? Text(famEmoji(el.family), style: const TextStyle(fontSize: 26))
          : GestureDetector(
              key: Key('cell_${r}_$c'),
              behavior: HitTestBehavior.opaque,
              onTap: () => _tapEmpty(r, c),
              child: const SizedBox(
                width: 64,
                height: 64,
                child: Center(
                  child: Text('+',
                      style: TextStyle(fontSize: 22, color: _cDim)),
                ),
              ),
            ),
    );
  }

  Widget _suggestionArea() {
    if (_active == null) {
      return const SizedBox(height: 4);
    }
    final s = _suggestions;
    if (s.isEmpty) {
      return const Text('אין אביזר שמתחבר לשכן כאן',
          style: TextStyle(fontSize: 12.5, color: _cDim));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('💡 מתחברים לשכן:',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w800, color: _cAccent)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < s.length; i++)
              GestureDetector(
                key: Key('suggest_$i'),
                behavior: HitTestBehavior.opaque,
                onTap: () => _place(s[i]),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _cImgBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _cLine),
                  ),
                  child: Text(
                    '${famEmoji(s[i].family)} ${s[i].family.label}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: _cInk),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _actions() {
    Widget btn(String label, Color bg, Color fg, VoidCallback onTap, Key key) =>
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              key: key,
              color: bg,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Center(
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: fg)),
                  ),
                ),
              ),
            ),
          ),
        );
    return Row(
      children: [
        btn('✅ השלם', _cGreen, Colors.white, () {
          _snack('הקו: ${_placed.length} אביזרים · ${freeEndsOf(_cells).length} קצוות פנויים');
        }, const Key('gridBtnComplete')),
        btn('🔍 בדיקה', _cImgBg, _cInk, () {
          final free = freeEndsOf(_cells).length;
          _snack(free == 0 ? 'קו סגור — אין קצוות פנויים' : '$free קצוות פנויים');
        }, const Key('gridBtnCheck')),
        btn('🔗 קו', _cImgBg, _cInk, () {
          _snack('${_placed.length} אביזרים בקו');
        }, const Key('gridBtnLine')),
      ],
    );
  }
}
