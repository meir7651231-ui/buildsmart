// ⚛️ אטום-Dart (דרגת-חוזה) · segmentKeyOf
// מוצא: buildsmart/app_flutter/lib/logic/intel/segments.dart:43-49 (‏segmentKeyOf; חוק-4).
//        האטום = הפונקציה בלבד; שאר-הטיוטה (‏ActorSegment/segmentsByActor/…) אינו היעד.
//        הקובץ אינו קיים עוד ב-checkout; הטיוטה = מקור-האמת.
// טוהר: בחירת-מפתח טהורה. שקעים (חוק-3):
//        · `IntelEvent` (טיפוס-אירוע-שכן גדול) ⇒ מפורק לשני-השדות שהאטום נוגע בהם:
//          `uid` (‏String?) ו-`actorKey` (‏String?).
//        · `kAnonymousSegmentKey` — const-שכן לא-ניתן-לשחזור ⇒ שקע `anonymousKey`,
//          ברירת-מחדל מייצגת ומתועדת.
//
// פלט:  המפתח-היציב: uid לא-ריק, אחרת actorKey לא-ריק, אחרת דלי-האנונימי.

/// The STABLE merge key of an actor: [uid] if non-null-non-empty, else
/// [actorKey] if non-null-non-empty, else [anonymousKey] (the shared bucket).
/// Verbatim precedence of segments.dart:43-49 with the `IntelEvent` fields and
/// the anonymous constant injected as sockets.
String segmentKeyOf({
  String? uid,
  String? actorKey,
  String anonymousKey = 'anonymous',
}) {
  if (uid != null && uid.isNotEmpty) return uid;
  if (actorKey != null && actorKey.isNotEmpty) return actorKey;
  return anonymousKey;
}
