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

  /// Tapped the grid-toggle (left of the strip, [Icons.grid_view]).
  final VoidCallback? onToolGrid;

  /// Tapped the gear-toggle (right of the strip, [Icons.settings]).
  final VoidCallback? onToolGear;

  /// Tapped a tool tile — receives the tile's typed [KbTool] id. The single
  /// keyboard→app coupling point ([runKeyboardTool]) switches on this id.
  final ValueChanged<KbTool>? onTool;

  /// Tapped a prediction chip — receives the chip's text.
  final ValueChanged<String>? onPrediction;

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
    this.onToolGrid,
    this.onToolGear,
    this.onTool,
    this.onPrediction,
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

  @override
  Widget build(BuildContext context) {
    final rowWidgets = <Widget>[
      // FLAGGED strip above the layer rows. Off (the default) → nothing extra,
      // so the keyboard is byte-identical to before.
      if (showToolStrip) ...<Widget>[
        _ToolStrip(
          toolLayer: toolLayer,
          predictions: predictions,
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
        color: BsTokens.surfaceMid,
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
  final VoidCallback? onToolGrid;
  final VoidCallback? onToolGear;
  final ValueChanged<String>? onPrediction;

  const _ToolStrip({
    required this.toolLayer,
    required this.predictions,
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
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
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
class _PredictionChip extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _PredictionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: BsTokens.space2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
            border: Border.all(color: BsTokens.divider),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w500,
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
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(
              vertical: BsTokens.space2,
              horizontal: BsTokens.space1,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard / 2),
              border: Border.all(color: BsTokens.divider),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: BsTokens.dialIconSize, color: BsTokens.inkLight),
                const SizedBox(height: BsTokens.spaceHair),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: BsTokens.typeMicro,
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w500,
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
