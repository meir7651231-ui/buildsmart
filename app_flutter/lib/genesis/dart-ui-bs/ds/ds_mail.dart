// ── G33 · ds_mail (Gmail socket, client OAuth token only) ──
// הכרעה-29 · חוק-6: הטוקן של הלקוח בלבד, במכשיר (appStore.setting('mail.token')). בלי טוקן ⇒ null מיד; כשל-רשת/טוקן-פג ⇒ null (המסך אומר, לא מזייף).
import 'dart:convert';
import 'package:http/http.dart' as http;

class DsMailItem {
  const DsMailItem({required this.id, required this.subject, required this.from, required this.date, required this.snippet});
  final String id, subject, from, date, snippet;
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
      final r = await http.get(Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/messages/$id?format=metadata&metadataHeaders=Subject&metadataHeaders=From&metadataHeaders=Date'), headers: h);
      if (r.statusCode != 200) continue;
      final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map;
      final headers = (((j['payload'] as Map?)?['headers']) as List?) ?? const [];
      String hd(String name) { for (final x in headers) { if ((x as Map)['name']?.toString().toLowerCase() == name) return (x['value'] ?? '').toString(); } return ''; }
      out.add(DsMailItem(id: id, subject: hd('subject'), from: hd('from'), date: hd('date'), snippet: (j['snippet'] ?? '').toString()));
    }
    return out;
  } catch (_) {
    return null;
  }
}
