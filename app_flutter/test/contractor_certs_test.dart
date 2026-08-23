// Wave H2a · CONTRACTOR view of worker certifications —
// lib/state/worker_certs.dart. Mirrors the vacation H1 server-ready pattern: a
// WorkerCert carries an `employerId` (the worker→contractor LINK) so the
// contractor's read-only view (`certsForEmployer`) scopes to THEIR workers.
// This locks the FROZEN cross-file contract (Builder H2a state):
//   • WorkerCert.employerId (default '', additive, back-compat decode → '')
//   • add({...existing..., String employerId=''}) stamps it
//   • certsForEmployer(String) — Provider.family, employerId==arg, newest-first
//
// A cert added with an employerId lands in the matching contractor view; one
// under a DIFFERENT/empty employerId is OUT of scope; the view is newest-first;
// and WorkerCert.statusAt drives the expiry traffic-light. ProviderContainer,
// Firebase-free — mirrors contractor_vacation_approval_test.dart.
import 'package:buildsmart/state/worker_certs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The contractor whose worker-cert view is under test.
const String kEmployer = 'contractor-demo';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("add(employerId) lands in the contractor's scoped cert view", () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerCertsProvider.notifier);

    final cert = await n.add(
      username: 'ran',
      name: 'היתר עבודה בגובה',
      issuer: 'משרד העבודה',
      expiry: DateTime(2027, 1, 1),
      employerId: kEmployer,
    );
    expect(cert, isNotNull, reason: 'a fresh cert persists under the mock prefs');
    expect(cert!.employerId, kEmployer,
        reason: 'add stamps the employerId onto the cert');

    final view = c.read(certsForEmployer(kEmployer));
    expect(view.map((x) => x.id), [cert.id],
        reason: "the cert is in the contractor's scoped view");
  });

  test('SCOPE — a different/empty employerId is NOT in this view', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerCertsProvider.notifier);

    // NOTE: WorkerCert ids are `cert-<micros>` (no _seq), so rapid same-µs adds
    // can COLLIDE on id — assert on the unique `name` field, not the id.
    final mine = await n.add(
      username: 'ran',
      name: 'שלי',
      issuer: 'x',
      expiry: DateTime(2027, 1, 1),
      employerId: kEmployer,
    );
    final none = await n.add(
      username: 'dan',
      name: 'ללא מעסיק',
      issuer: 'x',
      expiry: DateTime(2027, 1, 1),
      // employerId omitted → defaults to ''
    );
    await n.add(
      username: 'gad',
      name: 'מעסיק אחר',
      issuer: 'x',
      expiry: DateTime(2027, 1, 1),
      employerId: 'contractor-other',
    );

    final names = c.read(certsForEmployer(kEmployer)).map((x) => x.name).toList();
    expect(names, [mine!.name],
        reason: 'only certs stamped with THIS employerId are in scope');
    expect(names, isNot(contains('מעסיק אחר')),
        reason: "another contractor's cert must not leak in");
    expect(names, isNot(contains('ללא מעסיק')),
        reason: 'an unscoped (empty employerId) cert must not leak in');
    expect(none!.employerId, '',
        reason: 'add without employerId defaults to empty string');

    // A different contractor sees only its own; an unqueried one sees nothing.
    expect(c.read(certsForEmployer('contractor-other')).map((x) => x.name),
        ['מעסיק אחר']);
    expect(c.read(certsForEmployer('nobody')), isEmpty);
  });

  test('contractor view is newest-first', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerCertsProvider.notifier);

    await n.add(
      username: 'ran',
      name: 'ראשון',
      issuer: 'x',
      expiry: DateTime(2027, 1, 1),
      employerId: kEmployer,
    );
    await n.add(
      username: 'omer',
      name: 'שני',
      issuer: 'x',
      expiry: DateTime(2027, 6, 1),
      employerId: kEmployer,
    );

    // newest-first = the most-recently-added row leads (insertion order
    // reversed). Keyed on `name` since ids can collide (no _seq in WorkerCert).
    expect(c.read(certsForEmployer(kEmployer)).map((x) => x.name),
        ['שני', 'ראשון'],
        reason: 'the contractor view lists the most-recent cert first');
  });

  test('back-compat — an old cert without employerId is excluded', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerCertsProvider.notifier);

    // Decoder contract: a record whose 'employerId' key is absent decodes to ''
    // (additive back-compat) and therefore falls OUTSIDE a non-empty query.
    final decoded = WorkerCert.tryFromJson({
      'id': 'cert-legacy',
      'username': 'ran',
      'name': 'ישן',
      'issuer': 'x',
      'expiry': DateTime(2027, 1, 1).toIso8601String(),
      'addedTs': DateTime(2026, 1, 1).toIso8601String(),
      // NOTE: no 'employerId' key — the pre-H2 wire shape.
    });
    expect(decoded, isNotNull);
    expect(decoded!.employerId, '',
        reason: 'a record without an employerId key decodes to empty');

    // An empty-employerId cert added alongside a scoped one is out of scope.
    await n.add(
      username: 'ran',
      name: 'מחובר',
      issuer: 'x',
      expiry: DateTime(2027, 1, 1),
      employerId: kEmployer,
    );
    await n.add(
      username: 'ran',
      name: 'ללא חיבור',
      issuer: 'x',
      expiry: DateTime(2027, 1, 1),
    );
    await _settle();
    expect(c.read(certsForEmployer(kEmployer)).map((x) => x.name), ['מחובר'],
        reason: 'an unscoped cert is excluded from a non-empty employer view');
  });

  // ── statusAt — the expiry traffic-light (fixed DateTimes, no now() flake) ────
  group('WorkerCert.statusAt', () {
    WorkerCert certExpiring(DateTime expiry) => WorkerCert(
          id: 'cert-x',
          username: 'ran',
          name: 'n',
          issuer: 'i',
          expiry: expiry,
          addedTs: DateTime(2026, 1, 1),
        );

    test('an expiry in the past → expired', () {
      final now = DateTime(2026, 6, 14, 9, 30);
      expect(certExpiring(DateTime(2026, 6, 13)).statusAt(now),
          CertExpiryStatus.expired);
    });

    test('an expiry within 31 days → expiringSoon', () {
      final now = DateTime(2026, 6, 14, 9, 30);
      // 20 days out, and the boundary day (exactly today) both count as soon.
      expect(certExpiring(DateTime(2026, 7, 4)).statusAt(now),
          CertExpiryStatus.expiringSoon);
      expect(certExpiring(DateTime(2026, 6, 14)).statusAt(now),
          CertExpiryStatus.expiringSoon,
          reason: 'expiring today is within the ≤31-day window');
    });

    test('a far-future expiry → valid', () {
      final now = DateTime(2026, 6, 14, 9, 30);
      expect(certExpiring(DateTime(2027, 1, 1)).statusAt(now),
          CertExpiryStatus.valid);
    });
  });
}
