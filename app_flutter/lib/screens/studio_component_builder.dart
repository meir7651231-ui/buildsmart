// ─────────────────────────────────────────────────────────────────────────────
// StudioComponentBuilder — BuildSmart Studio · Pillar 4 · step 82. The manual,
// NO-MODEL builder: the pillar's MVP — no-code editing that works with `kClaudeAi`
// OFF (the builder NEVER reads `claudeGatewayProvider`; §8).
//
// THE FLOW (§2): pick an element id (over the frozen `ElementRegistryView`) → pick
// an edit — a prop (text / emoji / style-color from `allowedValues`), visibility
// (SetHidden), an action (from the step-72 `kActionCatalog`; typed-arg screens are
// GREYED "צריך פרמטרים — לא זמין", R1-5 — never dropped), or a component (from the
// step-73 `kComponentPalette`, validated for preview) → PREVIEW (validateSafe →
// summarizeDiff, recomputed FREE on every change, §6) → CONFIRM (a single tracked
// tap → P1 `applyOps` ONCE, R1-4) → UNDO/REDO (P1's undo-stack, the SSOT — §9).
//
// THE ONE INVARIANT (R1-4 · DoD §8): writes go ONLY through Pillar-1's
// `configStoreProvider.notifier.applyOps` — there is NO P4-local apply. Undo is
// `notifier.undo()` (P1's stack); our `_mirror` op-history is a DISPLAY MIRROR only,
// never a parallel source of truth (§9). The confirm-gate mirrors `_confirmAdd`'s
// `_confirmedKitTurns` guard (ai_assistant_screen.dart:71,210,223): one explicit,
// tracked tap → apply once, so a double-tap can never write twice.
//
// FROZEN-FAMILY RECONCILIATION (documented, matching diff_preview.dart's own note):
// P1's `ConfigOp` family is the 6 Set-axis ops — there is NO `AddComponent` variant.
// So the component category is a GROUNDED, validated PREVIEW (over `validateAddCom
// ponent`); placing a component applies once P1 exposes that op. text/emoji/
// visibility produce ops that apply; style-color/action are grounded + previewed and
// (on the seed registry, whose `allowedValues`/`allowedActions` are empty) safely
// BLOCKED by `validateSafe` — the backstop working, surfaced as "נחסמו K" (§4).
//
// §10 draft badge: the Studio edits the DRAFT only; publish is a SEPARATE Pillar-1
// gate, so a "טיוטה" badge is always shown. All colors from `BsTokens` (the color-
// ratchet — zero raw hex literals). No Firebase, no gateway.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/studio/action_catalog.dart'
    show ActionDescriptor, kActionCatalog, kNavScreenIds;
import 'package:buildsmart/logic/studio/component_palette.dart'
    show
        AddComponentRequest,
        ComponentTemplate,
        ComponentType,
        kComponentPalette,
        validateAddComponent;
import 'package:buildsmart/logic/studio/diff_preview.dart'
    show DiffLine, summarizeDiff;
import 'package:buildsmart/logic/studio/edit_safety.dart'
    show SafetyVerdict, validateSafe;
import 'package:buildsmart/logic/studio/registry_view.dart'
    show ElementRegistryView, RegistryView;
import 'package:buildsmart/state/studio/config_node.dart'
    show CfgAction, CfgStyle;
import 'package:buildsmart/state/studio/config_store.dart'
    show
        ConfigOp,
        ConfigStore,
        SetAction,
        SetEmoji,
        SetHidden,
        SetStyle,
        SetText,
        configStoreProvider;
import 'package:buildsmart/state/studio/element_registry.dart'
    show EditAxis, ElementDescriptor, findDescriptor, kElementRegistry;
import 'package:buildsmart/theme/app_theme.dart' show bsOnAccent;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The category of edit the owner is composing — each maps to ONE P1 `ConfigOp`
/// (except [component], which is a validated preview — P1's frozen family has no
/// `AddComponent`, see the file header).
enum _EditKind { text, emoji, color, visibility, action, component }

/// A few REAL typed-arg screens (need per-screen args → out-of-v1). They are NOT in
/// [kNavScreenIds]; the action-picker shows them GREYED "צריך פרמטרים — לא זמין"
/// (R1-5) rather than dropping them silently. All three exist in the tree.
const List<String> _kTypedArgScreens = <String>[
  'AiFinderScreen',
  'RejectReasonScreen',
  'LipskeySectionScreen',
];

/// The manual (no-model) Studio builder — mounted in `StudioScreen`'s 🛠️ tab.
class StudioComponentBuilder extends ConsumerStatefulWidget {
  const StudioComponentBuilder({super.key});

  @override
  ConsumerState<StudioComponentBuilder> createState() =>
      _StudioComponentBuilderState();
}

class _StudioComponentBuilderState
    extends ConsumerState<StudioComponentBuilder> {
  // The frozen grounding source (R1-2) — the SAME registry `validateSafe` /
  // `summarizeDiff` use, so the pick-options and the preview never disagree.
  final RegistryView _registry = ElementRegistryView.builtIn();

  final TextEditingController _textCtrl = TextEditingController();
  final TextEditingController _emojiCtrl = TextEditingController();

  String? _elementId;
  _EditKind? _kind;
  String? _colorToken;
  bool? _hide;
  String? _actionId; // a catalog action id (kActionCatalog)
  String? _navTarget; // a screen id (only for action id 'nav.screen')
  ComponentType? _componentType;

  // ── the confirm-gate (mirror of `_confirmedKitTurns`, ai_assistant_screen.dart:
  // 71,223): every distinct pending selection is a "turn"; a turn already in the
  // set was applied → a re-tap is a no-op, so a double-tap can't write twice.
  int _turn = 0;
  final Set<int> _confirmedTurns = <int>{};

  // §9 — a DISPLAY MIRROR of applied edits (for the owner to read). NOT a source of
  // truth: undo/redo is P1's stack, this list is cosmetic only.
  final List<String> _mirror = <String>[];

  @override
  void dispose() {
    _textCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  /// Bump the pending "turn" and rebuild — called on every selection change, so a
  /// changed op is a fresh (re-confirmable) proposal and the preview recomputes.
  void _touch(VoidCallback fn) => setState(() {
        fn();
        _turn++;
      });

  void _resetSub() {
    _colorToken = null;
    _hide = null;
    _actionId = null;
    _navTarget = null;
    _componentType = null;
    _textCtrl.clear();
    _emojiCtrl.clear();
  }

  void _pickElement(String? id) => _touch(() {
        _elementId = id;
        _kind = null;
        _resetSub();
      });

  void _pickCategory(_EditKind k) => _touch(() {
        _kind = k;
        _resetSub();
      });

  // ── op construction (each pick → ONE P1 ConfigOp; component → none) ──

  /// The ops the current selection proposes (0 or 1). Pure — recomputed every build
  /// (preview is free, §6) and again at confirm time (so confirm sees the live set).
  List<ConfigOp> _buildOps() {
    final id = _elementId;
    if (id == null || _kind == null) return const <ConfigOp>[];
    switch (_kind!) {
      case _EditKind.text:
        final t = _textCtrl.text;
        return t.isEmpty ? const [] : [SetText(id, t)];
      case _EditKind.emoji:
        final e = _emojiCtrl.text;
        return e.isEmpty ? const [] : [SetEmoji(id, e)];
      case _EditKind.color:
        final tok = _colorToken;
        return tok == null ? const [] : [SetStyle(id, CfgStyle(colorToken: tok))];
      case _EditKind.visibility:
        final h = _hide;
        return h == null ? const [] : [SetHidden(id, h)];
      case _EditKind.action:
        final op = _buildActionOp(id);
        return op == null ? const [] : [op];
      case _EditKind.component:
        // P1's frozen ConfigOp family has NO AddComponent — component-add is a
        // validated preview only (see the file header). No op is emitted.
        return const <ConfigOp>[];
    }
  }

  /// A `SetAction` from the grounded catalog id — `CfgAction.kind` carries the
  /// catalog action id (the identifier `validateSafe` grounds against the element's
  /// legal action set). A nav.screen also carries the chosen no-arg screen in `args`.
  ConfigOp? _buildActionOp(String id) {
    final a = _actionId;
    if (a == null) return null;
    if (a == 'nav.screen') {
      final target = _navTarget;
      if (target == null) return null;
      return SetAction(id, CfgAction(kind: a, args: {'screen': target}));
    }
    return SetAction(id, CfgAction(kind: a));
  }

  // ── the confirm-gate → P1 applyOps ONCE (R1-4) ──

  void _confirm() {
    final verdict = validateSafe(_buildOps());
    final applied = verdict.applied;
    if (applied.isEmpty) return; // nothing safe to apply
    if (_confirmedTurns.contains(_turn)) return; // double-tap guard (mirror)
    _confirmedTurns.add(_turn);
    // THE single write path (R1-4): P1 owns the apply + the undo-stack; we never
    // mutate the draft locally. Pass ONLY the safe (verdict.applied) ops.
    ref.read(configStoreProvider.notifier).applyOps(applied);
    setState(() => _mirror.insert(0, _mirrorLabel(applied)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('הוחל — ${applied.length} שינוי בטיוטה ✓'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _mirrorLabel(List<ConfigOp> ops) {
    final rows = summarizeDiff(ops, _registry);
    return rows.isEmpty ? 'שינוי' : rows.first.he;
  }

  // ── undo/redo → P1's SSOT stack (§9); the mirror is display-only ──

  void _undo() {
    ref.read(configStoreProvider.notifier).undo();
    setState(() {
      if (_mirror.isNotEmpty) _mirror.removeAt(0);
    });
  }

  void _redo() {
    ref.read(configStoreProvider.notifier).redo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild on any config change → fresh canUndo/canRedo + draft badge. The undo
    // stack only moves alongside a state change, so reading the notifier here is
    // always current.
    final doc = ref.watch(configStoreProvider);
    final notifier = ref.read(configStoreProvider.notifier);

    final d = _elementId == null
        ? null
        : findDescriptor(kElementRegistry, _elementId!);

    // §6 — preview is FREE: recompute the whole pipeline every build.
    final ops = _buildOps();
    final verdict = validateSafe(ops);
    final preview = summarizeDiff(ops, _registry, verdict: verdict);

    return ListView(
      padding: const EdgeInsets.all(BsTokens.space4),
      children: [
        _header(doc.draft.global.length),
        const SizedBox(height: BsTokens.space3),
        _elementPicker(),
        if (d != null) ...[
          const SizedBox(height: BsTokens.space3),
          _descriptorCard(d),
          const SizedBox(height: BsTokens.space3),
          _categorySelector(d),
          const SizedBox(height: BsTokens.space3),
          _categoryInput(d),
          const SizedBox(height: BsTokens.space4),
          _previewCard(preview, verdict),
          const SizedBox(height: BsTokens.space3),
          _actionsBar(canApply: verdict.applied.isNotEmpty, notifier: notifier),
          if (_mirror.isNotEmpty) ...[
            const SizedBox(height: BsTokens.space3),
            _historyCard(),
          ],
        ],
      ],
    );
  }

  // ── header + draft badge (§10) ──

  Widget _header(int dirtyCount) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '🛠️ בונה ידני — ללא מודל',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space3,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
          child: Text(
            dirtyCount > 0 ? 'טיוטה · $dirtyCount' : 'טיוטה',
            style: const TextStyle(
              color: BsTokens.warnText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ── element picker (over the closed registry) ──

  Widget _elementPicker() {
    return _panel(
      title: '1 · בחר אלמנט',
      child: DropdownButton<String>(
        key: const Key('studio-el-picker'),
        value: _elementId,
        isExpanded: true,
        hint: const Text('בחר רכיב לעריכה…'),
        underline: const SizedBox.shrink(),
        items: [
          for (final e in kElementRegistry)
            DropdownMenuItem<String>(
              value: e.id,
              child: Text(
                e.labelHe,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: BsTokens.inkLight),
              ),
            ),
        ],
        onChanged: _pickElement,
      ),
    );
  }

  Widget _descriptorCard(ElementDescriptor d) {
    return _panel(
      title: 'הרכיב הנבחר',
      child: Text(
        '${d.labelHe}\nמזהה: ${d.id} · סוג: ${d.kind.name} · מסך: ${d.screen}'
        '${d.kImmutable ? ' · 🔒 נעול' : ''}',
        style: const TextStyle(
          color: BsTokens.mutedLight,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }

  // ── category selector (filtered by the element's editableProps) ──

  bool _catAvailable(_EditKind k, ElementDescriptor d) {
    switch (k) {
      case _EditKind.text:
        return d.editableProps.contains(EditAxis.text);
      case _EditKind.emoji:
        return d.editableProps.contains(EditAxis.emoji);
      case _EditKind.color:
        return d.editableProps.contains(EditAxis.style);
      case _EditKind.visibility:
      case _EditKind.action:
      case _EditKind.component:
        return true;
    }
  }

  static const Map<_EditKind, (String, String)> _catLabel = {
    _EditKind.text: ('📝', 'טקסט'),
    _EditKind.emoji: ('😀', 'אמוג׳י'),
    _EditKind.color: ('🎨', 'צבע'),
    _EditKind.visibility: ('🙈', 'נראות'),
    _EditKind.action: ('⚙️', 'פעולה'),
    _EditKind.component: ('➕', 'רכיב'),
  };

  Widget _categorySelector(ElementDescriptor d) {
    return _panel(
      title: '2 · בחר סוג עריכה',
      child: Wrap(
        spacing: BsTokens.space2,
        runSpacing: BsTokens.space2,
        children: [
          for (final k in _EditKind.values)
            if (_catAvailable(k, d))
              ChoiceChip(
                key: Key('studio-cat-${k.name}'),
                label: Text('${_catLabel[k]!.$1} ${_catLabel[k]!.$2}'),
                selected: _kind == k,
                onSelected: (_) => _pickCategory(k),
              ),
        ],
      ),
    );
  }

  // ── per-category input ──

  Widget _categoryInput(ElementDescriptor d) {
    switch (_kind) {
      case null:
        return const SizedBox.shrink();
      case _EditKind.text:
        return _panel(
          title: '3 · טקסט חדש',
          child: TextField(
            key: const Key('studio-text-field'),
            controller: _textCtrl,
            maxLength: 80,
            decoration: const InputDecoration(
              hintText: 'הקלד טקסט…',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _touch(() {}),
          ),
        );
      case _EditKind.emoji:
        return _panel(
          title: '3 · אמוג׳י חדש',
          child: TextField(
            key: const Key('studio-emoji-field'),
            controller: _emojiCtrl,
            maxLength: 8,
            decoration: const InputDecoration(
              hintText: 'הדבק אמוג׳י…',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _touch(() {}),
          ),
        );
      case _EditKind.color:
        return _colorInput(d);
      case _EditKind.visibility:
        return _visibilityInput();
      case _EditKind.action:
        return _actionInput(d);
      case _EditKind.component:
        return _componentInput(d);
    }
  }

  Widget _colorInput(ElementDescriptor d) {
    // Closed value set from the registry (`allowedValues(id,'color')`). Empty on the
    // seed registry ⇒ nothing to pick (fail-closed) — a future domain registry that
    // populates it lights the chips up automatically.
    final tokens = _registry.allowedValues(d.id, 'color').toList()..sort();
    return _panel(
      title: '3 · צבע (מתוך הערכים החוקיים לרכיב)',
      child: tokens.isEmpty
          ? const Text(
              'אין ערכי צבע מוגדרים לרכיב זה (fail-closed).',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            )
          : Wrap(
              spacing: BsTokens.space2,
              runSpacing: BsTokens.space2,
              children: [
                for (final tok in tokens)
                  ChoiceChip(
                    key: Key('studio-color-$tok'),
                    label: Text(tok),
                    selected: _colorToken == tok,
                    onSelected: (_) => _touch(() => _colorToken = tok),
                  ),
              ],
            ),
    );
  }

  Widget _visibilityInput() {
    return _panel(
      title: '3 · נראות',
      child: Wrap(
        spacing: BsTokens.space2,
        children: [
          ChoiceChip(
            key: const Key('studio-vis-hide'),
            label: const Text('🙈 הסתר'),
            selected: _hide ?? false,
            onSelected: (_) => _touch(() => _hide = true),
          ),
          ChoiceChip(
            key: const Key('studio-vis-show'),
            label: const Text('👁️ הצג'),
            selected: _hide == false,
            onSelected: (_) => _touch(() => _hide = false),
          ),
        ],
      ),
    );
  }

  Widget _actionInput(ElementDescriptor d) {
    return _panel(
      title: '3 · פעולה (מתוך קטלוג הפעולות)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: BsTokens.space2,
            runSpacing: BsTokens.space2,
            children: [
              for (final ActionDescriptor a in kActionCatalog)
                ChoiceChip(
                  key: Key('studio-action-${a.id}'),
                  label: Text(a.he),
                  selected: _actionId == a.id,
                  onSelected: (_) => _touch(() {
                    _actionId = a.id;
                    _navTarget = null;
                  }),
                ),
            ],
          ),
          if (_actionId == 'nav.screen') ...[
            const SizedBox(height: BsTokens.space3),
            const Text(
              'בחר מסך-יעד (מסכי-פרמטר מאופרים — צריך פרמטרים):',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            const SizedBox(height: BsTokens.space2),
            _navTargetPicker(),
          ],
        ],
      ),
    );
  }

  /// The nav-screen target picker. The ~38 no-arg [kNavScreenIds] are SELECTABLE;
  /// the typed-arg screens are GREYED-disabled with "צריך פרמטרים — לא זמין" (R1-5)
  /// — never dropped. A `Column` in a scroll builds EVERY tile (so a greyed entry is
  /// always present, not lazily culled).
  Widget _navTargetPicker() {
    final navScreens = kNavScreenIds.toList()..sort();
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: BsTokens.divider),
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: SizedBox(
        height: 200,
        // A transparent Material so the ListTiles have a Material ancestor with no
        // intervening background (else the panel's colored box hides their ink).
        child: Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // typed-arg — greyed / not selectable (R1-5), shown FIRST.
              for (final s in _kTypedArgScreens)
                ListTile(
                  key: Key('studio-nav-$s'),
                  enabled: false,
                  dense: true,
                  title: Text(
                    s,
                    style: const TextStyle(color: BsTokens.mutedLight),
                  ),
                  subtitle: const Text(
                    'צריך פרמטרים — לא זמין',
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 11),
                  ),
                ),
              const Divider(height: 1, color: BsTokens.divider),
              // no-arg screens — selectable.
              for (final s in navScreens)
                ListTile(
                  key: Key('studio-nav-$s'),
                  dense: true,
                  selected: _navTarget == s,
                  title: Text(
                    s,
                    style: const TextStyle(color: BsTokens.inkLight),
                  ),
                  onTap: () => _touch(() => _navTarget = s),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _componentInput(ElementDescriptor d) {
    // No AddComponent op in P1's frozen family — this is a GROUNDED, validated
    // PREVIEW (validateAddComponent) over the closed palette. The verdict shows
    // whether the pick is legal for the target container (on the seed registry a
    // text/action element rejects a content-only component — fail-closed).
    final type = _componentType;
    String? verdictHe;
    if (type != null) {
      final v = validateAddComponent(
        AddComponentRequest(type: type),
        container: d.kind,
      );
      verdictHe = v.ok
          ? '✓ חוקי להוספה (יופעל עם שער ה-AddComponent של Pillar 1)'
          : '⛔ ${v.reasonHe}';
    }
    return _panel(
      title: '3 · רכיב להוספה (תצוגה מקדימה — ללא op בגרסה זו)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: BsTokens.space2,
            runSpacing: BsTokens.space2,
            children: [
              for (final ComponentTemplate t in kComponentPalette)
                ChoiceChip(
                  key: Key('studio-comp-${t.type.name}'),
                  label: Text(t.he),
                  selected: _componentType == t.type,
                  onSelected: (_) => _touch(() => _componentType = t.type),
                ),
            ],
          ),
          if (verdictHe != null) ...[
            const SizedBox(height: BsTokens.space2),
            Text(
              verdictHe,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // ── preview (§4/§6) ──

  Widget _previewCard(List<DiffLine> preview, SafetyVerdict verdict) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '👁️ תצוגה מקדימה (לפני החלה)',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          if (preview.isEmpty)
            const Text(
              'בחר עריכה כדי לראות תצוגה מקדימה.',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            )
          else
            for (final row in preview)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${row.he}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13,
                  ),
                ),
              ),
          // §4/§6 — every BLOCK carries a Hebrew reason, SHOWN (never silent).
          if (verdict.blocked.isNotEmpty) ...[
            const SizedBox(height: BsTokens.space2),
            for (final b in verdict.blocked)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '⛔ ${b.reasonHe}',
                  style: const TextStyle(
                    color: BsTokens.dangerDark,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ── confirm + undo/redo (§9 — undo is P1's stack) ──

  Widget _actionsBar({required bool canApply, required ConfigStore notifier}) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            key: const Key('studio-confirm'),
            onPressed: canApply ? _confirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: BsTokens.brand,
              disabledBackgroundColor: BsTokens.divider,
              foregroundColor: bsOnAccent(context),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'אשר והחל בטיוטה ✓',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: BsTokens.space2),
        IconButton(
          key: const Key('studio-undo'),
          tooltip: 'בטל (undo של Pillar 1)',
          onPressed: notifier.canUndo ? _undo : null,
          icon: const Icon(Icons.undo, color: BsTokens.inkLight),
        ),
        IconButton(
          key: const Key('studio-redo'),
          tooltip: 'בצע-שוב (redo של Pillar 1)',
          onPressed: notifier.canRedo ? _redo : null,
          icon: const Icon(Icons.redo, color: BsTokens.inkLight),
        ),
      ],
    );
  }

  Widget _historyCard() {
    return _panel(
      title: 'יומן שינויים (תצוגה — מקור-האמת הוא undo של Pillar 1)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in _mirror)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '↩︎ $line',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── shared panel chrome ──

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: BsTokens.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BsTokens.mutedLight,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          child,
        ],
      ),
    );
  }
}
