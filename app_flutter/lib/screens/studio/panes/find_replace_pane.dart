// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 25 — global find-&-replace over content.
//
// A registry-driven substring search across the owner's CONTENT overrides (the
// draft⊕published text per id — NOT labelHe, which is the element's *name*). Each
// hit previews labelHe + "before → after", with a per-hit checkbox so the owner
// replaces selectively. "החלף בנבחרים" applies ALL chosen edits as a SINGLE
// `applyOps` batch ⇒ one undo unit (R1-A3 · R2-#18), straight to the DRAFT —
// nothing reaches users until "פרסם לכולם". kImmutable ids are read-only here too.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_store.dart'
    show ConfigOp, SetText, cfgOpError, configStoreProvider;
import 'package:buildsmart/state/studio/element_registry.dart'
    show EditAxis, ElementDescriptor, criticalIdsProvider, elementRegistryProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FindReplacePane extends ConsumerStatefulWidget {
  const FindReplacePane({super.key});

  @override
  ConsumerState<FindReplacePane> createState() => _FindReplacePaneState();
}

class _FindReplacePaneState extends ConsumerState<FindReplacePane> {
  final _find = TextEditingController();
  final _replace = TextEditingController();
  final _deselected = <String>{}; // ids the owner explicitly unchecked

  @override
  void dispose() {
    _find.dispose();
    _replace.dispose();
    super.dispose();
  }

  bool _selected(_Hit h) => !h.d.kImmutable && !_deselected.contains(h.d.id);

  @override
  Widget build(BuildContext context) {
    final query = _find.text.trim();
    final replacement = _replace.text;
    final doc = ref.watch(configStoreProvider);
    final registry = ref.watch(elementRegistryProvider);

    final hits = <_Hit>[];
    if (query.isNotEmpty) {
      for (final d in registry) {
        if (!d.editableProps.contains(EditAxis.text)) continue;
        // The CONTENT override only — never labelHe (that is the element's name).
        final text = doc.draft.global[d.id]?.text ?? doc.published.global[d.id]?.text;
        if (text != null && text.contains(query)) hits.add(_Hit(d, text));
      }
    }
    final selectedCount = hits.where(_selected).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(BsTokens.space4),
          child: Column(
            children: [
              TextField(
                controller: _find,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'מצא טקסט',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              TextField(
                controller: _replace,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'החלף ב…',
                  prefixIcon: Icon(Icons.find_replace),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        if (query.isEmpty)
          const Expanded(
            child: _Placeholder('הקלד טקסט לחיפוש על-פני הרכיבים שנערכו.'),
          )
        else if (hits.isEmpty)
          Expanded(child: _Placeholder('אין התאמות ל־"$query".'))
        else ...[
          if (hits.length > 50) _WideWarning(count: hits.length),
          Expanded(
            child: ListView.builder(
              itemCount: hits.length,
              itemBuilder: (_, i) {
                final h = hits[i];
                final locked = h.d.kImmutable;
                final after = h.text.replaceAll(query, replacement);
                return CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: !locked && _selected(h),
                  onChanged: locked
                      ? null
                      : (v) => setState(() {
                            if (v ?? false) {
                              _deselected.remove(h.d.id);
                            } else {
                              _deselected.add(h.d.id);
                            }
                          }),
                  title: Text(
                    h.d.labelHe,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: BsTokens.inkLight,
                    ),
                  ),
                  subtitle: locked
                      ? const Text(
                          'רכיב קריטי — קריאה בלבד',
                          style: TextStyle(color: BsTokens.mutedLight),
                        )
                      // The strike-through old / bold new is a VISUAL cue; a
                      // screen reader gets a spoken "מ־… ל־…" instead (the bare
                      // glyphs alone wouldn't convey old vs new). [round-2 a11y]
                      : Semantics(
                          label: 'מ־${h.text} ל־${after.isEmpty ? 'ריק' : after}',
                          child: ExcludeSemantics(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: h.text,
                                    style: const TextStyle(
                                      color: BsTokens.mutedLight,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const TextSpan(text: '  ←  '),
                                  TextSpan(
                                    text: after.isEmpty ? '(ריק)' : after,
                                    style: const TextStyle(
                                      color: BsTokens.inkLight,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    selectedCount == 0 ? null : () => _apply(hits, query, replacement),
                icon: const Icon(Icons.find_replace),
                label: Text('החלף בנבחרים ($selectedCount)'),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _apply(List<_Hit> hits, String query, String replacement) {
    final critical = ref.read(criticalIdsProvider);
    final ops = <ConfigOp>[];
    var dropped = 0;
    for (final h in hits) {
      if (!_selected(h)) continue;
      final next = h.text.replaceAll(query, replacement);
      final op = SetText(h.d.id, next.isEmpty ? null : next);
      // Pre-validate so a too-long / bidi result is reported, not silently lost.
      if (cfgOpError(op, criticalIds: critical) != null) {
        dropped++;
        continue;
      }
      ops.add(op);
    }
    if (ops.isEmpty && dropped == 0) return;
    // ONE batch ⇒ a single undo frame; draft-only (never publish). `applied` is the
    // count that ACTUALLY changed the draft — reported honestly (round-2 fix).
    final applied =
        ref.read(configStoreProvider.notifier).applyOps(ops, criticalIds: critical);
    final msg = StringBuffer(
      'הוחלפו $applied — בטיוטה. "פרסם לכולם" כדי לשדר לכל המשתמשים.',
    );
    if (dropped > 0) msg.write(' ($dropped נדחו — טקסט ארוך/לא תקין)');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg.toString())),
    );
    setState(() {
      _find.clear();
      _replace.clear();
      _deselected.clear();
    });
  }
}

class _Hit {
  const _Hit(this.d, this.text);

  final ElementDescriptor d;
  final String text;
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.msg);

  final String msg;

  @override
  Widget build(BuildContext context) => Center(
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

class _WideWarning extends StatelessWidget {
  const _WideWarning({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
        padding: const EdgeInsets.all(BsTokens.space3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E5),
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          border: Border.all(color: const Color(0xFFFFB74D)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100)),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: Text(
                '$count התאמות — החלפה רחבה, לסקור היטב לפני "פרסם".',
                style: const TextStyle(color: Color(0xFF7A3E00)),
              ),
            ),
          ],
        ),
      );
}
