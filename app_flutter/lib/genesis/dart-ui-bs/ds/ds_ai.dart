// ── G33 · ds_ai (AI socket, client key only) ──
// הכרעה-29 · חוק-6: המפתח של הלקוח בלבד, נשמר במכשיר (appStore.setting('ai.key')), לעולם לא אצלנו. בלי מפתח ⇒ null מיד, אפס-זיוף.
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// מחלץ שדות ⇒ ערך מטקסט/צילום דרך Anthropic Messages API. מחזיר null בכשל (המסך אומר «תכתוב שורה»).
/// תמיד מוסיף '_text' = תמלול קצר (כדי שמזהה-הרגע הדטרמיניסטי יעבוד על הצילום).
Future<Map<String, String>?> dsAiExtract({required String apiKey, String? text, Uint8List? image, String imageMime = 'image/jpeg', required List<String> fields, String model = 'claude-sonnet-5'}) async {
  if (apiKey.trim().isEmpty) return null;
  final content = <Map<String, dynamic>>[];
  if (image != null) content.add({'type': 'image', 'source': {'type': 'base64', 'media_type': imageMime, 'data': base64Encode(image)}});
  content.add({'type': 'text', 'text': 'חלץ מהמסמך/הטקסט את השדות הבאים והחזר JSON בלבד (מפתח = שם-השדה בעברית, ערך = מחרוזת; תאריך = YYYY-MM-DD; סכום = ספרות בלבד; חסר = ""). הוסף מפתח "_text" עם תמלול קצר של המסמך (עד 400 תווים).\nשדות: ${fields.join(' · ')}\n${text ?? ''}'});
  try {
    final res = await http.post(Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {'content-type': 'application/json', 'x-api-key': apiKey.trim(), 'anthropic-version': '2023-06-01', 'anthropic-dangerous-direct-browser-access': 'true'},
        body: jsonEncode({'model': model.trim().isEmpty ? 'claude-sonnet-5' : model.trim(), 'max_tokens': 800, 'messages': [{'role': 'user', 'content': content}]}));
    if (res.statusCode != 200) return null;
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    final parts = (body is Map ? body['content'] as List? : null) ?? const [];
    final txt = parts.map((p) => (p is Map ? p['text'] : null) ?? '').join('\n');
    final m = RegExp(r'\{[\s\S]*\}').firstMatch(txt);
    if (m == null) return null;
    final j = jsonDecode(m.group(0)!);
    if (j is! Map) return null;
    return j.map((k, v) => MapEntry(k.toString(), v == null ? '' : v.toString()));
  } catch (_) {
    return null;
  }
}
