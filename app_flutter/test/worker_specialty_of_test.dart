// #104ב guard tests · workerSpecialtyOf — lib/screens/worker_profile_screen.dart.
// התמחות has ONE source of truth: the latest saved Form101 for the username.
// The function is a PURE top-level helper (username, WorkerFormsState,
// WorkerProfile) → String, so it is tested directly with no widget/container.
//
// Fallback chain (אין המצאות):
//   1. the latest saved Form101.specialty for this username (newest year wins);
//   2. else the legacy WorkerProfile.specialty override (back-compat);
//   3. else '' (honest empty — the UI renders nothing).
import 'package:buildsmart/screens/worker_profile_screen.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:buildsmart/state/worker_profile_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal Form101 builder — only the fields workerSpecialtyOf reads
/// (username, year, specialty) carry meaning; the rest are honest fillers.
Form101 _form(String username, int year, String specialty) => Form101(
      username: username,
      year: year,
      fullName: 'x',
      idNumber: '123456789',
      phone: '0501234567',
      specialty: specialty,
      maritalStatus: 'רווק/ה',
      savedTs: DateTime(year),
    );

void main() {
  test('מחזיר את ההתמחות מטופס 101 (כשקיים) — מקור-האמת', () {
    final forms = WorkerFormsState(forms: [_form('ran', 2026, 'אינסטלטור')]);
    // even with a DIFFERENT legacy override, 101 wins.
    const profile = WorkerProfile(specialty: 'חשמלאי');
    expect(workerSpecialtyOf('ran', forms, profile), 'אינסטלטור');
  });

  test('בין כמה טפסי 101 — השנה החדשה ביותר מנצחת', () {
    final forms = WorkerFormsState(forms: [
      _form('ran', 2024, 'כללי'),
      _form('ran', 2026, 'אינסטלטור'), // newest
      _form('ran', 2025, 'חשמלאי'),
    ]);
    expect(workerSpecialtyOf('ran', forms, const WorkerProfile()),
        'אינסטלטור');
  });

  test('כשאין טופס 101 — נופל ל-WorkerProfile.specialty ה-legacy', () {
    const profile = WorkerProfile(specialty: 'חשמלאי');
    expect(workerSpecialtyOf('ran', const WorkerFormsState(), profile),
        'חשמלאי');
  });

  test('טופס 101 של משתמש אחר אינו נחשב — מסונן לפי username', () {
    final forms = WorkerFormsState(forms: [_form('omer', 2026, 'אינסטלטור')]);
    const profile = WorkerProfile(specialty: 'חשמלאי');
    // omer's 101 is ignored for ran → falls back to ran's legacy override.
    expect(workerSpecialtyOf('ran', forms, profile), 'חשמלאי');
  });

  test('טופס 101 עם התמחות ריקה/רווחים מדולג — נופל ל-legacy', () {
    final forms = WorkerFormsState(forms: [
      _form('ran', 2026, '   '), // blank specialty → skipped
    ]);
    const profile = WorkerProfile(specialty: 'חשמלאי');
    expect(workerSpecialtyOf('ran', forms, profile), 'חשמלאי');
  });

  test('טופס 101 חדש-יותר אך ריק לא דורס טופס ישן-יותר עם התמחות אמיתית', () {
    final forms = WorkerFormsState(forms: [
      _form('ran', 2025, 'אינסטלטור'),
      _form('ran', 2026, ''), // newer year but blank → must be skipped
    ]);
    expect(workerSpecialtyOf('ran', forms, const WorkerProfile()),
        'אינסטלטור');
  });

  test('ההתמחות המוחזרת עברה trim', () {
    final forms = WorkerFormsState(forms: [_form('ran', 2026, '  אינסטלטור ')]);
    expect(workerSpecialtyOf('ran', forms, const WorkerProfile()),
        'אינסטלטור');
  });

  test('legacy specialty עובר trim כשאין 101', () {
    const profile = WorkerProfile(specialty: '  חשמלאי  ');
    expect(workerSpecialtyOf('ran', const WorkerFormsState(), profile),
        'חשמלאי');
  });

  test('אין 101 ואין legacy — מחרוזת ריקה (מצב-ריק כן)', () {
    expect(
      workerSpecialtyOf('ran', const WorkerFormsState(), const WorkerProfile()),
      '',
    );
  });
}
