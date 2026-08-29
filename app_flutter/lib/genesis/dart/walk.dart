// ⚛️ אטום-Dart (דרגת-חוזה) · walk
// תפקיד: חיפוש-עומק רקורסיבי (DFS קדם-סדר) של הצומת הראשון בעץ CatalogNode
//        שכותרתו או ה-lipskeyCategory שלו שווים ל-title; עצירה-מוקדמת אם כבר נמצא.
// מוצא: buildsmart/app_flutter/lib/logic/category_division.dart:86-95 (ה-closure `walk`
//       בתוך resolveCatTitle; חוק-4 — verbatim). המקור בגיט: commit 54d5e20e
//       (הקובץ אינו בעץ-העבודה הנוכחי של buildsmart — חולץ מההיסטוריה).
// אחים: במקור זה closure שסוגר על שני חיצוניים: `title` (קריאה) ו-`hit` (קריאה+כתיבה).
//       כאן הופך לפונקציית-top-level עצמאית: `title` ⇒ פרמטר; `hit` ⇒ מחזיק-מוטבל
//       CatalogHit המוזרק כפרמטר (חוק-3: הסגירה החיצונית ⇒ שקע; Dart לא מעביר
//       מקומי-nullable by-ref, לכן מחזיק מינימלי). הגוף verbatim פרט ל-`hit`⇒`hit.node`.
//       הזנב בטיוטה (לולאת kCatalogTree + עלה-סינתטי catalogRepo) שייך לפונקציה-העוטפת
//       resolveCatTitle ואינו חלק מ-closure זה — הושמט (תקדים: collect.dart).
//       טיפוס-השכן CatalogNode הוטבע inline (השדות הנקראים בלבד).
// טוהר: dart:core בלבד. אפס-דאטה: העץ, הכותרת והמחזיק מוזרקים.

/// אם [hit] כבר מלא ⇒ יציאה מיידית (בלי לגעת בו). אחרת: התאמה על [n] עצמו
/// (title או lipskeyCategory שווים ל-[title]) ⇒ נכתב ל-[hit] ועוצרים; אחרת
/// רקורסיה על הילדים בסדרם. verbatim category_division.dart:86-95.
void walk(CatalogNode n, String title, CatalogHit hit) {
  if (hit.node != null) return;
  if (n.title == title || n.lipskeyCategory == title) {
    hit.node = n;
    return;
  }
  for (final c in n.children) {
    walk(c, title, hit);
  }
}

/// מחזיק-התוצאה המוטבל — במקור המשתנה המקומי `CatalogNode? hit` שה-closure סוגר
/// עליו (resolveCatTitle, שורה 85). מוזרק כדי לאפשר לולאת-יער עם עצירה-מוקדמת.
class CatalogHit {
  CatalogHit([this.node]);
  CatalogNode? node;
}

// — טיפוס-השכן מוטבע (השדות הנקראים ע"י האטום בלבד) —
class CatalogNode {
  const CatalogNode({
    required this.title,
    this.lipskeyCategory,
    this.children = const [],
  });

  final String title;
  final String? lipskeyCategory;
  final List<CatalogNode> children;
}
