// keyboard_updates_deriver — PURE MIRROR ENGINE tests (plan phases 0-2).
//
// WHY THIS FILE IS THE WHOLE COVERAGE OF THE FLAG-ON LOGIC: the floating
// keyboard's live-mirror branch is gated by a compile-time `const kKbLiveMirror`
// (+ a runtime tier), and `flutter test` does NOT forward `--dart-define` to
// consts (feature_flags.dart) — so the flag-ON code path is unreachable from a
// unit test THROUGH the keyboard. The plan's deliberate design answer is that
// `deriveUpdatesContext` is a PURE FUNCTION taking ALL data as parameters and
// reading NO providers/context, so its ON logic is fully unit-testable with
// hand-built locations regardless of the flag. These tests exercise that pure
// function directly — they are the authoritative proof of the mirror's chips,
// its three dispatch surfaces, its tool bases, determinism, and the
// pairwise-disjointness the dispatch fall-through relies on.
//
// Two layers:
//   • PURE (no widget): the deriver is a value→value function; assert the EXACT
//     chips, the destByChip/runByChip key-sets, the toolBase LABELS, determinism,
//     disjointness, the chats dedup-by-label + cap, and empty/edge safety.
//   • DISPATCH (testWidgets + a capturing Consumer, hermetic ProviderContainer):
//     ACTUALLY INVOKE the returned closures and assert they set the right
//     providers and KEEP THE OVERLAY FLOATING (no Navigator.push from a chip) —
//     the "run the code" tier the reliability charter prefers over inspection.
//
// SharedPreferences.setMockInitialValues({}) is seeded for the widget layer
// (boardAuth/feature-flags read prefs lazily); the pure layer needs no binding.

import 'package:buildsmart/screens/chats_screen.dart'
    show ThreadLite, updatesChatOpenProvider;
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, kbDestinations;
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbUpdatesChatsNodes, kbUpdatesNotifNodes;
import 'package:buildsmart/screens/keyboard_updates_deriver.dart';
import 'package:buildsmart/screens/notifications_screen.dart'
    show NotifSection, notifSectionProvider;
import 'package:buildsmart/screens/updates_screen.dart'
    show updatesSubTabProvider;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/updates_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The home-shell scope every location carries (plan Q6) — kept in one place so
/// a fixture change can't drift between cases.
const String _kPersona = 'contractor';
const String _kAudience = 'contractor';

/// The two entry-section labels the root row must show, in OWNER order (שיחות
/// first) — the SAME pair the keyboard's hardcoded `labelsByTab[2]` shows today,
/// so the deriver's root row is byte-identical to the flag-OFF tab-2 row.
const List<String> _kEntrySections = <String>['שיחות', 'התראות'];

/// The 6 notification TYPE chips, in the exact VERBATIM order + labels the
/// in-list `_SectionChipsRow` pills use (mirrored by the deriver's
/// `_kNotifTypeChips`). Pairs each label with the [NotifSection] a tap must set.
const List<({String label, NotifSection section})> _kNotifChips = [
  (label: 'הכל', section: NotifSection.all),
  (label: '📦 משלוחים', section: NotifSection.shipments),
  (label: '🛒 הזמנות', section: NotifSection.orders),
  (label: '🦺 בטיחות', section: NotifSection.safety),
  (label: '💰 תקציב', section: NotifSection.budget),
  (label: '🎁 מבצעים', section: NotifSection.deals),
];

/// The tool-node LABELS each arm installs (the comparable projection — tool
/// closures are never structurally equal, so equality keys on visible labels).
const List<String> _kNotifToolLabels = <String>[
  'סמן הכל כנקרא',
  'הגדרות התראות',
];
const List<String> _kChatToolLabels = <String>[
  'שיחה חדשה',
  'חיפוש שיחות',
  'צרף',
  'קולי',
];

List<String> _toolLabels(KbUpdatesContext ctx) => <String>[
      for (final KbToolNode n in ctx.toolBase ?? const <KbToolNode>[]) n.label,
    ];

ThreadLite _thread(String id, String name) => (id: id, name: name);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────────
  // PURE: value→value, no widget tree. The strongest, most deterministic layer.
  // ───────────────────────────────────────────────────────────────────────────
  group('deriveUpdatesContext — UpdatesRoot arm (entry / section chips)', () {
    const root = UpdatesRoot(
      persona: _kPersona,
      audience: _kAudience,
      subTab: 0, // התראות active
    );

    test('chips are EXACTLY [שיחות, התראות] in owner order', () {
      final ctx = deriveUpdatesContext(root, threads: const []);
      expect(ctx.row.chips, _kEntrySections,
          reason: 'the root predictions are the two section chips, שיחות first');
    });

    test('both section chips are REAL registry KbDestinations (destByChip), '
        'runByChip is empty', () {
      final ctx = deriveUpdatesContext(root, threads: const []);
      expect(ctx.row.destByChip.keys.toSet(), _kEntrySections.toSet(),
          reason: 'each section chip dispatches via destByChip (ii)');
      expect(ctx.row.runByChip, isEmpty,
          reason: 'no dynamic chips at the root → runByChip is empty');

      // The destinations are sourced BY LABEL from the registry — identity-equal
      // to the same-label entries kbDestinations() returns, so they carry the
      // real `_openUpdatesSub` runs (not a stub).
      final byLabel = {for (final d in kbDestinations()) d.label: d};
      for (final label in _kEntrySections) {
        expect(identical(ctx.row.destByChip[label], byLabel[label]), isTrue,
            reason: '"$label" must be the registry destination, by label');
      }
    });

    test('every section chip is navigable (gets the nav glyph)', () {
      final ctx = deriveUpdatesContext(root, threads: const []);
      expect(ctx.row.destinationChips, _kEntrySections.toSet(),
          reason: 'the whole root row is one-tap navigation → all navigable');
    });

    test('toolBase reflects the active sub-tab: sub 0 → notif tools', () {
      final ctx = deriveUpdatesContext(root, threads: const []);
      expect(_toolLabels(ctx), _kNotifToolLabels,
          reason: 'at sub 0 (התראות) the root offers the notif tools');
    });

    test('toolBase reflects the active sub-tab: sub 1 → chat tools', () {
      const rootChats = UpdatesRoot(
        persona: _kPersona,
        audience: _kAudience,
        subTab: 1, // שיחות active
      );
      final ctx = deriveUpdatesContext(rootChats, threads: const []);
      // Predictions at the root are ALWAYS the two section chips regardless of
      // sub-tab; only the TOOLS swap.
      expect(ctx.row.chips, _kEntrySections,
          reason: 'root predictions stay the section chips at sub 1');
      expect(_toolLabels(ctx), _kChatToolLabels,
          reason: 'at sub 1 (שיחות) the root offers the chat tools');
    });

    test('ORG-GATE chatOn:false ⇒ chips EXACTLY [התראות] (שיחות drops)', () {
      final ctx = deriveUpdatesContext(root, threads: const [], chatOn: false);
      expect(ctx.row.chips, <String>['התראות'],
          reason: 'a dark chat module drops the שיחות chip from the root row');
      expect(ctx.row.destByChip.keys.toSet(), {'התראות'},
          reason: 'the surviving chip still dispatches via the registry');
    });

    test('ORG-GATE chatOn:false forces the notif tools even at subTab 1', () {
      const rootChats = UpdatesRoot(
        persona: _kPersona,
        audience: _kAudience,
        subTab: 1, // שיחות active — but the pane cannot render chat-off
      );
      final ctx =
          deriveUpdatesContext(rootChats, threads: const [], chatOn: false);
      expect(_toolLabels(ctx), _kNotifToolLabels,
          reason: 'chat off ⇒ never the chat tools (the screen clamps its '
              'IndexedStack to התראות, so the mirror must not offer tools '
              'for a pane that cannot render)');
    });

    test('ORG-GATE chatOn:true (the default) is the identity', () {
      expect(deriveUpdatesContext(root, threads: const [], chatOn: true),
          deriveUpdatesContext(root, threads: const []),
          reason: 'the optional org-gate param defaults to the identity');
    });
  });

  group('deriveUpdatesContext — NotifsLocation arm (the 6 type chips)', () {
    const loc = NotifsLocation(
      persona: _kPersona,
      audience: _kAudience,
      section: NotifSection.all,
    );

    test('chips are EXACTLY the 6 type labels, verbatim + in order', () {
      final ctx = deriveUpdatesContext(loc, threads: const []);
      expect(ctx.row.chips, [for (final c in _kNotifChips) c.label],
          reason: 'the notif arm mirrors _SectionChipsRow verbatim, in order');
    });

    test('all 6 chips dispatch via runByChip (iii); destByChip empty', () {
      final ctx = deriveUpdatesContext(loc, threads: const []);
      expect(ctx.row.runByChip.keys.toSet(),
          {for (final c in _kNotifChips) c.label},
          reason: 'each type chip is a dynamic runByChip closure');
      expect(ctx.row.destByChip, isEmpty,
          reason: 'no static destinations in the notif arm');
    });

    test('every type chip is navigable', () {
      final ctx = deriveUpdatesContext(loc, threads: const []);
      expect(ctx.row.destinationChips, {for (final c in _kNotifChips) c.label},
          reason: 'all 6 type chips get the nav glyph');
    });

    test('toolBase is the notif tools (mark-all-read / settings)', () {
      final ctx = deriveUpdatesContext(loc, threads: const []);
      expect(_toolLabels(ctx), _kNotifToolLabels);
      // Pin to the REAL factory (not just my hardcoded copy): the deriver must
      // install exactly kbUpdatesNotifNodes(), so a label edit there propagates
      // here automatically rather than silently diverging.
      expect(_toolLabels(ctx),
          [for (final n in kbUpdatesNotifNodes()) n.label],
          reason: 'the notif arm installs the kbUpdatesNotifNodes() factory');
    });

    test('the row is NEVER blank — independent of the selected section', () {
      for (final s in NotifSection.values) {
        final ctx = deriveUpdatesContext(
          NotifsLocation(
              persona: _kPersona, audience: _kAudience, section: s),
          threads: const [],
        );
        expect(ctx.row.chips.length, _kNotifChips.length,
            reason: 'the 6 static type chips always render (section=$s)');
      }
    });
  });

  group('deriveUpdatesContext — ChatsLocation arm (real conversation chips)',
      () {
    const loc = ChatsLocation(persona: _kPersona, audience: _kAudience);

    test('one chip per visible thread, label = thread name, in order', () {
      final threads = [
        _thread('a', 'אבי הקבלן'),
        _thread('b', 'בני שיפוצים'),
        _thread('c', 'גדי חשמל'),
      ];
      final ctx = deriveUpdatesContext(loc, threads: threads);
      expect(ctx.row.chips, ['אבי הקבלן', 'בני שיפוצים', 'גדי חשמל'],
          reason: 'conversation chips are the thread names, in list order');
      expect(ctx.row.runByChip.keys.toSet(),
          {'אבי הקבלן', 'בני שיפוצים', 'גדי חשמל'},
          reason: 'each conversation chip is a dynamic runByChip closure');
      expect(ctx.row.destByChip, isEmpty);
    });

    test('DE-DUPS by visible label: duplicate names collapse to the FIRST id',
        () {
      // Thread names can duplicate (the contractor sees the same display name
      // for several worker threads). The row must stay unambiguous: one chip per
      // distinct label, the FIRST occurrence winning.
      final threads = [
        _thread('id-1', 'עובד'),
        _thread('id-2', 'עובד'), // same label → collapses
        _thread('id-3', 'מנהל'),
      ];
      final ctx = deriveUpdatesContext(loc, threads: threads);
      expect(ctx.row.chips, ['עובד', 'מנהל'],
          reason: 'the duplicate "עובד" label collapses to a single chip');
      expect(ctx.row.runByChip.keys.length, 2,
          reason: 'one closure per distinct label');
    });

    test('CAPS at 5 conversation chips (reuses _kRowCap budget)', () {
      final threads = [
        for (var i = 0; i < 9; i++) _thread('id$i', 'שיחה $i'),
      ];
      final ctx = deriveUpdatesContext(loc, threads: threads);
      expect(ctx.row.chips.length, 5, reason: 'capped at 5');
      expect(ctx.row.chips,
          ['שיחה 0', 'שיחה 1', 'שיחה 2', 'שיחה 3', 'שיחה 4'],
          reason: 'the cap keeps the FIRST five in order');
    });

    test('EMPTY threads → empty chip list, tools only, no crash', () {
      final ctx = deriveUpdatesContext(loc, threads: const []);
      expect(ctx.row.chips, isEmpty,
          reason: 'zero conversations → no chips (the row shows tools only)');
      expect(ctx.row.runByChip, isEmpty);
      expect(_toolLabels(ctx), _kChatToolLabels,
          reason: 'the chat tools still render with no conversations');
    });

    test('toolBase is the chat tools (new-chat/search/attach/voice)', () {
      final ctx = deriveUpdatesContext(loc, threads: const []);
      expect(_toolLabels(ctx), _kChatToolLabels);
      // Pin to the REAL factory so a future edit to the chat tools is caught.
      expect(_toolLabels(ctx),
          [for (final n in kbUpdatesChatsNodes()) n.label],
          reason: 'the chats arm installs the kbUpdatesChatsNodes() factory');
    });
  });

  // ── DISPATCH DISJOINTNESS — the structural fall-through guarantee ───────────
  group('dispatch maps are pairwise-disjoint (every arm)', () {
    void assertDisjoint(KbUpdatesContext ctx, String arm) {
      final dest = ctx.row.destByChip.keys.toSet();
      final run = ctx.row.runByChip.keys.toSet();
      expect(dest.intersection(run), isEmpty,
          reason: '$arm: destByChip ∩ runByChip must be empty so the dispatch '
              'fall-through is structural, not coincidental');
    }

    test('UpdatesRoot: destByChip ∩ runByChip == ∅', () {
      assertDisjoint(
        deriveUpdatesContext(
          const UpdatesRoot(
              persona: _kPersona, audience: _kAudience, subTab: 0),
          threads: const [],
        ),
        'UpdatesRoot',
      );
    });

    test('NotifsLocation: destByChip ∩ runByChip == ∅', () {
      assertDisjoint(
        deriveUpdatesContext(
          const NotifsLocation(
              persona: _kPersona,
              audience: _kAudience,
              section: NotifSection.all),
          threads: const [],
        ),
        'NotifsLocation',
      );
    });

    test('ChatsLocation: destByChip ∩ runByChip == ∅', () {
      assertDisjoint(
        deriveUpdatesContext(
          const ChatsLocation(persona: _kPersona, audience: _kAudience),
          threads: [_thread('a', 'אבי'), _thread('b', 'בני')],
        ),
        'ChatsLocation',
      );
    });

    test(
        'no notif type label nor a seed thread name collides with ANY registry '
        'destination label (fall-through stays structural)', () {
      final destLabels = {for (final d in kbDestinations()) d.label};
      // The dynamic chips must not create an AMBIGUOUS dispatch. The real
      // guarantee is PER-ROW (runByChip ∩ destByChip == ∅, asserted per arm
      // above) — never global label uniqueness. A notif-TYPE label may, by
      // design, coincide with a nav destination: 'תקציב' is BOTH a notification
      // category (a runByChip filter on the NotifsLocation row) AND the budget
      // screen (a registry nav destination reached elsewhere / by typing). That
      // is harmless — they never share a row, so the fall-through stays
      // structural. Only NON-intentional-overlap notif labels must stay out of
      // the registry.
      const intentionalNavOverlap = {'תקציב'};
      for (final c in _kNotifChips) {
        if (intentionalNavOverlap.contains(c.label)) continue;
        expect(destLabels.contains(c.label), isFalse,
            reason: 'notif type "${c.label}" must not be a destination label');
      }
      // Realistic conversation names. (A real chat CAN be named after a nav
      // label — e.g. 'עובד'/'תקציב' — and stays harmless per-row, as the
      // assertDisjoint tests above prove; these fixtures simply use clearly
      // non-destination names to document the typical case.)
      for (final name in const [
        'אבי הקבלן',
        'בני שיפוצים',
        'דנה האדריכלית',
        'שיחה 1'
      ]) {
        expect(destLabels.contains(name), isFalse,
            reason: 'seed thread name "$name" must not be a destination label');
      }
    });
  });

  // ── DETERMINISM (purity) ───────────────────────────────────────────────────
  group('deriver is deterministic (same location + data ⇒ equal context)', () {
    test('UpdatesRoot: two calls produce == contexts', () {
      const loc =
          UpdatesRoot(persona: _kPersona, audience: _kAudience, subTab: 1);
      expect(deriveUpdatesContext(loc, threads: const []),
          deriveUpdatesContext(loc, threads: const []),
          reason: 'pure: identical inputs ⇒ identical (==) context');
    });

    test('NotifsLocation: two calls produce == contexts', () {
      const loc = NotifsLocation(
          persona: _kPersona,
          audience: _kAudience,
          section: NotifSection.budget);
      expect(deriveUpdatesContext(loc, threads: const []),
          deriveUpdatesContext(loc, threads: const []));
    });

    test('ChatsLocation: identical thread data ⇒ == contexts', () {
      const loc = ChatsLocation(persona: _kPersona, audience: _kAudience);
      final t1 = [_thread('a', 'אבי'), _thread('b', 'בני')];
      final t2 = [_thread('a', 'אבי'), _thread('b', 'בני')];
      expect(deriveUpdatesContext(loc, threads: t1),
          deriveUpdatesContext(loc, threads: t2),
          reason: 'equal thread lists ⇒ equal context (no per-frame churn)');
    });

    test('a different location ⇒ a DIFFERENT context', () {
      final notif = deriveUpdatesContext(
        const NotifsLocation(
            persona: _kPersona,
            audience: _kAudience,
            section: NotifSection.all),
        threads: const [],
      );
      final root = deriveUpdatesContext(
        const UpdatesRoot(persona: _kPersona, audience: _kAudience, subTab: 0),
        threads: const [],
      );
      expect(notif == root, isFalse,
          reason: 'distinct surfaces must not compare equal');
    });
  });

  // ── FLAG-OFF BYTE-IDENTITY (deriver layer) ─────────────────────────────────
  // The widget-level flag-OFF regression (tab-2 row + typed path + tabs 0/1/3
  // unchanged) is ALREADY covered, green, by
  // test/screens/floating_card_keyboard_test.dart cases (a),(c),(d),(e),(f),
  // which pump the REAL FloatingCardKeyboard with kKbLiveMirror at its const
  // default OFF and featureFlagsProvider empty (kKbLiveMirrorFlag is not in
  // _forcedOnFlags), so the mirror branch + the build() watches fold out and the
  // hardcoded ['שיחות','התראות'] tab-2 row is what renders. We do NOT duplicate
  // that here. What we add is the COMPLEMENT: proof that when the flag IS on, the
  // deriver's root row is byte-identical to that preserved hardcoded row — so the
  // flag flip changes timing/wiring, never the entry row the user sees.
  group('flag-OFF byte-identity (deriver root == the hardcoded tab-2 row)', () {
    test('the deriver root row equals the hardcoded labelsByTab[2] exactly', () {
      // This list is copied byte-for-byte from floating_card_keyboard.dart's
      // const labelsByTab[2] (verified). The deriver must emit the same labels in
      // the same order so flag-ON's entry == flag-OFF's entry.
      const hardcodedTab2Row = <String>['שיחות', 'התראות'];
      for (final sub in const [0, 1]) {
        final ctx = deriveUpdatesContext(
          UpdatesRoot(persona: _kPersona, audience: _kAudience, subTab: sub),
          threads: const [],
        );
        expect(ctx.row.chips, hardcodedTab2Row,
            reason: 'deriver root chips (sub=$sub) == the preserved tab-2 row');
        expect(ctx.row.destByChip.keys.toSet(), hardcodedTab2Row.toSet(),
            reason: 'and they carry the same by-label registry destinations');
      }
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // DISPATCH (run the code): invoke the returned closures against a real
  // container + BuildContext and assert they set the right providers AND keep
  // the overlay floating (no Navigator.push from a chip). A capturing Consumer
  // hands us the (ref, context) the floating keyboard would supply at tap time.
  // ───────────────────────────────────────────────────────────────────────────
  group('dispatch closures (invoked) set providers + keep floating', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    /// Pumps a tiny Consumer that captures the live (WidgetRef, BuildContext) and
    /// records every route pushed onto the Navigator, so a test can invoke a
    /// dispatch closure exactly as the keyboard would and assert no nav occurred.
    Future<({WidgetRef ref, BuildContext context, List<Route<dynamic>> pushed})>
        pumpRunner(WidgetTester tester, ProviderContainer container) async {
      late WidgetRef capturedRef;
      late BuildContext capturedContext;
      final pushed = <Route<dynamic>>[];
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorObservers: [_PushSpy(pushed)],
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (ref: capturedRef, context: capturedContext, pushed: pushed);
    }

    testWidgets('a notif TYPE chip closure sets notifSectionProvider, no push',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await pumpRunner(tester, container);

      // Default section is `all`; pick the שמירה chip for 'בטיחות' (safety).
      final ctx = deriveUpdatesContext(
        const NotifsLocation(
            persona: _kPersona,
            audience: _kAudience,
            section: NotifSection.all),
        threads: const [],
      );
      const target = '🦺 בטיחות';
      expect(container.read(notifSectionProvider), NotifSection.all,
          reason: 'sanity: starts on the default section');

      // Baseline = the routes already on the Navigator (MaterialApp's own home
      // route). The closure must add ZERO routes (keep-floating).
      final before = r.pushed.length;
      ctx.row.runByChip[target]!(r.ref, r.context);
      await tester.pump();

      expect(container.read(notifSectionProvider), NotifSection.safety,
          reason: 'tapping the בטיחות type chip filters to safety');
      expect(r.pushed.length, before,
          reason: 'a type chip mutates a provider only — keep-floating');
    });

    testWidgets(
        'a conversation chip closure sets updatesChatOpenProvider to the id, '
        'no push', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await pumpRunner(tester, container);

      final ctx = deriveUpdatesContext(
        const ChatsLocation(persona: _kPersona, audience: _kAudience),
        threads: [_thread('thread-42', 'אבי הקבלן'), _thread('z', 'בני')],
      );
      expect(container.read(updatesChatOpenProvider), isNull,
          reason: 'sanity: no chat open yet');

      final before = r.pushed.length;
      ctx.row.runByChip['אבי הקבלן']!(r.ref, r.context);
      await tester.pump();

      expect(container.read(updatesChatOpenProvider), 'thread-42',
          reason: 'the conversation chip hands its id to the open-provider '
              '(the SCREEN performs the route push, not the keyboard)');
      expect(r.pushed.length, before,
          reason: 'the chip itself pushes no route — keep-floating');
    });

    testWidgets(
        'a section chip KbDestination.run flips the updates sub-tab, no push',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await pumpRunner(tester, container);

      final ctx = deriveUpdatesContext(
        const UpdatesRoot(persona: _kPersona, audience: _kAudience, subTab: 0),
        threads: const [],
      );
      final before = r.pushed.length;

      // שיחות → _openUpdatesSub(1): mainTab 2 + updatesSubTab 1.
      final KbDestination chats = ctx.row.destByChip['שיחות']!;
      chats.run(r.ref, r.context);
      await tester.pump();
      expect(container.read(mainTabProvider), 2,
          reason: 'שיחות routes to the updates tab');
      expect(container.read(updatesSubTabProvider), 1,
          reason: 'שיחות selects the chats sub-tab');

      // התראות → _openUpdatesSub(0).
      final KbDestination notifs = ctx.row.destByChip['התראות']!;
      notifs.run(r.ref, r.context);
      await tester.pump();
      expect(container.read(updatesSubTabProvider), 0,
          reason: 'התראות selects the notifications sub-tab');

      expect(r.pushed.length, before,
          reason: 'section chips swap a sub-tab under the overlay — no push');
    });
  });
}

/// Records every route pushed onto the Navigator, so a test can prove a dispatch
/// closure performed NO navigation (the keep-floating guarantee: a chip sets a
/// provider; only the SCREEN — not the keyboard — ever pushes a route).
class _PushSpy extends NavigatorObserver {
  _PushSpy(this.pushed);
  final List<Route<dynamic>> pushed;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}
