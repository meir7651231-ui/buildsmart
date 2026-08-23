// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 20 — the owner entry (the unlock).
//
// [StudioEntryCard] is the ONE place the Studio becomes reachable. It is HIDDEN for
// everyone but the owner-manager (`SizedBox.shrink` ⇒ zero change for every other
// user). Tapping it stages the runtime `kStudio` flag (no rebuild) and opens the
// Studio via the owner-gated `StudioScreen.route`.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/screens/studio/studio_screen.dart' show StudioScreen;
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:buildsmart/state/studio/edit_mode.dart'
    show studioOwnerManagerProvider;
import 'package:buildsmart/state/studio/studio_flags.dart' show kStudioFlagName;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The owner-only "🎨 סטודיו" entry — hidden unless the viewer is the owner-manager.
class StudioEntryCard extends ConsumerWidget {
  const StudioEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(studioOwnerManagerProvider)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space4),
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        child: ListTile(
          leading: const Text('🎨', style: TextStyle(fontSize: 24)),
          title: const Text(
            'סטודיו (בטא)',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text('ערוך את האפליקציה — טקסטים · עיצוב · נראות'),
          trailing: const Icon(Icons.chevron_left),
          onTap: () {
            // Stage the runtime flag (no rebuild) then open the owner-gated route.
            ref.read(featureFlagsProvider.notifier).enable(kStudioFlagName);
            final route = StudioScreen.route(ref);
            if (route != null) Navigator.of(context).push(route);
          },
        ),
      ),
    );
  }
}
