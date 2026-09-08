// אטום-הצבה · דיבור⇒טקסט דרך SpeechRecognition של הדפדפן (חוק-6: גבול-פלטפורמה מבוקר, אפס-שרת שלנו;
// הזיהוי עצמו אצל ספק-הדפדפן). לא נתמך ⇒ null. תוצאה = הטקסט הסופי של הביטוי הראשון.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

@JS('webkitSpeechRecognition')
external JSFunction? get _webkitCtor;
@JS('SpeechRecognition')
external JSFunction? get _stdCtor;

bool get voiceSupported => _stdCtor != null || _webkitCtor != null;

Future<String?> voiceListen(String lang) async {
  final ctor = _stdCtor ?? _webkitCtor;
  if (ctor == null) return null;
  final rec = ctor.callAsConstructor<JSObject>();
  rec.setProperty('lang'.toJS, lang.toJS);
  rec.setProperty('interimResults'.toJS, false.toJS);
  rec.setProperty('maxAlternatives'.toJS, 1.toJS);
  final done = Completer<String?>();
  void finish(String? v) { if (!done.isCompleted) done.complete(v); }
  rec.setProperty('onresult'.toJS, ((JSObject e) {
    try {
      final results = e.getProperty<JSObject>('results'.toJS);
      final first = results.getProperty<JSObject>('0'.toJS);
      final alt = first.getProperty<JSObject>('0'.toJS);
      final t = alt.getProperty<JSString>('transcript'.toJS).toDart;
      finish(t.trim());
    } catch (_) { finish(null); }
  }).toJS);
  rec.setProperty('onerror'.toJS, ((JSObject e) { finish(null); }).toJS);
  rec.setProperty('onend'.toJS, ((JSObject e) { finish(null); }).toJS);
  try { rec.callMethod('start'.toJS); } catch (_) { return null; }
  // web.window נשמר ליבוא-עקבי עם שאר אטומי-ההצבה (localStorage) — כאן לא נדרש
  web.window;
  return done.future.timeout(const Duration(seconds: 15), onTimeout: () { try { rec.callMethod('stop'.toJS); } catch (_) {} return null; });
}
