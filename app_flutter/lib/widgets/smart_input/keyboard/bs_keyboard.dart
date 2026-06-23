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

  /// Toggle between the letter and `?123` symbols layers. The single
  /// layer-switch key — labelled `?123` on letters, `אבג` on symbols — routes
  /// here (there is no second toggle key).
  final VoidCallback? onToggleSymbols;

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
    this.onToggleSymbols,
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
        onToggleSymbols?.call();
      case KeyKind.language:
        onLanguage?.call();
    }
  }

  /// Builds one keyboard row: each key gets an [Expanded] sized by its
  /// [KbKey.flex], with small gaps between keys.
  Widget _buildRow(List<KbKey> keys) {
    final children = <Widget>[];
    for (var i = 0; i < keys.length; i++) {
      if (i > 0) children.add(const SizedBox(width: BsTokens.space1));
      final key = keys[i];
      // Two keys relabel at runtime by layer/language; tap routing still uses
      // the original key. (Runtime values → `final`, not const.)
      //   • The layer-switch key: `?123` on the letter layer, and the
      //     back-to-letters label matches the active language on the symbols
      //     layer (`ABC` in English, `אבג` in Hebrew) — ONE toggle key (like
      //     real keyboards), never two.
      //   • The space bar: labelled for the active language (`English` /
      //     `עברית`), keeping its `' '` output and wide flex.
      final KbKey model;
      if (key.kind == KeyKind.symbols) {
        model = KbKey(
          showSymbols ? (english ? 'ABC' : 'אבג') : '?123',
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
  List<Widget> _mainRows() {
    // MORPH path: a non-null [tiles] list replaces the whole grid with the
    // current drill node-list (pure tiles), with a leading BACK tile when asked.
    // Checked FIRST so it takes precedence over the legacy layers; when [tiles]
    // is null this whole branch is skipped and the historical render is exact.
    if (tiles != null) {
      return _tileRows(tiles!);
    }

    // Tool layers replace the letter grid (the existing layer mechanism, the
    // same idea as showSymbols). kBottomRow is added by build(), not here.
    switch (toolLayer) {
      case KbToolLayer.home:
        return _toolRows(_kHomeTools);
      case KbToolLayer.kbd:
        return _toolRows(_kKbdTools);
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
      rowWidgets.add(_buildRow(row));
      rowWidgets.add(const SizedBox(height: BsTokens.space1));
    }
    return rowWidgets;
  }

  /// Lays the given tool [defs] out as a single [Row] of equal-width tiles
  /// (each [Expanded]) with the same small inter-key gap the letter rows use,
  /// followed by a spacer to match the letter-row rhythm. Each tile DISPLAYS
  /// its [_ToolDef.label] but calls [onTool] with its typed [_ToolDef.id].
  List<Widget> _toolRows(List<_ToolDef> defs) {
    final children = <Widget>[];
    for (var i = 0; i < defs.length; i++) {
      if (i > 0) children.add(const SizedBox(width: BsTokens.space1));
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
      const SizedBox(height: BsTokens.space1),
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
  List<Widget> _tileRows(List<KbTile> tiles) {
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

    // Chunk into rows of [_kTilesPerRow], padding the last row with empty slots
    // so widths stay uniform across rows.
    final rowWidgets = <Widget>[];
    for (var start = 0; start < cells.length; start += _kTilesPerRow) {
      final end =
          (start + _kTilesPerRow) < cells.length
              ? start + _kTilesPerRow
              : cells.length;
      final rowCells = cells.sublist(start, end);
      final children = <Widget>[];
      for (var i = 0; i < _kTilesPerRow; i++) {
        if (i > 0) children.add(const SizedBox(width: BsTokens.space1));
        children.add(
          Expanded(
            child: i < rowCells.length ? rowCells[i] : const SizedBox.shrink(),
          ),
        );
      }
      rowWidgets.add(Row(children: children));
      rowWidgets.add(const SizedBox(height: BsTokens.space1));
    }
    return rowWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final rowWidgets = <Widget>[
      // FLAGGED strip above the layer rows. Off (the default) → nothing extra,
      // so the keyboard is byte-identical to before.
      if (showToolStrip) ...<Widget>[
        _ToolStrip(
          toolLayer: toolLayer,
          predictions: predictions,
          destinationChips: destinationChips,
          onToolGrid: onToolGrid,
          onToolGear: onToolGear,
          onPrediction: onPrediction,
        ),
        const SizedBox(height: BsTokens.space1),
      ],
      // The MAIN area: a tool layer when one is active, else the existing
      // letters/symbols layer — unchanged.
      ..._mainRows(),
      // The bottom action row (send · ?123 · globe · space · period · enter) —
      // ALWAYS rendered, on every layer.
      _buildRow(kBottomRow),
    ];

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        // Light-orange seam fill (owner): only the keys keep their own (white)
        // fill, so every gap between them reads as a warm light orange.
        color: BsTokens.kbSeam,
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rowWidgets,
          ),
        ),
      ),
    );
  }
}

/// The FLAGGED strip above the layer rows: a grid-layer toggle on the leading
/// edge, the predictions in the middle (rendered as-is, NO horizontal scroll),
/// and a keyboard-tools (gear) toggle on the trailing edge. Each toggle is
/// accent-highlighted when its layer is the active one.
class _ToolStrip extends StatelessWidget {
  final KbToolLayer toolLayer;
  final List<String> predictions;

  /// The subset of [predictions] that are navigable destinations (gets the nav
  /// glyph + brand accent). Empty → every chip renders as before.
  final Set<String> destinationChips;
  final VoidCallback? onToolGrid;
  final VoidCallback? onToolGear;
  final ValueChanged<String>? onPrediction;

  const _ToolStrip({
    required this.toolLayer,
    required this.predictions,
    required this.destinationChips,
    required this.onToolGrid,
    required this.onToolGear,
    required this.onPrediction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _StripToggle(
          icon: Icons.grid_view,
          active: toolLayer == KbToolLayer.home,
          onTap: onToolGrid,
          semanticLabel: 'מחלקות',
        ),
        const SizedBox(width: BsTokens.space1),
        // Predictions fill the middle. The given list is rendered as-is with no
        // horizontal scroll — each chip is Expanded so a short list spreads and
        // a long one shares the width evenly (and clips its own text if needed).
        Expanded(
          child: Row(
            children: <Widget>[
              for (var i = 0; i < predictions.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: BsTokens.space1),
                Expanded(
                  child: _PredictionChip(
                    text: predictions[i],
                    isDestination: destinationChips.contains(predictions[i]),
                    onTap: () => onPrediction?.call(predictions[i]),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: BsTokens.space1),
        _StripToggle(
          icon: Icons.settings,
          active: toolLayer == KbToolLayer.kbd,
          onTap: onToolGear,
          semanticLabel: 'כלי מקלדת',
        ),
      ],
    );
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
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
              border: active ? null : Border.all(color: BsTokens.divider),
            ),
            child: Icon(icon, size: BsTokens.dialIconSize, color: fg),
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
    // The shared text label — identical styling in both branches, so a
    // destination chip and a word chip read the same except for the affordance.
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(
        // Owner: uniform 20px text across the whole keyboard (was 15 on chips).
        fontSize: 20,
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
              constraints: const BoxConstraints(minHeight: 44),
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
            constraints: const BoxConstraints(minHeight: 44),
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
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(
              vertical: BsTokens.space2,
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
                Icon(icon, size: BsTokens.dialIconSize, color: BsTokens.inkLight),
                const SizedBox(width: BsTokens.space1),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 20,
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
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(
              vertical: BsTokens.space2,
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
                  size: BsTokens.dialIconSize,
                  color: BsTokens.brand,
                ),
                const SizedBox(width: BsTokens.space1),
                const Flexible(
                  child: Text(
                    'חזרה',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 20,
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
