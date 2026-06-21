// keyboard_tool_tree — the SCREEN-AWARE tool tree behind the morph keyboard.
//
// Pure structural assertions (no widget pump needed): the HOME node-list is 8
// nodes in the legacy order with מהירים now a BRANCH (3 quick-action children)
// and the rest leaves; the KBD node-list carries תפריט as a BRANCH with exactly
// the AI-hub + settings children and marks קולי as [isVoiceInput]; leaf/branch
// roles are well-formed (a leaf has an action and no children; a branch has
// children and no action), and [kbTilesFor] projects a node-list to pure tiles
// whose id == index. We do NOT invoke the leaf actions here (they touch real
// screens/providers); the seam behaviour they delegate to is covered by
// keyboard_tool_actions_test, and the morph wiring by floating_card_keyboard_test.

import 'package:buildsmart/screens/keyboard_tool_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kbHomeNodes', () {
    test('is 8 nodes in the legacy home order; only מהירים is a branch', () {
      final nodes = kbHomeNodes();
      expect(nodes.length, 8, reason: 'the 8 home tools');
      const labels = <String>[
        'מחלקות',
        'עץ חכם',
        'מסלול',
        'מהירים',
        'הזמנות',
        'מאתר',
        'חיבור',
        'מועדפים',
      ];
      expect(nodes.map((n) => n.label).toList(), labels,
          reason: 'order matches the legacy home layer');
      for (final n in nodes) {
        if (n.label == 'מהירים') {
          // STEP D — מהירים is now a BRANCH (3 quick-action children), not a leaf.
          expect(n.isBranch, isTrue, reason: 'מהירים morphs to its children');
          expect(n.action, isNull, reason: 'a branch has no leaf action');
        } else {
          expect(n.isBranch, isFalse, reason: '"${n.label}" is a leaf');
          expect(n.action, isNotNull, reason: '"${n.label}" carries an action');
          expect(n.children, isEmpty, reason: '"${n.label}" has no children');
        }
      }
    });

    test('the מהירים branch has the 3 _QuickTools children, each a leaf', () {
      // STEP D — mirrors smart_home_screen _QuickTools exactly: scan-plan / my
      // stock / tasks. Each child is a keep-floating LEAF (carries an action).
      final quick = kbHomeNodes().firstWhere((n) => n.label == 'מהירים');
      expect(quick.children.length, 3, reason: 'three quick actions');
      expect(quick.children.map((c) => c.label).toList(),
          <String>['סריקת תוכנית', 'המלאי שלי', 'משימות'],
          reason: 'mirrors _QuickTools rows in order');
      for (final c in quick.children) {
        expect(c.isBranch, isFalse, reason: '"${c.label}" child is a leaf');
        expect(c.action, isNotNull, reason: '"${c.label}" child runs an action');
      }
    });

    test('the הזמנות leaf is a real keep-floating action (not a branch)', () {
      // STEP D — הזמנות jumps to the store orders section; it is a wired LEAF.
      final orders = kbHomeNodes().firstWhere((n) => n.label == 'הזמנות');
      expect(orders.isBranch, isFalse, reason: 'הזמנות is a leaf');
      expect(orders.action, isNotNull, reason: 'הזמנות carries a nav action');
    });
  });

  group('kbKbdNodes', () {
    test('is 5 nodes; תפריט is a BRANCH, the rest are leaves', () {
      final nodes = kbKbdNodes();
      expect(nodes.length, 5, reason: 'קולי/חיפוש/תפריט/מצלמה/היכרות');
      expect(nodes.map((n) => n.label).toList(),
          <String>['קולי', 'חיפוש', 'תפריט', 'מצלמה', 'היכרות'],
          reason: 'order matches the legacy kbd layer');

      for (final n in nodes) {
        if (n.label == 'תפריט') {
          expect(n.isBranch, isTrue, reason: 'תפריט morphs to children');
          expect(n.action, isNull, reason: 'a branch has no leaf action');
        } else {
          expect(n.isBranch, isFalse, reason: '"${n.label}" is a leaf');
          expect(n.action, isNotNull, reason: '"${n.label}" carries an action');
        }
      }
    });

    test('only קולי is marked isVoiceInput (the field-intercept node)', () {
      // STEP D — the floating keyboard intercepts the voice-marked node to run
      // the mic→field path; exactly one kbd node carries the marker, and it is
      // a LEAF (it still keeps a legacy "בקרוב" fallback action).
      final nodes = kbKbdNodes();
      final voice = nodes.firstWhere((n) => n.label == 'קולי');
      expect(voice.isVoiceInput, isTrue, reason: 'קולי is the voice-input leaf');
      expect(voice.isBranch, isFalse, reason: 'קולי stays a leaf');
      expect(voice.action, isNotNull,
          reason: 'קולי keeps a legacy fallback action');
      for (final n in nodes.where((n) => n.label != 'קולי')) {
        expect(n.isVoiceInput, isFalse,
            reason: '"${n.label}" is not voice-marked');
      }
    });

    test('the תפריט branch children are AI-hub (בינה) + settings (הגדרות)', () {
      final menu = kbKbdNodes().firstWhere((n) => n.label == 'תפריט');
      expect(menu.children.length, 2, reason: 'exactly two destinations');
      expect(menu.children.map((c) => c.label).toList(),
          <String>['בינה', 'הגדרות']);
      // Each child is itself a LEAF that pushes a route.
      for (final c in menu.children) {
        expect(c.isBranch, isFalse, reason: '"${c.label}" child is a leaf');
        expect(c.action, isNotNull, reason: '"${c.label}" child pushes a route');
      }
    });
  });

  group('kbTilesFor', () {
    test('projects a node-list to pure tiles with id == index', () {
      final nodes = kbKbdNodes();
      final tiles = kbTilesFor(nodes);
      expect(tiles.length, nodes.length);
      for (var i = 0; i < nodes.length; i++) {
        expect(tiles[i].id, i, reason: 'tile id is the node index');
        expect(tiles[i].label, nodes[i].label, reason: 'label carried through');
        expect(tiles[i].icon, nodes[i].icon, reason: 'icon carried through');
      }
    });

    test('an empty node-list projects to no tiles', () {
      expect(kbTilesFor(const <KbToolNode>[]), isEmpty);
    });
  });

  group('KbToolNode roles', () {
    test('a leaf reports isBranch:false; a branch reports isBranch:true', () {
      final leaf = KbToolNode.leaf(
        icon: Icons.star,
        label: 'L',
        action: (_, __) {},
      );
      final branch = KbToolNode.branch(
        icon: Icons.folder,
        label: 'B',
        children: <KbToolNode>[leaf],
      );
      expect(leaf.isBranch, isFalse);
      expect(leaf.children, isEmpty);
      expect(branch.isBranch, isTrue);
      expect(branch.action, isNull);
      expect(branch.children, hasLength(1));
    });

    test('isVoiceInput defaults false; a leaf can opt in; a branch never does',
        () {
      final plainLeaf =
          KbToolNode.leaf(icon: Icons.star, label: 'L', action: (_, __) {});
      final voiceLeaf = KbToolNode.leaf(
        icon: Icons.mic,
        label: 'V',
        action: (_, __) {},
        isVoiceInput: true,
      );
      final branch = KbToolNode.branch(
        icon: Icons.folder,
        label: 'B',
        children: <KbToolNode>[plainLeaf],
      );
      expect(plainLeaf.isVoiceInput, isFalse, reason: 'leaf defaults off');
      expect(voiceLeaf.isVoiceInput, isTrue, reason: 'leaf can opt in');
      expect(branch.isVoiceInput, isFalse, reason: 'a branch is never voice');
    });
  });
}
