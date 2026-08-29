// חוט · ayin-sheet-rows — שורות ייצוא גיליון-העיניים. חוזה: ayin-sheet-rows.contract.md
// המרת-Dart זהה-ביט למקור new/atoms/ayin-sheet-rows.mjs (חולץ מ-maor/src/lib/ayin.ts:380-418).
// הכותרת AYIN_SHEET_HEADER הוטבעה כאן (אפס import פנימי, חוק-1). דארט-ליבה בלבד.

List<List<String>> ayinSheetRows(List<dynamic> supporters, {required String Function(String) term, required List<dynamic> ayinSheetHeader}) {
  final List<List<String>> rows = [
    [...ayinSheetHeader]
  ];
  for (final sp in supporters) {
    final a = sp['ayin'];
    if (a == null) continue; // JS: if (!a) continue — ayin חסר/undefined ⇒ מדולג
    final List<dynamic> answers = a['answers'] as List<dynamic>;
    // JS: a.answers[0] על מערך ריק ⇒ undefined (falsy) ⇒ נופל ל-answeredNote
    final lastAns = answers.isNotEmpty ? answers[0] : null;
    final String leadDone =
        ['eyes', 'answer', 'done'].contains(a['stage']) ? term('kn') : term('la');
    for (final n in (a['names'] as List<dynamic>)) {
      final eyes = n['eyes'];
      // JS: lastAns ? lastAns.note : (a.answeredNote || '')
      final String note = (lastAns != null
          ? lastAns['note'] as String
          : ((a['answeredNote'] as String?) ?? ''));
      rows.add([
        sp['name'] as String,
        (sp['phone'] ?? '') as String,
        n['name'] as String,
        (eyes == '' || eyes == null) ? '' : eyes.toString(),
        n['done'] == true ? term('kn') : term('la'),
        a['paid'] == true ? term('kn') : term('la'),
        note.replaceAll(',', ' '), // JS: /,/g — גלובלי, כל הפסיקים
        leadDone,
      ]);
    }
  }
  return rows;
}
