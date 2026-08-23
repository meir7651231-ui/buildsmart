// Drives [publishOrgConfig] WITHOUT Firebase — a fake [OrgConfigDocPort] stands
// in for the `orgConfigLive/current` doc, recording every write/remove so the
// whole best-effort publish path (write vs. remove vs. swallowed-throw) is unit
// tested on pure strings (the project's Firebase-free rule). Firebase is never
// initialised here.
import 'dart:async';

import 'package:buildsmart/state/org_config_sink_firebase.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in for the single Firestore doc. Records the last-written
/// json, whether remove() ran, and call counts; [throwOnWrite]/[throwOnRemove]
/// make the matching method throw to exercise the swallow-and-return-false path.
/// read()/snapshots() are trivial — publishOrgConfig never touches them.
class _FakePort implements OrgConfigDocPort {
  String? lastWritten;
  bool removeCalled = false;
  int writes = 0;
  int removes = 0;

  bool throwOnWrite = false;
  bool throwOnRemove = false;

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String companyJson) async {
    if (throwOnWrite) {
      throw StateError('write blew up (permission-denied / offline)');
    }
    lastWritten = companyJson;
    writes++;
  }

  @override
  Future<void> remove() async {
    if (throwOnRemove) {
      throw StateError('remove blew up (permission-denied / offline)');
    }
    removeCalled = true;
    removes++;
  }

  @override
  Stream<String?> snapshots() => const Stream<String?>.empty();
}

void main() {
  group('publishOrgConfig', () {
    test('a non-empty json is WRITTEN verbatim (never removed), returns true',
        () async {
      final port = _FakePort();

      final ok = await publishOrgConfig(port, '{"v":1}');

      expect(ok, isTrue);
      expect(port.writes, 1);
      expect(port.lastWritten, '{"v":1}');
      expect(port.removeCalled, isFalse);
      expect(port.removes, 0);
    });

    test('an EMPTY json is a reset → REMOVES the doc (never writes), returns true',
        () async {
      final port = _FakePort();

      final ok = await publishOrgConfig(port, '');

      expect(ok, isTrue);
      expect(port.removeCalled, isTrue);
      expect(port.removes, 1);
      expect(port.writes, 0);
      expect(port.lastWritten, isNull);
    });

    test('a throwing write is SWALLOWED → returns false, never rethrows',
        () async {
      final port = _FakePort()..throwOnWrite = true;

      // Must complete normally (no throw) and yield false.
      final ok = await publishOrgConfig(port, '{"v":1}');

      expect(ok, isFalse);
    });

    test('a throwing remove is SWALLOWED → returns false, never rethrows',
        () async {
      final port = _FakePort()..throwOnRemove = true;

      final ok = await publishOrgConfig(port, '');

      expect(ok, isFalse);
    });
  });
}
