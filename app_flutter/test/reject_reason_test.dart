// Pins the AI rejection-reason drafter (#ai-reject-reason). This feature GENERATES
// text (not narrates data), so the safety is the CLOSED SET of reason-categories
// the prompt hands the model + the ban on inventing facts about the person. Pure —
// no gateway, no widget pump.
import 'package:buildsmart/screens/reject_reason_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rejectReasonPrompt names the role + person and lists the closed set', () {
    final p = rejectReasonPrompt(role: 'עובד', name: 'דני לוי');
    expect(p, contains('עובד'), reason: 'the requested role is named');
    expect(p, contains('דני לוי'), reason: 'the applicant is named');
    // The closed set of acceptable reason-categories must be embedded.
    expect(p, contains('מסמכים'));
    expect(p, contains('הדרכה'));
    expect(p, contains('בדיקת-רקע'));
    expect(p, contains('מקום פנוי'));
  });

  test('rejectReasonPrompt forbids inventing facts (anti-hallucination)', () {
    final p = rejectReasonPrompt(role: 'שליח', name: '');
    expect(p, contains('אל תמציא עובדות ספציפיות'),
        reason: 'the model must not invent facts about the person');
    expect(p, contains('המבקש'),
        reason: 'an empty name falls back to the neutral "המבקש"');
  });
}
