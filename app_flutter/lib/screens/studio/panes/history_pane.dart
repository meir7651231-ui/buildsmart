// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 21 — Pane D: version history.
//
// Lists every published [ConfigVersion] (newest first) with its note, publisher,
// and time. "שחזר" re-publishes that snapshot as a NEW forward version (the store's
// forward-only rollback — history is never destroyed), behind a confirm dialog.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_doc.dart' show ConfigVersion;
import 'package:buildsmart/state/studio/config_store.dart'
    show configStoreProvider;
import 'package:buildsmart/state/studio/edit_mode.dart'
    show studioOwnerEmailProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryPane extends ConsumerWidget {
  const HistoryPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(configStoreProvider.select((d) => d.history));
    if (history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(BsTokens.space5),
          child: Text(
            'עדיין לא פורסמו גרסאות.\nכל "פרסם לכולם" יופיע כאן, וניתן יהיה לשחזר.',
            textAlign: TextAlign.center,
            style: TextStyle(color: BsTokens.mutedLight),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (_, i) {
        final v = history[i];
        return ListTile(
          leading: const Icon(Icons.history, color: BsTokens.mutedLight),
          title: Text(v.note.isEmpty ? 'עריכה' : v.note),
          subtitle: Text(
            '${v.byEmail.isEmpty ? 'בעלים' : v.byEmail} · ${_fmt(v.publishedAtMs)}',
            style: const TextStyle(
              fontSize: BsTokens.typeCaption,
              color: BsTokens.mutedLight,
            ),
          ),
          trailing: TextButton(
            onPressed: () => _restore(context, ref, v),
            child: const Text('שחזר'),
          ),
        );
      },
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    ConfigVersion v,
  ) async {
    final notifier = ref.read(configStoreProvider.notifier);
    final email = ref.read(studioOwnerEmailProvider) ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('לשחזר גרסה זו?'),
        content: Text(
          'הגרסה תפורסם מחדש לכל המשתמשים כגרסה חדשה (ההיסטוריה נשמרת).'
          '${v.note.isEmpty ? '' : '\n\n"${v.note}"'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('שחזר'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      notifier.rollback(
        v.id,
        byEmail: email,
        nowMs: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
}

String _fmt(int ms) {
  final dt = DateTime.fromMillisecondsSinceEpoch(ms);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(dt.day)}/${two(dt.month)} ${two(dt.hour)}:${two(dt.minute)}';
}
