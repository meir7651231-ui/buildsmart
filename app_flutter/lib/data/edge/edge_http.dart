// 🌉 מצב-מסונן · שולח-HTTP אמיתי ל-EdgeRestAuth.
//
// `package:http` חוצה-פלטפורמה: על web ⇒ ‏BrowserClient (fetch/XHR) לתת-דומיין
// המאושר של המתווך — הסנן רואה רק `*.buildsmart-il.com`. מוזרק ל-EdgeRestAuth
// (שנשאר טהור). לא-נקרא בבדיקות/native (הספק דלוק רק במצב-מסונן על web).

import 'package:buildsmart/data/edge/rest_auth.dart';
import 'package:http/http.dart' as http;

/// בונה את חוזה-השליחה של EdgeRestAuth מעל `package:http`.
EdgeHttpSend makeEdgeHttpSend() {
  return (Uri url, Map<String, String> headers, String body) async {
    final res = await http.post(url, headers: headers, body: body);
    return (status: res.statusCode, body: res.body);
  };
}

/// חוזה-שליחה נושא-מתודה (GET/PATCH/POST) — שכבת-הנתונים (Firestore-REST, שלב D)
/// צריכה GET למסמך ו-PATCH לכתיבה, לא רק POST. מוזרק ⇒ נבדק בלי HTTP אמיתי.
typedef EdgeHttpRequest = Future<({int status, String body})> Function(
  String method,
  Uri url,
  Map<String, String> headers,
  String? body,
);

/// גרסת-ריצה מעל `package:http`. על web ⇒ fetch לתת-דומיין המתווך.
EdgeHttpRequest makeEdgeHttpRequest() {
  return (String method, Uri url, Map<String, String> headers,
      String? body) async {
    final req = http.Request(method, url)..headers.addAll(headers);
    if (body != null) req.body = body;
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return (status: res.statusCode, body: res.body);
  };
}
