// ⚛️ אטום-Dart (דרגת-חוזה) · receiptHtml — הקבלה כ-HTML מוכן-להדפסה (טהור — מחרוזת בלבד).
// מוצא: maor/src/lib/receipt.ts:165-195 כלשונו · המקור: new/atoms/receipt-html.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// receiptLines הוזרק כשקע (חוק-1/3 — אפס import פנימי): (o)=>List<String> שורות-הטקסט.
// esc = עוזר-פנימי לא-מיוצא במקור, נכלל (שם-תורם/ייעוד = קלט חופשי ⇒ חייב escaping-XSS).
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES):
//  • `String.replace(/&/g, …)` → `replaceAll('&', …)` — הטיוטה השתמשה ב-replaceFirst
//    (רק המופע הראשון) — סטייה-מהמקור: ה-JS גלובלי. תוקן ל-replaceAll (כל המופעים).
//  • סדר-ההחלפה נשמר: & ← < ← > (זהה ל-JS; & ראשון כדי לא לברוח-כפול).
//  • `const [first, ...rest] = lines` (destructuring שהטיוטה פספסה) →
//    first=lines[0] · rest=lines.sublist(1).
//  • `.join('\n')` — הטיוטה הכניסה newline מילולי; כאן escape תקין '\n'.
//  • `o.rid` (גישת-שדה JS) → `o['rid']` על Map; שרשור-מחרוזת JS מקבל כל טיפוס ⇒ .toString().
//  • אין locale/getMonth/מודולו/תאריך — רק שרשור-מחרוזת ו-escaping.

/// הורחב-XSS: & → &amp; · < → &lt; · > → &gt; (כל המופעים, בסדר-המקור).
String esc(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// הקבלה כ-HTML מוכן-להדפסה. o=פרטי-הקבלה (דורש o['rid']) ·
/// receiptLines=שקע: (o)=>List<String> שורות-הטקסט של הקבלה.
String receiptHtml(Map<String, dynamic> o,
  List<String> Function(Map<String, dynamic>) receiptLines, Map<String, String> T) {
  final lines = receiptLines(o).where((x) => x != '').toList();
  final first = lines[0];
  final rest = lines.sublist(1);
  final body =
      rest.map((ln) => '<div class="ln">' + esc(ln) + '</div>').join('\n');
  return ('<!doctype html><html dir="rtl" lang="he"><head><meta charset="utf-8">' +
      '<title>' +
      esc(T['k6']! + o['rid'].toString()) +
      '</title>' +
      '<style>' +
      'body{font-family:"Segoe UI",Arial,"Noto Sans Hebrew",sans-serif;color:#111;margin:0;padding:32px;direction:rtl}' +
      '.sheet{max-width:520px;margin:0 auto;border:1px solid #bbb;border-radius:10px;padding:28px 32px}' +
      '.mark{font-size:12px;letter-spacing:.08em;color:#555;text-align:left}' +
      '.ln{font-size:14.5px;line-height:1.9}' +
      '.ln:first-of-type{font-size:19px;font-weight:700;margin-bottom:6px}' +
      '@media print{body{padding:0}.sheet{border:none}}' +
      '</style></head><body><div class="sheet">' +
      '<div class="mark">' +
      esc(first) +
      '</div>' +
      body +
      '</div></body></html>');
}
