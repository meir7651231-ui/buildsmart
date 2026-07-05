// BsKeyboard — the custom Hebrew on-screen keyboard (Phase-3a).
//
// Pure presentation + routing: it lays out the approved layout
// ([hebrew_layout.dart]) as a grid of [BsKey]s and forwards every tap to a
// typed callback based on the key's [KeyKind]. No text controller / Riverpod /
// feature-flag awareness lives here — what to do with an inserted character,
// a backspace, an enter, a send, or a layer toggle is entirely the caller's
// job. This keeps the widget trivially testable and reusable.
//
// The whole keyboard is pinned to [TextDirection.ltr] so the key ORDER stays
// stable inside the otherwise-RTL app (the framework would mirror the rows
// under RTL otherwise — see [hebrew_layout.dart]). The letters themselves are
// authored LTR for the same reason.

import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_key.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/english_layout.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/hebrew_layout.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter/material.dart';

/// Which tool LAYER (if any) replaces the letter/symbol area of [BsKeyboard].
///
/// This reuses the EXISTING layer mechanism (the same idea as `showSymbols`):
/// when [BsKeyboard.toolLayer] is anything other than [none] the main grid area
/// renders a set of tool tiles instead of the letters, while [kBottomRow] keeps
/// rendering at the bottom. [none] is the default and preserves today's
/// behaviour byte-for-byte.
///   • [home] — the 8 "home" product tools ([_kHomeTools]).
///   • [kbd]  — the 5 keyboard-adjacent tools ([_kKbdTools]).
enum KbToolLayer { none, home, kbd }

/// Stable, typed identity of each tool tile — the payload of [BsKeyboard.onTool].
///
/// The tile still DISPLAYS its Hebrew [_ToolDef.label]; this enum is what the
/// callback carries so the (single) keyboard→app coupling point
/// ([lib/screens/keyboard_tool_actions.dart]) can switch on a value instead of
/// matching a free-form string. The 8 `home` ids then the 5 `kbd` ids, declared
/// in the SAME order the tiles appear in [_kHomeTools] / [_kKbdTools].
enum KbTool {
  departments,
  smartTree,
  workRoute,
  quickTools,
  recentOrders,
  finder,
  connect,
  favorites,
  voice,
  search,
  menu,
  camera,
  intro,
}

/// One tool tile's definition: a stable [id] (the callback payload), a Material
/// [icon], and its Hebrew [label]. The label is what shows under the icon AND
/// drives Semantics; the [id] is what is passed back through [BsKeyboard.onTool]
/// on tap.
@immutable
class _ToolDef {
  final KbTool id;
  final IconData icon;
  final String label;
  const _ToolDef(this.id, this.icon, this.label);
}

/// A PURE description of one morph tile — the data the screens-layer drill
/// engine ([keyboard_tool_tree.dart]) hands to [BsKeyboard.tiles].
///
/// This keeps [BsKeyboard] screen-agnostic for the MORPH path (the drill-stack)
/// exactly as [_ToolDef]/[KbTool] keep it agnostic for the legacy [toolLayer]
/// path: a tile is just an [icon] + a Hebrew [label] + a plain integer [id].
/// The id carries no app meaning here — the screens layer chose it and switches
/// on it when [BsKeyboard.onTile] bubbles it back on tap. No import from
/// `lib/screens` or `lib/state` is needed to render a tile, so this type (and
/// the whole tiles path) keeps the widget pure.
@immutable
class KbTile {
  /// The Material icon shown above the label.
  final IconData icon;

  /// The Hebrew label shown under the icon (also the Semantics label).
  final String label;

  /// An opaque, screens-layer-chosen identity bubbled back via [BsKeyboard.onTile]
  /// when this tile is tapped. Meaningless to [BsKeyboard] itself.
  final int id;

  const KbTile({required this.icon, required this.label, required this.id});
}

/// The 8 home tools, in layout order. Material icons (the app uses Material).
const List<_ToolDef> _kHomeTools = <_ToolDef>[
  _ToolDef(KbTool.departments, Icons.grid_view, 'מחלקות'),
  _ToolDef(KbTool.smartTree, Icons.account_tree, 'עץ חכם'),
  _ToolDef(KbTool.workRoute, Icons.route, 'מסלול'),
  _ToolDef(KbTool.quickTools, Icons.bolt, 'מהירים'),
  _ToolDef(KbTool.recentOrders, Icons.receipt_long, 'הזמנות'),
  _ToolDef(KbTool.finder, Icons.gps_fixed, 'מאתר'),
  _ToolDef(KbTool.connect, Icons.cable, 'חיבור'),
  _ToolDef(KbTool.favorites, Icons.star_border, 'מועדפים'),
];

/// How many morph tiles ([_tileRows]) sit in one row. The legacy fixed layers
/// pack their 8/5 into a single row; the variable-length drill view wraps at
/// this width so deep branches stay legible.
const int _kTilesPerRow = 4;

/// The 5 keyboard tools, in layout order.
const List<_ToolDef> _kKbdTools = <_ToolDef>[
  _ToolDef(KbTool.voice, Icons.mic, 'קולי'),
  _ToolDef(KbTool.search, Icons.search, 'חיפוש'),
  _ToolDef(KbTool.menu, Icons.more_vert, 'תפריט'),
  _ToolDef(KbTool.camera, Icons.camera_alt, 'מצלמה'),
  _ToolDef(KbTool.intro, Icons.lightbulb_outline, 'היכרות'),
];

/// The custom keyboard. Renders one of three layers — the Hebrew letters
/// ([kHebrewRows]), the English QWERTY letters ([kEnglishRows]) when [english]
/// is true, or the `?123` symbols layer ([kSymbolsRows]) when [showSymbols] is
/// true (which takes precedence) — always followed by [kBottomRow]. A backspace
/// key is appended to the right end of the last letter/symbol row.
class BsKeyboard extends StatelessWidget {
  /// Insert this text into the field (letters, digits, punctuation, or the
  /// space bar's `' '` output).
  final ValueChanged<String> onKey;

  /// Delete one character (backspace key).
  final VoidCallback onBackspace;

  /// Insert a newline / submit a line (enter key).
  final VoidCallback onEnter;

  /// Fire the send action (the brand-orange send key).
  final VoidCallback onSend;

  /// Close the floating overlay — the X that now lives at the LEADING (left) edge
  /// of the tool strip (owner mobile redesign moved it out of the panel's own
  /// row). Null on every non-floating mount, where the strip carries no X.
  final VoidCallback? onClose;

  /// The current query text, shown INSIDE the tool strip's middle. The separate
  /// search field was removed (owner mobile redesign) — typing now registers in
  /// the strip itself. Empty (default) → the strip shows a faint hint, no input
  /// glyph, so the legacy strip (no typed text) reads as before.
  final String typedText;

  /// Exit the tool view back to the LETTERS — the action of the dual-mode bottom
  /// key WHEN a tool layer is open (the key reads "אבג" then, "?123" on the
  /// letters). Null on every non-floating mount, where that key stays the plain
  /// `?123`/symbols toggle (byte-identical), since [tiles] is null there.
  final VoidCallback? onExitTools;

  /// Toggle between the letter and `?123` symbols layers. The single
  /// layer-switch key — labelled `?123` on letters, `אבג` on symbols — routes
  /// here (there is no second toggle key).
  final VoidCallback? onToggleSymbols;

  /// When true, the layer-switch key ALWAYS toggles letters↔symbols — even while
  /// a tool layer is open (it stops doubling as "exit tools"). Owner button-spec
  /// v2 (#7 = letters↔numbers ONLY); the floating mount passes its
  /// `KB_BUTTONS_V2` flag. Default false → byte-identical (the key still exits
  /// tools when [tiles] is non-null, the legacy dual-mode behaviour).
  final bool symbolsAlwaysToggles;

  /// Switch input language (the globe key).
  final VoidCallback? onLanguage;

  /// When true, render the `?123` symbols layer instead of the letter layer.
  final bool showSymbols;

  /// When true (and not showing symbols), render the English QWERTY layer
  /// instead of Hebrew.
  final bool english;

  // ── Tool strip + tool layers (FLAGGED — all default OFF) ──────────────────
  // Every field below is optional and defaults to the OFF/empty value, so a
  // caller that does not pass them gets exactly today's keyboard. The live host
  // keeps the strip off behind `kKeyboardToolStrip`.

  /// When true, render the tool STRIP above the layer rows (grid toggle ·
  /// predictions · gear toggle). When false, nothing extra renders.
  final bool showToolStrip;

  /// Which tool layer replaces the letter/symbol grid. [KbToolLayer.none]
  /// (default) keeps the existing letters/symbols layer untouched.
  final KbToolLayer toolLayer;

  /// Prediction strings shown as chips in the MIDDLE of the strip, rendered
  /// as-is with no horizontal scroll. Empty by default.
  final List<String> predictions;

  /// The subset of [predictions] that are navigable DESTINATIONS (a tap
  /// navigates) rather than query-narrowing product WORDS (a tap narrows the
  /// query). A chip whose text is in this set renders with a small leading nav
  /// glyph ([Icons.north_east]) + a subtle brand accent so the user can tell a
  /// one-tap nav target from a word; every other chip renders EXACTLY as before.
  ///
  /// PURE plain data — just the destination chip LABELS — so [BsKeyboard] stays
  /// screen-agnostic (no import from `lib/screens` or `lib/state`). Empty by
  /// default, which makes every chip render byte-identically to today.
  final Set<String> destinationChips;

  /// Tapped the grid-toggle (left of the strip, [Icons.grid_view]).
  final VoidCallback? onToolGrid;

  /// Tapped the gear-toggle (right of the strip, [Icons.settings]).
  final VoidCallback? onToolGear;

  /// Tapped a tool tile — receives the tile's typed [KbTool] id. The single
  /// keyboard→app coupling point ([runKeyboardTool]) switches on this id.
  final ValueChanged<KbTool>? onTool;

  /// Tapped a prediction chip — receives the chip's text.
  final ValueChanged<String>? onPrediction;

  // ── MORPH path (drill-stack) — PURE tiles, screens-layer driven ───────────
  // When [tiles] is non-null it OVERRIDES the letter/symbol/[toolLayer] grid:
  // the main area renders exactly these pure [KbTile]s (the current drill
  // node-list), with a leading BACK tile when [showBack] is true. This is the
  // path the floating keyboard uses for the morph engine; the legacy
  // [toolLayer]/[onTool] path is left untouched so the golden + strip tests are
  // byte-identical. Both default OFF (null) so every existing mount is unchanged.

  /// The pure tiles to render in the main grid (the current drill node-list).
  /// Null (default) → render the letters/symbols/[toolLayer] grid as before.
  final List<KbTile>? tiles;

  /// Tapped a [tiles] tile — receives that tile's opaque [KbTile.id]. The
  /// screens-layer drill engine switches on it (leaf → run · branch → morph).
  final ValueChanged<int>? onTile;

  /// When true (and [tiles] is shown), prepend a BACK tile that drills out one
  /// level. False on a top tool-view (back there returns to the letters, which
  /// the screens layer drives by clearing [tiles]).
  final bool showBack;

  /// Tapped the BACK tile — pops one drill level. Only rendered when [showBack].
  final VoidCallback? onBack;

  const BsKeyboard({
    super.key,
    required this.onKey,
    required this.onBackspace,
    required this.onEnter,
    required this.onSend,
    this.onClose,
    this.typedText = '',
    this.onExitTools,
    this.onToggleSymbols,
    this.symbolsAlwaysToggles = false,
    this.onLanguage,
    this.showSymbols = false,
    this.english = false,
    this.showToolStrip = false,
    this.toolLayer = KbToolLayer.none,
    this.predictions = const <String>[],
    this.destinationChips = const <String>{},
    this.onToolGrid,
    this.onToolGear,
    this.onTool,
    this.onPrediction,
    this.tiles,
    this.onTile,
    this.showBack = false,
    this.onBack,
  });

  /// Dispatches a tapped [key] to the matching callback based on its [kind].
  /// Text-bearing kinds (letter / period / punct / space) insert their
  /// [KbKey.effectiveOutput]; the rest drive keyboard behaviour.
  void _route(KbKey key) {
    switch (key.kind) {
      case KeyKind.letter:
      case KeyKind.period:
      case KeyKind.punct:
      case KeyKind.space:
        onKey(key.effectiveOutput);
      case KeyKind.backspace:
        onBackspace();
      case KeyKind.enter:
        onEnter();
      case KeyKind.send:
        onSend();
      case KeyKind.symbols:
        // DUAL-MODE bottom key (owner): while a tool layer is open ([tiles] non-
        // null) the key reads "אבג" and EXITS the tools back to the letters;
        // otherwise it is the plain "?123" symbols toggle. [tiles] is null on
        // every non-floating mount, so this stays the symbols toggle there.
        // Owner button-spec v2 (#7): with [symbolsAlwaysToggles] the key ONLY
        // toggles letters↔numbers; "exit tools" moves to BACK / the ▦ toggle.
        if (tiles != null && !symbolsAlwaysToggles) {
          onExitTools?.call();
        } else {
          onToggleSymbols?.call();
        }
      case KeyKind.language:
        onLanguage?.call();
      case KeyKind.gear:
        // The bottom-row keyboard-tools launcher (moved out of the strip, owner
        // mobile redesign). Only present when [showToolStrip]; routes to the
        // same gear callback the strip used to own.
        onToolGear?.call();
    }
  }

  /// Builds one keyboard row: each key gets an [Expanded] sized by its
  /// [KbKey.flex], with small gaps between keys.
  Widget _buildRow(
    List<KbKey> keys, {
    required double gap,
    required bool compact,
  }) {
    final children = <Widget>[];
    for (var i = 0; i < keys.length; i++) {
      if (i > 0) children.add(SizedBox(width: gap));
      final key = keys[i];
      // Two keys relabel at runtime by layer/language; tap routing still uses
      // the original key. (Runtime values → `final`, not const.)
      //   • The layer-switch key: `?123` on the letter layer; `אבג`/`ABC` on the
      //     symbols layer (back to letters); AND `אבג`/`ABC` while a TOOL layer
      //     is open ([tiles] non-null) — there it EXITS the tools back to the
      //     letters (owner dual-mode key). [tiles] is null on every non-floating
      //     mount, so this stays the plain `?123`↔`אבג` symbols toggle there.
      //   • The space bar: labelled for the active language (`English` /
      //     `עברית`), keeping its `' '` output and wide flex.
      final KbKey model;
      if (key.kind == KeyKind.symbols) {
        model = KbKey(
          (showSymbols || (tiles != null && !symbolsAlwaysToggles))
              ? (english ? 'ABC' : 'אבג')
              // A narrow phone key can't fit "?123" on one line (it wraps to
              // three), so on a compact (mobile) keyboard the layer key reads the
              // shorter "123" (owner mockup); desktop keeps the full "?123".
              : (compact ? '123' : '?123'),
          kind: KeyKind.symbols,
        );
      } else if (key.kind == KeyKind.space) {
        model = KbKey(
          english ? 'English' : 'עברית',
          kind: KeyKind.space,
          output: key.effectiveOutput,
          flex: key.flex,
        );
      } else {
        model = key;
      }
      children.add(
        Expanded(
          flex: key.flex,
          child: BsKey(
            model: model,
            isAccent: key.kind == KeyKind.send,
            onTap: () => _route(key),
          ),
        ),
      );
    }
    return Row(children: children);
  }

  /// Builds the rows that fill the MAIN (grid) area above [kBottomRow].
  ///
  /// When [toolLayer] is [KbToolLayer.none] this returns EXACTLY the historical
  /// letter/symbol rows (the appended-backspace layout, byte-for-byte). When a
  /// tool layer is active it returns that layer's tool-tile rows instead — the
  /// letters/KeyKind routing are never touched in that case.
  List<Widget> _mainRows({
    required double rowGap,
    required double toolGap,
    required int tilesPerRow,
    required bool compact,
  }) {
    // MORPH path: a non-null [tiles] list replaces the whole grid with the
    // current drill node-list (pure tiles), with a leading BACK tile when asked.
    // Checked FIRST so it takes precedence over the legacy layers; when [tiles]
    // is null this whole branch is skipped and the historical render is exact.
    if (tiles != null) {
      return _tileRows(tiles!, gap: toolGap, perRow: tilesPerRow);
    }

    // Tool layers replace the letter grid (the existing layer mechanism, the
    // same idea as showSymbols). kBottomRow is added by build(), not here.
    switch (toolLayer) {
      case KbToolLayer.home:
        return _toolRows(_kHomeTools, gap: toolGap);
      case KbToolLayer.kbd:
        return _toolRows(_kKbdTools, gap: toolGap);
      case KbToolLayer.none:
        break;
    }

    // ── Default (unchanged) letter/symbol layer ──
    // The active letter/symbol layer.
    final layer =
        showSymbols ? kSymbolsRows : (english ? kEnglishRows : kHebrewRows);

    // Append a backspace to the END of the LAST layer row so it sits at the
    // right end of the bottom letter/symbol row. We copy that row rather than
    // mutate the const layout.
    const backspace = KbKey('⌫', kind: KeyKind.backspace);
    final rows = <List<KbKey>>[
      for (var i = 0; i < layer.length; i++)
        i == layer.length - 1 ? <KbKey>[...layer[i], backspace] : layer[i],
    ];

    final rowWidgets = <Widget>[];
    for (final row in rows) {
      rowWidgets.add(_buildRow(row, gap: rowGap, compact: compact));
      rowWidgets.add(SizedBox(height: rowGap));
    }
    return rowWidgets;
  }

  /// Lays the given tool [defs] out as a single [Row] of equal-width tiles
  /// (each [Expanded]) with the same small inter-key gap the letter rows use,
  /// followed by a spacer to match the letter-row rhythm. Each tile DISPLAYS
  /// its [_ToolDef.label] but calls [onTool] with its typed [_ToolDef.id].
  List<Widget> _toolRows(List<_ToolDef> defs, {required double gap}) {
    final children = <Widget>[];
    for (var i = 0; i < defs.length; i++) {
      if (i > 0) children.add(SizedBox(width: gap));
      final def = defs[i];
      children.add(
        Expanded(
          child: _ToolTile(
            icon: def.icon,
            label: def.label,
            onTap: () => onTool?.call(def.id),
          ),
        ),
      );
    }
    return <Widget>[
      Row(children: children),
      SizedBox(height: gap),
    ];
  }

  /// Lays the MORPH drill node-list out as pure tiles, wrapped at
  /// [_kTilesPerRow] per row so a variable-length children list stays readable
  /// (the legacy [_toolRows] packs a fixed 8 into ONE row; a drill view can hold
  /// any count). When [showBack] is true a BACK tile leads the FIRST row.
  ///
  /// Each tile is [Expanded] like the letter rows; the final row is padded with
  /// empty [Expanded]s so every tile keeps the same width as a full row's. Each
  /// tile DISPLAYS its [KbTile.label] and calls [onTile] with its [KbTile.id];
  /// the back tile calls [onBack].
  List<Widget> _tileRows(
    List<KbTile> tiles, {
    required double gap,
    required int perRow,
  }) {
    // Build the flat sequence of tile widgets (a leading back tile first).
    final cells = <Widget>[];
    if (showBack) {
      cells.add(
        _BackTile(onTap: onBack),
      );
    }
    for (final t in tiles) {
      cells.add(
        _ToolTile(icon: t.icon, label: t.label, onTap: () => onTile?.call(t.id)),
      );
    }

    // Chunk into rows of [perRow] (responsive: 2 on mobile, 4 on desktop),
    // padding the last row with empty slots so widths stay uniform across rows.
    final rowWidgets = <Widget>[];
    for (var start = 0; start < cells.length; start += perRow) {
      final end =
          (start + perRow) < cells.length ? start + perRow : cells.length;
      final rowCells = cells.sublist(start, end);
      final children = <Widget>[];
      for (var i = 0; i < perRow; i++) {
        if (i > 0) children.add(SizedBox(width: gap));
        children.add(
          Expanded(
            child: i < rowCells.length ? rowCells[i] : const SizedBox.shrink(),
          ),
        );
      }
      rowWidgets.add(Row(children: children));
      rowWidgets.add(SizedBox(height: gap));
    }
    return rowWidgets;
  }

  @override
  Widget build(BuildContext context) {
    // RESPONSIVE METRICS (owner mobile redesign) — a narrow (phone) viewport
    // shrinks the whole keyboard to the owner's tuned sizes; desktop keeps the
    // historical 44/20. Width is read defensively (no MediaQuery → desktop), so
    // a direct widget mount never throws and stays byte-identical.
    final double width = MediaQuery.maybeSizeOf(context)?.width ?? 9999;
    final bool mobile = width < 600;
    // Typing surface (letters · strip · bottom row): owner 30 / 19, gap 2.
    final KbCellMetrics typingScale = mobile
        ? const KbCellMetrics(cellHeight: 30, fontSize: 19, iconSize: 18)
        : KbCellMetrics.desktop;
    // Tool surface (the tile grid): owner 30 / 16, gap 1, 2-per-row.
    final KbCellMetrics toolScale = mobile
        ? const KbCellMetrics(cellHeight: 30, fontSize: 16, iconSize: 18)
        : KbCellMetrics.desktop;
    final double rowGap = mobile ? 2 : BsTokens.space1;
    final double toolGap = mobile ? 1 : BsTokens.space1;
    final int tilesPerRow = mobile ? 2 : _kTilesPerRow;

    // The MAIN area is either tool tiles (a morph drill / legacy tool layer) or
    // the letters. Tools render at the smaller [toolScale] and are height-capped
    // + scrollable so a deep drill never pushes the bottom row off-screen; the
    // letters render at the ambient [typingScale] (the outer scope).
    final bool mainIsTools = tiles != null || toolLayer != KbToolLayer.none;
    final List<Widget> mainRows = _mainRows(
      rowGap: rowGap,
      toolGap: toolGap,
      tilesPerRow: tilesPerRow,
      compact: mobile,
    );

    final List<Widget> columnChildren = <Widget>[
      // FLAGGED strip above the layer rows. Off (the default) → nothing extra,
      // so the keyboard is byte-identical to before.
      if (showToolStrip) ...<Widget>[
        _ToolStrip(
          toolLayer: toolLayer,
          predictions: predictions,
          destinationChips: destinationChips,
          typedText: typedText,
          onClose: onClose,
          onToolGrid: onToolGrid,
          onPrediction: onPrediction,
          gap: rowGap,
        ),
        SizedBox(height: rowGap),
      ],
      // The MAIN area: tool tiles (own scale + capped scroll) when active, else
      // the existing letters/symbols layer at the ambient typing scale.
      if (mainIsTools)
        BsKbScale(
          metrics: toolScale,
          child: _cappedToolArea(mainRows, context),
        )
      else
        ...mainRows,
      // The bottom action row — ALWAYS rendered. The tool-strip (floating card)
      // keyboard injects the GEAR launcher before enter (and its 123 key is the
      // dual-mode key); the plain chat keyboard keeps [kBottomRow] unchanged, so
      // it stays byte-identical.
      _buildRow(showToolStrip ? _bottomRow() : kBottomRow,
          gap: rowGap, compact: mobile),
    ];

    return BsKbScale(
      metrics: typingScale,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          // Light-orange seam fill (owner): only the keys keep their own (white)
          // fill, so every gap between them reads as a warm light orange.
          color: BsTokens.kbSeam,
          child: Padding(
            padding: EdgeInsets.all(rowGap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: columnChildren,
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom row for the tool-strip (floating card) keyboard: the historical
  /// [kBottomRow] with the GEAR launcher injected just LEFT of the enter key
  /// (owner moved ⚙️ here from the strip, beside עברית/enter). The plain keyboard
  /// keeps [kBottomRow] unchanged — this is only used when [showToolStrip].
  List<KbKey> _bottomRow() {
    const gear = KbKey('gear', kind: KeyKind.gear);
    final out = <KbKey>[];
    for (final k in kBottomRow) {
      if (k.kind == KeyKind.enter) out.add(gear); // gear sits left of enter
      out.add(k);
    }
    return out;
  }

  /// Wraps the tool tiles in a height-capped, vertically-scrollable box so a
  /// deep drill view never grows past ~⅓ of the screen and pushes the bottom
  /// action row off — the strip + bottom row stay pinned, only the tiles scroll.
  /// On desktop the cap is generous (rarely reached).
  Widget _cappedToolArea(List<Widget> rows, BuildContext context) {
    final double h = MediaQuery.maybeSizeOf(context)?.height ?? 9999;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: h * 0.34),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: rows,
        ),
      ),
    );
  }
}

/// The strip above the layer rows (owner mobile redesign): the X CLOSE on the
/// LEADING (left) edge, the merged INPUT + predictions in the middle (the
/// separate search field was removed — typing registers here), and the ▦ grid
/// toggle on the TRAILING (right) edge (it moved here; the ⚙️ gear moved to the
/// bottom row). The grid toggle is accent-highlighted when the tool layer is on.
class _ToolStrip extends StatelessWidget {
  final KbToolLayer toolLayer;
  final List<String> predictions;

  /// The subset of [predictions] that are navigable destinations (gets the nav
  /// glyph + brand accent). Empty → every chip renders as before.
  final Set<String> destinationChips;

  /// The current query text shown in the strip's middle (replaces the field).
  final String typedText;

  /// The X close (leading edge). Null → no-op.
  final VoidCallback? onClose;
  final VoidCallback? onToolGrid;
  final ValueChanged<String>? onPrediction;

  /// Responsive inter-cell gap (2 mobile / space1 desktop).
  final double gap;

  const _ToolStrip({
    required this.toolLayer,
    required this.predictions,
    required this.destinationChips,
    required this.typedText,
    required this.onClose,
    required this.onToolGrid,
    required this.onPrediction,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // LEADING (left): the X close — moved here from the panel's own row.
        _StripToggle(
          icon: Icons.close,
          active: false,
          onTap: onClose,
          semanticLabel: 'סגור מקלדת',
        ),
        SizedBox(width: gap),
        // MIDDLE: the merged input + predictions. Empty → a faint hint (no empty
        // chip row); typing → the query (RTL, brand caret) then the chips.
        Expanded(
          child: _StripInput(
            typedText: typedText,
            predictions: predictions,
            destinationChips: destinationChips,
            onPrediction: onPrediction,
            gap: gap,
          ),
        ),
        SizedBox(width: gap),
        // TRAILING (right): the ▦ grid toggle → tool mode (moved here from the
        // left). Lit (brand fill) while the home tool layer is open.
        _StripToggle(
          icon: Icons.grid_view,
          active: toolLayer == KbToolLayer.home,
          onTap: onToolGrid,
          semanticLabel: 'מחלקות',
        ),
      ],
    );
  }
}

/// The MIDDLE of the [_ToolStrip]: the merged input + prediction row. The
/// separate search field was removed (owner mobile redesign) — the typed query
/// shows HERE (RTL, plain inked text + a brand caret) with the prediction chips
/// after it. When there is NO text AND NO chips it shows a faint hint instead of
/// an empty chip row (owner: "חיזוי ריק — הסתר; הקלדה בחיזוי בלבד").
class _StripInput extends StatelessWidget {
  final String typedText;
  final List<String> predictions;
  final Set<String> destinationChips;
  final ValueChanged<String>? onPrediction;
  final double gap;

  const _StripInput({
    required this.typedText,
    required this.predictions,
    required this.destinationChips,
    required this.onPrediction,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    final KbCellMetrics m = BsKbScale.of(context);
    final bool hasText = typedText.isNotEmpty;
    final bool hasChips = predictions.isNotEmpty;

    // EMPTY (no text, no chips): a faint hint at the row height — NOT an empty
    // chip row. This is the owner's "hide the empty prediction row".
    if (!hasText && !hasChips) {
      return Container(
        alignment: Alignment.centerRight,
        constraints: BoxConstraints(minHeight: m.cellHeight),
        padding: const EdgeInsets.symmetric(horizontal: BsTokens.space2),
        child: Text(
          'מה לחפש?',
          textDirection: TextDirection.rtl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: m.fontSize,
            color: BsTokens.inkLight.withValues(alpha: 0.45),
          ),
        ),
      );
    }

    final children = <Widget>[];
    // The typed query (RTL) + a brand caret — the "input", as plain inked text
    // (distinct from the boxed chips). Flexible so it ellipsizes, never overflows.
    if (hasText) {
      children.add(
        Flexible(
          child: Container(
            alignment: Alignment.centerRight,
            constraints: BoxConstraints(minHeight: m.cellHeight),
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space2),
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: typedText),
                  const TextSpan(
                    text: '|',
                    style: TextStyle(color: BsTokens.brand),
                  ),
                ],
              ),
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.fontSize,
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
    // The prediction chips. OWNER (uniform font + "up to 4 per row, rest scroll"):
    // every chip keeps the SAME key font. Each chip is at LEAST a quarter-strip
    // wide (so ~4 sit in view) but GROWS to fit a longer label at full size rather
    // than shrinking it — so the font stays uniform chip-to-chip. Chips past what
    // fits overflow into the horizontal scroll.
    if (hasChips) {
      if (hasText) children.add(SizedBox(width: gap));
      children.add(
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const maxVisible = 4;
              final visible = predictions.length < maxVisible
                  ? predictions.length
                  : maxVisible;
              // Baseline width so [visible] chips + their gaps fill the strip; a
              // chip only ever GROWS past this (for a long label), never shrinks
              // below it — keeping ~4 in view with the rest in horizontal scroll.
              final chipW =
                  (constraints.maxWidth - gap * (visible - 1)) / visible;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: <Widget>[
                    for (var i = 0; i < predictions.length; i++) ...<Widget>[
                      if (i > 0) SizedBox(width: gap),
                      ConstrainedBox(
                        constraints: BoxConstraints(minWidth: chipW),
                        child: _PredictionChip(
                          text: predictions[i],
                          isDestination:
                              destinationChips.contains(predictions[i]),
                          onTap: () => onPrediction?.call(predictions[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
    return Row(textDirection: TextDirection.rtl, children: children);
  }
}

/// A square icon toggle at either end of the [_ToolStrip]. Renders in the
/// keyboard key style (white fill, hairline border, rounded) — but switches to
/// the brand-accent fill when [active] so the user sees which tool layer is on.
class _StripToggle extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;
  final String semanticLabel;

  const _StripToggle({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = active ? BsTokens.brand : Colors.white;
    final Color fg = active ? bsOnAccent(context) : BsTokens.inkLight;
    final KbCellMetrics m = BsKbScale.of(context);
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
        child: Semantics(
          button: true,
          selected: active,
          label: semanticLabel,
          child: Container(
            constraints:
                BoxConstraints(minHeight: m.cellHeight, minWidth: m.cellHeight),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
              border: active ? null : Border.all(color: BsTokens.divider),
            ),
            child: Icon(icon, size: m.iconSize, color: fg),
          ),
        ),
      ),
    );
  }
}

/// A single prediction chip in the middle of the [_ToolStrip]. Keyboard key
/// styling (white fill, hairline border, rounded); shows its text on one line
/// with ellipsis so a long suggestion never overflows the strip.
///
/// "FITTING PREDICTION" distinction: a chip is EITHER a navigable DESTINATION (a
/// tap navigates) or a product WORD (a tap narrows the query). When
/// [isDestination] is true the chip reads as a one-tap nav target — a small
/// leading [Icons.north_east] glyph (brand-tinted) precedes the text, the
/// hairline border becomes a thin brand border, and the fill gets a faint
/// brand wash — mirroring the [_BackTile] brand affordance. When false (the
/// DEFAULT for every chip, and for every chip while [destinationChips] is empty)
/// it renders EXACTLY as before — byte-identical: a centered single [Text] with
/// the hairline [BsTokens.divider] border and white fill, no glyph.
class _PredictionChip extends StatelessWidget {
  final String text;

  /// When true, render the nav-target affordance (leading glyph + brand accent);
  /// when false (default), render byte-identically to the historical chip.
  final bool isDestination;
  final VoidCallback? onTap;

  const _PredictionChip({
    required this.text,
    this.isDestination = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final KbCellMetrics m = BsKbScale.of(context);
    // The shared text label — identical styling in both branches, so a
    // destination chip and a word chip read the same except for the affordance.
    // OWNER (uniform font): the chip keeps the SAME key font as every other tile —
    // NEVER shrink-to-fit (that made long suggestions render smaller than short
    // ones). The strip lays chips at their natural width and scrolls horizontally,
    // so a long label stays full-size and fully readable rather than squeezed.
    final label = Text(
      text,
      maxLines: 1,
      softWrap: false,
      textAlign: TextAlign.center,
      style: TextStyle(
        // Uniform with the keys; responsive (desktop 20, mobile 19 — owner spec).
        fontSize: m.fontSize,
        color: BsTokens.inkLight,
        fontWeight: FontWeight.w500,
      ),
    );

    // DEFAULT (word / empty destinationChips): EXACTLY the historical render —
    // white Material, hairline divider border, centered single Text, no glyph.
    if (!isDestination) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
          child: Semantics(
            button: true,
            label: '$text (חיפוש)',
            child: Container(
              constraints: BoxConstraints(minHeight: m.cellHeight),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: BsTokens.space2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
                border: Border.all(color: BsTokens.divider),
              ),
              child: label,
            ),
          ),
        ),
      );
    }

    // DESTINATION: a one-tap nav target. Leading north-east glyph + a thin brand
    // border + a faint brand wash. Kept compact — one line, ellipsis preserved
    // (the label stays Flexible inside a centered, min-width Row).
    final radius = BorderRadius.circular(BsTokens.radiusCard / 2);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Semantics(
          button: true,
          label: '$text (ניווט)',
          child: Container(
            constraints: BoxConstraints(minHeight: m.cellHeight),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space2),
            decoration: BoxDecoration(
              // Faint brand wash so the destination reads as accented without
              // shouting over the neutral keyboard.
              color: BsTokens.brand.withOpacity(0.06),
              borderRadius: radius,
              border: Border.all(color: BsTokens.brand),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(child: label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A tool tile shown in a tool LAYER (home/kbd): a Material [icon] above its
/// [label], in the keyboard key style (white fill, hairline border, rounded).
/// Tapping calls back with the label (no navigation yet — STEP 1). It is a
/// distinct widget from [BsKey] so existing `find.byType(BsKey)` key-count
/// tests stay exact even when a tool layer is shown.
class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ToolTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final KbCellMetrics m = BsKbScale.of(context);
    // Vertical padding shrinks on mobile so the tile sits at the responsive
    // cellHeight (30) instead of growing past it; desktop keeps space2 (the
    // minHeight 44 dominates either way there, so desktop is byte-identical).
    final double vpad = m.cellHeight >= 44 ? BsTokens.space2 : BsTokens.spaceHair;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
        child: Semantics(
          button: true,
          label: label,
          child: Container(
            constraints: BoxConstraints(minHeight: m.cellHeight),
            padding: EdgeInsets.symmetric(
              vertical: vpad,
              horizontal: BsTokens.space1,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
              border: Border.all(color: BsTokens.divider),
            ),
            child: Row(
              // Owner: the symbol/emoji sits on the SIDE with the phrase beside
              // it (RTL → icon on the right, label to its left), and the label is
              // bigger — a horizontal tile, not the old stacked icon-over-label.
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: m.iconSize, color: BsTokens.inkLight),
                const SizedBox(width: BsTokens.space1),
                Flexible(
                  // OWNER (uniform font, ALL keyboard screens): keep EVERY tile at
                  // the same key font — never shrink a long label (that made the
                  // font look non-uniform tile-to-tile). A label that does not fit
                  // WRAPS to a second line instead; the Row sizes every tile in the
                  // row to the same height, so the grid stays even.
                  child: Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: m.fontSize,
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The BACK tile that leads a MORPH drill view ([_tileRows] with `showBack`).
/// Same key-style shell as [_ToolTile] but an arrow-back glyph + 'חזרה' label,
/// tinted with the brand colour so the drill-out affordance reads as distinct
/// from the navigable tool tiles. Tapping pops one drill level ([onBack]).
class _BackTile extends StatelessWidget {
  final VoidCallback? onTap;

  const _BackTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final KbCellMetrics m = BsKbScale.of(context);
    final double vpad = m.cellHeight >= 44 ? BsTokens.space2 : BsTokens.spaceHair;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
        child: Semantics(
          button: true,
          label: 'חזרה',
          child: Container(
            constraints: BoxConstraints(minHeight: m.cellHeight),
            padding: EdgeInsets.symmetric(
              vertical: vpad,
              horizontal: BsTokens.space1,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
              border: Border.all(color: BsTokens.brand),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.arrow_back,
                  size: m.iconSize,
                  color: BsTokens.brand,
                ),
                const SizedBox(width: BsTokens.space1),
                Flexible(
                  child: Text(
                    'חזרה',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: m.fontSize,
                      color: BsTokens.brand,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
