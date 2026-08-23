// A2 — a vacation / training decision must fire its bell+chat+toast EXACTLY
// once. approve()/reject() now return whether a REAL pending→decided transition
// happened; the contractor HR sheet gates its side-effects on that bool, so a
// double-tap (or the manager deciding the same shared request) can't
// double-notify the worker. Engine-level proof: a repeat decide returns false.
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_trainings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('vacation: approve transitions once (true), a repeat is a no-op (false)',
      () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(vacationRequestsProvider.notifier);
    final r = n.submit(
      username: 'ran',
      workerName: 'רן',
      from: DateTime(2026, 7, 1),
      to: DateTime(2026, 7, 3),
      reason: '',
      role: 'worker',
      employerId: 'contractor-demo',
    );
    expect(n.approve(r.id), isTrue, reason: 'first decide is a real transition');
    expect(n.approve(r.id), isFalse,
        reason: 'already approved → no second fire');
    expect(n.reject(r.id), isFalse,
        reason: 'still decided → reject is also a no-op');
  });

  test('training: approve transitions once (true), a repeat is a no-op (false)',
      () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerTrainingsProvider.notifier);
    final t = await n.add(
      username: 'ran',
      title: 'עבודה בגובה',
      by: 'מדריך הבטיחות',
      date: DateTime(2026, 1, 1),
    );
    expect(t, isNotNull);
    n.sendForApproval(t!.id);
    expect(n.approve(t.id), isTrue, reason: 'first decide is a real transition');
    expect(n.approve(t.id), isFalse,
        reason: 'already approved → no second fire');
  });
}
