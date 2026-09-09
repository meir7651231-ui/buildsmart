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
    expect(balaganDuplicates(m, {'לקוח': 'לוי רות'}).map((r) => r['__id']), [a]);   // ב׳-קג · סדר-מילים הפוך = אותו אדם
    expect(balaganDuplicates(m, {'לקוח': 'רות כהן'}), isEmpty);   // ב׳-קג · מילה-אחת חופפת אינה אותו אדם
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
    expect(balaganPersonFor('שגב נועה')!.name, 'נועה שגב');   // ב׳-קג · סדר-מילים הפוך ⇒ אותו אדם
  });
  test('ב׳-קי/קיא/קיב · החודש (מונה+₪ של תיקים פתוחים) · נראה-חוזר (3 ארנונות חודשיות ⇒ m1) · שלחת-ואין-תשובה (3 ימים; פעולה מאוחרת מבטלת)', () {
    final m = kBalaganModules.firstWhere((x) => x.dateFields.isNotEmpty && x.descField.isNotEmpty && x.numFields.any((f) => !x.percentFields.contains(f))); final S = m.rootSlug; final D = m.descField; final df = m.dateFields.first; final nf = m.numFields.where((f) => !m.percentFields.contains(f)).first;
    appStore.add(S, {D: 'ארנונה', df: '2026-07-15', nf: '350', '__stage': '0'}); appStore.add(S, {D: 'ארנונה', df: '2026-08-15', nf: '350', '__stage': '0'}); appStore.add(S, {D: 'ביטוח', df: '2026-09-20', nf: '1,200', '__stage': '0'});
    expect(balaganRecurHint(m, {D: 'ארנונה', df: '2026-09-15'}), 'm1'); expect(balaganRecurHint(m, {D: 'ביטוח', df: '2026-09-15'}), ''); expect(balaganRecurHint(m, {D: 'ארנונה', df: ''}), '');
    final ms = balaganMonthSummary(DateTime(2026, 9, 8)); expect(ms[0] >= 1, isTrue); expect(ms[1] >= 1200, isTrue);
    final id = appStore.add(S, {D: 'לשלוח הצעה', df: '2026-09-01'}); appStore.logAction('send', 'שלח', entity: S, rid: id); final i0 = appStore.log.first['id'] ?? '';
    expect(balaganSilentSends(DateTime.now().add(const Duration(days: 4))).any((s) => s[1] == id), isTrue); expect(balaganSilentSends(DateTime.now()).any((s) => s[1] == id), isFalse);
    appStore.logAction('done', 'סיים', entity: S, rid: id); expect(balaganSilentSends(DateTime.now().add(const Duration(days: 4))).any((s) => s[1] == id), isFalse); expect(i0.isNotEmpty, isTrue);
  });
  test('ב׳-קנט/קסב · «₪ 350 כמו תמיד» = השכיח (≥2 שווים) · תווית «כל חודש (ב-15)»', () {
    final m = kBalaganModules.where((x) => x.descField.isNotEmpty && x.numFields.any((f) => !x.percentFields.contains(f))).skip(1).first; final nf = m.numFields.where((f) => !m.percentFields.contains(f)).first;
    appStore.add(m.rootSlug, {m.descField: 'ועד בית', nf: '350'}); appStore.add(m.rootSlug, {m.descField: 'ועד בית', nf: '350'}); appStore.add(m.rootSlug, {m.descField: 'ועד בית', nf: '400'});
    expect(balaganUsualAmount(m, {m.descField: 'ועד בית'}), '350'); expect(balaganUsualAmount(m, {m.descField: 'אחר'}), '');
    expect(balaganRepeatLabelFor('m1', '2026-09-15').contains('15'), isTrue); expect(balaganRepeatLabelFor('w1', '2026-09-15'), balaganRepeatLabel('w1'));
  });
  test('ב׳-קנו/קנח · «ט״ו אלול» ⇒ תאריך · «כ״ט באלול» · «כל שנה עברית» ⇒ h1 · תווית', () {
    final m = kBalaganModules.firstWhere((x) => x.dateFields.isNotEmpty);
    final f1 = balaganFacts('לשלם ארנונה ט״ו אלול', m, today: DateTime(2026, 8, 1)); expect(f1[m.dateFields.first], '2026-08-28');
    final f2 = balaganFacts('חתונה כ״ט באלול', m, today: DateTime(2026, 8, 1)); expect(f2[m.dateFields.first], '2026-09-11');
    final f3 = balaganFacts('יארצייט כל שנה עברית ט״ו אלול', m, today: DateTime(2026, 8, 1)); expect(f3['__repeat'], 'h1'); expect(balaganRepeatLabel('h1').isNotEmpty, isTrue);
  });
  test('ב׳-קנד · ייבוא-VCF ⇒ ספר-טלפונים (דדופ לפי מפתח) · טלפון-לפי-שם · שם-לפי-טלפון מהספר', () {
    appStore.setSetting('phonebook', '');
    final r1 = balaganImportVcf('BEGIN:VCARD\nFN:יעל ברק\nTEL;CELL:054-333-4444\nEND:VCARD\nBEGIN:VCARD\nFN:יעל ברק\nTEL:+972543334444\nEND:VCARD\n'); expect(r1, [1, 1]);
    expect(balaganBookPhone('ברק יעל'), '054-333-4444'); expect(balaganBookPhone('אין'), ''); expect(balaganPersonByPhone('0543334444'), 'יעל ברק');
    expect(balaganImportVcf('שטויות'), [0, 0]); appStore.setSetting('phonebook', '');
  });
  test('ב׳-קנ/קנא/קנג · טלפון מתיק אחר · CSV-הכל · «טלפון של X» ⇒ ערך · «של» בלי צדדים ⇒ ריק', () {
    final mp = kBalaganModules.firstWhere((x) => x.personFields.isNotEmpty && x.phoneFields.isNotEmpty);
    appStore.add(mp.rootSlug, {mp.personFields.first: 'גדי פרץ', mp.phoneFields.first: '053-999-1111'}); expect(balaganPhoneOfPerson('גדי פרץ'), '053-999-1111'); expect(balaganPhoneOfPerson('אין כזה'), '');
    expect(balaganFieldOf('טלפון של גדי פרץ'), ['טלפון', 'גדי פרץ']); expect(balaganFieldOf('של גדי'), isEmpty); expect(balaganFieldOf('טלפון'), isEmpty);
    final fv = balaganFieldValue(mp.phoneFields.first, 'גדי פרץ'); expect(fv.isNotEmpty, isTrue); expect(fv[2], '053-999-1111'); expect(balaganFieldValue('זזזז', 'גדי פרץ'), isEmpty);
    final all = balaganCsvAll(); expect(all.contains('גדי פרץ'), isTrue); expect(all.startsWith('\uFEFF') || all.codeUnitAt(0) == 0xFEFF, isTrue);
  });
  test('ב׳-קמז/קמח · CSV מפריטי-טווח · ייבוא-CSV לפי כותרות ⇒ רשומות · כותרות זרות ⇒ אין', () {
    final m = kBalaganModules.where((x) => x.dateFields.isNotEmpty && x.descField.isNotEmpty && x.numFields.any((f) => !x.percentFields.contains(f))).last; final nf = m.numFields.where((f) => !m.percentFields.contains(f)).first;
    final csv = m.descField + ',' + m.dateFields.first + ',' + nf + '\nייבוא-א,2034-01-05,"1,500"\nייבוא-ב,2034-01-06,200';
    final r = balaganImportCsv(csv); expect(r[0], m.title); expect(r[1], 2);
    expect(appStore.records(m.rootSlug).any((x) => x[m.descField] == 'ייבוא-א' && x[nf] == '1,500'), isTrue);
    expect(balaganImportCsv('זזז,קקק\n1,2')[1], 0); expect(balaganImportCsv('')[1], 0);
    final out = balaganCsvOf(balaganRangeItems('2034-01-01', '2034-01-31')); expect(out.contains('ייבוא-א'), isTrue); expect(out.contains('"1,500"'), isTrue);
  });
  test('ב׳-קמב/קמד/קמה · ICS מפריטי-טווח · «מתי ארנונה» ⇒ הפעם האחרונה · חסר-טלפון', () {
    final m = kBalaganModules.where((x) => x.dateFields.isNotEmpty && x.descField.isNotEmpty).skip(4).first;
    final id = appStore.add(m.rootSlug, {m.descField: 'ביקורת רכב', m.dateFields.first: '2033-04-05'}); final ics = balaganIcsOf(balaganRangeItems('2033-04-01', '2033-04-30'), 'בדיקה', DateTime(2026, 9, 8, 10));
    expect(ics.contains('DTSTART;VALUE=DATE:20330405'), isTrue); expect(ics.contains('X-WR-CALNAME:בדיקה'), isTrue);
    expect(balaganWhenOf('מתי ארנונה'), 'ארנונה'); expect(balaganWhenOf('מתי היה ביקורת רכב'), 'ביקורת רכב'); expect(balaganWhenOf('ארנונה'), '');
    expect(balaganLastDone('ביקורת רכב'), isEmpty); appStore.logAction('done', 'סיים', entity: m.rootSlug, rid: id); expect(balaganLastDone('ביקורת רכב').isNotEmpty, isTrue); expect(balaganLastDone('זזזזז'), isEmpty);
    final mp = kBalaganModules.firstWhere((x) => x.personFields.isNotEmpty && x.phoneFields.isNotEmpty); final a = appStore.add(mp.rootSlug, {mp.personFields.first: 'בלי טלפון', '__stage': '0'}); final b = appStore.add(mp.rootSlug, {mp.personFields.first: 'עם טלפון', mp.phoneFields.first: '050-1112222', '__stage': '0'});
    final np = balaganNoPhone(); expect(np.any((e) => e[1] == a), isTrue); expect(np.any((e) => e[1] == b), isFalse);
  });
  test('ב׳-קלט/קמא · השעה הרגילה (חציון של אותו מתאר, ≥2) · פג-תוקף בקרוב (שדה-תוקף ב-30 יום, פתוח בלבד)', () {
    final mt = kBalaganModules.where((x) => x.descField.isNotEmpty && x.timeFields.isNotEmpty).firstOrNull;
    if (mt != null) { appStore.add(mt.rootSlug, {mt.descField: 'חוג שחייה', mt.timeFields.first: '16:00'}); appStore.add(mt.rootSlug, {mt.descField: 'חוג שחייה', mt.timeFields.first: '17:00'}); appStore.add(mt.rootSlug, {mt.descField: 'חוג שחייה', mt.timeFields.first: '16:30'}); expect(balaganUsualTime(mt, {mt.descField: 'חוג שחייה'}), '16:30'); expect(balaganUsualTime(mt, {mt.descField: 'אחר'}), ''); }
    final me = kBalaganModules.where((x) => x.dateFields.any((f) => f.contains('תוקף') || f.contains('חידוש') || f.contains('סיום'))).firstOrNull;
    if (me != null) { final f = me.dateFields.firstWhere((x) => x.contains('תוקף') || x.contains('חידוש') || x.contains('סיום')); final id = appStore.add(me.rootSlug, {f: DateTime.now().add(const Duration(days: 10)).toIso8601String().substring(0, 10), '__stage': '0'}); appStore.add(me.rootSlug, {f: DateTime.now().add(const Duration(days: 90)).toIso8601String().substring(0, 10), '__stage': '0'}); final ex = balaganExpiring(DateTime.now()); expect(ex.any((e) => e[2] == id), isTrue); expect(ex.length, 1); }
  });
  test('ב׳-קלו · המתארים השכיחים: «ארנונה» ×3 (גם «ארנונה ») ראשון · יחיד לא נכנס', () {
    final m = kBalaganModules.where((x) => x.descField.isNotEmpty).skip(3).first;
    appStore.add(m.rootSlug, {m.descField: 'ארנונה-בדיקה'}); appStore.add(m.rootSlug, {m.descField: 'ארנונה-בדיקה '}); appStore.add(m.rootSlug, {m.descField: 'ארנונה-בדיקה'}); appStore.add(m.rootSlug, {m.descField: 'יחיד-בדיקה'});
    final top = balaganTopDescs(); expect(top.any((t) => t[0] == 'ארנונה-בדיקה' && t[1] == 3), isTrue); expect(top.any((t) => t[0] == 'יחיד-בדיקה'), isFalse);
  });
  test('ב׳-קל/קלא · «בין 1.9 ל-15.9» ⇒ טווח · «מ-15.9 עד 1.9» ⇒ ממוין · טקסט-זר ⇒ ריק · שולם-כבר ב-7 ימים ⇒ אזהרה', () {
    final today = DateTime(2026, 9, 8);
    expect(balaganRangeOf('בין 1.9 ל-15.9', today), ['2026-09-01', '2026-09-15']); expect(balaganRangeOf('מ-15.9 עד 1.9', today), ['2026-09-01', '2026-09-15']); expect(balaganRangeOf('לשלם בין 1.9 ל-15.9', today), isEmpty); expect(balaganRangeOf('15.9', today), isEmpty);
    final m = kBalaganModules.where((x) => x.descField.isNotEmpty && x.numFields.any((f) => !x.percentFields.contains(f))).skip(2).first; final nf = m.numFields.where((f) => !m.percentFields.contains(f)).first;
    final id = appStore.add(m.rootSlug, {m.descField: 'ביטוח רכב', nf: '1,200'}); appStore.logAction('done', 'סיים', entity: m.rootSlug, rid: id);
    expect(balaganPaidRecently(m, {m.descField: 'ביטוח רכב', nf: '1200'}, DateTime.now()).isNotEmpty, isTrue); expect(balaganPaidRecently(m, {m.descField: 'ביטוח רכב', nf: '900'}, DateTime.now()), isEmpty); expect(balaganPaidRecently(m, {m.descField: 'ביטוח דירה', nf: '1200'}, DateTime.now()), isEmpty); expect(balaganPaidRecently(m, {m.descField: 'ביטוח רכב', nf: '1200'}, DateTime.now().add(const Duration(days: 30))), isEmpty);
  });
  test('ב׳-קכח · טלפון מוכר ⇒ שם-האדם (052… = +972…) · קצר/זר ⇒ ריק', () {
    final m = kBalaganModules.firstWhere((x) => x.personFields.isNotEmpty && x.phoneFields.isNotEmpty);
    appStore.add(m.rootSlug, {m.personFields.first: 'יוסי ברק', m.phoneFields.first: '054-777-8899'});
    expect(balaganPersonByPhone('+972547778899'), 'יוסי ברק'); expect(balaganPersonByPhone('054-000-0000'), ''); expect(balaganPersonByPhone('054'), '');
  });
  test('ב׳-קכב/קכג/קכה · «שבוע הבא» ⇒ היסט · «מעל 5000» ⇒ סינון-סכום · פריטי-טווח · ספירת-דחיות', () {
    expect(balaganWeekOf('שבוע הבא'), 1); expect(balaganWeekOf(' השבוע '), 0); expect(balaganWeekOf('שבוע שעבר'), -1); expect(balaganWeekOf('שבוע'), isNull);
    expect(balaganAmountFilter('מעל 5,000'), ['>', '5000']); expect(balaganAmountFilter('פחות מ-300'), ['<', '300']); expect(balaganAmountFilter('מעל הכל'), isEmpty); expect(balaganAmountFilter('5000'), isEmpty);
    final m = kBalaganModules.firstWhere((x) => x.dateFields.isNotEmpty && x.descField.isNotEmpty && x.numFields.any((f) => !x.percentFields.contains(f))); final nf = m.numFields.where((f) => !m.percentFields.contains(f)).first;
    final big = appStore.add(m.rootSlug, {m.descField: 'גדול', m.dateFields.first: '2032-05-13', nf: '9,999'}); appStore.add(m.rootSlug, {m.descField: 'קטן', m.dateFields.first: '2032-05-09', nf: '10'});
    expect(balaganAmountItems('>', '5000').any((r) => r[1] == big), isTrue); expect(balaganAmountItems('<', '5000').any((r) => r[1] == big), isFalse);
    final it = balaganRangeItems('2032-05-10', '2032-05-16'); expect(it.length, 1); expect(it.first[2], big); expect(balaganRangeItems('2032-05-01', '2032-05-16').length, 2);
    for (var i = 0; i < 3; i++) { appStore.logAction('auto', 'דחה למחר' + ' · מועד', entity: m.rootSlug, rid: big, field: m.dateFields.first); } expect(balaganSnoozeCounts()[big], 3);
  });
  test('ב׳-קכא · «ספטמבר» ⇒ מפתח-חודש · «באוקטובר 2027» · לא-חודש ⇒ ריק · פריטי-החודש ממוינים לפי יום', () {
    final today = DateTime(2026, 9, 8);
    expect(balaganMonthOf('ספטמבר', today), '2026-09'); expect(balaganMonthOf(' באוקטובר 2027 ', today), '2027-10'); expect(balaganMonthOf('ספטמבר 15', today), ''); expect(balaganMonthOf('שלום', today), ''); expect(balaganMonthName('2026-09'), 'ספטמבר');
    final m = kBalaganModules.firstWhere((x) => x.dateFields.isNotEmpty && x.descField.isNotEmpty); appStore.add(m.rootSlug, {m.descField: 'חודש-ב', m.dateFields.first: '2031-03-20'}); appStore.add(m.rootSlug, {m.descField: 'חודש-א', m.dateFields.first: '2031-03-05'});
    final it = balaganMonthItems('2031-03'); expect(it.length, 2); expect(it.first[0], '2031-03-05'); expect(balaganMonthItems('2031-04'), isEmpty);
  });
  test('ב׳-קיד/קטו/קיז · החודש לפי נושא · בדרך-כלל נסגר תוך n · נסגר אחרי n', () {
    final m = kBalaganModules.where((x) => x.dateFields.isNotEmpty && x.descField.isNotEmpty && x.numFields.any((f) => !x.percentFields.contains(f))).skip(1).first;   /* מודול אחר מזה של ב׳-קי — ה-store משותף בין הבדיקות */ final S = m.rootSlug; final df = m.dateFields.first; final nf = m.numFields.where((f) => !m.percentFields.contains(f)).first;
    appStore.add(S, {m.descField: 'א', df: '2026-09-03', nf: '100', '__stage': '0'}); appStore.add(S, {m.descField: 'ב', df: '2026-09-25', nf: '250', '__stage': '0'});
    final bt = balaganMonthByTopic(DateTime(2026, 9, 8)); expect(bt.any((r) => r[0] == (m.topic.isEmpty ? m.title : m.topic) && (r[2] as double) >= 350), isTrue);
    expect(balaganTypicalDays(m), 0);
    final a = appStore.add(S, {m.descField: 'ג', df: '2026-09-01', '__at': DateTime.now().subtract(const Duration(days: 4)).toIso8601String()}); appStore.logAction('done', 'סיים', entity: S, rid: a);
    final b = appStore.add(S, {m.descField: 'ד', df: '2026-09-01', '__at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String()}); appStore.logAction('done', 'סיים', entity: S, rid: b);
    expect(balaganTypicalDays(m), 4); expect(balaganClosedAfter(appStore.log.first), 2); expect(balaganClosedAfter({'entity': S, 'rid': 'zz', 'at': ''}), -1);
  });
  test('ב׳-קו · אותו אדם בכמה שמות: טלפון משותף ⇒ כינויים · הכרטיס מאחד את התיקים · שם זר לא נדבק', () {
    final m = kBalaganModules.firstWhere((x) => x.personFields.isNotEmpty && x.phoneFields.isNotEmpty);
    appStore.add(m.rootSlug, {m.personFields.first: 'רות לוי', m.phoneFields.first: '052-111-2233'}); appStore.add(m.rootSlug, {m.personFields.first: 'רותי לוי', m.phoneFields.first: '+972521112233'}); appStore.add(m.rootSlug, {m.personFields.first: 'דן כהן', m.phoneFields.first: '03-5551234'});
    expect(balaganAliases('רות לוי'), {'רות לוי', 'רותי לוי'}); expect(balaganAliases('דן כהן'), {'דן כהן'});
    expect(balaganPerson('רות לוי')!.files, 2); expect(balaganPerson('רותי לוי')!.files, 2); expect(balaganPerson('דן כהן')!.files, 1);
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
  test('מתי זה קרה: עכשיו · לפני 5 דק׳ · לפני שעה · לפני 3 שעות · אתמול', () {
    final now = DateTime(2026, 9, 8, 14, 0);
    expect(balaganAgo(DateTime(2026, 9, 8, 13, 59, 40), now), 'עכשיו');
    expect(balaganAgo(DateTime(2026, 9, 8, 13, 55), now), 'לפני 5 דק׳');
    expect(balaganAgo(DateTime(2026, 9, 8, 12, 50), now), 'לפני שעה');
    expect(balaganAgo(DateTime(2026, 9, 8, 11, 0), now), 'לפני 3 שעות');
    expect(balaganAgo(DateTime(2026, 9, 7, 23, 0), now), 'אתמול');
  });
  test('הקשר לכרטיס-הכפול (מודול · מועד · ₪) · «n פתוחים» למודול', () {
    final m = kBalaganModules.firstWhere((x) => x.dateFields.isNotEmpty && x.numFields.any((f) => !x.percentFields.contains(f)));
    final nf = m.numFields.firstWhere((f) => !m.percentFields.contains(f));
    expect(balaganDupSub(m, {m.dateFields.first: '2026-09-09', nf: '8000'}, today), m.title + ' · מחר · ₪ 8,000');
    expect(balaganDupSub(m, {}, today), m.title);
    final before = balaganOpenCount(m.rootSlug, m.stages);
    appStore.add(m.rootSlug, {nf: '1'}); if (m.stages > 0) appStore.add(m.rootSlug, {nf: '2', '__stage': (m.stages - 1).toString()});
    final after = balaganOpenCount(m.rootSlug, m.stages);
    expect(after, isNot(before)); expect(after.contains('פתוחים'), isTrue);
  });
  test('«שם: רגע» — שם מוכר בתחילת השורה = האדם, לא-מוכר = טקסט רגיל · מיזוג מעדכן מועד-שעבר בלבד', () {
    final m = kBalaganModules.firstWhere((x) => x.personFields.isNotEmpty && x.dateFields.isNotEmpty);
    appStore.add(m.rootSlug, {m.personFields.first: 'גלית בר'});
    final f = balaganFacts('גלית בר: להתקשר מחר', m, today: today);
    expect(f[m.personFields.first], 'גלית בר'); expect(f[m.dateFields.first], '2026-09-09');
    final g = balaganFacts('הערה: להתקשר מחר', m, today: today);
    expect(g[m.personFields.first], isNot('הערה'));
    final id = appStore.add(m.rootSlug, {m.personFields.first: 'גלית בר', m.dateFields.first: '2020-01-01'});
    balaganMerge(m, id, {m.dateFields.first: '2099-01-01'}, 'x'); expect(appStore.byId(m.rootSlug, id)![m.dateFields.first], '2099-01-01');
    balaganMerge(m, id, {m.dateFields.first: '2098-01-01'}, 'x'); expect(appStore.byId(m.rootSlug, id)![m.dateFields.first], '2099-01-01');
    final id2 = appStore.add(m.rootSlug, {m.personFields.first: 'גלית בר', m.dateFields.first: '2020-01-01'});
    balaganMerge(m, id2, {m.dateFields.first: '2019-01-01'}, 'x'); expect(appStore.byId(m.rootSlug, id2)![m.dateFields.first], '2020-01-01');
  });
  test('אין מבוי-סתום: טקסט שלא זוהה ⇒ הבסיס (משימות) · שיתוף עם בלי-מועד/נשכחים', () {
    final h = balaganIdentify('קסםקסם'); expect(h, isNotEmpty); expect(h.first.module.layer, 'base'); expect(h.first.module.dateFields, isNotEmpty);
    expect(balaganDayText(const [], const [], today, undated: 2, stale: 1).contains('2 בלי מועד · 1 נשכחים'), isTrue);
    expect(balaganDayText(const [], const [], today).contains('בלי מועד'), isFalse);
  });
  test('פיצול שורה לכמה רגעים', () {
    expect(balaganSplit('שילמתי ארנונה. מחר תור לרופא ב-9:00'), ['שילמתי ארנונה', 'מחר תור לרופא ב-9:00']);
    expect(balaganSplit('מסרתי מפתח ב-1.8.2026 והמשכיר מקזז 6,200'), ['מסרתי מפתח ב-1.8.2026 והמשכיר מקזז 6,200']);
    expect(balaganSplit('שורה אחת\nשורה שתיים; ועוד אחת').length, 3);
  });
  test('זיהוי: כל כותרת-מודול ⇒ עצמו (הסף אינו בולע כותרות)', () {
    for (final m in kBalaganModules) { expect(balaganIdentify(m.title).first.module.ns, m.ns, reason: m.title); }
  });
  test('ב׳-פו · «דחה למחר» מבאיחור = מחר (לא יום-אחרי-המועד-שעבר) · «דחה לשבוע» = בעוד שבוע · החזר', () {
    const S = 'app_calendar_ent1'; const F = 'מועד';
    final id = appStore.add(S, {'מה': 'ישן', F: '2026-09-01'});
    final it = GenAppCalendarHomeScreenToday.items(today, dayDelta: 0).firstWhere((x) => x.rid == id); expect(it.overdue, isTrue);
    it.act(it.actions.indexOf('דחה למחר')); expect(appStore.byId(S, id)![F], '2026-09-09');
    expect(GenAppCalendarHomeScreenToday.items(today, dayDelta: 0).any((x) => x.rid == id), isFalse); expect(GenAppCalendarHomeScreenToday.items(today, dayDelta: 1).any((x) => x.rid == id), isTrue);
    expect(appStore.undo(appStore.log.first['id']!), isTrue); expect(appStore.byId(S, id)![F], '2026-09-01');
    final it2 = GenAppCalendarHomeScreenToday.items(today, dayDelta: 0).firstWhere((x) => x.rid == id); it2.act(it2.actions.indexOf('דחה לשבוע')); expect(appStore.byId(S, id)![F], '2026-09-15');
  });
  test('ב׳-פז · החזר-קבוצתי: כמה שורות-יומן עם group אחד ⇒ החזר של אחת מחזיר את כולן', () {
    const S = 'app_calendar_ent1'; const F = 'מועד';
    final a = appStore.add(S, {F: '2026-09-01'}); final b = appStore.add(S, {F: '2026-09-02'});
    final ia = appStore.logAction('auto', 'א', entity: S, rid: a, field: F, prev: '2026-09-01', group: 'g1'); appStore.update(S, a, {F: '2026-09-09'});
    appStore.logAction('auto', 'ב', entity: S, rid: b, field: F, prev: '2026-09-02', group: 'g1'); appStore.update(S, b, {F: '2026-09-09'});
    expect(appStore.undo(ia), isTrue);
    expect(appStore.byId(S, a)![F], '2026-09-01'); expect(appStore.byId(S, b)![F], '2026-09-02');
    expect(appStore.log.where((e) => e['group'] == 'g1' && e['undone'] != '1'), isEmpty);
  });
  test('ב׳-פח/פט · טלפון מהאדם המוכר · «כמו בפעם הקודמת» = הסכום של התיק האחרון (אותו אדם כשיש)', () {
    final ms = kBalaganModules.where((x) => x.personFields.isNotEmpty && x.phoneFields.isNotEmpty && x.numFields.any((f) => !x.percentFields.contains(f))).toList();
    expect(ms, isNotEmpty);
    final m = ms.first; final nf = m.numFields.firstWhere((f) => !m.percentFields.contains(f));
    expect(balaganPhoneOf('אבי כהן'), ''); expect(balaganLastAmount(m, 'אבי כהן'), '');
    appStore.add(m.rootSlug, {m.personFields.first: 'אבי כהן', m.phoneFields.first: '052-1234567', nf: '1,500'});
    appStore.add(m.rootSlug, {m.personFields.first: 'אבי כהן', nf: '2,000'});
    appStore.add(m.rootSlug, {m.personFields.first: 'דנה לוי', nf: '300'});
    expect(balaganPhoneOf('אבי כהן'), '052-1234567'); expect(balaganPhoneOf('אבי'), '');
    expect(balaganLastAmount(m, 'אבי כהן'), '2,000'); expect(balaganLastAmount(m, 'דנה לוי'), '300'); expect(balaganLastAmount(m, ''), '300');
    expect(balaganLastAmount(m, 'מישהו אחר'), '');
  });
  test('ב׳-צ · «שלח לו את הפתוחים»: שורה לכל תיק פתוח עם האדם, סגור לא נכלל', () {
    final m = kBalaganModules.firstWhere((x) => x.personFields.isNotEmpty && x.stages > 0);
    expect(balaganPersonOpenText('גל רון', today), '');
    appStore.add(m.rootSlug, {m.personFields.first: 'גל רון', if (m.descField.isNotEmpty && m.descField != m.personFields.first) m.descField: 'פתוח'});   // שדה-התיאור יכול להיות שדה-האדם עצמו
    appStore.add(m.rootSlug, {m.personFields.first: 'גל רון', if (m.descField.isNotEmpty && m.descField != m.personFields.first) m.descField: 'סגור', '__stage': (m.stages - 1).toString()});
    final t = balaganPersonOpenText('גל רון', today);
    expect(t.startsWith('גל רון, מה שפתוח אצלנו:'), isTrue); expect(t.split('\n').length, 2); expect(t.contains(m.title), isTrue);
  });
  test('ב׳-צא · הצעת-התזכורת אומרת רק מה שעוד לפנינו: מועד מחר ⇒ [1, 0], מועד בעוד 10 ימים ⇒ [3, 1, 0]', () {
    expect(GenAppCalendarHomeScreenToday.aheadOf(DateTime(2026, 9, 9), true, today), [1, 0]);
    expect(GenAppCalendarHomeScreenToday.aheadOf(DateTime(2026, 9, 18), true, today), [3, 1, 0]);
    expect(GenAppCalendarHomeScreenToday.aheadOf(DateTime(2026, 9, 8), true, today), [0]);
  });
  test('ב׳-צב · חיפוש-ספרות: «1250» מוצא «1,250» · «052-123» מוצא «0521234567» · טקסט רגיל לא נשבר', () {
    const S = 'app_calendar_ent1';
    final id = appStore.add(S, {'מה': 'ארנונה 1,250 · 0521234567'});
    expect(appStore.search('1250').any((h) => h[1] == id), isTrue); expect(appStore.search('052-123').any((h) => h[1] == id), isTrue);
    expect(appStore.search('ארנונה').any((h) => h[1] == id), isTrue); expect(appStore.search('9999').any((h) => h[1] == id), isFalse);
  });
  test('ב׳-קב · חיפוש-סלחן מדורג: «ארנונא» מוצא «ארנונה» · מדויק לפני מכיל · ספרות דרך המחסן · אין-כלום ⇒ ריק', () {
    const S = 'app_calendar_ent1';
    final a = appStore.add(S, {'מה': 'חשמל לעירייה'});
    final b = appStore.add(S, {'מה': 'חשמל'});
    final r = balaganSearchRanked('חשמל'); expect(r.first[1], b); expect(r.any((h) => h[1] == a), isTrue);   // מדויק (100) לפני קידומת (80)
    expect(balaganSearchRanked('חשמא').any((h) => h[1] == b), isTrue);   // שגיאת-כתיב אחת
    expect(balaganSearchRanked('1250').any((h) => h[0] == S), isTrue); expect(balaganSearchRanked('זזזז'), isEmpty); expect(balaganSearchRanked('ח'), isEmpty);
  });
  test('ב׳-צג · grouped: «סיים» על שני תיקים-באיחור בתוך grouped ⇒ החזר אחד מחזיר את שניהם', () {
    const S = 'app_calendar_ent1'; const F = 'מועד';
    final a = appStore.add(S, {F: '2026-09-01'}); final b = appStore.add(S, {F: '2026-09-02'});
    final its = GenAppCalendarHomeScreenToday.items(today, dayDelta: 0).where((x) => x.rid == a || x.rid == b).toList(); expect(its.length, 2);
    appStore.grouped(() { for (final it in its) { it.act(it.actions.indexOf('סיים')); } });
    expect(GenAppCalendarHomeScreenToday.items(today, dayDelta: 0).any((x) => x.rid == a || x.rid == b), isFalse);
    final g = appStore.log.first['group'] ?? ''; expect(g, isNotEmpty); expect(appStore.log.where((e) => e['group'] == g).length, 2);
    expect(appStore.undo(appStore.log.first['id']!), isTrue);
    expect(GenAppCalendarHomeScreenToday.items(today, dayDelta: 0).where((x) => x.rid == a || x.rid == b).length, 2);
    appStore.logAction('auto', 'בודד'); expect(appStore.log.first['group'], isNull);   // מחוץ ל-grouped אין group
  });
  test('ב׳-צה/צז · שורה-מהירה: ספרות = חיפוש · «איפה X»/«חפש X»/«מה עם X» = חיפוש X · רגע רגיל = לא', () {
    expect(balaganSearchQuery('1250'), '1250'); expect(balaganSearchQuery('052-123'), '052-123'); expect(balaganSearchQuery('7'), '');
    expect(balaganSearchQuery('איפה הפיקדון של רות'), 'הפיקדון של רות'); expect(balaganSearchQuery('חפש ארנונה'), 'ארנונה'); expect(balaganSearchQuery('מה עם הגנן'), 'הגנן');
    expect(balaganSearchQuery('שילמתי ארנונה 1,250'), ''); expect(balaganSearchQuery('איפה'), ''); expect(balaganSearchQuery('איפהשהו בעיר'), '');
  });
  test('ב׳-צח · התוכנית מתחילה מעכשיו: 15:03 ⇒ 15:05 · 07:00 ⇒ 09:00 · יום אחר ⇒ 09:00', () {
    expect(balaganPlanStart(today, 9, DateTime(2026, 9, 8, 15, 3)), DateTime(2026, 9, 8, 15, 5));
    expect(balaganPlanStart(today, 9, DateTime(2026, 9, 8, 7, 0)), DateTime(2026, 9, 8, 9, 0));
    expect(balaganPlanStart(today, 9, DateTime(2026, 9, 9, 15, 3)), DateTime(2026, 9, 8, 9, 0));
    expect(balaganPlanStart(today, 9, DateTime(2026, 9, 8, 9, 0)), DateTime(2026, 9, 8, 9, 0));
  });
  test('ב׳-צט · לשון-עבר: «שילמתי ארנונה» כן · «לשלם ארנונה» לא · «אתמול קיבלתי מכתב» כן · «רותי: …» לא · תיק-פתוח-תואם ⇒ «סיימת אותו?» ⇒ סגירה עם החזר', () {
    expect(balaganIsPast('שילמתי ארנונה'), isTrue); expect(balaganIsPast('לשלם ארנונה'), isFalse); expect(balaganIsPast('אתמול קיבלתי מכתב מהעירייה'), isTrue);
    expect(balaganIsPast('רותי: תור לרופא'), isFalse); expect(balaganIsPast('בית ספר מחר'), isFalse); expect(balaganIsPast(''), isFalse);
    final m = kBalaganModules.firstWhere((x) => x.stages > 0 && x.descField.isNotEmpty && x.dateFields.isNotEmpty && (x.personFields.isEmpty || x.descField != x.personFields.first));
    final S = m.rootSlug; final D = m.descField; final F = m.dateFields.first;
    final id = appStore.add(S, {D: 'להחזיר מקדחה לשכן', F: '2026-09-01', '__stage': '0'});   // מילה ייחודית — בדיקות קודמות זרעו «ארנונה» באותו מודול
    final closed = appStore.add(S, {D: 'להחזיר מקדחה ישנה', F: '2026-08-01', '__stage': (m.stages - 1).toString()});
    final hits = balaganPastMatches(m, 'החזרתי מקדחה'); expect(hits.map((r) => r['__id']).toList(), [id]); expect(hits.any((r) => r['__id'] == closed), isFalse);
    expect(balaganPastMatches(m, 'שילמתי לגנן'), isEmpty); expect(balaganPastMatches(m, 'לשלם ארנונה'), isEmpty);
    balaganCloseFile(m, id);
    expect(appStore.stageOf(S, id), m.stages - 1); expect(appStore.decision('ign:' + id + ':' + appStore.log.first['field']!), 'no'); expect(appStore.log.first['kind'], 'done');
    expect(appStore.undo(appStore.log.first['id']!), isTrue); expect(appStore.stageOf(S, id), 0); expect(appStore.decision('ign:' + id + ':' + appStore.log.first['field']!), '');
  });
}
