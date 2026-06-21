// keyboard_tool_tree — the SCREEN-AWARE tool tree behind the morph keyboard.
//
// Pure structural assertions (no widget pump needed): the HOME node-list is 8
// leaves, the KBD node-list carries תפריט as a BRANCH with exactly the AI-hub +
// settings children, leaf/branch roles are well-formed (a leaf has an action and
// no children; a branch has children and no action), and [kbTilesFor] projects a
// node-list to pure tiles whose id == index. We do NOT invoke the leaf actions
// here (they touch real screens/providers); the seam behaviour they delegate to
// is covered by keyboard_tool_actions_test, and the morph wiring by
// floating_card_keyboard_test.

import 'package:buildsmart/screens/keyboard_tool_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kbHomeNodes', () {
    test('is 8 leaves, in the legacy home order, all with actions', () {
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
        expect(n.isBranch, isFalse, reason: '"${n.label}" is a leaf');
        expect(n.action, isNotNull, reason: '"${n.label}" carries an action');
        expect(n.children, isEmpty, reason: '"${n.label}" has no children');
      }
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
  });
}
