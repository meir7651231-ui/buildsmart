// ⚛️ אטום-Dart (דרגת-חוזה) · pending
// תפקיד: קריאה-שמורה (guarded) של תור-ההזמנות-האופליין המתמיד — מחזיר את הישויות
//        בתור (FIFO, ותיק-ראשון); כל כשל-קריאה/פענוח ⇒ רשימה-ריקה + לוג; לעולם לא זורק.
//        משמש offline_order_queue ("ממתין לסנכרון").
// מוצא: buildsmart/app_flutter/lib/logic/offline_order_queue.dart:243-251
//        (‏OfflineOrderQueue.pending; חוק-4 — הקוד-החלוץ קדוש; המקור בענף-החי
//        origin/claude/whats-happening-LyY9G).
// טוהר: פונקציית top-level עצמאית; אפס imports. מתודת-מופע-במקור ⇒ top-level.
// אחים-שסוקטו (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע):
//        `SharedPreferences.getInstance()`+`prefs.getString(kOfflineOrdersKey)` ⇒ שקע `readRaw`
//        (שקע-אחד — במקור שתיהן באותו try/catch, כשל בכל-אחת נתפס יחד) ·
//        `_decode` ⇒ שקע `decode` (האח קודם כאטום decode.dart; הקופסה מחווטת) ·
//        `debugPrint` ⇒ שקע `log` (אין תלות ב-Flutter/foundation). גנרי על `T`.
//        `_serialized` — אינו-באטום: שרשרת-ההסדרה = סדר, וסדר = חיווט-קופסה
//        (תיקון-בעלים לחוק-5); קופסת-התור מריצה את האטום דרך השרשרת שלה.
//
// קלט:  readRaw — שקע: קריאת המטען-הגולמי המתמיד (Future<String?> Function()).
//       decode  — שקע: פענוח raw⇒ישויות (List<T> Function(String?)); במקור `_decode`.
//       log     — שקע: לוג-אזהרה (void Function(String)); במקור `debugPrint`.
// פלט:  Future<List<T>> — הישויות בתור כפי ש-decode החזיר; כל כשל ⇒ ריק (unmodifiable) + לוג.

/// The currently queued intents, oldest first (FIFO — replay order). Guarded:
/// any failure (readRaw OR decode) → empty list + one log line. NEVER throws.
/// Verbatim behaviour of offline_order_queue.dart:243-251 with the prefs read
/// (`readRaw`), `_decode` and `debugPrint` injected; the `_serialized` chain is
/// box wiring (ordering lives in the box).
Future<List<T>> pending<T>({
  required Future<String?> Function() readRaw,
  required List<T> Function(String?) decode,
  required void Function(String) log,
}) async {
  try {
    return decode(await readRaw());
  } on Object catch (e) {
    log('OfflineOrderQueue: pending read failed (empty): $e');
    // במקור `const <OfflineOrderIntent>[]` — ריק ובלתי-ניתן-לשינוי; const-literal
    // אסור על טיפוס-פרמטר, לכן List.empty (אותה התנהגות: ריק + לא-growable).
    return List<T>.empty();
  }
}
