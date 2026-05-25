import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/screens/regression_panel_screen.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/widgets/dial.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// BS dial — port of app/src/components/bs/bs-dial.tsx.
/// L1 = 5 personas. L2+ = walk active persona's section tree along
/// the drill path. Tapping a leaf with no children → toast.
class BsDialWidget extends ConsumerWidget {
  const BsDialWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaId = ref.watch(activePersonaProvider);

    // L1 — 5 personas.
    if (personaId == null) {
      return DialColumn(
        children: [
          for (final p in kPersonas)
            DialRow(
              label: p.title,
              emoji: p.emoji,
              icon: Icons.circle,
              onTap: () =>
                  ref.read(activePersonaProvider.notifier).state = p.id,
            ),
        ],
      );
    }

    final persona = kPersonas.firstWhere((p) => p.id == personaId);
    final path = ref.watch(bsDrillPathProvider);
    final walked = walkBsDrill(personaId, path);

    return DialColumn(
      children: [
        // Persona anchor — tap to pop back to L1.
        DialRow(
          label: persona.title,
          emoji: persona.emoji,
          icon: Icons.circle,
          active: true,
          onTap: () {
            ref.read(activePersonaProvider.notifier).state = null;
            ref.read(bsDrillPathProvider.notifier).state = const [];
          },
        ),
        // One anchor per drill step — tap pops to that depth.
        for (var i = 0; i < walked.anchors.length; i++)
          DialRow(
            label: walked.anchors[i].title,
            emoji: walked.anchors[i].emoji,
            icon: Icons.circle,
            active: true,
            onTap: () => ref.read(bsDrillPathProvider.notifier).state =
                path.sublist(0, i),
          ),
        // Current items at this depth.
        for (final s in walked.current)
          DialRow(
            label: s.title,
            emoji: s.emoji,
            icon: Icons.circle,
            onTap: () {
              if (s.hasChildren) {
                ref.read(bsDrillPathProvider.notifier).state = [
                  ...path,
                  s.title,
                ];
              } else if (s.id == 'mm-regression') {
                ref.read(openDialProvider.notifier).state = OpenDial.none;
                Navigator.of(context).push(RegressionPanelScreen.route());
              } else {
                showToast(context, '${s.title} — בבנייה');
              }
            },
          ),
      ],
    );
  }
}
