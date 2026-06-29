// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 17 — the Studio top-bar.
//
// Draft badge (live change count) · "מצב עריכה" toggle · "בטל טיוטה" · "פרסם לכולם".
// Publish/discard are disabled on an empty draft. Publish opens a CONFIRM sheet
// (R2-#13): "ישפיע על כל המשתמשים — N שינויים" + an inline note + a view-as-persona
// dropdown (how many changes hit each role), then calls publish(note, byEmail). All
// mutations go through the store's applyOps/publish — never a direct write.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_store.dart'
    show configStoreProvider;
import 'package:buildsmart/state/studio/edit_mode.dart'
    show editModeProvider, studioCanEditProvider, studioOwnerEmailProvider;
import 'package:buildsmart/state/studio/element_registry.dart'
    show criticalIdsProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kPersonaKeys = ['contractor', 'manager', 'store', 'courier', 'worker'];
const _kPersonaHe = {
  'contractor': 'קבלן',
  'manager': 'מנהל',
  'store': 'חנות',
  'courier': 'שליח',
  'worker': 'עובד',
};

/// The Studio top-bar: badge + edit toggle + discard + publish.
class StudioTopBar extends ConsumerWidget {
  const StudioTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(configStoreProvider.select((d) => d.draftNodeCount));
    final editing = ref.watch(editModeProvider.select((s) => s.isEditing));
    // #84 — every mutating control is gated on the owner gate (not just the draft
    // count), so publish/discard can never fire for a non-owner even if the bar
    // somehow renders (defence-in-depth, not only the route guard).
    final canEdit = ref.watch(studioCanEditProvider);
    return Material(
      color: BsTokens.cardLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space3,
          vertical: BsTokens.space2,
        ),
        child: Row(
          children: [
            _DraftBadge(count: count),
            const Spacer(),
            TextButton.icon(
              onPressed: !canEdit
                  ? null
                  : () => ref.read(editModeProvider.notifier).toggleEdit(),
              icon: Icon(
                editing ? Icons.edit_off_outlined : Icons.edit_outlined,
                size: 18,
              ),
              label: Text(editing ? 'סיים עריכה' : 'מצב עריכה'),
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: (!canEdit || count == 0)
                  ? null
                  : () => _confirmDiscard(context, ref, count),
              child: const Text('בטל טיוטה'),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BsTokens.brand,
                foregroundColor: Colors.white,
              ),
              onPressed: (!canEdit || count == 0)
                  ? null
                  : () => _openPublish(context, count),
              child: const Text('פרסם לכולם'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftBadge extends StatelessWidget {
  const _DraftBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final has = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: has
            ? BsTokens.brand.withValues(alpha: 0.12)
            : BsTokens.surfaceMid,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        has ? 'טיוטה · $count שינויים' : 'אין שינויים',
        style: TextStyle(
          color: has ? BsTokens.brandDark : BsTokens.mutedLight,
          fontWeight: FontWeight.w700,
          fontSize: BsTokens.typeCaption,
        ),
      ),
    );
  }
}

Future<void> _confirmDiscard(
  BuildContext context,
  WidgetRef ref,
  int count,
) async {
  final notifier = ref.read(configStoreProvider.notifier);
  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: BsTokens.cardLight,
    builder: (sheetCtx) => Padding(
      padding: const EdgeInsets.all(BsTokens.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'לבטל $count שינויים בטיוטה?',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: BsTokens.typeSubhead,
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          const Text(
            'הטיוטה תימחק. מה שכבר פורסם יישאר חי.',
            style: TextStyle(color: BsTokens.mutedLight),
          ),
          const SizedBox(height: BsTokens.space4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetCtx, false),
                  child: const Text('השאר'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BsTokens.danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(sheetCtx, true),
                  child: const Text('בטל טיוטה'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  if (ok ?? false) notifier.discardDraft();
}

Future<void> _openPublish(BuildContext context, int count) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BsTokens.cardLight,
      builder: (_) => _PublishSheet(count: count),
    );

class _PublishSheet extends ConsumerStatefulWidget {
  const _PublishSheet({required this.count});

  final int count;

  @override
  ConsumerState<_PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends ConsumerState<_PublishSheet> {
  final _note = TextEditingController();
  String _viewAs = 'contractor';
  bool _publishing = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  int _countFor(String roleKey) {
    final doc = ref.read(configStoreProvider);
    return doc.draft.global.length + (doc.draft.persona[roleKey]?.length ?? 0);
  }

  void _doPublish() {
    if (_publishing) return;
    setState(() => _publishing = true);
    final note = _note.text.trim();
    ref.read(configStoreProvider.notifier).publish(
          note: note.isEmpty ? 'עריכה ידנית' : note,
          byEmail: ref.read(studioOwnerEmailProvider) ?? '',
          nowMs: DateTime.now().millisecondsSinceEpoch,
          // Run the publish-validator in prod so a critical hide/reroute is stripped
          // before it ever reaches `published` (round-2 fix — keeps published clean).
          criticalIds: ref.read(criticalIdsProvider),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: BsTokens.space4,
        end: BsTokens.space4,
        top: BsTokens.space4,
        bottom: MediaQuery.of(context).viewInsets.bottom + BsTokens.space4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'פרסום לכולם',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: BsTokens.typeSubhead,
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          Text(
            '⚠️ ישפיע על כל המשתמשים — ${widget.count} שינויים.',
            style: const TextStyle(
              color: BsTokens.warnText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: BsTokens.space4),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              labelText: 'מה שינית? (אופציונלי)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BsTokens.space4),
          Row(
            children: [
              const Text('צפה כפי ש-', style: TextStyle(color: BsTokens.mutedLight)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _viewAs,
                items: [
                  for (final k in _kPersonaKeys)
                    DropdownMenuItem(value: k, child: Text(_kPersonaHe[k]!)),
                ],
                onChanged: (v) => setState(() => _viewAs = v ?? 'contractor'),
              ),
              const Spacer(),
              Text(
                '${_countFor(_viewAs)} יחולו',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: BsTokens.space4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _publishing ? null : () => Navigator.pop(context),
                  child: const Text('ביטול'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BsTokens.brand,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _publishing ? null : _doPublish,
                  child: const Text('פרסם'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
