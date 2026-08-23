// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 19 — Pane B: the inspector.
//
// Edits the element selected in the tree (studioSelectedIdProvider). Only the axes
// the descriptor allows (editableProps) are shown: content (text + emoji) and
// visibility (locked when kImmutable). Every edit goes to the DRAFT via applyOps —
// nothing is live until "פרסם לכולם". v1 edits the GLOBAL layer ("change for
// everyone"); per-persona scoping (studioScopePersona) is a later refinement.
// (Style → s24 theme editor; behavior → Pillar-4.)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_store.dart'
    show SetEmoji, SetHidden, SetText, configStoreProvider;
import 'package:buildsmart/state/studio/element_registry.dart'
    show EditAxis, descriptorProvider;
import 'package:buildsmart/state/studio/studio_nav.dart'
    show studioSelectedIdProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InspectorPane extends ConsumerStatefulWidget {
  const InspectorPane({super.key});

  @override
  ConsumerState<InspectorPane> createState() => _InspectorPaneState();
}

class _InspectorPaneState extends ConsumerState<InspectorPane> {
  final _text = TextEditingController();
  final _emoji = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bindToSelection();
  }

  @override
  void dispose() {
    _text.dispose();
    _emoji.dispose();
    super.dispose();
  }

  // R2-#2: seed the local controllers from the draft ONCE per selection; while the
  // owner types, the field is decoupled from the doc (no re-seed on every keystroke).
  void _bindToSelection() {
    final id = ref.read(studioSelectedIdProvider);
    final draft = id == null
        ? null
        : ref.read(configStoreProvider).draft.global[id];
    _text.text = draft?.text ?? '';
    _emoji.text = draft?.emoji ?? '';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(studioSelectedIdProvider, (_, __) => _bindToSelection());

    final id = ref.watch(studioSelectedIdProvider);
    if (id == null) {
      return _placeholder('בחר רכיב מהעץ כדי לערוך');
    }
    final d = ref.watch(descriptorProvider(id));
    if (d == null) {
      return _placeholder('רכיב לא מוכר (אינו ברישום)');
    }

    final notifier = ref.read(configStoreProvider.notifier);
    final props = d.editableProps;
    final effText = ref.watch(
      configStoreProvider.select(
        (doc) => doc.draft.global[id]?.text ?? doc.published.global[id]?.text,
      ),
    );
    final effEmoji = ref.watch(
      configStoreProvider.select(
        (doc) => doc.draft.global[id]?.emoji ?? doc.published.global[id]?.emoji,
      ),
    );
    final hidden = ref.watch(
      configStoreProvider.select(
        (doc) =>
            doc.draft.global[id]?.hidden ??
            doc.published.global[id]?.hidden ??
            false,
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(BsTokens.space4),
      children: [
        Text(
          d.labelHe,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: BsTokens.typeSubhead,
            color: BsTokens.inkLight,
          ),
        ),
        Text(
          d.id,
          style: const TextStyle(
            fontSize: BsTokens.typeCaption,
            color: BsTokens.mutedLight,
          ),
        ),
        const Divider(height: BsTokens.space5),
        if (props.contains(EditAxis.text))
          TextField(
            controller: _text,
            onChanged: (v) =>
                notifier.applyOps([SetText(id, v.isEmpty ? null : v)]),
            decoration: InputDecoration(
              labelText: 'טקסט',
              hintText: d.labelHe,
              border: const OutlineInputBorder(),
            ),
          ),
        if (props.contains(EditAxis.emoji)) ...[
          const SizedBox(height: BsTokens.space3),
          TextField(
            controller: _emoji,
            onChanged: (v) =>
                notifier.applyOps([SetEmoji(id, v.isEmpty ? null : v)]),
            decoration: const InputDecoration(
              labelText: 'אמוג׳י',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        if (props.contains(EditAxis.hidden)) ...[
          const SizedBox(height: BsTokens.space2),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: hidden,
            title: const Text('מוסתר'),
            subtitle: d.kImmutable
                ? const Text(
                    'רכיב קריטי — לא ניתן להסתרה',
                    style: TextStyle(color: BsTokens.mutedLight),
                  )
                : null,
            onChanged: d.kImmutable
                ? null
                : (h) => notifier.applyOps([SetHidden(id, h ? true : null)]),
          ),
        ],
        const SizedBox(height: BsTokens.space4),
        // Live preview of the draft value (what publishing would make live).
        const Text(
          'תצוגה:',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: BsTokens.typeCaption),
        ),
        const SizedBox(height: 4),
        Text(
          effText == null
              ? '(ברירת-מחדל — ${d.labelHe})'
              : (effEmoji == null ? effText : '$effEmoji $effText'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: BsTokens.inkLight,
          ),
        ),
        const SizedBox(height: BsTokens.space5),
        OutlinedButton.icon(
          onPressed: () {
            notifier.resetDraftNode(id);
            _bindToSelection();
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text('אפס רכיב לברירת-המחדל'),
        ),
      ],
    );
  }

  Widget _placeholder(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space5),
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: BsTokens.mutedLight),
          ),
        ),
      );
}
