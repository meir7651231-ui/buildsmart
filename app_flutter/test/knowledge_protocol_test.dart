import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// ENFORCEMENT of the knowledge protocol (the "teeth"). Runs as part of
/// `flutter test`, so a protocol violation turns the suite red:
///   - a screen regressing to a dark scaffold,
///   - a wired pure-helper being removed/renamed,
///   - the WIRING contract or knowledge docs drifting from the code.
/// Source-scanning, no app launch. CWD is the package root under `flutter test`.
void main() {
  String read(String p) => File(p).readAsStringSync();

  group('protocol · light-mode guard', () {
    // A near-black fill used as a *surface* (ColoredBox / Container /
    // DecoratedBox), not as a text colour. `0xFF111111` as a TextStyle colour is
    // legitimate (e.g. ink on light chat bubbles), so we only flag fills.
    final darkFill = RegExp(
      r'(ColoredBox|Container|DecoratedBox)\(\s*color:\s*(const\s+)?'
      r'Color\(0xFF111111\)',
    );
    test('no screen uses a dark surface (0xFF111111 / bgDark)', () {
      final offenders = <String>[];
      for (final f in Directory('lib/screens').listSync().whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final s = f.readAsStringSync();
        if (s.contains('backgroundColor: const Color(0xFF111111)') ||
            s.contains('backgroundColor: BsTokens.bgDark') ||
            darkFill.hasMatch(s)) {
          offenders.add(f.path);
        }
      }
      expect(offenders, isEmpty,
          reason: 'dark surface reintroduced in: $offenders');
    });
  });

  group('protocol · wired helpers exist (contract ↔ code)', () {
    void mustContain(String file, List<String> symbols) {
      final s = read(file);
      for (final sym in symbols) {
        expect(s.contains(sym), isTrue, reason: '$sym missing from $file');
      }
    }

    test('store cart-math helpers', () {
      mustContain('lib/screens/store_screen.dart', [
        'int deliveryFeeFor(',
        'int cartVat(',
        'int cartTotal(',
        'bool cartBelowMinimum(',
        'bool cartNeedsLargeConfirm(',
        'CartPaymentMethod cartPaymentFor(',
        'CartDelivery cartDeliveryFor(',
      ]);
    });
    test('notification helpers', () {
      mustContain('lib/screens/notifications_screen.dart', [
        'Set<NotifSection> notifMutedSections(',
        'bool notifPasses(',
        'bool passesImportance(',
        'bool shouldCollapseNotifRun(',
        'bool isNewDateGroup(',
      ]);
    });
    test('catalog + chat + cart helpers', () {
      mustContain('lib/data/lipskey_catalog.dart', ['bool indexableWord(']);
      mustContain('lib/screens/chats_screen.dart', ['bool showOnlinePresence(']);
      mustContain('lib/state/smart_cart.dart',
          ['int qtyForKey(', 'void setQtyForKey(']);
    });
  });

  group('protocol · knowledge base present & contract in sync', () {
    test('all knowledge docs exist and are non-trivial', () {
      for (final p in const [
        'knowledge/README.md',
        'knowledge/TARGET.md',
        'knowledge/SPEC.md',
        'knowledge/STATUS.md',
        'knowledge/ARCHITECTURE.md',
        'knowledge/TESTING.md',
        'knowledge/CONVENTIONS.md',
        'knowledge/DECISIONS.md',
        'WIRING.md',
      ]) {
        expect(File(p).existsSync(), isTrue, reason: '$p missing');
        expect(read(p).length, greaterThan(400), reason: '$p too short');
      }
    });
    test('WIRING.md references every enforced helper', () {
      final w = read('WIRING.md');
      for (final sym in const [
        'qtyForKey',
        'setQtyForKey',
        'notifMutedSections',
        'passesImportance',
        'showOnlinePresence',
      ]) {
        expect(w.contains(sym), isTrue,
            reason: 'WIRING.md lost its reference to $sym');
      }
    });
  });
}
