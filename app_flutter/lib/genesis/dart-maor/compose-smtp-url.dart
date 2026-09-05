/// חוט · compose-smtp-url — הרכבת כתובת-SMTP מלאה ממייל+סיסמה+שרת.
/// חוזה: compose-smtp-url.contract.md
/// חולץ כלשונו מ-maor/src/lib/smtpUrl.ts:33-41 (תורגם TS→JS→Dart).
String? composeSmtpUrl(String email, String password, String host) {
  final em = email.trim();
  final pw = password.trim();
  final h = host.trim();
  // JS truthiness על מחרוזות: ריק = falsy ⇒ isEmpty; em.indexOf('@') < 1 שומר על "@ במיקום ≥1".
  if (em.isEmpty || pw.isEmpty || h.isEmpty || em.indexOf('@') < 1) return null;
  // /:465$/ — סיומת ':465'.
  final scheme = h.endsWith(':465') ? 'smtps' : 'smtp';
  // Uri.encodeComponent ≡ encodeURIComponent (אותה קבוצת תווים-לא-שמורים).
  return '$scheme://${Uri.encodeComponent(em)}:${Uri.encodeComponent(pw)}@$h';
}
