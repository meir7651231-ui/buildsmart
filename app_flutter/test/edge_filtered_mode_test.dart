// ratchet — מצב-מסונן · חיווט-הדגל הריצתי והחלפת-הגשר (שלב E-wiring).
import 'package:buildsmart/data/edge/filtered_auth_gateway.dart';
import 'package:buildsmart/data/edge/filtered_mode.dart';
import 'package:buildsmart/data/edge/filtered_session.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemStore implements EdgeKvStore {
  final Map<String, String> m = {};
  @override
  String? read(String key) => m[key];
  @override
  void write(String key, String value) => m[key] = value;
  @override
  void remove(String key) => m.remove(key);
}

void main() {
  group('מצב-מסונן — דגל ריצתי טהור', () {
    test('ברירת-מחדל כבוי · הדלקה כותבת · כיבוי מוחק (canonical-minimal)', () {
      final s = _MemStore();
      expect(readFilteredMode(s), isFalse);
      writeFilteredMode(s, on: true);
      expect(s.m[kFilteredModeKey], '1');
      expect(readFilteredMode(s), isTrue);
      writeFilteredMode(s, on: false);
      expect(s.m.containsKey(kFilteredModeKey), isFalse); // נמחק, לא 'false'
      expect(readFilteredMode(s), isFalse);
    });
  });

  group('מצב-מסונן — החלפת-גשר ב-authGatewayProvider', () {
    test('כבוי (ברירת-מחדל · Firebase-free) ⇒ גשר null, ביט-זהה להיום', () {
      final c = ProviderContainer(
        overrides: [edgeKvStoreProvider.overrideWithValue(_MemStore())],
      );
      addTearDown(c.dispose);
      expect(c.read(filteredModeProvider), isFalse);
      expect(c.read(authGatewayProvider), isNull); // אין Firebase בבדיקות
    });

    test('הדלקה ⇒ הגשר הופך ל-FilteredAuthGateway (ריאקטיבי)', () {
      final c = ProviderContainer(
        overrides: [edgeKvStoreProvider.overrideWithValue(_MemStore())],
      );
      addTearDown(c.dispose);
      expect(c.read(authGatewayProvider), isNull);
      c.read(filteredModeProvider.notifier).setEnabled(on: true);
      expect(c.read(filteredModeProvider), isTrue);
      expect(c.read(authGatewayProvider), isA<FilteredAuthGateway>());
    });

    test('הדגל מתמיד — קונטיינר חדש על אותו אחסון נולד דלוק', () {
      final store = _MemStore();
      final c1 = ProviderContainer(
        overrides: [edgeKvStoreProvider.overrideWithValue(store)],
      );
      c1.read(filteredModeProvider.notifier).setEnabled(on: true);
      c1.dispose();
      // "ריצה חדשה" — אותו אחסון (localStorage בפרוד):
      final c2 = ProviderContainer(
        overrides: [edgeKvStoreProvider.overrideWithValue(store)],
      );
      addTearDown(c2.dispose);
      expect(c2.read(filteredModeProvider), isTrue);
      expect(c2.read(authGatewayProvider), isA<FilteredAuthGateway>());
    });
  });
}
