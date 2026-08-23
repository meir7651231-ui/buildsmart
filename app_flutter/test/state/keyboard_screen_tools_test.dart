// keyboard_screen_tools — tests for the STACK-AWARE per-screen tool registry that
// makes the floating keyboard a live mirror of the front-most route's tools
// (lib/state/keyboard_screen_tools.dart).
//
// The registry's CENTRAL PROMISE (file header) is LIFO-correctness WITHOUT order
// assumptions: each [KbScreen] pushes a uniquely-tokened entry on mount and
// removes ITS OWN entry by token on unmount (never a blind `removeLast`), so it
// stays correct under any dispose/initState interleaving across route
// transitions. The top of the stack (`last`) is always the front-most surviving
// route's tools, and [currentScreenTools] reads it.
//
// These tests exercise the [KeyboardScreenToolsNotifier] DIRECTLY (it is a plain
// StateNotifier — the `kKbGlobal` gate lives in the [KbScreen] widget, not the
// notifier, so the notifier's contract is testable without a widget tree or the
// flag). They cover the file header's five load-bearing claims:
//   (a) buried-entry removal (the LIFO claim is by-token, not by-position);
//   (b) pop reveals the parent (last == the remaining entry);
//   (c) double-remove is no-churn (identical list instance — the doc's idempotence);
//   (d) re-push of an existing token is replace-in-place (length + position held);
//   (e) interleaved dispose (remove a BURIED token first) keeps the top correct.

import 'package:buildsmart/screens/keyboard_tool_tree.dart' show KbToolNode;
import 'package:buildsmart/state/keyboard_screen_tools.dart';
import 'package:flutter/widgets.dart' show IconData;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A throwaway leaf node carrying a recognisable [label] so a test can assert
  // WHICH screen's tools sit on top. The icon is an arbitrary const IconData (no
  // font lookup happens in these pure-state tests).
  KbToolNode node(String label) => KbToolNode.leaf(
        icon: const IconData(0xe000),
        label: label,
        action: (_, __) {},
      );

  List<KbToolNode> tools(String label) => <KbToolNode>[node(label)];

  group('KeyboardScreenToolsNotifier — LIFO-by-token stack', () {
    test('(a) buried-entry removal: push two, remove the FIRST ⇒ [second]', () {
      final n = KeyboardScreenToolsNotifier();
      final tokenA = Object();
      final tokenB = Object();
      // Push A then B, then remove the BURIED entry (the first-pushed, now
      // underneath B). A blind `removeLast` would wrongly drop B; by-token removal
      // drops exactly A.
      n
        ..push(KbScreenToolsEntry(tokenA, tools('A')))
        ..push(KbScreenToolsEntry(tokenB, tools('B')))
        ..removeToken(tokenA);

      expect(n.state.length, 1, reason: 'only A removed');
      expect(n.state.single.token, tokenB,
          reason: 'the surviving entry is B (removal is by token, not position)');
      expect(currentScreenTools(n.state)!.single.label, 'B');
    });

    test('(b) pop reveals the parent: push A, push B, remove B ⇒ last == A', () {
      final n = KeyboardScreenToolsNotifier();
      final tokenA = Object();
      final tokenB = Object();
      // Push A then B, then pop B → its parent A is revealed.
      n
        ..push(KbScreenToolsEntry(tokenA, tools('A')))
        ..push(KbScreenToolsEntry(tokenB, tools('B')))
        ..removeToken(tokenB);

      expect(n.state.length, 1);
      expect(n.state.last.token, tokenA);
      expect(currentScreenTools(n.state)!.single.label, 'A',
          reason: 'popping the top reveals the parent tools');
    });

    test('(c) double removeToken ⇒ IDENTICAL list instance (no churn)', () {
      final n = KeyboardScreenToolsNotifier();
      final tokenA = Object();
      // Push then remove → empty. Capture that list instance.
      n
        ..push(KbScreenToolsEntry(tokenA, tools('A')))
        ..removeToken(tokenA);
      final afterFirst = n.state;
      expect(afterFirst, isEmpty);

      // A second remove of an already-gone token must NOT emit a new list (the
      // doc's "same-length ⇒ keep the identical list, so no spurious rebuild").
      n.removeToken(tokenA);
      expect(identical(n.state, afterFirst), isTrue,
          reason: 'idempotent removeToken keeps the identical list instance');
    });

    test('(d) re-push same token, different tools ⇒ length 1, position held', () {
      final n = KeyboardScreenToolsNotifier();
      final tokenParent = Object();
      final tokenChild = Object();
      // Push parent then child; then the buried PARENT rebuilds with a fresh tools
      // list (a didUpdateWidget re-push). Replace-in-place must keep its POSITION
      // (still underneath the child) and NOT duplicate it — so `last` stays the
      // child, not the parent.
      n
        ..push(KbScreenToolsEntry(tokenParent, tools('parent-v1')))
        ..push(KbScreenToolsEntry(tokenChild, tools('child')))
        ..push(KbScreenToolsEntry(tokenParent, tools('parent-v2')));

      expect(n.state.length, 2, reason: 'no duplicate entry for the re-pushed token');
      expect(n.state.first.token, tokenParent,
          reason: 'the re-pushed parent keeps its (buried) position');
      expect(n.state.first.tools.single.label, 'parent-v2',
          reason: 'the entry is swapped in place to the new tools');
      expect(n.state.last.token, tokenChild,
          reason: 'last is still the child — a buried re-push never reorders the '
              'stack to look front-most');
    });

    test('(e) interleaved dispose: remove BURIED A first ⇒ last stays B', () {
      final n = KeyboardScreenToolsNotifier();
      final tokenA = Object();
      final tokenB = Object();
      // Push A then B, then simulate Flutter running A.dispose BEFORE B.dispose
      // (overlapping route transitions): A is removed while B is still front-most.
      n
        ..push(KbScreenToolsEntry(tokenA, tools('A')))
        ..push(KbScreenToolsEntry(tokenB, tools('B')))
        ..removeToken(tokenA);
      expect(n.state.last.token, tokenB,
          reason: 'the front-most route B stays on top while its parent disposes');

      // Then B disposes too → the stack empties (back to the tab fallback).
      n.removeToken(tokenB);
      expect(n.state, isEmpty);
      expect(currentScreenTools(n.state), isNull,
          reason: 'empty stack ⇒ no current screen tools (keyboard falls back)');
    });
  });

  group('currentScreenTools', () {
    test('empty stack ⇒ null (tab fallback)', () {
      expect(currentScreenTools(const <KbScreenToolsEntry>[]), isNull);
    });

    test('non-empty ⇒ the TOP (last) entry tools', () {
      final stack = <KbScreenToolsEntry>[
        KbScreenToolsEntry(Object(), tools('under')),
        KbScreenToolsEntry(Object(), tools('top')),
      ];
      expect(currentScreenTools(stack)!.single.label, 'top');
    });
  });
}
