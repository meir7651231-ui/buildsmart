// ⚛️ אטום-Dart (דרגת-חוזה) · configOpFromJson
// מוצא: buildsmart/app_flutter/lib/logic/studio/config_op.dart:77-107
//        (‏configOpFromJson; חוק-4 — התנהגות זהה בדיוק, לא-משופרת, Dart נשאר Dart).
// טוהר: פונקציית top-level עצמאית + גנרית, אפס import פנימי (רק שפה/סטנדרט —
//        ‏Map.map / toString / num.toInt). התיוג-הסגור (op-tags) נשמר verbatim.
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   שֵש בנאי-השכן של המשפחה-הסגורה (config_store.dart: SetText·SetEmoji·SetHidden·
//   SetOrder·SetStyle·SetAction) ⇒ שֵש שקעי-בנייה. סוג-ההחזרה `ConfigOp?` ⇒ גנרי T.
//     • setText(id, text?)     — SetText(id, t is String ? t : null)   (:88)
//     • setEmoji(id, emoji?)   — SetEmoji(id, e is String ? e : null)  (:91)
//     • setHidden(id, hidden?) — SetHidden(id, h is bool ? h : null)   (:94)
//     • setOrder(id, order?)   — SetOrder(id, o is num ? o.toInt() : null) (:97)
//     • setStyle(id, style?)   — SetStyle(id, s is Map ? CfgStyle.fromJson(_strMap(s)) : null) (:100)
//     • setAction(id, action?) — SetAction(id, a is Map ? CfgAction.fromJson(_strMap(a)) : null) (:103)
//   בשני האחרונים קריאת-השכן `CfgStyle/CfgAction.fromJson` (config_node.dart) חיה
//   בתוך-השקע: האטום עושה את שמירת-הבית (‏is Map ⇒ נרמול-מפתחות _strMap, אחרת null)
//   ומוסר `Map<String,dynamic>?` לשקע; הרכבת ה-fromJson היא חיווט-קופסה.
//
// קלט:  raw — Object? : ה-JSON הגולמי לפענוח (מפה, או כל דבר אחר).
//       שֵש שקעי-בנייה required (T Function(...)) — בונים את וריאנט-האטום המתאים.
// פלט:  T? — האטום שנבנה, או null כשאין זיהוי (‏TOTAL — לעולם לא זריקה).

/// §69 — הופכי-סובלני של `op.toJson()` (config_op.dart:77-107): משחזר וריאנט-אטום
/// מ-[raw], או `null` כשאינו op-מוכר. לעולם לא זורק: קלט-שאינו-מפה, id חסר/ריק,
/// תג-op לא-מוכר/חסר, או שדה שגוי-טיפוס — כולם מתדרדרים ל-null. כל קריאת-שדה
/// שמורה ב-`is` (לא `as`) כדי ש-JSON עוין לא יתפוצץ.
T? configOpFromJson<T>(
  Object? raw, {
  required T Function(String id, String? text) setText,
  required T Function(String id, String? emoji) setEmoji,
  required T Function(String id, bool? hidden) setHidden,
  required T Function(String id, int? order) setOrder,
  required T Function(String id, Map<String, dynamic>? style) setStyle,
  required T Function(String id, Map<String, dynamic>? action) setAction,
}) {
  if (raw is! Map) return null;
  final j = raw.map((k, v) => MapEntry(k.toString(), v));

  final rawId = j['id'];
  if (rawId is! String || rawId.isEmpty) return null; // fail-closed on identity
  final id = rawId;

  switch (j['op']) {
    case 'setText':
      final t = j['text'];
      return setText(id, t is String ? t : null);
    case 'setEmoji':
      final e = j['emoji'];
      return setEmoji(id, e is String ? e : null);
    case 'setHidden':
      final h = j['hidden'];
      return setHidden(id, h is bool ? h : null);
    case 'setOrder':
      final o = j['order'];
      return setOrder(id, o is num ? o.toInt() : null);
    case 'setStyle':
      final s = j['style'];
      return setStyle(id, s is Map ? _strMap(s) : null);
    case 'setAction':
      final a = j['action'];
      return setAction(id, a is Map ? _strMap(a) : null);
    default:
      return null; // unknown / missing tag → drop (degrade, never throw)
  }
}

/// נרמול-מפתחות למפה מקוננת (‏config_op.dart:143-144, `_strMap`) — שכבת-הפלטפורמה
/// עלולה להחזיר `Map<Object?,Object?>`. סטנדרט-שפה בלבד (Map.map + toString) ⇒
/// מוטמע באטום, לא-אטום-שכן (כלל-הגלגול: עוזר-תמיכה פרטי, לא נגזרת עצמאית).
Map<String, dynamic> _strMap(Map<dynamic, dynamic> m) =>
    m.map((k, v) => MapEntry(k.toString(), v));
