// Pins the Cfg* wrapper zero-cost contract (#studio · Pillar 1 · steps 9–11).
// Step 9 — EditHandle.maybe: OUTSIDE edit-mode it returns the child verbatim (zero
// added widgets ⇒ the zero-regression root); INSIDE edit-mode it tags the subtree
// with a StudioEditTarget (for the overlay's central hit-test, step 13) and draws
// the non-sizing brand outline. The gate inputs are overridden, so no auth/prefs.
//
// (Steps 10–11 EXTEND this file with CfgText / CfgVisible / CfgList cases.)
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/state/studio/edit_mode.dart';
import 'package:buildsmart/widgets/studio/edit_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Host extends ConsumerWidget {
  const _Host();
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      EditHandle.maybe(ref, 'cart.cta', child: const Text('הזמן'));
}

ProviderContainer _container({required bool editing}) {
  final c = ProviderContainer(
    overrides: [
      studioActiveProvider.overrideWithValue(editing),
      studioOwnerEmailProvider
          .overrideWithValue(editing ? kOwnerEmails.first : null),
      studioInManagerContextProvider.overrideWithValue(editing),
    ],
  );
  if (editing) c.read(editModeProvider.notifier).enterEdit();
  return c;
}

Widget _pump(ProviderContainer c) => UncontrolledProviderScope(
      container: c,
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: _Host(),
      ),
    );

void main() {
  testWidgets('OFF edit-mode: EditHandle.maybe returns the child verbatim', (
    tester,
  ) async {
    final c = _container(editing: false);
    addTearDown(c.dispose);
    await tester.pumpWidget(_pump(c));

    expect(find.text('הזמן'), findsOneWidget);
    expect(find.byType(MetaData), findsNothing); // no affordance wrapper at all
  });

  testWidgets('ON edit-mode: tags StudioEditTarget(id) + draws the outline', (
    tester,
  ) async {
    final c = _container(editing: true);
    addTearDown(c.dispose);
    await tester.pumpWidget(_pump(c));

    expect(find.text('הזמן'), findsOneWidget); // child still rendered
    final meta = tester.widget<MetaData>(find.byType(MetaData));
    expect(meta.metaData, isA<StudioEditTarget>());
    expect((meta.metaData as StudioEditTarget).id, 'cart.cta');
    expect(find.byType(DecoratedBox), findsWidgets); // brand outline present
  });
}
