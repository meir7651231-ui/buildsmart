// 🧭 חולל ע"י balagan (G33 ב׳-ה · הכרעה-29) — הוכחת-עובדות: תאריכים-יחסיים בעברית · צורות-סכום · קרבה-למילת-השדה. היום מוזרק ⇒ דטרמיניסטי. אל תערוך ידנית.
import 'package:buildsmart/genesis/dart-gen-bs/gen_balagan_moments.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_calendar_home.dart' show GenAppCalendarHomeScreenToday;
import 'dart:convert';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_store.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_balagan_home.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_balagan_confirm.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_balagan_topics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 9, 8);   // יום שלישי
  BalaganModule mod(List<String> dates, List<String> nums, {List<String> tm = const [], List<String> ph = const [], List<String> pe = const [], List<String> pc = const [], String lf = '', String desc = 'מה'}) => BalaganModule(0, 't', 'בדיקה', 'בדיקה', '', const <String, double>{}, dates, nums, desc, lf, 'x', const <BalaganField>[], 1, const <String>[], timeFields: tm, phoneFields: ph, personFields: pe, percentFields: pc);
  test('עובדות 1: לשלם ארנונה מחר 350 ש"ח', () {
    final f = balaganFacts('לשלם ארנונה מחר 350 ש"ח', mod(['תאריך תשלום'], ['סכום']), today: today);
    expect(f['תאריך תשלום'], '2026-09-09');
    expect(f['סכום'], '350');
    expect(f['מה'], 'לשלם ארנונה');

    expect(f['__note'], 'לשלם ארנונה מחר 350 ש"ח');
  });
  test('עובדות 2: המשכיר מקזז 6,200 מהפיקדון של 8,000, מסרתי מפתח ב-1.8.2026', () {
    final f = balaganFacts('המשכיר מקזז 6,200 מהפיקדון של 8,000, מסרתי מפתח ב-1.8.2026', mod(['תאריך מסירת מפתח'], ['סכום הפיקדון']), today: today);
    expect(f['תאריך מסירת מפתח'], '2026-08-01');
    expect(f['סכום הפיקדון'], '8000');

    expect(f['__note'], 'המשכיר מקזז 6,200 מהפיקדון של 8,000, מסרתי מפתח ב-1.8.2026');
  });
  test('עובדות 3: פגישה עם הרו"ח בעוד שבועיים', () {
    final f = balaganFacts('פגישה עם הרו"ח בעוד שבועיים', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-09-22');
    expect(f['מה'], 'פגישה עם הרו"ח');

    expect(f['__note'], 'פגישה עם הרו"ח בעוד שבועיים');
  });
  test('עובדות 4: תשובה ביום ראשון', () {
    final f = balaganFacts('תשובה ביום ראשון', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-09-13');

    expect(f['__note'], 'תשובה ביום ראשון');
  });
  test('עובדות 5: לשלם בסוף החודש 8 אלף', () {
    final f = balaganFacts('לשלם בסוף החודש 8 אלף', mod(['מועד'], ['סכום']), today: today);
    expect(f['מועד'], '2026-09-30');
    expect(f['סכום'], '8000');

    expect(f['__note'], 'לשלם בסוף החודש 8 אלף');
  });
  test('עובדות 6: ההמחאה ב-15 לחודש', () {
    final f = balaganFacts('ההמחאה ב-15 לחודש', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-09-15');
    expect(f['מה'], 'ההמחאה');

    expect(f['__note'], 'ההמחאה ב-15 לחודש');
  });
  test('עובדות 7: בעוד שלושה ימים מגיע הטכנאי, 12.5 ₪ לדקה', () {
    final f = balaganFacts('בעוד שלושה ימים מגיע הטכנאי, 12.5 ₪ לדקה', mod(['מועד'], ['סכום']), today: today);
    expect(f['מועד'], '2026-09-11');
    expect(f['סכום'], '12.5');

    expect(f['__note'], 'בעוד שלושה ימים מגיע הטכנאי, 12.5 ₪ לדקה');
  });
  test('עובדות 8: החוזה נגמר 30.11', () {
    final f = balaganFacts('החוזה נגמר 30.11', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-11-30');

    expect(f['__note'], 'החוזה נגמר 30.11');
  });
  test('עובדות 9: ריבית 3.5% על 2,400', () {
    final f = balaganFacts('ריבית 3.5% על 2,400', mod(['מועד'], ['סכום', 'ריבית'], pc: ['ריבית']), today: today);
    expect(f['סכום'], '2400');
    expect(f['ריבית'], '3.5');
    expect(f.containsKey('מועד'), isFalse);
    expect(f['__note'], 'ריבית 3.5% על 2,400');
  });
  test('עובדות 10: יום ה׳ אצל הרופא', () {
    final f = balaganFacts('יום ה׳ אצל הרופא', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-09-10');

    expect(f['__note'], 'יום ה׳ אצל הרופא');
  });
  test('עובדות 11: פגישה עם רו"ח מחר ב-16:30', () {
    final f = balaganFacts('פגישה עם רו"ח מחר ב-16:30', mod(['מועד'], [], tm: ['שעה']), today: today);
    expect(f['מועד'], '2026-09-09');
    expect(f['שעה'], '16:30');
    expect(f['מה'], 'פגישה עם רו"ח');

    expect(f['__note'], 'פגישה עם רו"ח מחר ב-16:30');
  });
  test('עובדות 12: בשעה 9 אצל דני בשבוע הבא', () {
    final f = balaganFacts('בשעה 9 אצל דני בשבוע הבא', mod(['מועד'], [], tm: ['שעה'], pe: ['לקוח']), today: today);
    expect(f['מועד'], '2026-09-15');
    expect(f['שעה'], '09:00');
    expect(f['מה'], 'אצל דני');
    expect(f['לקוח'], 'דני');

    expect(f['__note'], 'בשעה 9 אצל דני בשבוע הבא');
  });
  test('עובדות 13: רות לוי 052-123-4567 פיקדון 8,000', () {
    final f = balaganFacts('רות לוי 052-123-4567 פיקדון 8,000', mod([], ['סכום הפיקדון'], ph: ['טלפון']), today: today);
    expect(f['טלפון'], '0521234567');
    expect(f['סכום הפיקדון'], '8000');
    expect(f['מה'], 'רות לוי פיקדון');

    expect(f['__note'], 'רות לוי 052-123-4567 פיקדון 8,000');
  });
  test('עובדות 14: לדבר עם המשכיר על התיקון', () {
    final f = balaganFacts('לדבר עם המשכיר על התיקון', mod([], [], pe: ['לקוח']), today: today);
    expect(f['לקוח'], 'המשכיר');

    expect(f['__note'], 'לדבר עם המשכיר על התיקון');
  });
  test('עובדות 15: רות לוי 052-123-4567 פיקדון 8,000', () {
    final f = balaganFacts('רות לוי 052-123-4567 פיקדון 8,000', mod([], ['סכום הפיקדון'], ph: ['טלפון'], pe: ['לקוח']), today: today);
    expect(f['לקוח'], 'רות לוי');
    expect(f['טלפון'], '0521234567');

    expect(f['__note'], 'רות לוי 052-123-4567 פיקדון 8,000');
  });
  test('עובדות 16: התקשרתי ללאה כהן 03-1234567', () {
    final f = balaganFacts('התקשרתי ללאה כהן 03-1234567', mod([], [], ph: ['טלפון'], pe: ['לקוח']), today: today);
    expect(f['לקוח'], 'לאה כהן');
    expect(f['טלפון'], '031234567');

    expect(f['__note'], 'התקשרתי ללאה כהן 03-1234567');
  });
  test('עובדות 17: לשלם ארנונה כל חודשיים ב-15 לחודש 350 ש"ח', () {
    final f = balaganFacts('לשלם ארנונה כל חודשיים ב-15 לחודש 350 ש"ח', mod(['מועד'], ['סכום']), today: today);
    expect(f['מועד'], '2026-09-15');
    expect(f['סכום'], '350');
    expect(f['__repeat'], 'm2');
    expect(f['מה'], 'לשלם ארנונה');

    expect(f['__note'], 'לשלם ארנונה כל חודשיים ב-15 לחודש 350 ש"ח');
  });
  test('עובדות 18: כל יום ראשון חוג ג׳ודו', () {
    final f = balaganFacts('כל יום ראשון חוג ג׳ודו', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-09-13');
    expect(f['__repeat'], 'w1');
    expect(f['מה'], 'חוג ג׳ודו');

    expect(f['__note'], 'כל יום ראשון חוג ג׳ודו');
  });
  test('עובדות 19: ריבית 3.5% מול הבנק', () {
    final f = balaganFacts('ריבית 3.5% מול הבנק', mod([], [], lf: 'הערה'), today: today);
    expect(f['הערה'], '3.5%');

    expect(f['__note'], 'ריבית 3.5% מול הבנק');
  });
  test('עובדות 20: ההמחאה ב-15 בספטמבר', () {
    final f = balaganFacts('ההמחאה ב-15 בספטמבר', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-09-15');
    expect(f['מה'], 'ההמחאה');

    expect(f['__note'], 'ההמחאה ב-15 בספטמבר');
  });
  test('עובדות 21: החוזה נגמר 3 באוקטובר 2027', () {
    final f = balaganFacts('החוזה נגמר 3 באוקטובר 2027', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2027-10-03');

    expect(f['__note'], 'החוזה נגמר 3 באוקטובר 2027');
  });
  test('עובדות 22: שילמתי אלף וחמש מאות שקל לגנן', () {
    final f = balaganFacts('שילמתי אלף וחמש מאות שקל לגנן', mod([], ['סכום']), today: today);
    expect(f['סכום'], '1500');
    expect(f['מה'], 'שילמתי לגנן');

    expect(f['__note'], 'שילמתי אלף וחמש מאות שקל לגנן');
  });
  test('עובדות 23: הפיקדון שלושת אלפים ומאתיים', () {
    final f = balaganFacts('הפיקדון שלושת אלפים ומאתיים', mod([], ['סכום']), today: today);
    expect(f['סכום'], '3200');

    expect(f['__note'], 'הפיקדון שלושת אלפים ומאתיים');
  });
  test('עובדות 24: קנס של מאתיים', () {
    final f = balaganFacts('קנס של מאתיים', mod([], ['סכום']), today: today);
    expect(f['סכום'], '200');

    expect(f['__note'], 'קנס של מאתיים');
  });
  test('עובדות 25: רות לוי 052-123-4567 המשכיר עדיין לא החזיר', () {
    final f = balaganFacts('רות לוי 052-123-4567 המשכיר עדיין לא החזיר', mod([], [], ph: ['טלפון'], pe: ['לקוח'], desc: 'לקוח'), today: today);
    expect(f['לקוח'], 'רות לוי');
    expect(f['טלפון'], '0521234567');

    expect(f['__note'], 'רות לוי 052-123-4567 המשכיר עדיין לא החזיר');
  });
  test('עובדות 26: [8.9.2026, 16:30] דני: מחר ב-9:00 אצל הרופא', () {
    final f = balaganFacts('[8.9.2026, 16:30] דני: מחר ב-9:00 אצל הרופא', mod(['מועד'], [], tm: ['שעה'], pe: ['לקוח']), today: today);
    expect(f['מועד'], '2026-09-09');
    expect(f['שעה'], '09:00');
    expect(f['לקוח'], 'הרופא');
    expect(f['מה'], 'אצל הרופא');

    expect(f['__note'], '[8.9.2026, 16:30] דני: מחר ב-9:00 אצל הרופא');
  });
  test('עובדות 27: [8.9.2026, 16:30] דני: מחר ב-9:00 פגישה', () {
    final f = balaganFacts('[8.9.2026, 16:30] דני: מחר ב-9:00 פגישה', mod(['מועד'], [], tm: ['שעה'], pe: ['לקוח']), today: today);
    expect(f['מועד'], '2026-09-09');
    expect(f['שעה'], '09:00');
    expect(f['לקוח'], 'דני');
    expect(f['מה'], 'פגישה');

    expect(f['__note'], '[8.9.2026, 16:30] דני: מחר ב-9:00 פגישה');
  });
  test('עובדות 28: מחר בבוקר תור לרופא', () {
    final f = balaganFacts('מחר בבוקר תור לרופא', mod(['מועד'], [], tm: ['שעה']), today: today);
    expect(f['מועד'], '2026-09-09');
    expect(f['שעה'], '09:00');
    expect(f['מה'], 'תור לרופא');

    expect(f['__note'], 'מחר בבוקר תור לרופא');
  });
  test('עובדות 29: להתקשר לבנק בעוד שעה', () {
    final f = balaganFacts('להתקשר לבנק בעוד שעה', mod([], [], tm: ['שעה']), today: today);
    expect(f['שעה'], '11:00');
    expect(f['מה'], 'להתקשר לבנק');

    expect(f['__note'], 'להתקשר לבנק בעוד שעה');
  });
  test('עובדות 30: תזכיר לי בעוד 20 דקות לכבות את התנור', () {
    final f = balaganFacts('תזכיר לי בעוד 20 דקות לכבות את התנור', mod([], [], tm: ['שעה']), today: today);
    expect(f['שעה'], '10:20');

    expect(f['__note'], 'תזכיר לי בעוד 20 דקות לכבות את התנור');
  });
  test('עובדות 31: בערב פגישה עם דני', () {
    final f = balaganFacts('בערב פגישה עם דני', mod(['מועד'], [], tm: ['שעה']), today: today);
    expect(f['שעה'], '19:00');
    expect(f['מה'], 'פגישה עם דני');
    expect(f.containsKey('מועד'), isFalse);
    expect(f['__note'], 'בערב פגישה עם דני');
  });
  test('עובדות 32: 8.9.26, 16:30 - רות לוי: מסרתי מפתח ב-1.8.2026', () {
    final f = balaganFacts('8.9.26, 16:30 - רות לוי: מסרתי מפתח ב-1.8.2026', mod(['תאריך מסירת מפתח'], [], pe: ['לקוח']), today: today);
    expect(f['תאריך מסירת מפתח'], '2026-08-01');
    expect(f['לקוח'], 'רות לוי');

    expect(f['__note'], '8.9.26, 16:30 - רות לוי: מסרתי מפתח ב-1.8.2026');
  });
  test('זיהוי: רגע כללי ⇒ שכבת-הבסיס ראשונה, המודול-החלש חלופה', () {
    final h = balaganIdentify('לשלם ארנונה מחר 350 ש"ח');
    expect(h.first.module.layer, 'base');
    expect(h.first.module.required, kBalaganModules.where((m) => m.layer == 'base').map((m) => m.required).reduce((a, b) => a < b ? a : b));
  });
  test('זיהוי: מילות-דקדוק לא מזהות — «ב-15 לחודש» / «כל חודש» ⇒ הבסיס, לא «לא משלם»', () {
    expect(balaganIdentify('לשלם ארנונה כל חודשיים ב-15 לחודש 350 ש"ח').first.module.layer, 'base');
    expect(balaganIdentify('לשלם לגנן כל חודש 400 ש"ח').first.module.layer, 'base');
    expect(balaganStripGrammar('לשלם ארנונה כל חודשיים ב-15 לחודש 350 ש"ח').contains('חודש'), isFalse);
  });
  test('זיהוי: רגע מובהק ⇒ המודול שלו, לא הבסיס', () {
    final h = balaganIdentify('המשכיר מקזז 6,200 מהפיקדון של 8,000, מסרתי מפתח');
    expect(h.first.module.layer, isNot('base'));
    expect(h.first.score / h.first.module.selfScore >= kBalaganWeak, isTrue);
  });
  test('תאריך שהמודול לא יכול להחזיק ⇒ הבסיס; בלי תאריך המודול נשאר', () {
    final a = balaganIdentify('מחר בבוקר תור לרופא'); expect(a.first.module.layer, 'base'); expect(a.first.module.timeFields, isNotEmpty); expect(a.any((h) => h.module.layer != 'base'), isTrue);
    final b = balaganIdentify('תור לרופא'); expect(b.first.module.layer, isNot('base'));
  });
  test('שעה + רגע כללי ⇒ הבסיס עם שדה-שעה (פגישה), לא משימה', () {
    final h = balaganIdentify('מחר ב-9:00 עם דני');
    expect(h.first.module.layer, 'base');
    expect(h.first.module.timeFields, isNotEmpty);
  });
  test('↻ המועד-הבא: חודש קצר ⇒ היום-האחרון · שבועיים · 3 ימים · שנה', () {
    expect(GenAppCalendarHomeScreenToday.nextRepeat(DateTime(2026, 1, 31), 'm1'), DateTime(2026, 2, 28));
    expect(GenAppCalendarHomeScreenToday.nextRepeat(DateTime(2026, 9, 8), 'w2'), DateTime(2026, 9, 22));
    expect(GenAppCalendarHomeScreenToday.nextRepeat(DateTime(2026, 9, 8), 'd3'), DateTime(2026, 9, 11));
    expect(GenAppCalendarHomeScreenToday.nextRepeat(DateTime(2028, 2, 29), 'y1'), DateTime(2029, 2, 28));
    expect(balaganRepeatLabel('m2'), 'כל חודשיים');
  });
  test('גיבוי: ייצוא ⇒ שחזור מחזיר את התיקים · טקסט זר נדחה · חיפוש מוצא בכל שדה', () {
    final st = AppStore();
    final id = st.add('x_ent', {'מה': 'לשלם ארנונה', 'טלפון': '0521234567'});
    final dump = st.exportJson();
    expect(st.importJson('לא גיבוי'), -1);
    expect(st.records('x_ent').length, 1);
    st.add('x_ent', {'מה': 'עוד אחד'});
    expect(st.importJson(dump), 1);
    expect(st.records('x_ent').first['מה'], 'לשלם ארנונה');
    expect(st.search('052').first[1], id);
    expect(st.search('ארנונה').length, 1);
    expect(st.search('x'), isEmpty);
  });
  test('«סיים» עם החזר: השורה מוסתרת והשלב מתקדם; החזר מחזיר את שניהם', () {
    final st = AppStore();
    final id = st.add('e_ent', {'מה': 'x', 'מועד': '2026-09-08', '__stage': '0'});
    st.advance('e_ent', id, 3); st.decide('ign:$id:מועד', 'no');
    final lid = st.logAction('done', 'סיים', entity: 'e_ent', rid: id, field: 'מועד', prev: '0');
    expect(st.stageOf('e_ent', id), 1); expect(st.decision('ign:$id:מועד'), 'no');
    expect(st.undo(lid), isTrue);
    expect(st.stageOf('e_ent', id), 0); expect(st.decision('ign:$id:מועד'), '');
  });
  test('תיק כפול: אותו אדם/מתאר במודול פתוח ⇒ נמצא; סגור ⇒ לא', () {
    final m = BalaganModule(0, 't', 'בדיקה', 'בדיקה', '', const <String, double>{}, const [], const [], 'מה', '', 'dup_ent', const <BalaganField>[], 3, const <String>[], personFields: const ['לקוח']);
    final a = appStore.add('dup_ent', {'מה': 'פיקדון', 'לקוח': 'רות לוי', '__stage': '0'});
    appStore.add('dup_ent', {'מה': 'אחר', 'לקוח': 'דן כהן', '__stage': '2'});
    expect(balaganDuplicates(m, {'לקוח': ' רות  לוי '}).map((r) => r['__id']), [a]);
    expect(balaganDuplicates(m, {'לקוח': 'דן כהן'}), isEmpty);
    expect(balaganDuplicates(m, {'מה': 'פי'}), isEmpty);
  });
  test('מיזוג לתיק קיים: ריק מתמלא · מלא לא נדרס · «מה כתבת» נצבר · החזר מחזיר הכל', () {
    final m = BalaganModule(0, 't', 'בדיקה', 'בדיקה', '', const <String, double>{}, const [], const [], 'לקוח', '', 'mrg_ent', const <BalaganField>[], 3, const <String>[], personFields: const ['לקוח'], phoneFields: const ['טלפון']);
    final id = appStore.add('mrg_ent', {'לקוח': 'רות לוי', 'טלפון': '', 'סכום': '8000', '__note': 'ראשון', '__stage': '0'});
    final n = balaganMerge(m, id, {'לקוח': 'רות לוי', 'טלפון': '0521234567', 'סכום': '9999', '__note': 'שני'}, 'מוזג {n}');
    expect(n, 2);
    final r = appStore.byId('mrg_ent', id)!;
    expect(r['טלפון'], '0521234567'); expect(r['סכום'], '8000'); expect(r['__note'], 'ראשון\nשני');
    final lid = appStore.log.first['id']!; expect(appStore.log.first['kind'], 'merge');
    expect(appStore.undo(lid), isTrue);
    final r2 = appStore.byId('mrg_ent', id)!; expect(r2['טלפון'], ''); expect(r2['__note'], 'ראשון');
  });
  test('«שתף את היום»: טקסט עם באיחור/היום ושעות', () {
    final a = DsTodayItem(title: 'רופא שיניים', sub: '', due: DateTime(2026, 9, 8), hard: false, overdue: false, module: 'יומן', actions: const [], act: (_) {}, time: '09:30');
    final o = DsTodayItem(title: 'ארנונה', sub: '', due: DateTime(2026, 9, 5), hard: true, overdue: true, module: 'משימות', actions: const [], act: (_) {});
    final t = balaganDayText([o], [a], DateTime(2026, 9, 8));
    expect(t.contains('8.9'), isTrue); expect(t.contains('2026-09-08'), isFalse);   // ב׳-מא · כותרת כמו שאומרים expect(t.contains('• ארנונה (משימות)'), isTrue); expect(t.contains('• 09:30 רופא שיניים (יומן)'), isTrue);
  });
  test('ייצוא-וואטסאפ: הכותרת נקלפת, השולח = אדם, חותמת-ההודעה אינה מועד', () {
    expect(balaganWaStrip('[8.9.2026, 16:30] דני: מחר ב-9:00'), 'מחר ב-9:00');
    expect(balaganWaSender('8.9.26, 16:30 - רות לוי: שלום'), 'רות לוי');
    expect(balaganWaSender('מחר ב-9:00'), '');
    expect(balaganSplit('[8.9.2026, 16:30] דני: מחר אצל הרופא\n[8.9.2026, 16:31] דני: ok').length, 1);
  });
  test('מחיקה עם החזר: הרשומה חוזרת כמו שהייתה', () {
    final st = AppStore();
    final id = st.add('d_ent', {'מה': 'x', 'טלפון': '05', '__stage': '1'});
    final snap = Map<String, String>.from(st.byId('d_ent', id)!);
    st.removeById('d_ent', id); expect(st.byId('d_ent', id), isNull);
    final lid = st.logAction('del', 'נמחק', entity: 'd_ent', rid: id, prev: jsonEncode(snap));
    expect(st.undo(lid), isTrue);
    expect(st.byId('d_ent', id)!['טלפון'], '05'); expect(st.byId('d_ent', id)!['__stage'], '1');
  });
  test('בלי תאריך: תיק בלי מועד לא נעלם — «קבע למחר»/«לשבוע» נותנים מועד עם החזר · «התעלם» מסתיר', () {
    final id = appStore.add('app_calendar_ent1', {'מה': 'לתקן את הברז'});
    final u = GenAppCalendarHomeScreenToday.undated(today);
    expect(u.any((x) => x.rid == id), isTrue);
    final it = u.firstWhere((x) => x.rid == id);
    it.act(0);
    expect(appStore.byId('app_calendar_ent1', id)![it.field], '2026-09-09');
    expect(GenAppCalendarHomeScreenToday.undated(today).any((x) => x.rid == id), isFalse);
    expect(appStore.undo(appStore.log.first['id']!), isTrue);
    expect(appStore.byId('app_calendar_ent1', id)![it.field], '');
    GenAppCalendarHomeScreenToday.undated(today).firstWhere((x) => x.rid == id).act(1);
    expect(appStore.byId('app_calendar_ent1', id)![it.field], '2026-09-15');
    expect(appStore.undo(appStore.log.first['id']!), isTrue);
    GenAppCalendarHomeScreenToday.undated(today).firstWhere((x) => x.rid == id).act(2);
    expect(GenAppCalendarHomeScreenToday.undated(today).any((x) => x.rid == id), isFalse);
    expect(appStore.byId('app_calendar_ent1', id)![it.field], '');
  });
  test('כסף-במבט: סכום שדה-הסכום הראשי של שורות-היום — תיק פעם אחת · פסיקים נקראים · עיצוב-אלפים · בשיתוף', () {
    final m = kBalaganModules.firstWhere((x) => x.numFields.any((f) => !x.percentFields.contains(f)));
    final f = m.numFields.firstWhere((x) => !m.percentFields.contains(x));
    final a = appStore.add(m.rootSlug, {f: '1250'}); final b = appStore.add(m.rootSlug, {f: '8,000'}); final c = appStore.add(m.rootSlug, {f: ''});
    DsTodayItem it(String rid) => DsTodayItem(title: 'x', sub: '', due: today, hard: false, overdue: false, module: m.title, actions: const [], act: (_) {}, rid: rid);
    expect(balaganMoney([it(a), it(a), it(b), it(c)]), 9250);
    expect(balaganMoney(const []), 0);
    expect(balaganFmtMoney(9250), '9,250'); expect(balaganFmtMoney(350), '350');
    expect(balaganDayText(const [], [it(a)], today, money: 1250).contains('1,250'), isTrue);
    expect(balaganDayText(const [], [it(a)], today).contains('סה'), isFalse);
  });
  test('נשכחים: תיק ישן שכל מועדיו עברו ונדחו-בהתעלם ⇒ מופיע; טרי/עתידי ⇒ לא; «סגור תיק» עם החזר; «קבע למחר» מחזיר ל«היום»', () {
    const F = 'מועד'; const S = 'app_calendar_ent1';
    final old = appStore.add(S, {'מה': 'ישן', F: '2026-08-01', '__at': '2026-07-30'}); appStore.decide('ign:$old:' + F, 'no');
    final fresh = appStore.add(S, {'מה': 'טרי', F: '2026-08-01', '__at': '2026-09-01'}); appStore.decide('ign:$fresh:' + F, 'no');
    final fut = appStore.add(S, {'מה': 'עתידי', F: '2026-10-01', '__at': '2026-07-30'});
    final s = GenAppCalendarHomeScreenToday.stale(today);
    expect(s.map((x) => x.rid), contains(old)); expect(s.map((x) => x.rid), isNot(contains(fresh))); expect(s.map((x) => x.rid), isNot(contains(fut)));
    expect(s.firstWhere((x) => x.rid == old).sub.contains('40'), isTrue);
    s.firstWhere((x) => x.rid == old).act(0);
    expect(appStore.stageOf(S, old), 1);
    expect(GenAppCalendarHomeScreenToday.stale(today).any((x) => x.rid == old), isFalse);
    expect(appStore.undo(appStore.log.first['id']!), isTrue);
    expect(GenAppCalendarHomeScreenToday.stale(today).any((x) => x.rid == old), isTrue);
    GenAppCalendarHomeScreenToday.stale(today).firstWhere((x) => x.rid == old).act(1);
    expect(appStore.byId(S, old)![F], '2026-09-09');
    expect(GenAppCalendarHomeScreenToday.stale(today).any((x) => x.rid == old), isFalse);
    expect(GenAppCalendarHomeScreenToday.items(today.add(const Duration(days: 1)), dayDelta: 0).any((x) => x.rid == old), isTrue);
  });
  test('צ׳יפי-מועד: כל תווית ⇒ תאריך דרך מנתח-הרגעים (היום · מחר · ביום ראשון · בעוד שבוע)', () {
    final c = balaganDateChips(today);
    expect(c.length, 4);
    expect(c.map((x) => x[1]).toList(), ['2026-09-08', '2026-09-09', '2026-09-13', '2026-09-15']);
  });
  test('«התעלם» עם החזר: שורת-באיחור נעלמת, נרשמת ביומן, והחזר מחזיר אותה', () {
    const S = 'app_calendar_ent1'; const F = 'מועד';
    final id = appStore.add(S, {'מה': 'להתעלם', F: '2026-09-01'});
    final it = GenAppCalendarHomeScreenToday.items(today, dayDelta: 0).firstWhere((x) => x.rid == id);
    expect(it.overdue, isTrue); it.act(it.actions.length - 1);
    expect(GenAppCalendarHomeScreenToday.items(today, dayDelta: 0).any((x) => x.rid == id), isFalse);
    expect(appStore.log.first['kind'], 'decide'); expect(appStore.log.first['field'], 'ign:' + id + ':' + F);
    expect(appStore.undo(appStore.log.first['id']!), isTrue);
    expect(GenAppCalendarHomeScreenToday.items(today, dayDelta: 0).any((x) => x.rid == id), isTrue);
  });
  test('צ׳יפי-שעה: חלקי-יום ⇒ שעה דרך מנתח-הרגעים · צ׳יפי-אנשים: מי שכבר בתיקים לפי תדירות, בלי תיקים אין', () {
    expect(balaganTimeChips(DateTime(2026, 9, 8, 10)).map((x) => x[1]).toList(), ['09:00', '13:00', '16:00', '19:00']);
    final m = kBalaganModules.firstWhere((x) => x.personFields.isNotEmpty);
    final before = balaganPeople();
    appStore.add(m.rootSlug, {m.personFields.first: 'משה פרץ'}); appStore.add(m.rootSlug, {m.personFields.first: 'משה פרץ'}); appStore.add(m.rootSlug, {m.personFields.first: 'שרה גל'});
    final p = balaganPeople();
    expect(p.indexOf('משה פרץ') < p.indexOf('שרה גל') || !p.contains('שרה גל'), isTrue);
    expect(p.first, before.isEmpty ? 'משה פרץ' : p.first);
    expect(p.length <= 6, isTrue);
  });
  test('צ׳יפי-חזרה: כל תווית ⇒ קוד דרך מנתח-הרגעים (יום · שבוע · חודש · שנה)', () {
    expect(balaganRepeatChips().map((x) => x[1]).toList(), ['d1', 'w1', 'm1', 'y1']);
    expect(balaganRepeatChips().map((x) => balaganRepeatLabel(x[1])).toList(), balaganRepeatChips().map((x) => x[0]).toList());
  });
  test('כרטיס-אדם: תיקים · פתוחים · ₪ פתוח (שדה ראשי, פסיקים) · טלפונים · לא-קיים ⇒ null · 0⇒972', () {
    final m = kBalaganModules.firstWhere((x) => x.personFields.isNotEmpty && x.numFields.any((f) => !x.percentFields.contains(f)));
    final nf = m.numFields.firstWhere((f) => !m.percentFields.contains(f));
    appStore.add(m.rootSlug, {m.personFields.first: 'יעל ברק', nf: '1,000', if (m.phoneFields.isNotEmpty) m.phoneFields.first: '0501234567'});
    appStore.add(m.rootSlug, {m.personFields.first: ' יעל ברק ', nf: '250', if (m.stages > 0) '__stage': (m.stages - 1).toString()});
    final p = balaganPerson('יעל ברק')!;
    expect(p.files, 2); expect(p.open, m.stages > 0 ? 1 : 2); expect(p.money, m.stages > 0 ? 1000 : 1250);
    if (m.phoneFields.isNotEmpty) expect(p.phones, ['0501234567']);
    expect(balaganIntl('050-123-4567'), '972501234567'); expect(balaganIntl('+972501234567'), '972501234567');
    expect(balaganPerson('אין כזה'), isNull);
  });
  test('גיבוי: גיל בימים (מעולם = −1) · מזכירים רק מ-10 תיקים ורק מעולם/≥30 יום', () {
    expect(balaganBackupAge('', today), -1); expect(balaganBackupAge('לא תאריך', today), -1);
    expect(balaganBackupAge('2026-08-09', today), 30); expect(balaganBackupAge('2026-09-08', today), 0);
    expect(balaganBackupDue(3, -1), isFalse); expect(balaganBackupDue(10, -1), isTrue);
    expect(balaganBackupDue(10, 29), isFalse); expect(balaganBackupDue(10, 30), isTrue);
  });
  test('תזכורות-מרוכזות: מועדים קרובים בלי הכרעה נמנים · שהוכרע יוצא · החזר-מרוכז מוחק את כל ההכרעות', () {
    const S = 'app_calendar_ent1'; const F = 'מועד';
    final ids = [for (var i = 1; i <= 4; i++) appStore.add(S, {'מה': 'תזכורת $i', F: '2026-09-1$i'})];
    expect(ids.every((id) => GenAppCalendarHomeScreenToday.remPending(today).any((x) => x.rid == id)), isTrue);
    appStore.decide('rem:' + ids[0] + ':' + F, 'ok');
    expect(GenAppCalendarHomeScreenToday.remPending(today).any((x) => x.rid == ids[0]), isFalse);
    final keys = [for (final id in ids.skip(1)) 'rem:' + id + ':' + F];
    for (final k in keys) { appStore.decide(k, 'ok'); }
    final lid = appStore.logAction('decide', 'תזכורות', field: keys.first, prev: keys.skip(1).join(','));
    expect(appStore.undo(lid), isTrue);
    expect(keys.every((k) => appStore.decision(k).isEmpty), isTrue);
    expect(ids.skip(1).every((id) => GenAppCalendarHomeScreenToday.remPending(today).any((x) => x.rid == id)), isTrue);
  });
  test('כרטיס-אדם מחיפוש-חלקי: יחיד-שמכיל ⇒ הכרטיס · שניים ⇒ אין · קצר ⇒ אין', () {
    final m = kBalaganModules.firstWhere((x) => x.personFields.isNotEmpty);
    appStore.add(m.rootSlug, {m.personFields.first: 'נועה שגב'}); appStore.add(m.rootSlug, {m.personFields.first: 'נועה לב'});
    expect(balaganPersonFor('שגב')!.name, 'נועה שגב');
    expect(balaganPersonFor('נועה'), isNull);
    expect(balaganPersonFor('ש'), isNull);
    expect(balaganPersonFor(' נועה לב ')!.files, 1);
  });
  test('פותח-תיק: ישות מוכרת ⇒ עמוד-השורש שלה; לא מוכרת ⇒ ריק', () {
    expect(balaganOpenRoot('nope', 'x') is SizedBox, isTrue);
    for (final m in kBalaganModules) { expect(balaganOpenRoot(m.rootSlug, 'x') is SizedBox, isFalse, reason: m.rootSlug); }
  });
  test('תאריך כמו שאומרים: היום · מחר · אתמול · יום שלישי 15.9 · 30.11 · 3.10.2027', () {
    expect(balaganDayLabel(DateTime(2026, 9, 8), today), 'היום');
    expect(balaganDayLabel(DateTime(2026, 9, 9), today), 'מחר');
    expect(balaganDayLabel(DateTime(2026, 9, 7), today), 'אתמול');
    expect(balaganDayLabel(DateTime(2026, 9, 13), today).endsWith(' 13.9'), isTrue);
    expect(balaganDayLabel(DateTime(2026, 9, 13), today).startsWith('יום'), isTrue);
    expect(balaganDayLabel(DateTime(2026, 11, 30), today), '30.11');
    expect(balaganDayLabel(DateTime(2027, 10, 3), today), '3.10.2027');
    expect(balaganDayText(const [], const [], today, tomorrow: [DsTodayItem(title: 'ביטוח', sub: '', due: DateTime(2026, 9, 9), hard: false, overdue: false, module: 'משימות', actions: const [], act: (_) {})]).contains('• ביטוח (משימות)'), isTrue);
  });
  test('היסטי-תזכורת כמו שאומרים: 3,1,0 ⇒ «3 ימים לפני · יום לפני · ביום»', () {
    expect(balaganOffsetsLabel('3,1,0'), '3 ימים לפני · יום לפני · ביום');
    expect(balaganOffsetsLabel('7'), '7 ימים לפני');
  });
  test('פיצול שורה לכמה רגעים', () {
    expect(balaganSplit('שילמתי ארנונה. מחר תור לרופא ב-9:00'), ['שילמתי ארנונה', 'מחר תור לרופא ב-9:00']);
    expect(balaganSplit('מסרתי מפתח ב-1.8.2026 והמשכיר מקזז 6,200'), ['מסרתי מפתח ב-1.8.2026 והמשכיר מקזז 6,200']);
    expect(balaganSplit('שורה אחת\nשורה שתיים; ועוד אחת').length, 3);
  });
  test('זיהוי: כל כותרת-מודול ⇒ עצמו (הסף אינו בולע כותרות)', () {
    for (final m in kBalaganModules) { expect(balaganIdentify(m.title).first.module.ns, m.ns, reason: m.title); }
  });
}
