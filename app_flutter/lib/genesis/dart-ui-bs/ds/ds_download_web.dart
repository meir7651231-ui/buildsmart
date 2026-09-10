// אטום-הצבה (placement) · הורדת-קובץ בדפדפן (Blob + <a download>). חוצה package:web —
// גבול-פלטפורמה מבוקר (חוק-6: הצבה, לא אטום-טהור). אפס-שרת: הקובץ נוצר במכשיר ונשאר בו.
// G51 · «גיבוי» שהוא רק העתקה-ללוח נותן ביטחון-שווא — קובץ שירד הוא הראיה היחידה.
import 'dart:js_interop';
import 'package:web/web.dart' as web;

bool downloadText(String filename, String text, [String mime = 'application/json']) {
  try {
    final blob = web.Blob(<JSAny>[text.toJS].toJS, web.BlobPropertyBag(type: '$mime;charset=utf-8'));
    final url = web.URL.createObjectURL(blob);
    final a = web.document.createElement('a') as web.HTMLAnchorElement;
    a.href = url;
    a.download = filename;
    a.click();
    web.URL.revokeObjectURL(url);
    return true;
  } catch (_) {
    return false;
  }
}
