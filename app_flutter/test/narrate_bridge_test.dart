// Pins the AI site-summary BRIDGE (#ai-site-summary): the wire between the live
// site engines and the narrator prompt. The swarm flagged that this line-builder
// was untested — a typo in a status string ('פתוח'/'טופל'/'מתוכננת'/'בוצעה') would
// silently zero a count and the AI would narrate wrong numbers. This guards it.
// Pure — operates on plain model lists, no providers/gateway/pump.
import 'package:buildsmart/state/site_hub_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('siteSummaryReportLines counts snags by the REAL status strings', () {
    const snags = [
      SiteSnag(id: '1', what: 'a', loc: 'x', severity: 'גבוה', status: 'פתוח'),
      SiteSnag(id: '2', what: 'b', loc: 'y', severity: 'נמוך', status: 'פתוח'),
      SiteSnag(id: '3', what: 'c', loc: 'z', severity: 'נמוך', status: 'טופל'),
    ];
    final lines = siteSummaryReportLines(const [], snags, const []);
    expect(lines, contains('🔧 ליקויים: 2 פתוחים · 1 טופלו'),
        reason: 'open/fixed must match the real "פתוח"/"טופל" status values');
  });

  test('siteSummaryReportLines counts inspections by the REAL status strings',
      () {
    const insp = [
      SiteInspection(id: '1', what: 'a', due: 'מחר', status: 'מתוכננת'),
      SiteInspection(id: '2', what: 'b', due: 'אתמול', status: 'בוצעה'),
      SiteInspection(id: '3', what: 'c', due: 'מחר', status: 'מתוכננת'),
    ];
    final lines = siteSummaryReportLines(const [], const [], insp);
    expect(lines, contains('🔍 ביקורות: 2 מתוכננות · 1 בוצעו'),
        reason: 'planned/done must match "מתוכננת"/"בוצעה"');
  });

  test('siteSummaryReportLines surfaces the diary count + latest entry', () {
    const diary = [
      DiaryEntry(date: '23.6', text: 'יציקת קומה 3', workers: 4, weather: 'בהיר'),
      DiaryEntry(date: '22.6', text: 'טיח', workers: 3, weather: 'בהיר'),
    ];
    final lines = siteSummaryReportLines(diary, const [], const []);
    expect(lines, contains('📓 רישומי-יומן: 2'));
    expect(lines.any((l) => l.contains('יציקת קומה 3')), isTrue,
        reason: 'the latest diary text is surfaced');
  });

  test('empty site → zero counts, no latest-entry line (honest)', () {
    final lines = siteSummaryReportLines(const [], const [], const []);
    expect(lines, contains('📓 רישומי-יומן: 0'));
    expect(lines, contains('🔧 ליקויים: 0 פתוחים · 0 טופלו'));
    expect(lines.any((l) => l.contains('רישום אחרון')), isFalse,
        reason: 'no invented "latest entry" when the diary is empty');
  });
}
