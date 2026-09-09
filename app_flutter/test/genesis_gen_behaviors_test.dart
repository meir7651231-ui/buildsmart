// 🧩 חולל ע"י behavior-compose — בדיקת שכבת-ההרכבה (היום = 2026-09-08 יום-שלישי). אל תערוך ידנית.
import 'package:buildsmart/genesis/dart-gen-bs/gen_behaviors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('יום-בשבוע · לא-בשבת · בסיס-דחייה · הוספת-ימים', () {
    expect(bhWeekday('2026-09-08'), 2); expect(bhWeekday('2026-09-12'), 6); expect(bhWeekday('2026-09-13'), 0);
    expect(bhSoftShift('2026-09-12', false), '2026-09-13'); expect(bhSoftShift('2026-09-12', true), '2026-09-12');
    expect(bhDueBase('2026-09-01', '2026-09-08'), '2026-09-08'); expect(bhDueBase('2026-09-20', '2026-09-08'), '2026-09-20');
    expect(bhPlusDays('2026-09-30', 1), '2026-10-01'); expect(bhDaysSince('2026-09-05', '2026-09-08'), 3);
  });
  test('תזכורות-שלפנינו · תווית-תאריך · לפני · תחילת-תוכנית', () {
    expect(bhAheadOffsets('2026-09-09', true, '2026-09-08', [3, 1, 0]), [1, 0]);
    expect(bhDayLabelParts('2026-09-13', '2026-09-08'), ['weekday', '0', '13.9']); expect(bhDayLabelParts('2027-10-03', '2026-09-08')[2], '3.10.2027'); expect(bhDayLabelParts('2026-09-09', '2026-09-08')[0], 'tomorrow');
    expect(bhAgoParts('2026-09-08T09:55:00', '2026-09-08T10:00:00'), ['min', '5']); expect(bhAgoParts('2026-09-08T09:59:40', '2026-09-08T10:00:10')[0], 'now');
    expect(bhPlanStart('2026-09-08', 9, '2026-09-08T15:03:00'), '15:05'); expect(bhPlanStart('2026-09-08', 9, '2026-09-08T07:00:00'), '09:00');
  });
  test('נרמול · ספרות · קידומת · פתוחים · אלפים', () {
    expect(bhNormName('רות לוי'), 'רותלוי'); expect(bhNormSearch('שלום'), 'שלומ');
    expect(bhDigitsQuery('1,250'), '1,250'); expect(bhDigitsQuery('ארנונה 1250'), '');
    expect(bhPrefixRest('איפה הפיקדון', ['איפה', 'חפש']), 'הפיקדון'); expect(bhPrefixRest('הפיקדון איפה', ['איפה']), '');
    expect(bhOpenCount([{'__stage': '0'}, {'__stage': '2'}, {}], 3), 2); expect(bhThousands(1650), '1,650');
  });
  test('G35 · חיפוש-סלחן · אותו-שם · תאריך-עברי · איחוד-היסטים · שורות-קבוצה', () {
    expect(bhSearchScore('ארנונה', 'ארנונה'), 100); expect(bhSearchScore('ארנ', 'ארנונה 1250'), 80); expect(bhSearchScore('1250', 'ארנונה 1250'), 62);
    expect(bhSearchScore('ארנונא', 'ארנונה לעירייה'), 40); expect(bhSearchScore('ארנונא', 'חשמל'), 0); expect(bhSearchScore('אר', 'ארט'), 80); expect(bhSearchScore('קק', 'חשמל'), 0);
    expect(bhSameName('רות לוי', 'לוי רות'), true); expect(bhSameName('רות לוי', 'רות כהן'), false); expect(bhSameName('נועה', 'נועה'), true); expect(bhSameName('', 'נועה'), false);
    expect(bhHebDate('2026-09-08'), 'כ״ו אלול תשפ״ו'); expect(bhHebDate(''), '');
    expect(bhAheadOffsetsUnion(['2026-09-09', '2026-09-12'], true, '2026-09-08', [3, 1, 0]), [3, 1, 0]); expect(bhAheadOffsetsUnion(['2026-09-09'], true, '2026-09-08', [3, 1, 0]), [1, 0]);
    expect(bhGroupRows([{'group': 'g1'}, {'group': 'g1'}, {}], 'group'), [['g1', 2], ['', 1]]);
  });
  test('G36 · מפתח-טלפון · wa · קבוצות-אדם · התכוונת · חלונות-פנויים', () {
    expect(bhPhoneKey('052-123-4567'), '521234567'); expect(bhWaPhone('+972 52-123-4567'), '972521234567'); expect(bhWaPhone('abc'), '');
    final g = bhPersonGroups(['רות לוי', 'רותי לוי', 'דן כהן', 'רות  לוי'], {'רות לוי': ['052-1234567'], 'רותי לוי': ['+972521234567'], 'דן כהן': ['03-5551234']});
    expect(g.length, 1); expect(g.first.toSet(), {'רות לוי', 'רותי לוי', 'רות  לוי'});
    expect(bhClosest('ארנונא', ['ארנונה', 'חשמל']), 'ארנונה'); expect(bhClosest('ליקוים', ['ליקויים אחרי כניסה לדירה', 'חשמל']), 'ליקויים אחרי כניסה לדירה'); expect(bhClosest('חשמל', ['חשמל']), ''); expect(bhClosest('זזזז', ['ארנונה']), ''); expect(bhClosest('אר', ['ארט']), '');
    expect(bhFreeWindows([['10:00', '10:30'], ['12:00', '13:00']], '09:00', '18:00', 30), [['09:00', '10:00'], ['10:30', '12:00'], ['13:00', '18:00']]);
    expect(bhFreeWindows([['09:00', '09:20']], '09:00', '09:40', 30), <List<String>>[]); expect(bhFreeWindows(const [], '09:00', '10:00', 30), [['09:00', '10:00']]);
  });
}
