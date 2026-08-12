// 🌉 מצב-מסונן · בורר-פלטפורמה לאחסון-מפתח-ערך.
//
// import מותנה כמו `services/geo.dart`: ‏native/VM ⇒ מפה-בזיכרון (בלי
// `package:web` ⇒ מתקמפל על ה-Dart-VM של הבדיקות); web ⇒ localStorage אמיתי.
// שני הקבצים חושפים `EdgeKvStore makeEdgeKvStore()`.
export 'edge_kv_stub.dart' if (dart.library.js_interop) 'edge_kv_web.dart';
