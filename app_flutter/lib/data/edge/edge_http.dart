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
