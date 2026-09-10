// ── G33 · ds_mail (Gmail socket, client OAuth token only) ──
// הכרעה-29 · חוק-6: הטוקן של הלקוח בלבד, במכשיר (appStore.setting('mail.token')). בלי טוקן ⇒ null מיד; כשל-רשת/טוקן-פג ⇒ null (המסך אומר, לא מזייף).
import 'dart:convert';
import 'package:http/http.dart' as http;

class DsMailItem {
  const DsMailItem({required this.id, required this.subject, required this.from, required this.date, required this.snippet, this.body = ''});
  final String id, subject, from, date, snippet;
  /// G56 · גוף-המכתב (text/plain, עד 4,000 תווים). ה-snippet הוא ~100 תווים —
  ///   «היא רואה את המכתב מהקופה» לא עובד על שורת-פתיחה.
  final String body;
  /// הטקסט שמזהה-הרגע קורא: נושא + גוף (ובלית-ברירה ה-snippet).
  String get text => (subject + '\n' + (body.trim().isEmpty ? snippet : body)).trim();
}

/// פענוח base64url של Gmail (מחליף -_ ומשלים ריפוד).
String _b64u(String s) {
  var t = s.replaceAll('-', '+').replaceAll('_', '/');
  while (t.length % 4 != 0) { t += '='; }
  try { return utf8.decode(base64Decode(t), allowMalformed: true); } catch (_) { return ''; }
}

/// הליכה רקורסיבית על עץ-החלקים ⇒ ה-text/plain הראשון (נפילה ל-text/html מנוקה מתגיות).
/// ציבורי כדי שיהיה **ניתן-להוכחה** בבדיקה בלי רשת (G56).
String dsMailPlain(Map payload) => _plainOf(payload);
String _plainOf(Map payload) {
  // שני מעברים: קודם text/plain בכל העץ, ורק אם אין — html מנוקה. מעבר-יחיד היה מחזיר
  // את החלק הראשון שהחזיר משהו, ובמכתב multipart/alternative זה תמיד ה-html (G56, נתפס בבדיקה).
  final p = _walk(payload, 'text/plain');
  if (p.trim().isNotEmpty) return p;
  final h = _walk(payload, 'text/html');
  return h.isEmpty ? '' : h.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ');
}

String _walk(Map payload, String want) {
  final mime = (payload['mimeType'] ?? '').toString();
  final data = ((payload['body'] as Map?)?['data'] ?? '').toString();
  if (mime == want && data.isNotEmpty) return _b64u(data);
  for (final part in (payload['parts'] as List?) ?? const []) {
    final t = _walk(part as Map, want);
    if (t.trim().isNotEmpty) return t;
  }
  return '';
}

/// המיילים האחרונים (Gmail REST · users/me): רשימת-מזהים ⇒ מטא (נושא · מאת · תאריך) + snippet. עד 15.
Future<List<DsMailItem>?> dsMailRecent({required String token, String query = 'newer_than:7d', int max = 15}) async {
  if (token.trim().isEmpty) return null;
  final h = {'Authorization': 'Bearer ${token.trim()}'};
  try {
    final list = await http.get(Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=$max&q=${Uri.encodeQueryComponent(query)}'), headers: h);
    if (list.statusCode != 200) return null;
    final ids = ((jsonDecode(utf8.decode(list.bodyBytes))['messages'] as List?) ?? const []).map((m) => (m as Map)['id'].toString()).toList();
    final out = <DsMailItem>[];
    for (final id in ids) {
      // G56 · format=full — בלעדיו יש רק ~100 תווים של snippet, והזיהוי עובד על שורת-הפתיחה.
      final r = await http.get(Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/messages/$id?format=full'), headers: h);
      if (r.statusCode != 200) continue;
      final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map;
      final headers = (((j['payload'] as Map?)?['headers']) as List?) ?? const [];
      String hd(String name) { for (final x in headers) { if ((x as Map)['name']?.toString().toLowerCase() == name) return (x['value'] ?? '').toString(); } return ''; }
      final payload = (j['payload'] as Map?) ?? const {};
      final body = _plainOf(payload);
      out.add(DsMailItem(id: id, subject: hd('subject'), from: hd('from'), date: hd('date'), snippet: (j['snippet'] ?? '').toString(), body: body.length > 4000 ? body.substring(0, 4000) : body));
    }
    return out;
  } catch (_) {
    return null;
  }
}
