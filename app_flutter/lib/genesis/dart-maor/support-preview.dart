/// חוט · support-preview — הומר מ-new/atoms/support-preview.mjs (זהה-ביט ל-JS).
/// מקור: maor/src/lib/supportChat.ts:76-81. חוזה: support-preview.contract.md.

/// slice בסגנון-JS (חוק 5): אינדקסים שליליים נעטפים מהסוף, גידור-אורך, קיצוץ-שלם.
String _sliceJs(String s, num start, num end) {
  final len = s.length;
  var st = start.truncate();
  var en = end.truncate();
  if (st < 0) st = len + st;
  if (en < 0) en = len + en;
  if (st < 0) st = 0;
  if (en < 0) en = 0;
  if (st > len) st = len;
  if (en > len) en = len;
  if (en <= st) return '';
  return s.substring(st, en);
}

/// trim בקבוצת-ES בלבד (חוק 16): ‏\s של regex-ES ≡ קבוצת ה-trim של JS;
/// ‏Dart.trim היה גוזם גם U+0085/U+180E — לכן regex ולא trim().
String _trimEs(String s) =>
    s.replaceAll(RegExp(r'^\s+|\s+$', unicode: true), '');

dynamic supportPreview(dynamic text, [dynamic max = 40]) {
  final t = _trimEs(
      (text ?? '').replaceAll(RegExp(r'\s+', unicode: true), ' ') as String);
  return t.length > max ? _sliceJs(t, 0, max - 1) + '…' : t;
}
